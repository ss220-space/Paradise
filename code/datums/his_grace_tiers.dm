/datum/grace_tier
	/// His Grace.
	var/obj/item/his_grace/his_grace
	/// just OOP thing. Tiers without this designated as last tier/first tier.
	var/next_tier_type
	/// How many consumed bodies we need to ascend.
	var/required_kills
	/// Applied force bonus per consumed body
	var/force_bonus
	/// Additional force bonus, not based on kills.
	var/add_force_bonus
	/// Armour penetration
	var/armour_pen

	var/tier_name
	var/tier_desc
	var/list/tier_ru_names

/datum/grace_tier/Destroy(force)
	his_grace = null

	return ..()

/datum/grace_tier/proc/link_tier(obj/item/his_grace/his_grace)
	src.his_grace = his_grace

/datum/grace_tier/proc/apply_tier()
	his_grace.name = tier_name
	his_grace.desc = tier_desc
	his_grace.ru_names = tier_ru_names

	his_grace.force_bonus = force_bonus * LAZYLEN(his_grace.contents) + add_force_bonus
	his_grace.armour_penetration = armour_pen

/datum/grace_tier/dormant
	tier_name = "artistic toolbox"
	tier_desc = "Покрашенный в ярко-зелёные цвета тулбокс. От одного его вида становится страшно."
	tier_ru_names = list(
		NOMINATIVE = "артистический ящик для инструментов",
		GENITIVE = "артистического ящика для инструментов",
		DATIVE = "артистическому ящику для инструментов",
		ACCUSATIVE = "артистический ящик для инструментов",
		INSTRUMENTAL = "артистическим ящиком для инструментов",
		PREPOSITIONAL = "артистическом ящике для инструментов"
	)

/datum/grace_tier/awakened
	tier_name = "His Grace"
	tier_desc = "Кровавый артефакт, рождённый скверной магией."
	tier_ru_names = list(
		NOMINATIVE = "Его Светлость",
		GENITIVE = "Его Светлости",
		DATIVE = "Его Светлости",
		ACCUSATIVE = "Его Светлость",
		INSTRUMENTAL = "Его Светлостью",
		PREPOSITIONAL = "Его Светлости"
	)

	force_bonus = HIS_GRACE_FORCE_BONUS
	armour_pen = HIS_GRACE_PEN_BONUS

	required_kills = HIS_GRACE_ASCENDING_REQ
	next_tier_type = HIS_GRACE_ASCENDED

/datum/grace_tier/ascended
	tier_name = "mythical toolbox of three powers"
	tier_desc = "Мифический тулбокс, реликт Эпохи Трёх Сил. Его три застёжки сияют надписями «The Sun», «The Moon», «The Stars», а на гранях — таинственное «The World»."
	tier_ru_names = list(
		NOMINATIVE = "Мифический тулбокс трёх сил",
		GENITIVE = "Мифического тулбокса трёх сил",
		DATIVE = "Мифическому тулбоксу трёх сил",
		ACCUSATIVE = "Мифический тулбокс трёх сил",
		INSTRUMENTAL = "Мифическим тулбоксом трёх сил",
		PREPOSITIONAL = "Мифическом тулбоксе трёх сил"
	)

	force_bonus = HIS_GRACE_FORCE_BONUS
	add_force_bonus = HIS_GRACE_ASCEND_BONUS
	armour_pen = HIS_GRACE_PEN_BONUS

/datum/grace_tier/ascended/apply_tier()
	. = ..()
	his_grace.on_ascend()
