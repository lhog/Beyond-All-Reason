
-- see alldefs.lua for documentation
-- load the games _Post functions for defs, and find out if saving to custom params is wanted
VFS.Include("gamedata/alldefs_post.lua")
-- load functionality for saving to custom params
VFS.Include("gamedata/post_save_to_customparams.lua")

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


-- create PBR unit alternatives
local addedUnits = {}
for name,uDef in pairs(UnitDefs) do
    if string.sub(name, 1, 3) == 'arm' or string.sub(name, 1, 3) == 'cor' then
        addedUnits[name..'_pbr'] = deepcopy(uDef)
        if not addedUnits[name..'_pbr'].customparams then
            addedUnits[name..'_pbr'].customparams = {}
        end
        addedUnits[name..'_pbr'].customparams.pbr = true
    end
end
for name,ud in pairs(addedUnits) do UnitDefs[name] = ud end


-- handle unba modoption
if (Spring.GetModOptions) and Spring.GetModOptions().unba and Spring.GetModOptions().unba == "enabled" then
	VFS.Include("gamedata/unbaconfigs/unbacom_post.lua")
	VFS.Include("gamedata/unbaconfigs/stats.lua")
	VFS.Include("gamedata/unbaconfigs/buildoptions.lua")
	UnbaCom_Post("armcom")
	UnbaCom_Post("corcom")
end


-- handle unitdefs and the weapons they contain
for name,ud in pairs(UnitDefs) do
  UnitDef_Post(name,ud)
  if ud.weapondefs then
	for wname,wd in pairs(ud.weapondefs) do
	  WeaponDef_Post(wname,wd)
	end
  end 
  
  --ud.acceleration = 0.75
  --ud.turnrate = 800
  
  if SaveDefsToCustomParams then
      SaveDefToCustomParams("UnitDefs", name, ud)    
  end
end