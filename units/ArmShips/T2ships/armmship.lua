return {
	armmship = {
		activatewhenbuilt = true,
		buildcostenergy = 14000,
		buildcostmetal = 2200,
		buildpic = "ARMMSHIP.DDS",
		buildtime = 0.75 * 1.5 * 0.8*24817,
		canmove = true,
		category = "ALL NOTLAND MOBILE WEAPON NOTSUB SHIP NOTAIR NOTHOVER SURFACE",
		collisionvolumeoffsets = "0 -5 -3",
		collisionvolumescales = "44 44 108",
		collisionvolumetype = "CylZ",
		corpse = "DEAD",
		description = "Missile Cruiser",
		energymake = 0.8,
		energyuse = 0.8,
		explodeas = "largeExplosionGeneric",
		floater = true,
		footprintx = 5,
		footprintz = 5,
		icontype = "sea",
		idleautoheal = 5,
		idletime = 1800,
		maxdamage = 2200,
		minwaterdepth = 12,
		movementclass = "BOAT55X5",
		name = "Ranger",
		nochasecategory = "VTOL",
		objectname = "ARMMSHIP",
		radardistance = 1400,
		seismicsignature = 0,
		selfdestructas = "largeExplosionGenericSelfd",
		sightdistance = 318.5,
		waterline = 0,
		--move
		acceleration = 0.035,
		brakerate = 0.06,
		turninplace = true,
		maxvelocity = 2.10,
		turninplaceanglelimit = 140,
		turnrate = 200,
		--end move
		customparams = {
			techlevel = 2,
		},
		featuredefs = {
			dead = {
				blocking = false,
				category = "corpses",
				collisionvolumeoffsets = "-1.52864837646 2.44506835934e-05 -1.26249694824",
				collisionvolumescales = "46.7322845459 37.6582489014 110.324981689",
				collisionvolumetype = "Box",
				damage = 1320,
				description = "Ranger Wreckage",
				energy = 0.8*0,
				featuredead = "HEAP",
				footprintx = 5,
				footprintz = 5,
				height = 4,
				hitdensity = 100,
				metal = 0.8*1721,
				object = "ARMMSHIP_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				damage = 2016,
				description = "Ranger Heap",
				energy = 0.8*0,
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 0.8*491,
				object = "4X4B",
                collisionvolumescales = "85.0 14.0 6.0",
                collisionvolumetype = "cylY",
				reclaimable = true,
				resurrectable = 0,
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
				[1] = "sharmmov",
			},
			select = {
				[1] = "sharmsel",
			},
		},
		weapondefs = {
			armmship_rocket = {
				cegTag = "missiletrailmedium-starburst",
				explosiongenerator = "custom:genericshellexplosion-large-bomb",
				areaofeffect = 120,
				avoidfeature = false,
				burnblow = true,
				craterareaofeffect = 120,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.5,
				energypershot = 100,
				firestarter = 100,
				flighttime = 15,
				impulseboost = 0.123,
				impulsefactor = 0.123,
				metalpershot = 0,
				model = "rocket",
				name = "Rocket",
				noselfdamage = true,
				range = 1550,
				reloadtime = 6,
				soundhit = "xplomed4",
				soundhitwet = "splsmed",
				soundhitwetvolume = 0.5,
				soundstart = "Rockhvy1",
				smoketrail = false,
				texture1 = "trans",
				texture2 = "null",
				texture3 = "null",
				tolerance = 4000,
				turnrate = 24384,
				weaponacceleration = 80,
				weapontimer = 5,
				weapontype = "StarburstLauncher",
				weaponvelocity = 400,
				damage = {
					commanders = 500,
					default = 800,
					subs = 5,
				},
				customparams = {
					light_mult = 2.6,
					light_radius_mult = 1.2,
					light_color = "1 0.6 0.15",
					expl_light_mult = 1.2,
					expl_light_radius_mult = 1.25,
					expl_light_life_mult = 1.25,
                    expl_light_color = "1 0.5 0.05",
                },
			},
			armmship_missile = {
				areaofeffect = 96,
				avoidfeature = false,
				canattackground = false,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				cegTag = "missiletrailaa",
				explosiongenerator = "custom:genericshellexplosion-tiny-aa",
				firestarter = 70,
				flighttime = 3,
				impulseboost = 0.123,
				impulsefactor = 0.123,
				metalpershot = 0,
				model = "missile",
				name = "Missiles",
				noselfdamage = true,
				range = 1550,
				reloadtime = 6,
				smoketrail = true,
				soundhit = "xplomed2",
				soundhitwet = "splshbig",
				soundhitwetvolume = 0.5,
				soundstart = "rockhvy2",
				startvelocity = 430,
				texture1 = "trans",
				tolerance = 8000,
				tracks = true,
				turnrate = 30000,
				turret = true,
				weaponacceleration = 90,
				weapontimer = 5,
				weapontype = "MissileLauncher",
				weaponvelocity = 450,
				damage = {
					default = 138,
					subs = 5,
				},
				customparams = {
					light_skip = true,		-- used by light_effects widget
                    light_color = "1 0.5 0.6",
                    expl_light_color = "1 0.4 0.5",
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "MOBILE",
				def = "ARMMSHIP_ROCKET",
				onlytargetcategory = "SURFACE",
			},
			[3] = {
				def = "ARMMSHIP_MISSILE",
				onlytargetcategory = "VTOL",
			},
		},
	},
}