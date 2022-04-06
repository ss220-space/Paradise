/*
// Frankly, this is just for chemicals that are sortof 'watery', which really didn't seem to fit under any other file
// Current chems: Water, Space Lube, Space Cleaner, Blood, Fish Water, Holy water
//
//
*/



/datum/reagent/water
	name = "Вода"
	id = "water"
	description = "Вездесущее химическое вещество. Состоит из водорода и кислорода."
	reagent_state = LIQUID
	color = "#0064C8" // rgb: 0, 100, 200
	taste_description = "воды"
	var/cooling_temperature = 2
	process_flags = ORGANIC | SYNTHETIC
	drink_icon = "glass_clear"
	drink_name = "Стакан воды"
	drink_desc = "Отец всех освежающих напитков."
	var/water_temperature = 283.15 // As reagents don't have a temperature value, we'll just use 10 celsius.

/datum/reagent/water/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	M.water_act(volume, water_temperature, src, method)

/datum/reagent/water/reaction_turf(turf/T, volume)
	T.water_act(volume, water_temperature, src)
	var/obj/effect/acid/A = (locate(/obj/effect/acid) in T)
	if(A)
		A.acid_level = max(A.acid_level - volume*  50, 0)

/datum/reagent/water/reaction_obj(obj/O, volume)
	O.water_act(volume, water_temperature, src)

/datum/reagent/lube
	name = "Космическая смазка" // Space Lube
	id = "lube"
	description = "Смазка представляет собой вещество, вводимое между двумя движущимися поверхностями для уменьшения износа и трения между ними. Хи-хи-хи."
	reagent_state = LIQUID
	color = "#1BB1AB"
	harmless = TRUE
	taste_description = "вишни"

/datum/reagent/lube/reaction_turf(turf/simulated/T, volume)
	if(volume >= 1 && istype(T))
		T.MakeSlippery(TURF_WET_LUBE)


/datum/reagent/space_cleaner
	name = "Космический очиститель" // Space cleaner
	id = "cleaner"
	description = "Состав для чистки вещей. Теперь на 50 % больше гипохлорита натрия!"
	reagent_state = LIQUID
	color = "#61C2C2"
	harmless = TRUE
	taste_description = "очистителя для пола"

/datum/reagent/space_cleaner/reaction_obj(obj/O, volume)
	if(is_cleanable(O))
		var/obj/effect/decal/cleanable/blood/B = O
		if(!(istype(B) && B.off_floor))
			qdel(O)
	else
		if(O.simulated)
			O.color = initial(O.color)
		O.clean_blood()

/datum/reagent/space_cleaner/reaction_turf(turf/T, volume)
	if(volume >= 1)
		var/floor_only = TRUE
		for(var/obj/effect/decal/cleanable/C in T)
			var/obj/effect/decal/cleanable/blood/B = C
			if(istype(B) && B.off_floor)
				floor_only = FALSE
			else
				qdel(C)
		T.color = initial(T.color)
		if(floor_only)
			T.clean_blood()

		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(5, 10))

/datum/reagent/space_cleaner/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	M.clean_blood()

/datum/reagent/blood
	data = list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=null,"blood_colour"="#A10808","resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null, "dna" = null)
	name = "Кровь" // Blood
	id = "blood"
	reagent_state = LIQUID
	color = "#770000" // rgb: 40, 0, 0
	metabolization_rate = 5 //fast rate so it disappears fast.
	drink_icon = "glass_red"
	drink_name = "Стакан томатного сока"
	drink_desc = "Вы уверены что это томатный сок?"
	taste_description = "<span class='warning'>крови</span>"
	taste_mult = 1.3

/datum/reagent/blood/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(data && data["viruses"])
		for(var/thing in data["viruses"])
			var/datum/disease/D = thing

			if(D.spread_flags & SPECIAL || D.spread_flags & NON_CONTAGIOUS)
				continue

			if(method == REAGENT_TOUCH)
				M.ContractDisease(D)
			else //ingest, patch or inject
				M.ForceContractDisease(D)

	if(method == REAGENT_INGEST && iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.get_blood_id() == "blood")
			if((!data || !(data["blood_type"] in get_safe_blood(C.dna.blood_type))))
				C.reagents.add_reagent("toxin", volume * 0.5)
			else
				C.blood_volume = min(C.blood_volume + round(volume, 0.1), BLOOD_VOLUME_NORMAL)

/datum/reagent/blood/on_new(list/data)
	if(istype(data))
		SetViruses(src, data)

/datum/reagent/blood/on_merge(list/mix_data)
	if(data && mix_data)
		data["cloneable"] = 0 //On mix, consider the genetic sampling unviable for pod cloning, or else we won't know who's even getting cloned, etc
		if(data["viruses"] || mix_data["viruses"])

			var/list/mix1 = data["viruses"]
			var/list/mix2 = mix_data["viruses"]

			// Stop issues with the list changing during mixing.
			var/list/to_mix = list()

			for(var/datum/disease/advance/AD in mix1)
				to_mix += AD
			for(var/datum/disease/advance/AD in mix2)
				to_mix += AD

			var/datum/disease/advance/AD = Advance_Mix(to_mix)
			if(AD)
				var/list/preserve = list(AD)
				for(var/D in data["viruses"])
					if(!istype(D, /datum/disease/advance))
						preserve += D
				data["viruses"] = preserve

		if(mix_data["blood_color"])
			color = mix_data["blood_color"]
	return 1

/datum/reagent/blood/on_update(atom/A)
	if(data["blood_color"])
		color = data["blood_color"]
	return ..()

/datum/reagent/blood/reaction_turf(turf/simulated/T, volume)//splash the blood all over the place
	if(!istype(T))
		return
	if(volume < 3)
		return
	if(!data["donor"] || istype(data["donor"], /mob/living/carbon/human))
		var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T //find some blood here
		if(!blood_prop) //first blood!
			blood_prop = new(T)
			blood_prop.blood_DNA[data["blood_DNA"]] = data["blood_type"]

	else if(istype(data["donor"], /mob/living/carbon/alien))
		var/obj/effect/decal/cleanable/blood/xeno/blood_prop = locate() in T
		if(!blood_prop)
			blood_prop = new(T)
			blood_prop.blood_DNA["НЕИЗВЕСТНАЯ СТРУКТУРА ДНК"] = "X*"

/datum/reagent/vaccine
	//data must contain virus type
	name = "Вакцина" // Vaccine
	id = "vaccine"
	color = "#C81040" // rgb: 200, 16, 64
	taste_description = "антител"

/datum/reagent/vaccine/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(islist(data) && (method == REAGENT_INGEST))
		for(var/thing in M.viruses)
			var/datum/disease/D = thing
			if(D.GetDiseaseID() in data)
				D.cure()
		M.resistances |= data

/datum/reagent/vaccine/on_merge(list/data)
	if(istype(data))
		data |= data.Copy()

/datum/reagent/fishwater
	name = "Аквариумная вода" // Fish Water
	id = "fishwater"
	description = "Вонючая вода из аквариума. Отвратительно!"
	reagent_state = LIQUID
	color = "#757547"
	taste_description = "рвоты"

/datum/reagent/fishwater/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST)
		to_chat(M, "Боже, почему вы это выпили?")

/datum/reagent/fishwater/on_mob_life(mob/living/M)
	if(prob(30))		// Nasty, you drank this stuff? 30% chance of the fakevomit (non-stunning version)
		if(prob(50))	// 50/50 chance of green vomit vs normal vomit
			M.fakevomit(1)
		else
			M.fakevomit(0)
	return ..()

/datum/reagent/fishwater/toiletwater
	name = "Туалетная вода" // Toilet Water
	id = "toiletwater"
	description = "Вонючая вода, взятая из грязного унитаза. Абсолютно отвратительно."
	reagent_state = LIQUID
	color = "#757547"
	taste_description = "туалетного слива… или даже хуже"

/datum/reagent/fishwater/toiletwater/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume) //For shennanigans
	return

/datum/reagent/holywater
	name = "Вода"
	id = "holywater"
	description = "Вездесущее химическое вещество. Состоит из водорода и кислорода."
	reagent_state = LIQUID
	color = "#0064C8" // rgb: 0, 100, 200
	process_flags = ORGANIC | SYNTHETIC
	drink_icon = "glass_clear"
	drink_name = "Стакан воды"
	drink_desc = "Отец всех освежающих напитков."
	taste_description = "воды"

/datum/reagent/holywater/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustJitter(-5)
	if(current_cycle >= 30)		// 12 units, 60 seconds @ metabolism 0.4 units & tick rate 2.0 sec
		M.AdjustStuttering(4, bound_lower = 0, bound_upper = 20)
		M.Dizzy(5)
		if(iscultist(M))
			for(var/datum/action/innate/cult/blood_magic/BM in M.actions)
				for(var/datum/action/innate/cult/blood_spell/BS in BM.spells)
					to_chat(M, "<span class='cultlarge'>Святая вода очищает ваше тело, и ритуалы течения крови в нём нарушаются!</span>")
					qdel(BS)
			if(prob(5))
				M.AdjustCultSlur(5)//5 seems like a good number...
				M.say(pick("Av'te Nar'sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","Egkau'haom'nai en Chaous","Ho Diak'nos tou Ap'iron","R'ge Na'sie","Diabo us Vo'iscum","Si gn'um Co'nu"))
	if(current_cycle >= 75 && prob(33))	// 30 units, 150 seconds
		M.AdjustConfused(3)
		if(isvampirethrall(M))
			SSticker.mode.remove_vampire_mind(M.mind)
			holder.remove_reagent(id, volume)
			M.SetJitter(0)
			M.SetStuttering(0)
			M.SetConfused(0)
			return
		if(iscultist(M))
			SSticker.mode.remove_cultist(M.mind)
			holder.remove_reagent(id, volume)	// maybe this is a little too perfect and a max() cap on the statuses would be better??
			M.SetJitter(0)
			M.SetStuttering(0)
			M.SetConfused(0)
			if(ishuman(M)) // Unequip all cult clothing
				var/mob/living/carbon/human/H = M
				for(var/I in H.contents - (H.bodyparts | H.internal_organs)) // Satanic liver NYI
					if(is_type_in_list(I, CULT_CLOTHING))
						H.unEquip(I)
			return
	if(ishuman(M) && M.mind && M.mind.vampire && !M.mind.vampire.get_ability(/datum/vampire_passive/full) && prob(80))
		var/mob/living/carbon/V = M
		if(M.mind.vampire.bloodusable)
			M.Stuttering(1)
			M.Jitter(30)
			update_flags |= M.adjustStaminaLoss(5, FALSE)
			if(prob(20))
				M.emote("scream")
			M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
			M.mind.vampire.bloodusable = max(M.mind.vampire.bloodusable - 3,0)
			if(M.mind.vampire.bloodusable)
				V.vomit(0,1)
			else
				holder.remove_reagent(id, volume)
				V.vomit(0,0)
				return
		else
			switch(current_cycle)
				if(1 to 4)
					to_chat(M, "<span class = 'warning'>В ваших венах что-то шипит !</span>")
					M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
				if(5 to 12)
					to_chat(M, "<span class = 'danger'>Вы чувствуете внутри сильное жжение!</span>")
					update_flags |= M.adjustFireLoss(1, FALSE)
					M.Stuttering(1)
					M.Jitter(20)
					if(prob(20))
						M.emote("scream")
					M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
				if(13 to INFINITY)
					to_chat(M, "<span class = 'danger'>Вы вдруг воспламеняетесь священным пламенем!</span>")
					for(var/mob/O in viewers(M, null))
						O.show_message(text("<span class = 'danger'>[] вдруг загорается!</span>", M), 1)
					M.fire_stacks = min(5,M.fire_stacks + 3)
					M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
					update_flags |= M.adjustFireLoss(3, FALSE)		//Hence the other damages... ain't I a bastard?
					M.Stuttering(1)
					M.Jitter(30)
					if(prob(40))
						M.emote("scream")
					M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
	return ..() | update_flags


/datum/reagent/holywater/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	// Vampires have their powers weakened by holy water applied to the skin.
	if(ishuman(M) && M.mind && M.mind.vampire && !M.mind.vampire.get_ability(/datum/vampire_passive/full))
		var/mob/living/carbon/human/H=M
		if(method == REAGENT_TOUCH)
			if(H.wear_mask)
				to_chat(H, "<span class='warning'>Маска защищает вас от святой воды!</span>")
				return
			else if(H.head)
				to_chat(H, "<span class='warning'>Шлем защищает вас от святой воды!</span>")
				return
			else
				to_chat(M, "<span class='warning'>Что-то святое мешает вашим силам!</span>")
				M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)


/datum/reagent/holywater/reaction_turf(turf/simulated/T, volume)
	if(!istype(T))
		return
	if(volume>=10)
		for(var/obj/effect/rune/R in T)
			qdel(R)
	T.Bless()

/datum/reagent/fuel/unholywater		//if you somehow managed to extract this from someone, dont splash it on yourself and have a smoke
	name = "Несвятая вода" // Unholy Water
	id = "unholywater"
	description = "То, чего не должно существовать на этом плане существования."
	process_flags = ORGANIC | SYNTHETIC //ethereal means everything processes it.
	metabolization_rate = 1
	taste_description = "серы"

/datum/reagent/fuel/unholywater/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(iscultist(M))
		M.AdjustDrowsy(-5)
		update_flags |= M.AdjustParalysis(-1, FALSE)
		update_flags |= M.AdjustStunned(-2, FALSE)
		update_flags |= M.AdjustWeakened(-2, FALSE)
		update_flags |= M.adjustToxLoss(-2, FALSE)
		update_flags |= M.adjustFireLoss(-2, FALSE)
		update_flags |= M.adjustOxyLoss(-2, FALSE)
		update_flags |= M.adjustBruteLoss(-2, FALSE)
	else
		update_flags |= M.adjustBrainLoss(3, FALSE)
		update_flags |= M.adjustToxLoss(1, FALSE)
		update_flags |= M.adjustFireLoss(2, FALSE)
		update_flags |= M.adjustOxyLoss(2, FALSE)
		update_flags |= M.adjustBruteLoss(2, FALSE)
		M.AdjustCultSlur(10)//CUASE WHY THE HELL NOT
	return ..() | update_flags

/datum/reagent/hellwater
	name = "Адская вода" // Hell Water
	id = "hell_water"
	description = "ВАША ПЛОТЬ! ОНА ГОРИТ!"
	process_flags = ORGANIC | SYNTHETIC		//Admin-bus has no brakes! KILL THEM ALL.
	metabolization_rate = 1
	can_synth = FALSE
	taste_description = "горения"

/datum/reagent/hellwater/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.fire_stacks = min(5, M.fire_stacks + 3)
	M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
	update_flags |= M.adjustToxLoss(1, FALSE)
	update_flags |= M.adjustFireLoss(1, FALSE)		//Hence the other damages... ain't I a bastard?
	update_flags |= M.adjustBrainLoss(5, FALSE)
	return ..() | update_flags

/datum/reagent/liquidgibs
	name = "Жидкие ошмётки" // Liquid gibs
	id = "liquidgibs"
	color = "#FF9966"
	description = "Не хочется даже думать о том, откуда они."
	reagent_state = LIQUID
	taste_description = "мяса"

/datum/reagent/liquidgibs/reaction_turf(turf/T, volume) //yes i took it from synthflesh...
	if(volume >= 5 && !isspaceturf(T))
		new /obj/effect/decal/cleanable/blood/gibs/cleangibs(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)

/datum/reagent/lye
	name = "Щелочь" // Lye
	id = "lye"
	description = "Также известна как гидроксид натрия."
	reagent_state = LIQUID
	color = "#FFFFD6" // very very light yellow
	taste_description = "<span class='userdanger'>КИСЛОТЫ</span>"//don't drink lye, kids

/datum/reagent/drying_agent
	name = "Осушающий агент" // Drying agent
	id = "drying_agent"
	description = "Можно использовать для сушки вещей."
	reagent_state = LIQUID
	color = "#A70FFF"
	taste_description = "сухости во рту"

/datum/reagent/drying_agent/reaction_turf(turf/simulated/T, volume)
	if(istype(T) && T.wet)
		T.MakeDry(TURF_WET_WATER)

/datum/reagent/drying_agent/reaction_obj(obj/O, volume)
	if(istype(O, /obj/item/clothing/shoes/galoshes))
		var/t_loc = get_turf(O)
		qdel(O)
		new /obj/item/clothing/shoes/galoshes/dry(t_loc)
