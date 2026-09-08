/*
//////////////////////////////////////

Limb Rejection

//////////////////////////////////////
*/

/datum/symptom/limb_throw

	name = "Отстреливание конечностей"
	id = "limb_throw"
	stealth = -4
	resistance = -5
	stage_speed = 3
	transmittable = -3
	level = 5
	severity = 4
	var/spell_learned = FALSE

/datum/symptom/limb_throw/Activate(datum/disease/virus/advance/A)
	if(!spell_learned && A.stage >= 4)
		A.affected_mob.AddSpell(new /datum/action/cooldown/spell/pointed/limb_throw)
		spell_learned = TRUE
	return

/datum/symptom/limb_throw/End(datum/disease/virus/advance/A)
	A.affected_mob.RemoveSpell(/datum/action/cooldown/spell/pointed/limb_throw)
	spell_learned = FALSE
	return

/datum/action/cooldown/spell/pointed/limb_throw
	name = "Отстреливание конечностей"
	desc = "Метните выбранную конечность как снаряд."
	spell_requirements = NONE
	invocation = ""
	active_msg = span_notice_alt("Вы готовитесь бросить конечность!! <b>ЛКМ, чтобы бросить в цель!</b>")
	deactive_msg = span_notice_alt("Вы решили не бросать конечность... пока что.")
	background_icon_state = "bg_changeling"
	button_icon_state = "limb_throw"
	background_icon_state_active = "bg_changeling"
	cooldown_time = 5 SECONDS

/datum/action/cooldown/spell/pointed/limb_throw/cast(atom/cast_on)
	. = ..()
	var/target = cast_on
	var/turf/T = owner.loc
	var/turf/U = get_step(owner, owner.dir)
	if(!isturf(U) || !isturf(T))
		return

	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return

	var/obj/item/organ/external/limb = H.bodyparts_by_name[H.zone_selected]
	if(!istype(limb))
		to_chat(H, span_alert("У вас нет выбранной части тела!"))
		reset_spell_cooldown()
		return

	if(limb.vital)
		to_chat(H, span_alert("Вам всё ещё нужна [limb.declent_ru(NOMINATIVE)]!"))
		reset_spell_cooldown()
		return

	for(var/obj/item/organ/internal/organ as anything in limb.internal_organs)
		if(organ.vital)
			to_chat(H, span_alert("Вам всё ещё нужен [organ.declent_ru(NOMINATIVE)]!"))
			reset_spell_cooldown()
			return

	var/obj/projectile/limb/limb_projectile = new(owner.loc, limb)
	limb_projectile.current = get_turf(owner)
	var/turf/target_turf = get_turf(target)
	limb_projectile.preparePixelProjectile(target, owner)
	limb_projectile.firer = owner
	limb_projectile.fire()
	playsound(get_turf(usr), 'sound/effects/splat.ogg', 50, TRUE)

	limb.droplimb()
	qdel(limb)
	H.emote("scream")

	owner.newtonian_move(get_dir(target_turf, T))

	return TRUE
