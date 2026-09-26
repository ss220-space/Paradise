/obj/item/laser_eyes_injector
	name = "laser eyes injector"
	desc = "Инъектор, который даст вам способность стрелять лазерами из глаз."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "dnainjector"
	var/used = FALSE

/obj/item/laser_eyes_injector/get_ru_names()
	return alist(
		NOMINATIVE = "инъектор лазерных глаз",
		GENITIVE = "инъектора лазерных глаз",
		DATIVE = "инъектору лазерных глаз",
		ACCUSATIVE = "инъектор лазерных глаз",
		INSTRUMENTAL = "инъектором лазерных глаз",
		PREPOSITIONAL = "инъекторе лазерных глаз",
	)

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
		balloon_alert(user, UNLINT("ДНК не обнаружена!"))
		return .

	if(locate(/datum/action/cooldown/spell/lasereyes, target.mob_spell_list))
		balloon_alert(user, "ген уже имеется!")
		return .

	if(used)
		balloon_alert(user, "уже использовано!")
		return .

	. |= ATTACK_CHAIN_SUCCESS
	target.AddSpell(new /datum/action/cooldown/spell/lasereyes)
	used = TRUE
	update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)

/datum/action/cooldown/spell/lasereyes
	name = "Лазеры из глаз"
	desc = "Активация или дезактивация способности стрелять лазерами из глаз."
	spell_requirements = SPELL_REQUIRES_HUMAN
	cooldown_time = 1 SECONDS
	button_icon_state = "lazer_hulk"

/datum/action/cooldown/spell/lasereyes/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/user = cast_on
	if(HAS_TRAIT_FROM(user, TRAIT_LASEREYES, UNIQUE_TRAIT_SOURCE(src)))
		REMOVE_TRAIT(user, TRAIT_LASEREYES, UNIQUE_TRAIT_SOURCE(src))
		to_chat(user, span_warning("Лёгкое жжение в области ваших глаз прошло."))
	else
		ADD_TRAIT(user, TRAIT_LASEREYES, UNIQUE_TRAIT_SOURCE(src))
		to_chat(user, span_warning("Вы чувствуете лёгкое жжение в области ваших глаз."))

