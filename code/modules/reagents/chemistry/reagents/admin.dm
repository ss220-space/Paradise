/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Админордразин"
	id = "adminordrazine"
	description = "Это магия. Тут нечего объяснять."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	process_flags = ORGANIC | SYNTHETIC	//Adminbuse knows no bounds!
	can_synth = FALSE
	taste_description = "админ абуза"

/datum/reagent/medicine/adminordrazine/on_mob_life(mob/living/carbon/M)
	M.setCloneLoss(0, FALSE)
	M.setOxyLoss(0, FALSE)
	M.radiation = 0
	M.adjustBruteLoss(-5, FALSE)
	M.adjustFireLoss(-5, FALSE)
	M.adjustToxLoss(-5, FALSE)
	M.setBrainLoss(0, FALSE)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/obj/item/organ/internal/organ as anything in H.internal_organs)
			organ.internal_receive_damage(-5)
		for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
			bodypart.mend_fracture()
			bodypart.stop_internal_bleeding()
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
	REMOVE_TRAITS_NOT_IN(M, list(ROUNDSTART_TRAIT))
	M.SetDizzy(0)
	M.SetDrowsy(0)
	M.SetStuttering(0)
	M.SetSlur(0)
	M.SetConfused(0)
	M.SetSleeping(0)
	M.SetJitter(0)
	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(D.severity == NONTHREAT)
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
	if(istype(O, /obj/item/mmi))
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
	description = "Невероятно опасный набор нанитов, созданный Уборщиками Синдиката, которые пожирают всё, к чему прикасаются."

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


/datum/reagent/napalm
	name = "Napalm"
	id = "napalm"
	description = "This will probably ignite before you get to read this."
	reagent_state = LIQUID
	color = "#ffb300"
	chemfiresupp = TRUE
	burncolor = "#D05006"
	burn_sprite = "red"

/datum/reagent/napalm/sticky
	name = "Sticky-Napalm"
	id = "stickynapalm"
	description = "A custom napalm mix, stickier and lasts longer but lower damage"
	reagent_state = LIQUID
	color = "#f8e3b2"
	burncolor = "#f8e3b2"
	burn_sprite = "dynamic"
	intensitymod = -1.5
	durationmod = -5
	radiusmod = -0.5
	intensityfire = BURN_LEVEL_TIER_2
	durationfire = BURN_TIME_TIER_5
	rangefire = 5

/datum/reagent/napalm/high_damage
	name = "High-Combustion Napalm Fuel"
	id = "highdamagenapalm"
	description = "A custom napalm mix, higher damage but not as sticky"
	reagent_state = LIQUID
	color = "#c51c1c"
	burncolor = "#c51c1c"
	burn_sprite = "dynamic"
	intensitymod = -4.5
	durationmod = -1
	radiusmod = -0.5
	intensityfire = BURN_LEVEL_TIER_8
	durationfire = BURN_TIME_TIER_1
	rangefire = 5

// This is the regular flamer fuel and pyro regular flamer fuel.
/datum/reagent/napalm/ut
	name = "UT-Napthal Fuel"
	id = "utnapthal"
	description = "Known as Ultra Thick Napthal Fuel, a sticky combustible liquid chemical, typically used with flamethrowers."
	burncolor = "#EE6515"
	intensityfire = BURN_LEVEL_TIER_5
	durationfire = BURN_TIME_TIER_2
	rangefire = 5

// This is gellie fuel. Green Flames.
/datum/reagent/napalm/gel
	name = "Napalm B-Gel"
	id = "napalmgel"
	description = "Unlike its liquid contemporaries, this gelled variant of napalm is easily extinguished, but shoots far and lingers on the ground in a viscous mess, while reacting with inorganic materials to ignite them."
	flameshape = FLAMESHAPE_LINE
	color = COLOR_GREEN
	burncolor = COLOR_GREEN
	burn_sprite = "green"
	intensityfire = BURN_LEVEL_TIER_2
	durationfire = BURN_TIME_TIER_5
	rangefire = 7
	fire_type = FIRE_VARIANT_TYPE_B //Armor Shredding Greenfire

// This is the blue flamer fuel for the pyro.
/datum/reagent/napalm/blue
	name = "Napalm X"
	id = "napalmx"
	description = "A sticky combustible liquid chemical that burns extremely hot."
	color = "#00b8ff"
	burncolor = "#00b8ff"
	burn_sprite = "blue"
	intensityfire = BURN_LEVEL_TIER_7
	durationfire = BURN_TIME_TIER_4
	rangefire = 5

// This is the green flamer fuel for the pyro.
/datum/reagent/napalm/green
	name = "Napalm B"
	id = "napalmb"
	description = "A special variant of napalm that's unable to cling well to anything, but disperses over a wide area while burning slowly. The composition reacts with inorganic materials to ignite them, causing severe damage."
	flameshape = FLAMESHAPE_TRIANGLE
	color = COLOR_GREEN
	burncolor = COLOR_GREEN
	burn_sprite = "green"
	intensityfire = BURN_LEVEL_TIER_2
	durationfire = BURN_TIME_TIER_5
	rangefire = 6
	fire_type = FIRE_VARIANT_TYPE_B //Armor Shredding Greenfire

/datum/reagent/napalm/penetrating
	name = "Napalm E"
	id = "napalme"
	description = "A sticky combustible liquid chemical that penetrates the best fire retardants."
	color = COLOR_PURPLE
	burncolor = COLOR_PURPLE
	burn_sprite = "dynamic"
	intensityfire = BURN_LEVEL_TIER_2
	durationfire = BURN_TIME_TIER_5
	rangefire = 6
	fire_penetrating = TRUE

/datum/reagent/napalm/deathsquad //version of fuel for dsquad flamers.
	name = "Napalm EX"
	id = "napalmex"
	description = "A sticky combustible liquid chemical made up of a combonation of rare and dangerous reagents both that penetrates the best fire retardants, and burns extremely hot."
	color = "#641dd6"
	burncolor = "#641dd6"
	burn_sprite = "dynamic"
	intensityfire = BURN_LEVEL_TIER_7
	durationfire = BURN_TIME_TIER_4
	rangefire = 6
	fire_penetrating = TRUE

/datum/reagent/napalm/upp
	name = "R189"
	id = "R189"
	description = "A UPP chemical, it burns at an extremely high tempature and is designed to melt directly through fortified positions or bunkers."
	color = "#ffe49c"
	burncolor = "#ffe49c"
	burn_sprite = "dynamic"
	intensityfire = BURN_LEVEL_TIER_9
	durationfire = BURN_TIME_TIER_3
	rangefire = 6
	fire_penetrating = TRUE

