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

function widget:Initialize()
	Spring.Echo(widget:GetInfo().name, "Initialize")
	vsx,vsy = Spring.GetViewGeometry()
end



local function DrawRectRound(px,py,sx,sy,cs)
	gl.TexCoord(0.8,0.8)
	gl.Vertex(px+cs, py, 0)
	gl.Vertex(sx-cs, py, 0)
	gl.Vertex(sx-cs, sy, 0)
	gl.Vertex(px+cs, sy, 0)

	gl.Vertex(px, py+cs, 0)
	gl.Vertex(px+cs, py+cs, 0)
	gl.Vertex(px+cs, sy-cs, 0)
	gl.Vertex(px, sy-cs, 0)

	gl.Vertex(sx, py+cs, 0)
	gl.Vertex(sx-cs, py+cs, 0)
	gl.Vertex(sx-cs, sy-cs, 0)
	gl.Vertex(sx, sy-cs, 0)

	local offset = 0.07		-- texture offset, because else gaps could show
	local o = offset
	-- top left
	if py <= 0 or px <= 0 then o = 0.5 else o = offset end
	gl.TexCoord(o,o)
	gl.Vertex(px, py, 0)
	gl.TexCoord(o,1-offset)
	gl.Vertex(px+cs, py, 0)
	gl.TexCoord(1-offset,1-offset)
	gl.Vertex(px+cs, py+cs, 0)
	gl.TexCoord(1-offset,o)
	gl.Vertex(px, py+cs, 0)
	-- top right
	if py <= 0 or sx >= vsx then o = 0.5 else o = offset end
	gl.TexCoord(o,o)
	gl.Vertex(sx, py, 0)
	gl.TexCoord(o,1-offset)
	gl.Vertex(sx-cs, py, 0)
	gl.TexCoord(1-offset,1-offset)
	gl.Vertex(sx-cs, py+cs, 0)
	gl.TexCoord(1-offset,o)
	gl.Vertex(sx, py+cs, 0)
	-- bottom left
	if sy >= vsy or px <= 0 then o = 0.5 else o = offset end
	gl.TexCoord(o,o)
	gl.Vertex(px, sy, 0)
	gl.TexCoord(o,1-offset)
	gl.Vertex(px+cs, sy, 0)
	gl.TexCoord(1-offset,1-offset)
	gl.Vertex(px+cs, sy-cs, 0)
	gl.TexCoord(1-offset,o)
	gl.Vertex(px, sy-cs, 0)
	-- bottom right
	if sy >= vsy or sx >= vsx then o = 0.5 else o = offset end
	gl.TexCoord(o,o)
	gl.Vertex(sx, sy, 0)
	gl.TexCoord(o,1-offset)
	gl.Vertex(sx-cs, sy, 0)
	gl.TexCoord(1-offset,1-offset)
	gl.Vertex(sx-cs, sy-cs, 0)
	gl.TexCoord(1-offset,o)
	gl.Vertex(sx, sy-cs, 0)
end

function RectRound(px,py,sx,sy,cs)
	local px,py,sx,sy,cs = math.floor(px),math.floor(py),math.ceil(sx),math.ceil(sy),math.floor(cs)

	--gl.Texture(bgcorner)
	gl.Color(0.33,0.33,0.33,0.2)
	gl.BeginEnd(GL.QUADS, DrawRectRound, px,py,sx,sy,cs)
	--gl.Texture(false)



end

local vao = nil

function widget:DrawScreenEffects()
	local px, py, sx, sy, cs = 500, 500, 800, 800, 8
	RectRound(px,py,sx,sy,cs)

--[[
	gl.BeginEnd(GL.QUADS, function()
		local x1, y1, x2, y2 = 0, 0, 100, 1000

		gl.Color(0, 1, 0, 1)
		gl.TexCoord(0, 0)
		gl.Vertex(x1, y1)

		--gl.Color(0, 0.5, 0, 1)
		gl.TexCoord(1, 0)
		gl.Vertex(x2, y1)

		--gl.Color(0, 0, 0.5, 1)
		gl.TexCoord(1, 1)
		gl.Vertex(x2, y2)

		--gl.Color(1, 1, 1, 1)
		gl.TexCoord(0, 1)
		gl.Vertex(x1, y2)
	end)


	gl.BeginEnd(GL.QUADS, function()
		local x1, y1, x2, y2 = 0, 0, 1000, 100

		gl.Color(1, 0, 0, 1)
		gl.TexCoord(0, 0)
		gl.Vertex(x1, y1)

		--gl.Color(0, 0.5, 0, 1)
		gl.TexCoord(1, 0)
		gl.Vertex(x2, y1)

		--gl.Color(0, 0, 0.5, 1)
		gl.TexCoord(1, 1)
		gl.Vertex(x2, y2)

		--gl.Color(1, 1, 1, 1)
		gl.TexCoord(0, 1)
		gl.Vertex(x1, y2)

	end)
]]--


--[[	vao = gl.CreateVertexArray(4, 6)
	gl.UpdateVertexArray(vao, 0, 0,
	{
		p  = {x1, y1, 0, 1, x2, y1, 0, 1, x2, y2, 0, 1, x1, y2, 0, 1},
		c0 = {1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1},
		i  = {0, 1, 2, 2, 3, 0},
	})
	gl.RenderVertexArray(vao, GL.TRIANGLES)
	gl.DeleteVertexArray(vao)
	vao = nil
	]]--

--[[
	local x1, y1, x2, y2 = -1, -1, 1, 1
	--math.randomseed(os.time())

	local a1 = (math.random() > 0.5) and 1.0 or 0.0
	local a2 = (math.random() > 0.5) and 1.0 or 0.0
	local a3 = (math.random() > 0.5) and 1.0 or 0.0
	local a4 = (math.random() > 0.5) and 1.0 or 0.0

	vao = vao or gl.CreateVertexArray(4, 6)
	gl.UpdateVertexArray(vao, 0, 0,
	{
		p  = {x1, y1, 0, 1, x2, y1, 0, 1, x2, y2, 0, 1, x1, y2, 0, 1},
		c0 = {
			a1, 1, 1, 1,
			1, a2, 1, 1,
			1, 1, a3, 1,
			a1, a2, a3, 1
			},
		i  = {0, 1, 2, 2, 3, 0},
	})
	gl.RenderVertexArray(vao, GL.TRIANGLES)
]]--
	--gl.DeleteVertexArray(vao)

--	gl.Color(1, 0, 0, 1)
--	gl.Rect(x1, y1, x2, y2)

end



--function widget:DrawScreen()

	--Spring.Echo(widget:GetInfo().name, "DrawWorld")

	--local x1, y1, x2, y2 = 0, 0, 1000, 1000
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
	vao = nil
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

--end


function widget:Shutdown()
	if vao then gl.DeleteVertexArray(vao) end
end