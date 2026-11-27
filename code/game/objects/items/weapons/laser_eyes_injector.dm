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

	if(HAS_TRAIT(target, TRAIT_LASEREYES))
		balloon_alert(user, "ген уже имеется!")
		return .

	if(used)
		balloon_alert(user, "уже использовано!")
		return .

	. |= ATTACK_CHAIN_SUCCESS
	target.AddSpell(new /datum/action/cooldown/spell/pointed/projectile/lasereyes)
	used = TRUE
	update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
