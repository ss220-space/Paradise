/datum/heretic_knowledge/phylactery
	drafting_tier = 1
	name = "Проклятая Филактерия"
	desc = "Позволяет создать филактерию, \
			способную мгновенно набирать кровь даже с большого расстояния."
	transmute_text = "Преобразуйте лист стекла и мак."
	notice = "Цель филактерии может почувствовать укол."
	gain_text = "Настойка, принявшая форму кровососущего паразита. \
				Выбрала ли она эту форму сама, или это юмор больного разума, \
				создавшего это мерзкое орудие, — лучше не пытаться понять."
	required_atoms = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/food/snacks/grown/poppy = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/glass/phylactery)
	cost = 1
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "phylactery_2"


/datum/heretic_knowledge/spell/opening_blast
	drafting_tier = 2
	name = "Волна Отчаяния"
	desc = "Дарует вам \"Волну отчаяния\", заклинание, которое можно применить только будучи скованным. \
			Оно снимает с вас оковы, отталкивает и сбивает с ног окружающих, а также накладывает \"Хватку \
			Обители\" на всё вокруг."
	gain_text = "Мои оковы были разорваны в тёмной ярости, их слабые путы рушатся под давлением моей силы."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "uncuff"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/wave_of_desperation
	cost = 1


