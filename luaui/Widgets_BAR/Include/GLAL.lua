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
UseShader = function(shaderID)
	if shaderID == 0 then
		activeShader = 0
	else
		 --don't care if shader is wrong, it's only for bookkeeping purpose
		activeShader = shaderID
	end
	orig.UseShader(shaderID)
end

ActiveShader = function(shaderID, glFunc, ...)
	if shaderID == 0 then
		activeShader = 0
		return
	end

	activeShader = shaderID
	orig.ActiveShader(shaderID, glFunc, ...)
	activeShader = 0
end


local vertIndices = {}
local function UpdateVertexIndicesForQuad()
	vertIndices = {}
	local quadsCount = math.floor(vertexCounter / 4)
	for quad = 0, quadsCount - 1 do
		-- Upper triangle of QUAD
		table.insert(vertIndices, 4 * quad + 0) --tl
		table.insert(vertIndices, 4 * quad + 1) --tr
		table.insert(vertIndices, 4 * quad + 2) --br

		-- Lower triangle of QUAD
		table.insert(vertIndices, 4 * quad + 2) --br
		table.insert(vertIndices, 4 * quad + 3) --bl
		table.insert(vertIndices, 4 * quad + 0) --tl
	end

	gl.VertexIndices(vertIndices)
end


local vertexTypes = {
	"VA_TYPE_0", -- p
	"VA_TYPE_C", -- p, c
	"VA_TYPE_T", -- p, st
	"VA_TYPE_T4", -- p, uvwz
	"VA_TYPE_TN", -- p, st, n
	"VA_TYPE_TC", -- p, st, c
	"VA_TYPE_2D0", -- x, y
	"VA_TYPE_2DT", -- x, y, st
	"VA_TYPE_2DTC", -- x, y, st, c
	"VA_TYPE_L", -- p, n, uvwz, c0, c1
}

local defaultShaders = {}
local function CompileDefaultShader(shType)
	local shaderSrc = gl.GetDefaultShaderSources(shType)
	Spring.Echo("shaderSrc", shaderSrc)
	for k, v in pairs(shaderSrc) do
		Spring.Echo(k, v)
	end
end

local function CondEnableDisableDefaultShaders(shType, glCallFunc, ...)
	if activeShader ~= 0 then --someone else activated non-default shader
		glCallFunc(...)
		return
	end

	if not defaultShaders[shType] then
		defaultShaders[shType] = CompileDefaultShader(shType)
	end

	activeShader = defaultShaders[shType]
	--orig.ActiveShader(defaultShaders[shType], glCallFunc, ...)
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

	CondEnableDisableDefaultShaders("VA_TYPE_TC", orig.BeginEnd, glType, glCallFunc, ...)

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
end

-----------------------------------------------------------------
-- Maintenance
-----------------------------------------------------------------
else



end