/datum/reagent/toxin
	name = "Токсин"
	id = "toxin"
	description = "Ядовитый."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	taste_mult = 1.2
	taste_description = "горечи"
	var/toxpwr = 2

/datum/reagent/toxin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(toxpwr, FALSE)
	return ..() | update_flags

/datum/reagent/spider_venom
	name = "Паучий яд"
	id = "spidertoxin"
	description = "Яд, впрыскиваемый космическими арахнидами."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	taste_description = "горечи"

/datum/reagent/spider_venom/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1.5, FALSE)
	return ..() | update_flags

/datum/reagent/bee_venom
	name = "Пчелиный яд"
	id = "beetoxin"
	description = "Яд, впрыскиваемый космическими пчелами."
	reagent_state = LIQUID
	color = "#ff932f"
	taste_description = "боли"

/datum/reagent/bee_venom/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1.5, FALSE)
	return ..() | update_flags

//bee venom specially for Beesease bees
/datum/reagent/bee_venom_beesease
	name = "Пчелиный яд"
	id = "beetoxinbeesease"
	description = "Яд, впрыскиваемый космическими пчелами."
	reagent_state = LIQUID
	color = "#ff932f"
	taste_description = "боли"
	overdose_threshold = 30

/datum/reagent/bee_venom_beesease/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(0.1, FALSE)
	return ..() | update_flags

/datum/reagent/bee_venom_beesease/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	switch(severity)
		//30-60 units
		if(1)
			M.Slowed(3 SECONDS, 3)
			M.damageoverlaytemp = 50
			update_flags |= M.adjustToxLoss(0.75, FALSE)
			if(effect <= 5)
				M.Jitter(8 SECONDS)
			else if(effect <= 7)
				M.Stuttering(8 SECONDS)
		//60 - Infinity units
		if(2)
			M.Slowed(3 SECONDS, 6)
			M.damageoverlaytemp = 90
			update_flags |= M.adjustToxLoss(1.5, FALSE)
			if(effect <= 3)
				M.Weaken(4 SECONDS)
				M.Jitter(8 SECONDS)
				M.Stuttering(8 SECONDS)
			else if(effect <= 7)
				M.Stuttering(8 SECONDS)
	return list(effect, update_flags)

/datum/reagent/minttoxin
	name = "Мятный токсин"
	id = "minttoxin"
	description = "Пригодится для работы с нежелательными клиентами."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	taste_description = "мяты"

/datum/reagent/minttoxin/on_mob_life(mob/living/M)
	if(HAS_TRAIT(M, TRAIT_FAT) && M.gib())
		return STATUS_UPDATE_NONE
	return ..()

/datum/reagent/slimejelly
	data = list("diseases" = null)
	name = "Слаймовое желе"
	id = "slimejelly"
	description = "Липкая полужидкость, полученная из одной из самых смертоносных форм жизни в галактике."
	reagent_state = LIQUID
	color = "#0b8f70" // rgb: 11, 143, 112
	taste_description = "желе"
	taste_mult = 1.3

/datum/reagent/slimejelly/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!isslimeperson(M) && prob(10))
		to_chat(M, span_danger("Ваши внутренности пылают!"))
		update_flags |= M.adjustToxLoss(rand(2,6) / 2, FALSE) // avg 0.2 toxin per cycle
	else if(prob(40))
		update_flags |= M.adjustBruteLoss(-0.25, FALSE)
	return ..() | update_flags

/datum/reagent/slimejelly/on_merge(list/mix_data)
	merge_diseases_data(mix_data)
	if(data && mix_data && mix_data["colour"])
		color = mix_data["colour"]

/datum/reagent/slimejelly/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(data && data["diseases"])
		for(var/datum/disease/virus/V in data["diseases"])

			if(V.spread_flags < BLOOD)
				continue

			if(method == REAGENT_TOUCH)
				V.Contract(M, need_protection_check = TRUE, act_type = CONTACT)
			else
				V.Contract(M, need_protection_check = FALSE)

	if(method == REAGENT_INGEST && iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.get_blood_id() == id && !HAS_TRAIT(C, TRAIT_NO_BLOOD_RESTORE))
			C.setBlood(min(C.blood_volume + round(volume, 0.1), BLOOD_VOLUME_NORMAL))
			C.reagents.del_reagent(id)

/datum/reagent/slimejelly/reaction_turf(turf/T, volume, color)
	if(volume >= 3 && !isspaceturf(T) && !locate(/obj/effect/decal/cleanable/blood/slime) in T)
		var/obj/effect/decal/cleanable/blood/slime/B = new(T)
		B.basecolor = color
		B.update_icon()


/datum/reagent/slimetoxin
	name = "Мутационный токсин"
	id = "mutationtoxin"
	description = "Мутационный токсин, производимый слаймами."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94
	can_synth = FALSE
	taste_description = "теней"

/datum/reagent/slimetoxin/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/human = M
		if(!isshadowperson(human))
			to_chat(M, span_danger("Ваша плоть быстро мутирует!"))
			to_chat(M, span_danger("Теперь вы - Тень, мутант из расы обитающих во тьме гуманоидов."))
			to_chat(M, span_danger("Ваше тело сильно реагирует на свет, однако оно натурально исцеляется при нахождении во тьме."))
			to_chat(M, span_danger("Тем не менее, вы не изменились психически и сохранили свои прежние обязанности."))
			human.set_species(/datum/species/shadow)
	return ..()

/datum/reagent/aslimetoxin
	name = "Продвинутый мутационный токсин"
	id = "amutationtoxin"
	description = "Продвинутый мутационный токсин, производимый слаймами."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94
	can_synth = FALSE
	taste_description = "желе"

/datum/reagent/aslimetoxin/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method != REAGENT_TOUCH)
		var/datum/disease/virus/transformation/slime/D = new
		D.Contract(M)


/datum/reagent/mercury
	name = "Ртуть"
	id = "mercury"
	description = "Химический элемент."
	reagent_state = LIQUID
	color = "#484848" // rgb: 72, 72, 72
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	penetrates_skin = TRUE
	taste_mult = 0 // elemental mercury is tasteless

/datum/reagent/mercury/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(70))
		M.adjustBrainLoss(1)
	return ..() | update_flags

/datum/reagent/chlorine
	name = "Хлор"
	id = "chlorine"
	description = "Химический элемент."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	penetrates_skin = TRUE
	process_flags = ORGANIC | SYNTHETIC
	taste_description = "огня"

/datum/reagent/chlorine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/fluorine
	name = "Фтор"
	id = "fluorine"
	description = "Высокореактивный химический элемент."
	reagent_state = GAS
	color = "#6A6054"
	penetrates_skin = TRUE
	process_flags = ORGANIC | SYNTHETIC
	taste_description = "кислоты"

/datum/reagent/fluorine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(1, FALSE)
	update_flags |= M.adjustToxLoss(0.5, FALSE)
	return ..() | update_flags

/datum/reagent/radium
	name = "Радий"
	id = "radium"
	description = "Радий - щелочноземельный металл. Он чрезвычайно радиоактивен."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199
	penetrates_skin = TRUE
	taste_description = "голубизны и сожалений"

/datum/reagent/radium/on_mob_life(mob/living/M)
	if(M.radiation < 80)
		M.apply_effect(4, IRRADIATE, negate_armor = 1)
	return ..()

/datum/reagent/radium/reaction_turf(turf/T, volume)
	if(volume >= 3 && !isspaceturf(T))
		new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/mutagen
	name = "Нестабильный мутаген"
	id = "mutagen"
	description = "Может вызывать непредсказуемые мутации. Держите подальше от детей."
	reagent_state = LIQUID
	color = "#04DF27"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	taste_mult = 0.9
	taste_description = "желе"

/datum/reagent/mutagen/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(!..())
		return
	if(!M.dna)
		return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if(volume > 1 && ((method == REAGENT_TOUCH && prob(33)) || method == REAGENT_INGEST))
		randmutb(M)
		M.check_genes()

/datum/reagent/mutagen/on_mob_life(mob/living/M)
	if(!M.dna)
		return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	M.apply_effect(1, IRRADIATE, negate_armor = 1)
	if(prob(4))
		randmutb(M)
		M.check_genes()
	return ..()


/datum/reagent/stable_mutagen
	name = "Стабильный мутаген"
	id = "stable_mutagen"
	description = "Обычное, скучное мутагенное соединение. Действует совершенно предсказуемо."
	reagent_state = LIQUID
	color = "#7DFF00"
	taste_description = "желе"


/datum/reagent/stable_mutagen/on_new(data)
	..()
	START_PROCESSING(SSprocessing, src)


/datum/reagent/stable_mutagen/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()


/datum/reagent/stable_mutagen/on_mob_life(mob/living/carbon/human/target)
	if(isnucleation(target))
		return ..()
	target.apply_effect(1, IRRADIATE, negate_armor = TRUE)
	if(current_cycle != 10 || !ishuman(target) || !target.dna || !islist(data) || !istype(data["dna"], /datum/dna))
		return ..()
	var/datum/dna/reagent_dna = data["dna"]
	if(!reagent_dna.species.is_monkeybasic)
		target.change_dna(reagent_dna, TRUE, TRUE)
		target.special_post_clone_handling()
	return ..()


/datum/reagent/stable_mutagen/process()
	. = ..()
	if(data)
		return .
	var/datum/reagent/blood/blood = locate() in holder.reagent_list
	if(blood && islist(blood.data))
		data = blood.data.Copy()


/datum/reagent/uranium
	name ="Уран"
	id = "uranium"
	description = "Серебристо-белый металл из ряда актинидов, слабо радиоактивный."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192
	taste_mult = 0
	taste_description = "атомной энергии"

/datum/reagent/uranium/on_mob_life(mob/living/M)
	M.apply_effect(2, IRRADIATE, negate_armor = 1)
	return ..()

/datum/reagent/uranium/reaction_turf(turf/T, volume)
	if(volume >= 3 && !isspaceturf(T))
		new /obj/effect/decal/cleanable/greenglow(T)


/datum/reagent/lexorin
	name = "Лексорин"
	id = "lexorin"
	description = "Лексорин временно останавливает дыхание. Вызывает повреждение тканей."
	reagent_state = LIQUID
	color = "#52685D"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "сладости"

/datum/reagent/lexorin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags


/datum/reagent/acid
	name = "Серная кислота"
	id = "sacid"
	description = "Сильная минеральная кислота с молекулярной формулой H2SO4."
	reagent_state = LIQUID
	color = "#00FF32"
	process_flags = ORGANIC | SYNTHETIC
	taste_description = span_userdanger("РАЗЪЕДАЮЩЕЙ КИСЛОТЫ")
	//acid is not using permeability_coefficient to calculate protection, but armour["acid"]
	clothing_penetration = 1
	var/acidpwr = 10 //the amount of protection removed from the armour


/datum/reagent/acid/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE

	if(!acid_proof_species(M))
		update_flags |= M.adjustFireLoss(1, FALSE)

	return ..() | update_flags


/datum/reagent/acid/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M

	if(acid_proof_species(H))
		return

	if(method == REAGENT_TOUCH)
		to_chat(H, span_warning("Зеленоватое кислое вещество жжёт вашу кожу[volume < 1 ? " но оно недостаточно концентрированное, чтобы нанести вам вред" : null]!"))
		if(volume < 1)
			return

		var/damage_coef = 0
		var/should_scream = TRUE

		for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
			if(istype(bodypart, /obj/item/organ/external/head) && !H.wear_mask && !H.head && volume > 25)
				bodypart.disfigure()
				if(H.has_pain() && should_scream)
					H.emote("scream")
					should_scream = FALSE

			damage_coef = (100 - clamp(H.getarmor_organ(bodypart, "acid"), 0, 100))/100

			if(damage_coef > 0 && should_scream)
				should_scream = FALSE
				if(H.has_pain())
					H.emote("scream")

			H.apply_damage(clamp(volume - 1, 2, 20) * damage_coef / length(H.bodyparts), BURN, def_zone = bodypart)
			H.apply_damage(clamp((volume - 1)/2, 1, 10) * damage_coef / length(H.bodyparts), BRUTE, def_zone = bodypart)

		return

	if(method == REAGENT_INGEST)
		to_chat(H, span_warning("Зеленоватое кислое вещество жжёт вашу кожу[volume < 1 ? ", но оно недостаточно концентрированное, чтобы нанести вам вред" : null]!"))
		if(volume >= 1)
			H.adjustFireLoss(clamp((volume - 1) * 2, 0, 30))
			if(H.has_pain())
				H.emote("scream")


/datum/reagent/acid/reaction_obj(obj/O, volume)
	if(ismob(O.loc)) //handled in human acid_act()
		return

	volume = round(volume, 0.1)
	O.acid_act(acidpwr, volume)


/datum/reagent/acid/reaction_turf(turf/T, volume)
	if(!istype(T))
		return

	volume = round(volume, 0.1)
	T.acid_act(acidpwr, volume)


/datum/reagent/acid/facid
	name = "Фторсерная кислота"
	id = "facid"
	description = "Фторсерная кислота это чрезвычайно агрессивная суперкислота."
	color = "#5050FF"
	acidpwr = 42
	//acid is not using permeability_coefficient to calculate protection, but armour["acid"]
	clothing_penetration = 1


/datum/reagent/acid/facid/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE

	if(!acid_proof_species(M))
		update_flags |= M.adjustToxLoss(0.5, FALSE)

	return ..() | update_flags


/datum/reagent/acid/facid/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M
	var/damage_ignored = acid_proof_species(H)

	if(method == REAGENT_TOUCH)
		if(volume >= 5 && !damage_ignored) // Prevent damage to mob, but not to clothes
			var/damage_coef = 0
			var/should_scream = TRUE

			for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
				damage_coef = (100 - clamp(H.getarmor_organ(bodypart, "acid"), 0, 100))/100
				if(damage_coef && should_scream && H.has_pain()) // prevent emote spam
					H.emote("scream")
					should_scream = FALSE

				H.apply_damage(clamp((volume - 5) * 3, 8, 75) * damage_coef / length(H.bodyparts), BURN, def_zone = bodypart)

		if(volume > 9 && (H.wear_mask || H.head))
			if(H.wear_mask && !(H.wear_mask.resistance_flags & ACID_PROOF))
				to_chat(H, span_danger("Ваш[genderize_ru(H.wear_mask.gender, "", "а", "е", "и")] [H.wear_mask.declent_ru(NOMINATIVE)] плавится!"))
				qdel(H.wear_mask)
				H.update_inv_wear_mask()

			if(H.head && !(H.head.resistance_flags & ACID_PROOF))
				to_chat(H, span_danger("Ваш[genderize_ru(H.head.gender, "", "а", "е", "и")] [H.head.declent_ru(NOMINATIVE)] плавится!"))
				qdel(H.head)
				H.update_inv_head()

			return

	else
		if(damage_ignored)
			return

		if(volume >= 5)
			H.emote("scream")
			H.adjustFireLoss(clamp((volume - 5) * 3, 8, 75));

	to_chat(H, span_warning("Синеватое кислотное вещество жжёт вашу кожу[volume < 5 ? ", но оно недостаточно концентрированное, чтобы нанести вам вред" : null]!"))


/datum/reagent/acetic_acid
	name = "Уксусная кислота"
	id = "acetic_acid"
	description = "Слабая кислота, которая является основным компонентом уксуса и плохого похмелья."
	color = "#0080ff"
	reagent_state = LIQUID
	taste_description = "уксуса"


/datum/reagent/acetic_acid/reaction_mob(mob/M, method = REAGENT_TOUCH, volume)
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M
	if(acid_proof_species(H))
		return

	if(method == REAGENT_TOUCH)
		if(H.wear_mask || H.head)
			return

		if(volume >= 50 && prob(75))
			var/obj/item/organ/external/affecting = H.get_organ(BODY_ZONE_HEAD)
			if(affecting)
				affecting.disfigure()

			H.take_overall_damage(5, 15)
			H.emote("scream")

		else
			H.adjustBruteLoss(min(5, volume * 0.25))

	else
		to_chat(H, span_warning("Прозрачная кислотное вещество жалит вашу кожу[volume < 25 ? ", но оно недостаточно концентрированное, чтобы нанести вам вред" : null]!"))
		if(volume >= 25)
			H.take_overall_damage(2)
			H.emote("scream")


/datum/reagent/proc/acid_proof_species(mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE // skip check

	if(HAS_TRAIT(H, TRAIT_ACID_PROTECTED))
		return TRUE // acid proof species

	return FALSE


/datum/reagent/carpotoxin
	name = "Карпотоксин"
	id = "carpotoxin"
	description = "Смертельный нейротоксин, вырабатываемый железами космического карпа."
	reagent_state = LIQUID
	color = "#003333" // rgb: 0, 51, 51
	taste_description = "рыбы"

/datum/reagent/carpotoxin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/staminatoxin
	name = "Тиризин"
	id = "tirizene"
	description = "Токсин, который ухудшает снабжение тканей кислородом, постепенно выматывая организм субъекта."
	reagent_state = LIQUID
	color = "#6E2828"
	data = 13
	taste_description = "горечи"

/datum/reagent/staminatoxin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustStaminaLoss(0.5 * data, FALSE)
	data = max(data - 1, 3)
	return ..() | update_flags


/datum/reagent/toxin/spore
	name = "Споровый токсин"
	description = "Природный токсин, вырабатываемый спорами блоба, который при попадании в организм подавляет зрение."
	color = "#9ACD32"
	id = "spore"
	toxpwr = 1
	can_synth = FALSE
	taste_description = "горечи"

/datum/reagent/toxin/spore/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.damageoverlaytemp = 60
	affected_mob.update_damage_hud()
	affected_mob.EyeBlurry(6 SECONDS * REM * seconds_per_tick)

/datum/reagent/toxin/spore_burning
	name = "Огненый споровый токсин"
	description = "Природный токсин, вырабатываемый спорами блоба, который вызывает возгорание тканей жертвы."
	color = "#9ACD32"
	id = "spore_burn"
	toxpwr = 0.5
	taste_description = "ожогов"
	can_synth = FALSE

/datum/reagent/toxin/spore_burning/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_fire_stacks(2 * REM * seconds_per_tick)
	affected_mob.IgniteMob()


/datum/reagent/beer2	//disguised as normal beer for use by emagged service borgs
	name = "Пиво"
	id = "beer2"
	description = "Алкогольный напиток, приготовленный из солода, хмеля, дрожжей и воды."
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	drink_icon ="beerglass"
	drink_name = "стакан пива"
	drink_desc = "Освежающая пинта пива."
	taste_description = "мочи"

/datum/reagent/beer2/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(1 to 50)
			M.Sleeping(4 SECONDS)
		if(51 to INFINITY)
			M.Sleeping(4 SECONDS)
			update_flags |= M.adjustToxLoss((current_cycle - 50) / 2, FALSE)
	return ..() | update_flags

/datum/reagent/polonium
	name = "Полоний"
	id = "polonium"
	description = "Вызывают значительные радиационные повреждения с течением времени."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	penetrates_skin = TRUE
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/polonium/on_mob_life(mob/living/M)
	M.apply_effect(8, IRRADIATE, negate_armor = 1)
	return ..()

/datum/reagent/histamine
	name = "Гистамин"
	id = "histamine"
	description = "Нейротрансмиттер иммунной системы. Если он обнаружен в крови, то, скорее всего, у человека наблюдается аллергическая реакция."
	reagent_state = LIQUID
	color = "#E7C4C4"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 40
	taste_mult = 0

/datum/reagent/histamine/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume) //dumping histamine on someone is VERY mean.
	if(iscarbon(M))
		if(method == REAGENT_TOUCH)
			M.reagents.add_reagent("histamine",10)
		else
			to_chat(M, span_danger("Вы чувствуете жжение в горле..."))
			M.emote("drool")

/datum/reagent/histamine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		M.emote(pick("twitch", "grumble", "sneeze", "cough"))
	if(prob(10))
		to_chat(M, span_danger("Ваши глаза чешутся..."))
		M.emote(pick("blink", "sneeze"))
		M.AdjustEyeBlurry(6 SECONDS)
	if(prob(10))
		M.visible_message(span_danger("[M] расчёсыва[pluralize_ru(M.gender, "ет", "ют")] кожу до крови!"))
		update_flags |= M.adjustBruteLoss(1, FALSE)
		M.emote("grumble")
	if(prob(5))
		to_chat(M, span_danger("У вас сыпь!"))
		update_flags |= M.adjustBruteLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/histamine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			to_chat(M, span_warning("Вы чувствуете, как слизь стекает по задней стенке вашего горла..."))
			update_flags |= M.adjustToxLoss(1, FALSE)
			M.Jitter(8 SECONDS)
			M.emote(pick("sneeze", "cough"))
		else if(effect <= 4)
			M.AdjustStuttering(rand(0, 10 SECONDS))
			if(prob(25))
				M.emote(pick("choke","gasp"))
				update_flags |= M.adjustOxyLoss(5, FALSE)
		else if(effect <= 7)
			to_chat(M, span_warning("Вы чувствуете боль в груди!"))
			M.emote(pick("cough","gasp"))
			update_flags |= M.adjustOxyLoss(3, FALSE)
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message(span_danger("У [M] выступила крапивница на коже!"))
			update_flags |= M.adjustBruteLoss(6, FALSE)
		else if(effect <= 4)
			M.visible_message(span_warning("[M] оглушительно кашля[pluralize_ru(M.gender, "ет", "ют")], сгинаясь пополам!"))
			M.Jitter(20 SECONDS)
			M.AdjustStuttering(rand(0, 10 SECONDS))
			M.emote("cough")
			if(prob(40))
				M.emote(pick("choke","gasp"))
				update_flags |= M.adjustOxyLoss(6, FALSE)
			M.Weaken(16 SECONDS)
		else if(effect <= 7)
			to_chat(M, span_warning("Вы слышите оглушительный стук собственного сердца!"))
			M << 'sound/effects/singlebeat.ogg'
			M.emote("collapse")
			update_flags |= M.adjustOxyLoss(8, FALSE)
			update_flags |= M.adjustToxLoss(3, FALSE)
			M.Weaken(6 SECONDS)
			M.emote(pick("choke", "gasp"))
			to_chat(M, span_warning("Вам кажется, что вы сейчас умрёте!"))
	return list(effect, update_flags)

/datum/reagent/formaldehyde
	name = "Формальдегид"
	id = "formaldehyde"
	description = "Формальдегид - распространенный промышленный химикат, который используется для консервации трупов и медицинских препа. Он очень токсичен и вызывает аллергию."
	reagent_state = LIQUID
	color = "#B44B00"
	penetrates_skin = TRUE
	taste_description = "горечи"

/datum/reagent/formaldehyde/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(0.5, FALSE)
	if(prob(10))
		M.reagents.add_reagent("histamine",rand(5,15))
	return ..() | update_flags

/datum/reagent/acetaldehyde
	name = "Ацетальдегид"
	id = "acetaldehyde"
	description = "Ацетальдегид - распространенный промышленный химикат. Он является сильным раздражителем."
	reagent_state = LIQUID
	color = "#B44B00"
	penetrates_skin = TRUE
	taste_description = "яблок"

/datum/reagent/acetaldehyde/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(0.5, FALSE)
	return ..() | update_flags

/datum/reagent/venom
	name = "Яд"
	id = "venom"
	description = "Невероятно сильный яд. Происхождение неизвестно."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 40
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/venom/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(25))
		M.reagents.add_reagent("histamine",rand(5,10))
	if(volume < 20)
		update_flags |= M.adjustToxLoss(1, FALSE)
		update_flags |= M.adjustBruteLoss(1, FALSE)
	else if(volume < 40)
		if(prob(8))
			M.fakevomit()
		update_flags |= M.adjustToxLoss(2, FALSE)
		update_flags |= M.adjustBruteLoss(2, FALSE)
	if(volume > 40 && prob(4))
		M.delayed_gib()
		return
	return ..() | update_flags

/datum/reagent/neurotoxin2
	name = "Нейротоксин"
	id = "neurotoxin2"
	description = "Опасный токсин, поражающий нервную систему."
	reagent_state = LIQUID
	color = "#60A584"
	metabolization_rate = 2.5 * REAGENTS_METABOLISM
	taste_mult = 0

/datum/reagent/neurotoxin2/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(1 to 4)
			current_cycle++
			return
		if(5 to 8)
			M.AdjustDizzy(2 SECONDS)
			M.Confused(20 SECONDS)
		if(9 to 12)
			M.Drowsy(20 SECONDS)
			M.AdjustDizzy(2 SECONDS)
			M.Confused(40 SECONDS)
		if(13)
			M.emote("faint")
		if(14 to INFINITY)
			M.Paralyse(20 SECONDS)
			M.Drowsy(40 SECONDS)

	M.AdjustJitter(-60 SECONDS)
	if(M.getBrainLoss() <= 80)
		update_flags |= M.adjustBrainLoss(1, FALSE)
	else
		if(prob(10))
			update_flags |= M.adjustBrainLoss(1, FALSE)
	if(prob(10))
		M.emote("drool")
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/cyanide
	name = "Цианид"
	id = "cyanide"
	description = "Высокотоксичное химическое вещество, используемое в качестве строительного блока для других веществ."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	penetrates_skin = TRUE
	taste_description = "миндаля"

/datum/reagent/cyanide/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(0.75, FALSE)
	if(prob(5))
		M.emote("drool")
	if(prob(10))
		to_chat(M, span_danger("Вы не можете дышать!"))
		M.AdjustLoseBreath(2 SECONDS)
		M.emote("gasp")
	if(prob(8))
		to_chat(M, span_danger("Вы чувствуете сильную слабость!"))
		M.Stun(4 SECONDS)
		update_flags |= M.adjustToxLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/itching_powder
	name = "Зудящий порошок"
	id = "itching_powder"
	description = "Абразивный порошок, любимый жестокими шутниками."
	reagent_state = LIQUID
	color = "#B0B0B0"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	penetrates_skin = TRUE
	taste_description = "чесотки на языке"

/datum/reagent/itching_powder/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_STAT
	if(prob(25))
		M.emote(pick("twitch", "laugh", "sneeze", "cry"))
	if(prob(20))
		to_chat(M, span_notice("Вам щекотно!"))
		M.emote(pick("laugh", "giggle"))
	if(prob(15))
		M.visible_message(span_danger("[M] сильно чеш[pluralize_ru(M.gender, "ет", "ут")]ся!"))
		update_flags |= M.adjustBruteLoss(1, FALSE)
		M.Stun(rand(0, 2 SECONDS))
		M.emote("grumble")
	if(prob(10))
		to_chat(M, span_danger("Вам щекотно, слишком щекотно!"))
		update_flags |= M.adjustBruteLoss(2, FALSE)
	if(prob(6))
		M.reagents.add_reagent("histamine", rand(1,3))
	if(prob(2))
		to_chat(M, span_danger("ААААААА!!!"))
		update_flags |= M.adjustBruteLoss(5, FALSE)
		M.Weaken(10 SECONDS)
		M.AdjustJitter(12 SECONDS)
		M.visible_message(span_danger("[M] вал[pluralize_ru(M.gender, "ит", "ят")]ся на землю, истерично рассчёсывая свою кожу до крови!"))
		M.emote("scream")
	return ..() | update_flags

/datum/reagent/initropidril
	name = "Инитропидрил"
	id = "initropidril"
	description = "Сильнодействующий сердечный яд - может убить за несколько минут."
	reagent_state = LIQUID
	color = "#7F10C0"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/initropidril/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(33))
		update_flags |= M.adjustToxLoss(rand(5,25), FALSE)
	if(prob(33))
		to_chat(M, span_danger("Вы чувствуете сильную слабость!"))
		M.Stun(4 SECONDS)
	if(prob(10))
		to_chat(M, span_danger("Вы не можете дышать!"))
		update_flags |= M.adjustOxyLoss(10, FALSE)
		M.AdjustLoseBreath(2 SECONDS)
	if(prob(10))
		to_chat(M, span_warning("Вы чувствуете сильную боль в груди!"))
		update_flags |= M.adjustOxyLoss(10, FALSE)
		M.AdjustLoseBreath(2 SECONDS)
		M.Weaken(4 SECONDS)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.undergoing_cardiac_arrest())
				H.set_heartattack(TRUE) // rip in pepperoni
	return ..() | update_flags

/datum/reagent/pancuronium
	name = "Панкуроний"
	id = "pancuronium"
	description = "Бромид панкурония - мощный релаксант скелетных мышц."
	reagent_state = LIQUID
	color = "#1E4664"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_mult = 0

/datum/reagent/pancuronium/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(1 to 5)
			if(prob(10))
				M.emote(pick("drool", "tremble"))
		if(6 to 10)
			if(prob(8))
				to_chat(M, span_danger("Вы чувствуете [pick("сильную слабость", "немоту в мышцах", ", что вы едва можете двигаться", "сильное покалывание")]!"))
				M.Stun(2 SECONDS)
			else if(prob(8))
				M.emote(pick("drool", "tremble"))
		if(11 to INFINITY)
			M.Weaken(40 SECONDS)
			if(prob(10))
				M.emote(pick("drool", "tremble", "gasp"))
				M.AdjustLoseBreath(2 SECONDS)
			if(prob(9))
				to_chat(M, span_danger("Вы не[pick(" чувствуете свои ноги", " можете двигаться", "способны пошевелить даже пальцем", "чувствуете ничего")]!"))
			if(prob(7))
				to_chat(M, span_danger("Вы не можете дышать!"))
				M.AdjustLoseBreath(6 SECONDS)
	return ..() | update_flags

/datum/reagent/sodium_thiopental
	name = "Тиопентал натрия"
	id = "sodium_thiopental"
	description = "Быстродействующий транквилизатор барбитуратного ряда."
	reagent_state = LIQUID
	color = "#5F8BE1"
	metabolization_rate = 1.75 * REAGENTS_METABOLISM
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/sodium_thiopental/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(1)
			M.emote("drool")
			M.Confused(10 SECONDS)
		if(2 to 4)
			M.Drowsy(40 SECONDS)
		if(5)
			M.emote("faint")
			M.Weaken(10 SECONDS)
		if(6 to INFINITY)
			M.Paralyse(40 SECONDS)
	M.AdjustJitter(-100 SECONDS)
	if(prob(10))
		M.emote("drool")
		update_flags |= M.adjustBrainLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/ketamine
	name = "Кетамин"
	id = "ketamine"
	description = "Сильнодействующий ветеринарный транквилизатор."
	reagent_state = LIQUID
	color = "#646EA0"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	penetrates_skin = TRUE
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/ketamine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(1 to 5)
			if(prob(25))
				M.emote("yawn")
		if(6 to 9)
			M.AdjustEyeBlurry(10 SECONDS)
			if(prob(35))
				M.emote("yawn")
		if(10)
			M.emote("faint")
			M.Weaken(10 SECONDS)
		if(11 to INFINITY)
			M.Paralyse(50 SECONDS)
	return ..() | update_flags

/datum/reagent/sulfonal
	name = "Сульфонал"
	id = "sulfonal"
	description = "Отравляет организм субьекта и погружает его в сон."
	reagent_state = LIQUID
	color = "#6BA688"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_mult = 0

/datum/reagent/sulfonal/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustJitter(-60 SECONDS)
	switch(current_cycle)
		if(1 to 10)
			if(prob(7))
				M.emote("yawn")
		if(11 to 20)
			M.Drowsy(40 SECONDS)
		if(21)
			M.emote("faint")
		if(22 to INFINITY)
			if(prob(20))
				M.emote("faint")
				M.Paralyse(10 SECONDS)
			M.Drowsy(40 SECONDS)
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/amanitin
	name = "Аманитин"
	id = "amanitin"
	description = "Токсин, вырабатываемый некоторыми грибами. Очень опасен."
	reagent_state = LIQUID
	color = "#D9D9D9"
	taste_mult = 0

/datum/reagent/amanitin/on_mob_delete(mob/living/M)
	M.adjustToxLoss(current_cycle*rand(2,4))
	..()

/datum/reagent/lipolicide
	name = "Липолицид"
	id = "lipolicide"
	description = "Соединение, которое можно найти во многих магазинах в виде тоника для похудения."
	reagent_state = SOLID
	color = "#D1DED1"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "кислоты для аккумуляторов"

/datum/reagent/lipolicide/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!M.nutrition)
		switch(rand(1,3))
			if(1)
				to_chat(M, span_warning("Вам хочется есть!"))
			if(2)
				update_flags |= M.adjustToxLoss(1, FALSE)
				to_chat(M, span_warning("Вы чувствуете боль в животе!"))
			else
				pass()
	else
		if(prob(60))
			var/fat_to_burn = max(round(M.nutrition / 100, 1), 5)
			M.adjust_nutrition(-fat_to_burn)
			M.overeatduration = 0
	return ..() | update_flags

/datum/reagent/coniine
	name = "Кониин"
	id = "coniine"
	description = "Нейротоксин, быстро вызывающий остановку дыхания."
	reagent_state = LIQUID
	color = "#C2D8CD"
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/coniine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(2, FALSE)
	M.AdjustLoseBreath(10 SECONDS)
	return ..() | update_flags

/datum/reagent/curare
	name = "Кураре"
	id = "curare"
	description = "Очень опасный паралитический яд."
	reagent_state = LIQUID
	color = "#191919"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	can_synth = FALSE
	penetrates_skin = TRUE
	taste_mult = 0

/datum/reagent/curare/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	update_flags |= M.adjustOxyLoss(1, FALSE)
	switch(current_cycle)
		if(1 to 5)
			if(prob(20))
				M.emote(pick("drool", "pale", "gasp"))
		if(6 to 10)
			M.AdjustEyeBlurry(10 SECONDS)
			if(prob(8))
				to_chat(M, span_danger("Вы чувствуете [pick("сильную слабость", "немоту в мышцах", ", что вы едва можете двигаться", "сильное покалывание")]!"))
				M.Stun(2 SECONDS)
			else if(prob(8))
				M.emote(pick("drool", "pale", "gasp"))
		if(11 to INFINITY)
			M.Stun(60 SECONDS)
			M.Drowsy(40 SECONDS)
			if(prob(20))
				M.emote(pick("drool", "faint", "pale", "gasp", "collapse"))
			else if(prob(8))
				to_chat(M, span_danger("Вы не[pick(" чувствуете свои ноги", " можете двигаться", "способны пошевелить даже пальцем", " чувствуете ничего", " можете дышать")]!"))
				M.AdjustLoseBreath(2 SECONDS)
	return ..() | update_flags

/datum/reagent/sarin
	name = "Зарин"
	id = "sarin"
	description = "Чрезвычайно смертоносный нейротоксин."
	reagent_state = LIQUID
	color = "#C7C7C7"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	penetrates_skin = TRUE
	overdose_threshold = 25
	taste_mult = 0

/datum/reagent/sarin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(1 to 15)
			M.AdjustJitter(40 SECONDS)
			if(prob(20))
				M.emote(pick("twitch","twitch_s","quiver"))
		if(16 to 30)
			if(prob(25))
				M.emote(pick("twitch","twitch","drool","quiver","tremble"))
			M.AdjustEyeBlurry(10 SECONDS)
			M.Stuttering(10 SECONDS)
			if(prob(10))
				M.Confused(30 SECONDS)
			if(prob(15))
				M.Stun(2 SECONDS)
				M.emote("scream")
		if(30 to 60)
			M.AdjustEyeBlurry(10 SECONDS)
			M.Stuttering(10 SECONDS)
			if(prob(10))
				M.Stun(2 SECONDS)
				M.emote(pick("twitch","twitch","drool","shake","tremble"))
			if(prob(5))
				M.emote("collapse")
			if(prob(5))
				M.Weaken(6 SECONDS)
				M.visible_message(span_warning("У [M] припадок!"))
				M.SetJitter(2000 SECONDS)
			if(prob(5))
				to_chat(M, span_warning("Вы не можете дышать!"))
				M.emote(pick("gasp", "choke", "cough"))
				M.AdjustLoseBreath(2 SECONDS)
		if(61 to INFINITY)
			if(prob(15))
				M.emote(pick("gasp", "choke", "cough","twitch", "shake", "tremble","quiver","drool", "twitch","collapse"))
			M.LoseBreath(10 SECONDS)
			update_flags |= M.adjustToxLoss(1, FALSE)
			update_flags |= M.adjustBrainLoss(1, FALSE)
			M.Weaken(8 SECONDS)
	if(prob(8))
		M.fakevomit()
	update_flags |= M.adjustToxLoss(1, FALSE)
	update_flags |= M.adjustBrainLoss(1, FALSE)
	update_flags |= M.adjustFireLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/glyphosate
	name = "Глифосат"
	id = "glyphosate"
	description = "Гербицид широкого спектра применения, эффективно уничтожающий вредителей."
	reagent_state = LIQUID
	color = "#d3cf50"
	var/lethality = 0 //Glyphosate is non-toxic to people
	taste_description = "горечи"

/datum/reagent/glyphosate/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(lethality, FALSE)
	return ..() | update_flags

/datum/reagent/glyphosate/reaction_turf(turf/simulated/wall/W, volume) // Clear off wallrot fungi
	if(istype(W) && W.rotting)
		for(var/obj/effect/overlay/wall_rot/WR in W)
			qdel(WR)
		W.rotting = 0
		W.visible_message(span_warning("Глифосат полностью растворил грибок!"))

/datum/reagent/glyphosate/reaction_obj(obj/O, volume)
	if(istype(O,/obj/structure/alien/weeds))
		var/obj/structure/alien/weeds/alien_weeds = O
		alien_weeds.take_damage(rand(15, 35), BRUTE, 0) // Kills alien weeds pretty fast
	else if(istype(O, /obj/structure/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O, /obj/structure/spacevine))
		var/obj/structure/spacevine/SV = O
		SV.on_chem_effect(src)


/datum/reagent/glyphosate/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) // If not wearing a mask
			C.adjustToxLoss(lethality)
		if(HAS_TRAIT(C, TRAIT_PLANT_ORIGIN))	//plantmen take extra damage
			C.adjustToxLoss(3)
			..()
	else if(istype(M, /mob/living/simple_animal/diona)) //nymphs take EVEN MORE damage
		M.apply_damage(100)
		..()


/datum/reagent/glyphosate/atrazine
	name = "Атразин"
	id = "atrazine"
	description = "Гербицидное соединение, используемое для уничтожения нежелательных растений."
	reagent_state = LIQUID
	color = "#773E73" //RGB: 47 24 45
	lethality = 2 //Atrazine, however, is definitely toxic


/datum/reagent/pestkiller // To-Do; make this more realistic.
	name = "Пестицид"
	id = "pestkiller"
	description = "Вредная токсичная смесь для уничтожения вредителей. Не проглатывать!"
	color = "#4B004B" // rgb: 75, 0, 75
	taste_description = "горечи"

/datum/reagent/pestkiller/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/pestkiller/reaction_obj(obj/O, volume)
	if(istype(O, /obj/effect/decal/ants))
		O.visible_message(span_warning("Пестицид убивает муравьёв!"))
		qdel(O)

/datum/reagent/pestkiller/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) // If not wearing a mask
			C.adjustToxLoss(2)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(iskidan(H)) //RIP
				H.adjustToxLoss(20)

/datum/reagent/capulettium
	name = "Капулеттий"
	id = "capulettium"
	description = "Редкий препарат, используемый для симуляции смерти организма употребившего."
	reagent_state = LIQUID
	color = "#60A584"
	heart_rate_stop = 1
	taste_description = "сладости"

/datum/reagent/capulettium/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(1 to 5)
			M.AdjustEyeBlurry(20 SECONDS)
		if(6 to 10)
			M.Drowsy(20 SECONDS)
		if(11)
			fakedeath(M)
		if(61 to 69)
			M.AdjustEyeBlurry(20 SECONDS)
		if(70 to INFINITY)
			M.AdjustEyeBlurry(20 SECONDS)
	return ..() | update_flags

/datum/reagent/capulettium/on_mob_delete(mob/living/M)
	fakerevive(M)
	..()

/datum/reagent/capulettium_plus
	name = "Капулеттий+"
	id = "capulettium_plus"
	description = "Редкий препарат, используемый для симуляции смерти организма употребившего. Пока находится в кровотоке, не позволяет субъекту говорить."
	reagent_state = LIQUID
	color = "#60A584"
	heart_rate_stop = 1
	taste_description = "сладости"

/datum/reagent/capulettium_plus/on_mob_life(mob/living/M)
	M.Silence(4 SECONDS)
	if(M.resting)
		fakedeath(M)
	else
		fakerevive(M)

	return ..()

/datum/reagent/capulettium_plus/on_mob_delete(mob/living/M)
	fakerevive(M)
	..()

/datum/reagent/toxic_slurry
	name = "Токсичная жижа"
	id = "toxic_slurry"
	description = "Токсичный канцерогенный осадок, образующийся на заводе \"Сларрипод\"."
	reagent_state = LIQUID
	color = "#00C81E"
	taste_description = "желе"

/datum/reagent/toxic_slurry/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(10))
		update_flags |= M.adjustToxLoss(rand(2.4), FALSE)
	if(prob(7))
		to_chat(M, span_danger("Вас одолевает ужасная мигрень!"))
		M.Stun(rand(4 SECONDS, 10 SECONDS))
	if(prob(7))
		M.fakevomit(1)
	return ..() | update_flags

/datum/reagent/glowing_slurry
	name = "Светящаяся жижа"
	id = "glowing_slurry"
	description = "Это, вероятно, не очень хорошо для вас."
	reagent_state = LIQUID
	color = "#00FD00"
	taste_description = "желе"

/datum/reagent/glowing_slurry/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume) //same as mutagen
	if(!..())
		return
	if(!M.dna)
		return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if((method==REAGENT_TOUCH && prob(50)) || method==REAGENT_INGEST)
		randmutb(M)
		M.check_genes()

/datum/reagent/glowing_slurry/on_mob_life(mob/living/M)
	M.apply_effect(2, IRRADIATE, 0, negate_armor = 1)
	if(!M.dna)
		return
	var/did_mutation = FALSE
	if(prob(15))
		randmutb(M)
		did_mutation = TRUE
	if(prob(3))
		randmutg(M)
		did_mutation = TRUE
	if(did_mutation)
		M.check_genes()
	return ..()

/datum/reagent/ants
	name = "Муравьи"
	id = "ants"
	description = "Образец потерянной породы космических муравьёв (Formicidae bastardium tyrannus). Они известны тем, что способны поглотить практически всё."
	reagent_state = SOLID
	color = "#993333"
	process_flags = ORGANIC | SYNTHETIC
	taste_description = span_warning("МУРАВЬЁВ")

/datum/reagent/ants/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/ants/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume) //NOT THE ANTS
	if(iscarbon(M))
		if(volume > 1 && (method == REAGENT_TOUCH || method == REAGENT_INGEST))
			to_chat(M, span_warning("ТВОЮ МАТЬ, МУРАВЬИ!"))
			M.emote("scream")
			M.adjustBruteLoss(4)

/datum/reagent/teslium //Teslium. Causes periodic shocks, and makes shocks against the target much more effective.
	name = "Теслий"
	id = "teslium"
	description = "Нестабильная, электрически заряженная металлическая суспензия. Увеличивает проводимость живых организмов."
	reagent_state = LIQUID
	color = "#20324D" //RGB: 32, 50, 77
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	var/shock_timer = 0
	process_flags = ORGANIC | SYNTHETIC
	taste_description = "электричества"


/datum/reagent/teslium/on_mob_life(mob/living/affected_mob)
	shock_timer++
	if(shock_timer >= rand(5,30)) //Random shocks are wildly unpredictable
		shock_timer = 0
		affected_mob.electrocute_act(rand(5, 20), "теслиума внутри организма", flags = SHOCK_NOGLOVES)	//SHOCK_NOGLOVES because it's caused from INSIDE of you
		playsound(affected_mob, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return ..()


/datum/reagent/teslium/on_mob_add(mob/living/carbon/human/affected_mob)
	. = ..()
	if(!ishuman(affected_mob))
		return .
	affected_mob.physiology.siemens_coeff *= 2


/datum/reagent/teslium/on_mob_delete(mob/living/carbon/human/affected_mob)
	. = ..()
	if(!ishuman(affected_mob))
		return .
	affected_mob.physiology.siemens_coeff *= 0.5


/datum/reagent/gluttonytoxin
	name = "Благословение Чревоугодия"
	id = "gluttonytoxin"
	description = "Продвинутый токсин, вызывающий разложение, производимый чем-то ужасным."
	reagent_state = LIQUID
	color = "#5EFF3B" //RGB: 94, 255, 59
	can_synth = FALSE
	taste_description = "разложения"

/datum/reagent/gluttonytoxin/reaction_mob(mob/living/L, method=REAGENT_TOUCH, reac_volume)
	var/datum/disease/virus/transformation/morph/D = new
	D.Contract(L)

/datum/reagent/bungotoxin
	name = "Бунготоксин"
	id = "bungotoxin"
	description = "Ужасный кардиотоксин."
	reagent_state = LIQUID
	color = "#EBFF8E"
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	taste_description = "танина"

/datum/reagent/bungotoxin/on_mob_life(mob/living/carbon/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle >= 20)
		if(prob(25))
			M.Dizzy(20 SECONDS)
			to_chat(M, span_danger("Вы чувствуете, как сердце сжимается в груди."))
	if(current_cycle >= 30)
		if(prob(25))
			M.Confused(20 SECONDS)
			to_chat(M, span_danger("Вы чувствуете, что вам нужно сесть и отдышаться."))
	if(current_cycle >= 40)
		if(prob(10))
			to_chat(M, span_danger("Вы чувствуете сильную слабость!"))
			M.Stun(4 SECONDS)
	if(current_cycle == 50)
		to_chat(M, span_warning("Вы чувствуете сильную боль в груди!"))
		update_flags |= M.adjustOxyLoss(10, FALSE)
		M.AdjustLoseBreath(2 SECONDS)
		M.Weaken(6 SECONDS)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.undergoing_cardiac_arrest())
				H.set_heartattack(TRUE) // rip in pepperoni
	return ..() | update_flags

/datum/reagent/coca_extract
	name = "Экстракт коки"
	id = "cocaextract"
	description = "Необработанный экстракт коки. Не стоит пробовать его в таком виде."
	reagent_state = LIQUID
	color = "#f4f4f4"
	metabolization_rate = 1 * REAGENTS_METABOLISM
	taste_description = "травяной горечи"

/datum/reagent/coca_extract/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(2, FALSE)
	if(current_cycle >= 5)
		if(prob(25))
			M.fakevomit(1)
	return ..() | update_flags

/datum/reagent/metalic_dust
	name = "Металлическая пыль"
	id = "metalicdust"
	description = "Металлическая пыль с крупными кусками различных металлов и техническими жидкостями."
	reagent_state = SOLID
	color = "#353434"
	process_flags = ORGANIC | SYNTHETIC
	metabolization_rate = 5
	taste_description = span_warning("МЕТАЛЛИЧЕСКОЙ ПЫЛИ И МАСЛА, БЛЯДЬ!")

/datum/reagent/metalic_dust/on_mob_life(mob/living/M)
	M.emote("scream")
	to_chat(M, span_warning("ТВОЮ МАТЬ!!!"))
	M.AdjustWeakened(2 SECONDS)
	M.EyeBlurry(1 SECONDS)
	M.adjustBruteLoss(rand(5, 10))
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		for(var/obj/item/organ/internal/organ in C.get_organs_zone(BODY_ZONE_PRECISE_GROIN))
			organ.internal_receive_damage(rand(5, 10))

	return ..()
