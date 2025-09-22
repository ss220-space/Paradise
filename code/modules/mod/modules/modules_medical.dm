//Medical modules for MODsuits

#define HEALTH_SCAN "Health"
#define CHEM_SCAN "Chemical"

///Health Analyzer - Gives the user a ranged health analyzer and their health status in the panel.
/obj/item/mod/module/health_analyzer
	name = "MOD health analyzer module"
	desc = "A module installed into the glove of the suit. This is a high-tech biological scanning suite, \
		allowing the user indepth information on the vitals and injuries of others even at a distance, \
		all with the flick of the wrist. Data is displayed in a convenient package, but it's up to you to do something with it."
	icon_state = "health"
	module_type = MODULE_ACTIVE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/health_analyzer)
	cooldown_time = 0.5 SECONDS
	tgui_id = "health_analyzer"
	//required_slots = list(ITEM_SLOT_GLOVES)
	/// Scanning mode, changes how we scan something.
	var/mode = HEALTH_SCAN

	/// List of all scanning modes.
	var/static/list/modes = list(HEALTH_SCAN, CHEM_SCAN)

/obj/item/mod/module/health_analyzer/add_ui_data()
	. = ..()
	.["health"] = mod.wearer?.health || 0
	.["health_max"] = mod.wearer?.getMaxHealth() || 0
	.["loss_brute"] = mod.wearer?.getBruteLoss() || 0
	.["loss_fire"] = mod.wearer?.getFireLoss() || 0
	.["loss_tox"] = mod.wearer?.getToxLoss() || 0
	.["loss_oxy"] = mod.wearer?.getOxyLoss() || 0

	return .

/obj/item/mod/module/health_analyzer/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!isliving(target) || !is_monkeybasic(mod.wearer))
		return
	switch(mode)
		if(HEALTH_SCAN)
			healthscan(mod.wearer, target)
		if(CHEM_SCAN)
			chemscan(mod.wearer, target)
	drain_power(use_energy_cost)

/obj/item/mod/module/health_analyzer/get_configuration()
	. = ..()
	.["mode"] = add_ui_configuration("Scan Mode", "list", mode, modes)

/obj/item/mod/module/health_analyzer/configure_edit(key, value)
	switch(key)
		if("mode")
			mode = value

#undef HEALTH_SCAN
#undef CHEM_SCAN

///Quick Carry - Lets the user carry bodies quicker.
/obj/item/mod/module/quick_carry
	name = "MOD quick carry module"
	desc = "A suite of advanced servos, redirecting power from the suit's arms to help carry the wounded; \
		or simply for fun. However, Nanotrasen has locked the module's ability to assist in hand-to-hand combat."
	icon_state = "carry"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/quick_carry) //TODO MODSUIT: add /obj/item/mod/module/constructor
	//required_slots = list(ITEM_SLOT_GLOVES)
	var/quick_carry_trait = TRAIT_QUICK_CARRY

/obj/item/mod/module/quick_carry/on_part_activation()
	. = ..()
	ADD_TRAIT(mod.wearer, quick_carry_trait, UNIQUE_TRAIT_SOURCE(src))

/obj/item/mod/module/quick_carry/on_part_deactivation(deleting = FALSE)
	. = ..()
	REMOVE_TRAIT(mod.wearer, quick_carry_trait, UNIQUE_TRAIT_SOURCE(src))

/obj/item/mod/module/quick_carry/advanced
	name = "MOD advanced quick carry module"
	removable = FALSE
	complexity = 0
	quick_carry_trait = TRAIT_QUICKER_CARRY

///Injector - Gives the suit an extendable large-capacity piercing syringe.
/obj/item/mod/module/injector
	name = "MOD injector module"
	desc = "A module installed into the wrist of the suit, this functions as a high-capacity syringe, \
		with a tip fine enough to locate the emergency injection ports on any suit of armor, \
		penetrating it with ease. Even yours."
	icon_state = "injector"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/reagent_containers/syringe/mod
	incompatible_modules = list(/obj/item/mod/module/injector)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/injector/get_ru_names()
	return list(
		NOMINATIVE = "инжекторный модуль для МЭК",
		GENITIVE = "инжекторного модуля для МЭК",
		DATIVE = "инжекторному модулю для МЭК",
		ACCUSATIVE = "инжекторный модуль для МЭК",
		INSTRUMENTAL = "инжекторным модулем для МЭК",
		PREPOSITIONAL = "инжекторном модуле для МЭК",
	)

/obj/item/reagent_containers/syringe/mod
	name = "MOD injector syringe"
	desc = "A high-capacity syringe, with a tip fine enough to locate \
		the emergency injection ports on any suit of armor, penetrating it with ease. Even yours."
	amount_per_transfer_from_this = 30
	possible_transfer_amounts = list(5, 10, 15, 20, 30)
	volume = 30
	penetrates_thick = TRUE

/obj/item/reagent_containers/syringe/mod/get_ru_names()
	return list(
		NOMINATIVE = "шприц-инъектор для МЭК",
		GENITIVE = "шприца-инъектора для МЭК",
		DATIVE = "шприцу-инъектору для МЭК",
		ACCUSATIVE = "шприц-инъектор для МЭК",
		INSTRUMENTAL = "шприцом-инъектором для МЭК",
		PREPOSITIONAL = "шприце-инъекторе для МЭК",
	)

/obj/item/reagent_containers/syringe/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, MODSUIT_TRAIT)

///Defibrillator - Gives the suit an extendable pair of shock paddles.
/obj/item/mod/module/defibrillator
	name = "MOD defibrillator module"
	desc = "A module built into the gauntlets of the suit; commonly known as the 'Healing Hands' by medical professionals. \
		The user places their palms above the patient. Onboard computers in the suit calculate the necessary voltage, \
		and a modded targeting computer determines the best position for the user to push. \
		Twenty five pounds of force are applied to the patient's skin. Shocks travel from the suit's gloves \
		and counter-shock the heart, and the wearer returns to Medical a hero. Don't you even think about using it as a weapon; \
		regulations on manufacture and software locks expressly forbid it."
	icon_state = "defibrillator"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 200 // 1000 charge. Shocking, I know.
	device = /obj/item/mod_defib
	overlay_state_inactive = "module_defibrillator"
	overlay_state_active = "module_defibrillator_active"
	incompatible_modules = list(/obj/item/mod/module/defibrillator)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/defibrillator/get_ru_names()
	return list(
		NOMINATIVE = "модуль-дефибриллятор для МЭК",
		GENITIVE = "модуля-дефибриллятора для МЭК",
		DATIVE = "модулю-дефибриллятору для МЭК",
		ACCUSATIVE = "модуль-дефибриллятор для МЭК",
		INSTRUMENTAL = "модулем-дефибриллятором для МЭК",
		PREPOSITIONAL = "модуле-дефибрилляторе для МЭК",
	)

/obj/item/mod/module/defibrillator/Initialize(mapload)
	. = ..()
	RegisterSignal(device, COMSIG_DEFIB_SHOCK_APPLIED, PROC_REF(on_defib_success))

/obj/item/mod/module/defibrillator/proc/on_defib_success()
	SIGNAL_HANDLER  // COMSIG_DEFIB_SHOCK_APPLIED
	drain_power(use_energy_cost)

/obj/item/mod_defib
	name = "defibrillator gauntlets"
	desc = "A pair of paddles with flat metal surfaces that are used to deliver powerful electric shocks."
	icon = 'icons/obj/defib.dmi'
	icon_state = "defibgauntlets0" //Inhands handled by the module overlays
	force = 0
	w_class = WEIGHT_CLASS_BULKY
	toolspeed = 1
	var/defib_cooldown = 5 SECONDS
	var/safety = TRUE
	/// Whether or not the paddles are on cooldown. Used for tracking icon states.
	var/on_cooldown = FALSE

/obj/item/mod_defib/get_ru_names()
	return list(
		NOMINATIVE = "рукавицы-дефибрилляторы",
		GENITIVE = "рукавиц-дефибрилляторов",
		DATIVE = "рукавицам-дефибрилляторам",
		ACCUSATIVE = "рукавицы-дефибрилляторы",
		INSTRUMENTAL = "рукавицами-дефибрилляторами",
		PREPOSITIONAL = "рукавицах-дефибрилляторах",
	)

/obj/item/mod_defib/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/defib, cooldown = defib_cooldown, speed_multiplier = toolspeed, ignore_hardsuits = !safety, safe_by_default = safety, robotic = TRUE, safe_by_default = safety, emp_proof = TRUE)
	ADD_TRAIT(src, TRAIT_NODROP, MODSUIT_TRAIT)
	RegisterSignal(src, COMSIG_DEFIB_READY, PROC_REF(on_cooldown_expire))
	RegisterSignal(src, COMSIG_DEFIB_SHOCK_APPLIED, PROC_REF(after_shock))

/obj/item/mod_defib/proc/after_shock(obj/item/defib, mob/user)
	SIGNAL_HANDLER  // COMSIG_DEFIB_SHOCK_APPLIED
	on_cooldown = TRUE
	update_icon(UPDATE_ICON_STATE)

/obj/item/mod_defib/proc/on_cooldown_expire(obj/item/defib)
	SIGNAL_HANDLER // COMSIG_DEFIB_READY
	on_cooldown = FALSE
	visible_message(span_notice("[src] beeps: Defibrillation unit ready."))
	playsound(get_turf(src), 'sound/machines/defib_ready.ogg', 50, FALSE)
	update_icon(UPDATE_ICON_STATE)

/obj/item/mod_defib/update_icon_state()
	icon_state = "[initial(icon_state)]"
	if(on_cooldown)
		icon_state = "[initial(icon_state)]_cooldown"

/obj/item/mod/module/defibrillator/combat
	name = "MOD combat defibrillator module"
	desc = "A module built into the gauntlets of the suit; commonly known as the 'Healing Hands' by medical professionals. \
		The user places their palms above the patient. Onboard computers in the suit calculate the necessary voltage, \
		and a modded targeting computer determines the best position for the user to push. \
		Twenty five pounds of force are applied to the patient's skin. Shocks travel from the suit's gloves \
		and counter-shock the heart, and the wearer returns to Medical a hero. \
		Interdyne Pharmaceutics marketed the domestic version of the Healing Hands as foolproof and unusable as a weapon. \
		But when it came time to provide their operatives with usable medical equipment, they didn't hesitate to remove \
		those in-built safeties. Operatives in the field can benefit from what they dub as 'Stun Gloves', able to apply shocks \
		straight to a victims heart to disable them, or maybe even outright stop their heart with enough power."
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 400 // 2000 charge. Since you like causing heart attacks, don't you?
	module_type = MODULE_ACTIVE
	overlay_state_inactive = "module_defibrillator_combat"
	overlay_state_active = "module_defibrillator_combat_active"
	device = /obj/item/mod_defib/syndicate

/obj/item/mod/module/defibrillator/combat/get_ru_names()
	return list(
		NOMINATIVE = "боевой модуль-дефибриллятор для МЭК",
		GENITIVE = "боевого модуля-дефибриллятора для МЭК",
		DATIVE = "боевому модулю-дефибриллятору для МЭК",
		ACCUSATIVE = "боевой модуль-дефибриллятор для МЭК",
		INSTRUMENTAL = "боевым модулем-дефибриллятором для МЭК",
		PREPOSITIONAL = "боевом модуле-дефибрилляторе для МЭК",
	)

/obj/item/mod_defib/syndicate
	name = "combat defibrillator gauntlets"
	icon_state = "syndiegauntlets0"
	safety = FALSE
	toolspeed = 2
	defib_cooldown = 2.5 SECONDS

/obj/item/mod_defib/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "боевые рукавицы-дефибрилляторы",
		GENITIVE = "боевых рукавиц-дефибрилляторов",
		DATIVE = "боевым рукавицам-дефибрилляторам",
		ACCUSATIVE = "боевые рукавицы-дефибрилляторы",
		INSTRUMENTAL = "боевыми рукавицами-дефибрилляторами",
		PREPOSITIONAL = "боевых рукавицах-дефибрилляторах",
	)

///Crew Monitor - Deploys or retracts a built-in handheld crew monitor
/obj/item/mod/module/monitor
	name = "MOD crew monitor module"
	desc = "A module installed into the wrist of the suit, this presents a display of crew sensor data."
	icon_state = "scanner"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/sensor_device/mod
	incompatible_modules = list(/obj/item/mod/module/monitor)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/monitor/get_ru_names()
	return list(
		NOMINATIVE = "модуль монитора наблюдения за экипажем для МЭК",
		GENITIVE = "модуля монитора наблюдения за экипажем для МЭК",
		DATIVE = "модулю монитора наблюдения за экипажем для МЭК",
		ACCUSATIVE = "модуль монитора наблюдения за экипажем для МЭК",
		INSTRUMENTAL = "модулем монитора наблюдения за экипажем для МЭК",
		PREPOSITIONAL = "модуле монитора наблюдения за экипажем для МЭК",
	)

/obj/item/sensor_device/mod
	name = "MOD crew monitor"
	desc = "A miniature machine built into a modsuit that tracks suit sensors across the station."

/obj/item/sensor_device/mod/get_ru_names()
	return list(
		NOMINATIVE = "ручной монитор экипажа для МЭК",
		GENITIVE = "ручного монитора экипажа для МЭК",
		DATIVE = "ручному монитору экипажа для МЭК",
		ACCUSATIVE = "ручной монитор экипажа для МЭК",
		INSTRUMENTAL = "ручным монитором экипажа для МЭК",
		PREPOSITIONAL = "ручном мониторе экипажа для МЭК"
	)


/obj/item/sensor_device/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, MODSUIT_TRAIT)

///Organizer - Lets you shoot organs, immediately replacing them if the target has the organ manipulation surgery.
/obj/item/mod/module/organizer
	name = "MOD organizer module"
	desc = "A device recovered from a crashed Interdyne Pharmaceuticals vessel, \
		this module has been unearthed for better or for worse. \
		It's an arm-mounted device utilizing technology similar to modern rapid part exchange devices, \
		capable of instantly replacing up to 5 organs at once in surgery without the need to remove them first, even from range. \
		It's recommended by the DeForest Medical Corporation to not inform patients it has been used."
	icon_state = "organizer"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/organizer) //TODO modsuit: add /obj/item/mod/module/microwave_beam
	cooldown_time = 0.5 SECONDS
	//required_slots = list(ITEM_SLOT_GLOVES)
	/// How many organs the module can hold.
	var/max_organs = 5
	/// A list of all our organs.
	var/organ_list = list()

/obj/item/mod/module/organizer/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/wearer_human = mod.wearer
	if(is_organ(target))
		if(!wearer_human.Adjacent(target))
			return
		var/atom/movable/organ = target
		if(length(organ_list) >= max_organs)
			balloon_alert(mod.wearer, "too many organs!")
			return
		organ_list += organ
		organ.forceMove(src)
		balloon_alert(mod.wearer, "picked up [organ]")
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		drain_power(use_energy_cost)
		return
	if(!length(organ_list))
		return
	var/atom/movable/fired_organ = pop(organ_list)
	var/obj/projectile/organ/projectile = new /obj/projectile/organ(mod.wearer.loc, fired_organ)
	projectile.original = target
	projectile.firer = mod.wearer
	projectile.preparePixelProjectile(target, get_turf(target), mod.wearer)
	projectile.fire()
	playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
	INVOKE_ASYNC(projectile, TYPE_PROC_REF(/obj/projectile, fire))
	drain_power(use_energy_cost)

/obj/projectile/organ
	name = "organ"
	damage = 0
	hitsound = 'sound/effects/attackblob.ogg'
	hitsound_wall = 'sound/effects/attackblob.ogg'
	/// A reference to the organ we "are".
	var/obj/item/organ/internal/organ

/obj/projectile/organ/Initialize(mapload, obj/item/stored_organ)
	. = ..()
	if(!stored_organ)
		return INITIALIZE_HINT_QDEL
	appearance = stored_organ.appearance
	stored_organ.forceMove(src)
	organ = stored_organ

/obj/projectile/organ/Destroy()
	organ = null
	return ..()

/obj/projectile/organ/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!isliving(target))
		organ.forceMove(drop_location())
		organ = null
		return
	var/mob/living/carbon/human/organ_receiver = target
	var/succeed = FALSE
	if(organ_receiver.surgeries.len)
		for(var/datum/surgery/organ_manipulation/procedure in organ_receiver.surgeries)
			if(procedure.location != organ.parent_organ_zone)
				continue
			if(!ispath(procedure.steps[procedure.step_number], /datum/surgery_step/proxy/manipulate_organs))
				continue
			succeed = TRUE
			break

	if(!succeed)
		organ.forceMove(drop_location())
		organ = null
		return

	var/list/organs_to_boot_out = organ_receiver.get_organ_slot(organ.parent_organ_zone)
	for(var/obj/item/organ/internal/organ_evacced as anything in organs_to_boot_out)
		organ_evacced.remove(target, special = TRUE)
		organ_evacced.forceMove(get_turf(target))

	organ.insert(target)
	organ = null

///Patrient Transport - Generates hardlight bags you can put people in.
/obj/item/mod/module/criminalcapture/patienttransport
	name = "MOD patient transport module"
	desc = "A module built into the forearm of the suit. Countless waves of mostly-lost mining teams being sent to \
		Indecipheries and other hazardous locations have taught the DeForest Medical Company many lessons. \
		Physical bodybags are difficult to store, hard to deploy, and even worse to keep intact in tough scenarios. \
		Enter the hardlight transport bag. Summonable with merely a gesture, weightless, and immunized against \
		any extreme scenario the wearer could think of, this bag is perfectly designed for \
		transport of any body in any environment, any time."
	icon_state = "patient_transport"
	bodybag_type = /obj/structure/closet/body_bag/environmental/hardlight
	capture_time = 1.5 SECONDS
	packup_time = 0.5 SECONDS
