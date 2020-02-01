--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
    return {
        name      = "Voice Notifs",
        desc      = "Plays various voice notifications",
        author    = "Doo, Floris",
        date      = "2018",
        license   = "GNU GPL, v2 or later",
        version   = 1,
        layer     = 5,
        enabled   = true  --  loaded by default?
    }
end

local volume = 1
local playTrackedPlayerNotifs = true
local muteWhenIdle = true
local idleTime = 6		-- after this much sec: mark user as idle

local soundFolder = "LuaUI/Sounds/VoiceNotifs/"
local Sound = {
	eCommDestroyed = {
		'LuaUI/Sounds/VoiceNotifs/eCommDestroyed.wav',
		1, 		-- min delay
		1,		-- relative volume
		1.7,	-- duration (optional, but define for sounds longer than 2 seconds)
	},
	aCommLost = {soundFolder..'aCommLost.wav', 1, 0.8, 1.75},
	ComHeavyDamage = {soundFolder..'ComHeavyDamage.wav', 12, 0.6, 2.1},

	NukeLaunched = {soundFolder..'NukeLaunched.wav', 3, 0.8, 2},
	IdleBuilder = {soundFolder..'IdleBuilder.wav', 30, 0.6, 1.9},
	GameStarted = {soundFolder..'GameStarted.wav', 1, 0.6, 1},
	GamePause = {soundFolder..'GamePause.wav', 5, 0.6, 1},
	PlayerLeft = {soundFolder..'PlayerLeft.wav', 1, 0.6, 1.65},
	UnitsReceived = {soundFolder..'UnitReceived.wav', 4, 0.8, 1.75},

	UnitLost = {soundFolder..'UnitLost.wav', 20, 0.6, 1.2},
	RadarLost = {soundFolder..'RadarLost.wav', 8, 0.6, 1},
	AdvRadarLost = {soundFolder..'AdvRadarLost.wav', 8, 0.6, 1.32},
	MexLost = {soundFolder..'MexLost.wav', 8, 0.6, 1.53},
	T2MexLost = {soundFolder..'T2MexLost.wav', 8, 0.6, 2.34},

	LowPower = {soundFolder..'LowPower.wav', 20, 0.6, 0.95},
	TeamWastingMetal = {soundFolder..'teamwastemetal.wav', 22, 0.6, 1.7},		-- top bar widget calls this
	TeamWastingEnergy = {soundFolder..'teamwasteenergy.wav', 30, 0.6, 1.8},		-- top bar widget calls this
	MetalStorageFull = {soundFolder..'metalstorefull.wav', 40, 0.6, 1.62},		-- top bar widget calls this
	EnergyStorageFull = {soundFolder..'energystorefull.wav', 40, 0.6, 1.65},	-- top bar widget calls this

	AircraftSpotted = {soundFolder..'AircraftSpotted.wav', 9999999, 0.6, 1.25},	-- top bar widget calls this
	T2Detected = {soundFolder..'T2UnitDetected.wav', 9999999, 0.6, 1.5},	-- top bar widget calls this
	T3Detected = {soundFolder..'T3UnitDetected.wav', 9999999, 0.6, 1.94},	-- top bar widget calls this

	IntrusionCountermeasure = {soundFolder..'StealthyUnitsInRange.wav', 30, 0.6, 4.8},
	EMPmissilesiloDetected = {soundFolder..'EmpSiloDetected.wav', 4, 0.6, 2.1},
	TacticalNukeSiloDetected = {soundFolder..'TacticalNukeDetected.wav', 4, 0.6, 2},
	NuclearSiloDetected = {soundFolder..'NuclearSiloDetected.wav', 4, 0.6, 1.7},
	LrpcDetected = {soundFolder..'LrpcDetected.wav', 25, 0.6, 2.3},
	NuclearBomberDetected = {soundFolder..'NuclearBomberDetected.wav', 45, 0.6, 1.6},
}
local unitsOfInterest = {}
unitsOfInterest[UnitDefNames['armemp'].id] = 'EMPmissilesiloDetected'
unitsOfInterest[UnitDefNames['cortron'].id] = 'TacticalNukeSiloDetected'
unitsOfInterest[UnitDefNames['armsilo'].id] = 'NuclearSiloDetected'
unitsOfInterest[UnitDefNames['corsilo'].id] = 'NuclearSiloDetected'
unitsOfInterest[UnitDefNames['corint'].id] = 'LrpcDetected'
unitsOfInterest[UnitDefNames['armbrtha'].id] = 'LrpcDetected'
unitsOfInterest[UnitDefNames['corbuzz'].id] = 'LrpcDetected'
unitsOfInterest[UnitDefNames['armvulc'].id] = 'LrpcDetected'
unitsOfInterest[UnitDefNames['armliche'].id] = 'NuclearBomberDetected'

-- adding duration
local silenceDuration = 0.6
for i,v in pairs(Sound) do
	if not Sound[i][4] then
		Sound[i][4] = 2 + silenceDuration
	else
		Sound[i][4] = Sound[i][4] + silenceDuration
	end
end

local LastPlay = {}
-- adding so they wont get immediately triggered after gamestart
LastPlay['TeamWastingMetal'] = Spring.GetGameFrame()+300
LastPlay['TeamWastingEnergy'] = Spring.GetGameFrame()+300
LastPlay['MetalStorageFull'] = Spring.GetGameFrame()+300
LastPlay['EnergyStorageFull'] = Spring.GetGameFrame()+300


local soundQueue = {}
local nextSoundQueued = 0
local taggedUnitsOfInterest = {}
local aircraftSpotted = false
local t2detected = false
local t3detected = false

local soundList = {}
for k, v in pairs(Sound) do
	soundList[k] = true
end

local passedTime = 0
local sec = 0
local spIsUnitAllied = Spring.IsUnitAllied
local spGetUnitDefID = Spring.GetUnitDefID
local spIsUnitInView = Spring.IsUnitInView
local spGetUnitHealth = Spring.GetUnitHealth

local isIdle = false
local lastUserInputTime = os.clock()
local lastMouseX, lastMouseY = Spring.GetMouseState()

local isSpec = Spring.GetSpectatingState()
local myTeamID = Spring.GetMyTeamID()
local myPlayerID = Spring.GetMyPlayerID()
local myAllyTeamID = Spring.GetMyAllyTeamID()


local isCommander = {}
for udefID,def in ipairs(UnitDefs) do
	if def.customParams.iscommander then
		isCommander[udefID] = true
	end
end

local commanders = {}
local commandersDamages = {}
function updateCommanders()
	local units = Spring.GetTeamUnits(myTeamID)
	for i=1,#units do
		local unitID    = units[i]
		local unitDefID = spGetUnitDefID(unitID)
		if isCommander[unitDefID] then
			local health,maxHealth,paralyzeDamage,captureProgress,buildProgress = spGetUnitHealth(unitID)
			commanders[unitID] = maxHealth
		end
	end
end

local isAircraft = {}
local isT2 = {}
local isT3 = {}
for unitDefID, unitDef in pairs(UnitDefs) do
	if unitDef.canFly then
		isAircraft[unitDefID] = true
	end
	if unitDef.customParams and unitDef.customParams.techlevel then
		if unitDef.customParams.techlevel == '2' and not unitDef.customParams.iscommander then
			isT2[unitDefID] = true
		end
		if unitDef.customParams.techlevel == '3' then
			isT3[unitDefID] = true
		end
	end
end

function widget:PlayerChanged(playerID)
	isSpec = Spring.GetSpectatingState()
	myTeamID = Spring.GetMyTeamID()
	myPlayerID = Spring.GetMyPlayerID()
	myAllyTeamID = Spring.GetMyAllyTeamID()
	updateCommanders()
end

function widget:Initialize()
	if Spring.IsReplay() or Spring.GetGameFrame() > 0 then
		widget:PlayerChanged()
	end
	widgetHandler:RegisterGlobal('EventBroadcast', EventBroadcast)

	WG['voicenotifs'] = {}
	for sound, params in pairs(Sound) do
		WG['voicenotifs']['getSound'..sound] = function()
			return (SoundDisabled[sound] and false or true)
		end
		WG['voicenotifs']['setSound'..sound] = function(value)
			soundList[sound] = value
		end
	end
	WG['voicenotifs'].getSoundList = function()
		return soundList
	end
    WG['voicenotifs'].getVolume = function()
        return volume
    end
    WG['voicenotifs'].setVolume = function(value)
        volume = value
    end
    WG['voicenotifs'].getPlayTrackedPlayerNotifs = function()
        return playTrackedPlayerNotifs
    end
	WG['voicenotifs'].setPlayTrackedPlayerNotifs = function(value)
		playTrackedPlayerNotifs = value
	end
	WG['voicenotifs'].addEvent = function(value)
		if Sound[value] then
			Sd(value)
		end
	end
end

function widget:Shutdown()
	WG['voicenotifs'] = nil
	widgetHandler:DeregisterGlobal('EventBroadcast')
end


local lowpowerThreshold = 6		-- if there is X secs a low power situation
local lowpowerDuration = 0
function widget:GameFrame(gf)
	if gf % 30 == 15 then
		-- low power check
		local currentLevel, storage, pull, income, expense, share, sent, received = Spring.GetTeamResources(myTeamID,'energy')
		if (currentLevel / storage) < 0.025 and currentLevel < 3000 then
			lowpowerDuration = lowpowerDuration + 1
			if lowpowerDuration >= lowpowerThreshold then
				Sd('LowPower')
				lowpowerDuration = 0
			end
		end
	end
end

function widget:UnitEnteredLos(unitID, allyTeam)
	if spIsUnitAllied(unitID) then return end

	local udefID = spGetUnitDefID(unitID)

	-- single detection events below
	if not aircraftSpotted and isAircraft[udefID] then
		aircraftSpotted = true
		Sd('AircraftSpotted')
	end
	if not t2detected and isT2[udefID] then
		t2detected = true
		Sd('T2Detected')
	end
	if not t3detected and isT3[udefID] then
		t3detected = true
		Sd('T3Detected')
	end

	-- notify about units of interest
	if udefID and unitsOfInterest[udefID] and not taggedUnitsOfInterest[unitID] then
		taggedUnitsOfInterest[unitID] = true
		Sd(unitsOfInterest[udefID])
	end
end


function widget:UnitTaken(unitID, unitDefID, unitTeam, newTeam)
    if unitTeam == myTeamID and isCommander[unitDefID] then
        commanders[unitID] = select(2, spGetUnitHealth(unitID))
    end
end

function widget:UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
    if unitTeam == myTeamID and isCommander[unitDefID] then
        commanders[unitID] = select(2, spGetUnitHealth(unitID))
    end
end

function widget:UnitCreated(unitID, unitDefID, unitTeam, damage, paralyzer)
    if unitTeam == myTeamID and isCommander[unitDefID] then
        commanders[unitID] = select(2, spGetUnitHealth(unitID))
    end
end


function widget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer)

	-- notify when commander gets heavy damage
	if unitTeam == myTeamID and commanders[unitID] and not spIsUnitInView(unitID) then
		if not commandersDamages[unitID] then
			commandersDamages[unitID] = {}
		end
		local gameframe = Spring.GetGameFrame()
		commandersDamages[unitID][gameframe] = damage		-- if widget:UnitDamaged can be called multiple times during 1 gameframe then you need to add those up, i dont know

		-- count total damage of last few secs
        local totalDamage = 0
        local startGameframe = gameframe - (5.5 * 30)
        for gf,damage in pairs(commandersDamages[unitID]) do
            if gf > startGameframe then
                totalDamage = totalDamage + damage
            else
                commandersDamages[unitID][gf] = nil
            end
        end
        if totalDamage >= commanders[unitID] * 0.12 then
            Sd('ComHeavyDamage')
        end
	end
end

function widget:UnitDestroyed(unitID, unitDefID, teamID)
	taggedUnitsOfInterest[unitID] = nil
    commanders[unitID] = nil
    commandersDamages[unitID] = nil
end

function playNextSound()
	if #soundQueue > 0 then
		local event = soundQueue[1]
		nextSoundQueued = sec + Sound[event][4]
		if not muteWhenIdle or not isIdle then
			Spring.PlaySoundFile(Sound[event][1], volume * Sound[event][3], 'ui')
		end
		LastPlay[event] = Spring.GetGameFrame()

		local newQueue = {}
		for i,v in pairs(soundQueue) do
			if i ~= 1 then
				newQueue[#newQueue+1] = v
			end
		end
		soundQueue = newQueue
	end
end

function widget:Update(dt)
	sec = sec + dt

    myTeamID = Spring.GetMyTeamID()
    myPlayerID = Spring.GetMyPlayerID()
    isSpec = Spring.GetSpectatingState()

    passedTime = passedTime + dt
    if passedTime > 0.2 then
        passedTime = passedTime - 0.2
        if WG['advplayerlist_api'] and WG['advplayerlist_api'].GetLockPlayerID ~= nil then
            lockPlayerID = WG['advplayerlist_api'].GetLockPlayerID()
        end

		-- process sound queue
		if sec >= nextSoundQueued then
			playNextSound()
		end

		-- check idle status
		local mouseX, mouseY = Spring.GetMouseState()
		if mouseX ~= lastMouseX or mouseY ~= lastMouseY then
			lastUserInputTime = os.clock()
		end
		lastMouseX, lastMouseY = mouseX, mouseY
		if lastUserInputTime < os.clock() - idleTime then
			isIdle = true
		else
			isIdle = false
		end
    end
end

function EventBroadcast(msg)
	if not isSpec or (isSpec and playTrackedPlayerNotifs and lockPlayerID ~= nil) then
        if string.find(msg, "SoundEvents") then
            msg = string.sub(msg, 13)
            event = string.sub(msg, 1, string.find(msg, " ")-1)
            player = string.sub(msg, string.find(msg, " ")+1, string.len(msg))
            if (tonumber(player) and (tonumber(player) == Spring.GetMyPlayerID())) or (isSpec and tonumber(player) == lockPlayerID) then
                Sd(event)
            end
        end
	end
end

function Sd(event)
	if not isSpec or (isSpec and playTrackedPlayerNotifs and lockPlayerID ~= nil) then
		if soundList[event] and Sound[event] then
			if not LastPlay[event] then
				soundQueue[#soundQueue+1] = event
				LastPlay[event] = Spring.GetGameFrame()
			elseif LastPlay[event] and Spring.GetGameFrame() >= LastPlay[event] + (Sound[event][2] * 30) then
				soundQueue[#soundQueue+1] = event
                LastPlay[event] = Spring.GetGameFrame()
			end
		end
	end
end

function widget:MousePress()
	lastUserInputTime = os.clock()
end

function widget:MouseWheel()
	lastUserInputTime = os.clock()
end

function widget:KeyPress()
	lastUserInputTime = os.clock()
end


function widget:GetConfigData(data)
	return {
		soundList = soundList,
		volume = volume,
		playTrackedPlayerNotifs = playTrackedPlayerNotifs,
		LastPlay = LastPlay,
		aircraftSpotted = aircraftSpotted,
		t2detected = t2detected,
		t3detected = t3detected,
	}
end

function widget:SetConfigData(data)
	if data.soundList ~= nil then
		for sound, enabled in pairs(data.soundList) do
			if Sound[sound] then
				soundList[sound] = enabled
			end
		end
	end
	if data.volume ~= nil then
		volume = data.volume
	end
	if data.playTrackedPlayerNotifs ~= nil then
		playTrackedPlayerNotifs = data.playTrackedPlayerNotifs
	end
	if Spring.GetGameFrame() > 0 then
		if data.LastPlay then
			LastPlay = data.LastPlay
		end
		if data.aircraftSpotted then
			aircraftSpotted = data.aircraftSpotted
		end
		if data.t2detected then
			t2detected = data.t2detected
		end
		if data.t3detected then
			t3detected = data.t3detected
		end
	end
end