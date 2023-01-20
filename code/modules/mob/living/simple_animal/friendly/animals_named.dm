/mob/living/simple_animal/pig/Sanya
	name = "Саня"
	desc = "Старый добрый хряк с сединой. Слегка подслеповат, но нюх и харизма по прежнему с ним. Чудом не пущен на мясо и дожил до почтенного возраста."
	icon_state = "pig_old"
	icon_living = "pig_old"
	icon_dead = "pig_old_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/ham/old = 10)
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

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

/mob/living/simple_animal/cock/Commandor
	name = "Коммандор Клакки"
	desc = "Его великая армия бесчисленна. Ко-ко-ко."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/goose/Scientist
	name = "Учёный Гусь"
	desc = "Гусь. Везде учусь. Крайне умная птица."
	icon_state = "goose_labcoat"
	icon_living = "goose_labcoat"
	icon_dead = "goose_labcoat_dead"
	icon_resting = "goose_labcoat_rest"
	attacktext = "умно щипает"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

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

/mob/living/simple_animal/mouse/hamster/Representative
	name = "Представитель Алексей"
	desc = "Представитель федерации хомяков. Проявите уважение при его виде, ведь он с позитивным исходом решил немало дипломатических вопросов между федерацией мышей и корпорацией Нанотрейзен. Да и кто вообще хомяка так назвал?!"
	icon_state = "hamster_rep"
	icon_living = "hamster_rep"
	icon_dead = "hamster_rep_dead"
	icon_resting = "hamster_rep_rest"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	holder_type = /obj/item/holder/hamster_rep

/mob/living/simple_animal/pet/dog/bullterrier/Genn
	name = "Геннадий"
	desc = "Собачий аристократ. Выглядит очень важным и начитанным. Доброжелательный любимец ассистентов."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
