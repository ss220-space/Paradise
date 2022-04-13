/*/datum/reagent/silicate
	name = "Силикат" // Silicate
	id = "silicate"
	description = "Соединение, которым можно укреплять стекла."
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
	name = "Кислород" // Oxygen
	id = "oxygen"
	description = "Бесцветный газ без запаха."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0

/datum/reagent/nitrogen
	name = "Азот" // Nitrogen
	id = "nitrogen"
	description = "Бесцветный газ без вкуса и запаха."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0

/datum/reagent/hydrogen
	name = "Водород" // Hydrogen
	id = "hydrogen"
	description = "Легковоспламеняющийся двухатомный неметаллический газ без цвета, вкуса и запаха."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0

/datum/reagent/potassium
	name = "Калий" // Potassium
	id = "potassium"
	description = "Мягкое легкоплавкое твердое вещество, которое легко режется ножом. Бурно реагирует с водой."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160
	taste_description = "плохих идей"

/datum/reagent/sulfur
	name = "Сера" // Sulfur
	id = "sulfur"
	description = "Химический элемент."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0
	taste_description = "impulsive decisions"

/datum/reagent/sodium
	name = "Натрий" // Sodium
	id = "sodium"
	description = "Химический элемент."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "ужасной ошибки"

/datum/reagent/phosphorus
	name = "Фосфор" // Phosphorus
	id = "phosphorus"
	description = "Химический элемент."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40
	taste_description = "неправильных выборов"

/datum/reagent/carbon
	name = "Углерод" // Carbon
	id = "carbon"
	description = "Химический элемент."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0
	taste_description = "кончика карандаша"

/datum/reagent/carbon/reaction_turf(turf/T, volume)
	if(!(locate(/obj/effect/decal/cleanable/dirt) in T) && !isspaceturf(T)) // Only add one dirt per turf.  Was causing people to crash.
		new /obj/effect/decal/cleanable/dirt(T)

/datum/reagent/gold
	name = "Золото" // Gold
	id = "gold"
	description = "Золото — плотный, мягкий и блестящий металл. Это самый ковкий и пластичный из известных металлов."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48
	taste_description = "побрякушек"


/datum/reagent/silver
	name = "Серебро" // Silver
	id = "silver"
	description = "Блестящий драгоценный металл."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208
	taste_description = "недорогих побрякушек"

/datum/reagent/silver/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(M.has_bane(BANE_SILVER))
		M.reagents.add_reagent("toxin", volume)
	. = ..()

/datum/reagent/aluminum
	name = "Алюминий" // Aluminum
	id = "aluminum"
	description = "Пластичный серебристо-белый химический элемент подгруппы бора."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_description = "металла"

/datum/reagent/silicon
	name = "Кремний" // Silicon
	id = "silicon"
	description = "кремний  — четырехвалентный полуметалл. Он менее реакционноспособен, чем его химический аналог углерод."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_description = "микросхем"


/datum/reagent/copper
	name = "Медь" // Copper
	id = "copper"
	description = "Очень пластичный металл."
	color = "#6E3B08" // rgb: 110, 59, 8
	taste_description = "меди"

/datum/reagent/chromium
	name = "Хром" // Chromium
	id = "chromium"
	description = "Каталитический химический элемент."
	color = "#DCDCDC"
	taste_description = "горечи"

/datum/reagent/iron
	name = "Железо" // Iron
	id = "iron"
	description = "Чистое железо — металл."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220
	taste_description = "металла"

/datum/reagent/iron/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!(NO_BLOOD in H.dna.species.species_traits))
			if(H.blood_volume < BLOOD_VOLUME_NORMAL)
				H.blood_volume += 0.8
	return ..()

/datum/reagent/iron/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(M.has_bane(BANE_IRON) && holder && holder.chem_temp < 150) //If the target is weak to cold iron, then poison them.
		M.reagents.add_reagent("toxin", volume)
	..()

//foam
/datum/reagent/fluorosurfactant
	name = "Фтортензид" // Fluorosurfactant
	id = "fluorosurfactant"
	description = "Перфторированная сульфоновая кислота, образующая пену при смешивании с водой."
	reagent_state = LIQUID
	color = "#9E6B38" // rgb: 158, 107, 56
	taste_description = "невероятного дискомфорта"

// metal foaming agent
// this is lithium hydride. Add other recipies (e.g. LiH + H2O -> LiOH + H2) eventually
/datum/reagent/ammonia
	name = "Аммиак" // Ammonia
	id = "ammonia"
	description = "Едкое вещество, обычно используемое в удобрениях или бытовых чистящих средствах."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48
	taste_description = "очистки пола"

/datum/reagent/diethylamine
	name = "Диэтиламин" // Diethylamine
	id = "diethylamine"
	description = "Вторичный амин. Используется в химии и для подкормки растений."
	reagent_state = LIQUID
	color = "#322D00"
	taste_description = "железа"

/datum/reagent/oil
	name = "Масло" // Oil
	id = "oil"
	description = "Хорошая машинная смазка. Содержит много бензола, лигроина и других углеводородов."
	reagent_state = LIQUID
	color = "#3C3C3C"
	taste_description = "моторного масла"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/oil/reaction_temperature(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 600)
		var/turf/T = get_turf(holder.my_atom)
		holder.my_atom.visible_message("<b>Масло горит!</b>")
		fireflash(T, min(max(0, volume / 40), 8))
		fire_flash_log(holder, id)
		var/datum/effect_system/smoke_spread/bad/BS = new
		BS.set_up(1, 0, T)
		BS.start()
		if(holder)
			holder.add_reagent("ash", round(volume * 0.5))
			holder.del_reagent(id)

/datum/reagent/oil/reaction_turf(turf/T, volume)
	if(volume >= 3 && !isspaceturf(T) && !locate(/obj/effect/decal/cleanable/blood/oil) in T)
		new /obj/effect/decal/cleanable/blood/oil(T)

/datum/reagent/iodine
	name = "Йод" // Iodine
	id = "iodine"
	description = "Розовый газообразный элемент."
	reagent_state = GAS
	color = "#493062"
	taste_description = "химической стойкости"

/datum/reagent/carpet
	name = "Ковёр" // Carpet
	id = "carpet"
	description = "Плотная ткань для покрытия полов. Выглядит особенно грубо."
	reagent_state = LIQUID
	color = "#701345"
	taste_description = "ковра… чего?"

/datum/reagent/carpet/reaction_turf(turf/simulated/T, volume)
	if(istype(T, /turf/simulated/floor/plating) || istype(T, /turf/simulated/floor/plasteel))
		var/turf/simulated/floor/F = T
		F.ChangeTurf(/turf/simulated/floor/carpet)
	..()

/datum/reagent/bromine
	name = "Бром" // Bromine
	id = "bromine"
	description = "Жидкий элемент красно-коричневого цвета."
	reagent_state = LIQUID
	color = "#4E3A3A"
	taste_description = "химикатов"

/datum/reagent/phenol
	name = "Фенол" // Phenol
	id = "phenol"
	description = "Полезный компонент органической химии. Также известен как карболовая кислота."
	reagent_state = LIQUID
	color = "#525050"
	taste_description = "кислоты"

/datum/reagent/ash
	name = "Пепел" // Ash
	id = "ash"
	description = "Земля к земле, пепел к пеплу, прах к праху."
	reagent_state = LIQUID
	color = "#191919"
	taste_description = "пепла"

/datum/reagent/acetone
	name = "Ацетон" // Acetone
	id = "acetone"
	description = "100% средство снятия лака для ногтей. Также используется как промышленный растворитель."
	reagent_state = LIQUID
	color = "#474747"
	taste_description = "средства снятия лака"

/datum/reagent/acetone/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1.5, FALSE)
	return ..() | update_flags

/datum/reagent/saltpetre
	name = "Селитра" // Saltpetre
	id = "saltpetre"
	description = "Взрывоопасна."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	taste_description = "одной трети взрыва"

/datum/reagent/colorful_reagent
	name = "Цветастый реагент" // Colorful Reagent
	id = "colorful_reagent"
	description = "Жидкие цвета настоящей радуги. Вот до чего химия дошла!"
	reagent_state = LIQUID
	color = "#FFFFFF"
	taste_description = "радуги"

/datum/reagent/colorful_reagent/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!(NO_BLOOD in H.dna.species.species_traits) && !H.dna.species.exotic_blood)
			H.dna.species.blood_color = "#[num2hex(rand(0, 255))][num2hex(rand(0, 255))][num2hex(rand(0, 255))]"
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
	name = "Квантовая краска для волос" // Quantum Hair Dye
	id = "hair_dye"
	description = "Довольно завитой и кучерявый способ окрашивания совершенно дерзких волос. Чу-у-у-у-ва-а-а-ак."
	reagent_state = LIQUID
	color = "#960096"
	taste_description = "каталога Le Jeune Homme выпуска осени 2559 для профессиональных парикмахеров"

/datum/reagent/hair_dye/reaction_mob(mob/living/M, volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")
		head_organ.facial_colour = rand_hex_color()
		head_organ.sec_facial_colour = rand_hex_color()
		head_organ.hair_colour = rand_hex_color()
		head_organ.sec_hair_colour = rand_hex_color()
		H.update_hair()
		H.update_fhair()
	..()

/datum/reagent/hairgrownium
	name = "Власорост" // Hairgrownium
	id = "hairgrownium"
	description = "Таинственный химикат, предназначенный для роста волос. Часто встречается в ночной ТВ-рекламе."
	reagent_state = LIQUID
	color = "#5DDA5D"
	penetrates_skin = TRUE
	taste_description = "чьей-то бороды"

/datum/reagent/hairgrownium/reaction_mob(mob/living/M, volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")
		head_organ.h_style = random_hair_style(H.gender, head_organ.dna.species.name)
		head_organ.f_style = random_facial_hair_style(H.gender, head_organ.dna.species.name)
		H.update_hair()
		H.update_fhair()
	..()

/datum/reagent/super_hairgrownium
	name = "Супервласорост" // Super Hairgrownium
	id = "super_hairgrownium"
	description = "Таинственный мощный химикат, вызывающий быстрый рост волос."
	reagent_state = LIQUID
	color = "#5DD95D"
	penetrates_skin = TRUE
	taste_description = "нескольких бород"

/datum/reagent/super_hairgrownium/reaction_mob(mob/living/M, volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")
		var/datum/sprite_accessory/tmp_hair_style = GLOB.hair_styles_full_list["Very Long Hair"]
		var/datum/sprite_accessory/tmp_facial_hair_style = GLOB.facial_hair_styles_list["Very Long Beard"]

		if(head_organ.dna.species.name in tmp_hair_style.species_allowed) //If 'Very Long Hair' is a style the person's species can have, give it to them.
			head_organ.h_style = "Very Long Hair"
		else //Otherwise, give them a random hair style.
			head_organ.h_style = random_hair_style(H.gender, head_organ.dna.species.name)
		if(head_organ.dna.species.name in tmp_facial_hair_style.species_allowed) //If 'Very Long Beard' is a style the person's species can have, give it to them.
			head_organ.f_style = "Very Long Beard"
		else //Otherwise, give them a random facial hair style.
			head_organ.f_style = random_facial_hair_style(H.gender, head_organ.dna.species.name)
		H.update_hair()
		H.update_fhair()
		if(!H.wear_mask || H.wear_mask && !istype(H.wear_mask, /obj/item/clothing/mask/fakemoustache))
			if(H.wear_mask)
				H.unEquip(H.wear_mask)
			var/obj/item/clothing/mask/fakemoustache = new /obj/item/clothing/mask/fakemoustache
			H.equip_to_slot(fakemoustache, slot_wear_mask)
			to_chat(H, "<span class='notice'>Волосы прорываются из каждой вашей фолликулы!")
	..()

/datum/reagent/hugs
	name = "Чистые обнимашки" // Pure hugs
	id = "hugs"
	description = "Обнимашки, в жидком виде. Да, обнимашки как концепт. В виде жидкости. Да, в 2566 это имеет смысл."
	reagent_state = LIQUID
	color = "#FF97B9"
	taste_description = "<font color='pink'><b>обнимашек</b></font>"

/datum/reagent/love
	name = "Чистая любовь" // Pure love
	id = "love"
	description = "Что это за эмоция такая, которую люди зовут «любовью»? Вот эта вот? Это же она? Ага, ясно, спасибо."
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
		var/lovely_phrase = pick("довольн[genderize_ru(M.gender,"ым","ой","ым","ыми")]", "любим[genderize_ru(M.gender,"ым","ой","ым","ыми")]", "славно", "очень хорошо", "довольн[genderize_ru(M.gender,"ым","ой","ым","ыми")] собой, хоть и не всегда всё получается так хорошо, как могло бы быть")
		to_chat(M, "<span class='notice'>Вы чувствуете себя [lovely_phrase].</span>")

	else if(!M.restrained())
		for(var/mob/living/carbon/C in orange(1, M))
			if(C)
				if(C == M)
					continue
				if(!C.stat)
					M.visible_message("<span class='notice'>[M] [pick("тепло обнимает","дар[pluralize_ru(M.gender,"ит","ят")] тёплые объятья")] [C].</span>")
					playsound(get_turf(M), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					break
	return ..()

/datum/reagent/love/on_mob_delete(mob/living/M)
	M.can_change_intents = TRUE
	..()

/datum/reagent/love/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	to_chat(M, "<span class='notice'>Вы чувствуете себя любим[genderize_ru(M.gender,"ым","ой","ым","ыми")]!</span>")

/datum/reagent/jestosterone //Formerly known as Nitrogen tungstide hypochlorite before NT fired the chemists for trying to be funny
	name = "Шутостерон" // Jestosterone
	id = "jestosterone"
	description = "Шутостерон — странный химикат, вызывающий у обычных людей множество раздражающих побочных эффектов и лёгкое отравление. Токсичен для мимов."
	color = "#ff00ff" //Fuchsia, pity we can't do rainbow here
	taste_description = "забавного вкуса"

/datum/reagent/jestosterone/on_new()
	..()
	var/mob/living/carbon/C = holder.my_atom
	if(!istype(C))
		return
	if(C.mind)
		if(C.mind.assigned_role == "Clown" || C.mind.assigned_role == SPECIAL_ROLE_HONKSQUAD)
			to_chat(C, "<span class='notice'>Что бы это ни было, оно офигенное!</span>")
		else if(C.mind.assigned_role == "Mime")
			to_chat(C, "<span class='warning'>Вас тошнит.</span>")
			C.AdjustDizzy(volume)
		else
			to_chat(C, "<span class='warning'>Что-то не так…</span>")
			C.AdjustDizzy(volume)
	ADD_TRAIT(C, TRAIT_JESTER, id)
	C.AddComponent(/datum/component/squeak, null, null, null, null, null, TRUE)
	C.AddElement(/datum/element/waddling)

/datum/reagent/jestosterone/on_mob_life(mob/living/carbon/M)
	if(!istype(M))
		return ..()
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(10))
		M.emote("giggle")
	if(M?.mind.assigned_role == "Clown" || M?.mind.assigned_role == SPECIAL_ROLE_HONKSQUAD)
		update_flags |= M.adjustBruteLoss(-1.5 * REAGENTS_EFFECT_MULTIPLIER) //Screw those pesky clown beatings!
	else
		M.AdjustDizzy(10, 0, 500)
		M.Druggy(15)
		if(prob(10))
			M.EyeBlurry(5)
		if(prob(6))
			var/list/clown_message = list("У вас кружится голова.",
			"Вам сложно сосредоточиться.",
			"Вы чувствуете себя забавн[genderize_ru(M?.gender,"ым","ой","ым","ыми")], будто вы — штатный клоун.",
			"Ваше зрение застилают яркие цвета и радуги.",
			"У вас смешно ноют кости.",
			"Что это было?!",
			"Вы слышите неподалёку звуки гудков.",
			"Вам хочется <em>ОРАТЬ</em>!",
			"Зловещий смех эхом отзывается в ваших ушах.",
			"Ваши ноги будто сделаны из желе.",
			"Вам хочется отпустить шуточку.")
			to_chat(M, "<span class='warning'>[pick(clown_message)]</span>")
		if(M?.mind.assigned_role == "Mime")
			update_flags |= M.adjustToxLoss(1.5 * REAGENTS_EFFECT_MULTIPLIER)
	return ..() | update_flags

/datum/reagent/jestosterone/on_mob_delete(mob/living/M)
	..()
	REMOVE_TRAIT(M, TRAIT_JESTER, id)
	qdel(M.GetComponent(/datum/component/squeak))
	M.RemoveElement(/datum/element/waddling)

/datum/reagent/royal_bee_jelly
	name = "маточное молочко" // royal bee jelly
	id = "royal_bee_jelly"
	description = "Маточное пчелиное молочко. Если его ввести матке космических пчёл, она разделится на две."
	color = "#00ff80"
	taste_description = "сладости"

/datum/reagent/royal_bee_jelly/on_mob_life(mob/living/M)
	if(prob(2))
		M.say(pick("Б-з-з-з…","Б-З-З Б-З-З","Б-з-з-з-з-з-з-з-з-з-з-з…"))
	return ..()

/datum/reagent/growthserum
	name = "Сыворотка роста" // Growth serum
	id = "growthserum"
	description = "Коммерческое средство. Помогает пожилым мужчинам в постели." //not really it just makes you a giant
	color = "#ff0000"//strong red. rgb 255, 0, 0
	var/current_size = 1
	taste_description = "увеличения"

/datum/reagent/growthserum/on_mob_life(mob/living/carbon/H)
	var/newsize = current_size
	switch(volume)
		if(0 to 19)
			newsize = 1.1
		if(20 to 49)
			newsize = 1.2
		if(50 to 99)
			newsize = 1.25
		if(100 to 199)
			newsize = 1.3
		if(200 to INFINITY)
			newsize = 1.5

	H.resize = newsize/current_size
	current_size = newsize
	H.update_transform()
	return ..()

/datum/reagent/growthserum/on_mob_delete(mob/living/M)
	M.resize = 1/current_size
	M.update_transform()
	..()

// Вообще «Pax» — это латинское, а не английское слово. Не уверен здесь насчёт перевода названия
/datum/reagent/pax
	name = "Мир" // Pax
	id = "pax"
	description = "Бесцветная жидкость, подавляющая у субъектов тягу к насилию."
	color = "#AAAAAA55"
	taste_description = "воды"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/pax/on_mob_add(mob/living/M)
	..()
	ADD_TRAIT(M, TRAIT_PACIFISM, id)

/datum/reagent/pax/on_mob_delete(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_PACIFISM, id)
	..()

/datum/reagent/toxin/coffeepowder
	name = "Кофейная гуща" // Coffee Grounds
	id = "coffeepowder"
	description = "Кофейные зерна мелкого помола, из которых уже сварили кофе."
	reagent_state = SOLID
	color = "#5B2E0D" // rgb: 91, 46, 13
	taste_description = "отходов"

/datum/reagent/toxin/teapowder
	name = "Чайная заварка" // Ground Tea Leaves
	id = "teapowder"
	description = "Мелко нарезанные чайные листья, из которых уже заваривали чай."
	reagent_state = SOLID
	color = "#7F8400" // rgb: 127, 132, 0"
	taste_description = "будущего"

//////////////////////////////////Hydroponics stuff///////////////////////////////

/datum/reagent/plantnutriment
	name = "Обычные удобрения" // Generic nutriment
	id = "plantnutriment"
	description = "Какое-то удобрение. Сложно точно сказать — какое. Вы, вероятно, должны сообщить об этом и описать как вы это получили."
	color = "#000000" // RBG: 0, 0, 0
	var/tox_prob = 0
	taste_description = "рвоты"

/datum/reagent/plantnutriment/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(tox_prob))
		update_flags |= M.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/plantnutriment/eznutriment
	name = "Удобрение E-Z" // E-Z-Nutrient
	id = "eznutriment"
	description = "Дешевые и чрезвычайно распространенные удобрения."
	color = "#376400" // RBG: 50, 100, 0
	tox_prob = 10
	taste_description = "труда и безвестности"

/datum/reagent/plantnutriment/left4zednutriment
	name = "Left 4 Zed"
	id = "left4zednutriment"
	description = "Нестабильное удобрение, из-за которого растения мутируют чаще, чем обычно."
	color = "#2A1680" // RBG: 42, 128, 22
	tox_prob = 25
	taste_description = "эволюции"

/datum/reagent/plantnutriment/robustharvestnutriment
	name = "Робастный урожай" // Robust Harvest
	id = "robustharvestnutriment"
	description = "Очень мощное удобрение, предотвращающее мутации растений."
	color = "#9D9D00" // RBG: 157, 157, 0
	tox_prob = 15
	taste_description = "изобилия"

///Alchemical Reagents

/datum/reagent/eyenewt
	name = "Глаз тритона" // Eye of newt
	id = "eyenewt"
	description = "Мощный алхимический ингредиент."
	reagent_state = LIQUID
	color = "#050519"
	taste_description = "алхимии"

/datum/reagent/toefrog
	name = "Лягушачья лапка" // Toe of frog
	id = "toefrog"
	description = "Мощный алхимический ингредиент."
	reagent_state = LIQUID
	color = "#092D09"
	taste_description = "алхимии"

/datum/reagent/woolbat
	name = "Шерсть летучей мыши" // Wool of bat
	id = "woolbat"
	description = "Мощный алхимический ингредиент."
	reagent_state = LIQUID
	color = "#080808"
	taste_description = "алхимии"

/datum/reagent/tonguedog
	name = "Собачий язык" // Tongue of dog
	id = "tonguedog"
	description = "Мощный алхимический ингредиент."
	reagent_state = LIQUID
	color = "#2D0909"
	taste_description = "алхимии"

/datum/reagent/triplepiss
	name = "Тройная моча" // Triplepiss
	id = "triplepiss"
	description = "Фу-у-у-у-у-у-у."
	reagent_state = LIQUID
	color = "#857400"
	taste_description = "алхимии"

/datum/reagent/spraytan
	name = "Спрей для загара" // Spray Tan
	id = "spraytan"
	description = "Вещество, используемое для потемнения кожи."
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
				to_chat(M, "<span class='notice'>На вкус совершенно ужасно.</span>")
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
				M.visible_message(pick("<b>[M]</b>'s collar pops up without warning.</span>", "<b>[M]</b> flexes [M.p_their()] arms."))
			else
				M.visible_message("<b>[M]</b> flexes [M.p_their()] arms.")
	if(prob(10))
		M.say(pick("Shit was SO cash.", "You are everything bad in the world.", "What sports do you play, other than 'jack off to naked drawn Japanese people?'", "Don’t be a stranger. Just hit me with your best shot.", "My name is John and I hate every single one of you."))

	return list(0, STATUS_UPDATE_NONE)

/datum/reagent/spraytan/proc/set_skin_color(mob/living/carbon/human/H)
	if(H.dna.species.bodyflags & HAS_SKIN_TONE)
		H.change_skin_tone(-30)

	if(H.dna.species.bodyflags & HAS_SKIN_COLOR) //take current alien color and darken it slightly
		H.change_skin_color("#9B7653")
