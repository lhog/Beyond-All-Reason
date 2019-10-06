function widget:GetInfo()
  return {
    name      = "GLAL testing suite",
    desc      = "GLAL testing suite",
    author    = "ivand",
    license   = "GNU GPL, v2 or later",
    layer     = 10,
    enabled = true,  --  loaded by default?
  }
end

--VFS.Include("LuaUI/Widgets_BAR/Include/GLAL.lua")

function widget:Initialize()
	Spring.Echo(widget:GetInfo().name, "Initialize")
end

function widget:DrawScreen()

	--Spring.Echo(widget:GetInfo().name, "DrawWorld")

	local x1, y1, x2, y2 = 0, 0, 1000, 1000
	--local x1, y1, x2, y2 = 0, 0, 0.5, 0.5
--[[
	gl.BeginEnd(GL.QUADS, function()

		gl.Color(1, 0, 0, 1)
		gl.TexCoord(0, 0)
		gl.Vertex(x1, y1)

		gl.Color(1, 0, 0, 1)
		gl.TexCoord(1, 0)
		gl.Vertex(x2, y1)

		gl.Color(1, 0, 0, 1)
		gl.TexCoord(1, 1)
		gl.Vertex(x2, y2)

		gl.Color(1, 0, 0, 1)
		gl.TexCoord(0, 1)
		gl.Vertex(x1, y2)

	end)
]]--

--[[
	local vao = gl.CreateVertexArray(4, 6)
	gl.UpdateVertexArray(vao, 0, 0,
	{
		p  = {x1, y1, 0, 1, x2, y1, 0, 1, x2, y2, 0, 1, x1, y2, 0, 1},
		c0 = {1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1},
		i  = {0, 1, 2, 2, 3, 0},
	})
	gl.RenderVertexArray(vao, GL.TRIANGLES)
	gl.DeleteVertexArray(vao)
]]--

--[[
	gl.Color(1, 0, 0, 1)
	--gl.TexRect(x1, y1, x2, y2)
	gl.Rect(x1, y1, x2, y2)
	--gl.TexRect(-1, -1, 10, 10)
]]--
--[[
	gl.BeginEnd(GL.TRIANGLES, function()

		gl.Color(1, 0, 0, 1)
		gl.Vertex(x1, y1)

		gl.Color(1, 0, 0, 1)
		gl.Vertex(x2, y1)

		gl.Color(1, 0, 0, 1)
		gl.Vertex(x2, y2)

		gl.Color(1, 0, 0, 1)
		gl.Vertex(x2, y2)

		gl.Color(1, 0, 0, 1)
		gl.Vertex(x1, y2)

		gl.Color(1, 0, 0, 1)
		gl.Vertex(x1, y1)

	end)
]]--

end