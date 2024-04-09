/datum/crafting_recipe
	var/name = "" //in-game display name
	var/reqs[] = list() //type paths of items consumed associated with how many are needed
	var/blacklist[] = list() //type paths of items explicitly not allowed as an ingredient, you can expand it in New() by using typecacheof to ban subtypes
	var/result //type path of item resulting from this craft
	var/tools[] = list() //tool behaviours of items needed but not consumed
	var/pathtools[] = list() //type paths of items needed but not consumed
	var/time = 30 //time in deciseconds
	var/parts[] = list() //type paths of items that will be placed in the result
	var/chem_catalysts[] = list() //like tools but for reagents
	var/category = CAT_NONE //where it shows up in the crafting UI
	var/subcategory = CAT_NONE
	var/always_availible = TRUE //Set to FALSE if it needs to be learned first.
	var/alert_admins_on_craft = FALSE

/datum/crafting_recipe/IED
	name = "IED"
	result = /obj/item/grenade/iedcasing
	reqs = list(/datum/reagent/fuel = 50,
				/obj/item/stack/cable_coil = 1,
				/obj/item/assembly/igniter = 1,
				/obj/item/reagent_containers/food/drinks/cans = 1)
	parts = list(/obj/item/reagent_containers/food/drinks/cans = 1)
	time = 15
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/IEDsatchel
	name = "IED Satchel"
	result = /obj/item/grenade/iedsatchel
	reqs = list(/obj/item/grenade/iedcasing = 3,
				/obj/item/storage/box/large = 1,
				/obj/item/stack/tape_roll = 20,
				/obj/item/stack/cable_coil  = 10)
	time = 60
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/molotov
	name = "Molotov"
	result = /obj/item/reagent_containers/food/drinks/bottle/molotov
	reqs = list(/obj/item/reagent_containers/glass/rag = 1,
				/obj/item/reagent_containers/food/drinks/bottle = 1)
	blacklist = list(/obj/item/reagent_containers/food/drinks/bottle/molotov)
	parts = list(/obj/item/reagent_containers/food/drinks/bottle = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/stunprod
	name = "Stunprod"
	result = /obj/item/melee/baton/cattleprod
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/stack/rods = 1,
				/obj/item/assembly/igniter = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/bola
	name = "Bola"
	result = /obj/item/restraints/legcuffs/bola
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/stack/sheet/metal = 6)
	time = 20//15 faster than crafting them by hand!
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/razorgloves
	name = "Razor Gloves"
	result = /obj/item/clothing/gloves/color/black/razorgloves
	reqs = list(/obj/item/stack/tape_roll = 4,
				/obj/item/clothing/gloves/color/black = 1,
				/obj/item/cultivator = 1)
	blacklist = list(/obj/item/clothing/gloves/color/black/razorgloves) // so we don't craft razorgloves using razorgloves etc.
	time = 40
	tools = list(TOOL_WIRECUTTER)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/emittergun
	name = "Handicraft Emitter Rifle"
	result = /obj/item/gun/energy/emittergun
	reqs = list(/obj/item/stack/tape_roll = 1,
				/obj/item/stack/cable_coil  = 10,
				/obj/item/light/tube = 1,
				/obj/item/stock_parts/cell  = 2,
				/obj/item/stock_parts/capacitor = 1,
				/obj/item/pipe = 1,
				/obj/item/circuitboard/emitter = 1,
				/obj/item/stack/sheet/plasteel = 10)
	time = 120
	tools = list(TOOL_WIRECUTTER, TOOL_WELDER)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/ed209
	name = "ED209"
	result = /mob/living/simple_animal/bot/ed209
	reqs = list(/obj/item/robot_parts/robot_suit = 1,
				/obj/item/clothing/head/helmet = 1,
				/obj/item/clothing/suit/armor/vest = 1,
				/obj/item/robot_parts/l_leg = 1,
				/obj/item/robot_parts/r_leg = 1,
				/obj/item/stack/sheet/metal = 1,
				/obj/item/stack/cable_coil = 1,
				/obj/item/gun/energy/gun/advtaser = 1,
				/obj/item/stock_parts/cell = 1,
				/obj/item/assembly/prox_sensor = 1)
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	time = 60
	category = CAT_ROBOT

/datum/crafting_recipe/secbot
	name = "Secbot"
	result = /mob/living/simple_animal/bot/secbot
	reqs = list(/obj/item/assembly/signaler = 1,
				/obj/item/clothing/head/helmet = 1,
				/obj/item/melee/baton = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	tools = list(TOOL_WELDER)
	time = 60
	category = CAT_ROBOT

/datum/crafting_recipe/griefsky
	name = "General Griefsky"
	result = /mob/living/simple_animal/bot/secbot/griefsky
	reqs = list(/obj/item/assembly/signaler = 1,
				/obj/item/clothing/head/helmet = 1,
				/obj/item/melee/energy/sword = 4,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 2,
				/obj/item/robot_parts/l_arm = 2)
	tools = list(TOOL_WELDER)
	time = 120
	category = CAT_ROBOT
	alert_admins_on_craft = TRUE

/datum/crafting_recipe/cleanbot
	name = "Cleanbot"
	result = /mob/living/simple_animal/bot/cleanbot
	reqs = list(/obj/item/reagent_containers/glass/bucket = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/honkbot
	name = "Honkbot"
	result = /mob/living/simple_animal/bot/honkbot
	reqs = list(/obj/item/robot_parts/r_arm = 1,
				/obj/item/bikehorn = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/storage/box/clown = 1,
				/obj/item/instrument/trombone  = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/floorbot
	name = "Floorbot"
	result = /mob/living/simple_animal/bot/floorbot
	reqs = list(/obj/item/storage/toolbox = 1,
				/obj/item/stack/tile/plasteel = 10,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/medbot
	name = "Medbot"
	result = /mob/living/simple_animal/bot/medbot
	reqs = list(/obj/item/healthanalyzer = 1,
				/obj/item/storage/firstaid = 1,
				/obj/item/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/armour_plate
	name = "Armour Mecha Plate"
	result = list(/obj/item/stack/sheet/armour_plate,
				/obj/item/stack/sheet/armour_plate)
	reqs = list(/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster = 1,
				/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster = 1,
				/obj/item/stack/cable_coil = 5)
	tools = list(TOOL_WELDER)
	time = 20
	category = CAT_ROBOT

/datum/crafting_recipe/flamethrower
	name = "Flamethrower"
	result = /obj/item/flamethrower
	reqs = list(/obj/item/weldingtool = 1,
				/obj/item/assembly/igniter = 1,
				/obj/item/stack/rods = 1)
	parts = list(/obj/item/assembly/igniter = 1,
				/obj/item/weldingtool = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 10
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	alert_admins_on_craft = TRUE

/datum/crafting_recipe/revolver_ibullet
	name = "Improvised Revolver Shell"
	result = /obj/item/ammo_casing/revolver/improvised
	reqs = list(/obj/item/stack/sheet/metal = 1,
				/obj/item/stack/cable_coil = 1,
				/datum/reagent/fuel = 5,)
	tools = list(TOOL_SCREWDRIVER)
	time = 2
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/revolver_pbullet
	name = "Phosphorous Revolver Bullet"
	result = /obj/item/ammo_casing/revolver/improvised/phosphorus
	reqs = list(/obj/item/stack/sheet/metal = 1,
				/obj/item/stack/cable_coil = 1,
				/datum/reagent/phosphorus = 5,
				/datum/reagent/fuel = 5,)
	tools = list(TOOL_SCREWDRIVER)
	time = 2
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/pulseslug
	name = "Pulse Slug Shell"
	result = /obj/item/ammo_casing/shotgun/pulseslug
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stock_parts/capacitor/adv = 2,
				/obj/item/stock_parts/micro_laser/ultra = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/dragonsbreath
	name = "Dragonsbreath Shell"
	result = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/datum/reagent/phosphorus = 5,)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/frag12
	name = "FRAG-12 Shell"
	result = /obj/item/ammo_casing/shotgun/frag12
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/datum/reagent/glycerol = 5,
				/datum/reagent/acid = 5,
				/datum/reagent/acid/facid = 5,)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/ionslug
	name = "Ion Scatter Shell"
	result = /obj/item/ammo_casing/shotgun/ion
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stock_parts/micro_laser/ultra = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/improvisedslug
	name = "Improvised Shotgun Shell"
	result = /obj/item/ammo_casing/shotgun/improvised
	reqs = list(/obj/item/grenade/chem_grenade = 1,
				/obj/item/stack/sheet/metal = 1,
				/obj/item/stack/cable_coil = 1,
				/datum/reagent/fuel = 10)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/improvisedslugoverload
	name = "Overload Improvised Shell"
	result = /obj/item/ammo_casing/shotgun/improvised/overload
	reqs = list(/obj/item/ammo_casing/shotgun/improvised = 1,
				/datum/reagent/blackpowder = 10,
				/datum/reagent/plasma_dust = 20)
	blacklist = list(/obj/item/ammo_casing/shotgun/improvised/overload)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/laserslug
	name = "Laser Slug Shell"
	result = /obj/item/ammo_casing/shotgun/laserslug
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stock_parts/capacitor/adv = 1,
				/obj/item/stock_parts/micro_laser/high = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 5
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/ishotgun
	name = "Improvised Shotgun"
	result = /obj/item/gun/projectile/revolver/doublebarrel/improvised
	reqs = list(/obj/item/weaponcrafting/receiver = 1,
				/obj/item/pipe = 1,
				/obj/item/weaponcrafting/stock = 1,
				/obj/item/stack/packageWrap = 5,)
	tools = list(TOOL_SCREWDRIVER)
	time = 100
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/irevolver
	name = "Improvised Revolver"
	result = /obj/item/gun/projectile/revolver/improvised
	reqs = list(/obj/item/weaponcrafting/receiver = 1,
				/obj/item/stack/sheet/wood = 2,
				/obj/item/stack/sheet/metal = 3,
				/obj/item/stack/tape_roll = 10)
	tools = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	time = 100
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON


/datum/crafting_recipe/chainsaw
	name = "Chainsaw"
	result = /obj/item/twohanded/required/chainsaw
	reqs = list(/obj/item/circular_saw = 1,
				/obj/item/stack/cable_coil = 1,
				/obj/item/stack/sheet/plasteel = 1)
	tools = list(TOOL_WELDER)
	time = 50
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	alert_admins_on_craft = TRUE

/datum/crafting_recipe/spear
	name = "Spear"
	result = /obj/item/twohanded/spear
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/shard = 1,
				/obj/item/stack/rods = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/spooky_camera
	name = "Camera Obscura"
	result = /obj/item/camera/spooky
	time = 15
	reqs = list(/obj/item/camera = 1,
				/datum/reagent/holywater = 10)
	blacklist = list(/obj/item/camera/spooky)
	parts = list(/obj/item/camera = 1)
	category = CAT_MISC

/datum/crafting_recipe/papersack
	name = "Paper Sack"
	result = /obj/item/storage/box/papersack
	time = 10
	reqs = list(/obj/item/paper = 5)
	category = CAT_MISC

/datum/crafting_recipe/sushimat
	name = "Sushi Mat"
	result = /obj/item/kitchen/sushimat
	time = 10
	reqs = list(/obj/item/stack/sheet/wood = 1,
				/obj/item/stack/cable_coil = 2)
	category = CAT_MISC

/datum/crafting_recipe/notreallysoap
	name = "Homemade Soap"
	result = /obj/item/soap/ducttape
	time = 50
	reqs = list(/obj/item/stack/tape_roll = 1,
				/datum/reagent/liquidgibs = 10)
	category = CAT_MISC

/datum/crafting_recipe/rollingpin
	name = "Rolling Pin"
	result = /obj/item/kitchen/rollingpin
	time = 5
	reqs = list(/obj/item/stack/sheet/wood = 2)
	category = CAT_MISC

/datum/crafting_recipe/garrote
	name = "Makeshift Garrote"
	result = /obj/item/twohanded/garrote/improvised
	time = 15
	reqs = list(/obj/item/stack/sheet/wood = 1,
				/obj/item/stack/cable_coil = 5)
	pathtools = list(/obj/item/shard) // Gotta carve the wood into handles
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/makeshift_bolt
	name = "Makeshift Bolt"
	result = /obj/item/arrow/rod
	time = 5
	reqs = list(/obj/item/stack/rods = 1)
	tools = list(TOOL_WELDER)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/crossbow
	name = "Powered Crossbow"
	result = /obj/item/gun/throw/crossbow
	time = 150
	reqs = list(/obj/item/stack/rods = 3,
				/obj/item/stack/cable_coil = 10,
				/obj/item/stack/sheet/plastic = 3,
				/obj/item/stack/sheet/wood = 5)
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/glove_balloon
	name = "Latex Glove Balloon"
	result = /obj/item/latexballon
	time = 15
	reqs = list(/obj/item/clothing/gloves/color/latex = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_MISC

/datum/crafting_recipe/gold_horn
	name = "Golden bike horn"
	result = /obj/item/bikehorn/golden
	time = 20
	reqs = list(/obj/item/stack/sheet/mineral/bananium = 5,
				/obj/item/bikehorn = 1)
	category = CAT_MISC

/datum/crafting_recipe/blackcarpet
	name = "Black Carpet"
	result = /obj/item/stack/tile/carpet/black
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	blacklist = list(/obj/item/stack/tile/carpet/black)
	pathtools = list(/obj/item/toy/crayon/black)
	category = CAT_MISC

/datum/crafting_recipe/bluecarpet
	name = "Blue Carpet"
	result = /obj/item/stack/tile/carpet/blue
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	blacklist = list(/obj/item/stack/tile/carpet/blue)
	pathtools = list(/obj/item/toy/crayon/blue)
	category = CAT_MISC

/datum/crafting_recipe/cyancarpet
	name = "Cyan Carpet"
	result = /obj/item/stack/tile/carpet/cyan
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	blacklist = list(/obj/item/stack/tile/carpet/cyan)
	pathtools = list(/obj/item/toy/crayon/blue, /obj/item/toy/crayon/green)
	category = CAT_MISC

/datum/crafting_recipe/greencarpet
	name = "Green Carpet"
	result = /obj/item/stack/tile/carpet/green
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	blacklist = list(/obj/item/stack/tile/carpet/green)
	pathtools = list(/obj/item/toy/crayon/green)
	category = CAT_MISC

/datum/crafting_recipe/orangecarpet
	name = "Orange Carpet"
	result = /obj/item/stack/tile/carpet/orange
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	blacklist = list(/obj/item/stack/tile/carpet/orange)
	pathtools = list(/obj/item/toy/crayon/orange)
	category = CAT_MISC

/datum/crafting_recipe/purplecarpet
	name = "Purple Carpet"
	result = /obj/item/stack/tile/carpet/purple
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	blacklist = list(/obj/item/stack/tile/carpet/purple)
	pathtools = list(/obj/item/toy/crayon/purple)
	category = CAT_MISC

/datum/crafting_recipe/redcarpet
	name = "Red Carpet"
	result = /obj/item/stack/tile/carpet/red
	time = 10
	reqs = list(/obj/item/stack/tile/carpet = 1)
	blacklist = list(/obj/item/stack/tile/carpet/red)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_MISC

/datum/crafting_recipe/royalblackcarpet
	name = "Royal Black Carpet"
	result = /obj/item/stack/tile/carpet/royalblack/ten
	time = 10
	reqs = list(/obj/item/stack/tile/carpet/black = 10,
				/obj/item/stack/sheet/mineral/gold = 1)
	category = CAT_MISC

/datum/crafting_recipe/royalbluecarpet
	name = "Royal Blue Carpet"
	result = /obj/item/stack/tile/carpet/royalblue/ten
	time = 10
	reqs = list(/obj/item/stack/tile/carpet/blue = 10,
				/obj/item/stack/sheet/mineral/gold = 1)
	category = CAT_MISC

/datum/crafting_recipe/showercurtain
	name = "Shower Curtains"
	result = /obj/structure/curtain
	time = 20
	reqs = list(/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/sheet/plastic = 2,
				/obj/item/stack/rods = 1)
	category = CAT_MISC

/datum/crafting_recipe/chemical_payload
	name = "Chemical Payload (C4)"
	result = /obj/item/bombcore/chemical
	reqs = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/grenade/plastic/c4 = 1,
		/obj/item/grenade/chem_grenade = 2
	)
	parts = list(/obj/item/stock_parts/matter_bin = 1, /obj/item/grenade/chem_grenade = 2)
	time = 30
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	alert_admins_on_craft = TRUE

/datum/crafting_recipe/chemical_payload2
	name = "Chemical Payload (gibtonite)"
	result = /obj/item/bombcore/chemical
	reqs = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/twohanded/required/gibtonite = 1,
		/obj/item/grenade/chem_grenade = 2
	)
	parts = list(/obj/item/stock_parts/matter_bin = 1, /obj/item/grenade/chem_grenade = 2)
	time = 50
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	alert_admins_on_craft = TRUE

/datum/crafting_recipe/toxins_payload
	name = "Toxins Payload Casing"
	result = /obj/item/bombcore/toxins
	reqs = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/assembly/signaler = 1,
		/obj/item/stack/sheet/metal = 2
	)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/bonearmor
	name = "Bone Armor"
	result = /obj/item/clothing/suit/armor/bone
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 6)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonetalisman
	name = "Bone Talisman"
	result = /obj/item/clothing/accessory/necklace/talisman
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonecodpiece
	name = "Skull Codpiece"
	result = /obj/item/clothing/accessory/necklace/skullcodpiece
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/animalhide/goliath_hide = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bracers
	name = "Bone Bracers"
	result = /obj/item/clothing/gloves/bracer
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/skullhelm
	name = "Skull Helmet"
	result = /obj/item/clothing/head/helmet/skull
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 4)
	category = CAT_PRIMAL

/datum/crafting_recipe/beltprimitive
	name = "Hunter's Belt"
	result = /obj/item/storage/belt/mining/primitive
	time = 30
	reqs = list(/obj/item/stack/sheet/sinew = 4,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/goliathcloak
	name = "Goliath Cloak"
	result = /obj/item/clothing/suit/hooded/goliath
	time = 50
	reqs = list(/obj/item/stack/sheet/leather = 2,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/drakecloak
	name = "Ash Drake Armour"
	result = /obj/item/clothing/suit/hooded/drake
	time = 60
	reqs = list(/obj/item/stack/sheet/bone = 10,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/ashdrake = 5)
	category = CAT_PRIMAL

/datum/crafting_recipe/firebrand
	name = "Firebrand"
	result = /obj/item/match/firebrand
	time = 100 //Long construction time. Making fire is hard work.
	reqs = list(/obj/item/stack/sheet/wood = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/tribal_splint
	name = "Tribal Splint"
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2,
				/obj/item/stack/sheet/sinew = 1)
	result = /obj/item/stack/medical/splint/tribal
	category = CAT_PRIMAL

/datum/crafting_recipe/bonedagger
	name = "Bone Dagger"
	result = /obj/item/kitchen/knife/combat/survival/bone
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonesword
	name = "Bone Sword"
	result = /obj/item/claymore/bone
	time = 4 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 3,
				/obj/item/stack/sheet/sinew = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/goliathshield
	name = "Goliath Shield"
	result = /obj/item/shield/riot/goliath
	time = 6 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 4,
				/obj/item/stack/sheet/animalhide/goliath_hide = 3)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonespear
	name = "Bone Spear"
	result = /obj/item/twohanded/spear/bonespear
	time = 30
	reqs = list(/obj/item/stack/sheet/bone = 4,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/chitinspear
	name = "Chitin Spear"
	result = /obj/item/twohanded/spear/bonespear/chitinspear
	time = 7.5 SECONDS
	reqs = list(/obj/item/twohanded/spear/bonespear = 1, //tier 2 spear
				/obj/item/stack/sheet/sinew = 3,
				/obj/item/stack/sheet/animalhide/weaver_chitin = 8)
	blacklist = list(/obj/item/twohanded/spear/bonespear/chitinspear)
	category = CAT_PRIMAL

/datum/crafting_recipe/bow
	name = "Wooden Bow"
	result = /obj/item/gun/projectile/bow
	time = 30
	reqs = list(/obj/item/stack/sheet/wood = 2,
				 /obj/item/stack/sheet/sinew = 2,
				 /obj/item/stack/sheet/animalhide/goliath_hide = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/bone_bow
	name = "Bone Bow"
	result = /obj/item/gun/projectile/bow/ashen
	time = 8 SECONDS
	reqs = list(/obj/item/gun/projectile/bow = 1, //it's actually tier 2 bow
				/obj/item/stack/sheet/bone = 4,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2,
				/obj/item/stack/sheet/sinew = 2)
	blacklist = list(/obj/item/gun/projectile/bow/ashen)
	category = CAT_PRIMAL

/datum/crafting_recipe/arrow
	name = "Arrows"
	result = list(/obj/item/ammo_casing/caseless/arrow,
				/obj/item/ammo_casing/caseless/arrow,
				/obj/item/ammo_casing/caseless/arrow)
	time = 20
	reqs = list(/obj/item/stack/sheet/bone = 1,
				 /obj/item/stack/sheet/wood = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/ashen_arrow //the price is fully justified
	name = "Bone-tipped Arrows"
	result = list(/obj/item/ammo_casing/caseless/arrow/bone_tipped,
				/obj/item/ammo_casing/caseless/arrow/bone_tipped,
				/obj/item/ammo_casing/caseless/arrow/bone_tipped)
	time = 4 SECONDS
	reqs = list(/obj/item/ammo_casing/caseless/arrow = 3,
				/obj/item/stack/sheet/bone = 1,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/weaver_chitin = 2)
	blacklist = list(/obj/item/ammo_casing/caseless/arrow/bone_tipped)
	category = CAT_PRIMAL

/datum/crafting_recipe/quiver
	name = "Quiver"
	result = /obj/item/storage/backpack/quiver
	time = 30
	reqs = list(/obj/item/stack/sheet/wood = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/chitinquiver
	name = "Chitin Quiver"
	result = /obj/item/storage/belt/quiver_weaver
	time = 8 SECONDS
	reqs = list(/obj/item/stack/sheet/animalhide/weaver_chitin = 4) //Just one spider!
	category = CAT_PRIMAL

/datum/crafting_recipe/bola_s
	name = "Skull Bola"
	result = /obj/item/restraints/legcuffs/bola/sinew
	reqs = list(/obj/item/restraints/handcuffs/sinew = 2, //We don't have a "hand craft" version due to the need for 2 restraints in crafting.
				/obj/item/stack/sheet/bone = 3)
	time = 20
	category = CAT_PRIMAL

/datum/crafting_recipe/boneaxe
	name = "Bone Axe"
	result = /obj/item/twohanded/fireaxe/boneaxe
	time = 50
	reqs = list(/obj/item/stack/sheet/bone = 6,
				 /obj/item/stack/sheet/sinew = 3)
	category = CAT_PRIMAL

/datum/crafting_recipe/bonfire
	name = "Bonfire"
	time = 60
	reqs = list(/obj/item/grown/log = 5)
	result = /obj/structure/bonfire
	category = CAT_PRIMAL
	alert_admins_on_craft = TRUE

/datum/crafting_recipe/rake //Category resorting incoming
	name = "Rake"
	time = 30
	reqs = list(/obj/item/stack/sheet/wood = 5)
	result = /obj/item/cultivator/rake
	category = CAT_PRIMAL

/datum/crafting_recipe/woodbucket
	name = "Wooden Bucket"
	time = 30
	reqs = list(/obj/item/stack/sheet/wood = 3)
	result = /obj/item/reagent_containers/glass/bucket/wooden
	category = CAT_PRIMAL

/datum/crafting_recipe/guillotine
	name = "Guillotine"
	result = /obj/structure/guillotine
	time = 150 // Building a functioning guillotine takes time
	reqs = list(/obj/item/stack/sheet/plasteel = 3,
		        /obj/item/stack/sheet/wood = 20,
		        /obj/item/stack/cable_coil = 10)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_WELDER)
	category = CAT_MISC

/datum/crafting_recipe/ghettojetpack
	name = "Improvised Jetpack"
	result = /obj/item/tank/jetpack/improvised
	time = 30
	reqs = list(/obj/item/tank/internals/oxygen = 2, /obj/item/extinguisher = 1, /obj/item/pipe = 3, /obj/item/stack/cable_coil = MAXCOIL)
	category = CAT_MISC
	tools = list(TOOL_WRENCH, TOOL_WELDER, TOOL_WIRECUTTER)

/datum/crafting_recipe/autoinjector
	name = "Selfmade Autoinjector"
	result = /obj/item/reagent_containers/hypospray/autoinjector/selfmade
	time = 5
	reqs = list(/obj/item/reagent_containers/syringe = 1,
				/obj/item/stack/sheet/plastic = 1,
				/obj/item/stack/sheet/metal = 1)
	category = CAT_MISC

/datum/crafting_recipe/drill
	name = "Thermal Drill"
	result = /obj/item/thermal_drill
	time = 60
	reqs = list(/obj/item/stack/cable_coil = 5,
		        /obj/item/mecha_parts/mecha_equipment/drill = 1,
		        /obj/item/stock_parts/cell = 1,
		        /obj/item/stack/rods = 2,
		        /obj/item/assembly/timer = 1)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_MISC

/datum/crafting_recipe/drill_alt
	name = "Thermal Drill(Alternative)"
	result = /obj/item/thermal_drill
	time = 60
	reqs = list(/obj/item/stack/cable_coil = 5,
		        /obj/item/surgicaldrill = 1,
		        /obj/item/stock_parts/cell = 1,
		        /obj/item/stack/rods = 2,
		        /obj/item/assembly/timer = 1)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_MISC

/datum/crafting_recipe/d_drill
	name = "Diamond Tipped Thermal Drill"
	result = /obj/item/thermal_drill/diamond_drill
	time = 60
	reqs = list(/obj/item/stack/cable_coil = 5,
		        /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill = 1,
		        /obj/item/stock_parts/cell = 1,
		        /obj/item/stack/rods = 2,
		        /obj/item/assembly/prox_sensor = 1) // Not a timer because the system sees a diamond drill as a drill too, letting you make both otherwise.
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_MISC

/datum/crafting_recipe/faketoolbox
	name = "Black and Red toolbox"
	result = /obj/item/storage/toolbox/fakesyndi
	time = 40
	reqs = list(/datum/reagent/paint/red = 10,
				/datum/reagent/paint/black = 30,
				/obj/item/storage/toolbox = 1) //Paint in reagents so it doesnt take the container up, yet still take it from the beaker
	blacklist = list(/obj/item/storage/toolbox/fakesyndi)
	pathtools = list(/obj/item/reagent_containers/glass/rag = 1) //need something to paint with it
	category = CAT_MISC

/datum/crafting_recipe/snowman
	name = "Snowman"
	result = /obj/structure/snowman/built
	reqs = list(/obj/item/snowball = 10,
				/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
				/obj/item/grown/log = 2)
	time = 50
	category = CAT_MISC
	always_availible = FALSE

/datum/crafting_recipe/paper_craft
	name = "Paper Heart"
	time = 10
	result = /obj/item/decorations/sticky_decorations/flammable/heart
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 1)
	tools = list(TOOL_WIRECUTTER) //cutters act as makeshift scissors. I doubt the barber wants to have their scissors stolen when somone wants to decorate
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_DECORATION

/datum/crafting_recipe/paper_craft/single_eye
	name = "Paper Eye"
	result = /obj/item/decorations/sticky_decorations/flammable/singleeye
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen, /obj/item/toy/crayon/blue)
	category = CAT_DECORATIONS
	subcategory = CAT_DECORATION

/datum/crafting_recipe/paper_craft/googlyeyes
	name = "Paper Googly Eye"
	result = /obj/item/decorations/sticky_decorations/flammable/googlyeyes
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)
	category = CAT_DECORATIONS
	subcategory = CAT_DECORATION

/datum/crafting_recipe/paper_craft/clock
	name = "Paper Clock"
	result = /obj/item/decorations/sticky_decorations/flammable/paperclock
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)
	category = CAT_DECORATIONS
	subcategory = CAT_DECORATION

/datum/crafting_recipe/paper_craft/jack_o_lantern
	name = "Paper Jack o'Lantern"
	result = /obj/item/decorations/sticky_decorations/flammable/jack_o_lantern
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
					/obj/item/toy/crayon/orange,
					/obj/item/toy/crayon/green)//pen ink is black
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/ghost
	name = "Paper Ghost"
	result = /obj/item/decorations/sticky_decorations/flammable/ghost
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)//it's white paper why need a white crayon?
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/spider
	name = "Paper Spider"
	result = /obj/item/decorations/sticky_decorations/flammable/spider
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
					/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/spiderweb
	name = "Paper Spiderweb"
	result = /obj/item/decorations/sticky_decorations/flammable/spiderweb
	tools = list(TOOL_WIRECUTTER)
	pathtools = list()
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/skull
	name = "Paper Skull"
	result = /obj/item/decorations/sticky_decorations/flammable/skull
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/skeleton
	name = "Paper Skeleton"
	result = /obj/item/decorations/sticky_decorations/flammable/skeleton
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/cauldron
	name = "Paper Cauldron"
	result = /obj/item/decorations/sticky_decorations/flammable/cauldron
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/snowman
	name = "Paper Snowman"
	result = /obj/item/decorations/sticky_decorations/flammable/snowman
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
					/obj/item/toy/crayon/orange)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/christmas_stocking
	name = "Paper Christmas Stocking"
	result = /obj/item/decorations/sticky_decorations/flammable/christmas_stocking
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/christmas_tree
	name = "Paper Christmas Tree"
	result = /obj/item/decorations/sticky_decorations/flammable/christmas_tree
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red,
					/obj/item/toy/crayon/yellow,
					/obj/item/toy/crayon/blue,
					/obj/item/toy/crayon/green)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/snowflake
	name = "Paper Snowflake"
	result = /obj/item/decorations/sticky_decorations/flammable/snowflake
	tools = list(TOOL_WIRECUTTER)
	pathtools = list()
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/candy_cane
	name = "Paper Candy Cane"
	result = /obj/item/decorations/sticky_decorations/flammable/candy_cane
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/mistletoe
	name = "Paper Mistletoe"
	result = /obj/item/decorations/sticky_decorations/flammable/mistletoe
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red,
					/obj/item/toy/crayon/green)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/holly
	name = "Paper Holly"
	result = /obj/item/decorations/sticky_decorations/flammable/holly
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red,
					/obj/item/toy/crayon/green)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_white
	name = "Paper Tinsel White"
	time = 10
	result = /obj/item/decorations/sticky_decorations/flammable/tinsel
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list()
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_red
	name = "Red Paper Tinsel"
	time = 10
	result = /obj/item/decorations/sticky_decorations/flammable/tinsel/red
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_blue
	name = "Blue Paper Tinsel"
	time = 10
	result = /obj/item/decorations/sticky_decorations/flammable/tinsel/blue
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/blue)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_yellow
	name = "Yellow Paper Tinsel"
	time = 10
	result = /obj/item/decorations/sticky_decorations/flammable/tinsel/yellow
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/yellow)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_purple
	name = "Purple Paper Tinsel"
	time = 10
	result = /obj/item/decorations/sticky_decorations/flammable/tinsel/purple
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/purple)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_green
	name = "Green Paper Tinsel"
	time = 10
	result = /obj/item/decorations/sticky_decorations/flammable/tinsel/green
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/green)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_orange
	name = "Orange Paper Tinsel"
	time = 10
	result = /obj/item/decorations/sticky_decorations/flammable/tinsel/orange
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/orange)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_black
	name = "Black Paper Tinsel"
	time = 10
	result = /obj/item/decorations/sticky_decorations/flammable/tinsel/black
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/tinsel_halloween
	name = "Halloween style Paper Tinsel"
	time = 10
	result = /obj/item/decorations/sticky_decorations/flammable/tinsel/halloween
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
					/obj/item/toy/crayon/orange)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/arrowed_heart
	name = "Paper Arrowed Heart"
	result = /obj/item/decorations/sticky_decorations/flammable/arrowed_heart
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/heart_chain
	name = "Paper Heart Chain"
	result = /obj/item/decorations/sticky_decorations/flammable/heart_chain
	reqs = list(/obj/item/paper = 1,
				/obj/item/stack/tape_roll = 2,
				/obj/item/stack/cable_coil = 2)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/four_leaf_clover
	name = "Paper Four Leaf Clover"
	result = /obj/item/decorations/sticky_decorations/flammable/four_leaf_clover
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/green)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/pot_of_gold
	name = "Paper Pot of Gold"
	result = /obj/item/decorations/sticky_decorations/flammable/pot_of_gold
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
				/obj/item/toy/crayon/red,
				/obj/item/toy/crayon/yellow,
				/obj/item/toy/crayon/orange,
				/obj/item/toy/crayon/green,
				/obj/item/toy/crayon/blue,
				/obj/item/toy/crayon/purple)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/leprechaun_hat
	name = "Paper Leprechaun Hat"
	time = 10
	result = /obj/item/decorations/sticky_decorations/flammable/leprechaun_hat
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
				/obj/item/toy/crayon/yellow,
				/obj/item/toy/crayon/green)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/easter_bunny
	name = "Paper Easter Bunny"
	result = /obj/item/decorations/sticky_decorations/flammable/easter_bunny
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/pen,
				/obj/item/toy/crayon/blue,
				/obj/item/toy/crayon/purple)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/easter_egg_blue
	name = "Blue Paper Easter Egg"
	result = /obj/item/decorations/sticky_decorations/flammable/easter_egg
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/blue)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/easter_egg_yellow
	name = "Yellow Paper Easter Egg"
	result = /obj/item/decorations/sticky_decorations/flammable/easter_egg/yellow
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/yellow)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/easter_egg_red
	name = "Red Paper Easter Egg"
	result = /obj/item/decorations/sticky_decorations/flammable/easter_egg/red
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/easter_egg_purple
	name = "Purple Paper Easter Egg"
	result = /obj/item/decorations/sticky_decorations/flammable/easter_egg/purple
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/purple)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/paper_craft/easter_egg_orange
	name = "Orange Paper Easter Egg"
	result = /obj/item/decorations/sticky_decorations/flammable/easter_egg/orange
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/toy/crayon/orange)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/metal_angel_statue
	name = "Metal angel statue"
	time = 50
	result = /obj/structure/decorative_structures/metal/statue/metal_angel
	reqs = list(/obj/item/stack/sheet/metal = 10,
				/obj/item/stack/sheet/mineral/gold = 6)
	tools = list(TOOL_WELDER)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/golden_disk_statue
	name = "Golden disk statue"
	time = 50
	result = /obj/structure/decorative_structures/metal/statue/golden_disk
	reqs = list(/obj/item/stack/sheet/metal = 10,
				/obj/item/stack/sheet/mineral/plasma = 3,
				/obj/item/stack/sheet/mineral/gold = 8)
	tools = list(TOOL_WELDER)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/sun_statue
	name = "Sun statue"
	time = 40
	result = /obj/structure/decorative_structures/metal/statue/sun
	reqs = list(/obj/item/stack/sheet/metal = 6,
				/obj/item/stack/sheet/mineral/gold = 4)
	tools = list(TOOL_WELDER)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/moon_statue
	name = "Moon statue"
	time = 50
	result = /obj/structure/decorative_structures/metal/statue/moon
	reqs = list(/obj/item/stack/sheet/metal = 6,
				/obj/item/stack/sheet/mineral/silver = 6,
				/obj/item/stack/sheet/mineral/gold = 4)
	tools = list(TOOL_WELDER)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/tesla_statue
	name = "Tesla statue"
	time = 40
	result = /obj/structure/decorative_structures/metal/statue/tesla
	reqs = list(/obj/item/stack/sheet/metal = 4,
				/obj/item/stack/sheet/glass = 8)
	tools = list(TOOL_WELDER)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/tesla_monument
	name = "Tesla monument"
	time = 50
	result = /obj/structure/decorative_structures/metal/statue/tesla_monument
	reqs = list(/obj/item/stack/sheet/metal = 8,
				/obj/item/stock_parts/cell = 3,
				/obj/item/stack/cable_coil = 4)
	tools = list(TOOL_WELDER)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/grandfather_clock
	name = "Grandfather clock"
	time = 50
	result = /obj/structure/decorative_structures/flammable/grandfather_clock
	reqs = list(/obj/item/stack/sheet/wood = 5,
				/obj/item/stack/sheet/mineral/gold = 1,
				/obj/item/stack/sheet/glass = 2)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/lava_land_display
	name = "Lava land display"
	time = 50
	result = /obj/structure/decorative_structures/flammable/lava_land_display
	reqs = list(/obj/item/paper = 4,
				/obj/item/stack/sheet/wood = 4,
				/obj/item/stack/rods = 4,
				/obj/item/stock_parts/cell = 1,
				/obj/item/stack/cable_coil = 4)//thing is a wireframe construct with an electro magnetic hover field
	tools = list(TOOL_WIRECUTTER,
				TOOL_WELDER)
	pathtools = list(/obj/item/pen,
				/obj/item/toy/crayon/red)
	category = CAT_DECORATIONS
	subcategory = CAT_LARGE_DECORATIONS

/datum/crafting_recipe/lockermech
	name = "Locker Mech"
	result = /obj/mecha/makeshift
	reqs = list(/obj/item/stack/cable_coil = 20,
				/obj/item/stack/sheet/metal = 10,
				/obj/item/storage/toolbox = 2, // For feet
				/obj/item/tank/internals/oxygen = 1, // For air
				/obj/item/airlock_electronics = 1, //You are stealing the motors from airlocks
				/obj/item/extinguisher = 1, //For bastard pnumatics
				/obj/item/c_tube = 5, //to make it airtight
				/obj/item/flashlight = 1, //For the mech light
				/obj/item/stack/tape_roll = 25, //¯\_(ツ)_/¯
				/obj/item/stock_parts/cell/high = 1,
				/obj/item/stack/rods = 4) //to mount the equipment
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	time = 200
	category = CAT_ROBOT

/datum/crafting_recipe/lockermechdrill
	name = "Makeshift exosuit drill"
	result = /obj/item/mecha_parts/mecha_equipment/drill/makeshift
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/stack/sheet/metal = 2,
				/obj/item/surgicaldrill = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 50
	category = CAT_ROBOT

/datum/crafting_recipe/lockermechclamp
	name = "Makeshift exosuit clamp"
	result = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/stack/sheet/metal = 2,
				/obj/item/wirecutters = 1) //Don't ask, its just for the grabby grabby thing
	tools = list(TOOL_SCREWDRIVER)
	time = 50
	category = CAT_ROBOT

/datum/crafting_recipe/syndielockerpaint
	name = "Syndie Locker Mech Paintkit"
	result = /obj/item/paintkit/lockermech_syndie
	time = 35
	reqs = list(/obj/item/stack/sheet/cardboard = 5,
				/obj/item/toy/crayon/spraycan = 1)
	category = CAT_MISC

/datum/crafting_recipe/piratelockerpaint
	name = "Pirate Locker Mech Paintkit"
	result = /obj/item/paintkit/lockermech_pirate
	time = 35
	reqs = list(/obj/item/stack/sheet/cardboard = 5,
				/obj/item/toy/crayon/spraycan = 1)
	category = CAT_MISC

/datum/crafting_recipe/ntlockerpaint
	name = "NT Special Mech Paintkit"
	result = /obj/item/paintkit/lockermech_nt
	time = 35
	reqs = list(/obj/item/stack/sheet/cardboard = 5,
				/obj/item/toy/crayon/spraycan = 1)
	category = CAT_MISC

/datum/crafting_recipe/stacklifter
	name = "The weight stacklifter"
	result = /obj/structure/weightmachine/stacklifter
	time = 100
	reqs = list(/obj/item/restraints/handcuffs/cable  = 4,
				/obj/item/stack/sheet/metal = 30,
				/obj/item/stack/sheet/plasteel = 10,
				/obj/item/stack/rods = 15)
	tools = list(TOOL_WELDER, TOOL_WIRECUTTER)
	category = CAT_MISC

/datum/crafting_recipe/weightlifter
	name = "The weightlifter"
	result = /obj/structure/weightmachine/weightlifter
	time = 100
	reqs = list(/obj/item/stack/sheet/plasteel = 10,
				/obj/item/stack/sheet/metal = 35,
				/obj/item/stack/rods = 20,
				/obj/item/stack/sheet/mineral/silver = 5)
	tools = list(TOOL_WELDER, TOOL_WRENCH)
	category = CAT_MISC

/datum/crafting_recipe/makeshift_splint
	name = "Makeshift splint"
	result = /obj/item/stack/medical/splint/makeshift
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/wood = 2,
				/obj/item/stack/sheet/cloth = 3)
	category = CAT_MISC

/datum/crafting_recipe/brig_cleaner
	name = "Brig cleaner"
	result = /obj/item/reagent_containers/spray/cleaner/brig/empty
	reqs = list(/obj/item/reagent_containers/spray = 1)
	blacklist = list(/obj/item/reagent_containers/spray/cleaner/brig)
	pathtools = list(/obj/item/toy/crayon/red = 1)
	time = 1.5 SECONDS
	category = CAT_MISC

/datum/crafting_recipe/chemical_cleaner
	name = "Chemical cleaner"
	result = /obj/item/reagent_containers/spray/cleaner/chemical/empty
	reqs = list(/obj/item/reagent_containers/spray = 1)
	blacklist = list(/obj/item/reagent_containers/spray/cleaner/chemical)
	pathtools = list(/obj/item/toy/crayon/orange = 1)
	time = 1.5 SECONDS
	category = CAT_MISC

/datum/crafting_recipe/janitor_cleaner
	name = "Janitor cleaner"
	result = /obj/item/reagent_containers/spray/cleaner/janitor/empty
	reqs = list(/obj/item/reagent_containers/spray = 1)
	blacklist = list(/obj/item/reagent_containers/spray/cleaner/janitor)
	pathtools = list(/obj/item/toy/crayon/purple = 1)
	time = 1.5 SECONDS
	category = CAT_MISC

/datum/crafting_recipe/medical_cleaner
	name = "Medical cleaner"
	result = /obj/item/reagent_containers/spray/cleaner/medical/empty
	reqs = list(/obj/item/reagent_containers/spray = 1)
	blacklist = list(/obj/item/reagent_containers/spray/cleaner/medical)
	pathtools = list(/obj/item/toy/crayon/white = 1)
	time = 1.5 SECONDS
	category = CAT_MISC

/datum/crafting_recipe/pathcloak
	name = "Pathfinder Cloak"
	result = /obj/item/clothing/suit/hooded/pathfinder
	time = 5 SECONDS
	reqs = list(/obj/item/clothing/suit/hooded/goliath = 1,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2, //2 plates for the cloak plus 2 here plus 3 for plating the armor = 7 total
				/obj/item/stack/sheet/animalhide/weaver_chitin = 10,
				/obj/item/stack/sheet/bone = 8,
				/obj/item/stack/sheet/sinew = 10)
	category = CAT_PRIMAL

/datum/crafting_recipe/pathtreads
	name = "Pathfinder Treads"
	result = /obj/item/clothing/shoes/pathtreads
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/weaver_chitin = 2)
	category = CAT_PRIMAL

/datum/crafting_recipe/makeshift_speedloader
	name = "Makeshift Speedloader"
	result = /obj/item/ammo_box/speedloader/improvised
	time = 5 SECONDS
	reqs = list(/obj/item/c_tube = 4,
				/obj/item/stack/packageWrap = 10,
				/obj/item/stack/tape_roll = 4)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/crack_pipe
	name = "Crack pipe"
	result = /obj/item/clothing/mask/cigarette/pipe/crack_pipe
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/glass = 3)
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	category = CAT_MISC

/datum/crafting_recipe/throwing_croissant
	name = "Throwing croissant"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/croissant = 1,
		/obj/item/stack/rods = 1
	)
	result = list(/obj/item/reagent_containers/food/snacks/croissant/throwing)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	always_availible = FALSE

/datum/crafting_recipe/strawnest
	name = "Straw nest"
	result = /obj/structure/bed/strawnest
	time = 10 SECONDS
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/wheat = 10)
	category = CAT_PRIMAL
