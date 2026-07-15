/datum/heretic_knowledge/armor
	abstract_parent_type = /datum/heretic_knowledge/armor
	name = "Ритуал Оружейника"
	desc = "Позволяет преобразовать стол и противогаз в \"Потустороннюю броню\". \
			\"Потусторонняя броня\" обеспечивает отличную защиту, а при надетом капюшоне \
			служит источником фокуса."
	gain_text = "Ржавые Холмы щедро встретили Кузнеца. И Кузнец ответил им взаимностью."

	required_atoms = list(
		/obj/structure/table = 1,
		/obj/item/clothing/mask/gas = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/suits.dmi'
	research_tree_icon_state = "eldritch_armor"
	research_tree_icon_frame = 12


/datum/heretic_knowledge/armor/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/datum/antagonist/heretic/our_heretic = user.mind?.has_antag_datum(/datum/antagonist/heretic)
	our_heretic?.set_passive_level(2)
	our_heretic?.gain_knowledge(/datum/heretic_knowledge/knowledge_ritual)


/datum/heretic_knowledge/crucible
	drafting_tier = 1
	name = "Котёл Страданий"
	desc = "Позволяет создать Котёл Страданий.<br>\
			Котёл Страданий варит мощные, но временные зелья. После каждого использования \
			его содержимое какое-то время восстанавливается — процесс можно ускорить, \
			подпитывая котёл частями тел и органами. \
			<br>&bull; Варево Души Котла: позволяет проходить сквозь стены. По окончании действия возвращает вас туда, где вы выпили зелье. \
			<br>&bull; Варево Заката и Рассвета: позволяет видеть сквозь стены. \
			<br>&bull; Варево Раненого Солдата: постепенно лечит вас. Чем тяжелее ваши раны (переломы, порезы), тем быстрее лечение."
	transmute_text = "Преобразуйте бак воды и стол."
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
	drafting_tier = 2
	name = "Винтовка Охотника на Львов"
	desc = "Позволяет преобразовать кусок дерева, шкуру \
			любого животного и фотоаппарат, в винтовку Охотника на Львов. \
			Винтовка Охотника на львов — это дальнобойное баллистическое оружие, вмещающее три патрона. \
			Попадание по жертве оставляет вашу метку на ней."
	gain_text = "В антикварной лавке я встретил старика, владеющего очень необычным оружием. \
				Тогда я не смог его купить, но старик рассказал, как оно было создано."

	required_atoms = list(
		/obj/item/stack/sheet/wood = 1,
		/obj/item/stack/sheet/animalhide = 1,
		/obj/item/camera = 1,
	)
	result_atoms = list(/obj/item/gun/projectile/shotgun/boltaction/lionhunter)
	cost = 2


	research_tree_icon_path = 'icons/obj/weapons/projectile.dmi'
	research_tree_icon_state = "goldrevolver"


/datum/heretic_knowledge/rifle_ammo
	name = "Боеприпасы для винтовки Охотника на Львов"
	desc = "Позволяет преобразовать 3 гильзы баллистических патронов любого калибра, \
			включая патроны для дробовика, в дополнительный магазин для винтовки Охотника на Львов."
	gain_text = "К оружию прилагались три грубых железных шарика — патрона. \
				Вскоре они закончились. Никакие другие боеприпасы не работали. \
				Тот старик был очень странным."
	required_atoms = list(
		/obj/item/ammo_casing = 3,
	)
	result_atoms = list(/obj/item/ammo_box/speedloader/lionhunter)
	research_tree_icon_path = 'icons/obj/weapons/ammo.dmi'
	research_tree_icon_state = "310_strip"


/datum/heretic_knowledge/rifle_ammo/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	return TRUE


/datum/heretic_knowledge/spell/rust_charge
	name = "Заряд Ржавчины"
	desc = "Дает заклинание, которое необходимо начать стоя на ржавой плитке. Уничтожит все ржавые \
			объекты, которых вы коснётесь, нанесет большой урон нержавым и покроет ржавчиной всё вокруг."
	gain_text = "Холмы теперь сверкали. Чем ближе я был к ним, тем ужасней были мои мысли. \
				Я быстро собрался с духом и двинулся вперёд: последний отрезок пути был самым опасным."
	research_tree_icon_path = 'icons/mob/actions/actions_items.dmi'
	research_tree_icon_state = "sniper_zoom"
	spell_to_add = /obj/effect/proc_holder/spell/mob_cooldown/charge/rust
	cost = 2


/datum/heretic_knowledge/greaves_of_the_prophet
	drafting_tier = 2
	name = "Поножи Пророка"
	desc = "Позволяет объединить пару берцев и 2 листа титана в пару \
			бронированных, не скользящих поножей."
	gain_text = "Хрящи с хрустом проворачиваются в суставах — резкий омерзительный щелчок, и безумец \
		вырывает почерневшую ступню из пасти другого. Веками ведя свою игру, это изувеченное сплетение конечностей \
		корчится и бьётся; вцепившись в оскалённые десны, они пытаются разорвать на части тяжесть своих приросших \
		друг к другу собратьев. Отягощённая истерзанными ногами, эта крона из зловонных идиотов вечно стремится \
		разорвать узы, сковывающие их воедино. Меня страшит мысль о том, чтобы идти по их следам, \
		но я все же обязан двигаться дальше. Их ритмы, не ведающие преград и границ, разжигают вражду \
		с новой силой, вовлекая всё новых и новых участников в этот безумный вальс."
	cost = 1
	required_atoms = list(
		/obj/item/clothing/shoes/jackboots = 1,
		/obj/item/stack/sheet/mineral/titanium = 2,
	)
	result_atoms = list(/obj/item/clothing/shoes/greaves_of_the_prophet)
	research_tree_icon_path = 'icons/obj/clothing/shoes.dmi'
	research_tree_icon_state = "hereticgreaves"
