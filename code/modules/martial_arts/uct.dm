/**
 * Unarmed Combat Techniques - техника безоружного боя.
 * Боевое исскуство получаемое при прокачке навыка безоружного боя.
 */
/datum/martial_art/uct
	name = "Техника безоружного боя"
	has_explaination_verb = TRUE

	combos = list()
	weight = 0
	change_musculs = FALSE
	has_dirslash = FALSE
	works_with_rapid_gloves = TRUE

	var/alist/combos_by_level = alist(
		SKILL_LEVEL_BASIC = /datum/martial_combo/uct/wrist_lock,
		SKILL_LEVEL_ADVANCED = /datum/martial_combo/uct/foot_swep,
		SKILL_LEVEL_PROFESSIONAL = /datum/martial_combo/uct/knee_on_belly,
		SKILL_LEVEL_EXPERT = /datum/martial_combo/uct/armbar,
		SKILL_LEVEL_LEGEND = /datum/martial_combo/uct/leg_slicer,
	)

/mob/living/carbon/human/proc/refresh_uct()
	GET_SKILL_LEVEL(src, /datum/skill/combat/fists, skill_level)
	var/datum/martial_art/uct/martial_art = null
	for(var/datum/martial_art/art in mind.known_martial_arts)
		if(istype(art, /datum/martial_art/uct))
			martial_art = art
			break

	if(skill_level < SKILL_LEVEL_BASIC)
		if(martial_art != null)
			martial_art.remove(src)
		return

	if(martial_art == null)
		martial_art = new()

	martial_art.combos = list()
	for(var/level, combo in martial_art.combos_by_level)
		if(level <= skill_level)
			martial_art.combos += combo

	martial_art.teach(src)
	if(mind.martial_art == martial_art && hud_used?.combo_display)
		martial_art.reset_combos(src)
