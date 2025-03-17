/mob/living/simple_animal/pig/Sanya
	name = "Sanya"
	desc = "Старый добрый хряк с сединой. Слегка подслеповат, но нюх и харизма по прежнему с ним. Чудом не был пущен на мясо и смог дожить до почтенного возраста."
	ru_names = list(
		NOMINATIVE = "Саня",
		GENITIVE = "Сани",
		DATIVE = "Сане",
		ACCUSATIVE = "Саню",
		INSTRUMENTAL = "Саней",
		PREPOSITIONAL = "Сане"
	)
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

/mob/living/simple_animal/cow/Betsy
	name = "Betsy"
	desc = "Старая добрая старушка. Нескончаемый источник природного молока без ГМО. Ну почти без ГМО..."
	ru_names = list(
		NOMINATIVE = "Бетси",
		GENITIVE = "Бетси",
		DATIVE = "Бетси",
		ACCUSATIVE = "Бетси",
		INSTRUMENTAL = "Бетси",
		PREPOSITIONAL = "Бетси"
	)
	body_color = "black"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/chicken/Wife
	name = "Galya"
	desc = "Почетная наседка. Жена Коммандора, следующая за ним в коммандировках по космическим станциям."
	ru_names = list(
		NOMINATIVE = "Галя",
		GENITIVE = "Гали",
		DATIVE = "Гале",
		ACCUSATIVE = "Галю",
		INSTRUMENTAL = "Галей",
		PREPOSITIONAL = "Гале"
	)
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20

/mob/living/simple_animal/cock/Commandor
	name = "Commandor Klucky"
	desc = "Его великая армия бесчисленна. Ко-ко-ко."
	ru_names = list(
		NOMINATIVE = "Коммандор Клакки",
		GENITIVE = "Коммандора Клакки",
		DATIVE = "Коммандору Клакки",
		ACCUSATIVE = "Коммандора Клакки",
		INSTRUMENTAL = "Коммандором Клакки",
		PREPOSITIONAL = "Коммандоре Клакки"
	)
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 40	//Veteran
	health = 40

/mob/living/simple_animal/goose/Scientist
	name = "Scientist Goose"
	desc = "И учёный, и жнец, и на дуде игрец."
	ru_names = list(
		NOMINATIVE = "Гусар",
		GENITIVE = "Гусара",
		DATIVE = "Гусару",
		ACCUSATIVE = "Гусара",
		INSTRUMENTAL = "Гусаром",
		PREPOSITIONAL = "Гусаре"
	)
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

/mob/living/simple_animal/pet/cat/fat/Iriska
	name = "Iriska"
	desc = "Упитана. Счастлива. Бюрократы её обожают. И похоже даже черезчур сильно."
	ru_names = list(
		NOMINATIVE = "Ириска",
		GENITIVE = "Ириски",
		DATIVE = "Ириске",
		ACCUSATIVE = "Ириску",
		INSTRUMENTAL = "Ириской",
		PREPOSITIONAL = "Ириске"
	)
	gender = FEMALE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/cat/white/Penny
	name = "Penny"
	desc = "Любит таскать монетки и мелкие предметы. Успевайте прятать их!"
	ru_names = list(
		NOMINATIVE = "Копейка",
		GENITIVE = "Копейки",
		DATIVE = "Копейке",
		ACCUSATIVE = "Копейку",
		INSTRUMENTAL = "Копейкой",
		PREPOSITIONAL = "Копейке"
	)
	gender = FEMALE
	icon_state = "penny"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	resting = TRUE
	gender = FEMALE
	tts_seed = "Widowmaker"

/mob/living/simple_animal/pet/cat/birman/Crusher
	name = "Crusher"
	desc = "Любит крушить всё, что не прикручено. Нужно вовремя прибираться."
	ru_names = list(
		NOMINATIVE = "Бедокур",
		GENITIVE = "Бедокура",
		DATIVE = "Бедокуру",
		ACCUSATIVE = "Бедокура",
		INSTRUMENTAL = "Бедокуром",
		PREPOSITIONAL = "Бедокуре"
	)
	icon_state = "crusher"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	resting = TRUE

/mob/living/simple_animal/mouse/hamster/Representative
	name = "Representative Alexiy"
	desc = "Представитель Федерации Хомяков. Проявите уважение при его виде, ведь он с позитивным исходом решил немало дипломатических вопросов между Федерацией Мышей, Республикой Крыс и корпорацией НаноТрейзен. Да и кто вообще хомяка так назвал?!"
	ru_names = list(
		NOMINATIVE = "Представитель Алексей",
		GENITIVE = "Представителя Алексея",
		DATIVE = "Представителю Алексею",
		ACCUSATIVE = "Представителя Алексея",
		INSTRUMENTAL = "Представителем Алексеем",
		PREPOSITIONAL = "Представителе Алексее"
	)
	icon_state = "hamster_rep"
	icon_living = "hamster_rep"
	icon_dead = "hamster_rep_dead"
	icon_resting = "hamster_rep_rest"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	holder_type = /obj/item/holder/hamster_rep
	maxHealth = 20
	health = 20
	resting = TRUE

/mob/living/simple_animal/pet/dog/bullterrier/Genn
	name = "Gennadiy"
	desc = "Собачий аристократ. Выглядит очень важным и начитанным. Доброжелательный любимец ассистентов."
	ru_names = list(
		NOMINATIVE = "Генеадий",
		GENITIVE = "Геннадия",
		DATIVE = "Геннадию",
		ACCUSATIVE = "Геннадия",
		INSTRUMENTAL = "Геннадием",
		PREPOSITIONAL = "Геннадии"
	)
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 5
	health = 5
	resting = TRUE

/mob/living/simple_animal/mouse/rat/white/Brain
	name = "Brain"
	real_name = "Брейн"
	desc = "Сообразительная личная лабораторная крыса директора исследований, даже освоившая речь. Настолько часто сбегал, что его перестали помещать в клетку. Он явно хочет захватить мир. Где-то спрятался его напарник..."
	ru_names = list(
		NOMINATIVE = "Брейн",
		GENITIVE = "Брейна",
		DATIVE = "Брейну",
		ACCUSATIVE = "Брейна",
		INSTRUMENTAL = "Брейном",
		PREPOSITIONAL = "Брейне"
	)
	gender = MALE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20
	universal_speak = 1
	resting = TRUE

/obj/effect/decal/remains/mouse/Pinkie
	name = "Pinkie"
	desc = "Когда-то это был напарник самой сообразительной крысы в мире. К сожалению он таковым не являлся..."
	ru_names = list(
		NOMINATIVE = "Пинки",
		GENITIVE = "Пинки",
		DATIVE = "Пинки",
		ACCUSATIVE = "Пинки",
		INSTRUMENTAL = "Пинки",
		PREPOSITIONAL = "Пинки"
	)
	gender = MALE
	anchored = TRUE

/mob/living/simple_animal/mouse/rat/Ratatui
	name = "Ratatui"
	real_name = "Рататуй"
	desc = "Личная крыса шеф повара, помогающая ему при готовке наиболее изысканных блюд. До момента пока он не пропадёт и повар не начнет готовить что-то новенькое..."
	ru_names = list(
		NOMINATIVE = "Рататуй",
		GENITIVE = "Рататуя",
		DATIVE = "Рататую",
		ACCUSATIVE = "Рататуя",
		INSTRUMENTAL = "Рататуем",
		PREPOSITIONAL = "Рататуе"
	)
	gender = MALE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20

/mob/living/simple_animal/mouse/rat/irish/Remi
	name = "Remi"
	real_name = "Реми"
	desc = "Близкий друг Рататуя. Не любимец повара, но пока тот не мешает на кухне, ему разрешили здесь остаться. Очень толстая крыса."
	ru_names = list(
		NOMINATIVE = "Реми",
		GENITIVE = "Реми",
		DATIVE = "Реми",
		ACCUSATIVE = "Реми",
		INSTRUMENTAL = "Реми",
		PREPOSITIONAL = "Реми"
	)
	gender = MALE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 25
	health = 25
	transform = matrix(1.250, 0, 0, 0, 1, 0)	//толстячок на +2 пикселя

/mob/living/simple_animal/pet/dog/fox/fennec/Fenya
	name = "Fenya"
	desc = "Миниатюрная лисичка c важным видом и очень большими ушами. Был пойман во время разливания огромного мороженого по формочкам и теперь магистрат держит его при себе и следит за ним. Похоже, ему даже нравится быть частью правосудия."
	ru_names = list(
		NOMINATIVE = "Феня",
		GENITIVE = "Фени",
		DATIVE = "Фене",
		ACCUSATIVE = "Феню",
		INSTRUMENTAL = "Феней",
		PREPOSITIONAL = "Фене"
	)
	resting = TRUE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/dog/brittany/Psycho
	name = "Psycho"
	real_name = "Перрито"
	desc = "Собака, обожающая котов, особенно в сапогах, прекрасно лающая на Испанском, прошла терапевтические курсы, готова выслушать все ваши проблемы и выдать вам целебных объятий с завершением в виде почесыванием животика."
	ru_names = list(
		NOMINATIVE = "Перрито",
		GENITIVE = "Перрито",
		DATIVE = "Перрито",
		ACCUSATIVE = "Перрито",
		INSTRUMENTAL = "Перрито",
		PREPOSITIONAL = "Перрито"
	)
	resting = TRUE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/dog/pug/Frank
	name = "Фрэнк"
	real_name = "Фрэнк"
	desc = "Мопс, полученный в результате эксперимента учёных в черном. И почему его не забрали?. Похоже, он всем надоел своей болтовней, после чего его лишили дара речи."
	ru_names = list(
		NOMINATIVE = "Фрэнк",
		GENITIVE = "Френка",
		DATIVE = "Фрэнку",
		ACCUSATIVE = "Фрэнка",
		INSTRUMENTAL = "Фрэнком",
		PREPOSITIONAL = "Френке"
	)
	resting = TRUE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
