
/datum/status_effect/crucible_soul
	id = "Blessing of Crucible Soul"
	status_type = STATUS_EFFECT_REFRESH
	duration = 40 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/crucible_soul
	show_duration = TRUE
	///Stores the location where the mob drank the potion, used to teleport the drinker back to the spot after expiration
	var/turf/location
	var/datum/action/cancel_crucible_soul/cancel_button


/datum/status_effect/crucible_soul/on_apply()
	to_chat(owner,span_notice("Вы перемещаетесь игнорируя окружающую реальность. Вам кажется, что нет ничего невозможного!"))
	owner.alpha = 180
	owner.pass_flags |= PASSEVERYTHING
	location = get_turf(owner)
	cancel_button = new(src)
	cancel_button.Grant(owner)
	return TRUE


/datum/status_effect/crucible_soul/on_remove()
	to_chat(owner,span_notice("Вы восстанавливаете свою физическую форму и возвращаетесь в свое изначальное местоположение..."))
	owner.alpha = initial(owner.alpha)
	owner.pass_flags &= ~PASSEVERYTHING
	owner.forceMove(location)
	location = null
	cancel_button.Remove(owner)
	cancel_button = null
	owner.apply_status_effect(/datum/status_effect/crucible_soul_cooldown)


/datum/status_effect/crucible_soul_cooldown
	id = "Crucible Soul Cooldown"
	duration = 2 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/crucible_soul_cooldown
	show_duration = TRUE


/datum/status_effect/crucible_soul/get_examine_text()
	return span_notice("Не похоже, что [GEND_HE_SHE(owner)] действительно здесь наход[PLUR_IT_YAT(owner)]ся.")


/datum/action/cancel_crucible_soul
	name = "Вернуться"
	desc = "Используйте, чтобы закончить эффект дарованного Обителью благословения раньше времени."
	button_icon = 'icons/obj/eldritch.dmi'
	button_icon_state = "crucible_soul"


/datum/action/cancel_crucible_soul/Grant(mob/user)
	. = ..()
	UpdateButtonIcon()

/datum/action/cancel_crucible_soul/Trigger(left_click = TRUE, trigger_flags)
	. = ..()
	if(!.)
		return

	var/datum/status_effect/active_effect = owner.has_status_effect(/datum/status_effect/crucible_soul)
	target = active_effect
	qdel(target)


/datum/status_effect/duskndawn
	id = "Blessing of Dusk and Dawn"
	status_type = STATUS_EFFECT_REFRESH
	duration = 90 SECONDS
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/duskndawn


/datum/status_effect/duskndawn/on_apply()
	ADD_TRAIT(owner, TRAIT_XRAY, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()
	return TRUE


/datum/status_effect/duskndawn/on_remove()
	REMOVE_TRAIT(owner, TRAIT_XRAY, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()


/datum/status_effect/temporary_xray
	id = "temp_xray"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	duration = 10 SECONDS


/datum/status_effect/temporary_xray/on_apply()
	ADD_TRAIT(owner, TRAIT_XRAY, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()
	return TRUE


/datum/status_effect/temporary_xray/on_remove()
	REMOVE_TRAIT(owner, TRAIT_XRAY, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()


/// Heretic subtype - plays a whisper and shows a screen alert with a countdown timer.
/datum/status_effect/temporary_xray/eldritch
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_sight
	show_duration = TRUE


/datum/status_effect/temporary_xray/eldritch/on_apply()
	. = ..()
	SEND_SOUND(owner, sound('sound/hallucinations/i_see_you1.ogg'))


#define MARSHAL_PASSIVE_HEAL 0.5
#define MARSHAL_WOUND_HEAL 3
#define MARSHAL_BLOOD_PER_HEAL 3

/datum/status_effect/marshal
	id = "Blessing of Wounded Soldier"
	status_type = STATUS_EFFECT_REFRESH
	duration = 60 SECONDS
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/marshal


/datum/status_effect/marshal/on_apply()
	owner.add_movespeed_mod_immunities(id, /datum/movespeed_modifier/damage_slowdown)
	return TRUE


/datum/status_effect/marshal/on_remove()
	owner.remove_movespeed_mod_immunities(id, /datum/movespeed_modifier/damage_slowdown)
	if(!iscarbon(owner))
		return

	var/mob/living/carbon/human/drinker = owner
	for(var/obj/item/organ/external/potentially_wounded as anything in drinker.bodyparts)
		potentially_wounded.mend_fracture()
		potentially_wounded.stop_internal_bleeding()

	var/list/missing_bodyparts = list()
	for(var/limb_zone in drinker.dna.species.has_limbs)
		if(!isnull(drinker.bodyparts_by_name[limb_zone]))
			continue

		missing_bodyparts += limb_zone

	if(!length(missing_bodyparts))
		playsound(drinker, 'sound/effects/ahaha.ogg', 50, TRUE, -1, extrarange = SILENCED_SOUND_EXTRARANGE, frequency = 0.5)
		return

	drinker.dna.species.create_organs(drinker, missing_bodyparts)
	to_chat(drinker, span_purple("Обитель возвращает вам [missing_bodyparts.len == 1 ? "утерянную конечность" : "утерянные конечности"]."))
	playsound(drinker, 'sound/effects/ahaha.ogg', 50, TRUE, -1, extrarange = SILENCED_SOUND_EXTRARANGE, frequency = 0.5)


/datum/status_effect/marshal/tick(seconds_between_ticks)
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/carbie = owner
	if(!carbie.getBruteLoss() && !carbie.getFireLoss() && carbie.blood_volume >= BLOOD_VOLUME_NORMAL)
		return

	var/wound_heal = 0
	for(var/obj/item/organ/external/part as anything in carbie.bodyparts)
		if(isroboticorgan(part))
			continue

		if(part.has_fracture())
			wound_heal += MARSHAL_WOUND_HEAL

		if(part.has_internal_bleeding())
			wound_heal += MARSHAL_WOUND_HEAL

	carbie.heal_overall_damage((MARSHAL_PASSIVE_HEAL + wound_heal) * seconds_between_ticks, MARSHAL_PASSIVE_HEAL * seconds_between_ticks)

	if(wound_heal && carbie.blood_volume < BLOOD_VOLUME_NORMAL)
		var/blood_to_restore = wound_heal * MARSHAL_BLOOD_PER_HEAL * seconds_between_ticks
		carbie.AdjustBlood(min(blood_to_restore, BLOOD_VOLUME_NORMAL - carbie.blood_volume))

#undef MARSHAL_PASSIVE_HEAL
#undef MARSHAL_WOUND_HEAL
#undef MARSHAL_BLOOD_PER_HEAL


/atom/movable/screen/alert/status_effect/crucible_soul
	name = "Благословение Измученной Души"
	desc = "Вы прошли сквозь ткань реальности. Вы на полпути к конечному пункту назначения..."
	icon_state = "crucible"


/atom/movable/screen/alert/status_effect/crucible_soul_cooldown
	name = "Истощение Измученной Души"
	desc = "Вы недавно прошли сквозь ткань реальности. Придётся подождать, прежде чем сделать это снова."
	icon_state = "crucible_cooldown"


/atom/movable/screen/alert/status_effect/duskndawn
	name = "Благословение Заката и Рассвета"
	desc = "Многое скрыто за горизонтом. С помощью Совы мне удалось проскользнуть мимо стражи Солнца и часового Луны."
	icon_state = "duskndawn"


/atom/movable/screen/alert/status_effect/eldritch_sight
	name = "Око Иной Стороны"
	desc = "Вы мельком видите нечто сокрытое за гранью реальности..."
	icon_state = "influence"


/atom/movable/screen/alert/status_effect/marshal
	name = "Благословение Раненого Солдата"
	desc = "Некоторые люди ищут силу через искупление. Многие люди не знают, что битва \
			— это окончательное искупление, а раны позволяют вам наслаждаться вечной славой."
	icon_state = "wounded_soldier"


/// Summons multiple foating knives around the owner.
/// Each knife will block an attack straight up.
/datum/status_effect/protective_blades
	id = "Silver Knives"
	alert_type = null
	status_type = STATUS_EFFECT_MULTIPLE
	tick_interval = -1
	/// The number of blades we summon up to.
	var/max_num_blades = 4
	/// The radius of the blade's orbit.
	var/blade_orbit_radius = 20
	/// The time between spawning blades.
	var/time_between_initial_blades = 0.25 SECONDS
	/// If TRUE, we self-delete our status effect after all the blades are deleted.
	var/delete_on_blades_gone = TRUE
	/// What blade type to create
	var/obj/effect/floating_blade/blade_type
	/// A list of blade effects orbiting / protecting our owner
	var/list/obj/effect/floating_blade/blades = list()
	/// Number of blades it remins to create.
	var/remains_to_create


/datum/status_effect/protective_blades/on_creation(
	mob/living/new_owner,
	new_duration = -1,
	max_num_blades = 4,
	blade_orbit_radius = 20,
	time_between_initial_blades = 0.25 SECONDS,
	blade_type = /obj/effect/floating_blade,
)

	src.duration = new_duration
	src.max_num_blades = max_num_blades
	src.remains_to_create = max_num_blades
	src.blade_orbit_radius = blade_orbit_radius
	src.time_between_initial_blades = time_between_initial_blades
	src.blade_type = blade_type
	return ..()


/datum/status_effect/protective_blades/on_apply()
	RegisterSignal(owner, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(on_shield_reaction))
	for(var/blade_num in 1 to max_num_blades)
		var/time_until_created = (blade_num - 1) * time_between_initial_blades
		if(time_until_created <= 0)
			create_blade()
			continue

		addtimer(CALLBACK(src, PROC_REF(create_blade)), time_until_created)

	return TRUE


/datum/status_effect/protective_blades/on_remove()
	UnregisterSignal(owner, COMSIG_HUMAN_CHECK_SHIELDS)
	QDEL_LIST(blades)
	return ..()


/// Creates a floating blade, adds it to our blade list, and makes it orbit our owner.
/datum/status_effect/protective_blades/proc/create_blade()
	if(QDELETED(src) || QDELETED(owner))
		return

	remains_to_create--
	var/obj/effect/floating_blade/blade = new blade_type(get_turf(owner))
	blades += blade
	INVOKE_ASYNC(blade, TYPE_PROC_REF(/atom/movable, orbit), owner, blade_orbit_radius)
	RegisterSignal(blade, COMSIG_QDELETING, PROC_REF(remove_blade))
	playsound(get_turf(owner), 'sound/items/unsheath.ogg', 33, TRUE)


/// Signal proc for [COMSIG_LIVING_CHECK_BLOCK].
/// If we have a blade in our list, consume it and block the incoming attack (shield it)
/datum/status_effect/protective_blades/proc/on_shield_reaction(
	mob/living/carbon/human/source,
	atom/movable/hitby,
	attack_text = "the attack",
	armour_penetration = 0,
	damage = 0,
	attack_type = ITEM_ATTACK,
	damage_type = BRUTE,
)
	SIGNAL_HANDLER

	if(!length(blades))
		return

	if(HAS_TRAIT(source, TRAIT_BEING_BLADE_SHIELDED))
		return

	SEND_SIGNAL(src, COMSIG_BLADE_BARRIER_TRIGGERED)
	ADD_TRAIT(source, TRAIT_BEING_BLADE_SHIELDED, TRAIT_STATUS_EFFECT(id))
	addtimer(TRAIT_CALLBACK_REMOVE(source, TRAIT_BEING_BLADE_SHIELDED, TRAIT_STATUS_EFFECT(id)), 0.1 SECONDS)

	var/obj/effect/floating_blade/to_remove = blades[1]
	playsound(get_turf(source), 'sound/weapons/parry.ogg', 100, TRUE)
	var/atom/atom_source = source
	source.visible_message(
		span_warning("[DECLENT_RU_CAP(to_remove, NOMINATIVE)], вращающийся вокруг [atom_source.declent_ru(GENITIVE)] блокирет атаку и исчезает!"),
		span_warning("[DECLENT_RU_CAP(to_remove, NOMINATIVE)], вращающийся вокруг вас блокирует атаку и исчезает!"),
		span_hear("Вы слышите металлический звон."),
	)

	qdel(to_remove)
	return SHIELD_BLOCK


/// Remove deleted blades from our blades list properly.
/datum/status_effect/protective_blades/proc/remove_blade(obj/effect/floating_blade/to_remove)
	SIGNAL_HANDLER

	if(!(to_remove in blades))
		CRASH("[type] called remove_blade() with a blade that was not in its blades list.")

	to_remove.stop_orbit(owner.orbiters)
	blades -= to_remove

	if(length(blades) || QDELETED(src) || !delete_on_blades_gone)
		return TRUE

	if(!remains_to_create)
		qdel(src)

	return TRUE


/// A subtype that doesn't self-delete / disappear when all blades are gone
/// It instead regenerates over time back to the max after blades are consumed
/datum/status_effect/protective_blades/recharging
	delete_on_blades_gone = FALSE
	/// The amount of time it takes for a blade to recharge
	var/blade_recharge_time = 30 SECONDS


/datum/status_effect/protective_blades/recharging/on_creation(
	mob/living/new_owner,
	new_duration = -1,
	max_num_blades = 4,
	blade_orbit_radius = 20,
	time_between_initial_blades = 0.25 SECONDS,
	blade_type = /obj/projectile/floating_blade,
	blade_recharge_time = 30 SECONDS,
)

	src.blade_recharge_time = blade_recharge_time
	return ..()


/datum/status_effect/protective_blades/recharging/remove_blade(obj/effect/floating_blade/to_remove)
	. = ..()
	if(!.)
		return

	addtimer(CALLBACK(src, PROC_REF(create_blade)), blade_recharge_time)


/datum/status_effect/moon_grasp_hide
	id = "Moon Grasp Hide Identity"
	status_type = STATUS_EFFECT_REFRESH
	duration = 15 SECONDS
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/moon_grasp_hide


/datum/status_effect/moon_grasp_hide/on_apply()
	owner.add_traits(list(TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE, TRAIT_SILENT_FOOTSTEPS, TRAIT_NO_SNOWPRINTS), TRAIT_STATUS_EFFECT(id))
	return TRUE


/datum/status_effect/moon_grasp_hide/on_remove()
	owner.remove_traits(list(TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE, TRAIT_SILENT_FOOTSTEPS, TRAIT_NO_SNOWPRINTS), TRAIT_STATUS_EFFECT(id))


/atom/movable/screen/alert/status_effect/moon_grasp_hide
	name = "Благословение Луны"
	desc = "Луна одаряет вас своим светом так же, как когда-то одаряло солнце."
	icon_state = "moon_hide"


/datum/status_effect/mansus_bless
	id = "Mansus Bless"
	status_type = STATUS_EFFECT_REFRESH
	duration = 8 SECONDS
	alert_type = null


/datum/status_effect/mansus_bless/tick(seconds_between_ticks)
	owner.AdjustStunned(-2 SECONDS)
	owner.AdjustWeakened(-2 SECONDS)
	owner.AdjustKnockdown(-2 SECONDS)
	owner.AdjustImmobilized(-2 SECONDS)
	owner.AdjustParalysis(-2 SECONDS)
	owner.adjustStaminaLoss(-10)
	return TRUE


/datum/status_effect/heretic_lastresort
	id = "heretic_lastresort"
	alert_type = /atom/movable/screen/alert/status_effect/heretic_lastresort
	duration = 12 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = -1

/atom/movable/screen/alert/status_effect/heretic_lastresort
	name = "Последний Шанс"
	desc = "Голова кружится, сердце колотится изо всех сил!"
	icon_state = "lastresort"

/datum/status_effect/heretic_lastresort/on_apply()
	ADD_TRAIT(owner, TRAIT_IGNORESLOWDOWN, TRAIT_STATUS_EFFECT(id))
	to_chat(owner, span_userdanger("Вы не сдадитесь так просто!"))
	return TRUE

/datum/status_effect/heretic_lastresort/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNORESLOWDOWN, TRAIT_STATUS_EFFECT(id))
