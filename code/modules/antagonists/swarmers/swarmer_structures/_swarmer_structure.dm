/// List of all swarmer structures
GLOBAL_LIST_EMPTY(swarmer_objects)

/**
 * Swarmer structures
 *
 * Has 4 different interactions based on swarmer's intent, separated in swarmer_act().
 * All structures of this type allow swarmer projectiles to pass through them.
 */
/obj/structure/swarmer
	abstract_type = /obj/structure/swarmer
	name = "swarmer structure"
	desc = "Вы не должны это видеть."
	icon = 'icons/obj/swarmer.dmi'
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_color = LIGHT_COLOR_CYAN
	max_integrity = 30
	anchored = TRUE
	density = TRUE
	/// Light range
	var/lon_range = 1
	/// Text shown on examine to swarmers
	var/swarmer_examine
	/// Do we let swarmer projectiles pass through
	var/projectiles_pass = TRUE
	/// Do we let swarmers pass through
	var/swarmers_pass = FALSE

/obj/structure/swarmer/Initialize(mapload)
	. = ..()
	GLOB.swarmer_objects += src
	set_light(lon_range)

/obj/structure/swarmer/Destroy(force)
	GLOB.swarmer_objects -= src
	return ..()

/obj/structure/swarmer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/weapons/egloves.ogg', 80, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)

/// Special intent handling for swarmer clicks on swarmer structures. All structures are not interactable, if unanchored.
/obj/structure/swarmer/proc/swarmer_help_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	if(!anchored)
		swarmer.balloon_alert(swarmer, "не прикручено!")
		return FALSE
	return TRUE

/// Special intent handling for swarmer clicks on swarmer structures. Used for repairing.
/obj/structure/swarmer/proc/swarmer_disarm_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	swarmer.balloon_alert_to_viewers("чинит...", "починка...")
	if(!do_after(swarmer, SWARMER_REPAIR_DELAY(swarmer), src, max_interact_count = 1))
		swarmer.balloon_alert(swarmer, "сбито!")
		return
	if(!adjust_swarmer_metallic_resources(-SWARMER_REPAIR_COST))
		swarmer.balloon_alert(swarmer, "недостаточно ресурсов!")
		return
	if(!repair_damage(SWARMER_REPAIR_AMOUNT(swarmer)))
		swarmer.balloon_alert(swarmer, "полностью починено!")

/**
 * Special intent handling for swarmer clicks on swarmer structures. Used by builders for anchoring.
 *
 * Returns TRUE, if we successfully unanchored/anchored src.
 * Returns FALSE otherwise.
 */
/obj/structure/swarmer/proc/swarmer_grab_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	if(!is_builderswarmer(swarmer))
		return FALSE
	var/message = anchored ? "открепляем..." : "прикрепляем..."
	swarmer.balloon_alert(swarmer, message)
	if(!do_after(swarmer, 3 SECONDS, src, max_interact_count = 1))
		swarmer.balloon_alert(swarmer, "сбито!")
		return FALSE
	swarmer.balloon_alert(swarmer, "успех!")
	playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)
	set_anchored(!anchored)
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/// Special intent handling for swarmer clicks on swarmer structures. Used by builders for destroying.
/obj/structure/swarmer/proc/swarmer_harm_act(mob/living/simple_animal/hostile/swarmer/swarmer)
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

// Allows for all swarmer structures to be shoot through with swarmer projectiles.
/obj/structure/swarmer/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(is_swarmerprojectile(mover) && projectiles_pass)
		return TRUE
	if(isswarmer(mover) && swarmers_pass)
		return TRUE

// All swarmer structures get damaged on emp_act.
/obj/structure/swarmer/emp_act(severity)
	..()
	take_damage(SWARMER_EMP_DAMAGE)

// Extra info shown to swarmers
/obj/structure/swarmer/examine(mob/user)
	. = ..()
	if(swarmer_examine)
		. += span_swarmer(swarmer_examine)
