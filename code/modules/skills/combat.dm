// Combat skills (Security)
/datum/skill/combat
	category = "Боевые"
	category_color = "#dd3535"


// MARK: Accuracy
/datum/skill/combat/guns
	id = "combat.guns"
	name = "Дальний бой"
	desc = "Влияет на меткость, отдачу, осечки при стрельбе, а также скорость перезарядки."
	duration_mod_names = list(MAGAZINE_RELOAD_MOD)
	skills_mods = alist(
		ACCURACY_MOD = alist(
			SKILL_LEVEL_NONE = 0.8,
			SKILL_LEVEL_BEGINNER = 0.9,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 1.05,
			SKILL_LEVEL_PROFESSIONAL = 1.10,
			SKILL_LEVEL_EXPERT = 1.15,
			SKILL_LEVEL_LEGEND = 1.20,
			SKILL_LEVEL_UNAVAILABLE = 0.1,
		),
		SPREAD_MOD = alist(
			SKILL_LEVEL_NONE = 2,
			SKILL_LEVEL_BEGINNER = 1.5,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 0.8,
			SKILL_LEVEL_PROFESSIONAL = 0.6,
			SKILL_LEVEL_EXPERT = 0.4,
			SKILL_LEVEL_LEGEND = 0.2,
			SKILL_LEVEL_UNAVAILABLE = 5,
		),
		RECOIL_MOD = alist(
			SKILL_LEVEL_NONE = 2,
			SKILL_LEVEL_BEGINNER = 1.5,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 0.75,
			SKILL_LEVEL_PROFESSIONAL = 0.5,
			SKILL_LEVEL_EXPERT = 0.25,
			SKILL_LEVEL_LEGEND = 0.1,
			SKILL_LEVEL_UNAVAILABLE = 5,
		),
	)

// MARK: Melee
/datum/skill/combat/melee
	id = "combat.melee"
	name = "Ближний бой"
	desc = "Влияет на урон и расход выносливости при парировании оружием ближнего боя и щитами, а также урон, шанс."
	duration_mod_names = list(FISTS_GRAB_MOD)
	quality_mod_names = list(FISTS_DISARM_MOD)
	skills_mods = alist(
		MELEE_DAMAGE_MOD = alist(
			SKILL_LEVEL_NONE = 0.70,
			SKILL_LEVEL_BEGINNER = 0.80,
			SKILL_LEVEL_BASIC = 1.0,
			SKILL_LEVEL_ADVANCED = 1.10,
			SKILL_LEVEL_PROFESSIONAL = 1.20,
			SKILL_LEVEL_EXPERT = 1.25,
			SKILL_LEVEL_LEGEND = 1.30,
			SKILL_LEVEL_UNAVAILABLE = 0.01,
		),
		SHIELD_MOD = alist(
			SKILL_LEVEL_NONE = 2,
			SKILL_LEVEL_BEGINNER = 1.5,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 0.9,
			SKILL_LEVEL_PROFESSIONAL = 0.8,
			SKILL_LEVEL_EXPERT = 0.7,
			SKILL_LEVEL_LEGEND = 0.5,
			SKILL_LEVEL_UNAVAILABLE = 10,
		),
		FISTS_DAMAGE_MOD = alist(
			SKILL_LEVEL_NONE = 0.6,
			SKILL_LEVEL_BEGINNER = 0.75,
			SKILL_LEVEL_BASIC = 1.0,
			SKILL_LEVEL_ADVANCED = 1.25,
			SKILL_LEVEL_PROFESSIONAL = 1.5,
			SKILL_LEVEL_EXPERT = 1.75,
			SKILL_LEVEL_LEGEND = 2,
			SKILL_LEVEL_UNAVAILABLE = 0.01,
		),
	)

// MARK: Bows
/datum/skill/combat/bows
	id = "combat.bows"
	name = "Стрельба из лука"
	desc = "Влияет на меткость стрельбы из лука, а так же на самедление при нятянутой тетеве."
	duration_mod_names = list(BOW_SLOWDOWN_MOD)
	skills_mods = alist(
		BOW_ACCURACY_MOD = alist(
			SKILL_LEVEL_NONE = 0.8,
			SKILL_LEVEL_BEGINNER = 0.9,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 1.05,
			SKILL_LEVEL_PROFESSIONAL = 1.10,
			SKILL_LEVEL_EXPERT = 1.15,
			SKILL_LEVEL_LEGEND = 1.20,
			SKILL_LEVEL_UNAVAILABLE = 0.1,
		),
		BOW_SPREAD_MOD = alist(
			SKILL_LEVEL_NONE = 2,
			SKILL_LEVEL_BEGINNER = 1.5,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 0.8,
			SKILL_LEVEL_PROFESSIONAL = 0.6,
			SKILL_LEVEL_EXPERT = 0.4,
			SKILL_LEVEL_LEGEND = 0.2,
			SKILL_LEVEL_UNAVAILABLE = 5,
		),
	)
