/obj/item/clothing
	name = "clothing"
	integrity_failure = 80
	resistance_flags = FLAMMABLE
	abstract_type = /obj/item/clothing
	var/list/species_restricted = null //Only these species can wear this kit.
	var/gunshot_residue //Used by forensics.
	var/obj/item/slimepotion/clothing/applied_slime_potion = null
	var/list/faction_restricted = null
	var/teleportation = FALSE //used for xenobio potions

	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	var/alt_desc = null
	/*
	FLASH_PROTECTION_VERYVUNERABLE	-4 = just another "OH GOD WELDING BURNT OUT MY RETINAS".
	FLASH_PROTECTION_SENSITIVE		-1 = OH GOD WELDING BURNT OUT MY RETINAS
	FLASH_PROTECTION_NONE			 0 = Regular eyes with no protection or vulnerabilities.
	FLASH_PROTECTION_FLASH			 1 = Flashers, Flashes, & Flashbangs.
	FLASH_PROTECTION_WELDER			 2 = Welding.
	*/
	/// What level of bright light protection item has.
	var/flash_protect = FLASH_PROTECTION_NONE
	/// Sets the item's level of visual impairment tint, normally set to the same as flash_protect
	var/tint = 0
	/// Tint when its up
	var/tint_up = 0

	/// Whether clothing is currently adjusted.
	var/up = FALSE

	var/can_toggle = FALSE
	var/toggle_on_message
	var/toggle_off_message
	var/active_sound
	var/active_sound_volume = 100
	var/toggle_sound
	var/toggle_cooldown = 0
	var/cooldown = 0
	var/species_disguise
	var/magical = FALSE
	var/heal_bodypart = null	//If a bodypart or an organ is specified here, it will slowly regenerate while the clothes are worn. Currently only implemented for eyes, though.
	var/heal_rate = 1
	w_class = WEIGHT_CLASS_SMALL

	/// Trait modification, lazylist of traits to add/take away, on equipment/drop in the correct slot
	var/list/clothing_traits

	var/obj/item/radio/spy_spider/spy_spider_attached = null

/obj/item/clothing/Initialize(mapload)
	if(LAZYLEN(clothing_traits))
		clothing_traits = string_list(clothing_traits)
	. = ..()

/obj/item/clothing/examine(mob/user)
	. = ..()
	var/healthpercent = (obj_integrity/max_integrity) * 100
	switch(healthpercent)
		if(50 to 99)
			. +=  span_notice("Выглядит слегка повреждённ[GEND_YM_OI_YM_YMI(src)].")
		if(25 to 50)
			. +=  span_notice("Выглядит сильно повреждённ[GEND_YM_OI_YM_YMI(src)].")
		if(0 to 25)
			. +=  span_warning("Да [GEND_HE_SHE(src)] развалива[PLUR_ET_YUT(src)][GEND_SYA_AS_OS_IS(src)] на глазах!")

	if(armor.has_any_armor() || (flags_cover & (HEADCOVERSMOUTH|MASKCOVERSMOUTH|GLASSESCOVERSEYES|MASKCOVERSEYES|HEADCOVERSEYES|PEPPERPROOF)) || (clothing_flags & STOPSPRESSUREDAMAGE) || (visor_flags & STOPSPRESSUREDAMAGE))
		. += span_notice("Имеется <a href='byond://?src=[UID()];list_armor=1'>бирка</a>, указывающая защитные характеристики.")

/obj/item/clothing/examine_tags(mob/user)
	. = ..()
	if(clothing_flags & THICKMATERIAL)
		.["плотный"] = "Выполнен из плотного материала, защищающего от уколов."
	if((clothing_flags & STOPSPRESSUREDAMAGE) || (visor_flags & STOPSPRESSUREDAMAGE))
		.["устойчивый к давлению"] = "Способен защитить носителя от экстремального давления."
	if((clothing_traits & TRAIT_QUICK_CARRY) || (clothing_traits & TRAIT_QUICKER_CARRY))
		.["тактильный"] = "Уменьшает время для поднятия существ в пожарный захват на [(clothing_traits & TRAIT_QUICKER_CARRY) ? "две секунды" : "одну секунду"]."
	if(clothing_traits & FINGERS_COVERED)
		.["закрывающий пальцы"] = "Пальцы носителя закрыты."
	if(clothing_traits & TRAIT_FAST_CUFFING)
		.["сдерживающий"] = "Позволяет носителю заковывать существ в наручники быстрее."
	if((item_flags & BANGPROTECT_MINOR) || (item_flags & BANGPROTECT_TOTAL))
		.["защищающий слух"] = "Защищает органы слуха носителя от громких звуков."
	if(flash_protect > FLASH_PROTECTION_NONE)
		.["защищающий зрение"] = "Обеспечивает [flash_protect == FLASH_PROTECTION_FLASH ? "умеренную защиту от вспышек cвета" : "сильную защиту от интенсивного света, в том числе от сварочного огня"]."

/obj/item/clothing/examine_descriptor(mob/user)
	return "предмет одежды"

/obj/item/clothing/Topic(href, href_list)
	. = ..()

	if(href_list["list_armor"])
		var/list/readout = list()

		var/added_damage_header = FALSE
		for(var/damage_key in ARMOR_LIST_DAMAGE)
			var/rating = armor.getRating(damage_key)
			if(!rating)
				continue
			if(!added_damage_header)
				readout += "<b><u>БРОНЯ (1-10)</u></b>"
				added_damage_header = TRUE
			readout += "- [armor_to_protection_name(damage_key)] [armor_to_protection_class(rating)]"

		var/added_durability_header = FALSE
		for(var/durability_key in ARMOR_LIST_DURABILITY)
			var/rating = armor.getRating(durability_key)
			if(!rating)
				continue
			if(!added_durability_header)
				readout += "<b><u>СОПРОТИВЛЕНИЕ (1-10)</u></b>"
				added_durability_header = TRUE
			readout += "- [armor_to_protection_name(durability_key)] [armor_to_protection_class(rating)]"

		readout += "<b><u>ПОКРЫТИЕ</u></b>"
		if((flags_cover & HEADCOVERSMOUTH) || (flags_cover & PEPPERPROOF))
			var/list/things_blocked = list()
			if(flags_cover & PEPPERPROOF)
				things_blocked += span_tooltip("Защищает носителя от эффектов перцового спрея и аэрозольного капсаицина.", "перцовый спрей")
			if(length(things_blocked))
				readout += "- Блокирует [russian_list(things_blocked)]."

		var/list/parts_covered = list()
		if((body_parts_covered & HEAD) && !(slot_flags == ITEM_SLOT_MASK)) // because we don't want masks to be displayed as "Покрывает голову" when they actually don't
			parts_covered += "голову"
		else
			if((flags_cover & GLASSESCOVERSEYES) || (flags_cover & MASKCOVERSEYES) || (flags_cover & HEADCOVERSEYES))
				parts_covered += "глаза"
			if((flags_cover & MASKCOVERSMOUTH) || (flags_cover & HEADCOVERSMOUTH))
				parts_covered += "рот"
		if(body_parts_covered & UPPER_TORSO)
			parts_covered += "грудь"
		if(body_parts_covered & LOWER_TORSO)
			parts_covered += "живот"
		if(body_parts_covered & ARMS)
			parts_covered += "руки"
		if(body_parts_covered & HANDS)
			parts_covered += "ладони"
		if(body_parts_covered & LEGS)
			parts_covered += "ноги"
		if(body_parts_covered & FEET)
			parts_covered += "ступни"
		if(length(parts_covered))
			readout += "- Покрывает [russian_list(parts_covered)] носителя."

		if((clothing_flags & STOPSPRESSUREDAMAGE) || (visor_flags & STOPSPRESSUREDAMAGE))
			var/output_string = "Защищает"
			if(!(clothing_flags & STOPSPRESSUREDAMAGE))
				output_string = "Если герметизировано, то защищает"
			readout += "- [output_string] носителя от экстремального давления."

		if(max_heat_protection_temperature)
			readout += "- Защищает владельца от перегрева вплоть до [max_heat_protection_temperature]° по Кельвину ([(T0C - max_heat_protection_temperature) * -1] °C)."

		if(min_cold_protection_temperature)
			readout += "- Защищает владельца от [min_cold_protection_temperature <= SPACE_SUIT_MIN_TEMP_PROTECT ? span_tooltip("Достаточно, чтобы предотвратить потерю тепла в открытом космосе.", \
			"низких температур вплоть до [min_cold_protection_temperature]° по Кельвину ([(T0C - min_cold_protection_temperature) * -1] °C)") : "низких температур вплоть до \
			[min_cold_protection_temperature]° по Кельвину ([(T0C - min_cold_protection_temperature) * -1] °C)"]."

		if(!length(readout))
			readout += "Нет информации о прочности или защите."

		var/formatted_readout = span_notice("<b>ЗАЩИТНЫЕ ХАРАКТЕРИСТИКИ</b><hr>[jointext(readout, "\n")]")
		to_chat(usr, chat_box_examine(formatted_readout))

/obj/item/clothing/update_icon_state()
	if(!can_toggle)
		return FALSE
	// Done as such to not break chameleon gear since you can't rely on initial states
	icon_state = "[replacetext("[icon_state]", "_up", "")][up ? "_up" : ""]"
	return TRUE

/obj/item/clothing/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/radio/spy_spider))
		add_fingerprint(user)
		var/obj/item/radio/spy_spider/spy_spider = I
		if(!(slot_flags & (ITEM_SLOT_CLOTH_OUTER|ITEM_SLOT_CLOTH_INNER)))
			to_chat(user, span_warning("Вы не находите места для жучка."))
			return ATTACK_CHAIN_PROCEED
		if(spy_spider_attached)
			to_chat(user, span_warning("Жучок уже установлен."))
			return ATTACK_CHAIN_PROCEED
		if(!spy_spider.get_broadcasting())
			to_chat(user, span_warning("Жучок выключен."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(spy_spider, src))
			return ATTACK_CHAIN_PROCEED
		spy_spider_attached = spy_spider
		to_chat(user, span_notice("Вы незаметно прикрепляете жучок к [declent_ru(DATIVE)]."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/nanopaste = I

		if(obj_integrity >= max_integrity)
			user.balloon_alert(user, "[DECLENT_RU_CAP(src, NOMINATIVE)] в полном порядке")
			return ATTACK_CHAIN_PROCEED

		if(!nanopaste.use(1))
			user.balloon_alert(user, "нанопаста закончилась!")
			return ATTACK_CHAIN_PROCEED

		repair_damage(max_integrity * 0.15)
		user.visible_message(
			span_notice("[DECLENT_RU_CAP(user, NOMINATIVE)] наносит немного нанопасты на [declent_ru(ACCUSATIVE)]. [DECLENT_RU_CAP(src, NOMINATIVE)] выглядит целее."),
			span_notice("Вы нанесли немного нанопасты на [declent_ru(ACCUSATIVE)]. [DECLENT_RU_CAP(src, NOMINATIVE)] выглядит целее."),
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

/obj/item/clothing/proc/weldingvisortoggle(mob/user) //proc to toggle welding visors on helmets, masks, goggles, etc.
	if(user && !can_use(user))
		return FALSE

	if(visor_toggling(user))
		update_equipped_item(update_speedmods = FALSE)
		if(user)
			to_chat(user, span_notice("Вы [up ? "поднимаете на лоб" : "опускаете на глаза"] [declent_ru(ACCUSATIVE)]."))
		return TRUE

	return FALSE

/obj/item/clothing/proc/visor_toggling(mob/user) //handles all the actual toggling of flags
	if(!can_toggle)
		return FALSE

	. = TRUE
	up = !up
	clothing_flags ^= visor_flags
	flags_inv ^= visor_flags_inv
	flags_inv_transparent ^= visor_flags_inv_transparent
	flags_cover ^= visor_flags_cover
	if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
		flash_protect ^= initial(flash_protect)
	if(visor_vars_to_toggle & VISOR_TINT)
		tint = up ? tint_up : initial(tint)
	update_appearance()

// Aurora forensics port.
/obj/item/clothing/clean_blood()
	. = ..()
	gunshot_residue = null

/obj/item/clothing/proc/can_use(mob/user)
	if(isliving(user) && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return TRUE
	return FALSE

/obj/item/clothing/mob_can_equip(mob/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE, bypass_incapacitated = FALSE)
	. = ..()
	if(!.)
		return FALSE

	// For clothing that are faction restricted
	if(faction_restricted && !M.is_general_slot(slot) && faction_check(faction_restricted, M.faction))
		if(!disable_warning)
			to_chat(M, span_warning("[src] не могут использовать такие как Вы."))
		return FALSE

/obj/item/clothing/dropped(mob/living/user, slot, silent = FALSE)
	. = ..()
	if(!istype(user) || !LAZYLEN(clothing_traits))
		return .
	remove_clothing_traits(user)

/obj/item/clothing/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(!istype(user) || !LAZYLEN(clothing_traits) || !(slot_flags & slot))
		return .

	add_clothing_traits(user)

/obj/item/clothing/proc/remove_clothing_traits(mob/living/user)
	for(var/trait in clothing_traits)
		REMOVE_CLOTHING_TRAIT(user, src, trait)

/obj/item/clothing/proc/add_clothing_traits(mob/living/user)
	for(var/trait in clothing_traits)
		ADD_CLOTHING_TRAIT(user, src, trait)
/**
 * Used for any clothing interactions when the user is on fire. (e.g. Cigarettes getting lit.)
 */
/obj/item/clothing/proc/catch_fire() //Called in handle_fire()
	return

//Ears: currently only used for headsets and earmuffs
/obj/item/clothing/ears
	name = "ears"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 2
	slot_flags = ITEM_SLOT_EARS
	resistance_flags = NONE
	abstract_type = /obj/item/clothing/ears

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/ears.dmi',
		SPECIES_VOX_ARMALIS = 'icons/mob/clothing/species/armalis/ears.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/ears.dmi',
	) //We read you loud and skree-er.

/obj/item/proc/make_offear(slot, mob/living/carbon/human/user)
	var/obj/item/clothing/ears/offear/offear = new(user)
	offear.name = name
	offear.desc = desc
	offear.icon = icon
	offear.icon_state = icon_state
	offear.copy_overlays(src)
	offear.original_ear_UID = UID()
	offear.flags |= flags
	if(!user.equip_to_slot(offear, slot, TRUE))
		qdel(offear)
		CRASH("[src] offear was not equipped.")

/obj/item/clothing/ears/offear
	name = "off ear"
	desc = "Say hello to your other ear."
	item_flags = DROPDEL
	sprite_sheets = null
	equip_sound = null
	pickup_sound = null
	drop_sound = null
	/// UID of the original ear ite
	var/original_ear_UID

/obj/item/clothing/ears/offear/get_equip_sound()
	return

/obj/item/clothing/ears/offear/get_pickup_sound()
	return

/obj/item/clothing/ears/offear/get_drop_sound()
	return

/obj/item/clothing/ears/offear/dropped(mob/living/user, slot, silent = FALSE)
	. = ..()
	var/obj/item/original_ear = locateUID(original_ear_UID)
	if(!QDELETED(original_ear))
		user.drop_item_ground(original_ear, force = TRUE)

/obj/item/clothing/ears/offear/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	var/obj/item/original_ear = locateUID(original_ear_UID)
	if(!original_ear)
		CRASH("No original_ear found.")
	return original_ear.mouse_drop_dragged(over_object, user, src_location, over_location, params)

/obj/item/clothing/ears/offear/attack_hand(mob/user, pickupfireoverride)
	var/obj/item/original_ear = locateUID(original_ear_UID)
	if(!original_ear)
		CRASH("No original_ear found.")
	return original_ear.attack_hand(user, pickupfireoverride)

//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	icon = 'icons/obj/clothing/gloves.dmi'
	item_state = "bgloves" //For gloves withoit their own item_state
	belt_icon = "bgloves"
	siemens_coefficient = 0.50
	body_parts_covered = HANDS
	slot_flags = ITEM_SLOT_GLOVES
	attack_verb = list("на дуэль вызвал")
	clothing_flags = FINGERS_COVERED
	abstract_type = /obj/item/clothing/gloves
	var/transfer_prints = FALSE
	var/pickpocket = FALSE //Master pickpocket?
	var/clipped = FALSE
	var/extra_knock_chance = 0 //extra chance to knock down target when disarming
	/// Flat bonus to various tool handling
	/// Value of 0.1 adds 10% time delay to all performed actions in tool's category, -0.1 vice versa
	/// READ ONLY!
	var/surgeryspeedmod = 0
	/// Same as above, used for surgery modifiers
	var/toolspeedmod = 0
	/// Constant time of surgery step
	var/surgery_step_time = null
	/// Chance of germs transfering to organ
	var/surgery_germ_chance = 100
	strip_delay = 20
	put_on_delay = 40

	lefthand_file = 'icons/mob/inhands/gloves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/gloves_righthand.dmi'

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi',
	)

	var/transfer_blood = 0

/obj/item/clothing/gloves/equipped(mob/living/carbon/human/user, slot, initial)
	. = ..()
	if(!ishuman(user) || slot != ITEM_SLOT_GLOVES)
		return .
	if(surgeryspeedmod)
		user.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/surgical_gloves, multiplicative_slowdown = surgeryspeedmod)
	if(toolspeedmod)
		user.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/work_gloves, multiplicative_slowdown = toolspeedmod)

/obj/item/clothing/gloves/dropped(mob/living/carbon/human/user, slot, silent = FALSE)
	. = ..()
	if(!ishuman(user) || slot != ITEM_SLOT_GLOVES)
		return .
	if(surgeryspeedmod)
		user.remove_actionspeed_modifier(/datum/actionspeed_modifier/surgical_gloves)
	if(toolspeedmod)
		user.remove_actionspeed_modifier(/datum/actionspeed_modifier/work_gloves)

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(atom/A, proximity)
	if(!ishuman(loc))
		return FALSE //Only works while worn

	if(!ishuman(A))
		return FALSE

	if(!proximity)
		return FALSE

	var/mob/living/carbon/human/human = loc
	if(human.a_intent == INTENT_HELP)
		if(!human.is_hands_free())
			balloon_alert(usr, "руки заняты!")
			return FALSE

		return SEND_SIGNAL(src, COMSIG_GLOVES_DOUBLE_HANDS_TOUCH, A, usr) & COMPONENT_CANCEL_ATTACK_CHAIN

	return FALSE // return TRUE to cancel attack_hand()

/obj/item/clothing/gloves/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(clipped)
		to_chat(user, span_warning("The [name] have already been clipped!"))
		return .
	if(loc == user)
		to_chat(user, span_warning("You cannot clip [src] while wearing it!"))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	user.visible_message(
		span_warning("[user] snips the fingertips off [src]."),
		span_warning("You snip the fingertips off [src]."),
	)
	clipped = TRUE
	update_appearance()

/obj/item/clothing/gloves/update_name(updates = ALL)
	. = ..()
	name = clipped ? "mangled [initial(name)]" : initial(name)

/obj/item/clothing/gloves/update_desc(updates = ALL)
	. = ..()
	desc = clipped ? "[initial(desc)] They have had the fingertips cut off of them." : initial(desc)

/obj/item/clothing/gloves/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file)
	. = ..()
	if(isinhands)
		return

	var/mob/user = loc
	var/is_mob = istype(user)

	var/blood_overlay
	if(!is_mob || is_mob && user.has_left_hand())
		blood_overlay = get_blood_overlay("glove_l")
		if(blood_overlay)
			. += blood_overlay

	if(!is_mob || is_mob && user.has_right_hand())
		blood_overlay = get_blood_overlay("glove_r")
		if(blood_overlay)
			. += blood_overlay

/obj/item/clothing/under/proc/set_sensors(mob/living/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(user.pulledby && user.pulledby.grab_state >= GRAB_NECK)
		balloon_alert(user, "не добраться!")
		return
	if(has_sensor >= SENSOR_VITALS)
		balloon_alert(user, "датчики заблокированы!")
		return
	if(has_sensor <= SENSOR_OFF)
		balloon_alert(user, "датчики отсутствуют!")
		return

	if(!(user.mobility_flags & MOBILITY_USE) || !IsReachableBy(user))
		return FALSE

	var/list/modes = list("Выключены", "Бинарный режим", "Мониторинг жизненных показателей", "Полный мониторинг")
	var/new_mode = tgui_input_list(user, "Выберите режим работы датчиков:", "Режим работы датчиков костюма", modes, modes[sensor_mode+1])
	if(isnull(new_mode) || !(user.mobility_flags & MOBILITY_USE) || !IsReachableBy(user))
		return
	sensor_mode = modes.Find(new_mode) - 1

	if(src.loc == user)
		switch(sensor_mode)
			if(SENSOR_OFF)
				to_chat(user, "Вы отключаете датчики вашего костюма.")
			if(SENSOR_LIVING)
				to_chat(user, "Теперь датчики вашего костюма будут отслеживать, живы вы или мертвы.")
			if(SENSOR_VITALS)
				to_chat(user, "Теперь датчики вашего костюма будут отслеживать ваши жизненные показатели.")
			if(SENSOR_COORDS)
				to_chat(user, "Теперь датчики вашего костюма будут отслеживать ваши жизненные показатели и местоположение.")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.w_uniform == src)
				H.update_suit_sensors()

	else if(ismob(src.loc))
		switch(sensor_mode)
			if(0)
				for(var/mob/V in viewers(user, 1))
					V.show_message(span_warning("[user] отключа[PLUR_ET_YUT(user)] датчики [src.loc]."), 1)
			if(1)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] устанавлива[PLUR_ET_YUT(user)] датчики [src.loc] в бинарный режим.", 1)
			if(2)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] устанавлива[PLUR_ET_YUT(user)] датчики [src.loc] в режим мониторинга жизненных показателей.", 1)
			if(3)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] устанавлива[PLUR_ET_YUT(user)] датчики [src.loc] в режим мониторинга жизненных показателей и текущего местоположения.", 1)
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(H.w_uniform == src)
				H.update_suit_sensors()

/obj/item/clothing/under/verb/toggle()
	set name = "Датчики костюма"
	set category = VERB_CATEGORY_OBJECT
	set src in usr
	set_sensors(usr)

/obj/item/clothing/under/GetID()
	for(var/obj/item/clothing/accessory/accessory as anything in accessories)
		var/accessory_id = accessory.GetID()
		if(accessory_id)
			return accessory_id
	return ..()

/obj/item/clothing/under/GetAccess()
	. = ..()
	for(var/obj/item/clothing/accessory/accessory as anything in accessories)
		. |= accessory.GetAccess()

//Head
/obj/item/clothing/head
	name = "head"
	gender = MALE
	icon = 'icons/obj/clothing/hats.dmi'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD
	var/blockTracking // Do we block AI tracking?
	var/HUDType = null

	var/vision_flags = 0
	var/see_in_dark = 0
	var/lighting_alpha

	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi',
	)

/obj/item/clothing/head/update_icon_state()
	if(..())
		item_state = "[replacetext("[item_state]", "_up", "")][up ? "_up" : ""]"

/obj/item/clothing/head/attack_self(mob/user)
	adjust_headgear(user)

/obj/item/clothing/head/proc/adjust_headgear(mob/living/carbon/human/user)
	if(!can_toggle || user.incapacitated() || world.time < cooldown + toggle_cooldown)
		return FALSE

	. = TRUE

	cooldown = world.time
	up = !up
	update_icon(UPDATE_ICON_STATE)
	if(user.head == src)
		user.update_head(src, forced = TRUE, toggle_off = !up)
		for(var/datum/action/action as anything in actions)
			action.UpdateButtonIcon()
	else
		update_equipped_item()

	if(up && toggle_on_message)
		to_chat(user, span_notice("[toggle_on_message] [src]"))
	else if(!up && toggle_off_message)
		to_chat(user, span_notice("[toggle_off_message] [src]"))

	if(active_sound)
		INVOKE_ASYNC(src, PROC_REF(headgear_loop_sound))

	if(toggle_sound)
		playsound(loc, toggle_sound, 100, FALSE, 4)

/obj/item/clothing/head/proc/headgear_loop_sound()
	set waitfor = FALSE

	while(up)
		playsound(loc, active_sound, active_sound_volume, FALSE, 4)
		sleep(1.5 SECONDS)

/obj/item/clothing/head/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file)
	. = ..()
	if(isinhands)
		return

	var/blood_overlay = get_blood_overlay("helmet")
	if(blood_overlay)
		. += blood_overlay

//Mask
/obj/item/clothing/mask
	name = "mask"
	gender = FEMALE
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_MASK
	put_on_delay = 40
	var/adjusted_slot_flags = NONE
	var/adjusted_flags_inv = NONE
	var/adjusted_flags_inv_transparent = NONE

	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi',
	)

/// Proc that moves gas/breath masks out of the way
/obj/item/clothing/mask/proc/adjustmask(mob/living/carbon/human/user)
	if(!can_toggle || !ishuman(user) || user.incapacitated())
		return FALSE

	. = TRUE

	up = !up
	update_icon(UPDATE_ICON_STATE)

	if(up)
		gas_transfer_coefficient = 1
		permeability_coefficient = 1
		if(adjusted_slot_flags)
			slot_flags = adjusted_slot_flags
		if(adjusted_flags_inv)
			flags_inv ^= adjusted_flags_inv
		if(adjusted_flags_inv_transparent)
			flags_inv_transparent ^= adjusted_flags_inv_transparent
		//Mask won't cover the mouth any more since it's been pushed out of the way. Allows for CPRing with adjusted masks.
		if(flags_cover & MASKCOVERSMOUTH)
			flags_cover &= ~MASKCOVERSMOUTH
		//If the mask was airtight, it won't be anymore since you just pushed it off your face.
		if(clothing_flags & AIRTIGHT)
			clothing_flags &= ~AIRTIGHT

	else
		gas_transfer_coefficient = initial(gas_transfer_coefficient)
		permeability_coefficient = initial(permeability_coefficient)
		slot_flags = initial(slot_flags)
		if(adjusted_flags_inv)
			flags_inv ^= adjusted_flags_inv
		if(adjusted_flags_inv_transparent)
			flags_inv_transparent ^= adjusted_flags_inv_transparent
		if(clothing_flags != initial(clothing_flags))
			//If the mask is airtight and thus, one that you'd be able to run internals from yet can't because it was adjusted, make it airtight again.
			if(initial(clothing_flags) & AIRTIGHT)
				clothing_flags |= AIRTIGHT
		if(flags_cover != initial(flags_cover))
			//If the mask covers the mouth when it's down and can be adjusted yet lost that trait when it was adjusted, make it cover the mouth again.
			if(initial(flags_cover) & MASKCOVERSMOUTH)
				flags_cover |= MASKCOVERSMOUTH

	// special head and mask slots post handling
	if(user.wear_mask == src || user.head == src)
		user.wear_mask_update(src, toggle_off = up)
		for(var/datum/action/action as anything in actions)
			action.UpdateButtonIcon()
	else
		update_equipped_item()

	// now we are trying to reequip our mask to a new slot, hands or just drop it
	if(!adjusted_slot_flags || !(src in user.get_equipped_items()))
		return .
	user.drop_item_ground(src, force = TRUE)	// we are changing slots, force is a must
	if(!user.equip_to_slot_if_possible(src, slot_flags))
		user.put_in_hands(src)

/obj/item/clothing/mask/proc/force_adjust_mask()
	up = TRUE
	update_icon(UPDATE_ICON_STATE)
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	if(adjusted_slot_flags)
		slot_flags = adjusted_slot_flags
	if(adjusted_flags_inv)
		flags_inv ^= adjusted_flags_inv
	if(adjusted_flags_inv_transparent)
		flags_inv_transparent ^= adjusted_flags_inv_transparent
	if(flags_cover & MASKCOVERSMOUTH)
		flags_cover &= ~MASKCOVERSMOUTH
	if(clothing_flags & AIRTIGHT)
		clothing_flags &= ~AIRTIGHT

// Changes the speech verb when wearing a mask if a value is returned
/obj/item/clothing/mask/proc/change_speech_verb()
	return

/obj/item/clothing/mask/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file)
	. = ..()
	if(isinhands || !(body_parts_covered & HEAD))
		return

	var/blood_overlay = get_blood_overlay("mask")
	if(blood_overlay)
		. += blood_overlay

//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	abstract_type = /obj/item/clothing/shoes
	gender = PLURAL //Carn: for grammatically correct text-parsing
	//var/chained = 0
	var/can_cut_open = FALSE
	var/cut_open = FALSE
	body_parts_covered = FEET
	slot_flags = ITEM_SLOT_FEET
	pickup_sound = 'sound/items/handling/pickup/shoes_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/shoes_drop.ogg'

	var/silence_steps = 0
	var/blood_state = BLOOD_STATE_NOT_BLOODY
	var/list/bloody_shoes = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0, BLOOD_STATE_NOT_BLOODY = 0)

	permeability_coefficient = 0.50

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/shoes.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/shoes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/shoes.dmi',
	)

/obj/item/clothing/shoes/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!can_cut_open)
		to_chat(user, span_warning("You cannot cut open [src]!"))
		return .
	if(cut_open)
		to_chat(user, span_warning("The [name] have already had [p_their()] toes cut open!"))
		return .
	if(loc == user)
		to_chat(user, span_warning("You cannot cut open [src] while wearing it!"))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	user.visible_message(
		span_warning("[user] cuts open the toes of [src]."),
		span_warning("You cut open the toes of [src]."),
	)
	cut_open = TRUE
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE)

/obj/item/clothing/shoes/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/tape_roll) && !silence_steps)
		add_fingerprint(user)
		var/obj/item/stack/tape_roll/tape = I
		if(!tape.use(4))
			to_chat(user, span_warning("You need at least four lengths of tape to cover [src]!"))
			return ATTACK_CHAIN_PROCEED
		silence_steps = TRUE
		GetComponent(/datum/component/jackboots)?.ClearFromParent()
		to_chat(user, span_notice("You tape the soles of [src] to silence your footsteps."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/match) && loc == user)
		add_fingerprint(user)
		var/obj/item/match/match = I
		if(match.matchignite()) // Match isn't lit, but isn't burnt.
			playsound(user.loc, 'sound/goonstation/misc/matchstick_light.ogg', 50, TRUE)
			user.visible_message(
				span_warning("[user] strikes [match] on the bottom of [src], lighting it."),
				span_warning("You have striked [match] on the bottom of [src] to light it."),
			)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		user.visible_message(
				span_warning("[user] crushes [match] into the bottom of [src], extinguishing it."),
				span_warning("You have crushed [match] into the bottom of [src], extinguishing it."),
			)
		user.drop_item_ground(match, force = TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/clothing/shoes/update_name()
	. = ..()
	if(!cut_open)
		name = initial(name)
		return
	name = "mangled [initial(name)]"

/obj/item/clothing/shoes/update_desc()
	. = ..()
	if(!cut_open)
		desc = initial(desc)
		return
	desc = "[initial(desc)] They have had their toes opened up."

/obj/item/clothing/shoes/update_icon_state()
	var/base_icon_state = replacetext("[icon_state]", "_opentoe", "")
	var/base_item_state = replacetext("[item_state]", "_opentoe", "")
	if(cut_open)
		icon_state = "[base_icon_state]_opentoe"
		item_state = "[base_icon_state]_opentoe"
	else
		icon_state = base_icon_state
		item_state = base_item_state
	update_equipped_item(update_speedmods = FALSE)

/obj/item/clothing/shoes/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands = FALSE, icon_file)
	. = ..()
	if(isinhands)
		return

	var/mob/user = loc
	var/is_mob = istype(user)

	var/blood_overlay

	// We don't want overlays to lay one on another, so we separate conditions with two and one feet
	if(!is_mob || is_mob && user.has_both_feet())
		blood_overlay = get_blood_overlay("shoes")
		if(blood_overlay)
			. += blood_overlay
		return

	if(user.has_left_foot())
		blood_overlay = get_blood_overlay("shoe_l")
		if(blood_overlay)
			. += blood_overlay
		return

	if(user.has_right_foot())
		blood_overlay = get_blood_overlay("shoe_r")
		if(blood_overlay)
			. += blood_overlay
		return

//Suit
/obj/item/clothing/suit
	name = "suit"
	gender = MALE
	icon = 'icons/obj/clothing/suits.dmi'
	abstract_type = /obj/item/clothing/suit
	var/fire_resist = T0C+100
	allowed = list(/obj/item/tank/internals/emergency_oxygen)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	drop_sound = 'sound/items/handling/drop/cloth_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/cloth_pickup.ogg'
	slot_flags = ITEM_SLOT_CLOTH_OUTER
	var/blood_overlay_type = "suit"
	/// Whether suit is currently adjusted, example: shirt is buttoned.
	/// If this variable is set to `TRUE` initial icon_state/item_state should be without "_open" postfix.
	var/suit_adjusted = FALSE
	/// Whether we can even adjust this suit.
	var/ignore_suitadjust = TRUE
	/// Flavour text used when adjusting this suit.
	var/adjust_flavour
	var/list/hide_tail_by_species = null
	max_integrity = 400
	integrity_failure = 160

	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
	)

/obj/item/clothing/suit/Initialize(mapload)
	. = ..()
	setup_shielding()

/**
 * Wrapper proc to apply shielding through AddComponent().
 * Called in /obj/item/clothing/suit/Initialize().
 * Override with an AddComponent(/datum/component/shielded, args) call containing the desired shield statistics.
 * See /datum/component/shielded documentation for a description of the arguments
 **/
/obj/item/clothing/suit/proc/setup_shielding()
	return

//Proc that opens and closes jackets.
/obj/item/clothing/suit/proc/adjustsuit(mob/user)
	if(ignore_suitadjust)
		to_chat(user, span_notice("You attempt to button up the velcro on [src], before promptly realising how foolish you are."))
		return
	if(user.incapacitated())
		return

	if(HAS_TRAIT(user, TRAIT_HULK))
		if(user.can_unEquip(src)) //Checks to see if the item can be unequipped. If so, lets shred. Otherwise, struggle and fail.
			for(var/obj/item/thing in src) //AVOIDING ITEM LOSS. Check through everything that's stored in the jacket and see if one of the items is a pocket.
				if(istype(thing, /obj/item/storage/internal)) //If it's a pocket...
					for(var/obj/item/pocket_thing in thing) //Dump the pocket out onto the floor below the user.
						user.drop_item_ground(pocket_thing, force = TRUE)

			user.visible_message(span_warning("[user] bellows, [pick("shredding", "ripping open", "tearing off")] [user.p_their()] jacket in a fit of rage!"),span_warning("You accidentally [pick("shred", "rend", "tear apart")] [src] with your [pick("excessive", "extreme", "insane", "monstrous", "ridiculous", "unreal", "stupendous")] [pick("power", "strength")]!"))
			user.temporarily_remove_item_from_inventory(src)
			qdel(src) //Now that the pockets have been emptied, we can safely destroy the jacket.
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		else
			to_chat(user, span_warning("You yank and pull at \the [src] with your [pick("excessive", "extreme", "insane", "monstrous", "ridiculous", "unreal", "stupendous")] [pick("power", "strength")], however you are unable to change its state!"))//Yep, that's all they get. Avoids having to snowflake in a cooldown.
		return

	suit_adjusted = !suit_adjusted
	update_icon(UPDATE_ICON_STATE)
	update_equipped_item(update_speedmods = FALSE)

	if(suit_adjusted)
		var/flavour = "close"
		if(adjust_flavour)
			flavour = "[copytext(adjust_flavour, 3, length(adjust_flavour) + 1)] up" //Trims off the 'un' at the beginning of the word. unzip -> zip, unbutton->button.
		to_chat(user, "You [flavour] [src].")
	else
		var/flavour = "open"
		if(adjust_flavour)
			flavour = "[adjust_flavour]"
		to_chat(user, "You [flavour] [src].")

/obj/item/clothing/suit/attack_self(mob/user)
	adjustsuit(user)

/obj/item/clothing/suit/update_icon_state()
	// Trims the '_open' off the end of the icon state, thus avoiding a case where jackets that start open will
	// end up with a suffix of _open_open if adjusted twice, since their initial state is _open
	var/base_icon_state = replacetext("[icon_state]", "_open", "")
	var/base_item_state = replacetext("[item_state]", "_open", "")
	if(suit_adjusted || ignore_suitadjust)
		icon_state = base_icon_state
		item_state = base_item_state
	else
		icon_state = "[base_icon_state]_open"
		item_state = "[base_item_state]_open"
	update_equipped_item(update_speedmods = FALSE)

// Proc used to check if suit storage is limited by item weight
// Allows any suit to have their own weight limit for items that can be equipped into suit storage
/obj/item/clothing/suit/proc/can_store_weighted(obj/item/I, item_weight = WEIGHT_CLASS_BULKY)
	return I.w_class <= item_weight

/obj/item/clothing/suit/equipped(mob/living/carbon/human/user, slot, initial) //Handle tail-hiding on a by-species basis.
	. = ..()

	if(ishuman(user) && hide_tail_by_species && slot == ITEM_SLOT_CLOTH_OUTER)
		if("modsuit" in hide_tail_by_species)
			return
		if(user.dna.species.name in hide_tail_by_species)
			if(!(flags_inv & HIDETAIL)) //Hide the tail if the user's species is in the hide_tail_by_species list and the tail isn't already hidden.
				flags_inv |= HIDETAIL
				user.update_tail_layer()
		else
			if(!(initial(flags_inv) & HIDETAIL) && (flags_inv & HIDETAIL)) //Otherwise, remove the HIDETAIL flag if it wasn't already in the flags_inv to start with.
				flags_inv &= ~HIDETAIL
				user.update_tail_layer()

/obj/item/clothing/suit/ui_action_click(mob/user, datum/action/action, leftclick) //This is what happens when you click the HUD action button to adjust your suit.
	if(!ignore_suitadjust)
		adjustsuit(user)
	else
		..() //This is required in order to ensure that the UI buttons for items that have alternate functions tied to UI buttons still work.

/obj/item/clothing/suit/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands = FALSE, icon_file)
	. = ..()
	if(isinhands)
		return

	var/blood_overlay = get_blood_overlay(blood_overlay_type)
	if(blood_overlay)
		. += blood_overlay

//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "Space helmet"
	icon_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	clothing_flags = STOPSPRESSUREDAMAGE|THICKMATERIAL|STACKABLE_HELMET_EXEMPT
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = parent_type::flags_inv|HIDEHAIR|HIDENAME|HIDEMASK
	item_state = "s_helmet"
	permeability_coefficient = 0.01
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 80, ACID = 70)
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	species_restricted = list("exclude", SPECIES_WRYN, "lesser form")
	flash_protect = FLASH_PROTECTION_WELDER
	strip_delay = 50
	put_on_delay = 50
	resistance_flags = NONE
	dog_fashion = null
	/// List of things added to examine text, like security or medical records.
	var/examine_extensions = EXAMINE_HUD_NONE

/obj/item/clothing/suit/space
	name = "Space suit"
	desc = "A suit that protects against low pressure environments. Has a big 13 on the back."
	icon_state = "space"
	item_state = "s_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	clothing_flags = STOPSPRESSUREDAMAGE|THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|TAIL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	slowdown = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 80, ACID = 70)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | TAIL
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | TAIL
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 80
	put_on_delay = 80
	equip_delay_self = 4 SECONDS
	resistance_flags = NONE
	hide_tail_by_species = null
	species_restricted = list("exclude", SPECIES_WRYN, "lesser form")
	faction_restricted = list("ashwalker")
	undyeable = TRUE
	var/obj/item/tank/jetpack/suit/jetpack = null
	var/jetpack_upgradable = FALSE

/obj/item/clothing/suit/space/Initialize(mapload)
	. = ..()
	if(jetpack && ispath(jetpack))
		jetpack = new jetpack(src)
		jetpack.our_suit = src

/obj/item/clothing/suit/space/Destroy()
	QDEL_NULL(jetpack)
	return ..()

/obj/item/clothing/suit/space/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!jetpack)
		to_chat(user, span_warning("[src] has no jetpack installed."))
		return
	if(src == user.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER))
		to_chat(user, span_warning("You cannot remove the jetpack from [src] while wearing it."))
		return
	jetpack.turn_off(user)
	jetpack.our_suit = null
	jetpack.forceMove(drop_location())
	jetpack = null
	to_chat(user, span_notice("You successfully remove the jetpack from [src]."))

/obj/item/clothing/suit/space/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(jetpack && slot == ITEM_SLOT_CLOTH_OUTER)
		for(var/datum/action/action as anything in jetpack.actions)
			action.Grant(user)

/obj/item/clothing/suit/space/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(jetpack)
		for(var/datum/action/action as anything in jetpack.actions)
			action.Remove(user)
		jetpack.turn_off(user)

/obj/item/clothing/suit/space/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/jetpack/suit))
		add_fingerprint(user)
		if(!jetpack_upgradable)
			to_chat(user, span_warning("There is no slot for the jetpack upgrade in [src]"))
			return ATTACK_CHAIN_PROCEED
		if(jetpack)
			to_chat(user, span_warning("The [name] already has [jetpack] installed."))
			return ATTACK_CHAIN_PROCEED
		if(src == user.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, span_warning("You cannot install the upgrade to [src] while wearing it."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		jetpack = I
		jetpack.our_suit = src
		to_chat(user, span_notice("You successfully install the jetpack into [src]."))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

// Under clothing
/obj/item/clothing/under
	name = "under"
	gender = MALE
	icon = 'icons/obj/clothing/uniforms.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	permeability_coefficient = 0.90
	slot_flags = ITEM_SLOT_CLOTH_INNER
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	equip_sound = 'sound/items/handling/equip/jumpsuit_equip.ogg'
	drop_sound = 'sound/items/handling/drop/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/pickup/cloth_pickup.ogg'
	abstract_type = /obj/item/clothing/under

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
	)

	var/has_sensor = TRUE//For the crew computer 2 = unable to change mode
	var/sensor_mode = SENSOR_OFF
		/*
		SENSOR_OFF		= Report nothing
		SENSOR_LIVING	= Report living/dead
		SENSOR_VITALS	= Report detailed damages
		SENSOR_COORDS	= Report location
		*/
	var/random_sensor = TRUE
	var/displays_id = TRUE
	var/over_shoes = FALSE
	/// Lazylist of all accessories on the suit.
	var/list/accessories
	/// Whether we can roll down this uniform.
	var/can_adjust = TRUE
	/// If true, it's rolled down.
	var/rolled_down = FALSE

/obj/item/clothing/under/rank
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/rank/Initialize(mapload)
	. = ..()
	if(random_sensor)
		sensor_mode = pick(SENSOR_OFF, SENSOR_LIVING, SENSOR_VITALS, SENSOR_COORDS)


/obj/item/clothing/under/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/contextual_screentip_bare_hands, rmb_text = "Настроить датчики")

/obj/item/clothing/under/Destroy()
	QDEL_LIST(accessories)
	return ..()

/obj/item/clothing/under/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(!ishuman(user) || slot != ITEM_SLOT_CLOTH_INNER)
		return .

	for(var/obj/item/clothing/accessory/accessory as anything in accessories)
		accessory.attached_unequip(user)

/obj/item/clothing/under/equipped(mob/user, slot, initial)
	. = ..()

	if(!ishuman(user) || slot != ITEM_SLOT_CLOTH_INNER)
		return .

	for(var/obj/item/clothing/accessory/accessory as anything in accessories)
		accessory.attached_equip(user)

/obj/item/clothing/under/update_overlays()
	. = ..()

	if(!LAZYLEN(accessories))
		return .

	for(var/obj/item/clothing/accessory/accessory as anything in accessories)
		if(accessory.acc_overlay)
			. += accessory.acc_overlay

/obj/item/clothing/under/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands = FALSE, icon_file)
	. = ..()
	if(isinhands)
		return

	var/blood_overlay = get_blood_overlay("uniform")
	if(blood_overlay)
		. += blood_overlay

/*
 * # can_attach_accessory
 *
 * Arguments:
 * * checked_acc - The accessory object being checked. MUST BE TYPE /obj/item/clothing/accessory
 * * attacher - The mob trying to attach checked_acc
 */
/obj/item/clothing/under/proc/can_attach_accessory(obj/item/clothing/accessory/checked_acc, mob/attacher)
	if(!istype(checked_acc))
		return FALSE

	if(!LAZYLEN(accessories))
		return TRUE

	if(!checked_acc.uniform_check(user = attacher, uniform = src))
		return FALSE

	var/unique_slots = (checked_acc.slot & (ACCESSORY_SLOT_UTILITY|ACCESSORY_SLOT_ARMBAND))
	for(var/obj/item/clothing/accessory/accessory as anything in accessories)
		if(unique_slots && (accessory.slot & checked_acc.slot))
			return FALSE
		if(!checked_acc.allow_duplicates && accessory.type == checked_acc.type)
			return FALSE

	return TRUE

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if(isaccessory(I))
		if(attach_accessory(I, user, unequip = TRUE))
			return ATTACK_CHAIN_BLOCKED_ALL

	else if(LAZYLEN(accessories))
		add_fingerprint(user)
		for(var/obj/item/clothing/accessory/accessory as anything in accessories)
			accessory.attackby(I, user, params)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/clothing/under/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	set_sensors(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/under/attack_self_secondary(mob/user, list/modifiers)
	set_sensors(user)
	return TRUE

/obj/item/clothing/under/proc/attach_accessory(obj/item/clothing/accessory/accessory, mob/user, unequip = FALSE)
	if(!can_attach_accessory(accessory, user))
		if(user)
			to_chat(user, span_notice("Невозможно добавить больше аксессуаров этого типа к [declent_ru(DATIVE)]."))
		return FALSE
	if(unequip && user && !user.drop_transfer_item_to_loc(accessory, src)) // Make absolutely sure this accessory is removed from hands
		return FALSE
	accessory.on_attached(src, user)
	if(user)
		accessory.add_fingerprint(user)
		to_chat(user, span_notice("Вы прикрепили [accessory.declent_ru(ACCUSATIVE)] к [declent_ru(DATIVE)]."))
	return TRUE

/obj/item/clothing/under/verb/removetie()
	set name = "Убрать аксессуар"
	set category = VERB_CATEGORY_OBJECT
	set src in usr
	handle_accessories_removal(usr)

/obj/item/clothing/under/click_alt(mob/user)
	if(handle_accessories_removal(user))
		return CLICK_ACTION_SUCCESS
	return CLICK_ACTION_BLOCKING

/obj/item/clothing/under/proc/handle_accessories_removal(mob/user)
	var/accessories_len = LAZYLEN(accessories)
	if(!accessories_len)
		to_chat(user, span_notice("На [declent_ru(PREPOSITIONAL)] нет присоединённых аксессуаров."))
		return FALSE
	var/obj/item/clothing/accessory/accessory
	if(accessories_len > 1)
		accessory = tgui_input_list(user, "Выберите аксессуар для удаления с [declent_ru(GENITIVE)]", "Удаление аксессуара", accessories)
		if(!accessory || !LAZYIN(accessories, accessory) || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			return FALSE
	else
		accessory = accessories[1]

	to_chat(user, span_notice("Вы снимаете [accessory.declent_ru(ACCUSATIVE)] с [declent_ru(GENITIVE)]."))
	accessory.on_removed(user)
	if(!user.put_in_hands(accessory, ignore_anim = FALSE))
		accessory.forceMove_turf()
	return TRUE

/obj/item/clothing/under/examine(mob/user)
	. = ..()
	if(has_sensor)
		switch(sensor_mode)
			if(0)
				. += span_notice("Датчики отключены.")
			if(1)
				. += span_notice("Датчики работают в бинарном режиме.")
			if(2)
				. += span_notice("Датчики работают в режиме мониторинга жизненных показателей.")
			if(3)
				. += span_notice("Датчики работают в режиме мониторинга жизненных показателей и текущего местоположения.")

	for(var/obj/item/clothing/accessory/accessory as anything in accessories)
		. += accessory.attached_examine(user, src)

/obj/item/clothing/under/verb/rollsuit()
	set name = "Сменить стиль униформы"
	set category = VERB_CATEGORY_OBJECT
	set src in usr

	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/owner = usr
	if(owner.incapacitated() || HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED))
		to_chat(owner, span_notice("Вы не можете изменить стиль этой одежды прямо сейчас!"))
		return

	if(!can_adjust)
		to_chat(owner, span_notice("Вы не можете изменить стиль этой одежды прямо сейчас!"))
		return

	var/icon/our_icon = onmob_sheets[ITEM_SLOT_CLOTH_INNER_STRING]
	if(sprite_sheets?[owner.dna.species.name])
		our_icon = sprite_sheets[owner.dna.species.name]

	if(!icon_exists(our_icon, "[icon_state]_d_s"))
		to_chat(owner, span_notice("Вы не можете изменить стиль этой одежды прямо сейчас!"))
		return

	rolled_down = !rolled_down
	update_equipped_item(update_speedmods = FALSE)

/obj/item/clothing/under/emp_act(severity)
	for(var/obj/item/clothing/accessory/accessory as anything in accessories)
		accessory.emp_act(severity)
	..()

/obj/item/clothing/obj_destruction(damage_flag)
	if(damage_flag == BOMB || damage_flag == MELEE)
		var/turf/T = get_turf(src)
		spawn(1) //so the shred survives potential turf change from the explosion.
			var/obj/effect/decal/cleanable/shreds/Shreds = new(T)
			Shreds.desc = "The sad remains of what used to be [name]."
		deconstruct(FALSE)
	else
		..()

// Neck clothing
/obj/item/clothing/neck
	name = "necklace"
	icon = 'icons/obj/clothing/neck.dmi'
	body_parts_covered = UPPER_TORSO
	slot_flags = ITEM_SLOT_NECK
	abstract_type = /obj/item/clothing/neck

	sprite_sheets = list(
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/neck.dmi'
		)

/obj/item/clothing/neck/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file)
	. = ..()
	if(isinhands || !(body_parts_covered & HEAD))
		return

	var/blood_overlay = get_blood_overlay("mask")
	if(blood_overlay)
		. += blood_overlay

/obj/item/clothing/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(!teleportation)
		return ..()
	if(prob(5))
		var/mob/living/carbon/human/H = owner
		owner.visible_message(span_danger("The teleport slime potion flings [H] clear of [attack_text]!"))
		var/list/turfs = new/list()
		for(var/turf/T in orange(3, H))
			if(isspaceturf(T))
				continue
			if(T.density)
				continue
			if(T.x>world.maxx-3 || T.x<3)
				continue
			if(T.y>world.maxy-3 || T.y<3)
				continue
			turfs += T
		if(!length(turfs))
			turfs += pick(/turf in orange(3, H))
		var/turf/picked = pick(turfs)
		if(!isturf(picked))
			return
		H.forceMove(picked)
		return 1
	return ..()

/**
 * Inserts a trait (or multiple traits) into the clothing traits list
 *
 * If worn, then we will also give the wearer the trait as if equipped
 *
 * This is so you can add clothing traits without worrying about needing to equip or unequip them to gain effects
 */
/obj/item/clothing/proc/attach_clothing_traits(trait_or_traits)
	if(!islist(trait_or_traits))
		trait_or_traits = list(trait_or_traits)

	LAZYOR(clothing_traits, trait_or_traits)
	if(clothing_traits) // because we might be null
		clothing_traits = string_list(clothing_traits)
	var/mob/wearer = loc
	if(istype(wearer) && (wearer.get_slot_by_item(src) & slot_flags))
		for(var/new_trait in trait_or_traits)
			ADD_CLOTHING_TRAIT(wearer, src, new_trait)

/**
 * Removes a trait (or multiple traits) from the clothing traits list
 *
 * If worn, then we will also remove the trait from the wearer as if unequipped
 *
 * This is so you can add clothing traits without worrying about needing to equip or unequip them to gain effects
 */
/obj/item/clothing/proc/detach_clothing_traits(trait_or_traits)
	if(!islist(trait_or_traits))
		trait_or_traits = list(trait_or_traits)

	LAZYREMOVE(clothing_traits, trait_or_traits)
	var/mob/wearer = loc
	if(istype(wearer))
		for(var/new_trait in trait_or_traits)
			REMOVE_CLOTHING_TRAIT(wearer, src, new_trait)

/// Returns a list of overlays with our blood, if we're bloodied
/obj/item/clothing/proc/get_blood_overlay(blood_state)
	if(!blood_DNA)
		return

	var/blood_mask = 'icons/mob/human_races/masks/blood_human.dmi'

	var/mob/user = loc
	if(istype(user) && user.dna && ("[blood_state]blood" in user.dna.species.get_blood_overlays()))
		blood_mask = user.dna.species.blood_mask

	return mutable_appearance(blood_mask, "[blood_state]blood", color = blood_color)
