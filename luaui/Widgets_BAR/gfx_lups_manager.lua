--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  author:  jK
--
--  Copyright (C) 2007,2008.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "LupsManager",
    desc      = "",
    author    = "jK",
    date      = "Feb, 2008",
    license   = "GNU GPL, v2 or later",
    layer     = 10,
    enabled = false,
    handler   = true,
  }
end


include("Configs/lupsFXs.lua")

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function MergeTable(table1,table2)
  local result = {}
  for i,v in pairs(table2) do 
    if (type(v)=='table') then
      result[i] = MergeTable(v,{})
    else
      result[i] = v
    end
  end
  for i,v in pairs(table1) do 
    if (result[i]==nil) then
      if (type(v)=='table') then
        if (type(result[i])~='table') then result[i] = {} end
        result[i] = MergeTable(v,result[i])
      else
        result[i] = v
      end
    end
  end
  return result
end


local function blendColor(c1,c2,mix)
  if (mix>1) then mix=1 end
  local mixInv = 1-mix
  return {
    c1[1]*mixInv + c2[1]*mix,
    c1[2]*mixInv + c2[2]*mix,
    c1[3]*mixInv + c2[3]*mix,
    (c1[4] or 1)*mixInv + (c2[4] or 1)*mix
  }
end


local function blend(a,b,mix)
  if (mix>1) then mix=1 end
  return a*(1-mix) + b*mix
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local UnitEffects = {

    [UnitDefNames["armjuno"].id] = {
        {class='ShieldSphere',options=armjunoShieldSphere},
        {class='ShieldJitter',options={life=math.huge, pos={0,72,0}, size=14, precision=22, repeatEffect=true}},
    },
    [UnitDefNames["corjuno"].id] = {
        {class='ShieldSphere',options=corjunoShieldSphere},
        {class='ShieldJitter',options={life=math.huge, pos={0,72,0}, size=14, precision=22, repeatEffect=true}},
    },

    [UnitDefNames["cormakr"].id] = {
        {class='StaticParticles',options=cormakrEffect},
    },
    [UnitDefNames["corfmkr"].id] = {
        {class='StaticParticles',options=cormakrEffect},
    },

    --// FUSIONS //--------------------------
    [UnitDefNames["corafus"].id] = {
        {class='ShieldSphere',options=corafusShieldSphere},
        {class='ShieldJitter',options={layer=-16, life=math.huge, pos={0,60,0}, size=32.5, precision=22, repeatEffect=true}},
    },
    [UnitDefNames["corfus"].id] = {
        {class='ShieldSphere',options=corfusShieldSphere},
        {class='ShieldJitter',options={life=math.huge, pos={0,50,0}, size=23.5, precision=22, repeatEffect=true}},
    },
    [UnitDefNames["armafus"].id] = {
        {class='ShieldSphere',options=armafusShieldSphere},
        {class='ShieldJitter',options={layer=-16, life=math.huge, pos={0,60,0}, size=28.5, precision=22, repeatEffect=true}},
    },
    [UnitDefNames["corgate"].id] = {
        {class='Bursts',options=MergeTable({pos={0,40,0}},shieldBursts550)},
        {class='ShieldJitter',options={delay=0,life=math.huge, pos={0,42,0}, size=12, precision=22, repeatEffect=true}},
        {class='ShieldJitter', options={delay=0,life=math.huge, pos={0,42,0.0}, size=555, precision=0, strength   = 0.001, repeatEffect=true}},
        {class='ShieldSphere',options=corgateShieldSphere},
        --{class='ShieldJitter',options={life=math.huge, pos={0,42,0}, size=20, precision=2, repeatEffect=true}},
    },
    [UnitDefNames["corfgate"].id] = {
        {class='Bursts',options=MergeTable({pos={0,40,0}},shieldBursts600)},
        {class='ShieldJitter',options={delay=0,life=math.huge, pos={0,42,0}, size=12, precision=22, repeatEffect=true}},
        {class='ShieldJitter', options={delay=0,life=math.huge, pos={0,42,0.0}, size=555, precision=0, strength   = 0.001, repeatEffect=true}},
        {class='ShieldSphere',options=corgateShieldSphere},
        --{class='ShieldJitter',options={life=math.huge, pos={0,42,0}, size=20, precision=2, repeatEffect=true}},
    },
    [UnitDefNames["armgate"].id] = {
        {class='Bursts',options=MergeTable({pos={0,25,5}},shieldBursts550)},
        {class='ShieldJitter',options={delay=0,life=math.huge, pos={0,23.5,-5}, size=15, precision=22, repeatEffect=true}},
        {class='ShieldJitter', options={delay=0,life=math.huge, pos={0,23.5,-5}, size=555, precision=0, strength   = 0.001, repeatEffect=true}},
        {class='ShieldSphere',options=armgateShieldSphere},
    },
    [UnitDefNames["armfgate"].id] = {
        {class='Bursts',options=MergeTable({pos={0,25,0}},shieldBursts600)},
        {class='ShieldJitter',options={delay=0,life=math.huge, pos={0,25,0}, size=15, precision=22, repeatEffect=true}},
        {class='ShieldJitter', options={delay=0,life=math.huge, pos={0,25,0}, size=555, precision=0, strength   = 0.001, repeatEffect=true}},
        {class='ShieldSphere',options=MergeTable(armgateShieldSphere, {pos={0,25,0}})},
    },

    --T1 ARM AIR
    [UnitDefNames["armatlas"].id] = {
        {class='AirJet',options={color={0.7,0.4,0.1}, width=3, length=12, piece="thrustl", onActive=true, light=1}},
 	    {class='AirJet',options={color={0.7,0.4,0.1}, width=3, length=12, piece="thrustr", onActive=true, light=1}},
	    {class='AirJet',options={color={0.7,0.4,0.1}, width=4, length=15, piece="thrustc", onActive=true, xzVelocity=1.5, light=1}},
    },
    [UnitDefNames["armkam"].id] = {
        {class='AirJet',options={color={0.7,0.4,0.1}, width=3, length=28, piece="thrusta", onActive=true, xzVelocity=1.5, light=1, emitVector = {0,1,0}}},
        {class='AirJet',options={color={0.7,0.4,0.1}, width=3, length=28, piece="thrustb", onActive=true, xzVelocity=1.5, light=1, emitVector = {0,1,0}}},
    },
    [UnitDefNames["armthund"].id] = {
        {class='AirJet',options={color={0.7,0.4,0.1}, width=2, length=17, piece="thrust1", onActive=true, light=1}},
        {class='AirJet',options={color={0.7,0.4,0.1}, width=2, length=17, piece="thrust2", onActive=true}},
        {class='AirJet',options={color={0.7,0.4,0.1}, width=2, length=17, piece="thrust3", onActive=true}},
        {class='AirJet',options={color={0.7,0.4,0.1}, width=2, length=17, piece="thrust4", onActive=true, light=1}},
        {class='AirJet',options={color={0.7,0.4,0.1}, width=4, length=25, piece="thrustc", onActive=true, light=1.3}},
    },
    [UnitDefNames["armpeep"].id] = {
        {class='AirJet',options={color={0.7,0.4,0.1}, width=4, length=20, piece="jet1", onActive=true}},
        {class='AirJet',options={color={0.7,0.4,0.1}, width=4, length=20, piece="jet2", onActive=true}},
    },
    [UnitDefNames["armfig"].id] = {
        {class='AirJet',options={color={0.7,0.4,0.1}, width=6, length=45, piece="thrust", onActive=true}},
    },
    [UnitDefNames["armca"].id] = {
        {class='AirJet',options={color={0.7,0.4,0.1}, width=6, length=24, piece="thrust", onActive=true, xzVelocity=1.2}},
    },

    --T1 CORE
    [UnitDefNames["corshad"].id] = {
        {class='AirJet',options={color={0.7,0.4,0.1}, width=4, length=24, piece="thrusta1", onActive=true, light=1}},
        {class='AirJet',options={color={0.7,0.4,0.1}, width=4, length=24, piece="thrusta2", onActive=true, light=1}},
        {class='AirJet',options={color={0.7,0.4,0.1}, width=5, length=33, piece="thrustb1", onActive=true, light=1}},
        {class='AirJet',options={color={0.7,0.4,0.1}, width=5, length=33, piece="thrustb2", onActive=true, light=1}},
    },
    [UnitDefNames["corvalk"].id] = {
        {class='AirJet',options={color={0.7,0.4,0.1}, width=6, length=17, piece="thrust1", emitVector= {0,1,0}, onActive=true, light=1}},
        {class='AirJet',options={color={0.7,0.4,0.1}, width=6, length=17, piece="thrust3", emitVector= {0,1,0}, onActive=true, light=1}},
        {class='AirJet',options={color={0.7,0.4,0.1}, width=6, length=17, piece="thrust2", emitVector= {0,1,0}, onActive=true, light=1}},
        {class='AirJet',options={color={0.7,0.4,0.1}, width=6, length=17, piece="thrust4", emitVector= {0,1,0}, onActive=true, light=1}},
    },
    [UnitDefNames["corfink"].id] = {
        {class='AirJet',options={color={0.7,0.4,0.1}, width=3, length=20, piece="thrustb", onActive=true}},
    },
    [UnitDefNames["corveng"].id] = {
        {class='AirJet',options={color={0.7,0.4,0.1}, width=3, length=20, piece="thrust1", onActive=true}},
        {class='AirJet',options={color={0.7,0.4,0.1}, width=3, length=20, piece="thrust2", onActive=true}},
    },

    --T2 ARM
    [UnitDefNames["armstil"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=3.5, length=40, piece="thrusta", onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=3.5, length=40, piece="thrustb", onActive=true, light=1}},
    },
    [UnitDefNames["armblade"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=3.5, length=25, piece="thrust", onActive=true, light=1, xzVelocity=1.5}},
    },
    [UnitDefNames["armliche"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=3.5, length=44, piece="thrusta", onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=3.5, length=44, piece="thrustb", onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=3.5, length=44, piece="thrustc", onActive=true, light=1}},
    },
    [UnitDefNames["armaca"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=6, length=22, piece="thrust", onActive=true, xzVelocity=1.2}},
    },
    [UnitDefNames["armawac"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=3.5, length=30, piece="thrust", onActive=true, light=1}},
    },
    [UnitDefNames["armdfly"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=3.5, length=35, piece="thrusta", onActive=true, xzVelocity=1.5, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=3.5, length=35, piece="thrustb", onActive=true, xzVelocity=1.5, light=1}},
    },
    [UnitDefNames["armbrawl"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=3.7, length=15, piece="thrust1", onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=3.7, length=15, piece="thrust2", onActive=true, light=1}},
    },
    [UnitDefNames["armlance"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=5, length=40, piece="thrust1", onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=5, length=40, piece="thrust2", onActive=true, light=1}},
    },
    [UnitDefNames["armpnix"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=7, length=35, piece="thrusta", onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=7, length=35, piece="thrustb", onActive=true, light=1}},
    },
    [UnitDefNames["armhawk"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=5, length=35, piece="thrust", onActive=true}},
    },

    --T2 CORE

    [UnitDefNames["corhurc"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=8, length=50, piece="thrustb", onActive=true, light=2.2}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=5, length=35, piece="thrusta1", onActive=true}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=5, length=35, piece="thrusta2", onActive=true}},
    },
    [UnitDefNames["corvamp"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=3.5, length=35, piece="thrusta", onActive=true}},
    },
    [UnitDefNames["cortitan"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=5, length=35, piece="thrustb", onActive=true, light=1}},
    },
    [UnitDefNames["corape"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=7, length=22, piece="thrust1b", emitVector= {0,1,0}, onActive=true, xzVelocity=1.5, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=7, length=22, piece="thrust2b", emitVector= {0,1,0}, onActive=true, xzVelocity=1.5, light=1}},
    },
    [UnitDefNames["corca"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=4, length=15, piece="thrust", onActive=true, xzVelocity=1.2}},
    },
    [UnitDefNames["coraca"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=6, length=22, piece="thrust", onActive=true, xzVelocity=1.2}},
    },
    [UnitDefNames["corcrw"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=13, length=22, piece="thrustrra", emitVector= {0,1,0}, onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=13, length=22, piece="thrustrla", emitVector= {0,1,0}, onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=10, length=20, piece="thrustfra", emitVector= {0,1,0}, onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=10, length=22, piece="thrustfla", emitVector= {0,1,0}, onActive=true, light=1}},
    },
    [UnitDefNames["corseah"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=13, length=25, piece="thrustrra", emitVector= {0,1,0}, onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=13, length=25, piece="thrustrla", emitVector= {0,1,0}, onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=10, length=25, piece="thrustfra", emitVector= {0,1,0}, onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=10, length=25, piece="thrustfla", emitVector= {0,1,0}, onActive=true, light=1}},
    },
    [UnitDefNames["cortitan"].id] = {
        {class='AirJet',options={color={0.1,0.4,0.6}, width=9, length=40, piece="thrustb", onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=5, length=35, piece="thrusta1", onActive=true, light=1}},
        {class='AirJet',options={color={0.1,0.4,0.6}, width=5, length=35, piece="thrusta2", onActive=true, light=1}},
    },
    --SEAPLANE ARM

    [UnitDefNames["armcsa"].id] = {
        {class='AirJet',options={color={0.2,0.8,0.2}, width=7, length=25, piece="thrusta", onActive=true}},
        {class='AirJet',options={color={0.2,0.8,0.2}, width=5, length=17, piece="thrustb", onActive=true}},
    },
    [UnitDefNames["armsfig"].id] = {
        {class='AirJet',options={color={0.2,0.8,0.2}, width=4, length=25, piece="thrust", onActive=true}},
    },
    [UnitDefNames["armseap"].id] = {
        {class='AirJet',options={color={0.2,0.8,0.2}, width=5, length=35, piece="thrust", onActive=true, light=1}},
    },
    [UnitDefNames["armsehak"].id] = {
        {class='AirJet',options={color={0.2,0.8,0.2}, width=3.5, length=37, piece="thrust", onActive=true}, light=1},
    },
    [UnitDefNames["armsb"].id] = {
        {class='AirJet',options={color={0.2,0.8,0.2}, width=4, length=36, piece="thrustc", onActive=true, light=1}},
        {class='AirJet',options={color={0.2,0.8,0.2}, width=2.2, length=18, piece="thrusta", onActive=true, light=1}},
        {class='AirJet',options={color={0.2,0.8,0.2}, width=2.2, length=18, piece="thrustb", onActive=true, light=1}},
    },
    --SEAPLANE CORE
    [UnitDefNames["corsfig"].id] = {
        {class='AirJet',options={color={0.2,0.8,0.2}, width=3, length=32, piece="thrust", onActive=true}},
    },
    [UnitDefNames["corseap"].id] = {
        {class='AirJet',options={color={0.2,0.8,0.2}, width=3, length=32, piece="thrust", onActive=true, light=1}},
    },
    [UnitDefNames["corawac"].id] = {
        {class='AirJet',options={color={0.2,0.8,0.2}, width=4, length=30, piece="thrust", onActive=true, light=1}},
    },
    [UnitDefNames["corhunt"].id] = {
        {class='AirJet',options={color={0.2,0.8,0.2}, width=4, length=37, piece="thrust", onActive=true, light=1}},
    },
    [UnitDefNames["corsb"].id] = {
        {class='AirJet',options={color={0.2,0.8,0.2}, width=3.3, length=40, piece="thrusta", onActive=true, light=1}},
        {class='AirJet',options={color={0.2,0.8,0.2}, width=3.3, length=40, piece="thrustb", onActive=true, light=1}},
    },
}


-- remove airjet coloring (will use default team color isntead)
--for udid, effects in pairs(UnitEffects) do
--    for e,effect in pairs(effects) do
--        if effect.class == 'AirJet' and effect.options and effect.options.color then
--           UnitEffects[udid][e].options.color = nil
--        end
--    end
--end


local t = os.date('*t')
if (t.yday>343) then --(t.month==12)

    UnitEffects[UnitDefNames["armcom"].id] = {
        {class='SantaHat',options={color={1,0.1,0,1}, pos={0,24,-5.35}, emitVector={0.3,1,0.2}, width=3.6, height=8, ballSize=0.95, piecenum=8, piece="torso"}},
    }
    UnitEffects[UnitDefNames["armdecom"].id] = {
        {class='SantaHat',options={color={1,0.1,0,1}, pos={0,24,-5.35}, emitVector={0.3,1,0.2}, width=3.6, height=8, ballSize=0.95, piecenum=8, piece="torso"}},
    }
    UnitEffects[UnitDefNames["corcom"].id] = {
        {class='SantaHat',options={color={1,0.1,0,1}, pos={0,6.25,-0.3}, emitVector={0.3,1,0.2}, width=4.6, height=8.5, ballSize=1, piecenum=16, piece="head"}},
    }
    UnitEffects[UnitDefNames["cordecom"].id] = {
        {class='SantaHat',options={color={1,0.1,0,1}, pos={0,6.25,-0.3}, emitVector={0.3,1,0.2}, width=4.6, height=8.5, ballSize=1, piecenum=16, piece="head"}},
    }
end
local abs = math.abs
local spGetSpectatingState = Spring.GetSpectatingState
local spGetUnitDefID       = Spring.GetUnitDefID
local spGetUnitRulesParam  = Spring.GetUnitRulesParam
local spGetUnitIsActive    = Spring.GetUnitIsActive

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local Lups  -- Lua Particle System
local LupsAddFX
local particleIDs = {}
local initialized = false --// if LUPS isn't started yet, we try it once a gameframe later
local tryloading  = 1     --// try to activate lups if it isn't found

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function ClearFxs(unitID)
  if (particleIDs[unitID]) then
    for _,fxID in ipairs(particleIDs[unitID]) do
      Lups.RemoveParticles(fxID)
    end
    particleIDs[unitID] = nil
  end
end

local function ClearFx(unitID, fxIDtoDel)
  if (particleIDs[unitID]) then
	local newTable = {}
	for _,fxID in ipairs(particleIDs[unitID]) do
		if fxID == fxIDtoDel then 
			Lups.RemoveParticles(fxID)
		else 
			newTable[#newTable+1] = fxID
		end
    end
	if #newTable == 0 then 
		particleIDs[unitID] = nil
	else 
		particleIDs[unitID] = newTable
	end
  end
end

local function AddFxs(unitID,fxID)
  if (not particleIDs[unitID]) then
    particleIDs[unitID] = {}
  end

  local unitFXs = particleIDs[unitID]
  unitFXs[#unitFXs+1] = fxID
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function UnitFinished(_,unitID,unitDefID)

  local effects = UnitEffects[unitDefID]
  if (effects) then
    for _,fx in ipairs(effects) do
      if (not fx.options) then
        Spring.Echo("LUPS DEBUG ", UnitDefs[unitDefID].name, fx and fx.class)
        return
      end

      if (fx.class=="GroundFlash") then
        fx.options.pos = { Spring.GetUnitBasePosition(unitID) }
      end
      fx.options.unit = unitID
      AddFxs( unitID,LupsAddFX(fx.class,fx.options) )
      fx.options.unit = nil
    end
  end
end

local function UnitDestroyed(_,unitID,unitDefID)
  ClearFxs(unitID)
end

local function UnitEnteredLos(_,unitID)
  local spec, fullSpec = spGetSpectatingState()
  if (spec and fullSpec) then return end
    
  local unitDefID = spGetUnitDefID(unitID)
  local effects   = UnitEffects[unitDefID]
  if (effects) then
	for _,fx in ipairs(effects) do
      if (fx.options.onActive == true) and (spGetUnitIsActive(unitID) == nil) then
	  	break
	  else
		if (fx.class=="GroundFlash") then
		  fx.options.pos = { Spring.GetUnitBasePosition(unitID) }
		end
		fx.options.unit = unitID
		fx.options.under_construction = spGetUnitRulesParam(unitID, "under_construction")
		AddFxs( unitID,LupsAddFX(fx.class,fx.options) )
		fx.options.unit = nil
	  end
	end
  end
  
end


local function UnitLeftLos(_,unitID)
  local spec, fullSpec = spGetSpectatingState()
  if (spec and fullSpec) then return end

  ClearFxs(unitID)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function PlayerChanged(_,playerID)
  if (playerID == Spring.GetMyPlayerID()) then
    --// clear all FXs
    for _,unitFxIDs in pairs(particleIDs) do
      for _,fxID in ipairs(unitFxIDs) do
        Lups.RemoveParticles(fxID)
      end
    end
    particleIDs = {}

    widgetHandler:UpdateWidgetCallIn("Update",widget)
  end
end

local function CheckForExistingUnits()
  --// initialize effects for existing units
  local allUnits = Spring.GetAllUnits();
  for i=1,#allUnits do
    local unitID    = allUnits[i]
    local unitDefID = Spring.GetUnitDefID(unitID)
    if (spGetUnitRulesParam(unitID, "under_construction") ~= 1) then
        local _,_,inBuild = Spring.GetUnitIsStunned(unitID)
        if not inBuild then
            UnitFinished(nil,unitID,unitDefID)
        end
	end
  end

  widgetHandler:RemoveWidgetCallIn("Update",widget)
end

function widget:GameFrame()
  if (Spring.GetGameFrame() > 0) then
    Spring.SendLuaRulesMsg("lups running","allies")
    widgetHandler:RemoveWidgetCallIn("GameFrame",widget)
  end
end

function widget:Update()
  Lups = WG['Lups']
  local LupsWidget = widgetHandler.knownWidgets['Lups'] or {}

  --// Lups running?
  if (not initialized) then
    if (Lups and LupsWidget.active) then
      if (tryloading==-1) then
        Spring.Echo("LuaParticleSystem (Lups) activated.")
      end
      initialized=true
      return
    else
      if (tryloading==1) then
        Spring.Echo("Lups not found! Trying to activate it.")
        widgetHandler:EnableWidget("Lups")
        tryloading=-1
        return
      else
        Spring.Echo("LuaParticleSystem (Lups) couldn't be loaded!")
        widgetHandler:RemoveWidgetCallIn("Update",self)
        return
      end
    end
  end

  LupsAddFX = Lups.AddParticles

  Spring.SendLuaRulesMsg("lups running","allies")

  widget.UnitFinished   = UnitFinished
  widget.UnitDestroyed  = UnitDestroyed
  widget.UnitEnteredLos = UnitEnteredLos
  widget.UnitLeftLos    = UnitLeftLos
  widget.GameFrame      = GameFrame
  widget.PlayerChanged  = PlayerChanged
  widgetHandler:UpdateWidgetCallIn("UnitFinished",widget)
  widgetHandler:UpdateWidgetCallIn("UnitDestroyed",widget)
  widgetHandler:UpdateWidgetCallIn("UnitEnteredLos",widget)
  widgetHandler:UpdateWidgetCallIn("UnitLeftLos",widget)
  widgetHandler:UpdateWidgetCallIn("GameFrame",widget)
  widgetHandler:UpdateWidgetCallIn("PlayerChanged",widget)

  widget.Update = CheckForExistingUnits
  widgetHandler:UpdateWidgetCallIn("Update",widget)
end

function widget:Shutdown()
  if (initialized) then
    for _,unitFxIDs in pairs(particleIDs) do
      for _,fxID in ipairs(unitFxIDs) do
        Lups.RemoveParticles(fxID)
      end
    end
    particleIDs = {}
  end

  Spring.SendLuaRulesMsg("lups shutdown","allies")
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------