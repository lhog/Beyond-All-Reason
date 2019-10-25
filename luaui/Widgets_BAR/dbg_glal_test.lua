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

--include("fonts.lua")

function widget:Initialize()
	Spring.Echo(widget:GetInfo().name, "Initialize")
end

local vsx,vsy = Spring.GetViewGeometry()

local cutomScale = 1
local sizeMultiplier = 1

local WhiteStr   = "\255\255\255\255"
local RedStr     = "\255\255\001\001"
local GreenStr   = "\255\001\255\001"
local BlueStr    = "\255\001\001\255"
local CyanStr    = "\255\001\255\255"
local YellowStr  = "\255\255\255\001"
local MagentaStr = "\255\255\001\255"

local cutomScale = 1
local sizeMultiplier = 1

local floor = math.floor

local widgetsList = {}
local fullWidgetsList = {}

local vsx, vsy = widgetHandler:GetViewSizes()

local minMaxEntries = 15
local curMaxEntries = 25

local startEntry = 1
local pageStep  = math.floor(curMaxEntries / 2) - 1

local fontSize = 13.5
local fontSpace = 8.5
local yStep = fontSize + fontSpace

local fontfile = LUAUI_DIRNAME .. "fonts/" .. Spring.GetConfigString("bar_font", "Poppins-Regular.otf")
local vsx,vsy = Spring.GetViewGeometry()
local fontfileScale = (0.5 + (vsx*vsy / 5700000))
local fontfileSize = 25
local fontfileOutlineSize = 6
local fontfileOutlineStrength = 1.4
local font = gl.LoadFont(fontfile, fontfileSize*fontfileScale, fontfileOutlineSize*fontfileScale, fontfileOutlineStrength)
local fontfile2 = LUAUI_DIRNAME .. "fonts/" .. Spring.GetConfigString("bar_font2", "Exo2-SemiBold.otf")
local font2 = gl.LoadFont(fontfile2, fontfileSize*fontfileScale, fontfileOutlineSize*fontfileScale, fontfileOutlineStrength)

local bgPadding = 5.5
local bgcorner	= "LuaUI/Images/bgcorner.png"

local maxWidth = 0.01
local borderx = yStep * 0.75
local bordery = yStep * 0.75

local midx = vsx * 0.5
local minx = vsx * 0.4
local maxx = vsx * 0.6
local midy = vsy * 0.5
local miny = vsy * 0.4
local maxy = vsy * 0.6

local sbposx = 0.0
local sbposy = 0.0
local sbsizex = 0.0
local sbsizey = 0.0
local sby1 = 0.0
local sby2 = 0.0
local sbsize = 0.0
local sbheight = 0.0
local activescrollbar = false
local scrollbargrabpos = 0.0

local show = false
local pagestepped = false


local titleFontSize = 20
local buttonFontSize = 15
local buttonHeight = 24
local buttonTop = 28 -- offset between top of buttons and bottom of widget


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

	gl.Texture(bgcorner)
	gl.Color(0.33,0.33,0.33,0.2)
	gl.BeginEnd(GL.QUADS, DrawRectRound, px,py,sx,sy,cs)
	gl.Texture(false)
end

local vao = nil

local WhiteStr = "\255\255\255\255"

function widget:DrawWorld()
	--font:WorldBegin()
	--font:WorldPrint(WhiteStr.."leftleft", 882.0, 400.0, 984.0)
	--font:WorldEnd()
end

function widget:DrawScreen()

	--gl.ResetState()
	--gl.ResetMatrices()

		gl.MatrixMode(GL.PROJECTION)
		gl.LoadIdentity()
		gl.Ortho(0,vsx,vsy,0,0,1) --top left is 0,0
		gl.DepthTest(false)
		gl.MatrixMode(GL.MODELVIEW)
		gl.LoadIdentity()
		gl.Translate(0.375,0.375,0) -- for exact pixelization


	local px, py, sx, sy, cs = 500, 500, 800, 800, 8
	RectRound(px,py,sx,sy,cs)

--[[
	font:Begin()
		--font:Print(tcol.."leftleft", px/vsx, py/vsy, 50/vsy, "or")
		--font:Print("leftleft", 0.5 * vsx, 0.4 * vsy, 23.0, "vc")
		--gl.Scale(2,2,2)
		font:Print("leftleft", 0.5 * vsx, 0.5 * vsy, 23.0, "vc")
		--font:Print("leftleft", 0.5 * vsx, 0.6 * vsy, 23.0, "vc")
	font:End()
]]--

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
]]--

--[[
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


function widget:Shutdown()
	if vao then gl.DeleteVertexArray(vao) end
end