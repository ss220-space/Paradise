//Malfunctioning cryostasis sleepers: Spawns in makeshift shelters in lavaland. Ghosts become hermits with knowledge of how they got to where they are now.
/obj/effect/mob_spawn/human/hermit
	name = "malfunctioning cryostasis sleeper"
	desc = "Гудящая криокапсула с силуэтом гуманоида внутри. Функция стазиса сломана, и, вероятно, её используют как кровать."
	ru_names = list(
		NOMINATIVE = "неисправная криокапсула",
		GENITIVE = "неисправной криокапсулы",
		DATIVE = "неисправной криокапсуле",
		ACCUSATIVE = "неисправную криокапсулу",
		INSTRUMENTAL = "неисправной криокапсулой",
		PREPOSITIONAL = "неисправной криокапсуле"
	)
	mob_name = "a stranded hermit"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	roundstart = FALSE
	death = FALSE
	allow_species_pick = TRUE
	allow_prefs_prompt = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	outfit = /datum/outfit/hermit
	mob_species = /datum/species/human
	description = "Вы - единственный выживший, застрявший на Лаваленде в импровизированном укрытии. Попытайтесь выжить с минимальным оборудованием. Для тех, кому шахтёрская работа кажется слишком скучной."
	flavour_text = "Вы застряли на этой безбожной планете дольше, чем можете вспомнить. Каждый день вы едва сводите концы с концами, и между ужасными условиями вашего импровизированного укрытия, \
	враждебными существами и пепельными драконами, пикирующими с безоблачного неба, всё, о чём вы мечтаете — это ощущение мягкой травы под ногами и свежий воздух Земли. Эти мысли развеиваются очередным воспоминанием о том, как вы сюда попали...\n"
	assignedrole = "Hermit"

/datum/outfit/hermit
	name = "Lavaland Survivor"

/obj/effect/mob_spawn/human/hermit/Initialize(mapload)
	. = ..()
	var/arrpee = rand(1,4)
	switch(arrpee)
		if(1)
			flavour_text += "Вы были помощником [pick("торговца оружием", "кораблестроителя", "управляющего доком")] на небольшой торговой станции в нескольких секторах отсюда. На вас напали рейдеры, и когда вы добрались до отсека с капсулами, \
			осталась только одна. Вы заняли её и запустили в одиночестве, а толпа испуганных лиц, теснящихся у шлюза, пока двигатели капсулы запустились и отправили вас в этот ад, навсегда осталась в вашей памяти."
			outfit.uniform = /obj/item/clothing/under/assistantformal
			outfit.shoes = /obj/item/clothing/shoes/black
			outfit.back = /obj/item/storage/backpack
		if(2)
			flavour_text += "Вы - изгнанник из Кооператива \"Тигр\". Их технологический фанатизм заставил вас усомниться в силе и убеждениях Экзолитиков, и они сочли вас еретиком, подвергнув часам ужасных пыток. \
			Вы были в нескольких часах от казни, когда ваш высокопоставленный друг в Кооперативе смог обеспечить вам капсулу, скрыл координаты назначения и запустил её. Вы очнулись от стазиса после посадки и с тех пор едва выживаете."
			outfit.uniform = /obj/item/clothing/under/color/orange
			outfit.shoes = /obj/item/clothing/shoes/orange
			outfit.back = /obj/item/storage/backpack
		if(3)
			flavour_text += "Вы были врачом на одной из космических станций НаноТрейзен, но вы оставили позади тиранию этой проклятой корпорации и всё, что она представляет. Из метафорического ада в буквальный, \
			вы всё же скучаете по переработанному воздуху и тёплым полам того, что оставили позади... но вы всё равно предпочли бы быть здесь, чем там."
			outfit.uniform = /obj/item/clothing/under/rank/medical
			outfit.suit = /obj/item/clothing/suit/storage/labcoat
			outfit.back = /obj/item/storage/backpack/medic
			outfit.shoes = /obj/item/clothing/shoes/black
		if(4)
			flavour_text += "Ваши друзья всегда шутили, что вы \"не дружите с головой\". Кажется, они были правы, когда вы, находясь на экскурсии в одном из передовых исследовательских центров НаноТрейзен, \
			оказались в спасательной капсуле в одиночестве. Ваш взгляд упал на красную кнопку — она была такой большой и блестящей, что вы не смогли устоять. Вы нажали её, и после нескольких дней ужасающего путешествия \
			вы оказались здесь. С тех пор вы поумнели, и теперь ваши старые друзья, наверное, перестали бы смеяться."
			outfit.uniform = /obj/item/clothing/under/color/grey/glorf
			outfit.shoes = /obj/item/clothing/shoes/black
			outfit.back = /obj/item/storage/backpack
	l_pocket = /obj/item/kitchen/knife/combat

/obj/effect/mob_spawn/human/hermit/Destroy()
	new/obj/structure/fluff/empty_cryostasis_sleeper(get_turf(src))
	return ..()

/obj/effect/mob_spawn/human/hermit/special(mob/living/carbon/human/H)
	GLOB.human_names_list += H.real_name
	return ..()
