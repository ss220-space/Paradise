/datum/heretic_knowledge_tree_column/ash_to_moon
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/ash
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/moon

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/medallion
	tier2 = /datum/heretic_knowledge/ether
	tier3 = /datum/heretic_knowledge/summon/ashy


// Sidepaths for knowledge between Ash and Flesh.
/datum/heretic_knowledge/medallion
	name = "Глаза Пепла" // It should be like colour of eyes, but I think this sounds better.
	desc = "Позволяет преобразовать пару глаз, свечу и осколок стекла в Потусторонний Медальон. \
			Потусторонний Медальон дарует вам термальное зрение, пока вы его носите, а также выполняет \
			функцию амулета."
	gain_text = "Пронзительный взгляд вёл их сквозь обыденность. Ни тьма, ни страх не могли их остановить."

	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/shard = 1,
		/obj/item/candle = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)
	cost = 1
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "eye_medalion"


/datum/heretic_knowledge/ether
	name = "Душа Нерожденного Младенца"
	desc = "Превращает лужу рвоты и осколок в одноразовое зелье. Выпив его, \
			вы избавитесь от любых отклонений в вашем теле, включая болезни, травмы и имплантаты. \
			Кроме того, вы полностью восстановите здоровье, но потеряете сознание на целую минуту."
	gain_text = "Видения и мысли затуманиваются, когда пары этого вещества поднимаются мне навстречу. \
				Сквозь дымку я обнаруживаю, что смотрю на самого себя. Вернее на что-то отдалённо \
				напоминающее моё лицо. Именно эта жалкая личность будет следовать моей судьбе. Чью-то \
				чужую судьбу я поглотил вместе с этой дымкой. Как же я глуп."
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/effect/decal/cleanable/vomit = 1,
	)
	result_atoms = list(/obj/item/ether)
	cost = 1
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "poison_flask"


/datum/heretic_knowledge/summon/ashy
	name = "Ashen Ritual"
	desc = "Allows you to transmute a head, a pile of ash, and a book to create an Ash Spirit. \
		Ash Spirits have a short range jaunt and the ability to cause bleeding in foes at range. \
		They also have the ability to create a ring of fire around themselves for a length of time."
	gain_text = "I combined my principle of hunger with my desire for destruction. The Marshal knew my name, and the Nightwatcher gazed on."

	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/organ/external/head = 1,
		/obj/item/book = 1,
		)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/ash_spirit
	cost = 1

	poll_ignore_define = POLL_IGNORE_ASH_SPIRIT

