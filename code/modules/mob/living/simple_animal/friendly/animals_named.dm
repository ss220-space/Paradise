/mob/living/simple_animal/pig/Sanya
	name = "Саня"
	desc = "Старый добрый хряк с сединой. Слегка подслеповат, но нюх и харизма по прежнему с ним. Чудом не пущен на мясо и дожил до почтенного возраста."
	icon_state = "pig_old"
	icon_living = "pig_old"
	icon_dead = "pig_old_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/ham/old = 10)
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 80	//Старый Боров
	health = 80

/mob/living/simple_animal/cow/Betsy
	name = "Бетси"
	desc = "Старая добрая старушка. Нескончаемый источник природного молока без ГМО. Ну почти без ГМО..."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/chicken/Wife
	name = "Галя"
	desc = "Почетная наседка. Жена Коммандора, следующая за ним в коммандировки по космическим станциям."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20

/mob/living/simple_animal/cock/Commandor
	name = "Коммандор Клакки"
	desc = "Его великая армия бесчисленна. Ко-ко-ко."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 40	//Veteran
	health = 40

/mob/living/simple_animal/goose/Scientist
	name = "Гуськор"
	desc = "Учёный Гусь. Везде учусь. Крайне умная птица. Обожает генетику. Надеемся это не бывший пропавший генетик..."
	icon_state = "goose_labcoat"
	icon_living = "goose_labcoat"
	icon_dead = "goose_labcoat_dead"
	icon_resting = "goose_labcoat_rest"
	attacktext = "умно щипает"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 80	//Гусь-ученый привык к "экспериментам"
	health = 80

/mob/living/simple_animal/pet/cat/Iriska
	name = "Ириска"
	desc = "Упитана. Счастлива. Бюрократы её обожают. И похоже даже черезчур сильно."
	icon = 'icons/mob/iriska.dmi'
	icon_state = "iriska"
	icon_living = "iriska"
	icon_dead = "iriska_dead"
	icon_resting = "iriska"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	gender = FEMALE
	mob_size = MOB_SIZE_LARGE	//THICK!!!
	canmove = FALSE		// TOO FAT
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 8)
	tts_seed = "Huntress"
	maxHealth = 40	//Sooooo faaaat...
	health = 40
	speed = 0
	can_hide = 0

/mob/living/simple_animal/mouse/hamster/Representative
	name = "Представитель Алексей"
	desc = "Представитель федерации хомяков. Проявите уважение при его виде, ведь он с позитивным исходом решил немало дипломатических вопросов между федерацией мышей, республикой крыс и корпорацией Нанотрейзен. Да и кто вообще хомяка так назвал?!"
	icon_state = "hamster_rep"
	icon_living = "hamster_rep"
	icon_dead = "hamster_rep_dead"
	icon_resting = "hamster_rep_rest"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	holder_type = /obj/item/holder/hamster_rep
	maxHealth = 20
	health = 20

/mob/living/simple_animal/pet/dog/bullterrier/Genn
	name = "Геннадий"
	desc = "Собачий аристократ. Выглядит очень важным и начитанным. Доброжелательный любимец ассистентов."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 5
	health = 5

/mob/living/simple_animal/mouse/rat/white/Brain
	name = "Брейн"
	real_name = "Брейн"
	desc = "Сообразительная личная лабораторная крыса директора исследований. Настолько часто сбегал, что его перестали помещать в клетку. Он явно хочет захватить мир."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20

/mob/living/simple_animal/mouse/rat/gray/Ratatui
	name = "Рататуй"
	real_name = "Рататуй"
	desc = "Личная крыса шеф повара, помогающая ему при готовке наиболее изысканных блюд. До момента пока он не пропадет и повар не начнет готовить что-то новенькое..."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20

/mob/living/simple_animal/mouse/rat/irish/Remi
	name = "Реми"
	real_name = "Реми"
	desc = "Близкий друг Рататуя. Не любимец повара, но пока тот не мешает на кухне, ему разрешили здесь остаться. Очень толстая крыса."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20
	transform = matrix(1.125, 0, 0.5, 0, 1, 0)	//толстячок на +1 пиксель

/mob/living/simple_animal/pet/dog/fox/fennec/Fenya
	name = "Феня"
	desc = "Миниатюрная лисичка c важным видом и очень большими ушами. Был пойман во время разливания огромного мороженого по формочкам и теперь Магистрат держит его при себе и следит за ним. Но похоже что ему даже нравится быть частью правосудия."

/mob/living/simple_animal/pet/dog/brittany/Psycho
	name = "\improper Психо"
	real_name = "Психо"
	desc = "Собака готовая выслушать все ваши проблемы и дать вам целебных объятий и обнюхиваний."
