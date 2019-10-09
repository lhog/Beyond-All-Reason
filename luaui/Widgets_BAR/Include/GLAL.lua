-- Spring OpenGL abstraction layer (GLAL). Abstracts away the difference between maintenance and develop engines

local isDevelop = gl.CreateVertexArray ~= nil

if isDevelop then
-----------------------------------------------------------------
-- Develop
-----------------------------------------------------------------


local orig = {
	Vertex = gl.Vertex,
	BeginEnd = gl.BeginEnd,
	Color = gl.Color,
	UseShader = gl.UseShader,
	ActiveShader = gl.ActiveShader,
	TexRect = gl.TexRect,
	Rect = gl.Rect,
	Texture = gl.Texture,
}

local inBeginEnd = false
local vertexCounter = 0

gl.CreateList = function(functionName, ...)
	return {
		func = functionName,
		args = {...},
	}
end

gl.CallList = function(dl)
	dl.func(unpack(dl.args))
end

gl.DeleteList = function(dl)
	dl = nil
end

gl.DrawListAtUnit = function(unitID, listID, midPos, ...)
	gl.DrawFuncAtUnit(unitID, listID, midPos)
end

gl.LineStipple = function(arg1, arg2)
	-- Not Implemented
end

gl.LineWidth = function(width)
	-- Not Implemented
end

gl.Fog = function(width)
	-- Not Implemented
end

gl.FogCoord = function(width)
	-- Not Implemented
end

gl.PointSize = function(size)
	-- Not Implemented
end

gl.AlphaTest = function(arg1, arg2)
	-- Not Implemented
end

gl.Vertex = function(arg1, arg2, arg3, arg4)
	vertexCounter = vertexCounter + 1
	orig.Vertex(arg1, arg2, arg3, arg4)
end


local currentColor = {0, 0, 0, 0, 0, 0, 0}
gl.Color = function(r, g, b, a)
	if type(r) == "table" then
		local primColor = unpack(r)
		currentColor[1] = primColor[1]
		currentColor[2] = primColor[2]
		currentColor[3] = primColor[3]
		currentColor[4] = primColor[4]
	else
		currentColor[1] = r
		currentColor[2] = g
		currentColor[3] = b
		currentColor[4] = a
	end

	orig.Color(
		currentColor[1],
		currentColor[2],
		currentColor[3],
		currentColor[4],
		currentColor[5],
		currentColor[6],
		currentColor[7])
end

gl.SecondaryColor = function(r, g, b)
	currentColor[5] = r
	currentColor[6] = g
	currentColor[7] = b
end

local activeShader = 0
gl.UseShader = function(shaderID)
	if shaderID == 0 then
		activeShader = 0
	else
		 --don't care if shader is wrong, it's only for bookkeeping purpose
		activeShader = shaderID
	end
	orig.UseShader(shaderID)
end

gl.ActiveShader = function(shaderID, glFunc, ...)
	if shaderID == 0 then
		activeShader = 0
		return
	end

	activeShader = shaderID
	orig.ActiveShader(shaderID, glFunc, ...)
	activeShader = 0
end

local boundTextures = {}
gl.Texture = function(arg1, arg2)
	local tu
	local tex
	if arg2 == nil then
		tu = 0
		tex = arg1
	else
		tu = arg1
		tex = arg2
	end
	boundTextures[tu] = tex
	orig.Texture(tu, tex)
end


local lastDF = -1
local vertIndices
local quadIndex = 0
local function UpdateVertexIndicesForQuad()
	local df = Spring.GetDrawFrame()

	if lastDF ~= df then
		lastDF = df
		quadIndex = 0
	end

	vertIndices = {}
	local quadsCount = math.floor(vertexCounter / 4)
	for quad = 0, quadsCount - 1 do
		local q = quad + quadIndex
		-- Upper triangle of QUAD
		table.insert(vertIndices, 4 * q + 0) --tl
		table.insert(vertIndices, 4 * q + 1) --tr
		table.insert(vertIndices, 4 * q + 2) --br

		-- Lower triangle of QUAD
		table.insert(vertIndices, 4 * q + 2) --br
		table.insert(vertIndices, 4 * q + 3) --bl
		table.insert(vertIndices, 4 * q + 0) --tl
	end

	quadIndex = quadIndex + quadsCount

	gl.VertexIndices(vertIndices)
end


--[[
struct VA_TYPE_L {
	float4 p; // Lua can freely set the w-component
	float3 n;
	float4 uv; // two channels for basic texturing
	SColor c0; // primary
	SColor c1; // secondary
};
]]--
local vaTypeLShaderSources = {
	vs =
[[
#version 410 core
#extension GL_ARB_explicit_attrib_location : enable
// defines
#define VA_TYPE VA_TYPE_L

// globals
// uniforms
uniform mat4 u_movi_mat;
uniform mat4 u_proj_mat;

// VS input attributes
layout(location = 0) in vec4 a_vertex_xyzw;
layout(location = 1) in vec3 a_normal_xyz;
layout(location = 2) in vec2 a_texcoor_stuv;
layout(location = 3) in vec4 a_color0_rgba;
layout(location = 4) in vec4 a_color1_rgba;
// VS output attributes
 out vec4 v_vertex_xyzw;
 out vec3 v_normal_xyz;
 out vec2 v_texcoor_stuv;
 out vec4 v_color0_rgba;
 out vec4 v_color1_rgba;

void main() {
	gl_Position = u_proj_mat * u_movi_mat * vec4(a_vertex_xyzw          );
	v_vertex_xyzw = a_vertex_xyzw;
	v_normal_xyz = a_normal_xyz;
	v_texcoor_stuv = a_texcoor_stuv;
	v_color0_rgba = a_color0_rgba;
	v_color1_rgba = a_color1_rgba;
}
]],
	fs =
[[
#version 410 core
#extension GL_ARB_explicit_attrib_location : enable
// defines
#define VA_TYPE VA_TYPE_L

// globals
// uniforms
uniform sampler2D u_tex0;
uniform vec4 u_alpha_test_ctrl = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec3 u_gamma_exponents = vec3(1.0, 1.0, 1.0);
uniform float u_tex_loaded = 0.0;

// FS input attributes
 in vec4 v_vertex_xyzw;
 in vec3 v_normal_xyz;
 in vec2 v_texcoor_stuv;
 in vec4 v_color0_rgba;
 in vec4 v_color1_rgba;
// FS output attributes
layout(location = 0) out vec4 f_color_rgba;

void main() {
	f_color_rgba  = mix(vec4(1.0), texture(u_tex0, v_texcoor_stuv.st), u_tex_loaded);
	f_color_rgba *= v_color0_rgba * (1.0 / 255.0);

	float alpha_test_gt = float(f_color_rgba.a > u_alpha_test_ctrl.x) * u_alpha_test_ctrl.y;
	float alpha_test_lt = float(f_color_rgba.a < u_alpha_test_ctrl.x) * u_alpha_test_ctrl.z;
	if ((alpha_test_gt + alpha_test_lt + u_alpha_test_ctrl.w) == 0.0)
		discard;
	f_color_rgba.rgb = pow(f_color_rgba.rgb, u_gamma_exponents);
	f_color_rgba.rgb = vec3(u_tex_loaded);
}
]]
}

local vertexTypes = {
	["VA_TYPE_0"] = true, -- p
	["VA_TYPE_C"] = true, -- p, c
	["VA_TYPE_T"] = true, -- p, st
	["VA_TYPE_T4"] = true, -- p, uvwz
	["VA_TYPE_TN"] = true, -- p, st, n
	["VA_TYPE_TC"] = true, -- p, st, c
	["VA_TYPE_2D0"] = true, -- x, y
	["VA_TYPE_2DT"] = true, -- x, y, st
	["VA_TYPE_2DTC"] = true, -- x, y, st, c
	["VA_TYPE_L"] = true, -- p, n, uvwz, c0, c1
}

local defaultShaders = {}
local function CompileDefaultShader(shType)
	if not vertexTypes[shType] then
		return
	end

	local shaderSrc
	if shType ~= "VA_TYPE_L" then
		shaderSrc = gl.GetDefaultShaderSources(shType)
	else
		shaderSrc = vaTypeLShaderSources
	end

	local shader = gl.CreateShader({
		vertex = shaderSrc.vs,
		fragment = shaderSrc.fs,
	})

	local shLog = gl.GetShaderLog() or ""

	if not shader then
		--self:ShowError(shLog)
		Spring.Echo("CompileDefaultShader Error", shLog)
		return false
	elseif (shLog ~= "") then
		--self:ShowWarning(shLog)
		Spring.Echo("CompileDefaultShader Warning", shLog)
	end

	return shader
end

local function CondEnableDisableDefaultShaders(shType, glCallFunc, ...)
	if activeShader ~= 0 then --someone else activated non-default shader
		glCallFunc(...)
		return
	end

	if defaultShaders[shType] == nil then --can be false
		defaultShaders[shType] = CompileDefaultShader(shType)
	end

	local m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16 = gl.GetMatrixData(GL.MODELVIEW)
	--Spring.Echo(m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16)
	local p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16 = gl.GetMatrixData(GL.PROJECTION)
	--Spring.Echo(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16)

	activeShader = defaultShaders[shType]
	local viewMatLoc = gl.GetUniformLocation(activeShader, "u_movi_mat")
	local projMatLoc = gl.GetUniformLocation(activeShader, "u_proj_mat")
	local texLoadLoc = gl.GetUniformLocation(activeShader, "u_tex_loaded")

	local tu0 = (boundTextures[0] and 1.0) or 0.0

	orig.UseShader(activeShader)
		gl.UniformMatrix(viewMatLoc, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16)
		gl.UniformMatrix(projMatLoc, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16)
		gl.Uniform(texLoadLoc, tu0)
		glCallFunc(...)
	orig.UseShader(0)

	activeShader = 0
end

local GL_QUADS = GL.QUADS
local GL_TRIANGLES = GL.TRIANGLES
gl.BeginEnd = function(glType, glFuncInput, ...)
	inBeginEnd = true
	vertexCounter = 0

	local glQuads = false
	local glCallFunc

	if glType == GL_QUADS then
		glQuads = true
		glType = GL_TRIANGLES
		glCallFunc = function(...)
			glFuncInput(...)
			UpdateVertexIndicesForQuad()
		end
	else
		glCallFunc = glFuncInput
	end

	CondEnableDisableDefaultShaders("VA_TYPE_L", orig.BeginEnd, glType, glCallFunc, ...)

	vertexCounter = 0
	inBeginEnd = false
end


gl.TexRect = function(...)
	CondEnableDisableDefaultShaders("VA_TYPE_TC", orig.TexRect, ...)
end

gl.Rect = function(...)
	CondEnableDisableDefaultShaders("VA_TYPE_C", orig.Rect, ...)
end

gl.Shape = function(glType, shapeArray)
	--Spring.Echo("gl.Shape")
end

local glalScream = Script.CreateScream()
glalScream.func = function()
	Spring.Echo("GLAL UNLOAD")
	for k, v in pairs(defaultShaders) do
		if v then
			gl.DeleteShader(v)
		end
	end
end

-----------------------------------------------------------------
-- Maintenance
-----------------------------------------------------------------
else



end