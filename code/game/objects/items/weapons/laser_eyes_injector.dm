/obj/item/laser_eyes_injector
	name = "laser eyes injector"
	desc = "Инъектор, который даст вам способность стрелять лазерами из глаз."
	ru_names = list(
		NOMINATIVE = "инъектор лазерных глаз",
		GENITIVE = "инъектора лазерных глаз",
		DATIVE = "инъектору лазерных глаз",
		ACCUSATIVE = "инъектор лазерных глаз",
		INSTRUMENTAL = "инъектором лазерных глаз",
		PREPOSITIONAL = "инъекторе лазерных глаз"
	)
	icon = 'icons/obj/hypo.dmi'
	icon_state = "dnainjector"
	var/used = FALSE


/obj/item/laser_eyes_injector/update_icon_state()
	. = ..()
	icon_state = "dnainjector[used ? "0" : ""]"


/obj/item/laser_eyes_injector/update_name(updates = ALL)
	. = ..()
	name = used ? "used [initial(name)]" : initial(name)


/obj/item/laser_eyes_injector/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!ishuman(target))
		return .

	if(HAS_TRAIT(target, TRAIT_NO_DNA))
		balloon_alert(user, "ДНК не обнаружена!")
		return .

	if(locate(/obj/effect/proc_holder/spell/lasereyes, target.mob_spell_list))
		balloon_alert(user, "ген уже имеется!")
		return .

	if(used)
		balloon_alert(user, "уже использовано!")
		return .

	. |= ATTACK_CHAIN_SUCCESS
	target.AddSpell(new /obj/effect/proc_holder/spell/lasereyes)
	used = TRUE
	update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)


/obj/effect/proc_holder/spell/lasereyes
	name = "Лазеры из глаз"
	desc = "Активация или дезактивация способности стрелять лазерами из глаз."
	clothes_req = FALSE
	base_cooldown = 1 SECONDS
	cooldown_min = 1 SECONDS
	action_icon_state = "lazer_hulk"


/obj/effect/proc_holder/spell/lasereyes/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/lasereyes/cast(list/targets, mob/user = usr)
	if(HAS_TRAIT_FROM(user, TRAIT_LASEREYES, UNIQUE_TRAIT_SOURCE(src)))
		REMOVE_TRAIT(user, TRAIT_LASEREYES, UNIQUE_TRAIT_SOURCE(src))
		to_chat(user, span_warning("Лёгкое жжение в области ваших глаз прошло."))
	else
		ADD_TRAIT(user, TRAIT_LASEREYES, UNIQUE_TRAIT_SOURCE(src))
		to_chat(user, span_warning("Вы чувствуете лёгкое жжение в области ваших глаз."))

