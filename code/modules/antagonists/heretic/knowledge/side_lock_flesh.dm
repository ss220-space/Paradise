/datum/heretic_knowledge_tree_column/lock_to_flesh
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/lock
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/flesh

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/phylactery
	tier2 = /datum/heretic_knowledge/spell/opening_blast
	tier3 = /datum/heretic_knowledge/spell/apetra_vulnera

/**
 * Проклятая Филактерия
 */
/datum/heretic_knowledge/phylactery
	name = "Проклятая Филактерия"
	desc = "Позволяет превратить лист стекла и мак в филактерию, \
			способную мгновенно набирать кровь даже с большого расстояния. \
			Имейте в виду, что ваша цель может почувствовать укол."
	gain_text = "Настойка, приняла форму кровососущего паразита. \
				Выбрала ли она эту форму сама, или это юмор больного разума, \
				создавшего это мерзкое орудие, – лучше не пытаться понять."
	required_atoms = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/food/snacks/grown/poppy = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/glass/phylactery)
	cost = 1
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "phylactery_2"


// Sidepaths for knowledge between Knock and Flesh.
/datum/heretic_knowledge/spell/opening_blast
	name = "Волна Отчаяния"
	desc = "Дарует вам «Волну отчаяния» — заклинание, которое можно применить только будучи скованным. \
			Оно снимает с вас оковы, отталкивает и сбивает с ног окружающих, а также накладывает «Прикосновение \
			Мансуса» на всё вокруг."
	gain_text = "Мои оковы были разорваны в темной ярости, их слабые путы рушатся под давлением моей силы."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "uncuff"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/wave_of_desperation
	cost = 1


/datum/heretic_knowledge/spell/apetra_vulnera
	name = "Усугубление"
	desc = "Предоставляет вам Усугубление, заклинание, ломающее части тела жертвы, \
			имеющие более 15 единиц травм. Ранит случайную конечность, если ни одна конечность не повреждена \
			достаточно сильно."
	gain_text = "Пусть разрывается плоть и льётся кровь! Мой господин жаждет жертв, а я исполняю его желания!"
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "apetra_vulnera"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/apetra_vulnera
	cost = 1


