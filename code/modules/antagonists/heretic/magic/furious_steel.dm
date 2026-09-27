/datum/action/cooldown/spell/pointed/projectile/furious_steel
	name = "Яростная Сталь"
	desc = "Призывает три серебряных клинка, вращающихся вокруг вас. \
			Эти клинки защитят вас от атак, но будут расходоваться при использовании. \
			Кроме того, вы можете кликнуть, чтобы выстрелить клинками в цель, нанося урон и вызывая кровотечение."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "furious_steel"
	sound = 'sound/weapons/guillotine.ogg'

	school = SCHOOL_FORBIDDEN
	spell_requirements = NONE
	cooldown_time = 30 SECONDS
	invocation = "Р'СТН СТ'ЛЬ!"

	active_msg = "Вы призываете три серебряных клинка."
	deactive_msg = "Вы отзываете три серебряных клинка."
	cast_range = 20
	projectile_type = /obj/projectile/floating_blade
	projectile_amount = 3

	///Effect of the projectile that surrounds us while the spell is active
	var/projectile_effect = /obj/effect/floating_blade
	/// A ref to the status effect surrounding our heretic on activation.
	var/datum/status_effect/protective_blades/blade_effect


/datum/action/cooldown/spell/pointed/projectile/furious_steel/Grant(mob/grant_to)
	. = ..()
	if(!owner)
		return

	if(IS_HERETIC(owner))
		RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_lost))


/datum/action/cooldown/spell/pointed/projectile/furious_steel/Remove(mob/remove_from)
	UnregisterSignal(remove_from, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING))
	return ..()


/// Signal proc for [SIGNAL_REMOVETRAIT], via [TRAIT_ALLOW_HERETIC_CASTING], to remove the effect when we lose the focus trait
/datum/action/cooldown/spell/pointed/projectile/furious_steel/proc/on_focus_lost(mob/source)
	SIGNAL_HANDLER

	unset_click_ability(source.client, refund_cooldown = TRUE)


/datum/action/cooldown/spell/pointed/projectile/furious_steel/InterceptClickOn(mob/living/clicker, params, atom/target)
	if(!blade_effect)
		unset_click_ability(clicker)

	if(clicker.get_active_hand())
		return FALSE
	if(get_dist(clicker, target) <= 1)
		return FALSE

	return ..()


/datum/action/cooldown/spell/pointed/projectile/furious_steel/on_activation(mob/on_who)
	. = ..()
	if(!.)
		return

	if(!isliving(on_who))
		return
	if(blade_effect)
		return

	var/mob/living/living_user = on_who
	blade_effect = living_user.apply_status_effect(/datum/status_effect/protective_blades, -1, projectile_amount, 25, 0.66 SECONDS, projectile_effect)
	RegisterSignal(blade_effect, COMSIG_QDELETING, PROC_REF(on_status_effect_deleted))
	RegisterSignal(blade_effect, COMSIG_BLADE_BARRIER_TRIGGERED, PROC_REF(on_status_effect_triggered))


/datum/action/cooldown/spell/pointed/projectile/furious_steel/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(!isnull(blade_effect) && current_amount)
		return . | SPELL_NO_IMMEDIATE_COOLDOWN

	unset_click_ability(owner.client, refund_cooldown = FALSE)
	return SPELL_CANCEL_CAST


/datum/action/cooldown/spell/pointed/projectile/furious_steel/fire_projectile(mob/living/user, atom/target)
	if(blade_effect.blades.len == 0)
		return

	. = ..()
	qdel(blade_effect.blades[1])


/datum/action/cooldown/spell/pointed/projectile/furious_steel/ready_projectile(obj/projectile/to_launch, atom/target, mob/user, iteration)
	. = ..()
	to_launch.def_zone = check_zone(user.zone_selected)


/// If our blade status effect is deleted, clear our refs and deactivate
/datum/action/cooldown/spell/pointed/projectile/furious_steel/proc/on_status_effect_deleted(datum/status_effect/protective_blades/source)
	SIGNAL_HANDLER

	blade_effect = null
	var/blades_remaining = current_amount
	unset_click_ability(owner.client, refund_cooldown = FALSE)
	if(blades_remaining > 0)
		return

	StartCooldown()


/// Reduce our projectile amount when our blade status effect is triggered
/datum/action/cooldown/spell/pointed/projectile/furious_steel/proc/on_status_effect_triggered(datum/status_effect/protective_blades/source, atom/target)
	SIGNAL_HANDLER
	current_amount--


/obj/projectile/floating_blade
	name = "knife"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "dio_knife"
	damage = 25
	armour_penetration = 100
	sharp = TRUE
	pass_flags = PASSTABLE | PASSFLAPS
	/// Color applied as an outline filter on init
	var/outline_color = "#f8f8ff"


/obj/projectile/floating_blade/get_ru_names()
	return alist(
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
	name = "ritual knife"
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "render"
	damage = 35
	outline_color = "#D7CBCA"


/obj/projectile/floating_blade/haunted/get_ru_names()
	return alist(
		NOMINATIVE = "ритуальный клинок",
		GENITIVE = "ритуального клинка",
		DATIVE = "ритуальному клинку",
		ACCUSATIVE = "ритуальный клинок",
		INSTRUMENTAL = "ритуальным клинком",
		PREPOSITIONAL = "ритуальном клинке"
	)


/datum/action/cooldown/spell/pointed/projectile/furious_steel/solo
	name = "Ослабленная Яростная Сталь"
	cooldown_time = 20 SECONDS
	projectile_amount = 1
	active_msg = "Вы призываете серебряный клинок."
	deactive_msg = "Вы отзываете серебряный клинок."


/datum/action/cooldown/spell/pointed/projectile/furious_steel/haunted
	name = "Проклятая Сталь"
	desc = "Призывает два проклятых клинка, вращающихся вокруг вас. \
			Эти клинки защитят вас от атак, уничтожаясь в процессе. \
			Кроме того, вы можете кликнуть, чтобы выстрелить клинками в цель, нанося урон и вызывая кровотечение."

	cooldown_time = 40 SECONDS
	invocation = "IA!"
	invocation_type = INVOCATION_SHOUT


	active_msg = "Вы призываете два проклятых клинка."
	deactive_msg = "Вы отзываете проклятые клинки."
	projectile_amount = 2
	projectile_type = /obj/projectile/floating_blade/haunted
	projectile_effect = /obj/effect/floating_blade/haunted
