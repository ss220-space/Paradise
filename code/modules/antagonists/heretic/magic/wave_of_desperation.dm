/obj/effect/proc_holder/spell/aoe/wave_of_desperation
	name = "Волна отчаяния"
	desc = "Развязывает вас, отталкивает и сбивает с ног находящихся рядом людей, а также накладывает определённые эффекты Прикосновения Мансуса на всё вокруг. \
			Нельзя применить, если вы не ограничены, а стресс лишает вас сознания через 12 секунд!"
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "uncuff"
	sound = 'sound/magic/swap.ogg'

	// EVOCATION, not FORBIDDEN: this is the break-free panic button used while cuffed/stripped, so it must
	// NOT go through the heretic focus gate (on_spell_cast cancels SCHOOL_FORBIDDEN casts with "нужен амулет"
	// unless you hold your amulet — which you won't when arrested). Matches TG (school = SCHOOL_EVOCATION).
	school = SCHOOL_EVOCATION
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 5 MINUTES

	invocation = "'ТЪ'Б'СЬ"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	aoe_range = 3


/obj/effect/proc_holder/spell/aoe/wave_of_desperation/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/aoe/wave_of_desperation/valid_target(mob/living/carbon/cast_on)
	return istype(cast_on) && (cast_on.handcuffed || cast_on.legcuffed)


// IMPORTANT: param MUST be named `show_message` (not `feedback`) — master220's IsAvailable calls
// `spell.can_cast(owner, show_message = feedback)` by NAME; a mismatched name breaks availability and
// leaves the button permanently RED/unclickable (same can_cast-signature bug class as sessions 4d/4f).
/obj/effect/proc_holder/spell/aoe/wave_of_desperation/can_cast(mob/user, charge_check, show_message)
	var/mob/living/carbon/human/human = action.owner
	if(!istype(human) || !..())
		return FALSE
	// NOTE: the "must be restrained" gate lives in cast_check(), NOT here — TG keeps the button available
	// (green) and only refuses the actual cast. Gating availability would colour the button red at all times
	// you're not cuffed, which is exactly the "красная и нельзя прожать" complaint.
	return TRUE


// The whole point of the spell is to break free, so it can ONLY be cast while restrained (matches TG's
// is_valid_target). We gate here, BEFORE ..() spends the cooldown, so clicking while uncuffed just warns
// and never wastes the 5-minute cooldown. (Self-targeting bypasses valid_target, so this is the real gate.)
/obj/effect/proc_holder/spell/aoe/wave_of_desperation/cast_check(charge_check = TRUE, start_recharge = TRUE, mob/user = usr)
	var/mob/living/carbon/human/human = user
	if(!istype(human) || (!human.handcuffed && !human.legcuffed))
		to_chat(user, span_warning("«[name]» можно применить, только будучи скованным!"))
		return FALSE
	return ..()


// Before the cast, we do some small AOE damage around the caster
/obj/effect/proc_holder/spell/aoe/wave_of_desperation/before_cast(list/targets, mob/user = usr)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(!iscarbon(action.owner))
		return SPELL_CANCEL_CAST

	var/mob/living/carbon/human/human = action.owner
	if(human.handcuffed)
		human.visible_message(span_danger("[human.handcuffed.declent_ru(NOMINATIVE)] котор[genderize_ru(human.handcuffed.gender, "ый", "ое", "ую", "ые")] нос[pluralize_ru(human.gender, "ит", "ят")] [human.declent_ru(NOMINATIVE)] рассыпа[pluralize_ru(human.handcuffed.gender, "ет", "ют")]ся на множество осколков!"))
		QDEL_NULL(human.handcuffed)

	if(human.legcuffed)
		human.visible_message(span_danger("[human.legcuffed.declent_ru(NOMINATIVE)] котор[genderize_ru(human.legcuffed.gender, "ый", "ое", "ую", "ые")] нос[pluralize_ru(human.gender, "ит", "ят")] [human.declent_ru(NOMINATIVE)] рассыпа[pluralize_ru(human.handcuffed.gender, "ет", "ют")]ся на множество осколков!"))
		human.visible_message(span_danger("[human.legcuffed] on [human] shatters!"))
		QDEL_NULL(human.legcuffed)

	human.apply_status_effect(/datum/status_effect/heretic_lastresort)
	new /obj/effect/temp_visual/knockblast(get_turf(human))

	for(var/mob/living/victim in get_things_to_cast_on(human, radius_override = 1))
		victim.AdjustKnockdown(3 SECONDS)
		victim.AdjustParalysis(0.5 SECONDS)


/obj/effect/proc_holder/spell/aoe/wave_of_desperation/get_things_to_cast_on(atom/center, radius_override)
	. = list()
	for(var/atom/nearby in orange(center, radius_override ? radius_override : aoe_range))
		if(nearby == action.owner || nearby == center || isarea(nearby))
			continue

		if(!ismob(nearby))
			. += nearby
			continue

		var/mob/living/nearby_mob = nearby
		if(!isturf(nearby_mob.loc))
			continue

		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue

		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		. += nearby_mob


// Param MUST be named `user` (not `caster`): perform() calls `cast(targets, user = user)` BY NAME, so a
// differently-named param doesn't bind and silently falls back to usr (same cast-signature rule as 4f).
/obj/effect/proc_holder/spell/aoe/wave_of_desperation/cast(list/targets, mob/user = usr)
	// `targets` is just the caster (self-targeting), so do the real AOE pass here: shove everything around
	// the caster away and apply a secondary Mansus Grasp to non-mobs. Matches TG's cast_on_thing_in_aoe loop.
	// get_things_to_cast_on already excludes the caster and other heretics/monsters, so we never throw ourselves.
	var/our_turf = get_turf(user)
	for(var/atom/movable/mover in get_things_to_cast_on(user, radius_override = aoe_range))
		if(!ismob(mover))
			SEND_SIGNAL(action.owner, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, mover)

		if(mover.anchored)
			continue

		var/throwtarget = get_edge_target_turf(our_turf, get_dir(our_turf, get_step_away(mover, our_turf)))
		mover.throw_at(throwtarget, 3, 1, force = MOVE_FORCE_STRONG)


/obj/effect/temp_visual/knockblast
	icon = 'icons/effects/effects.dmi' // base temp_visual sets no icon file → without this the flash is invisible
	icon_state = "shield-flash"
	alpha = 180
