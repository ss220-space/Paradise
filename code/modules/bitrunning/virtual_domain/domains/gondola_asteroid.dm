/datum/lazy_template/virtual_domain/gondola_asteroid
	name = "Астероид гондол"
	desc = "Астероид, на котором вырос щедрый лес гондол. Мирное место."
	help_text = "Какой чудесный лес. Ящик с добычей стоит посреди карты. Хм... он не сдвигается. А вот гондолы таскают его без труда. Наверняка есть способ сдвинуть его самому."
	key = LAZY_TEMPLATE_KEY_BITRUNNING_GONDOLA_ASTEROID
	map_name = "gondola_asteroid"
	domain_flags = DOMAIN_NO_NOHIT_BONUS

/obj/structure/closet/crate/secure/bitrunning/encrypted/gondola
	move_resist = MOVE_FORCE_STRONG

/mob/living/simple_animal/pet/gondola/virtual_domain
	health = 50
	maxHealth = 50
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	loot = list(/obj/effect/decal/cleanable/blood/gibs = 1, /obj/item/reagent_containers/food/snacks/meat/virtual_gondola = 1)

/obj/item/reagent_containers/food/snacks/meat/virtual_gondola
	name = "gondola meat"
	desc = "Кусок плоти виртуальной гондолы. От него веет спокойствием."
	list_reagents = list("protein" = 4, "virtual_tranquility" = 5)

/obj/item/reagent_containers/food/snacks/meat/virtual_gondola/get_ru_names()
	return alist(
		NOMINATIVE = "мясо гандолы",
		GENITIVE = "мяса гандолы",
		DATIVE = "мясу гандолы",
		ACCUSATIVE = "мясо гандолы",
		INSTRUMENTAL = "мясом гандолы",
		PREPOSITIONAL = "мясе гандолы",
	)

/datum/reagent/virtual_tranquility
	name = "Усиленное спокойствие"
	id = "virtual_tranquility"
	description = "Мутаген виртуальных гондол."
	color = "#9A6750"
	taste_description = "внутреннего покоя"
	can_synth = FALSE

/datum/reagent/virtual_tranquility/reaction_mob(mob/living/target, method = REAGENT_TOUCH, volume)
	. = ..()
	if(method == REAGENT_TOUCH && !prob(min(volume, 100)))
		return
	var/datum/disease/virus/transformation/virtual_gondola/disease = new
	disease.Contract(target, act_type = CONTACT, need_protection_check = method == REAGENT_TOUCH)
	qdel(disease)

/datum/disease/virus/transformation/virtual_gondola
	name = "Превращение в гондолу"
	agent = "Усиленное спокойствие"
	desc = "Плоть виртуальной гондолы меняет съевшего её."
	stage_prob = 9
	cure_prob = 55
	cures = list("condensedcapsaicin")
	new_form = /mob/living/simple_animal/pet/gondola/virtual_domain
	stage1 = list(span_notice_alt("Ваш шаг стал немного легче."))
	stage2 = list(span_notice_alt("Вы улыбаетесь без причины."))
	stage3 = list(span_danger_alt("Вас охватывает жестокое спокойствие."), span_danger_alt("Вы не чувствуете рук!"), span_notice_alt("Вам больше не хочется обижать клоунов."))
	stage4 = list(span_danger_alt("Вы не чувствуете рук. Это вас больше не беспокоит."), span_notice_alt("Вы прощаете клоуна за причинённую боль."))
	stage5 = list(span_notice_alt("Вы стали гондолой."))

/datum/disease/virus/transformation/virtual_gondola/stage_act()
	. = ..()
	if(!. || QDELETED(affected_mob))
		return
	if(stage < 2 || stage > 4)
		return
	if(prob(5))
		affected_mob.emote("smile")
	if(prob(20))
		affected_mob.reagents.add_reagent("pax", 5)
	if(stage == 4 && prob(2))
		var/obj/item/held_item = affected_mob.get_active_hand()
		if(held_item)
			to_chat(affected_mob, span_notice("Вы выпускаете предмет из руки."))
			affected_mob.drop_item_ground(held_item)
