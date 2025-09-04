/mob/living/simple_animal/pig/Sanya
	name = "Sanya"
	desc = "Старый добрый хряк с сединой. Слегка подслеповат, но нюх и харизма по прежнему с ним. Чудом не был пущен на мясо и смог дожить до почтенного возраста."
	gender = MALE
	icon_state = "pig_old"
	icon_living = "pig_old"
	icon_resting = "pig_old_rest"
	icon_dead = "pig_old_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/ham/old = 10)
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 80	//Старый Боров
	health = 80

/mob/living/simple_animal/pig/Sanya/get_ru_names()
	return list(
		NOMINATIVE = "Саня",
		GENITIVE = "Сани",
		DATIVE = "Сане",
		ACCUSATIVE = "Саню",
		INSTRUMENTAL = "Саней",
		PREPOSITIONAL = "Сане"
	)

/mob/living/simple_animal/cow/Betsy
	name = "Betsy"
	desc = "Старая добрая старушка. Нескончаемый источник природного молока без ГМО. Ну почти без ГМО..."
	body_color = "black"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/cow/Betsy/get_ru_names()
	return list(
		NOMINATIVE = "Бетси",
		GENITIVE = "Бетси",
		DATIVE = "Бетси",
		ACCUSATIVE = "Бетси",
		INSTRUMENTAL = "Бетси",
		PREPOSITIONAL = "Бетси"
	)

/mob/living/simple_animal/chicken/Wife
	name = "Galya"
	desc = "Почетная наседка. Жена Коммандора, следующая за ним в коммандировках по космическим станциям."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20

/mob/living/simple_animal/chicken/Wife/get_ru_names()
	return list(
		NOMINATIVE = "Галя",
		GENITIVE = "Гали",
		DATIVE = "Гале",
		ACCUSATIVE = "Галю",
		INSTRUMENTAL = "Галей",
		PREPOSITIONAL = "Гале"
	)

/mob/living/simple_animal/cock/Commandor
	name = "Commandor Klucky"
	desc = "Его великая армия бесчисленна. Ко-ко-ко."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 40	//Veteran
	health = 40

/mob/living/simple_animal/cock/Commandor/get_ru_names()
	return list(
		NOMINATIVE = "Коммандор Клакки",
		GENITIVE = "Коммандора Клакки",
		DATIVE = "Коммандору Клакки",
		ACCUSATIVE = "Коммандора Клакки",
		INSTRUMENTAL = "Коммандором Клакки",
		PREPOSITIONAL = "Коммандоре Клакки"
	)

/mob/living/simple_animal/goose/Scientist
	name = "Scientist Goose"
	desc = "И учёный, и жнец, и на дуде игрец."
	icon_state = "goose_labcoat"
	icon_living = "goose_labcoat"
	icon_dead = "goose_labcoat_dead"
	icon_resting = "goose_labcoat_rest"
	attacktext = "умно щипает"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 80	//Гусь-ученый привык к "экспериментам"
	health = 80
	resting = TRUE

/mob/living/simple_animal/goose/Scientist/get_ru_names()
	return list(
		NOMINATIVE = "Гусар",
		GENITIVE = "Гусара",
		DATIVE = "Гусару",
		ACCUSATIVE = "Гусара",
		INSTRUMENTAL = "Гусаром",
		PREPOSITIONAL = "Гусаре"
	)

/mob/living/simple_animal/pet/cat/fat/Iriska
	name = "Iriska"
	desc = "Упитана. Счастлива. Бюрократы её обожают. И похоже даже черезчур сильно."
	gender = FEMALE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/cat/fat/Iriska/get_ru_names()
	return list(
		NOMINATIVE = "Ириска",
		GENITIVE = "Ириски",
		DATIVE = "Ириске",
		ACCUSATIVE = "Ириску",
		INSTRUMENTAL = "Ириской",
		PREPOSITIONAL = "Ириске"
	)

/mob/living/simple_animal/pet/cat/white/Penny
	name = "Penny"
	desc = "Любит таскать монетки и мелкие предметы. Успевайте прятать их!"
	gender = FEMALE
	icon_state = "penny"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	resting = TRUE
	gender = FEMALE
	tts_seed = "Widowmaker"

/mob/living/simple_animal/pet/cat/white/Penny/get_ru_names()
	return list(
		NOMINATIVE = "Копейка",
		GENITIVE = "Копейки",
		DATIVE = "Копейке",
		ACCUSATIVE = "Копейку",
		INSTRUMENTAL = "Копейкой",
		PREPOSITIONAL = "Копейке"
	)

/mob/living/simple_animal/pet/cat/birman/Crusher
	name = "Crusher"
	desc = "Любит крушить всё, что не прикручено. Нужно вовремя прибираться."
	icon_state = "crusher"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	resting = TRUE

/mob/living/simple_animal/pet/cat/birman/Crusher/get_ru_names()
	return list(
		NOMINATIVE = "Бедокур",
		GENITIVE = "Бедокура",
		DATIVE = "Бедокуру",
		ACCUSATIVE = "Бедокура",
		INSTRUMENTAL = "Бедокуром",
		PREPOSITIONAL = "Бедокуре"
	)

/mob/living/simple_animal/mouse/wooly/rep
	name = "Господин Мышкин"
	desc = "Господин Мышкин - самый влиятельный грызун-дипломат в обозримой вселенной и сооснователь корпорации НаноТрейзен в одном лице. В текущее время находится в командировке в Секторе Эпсилон Лукусты"
	icon_state = "mouse_rep"
	icon_living = "mouse_rep"
	icon_dead = "mouse_rep_dead"
	icon_resting = "mouse_rep_rest"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	holder_type = /obj/item/holder/mouse_rep
	maxHealth = 20
	health = 20
	resting = TRUE

/mob/living/simple_animal/mouse/wooly/rep/get_ru_names()
	return list(
		NOMINATIVE = "Господин Мышкин",
		GENITIVE = "Господина Мышкина",
		DATIVE = "Господину Мышкину",
		ACCUSATIVE = "Господина Мышкина",
		INSTRUMENTAL = "Господином Мышкином",
		PREPOSITIONAL = "Господине Мышкине"
	)

/mob/living/simple_animal/mouse/wooly/rep/update_icons()
	..()

	if(buckled)
		icon_state = "mouse_rep_buckled"
		pixel_x = 0
		pixel_y = 0
		return

/mob/living/simple_animal/mouse/wooly/rep/set_buckled(new_buckled)
	. = ..()
	update_icons()

// SLAVKA THE OWL

/mob/living/simple_animal/pet/library_owl
	name = "Slava the Owl"
	desc = "Молоденький Сыч Славка. Безвылазно сидит в коморке Библиотекаря, читает всякие книжки и сычует на разных форумах."
	icon_state = "library_owl"
	icon_living = "library_owl"
	icon_dead = "library_owl_dead"
	icon_resting = "library_owl_rest"
	response_help  = "гладит"
	response_disarm = "толкает"
	response_harm   = "пинает"
	speak = list("Уух-Ууууф.","Хууу, Хуууу.", "Ху-хууух!")
	gender = MALE
	speak_emote = list("угукает", "ухает")
	emote_hear = list("угукает!", "ухает!", "размахивает своими крыльями!")
	emote_see = list("встряхивает свои перья.", "машет крылышками.", "дрожит.")
	tts_seed = "Priest"
	faction = list("neutral")
	maxHealth = 50
	health = 50
	melee_damage_type = STAMINA
	melee_damage_lower = 6
	melee_damage_upper = 10
	attacktext = "клюёт"
	nightvision = 15
	speak_chance = 1
	turns_per_move = 10
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	mob_size = MOB_SIZE_SMALL
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	death_sound = 'sound/creatures/owl_death.ogg'
	talk_sound = list('sound/creatures/owl_talk.ogg')
	footstep_type = FOOTSTEP_MOB_CLAW
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/bird = 1)
	var/obj/item/card/id/access_card
	holder_type = /obj/item/holder/library_owl

/mob/living/simple_animal/pet/library_owl/get_ru_names()
	return list(
		NOMINATIVE = "сыч Слава",
		GENITIVE = "сыча Славы",
		DATIVE = "сычу Славе",
		ACCUSATIVE = "сыча Славу",
		INSTRUMENTAL = "сычом Славой",
		PREPOSITIONAL = "сыче Славе"
	)

/mob/living/simple_animal/pet/library_owl/can_use_machinery(obj/machinery/mas)
	. = ..()
	var/static/list/typecache_whitelist = typecacheof(list(
		/obj/machinery/computer/library,
	))
	if(is_type_in_typecache(mas, typecache_whitelist))
		return TRUE

/mob/living/simple_animal/pet/library_owl/Initialize(mapload)
	. = ..()
	access_card = new /obj/item/card/id/library_owl(src)

/mob/living/simple_animal/pet/library_owl/Destroy()
	QDEL_NULL(access_card)
	return ..()

/mob/living/simple_animal/pet/library_owl/get_access()
	. = ..()
	. |= access_card.GetAccess()

// BRAIN

/mob/living/simple_animal/mouse/rat/white/Brain
	name = "Brain"
	real_name = "Брейн"
	desc = "Сообразительная личная лабораторная крыса директора исследований, даже освоившая речь. Настолько часто сбегал, что его перестали помещать в клетку. Он явно хочет захватить мир. Где-то спрятался его напарник..."
	gender = MALE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20
	universal_speak = 1
	resting = TRUE

/mob/living/simple_animal/mouse/rat/white/Brain/get_ru_names()
	return list(
		NOMINATIVE = "Брейн",
		GENITIVE = "Брейна",
		DATIVE = "Брейну",
		ACCUSATIVE = "Брейна",
		INSTRUMENTAL = "Брейном",
		PREPOSITIONAL = "Брейне"
	)

/obj/effect/decal/remains/mouse/Pinkie
	name = "Pinkie"
	desc = "Когда-то это был напарник самой сообразительной крысы в мире. К сожалению он таковым не являлся..."
	gender = MALE
	anchored = TRUE

/obj/effect/decal/remains/mouse/Pinkie/get_ru_names()
	return list(
		NOMINATIVE = "Пинки",
		GENITIVE = "Пинки",
		DATIVE = "Пинки",
		ACCUSATIVE = "Пинки",
		INSTRUMENTAL = "Пинки",
		PREPOSITIONAL = "Пинки"
	)

/mob/living/simple_animal/mouse/rat/Ratatui
	name = "Ratatui"
	real_name = "Рататуй"
	desc = "Личная крыса шеф повара, помогающая ему при готовке наиболее изысканных блюд. До момента пока он не пропадёт и повар не начнет готовить что-то новенькое..."
	gender = MALE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20

/mob/living/simple_animal/mouse/rat/Ratatui/get_ru_names()
	return list(
		NOMINATIVE = "Рататуй",
		GENITIVE = "Рататуя",
		DATIVE = "Рататую",
		ACCUSATIVE = "Рататуя",
		INSTRUMENTAL = "Рататуем",
		PREPOSITIONAL = "Рататуе"
	)

/mob/living/simple_animal/mouse/rat/irish/Remi
	name = "Remi"
	real_name = "Реми"
	desc = "Близкий друг Рататуя. Не любимец повара, но пока тот не мешает на кухне, ему разрешили здесь остаться. Очень толстая крыса."
	gender = MALE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 25
	health = 25
	transform = matrix(1.250, 0, 0, 0, 1, 0)	//толстячок на +2 пикселя

/mob/living/simple_animal/mouse/rat/irish/Remi/get_ru_names()
	return list(
		NOMINATIVE = "Реми",
		GENITIVE = "Реми",
		DATIVE = "Реми",
		ACCUSATIVE = "Реми",
		INSTRUMENTAL = "Реми",
		PREPOSITIONAL = "Реми"
	)

/mob/living/simple_animal/pet/dog/fox/fennec/Fenya
	name = "Fenya"
	desc = "Миниатюрная лисичка c важным видом и очень большими ушами. Был пойман во время разливания огромного мороженого по формочкам и теперь магистрат держит его при себе и следит за ним. Похоже, ему даже нравится быть частью правосудия."
	resting = TRUE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/dog/fox/fennec/Fenya/get_ru_names()
	return list(
		NOMINATIVE = "Феня",
		GENITIVE = "Фени",
		DATIVE = "Фене",
		ACCUSATIVE = "Феню",
		INSTRUMENTAL = "Феней",
		PREPOSITIONAL = "Фене"
	)

/mob/living/simple_animal/pet/dog/brittany/Psycho
	name = "Psycho"
	real_name = "Перрито"
	desc = "Собака, обожающая котов, особенно в сапогах, прекрасно лающая на Испанском, прошла терапевтические курсы, готова выслушать все ваши проблемы и выдать вам целебных объятий с завершением в виде почесыванием животика."
	resting = TRUE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/dog/brittany/Psycho/get_ru_names()
	return list(
		NOMINATIVE = "Перрито",
		GENITIVE = "Перрито",
		DATIVE = "Перрито",
		ACCUSATIVE = "Перрито",
		INSTRUMENTAL = "Перрито",
		PREPOSITIONAL = "Перрито"
	)

/mob/living/simple_animal/pet/dog/pug/Frank
	name = "Frank"
	real_name = "Фрэнк"
	desc = "Мопс, полученный в результате эксперимента учёных в черном. И почему его не забрали?. Похоже, он всем надоел своей болтовней, после чего его лишили дара речи."
	resting = TRUE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/dog/pug/Frank/get_ru_names()
	return list(
		NOMINATIVE = "Фрэнк",
		GENITIVE = "Френка",
		DATIVE = "Фрэнку",
		ACCUSATIVE = "Фрэнка",
		INSTRUMENTAL = "Фрэнком",
		PREPOSITIONAL = "Френке"
	)
