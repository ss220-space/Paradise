
/datum/action/cooldown/spell/pointed/sword_fling
	name = "Метание Меча"
	desc = "Попробуйте метнуть себя куда-нибудь."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_cult_border"

	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "sword_fling"

	cooldown_time = 4 SECONDS
	spell_requirements = NONE

	cast_range = 6
	active_msg = "Вы готовы попытаться прыгнуть!"
	var/obj/item/melee/cultblade/haunted/flinged_sword


/datum/action/cooldown/spell/pointed/sword_fling/Destroy()
	flinged_sword = null
	. = ..()


/datum/action/cooldown/spell/pointed/sword_fling/can_cast_spell(feedback = TRUE)
	if(flinged_sword?.bound)
		return FALSE

	return ..()


/datum/action/cooldown/spell/pointed/sword_fling/cast(atom/cast_on)
	. = ..()
	var/turf/target_turf = get_turf(cast_on)
	var/atom/sword_loc = flinged_sword.loc
	if(ismob(sword_loc))
		var/mob/loccer = sword_loc
		var/resist_chance = 20
		var/fail_text = "Вы боретесь, но [loccer.declent_ru(NOMINATIVE)] держит вас под контролем!"
		var/particle_to_spawn = null
		if(iscultist(loccer))
			resist_chance = 5 // your mastahs
			fail_text = "Вы боретесь, но [loccer.declent_ru(NOMINATIVE)] без труда держит вас под контролем!"
			particle_to_spawn = /obj/effect/temp_visual/cult/sparks

		if(IS_HERETIC_OR_MONSTER(loccer) || IS_LUNATIC(loccer))
			resist_chance = 10
			fail_text = "Вы боретесь, но [loccer.declent_ru(NOMINATIVE)] практически без труда держит вас под контролем!"
			particle_to_spawn = /obj/effect/temp_visual/eldritch_sparks

		if(loccer.mind?.isholy) // IS_PRIEST()
			resist_chance = 6
			fail_text = "Вы боретесь, но [loccer.declent_ru(NOMINATIVE)] благодаря своей святости удерживает вас под контролем!"
			particle_to_spawn = /obj/effect/temp_visual/blessed

		if(iswizard(loccer))
			resist_chance = 3 // magic master
			fail_text = "Вы боретесь, но [loccer.declent_ru(NOMINATIVE)] благодаря своей магии легко удерживает вас под контролем!"
			particle_to_spawn = /obj/effect/particle_effect/sparks/electricity

		new particle_to_spawn(get_turf(loccer))
		loccer.Shake()
		playsound(loccer, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

		if(!prob(resist_chance))
			to_chat(owner, span_warning(fail_text))
			return

		flinged_sword.forceMove(get_turf(loccer))
		flinged_sword.visible_message(span_alert("[DECLENT_RU_CAP(flinged_sword, NOMINATIVE)] вырывается из хватки [loccer.declent_ru(GENITIVE)]!"))

	if(isitem(sword_loc))
		flinged_sword.forceMove(get_turf(sword_loc))
		flinged_sword.visible_message(span_alert("[DECLENT_RU_CAP(flinged_sword, NOMINATIVE)] вырывается из [sword_loc.declent_ru(GENITIVE)]!"))

	if(iscloset(sword_loc))
		var/obj/structure/closet/sword_closet = sword_loc
		if(!(sword_closet.open()))
			sword_closet.container_resist_act(owner)

		flinged_sword.visible_message(span_alert("[DECLENT_RU_CAP(flinged_sword, NOMINATIVE)] вырывается из [sword_closet.declent_ru(GENITIVE)]!"))


	if(!isturf(sword_loc))
		return

	new /obj/effect/temp_visual/sword_sparks(sword_loc)
	flinged_sword.throw_at(target_turf, cast_range, flinged_sword.throw_speed, owner)
	flinged_sword.visible_message(\
		span_warning("[DECLENT_RU_CAP(flinged_sword, NOMINATIVE)] бросается на [target_turf.declent_ru(ACCUSATIVE)]!"))
	playsound(flinged_sword, 'sound/items/haunted/ghostitemattack.ogg', 100, TRUE)
	flinged_sword.add_filter("cool_glow", 2, list("type" = "outline", "color" = COLOR_HERETIC_GREEN, "size" = 0.7))
	addtimer(CALLBACK(flinged_sword, TYPE_PROC_REF(/datum, remove_filter), "cool_glow"), 0.7 SECONDS)


/obj/effect/temp_visual/eldritch_sparks
	icon_state = "purplesparkles"


/obj/effect/temp_visual/sword_sparks
	icon_state = "mech_toxin" // only used in one place and it looks kinda good


/obj/effect/temp_visual/blessed
	icon_state = "blessed"


/obj/effect/particle_effect/sparks/electricity
	name = "lightning"
	icon_state = "electricity"
