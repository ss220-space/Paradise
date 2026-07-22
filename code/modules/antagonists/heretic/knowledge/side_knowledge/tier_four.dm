/datum/heretic_knowledge/spell/space_phase
	drafting_tier = 4
	name = "Космический Сдвиг"
	desc = "Даёт вам способность \"Космический Сдвиг\", заклинание, позволяющее свободно перемещаться в пространстве. \
			Вы можете переходить использовать её, только находясь в месте с низким давлением."
	gain_text = "Вы чувствуете, что ваше тело может перемещаться в пространстве, словно вы космическая пыль."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "space_crawl"
	spell_to_add = /obj/effect/proc_holder/spell/jaunt/space_crawl
	cost = 1

	research_tree_icon_frame = 6


/datum/heretic_knowledge/spell/cleave
	drafting_tier = 4
	name = "Кровавое Рассечение" // Crimson Cleave
	desc = "Даёт вам \"Кровавое рассечение\", направленное заклинание, вытягивающее здоровье \
			в небольшой области вокруг цели. При применении очищает все ваши раны."
	gain_text = "Сначала я не понимал, как использовать эти орудия войны, но священник \
				велел мне научиться. Скоро, сказал он, я овладею ими в совершенстве."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "blood_siphon"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/cleave
	cost = 2


/datum/heretic_knowledge/unfathomable_curio
	drafting_tier = 4
	name = "Непостижимая Диковинка"
	desc = "Позволяет преобразовать 3 стержня, лёгкие и любой пояс в Непостижимую Диковинку, \
			пояс, в котором можно хранить клинки и предметы для ритуалов. Если этот пояс надет, \
			он позволит выдержать 5 ударов без получения урона. \
			Вне боя эта защита будет перезаряжаться очень медленно."
	gain_text = "В Обители хранится множество диковинок, большинство из которых не предназначены для глаз смертных."

	required_atoms = list(
		/obj/item/organ/internal/lungs = 1,
		/obj/item/stack/rods = 3,
		/obj/item/storage/belt = 1,
	)
	result_atoms = list(/obj/item/storage/belt/unfathomable_curio)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/belts.dmi'
	research_tree_icon_state = "unfathomable_curio"


/datum/heretic_knowledge/rust_sower
	drafting_tier = 4
	name = "Граната \"Ржавый Дождь\""
	desc = "Позволяет объединить оболочку химической гранаты и печень, \
			чтобы создать проклятую гранату, наполненную Жуткой Ржавчиной. \
			При детонации она выпускает огромное облако, которое ослепляет \
			органику, покрывает ржавчиной пораженные участки и уничтожает Силиконов и Мехов."
	gain_text = "Высохшие лозы Ржавых холмов покрыты перезрелыми плодами. \
				Они стирают следы прогресса, освобождая лист реальности для творца."
	required_atoms = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/organ/internal/liver = 1,
	)
	result_atoms = list(/obj/item/grenade/chem_grenade/rust_sower)
	cost = 2
	research_tree_icon_path = 'icons/obj/weapons/grenade.dmi'
	research_tree_icon_state = "rustgrenade"
