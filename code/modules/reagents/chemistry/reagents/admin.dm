/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Админордразин"
	id = "adminordrazine"
	description = "Это магия. Тут нечего объяснять."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	process_flags = ORGANIC | SYNTHETIC	//Adminbuse knows no bounds!
	can_synth = FALSE
	taste_description = "админ абуза"
	tags = REAGENT_TAG_ANTI_STUN

/datum/reagent/medicine/adminordrazine/on_mob_life(mob/living/carbon/M)
	M.setOxyLoss(0, FALSE)
	M.adjustCloneLoss(-5, FALSE)
	M.cure_radiation()
	M.adjustBruteLoss(-5, FALSE)
	M.adjustFireLoss(-5, FALSE)
	M.adjustToxLoss(-5, FALSE)
	M.adjustBrainLoss(-5, FALSE)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/obj/item/organ/internal/organ as anything in H.internal_organs)
			organ.internal_receive_damage(-5)
		for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
			if(!prob(40))
				continue

			bodypart.mend_fracture()
			bodypart.stop_internal_bleeding()
			bodypart.stop_arterial_bleeding()
			bodypart.stop_bleeding()
		H.remove_all_parasites()
	M.SetEyeBlind(0)
	M.CureNearsighted(FALSE)
	M.CureBlind(FALSE)
	M.CureMute()
	M.CureDeaf()
	M.CureEpilepsy()
	M.CureTourettes()
	M.CureCoughing()
	M.CureNervous()
	M.SetEyeBlurry(0)
	M.SetDisgust(0)
	M.SetWeakened(0)
	M.SetKnockdown(0)
	M.SetStunned(0)
	M.SetImmobilized(0)
	M.SetParalysis(0)
	M.SetSilence(0)
	M.SetHallucinate(0)
	M.SetDeaf(0)
	M.SetDizzy(0)
	M.SetDrowsy(0)
	M.SetStuttering(0)
	M.SetSlur(0)
	M.SetConfused(0)
	M.SetSleeping(0)
	M.SetJitter(0)
	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(D.severity == DISEASE_SEVERITY_POSITIVE)
			continue
		D.cure(need_immunity = FALSE)
	..()
	return STATUS_UPDATE_ALL

/datum/reagent/medicine/adminordrazine/nanites
	name = "Наниты"
	id = "nanites"
	description = "Наномашины, способствующие быстрой регенерации клеточной структуры."
	taste_description = "наномашин, сынок"

/datum/reagent/admin_cleaner
	name = "WD-2381"
	color = "#da9eda"
	can_synth = FALSE
	description = "Супер-пузырьковое чистящее средство, предназначенное для очистки всех предметов. Или, ну, всего, что не прикручено. Или прикуручено, если уж на то пошло. Другими словами: если вы это видите, как вы это заполучили?"

/datum/reagent/admin_cleaner/organic
	name = "WD-2381-MOB"
	id = "admincleaner_mob"
	description = "Бутылочка со странными нанитами, мгновенно пожирающими тела, как живые, так и мёртвые, а также органы."

/datum/reagent/admin_cleaner/organic/reaction_mob(mob/living/M, method, volume, show_message)
	. = ..()
	if(method == REAGENT_TOUCH)
		M.dust()

/datum/reagent/admin_cleaner/organic/reaction_obj(obj/O, volume)
	if(is_organ(O))
		qdel(O)
	if(istype(O, /obj/effect/decal/cleanable/blood) || istype(O, /obj/effect/decal/cleanable/vomit))
		qdel(O)
	if(is_mmi(O))
		qdel(O)

/datum/reagent/admin_cleaner/item
	name = "WD-2381-ITM"
	id = "admincleaner_item"
	description = "Бутылочка со странными нанитами, которые мгновенно пожирают предметы, оставляя всё остальное нетронутым."

/datum/reagent/admin_cleaner/item/reaction_obj(obj/O, volume)
	if(isitem(O) && !istype(O, /obj/item/grenade/clusterbuster/segment))
		qdel(O)

/datum/reagent/admin_cleaner/all
	name = "WD-2381-ALL"
	id = "admincleaner_all"
	description = "Невероятно опасный набор нанитов, созданный Уборщиками \"Синдиката\", которые пожирают всё, к чему прикасаются."

/datum/reagent/admin_cleaner/all/reaction_obj(obj/O, volume)
	if(istype(O, /obj/item/grenade/clusterbuster/segment))
		// don't clear clusterbang segments
		// I'm allowed to make this hack because this is admin only anyway
		return
	if(!iseffect(O))
		qdel(O)

/datum/reagent/admin_cleaner/all/reaction_mob(mob/living/M, method, volume, show_message)
	. = ..()
	if(method == REAGENT_TOUCH)
		M.dust()

/datum/reagent/napalm/sticky
	name = "Липкий напалм"
	id = "stickynapalm"
	description = "Особая смесь напалма: более липкая и горит дольше, но наносит меньше урона"
	color = "#f8e3b2"
	burncolor = "#f8e3b2"
	burn_sprite = "dynamic"
	intensitymod = 1.5
	durationmod = 5
	radiusmod = 0.5
	properties = list(
		PROPERTY_INTENSITY = BURN_LEVEL_TIER_2,
		PROPERTY_DURATION = BURN_TIME_TIER_5,
		PROPERTY_RADIUS = 5,
	)

/datum/reagent/napalm/high_damage
	name = "Высокогорючее напалмовое топливо"
	id = "highdamagenapalm"
	description = "Особая смесь напалма: наносит больше урона, но менее липкая"
	color = "#c51c1c"
	burncolor = "#c51c1c"
	burn_sprite = "dynamic"
	intensitymod = 4.5
	durationmod = -1
	radiusmod = -0.5
	properties = list(
		PROPERTY_INTENSITY = BURN_LEVEL_TIER_8,
		PROPERTY_DURATION = BURN_TIME_TIER_1,
		PROPERTY_RADIUS = 5,
	)

// This is the regular flamer fuel and pyro regular flamer fuel.
/datum/reagent/napalm/ut
	name = "Топливо UT-Нафтал"
	id = "utnapthal"
	description = "Известное как сверхгустое нафталовое топливо — липкая горючая жидкая химическая субстанция, обычно используемая в огнемётах."
	burncolor = "#EE6515"
	properties = list(
		PROPERTY_INTENSITY = BURN_LEVEL_TIER_5,
		PROPERTY_DURATION = BURN_TIME_TIER_2,
		PROPERTY_RADIUS = 5,
	)

// Weaker liquid fuel
/datum/reagent/napalm/weak
	name = "Нафталовое топливо"
	id = "napthal"
	description = "Известное как нафталовое топливо — горючая жидкая химическая субстанция."
	burncolor = "#ee6515"
	properties = list(
		PROPERTY_INTENSITY = BURN_LEVEL_TIER_2,
		PROPERTY_DURATION = BURN_TIME_TIER_2,
		PROPERTY_RADIUS = 5,
	)

// This is gellie fuel. Green Flames.
/datum/reagent/napalm/gel
	name = "Напалм B-Гель"
	id = "napalmgel"
	description = "В отличие от своих жидких аналогов, этот гелевый вариант напалма легко тушится, но разбрызгивается далеко и остаётся на земле в виде вязкой массы, реагируя с неорганическими материалами и поджигая их."
	color = COLOR_GREEN
	burncolor = COLOR_GREEN
	burn_sprite = "green"
	properties = list(
		PROPERTY_INTENSITY = BURN_LEVEL_TIER_2,
		PROPERTY_DURATION = BURN_TIME_TIER_5,
		PROPERTY_RADIUS = 7,
	)
	fire_type = FIRE_VARIANT_TYPE_B //Armor Shredding Greenfire

// This is the blue flamer fuel for the pyro.
/datum/reagent/napalm/blue
	name = "Напалм X"
	id = "napalmx"
	description = "Липкая горючая жидкая химическая субстанция, горящая чрезвычайно горячо."
	color = "#00b8ff"
	burncolor = "#00b8ff"
	burn_sprite = "blue"
	properties = list(
		PROPERTY_INTENSITY = BURN_LEVEL_TIER_7,
		PROPERTY_DURATION = BURN_TIME_TIER_4,
		PROPERTY_RADIUS = 6,
	)

/datum/reagent/napalm/hellfire
	name = "Жидкое адское пламя"
	id = "hellfire"
	description = "Адское пламя, превращённое в вещество неизвестными силами."
	burncolor = "#EE6515"
	properties = list(
		PROPERTY_INTENSITY = BURN_LEVEL_TIER_2,
		PROPERTY_DURATION = BURN_TIME_TIER_1,
		PROPERTY_RADIUS = 3,
	)

// This is the green flamer fuel for the pyro.
/datum/reagent/napalm/green
	name = "Напалм B"
	id = "napalmb"
	description = "Особый вариант напалма, который плохо прилипает к чему-либо, но распространяется на широкой площади, горя медленно. Состав реагирует с неорганическими материалами, поджигая их и нанося серьёзный урон."
	flameshape = FLAMESHAPE_TRIANGLE
	color = COLOR_GREEN
	burncolor = COLOR_GREEN
	burn_sprite = "green"
	properties = list(
		PROPERTY_INTENSITY = BURN_LEVEL_TIER_2,
		PROPERTY_DURATION = BURN_TIME_TIER_5,
		PROPERTY_RADIUS = 6,
	)
	fire_type = FIRE_VARIANT_TYPE_B //Armor Shredding Greenfire

/datum/reagent/napalm/penetrating
	name = "Напалм E"
	id = "napalme"
	description = "Липкая горючая жидкая химическая субстанция, проникающая сквозь лучшие огнезащитные составы."
	color = COLOR_PURPLE
	burncolor = COLOR_PURPLE
	burn_sprite = "dynamic"
	properties = list(
		PROPERTY_INTENSITY = BURN_LEVEL_TIER_2,
		PROPERTY_DURATION = BURN_TIME_TIER_5,
		PROPERTY_RADIUS = 6,
		PROPERTY_FIRE_PENETRATING = 1,
	)

/datum/reagent/napalm/deathsquad //version of fuel for dsquad flamers.
	name = "Напалм EX"
	id = "napalmex"
	description = "Липкая горючая жидкая химическая субстанция, состоящая из комбинации редких и опасных реагентов, которая проникает сквозь лучшие огнезащитные составы и горит чрезвычайно горячо."
	color = "#641dd6"
	burncolor = "#641dd6"
	burn_sprite = "dynamic"
	intensityfire = BURN_LEVEL_TIER_7
	durationfire = BURN_TIME_TIER_4
	rangefire = 6
	properties = list(
		PROPERTY_INTENSITY = BURN_LEVEL_TIER_7,
		PROPERTY_DURATION = BURN_TIME_TIER_4,
		PROPERTY_RADIUS = 6,
		PROPERTY_FIRE_PENETRATING = 1,
	)

/datum/reagent/napalm/upp
	name = "R189"
	id = "R189"
	description = "Химическое вещество СПП: горит при чрезвычайно высокой температуре и предназначено для прожигания непосредственно укреплённых позиций или бункеров."
	color = "#ffe49c"
	burncolor = "#ffe49c"
	burn_sprite = "dynamic"
	properties = list(
		PROPERTY_INTENSITY = BURN_LEVEL_TIER_9,
		PROPERTY_DURATION = BURN_TIME_TIER_3,
		PROPERTY_RADIUS = 6,
		PROPERTY_FIRE_PENETRATING = 1,
	)
