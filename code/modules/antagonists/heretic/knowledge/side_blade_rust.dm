/datum/heretic_knowledge_tree_column/blade_to_rust
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/blade
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/rust

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/armor
	tier2 = list(/datum/heretic_knowledge/crucible, /datum/heretic_knowledge/rifle)
	tier3 = list(/datum/heretic_knowledge/spell/rust_charge, /datum/heretic_knowledge/greaves_of_the_prophet)


// Sidepaths for knowledge between Rust and Blade.
/datum/heretic_knowledge/armor
	name = "Ритуал оружейника"
	desc = "Позволяет преобразовать стол и противогаз в «Потустороннюю броню». \
			«Потусторонняя броня» обеспечивает отличную защиту, а также позволяет \
			колдовать без амулета при ношении капюшона."
	gain_text = "Ржавые Холмы щедро встретили Кузнеца. И Кузнец ответил им взаимностью."

	required_atoms = list(
		/obj/structure/table = 1,
		/obj/item/clothing/mask/gas = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/armor.dmi'
	research_tree_icon_state = "eldritch_armor"
	research_tree_icon_frame = 12


/datum/heretic_knowledge/crucible
	name = "Котёл Страданий"
	desc = "Позволяет преобразовать бак воды и стол в Котёл Страданий. \
			Котёл Страданий позволяет варить мощные зелья. После каждого использования \
			он содержимое какое-то время восстанавливается. \
			Вы можете ускорить этот процесс подпитывая котёл частями тела и органами."
	gain_text = "Это просто мучение. Мне не удалось вызвать фигуру Аристократа, \
				но благодаря вниманию Жреца я наткнулся на другой рецепт..."

	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/structure/table = 1,
	)
	result_atoms = list(/obj/structure/destructible/eldritch_crucible)
	cost = 1

	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "crucible"


/datum/heretic_knowledge/rifle
	name = "Винтовка Охотника на львов"
	desc = "Позволяет преобразовать кусок дерева, шкуру \
			любого животного и фотоаппарат, в винтовку Охотника на львов. \
			Винтовка Охотника на львов — это дальнобойное баллистическое оружие вмещающее три патрона. \
			Попадание по жертве оставляет вашу метку на ней."
	gain_text = "В антикварной лавке я встретил старика, владеющего очень необычным оружием. \
				Тогда я не смог его купить, но старик рассказал, как оно было создано."

	required_atoms = list(
		/obj/item/stack/sheet/wood = 1,
		/obj/item/stack/sheet/animalhide = 1,
		/obj/item/camera = 1,
	)
	result_atoms = list(/obj/item/gun/projectile/automatic/sniper_rifle/lionhunter)
	cost = 1


	research_tree_icon_path = 'icons/obj/weapons/ballistic.dmi'
	research_tree_icon_state = "goldrevolver"


/datum/heretic_knowledge/rifle_ammo
	name = "Боеприпасы для винтовки охотника на львов"
	desc = "Позволяет преобразовать 3 гильзы баллистических патронов любого калибра, \
			включая патроны для дробовика, в дополнительный магазин для винтовки охотника на львов."
	gain_text = "К оружию прилагались три грубых железных шарика - патрога. \
				Вскоре они закончились. Никакие другие боеприпасы не работали. \
				Тот старик был очень странным."
	required_atoms = list(
		/obj/item/ammo_casing = 3,
	)
	result_atoms = list(/obj/item/ammo_box/magazine/strilka310/lionhunter)
	research_tree_icon_path = 'icons/obj/weapons/ammo.dmi'
	research_tree_icon_state = "310_strip"
/*
	/// A list of calibers that the ritual will deny. Only ballistic calibers are allowed.
	var/static/list/caliber_blacklist = list(
		CALIBER_LASER,
		CALIBER_ENERGY,
		CALIBER_FOAM,
		CALIBER_ARROW,
		CALIBER_HARPOON,
		CALIBER_HOOK,
	)*/


/datum/heretic_knowledge/rifle_ammo/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
/*
	for(var/obj/item/ammo_casing/casing in atoms)
		if(!(casing.caliber in caliber_blacklist))
			continue

		// Remove any casings in the caliber_blacklist list from atoms
		atoms -= casing
*/
	// We removed any invalid casings from the atoms list,
	// return to allow the ritual to fill out selected atoms with the new list
	return TRUE


/datum/heretic_knowledge/spell/rust_charge
	name = "Заряд Ржавчины"
	desc = "Дает заклинание, которое необходимо начать стоя на ржавой плитке. Уничтожит все ржавые \
			объекты, которых вы коснётесь, нанесет большой урон не ржавым и покроет ржавчиной всё вокруг."
	gain_text = "Холмы теперь сверкали.  Чем ближе я был к ним, тем ужасней были мои мысли. \
				Я быстро собрался с духом и двинулся вперёд: последний отрезок пути был самым опасным."
	research_tree_icon_path = 'icons/mob/actions/actions_items.dmi'
	research_tree_icon_state = "sniper_zoom"
	spell_to_add = /obj/effect/proc_holder/spell/mob_cooldown/charge/rust
	cost = 1


/datum/heretic_knowledge/greaves_of_the_prophet
	name = "Поножи Пророка"
	desc = "Позволяет объединить пару ботфортов (ботинки как у службы безопасности) и 2 листа титана в пару \
			бронированных, не скользящих поножей."
	gain_text = "Хрящ отрывается, вместе с суставом, раздаётся крик и один дурак вырывает почерневшую ногу из \
				челюстей другого. Веками в их игре извивается это изуродованное дерево ветвей, \
				дрожащее силки, зарытые в рычащие десны, стремясь разорвать вес привитых соседей. \
				Отягощённый израненными ногами, этот навес прогорклых идиотов вечно стремится \
				разрушить собственные узы. Мне страшна мысль о том, чтобы идти по их следу, но \
				я всё равно должен идти вперёд. Их ритмы поддерживают вражду свежей, безразличием к \
				барьерам или границам. Вальсируя, они всё больше втягивают в свою суматоху." // Wtf
	cost = 1
	required_atoms = list(
		/obj/item/clothing/shoes/jackboots = 1,
		/obj/item/stack/sheet/mineral/titanium = 2,
	)
	result_atoms = list(/obj/item/clothing/shoes/greaves_of_the_prophet)
	research_tree_icon_path = 'icons/obj/clothing/shoes.dmi'
	research_tree_icon_state = "hereticgreaves"
