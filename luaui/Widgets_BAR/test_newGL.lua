function widget:GetInfo()
   return {
      name      = "Test new OpenGL API",
      layer     = 0,
      enabled   = false,
   }
end

local shader
local largeVAO

local smallVAOs = {}

local numRects = 200
local testSmall = true

local vsSrc = [[
#version 150 compatibility

#extension GL_ARB_uniform_buffer_object : require
#extension GL_ARB_shading_language_420pack: require

#line 1023

layout(std140, binding = 0) uniform UniformMatrixBuffer {
	mat4 screenView;
	mat4 screenProj;
	mat4 screenViewProj;

	mat4 cameraView;
	mat4 cameraProj;
	mat4 cameraViewProj;
	mat4 cameraBillboard;

	mat4 cameraViewInv;
	mat4 cameraProjInv;
	mat4 cameraViewProjInv;

	mat4 shadowView;
	mat4 shadowProj;
	mat4 shadowViewProj;

	//TODO: minimap matrices
};

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

void main() {
	gl_Position = proj * view * model * gl_Vertex;
	gl_Position = cameraViewProj * model * gl_Vertex;
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
]]

local fsSrc = [[
#version 150 compatibility

#line 2045

void main() {
    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
]]

function widget:Initialize()

	vsx, vsy = Spring.GetViewGeometry()
	shader = gl.CreateShader({
		vertex = vsSrc,
		geometry = gsSrc,
		fragment = fsSrc,
	})

	--local view = gl.Matrix(); view:ShadowViewMatrix(false);
	local view = gl.GetMatrix(); view:ShadowViewMatrix(false);
	local proj = gl.GetMatrix(); proj:ShadowProjMatrix(false);

	--Spring.Echo(view:GetAsTable())
	local vec = {1, 0, 1, 1}
	local viewVec = view * vec
	--Spring.Echo(viewVec)

	local rotate = gl.GetMatrix();
	local vec2 = {0, 1, 0, 1}
	rotate:RotateDegX(180)
	--Spring.Echo(rotate * vec2)
--[[
	local viewProj = proj:DeepCopy(); viewProj:ShadowViewMatrix(true);
	local vec = {1, 0, 1, 1}
	local viewVec = view * vec
	local projVec = proj * viewVec

	Spring.Echo("METHOD1")
	Spring.Echo(projVec)
	Spring.Echo("METHOD2")
	Spring.Echo(proj * view * vec)
	Spring.Echo("METHOD3")
	Spring.Echo(viewProj * vec)
]]--
	--Spring.Echo(gl:LuaMatrixImpl())

	--Spring.Echo("METHOD1")
	local proj = gl.GetMatrix(); proj:CameraProjMatrix(0, false);
	local view = gl.GetMatrix(); view:CameraViewMatrix(0, false);
	local viewProj = proj * view;
	--Spring.Echo(viewProj:GetAsTable())

	--Spring.Echo("METHOD2")
	local viewProj2 = proj:DeepCopy()
	viewProj2:CameraViewMatrix(0, true);
	--Spring.Echo(viewProj2:GetAsTable())
	
	Spring.Echo("GL_ARB_uniform_buffer_object", gl.HasExtension("GL_ARB_uniform_buffer_object"))
	Spring.Echo("GL_ARB_shading_language_420pack", gl.HasExtension("GL_ARB_shading_language_420pack"))

end

function widget:Finalize()
	gl.DeleteShader(shader)
end

--[[
function widget:DrawWorld()
	local proj = gl.GetMatrix(); proj:CameraProjMatrix(0, false);
	local view = gl.GetMatrix(); view:CameraViewMatrix(0, false);
	local viewProj = proj * view;
	--Spring.Echo(viewProj * {0, 0, 0, 1})
	--Spring.Echo(viewProj:GetAsTable())
end
]]--


local cnt = 0
function widget:DrawWorld()
	--Spring.Echo(gl.GetViewRange(0))

	local proj = gl.GetMatrix(); proj:CameraProjMatrix(0, false);
	local view = gl.GetMatrix(); view:CameraViewMatrix(0, false);

	cnt = cnt + 1

	local model = gl.GetMatrix();
	--model:RotateDeg(cnt / 60, 0, 1, 0);
	model:Translate(4184, 0, 3702)
	model:RotateDeg(cnt / 10, 0, 1, 0);

	gl.PushMatrix()

	gl.Translate(4184, 0, 3702)
	gl.Rotate(cnt / 10, 0, 1, 0);

	--Spring.Echo(proj:GetAsTable())
	--Spring.Echo(gl.GetMatrixData("camprj"))
	gl.UseShader(shader)
		gl.UniformMatrix(gl.GetUniformLocation(shader, "view"), view)
		gl.UniformMatrix(gl.GetUniformLocation(shader, "proj"), proj)
		gl.UniformMatrix(gl.GetUniformLocation(shader, "model"), model)
		gl.DepthTest(false)
		--gl.DrawGroundCircle(4184, 307, 3702, 100, 32)
		--gl.DrawGroundQuad(-100, -50, 100, 50)
		local h = 310
		gl.Shape(GL.QUADS,{
			[1] = {v = {-100, h, -100}},
			[2] = {v = { 100, h, -100}},
			[3] = {v = { 100, h,  100}},
			[4] = {v = {-100, h,  100}},
		})

		gl.DepthTest(true)
	gl.UseShader(0)

	gl.PopMatrix()
end