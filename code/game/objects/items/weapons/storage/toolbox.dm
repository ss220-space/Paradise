/obj/item/storage/toolbox
	name = "toolbox"
	desc = "Металлический контейнер, предназначенный для хранения инструментов. Выглядит мощно."
	gender = MALE
	icon = 'icons/obj/storage/boxes.dmi'
	icon_state = "toolbox_red"
	righthand_file = 'icons/mob/inhands/storage_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/storage_lefthand.dmi'
	item_state = "toolbox_red"
	flags = CONDUCT
	force = 10.0
	throwforce = 15.0
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 18
	materials = list(MAT_METAL = 500)
	origin_tech = "combat=1;engineering=1"
	attack_verb = list("огрел", "ударил", "вмазал")
	use_sound = 'sound/items/handling/toolbox_open.ogg'
	hitsound = 'sound/weapons/smash.ogg'
	drop_sound = 'sound/items/handling/drop/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/toolbox_pickup.ogg'
	/// Chance to blurry the vision of attacked human
	var/blurry_chance = 5
	/// How many interactions are we currently performing
	var/current_interactions = 0

/obj/item/storage/toolbox/get_ru_names()
	return list(
		NOMINATIVE = "ящик для инструментов",
		GENITIVE = "ящика для инструментов",
		DATIVE = "ящику для инструментов",
		ACCUSATIVE = "ящик для инструментов",
		INSTRUMENTAL = "ящиком для инструментов",
		PREPOSITIONAL = "ящике для инструментов",
	)

/obj/item/storage/toolbox/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = force, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/obj/item/storage/toolbox/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .
	if(!ishuman(target))
		return .
	if(user.zone_selected != BODY_ZONE_PRECISE_EYES && user.zone_selected != BODY_ZONE_HEAD)
		return .
	if(!prob(blurry_chance))
		return .
	target.AdjustEyeBlurry(8 SECONDS)
	to_chat(target, span_danger("Вас оглушает звон в ушах, а в глазах начинает двоиться."))

/obj/item/storage/toolbox/attack_obj(obj/object, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	for(var/obj/item/tool as anything in contents)
		if(tool?.toolbox_radial_menu_compatibility)
			return ATTACK_CHAIN_PROCEED

/// Check if we can use tools inside toolbox via radial menu
/obj/item/storage/toolbox/proc/check_for_radial_menu_availability(atom/object, mob/living/user, proximity)
	if(user.incapacitated())
		return FALSE

	if(!proximity)
		balloon_alert(user, "слишком далеко!")
		return FALSE

	if(ismob(object))
		return FALSE

	if(user.get_inactive_hand())
		balloon_alert(user, "руки заняты!")
		return FALSE

	return TRUE

/obj/item/storage/toolbox/afterattack(atom/object, mob/living/user, proximity, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(!check_for_radial_menu_availability(object, user, proximity))
		return

	handle_radial_menu_interaction(object, user)

/obj/item/storage/toolbox/proc/handle_radial_menu_interaction(atom/object, mob/living/user)
	if(current_interactions)
		var/obj/item/other_tool = user.get_inactive_hand()
		if(!istype(other_tool))
			return
		INVOKE_ASYNC(src, PROC_REF(use_tool_on), object, user, other_tool)
		return

	var/list/choices = list()
	for(var/obj/item/tool as anything in contents)
		if(tool?.toolbox_radial_menu_compatibility)
			choices[tool.declent_ru(NOMINATIVE)] = image(icon = tool.icon, icon_state = tool.icon_state)

	if(!length(choices))
		return

	playsound(user, 'sound/items/handling/toolbox_open.ogg', 50)

	var/obj/item/picked_item = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user, object), require_near = TRUE, anim_speed = 0.1)
	if(!picked_item)
		return

	if(user.incapacitated())
		return

	if(!user.Adjacent(object))
		balloon_alert(user, "слишком далеко!")
		return

	var/obj/item/selected
	for(var/obj/item/tool as anything in contents)
		if(tool.declent_ru(NOMINATIVE) != picked_item)
			continue
		selected = tool
	playsound(user, 'sound/items/handling/toolbox_rustle.ogg', 50)

	if(!user.put_in_inactive_hand(selected))
		return

	SEND_SIGNAL(selected, COMSIG_TOOLBOX_RADIAL_MENU_TOOL_USAGE, user)

	INVOKE_ASYNC(src, PROC_REF(use_tool_on), object, user, selected)
	return

/**
 * Runs a series of pre-checks before opening the radial menu to the user.
 *
 * Arguments:
 * * user - the mob trying to open the radial menu
 * * object - atom we interact with
 */
/obj/item/storage/toolbox/proc/check_menu(mob/living/user, atom/object)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(object))
		return FALSE
	return TRUE

/obj/item/storage/toolbox/proc/use_tool_on(atom/object, mob/living/user, obj/item/picked_tool)
	current_interactions += 1
	picked_tool.tool_attack_chain(user, object)
	current_interactions -= 1

	if(QDELETED(picked_tool) || picked_tool.loc != user || !user.Adjacent(picked_tool))
		current_interactions = 0
		return

	if(current_interactions)
		return

	SEND_SIGNAL(picked_tool, COMSIG_TOOLBOX_RADIAL_MENU_TOOL_USAGE, user)

	if(!can_be_inserted(picked_tool))
		return
	handle_item_insertion(picked_tool)

/**
 * MARK: Toolbox types
 */

/obj/item/storage/toolbox/emergency
	name = "emergency toolbox"

/obj/item/storage/toolbox/emergency/get_ru_names()
	return list(
		NOMINATIVE = "экстренный ящик для инструментов",
		GENITIVE = "экстренного ящика для инструментов",
		DATIVE = "экстренному ящику для инструментов",
		ACCUSATIVE = "экстренный ящик для инструментов",
		INSTRUMENTAL = "экстренным ящиком для инструментов",
		PREPOSITIONAL = "экстренном ящике для инструментов",
	)

/obj/item/storage/toolbox/emergency/populate_contents()
	new /obj/item/crowbar/red(src)
	new /obj/item/weldingtool/mini(src)
	new /obj/item/extinguisher/mini(src)
	if(prob(50))
		new /obj/item/flashlight(src)
	else
		new /obj/item/flashlight/flare(src)
	new /obj/item/radio(src)

/obj/item/storage/toolbox/emergency/old
	name = "rusty toolbox"
	icon_state = "toolbox_red_rusted"
	item_state = "toolbox_red_rusted"

/obj/item/storage/toolbox/emergency/old/get_ru_names()
	return list(
		NOMINATIVE = "ржавый ящик для инструментов",
		GENITIVE = "ржавого ящика для инструментов",
		DATIVE = "ржавому ящику для инструментов",
		ACCUSATIVE = "ржавый ящик для инструментов",
		INSTRUMENTAL = "ржавым ящиком для инструментов",
		PREPOSITIONAL = "ржавом ящике для инструментов",
	)

/obj/item/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "toolbox_blue"
	item_state = "toolbox_blue"

/obj/item/storage/toolbox/mechanical/get_ru_names()
	return list(
		NOMINATIVE = "ящик для механических инструментов",
		GENITIVE = "ящика для механических инструментов",
		DATIVE = "ящику для механических инструментов",
		ACCUSATIVE = "ящик для механических инструментов",
		INSTRUMENTAL = "ящиком для механических инструментов",
		PREPOSITIONAL = "ящике для механических инструментов",
	)

/obj/item/storage/toolbox/mechanical/populate_contents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/analyzer(src)
	new /obj/item/wirecutters(src)

/obj/item/storage/toolbox/mechanical/greytide

/obj/item/storage/toolbox/mechanical/greytide/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/storage/toolbox/mechanical/old
	name = "rusty toolbox"
	icon_state = "toolbox_blue_rusted"
	item_state = "toolbox_blue_rusted"

/obj/item/storage/toolbox/mechanical/old/get_ru_names()
	return list(
		NOMINATIVE = "ржавый ящик для инструментов",
		GENITIVE = "ржавого ящика для инструментов",
		DATIVE = "ржавому ящику для инструментов",
		ACCUSATIVE = "ржавый ящик для инструментов",
		INSTRUMENTAL = "ржавым ящиком для инструментов",
		PREPOSITIONAL = "ржавом ящике для инструментов",
	)

/obj/item/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "toolbox_yellow"
	item_state = "toolbox_yellow"

/obj/item/storage/toolbox/electrical/get_ru_names()
	return list(
		NOMINATIVE = "ящик для электромонтажных инструментов",
		GENITIVE = "ящика для электромонтажных инструментов",
		DATIVE = "ящику для электромонтажных инструментов",
		ACCUSATIVE = "ящик для электромонтажных инструментов",
		INSTRUMENTAL = "ящиком для электромонтажных инструментов",
		PREPOSITIONAL = "ящике для электромонтажных инструментов",
	)

/obj/item/storage/toolbox/electrical/populate_contents()
	var/pickedcolor = pick(COLOR_RED, COLOR_YELLOW, COLOR_GREEN, COLOR_BLUE, COLOR_PINK, COLOR_ORANGE, COLOR_CYAN, COLOR_WHITE)
	new /obj/item/screwdriver(src)
	new /obj/item/wirecutters(src)
	new /obj/item/t_scanner(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src, MAXCOIL, FALSE, pickedcolor)
	new /obj/item/stack/cable_coil(src, MAXCOIL, FALSE, pickedcolor)
	if(prob(5))
		new /obj/item/clothing/gloves/color/yellow(src)
	else
		new /obj/item/stack/cable_coil(src, MAXCOIL, FALSE, pickedcolor)

/obj/item/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	desc = "Металлический контейнер, предназначенный для хранения инструментов. Выглядит подозрительно."
	icon_state = "toolbox_syndicate"
	item_state = "toolbox_syndie"
	origin_tech = "combat=2;syndicate=1;engineering=2"
	silent = 1
	force = 15
	throwforce = 18
	blurry_chance = 8

/obj/item/storage/toolbox/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "подозрительный ящик для инструментов",
		GENITIVE = "подозрительного ящика для инструментов",
		DATIVE = "подозрительному ящику для инструментов",
		ACCUSATIVE = "подозрительный ящик для инструментов",
		INSTRUMENTAL = "подозрительным ящиком для инструментов",
		PREPOSITIONAL = "подозрительном ящике для инструментов",
	)

/obj/item/storage/toolbox/syndicate/populate_contents()
	new /obj/item/screwdriver(src, "red")
	new /obj/item/wrench(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/wirecutters(src, "red")
	new /obj/item/multitool(src)
	new /obj/item/clothing/gloves/combat(src)

/obj/item/storage/toolbox/syndisuper
	name = "exteremely suspicious looking toolbox"
	desc = "Металлический контейнер, предназначенный для хранения инструментов. Выглядит чрезвычайно подозрительно."
	icon_state = "toolbox_syndicate"
	item_state = "toolbox_syndie"
	origin_tech = "combat=5;syndicate=1;engineering=5"
	silent = 1
	force = 18 //robuster because of rarity
	throwforce = 20
	blurry_chance = 12

/obj/item/storage/toolbox/syndisuper/get_ru_names()
	return list(
		NOMINATIVE = "очень подозрительный ящик для инструментов",
		GENITIVE = "очень подозрительного ящика для инструментов",
		DATIVE = "очень подозрительному ящику для инструментов",
		ACCUSATIVE = "очень подозрительный ящик для инструментов",
		INSTRUMENTAL = "очень подозрительным ящиком для инструментов",
		PREPOSITIONAL = "очень подозрительном ящике для инструментов",
	)

/obj/item/storage/toolbox/syndisuper/populate_contents()
	new /obj/item/screwdriver/power(src)
	new /obj/item/weldingtool/experimental(src)
	new /obj/item/crowbar/power(src)
	new /obj/item/multitool/cyborg(src)
	new /obj/item/stack/cable_coil(src, MAXCOIL)
	new /obj/item/clothing/gloves/combat/swat/syndicate(src)
	new /obj/item/clothing/glasses/sunglasses(src)

/obj/item/storage/toolbox/fakesyndi
	name = "suspicous looking toolbox"
	desc = "Металлический контейнер, предназначенный для хранения инструментов. Выглядит подозрительно. Краска ещё не засохла."
	icon_state = "toolbox_syndicate"
	item_state = "toolbox_syndie"

/obj/item/storage/toolbox/fakesyndi/get_ru_names()
	return list(
		NOMINATIVE = "подозрительный ящик для инструментов",
		GENITIVE = "подозрительного ящика для инструментов",
		DATIVE = "подозрительному ящику для инструментов",
		ACCUSATIVE = "подозрительный ящик для инструментов",
		INSTRUMENTAL = "подозрительным ящиком для инструментов",
		PREPOSITIONAL = "подозрительном ящике для инструментов",
	)

/obj/item/storage/toolbox/drone
	name = "mechanical toolbox"
	icon_state = "toolbox_blue"
	item_state = "toolbox_blue"

/obj/item/storage/toolbox/drone/populate_contents()
	var/pickedcolor = pick(pick(COLOR_RED, COLOR_YELLOW, COLOR_GREEN, COLOR_BLUE, COLOR_PINK, COLOR_ORANGE, COLOR_CYAN, COLOR_WHITE))
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src, MAXCOIL, TRUE, pickedcolor)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)

/obj/item/storage/toolbox/brass
	name = "brass box"
	desc = "Большой латунный контейнер, имеющий несколько углублений на поверхности. От него исходит странная энергия."
	icon_state = "brassbox"
	item_state = null
	resistance_flags = FIRE_PROOF | ACID_PROOF
	/// Bigger than standart version
	w_class = WEIGHT_CLASS_HUGE
	/// More than standart version
	max_combined_w_class = 28
	/// Way more than standart version
	storage_slots = 28

/obj/item/storage/toolbox/brass/get_ru_names()
	return list(
		NOMINATIVE = "латунный ящик",
		GENITIVE = "латунного ящика",
		DATIVE = "латунному ящику",
		ACCUSATIVE = "латунный ящик",
		INSTRUMENTAL = "латунным ящиком",
		PREPOSITIONAL = "латунном ящике",
	)

/obj/item/storage/toolbox/brass/prefilled/populate_contents()
	new /obj/item/screwdriver/brass(src)
	new /obj/item/wirecutters/brass(src)
	new /obj/item/wrench/brass(src)
	new /obj/item/crowbar/brass(src)
	new /obj/item/weldingtool/experimental/brass(src)

/obj/item/storage/toolbox/surgery
	name = "surgery kit"
	desc = "Контейнер, предназначенный для хранения и транспортировки хирургических инструментов."
	icon_state = "surgerykit"
	item_state = "surgerykit"
	origin_tech = "combat=1;biotech=1"
	max_w_class = WEIGHT_CLASS_BULKY
	max_combined_w_class = 21
	storage_slots = 14
	can_hold = list(
		/obj/item/stack/medical/bruise_pack,
		/obj/item/bonesetter,
		/obj/item/bonegel,
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/retractor,
		/obj/item/FixOVein,
		/obj/item/surgicaldrill,
		/obj/item/circular_saw,
		/obj/item/roller/holo,
		/obj/item/stack/nanopaste,
		/obj/item/healthanalyzer,
		/obj/item/robotanalyzer,
	)

/obj/item/storage/toolbox/surgery/get_ru_names()
	return list(
		NOMINATIVE = "хирургический набор",
		GENITIVE = "хирургического набора",
		DATIVE = "хирургическому набору",
		ACCUSATIVE = "хирургический набор",
		INSTRUMENTAL = "хирургическим набором",
		PREPOSITIONAL = "хирургическом наборе",
	)

/obj/item/storage/toolbox/surgery/populate_contents()
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/bonesetter(src)
	new /obj/item/bonegel(src)
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/cautery(src)
	new /obj/item/retractor(src)
	new /obj/item/FixOVein(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/circular_saw(src)

/obj/item/storage/toolbox/surgery/empty/populate_contents()
	return

/obj/item/storage/toolbox/surgery/advanced
	name = "Advanced Laser Surgery Kit"
	desc = "Контейнер, предназначенный для хранения и транспортировки хирургических инструментов. Имеет зелёные неоновые накладки."
	icon_state = "surgerykit_advanced"
	item_state = "surgerykit_advanced"

/obj/item/storage/toolbox/surgery/advanced/populate_contents()
	new /obj/item/scalpel/laser/laser3(src)
	new /obj/item/hemostat/laser(src)
	new /obj/item/retractor/laser(src)
	new /obj/item/surgicaldrill/laser(src)
	new /obj/item/circular_saw/laser(src)
	new /obj/item/bonesetter/laser(src)
	new /obj/item/bonegel(src)
	new /obj/item/FixOVein(src)

/obj/item/storage/toolbox/surgery/advanced/get_ru_names()
	return list(
		NOMINATIVE = "продвинутый хирургический набор",
		GENITIVE = "продвинутого хирургического набора",
		DATIVE = "продвинутому хирургическому набору",
		ACCUSATIVE = "продвинутый хирургический набор",
		INSTRUMENTAL = "продвинутым хирургическим набором",
		PREPOSITIONAL = "продвинутом хирургическом наборе",
	)

/obj/item/storage/toolbox/surgery/advanced/empty/populate_contents()
	return

/obj/item/storage/toolbox/surgery/alien
	name = "Alien Surgery Kit"
	desc = "Контейнер, предназначенный для хранения и транспортировки хирургических инструментов. Выглядит очень необычно."
	icon_state = "surgerykit_alien"
	item_state = "surgerykit_alien"

/obj/item/storage/toolbox/surgery/alien/get_ru_names()
	return list(
		NOMINATIVE = "инородный хирургический набор",
		GENITIVE = "инородного хирургического набора",
		DATIVE = "инородному хирургическому набору",
		ACCUSATIVE = "инородный хирургический набор",
		INSTRUMENTAL = "инородным хирургическим набором",
		PREPOSITIONAL = "инородном хирургическом наборе",
	)

/obj/item/storage/toolbox/surgery/alien/populate_contents()
	new /obj/item/scalpel/alien(src)
	new /obj/item/hemostat/alien(src)
	new /obj/item/retractor/alien(src)
	new /obj/item/circular_saw/alien(src)
	new /obj/item/surgicaldrill/alien(src)
	new /obj/item/cautery/alien(src)
	new /obj/item/bonegel/alien(src)
	new /obj/item/bonesetter/alien(src)
	new /obj/item/FixOVein/alien(src)

/obj/item/storage/toolbox/surgery/alien/empty/populate_contents()
	return

/obj/item/storage/toolbox/surgery/ashwalker
	name = "surgery bag"
	desc = "Небольшой кожанный футляр, предназначенный для хранения и транспортировки хирургических инструментов. От него исходит едва заметный запах пепла."
	icon = 'icons/obj/storage.dmi'
	icon_state = "surgery_bag"
	pickup_sound = 'sound/items/handling/pickup/backpack_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/backpack_drop.ogg'
	flags = NONE
	force = 2
	throwforce = 4

/obj/item/storage/toolbox/surgery/ashwalker/get_ru_names()
	return list(
		NOMINATIVE = "хирургический саквояж",
		GENITIVE = "хирургического саквояжа",
		DATIVE = "хирургическому саквояжу",
		ACCUSATIVE = "хирургический саквояж",
		INSTRUMENTAL = "хирургическим саквояжем",
		PREPOSITIONAL = "хирургическом саквояже",
	)

/obj/item/storage/toolbox/surgery/ashwalker/populate_contents()
	new /obj/item/scalpel/primitive_scalpel(src)
	new /obj/item/hemostat/primitive_hemostat(src)
	new /obj/item/retractor/primitive_retractor(src)
	new /obj/item/primitive_saw(src)
	new /obj/item/cautery/primitive_cautery(src)
	new /obj/item/bonegel/primitive_bonegel(src)
	new /obj/item/FixOVein/primitive_FixOVein(src)
	new /obj/item/bonesetter/primitive_bonesetter(src)

/obj/item/storage/toolbox/surgery/ashwalker/empty/populate_contents()
	return

/obj/item/storage/toolbox/green
	name = "artistic toolbox"
	desc = "Металлический контейнер, предназначенный для хранения различных инструментов, в том числе художественных принадлежностей."
	icon_state = "toolbox_green"
	item_state = "toolbox_green"

/obj/item/storage/toolbox/green/get_ru_names()
	return list(
		NOMINATIVE = "артистический ящик для инструментов",
		GENITIVE = "артистического ящика для инструментов",
		DATIVE = "артистическому ящику для инструментов",
		ACCUSATIVE = "артистический ящик для инструментов",
		INSTRUMENTAL = "артистическим ящиком для инструментов",
		PREPOSITIONAL = "артистическом ящике для инструментов",
	)
