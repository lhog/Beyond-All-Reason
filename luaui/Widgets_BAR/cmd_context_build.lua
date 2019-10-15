local unitlist={--- Human friendly list. Automatically converted to unitdef IDs on init

	 -- this should only ever swap between pairs of (buildable) units, 03/06/13

	{'armmex','armuwmex', 'cormex','coruwmex'},-- to test that widget behaves correctly when unit can't really be built
	{'armmakr','armfmkr'},
	{'cormakr','corfmkr'},
	--{'armdrag','armfdrag'},  --both can be built in shallow water -> do not touch
	--{'cordrag','corfdrag'},  --both can be built in shallow water -> do not touch
	{'armmstor', 'armuwms'},
	{'armestor', 'armuwes'},
	{'cormstor', 'coruwms'},
	{'corestor', 'coruwes'},
	{'armrl','armfrt'},
	{'corrl','corfrt'},
	{'armhp','armfhp'},
	{'corhp','corfhp'},
	{'armrad','armfrad'},
	{'corrad','corfrad'},
	{'armhlt','armfhlt'},
	{'corhlt','corfhlt'},
	{'armtarg','armfatf'},
	{'cortarg','corfatf'},
	{'armmmmkr','armuwmmm'},
	{'cormmmkr','coruwmmm'},
	{'armfus','armuwfus'},
	{'corfus','coruwfus'},
	{'armflak','armfflak'},
	{'corflak','corfflak'},
	{'armmoho','armuwmme'},
	{'cormoho','coruwmme'},
	{'armsolar','armtide'},
	{'corsolar','cortide'},
	{'armlab','armsy'},
	{'corlab','corsy'},
	{'armllt','armtl'},
	{'corllt','cortl'},
	{'armnanotc','armnanotcplat'},
	{'cornanotc','cornanotcplat'},
}

function widget:GetInfo()
	return {
		name = "Context Build",
		desc = "Toggles buildings between buildings automagically" ,
		author = "dizekat and BD",
		date = "30 July 2009",
		license = "GNU LGPL, v2.1 or later",
		layer = 1,
		enabled = false
	}
end
local GetActiveCommand		= Spring.GetActiveCommand
local SetActiveCommand		= Spring.SetActiveCommand
local GetMouseState			= Spring.GetMouseState
local TraceScreenRay		= Spring.TraceScreenRay
local TestBuildOrder		= Spring.TestBuildOrder

local alternative_units = {}-- unit def id --> list of alternative unit def ids
local updateRate = 8/30
local timeCounter = 0


function maybeRemoveSelf()
    if Spring.GetSpectatingState() and (Spring.GetGameFrame() > 0 or gameStarted) then
        widgetHandler:RemoveWidget(self)
    end
end

function widget:GameStart()
    gameStarted = true
    maybeRemoveSelf()
end

function widget:PlayerChanged(playerID)
    maybeRemoveSelf()
end

function widget:Initialize()
    if Spring.IsReplay() or Spring.GetGameFrame() > 0 then
        maybeRemoveSelf()
    end
	local unitnameToUnitDefID = {}--- unit name or humanName --> unit def id
	for index,def in ipairs(UnitDefs) do
		unitnameToUnitDefID[def.name]=index
	end
	for _,unitNames in ipairs(unitlist) do
		local list={}
		for _,unitName in ipairs(unitNames) do
			local unitDefID=unitnameToUnitDefID[unitName]
			if unitDefID then
				table.insert(list,unitDefID)
			end
		end
		for _,unitDefID in ipairs(list) do
			local tempcopy = list
			table.remove(tempcopy,unitDefID) -- exclude itself from the alternatives
			alternative_units[unitDefID]=tempcopy
		end

	end
end


function widget:Update(deltaTime)
	timeCounter = timeCounter + deltaTime
	-- update only x times per second
	if timeCounter >= updateRate then
		timeCounter = 0
	else
		return
	end

	local _, cmd_id = GetActiveCommand()
	if (not cmd_id) or (cmd_id>=0) then
		return
	end
	local unitDefID = -cmd_id

	local alternatives = alternative_units[unitDefID]
	if (not alternatives) then
		return
	end

	local mx, my = GetMouseState()
	local _, coords = TraceScreenRay(mx, my, true, true)
	if (not coords) then
		return
	end

	if TestBuildOrder(unitDefID, coords[1], coords[2], coords[3], 1) == 0 then
		--Spring.Echo('cant build, looking for alternatives')
		for _,alt_id in ipairs(alternatives) do --- try all alternatives
			if TestBuildOrder(alt_id, coords[1], coords[2], coords[3], 1) ~= 0 then
				if SetActiveCommand('buildunit_'..UnitDefs[alt_id].name) then
					return
				end
			end
		end
	end

end
