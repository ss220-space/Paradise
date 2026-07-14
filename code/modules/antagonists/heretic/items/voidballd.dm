/obj/item/void_prison
	name = "void prison"
	desc = "Небольшая стеклянная сфера с клубящейся внутри тьмой. Она холодна на ощупь и поглощает весь свет вокруг себя."
	gender = FEMALE
	icon = 'icons/mob/actions/actions_ecult.dmi'
	icon_state = "voidball"
	pickup_sound = 'sound/items/handling/pickup/drinkglass_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/drinkglass_drop.ogg'


/obj/item/void_prison/get_ru_names()
	return alist(
		NOMINATIVE = "пустотная тюрьма",
		GENITIVE = "пустотной тюрьмы",
		DATIVE = "пустотной тюрьме",
		ACCUSATIVE = "пустотную тюрьму",
		INSTRUMENTAL = "пустотной тюрьмой",
		PREPOSITIONAL = "пустотной тюрьме",
	)


/obj/item/void_prison/Initialize(mapload)
	. = ..()
	transform = transform.Scale(0.5)


/obj/item/void_prison/attack_self(mob/living/user)
	. = ..()
	if(.)
		return

	playsound(src, SFX_SHATTER, 50, TRUE)
	playsound(src, 'sound/magic/voidblink.ogg', 50, FALSE)
	if(IS_HERETIC_OR_MONSTER(user))
		to_chat(user, span_hypnophrase("Вы разбиваете [declent_ru(ACCUSATIVE)], высвобождая её силу вокруг себя!"))
		for(var/mob/living/nearby_mob in view(3, user))
			if(IS_HERETIC_OR_MONSTER(nearby_mob))
				continue
			if(nearby_mob.has_status_effect(/datum/status_effect/eldritch))
				continue
			if(nearby_mob.can_block_magic(MAGIC_RESISTANCE))
				nearby_mob.visible_message(
					span_danger("Холодная, кружащаяся пустота окутывает [nearby_mob.declent_ru(ACCUSATIVE)], но [GEND_HE_SHE(nearby_mob)] вырыва[PLUR_ET_YUT(nearby_mob)]ся на свободу!"),
					span_userdanger("Перед вами разверзается зияющая пустота, но мощная волна жара разносит её вдребезги! Вы защищены!")
				)
				continue
			nearby_mob.visible_message(
				span_danger("Холодная, кружащаяся пустота окутывает [nearby_mob.declent_ru(ACCUSATIVE)]!"),
				span_userdanger("Перед вами разверзается зияющая пустота! Тьма поглощает вас, и вы оказываетесь в полном небытии..."),
			)
			nearby_mob.apply_status_effect(/datum/status_effect/void_prison)

	else if(user.can_block_magic(MAGIC_RESISTANCE))
		to_chat(user, span_hypnophrase("Вы разбиваете [declent_ru(ACCUSATIVE)], но её сила начинает окутывать вас самих!"))
		user.visible_message(
			span_danger("Холодная, кружащаяся пустота окутывает [user.declent_ru(ACCUSATIVE)], но [GEND_HE_SHE(user)] вырыва[PLUR_ET_YUT(user)]ся на свободу!"),
			span_userdanger("Перед вами разверзается зияющая пустота, но мощная волна жара разносит её вдребезги! Вы защищены!")
		)

	else
		to_chat(user, span_hypnophrase("Вы разбиваете [declent_ru(ACCUSATIVE)], но её сила начинает окутывать вас самих!"))
		user.visible_message(
			span_danger("Холодная, кружащаяся пустота окутывает [user.declent_ru(ACCUSATIVE)]!"),
			span_userdanger("Перед вами разверзается зияющая пустота! Тьма поглощает вас, и вы оказываетесь в полном небытии..."),
		)
		user.apply_status_effect(/datum/status_effect/void_prison)

	qdel(src)
	return TRUE


/datum/status_effect/void_prison
	id = "void_prison"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/void_prison
	///The overlay that gets applied to whoever has this status active
	var/obj/effect/abstract/voidball/stasis_overlay


/datum/status_effect/void_prison/on_creation(mob/living/new_owner)
	. = ..()
	stasis_overlay = new /obj/effect/abstract/voidball(new_owner)
	RegisterSignal(stasis_overlay, COMSIG_QDELETING, PROC_REF(clear_overlay))
	new_owner.vis_contents += stasis_overlay
	stasis_overlay.animate_opening()
	addtimer(CALLBACK(src, PROC_REF(enter_prison), new_owner), 1 SECONDS)


/datum/status_effect/void_prison/on_remove()
	if(!isheretic(owner))
		owner.apply_status_effect(/datum/status_effect/void_chill, 1) // 1 stack on release

	if(!stasis_overlay)
		return ..()

	owner.remove_traits(list(TRAIT_GODMODE, TRAIT_NO_TRANSFORM, TRAIT_SOFTSPOKEN), TRAIT_STATUS_EFFECT(id))
	owner.forceMove(get_turf(stasis_overlay))
	stasis_overlay.forceMove(owner)
	owner.vis_contents += stasis_overlay
	stasis_overlay.animate_closing()
	stasis_overlay.icon_state = "voidball_closed"
	QDEL_IN(stasis_overlay, 1.1 SECONDS)
	stasis_overlay = null
	return ..()


///Freezes our prisoner in place
/datum/status_effect/void_prison/proc/enter_prison(mob/living/prisoner)
	stasis_overlay.forceMove(prisoner.loc)
	prisoner.forceMove(stasis_overlay)
	prisoner.add_traits(list(TRAIT_GODMODE, TRAIT_NO_TRANSFORM, TRAIT_SOFTSPOKEN), TRAIT_STATUS_EFFECT(id))


///Makes sure to clear the ref in case the voidball ever suddenly disappears
/datum/status_effect/void_prison/proc/clear_overlay()
	SIGNAL_HANDLER
	stasis_overlay = null


/obj/effect/abstract/voidball
	icon = 'icons/mob/actions/actions_ecult.dmi'
	icon_state = "voidball_effect"
	layer = ABOVE_ALL_MOB_LAYER
	invisibility = INVISIBILITY_NONE
	vis_flags = VIS_INHERIT_ID


///Plays a opening animation
/obj/effect/abstract/voidball/proc/animate_opening()
	flick("voidball_opening", src)


///Plays a closing animation
/obj/effect/abstract/voidball/proc/animate_closing()
	flick("voidball_closing", src)


/atom/movable/screen/alert/status_effect/void_prison
	name = "Пустотная Тюрьма"
	desc = "Зияющая пустота окутывает вас." //Go straight to jail, do not pass GO, do not collect 200$
	icon = 'icons/mob/actions/actions_ecult.dmi'
	icon_state = "voidball_effect"
