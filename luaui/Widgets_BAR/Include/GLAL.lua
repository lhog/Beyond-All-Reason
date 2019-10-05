-- Spring OpenGL abstraction layer (GLAL). Abstracts away the difference between maintenance and develop engines

local isDevelop = gl.CreateVertexArray ~= nil

if isDevelop then

local orig = {
	Color = gl.Color,
	BeginEnd = gl.BeginEnd,
	TexCoord = gl.TexCoord,
	Normal = gl.Normal,
}

local inBeginEnd = false

local currColor = {1, 1, 1, 1}
local currNormal = {1, 1, 1}
local currTexCoord = {0, 0, 0, 0}

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

gl.BeginEnd = function(glType, ...)
	inBeginEnd = true
	orig.BeginEnd(glType, ...)
	inBeginEnd = false
end

gl.Color = function(r, g, b, a)
	if inBeginEnd then
		orig.Color(r, g, b, a)
	else
		currColor = {r, g, b, a}
	end
end

gl.Normal = function(x, y, z)
	if inBeginEnd then
		orig.Normal(x, y, z)
	else
		currNormal = {x, y, z}
	end
end

gl.TexCoord = function(x, y, z, w)
	if inBeginEnd then
		orig.TexCoord(x, y, z, w)
	else
		currTexCoord = {x, y, z, w}
	end
end


else -- Maintenance




end