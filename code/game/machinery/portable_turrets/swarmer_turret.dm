/obj/machinery/porta_turret/swarmer
	name = "energy turret"
	desc = "Вы это не должны видеть. Напишите баг-репорт, если увидели."
	projectile = /obj/projectile/beam/disabler/swarmer
	eprojectile = /obj/projectile/beam/disabler/swarmer // always non-lethal
	shot_sound = 'sound/weapons/gunshots/1laser2.ogg'
	eshot_sound = 'sound/weapons/gunshots/1laser2.ogg'

	icon = 'icons/obj/swarmer.dmi'
	icon_state = "barricade"

	installation = null
	always_up = TRUE
	use_power = NO_POWER_USE
	has_cover = FALSE
	raised = TRUE
	emp_vulnerable = FALSE // Damage and turning off is overkill
	density = TRUE
	scan_range = 9
	shot_delay = 1 SECONDS

	faction = ROLE_SWARMER

	targetting_is_configurable = FALSE
	check_arrest = FALSE
	check_records = FALSE
	check_access = FALSE
	check_synth	= TRUE
	check_borgs = TRUE
	ailock = TRUE
	req_access = list()

/obj/machinery/porta_turret/swarmer/Initialize(mapload)
	. = ..()
	GLOB.swarmer_objects += src

/obj/machinery/porta_turret/swarmer/Destroy()
	. = ..()
	GLOB.swarmer_objects -= src

/// Icon state of these turrets don't change
/obj/machinery/porta_turret/swarmer/update_icon_state()
	return

/// Special intent handling for swarmer clicks on swarmer turrets. Override as needed.
/obj/machinery/porta_turret/swarmer/proc/swarmer_help_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	SHOULD_CALL_PARENT(TRUE)
	ui_interact(src)

/// Special intent handling for swarmer clicks on swarmer turrets. Used for repairing.
/obj/machinery/porta_turret/swarmer/proc/swarmer_disarm_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	SHOULD_CALL_PARENT(TRUE)
	swarmer.balloon_alert_to_viewers("чинит...", "починка!")
	if(!do_after(swarmer, SWARMER_REPAIR_DELAY(swarmer), src, max_interact_count = 1))
		return
	if(!adjust_swarmer_metallic_resources(-SWARMER_REPAIR_COST))
		swarmer.balloon_alert(swarmer, "недостаточно ресурсов!")
		return
	repair_damage(SWARMER_REPAIR_AMOUNT(swarmer))

/// Special intent handling for swarmer clicks on swarmer turrets. Override as needed.
/obj/machinery/porta_turret/swarmer/proc/swarmer_grab_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	SHOULD_CALL_PARENT(TRUE)
	if(!is_builderswarmer(swarmer))
		return FALSE
	var/message = anchored ? "открепляем..." : "прикрепляем..."
	swarmer.balloon_alert(swarmer, message)
	if(!do_after(swarmer, 5 SECONDS, src, max_interact_count = 1))
		swarmer.balloon_alert(swarmer, "сбито!")
		return FALSE
	swarmer.balloon_alert(swarmer, "успех!")
	playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)
	set_anchored(!anchored)
	return

/// Special intent handling for swarmer clicks on swarmer turrets. Override as needed.
/obj/machinery/porta_turret/swarmer/proc/swarmer_harm_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	SHOULD_CALL_PARENT(TRUE)
	if(!is_builderswarmer(swarmer))
		return FALSE
	var/confirm = tgui_alert(swarmer, "Вы уверены, что хотите РАЗОБРАТЬ [declent_ru(ACCUSATIVE)]?", "Разбор структуры", list("Да", "Нет"))
	if(confirm == "Нет")
		return
	swarmer.balloon_alert(swarmer, "уничтожаем...")
	if(!do_after(swarmer, 5 SECONDS, src, max_interact_count = 1))
		swarmer.balloon_alert(swarmer, "сбито!")
		return FALSE
	swarmer.balloon_alert(swarmer, "уничтожено!")
	var/obj/effect/temp_visual/swarmer/disintegration/disintegrate_effect = new(get_turf(src))
	disintegrate_effect.adjust_size(src)
	qdel(src)

/// Swarmers can access the control panel
/obj/machinery/porta_turret/swarmer/isLocked(mob/user)
	return isswarmer(user)

/// No one except swarmers should be able to access the control panel
/obj/machinery/porta_turret/swarmer/allowed(mob/M)
	return FALSE

/// Swarmer turrets get destroyed on break
/obj/machinery/porta_turret/swarmer/die()
	. = ..()
	qdel(src)

/obj/machinery/porta_turret/swarmer/setup()
	return

/obj/machinery/porta_turret/swarmer/assess_perp(mob/living/carbon/human/perp)
	return 10 // Swarmer turrets shoot everything not in their faction

/obj/machinery/porta_turret/swarmer/emp_act(severity)
	..()
	take_damage(SWARMER_EMP_DAMAGE)

/obj/machinery/porta_turret/swarmer/get_ru_names()
	return alist(
		NOMINATIVE = "турель \"Свармеров\"",
		GENITIVE = "турели \"Свармеров\"",
		DATIVE = "турели \"Свармеров\"",
		ACCUSATIVE = "турель \"Свармеров\"",
		INSTRUMENTAL = "турелью \"Свармеров\"",
		PREPOSITIONAL = "турели \"Свармеров\""
	)

/// Swarmer turret. Shoots 3 projectiles at once with small damage
/obj/machinery/porta_turret/swarmer/turret
	name = "swarmer turret"
	desc = "Штурмовая энергетическая турель \"Свармеров\", способная стрелять залпом по три пули."
	health = 125
	icon_state = "turret_rapid"
	shot_delay = 1.5 SECONDS
	projectile = /obj/projectile/beam/disabler/swarmer/weak_turret
	eprojectile = /obj/projectile/beam/disabler/swarmer/weak_turret
	rapid = 3

/obj/machinery/porta_turret/swarmer/turret/get_ru_names()
	return alist(
		NOMINATIVE = "штурмовая турель \"Свармеров\"",
		GENITIVE = "штурмовой турели \"Свармеров\"",
		DATIVE = "штурмовой турели \"Свармеров\"",
		ACCUSATIVE = "штурмовую турель \"Свармеров\"",
		INSTRUMENTAL = "штурмовой турелью \"Свармеров\"",
		PREPOSITIONAL = "штурмовой турели \"Свармеров\""
	)

/// Swarmer sentry. Shoots one strong projectile.
/obj/machinery/porta_turret/swarmer/sniper
	name = "swarmer sentry"
	desc = "Снайперская энергетическая турель \"Свармеров\", способная стрелять мощным выстрелом, что пробивает целей насквозь."
	health = 175
	icon_state = "turret_sniper"
	shot_delay = 2.5 SECONDS
	projectile = /obj/projectile/beam/disabler/swarmer/strong_turret
	eprojectile = /obj/projectile/beam/disabler/swarmer/strong_turret

/obj/machinery/porta_turret/swarmer/sniper/get_ru_names()
	return alist(
		NOMINATIVE = "снайперская турель \"Свармеров\"",
		GENITIVE = "снайперской турели \"Свармеров\"",
		DATIVE = "снайперской турели \"Свармеров\"",
		ACCUSATIVE = "снайперскую турель \"Свармеров\"",
		INSTRUMENTAL = "снайперской турелью \"Свармеров\"",
		PREPOSITIONAL = "снайперской турели \"Свармеров\""
	)
