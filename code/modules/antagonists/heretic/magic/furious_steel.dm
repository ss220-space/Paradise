/obj/effect/proc_holder/spell/pointed/projectile/furious_steel
	name = "Яростная сталь"
	desc = "Призывает три серебряных клинка, вращающихся вокруг вас. \
			Эти клинки защитят вас от атак, но будут расходоваться при использовании. \
			Кроме того, вы можете кликнуть, чтобы выстрелить клинками в цель, нанося урон и вызывая кровотечение."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "furious_steel"
	sound = 'sound/weapons/guillotine.ogg'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 25 SECONDS
	invocation = "Р'СТН СТ'ЛЬ!"
	invocation_type = INVOCATION_SHOUT

	spell_requirements = NONE

	active_msg = "Вы призываете три серебрянных клинка."
	deactive_msg = "Вы отзываете три серебрянных клинка."
	cast_range = 20
	projectile_type = /obj/projectile/floating_blade
	projectile_amount = 3

	///Effect of the projectile that surrounds us while the spell is active
	var/projectile_effect = /obj/effect/floating_blade
	/// A ref to the status effect surrounding our heretic on activation.
	var/datum/status_effect/protective_blades/blade_effect


/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/on_spell_gain(mob/user = usr)
	. = ..()
	if(!action?.owner)
		return

	if(isheretic(action.owner))
		RegisterSignal(action.owner, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_lost))


/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/on_spell_loss(mob/remove_from)
	UnregisterSignal(remove_from, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING))
	return ..()


/// Signal proc for [SIGNAL_REMOVETRAIT], via [TRAIT_ALLOW_HERETIC_CASTING], to remove the effect when we lose the focus trait
/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/proc/on_focus_lost(mob/source)
	SIGNAL_HANDLER

	remove_mousepointer(source.client, refund_cooldown = TRUE)


/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/InterceptClickOn(mob/living/clicker, params, atom/target)
	if(!blade_effect)
		clicker.ranged_ability.remove_ranged_ability(clicker)

	// Let the caster prioritize using items like guns over blade casts
	if(clicker.get_active_hand())
		return FALSE
	// Let the caster prioritize melee attacks like punches and shoves over blade casts
	if(get_dist(clicker, target) <= 1)
		return FALSE

	return ..()


/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/on_activation(mob/on_who)
	. = ..()
	if(!.)
		return

	if(!isliving(on_who))
		return
	// Delete existing
	if(blade_effect)
		return

	var/mob/living/living_user = on_who
	blade_effect = living_user.apply_status_effect(/datum/status_effect/protective_blades, -1, projectile_amount, 25, 0.66 SECONDS, projectile_effect)
	RegisterSignal(blade_effect, COMSIG_QDELETING, PROC_REF(on_status_effect_deleted))
	RegisterSignal(blade_effect, COMSIG_BLADE_BARRIER_TRIGGERED, PROC_REF(on_status_effect_triggered))


/*
/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!blade_effect)
		return

	UnregisterSignal(blade_effect, COMSIG_QDELETING)
	UnregisterSignal(blade_effect, COMSIG_BLADE_BARRIER_TRIGGERED)
	QDEL_NULL(blade_effect)
*/


/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/before_cast(list/targets)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(!isnull(blade_effect) && current_amount)
		return . | SPELL_NO_IMMEDIATE_COOLDOWN

	remove_mousepointer(action.owner.client, refund_cooldown = FALSE)
	return SPELL_CANCEL_CAST


/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/fire_projectile(mob/living/user, atom/target)
	if(blade_effect.blades.len == 0)
		return

	. = ..()
	qdel(blade_effect.blades[1])


/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/ready_projectile(obj/projectile/to_launch, atom/target, mob/user, iteration)
	. = ..()
	to_launch.def_zone = check_zone(user.zone_selected)


/// If our blade status effect is deleted, clear our refs and deactivate
/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/proc/on_status_effect_deleted(datum/status_effect/protective_blades/source)
	SIGNAL_HANDLER

	blade_effect = null
	var/blades_remaining = current_amount
	// Which scales the cooldown according to projectiles remaining
	remove_mousepointer(action.owner.client, refund_cooldown = FALSE)
	// Snowflake because it does not handle cooldown if we used every projectile
	if(blades_remaining > 0)
		return

	cooldown_handler.start_recharge()


/// Reduce our projectile amount when our blade status effect is triggered
/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/proc/on_status_effect_triggered(datum/status_effect/protective_blades/source, atom/target)
	SIGNAL_HANDLER
	current_amount--


/obj/projectile/floating_blade
	name = "клинок"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "dio_knife"
	speed = 0.5
	damage = 25
	armour_penetration = 100
	sharp = TRUE
	//sharpness = SHARP_EDGED
	//wound_bonus = 15
	pass_flags = PASSTABLE | PASSFLAPS
	/// Color applied as an outline filter on init
	var/outline_color = "#f8f8ff"


/obj/projectile/floating_blade/get_ru_names()
	return list(
		NOMINATIVE = "клинок",
		GENITIVE = "клинка",
		DATIVE = "клинку",
		ACCUSATIVE = "клинок",
		INSTRUMENTAL = "клинком",
		PREPOSITIONAL = "клинке"
	)


/obj/projectile/floating_blade/Initialize(mapload)
	. = ..()
	add_filter("dio_knife", 2, list("type" = "outline", "color" = outline_color, "size" = 1))

/*
/obj/projectile/floating_blade/prehit_pierce(atom/hit)
	if(isliving(hit) && isliving(firer))
		var/mob/living/caster = firer
		var/mob/living/victim = hit
		if(caster == victim)
			return PROJECTILE_PIERCE_PHASE

		if(caster.mind)
			var/datum/antagonist/heretic_monster/monster = victim.mind?.has_antag_datum(/datum/antagonist/heretic_monster)
			if(monster?.master == caster.mind)
				return PROJECTILE_PIERCE_PHASE

		if(victim.can_block_magic(MAGIC_RESISTANCE))
			visible_message(span_warning("[src] drops to the ground and melts on contact [victim]!"))
			return PROJECTILE_DELETE_WITHOUT_HITTING

	return ..()
*/

/obj/projectile/floating_blade/haunted
	name = "ритуальный клинок"
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "render"
	damage = 35
	//wound_bonus = 25
	outline_color = "#D7CBCA"


/obj/projectile/floating_blade/haunted/get_ru_names()
	return list(
		NOMINATIVE = "ритуальный клинок",
		GENITIVE = "ритуального клинка",
		DATIVE = "ритуальному клинку",
		ACCUSATIVE = "ритуальный клинок",
		INSTRUMENTAL = "ритуальным клинком",
		PREPOSITIONAL = "ритуальном клинке"
	)


/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/solo
	name = "Ослабленная Яростная сталь"
	base_cooldown = 20 SECONDS
	projectile_amount = 1
	active_msg = "Вы призываете серебрянный клинок."
	deactive_msg = "Вы отзываете серебрянный клинок."


/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/haunted
	name = "Проклятая Сталь"
	desc = "Призывает два проклятых клинка, вращающихся вокруг вас. \
			Эти клинки защитят вас от атак, уничтожаясь в процессе. \
			Кроме того, вы можете кликнуть, чтобы выстрелить клинками в цель, нанося урон и вызывая кровотечение."
	action_background_icon_state = "bg_heretic" // kept intentionally
	overlay_icon_state = "bg_cult_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "cursed_steel"
	sound = 'sound/weapons/guillotine.ogg'

	base_cooldown = 40 SECONDS
	invocation = "IA!"
	invocation_type = INVOCATION_SHOUT

	spell_requirements = NONE

	active_msg = "Вы призываете два проклятых клинка."
	deactive_msg = "Вы отзываете проклятые клинки."
	projectile_amount = 2
	projectile_type = /obj/projectile/floating_blade/haunted
	projectile_effect = /obj/effect/floating_blade/haunted
