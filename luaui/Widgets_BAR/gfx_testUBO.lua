--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-----------------------------------------------------------------
-- Shader Sources
-----------------------------------------------------------------

local vsSrc = [[
#version 150 compatibility

#extension GL_ARB_uniform_buffer_object : require
#extension GL_ARB_shading_language_420pack: require

#line 1016

layout(std140, binding = 0) uniform UniformConstantsBuffer {
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

	vec4 timeInfo; //gameFrame, gameSeconds, drawFrame, frameTimeOffset
	vec4 viewGemetry; //vsx, vsy, vpx, vpy
	vec4 mapSize; //xz, xzPO2
};

void main() {
/*
	mat4 billBoard = cameraView;
	billBoard[0].xyz = vec3(1, 0, 0);
	billBoard[1].xyz = vec3(0, 1, 0);
	billBoard[2].xyz = vec3(0, 0, 1);
*/

	//gl_Position = cameraProj * cameraView * vec4(gl_Vertex.xyz, 1.0);
    //gl_Position = cameraProj * billBoard * vec4(gl_Vertex.xyz, 1.0);
	//gl_Position = shadowViewProj * vec4(gl_Vertex.xyz, 1.0);
	//gl_Position = gl_ModelViewProjectionMatrix * vec4(gl_Vertex.xyz, 1.0);
	//gl_Position = screenProj * billBoard * vec4(gl_Vertex.xyz, 1.0);
	gl_Position = cameraProj * cameraBillboard * vec4(gl_Vertex.xyz, 1.0);
	//gl_Position = cameraProj * cameraView * vec4(gl_Vertex.xyz, 1.0);
	
	//gl_Position = screenProj * screenView * vec4(gl_Vertex.xyz, 1.0);
	
}
	
]]

local fsSrc = [[
#version 150 compatibility

#extension GL_ARB_uniform_buffer_object : require
#extension GL_ARB_shading_language_420pack: require

#line 2045

void main() {
    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
]]


-----------------------------------------------------------------
-- Global Variables
-----------------------------------------------------------------

local vsx, vsy
local shader

-----------------------------------------------------------------

function widget:GetInfo()
  return {
	name      = "Test UBO",
	version   = 3,
	desc      = "Bla",
	author    = "ivand",
	date      = "2020",
	license   = "GPL V2",
	layer     = -99999990,
	enabled   = true
  }
end

function widget:Initialize()
	vsx, vsy = Spring.GetViewGeometry()
	shader = gl.CreateShader({
		vertex = vsSrc,
		geometry = gsSrc,
		fragment = fsSrc,
	})
end

function widget:Finalize()
	gl.DeleteShader(shader)
end

function widget:ViewResize()
	widget:Finalize()
	widget:Initialize()
end

local function DrawSomething(x, y, z, rad)
	gl.PushMatrix() --This is the start of an openGL function.
	gl.LineStipple(true)
	gl.LineWidth(2.0)
	gl.Color(1, 0, 0, 1)
	gl.DrawGroundCircle(x, y, z, rad, 40) -- draws a simple circle.
	gl.Translate(x, y, z)
	gl.Billboard()
	gl.Text("Selecting ", 30, -25, 36, "v") -- Displays text. First value is the string, second is a modifier for x (in this case it's x-25), third is a modifier for y, fourth is the size, then last is a modifier for the text itself. "v" means vertical align.
	gl.Color(1, 1, 1, 1) -- we have to reset what we did here.
	gl.LineWidth(1.0)
	gl.LineStipple(false)
	gl.PopMatrix() -- end of function. Have to use this with after a push!
end

--function widget:DrawScreen()
function widget:DrawWorldPreUnit()
	gl.UseShader(shader)
		gl.DepthTest(false)
		--DrawSomething(3500, 120, 3500, 100)		
		gl.PushMatrix()
		--gl.LoadIdentity()
		--gl.Translate(3500, 150, 3500)
		gl.Billboard()
		--gl.Color(1, 0, 0, 1)
		gl.TexRect(0, 0, vsx / 2, vsy / 2)
		gl.PopMatrix()
		gl.DepthTest(true)
	gl.UseShader(0)
end