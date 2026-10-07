/datum/action/cooldown/spell/jaunt/infernal_jaunt
	name = "Адский Скачок"
	desc = "Используйте адское пламя, чтобы выйти за границу материального мира."

	cooldown_time = 20 SECONDS
	jaunt_type = /obj/effect/dummy/phased_mob/blood
	button_icon_state = "jaunt"
	background_icon_state = "bg_demon"

/datum/action/cooldown/spell/jaunt/infernal_jaunt/can_cast_spell(feedback)
	if(!..())
		return FALSE
	if(!(is_jaunting(owner)))
		return TRUE
	if(is_area_shuttle(get_area(owner))) // Can always phase in in a shuttle.
		return TRUE
	for(var/mob/living/C in orange(2, get_turf(owner.loc))) //Can also phase in when nearby a potential buyer.
		if(C.mind && C.mind.soulOwner == C.mind)
			return TRUE
	if(feedback)
		to_chat(owner, span_warning("Вы можете материализоваться только на шаттле или рядом с тем, кто сможет подписать контракт."))
	return FALSE

/datum/action/cooldown/spell/jaunt/infernal_jaunt/cast(atom/cast_on)
	. = ..()
	if(!is_jaunting(cast_on))
		enter_jaunt(cast_on)
		return
	exit_jaunt(cast_on)

/datum/action/cooldown/spell/jaunt/infernal_jaunt/enter_jaunt(mob/living/jaunter, turf/loc_override)
	jaunter.fakefire()
	if(do_after(jaunter, 10 SECONDS, jaunter, NONE))
		jaunter.infernalphaseout()
		var/obj/effect/dummy/phased_mob/blood/jaunt = ..()
		jaunter.forceMove(jaunt)
	else
		to_chat(jaunter, span_warning("Вы должны оставаться неподвижным во время возвращения."))
		jaunter.ExtinguishMob()
		jaunter.fakefireextinguish()

/datum/action/cooldown/spell/jaunt/infernal_jaunt/exit_jaunt(mob/living/unjaunter, turf/loc_override)
	if(!do_after(unjaunter, 10 SECONDS, unjaunter.loc, NONE))
		return
	unjaunter.infernalphasein()
	return ..()

/mob/living/proc/infernalphaseout()
	dust_animation()
	visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] исчезает в огненной вспышке!"))
	playsound(get_turf(src), 'sound/misc/enter_blood.ogg', 100, TRUE, -1)
	ExtinguishMob()


/mob/living/proc/infernalphasein()
	fakefire()
	visible_message(span_warning("<b>[DECLENT_RU_CAP(src, NOMINATIVE)] появляется в огненной вспышке!</b>"))
	playsound(get_turf(src), 'sound/misc/exit_blood.ogg', 100, TRUE, -1)
	addtimer(CALLBACK(src, PROC_REF(fakefireextinguish), TRUE), 1.5 SECONDS)
