/obj/item/reagent_containers/spray
	name = "spray bottle"
	desc = "Бутылка с распылителем, с отвинчивающейся крышкой. Пшик-пшик."
	ru_names = list(
		NOMINATIVE = "распылитель",
		GENITIVE = "распылителя",
		DATIVE = "распылителю",
		ACCUSATIVE = "распылитель",
		INSTRUMENTAL = "распылителем",
		PREPOSITIONAL = "распылителе"
	)
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	belt_icon = "cleaner"
	item_flags = NOBLUDGEON
	container_type = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	var/spray_maxrange = 3 //what the sprayer will set spray_currentrange to in the attack_self.
	var/spray_currentrange = 3 //the range of tiles the sprayer will reach when in fixed mode.
	amount_per_transfer_from_this = 5
	volume = 250
	possible_transfer_amounts = null
	var/delay = CLICK_CD_RANGE * 2

/obj/item/reagent_containers/spray/afterattack(atom/A, mob/user, proximity, params)
	if(isstorage(A) || istype(A, /obj/structure/table) || istype(A, /obj/structure/rack) || istype(A, /obj/structure/closet) \
	|| istype(A, /obj/item/reagent_containers) || istype(A, /obj/structure/sink) || istype(A, /obj/structure/janitorialcart) || istype(A, /obj/machinery/hydroponics))
		return

	if(istype(A, /obj/effect/proc_holder/spell))
		return

	if(istype(A, /obj/structure/reagent_dispensers) && get_dist(src,A) <= 1) //this block copypasted from reagent_containers/glass, for lack of a better solution
		if(!A.reagents.total_volume && A.reagents)
			balloon_alert(user, "пусто!")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			balloon_alert(user, "нет места!")
			return

		var/trans = A.reagents.trans_to(src, 50) //This is a static amount, otherwise, it'll take forever to fill.
		to_chat(user, span_notice("Вы заполняете [declent_ru(ACCUSATIVE)] [trans] единиц[declension_ru(trans, "ей", "ами", "ами")] содержимого [A.declent_ru(GENITIVE)]."))
		return

	if(reagents.total_volume < amount_per_transfer_from_this)
		balloon_alert(user, "пусто!")
		return

	var/contents_log = reagents.reagent_list.Join(", ")
	INVOKE_ASYNC(src, PROC_REF(spray), A)

	playsound(loc, 'sound/effects/spray2.ogg', 50, 1, -6)
	user.changeNext_move(delay)
	user.newtonian_move(get_dir(A, user))

	var/attack_log_type = ATKLOG_ALMOSTALL

	if(reagents.chem_temp > 300 || reagents.chem_temp < 280)	//harmful temperature
		attack_log_type = ATKLOG_MOST

	if(reagents.reagent_list.len == 1 && reagents.has_reagent("cleaner")) // Only create space cleaner logs if it's burning people from being too hot or cold
		if(attack_log_type == ATKLOG_ALMOSTALL)
			return

	//commonly used for griefing or just very annoying and dangerous
	if(reagents.has_reagent("sacid") || reagents.has_reagent("facid") || reagents.has_reagent("lube"))
		attack_log_type = ATKLOG_FEW

	add_attack_logs(user, A, "Used a spray bottle. Contents: [contents_log] - Temperature: [reagents.chem_temp]K", attack_log_type)
	return


/obj/item/reagent_containers/spray/proc/spray(atom/A)
	var/obj/effect/decal/chempuff/D = new /obj/effect/decal/chempuff(get_turf(src))
	D.create_reagents(amount_per_transfer_from_this)
	reagents.trans_to(D, amount_per_transfer_from_this, 1/spray_currentrange)
	D.icon += mix_color_from_reagents(D.reagents.reagent_list)
	var/turf/target_turf = get_turf(A)
	for(var/i in 1 to spray_currentrange)
		step_towards(D, target_turf)
		D.reagents.reaction(get_turf(D))
		for(var/atom/T in get_turf(D))
			D.reagents.reaction(T)
		sleep(3)
	qdel(D)


/obj/item/reagent_containers/spray/attack_self(var/mob/user)

	amount_per_transfer_from_this = (amount_per_transfer_from_this == 10 ? 5 : 10)
	spray_currentrange = (spray_currentrange == 1 ? spray_maxrange : 1)
	to_chat(user, span_notice("Вы [amount_per_transfer_from_this == 10 ? "снимаете" : "надеваете"] насадку. Теперь вы будете распылять по [amount_per_transfer_from_this] единиц[declension_ru(amount_per_transfer_from_this, "е", "ы", "")] содержимого за раз."))

/obj/item/reagent_containers/spray/examine(mob/user)
	. = ..()
	if(get_dist(user, src) && user == loc)
		. += span_notice("Внутри остал[declension_ru(reagents.total_volume, "а", "о", "о")]сь примерно [round(reagents.total_volume)] единиц[declension_ru(reagents.total_volume, "а", "ы", "")] вещества.")

//space cleaner
/obj/item/reagent_containers/spray/cleaner
	name = "space cleaner"
	desc = "Распылитель, заполненный непенящимся средством для очистки поверхностей. Произведено компанией \"BLAM!\"."
	ru_names = list(
		NOMINATIVE = "распылитель",
		GENITIVE = "распылителя",
		DATIVE = "распылителю",
		ACCUSATIVE = "распылитель",
		INSTRUMENTAL = "распылителем",
		PREPOSITIONAL = "распылителе"
	)
	list_reagents = list("cleaner" = 250)

/obj/item/reagent_containers/spray/cleaner/brig
	name = "brig cleaner"
	desc = "Распылитель, заполненный непенящимся средством для очистки поверхностей. Идеально подойдёт для уборки брига после очередного допроса клоуна."
	ru_names = list(
		NOMINATIVE = "распылитель СБ",
		GENITIVE = "распылителя СБ",
		DATIVE = "распылителю СБ",
		ACCUSATIVE = "распылитель СБ",
		INSTRUMENTAL = "распылителем СБ",
		PREPOSITIONAL = "распылителе СБ"
	)
	icon_state = "cleaner_brig"
	item_state = "cleaner_brig"

/obj/item/reagent_containers/spray/cleaner/brig/empty
	list_reagents = list()

/obj/item/reagent_containers/spray/cleaner/chemical
	name = "chemical cleaner"
	desc = "Нет ничего безопаснее, чем смывать пролитый калий водой."
	ru_names = list(
		NOMINATIVE = "химический распылитель",
		GENITIVE = "химическего распылителя",
		DATIVE = "химическому распылителю",
		ACCUSATIVE = "химический распылитель",
		INSTRUMENTAL = "химическим распылителем",
		PREPOSITIONAL = "химическом распылителе"
	)
	icon_state = "cleaner_chemical"
	item_state = "cleaner_medchem"

/obj/item/reagent_containers/spray/cleaner/chemical/empty
	list_reagents = list()

/obj/item/reagent_containers/spray/cleaner/janitor
	name = "janitorial cleaner"
	desc = "Распылитель, заполненный непенящимся средством для очистки поверхностей. Стильный дизайн, специально для самого продуктивного работника станции!"
	ru_names = list(
		NOMINATIVE = "распылитель уборщика",
		GENITIVE = "распылителя уборщика",
		DATIVE = "распылителю уборщика",
		ACCUSATIVE = "распылитель уборщика",
		INSTRUMENTAL = "распылителем уборщика",
		PREPOSITIONAL = "распылителе уборщика"
	)
	icon_state = "cleaner_janitor"
	item_state = "cleaner_jan"

/obj/item/reagent_containers/spray/cleaner/janitor/empty
	list_reagents = list()

/obj/item/reagent_containers/spray/cleaner/medical
	name = "medical cleaner"
	desc = "Распылитель, заполненный непенящимся средством для очистки поверхностей. Дезинфицирующее средство для рук, пола и халата Главного Врача."
	ru_names = list(
		NOMINATIVE = "медицинский распылитель",
		GENITIVE = "медицинского распылителя",
		DATIVE = "медицинскому распылителю",
		ACCUSATIVE = "медицинский распылитель",
		INSTRUMENTAL = "медицинским распылителем",
		PREPOSITIONAL = "медицинском распылителе"
	)
	icon_state = "cleaner_medical"
	item_state = "cleaner_med"

/obj/item/reagent_containers/spray/cleaner/medical/empty
	list_reagents = list()

/obj/item/reagent_containers/spray/cleaner/tactical
	name = "Tactical cleaner"
	desc = "Бутылочка из прочнейшего тёмно-синего пластика, наверху которой прикреплён распылитель, оборудованный коллиматорным прицелом и глушителем. Разработано Уборочно-Силовыми Структурами Нанотрейзен для ЗАЧИСТКИ и контроля грязи в помещениях. Порадуйте своего внутреннего тактикульщика!"
	ru_names = list(
		NOMINATIVE = "тактический распылитель",
		GENITIVE = "тактическего распылителя",
		DATIVE = "тактическому распылителю",
		ACCUSATIVE = "тактический распылитель",
		INSTRUMENTAL = "тактическим распылителем",
		PREPOSITIONAL = "тактическом распылителе"
	)
	icon_state = "cleaner_tactical"
	item_state = "cleaner_tactical"

/obj/item/reagent_containers/spray/blue_cleaner
	name = "bluespace cleaner"
	desc = "Распылитель с увеличенным объёмом, изготовленный с использованием блюспейс-технологий. Оно точно того стоило?"
	ru_names = list(
		NOMINATIVE = "блюспейс распылитель",
		GENITIVE = "блюспейс распылителя",
		DATIVE = "блюспейс распылителю",
		ACCUSATIVE = "блюспейс распылитель",
		INSTRUMENTAL = "блюспейс распылителем",
		PREPOSITIONAL = "блюспейс распылителе"
	)
	icon_state = "cleaner_bluespace"
	item_state = "cleaner_bs"
	spray_maxrange = 4
	spray_currentrange = 4
	volume = 450

/obj/item/reagent_containers/spray/cleaner/safety
	desc = "Распылитель, заполненный непенящимся средством для очистки поверхностей. Эта модель принимает внутрь только космочист и ничего более."

/obj/item/reagent_containers/spray/cleaner/safety/on_reagent_change()
	for(var/filth in reagents.reagent_list)
		var/datum/reagent/R = filth
		if(R.id != "cleaner") //all chems other than space cleaner are filthy.
			reagents.del_reagent(R.id)
			if(ismob(loc))
				to_chat(loc, span_warning("[capitalize(declent_ru(NOMINATIVE))] определяет и удаляет недопустимое вещество."))
			else
				visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] определяет и удаляет недопустимое вещество."))

/obj/item/reagent_containers/spray/cleaner/drone
	volume = 50
	list_reagents = list("cleaner" = 50)

//spray tan
/obj/item/reagent_containers/spray/spraytan
	name = "spray tan"
	volume = 50
	desc = "Спрей-автозагар от бренда \"Gyaro\". Не попадите в глаза!"
	ru_names = list(
		NOMINATIVE = "спрей для авто-загара",
		GENITIVE = "спрея для авто-загара",
		DATIVE = "спрею для авто-загара",
		ACCUSATIVE = "спрей для авто-загара",
		INSTRUMENTAL = "спреем для авто-загара",
		PREPOSITIONAL = "спрее для авто-загара"
	)
	list_reagents = list("spraytan" = 50)

//pepperspray
/obj/item/reagent_containers/spray/pepper
	name = "pepperspray"
	desc = "Произведено компанией \"UhangInc\", используется для быстрого ослепления и обезвреживания противника."
	ru_names = list(
		NOMINATIVE = "перцовый баллончик",
		GENITIVE = "перцового баллончика",
		DATIVE = "перцовому баллончику",
		ACCUSATIVE = "перцовый баллончик",
		INSTRUMENTAL = "перцовым баллончиком",
		PREPOSITIONAL = "перцовом баллончике"
	)
	icon = 'icons/obj/items.dmi'
	icon_state = "pepperspray"
	item_state = "pepperspray"
	belt_icon = "pepperspray"
	volume = 40
	spray_maxrange = 4
	amount_per_transfer_from_this = 5
	list_reagents = list("condensedcapsaicin" = 40)

//water flower
/obj/item/reagent_containers/spray/waterflower
	name = "water flower"
	desc = "Невинный на первый взгляд подсолнух... с изюминкой."
	ru_names = list(
		NOMINATIVE = "водяной подсолнух",
		GENITIVE = "водяного подсолнуха",
		DATIVE = "водяному подсолнуху",
		ACCUSATIVE = "водяной подсолнух",
		INSTRUMENTAL = "водяным подсолнухом",
		PREPOSITIONAL = "водяном подсолнухе"
	)
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	amount_per_transfer_from_this = 1
	volume = 10
	list_reagents = list("water" = 10)

/obj/item/reagent_containers/spray/waterflower/attack_self(mob/user) //Don't allow changing how much the flower sprays
	return

//chemsprayer
/obj/item/reagent_containers/spray/chemsprayer
	name = "chem sprayer"
	desc = "Инструмент, используемый для распыления большого количества веществ в заданной области."
	ru_names = list(
		NOMINATIVE = "химический распылитель веществ",
		GENITIVE = "химическего распылителя веществ",
		DATIVE = "химическому распылителю веществ",
		ACCUSATIVE = "химический распылитель веществ",
		INSTRUMENTAL = "химическим распылителем веществ",
		PREPOSITIONAL = "химическом распылителе веществ"
	)
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	spray_maxrange = 7
	spray_currentrange = 7
	amount_per_transfer_from_this = 10
	volume = 600
	origin_tech = "combat=3;materials=3;engineering=3"


/obj/item/reagent_containers/spray/chemsprayer/spray(var/atom/A)
	var/Sprays[3]
	for(var/i=1, i<=3, i++) // intialize sprays
		if(reagents.total_volume < 1) break
		var/obj/effect/decal/chempuff/D = new/obj/effect/decal/chempuff(get_turf(src))
		D.create_reagents(amount_per_transfer_from_this)
		reagents.trans_to(D, amount_per_transfer_from_this)

		D.icon += mix_color_from_reagents(D.reagents.reagent_list)

		Sprays[i] = D

	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)

	for(var/i=1, i<=Sprays.len, i++)
		spawn()
			var/obj/effect/decal/chempuff/D = Sprays[i]
			if(!D) continue

			// Spreads the sprays a little bit
			var/turf/my_target = pick(the_targets)
			the_targets -= my_target

			for(var/j=0, j<=spray_currentrange, j++)
				step_towards(D, my_target)
				D.reagents.reaction(get_turf(D))
				for(var/atom/t in get_turf(D))
					D.reagents.reaction(t)
				sleep(2)
			qdel(D)



/obj/item/reagent_containers/spray/chemsprayer/attack_self(mob/user)

	amount_per_transfer_from_this = (amount_per_transfer_from_this == 10 ? 5 : 10)
	to_chat(user, span_notice("Вы настраиваете объём распыления. Теперь вы будете распылять по [amount_per_transfer_from_this] единиц[declension_ru(amount_per_transfer_from_this, "е", "ы", "")] содержимого за раз."))


// Plant-B-Gone
/obj/item/reagent_containers/spray/plantbgone // -- Skie
	name = "Plant-B-Gone"
	desc = "Распылитель гербицидов для уничтожения этих надоедливых сорняков!"
	ru_names = list(
		NOMINATIVE = "распылитель гербицидов \"Plant-B-Gone\"",
		GENITIVE = "распылителя гербицидов \"Plant-B-Gone\"",
		DATIVE = "распылителю гербицидов \"Plant-B-Gone\"",
		ACCUSATIVE = "распылитель гербицидов \"Plant-B-Gone\"",
		INSTRUMENTAL = "распылителем гербицидов \"Plant-B-Gone\"",
		PREPOSITIONAL = "распылителе гербицидов \"Plant-B-Gone\""
	)
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbgone"
	item_state = "plantbgone"
	volume = 100
	list_reagents = list("glyphosate" = 100)

