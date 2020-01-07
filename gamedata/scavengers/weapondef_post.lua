-- this file gets included in alldefs_post.lua

function scav_Wdef_Post(name, wDef)
    if wDef.weapontype == "Cannon" then
        wDef.rgbcolor = {0.95, 0.32, 1}
        --wDef.colormap = [[0.95 0.32 1]]   
    elseif wDef.weapontype == "LightningCannon" then
    wDef.rgbcolor = {0.95, 0.32, 1}
    wDef.customparams.expl_light_color = {0.95, 0.32, 1}
	wDef.customparams.light_color = {0.95, 0.32, 1}	
	wDef.explosiongenerator = "custom:genericshellexplosion-medium-lightning2-purple"
        --wDef.colormap = [[0.95 0.32 1]]  
    elseif wDef.weapontype == "BeamLaser" or wDef.weapontype == "LaserCannon" or wDef.weapontype == "DGun" then
        wDef.rgbcolor = {0.95, 0.32, 1}
        wDef.rgbcolor2 = {1, 0.8, 1}
    end
    return wDef
end