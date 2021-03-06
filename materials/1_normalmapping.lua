-- $Id$
--------------------------------------------------------------------------------

local function SunChanged(curShaderObj)
	curShaderObj:SetUniformAlways("shadowDensity", gl.GetSun("shadowDensity" ,"unit"))

	curShaderObj:SetUniformAlways("sunAmbient", gl.GetSun("ambient" ,"unit"))
	curShaderObj:SetUniformAlways("sunDiffuse", gl.GetSun("diffuse" ,"unit"))
	curShaderObj:SetUniformAlways("sunSpecular", gl.GetSun("specular" ,"unit"))

	curShaderObj:SetUniformFloatArrayAlways("pbrParams", {
		Spring.GetConfigFloat("tonemapA", 15.0),
		Spring.GetConfigFloat("tonemapB", 0.3),
		Spring.GetConfigFloat("tonemapC", 15.0),
		Spring.GetConfigFloat("tonemapD", 0.5),
		Spring.GetConfigFloat("tonemapE", 1.5),
		Spring.GetConfigFloat("envAmbient", 0.2),
		Spring.GetConfigFloat("unitSunMult", 1.0),
		Spring.GetConfigFloat("unitExposureMult", 1.0),
	})
end


local default_lua = VFS.Include("materials/Shaders/default.lua")

local matTemplate = {
	shaderDefinitions = {
		"#define use_normalmapping",
		"#define deferred_mode 0",
		"#define flashlights",
		"#define use_vertex_ao",

		"#define SHADOW_SOFTNESS SHADOW_SOFTER",

		"#define SUNMULT pbrParams[6]",
		"#define EXPOSURE pbrParams[7]",

		"#define SPECULAR_AO",

		--"#define ROUGHNESS_PERTURB_NORMAL 0.025",
		--"#define ROUGHNESS_PERTURB_COLOR 0.05",

		"#define USE_ENVIRONMENT_DIFFUSE",
		"#define USE_ENVIRONMENT_SPECULAR",

		"#define DO_GAMMA_CORRECTION",
		"#define TONEMAP(c) CustomTM(c)",
	},
	deferredDefinitions = {
		"#define use_normalmapping",
		"#define deferred_mode 1",
		"#define flashlights",
		"#define use_vertex_ao",

		"#define SHADOW_SOFTNESS SHADOW_HARD",

		"#define SUNMULT pbrParams[6]",
		"#define EXPOSURE pbrParams[7]",

		"#define SPECULAR_AO",

		--"#define ROUGHNESS_PERTURB_NORMAL 0.025",
		--"#define ROUGHNESS_PERTURB_COLOR 0.05",

		"#define USE_ENVIRONMENT_DIFFUSE",
		"#define USE_ENVIRONMENT_SPECULAR",

		"#define DO_GAMMA_CORRECTION",
		"#define TONEMAP(c) CustomTM(c)",

		"#define MAT_IDX 1",
	},

	shader    = default_lua,
	deferred  = default_lua,
	usecamera = false,
	force = true,
	culling   = GL.BACK,
	predl  = nil,
	postdl = nil,
	texunits  = {
		[0] = '%%UNITDEFID:0',
		[1] = '%%UNITDEFID:1',
		[2] = '$shadow',
		[4] = '$reflection',
		[5] = '%NORMALTEX',
		[6] = "$info",
		[7] = GG.GetBrdfTexture(),
	},
	SunChanged = SunChanged,
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local materials = {}
local unitMaterials = {}

for i = 1, #UnitDefs do
	local udef = UnitDefs[i]
	local udefCM = udef.customParams

	if (udefCM.arm_tank == nil) and udefCM.normaltex and VFS.FileExists(udefCM.normaltex) then
		local lm = tonumber(udefCM.lumamult) or 1
		local matName = string.format("%s(lumamult=%f)", "normalMappedS3O", lm)
		if not materials[matName] then
			materials[matName] = Spring.Utilities.CopyTable(matTemplate, true)
			if lm ~= 1 then
				local lmLM = string.format("#define LUMAMULT %f", lm)
				table.insert(materials[matName].shaderDefinitions, lmLM)
				table.insert(materials[matName].deferredDefinitions, lmLM)
			end
		end

		unitMaterials[udef.name] = {matName, NORMALTEX = udefCM.normaltex}
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return materials, unitMaterials

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
