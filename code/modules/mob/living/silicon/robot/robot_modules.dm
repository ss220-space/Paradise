/obj/item/robot_module
	name = "Placeholder name"
	var/name_disguise //used by examine
	var/has_transform_animation = FALSE
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	w_class = 100
	item_state = "electronic"
	flags = CONDUCT

	var/list/modules = list()
	var/obj/item/emag = null
	var/list/subsystems = list()
	var/list/module_actions = list()

	var/module_type = "NoMod" // For icon usage

	var/list/storages = list()
	var/channels = list()
	var/list/custom_removals = list()

	///List of skins the borg can be reskinned to, optional
	var/list/borg_skins
	//If decides not to choose
	var/default_skin

/obj/item/robot_module/emp_act(severity)
	if(modules)
		for(var/obj/O in modules)
			O.emp_act(severity)

	if(emag)
		emag.emp_act(severity)

	..()


/obj/item/robot_module/Initialize(mapload)
	. = ..()
	add_default_robot_items()
	emag = new /obj/item/toy/sword(src)
	emag.name = "Placeholder Emag Item"

/obj/item/robot_module/Destroy()
	QDEL_LIST(modules)
	QDEL_NULL(emag)
	return ..()

// By default, all robots will get the items in this proc, unless you override it for your specific module. See: ../robot_module/drone
/obj/item/robot_module/proc/add_default_robot_items()
	modules += new /obj/item/flash/cyborg(src)

/obj/item/robot_module/proc/on_apply(mob/living/silicon/robot/robot)
	return TRUE

/obj/item/robot_module/proc/set_appearance(mob/living/silicon/robot/robot)
	return TRUE

/obj/item/robot_module/proc/fix_modules()
	for(var/obj/item/I in modules)
		ADD_TRAIT(I, TRAIT_NODROP, CYBORG_ITEM_TRAIT)
		I.mouse_opacity = MOUSE_OPACITY_OPAQUE

	if(emag)
		ADD_TRAIT(emag, TRAIT_NODROP, CYBORG_ITEM_TRAIT)
		emag.mouse_opacity = MOUSE_OPACITY_OPAQUE

/obj/item/robot_module/proc/handle_storages()
	for(var/obj/item/stack/stack in modules)
		if(istype(stack, /obj/item/stack/sheet/rglass))
			var/obj/item/stack/sheet/rglass/cyborg/rglass = stack
			rglass.glasource = get_or_create_estorage(/datum/robot_energy_storage/glass)
		stack.source = get_or_create_estorage(stack.energy_type)
		stack.is_cyborg = TRUE


/obj/item/robot_module/proc/get_or_create_estorage(var/storage_type)
	for(var/datum/robot_energy_storage/S in storages)
		if(istype(S, storage_type))
			return S

	return new storage_type(src)

/obj/item/robot_module/proc/respawn_consumable(mob/living/silicon/robot/R)
	for(var/datum/robot_energy_storage/st in storages)
		st.energy = min(st.max_energy, st.energy + st.recharge_rate)

/obj/item/robot_module/proc/rebuild()//Rebuilds the list so it's possible to add/remove items from the module
	var/list/temp_list = modules
	modules = list()

	for(var/obj/O in temp_list)
		if(!QDELETED(O)) //so items getting deleted don't stay in module list and haunt you
			modules += O

/obj/item/robot_module/proc/add_languages(mob/living/silicon/robot/R)
	//full set of languages
	R.add_language(LANGUAGE_GALACTIC_COMMON, 1)
	R.add_language(LANGUAGE_SOL_COMMON, 1)
	R.add_language(LANGUAGE_TRADER, 1)
	R.add_language(LANGUAGE_GUTTER, 0)
	R.add_language(LANGUAGE_NEO_RUSSIAN, 0)
	R.add_language(LANGUAGE_UNATHI, 0)
	R.add_language(LANGUAGE_TAJARAN, 0)
	R.add_language(LANGUAGE_VULPKANIN, 0)
	R.add_language(LANGUAGE_SKRELL, 0)
	R.add_language(LANGUAGE_VOX, 0)
	R.add_language(LANGUAGE_DIONA, 0)
	R.add_language(LANGUAGE_TRINARY, 1)
	R.add_language(LANGUAGE_KIDAN, 0)
	R.add_language(LANGUAGE_SLIME, 0)
	R.add_language(LANGUAGE_DRASK, 0)
	R.add_language(LANGUAGE_CLOWN,0)
	R.add_language(LANGUAGE_MOTH, 0)

/obj/item/robot_module/proc/add_subsystems_and_actions(mob/living/silicon/robot/R)
	add_verb(R, subsystems)

	for(var/A in module_actions)
		var/datum/action/act = new A()
		act.Grant(R)
		R.module_actions += act

/obj/item/robot_module/proc/remove_subsystems_and_actions(mob/living/silicon/robot/R)
	remove_verb(R, subsystems)

	for(var/datum/action/A in R.module_actions)
		A.Remove(R)
		qdel(A)

	R.module_actions.Cut()

// Return true in an overridden subtype to prevent normal removal handling
/obj/item/robot_module/proc/handle_custom_removal(component_id, mob/living/user, obj/item/W)
	return FALSE

/obj/item/robot_module/proc/handle_death(mob/living/silicon/robot/R, gibbed)
	return

/obj/item/robot_module/standard
	// if station is fine, assist with constructing station goal room, cleaning, and repairing cables chewed by rats
	// if medical crisis, assist by providing basic healthcare, retrieving corpses, and monitoring crew lifesigns
	// if eng crisis, assist by helping repair hull breaches
	// if sec crisis, assist by opening doors for sec and providing backup zipties on patrols
	name = "Generalist"
	module_type = "Standard"
	subsystems = list(/mob/living/silicon/proc/subsystem_power_monitor, /mob/living/silicon/proc/subsystem_crew_monitor)
	channels = list(ENG_FREQ_NAME = 1, MED_FREQ_NAME = 1, SEC_FREQ_NAME = 1, SRV_FREQ_NAME = 1, SUP_FREQ_NAME = 1)
	default_skin = /datum/robot_skin/basic/std
	borg_skins = list(
		/datum/robot_skin/default/std,
		/datum/robot_skin/basic/std,
		/datum/robot_skin/noble/std,
		/datum/robot_skin/paladin/std,
		/datum/robot_skin/robot_drone/std,
		/datum/robot_skin/protectron/std,
		/datum/robot_skin/coffin/std,
		/datum/robot_skin/burger/std,
		/datum/robot_skin/raptor/std,
		/datum/robot_skin/doll/std,
		/datum/robot_skin/buddy/std,
		/datum/robot_skin/mine/std,
		/datum/robot_skin/eyebot/std,
		/datum/robot_skin/seek/std,
		/datum/robot_skin/noble_h/std,
		/datum/robot_skin/mech/std,
		/datum/robot_skin/heavy/std,
		/datum/robot_skin/android
	)
	has_transform_animation = TRUE

/obj/item/robot_module/standard/Initialize(mapload)
	. = ..()
	modules += new /obj/item/screwdriver/cyborg(src) //added for minor works
	modules += new /obj/item/wirecutters/cyborg(src) //addded to be able cut at least its own placed wires and rods
	modules += new /obj/item/crowbar/cyborg(src)
	modules += new /obj/item/wrench/cyborg(src)
	modules += new /obj/item/weldingtool(src) //added instead of upgraded version
	modules += new /obj/item/melee/baton/telescopic(src) // for minimal possablity to execute sec part of the module and also for tests
	modules += new /obj/item/restraints/handcuffs/cable/zipties(src)
	modules += new /obj/item/flash/cyborg(src)
	modules += new /obj/item/reagent_containers/spray/cleaner/drone(src) // test if will be in active usage and become op to be cutted out later
	modules += new /obj/item/soap/nanotrasen(src)
	modules += new /obj/item/stack/sheet/metal/cyborg(src)
	modules += new /obj/item/stack/sheet/glass/cyborg(src) // regular glass for simplest works on broken window replacement
	modules += new /obj/item/stack/cable_coil/cyborg(src)
	modules += new /obj/item/healthanalyzer(src)
	modules += new /obj/item/reagent_containers/borghypo/basic(src)
	modules += new /obj/item/handheld_defibrillator(src) // test if will be in active usage and become op to be cutted out later, instead of salbutomol
	modules += new /obj/item/extinguisher/mini(src) // for firefighting, and propulsion in space
	modules += new /obj/item/lightreplacer/cyborg(src)
	modules += new /obj/item/roller_holder(src) // for taking the injured to medbay without worsening their injuries or leaving a blood trail the whole way
	modules += new /obj/item/pickaxe/drill/cyborg(src) // instead of the pickaxe the worst tool for mining anywhere but killing someone with it
	modules += new /obj/item/mining_scanner/cyborg(src) // instead of advanced scanner, we have mining module already
	modules += new /obj/item/storage/bag/ore/cyborg(src)
	modules += new /obj/item/stack/rods/cyborg(src)
	modules += new /obj/item/stack/tile/plasteel(src)
	modules += new /obj/item/instrument/piano_synth(src) // added for minimal service part

	emag = new /obj/item/melee/energy/sword/cyborg(src)

	fix_modules()
	handle_storages()

/obj/item/robot_module/standard/add_default_robot_items()
	return

/obj/item/robot_module/standard/respawn_consumable(mob/living/silicon/robot/R)
	var/obj/item/reagent_containers/spray/cleaner/C = locate() in modules
	C.reagents.add_reagent("cleaner", 3)
	..()

/obj/item/robot_module/medical
	name = "Medical"
	module_type = "Medical"
	subsystems = list(/mob/living/silicon/proc/subsystem_crew_monitor)
	channels = list(MED_FREQ_NAME = 1)
	default_skin = /datum/robot_skin/basic/std
	borg_skins = list(
		/datum/robot_skin/default/medical,
		/datum/robot_skin/basic/medical,
		/datum/robot_skin/noble/medical,
		/datum/robot_skin/cricket/medical,
		/datum/robot_skin/tall/meka/medical,
		/datum/robot_skin/tall/fmeka/medical,
		/datum/robot_skin/tall/mmeka/medical,
		/datum/robot_skin/paladin/medical,
		/datum/robot_skin/robot_drone/medical,
		/datum/robot_skin/protectron/medical,
		/datum/robot_skin/burger/medical,
		/datum/robot_skin/raptor/medical,
		/datum/robot_skin/doll/medical,
		/datum/robot_skin/buddy/medical,
		/datum/robot_skin/mine/medical,
		/datum/robot_skin/eyebot/medical,
		/datum/robot_skin/seek/medical,
		/datum/robot_skin/noble_h/medical,
		/datum/robot_skin/mech/medical,
		/datum/robot_skin/heavy/medical,
		/datum/robot_skin/walla,
		/datum/robot_skin/surgeon,
		/datum/robot_skin/chiefbot,
		/datum/robot_skin/droid_medical,
		/datum/robot_skin/basic/needles
	)
	has_transform_animation = TRUE

/obj/item/robot_module/medical/on_apply(mob/living/silicon/robot/robot)
	if(robot.camera && ("Robots" in robot.camera.network))
		LAZYADD(robot.camera.network, "Medical")

	robot.status_flags &= ~CANPUSH
	robot.see_reagents = TRUE

	return TRUE

/obj/item/robot_module/medical/Initialize(mapload)
	. = ..()
	modules += new /obj/item/extinguisher/mini(src)
	modules += new /obj/item/healthanalyzer/advanced(src)
	modules += new /obj/item/robotanalyzer(src)
	modules += new /obj/item/reagent_containers/borghypo(src)
	modules += new /obj/item/handheld_defibrillator(src)
	modules += new /obj/item/twohanded/shockpaddles/borg(src)
	modules += new /obj/item/gripper/medical(src)
	modules += new /obj/item/flash/cyborg(src)
	modules += new /obj/item/scalpel/laser/laser1(src)
	modules += new /obj/item/hemostat(src)
	modules += new /obj/item/retractor(src)
	modules += new /obj/item/circular_saw(src)
	modules += new /obj/item/bonegel(src)
	modules += new /obj/item/bonesetter(src)
	modules += new /obj/item/stack/medical/splint(src)
	modules += new /obj/item/stack/nanopaste/cyborg(src)
	modules += new /obj/item/reagent_containers/glass/beaker/large(src)
	modules += new /obj/item/reagent_containers/dropper(src)
	modules += new /obj/item/reagent_containers/syringe(src)
	modules += new /obj/item/crowbar/cyborg(src)
	modules += new /obj/item/FixOVein(src)
	modules += new /obj/item/surgicaldrill(src)
	modules += new /obj/item/stack/medical/bruise_pack/advanced(src)
	modules += new /obj/item/stack/medical/ointment/advanced(src)
	modules += new /obj/item/stack/medical/suture/advanced(src)
	modules += new /obj/item/reagent_scanner/adv(src)
	modules += new /obj/item/roller_holder(src)
	modules += new /obj/item/rlf(src)

	emag = new /obj/item/reagent_containers/borghypo/emagged(src) // emagged med. cyborg gets a special hypospray.
// can pierce through thick skin and hardsuits.


	fix_modules()
	handle_storages()

// Disable safeties on the borg's defib.
/obj/item/robot_module/medical/emag_act(mob/user)
	. = ..()
	for(var/obj/item/twohanded/shockpaddles/borg/defib in modules)
		defib.emag_act()

// Enable safeties on the borg's defib.
/obj/item/robot_module/medical/unemag()
	for(var/obj/item/twohanded/shockpaddles/borg/defib in modules)
		defib.emag_act()

	return ..()

/obj/item/robot_module/medical/add_default_robot_items()
	return

/obj/item/robot_module/medical/respawn_consumable(mob/living/silicon/robot/R)
	if(emag)
		var/obj/item/reagent_containers/spray/PS = emag
		PS.reagents.add_reagent("sacid", 2)

	..()

/obj/item/robot_module/engineering
	name = "Engineering"
	module_type = "Engineer"
	subsystems = list(/mob/living/silicon/proc/subsystem_power_monitor, /mob/living/silicon/proc/subsystem_blueprints)
	module_actions = list(
		/datum/action/innate/robot_sight/meson,
	)
	channels = list(ENG_FREQ_NAME = 1)
	default_skin = /datum/robot_skin/basic/eng
	borg_skins = list(
		/datum/robot_skin/default/eng,
		/datum/robot_skin/basic/eng,
		/datum/robot_skin/noble/eng,
		/datum/robot_skin/cricket/eng,
		/datum/robot_skin/tall/meka/eng,
		/datum/robot_skin/tall/fmeka/eng,
		/datum/robot_skin/tall/mmeka/eng,
		/datum/robot_skin/paladin/eng,
		/datum/robot_skin/robot_drone/eng,
		/datum/robot_skin/protectron/eng,
		/datum/robot_skin/coffin/eng,
		/datum/robot_skin/burger/eng,
		/datum/robot_skin/raptor/eng,
		/datum/robot_skin/doll/eng,
		/datum/robot_skin/buddy/eng,
		/datum/robot_skin/mine/eng,
		/datum/robot_skin/eyebot/eng,
		/datum/robot_skin/seek/eng,
		/datum/robot_skin/noble_h/eng,
		/datum/robot_skin/mech/eng,
		/datum/robot_skin/heavy/eng,
		/datum/robot_skin/spider/eng,
		/datum/robot_skin/handy_eng,
		/datum/robot_skin/basic/antique,
		/datum/robot_skin/landmate,
		/datum/robot_skin/chiefmate
	)
	has_transform_animation = TRUE

/obj/item/robot_module/engineering/on_apply(mob/living/silicon/robot/robot)
	if(robot.camera && ("Robots" in robot.camera.network))
		LAZYADD(robot.camera.network, "Engineering")

	ADD_TRAIT(robot, TRAIT_NEGATES_GRAVITY, ROBOT_TRAIT)

	return TRUE

/obj/item/robot_module/engineering/Initialize(mapload)
	. = ..()
	modules += new /obj/item/flash/cyborg(src)
	modules += new /obj/item/rcd/borg(src)
	modules += new /obj/item/rpd(src)
	modules += new /obj/item/extinguisher(src)
	modules += new /obj/item/weldingtool/largetank/cyborg(src)
	modules += new /obj/item/screwdriver/cyborg(src)
	modules += new /obj/item/wrench/cyborg(src)
	modules += new /obj/item/crowbar/cyborg(src)
	modules += new /obj/item/wirecutters/cyborg(src)
	modules += new /obj/item/multitool/cyborg(src)
	modules += new /obj/item/t_scanner(src)
	modules += new /obj/item/analyzer(src)
	modules += new /obj/item/holosign_creator/engineering(src)
	modules += new /obj/item/holosign_creator/atmos(src)
	modules += new /obj/item/gripper(src)
	modules += new /obj/item/matter_decompiler(src)
	modules += new /obj/item/floor_painter(src)
	modules += new /obj/item/stack/sheet/metal/cyborg(src)
	modules += new /obj/item/stack/sheet/glass/cyborg(src)
	modules += new /obj/item/stack/sheet/rglass/cyborg(src)
	modules += new /obj/item/stack/cable_coil/cyborg(src)
	modules += new /obj/item/stack/rods/cyborg(src)
	modules += new /obj/item/stack/tile/plasteel(src)
	emag = new /obj/item/gun/energy/emittercannon(src)

	fix_modules()
	handle_storages()

/obj/item/robot_module/engineering/add_default_robot_items()
	return

/obj/item/robot_module/engineering/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/gripper/G = locate(/obj/item/gripper) in modules
	if(G)
		G.drop_gripped_item(silent = TRUE)

/obj/item/robot_module/security
	name = "Security"
	module_type = "Security"
	subsystems = list(/mob/living/silicon/proc/subsystem_crew_monitor)
	channels = list(SEC_FREQ_NAME = 1)
	default_skin = /datum/robot_skin/basic/sec
	borg_skins = list(
		/datum/robot_skin/default/sec,
		/datum/robot_skin/basic/sec,
		/datum/robot_skin/noble/sec,
		/datum/robot_skin/cricket/sec,
		/datum/robot_skin/tall/meka/sec,
		/datum/robot_skin/tall/fmeka/sec,
		/datum/robot_skin/tall/mmeka/sec,
		/datum/robot_skin/paladin/sec,
		/datum/robot_skin/robot_drone/sec,
		/datum/robot_skin/protectron/sec,
		/datum/robot_skin/coffin/sec,
		/datum/robot_skin/burger/sec,
		/datum/robot_skin/raptor/sec,
		/datum/robot_skin/doll/sec,
		/datum/robot_skin/buddy/sec,
		/datum/robot_skin/mine/sec,
		/datum/robot_skin/eyebot/sec,
		/datum/robot_skin/seek/sec,
		/datum/robot_skin/noble_h/sec,
		/datum/robot_skin/mech/sec,
		/datum/robot_skin/heavy/sec,
		/datum/robot_skin/spider/sec,
		/datum/robot_skin/securitron,
		/datum/robot_skin/redknight,
		/datum/robot_skin/blackknight,
		/datum/robot_skin/bloodhound
	)
	has_transform_animation = TRUE

/obj/item/robot_module/security/on_apply(mob/living/silicon/robot/robot)
	if(!robot.weapons_unlock)
		var/count_secborgs = 0

		for(var/mob/living/silicon/robot/silicon in GLOB.alive_mob_list)
			if(silicon == robot)
				continue

			if(silicon.stat != DEAD && silicon.module && istype(silicon.module, /obj/item/robot_module/security))
				count_secborgs++

		var/max_secborgs = 2
		if(SSsecurity_level.get_current_level_as_number() == SEC_LEVEL_GREEN)
			max_secborgs = 1

		if(count_secborgs >= max_secborgs)
			to_chat(robot, span_warning("There are too many Security cyborgs active. Please choose another module."))
			return FALSE

	robot.status_flags &= ~CANPUSH

	return TRUE

/obj/item/robot_module/security/Initialize(mapload)
	. = ..()
	modules += new /obj/item/restraints/handcuffs/cable/zipties(src)
	modules += new /obj/item/melee/baton/security(src)
	modules += new /obj/item/gun/energy/disabler/cyborg(src)
	modules += new /obj/item/holosign_creator/security(src)
	modules += new /obj/item/clothing/mask/gas/sechailer/cyborg(src)
	modules += new /obj/item/extinguisher/mini(src)
	modules += new /obj/item/crowbar/cyborg(src)
	emag = new /obj/item/gun/energy/laser/cyborg(src)

	fix_modules()


/obj/item/robot_module/janitor
	name = "Janitor"
	module_type = "Janitor"
	channels = list(SRV_FREQ_NAME = 1)
	default_skin = /datum/robot_skin/basic/jan
	borg_skins = list(
		/datum/robot_skin/default/jan,
		/datum/robot_skin/basic/jan,
		/datum/robot_skin/noble/jan,
		/datum/robot_skin/cricket/jan,
		/datum/robot_skin/tall/meka/jan,
		/datum/robot_skin/tall/fmeka/jan,
		/datum/robot_skin/tall/mmeka/jan,
		/datum/robot_skin/paladin/jan,
		/datum/robot_skin/robot_drone/jan,
		/datum/robot_skin/protectron/jan,
		/datum/robot_skin/burger/jan,
		/datum/robot_skin/raptor/jan,
		/datum/robot_skin/doll/jan,
		/datum/robot_skin/buddy/jan,
		/datum/robot_skin/mine/jan,
		/datum/robot_skin/eyebot/jan,
		/datum/robot_skin/seek/jan,
		/datum/robot_skin/noble_h/jan,
		/datum/robot_skin/mech/jan,
		/datum/robot_skin/heavy/jan,
		/datum/robot_skin/basic/mopbot,
		/datum/robot_skin/mopgearrex
	)
	has_transform_animation = TRUE

/obj/item/robot_module/janitor/Initialize(mapload)
	. = ..()
	modules += new /obj/item/soap/nanotrasen(src)
	modules += new /obj/item/storage/bag/trash/cyborg(src)
	modules += new /obj/item/mop/advanced/cyborg(src)
	modules += new /obj/item/lightreplacer/cyborg(src)
	modules += new /obj/item/holosign_creator/janitor(src)
	modules += new /obj/item/extinguisher/mini(src)
	modules += new /obj/item/reagent_containers/spray/pestspray(src) //kill all kidans!
	modules += new /obj/item/crowbar/cyborg(src)
	emag = new /obj/item/reagent_containers/spray(src)

	emag.reagents.add_reagent("lube", 250)
	emag.name = "Lube spray"

	fix_modules()

/obj/item/robot_module/butler
	name = "Service"
	module_type = "Service"
	channels = list(SRV_FREQ_NAME = 1)
	default_skin = /datum/robot_skin/basic/default
	borg_skins = list(
		/datum/robot_skin/default/srv,
		/datum/robot_skin/basic/default,
		/datum/robot_skin/noble/srv,
		/datum/robot_skin/cricket/srv,
		/datum/robot_skin/tall/meka/srv,
		/datum/robot_skin/tall/meka/srv_alt,
		/datum/robot_skin/tall/fmeka/srv,
		/datum/robot_skin/tall/mmeka/srv,
		/datum/robot_skin/paladin/srv,
		/datum/robot_skin/robot_drone/srv,
		/datum/robot_skin/protectron/srv,
		/datum/robot_skin/burger/srv,
		/datum/robot_skin/raptor/srv,
		/datum/robot_skin/doll/srv,
		/datum/robot_skin/buddy/srv,
		/datum/robot_skin/mine/srv,
		/datum/robot_skin/seek/srv,
		/datum/robot_skin/mech/srv,
		/datum/robot_skin/heavy/srv,
		/datum/robot_skin/handy_serv,
		/datum/robot_skin/basic/waitress,
		/datum/robot_skin/basic/bro,
		/datum/robot_skin/toiletbot,
		/datum/robot_skin/maximillion
	)
	has_transform_animation = TRUE

/obj/item/robot_module/butler/on_apply(mob/living/silicon/robot/robot)
	robot.see_reagents = TRUE

	return TRUE

/obj/item/robot_module/butler/Initialize(mapload)
	. = ..()
	modules += new /obj/item/handheld_chem_dispenser/booze(src)
	modules += new /obj/item/handheld_chem_dispenser/soda(src)
	modules += new /obj/item/handheld_chem_dispenser/botanical(src)
	modules += new /obj/item/handheld_chem_dispenser/cooking(src)
	modules += new /obj/item/kitchen/knife(src)
	modules += new /obj/item/reagent_containers/glass/bucket(src)
	modules += new /obj/item/cultivator(src)
	modules += new /obj/item/shovel/spade(src)
	modules += new /obj/item/storage/bag/plants/portaseeder(src)
	modules += new /obj/item/plant_analyzer(src)
	modules += new /obj/item/kitchen/rollingpin(src)
	modules += new /obj/item/bikehorn(src)
	modules += new /obj/item/reagent_containers/spray/pestspray(src)
	modules += new /obj/item/pen(src)
	modules += new /obj/item/razor(src)
	modules += new /obj/item/instrument/piano_synth(src)
	modules += new /obj/item/healthanalyzer/advanced(src)
	modules += new /obj/item/reagent_scanner/adv(src)
	modules += new /obj/item/gripper/service(src)
	modules += new /obj/item/eftpos/cyborg(src)
	modules += new /obj/item/camera/spooky(src)

	modules += new /obj/item/rsf(src)
	modules += new /obj/item/rsf/rff(src)

	modules += new /obj/item/reagent_containers/dropper/cyborg(src)
	modules += new /obj/item/lighter/zippo(src)
	modules += new /obj/item/storage/bag/tray/cyborg(src)
	modules += new /obj/item/reagent_containers/food/drinks/shaker(src)
	modules += new /obj/item/extinguisher(src)
	modules += new /obj/item/crowbar/cyborg(src)
	emag = new /obj/item/reagent_containers/food/drinks/cans/beer(src)

	var/datum/reagents/R = new/datum/reagents(50)
	if(emag.reagents)
		qdel(emag.reagents)
	emag.reagents = R
	R.my_atom = emag
	R.add_reagent("beer2", 50)
	emag.name = "Mickey Finn's Special Brew"

	fix_modules()

/obj/item/robot_module/butler/respawn_consumable(var/mob/living/silicon/robot/R)
	if(emag)
		var/obj/item/reagent_containers/food/drinks/cans/beer/B = emag
		B.reagents.add_reagent("beer2", 2)

	var/obj/item/reagent_containers/spray/pestspray/spray = locate() in modules
	spray?.reagents.add_reagent("pestkiller", 3)

	..()

/obj/item/robot_module/butler/add_languages(var/mob/living/silicon/robot/R)
	//full set of languages
	R.add_language(LANGUAGE_GALACTIC_COMMON, 1)
	R.add_language(LANGUAGE_SOL_COMMON, 1)
	R.add_language(LANGUAGE_TRADER, 1)
	R.add_language(LANGUAGE_GUTTER, 1)
	R.add_language(LANGUAGE_NEO_RUSSIAN, 1)
	R.add_language(LANGUAGE_UNATHI, 1)
	R.add_language(LANGUAGE_TAJARAN, 1)
	R.add_language(LANGUAGE_VULPKANIN, 1)
	R.add_language(LANGUAGE_SKRELL, 1)
	R.add_language(LANGUAGE_VOX, 1)
	R.add_language(LANGUAGE_DIONA, 1)
	R.add_language(LANGUAGE_TRINARY, 1)
	R.add_language(LANGUAGE_KIDAN, 1)
	R.add_language(LANGUAGE_SLIME, 1)
	R.add_language(LANGUAGE_DRASK, 1)
	R.add_language(LANGUAGE_CLOWN,1)
	R.add_language(LANGUAGE_MOTH, 1)

/obj/item/robot_module/butler/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/storage/bag/tray/cyborg/T = locate() in modules

	if(istype(T))
		T.drop_inventory(R)

	var/obj/item/gripper/service/G = locate() in modules
	if(G)
		G.drop_gripped_item(silent = TRUE)


/obj/item/robot_module/miner
	name = "Miner"
	module_type = "Miner"
	module_actions = list(
		/datum/action/innate/robot_sight/meson,
	)
	custom_removals = list("KA modkits")
	channels = list(SUP_FREQ_NAME = 1)
	default_skin = /datum/robot_skin/basic/mnr
	borg_skins = list(
		/datum/robot_skin/default/mnr,
		/datum/robot_skin/basic/mnr,
		/datum/robot_skin/noble/mnr,
		/datum/robot_skin/cricket/mnr,
		/datum/robot_skin/tall/meka/mnr,
		/datum/robot_skin/tall/fmeka/mnr,
		/datum/robot_skin/tall/mmeka/mnr,
		/datum/robot_skin/paladin/mnr,
		/datum/robot_skin/robot_drone/mnr,
		/datum/robot_skin/protectron/mnr,
		/datum/robot_skin/burger/mnr,
		/datum/robot_skin/raptor/mnr,
		/datum/robot_skin/doll/mnr,
		/datum/robot_skin/buddy/mnr,
		/datum/robot_skin/mine/mnr,
		/datum/robot_skin/seek/mnr,
		/datum/robot_skin/noble_h/mnr,
		/datum/robot_skin/mech/mnr,
		/datum/robot_skin/heavy/mnr,
		/datum/robot_skin/spider/mnr,
		/datum/robot_skin/walle,
		/datum/robot_skin/droid_miner,
		/datum/robot_skin/treadhead,
		/datum/robot_skin/lavaland
	)
	has_transform_animation = TRUE

/obj/item/robot_module/miner/on_apply(mob/living/silicon/robot/robot)
	if(robot.camera && ("Robots" in robot.camera.network))
		LAZYADD(robot.camera.network, "Mining Outpost")

	return TRUE

/obj/item/robot_module/miner/Initialize(mapload)
	. = ..()
	modules += new /obj/item/storage/bag/ore/cyborg(src)
	modules += new /obj/item/storage/bag/gem/cyborg(src)
	modules += new /obj/item/pickaxe/drill/cyborg(src)
	modules += new /obj/item/shovel(src)
	modules += new /obj/item/weldingtool/mini(src)
	modules += new /obj/item/extinguisher/mini(src)
	modules += new /obj/item/storage/bag/sheetsnatcher/borg(src)
	modules += new /obj/item/t_scanner/adv_mining_scanner/cyborg(src)
	modules += new /obj/item/gun/energy/kinetic_accelerator/cyborg(src)
	modules += new /obj/item/crowbar/cyborg(src)
	emag = new /obj/item/storage/bag/kaboom/cyborg(src)

	fix_modules()

// Replace their normal drill with a diamond drill.
/obj/item/robot_module/miner/emag_act()
	. = ..()
	for(var/obj/item/pickaxe/drill/cyborg/D in modules)
		// Make sure we don't remove the diamond drill If they already have a diamond drill from the borg upgrade.
		if(!istype(D, /obj/item/pickaxe/drill/cyborg/diamond))
			qdel(D)
			modules -= D // Remove it from this list so it doesn't get added in the rebuild.

	modules += new /obj/item/pickaxe/drill/cyborg/diamond(src)
	rebuild()

// Readd the normal drill
/obj/item/robot_module/miner/unemag()
	for(var/obj/item/pickaxe/drill/cyborg/diamond/drill in modules)
		qdel(drill)
		modules -= drill

	modules += new /obj/item/pickaxe/drill/cyborg(src)
	rebuild()

	return ..()

/obj/item/robot_module/miner/handle_custom_removal(component_id, mob/living/user, obj/item/W)
	if(component_id == "KA modkits")
		for(var/obj/item/gun/energy/kinetic_accelerator/cyborg/D in src)
			W.melee_attack_chain(user, D)

		return TRUE

	return ..()

/obj/item/robot_module/deathsquad
	name = "Deathsquad"
	name_disguise = "NT advanced combat"
	module_type = "Malf"
	module_actions = list(
		/datum/action/innate/robot_sight/thermal,
	)
	default_skin = /datum/robot_skin/deathsquad
	borg_skins = list(/datum/robot_skin/deathsquad)
	has_transform_animation = TRUE

/obj/item/robot_module/deathsquad/on_apply(mob/living/silicon/robot/robot)
	var/mob/living/silicon/robot/deathsquad/death = new(get_turf(robot))
	robot.mind?.transfer_to(death)
	qdel(robot)

	return TRUE

/obj/item/robot_module/deathsquad/Initialize(mapload)
	. = ..()
	modules += new /obj/item/melee/energy/sword/cyborg(src)
	modules += new /obj/item/gun/energy/pulse/cyborg(src)
	modules += new /obj/item/crowbar(src)
	modules += new /obj/item/gripper/nuclear(src)
	modules += new /obj/item/pinpointer(src)
	emag = new /obj/item/gun/energy/pulse/destroyer/annihilator(src)

	fix_modules()

/obj/item/robot_module/syndicate
	name = "Syndicate Bloodhound"
	module_type = "Malf" // cuz it looks cool
	default_skin = /datum/robot_skin/syndie_bloodhound
	borg_skins = list(
		/datum/robot_skin/syndie_bloodhound,
		/datum/robot_skin/tall/meka/syndi,
		/datum/robot_skin/tall/fmeka/syndi,
		/datum/robot_skin/tall/mmeka/syndi,
		/datum/robot_skin/heavy/syndi,
		/datum/robot_skin/spider/syndi,
	)
	has_transform_animation = TRUE

/obj/item/robot_module/syndicate/on_apply(mob/living/silicon/robot/robot)
	robot.spawn_syndicate_borgs(robot, "Bloodhound", get_turf(robot))
	qdel(robot)

	return TRUE

/obj/item/robot_module/syndicate/Initialize(mapload)
	. = ..()
	modules += new /obj/item/melee/energy/sword/cyborg(src)
	modules += new /obj/item/gun/energy/printer(src)
	modules += new /obj/item/gun/projectile/revolver/grenadelauncher/multi/cyborg(src)
	modules += new /obj/item/card/emag(src)
	modules += new /obj/item/extinguisher/mini(src)
	modules += new /obj/item/crowbar/cyborg(src)
	modules += new /obj/item/pinpointer/operative(src)
	modules += new /obj/item/pinpointer/nukeop(src)
	modules += new /obj/item/gripper/nuclear(src)
	emag = null

	fix_modules()

/obj/item/robot_module/syndicate_medical
	name = "Syndicate Medical"
	module_type = "Malf"
	default_skin = /datum/robot_skin/syndie_medi
	borg_skins = list(
		/datum/robot_skin/syndie_medi,
		/datum/robot_skin/tall/meka/syndi,
		/datum/robot_skin/tall/fmeka/syndi,
		/datum/robot_skin/tall/mmeka/syndi,
		/datum/robot_skin/heavy/syndi,
		/datum/robot_skin/spider/syndi,
	)
	has_transform_animation = TRUE

/obj/item/robot_module/syndicate_medical/on_apply(mob/living/silicon/robot/robot)
	robot.spawn_syndicate_borgs(robot, "Medical", get_turf(robot))
	qdel(robot)

	return TRUE

/obj/item/robot_module/syndicate_medical/Initialize(mapload)
	. = ..()
	modules += new /obj/item/extinguisher/mini(src)
	modules += new /obj/item/healthanalyzer/advanced(src)
	modules += new /obj/item/reagent_containers/borghypo/syndicate(src)
	modules += new /obj/item/gun/medbeam(src)
	modules += new /obj/item/handheld_defibrillator(src)
	modules += new /obj/item/twohanded/shockpaddles/borg(src)
	modules += new /obj/item/gripper/medical(src)
	modules += new /obj/item/flash/cyborg(src)
	modules += new /obj/item/scalpel/laser/laser1(src)
	modules += new /obj/item/hemostat(src)
	modules += new /obj/item/retractor(src)
	modules += new /obj/item/melee/energy/sword/cyborg/saw(src) //Energy saw -- primary weapon
	modules += new /obj/item/bonegel(src)
	modules += new /obj/item/bonesetter(src)
	modules += new /obj/item/gripper/nuclear(src)
	modules += new /obj/item/card/emag(src)
	modules += new /obj/item/crowbar/cyborg(src)
	modules += new /obj/item/FixOVein(src)
	modules += new /obj/item/surgicaldrill(src)
	modules += new /obj/item/bodyanalyzer/borg/syndicate(src)
	modules += new /obj/item/stack/medical/splint(src)
	modules += new /obj/item/stack/nanopaste/cyborg(src)
	modules += new /obj/item/stack/medical/bruise_pack/advanced/syndicate(src)
	modules += new /obj/item/stack/medical/ointment/advanced/syndicate(src)
	modules += new /obj/item/reagent_scanner/adv(src)
	modules += new /obj/item/pinpointer/operative(src)
	modules += new /obj/item/pinpointer/nukeop(src)
	modules += new /obj/item/roller_holder(src)
	emag = null

	fix_modules()
	handle_storages()

/obj/item/robot_module/syndicate_medical/add_default_robot_items()
	return

/obj/item/robot_module/syndicate_saboteur
	name = "Syndicate Saboteur"
	name_disguise = "Engineering"
	module_type = "Malf"
	default_skin = /datum/robot_skin/syndi_engi
	borg_skins = list(
		/datum/robot_skin/syndi_engi,
		/datum/robot_skin/tall/meka/syndi,
		/datum/robot_skin/tall/fmeka/syndi,
		/datum/robot_skin/tall/mmeka/syndi,
		/datum/robot_skin/heavy/syndi,
		/datum/robot_skin/spider/syndi,
	)
	has_transform_animation = TRUE

/obj/item/robot_module/syndicate_saboteur/on_apply(mob/living/silicon/robot/robot)
	robot.spawn_syndicate_borgs(robot, "Saboteur", get_turf(robot))
	qdel(robot)

	return TRUE

/obj/item/robot_module/syndicate_saboteur/Initialize(mapload)
	. = ..()
	modules += new /obj/item/screwdriver/cyborg(src)
	modules += new /obj/item/wirecutters/cyborg(src)
	modules += new /obj/item/crowbar/cyborg(src)
	modules += new /obj/item/wrench/cyborg(src)
	modules += new /obj/item/weldingtool/largetank/cyborg(src)
	modules += new /obj/item/multitool/cyborg(src)
	modules += new /obj/item/gripper(src)
	modules += new /obj/item/flash/cyborg(src)
	modules += new /obj/item/rcd/borg/syndicate(src)
	modules += new /obj/item/rpd(src)
	modules += new /obj/item/t_scanner(src)
	modules += new /obj/item/analyzer(src)
	modules += new /obj/item/card/emag(src)
	modules += new /obj/item/melee/energy/sword/cyborg(src)
	modules += new /obj/item/gripper/nuclear(src)
	modules += new /obj/item/extinguisher(src)
	modules += new /obj/item/pinpointer/operative(src)
	modules += new /obj/item/pinpointer/nukeop(src)
	modules += new /obj/item/borg_chameleon(src)
	modules += new /obj/item/stack/sheet/metal/cyborg(src)
	modules += new /obj/item/stack/sheet/glass/cyborg(src)
	modules += new /obj/item/stack/sheet/rglass/cyborg(src)
	modules += new /obj/item/stack/cable_coil/cyborg(src)
	modules += new /obj/item/stack/rods/cyborg(src)
	modules += new /obj/item/stack/tile/plasteel(src)
	modules += new /obj/item/storage/bag/kaboom/cyborg/saboteur(src)
	emag = null

	fix_modules()
	handle_storages()

/obj/item/robot_module/syndicate_saboteur/add_default_robot_items()
	return

/obj/item/robot_module/destroyer
	name = "Destroyer"
	module_type = "Malf"
	module_actions = list(
		/datum/action/innate/robot_sight/thermal,
	)
	channels = list(SEC_FREQ_NAME = 1)
	default_skin = /datum/robot_skin/droidcombat
	borg_skins = list(/datum/robot_skin/droidcombat)
	has_transform_animation = TRUE

/obj/item/robot_module/destroyer/on_apply(mob/living/silicon/robot/robot)
	var/mob/living/silicon/robot/destroyer/destroy = new(get_turf(robot))
	robot.mind?.transfer_to(destroy)
	qdel(robot)

	return TRUE

/obj/item/robot_module/destroyer/Initialize(mapload)
	. = ..()

	modules += new /obj/item/gun/energy/immolator/multi/cyborg(src) // See comments on /robot_module/combat below
	modules += new /obj/item/melee/baton/security(src) // secondary weapon, for things immune to burn, immune to ranged weapons, or for arresting low-grade threats
	modules += new /obj/item/restraints/handcuffs/cable/zipties(src)
	modules += new /obj/item/pickaxe/drill/jackhammer(src) // for breaking walls to execute flanking moves
	modules += new /obj/item/borg/destroyer/mobility(src)
	modules += new /obj/item/crowbar/cyborg(src)
	modules += new /obj/item/gripper/nuclear(src)
	modules += new /obj/item/pinpointer(src)
	emag = new /obj/item/gun/energy/pulse/destroyer/annihilator(src)

	fix_modules()


/obj/item/robot_module/combat
	name = "Combat"
	module_type = "Malf"
	module_actions = list()
	default_skin = /datum/robot_skin/ertgamma
	borg_skins = list(
			/datum/robot_skin/ertgamma,
			/datum/robot_skin/protectron/combat,
			/datum/robot_skin/coffin/combat,
			/datum/robot_skin/burger/combat,
			/datum/robot_skin/raptor/combat,
			/datum/robot_skin/buddy/combat,
			/datum/robot_skin/seek/mnr,
			/datum/robot_skin/mech/mnr,
			/datum/robot_skin/mrgutsy,
		)
	has_transform_animation = TRUE

/obj/item/robot_module/combat/on_apply(mob/living/silicon/robot/robot)
	robot.status_flags &= ~CANPUSH

	return TRUE

/obj/item/robot_module/combat/Initialize(mapload)
	. = ..()
	modules += new /obj/item/gun/energy/immolator/multi/cyborg(src) // primary weapon, strong at close range (ie: against blob/terror/xeno), but consumes a lot of energy per shot.
	// Borg gets 40 shots of this weapon. Gamma Sec ERT gets 10.
	// So, borg has way more burst damage, but also takes way longer to recharge / get back in the fight once depleted. Has to find a borg recharger and sit in it for ages.
	// Organic gamma sec ERT carries alternate weapons, including a box of flashbangs, and can load up on a huge number of guns from science. Borg cannot do either.
	// Overall, gamma borg has higher skill floor but lower skill ceiling.
	modules += new /obj/item/melee/baton/security(src) // secondary weapon, for things immune to burn, immune to ranged weapons, or for arresting low-grade threats
	modules += new /obj/item/restraints/handcuffs/cable/zipties(src)
	modules += new /obj/item/pickaxe/drill/jackhammer(src) // for breaking walls to execute flanking moves
	modules += new /obj/item/extinguisher/mini(src)
	modules += new /obj/item/crowbar/cyborg(src)
	modules += new /obj/item/gripper/nuclear(src)
	modules += new /obj/item/pinpointer(src)
	emag = null

	fix_modules()


/obj/item/robot_module/hunter
	name = "Hunter"
	module_type = "Standard"
	module_actions = list(
		/datum/action/innate/robot_sight/thermal/alien,
	)
	default_skin = /datum/robot_skin/xenoborg
	borg_skins = list(/datum/robot_skin/xenoborg)

/obj/item/robot_module/hunter/on_apply(mob/living/silicon/robot/robot)
	robot.modtype = /obj/item/robot_module/hunter
	return TRUE

/obj/item/robot_module/hunter/add_default_robot_items()
	return

/obj/item/robot_module/hunter/Initialize(mapload)
	. = ..()
	modules += new /obj/item/melee/energy/alien_claws(src)
	modules += new /obj/item/flash/cyborg/alien(src)
	modules += new /obj/item/reagent_containers/spray/alien/smoke(src)
	modules += new /obj/item/reagent_containers/spray/alien/stun(src)
	emag = new /obj/item/reagent_containers/spray/alien/acid(src)
	fix_modules()

/obj/item/robot_module/hunter/respawn_consumable(mob/living/silicon/robot/R)
	if(emag)
		var/obj/item/reagent_containers/spray/alien/acid/acidSpray = emag
		acidSpray.reagents.add_reagent("sacid", 3)
		acidSpray.reagents.add_reagent("facid", 3)
	..()

/obj/item/robot_module/hunter/add_languages(var/mob/living/silicon/robot/R)
	..()
	R.add_language(LANGUAGE_XENOS, 1)

/obj/item/robot_module/drone
	name = "Drone"
	module_type = "Engineer"

/obj/item/robot_module/drone/on_apply(mob/living/silicon/robot/robot)
	var/mob/living/silicon/robot/drone/drone = new(get_turf(robot))
	robot.mind?.transfer_to(drone)
	qdel(robot)

	return TRUE

/obj/item/robot_module/drone/Initialize(mapload)
	. = ..()
	modules += new /obj/item/screwdriver/cyborg(src)
	modules += new /obj/item/wirecutters/cyborg(src)
	modules += new /obj/item/crowbar/cyborg(src)
	modules += new /obj/item/wrench/cyborg(src)
	modules += new /obj/item/weldingtool/largetank/cyborg(src)
	modules += new /obj/item/multitool/cyborg(src)
	modules += new /obj/item/gripper(src)
	modules += new /obj/item/extinguisher(src)
	modules += new /obj/item/reagent_containers/spray/cleaner/drone(src)
	modules += new /obj/item/soap(src)
	modules += new /obj/item/rpd(src)
	modules += new /obj/item/t_scanner(src)
	modules += new /obj/item/analyzer(src)
	modules += new /obj/item/stack/sheet/wood/cyborg(src)
	modules += new /obj/item/stack/tile/wood(src)
	modules += new /obj/item/matter_decompiler(src)
	modules += new /obj/item/lightreplacer/cyborg(src)
	modules += new /obj/item/floor_painter(src)
	modules += new /obj/item/stack/sheet/metal/cyborg(src)
	modules += new /obj/item/stack/sheet/glass/cyborg(src)
	modules += new /obj/item/stack/sheet/rglass/cyborg(src)
	modules += new /obj/item/stack/cable_coil/cyborg(src)
	modules += new /obj/item/stack/rods/cyborg(src)
	modules += new /obj/item/stack/tile/plasteel(src)

	fix_modules()
	handle_storages()

/obj/item/robot_module/drone/add_default_robot_items()
	return

/obj/item/robot_module/drone/respawn_consumable(mob/living/silicon/robot/R)
	var/obj/item/reagent_containers/spray/cleaner/C = locate() in modules
	C.reagents.add_reagent("cleaner", 3)
	..()

/obj/item/robot_module/drone/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/gripper/G = locate(/obj/item/gripper) in modules
	if(G)
		G.drop_gripped_item(silent = TRUE)

/obj/item/robot_module/cogscarab
	name = "Cogscarab"
	module_type = "Cogscarab"

/obj/item/robot_module/cogscarab/on_apply(mob/living/silicon/robot/robot)
	var/mob/living/silicon/robot/cogscarab/cogscarab = new(get_turf(robot))
	robot.mind?.transfer_to(cogscarab)
	qdel(robot)

	return TRUE

/obj/item/robot_module/cogscarab/Initialize(mapload)
	. = ..()
	modules += new /obj/item/screwdriver/brass(src)
	modules += new /obj/item/wirecutters/brass(src)
	modules += new /obj/item/crowbar/brass(src)
	modules += new /obj/item/wrench/brass(src)
	modules += new /obj/item/weldingtool/experimental/brass(src)
	modules += new /obj/item/multitool/brass(src)
	modules += new /obj/item/gripper/cogscarab(src)
	modules += new /obj/item/stack/sheet/brass/cyborg(src)
	modules += new /obj/item/clockwork/brassmaker(src)
	modules += new /obj/item/extinguisher(src)
	emag = null

	fix_modules()
	handle_storages()

/obj/item/robot_module/cogscarab/add_default_robot_items()
	return

/obj/item/robot_module/cogscarab/respawn_consumable(mob/living/silicon/robot/R)
	return

/obj/item/robot_module/cogscarab/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/gripper/cogscarab/G = locate(/obj/item/gripper/cogscarab) in modules
	G?.drop_gripped_item(silent = TRUE)

/obj/item/robot_module/clockwork
	name = "Clockwork"
	module_type = "Cogscarab" //icon_state
	default_skin = /datum/robot_skin/clockwork
	borg_skins = list(/datum/robot_skin/clockwork)

/obj/item/robot_module/clockwork/on_apply(mob/living/silicon/robot/robot)
	robot.status_flags &= ~CANPUSH
	QDEL_NULL(robot.mmi)

	robot.mmi = new /obj/item/mmi/robotic_brain/clockwork(src)

	return TRUE

/obj/item/robot_module/clockwork/set_appearance(mob/living/silicon/robot/robot)
	robot.icon = 'icons/mob/clockwork_mobs.dmi'
	robot.icon_state = "cyborg"

/obj/item/robot_module/clockwork/Initialize(mapload)
	. = ..()
	modules += new /obj/item/clockwork/clockslab(src)
	modules += new /obj/item/clock_borg_spear(src)
	modules += new /obj/item/weldingtool/experimental/brass(src)
	modules += new /obj/item/screwdriver/brass(src)
	modules += new /obj/item/wrench/brass(src)
	modules += new /obj/item/crowbar/brass(src)
	modules += new /obj/item/wirecutters/brass(src)
	modules += new /obj/item/multitool/brass(src)
	modules += new /obj/item/gripper/cogscarab(src)
	modules += new /obj/item/t_scanner(src)
	modules += new /obj/item/stack/sheet/brass/cyborg(src)
	modules += new /obj/item/clockwork/brassmaker(src)
	modules += new /obj/item/extinguisher(src)
	emag = new /obj/item/toy/carpplushie/gold(src)

	fix_modules()
	handle_storages()

/obj/item/robot_module/clockwork/add_default_robot_items()
	return

/obj/item/robot_module/clockwork/respawn_consumable(mob/living/silicon/robot/R)
	return

/obj/item/robot_module/clockwork/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/gripper/cogscarab/G = locate() in modules
	G?.drop_gripped_item(silent = TRUE)

/obj/item/robot_module/ninja
	name = "Ninja"
	name_disguise = "Service"
	module_type = "ninja"
	default_skin = /datum/robot_skin/ninja
	borg_skins = list(
		/datum/robot_skin/ninja,
		/datum/robot_skin/tall/meka/ninja,
		/datum/robot_skin/tall/fmeka/ninja,
		/datum/robot_skin/tall/mmeka/ninja,
		/datum/robot_skin/heavy/ninja,
		/datum/robot_skin/spider/ninja,
		/datum/robot_skin/ninja_sec,
		/datum/robot_skin/ninja_engi,
		/datum/robot_skin/ninja_medical
	)

/obj/item/robot_module/ninja/on_apply(mob/living/silicon/robot/robot)
	var/mob/living/silicon/robot/syndicate/saboteur/ninja/ninja = new(get_turf(robot))
	robot.mind?.transfer_to(ninja)
	qdel(robot)

	return TRUE

/obj/item/robot_module/ninja/Initialize(mapload)
	. = ..()
	modules += new /obj/item/melee/energy_katana/borg(src)
	modules += new /obj/item/gun/energy/shuriken_emitter/borg(src)
	modules += new /obj/item/screwdriver/cyborg(src)
	modules += new /obj/item/wirecutters/cyborg(src)
	modules += new /obj/item/crowbar/cyborg(src)
	modules += new /obj/item/wrench/cyborg(src)
	modules += new /obj/item/weldingtool/largetank/cyborg(src)
	modules += new /obj/item/multitool/cyborg(src)
	modules += new /obj/item/extinguisher(src)
	modules += new /obj/item/healthanalyzer/advanced(src)
	modules += new /obj/item/reagent_containers/borghypo/upgraded/super(src)
	modules += new /obj/item/handheld_defibrillator(src)
	modules += new /obj/item/twohanded/shockpaddles/borg(src)
	modules += new /obj/item/restraints/handcuffs/cable/zipties(src)
	modules += new /obj/item/gripper/universal(src)
	modules += new /obj/item/flash/cyborg(src)
	modules += new /obj/item/scalpel/laser/laser1(src)
	modules += new /obj/item/hemostat(src)
	modules += new /obj/item/retractor(src)
	modules += new /obj/item/circular_saw(src)
	modules += new /obj/item/bonegel(src)
	modules += new /obj/item/bonesetter(src)
	modules += new /obj/item/stack/medical/bruise_pack/advanced(src)
	modules += new /obj/item/stack/medical/ointment/advanced(src)
	modules += new /obj/item/rcd/borg/syndicate(src)
	modules += new /obj/item/rpd(src)
	modules += new /obj/item/t_scanner(src)
	modules += new /obj/item/analyzer(src)
	modules += new /obj/item/FixOVein(src)
	modules += new /obj/item/surgicaldrill(src)
	modules += new /obj/item/bodyanalyzer/borg/syndicate(src)
	modules += new /obj/item/roller_holder(src)
	modules += new /obj/item/stack/sheet/metal/cyborg(src)
	modules += new /obj/item/stack/sheet/glass/cyborg(src)
	modules += new /obj/item/stack/sheet/rglass/cyborg(src)
	modules += new /obj/item/stack/rods/cyborg(src)
	modules += new /obj/item/pinpointer/ninja(src)			// Почему бы и да
	var/obj/item/borg_chameleon/cham_proj = new /obj/item/borg_chameleon(src)
	cham_proj.disguise = "maximillion"
	modules += cham_proj
	emag = null

	fix_modules()
	handle_storages()

/obj/item/robot_module/ninja/add_default_robot_items()
	return

//checks whether this item is a module of the robot it is located in.
/obj/item/proc/is_robot_module()
	if(!istype(loc, /mob/living/silicon/robot))
		return FALSE

	var/mob/living/silicon/robot/robot = loc
	if(!robot.module)
		return FALSE

	return (src in robot.module.modules)


/datum/robot_energy_storage
	var/name = "Generic energy storage"
	var/max_energy
	var/recharge_rate
	var/energy

/datum/robot_energy_storage/New(var/obj/item/robot_module/R = null)
	if(!energy)
		energy = max_energy

	if(R)
		R.storages |= src

	return

/datum/robot_energy_storage/proc/use_charge(amount)
	if (energy >= amount)
		energy -= amount
		if (energy == 0)
			return TRUE

		return TRUE

	else
		return FALSE

/datum/robot_energy_storage/proc/add_charge(amount)
	energy = min(energy + amount, max_energy)

/datum/robot_energy_storage/metal
	name = "Metal Storage"
	max_energy = 400
	recharge_rate = 15

/datum/robot_energy_storage/glass
	name = "Glass Storage"
	max_energy = 50
	recharge_rate = 2

/datum/robot_energy_storage/wire
	max_energy = 50
	recharge_rate = 2
	name = "Wire Storage"

/datum/robot_energy_storage/brass
	max_energy = 30
	recharge_rate = 0
	energy = 1
	name = "Brass Storage"

/datum/robot_energy_storage/medical
	max_energy = 12
	recharge_rate = 1
	name = "Medical Supplies Storage"

/datum/robot_energy_storage/medical/syndicate
	max_energy = 50
	recharge_rate = 4
	name = "Medical Supplies Storage"

/datum/robot_energy_storage/nanopaste
	max_energy = 6
	recharge_rate = 1
	name = "Nanopaste"

/datum/robot_energy_storage/splint
	max_energy = 6
	recharge_rate = 1
	name = "Splints"

/datum/robot_energy_storage/wood
	max_energy = 160
	recharge_rate = 2
	name = "Wood Storage"


/**
 * Called when the robot owner of this module has their power cell replaced.
 *
 * Changes the linked power cell for module items to the newly inserted cell, or to `null`.
 * Arguments:
 * * unlink_cell - If TRUE, set the item's power cell variable to `null` rather than linking it to a new one.
 */
/obj/item/robot_module/proc/update_cells(unlink_cell = FALSE)
	for(var/obj/item/melee/baton/security/baton in modules)
		baton.link_new_cell(unlink_cell)

