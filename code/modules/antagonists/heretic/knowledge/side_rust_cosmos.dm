/datum/heretic_knowledge_tree_column/rust_to_cosmic
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/rust
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/cosmic

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/essence
	tier2 = list(/datum/heretic_knowledge/entropy_pulse, /datum/heretic_knowledge/rust_sower)
	tier3 = /datum/heretic_knowledge/limited_amount/summon/rusty


// Sidepaths for knowledge between Rust and Cosmos.

/datum/heretic_knowledge/essence
	name = "Ритуал Священника"
	desc = "Позволяет превратить резервуар с водой и осколок стекла во флакон с эссенцией потустороннего. \
			Эссенцию потустороннего можно выпить для мощного исцеления или отравить ей язычников."
	gain_text = "Это старый рецепт. Мне его шепнула Сова. \
				Созданная Жрецом жидкость, которая находится перед вами, но при этом никогда не существовала."

	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/item/shard = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)
	cost = 1


	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "eldritch_flask"


/datum/heretic_knowledge/rust_sower
	name = "Граната «Ржавый Дождь»"
	desc = "Позволяет объединить оболочку химической гранаты и печень, \
			чтобы создать проклятую гранату, наполненную Жуткой Ржавчиной. \
			При детонации она выпускает огромное облако, которое ослепляет \
			органику, покрывает ржавчиной пораженные участки и уничтожает Силиконов и Мехов."
	gain_text = "Высохшие лозы Ржавых холмов покрыты перезрелыми плодами. \
				Они стирают следы прогресса, освобаждая лист реальности для творца."
	required_atoms = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/organ/internal/liver = 1,
	)
	result_atoms = list(/obj/item/grenade/chem_grenade/rust_sower)
	cost = 1
	research_tree_icon_path = 'icons/obj/weapons/grenade.dmi'
	research_tree_icon_state = "rustgrenade"


/datum/heretic_knowledge/entropy_pulse
	name = "Импульс Разложения"
	desc = "Позволяет преобразовать 10 железных листов и мусор (например обертку), \
			заполнив прилегающую к руне область ржавчиной."
	gain_text = "Реальность шепчет мне. Она молит чтобы это всё закончилось. Я помогу ей вернуться в первозданный вид."
	required_atoms = list(
		/obj/item/stack/sheet/metal = 10,
		/obj/item/trash = 1,
	)
	cost = 0

	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "corrode"
	research_tree_icon_frame = 10

	var/rusting_range = 8


/datum/heretic_knowledge/entropy_pulse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	for(var/turf/nearby_turf in view(rusting_range, loc))
		if(get_dist(nearby_turf, loc) <= 1) //tiles on rune should always be rusted
			nearby_turf.rust_heretic_act()

		//we exclude closed turf to avoid exposing cultist bases
		if(prob(10) || iswallturf(nearby_turf))
			continue

		nearby_turf.rust_heretic_act()

	return TRUE


/datum/heretic_knowledge/limited_amount/summon/rusty
	name = "Ржавый ритуал"
	desc = "Позволяет превратить лужу рвоты, 15 кусочков кабеля и 10 листов железа в Ржавого Странника. \
			Ржавые Странники отлично разносят ржавчину и довольно сильны в бою."
	gain_text = "Я совместил свои навыки творца с жаждой разложения. \
				Маршал знал моё имя, и Ржавые Холмы отзывались эхом."

	required_atoms = list(
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/stack/sheet/metal = 10,
		/obj/item/stack/cable_coil = 15,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/rust_walker
	cost = 1
