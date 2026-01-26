#define GOLEM_END_PR_1(gender) UNLINT(genderize_ru(gender, "ый", "ая", "ое", "ые"))
#define GOLEM_END_PR_2(gender) UNLINT(genderize_ru(gender, "ой", "ая", "ое", "ые"))

GLOBAL_LIST_EMPTY(cached_heal_materials)

/datum/species/golem
	name = SPECIES_GOLEM_BASIC
	name_plural = "Golems"

	icobase = 'icons/mob/human_races/r_golem.dmi'
	deform = 'icons/mob/human_races/r_golem.dmi'

	inherent_traits = list(
		TRAIT_NO_BLOOD,
		TRAIT_NO_BREATH,
		TRAIT_NO_PAIN,
		TRAIT_RADIMMUNE,
		TRAIT_NO_GUNS,
		TRAIT_PIERCEIMMUNE,
		TRAIT_EMBEDIMMUNE,
	)
	dies_at_threshold = TRUE
	speed_mod = 2
	brute_mod = 0.45
	burn_mod = 0.45
	tox_mod = 0.45
	clone_mod = 0.45
	brain_mod = 0.45
	stamina_mod = 0.45
	siemens_coeff = 0
	punchdamagelow = 5
	punchdamagehigh = 14
	punchstunthreshold = 11 //about 40% chance to stun
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_CLOTH_OUTER, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_CLOTH_INNER, ITEM_SLOT_SUITSTORE)
	nojumpsuit = TRUE

	reagent_tag = PROCESS_ORG

	warning_low_pressure = -INFINITY
	hazard_low_pressure = -INFINITY
	hazard_high_pressure = INFINITY
	warning_high_pressure = INFINITY

	cold_level_1 = -INFINITY
	cold_level_2 = -INFINITY
	cold_level_3 = -INFINITY

	heat_level_1 = INFINITY
	heat_level_2 = INFINITY
	heat_level_3 = INFINITY

	blood_color = "#515573"
	flesh_color = "#137E8F"
	skinned_type = /obj/item/stack/ore/iron

	blacklisted = TRUE // To prevent golem subtypes from overwhelming the odds when random species changes, only the Random Golem type can be chosen
	dangerous_existence = TRUE

	has_organ = list(
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/golem,
		INTERNAL_ORGAN_RESONATOR = /obj/item/organ/internal/adamantine_resonator,
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
	)

	has_limbs = list(
		BODY_ZONE_CHEST =  list("path" = /obj/item/organ/external/chest/unbreakable/sturdy),
		BODY_ZONE_PRECISE_GROIN = list("path" = /obj/item/organ/external/groin/unbreakable/sturdy),
		BODY_ZONE_HEAD = list("path" = /obj/item/organ/external/head/unbreakable/sturdy),
		BODY_ZONE_L_ARM = list("path" = /obj/item/organ/external/arm/unbreakable/sturdy),
		BODY_ZONE_R_ARM = list("path" = /obj/item/organ/external/arm/right/unbreakable/sturdy),
		BODY_ZONE_L_LEG = list("path" = /obj/item/organ/external/leg/unbreakable/sturdy),
		BODY_ZONE_R_LEG = list("path" = /obj/item/organ/external/leg/right/unbreakable/sturdy),
		BODY_ZONE_PRECISE_L_HAND = list("path" = /obj/item/organ/external/hand/unbreakable/sturdy),
		BODY_ZONE_PRECISE_R_HAND = list("path" = /obj/item/organ/external/hand/right/unbreakable/sturdy),
		BODY_ZONE_PRECISE_L_FOOT = list("path" = /obj/item/organ/external/foot/unbreakable/sturdy),
		BODY_ZONE_PRECISE_R_FOOT = list("path" = /obj/item/organ/external/foot/right/unbreakable/sturdy),
	)

	suicide_messages = list(
		"рассыпается в прах!",
		"разбивает своё тело на части!")

	/// Default color for the golem (RGB: 170,170,170 - medium gray)
	var/golem_colour = rgb(170, 170, 170)

	/// Description text shown to players when they become this golem type
	var/info_text = "Будучи <span class='danger'>железным големом</span>, вы не обладаете отличительными особенностями."

	/// Whether this golem species is eligible for random selection
	var/random_eligible = TRUE

	/// Name prefix without gender ending (completed by genderization function)
	var/prefix = "Железн"
	/// Type of prefix genderization for smoother translations (check get_random_name proc)
	var/prefix_type = 1
	/// Default gender for golem names (MALE)
	var/gender_name = MALE
	/// Chance for male name generation (80%)
	var/chance_name_male = 80
	/// Chance for female name generation (60%)
	var/chance_name_female = 60
	/// Chance for neuter name generation (5%)
	var/chance_name_neuter = 5
	/// Special names available for this golem type, organized by gender
	var/list/special_names = list(
		MALE = list("Человек", "Биба", "Боба", "Ржавчик", "Утюг", "Металлист", "Мужик", "Сплав", "Брусок", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева"),
		NEUTER = null
	)
	/// Chance to use a human surname instead of a special name (5%)
	var/human_surname_chance = 5
	/// Chance to use a special name from the list instead of a generated one (10%)
	var/special_name_chance = 10

	/// Reference to the golem's owner, if any (Dobby is a free golem reference)
	var/owner

	/// Amount of damage healed when using the golem's native material
	var/material_heal = 20
	/// Amount of material required for each healing action
	var/amount_required_for_heal = 5
	/// Time required to perform self-healing (2 seconds)
	var/self_heal_delay = 2 SECONDS

/**
 * Generates a random name for a golem
 *
 * Determines a random gender for the name based on configured probabilities,
 * then selects an appropriate name from various sources including special golem names,
 * human names, or fallback names. Handles Russian language genderization for prefixes.
 */
/datum/species/golem/get_random_name()
	// Determine random gender for the golem's NAME. If all chances fail, use default gender
	if(prob(chance_name_male))
		gender_name = MALE
	else if(prob(chance_name_female))
		gender_name = FEMALE
	else if(prob(chance_name_neuter))
		gender_name = NEUTER

	var/golem_surname // Golem's name

	// Initially select a random golem name like "Andesite"
	switch(gender_name)
		if(MALE)
			if(length(GLOB.golem_male)) // BYOND has a habit of file failures. We check file length to prevent this
				golem_surname = "[pick(GLOB.golem_male)]"
		if(FEMALE)
			if(length(GLOB.golem_female))
				golem_surname = "[pick(GLOB.golem_female)]"
		if(NEUTER)
			if(length(GLOB.golem_neuter))
				golem_surname = "[pick(GLOB.golem_neuter)]"

	// 10% chance to choose a special name, or use one if no name has been selected yet
	// (provided the golem has special names for this gender)
	if(special_names && length(special_names) && (prob(special_name_chance) || (golem_surname == null)))
		golem_surname = pick(special_names[gender_name])

	// 5% chance to choose a human first or last name, or if golem still doesn't have a name
	// The game still doesn't consider empty string elements != null, hence this check
	if(prob(human_surname_chance) || (golem_surname == null) || golem_surname == "" || golem_surname == " ")
		switch(gender_name)
			if(MALE)
				if(prob(50)) // Choose male first name or last name
					golem_surname = pick(GLOB.first_names_male)
				else
					golem_surname = pick(GLOB.last_names_male)
			if(FEMALE)
				if(prob(50)) // Choose female first name or last name
					golem_surname = pick(GLOB.first_names_female)
				else
					golem_surname = pick(GLOB.last_names_female)
			if(NEUTER)
				golem_surname = pick("Нечто", "Чудо") // Neuter gender golem

	// Set the adjective ending for prefix (e.g., "golden" becomes "golden" instead of "gold")
	var/end_pr
	switch(prefix_type)
		if(1)
			end_pr = GOLEM_END_PR_1(gender_name) // Male, Female, Neuter, Plural endings
		if(2)
			end_pr = GOLEM_END_PR_2(gender_name)
		if(3)
			end_pr = ""

	// Genderize the adjective prefix and append our gender-specific name
	var/golem_name
	if(prefix_type == 3)
		golem_name = "[prefix][end_pr]-[golem_surname]"
	else
		golem_name = "[prefix][end_pr] [golem_surname]"
	return golem_name

/datum/species/golem/on_species_gain(mob/living/carbon/human/human)
	. = ..()
	if(human.mind)
		human.mind.assigned_role = "Golem"
		if(owner)
			human.mind.special_role = SPECIAL_ROLE_GOLEM
		else
			human.mind.special_role = SPECIAL_ROLE_FREE_GOLEM
	human.real_name = get_random_name()
	human.name = human.real_name
	to_chat(human, info_text)

	var/list/heal_material_types_list = get_heal_material_types_cached()
	human.AddElement(/datum/element/material_heal, heal_material_types_list, amount_required_for_heal, material_heal, self_heal_delay)

/datum/species/golem/on_species_loss(mob/living/carbon/human/human)
	. = ..()
	human.RemoveElement(/datum/element/material_heal)

/datum/species/golem/gain_muscles(mob/living/target, default, max_level, can_become_stronger)
	..(target, default, max_level, FALSE)

/datum/species/golem/get_vision_organ(mob/living/carbon/human/user)
	return NO_VISION_ORGAN

/// Returns a list of material types required for healing
/datum/species/golem/proc/get_heal_material_types()
	return list(
		/obj/item/stack/ore/iron,
		/obj/item/stack/sheet/metal,
	)

/// Copy of get_ru_names_cached for golem heal materials
/datum/species/golem/proc/get_heal_material_types_cached()
	var/list/heal_materials = GLOB.cached_heal_materials[type]
	if(heal_materials)
		return heal_materials
	heal_materials = get_heal_material_types()
	if(heal_materials)
		GLOB.cached_heal_materials[type] = heal_materials
		return heal_materials
	return

//Random Golem

/datum/species/golem/random
	name = SPECIES_GOLEM_RANDOM
	blacklisted = FALSE
	dangerous_existence = FALSE
	var/static/list/random_golem_types

/datum/species/golem/random/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	if(!random_golem_types)
		random_golem_types = subtypesof(/datum/species/golem) - type
		for(var/V in random_golem_types)
			var/datum/species/golem/G = V
			if(!initial(G.random_eligible))
				random_golem_types -= G
	var/datum/species/golem/golem_type = pick(random_golem_types)
	var/mob/living/carbon/human/H = C
	H.set_species(golem_type)

//Golem subtypes

/**
 * Adamantine Golem - Leader type with resonance communication
 *
 * Leader golems that can resonate to communicate with all other golems.
 * Features special organs for resonance and vocal communication.
 */
/datum/species/golem/adamantine
	name = SPECIES_GOLEM_ADAMANTINE
	skinned_type = /obj/item/stack/sheet/mineral/adamantine

	has_organ = list(
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/golem,
		INTERNAL_ORGAN_RESONATOR = /obj/item/organ/internal/adamantine_resonator,
		INTERNAL_ORGAN_VOCALCORDS = /obj/item/organ/internal/vocal_cords/adamantine,
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
	)

	golem_colour = rgb(68, 238, 221)
	info_text = "Будучи <span class='danger'>адамантиновым големом</span>, вы обладаете особыми голосовыми связками, позволяющие вам «резонировать» послания всем големам."
	prefix = "Адамантинов"
	special_names = list(
		MALE = list("Сплав", "Брусок", "Мужик", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева"),
		NEUTER = null
		)

	material_heal = 40
	amount_required_for_heal = 1

/datum/species/golem/adamantine/get_heal_material_types()
	return list(
		/obj/item/stack/sheet/mineral/adamantine,
	)

/**
 * Plasma Golem - Explosive suicide bomber type
 *
 * The suicide bombers of golemkind. Burns easily and explodes when overheated.
 * Features self-ignition ability and explosion mechanics.
 */
/datum/species/golem/plasma
	name = SPECIES_GOLEM_PLASMA
	skinned_type = /obj/item/stack/ore/plasma
	golem_colour = rgb(170, 51, 221)
	heat_level_1 = 360
	heat_level_2 = 400
	heat_level_3 = 460
	info_text = "Будучи <span class='danger'>плазменным големом</span>, вы легко сгораете. Будьте осторожны, если вы сильно нагреетесь &mdash; взорвётесь!"
	heatmod = 0 //fine until they blow up
	prefix = "Плазменн"
	special_names = list(
		MALE = list("Потоп", "Прилив", "Разлив", "Залив", "Мужик", "Наводнение", "Поток", "Ливень", "Пожар", "Стержень", "Минерал", "Мужик", "Горец", "Сгоратель", "Пупс"),
		FEMALE = list("Дева"),
		NEUTER = null
		)
	var/boom_warning = FALSE

	material_heal = 25
	amount_required_for_heal = 2

/datum/species/golem/plasma/handle_life(mob/living/carbon/human/H)
	if(H.bodytemperature > 750)
		if(!boom_warning && H.on_fire)
			to_chat(H, span_userdanger("Вы чувствуете, что можете взорваться в любой момент!"))
			boom_warning = TRUE
	else
		if(boom_warning)
			to_chat(H, span_notice("Вы чувствуете себя стабильней."))
			boom_warning = FALSE

	if(H.bodytemperature > 850 && H.on_fire && prob(25))
		explosion(get_turf(H), devastation_range = 1, heavy_impact_range = 2, light_impact_range = 4, flame_range = 5, cause = H)
		add_attack_logs(H, null, "exploded", ATKLOG_FEW)
		if(H)
			H.gib()
	if(H.fire_stacks < 2) //flammable
		H.adjust_fire_stacks(1)
	..()

/datum/species/golem/plasma/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	var/datum/action/innate/ignite/ignite = locate() in H.actions
	if(!ignite)
		ignite = new
		ignite.Grant(H)

/datum/species/golem/plasma/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	var/datum/action/innate/ignite/ignite = locate() in H.actions
	ignite?.Remove(H)

/datum/species/golem/plasma/get_heal_material_types()
	return list(
		/obj/item/stack/ore/plasma,
		/obj/item/stack/sheet/mineral/plasma,
	)

/datum/action/innate/ignite
	name = "Поджог"
	desc = "Подожгите себя и достигните взрыва!"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	button_icon_state = "sacredflame"

/datum/action/innate/ignite/Activate()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.fire_stacks)
			to_chat(owner, span_notice("Вы подожгли себя!"))
		else
			to_chat(owner, span_warning("Вы попытались поджечь себя, но неудачно!"))
		H.IgniteMob() //firestacks are already there passively

/**
 * Diamond Golem - Extremely durable type
 *
 * Harder to hurt with significantly increased damage resistance across all types.
 * Features high damage reduction and special naming conventions.
 */
/datum/species/golem/diamond
	name = SPECIES_GOLEM_DIAMOND
	golem_colour = rgb(0, 255, 255)
	brute_mod = 0.3 //70% damage reduction up from 55%
	burn_mod = 0.3
	tox_mod = 0.3
	clone_mod = 0.3
	brain_mod = 0.3
	stamina_mod = 0.3
	skinned_type = /obj/item/stack/ore/diamond
	info_text = "Будучи <span class='danger'>алмазным големом</span>, вы прочнее обычных големов."
	prefix = "Алмазн"
	special_names = list(
		MALE = list("Сплав", "Брусок", "Мужик", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева", "Ювелирка", "Драгоценность", "Серёжка"),
		NEUTER = list("Украшение", "Кольцо")
		)
	chance_name_male = 50
	chance_name_female = 80
	chance_name_neuter = 10
	special_name_chance = 60

	material_heal = 35
	amount_required_for_heal = 2
	self_heal_delay = 3 SECONDS

/datum/species/golem/diamond/get_heal_material_types()
	return list(
		/obj/item/stack/ore/diamond,
		/obj/item/stack/sheet/mineral/diamond,
	)

/**
 * Gold Golem - Faster but less durable type
 *
 * Faster movement speed but reduced damage resistance compared to standard golems.
 * Features speed bonus at the cost of durability.
 */
/datum/species/golem/gold
	name = SPECIES_GOLEM_GOLD
	golem_colour = rgb(204, 204, 0)
	speed_mod = 1
	brute_mod = 0.75 // 25% damage reduction down from 55%
	burn_mod = 0.75
	tox_mod = 0.75
	clone_mod = 0.75
	brain_mod = 0.75
	stamina_mod = 0.75
	skinned_type = /obj/item/stack/ore/gold
	info_text = "Будучи <span class='danger'>золотым големом</span>, вы более быстры, но менее прочны, нежели обычный голем."
	prefix = "Золот"
	prefix_type = 2
	special_names = list(
		MALE = list("Мальчик", "Мужик", "Человек", "Ручник", "Молодежник", "Понтовщик", "Мост", "Яблочник", "Ювелир", "Дорогуша", "Дурак", "Брусок", "Закат", "Дым", "Шелк", "Сплав", "Ремесленник", "Мёд", "Сплав", "Брусок", "Мужик", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева", "Рука", "Ювелирка", "Драгоценность", "Серёжка"),
		NEUTER = list("Украшение", "Кольцо")
		)
	special_name_chance = 80

	material_heal = 25
	amount_required_for_heal = 3

/datum/species/golem/gold/get_heal_material_types()
	return list(
		/obj/item/stack/ore/gold,
		/obj/item/stack/sheet/mineral/gold,
	)

/**
 * Silver Golem - Stunner
 *
 * Slower, but higher stun chance.
 */
/datum/species/golem/silver
	name = SPECIES_GOLEM_SILVER
	golem_colour = rgb(221, 221, 221)
	punchstunthreshold = 9 // 60% chance, from 40%
	skinned_type = /obj/item/stack/ore/silver
	info_text = "Будучи <span class='danger'>серебряным големом</span>, вы с большей вероятностью можете оглушить противников атаками."
	prefix = "Серебрян"
	special_names = list(
		MALE = list("Серфер", "Чарриот", "Мужик", "Глушитель", "Тихон", "Анестетик", "Ювелир", "Пупс"),
		FEMALE = list("Дева", "Ювелирка", "Драгоценность", "Серёжка"),
		NEUTER = list("Украшение", "Кольцо")
		)
	chance_name_male = 70
	chance_name_neuter = 10
	special_name_chance = 40

	material_heal = 25
	amount_required_for_heal = 3

/datum/species/golem/silver/get_heal_material_types()
	return list(
		/obj/item/stack/ore/silver,
		/obj/item/stack/sheet/mineral/silver,
	)

/**
 * Plasteel Golem - Very slow, high damage
 *
 * Higher damage and stun threshold at the cost of speed.
 * Also tankier.
 */
/datum/species/golem/plasteel
	name = SPECIES_GOLEM_PLASTEEL
	golem_colour = rgb(187, 187, 187)
	stun_mod = 0.5
	stamina_mod = 0.5
	punchdamagelow = 12
	punchdamagehigh = 21
	punchstunthreshold = 18 // Still 40% stun chance
	speed_mod = 4 // Pretty fucking slow
	skinned_type = /obj/item/stack/sheet/plasteel
	info_text = "Будучи <span class='danger'>пласталиевым големом</span>, вы медлительны, но вас сложнее оглушить, а ваши кулаки причиняют серьёзные повреждения."
	prefix = "Пласталиев"
	special_names = list(
		MALE = list("Сплав", "Брусок", "Мужик", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева"),
		NEUTER = null
		)
	unarmed_type = /datum/unarmed_attack/golem/plasteel

/datum/species/golem/plasteel/get_heal_material_types()
	return list(
		/obj/item/stack/ore/iron,
		/obj/item/stack/ore/plasma,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/plasteel,
	)

/datum/unarmed_attack/golem/plasteel
	attack_verb = list("ударил")
	attack_sound = 'sound/effects/meteorimpact.ogg'

/**
 * Titanium Golem - Plasteel, but burn protected
 *
 * High burn resistance at the cost of speed.
 * Also immune to ashstorm.
 */
/datum/species/golem/titanium
	name = SPECIES_GOLEM_TITANIUM
	golem_colour = rgb(255, 255, 255)
	skinned_type = /obj/item/stack/ore/titanium
	info_text = "Будучи <span class='danger'>титановым големом</span>, вы частично устойчивы к ожогам и невосприимчивы к пепельным бурям."
	burn_mod = 0.405
	prefix = "Титанов"
	special_names = list(
		MALE = list("Диоксид", "Сплав", "Брусок", "Мужик", "Минерал", "Кусок", "Кирпич", "Буреходец", "Пожарник", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева"),
		NEUTER = null
		)
	inherent_traits = list(
		TRAIT_NO_BLOOD,
		TRAIT_NO_BREATH,
		TRAIT_NO_PAIN,
		TRAIT_RADIMMUNE,
		TRAIT_NO_GUNS,
		TRAIT_PIERCEIMMUNE,
		TRAIT_EMBEDIMMUNE,
		TRAIT_ASHSTORM_IMMUNE,
	)

	material_heal = 25
	amount_required_for_heal = 3

/datum/species/golem/titanium/get_heal_material_types()
	return list(
		/obj/item/stack/ore/titanium,
		/obj/item/stack/sheet/mineral/titanium,
	)

/**
 * Plastitanium Golem - Better Titanium
 *
 * Basically a better titanium golem.
 */
/datum/species/golem/plastitanium
	name = SPECIES_GOLEM_PLASTITANIUM
	golem_colour = rgb(136, 136, 136)
	skinned_type = /obj/item/stack/sheet/mineral/plastitanium
	info_text = "Будучи <span class='danger'>пластитановым големом</span>, вы крайне устойчивы к ожогам и невосприимчивы к пепельным бурям и лаве."
	burn_mod = 0.36
	prefix = "Пластитанов"
	special_names = list(
		MALE = list("Сплав", "Брусок", "Кусок", "Мужик", "Кирпич", "Минерал", "Буреходец", "Пожарник", "Лавоходец", "Лавоплавунец", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева"),
		NEUTER = null
		)
	inherent_traits = list(
		TRAIT_NO_BLOOD,
		TRAIT_NO_BREATH,
		TRAIT_NO_PAIN,
		TRAIT_RADIMMUNE,
		TRAIT_NO_GUNS,
		TRAIT_PIERCEIMMUNE,
		TRAIT_EMBEDIMMUNE,
		TRAIT_ASHSTORM_IMMUNE,
		TRAIT_LAVA_IMMUNE,
	)

/datum/species/golem/plastitanium/get_heal_material_types()
	return list(
		/obj/item/stack/ore/titanium,
		/obj/item/stack/ore/plasma,
		/obj/item/stack/sheet/mineral/titanium,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/stack/sheet/mineral/plastitanium,
	)

/**
 * Alien Alloy Golem - Best stats, but mute
 *
 * Can't speak, but has the most speed of all.
 * Also regenerates health passively.
 */
/datum/species/golem/alloy
	name = SPECIES_GOLEM_ALLOY
	golem_colour = rgb(51, 51, 51)
	skinned_type = /obj/item/stack/sheet/mineral/abductor
	language = LANGUAGE_HIVE_GOLEM
	default_language = LANGUAGE_HIVE_GOLEM
	speed_mod = 1 // Faster
	info_text = "Будучи <span class='danger'>големом из инопланетных сплавов</span>, вы быстрее двигаетесь и со временем регенерируете. Однако, вы можете разговаривать только с големами из того же материала, что и вы."
	prefix = "Инопланетн"
	special_names = list(
		MALE = list("Инопришеленец", "Технологичный Голем", "Наблюдатель", "Незнакомец", "Странник", "Чужак", "Посланник", "Минерал", "Мужик", "Пришеленец", "Пупс"),
		FEMALE = null,
		NEUTER = null
		)
	special_name_chance = 40
	chance_name_female = 30

	material_heal = 50
	amount_required_for_heal = 1
	self_heal_delay = 1 SECONDS

//Regenerates because self-repairing super-advanced alien tech
/datum/species/golem/alloy/handle_life(mob/living/carbon/human/human)
	var/update = NONE

	update |= human.heal_overall_damage(2, 2, updating_health = FALSE)
	update |= human.heal_damages(tox = 2, oxy = 2, updating_health = FALSE)

	if(update)
		human.updatehealth()

/datum/species/golem/alloy/can_understand(mob/other) // Can understand everyone, but they can only speak over their mindlink
	return TRUE

/datum/species/golem/alloy/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	LAZYREINITLIST(H.languages)
	H.add_language(LANGUAGE_HIVE_GOLEM)
	H.add_language(LANGUAGE_GREY) // Still grey enouhg to speak in psi link

/datum/species/golem/alloy/get_heal_material_types()
	return list(
		/obj/item/stack/sheet/mineral/abductor
	)

/**
 * Wood Golem
 *
 * Regenerates health slowly when in light.
 * Quite frail.
 */
/datum/species/golem/wood
	name = SPECIES_GOLEM_WOOD
	golem_colour = rgb(158, 112, 75)
	skinned_type = /obj/item/stack/sheet/wood
	inherent_traits = list(
		TRAIT_NO_BLOOD,
		TRAIT_NO_BREATH,
		TRAIT_NO_PAIN,
		TRAIT_PLANT_ORIGIN,
		TRAIT_RADIMMUNE,
		TRAIT_NO_GUNS,
		TRAIT_PIERCEIMMUNE,
		TRAIT_EMBEDIMMUNE,
	)
	brute_mod = 0.7 // 30% damage reduction down from 55%
	burn_mod = 0.875
	tox_mod = 0.7
	clone_mod = 0.7
	brain_mod = 0.7
	stamina_mod = 0.7
	heatmod = 1.5

	heat_level_1 = 300
	heat_level_2 = 340
	heat_level_3 = 400

	info_text = "Будучи <span class='danger'>деревянным големом</span>, вы обладаете некоторыми особенностями растений: Вы получаете урон от экстремальных температур, вас можно поджечь и у вас меньше брони, чем у обычного голема. Вы регенерируете на свету и увядаете во тьме."
	prefix = "Деревянн"
	special_names = list(
		MALE = list("Короед", "Грут", "Пень", "Дубень", "Дуболом", "Дуб", "Рогоз", "Сок", "Клен", "Вяз", "Тополь ", "Осина", "Ясень", "Бук", "Каштан", "Кедр", "Каштан", "Кипарис", "Пихта", "Боярышник", "Гикори", "Айронвуд", "Можжевельник", "Лист", "Мангровый Лес", "Тополь", "Редбад", "Сассафрас", "Ель", "Сумак", "Ствол", "Орех", "Тис", "Пупс"),
		FEMALE = list("Дева", "Ива", "Катальпа", "Ветка", "Тростинка", "Палка", "Береза", "Лиственница", "Липа", "Лещина", "Пальма", "Азимина", "Сосна"),
		NEUTER = list("Красное Дерево", "Редкое Дерево", "Древо")
		)
	human_surname_chance = 0
	chance_name_female = 70
	special_name_chance = 100

	amount_required_for_heal = 3

/datum/species/golem/wood/handle_life(mob/living/carbon/human/H)
	var/light_amount = 0 // How much light there is in the place, affects receiving nutrition and healing
	var/is_vamp = isvampire(H)
	if(isturf(H.loc)) // Else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.5
		if(light_amount > 0)
			H.clear_alert("nolight")
		else
			H.throw_alert("nolight", /atom/movable/screen/alert/nolight)
		if(!is_vamp)
			H.adjust_nutrition(light_amount * 10)
			if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
				H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
		if(light_amount > 0.2 && !H.suiciding) // If there's enough light, heal
			var/update = NONE
			update |= H.heal_overall_damage(1, 1, updating_health = FALSE)
			update |= H.heal_damages(tox = 1, oxy = 1, updating_health = FALSE)
			if(update)
				H.updatehealth()

	if(!is_vamp && H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.adjustBruteLoss(2)
	..()

/datum/species/golem/wood/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "glyphosate" || R.id == "atrazine")
		H.adjustToxLoss(3) // Deal aditional damage
		return TRUE
	return ..()

/datum/species/golem/wood/get_heal_material_types()
	return list(
		/obj/item/stack/sheet/wood,
	)

/**
 * Uranium Golem - Free Grief Permit
 *
 * Irradiates everyone around them. Thats all.
 */
/datum/species/golem/uranium
	name = SPECIES_GOLEM_URANIUM
	golem_colour = rgb(119, 255, 0)
	skinned_type = /obj/item/stack/ore/uranium
	info_text = "Будучи <span class='danger'>урановым големом</span>, вы излучаете радиацию. Это не вредит другим големам, но влияет на органические формы жизни."
	prefix = "Уранов"
	special_names = list(
		MALE = list("Оксид", "Стержень", "Мужик", "Сплав", "Расплав", "Светоч", "Сиятель", "Свет", "Блеск", "Лучезарец", "Луч", "Блестатель", "Пупс"),
		FEMALE = list("Яркость", "Светлость", "Яркость"),
		NEUTER = list("Сияние", "Светило")
		)
	chance_name_female = 40
	chance_name_neuter = 10
	special_name_chance = 60

	material_heal = 25
	amount_required_for_heal = 3

/datum/species/golem/uranium/handle_life(mob/living/carbon/human/user)
	for(var/mob/living/victim in range(2, user))
		if(HAS_TRAIT(victim, TRAIT_RADIMMUNE))
			continue
		victim.apply_effect(10, IRRADIATE)
		if(prob(25)) // Reduce spam
			to_chat(victim, span_danger("Вас окутывает мягкое зелёное свечение, исходящее от [user]."))
	..()

/datum/species/golem/uranium/get_heal_material_types()
	return list(
		/obj/item/stack/ore/uranium,
		/obj/item/stack/sheet/mineral/uranium,
	)

/**
 * Plastic Golem - Ventcrawlers
 *
 * Can ventcrawl when nude.
 */
/datum/species/golem/plastic
	name = SPECIES_GOLEM_PLASTIC
	prefix = "Пластиков"
	special_names = list(
		MALE = list("Стаканчик", "Сервиз"),
		FEMALE = list("Тарелка", "Посуда", "Утварь"),
		NEUTER = null
		)
	inherent_traits = list(
		TRAIT_NO_BLOOD,
		TRAIT_NO_BREATH,
		TRAIT_NO_PAIN,
		TRAIT_RADIMMUNE,
		TRAIT_NO_GUNS,
		TRAIT_PIERCEIMMUNE,
		TRAIT_EMBEDIMMUNE,
		TRAIT_VENTCRAWLER_NUDE,
	)
	golem_colour = rgb(255, 255, 255)
	skinned_type = /obj/item/stack/sheet/plastic
	info_text = "Будучи <span class='danger'>пластиковым големом</span>, вы способны ползать по вентиляции, если вы раздеты."

	material_heal = 40
	amount_required_for_heal = 4
	self_heal_delay = 1 SECONDS

/datum/species/golem/plastic/get_heal_material_types()
	return list(
		/obj/item/stack/sheet/plastic,
	)

/**
 * Sand Golem - Bulletproof
 *
 * Immune to bullets, has high brute resistance at the cost of high burn vulnerability.
 * Also dusts on death.
 */
/datum/species/golem/sand
	name = SPECIES_GOLEM_SAND
	golem_colour = rgb(255, 220, 143)
	skinned_type = /obj/item/stack/ore/glass //this is sand
	brute_mod = 0.25
	burn_mod = 3 // Melts easily
	tox_mod = 1
	clone_mod = 1
	brain_mod = 1
	stamina_mod = 1
	info_text = "Будучи <span class='danger'>песчаным големом</span>, вы невосприимчивы к физическим боеприпасам и получаете очень мало грубого урона. Однако вы чрезвычайно уязвимы к лучам лазерного и энергетического оружия, а также к ожогам. К тому же, вы превратитесь в песок после смерти, что предотвратит любую форму восстановления."
	unarmed_type = /datum/unarmed_attack/golem/sand
	prefix = "Песчан"
	special_names = list(
		MALE = list("Замок", "Берег", "Домик", "Вихрь", "Мужик", "Ураган", "Смерч", "Волчок", "Бархан", "Червь", "Шторм", "Пупс"),
		FEMALE = list("Башня"),
		NEUTER = null
		)
	special_name_chance = 30

	material_heal = 25
	self_heal_delay = 1 SECONDS

/datum/species/golem/sand/handle_death(gibbed, mob/living/carbon/human/H)
	H.visible_message(span_danger("[H] рассыпал[GEND_SYA_AS_OS_IS(H)] в кучу песка!"))
	for(var/obj/item/W in H)
		H.drop_item_ground(W)
	for(var/i=1, i <= rand(3, 5), i++)
		new /obj/item/stack/ore/glass(get_turf(H))
	qdel(H)

/datum/species/golem/sand/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H))
		if(P.flag == BULLET || P.flag == BOMB)
			playsound(H, 'sound/effects/shovel_dig.ogg', 70, TRUE)
			H.visible_message(span_danger("[P.name] тонет в песчаном теле [H] без видимого вреда здоровью!"), \
			span_userdanger("[P.name] тонет в песчаном теле [H] без видимого вреда здоровью!"), \
			projectile_message = TRUE)
			return FALSE
	return TRUE

/datum/species/golem/sand/get_heal_material_types()
	return list(
		/obj/item/stack/ore/glass,
		/obj/item/stack/ore/glass/basalt,
	)

/datum/unarmed_attack/golem/sand
	attack_sound = 'sound/effects/shovel_dig.ogg'

/**
 * Glass Golem - Laserproof
 *
 * Reflects lasers, has high burn resistance at the cost of high brute vulnerability.
 * Shatters on death.
 */
/datum/species/golem/glass
	name = SPECIES_GOLEM_GLASS
	golem_colour = rgb(90, 150, 180)
	skinned_type = /obj/item/stack/sheet/glass
	brute_mod = 3 // Very fragile
	burn_mod = 0.25
	tox_mod = 1
	clone_mod = 1
	brain_mod = 1
	stamina_mod = 1
	info_text = "Будучи <span class='danger'>стеклянным големом</span>, вы отражаете лучи лазерного и энергетического оружия, а также крайне устойчивы к ожогам. Однако вы чрезвычайно уязвимы к грубому урону и баллистическому оружию. К тому же, после смерти вы разобьётесь без всякой надежды на восстановление."
	unarmed_type = /datum/unarmed_attack/golem/glass
	prefix = "Стеклянн"
	special_names = list(
		MALE = list("Изолятор", "Изолятор Тока", "Преломлятор", "Пупс"),
		FEMALE = list("Линза", "Призма", "Бусинка", "Жемчужина", "Оптика"),
		NEUTER = list("Преломление", "Отражение", "Волокно")
		)
	chance_name_male = 50
	chance_name_female = 50
	chance_name_neuter = 30
	special_name_chance = 50

/datum/species/golem/glass/handle_death(gibbed, mob/living/carbon/human/H)
	playsound(H, SFX_SHATTER, 70, TRUE)
	H.visible_message(span_danger("[H] разбил[GEND_SYA_AS_OS_IS(H)] в дребезги!"))
	for(var/obj/item/W in H)
		H.drop_item_ground(W)
	for(var/i=1, i <= rand(3, 5), i++)
		new /obj/item/shard(get_turf(H))
	qdel(H)

/datum/species/golem/glass/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H)) // Self-shots don't reflect
		if(P.is_reflectable(REFLECTABILITY_ENERGY))
			H.visible_message(span_danger("[P.name] отражается от стеклянной кожи [H]!"), \
			span_userdanger("[P.name] отражается от стеклянной кожи [H]!"), \
			projectile_message = TRUE)

			P.reflect_back(H)

			return FALSE
	return TRUE

/datum/species/golem/sand/get_heal_material_types()
	return list(
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/plasmaglass,
	)

/datum/unarmed_attack/golem/glass
	attack_sound = 'sound/effects/glassbr2.ogg'

/**
 * Bluespace Golem - Can't touch me
 *
 * Teleports on being hit, or by will.
 */
/datum/species/golem/bluespace
	name = SPECIES_GOLEM_BLUESPACE
	golem_colour = rgb(51, 51, 255)
	skinned_type = /obj/item/stack/ore/bluespace_crystal
	info_text = "Будучи <span class='danger'>блюспейс-големом</span>, вы пространственно нестабильны: вы будете телепортироваться при получении ударов. Также вы можете телепортироваться вручную на большое расстояние."
	prefix = "Блюспейс"
	prefix_type = 3
	special_names = list(
		MALE = list("Кристалл", "Поликристалл", "Прыгун", "Скакун", "Транзит", "Прыжок", "Скачок", "Разрыв", "Мужик", "Попрыгун", "Пупс"),
		FEMALE = null,
		NEUTER = null
		)
	unarmed_type = /datum/unarmed_attack/golem/bluespace
	special_name_chance = 50
	chance_name_male = 90
	chance_name_female = 20
	var/teleport_cooldown = 100
	var/last_teleport = 0
	var/tele_range = 6

	material_heal = 35
	amount_required_for_heal = 2
	self_heal_delay = 1 SECONDS

/datum/species/golem/bluespace/proc/reactive_teleport(mob/living/carbon/human/H)
	H.visible_message(span_warning("[H] телепортировал[GEND_SYA_AS_OS_IS(H)]!"), span_danger("Вы дестабилизируетесь и телепортируетесь!"))
	var/list/turfs = new/list()
	for(var/turf/T in orange(tele_range, H))
		if(T.density)
			continue
		if(T.x>world.maxx-tele_range || T.x<tele_range)
			continue
		if(T.y>world.maxy-tele_range || T.y<tele_range)
			continue
		turfs += T
	if(!length(turfs))
		turfs += pick(/turf in orange(tele_range, H))
	var/turf/picked = pick(turfs)
	if(!isturf(picked))
		return
	if(H.buckled)
		H.buckled.unbuckle_mob(H, force = TRUE)
	do_teleport(H, picked)
	return TRUE

/datum/species/golem/bluespace/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(isitem(AM))
		I = AM
		if(locateUID(I.thrownby) == H) // No throwing stuff at yourself to trigger the teleport
			return FALSE
		else
			reactive_teleport(H)

/datum/species/golem/bluespace/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_teleport + teleport_cooldown && M != H &&  M.a_intent != INTENT_HELP)
		reactive_teleport(H)

/datum/species/golem/bluespace/spec_proceed_attack_results(obj/item/I, mob/living/carbon/human/defender, mob/living/attacker, obj/item/organ/external/affecting)
	. = ..()
	if(world.time > last_teleport + teleport_cooldown && defender != attacker && reactive_teleport(defender))
		. |= ATTACK_CHAIN_NO_AFTERATTACK

/datum/species/golem/bluespace/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(world.time > last_teleport + teleport_cooldown)
		reactive_teleport(H)
	return TRUE

/datum/species/golem/bluespace/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	var/datum/action/innate/unstable_teleport/unstable_teleport = locate() in H.actions
	if(!unstable_teleport)
		unstable_teleport = new
		unstable_teleport.Grant(H)
		last_teleport = world.time

/datum/species/golem/bluespace/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	var/datum/action/innate/unstable_teleport/unstable_teleport = locate() in H.actions
	unstable_teleport?.Remove(H)

/datum/species/golem/bluespace/get_heal_material_types()
	return list(
		/obj/item/stack/ore/bluespace_crystal,
		/obj/item/stack/sheet/bluespace_crystal,
	)

/datum/action/innate/unstable_teleport
	name = "Нестабильный телепорт"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	button_icon_state = "blink"
	var/activated = FALSE // To prevent spamming
	var/cooldown = 150
	var/last_teleport = 0
	var/tele_range = 6

/datum/action/innate/unstable_teleport/IsAvailable(feedback = FALSE)
	if(..())
		if(world.time > last_teleport + cooldown && !activated)
			return 1
		return 0

/datum/action/innate/unstable_teleport/Activate()
	activated = TRUE
	var/mob/living/carbon/human/H = owner
	H.visible_message(span_warning("[H] начинает вибрировать!"), span_danger("Вы начали заряжать своё блюспейс-ядро…"))
	playsound(get_turf(H), 'sound/weapons/flash.ogg', 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(teleport), H), 15)

/datum/action/innate/unstable_teleport/proc/teleport(mob/living/carbon/human/H)
	activated = FALSE
	H.visible_message(span_warning("[H] телепортировал[GEND_SYA_AS_OS_IS(H)]!"), span_danger("Вы телепортировались!"))
	var/list/turfs = new/list()
	for(var/turf/T in orange(tele_range, H))
		if(isspaceturf(T))
			continue
		if(T.density)
			continue
		if(T.x>world.maxx-tele_range || T.x<tele_range)
			continue
		if(T.y>world.maxy-tele_range || T.y<tele_range)
			continue
		turfs += T
	if(!length(turfs))
		turfs += pick(/turf in orange(tele_range, H))
	var/turf/picked = pick(turfs)
	if(!isturf(picked))
		return
	if(H.buckled)
		H.buckled.unbuckle_mob(H, force = TRUE)
	do_teleport(H, picked)
	last_teleport = world.time
	UpdateButtonIcon() // Action icon looks unavailable
	sleep(cooldown + 5)
	UpdateButtonIcon() // Action icon looks available again

/datum/unarmed_attack/golem/bluespace
	attack_verb = list("блюспейс ударил")
	attack_sound = 'sound/effects/phasein.ogg'

/**
 * Bananium Golem - honk
 *
 * Makes funny sounds, and makes bananas on being hit, or by will.
 */
/datum/species/golem/bananium
	name = SPECIES_GOLEM_BANANIUM
	golem_colour = rgb(255, 255, 0)
	punchdamagelow = 0
	punchdamagehigh = 1
	punchstunthreshold = 2 // Harmless and can't stun
	skinned_type = /obj/item/stack/ore/bananium
	info_text = "Будучи <span class='danger'>бананиевым големом</span>, вы созданы для розыгрышей. Ваше тело издает естественные гудки, и удары по людям издают безвредные гудки. Если вас ранить, вы будете бананоточить."
	prefix = "Бананиев"
	special_names = list(
		MALE = null,
		FEMALE = null,
		NEUTER = null,
	)
	unarmed_type = /datum/unarmed_attack/golem/bananium
	default_genes = list(/datum/dna/gene/disability/comic)

	var/last_honk = 0
	var/honkooldown = 0
	var/last_banana = 0
	var/banana_cooldown = 100
	var/active = null

	material_heal = 80 // honk
	amount_required_for_heal = 2
	self_heal_delay = 1 SECONDS

/datum/species/golem/bananium/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	last_banana = world.time
	last_honk = world.time
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/bottle/bottleofbanana(H), ITEM_SLOT_POCKET_RIGHT)
	H.equip_to_slot_or_del(new /obj/item/bikehorn(H), ITEM_SLOT_POCKET_LEFT)
	H.AddElement(/datum/element/waddling)

/datum/species/golem/bananium/handle_dna(mob/living/carbon/human/H, remove = FALSE)
	H.force_gene_block(GLOB.comicblock, !remove, TRUE, TRUE)

/datum/species/golem/bananium/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.RemoveElement(/datum/element/waddling)

/datum/species/golem/bananium/get_random_name()
	var/clown_name = pick(GLOB.clown_names)
	var/golem_name = "[prefix][GOLEM_END_PR_1(gender_name)] [clown_name]"
	return golem_name

/datum/species/golem/bananium/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_banana + banana_cooldown && M != H &&  M.a_intent != INTENT_HELP)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/spec_proceed_attack_results(obj/item/I, mob/living/carbon/human/defender, mob/living/attacker, obj/item/organ/external/affecting)
	. = ..()
	if(world.time > last_banana + banana_cooldown && defender != attacker)
		new /obj/item/grown/bananapeel/specialpeel(get_turf(defender))
		last_banana = world.time

/datum/species/golem/bananium/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(world.time > last_banana + banana_cooldown)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time
	return TRUE

/datum/species/golem/bananium/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(isitem(AM))
		I = AM
		if(locateUID(I.thrownby) == H) // No throwing stuff at yourself to make bananas
			return FALSE
		else
			new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
			last_banana = world.time

/datum/species/golem/bananium/handle_life(mob/living/carbon/human/H)
	if(!active)
		if(world.time > last_honk + honkooldown)
			active = 1
			playsound(get_turf(H), 'sound/items/bikehorn.ogg', 50, TRUE)
			last_honk = world.time
			honkooldown = rand(20, 80)
			active = null
	..()

/datum/species/golem/bananium/handle_death(gibbed, mob/living/carbon/human/H)
	playsound(get_turf(H), 'sound/misc/sadtrombone.ogg', 70, FALSE)

/datum/species/golem/bananium/get_heal_material_types()
	return list(
		/obj/item/stack/ore/bananium,
		/obj/item/stack/sheet/mineral/bananium,
	)

/datum/unarmed_attack/golem/bananium
	attack_verb = list("хонкнул")
	attack_sound = 'sound/items/airhorn2.ogg'
	animation_type = ATTACK_EFFECT_DISARM
	harmless = TRUE

/**
 * Tranquillite Golem - ...
 *
 * Mime, but golem.
 */
/datum/species/golem/tranquillite
	name = SPECIES_GOLEM_TRANQUILLITITE
	prefix = "Транквилитов"
	special_names = list(
		MALE = null,
		FEMALE = null,
		NEUTER = null,
	)
	golem_colour = rgb(255, 255, 255)
	skinned_type = /obj/item/stack/ore/tranquillite
	info_text = "Будучи <span class='danger'>транквилитовым големом</span>, вы можете создавать невидимые стены и регенерировать, выпивая бутылки с ничем."
	unarmed_type = /datum/unarmed_attack/golem/tranquillite

	material_heal = 40
	amount_required_for_heal = 1

/datum/species/golem/tranquillite/get_random_name()
	var/mime_name = pick(GLOB.mime_names)
	var/golem_name = "[prefix][GOLEM_END_PR_1(gender_name)] [mime_name]"
	return golem_name

/datum/species/golem/tranquillite/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	H.equip_to_slot_or_del(new	/obj/item/clothing/head/beret(H), ITEM_SLOT_HEAD)
	H.equip_to_slot_or_del(new	/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing(H), ITEM_SLOT_POCKET_RIGHT)
	H.equip_to_slot_or_del(new	/obj/item/cane(H), ITEM_SLOT_HAND_LEFT)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/conjure/build/mime_wall(null))
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/mime/speak(null))
		H.mind.miming = TRUE

/datum/species/golem/tranquillite/get_heal_material_types()
	return list(
		/obj/item/stack/ore/tranquillite,
		/obj/item/stack/sheet/mineral/tranquillite,
	)

/datum/unarmed_attack/golem/tranquillite
	attack_sound = null

/**
 * Clockwork Golem - Servant of Ratvar
 *
 * Fragile but empowered by Ratvar. Becomes a clock cultist upon creation.
 * Features brass construction and special cult abilities.
 */
/datum/species/golem/clockwork
	name = SPECIES_GOLEM_CLOCKWORK
	prefix = "Латунн"
	special_names = null
	golem_colour = rgb(176, 136, 32)
	skinned_type = /obj/item/stack/sheet/brass
	info_text = "Будучи <span class='danger'>латунный големом</span>, вы очень хрупкие, но взамен имеете силу Ратвара."
	special_names = list(
		MALE = list("Сплав", "Брусок", "Кусок", "Мужик", "Кирпич", "Минерал", "Буреходец", "Пожарник", "Лавоходец", "Лавоплавунец", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева"),
		NEUTER = null,
	)
	speed_mod = 0
	chance_name_male = 70
	chance_name_neuter = 10
	special_name_chance = 40

	material_heal = 40
	amount_required_for_heal = 2
	self_heal_delay = 1 SECONDS

/datum/species/golem/clockwork/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	if(!isclocker(H))
		SSticker.mode.add_clocker(H.mind)

/datum/species/golem/clockwork/handle_death(gibbed, mob/living/carbon/human/H)
	H.visible_message(span_danger("[H] crumbles into cogs and gears! Then leftovers suddenly dusts!"))
	for(var/obj/item/W in H)
		H.drop_item_ground(W)
	new /obj/item/clockwork/clockgolem_remains(get_turf(H))
	H.dust() // One-try only

/datum/species/golem/clockwork/get_heal_material_types()
	return list(
		/obj/item/stack/sheet/brass,
	)

#undef GOLEM_END_PR_1
#undef GOLEM_END_PR_2
