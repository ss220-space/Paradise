/obj/effect/proc_holder/spell/shadow_cloak
	name = "Плащ Тьмы"
	desc = "Полностью скрывает вашу личность, но не делает вас невидимым. Можно активировать снова, чтобы отключить эффект. \
			При использовании вы двигаетесь быстрее, но совершаете действия медленнее. \
			Получение урона при надетом плаще может привести к его внезапному отключению."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "ninja_cloak"
	sound = 'sound/effects/curse/curse2.ogg'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 6 SECONDS
	spell_requirements = NONE

	/// How long before we automatically uncloak? Kept in sync with /datum/status_effect/shadow_cloak's duration.
	var/uncloak_time = 3 MINUTES
	/// The cloak currently active
	var/datum/status_effect/shadow_cloak/active_cloak


/obj/effect/proc_holder/spell/shadow_cloak/on_spell_loss(mob/living/remove_from)
	if(!active_cloak)
		return ..()

	uncloak_mob(remove_from, show_message = FALSE)
	return ..()


/obj/effect/proc_holder/spell/shadow_cloak/valid_target(atom/cast_on)
	if(!HAS_TRAIT(cast_on, TRAIT_HULK)) // Hulks are not stealthy. Need not apply
		return isliving(cast_on)

	cast_on.balloon_alert(cast_on, "вы халк!")
	return FALSE


/obj/effect/proc_holder/spell/shadow_cloak/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	var/datum/antagonist/heretic/heretic_datum = cast_on.mind?.has_antag_datum(/datum/antagonist/heretic)
	if(heretic_datum && heretic_datum.has_living_heart() != HERETIC_HAS_LIVING_HEART)
		to_chat(cast_on, span_hypnophrase("Вам нужно Живое Сердце, чтобы применить \"[name]\"!"))
		return . | SPELL_CANCEL_CAST

	sound = pick(
		'sound/effects/curse/curse1.ogg',
		'sound/effects/curse/curse2.ogg',
		'sound/effects/curse/curse3.ogg',
		'sound/effects/curse/curse4.ogg',
		'sound/effects/curse/curse5.ogg',
		'sound/effects/curse/curse6.ogg',
	)
	return . | SPELL_NO_IMMEDIATE_COOLDOWN


/obj/effect/proc_holder/spell/shadow_cloak/cast(list/targets, mob/user = usr)
	. = ..()
	var/mob/living/cast_on = targets[1]
	if(active_cloak)
		var/time_left = max(active_cloak.duration - world.time, 0)
		var/time_elapsed = uncloak_time - time_left
		var/new_cd = max(time_elapsed / 3, base_cooldown)
		uncloak_mob(cast_on)
		cooldown_handler.start_recharge(new_cd)
		return

	cloak_mob(cast_on)
	cooldown_handler.start_recharge()


/obj/effect/proc_holder/spell/shadow_cloak/proc/cloak_mob(mob/living/cast_on)
	playsound(cast_on, 'sound/effects/ahaha.ogg', 50, TRUE, -1, extrarange = SILENCED_SOUND_EXTRARANGE, frequency = 0.5)
	cast_on.visible_message(
		span_warning("[DECLENT_RU_CAP(cast_on, NOMINATIVE)] скрывается в тени!"),
		span_notice("Вы скрываетесь в тени."),
	)

	active_cloak = cast_on.apply_status_effect(/datum/status_effect/shadow_cloak)
	RegisterSignal(active_cloak, COMSIG_QDELETING, PROC_REF(on_early_cloak_loss))
	RegisterSignal(cast_on, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_lost))


/obj/effect/proc_holder/spell/shadow_cloak/proc/uncloak_mob(mob/living/cast_on, show_message = TRUE)
	if(!QDELETED(active_cloak))
		UnregisterSignal(active_cloak, COMSIG_QDELETING)
		qdel(active_cloak)

	active_cloak = null
	UnregisterSignal(cast_on, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING))
	playsound(cast_on, 'sound/effects/curse/curseattack.ogg', 50)
	if(show_message)
		cast_on.visible_message(
			span_warning("[DECLENT_RU_CAP(cast_on, NOMINATIVE)] появляется из тени!"),
			span_notice("Вы появляетесь из тени!"),
		)


/// Signal proc for [COMSIG_QDELETING]. Fires when the cloak status ends without the spell removing it
/// itself (i.e. natural duration timeout, or a forced break from damage/crit). Only the forced breaks
/// impart the reveal penalty - a natural timeout just uncloaks cleanly.
/obj/effect/proc_holder/spell/shadow_cloak/proc/on_early_cloak_loss(datum/status_effect/shadow_cloak/source)
	SIGNAL_HANDLER

	var/mob/living/removed = source.owner
	var/penalize = source.forced_removal
	uncloak_mob(removed, show_message = !penalize)
	if(!penalize)
		return // Natural expiry - the cloak simply ran out, no penalty.

	removed.visible_message(
		span_warning("[DECLENT_RU_CAP(removed, NOMINATIVE)] появляется из тени!"),
		span_userdanger("Вас вытащили из тени!"),
	)

	removed.Knockdown(0.5 SECONDS)
	removed.add_movespeed_modifier(/datum/movespeed_modifier/shadow_cloak/early_remove)
	addtimer(CALLBACK(removed, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/shadow_cloak/early_remove), 2 MINUTES, TIMER_UNIQUE|TIMER_OVERRIDE)
	cooldown_handler.start_recharge(uncloak_time * 2/3)


/// Signal proc for [SIGNAL_REMOVETRAIT] via [TRAIT_ALLOW_HERETIC_CASTING], losing our focus midcast will throw us out.
/obj/effect/proc_holder/spell/shadow_cloak/proc/on_focus_lost(mob/living/source)
	SIGNAL_HANDLER

	uncloak_mob(source, show_message = FALSE)
	source.visible_message(
		span_warning("[DECLENT_RU_CAP(source, NOMINATIVE)] внезапно появляется из тени!"),
		span_userdanger("После потери концентрации, вы больше не можете скрываться в тени!"),
	)
	cooldown_handler.start_recharge(uncloak_time / 3)


/// Shadow cloak effect. Conceals the owner in a cloud of purple smoke, making them unidentifiable.
/// Also comes with some other buffs and debuffs - faster movespeed, slower actionspeed, etc.
/datum/status_effect/shadow_cloak
	id = "shadow_cloak"
	alert_type = null
	duration = 3 MINUTES
	tick_interval = -1
	/// How much damage we've been hit with
	var/damage_sustained = 0
	/// How much damage we can be hit with before it starts rolling reveal chances
	var/damage_before_reveal = 25
	/// Set TRUE when the cloak is broken early (damage / crit) so the spell knows to apply the reveal penalty.
	var/forced_removal = FALSE
	/// The image we place over the owner
	var/image/cloak_image


/datum/status_effect/shadow_cloak/on_apply()
	cloak_image = image('icons/effects/effects.dmi', owner, "curse", dir = owner.dir)
	cloak_image.override = TRUE
	cloak_image.alpha = 0
	animate(cloak_image, alpha = 255, 0.2 SECONDS)
	owner.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, id, cloak_image)
	owner.add_traits(list(TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE, TRAIT_SILENT_FOOTSTEPS, TRAIT_NO_SNOWPRINTS), TRAIT_STATUS_EFFECT(id))
	if(ishuman(owner))
		owner.name = owner.get_visible_name()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/shadow_cloak)
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/shadow_cloak)
	RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_body_position_change))
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	return TRUE


/datum/status_effect/shadow_cloak/on_remove()
	owner.remove_alt_appearance(id)
	QDEL_NULL(cloak_image)
	owner.remove_traits(list(TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE, TRAIT_SILENT_FOOTSTEPS, TRAIT_NO_SNOWPRINTS), TRAIT_STATUS_EFFECT(id))
	if(ishuman(owner))
		owner.name = owner.get_visible_name()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/shadow_cloak)
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/shadow_cloak)
	UnregisterSignal(owner, list(
		COMSIG_ATOM_DIR_CHANGE,
		COMSIG_LIVING_SET_BODY_POSITION,
		COMSIG_MOB_STATCHANGE,
		COMSIG_MOB_APPLY_DAMAGE,
		COMSIG_MOVABLE_MOVED,
	))


/// Signal proc for [COMSIG_ATOM_DIR_CHANGE], handles turning the effect as we turn
/datum/status_effect/shadow_cloak/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	cloak_image.dir = new_dir


/// Signal proc for [COMSIG_LIVING_SET_BODY_POSITION], handles rotating the effect when we're downed
/datum/status_effect/shadow_cloak/proc/on_body_position_change(datum/source, new_value, old_value)
	SIGNAL_HANDLER

	if(new_value == LYING_DOWN)
		cloak_image.transform = turn(cloak_image.transform, 90)
	else
		cloak_image.transform = turn(cloak_image.transform, -90)


/// Signal proc for [COMSIG_MOB_STATCHANGE], going past soft crit will stop the effect
/datum/status_effect/shadow_cloak/proc/on_stat_change(datum/source, new_stat, old_stat)
	SIGNAL_HANDLER

	if(new_stat >= UNCONSCIOUS)
		forced_removal = TRUE
		qdel(src)


/// Signal proc for [COMSIG_MOB_APPLY_DAMAGE], being damaged past a threshold will roll a chance to stop the effect
/datum/status_effect/shadow_cloak/proc/on_damaged(datum/source, damage, damagetype, ...)
	SIGNAL_HANDLER

	if(damagetype == STAMINA)
		damage *= 0.5

	damage_sustained += damage
	if(damage_sustained < damage_before_reveal)
		return

	if(prob(damage_sustained))
		forced_removal = TRUE
		qdel(src)


/// Signal proc for [COMSIG_MOVABLE_MOVED], leaves a cool looking trail behind us as we walk
/datum/status_effect/shadow_cloak/proc/on_move(datum/source, old_loc, movement_dir)
	SIGNAL_HANDLER

	if(owner.loc == old_loc)
		return

	var/obj/effect/temp_visual/dir_setting/cloak_walk/trail = new (old_loc, movement_dir)
	if(owner.body_position == LYING_DOWN)
		trail.transform = turn(trail.transform, 90)


/obj/effect/temp_visual/dir_setting/cloak_walk
	duration = 0.75 SECONDS
	icon_state = "curse"


/obj/effect/temp_visual/dir_setting/cloak_walk/Initialize(mapload, set_dir)
	. = ..()
	animate(src, alpha = 0, time = duration - 1)


/datum/movespeed_modifier/shadow_cloak
	blacklisted_movetypes = FLYING
	multiplicative_slowdown = -0.4


/datum/movespeed_modifier/shadow_cloak/early_remove
	multiplicative_slowdown = 0.5


/datum/actionspeed_modifier/shadow_cloak
	multiplicative_slowdown = 3
