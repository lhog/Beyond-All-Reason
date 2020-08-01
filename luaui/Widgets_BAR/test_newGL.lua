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

function widget:Initialize()

	--local view = gl.Matrix(); view:SunViewMatrix(false);
	local view = gl.GetMatrix(); view:SunViewMatrix(false);
	local proj = gl.GetMatrix(); proj:SunProjMatrix(false);
	local viewProj = proj:DeepCopy(); viewProj:SunViewMatrix(true);
	local vec = {1, 0, 1, 1}
	local viewVec = view * vec
	local projVec = proj * viewVec

	Spring.Echo("METHOD1")
	Spring.Echo(projVec)
	Spring.Echo("METHOD2")
	Spring.Echo(proj * view * vec)
	Spring.Echo("METHOD3")
	Spring.Echo(viewProj * vec)
	
	--Spring.Echo(gl:LuaMatrixImpl())
end