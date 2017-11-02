return {
	armgplat = {
		acceleration = 0,
		activatewhenbuilt = true,
		brakerate = 0,
		buildangle = 16384,
		buildcostenergy = 900,
		buildcostmetal = 110,
		buildpic = "ARMGPLAT.DDS",
		buildtime = 2860,
		canrepeat = false,
		category = "ALL NOTLAND WEAPON NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE",
		collisionvolumeoffsets = "0 -6 0",
		collisionvolumescales = "76 36 76",
		collisionvolumetype = "CylY",
		corpse = "DEAD",
		description = "Floating Gun Platform (Good vs Light Boats)",
		energymake = 1,
		energystorage = 10,
		explodeas = "mediumBuildingexplosiongeneric",
		footprintx = 4,
		footprintz = 4,
		icontype = "building",
		idleautoheal = 5,
		idletime = 1800,
		maxdamage = 680,
		minwaterdepth = 1,
		name = "Gun Platform",
		nochasecategory = "MOBILE",
		objectname = "ARMGPLAT",
		script = "ARMGPLAT_LUS.LUA",
		seismicsignature = 0,
		selfdestructas = "mediumBuildingExplosionGenericSelfd",
		sightdistance = 550,
		waterline = 1,
		yardmap = "wwwwwwwwwwwwwwww",
		customparams = {
			removewait = true,
		},
		featuredefs = {
			dead = {
				blocking = false,
				category = "corpses",
				collisionvolumeoffsets = "0.0 -6.6047363281e-05 -15.62939453125e-06",
				collisionvolumescales = "50.0 45.7867279053 45.9999847412",
				collisionvolumetype = "Box",
				damage = 750,
				description = "Gun Platform Wreckage",
				energy = 0,
				footprintx = 4,
				footprintz = 4,
				height = 20,
				hitdensity = 100,
				metal = 80,
				object = "ARMGPLAT_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = { 
 			pieceExplosionGenerators = { 
				"deathceg2",
				"deathceg3",
				"deathceg4",
			},
		},
		sounds = {
			canceldestruct = "cancel2",
			cloak = "kloak1",
			uncloak = "kloak1un",
			underattack = "warning1",
			cant = {
				[1] = "cantdo4",
			},
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			ok = {
				[1] = "twractv3",
			},
			select = {
				[1] = "twractv3",
			},
		},
		weapondefs = {
			armgplat = {
				accuracy = 4,
				areaofeffect = 16,
				avoidfeature = false,
				sizedecay = 0.1,
				alphadecay = 0.5,
				burst = 2,
				burstrate = 0.1,
				projectiles = 1,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				explosiongenerator = "custom:plasmahit-medium",
				impulseboost = 0.123,
				impulsefactor = 0.123,
				name = "Cannon",
				noselfdamage = true,
				range = 430,
				reloadtime = 1.625*0.5,
				soundhit = "xplomed2",
				soundhitwet = "splshbig",
				soundhitwetvolume = 0.5,
				soundstart = "cannhvy1",
				targetmoveerror = 0.1,
				turret = true,
				size = 1.75,
				tolerance = 0,
				firetolerance = 200,
				weapontype = "Cannon",
				weaponvelocity = 700,
				separation = 1.0,
				nogap = false,
				stages = 20,
				damage = {
					bombers = 1*1.5*1,
					default = 30*1.5*1,
					heavyunits = 30*1.5*0.7,
					fighters = 10*1.5*1,
					subs = 1*1.5*1,
					vtol = 1*1.5*1,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL LIGHTBOAT CAPITALSHIP",
				def = "ARMGPLAT",
				onlytargetcategory = "NOTSUB",
			},
		},
	},
}
