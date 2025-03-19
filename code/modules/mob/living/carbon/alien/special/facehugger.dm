#define MIN_IMPREGNATION_TIME 100 //time it takes to impregnate someone
#define MAX_IMPREGNATION_TIME 150

#define MIN_ACTIVE_TIME 200 //time between being dropped and going idle
#define MAX_ACTIVE_TIME 400

#define HELMET_HUGGER_DAMAGE 10

#define HELMET_BASE_DAMAGE 120

#define MASK_MIN_PROTECTION 50

/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "На конце хвоста у него есть что-то вроде трубки."
	ru_names = list(
		NOMINATIVE = "лицехват",
		GENITIVE = "лицехвата",
		DATIVE = "лицехвату",
		ACCUSATIVE = "лицехвата",
		INSTRUMENTAL = "лицехватом",
		PREPOSITIONAL = "лицехвате"
	)
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = WEIGHT_CLASS_TINY //note: can be picked up by aliens unlike most other items of w_class below 4
	throw_range = 5
	throwforce = 0
	tint = 3
	clothing_flags = AIRTIGHT
	flags_cover = MASKCOVERSMOUTH|MASKCOVERSEYES
	layer = MOB_LAYER
	max_integrity = 100
	mob_throw_hit_sound = 'sound/misc/moist_impact.ogg'
	equip_sound = 'sound/items/handling/flesh_pickup.ogg'
	drop_sound = 'sound/items/handling/flesh_drop.ogg'
	pickup_sound = 'sound/misc/moist_impact.ogg'

	holder_flags = ALIEN_HOLDER

	clothing_traits = list(TRAIT_NO_BREATH)


	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case

	var/sterile = FALSE
	var/real = TRUE //0 for the toy, 1 for real. Sure I could istype, but fuck that.
	var/strength = 3

	var/mob/living/simple_animal/hostile/facehugger/holdered_mob


/obj/item/clothing/mask/facehugger/Initialize(mapload, mob/hugger)
	. = ..()
	holdered_mob = hugger
	hugger?.forceMove(src)

/obj/item/clothing/mask/facehugger/Destroy()
	holdered_mob = null
	. = ..()

/obj/item/clothing/mask/facehugger/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	..()
	if(obj_integrity < 90)
		Die()

/obj/item/clothing/mask/facehugger/allowed_for_alien()
	return TRUE


/obj/item/clothing/mask/facehugger/attackby(obj/item/I, mob/user, params)
	return I.attack_obj(src, user, params)


/obj/item/clothing/mask/facehugger/attack_alien(mob/user) //can be picked up by aliens
	return attack_hand(user)

/obj/item/clothing/mask/facehugger/attack_hand(mob/user)
	if((stat == CONSCIOUS && !sterile) && !isalien(user))
		if(Attach(user))
			return TRUE
	if(!(isalien(user) && (holder_flags & ALIEN_HOLDER) || \
		ishuman(user) && (holder_flags & HUMAN_HOLDER)))
		return FALSE
	. = ..()


/obj/item/clothing/mask/facehugger/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(user.drop_item_ground(src) && Attach(target))
		user.do_attack_animation(target, used_item = src)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/clothing/mask/facehugger/examine(mob/user)
	. = ..()
	if(real)//So that giant red text about probisci doesn't show up for fake ones
		switch(stat)
			if(DEAD,UNCONSCIOUS)
				. += span_boldannounceic("[capitalize(declent_ru(NOMINATIVE))] не двигается.")
			if(CONSCIOUS)
				. += span_boldannounceic("[capitalize(declent_ru(NOMINATIVE))] кажется, активен!")
		if(sterile)
			. += span_boldannounceic("Похоже хоботок [genderize_ru(gender, "eго", "её", "его", "их")] удалили.")

/obj/item/clothing/mask/facehugger/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		Die()


/obj/item/clothing/mask/facehugger/equipped(mob/living/user, slot, initial = FALSE)
	if(slot_flags && slot && !sterile)
		pre_impregnate(user)
	. = ..()

/obj/item/clothing/mask/facehugger/add_clothing_traits(mob/living/user)
	if(stat == DEAD)
		return
	. = ..()


/obj/item/clothing/mask/facehugger/dropped(mob/living/user, slot, silent, mob/living/carbon/alien/alien)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(check_mob_inside)), 0.1 SECONDS)

/obj/item/clothing/mask/facehugger/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	HasProximity(arrived)


/obj/item/clothing/mask/facehugger/on_found(mob/finder)
	if(stat != DEAD)
		return HasProximity(finder)
	return FALSE

/obj/item/clothing/mask/facehugger/HasProximity(atom/movable/AM)
	if(CanHug(AM) && Adjacent(AM))
		return Attach(AM)
	return FALSE

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, dodgeable)
	. = ..()
	if(!.)
		return .
	if(stat != DEAD)
		icon_state = "[initial(icon_state)]_thrown"
	if(!iscarbon(thrower))
		return .
	var/mob/living/carbon/mob = thrower
	if(!isturf(mob.loc))
		return .
	if(!holdered_mob)
		return .
	holdered_mob.forceMove(loc)
	if(holdered_mob)
		holdered_mob.throw_at(target, range, speed, thrower, spin, diagonals_first, callback, force, dodgeable)
	holdered_mob.hugger_holder = null
	if(get_dist(target, thrower) > 1)
		qdel(src)
	return .

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(stat != DEAD)
		icon_state = "[initial(icon_state)]"
		Attach(hit_atom)

/obj/item/clothing/mask/facehugger/proc/check_mob_inside()
	if(holdered_mob && isturf(loc))
		holdered_mob.forceMove(loc)
		holdered_mob.hugger_holder = null
		qdel(src)

/obj/item/clothing/mask/facehugger/proc/Attach(mob/living/attached_mob)
	if(!isliving(attached_mob))
		return FALSE

	if((!iscarbon(attached_mob)) || isalien(attached_mob))
		return FALSE

	if(isfacehugger_mask(attached_mob.wear_mask))
		return FALSE

	if(!impregnate_check(attached_mob))
		return FALSE

	if(ishuman(attached_mob))
		var/mob/living/carbon/human/H = attached_mob
		if(!H.check_has_mouth())
			return FALSE

	if(loc == attached_mob)
		return FALSE

	var/text_name = capitalize(declent_ru(NOMINATIVE))

	if(!sterile)
		attached_mob.apply_damage(strength, BRUTE, BODY_ZONE_HEAD, forced = TRUE, silent = TRUE)

	attached_mob.visible_message(span_danger("[text_name] прыгает на лицо [attached_mob.declent_ru(GENITIVE)]!"), \
						span_userdanger("[text_name] прыгает на лицо [attached_mob.declent_ru(GENITIVE)]!"))

	if(iscarbon(attached_mob))
		var/mob/living/carbon/target = attached_mob
		var/obj/item/head = target.head

		if(head && head.flags_cover & HEADCOVERSMOUTH)
			target.visible_message(span_danger("[text_name] бьется о [head.declent_ru(ACCUSATIVE)] [target.declent_ru(GENITIVE)][real? ", оставляя немного кислоты, которая повреждает [head.declent_ru(ACCUSATIVE)]" : ""]!"), \
								span_userdanger("[text_name] бьется о [head.declent_ru(ACCUSATIVE)] [target.declent_ru(GENITIVE)][real? ", оставляя немного кислоты, которая повреждает [head.declent_ru(ACCUSATIVE)]" : ""]!"))
			if(real)
				head.take_damage(HELMET_BASE_DAMAGE, BRUTE, ACID)
				holdered_mob?.adjustBruteLoss(HELMET_HUGGER_DAMAGE)
			return FALSE

		var/obj/item/clothing/mask = target.wear_mask
		if(real && mask && !(mask.resistance_flags & ACID_PROOF) && (mask.armor.acid < MASK_MIN_PROTECTION))
			target.visible_message(span_danger("[text_name] расплавляет [mask.declent_ru(ACCUSATIVE)] своей кислотой!"), \
									span_userdanger("[text_name] расплавляет [mask.declent_ru(ACCUSATIVE)] своей кислотой!"))
			target.drop_item_ground(mask)
			qdel(mask)

		else if(mask)
			if(prob(80))
				return FALSE

			if(istype(mask, /obj/item/clothing/mask/muzzle) && real)
				var/obj/item/clothing/mask/muzzle/muzzle = mask

				if(muzzle.do_break())
					target.visible_message(span_danger("[text_name] плюёт кислотой на [muzzle.declent_ru(ACCUSATIVE)], расплавляя крепеж!"), \
									span_userdanger("[text_name] плюёт кислотой на [muzzle.declent_ru(ACCUSATIVE)], расплавляя крепеж!"))

			if(HAS_TRAIT(mask, TRAIT_NODROP))
				return FALSE

			target.drop_item_ground(mask)

			target.visible_message(span_danger("[text_name] отрывает [mask.declent_ru(ACCUSATIVE)] от лица [target.declent_ru(GENITIVE)]!"), \
									span_userdanger("[text_name] отрывает [mask.declent_ru(ACCUSATIVE)] от лица [target.declent_ru(GENITIVE)]!"))

		loc = target
		target.equip_to_slot_if_possible(src, ITEM_SLOT_MASK, disable_warning = TRUE)

	GoIdle() //so it doesn't jump the people that tear it off

	return TRUE


/obj/item/clothing/mask/facehugger/proc/impregnate_check(mob/living/attached_mob)
	if(attached_mob.get_int_organ(/obj/item/organ/internal/xenos/hivenode))
		return FALSE

	if(attached_mob.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo))
		return FALSE

	if(stat != CONSCIOUS)
		return FALSE

	return TRUE

/obj/item/clothing/mask/facehugger/proc/pre_impregnate(mob/living/attached_mob)
	if(!impregnate_check(attached_mob))
		return

	if(ishuman(attached_mob))
		var/mob/living/carbon/human/H = attached_mob
		if(!H.check_has_mouth())
			return

	GoActive()

	attached_mob.Paralyse(MAX_IMPREGNATION_TIME SECONDS / 6) //something like 25 ticks = 20 seconds with the default settings

	spawn(rand(MIN_IMPREGNATION_TIME, MAX_IMPREGNATION_TIME))
		impregnate(attached_mob)

/obj/item/clothing/mask/facehugger/proc/impregnate(mob/living/target)
	if(!target || target.stat == DEAD || loc != target) //was taken off or something
		return

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.wear_mask != src)
			return

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(!H.check_has_mouth())
			return

	var/text_name = capitalize(declent_ru(NOMINATIVE))
	if(!sterile)

		target.visible_message(span_danger("[text_name] отпускает лицо [target.declent_ru(GENITIVE)] после долгого контакта!"), \
								span_userdanger("[text_name] отпускает лицо [target.declent_ru(GENITIVE)] после долгого контакта!"))

		try_drop_hugger(target)
		holdered_mob?.on_impregnated()

		if(!target.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo))
			new /obj/item/organ/internal/body_egg/alien_embryo(target)
	else
		target.visible_message(span_danger("[text_name] продолжает контакт с лицом [target.declent_ru(GENITIVE)]!"), \
								span_userdanger("[text_name] продолжает контакт с лицом [target.declent_ru(GENITIVE)]!"))

/obj/item/clothing/mask/facehugger/proc/try_drop_hugger(mob/living/target)
	var/atom/cur_loc = loc
	if(!isliving(cur_loc.loc))
		target.drop_item_ground(src)
	else
		addtimer(CALLBACK(src, PROC_REF(try_drop_hugger), target), 0.5 SECONDS)

/obj/item/clothing/mask/facehugger/container_resist(mob/living/L)
	var/mob/living/mob = src.loc

	if(istype(mob))
		mob.drop_item_ground(src)
	else if(isitem(loc))
		to_chat(L, "Вы выбираетесь из [loc].")
		forceMove(get_turf(src))

/obj/item/clothing/mask/facehugger/proc/GoActive()
	if(stat == DEAD || stat == CONSCIOUS)
		return

	stat = CONSCIOUS
	icon_state = initial(icon_state)

/obj/item/clothing/mask/facehugger/proc/GoIdle()
	if(stat == DEAD || stat == UNCONSCIOUS)
		return

	stat = UNCONSCIOUS
	icon_state = "[initial(icon_state)]_inactive"

	spawn(rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME))
		GoActive()
	return

/obj/item/clothing/mask/facehugger/proc/Die()
	if(stat == DEAD)
		return

	icon_state = "[initial(icon_state)]_dead"
	item_state = "facehugger_inactive"
	stat = DEAD
	if(holdered_mob && holdered_mob.stat != DEAD)
		holdered_mob?.death()
	if(iscarbon(loc))
		remove_clothing_traits(loc)
	visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] сворачивается в клубок!"))

/proc/CanHug(mob/living/hugged_mob)
	if(!istype(hugged_mob))
		return FALSE

	if(hugged_mob.stat == DEAD)
		return FALSE

	if(hugged_mob.wear_mask && isfacehugger_mask(hugged_mob.wear_mask))
		return FALSE

	if(hugged_mob.get_int_organ(/obj/item/organ/internal/xenos/hivenode))
		return FALSE

	if(hugged_mob.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo))
		return FALSE

	if(ishuman(hugged_mob))
		var/mob/living/carbon/human/H = hugged_mob
		if(!H.check_has_mouth())
			return FALSE
		return TRUE

	return FALSE

/obj/item/clothing/mask/facehugger/lamarr
	name = "Lamarr"
	ru_names = list(
		NOMINATIVE = "ламарр",
		GENITIVE = "ламарр",
		DATIVE = "ламарр",
		ACCUSATIVE = "ламарр",
		INSTRUMENTAL = "ламарр",
		PREPOSITIONAL = "ламарр"
	)
	desc = "В худшем случае она попытается... спариться с вашей головой." //hope we don't get sued over a harmless reference, rite?
	sterile = 1
	gender = FEMALE
	holder_flags = ALIEN_HOLDER | HUMAN_HOLDER

/obj/item/clothing/mask/facehugger/lamarr/Initialize(mapload, hugger)
	. = ..()
	if(!holdered_mob)
		holdered_mob = new /mob/living/simple_animal/hostile/facehugger/lamarr(loc)
