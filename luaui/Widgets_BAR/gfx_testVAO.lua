function widget:GetInfo()
   return {
      name      = "Test VAO",
      layer     = 0,
      enabled   = false,
   }
end

local shader
local vao
function widget:Initialize()
	local GL_FLOAT = 0x1406
	local GL_UNSIGNED_BYTE = 0x1401

	vao = gl.GetVAO(false)

	Spring.Echo("SetVertexAttributes=", vao:SetVertexAttributes(4, {
		[0] = {name = "pos", size = 3},
		[1] = {name = "col", size = 3},
		--[1] = {name = "col", size = 3, type = GL_UNSIGNED_BYTE, normalized = true},
		--[2] = {name = "uv", size = 2},
	}))
	
	--vao:SetVertexAttributes(3, 4)
	
--[[
	Spring.Echo("SetVertexAttributes=", vao:SetVertexAttributes(4, {
		[0] = {name = "pos", size = 4},
	}))
]]--

	-- uncomment --[1] = {name = "col", size = 3},

--[[
	Spring.Echo("UploadVertexBulk=", vao:UploadVertexBulk({
		-1, -1, 0, 0, 0, 0, 0, 0,
		-1,  1, 0, 1, 0, 0, 0, 0.5,
		 1, -1, 0, 0, 1, 0, 0.5, 0.5,
		 1,  1, 0, 0, 0, 0.5, 0.5, 0,
	}))

]]--
	local x = 0.5
	vao:UploadVertexBulk({
		-1, -1, 0, x, 0, 0,
		-1,  1, 0, 0, x, 0,
		 1, -1, 0, 0, 0, x,
		 1,  1, 0, x, x, x,
	})

	Spring.Echo("SetInstanceAttributes=", vao:SetInstanceAttributes(4, 8)) -- 1 vec4
--[[
	Spring.Echo("SetInstanceAttributes=", vao:SetInstanceAttributes(1, {
		[2] = {name = "blabla", size = 4},
	})) -- 2 vec4
]]--

--[[
	Spring.Echo("UploadVertexBulk=", vao:UploadVertexBulk({
		-1, -1, 0, 0, 0, 0, 0, 0,
		-1,  1, 0, 255, 0, 0, 0, 1,
		 1, -1, 0, 0, 255, 0, 1, 1,
		 1,  1, 0, 0, 0, 255, 1, 0,
	}))
]]--

--[[
	Spring.Echo("UploadInstanceBulk=", vao:UploadInstanceBulk({
		-1, -1, 0, 0,
		-1,  1, 0, 0,
		 1,  1, 0, 0,
		 1, -1, 0, 0,
	}))
]]--

--[[
	Spring.Echo("UploadInstanceBulk=", vao:UploadInstanceBulk({
		-1, -1, 0, 0, 0, 0, 0, 0,
		-1,  1, 0, 0, 0, 0, 0, 0,
		 1, -1, 0, 0, 0, 0, 0, 0,
		 1,  1, 0, 0, 0, 0, 0, 0,
	}))
]]--

--[[
	Spring.Echo("UploadVertexAttribute=", vao:UploadVertexAttribute(0, {
		-0.5, -0.5, 0.0, 1.0,
		 0.5, -0.5, 0.0, 1.0,
		 0.0,  0.5, 0.0, 1.0,
	}))
]]--

	local a = 1.0


	Spring.Echo("UploadInstanceBulk=", vao:UploadInstanceBulk({
		-a, -a, 0, 0, 0, 0, 0, 0,
		-a,  a, 0, 0, 0, 0, 0, 0,
		 a, -a, 0, 0, 0, 0, 0, 0,
		 a,  a, 0, 0, 0, 0, 0, 0,
	}))
	
	Spring.Echo("UploadInstanceAttribute=", vao:UploadInstanceAttribute(2, {
		-a, -a, 0, 0,
		-a,  a, 0, 0,
		 a, -a, 0, 0,
		 a,  a, 0, 0,
	}))
	
	

	shader = gl.CreateShader({
		vertex = [[
			#version 330 compatibility
			#line 74
			layout (location = 0) in vec3 aPos;
			layout (location = 1) in vec3 aCol;
			//layout (location = 2) in vec2 aUV;
			//layout (location = 3) in vec4 aOffset;
			//layout (location = 4) in vec4 aCol2;
			
			layout (location = 2) in vec4 aOffset;
			layout (location = 3) in vec4 aBla;

			out vec4 vCol;
			//out vec2 vUV;

			void main()
			{
				vCol = vec4(aCol, 0.5);// + aCol2;
				//vCol.a += aCol2.a;
				//vUV  = aUV;
				
				gl_Position = vec4(0.1 * aPos, 1.0) + aOffset * 0.1;
			}
		]],
		fragment = [[
			#version 330 compatibility
			#line 99
			out vec4 FragColor;
			
			in vec4 vCol;
			//in vec2 vUV;

			void main()
			{
				FragColor = vCol;
			}
		]],
	})

	Spring.Echo("shader=", shader)
	Spring.Echo(gl.GetShaderLog())
end

function widget:Shutdown()
	vao:Delete()
	vao:Delete()
	vao:Delete()
	gl.DeleteShader(shader)
end

local x = 0.5
function widget:DrawScreen()
	--local x = math.random()
	
	--[[
	vao:UploadVertexBulk({
		-1, -1, 0, x, 0, 0,
		-1,  1, 0, 0, x, 0,
		 1, -1, 0, 0, 0, x,
		 1,  1, 0, x, x, x,
	})
	]]--
	


	gl.UseShader(shader)

	--gl.TexRect(-1, -1, 1, 1, false, true)
	--vao:DrawArrays(GL.POINTS, 3)
	--Spring.Echo(GL.TRIANGLES)
	--Spring.Echo("DrawArrays=", vao:DrawArrays(GL.TRIANGLES, 3))
	--gl.Culling(false)

--[[
	Spring.Echo("UploadInstanceAttribute=", vao:UploadInstanceAttribute(3, {
		math.random(0, 1), math.random(0, 1), math.random(0, 1), math.random(0, 1),
		math.random(0, 1), math.random(0, 1), math.random(0, 1), math.random(0, 1),
		math.random(0, 1), math.random(0, 1), math.random(0, 1), math.random(0, 1),
		math.random(0, 1), math.random(0, 1), math.random(0, 1), math.random(0, 1),
	}))
]]--


	--[[
	Spring.Echo("UploadInstanceBulk=", vao:UploadInstanceBulk({
		-1, -1, 0, 0, math.random(0, 1), math.random(0, 1), math.random(0, 1), math.random(0, 1),
		-1,  1, 0, 0, math.random(0, 1), math.random(0, 1), math.random(0, 1), math.random(0, 1),
		 1,  1, 0, 0, math.random(0, 1), math.random(0, 1), math.random(0, 1), math.random(0, 1),
		 1, -1, 0, 0, math.random(0, 1), math.random(0, 1), math.random(0, 1), math.random(0, 1),
	}))
	]]--
	
	Spring.Echo("DrawArrays=", vao:DrawArrays(GL.TRIANGLE_STRIP, 4, 0 , 4))
	--[[
	gl.BeginEnd(GL.TRIANGLE_STRIP, function()
		gl.Vertex(-1, -1, 0, 1)
		gl.Vertex(-1,  1, 0, 1)
		gl.Vertex( 1, -1, 0, 1)
		gl.Vertex( 1,  1, 0, 1)
	end)
	]]--
	
	
	gl.UseShader(0)
end