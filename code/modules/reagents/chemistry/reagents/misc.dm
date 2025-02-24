/*/datum/reagent/silicate
	name = "Silicate"
	id = "silicate"
	description = "A compound that can be used to reinforce glass."
	reagent_state = LIQUID
	color = "#C7FFFF" // rgb: 199, 255, 255

/datum/reagent/silicate/reaction_obj(obj/O, volume)
	if(istype(O, /obj/structure/window))
		if(O:silicate <= 200)

			O:silicate += volume
			O:health += volume * 3

			if(!O:silicateIcon)
				var/icon/I = icon(O.icon,O.icon_state,O.dir)

				var/r = (volume / 100) + 1
				var/g = (volume / 70) + 1
				var/b = (volume / 50) + 1
				I.SetIntensity(r,g,b)
				O.icon = I
				O:silicateIcon = I
			else
				var/icon/I = O:silicateIcon

				var/r = (volume / 100) + 1
				var/g = (volume / 70) + 1
				var/b = (volume / 50) + 1
				I.SetIntensity(r,g,b)
				O.icon = I
				O:silicateIcon = I */


/datum/reagent/oxygen
	name = "Кислород"
	id = "oxygen"
	description = "Бесцветный газ без запаха."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0

/datum/reagent/nitrogen
	name = "Азот"
	id = "nitrogen"
	description = "Бесцветный газ без запаха и вкуса."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0

/datum/reagent/hydrogen
	name = "Водород"
	id = "hydrogen"
	description = "Бесцветный, без запаха, неметаллический, безвкусный, сильно горючий двухатомный газ."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0

/datum/reagent/potassium
	name = "Калий"
	id = "potassium"
	description = "Мягкий, легко плавящийся твердый материал, который легко режется ножом. Бурно реагирует с водой."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160
	taste_description = "плохих мыслей"

/datum/reagent/sulfur
	name = "Сера"
	id = "sulfur"
	description = "Химический элемент."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0
	taste_description = "импульсивных решений"

/datum/reagent/sodium
	name = "Натрий"
	id = "sodium"
	description = "Химический элемент."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "ужасных суждений"

/datum/reagent/phosphorus
	name = "Фосфор"
	id = "phosphorus"
	description = "Химический элемент."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40
	taste_description = "неправильных выборов"

/datum/reagent/carbon
	name = "Углерод"
	id = "carbon"
	description = "Химический элемент."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0
	taste_description = "пишущей части карандаша"

/datum/reagent/carbon/reaction_turf(turf/T, volume)
	if(!(locate(/obj/effect/decal/cleanable/dirt) in T) && !isspaceturf(T)) // Only add one dirt per turf.  Was causing people to crash.
		new /obj/effect/decal/cleanable/dirt(T)

/datum/reagent/gold
	name = "Золото"
	id = "gold"
	description = "Золото - плотный, мягкий, блестящий металл, самый податливый и вязкий из всех известных металлов."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48


/datum/reagent/silver
	name = "Серебро"
	id = "silver"
	description = "Блестящий металлический элемент, считающийся одним из драгоценных металлов."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208
	taste_description = "серебра"

/datum/reagent/aluminum
	name = "Алюминий"
	id = "aluminum"
	description = "Серебристо-белый и ковкий представитель группы химических элементов бора."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_description = "алюминия"

/datum/reagent/silicon
	name = "Кремний"
	id = "silicon"
	description = "Являясь четырёхвалентным металлоидом, кремний менее реакционноспособен, чем его химический аналог углерод."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_description = "микросхем"


/datum/reagent/copper
	name = "Медь"
	id = "copper"
	description = "Высокопластичный металл."
	color = "#6E3B08" // rgb: 110, 59, 8
	taste_description = "меди"

/datum/reagent/chromium
	name = "Хром"
	id = "chromium"
	description = "Каталитический химический элемент."
	color = "#DCDCDC"
	taste_description = "горечи"

/datum/reagent/iron
	name = "Железо"
	id = "iron"
	description = "Чистое железо - это металл."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220
	taste_description = "железа"

/datum/reagent/iron/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!HAS_TRAIT(H, TRAIT_NO_BLOOD) && !HAS_TRAIT(H, TRAIT_NO_BLOOD_RESTORE) && H.blood_volume < BLOOD_VOLUME_NORMAL)
			H.AdjustBlood(0.8)

	return ..()

//foam
/datum/reagent/fluorosurfactant
	name = "Фтортензид"
	id = "fluorosurfactant"
	description = "Перфторированная сульфоновая кислота, образующая пену при смешивании с водой."
	reagent_state = LIQUID
	color = "#9E6B38" // rgb: 158, 107, 56
	taste_description = "сильного дискомфорта"

// metal foaming agent
// this is lithium hydride. Add other recipies (e.g. LiH + H2O -> LiOH + H2) eventually
/datum/reagent/ammonia
	name = "Аммиак"
	id = "ammonia"
	description = "Едкое вещество, обычно используемое в удобрениях или бытовых чистящих средствах."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48
	taste_description = "средства для мытья полов"

/datum/reagent/diethylamine
	name = "Диэтиламин"
	id = "diethylamine"
	description = "Вторичный амин, полезный в качестве питательного вещества для растений и строительного блока для других соединений."
	reagent_state = LIQUID
	color = "#322D00"
	taste_description = "железа"

/datum/reagent/oil
	name = "Масло"
	id = "oil"
	description = "Достойная смазка для машин. С высоким содержанием бензола, нафты и других углеводородов."
	reagent_state = LIQUID
	color = "#3C3C3C"
	taste_description = "моторного масла"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/oil/reaction_temperature(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 600)
		var/turf/T = get_turf(holder.my_atom)
		holder.my_atom.visible_message("<b>Масло горит!</b>")
		var/datum/reagents/old_holder = holder
		fire_flash_log(holder, id)
		if(holder)
			holder.del_reagent(id) // Remove first. Else fireflash triggers a reaction again

		fireflash(T, min(max(0, volume / 40), 8))
		var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
		smoke.set_up(amount = 1, location = T)
		smoke.start()
		if(!QDELETED(old_holder))
			old_holder.add_reagent("ash", round(volume * 0.5))

/datum/reagent/oil/reaction_turf(turf/T, volume)
	if(volume >= 3 && !isspaceturf(T) && !locate(/obj/effect/decal/cleanable/blood/oil) in T)
		new /obj/effect/decal/cleanable/blood/oil(T)

/datum/reagent/iodine
	name = "Йод"
	id = "iodine"
	description = "Газообразный элемент фиолетового цвета."
	reagent_state = GAS
	color = "#493062"
	taste_description = "сопротивления химтрейлам"

/datum/reagent/carpet
	name = "Ковёр"
	id = "carpet"
	description = "Покрытие из плотной ткани, используемое для полов. Этот тип выглядит особенно отвратительно."
	reagent_state = LIQUID
	color = "#701345"
	taste_description = "старого ковра"

/datum/reagent/carpet/reaction_turf(turf/simulated/T, volume)
	if(istype(T, /turf/simulated/floor/plating) || istype(T, /turf/simulated/floor/plasteel))
		var/turf/simulated/floor/F = T
		F.ChangeTurf(/turf/simulated/floor/carpet)
	..()

/datum/reagent/bromine
	name = "Бром"
	id = "bromine"
	description = "Красно-коричневый жидкий элемент."
	reagent_state = LIQUID
	color = "#4E3A3A"
	taste_description = "химикатов"

/datum/reagent/phenol
	name = "Фенол"
	id = "phenol"
	description = "Известная также как карболовая кислота, она является полезным строительным блоком в органической химии."
	reagent_state = LIQUID
	color = "#525050"
	taste_description = "кислоты"

/datum/reagent/ash
	name = "Пепел"
	id = "ash"
	description = "Пепел к пеплу, прах к праху."
	reagent_state = LIQUID
	color = "#191919"
	taste_description = "пепла"

/datum/reagent/acetone
	name = "Ацетон"
	id = "acetone"
	description = "Чистая 100% жидкость для снятия лака с ногтей, также работает как промышленный растворитель."
	reagent_state = LIQUID
	color = "#474747"
	taste_description = "средства для снятия лака с ногтей"

/datum/reagent/acetone/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1.5, FALSE)
	return ..() | update_flags

/datum/reagent/saltpetre
	name = "Селитра"
	id = "saltpetre"
	description = "Летучий химический элемент."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	taste_description = "одной трети взрыва"

/datum/reagent/colorful_reagent
	name = "Цветной реагент"
	id = "colorful_reagent"
	description = "Это чистые жидкие краски. Сейчас это в порядке вещей."
	reagent_state = LIQUID
	color = "#FFFFFF"
	taste_description = "радуги"

/datum/reagent/colorful_reagent/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!HAS_TRAIT(H, TRAIT_NO_BLOOD) && !HAS_TRAIT(H, TRAIT_EXOTIC_BLOOD))
			H.dna.species.blood_color = "#[num2hex(rand(0, 255), 2)][num2hex(rand(0, 255), 2)][num2hex(rand(0, 255), 2)]"
	return ..()

/datum/reagent/colorful_reagent/reaction_mob(mob/living/simple_animal/M, method=REAGENT_TOUCH, volume)
    if(isanimal(M))
        M.color = pick(GLOB.random_color_list)
    ..()

/datum/reagent/colorful_reagent/reaction_obj(obj/O, volume)
	O.color = pick(GLOB.random_color_list)

/datum/reagent/colorful_reagent/reaction_turf(turf/T, volume)
	T.color = pick(GLOB.random_color_list)

/datum/reagent/hair_dye
	name = "Квантовая краска для волос"
	id = "hair_dye"
	description = "Довольно громоздкий и нелепый способ окрашивания волос. Чуваааааак."
	reagent_state = LIQUID
	color = "#960096"
	taste_description = "осеннего выпуска каталога Le Jeune Homme для профессиональных парикмахеров от 2559 года"

/datum/reagent/hair_dye/reaction_mob(mob/living/M, volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head_organ = H.get_organ(BODY_ZONE_HEAD)
		head_organ.facial_colour = rand_hex_color()
		head_organ.sec_facial_colour = rand_hex_color()
		head_organ.hair_colour = rand_hex_color()
		head_organ.sec_hair_colour = rand_hex_color()
		H.update_hair()
		H.update_fhair()
	..()

/datum/reagent/hairgrownium
	name = "Власорост"
	id = "hairgrownium"
	description = "Таинственное химическое вещество, якобы помогающее отрастить волосы. Часто встречается в рекламных роликах на телевидении."
	reagent_state = LIQUID
	color = "#5DDA5D"
	penetrates_skin = TRUE
	taste_description = "волос"

/datum/reagent/hairgrownium/reaction_mob(mob/living/M, volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head_organ = H.get_organ(BODY_ZONE_HEAD)
		head_organ.h_style = random_hair_style(H.gender, head_organ.dna.species.name, human = H)
		head_organ.f_style = random_facial_hair_style(H.gender, head_organ.dna.species.name)
		H.update_hair()
		H.update_fhair()
	..()

/datum/reagent/super_hairgrownium
	name = "Супер власорост"
	id = "super_hairgrownium"
	description = "Загадочное и мощное химическое вещество, якобы вызывающее быстрый рост волос."
	reagent_state = LIQUID
	color = "#5DD95D"
	penetrates_skin = TRUE
	taste_description = "кучи волос"

/datum/reagent/super_hairgrownium/reaction_mob(mob/living/M, volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head_organ = H.get_organ(BODY_ZONE_HEAD)
		var/datum/sprite_accessory/tmp_hair_style = GLOB.hair_styles_full_list["Very Long Hair"]
		var/datum/sprite_accessory/tmp_facial_hair_style = GLOB.facial_hair_styles_list["Very Long Beard"]

		if(head_organ.dna.species.name in tmp_hair_style.species_allowed) //If 'Very Long Hair' is a style the person's species can have, give it to them.
			head_organ.h_style = "Very Long Hair"
		else //Otherwise, give them a random hair style.
			head_organ.h_style = random_hair_style(H.gender, head_organ.dna.species, human = H)
		if(head_organ.dna.species.name in tmp_facial_hair_style.species_allowed) //If 'Very Long Beard' is a style the person's species can have, give it to them.
			head_organ.f_style = "Very Long Beard"
		else //Otherwise, give them a random facial hair style.
			head_organ.f_style = random_facial_hair_style(H.gender, head_organ.dna.species.name)
		H.update_hair()
		H.update_fhair()
		if(!H.wear_mask || H.wear_mask && !istype(H.wear_mask, /obj/item/clothing/mask/fakemoustache) && !(H.wear_mask.resistance_flags & NO_MOUSTACHING))
			if(H.wear_mask)
				H.drop_item_ground(H.wear_mask, force = TRUE)
			var/obj/item/clothing/mask/fakemoustache = new /obj/item/clothing/mask/fakemoustache
			H.equip_to_slot(fakemoustache, ITEM_SLOT_MASK)
			to_chat(H, span_notice("Ваши волосы начинают стремительно расти!"))
	..()

/datum/reagent/hugs
	name = "Чистые объятия"
	id = "hugs"
	description = "Объятия в жидком виде. Да, концепция объятий. В жидком виде. Это имеет смысл в будущем."
	reagent_state = LIQUID
	color = "#FF97B9"
	taste_description = "<font color='pink'><b>обнимашек</b></font>"

/datum/reagent/love
	name = "Чистая любовь"
	id = "love"
	description = "Что это за чувство, которое вы, люди, называете \"любовью\"? О, это оно? Это оно? Ха, ну тогда ладно, спасибо."
	reagent_state = LIQUID
	color = "#FF83A5"
	process_flags = ORGANIC | SYNTHETIC // That's the power of love~
	taste_description = "<font color='pink'><b>любви</b></font>"

/datum/reagent/love/on_mob_add(mob/living/L)
	..()
	if(L.a_intent != INTENT_HELP)
		L.a_intent_change(INTENT_HELP)
	L.can_change_intents = FALSE //Now you have no choice but to be helpful.

/datum/reagent/love/on_mob_life(mob/living/M)
	if(prob(8))
		var/lovely_phrase = pick("оценивают по достоинству", "любят", "ценят", "уважают", "признают")
		to_chat(M, span_notice("Вы чувствуете, что вас [lovely_phrase]."))

	else if(!M.incapacitated() && !HAS_TRAIT(M, TRAIT_HANDS_BLOCKED))
		for(var/mob/living/carbon/C in orange(1, M))
			if(C)
				if(C == M)
					continue
				if(!C.stat)
					C.attack_hand(M)  //now real hugs, not fake
					break
	return ..()

/datum/reagent/love/on_mob_delete(mob/living/M)
	M.can_change_intents = TRUE
	..()

/datum/reagent/love/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	to_chat(M, span_notice("Вы чувствуете, что вас любят!"))

/datum/reagent/jestosterone //Formerly known as Nitrogen tungstide hypochlorite before NT fired the chemists for trying to be funny
	name = "Шутостерон"
	id = "jestosterone"
	description = "Джестостерон - странное химическое соединение, вызывающее у обычного человека целый ряд раздражающих побочных эффектов. Он также вызывает лёгкое опьянение и токсичен для мимов."
	color = "#ff00ff" //Fuchsia, pity we can't do rainbow here
	taste_description = "смеха и шуток"
	var/datum/component/squeak

/datum/reagent/jestosterone/on_new()
	..()
	var/mob/living/carbon/C = holder.my_atom
	if(!istype(C))
		return
	if(C.mind)
		if(C.mind.assigned_role == JOB_TITLE_CLOWN || C.mind.assigned_role == SPECIAL_ROLE_HONKSQUAD)
			to_chat(C, span_notice("Что бы это ни было, ощущения великолепные!"))
		else if(C.mind.assigned_role == JOB_TITLE_MIME)
			to_chat(C, span_warning("Вы чувствете тошноту."))
			C.AdjustDizzy(volume STATUS_EFFECT_CONSTANT)
		else
			to_chat(C, span_warning("Вы чувствуете себя странно и дискомфортно."))
			C.AdjustDizzy(volume STATUS_EFFECT_CONSTANT)
	ADD_TRAIT(C, TRAIT_JESTER, id)
	squeak = C.AddComponent(/datum/component/squeak, null, null, null, null, null, TRUE, falloff_exponent = 20)
	C.AddElement(/datum/element/waddling)

/datum/reagent/jestosterone/on_mob_life(mob/living/carbon/M)
	if(!istype(M))
		return ..()
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(10))
		M.emote("giggle")
	if(M?.mind.assigned_role == JOB_TITLE_CLOWN || M?.mind.assigned_role == SPECIAL_ROLE_HONKSQUAD)
		update_flags |= M.adjustBruteLoss(-1.5, affect_robotic = FALSE) //Screw those pesky clown beatings!
	else
		M.AdjustDizzy(20 SECONDS, 0, 1000 SECONDS)
		M.Druggy(30 SECONDS)
		if(prob(10))
			M.EyeBlurry(10 SECONDS)
		if(prob(6))
			var/list/clown_message = list("Вы чувствуете головокружение.",
			"Вы не можете видеть прямо.",
			"Вы чувствуете себя смешным клоуном.",
			"Яркие цвета и радуга затуманивают ваше зрение.",
			"Ваши смешные кости болят.",
			"Что это было?!",
			"Вы чувствуете приглушённые гудки в отдалении.",
			"Вы слышите приглушённые смешки.",
			"Зловещий смех отдаётся в ваших ушах.",
			"Ваши ноги словно желе.",
			"Вам хочется рассказать анекдот.")
			to_chat(M, span_warning("[pick(clown_message)]"))
		if(M?.mind.assigned_role == JOB_TITLE_MIME)
			update_flags |= M.adjustToxLoss(0.75)
	return ..() | update_flags

/datum/reagent/jestosterone/on_mob_delete(mob/living/M)
	..()
	REMOVE_TRAIT(M, TRAIT_JESTER, id)
	M.RemoveElement(/datum/element/waddling)
	QDEL_NULL(squeak)

/datum/reagent/royal_bee_jelly
	name = "Маточное молочко"
	id = "royal_bee_jelly"
	description = "Королевское маточное молочко. Если его ввести королеве космических пчёл, она размножится."
	color = "#00ff80"
	taste_description = "сладости"

/datum/reagent/royal_bee_jelly/on_mob_life(mob/living/M)
	if(prob(2))
		M.say(pick("Бзззз...","БЗЗ БЗЗ","Бззззззззз..."))
	return ..()

/datum/reagent/growthserum
	name = "Сыворотка роста"
	id = "growthserum"
	description = "Коммерческое химическое средство, призванное помочь пожилым мужчинам в спальне." //not really it just makes you a giant
	color = "#ff0000"//strong red. rgb 255, 0, 0
	var/current_size = RESIZE_DEFAULT_SIZE
	taste_description = "увеличения"

/datum/reagent/growthserum/on_mob_life(mob/living/carbon/H)
	var/newsize = current_size
	switch(volume)
		if(0 to 19)
			newsize = 1.1 * RESIZE_DEFAULT_SIZE
		if(20 to 49)
			newsize = 1.2 * RESIZE_DEFAULT_SIZE
		if(50 to 99)
			newsize = 1.25 * RESIZE_DEFAULT_SIZE
		if(100 to 199)
			newsize = 1.3 * RESIZE_DEFAULT_SIZE
		if(200 to INFINITY)
			newsize = 1.5 * RESIZE_DEFAULT_SIZE

	H.update_transform(newsize/current_size)
	current_size = newsize
	return ..()

/datum/reagent/growthserum/on_mob_delete(mob/living/M)
	M.update_transform(RESIZE_DEFAULT_SIZE/current_size)
	current_size = RESIZE_DEFAULT_SIZE
	..()

/datum/reagent/pax
	name = "Пакс"
	id = "pax"
	description = "Бесцветная жидкость, подавляющая тягу к насилию у гуманоидов."
	color = "#AAAAAA55"
	taste_description = "странной воды"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/pax/on_mob_add(mob/living/M)
	..()
	ADD_TRAIT(M, TRAIT_PACIFISM, id)

/datum/reagent/pax/on_mob_delete(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_PACIFISM, id)
	..()

/datum/reagent/toxin/coffeepowder
	name = "Кофейная гуща"
	id = "coffeepowder"
	description = "Кофейные зерна мелкого помола, используемые для приготовления кофе."
	reagent_state = SOLID
	color = "#5B2E0D" // rgb: 91, 46, 13
	taste_description = "горькой кофейной массы"

/datum/reagent/toxin/teapowder
	name = "Молотые чайные листья"
	id = "teapowder"
	description = "Мелко измельчённые чайные листья, используемые для приготовления чая."
	reagent_state = SOLID
	color = "#7F8400" // rgb: 127, 132, 0"
	taste_description = "отдающей чаем массы"

//////////////////////////////////Hydroponics stuff///////////////////////////////

/datum/reagent/plantnutriment
	name = "Растительные питательные вещества"
	id = "plantnutriment"
	description = "Какое-то питательное вещество. Невозможно определить, что это такое. Возможно, вам следует сообщить о нём и о том, как вы его получили, в соответствующие органы."
	color = "#000000" // RBG: 0, 0, 0
	var/tox_prob = 0
	taste_description = "puke"

/datum/reagent/plantnutriment/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(tox_prob))
		update_flags |= M.adjustToxLoss(0.5, FALSE)
	return ..() | update_flags

/datum/reagent/plantnutriment/eznutriment
	name = "И-ЗИ-Нутриент"
	id = "eznutriment"
	description = "Дешёвый и чрезвычайно распространенный вид растительных питательных веществ."
	color = "#376400" // RBG: 50, 100, 0
	tox_prob = 10
	taste_description = "безвестности и забытья"

/datum/reagent/plantnutriment/left4zednutriment
	name = "Лефт-Фо-Зед"
	id = "left4zednutriment"
	description = "Нестабильное соединение, заставляющее растения мутировать чаще, чем обычно."
	color = "#2A1680" // RBG: 42, 128, 22
	tox_prob = 25
	taste_description = "эволюции"

/datum/reagent/plantnutriment/robustharvestnutriment
	name = "Робаст-Харвест"
	id = "robustharvestnutriment"
	description = "Очень мощное питательное вещество, предотвращающее мутацию растений."
	color = "#9D9D00" // RBG: 157, 157, 0
	tox_prob = 15
	taste_description = "щедрости"

///Alchemical Reagents

/datum/reagent/eyenewt
	name = "Глаз тритона"
	id = "eyenewt"
	description = "Сильнодействующий алхимический ингредиент."
	reagent_state = LIQUID
	color = "#050519"
	taste_description = "алхимии"

/datum/reagent/toefrog
	name = "Палец лягушки"
	id = "toefrog"
	description = "Сильнодействующий алхимический ингредиент."
	reagent_state = LIQUID
	color = "#092D09"
	taste_description = "алхимии"

/datum/reagent/woolbat
	name = "Шерсть летучей мыши"
	id = "woolbat"
	description = "Сильнодействующий алхимический ингредиент."
	reagent_state = LIQUID
	color = "#080808"
	taste_description = "алхимии"

/datum/reagent/tonguedog
	name = "Язык собаки"
	id = "tonguedog"
	description = "Сильнодействующий алхимический ингредиент."
	reagent_state = LIQUID
	color = "#2D0909"
	taste_description = "алхимии"

/datum/reagent/triplepiss
	name = "Тройная моча"
	id = "triplepiss"
	description = "Уууууу."
	reagent_state = LIQUID
	color = "#857400"
	taste_description = "алхимии"

/datum/reagent/spraytan
	name = "Спрей-загар"
	id = "spraytan"
	description = "Вещество, наносимое на кожу для ее потемнения и имитации загара."
	color = "#FFC080" // rgb: 255, 196, 128  Bright orange
	metabolization_rate = 10 * REAGENTS_METABOLISM // very fast, so it can be applied rapidly.  But this changes on an overdose
	overdose_threshold = 11 //Slightly more than one un-nozzled spraybottle.
	taste_description = "кислых апельсинов"

/datum/reagent/spraytan/reaction_mob(mob/living/M, method=REAGENT_TOUCH, reac_volume, show_message = 1)
	if(ishuman(M))
		if(method == REAGENT_TOUCH)
			var/mob/living/carbon/human/N = M
			set_skin_color(N)

		if(method == REAGENT_INGEST)
			if(show_message)
				to_chat(M, span_notice("Это было отвратительно."))
	..()

/datum/reagent/spraytan/overdose_process(mob/living/M)
	metabolization_rate = 1 * REAGENTS_METABOLISM

	if(ishuman(M) && is_species(M, /datum/species/human))
		var/mob/living/carbon/human/N = M
		N.change_hair("Spiky")
		N.change_facial_hair("Shaved")
		N.change_hair_color("#000000")
		N.change_facial_hair_color("#000000")
		set_skin_color(N)
		if(prob(7))
			if(N.w_uniform)
				M.visible_message(span_notice(pick("Воротник [M] приподнимается без предупреждения.", "[M] игра[pluralize_ru(M.gender, "ет", "ют")] своими бицепсами.")))
			else
				M.visible_message(span_notice("[M] игра[pluralize_ru(M.gender, "ет", "ют")] своими бицепсами."))
	if(prob(10))
		M.say(pick(
			"Это было ПРОСТО ОХУИТЕЛЬНО.",
			"Вы - зло этого мира.",
			"А каким спортом вы занимаетесь кроме дрочки на голых анимешных тянок?",
			"Не стесняйтесь, покажите мне на что вы способны.",
			"Меня зовут Джон и я всех вас ненавижу.",
			"Вы жирные, тупые уроды без личной жизни.",
			"Вы самые настоящие пидорасы, которым следует убить себя. Спасибо за внимание."))

	return list(0, STATUS_UPDATE_NONE)

/datum/reagent/spraytan/proc/set_skin_color(mob/living/carbon/human/H)
	if(H.dna.species.bodyflags & HAS_SKIN_TONE)
		H.change_skin_tone(-30)

	if(H.dna.species.bodyflags & HAS_SKIN_COLOR) //take current alien color and darken it slightly
		H.change_skin_color("#9B7653")

/datum/reagent/monkeylanguage
	name = "Обезьяний язык"
	id = "monkeylanguage"
	description = "Эээ..."
	reagent_state = SOLID
	color = "#f0d18f" // rgb: 128, 128, 128
	taste_description = "чего-то странного"

/datum/reagent/monkeylanguage/on_mob_life(mob/living/M)
	if(volume > 4)
		M.add_language(LANGUAGE_MONKEY_HUMAN)
	return ..()

/datum/reagent/bugmilk
	name = "Пепельное молоко"
	id = "bugmilk"
	description = "Молочная субстанция, вырабатываемая некоторыми видами на Лазис Ардакс. Весьма вкусное."
	reagent_state = LIQUID
	color = "#e4dac5"
	taste_description = "густого молока"
	metabolization_rate = 2 * REAGENTS_METABOLISM

/datum/reagent/bugmilk/on_mob_life(mob/living/M)
	M.reagents.add_reagent("cream", 0.4)
	M.reagents.add_reagent("salglu_solution", 0,4)
	return ..()

/datum/reagent/admin_cleaner
	name = "WD-2381"
	color = "#da9eda"
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
