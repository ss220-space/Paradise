// MARK: Base Cup
/obj/item/reagent_containers/cup
	name = " "
	abstract_type = /obj/item/reagent_containers/cup
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50)
	volume = 50
	container_type = OPENCONTAINER
	resistance_flags = ACID_PROOF

	/// Like Edible's food type, what kind of drink is this?
	var/drink_type = NONE
	/// How much we drink at once, shot glasses drink more.
	var/gulp_size = 5
	/// Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it.
	var/is_glass = FALSE
	/// What kind of chem transfer method does this cup use. Defaults to INGEST
	var/reagent_consumption_method = REAGENT_INGEST
	/// What sound does our consumption play on consuming from the container?
	var/consumption_sound = 'sound/items/drink.ogg'
	/// Whether to allow heating up the contents with a source of flame.
	var/heatable = TRUE
	/// Can we put a lid on this container?
	var/can_lid = FALSE
	/// Does this container have a lid on right now?
	var/has_lid = FALSE
	/// The last time we have checked for taste.
	COOLDOWN_DECLARE(last_check_time)

/obj/item/reagent_containers/cup/Initialize(mapload, vol)
	. = ..()
	if(heatable)
		AddElement(/datum/element/reagents_item_heatable)
	register_context()
	register_item_context()

/obj/item/reagent_containers/cup/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(isnull(held_item) || held_item == src)
		if(can_lid)
			context[SCREENTIP_CONTEXT_ALT_LMB] = "[has_lid ? "Снять" : "Надеть"] крышку"
			. = CONTEXTUAL_SCREENTIP_SET
		if(has_variable_transfer_amount)
			context[SCREENTIP_CONTEXT_LMB] = "Перемещать больше"
			context[SCREENTIP_CONTEXT_RMB] = "Перемещать меньше"
			. = CONTEXTUAL_SCREENTIP_SET

/obj/item/reagent_containers/cup/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	. = ..()

	if(!is_open_container() || target == source)
		return

	if(user.a_intent == INTENT_HARM && reagents.total_volume)
		context[SCREENTIP_CONTEXT_RMB] = "Вылить содержимое на цель"
		. = CONTEXTUAL_SCREENTIP_SET

	if(target.is_refillable() && reagents.total_volume)
		context[SCREENTIP_CONTEXT_LMB] = "Вылить в [iscup(target) ? "эту ёмкость" : "этот объект"]"
		. = CONTEXTUAL_SCREENTIP_SET

	if(isliving(target) && reagents.total_volume)
		context[SCREENTIP_CONTEXT_LMB] = "[target == user ? "Сделать глоток" : "Напоить"] из ёмкости"
		context[SCREENTIP_CONTEXT_RMB] = "[target == user ? "Пить" : "Поить"] до опустошения"
		. = CONTEXTUAL_SCREENTIP_SET

	if(target.is_drainable())
		context[SCREENTIP_CONTEXT_RMB] = "Налить из [iscup(target) ? "этой ёмкости" : "этого объекта"]"
		. = CONTEXTUAL_SCREENTIP_SET

/obj/item/reagent_containers/cup/examine(mob/user)
	. = ..()
	if(can_lid)
		if(has_lid)
			. += span_notice("Закрыто крышкой. Используйте [EXAMINE_HINT("ALT+ЛКМ")], чтобы снять её.")
		else
			. += span_notice("Может быть закрыто крышкой. Используйте [EXAMINE_HINT("ALT+ЛКМ")], чтобы надеть её.")

// TODO: заменить после порта `edible` компонента с ТГ
/obj/item/reagent_containers/cup/proc/checkLiked(fraction, mob/eater)
	if(!COOLDOWN_FINISHED(src, last_check_time))
		return FALSE
	if(!ishuman(eater))
		return FALSE
	var/mob/living/carbon/human/gourmand = eater

	var/drink_taste_reaction

	if(drink_type & gourmand.dna.species.toxic_food)
		drink_taste_reaction = FOOD_TOXIC
	else if(drink_type & gourmand.dna.species.disliked_food)
		drink_taste_reaction = FOOD_DISLIKED
	else if(drink_type & gourmand.dna.species.liked_food)
		drink_taste_reaction = FOOD_LIKED

	switch(drink_taste_reaction)
		if(FOOD_TOXIC)
			to_chat(gourmand, span_danger("Это было отвратительно! Мерзость!"))
			gourmand.AdjustDisgust((25 + 30 * fraction) STATUS_EFFECT_CONSTANT)
		if(FOOD_DISLIKED)
			to_chat(gourmand, span_warning("Это было очень невкусно. Фу."))
			gourmand.AdjustDisgust((15 + 16 * fraction) STATUS_EFFECT_CONSTANT)
		if(FOOD_LIKED)
			to_chat(gourmand, span_notice("Какой замечательный вкус!"))
			gourmand.AdjustDisgust((-12 + -8 * fraction) STATUS_EFFECT_CONSTANT)

	COOLDOWN_START(src, last_check_time, 5 SECONDS)

/obj/item/reagent_containers/cup/proc/try_drink(mob/living/target_mob, mob/living/user, repeat_drinking = FALSE)
	if(!can_consume(target_mob, user))
		return ITEM_INTERACT_BLOCKING

	user.changeNext_move(CLICK_CD_MELEE)
	if(target_mob != user)
		if(DOING_INTERACTION_WITH_TARGET(user, target_mob))
			return ITEM_INTERACT_BLOCKING
		target_mob.visible_message(
			span_danger("[user] пыта[PLUR_ET_YUT(user)]ся напоить содержимым [declent_ru(GENITIVE)] [target_mob]!"),
			span_userdanger("[user] пыта[PLUR_ET_YUT(user)]ся напоить вас содержимым [declent_ru(GENITIVE)]!"),
		)
		if(target_mob.is_blind())
			to_chat(target_mob, span_userdanger("Кто-то пытается вас чем-то напоить!"))
		if(!do_after(user, 3 SECONDS, target_mob))
			return ITEM_INTERACT_BLOCKING
		if(!reagents || !reagents.total_volume)
			return ITEM_INTERACT_BLOCKING // The drink might be empty after the delay, such as by spam-feeding
		target_mob.visible_message(
			span_danger("[user] напоил[GEND_A_O_I(user)] [target_mob] содержимым [declent_ru(GENITIVE)]!"),
			span_userdanger("[user] напоил[GEND_A_O_I(user)] вас содержимым [declent_ru(GENITIVE)]!"),
		)
		if(target_mob.is_blind())
			to_chat(target_mob, span_userdanger("Вас чем-то напоили!"))
		add_attack_logs(user, target_mob, "Fed with [name] containing [reagents.log_list()]")

	else
		if(repeat_drinking)
			if(DOING_INTERACTION_WITH_TARGET(user, user))
				return ITEM_INTERACT_BLOCKING
			user.visible_message(
				span_notice("[user] пыта[PLUR_ET_YUT(user)]ся попить из [declent_ru(GENITIVE)]."),
				ignored_mobs = list(user),
			)
			to_chat(user, span_notice("Вы пытаетесь попить из [declent_ru(GENITIVE)]."))
			if(!do_after(user, 1.25 SECONDS, user, DA_IGNORE_USER_LOC_CHANGE))
				return ITEM_INTERACT_BLOCKING
			if(!reagents || !reagents.total_volume)
				return ITEM_INTERACT_BLOCKING
			user.visible_message(
				span_notice("[user] пь[PLUR_ET_YUT(user)] из [declent_ru(GENITIVE)]."),
				ignored_mobs = list(user),
			)
		to_chat(user, span_notice("Вы делаете глоток из [declent_ru(GENITIVE)]."))

	SEND_SIGNAL(src, COMSIG_GLASS_DRANK, target_mob, user)
	var/fraction = min(gulp_size / reagents.total_volume, 1)
	reagents.trans_to(target_mob, gulp_size)
	reagents.reaction(target_mob, reagent_consumption_method, fraction)
	checkLiked(fraction, target_mob)
	playsound(target_mob, consumption_sound, rand(10, 50), TRUE)

	if(repeat_drinking)
		return try_drink(target_mob, user, TRUE) | ITEM_INTERACT_SUCCESS

	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/cup/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()

	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(!is_open_container())
		return NONE

	if(target.is_refillable()) //Something like a glass. Player probably wants to transfer TO it.
		return try_refill(target, user)

	if(isliving(target))
		return try_drink(target, user)

	return NONE

/obj/item/reagent_containers/cup/interact_with_atom_secondary(atom/target, mob/living/user, list/modifiers)
	. = ..()

	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(!is_open_container())
		return NONE

	if(target.is_drainable() && is_reagent_dispenser(target)) //A dispenser. Transfer FROM it.
		return try_drain(target, user)

	if(isliving(target))
		return try_drink(target, user, TRUE)

	return NONE

/obj/item/reagent_containers/cup/update_overlays()
	. = ..()
	if(has_lid)
		. += mutable_appearance(icon, "[icon_state]_lid")

// For player convinience, assume that the lids are rubber and can be pierced with a syringe
/obj/item/reagent_containers/cup/is_refillable()
	return ..() && !has_lid

/obj/item/reagent_containers/cup/is_drainable()
	return ..() && !has_lid

/obj/item/reagent_containers/cup/is_dunkable()
	return ..() && !has_lid

/obj/item/reagent_containers/cup/click_alt(mob/user)
	if(!can_lid)
		return NONE

	has_lid = !has_lid
	update_appearance()
	balloon_alert(user, "крышка [has_lid ? "надета" : "снята"]")
	if(has_lid)
		container_type &= ~OPENCONTAINER
	else
		container_type |= OPENCONTAINER
	return CLICK_ACTION_SUCCESS

// MARK: Beaker
/obj/item/reagent_containers/cup/beaker
	name = "beaker"
	desc = "Простой стеклянный стакан. На его стенках обозначены деления для измерения объёма содержимого."
	icon_state = "beaker"
	item_state = "beaker"
	belt_icon = "beaker"
	materials = list(MAT_GLASS=500)
	custom_price = PAYCHECK_MIN / 5
	can_lid = TRUE
	fill_icon_thresholds = list(1, 10, 25, 50, 75, 80, 100)
	var/obj/item/assembly_holder/assembly = null
	var/can_assembly = TRUE

/obj/item/reagent_containers/cup/beaker/get_ru_names()
	return alist(
		NOMINATIVE = "мерный стакан",
		GENITIVE = "мерного стакана",
		DATIVE = "мерному стакану",
		ACCUSATIVE = "мерный стакан",
		INSTRUMENTAL = "мерным стаканом",
		PREPOSITIONAL = "мерном стакане",
	)

/obj/item/reagent_containers/cup/beaker/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/reagent_containers/cup/beaker/examine(mob/user)
	. = ..()
	if(assembly)
		. += span_notice("К нему прикреплен[GEND_A_O_Y(assembly)] [assembly]. Открутите [GEND_HIS_HER(assembly)] чем-нибудь, чтобы отсоединить.")

/obj/item/reagent_containers/cup/beaker/update_overlays()
	. = ..()

	if(has_lid && blocks_emissive == EMISSIVE_BLOCK_NONE)
		. += emissive_blocker(icon, "lid_[initial(icon_state)]", src)

	if(assembly)
		. += "assembly"

GAME_VERB_SRC(/obj/item/reagent_containers/cup/beaker, remove_assembly, usr, "Отсоединить", VERB_CATEGORY_HIDDEN)
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	if(assembly)
		balloon_alert(usr, "заготовка отсоединена")
		assembly.forceMove_turf()
		usr.put_in_hands(assembly, ignore_anim = FALSE)
		assembly = null
		update_icon(UPDATE_OVERLAYS)
	else
		balloon_alert(usr, "нечего отсоединять!")

/obj/item/reagent_containers/cup/beaker/proc/heat_beaker()
	if(reagents)
		reagents.temperature_reagents(4000)

/obj/item/reagent_containers/cup/beaker/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/assembly_holder))
		add_fingerprint(user)
		if(!can_assembly)
			balloon_alert(user, "несовместимо!")
			return ATTACK_CHAIN_PROCEED
		if(assembly)
			balloon_alert(user, "заготовка уже прикреплена!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		balloon_alert(user, "заготовка прикреплена")
		assembly = I
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/reagent_containers/cup/beaker/HasProximity(atom/movable/AM)
	if(assembly)
		assembly.HasProximity(AM)

/obj/item/reagent_containers/cup/beaker/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(assembly)
		assembly.assembly_crossed(arrived, old_loc)

/obj/item/reagent_containers/cup/beaker/on_found(mob/finder) //for mousetraps
	if(assembly)
		assembly.on_found(finder)

/obj/item/reagent_containers/cup/beaker/hear_talk(mob/living/M, list/message_pieces)
	. = ..()
	if(assembly)
		assembly.hear_talk(M, message_pieces)

/obj/item/reagent_containers/cup/beaker/hear_message(mob/living/M, msg)
	if(assembly)
		assembly.hear_message(M, msg)

/obj/item/reagent_containers/cup/beaker/large
	name = "large beaker"
	desc = "Как обычный мерный стакан, только в два раза больше объёмом."
	icon_state = "beakerlarge"
	belt_icon = "large_beaker"
	materials = list(MAT_GLASS=2500)
	custom_price = PAYCHECK_MIN / 2
	volume = 100
	possible_transfer_amounts = list(5, 10, 15, 25, 30, 50, 100)

/obj/item/reagent_containers/cup/beaker/large/get_ru_names()
	return alist(
		NOMINATIVE = "большой мерный стакан",
		GENITIVE = "большого мерного стакана",
		DATIVE = "большому мерному стакану",
		ACCUSATIVE = "большой мерный стакан",
		INSTRUMENTAL = "большим мерным стаканом",
		PREPOSITIONAL = "большом мерном стакане",
	)

// MARK: Vial
/obj/item/reagent_containers/cup/beaker/vial
	name = "vial"
	desc = "Небольшая стеклянная колбочка, часто используемая вирусологами в работе."
	icon_state = "vial"
	belt_icon = "vial"
	materials = list(MAT_GLASS = 250)
	volume = 25
	possible_transfer_amounts = list(5, 10, 15, 25)
	can_assembly = 0

/obj/item/reagent_containers/cup/beaker/vial/get_ru_names()
	return alist(
		NOMINATIVE = "пробирка",
		GENITIVE = "пробирки",
		DATIVE = "пробирке",
		ACCUSATIVE = "пробирку",
		INSTRUMENTAL = "пробиркой",
		PREPOSITIONAL = "пробирке",
	)

/obj/item/reagent_containers/cup/beaker/plastic_baggie
	icon_state = "baggie"
	can_assembly = 0
	can_lid = FALSE
	volume = 25

/obj/item/reagent_containers/cup/beaker/plastic_baggie/drugs
	name = "baggie"
	desc = "Небольшой пластиковый пакет, часто используемый фармацевтическими \"предпринимателями\"."
	amount_per_transfer_from_this = 2
	has_variable_transfer_amount = FALSE

/obj/item/reagent_containers/cup/beaker/plastic_baggie/drugs/get_ru_names()
	return alist(
		NOMINATIVE = "пластиковый пакетик",
		GENITIVE = "пластикового пакетика",
		DATIVE = "пластиковому пакетику",
		ACCUSATIVE = "пластиковый пакетик",
		INSTRUMENTAL = "пластиковым пакетиком",
		PREPOSITIONAL = "пластиковом пакетике",
	)

/obj/item/reagent_containers/cup/beaker/plastic_baggie/thermite
	name = "Thermite load"
	desc = "Пластиковый пакетик, надпись на этикетке – \"Термит\"."
	amount_per_transfer_from_this = 25
	has_variable_transfer_amount = FALSE
	list_reagents = list("thermite" = 25)

/obj/item/reagent_containers/cup/beaker/plastic_baggie/thermite/get_ru_names()
	return alist(
		NOMINATIVE = "пластиковый пакетик (Термит)",
		GENITIVE = "пластикового пакетика (Термит)",
		DATIVE = "пластиковому пакетику (Термит)",
		ACCUSATIVE = "пластиковый пакетик (Термит)",
		INSTRUMENTAL = "пластиковым пакетиком (Термит)",
		PREPOSITIONAL = "пластиковом пакетике (Термит)",
	)

/obj/item/reagent_containers/cup/beaker/noreact
	name = "cryostasis beaker"
	desc = "Криостазисная мензурка, позволяющий хранить химические вещества в таком состоянии, при котором они не вступают в реакцию друг с другом."
	icon_state = "beakernoreact"
	materials = list(MAT_METAL=3000)
	origin_tech = "materials=2;engineering=3;plasmatech=3"
	can_lid = FALSE

/obj/item/reagent_containers/cup/beaker/noreact/get_ru_names()
	return alist(
		NOMINATIVE = "криостазиный мерный стакан",
		GENITIVE = "криостазиного мерного стакана",
		DATIVE = "криостазиному мерному стакану",
		ACCUSATIVE = "криостазиный мерный стакан",
		INSTRUMENTAL = "криостазиным мерным стаканом",
		PREPOSITIONAL = "криостазином мерном стакане",
	)

/obj/item/reagent_containers/cup/beaker/noreact/Initialize(mapload)
	. = ..()
	reagents.set_reacting(FALSE)

/obj/item/reagent_containers/cup/beaker/bluespace
	name = "bluespace beaker"
	desc = "Мензурка, работающая на экспериментальной блюспейс технологии и элементе \"Кубаний\" в сочетании с соединением \"Питий\"."
	icon_state = "beakerbluespace"
	materials = list(MAT_GLASS=3000)
	volume = 300
	possible_transfer_amounts = list(5, 10, 15, 25, 30, 50, 100, 300)
	origin_tech = "bluespace=5;materials=4;plasmatech=4"
	can_lid = FALSE

/obj/item/reagent_containers/cup/beaker/bluespace/get_ru_names()
	return alist(
		NOMINATIVE = "блюспейс мерный стакан",
		GENITIVE = "блюспейс мерного стакана",
		DATIVE = "блюспейс мерному стакану",
		ACCUSATIVE = "блюспейс мерный стакан",
		INSTRUMENTAL = "блюспейс мерным стаканом",
		PREPOSITIONAL = "блюспейс мерном стакане",
	)

/obj/item/reagent_containers/cup/beaker/cryoxadone
	list_reagents = list("cryoxadone" = 30)

/obj/item/reagent_containers/cup/beaker/sacid
	list_reagents = list("sacid" = 50)

/obj/item/reagent_containers/cup/beaker/slimejelly
	list_reagents = list("slimejelly" = 50)

/obj/item/reagent_containers/cup/beaker/plastic_baggie/drugs/meth
	list_reagents = list("methamphetamine" = 10)

/obj/item/reagent_containers/cup/beaker/laughter
	list_reagents = list("laughter" = 50)

// MARK: Water bottle
/obj/item/reagent_containers/cup/beaker/waterbottle
	name = "bottle of water"
	desc = "Бутылка воды, наполненная на старом земном заводе по разливу воды."
	gender = FEMALE
	icon = 'icons/obj/drinks.dmi'
	icon_state = "smallbottle"
	item_state = "bottle"
	list_reagents = list("water" = 49.5, "fluorine" = 0.5) //see desc, don't think about it too hard
	materials = list(MAT_GLASS = 0)

/obj/item/reagent_containers/cup/beaker/waterbottle/get_ru_names()
	return alist(
		NOMINATIVE = "бутылка воды",
		GENITIVE = "бутылки воды",
		DATIVE = "бутылке воды",
		ACCUSATIVE = "бутылку воды",
		INSTRUMENTAL = "бутылкой воды",
		PREPOSITIONAL = "бутылке воды",
	)

/obj/item/reagent_containers/cup/beaker/waterbottle/empty
	list_reagents = list()

/obj/item/reagent_containers/cup/beaker/waterbottle/large
	desc = "Свежая бутылка воды коммерческого размера."
	icon_state = "largebottle"
	materials = list(MAT_GLASS = 0)
	list_reagents = list("water" = 100)
	volume = 100
	amount_per_transfer_from_this = 20

/obj/item/reagent_containers/cup/beaker/waterbottle/large/get_ru_names()
	return alist(
		NOMINATIVE = "большая бутылка воды",
		GENITIVE = "большой бутылки воды",
		DATIVE = "большой бутылке воды",
		ACCUSATIVE = "большую бутылку воды",
		INSTRUMENTAL = "большой бутылкой воды",
		PREPOSITIONAL = "большой бутылке воды",
	)

/obj/item/reagent_containers/cup/beaker/waterbottle/large/empty
	list_reagents = list()

// MARK: Bucket
/obj/item/reagent_containers/cup/bucket
	name = "bucket"
	desc = "Металлическое ведро. Можете налить туда что-то или надеть себе на голову, никто не запрещает."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	materials = list(MAT_METAL = 200)
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50, 80, 100, 120)
	volume = 120
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 75, ACID = 50) //Weak melee protection, because you can wear it on your head
	slot_flags = ITEM_SLOT_HEAD
	resistance_flags = NONE
	var/paintable = TRUE

/obj/item/reagent_containers/cup/bucket/get_ru_names()
	return alist(
		NOMINATIVE = "металлическое ведро",
		GENITIVE = "металлического ведра",
		DATIVE = "металлическому ведру",
		ACCUSATIVE = "металлическое ведро",
		INSTRUMENTAL = "металлическим ведром",
		PREPOSITIONAL = "металлическом ведре",
	)

/obj/item/reagent_containers/cup/bucket/Initialize(mapload)
	. = ..()
	if(!color && paintable)
		color = "#0085E5"
	update_icon(UPDATE_OVERLAYS) //in case bucket's color has been changed in editor or by some deriving buckets

/obj/item/reagent_containers/cup/bucket/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon/spraycan))
		add_fingerprint(user)
		var/obj/item/toy/crayon/spraycan/can = I
		if(!paintable)
			balloon_alert(user, "нельзя покрасить!")
			return ATTACK_CHAIN_PROCEED_NO_AFTERATTACK
		if(can.capped)
			balloon_alert(user, "закрыто крышкой!")
			return ATTACK_CHAIN_PROCEED_NO_AFTERATTACK
		balloon_alert(user, "перекрашено!")
		playsound(user.loc, 'sound/effects/spray.ogg', 20, TRUE)
		color = can.colour
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	if(istype(I, /obj/item/mop))
		if(reagents.total_volume < 1)
			user.balloon_alert(user, "empty!")
			return ATTACK_CHAIN_PROCEED
		reagents.trans_to(I, 5)
		user.balloon_alert(user, "doused [I]")
		playsound(src, 'sound/effects/slosh.ogg', 25, TRUE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(isprox(I))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		add_fingerprint(user)
		balloon_alert(user, "прикреплено")
		to_chat(user, span_notice("Вы прикрепили [I.declent_ru(ACCUSATIVE)] к [declent_ru(DATIVE)]."))
		var/obj/item/bot_assembly/bucket_sensor/bucket_sensor = new(drop_location())
		transfer_fingerprints_to(bucket_sensor)
		I.transfer_fingerprints_to(bucket_sensor)
		bucket_sensor.add_fingerprint(user)
		if(loc == user)
			user.temporarily_remove_item_from_inventory(src, force = TRUE)
			user.put_in_hands(bucket_sensor)
		qdel(I)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/reagent_containers/cup/bucket/update_overlays()
	. = ..()
	if(color)
		var/mutable_appearance/bucket_mask = mutable_appearance(icon='icons/obj/janitor.dmi', icon_state = "bucket_mask")
		. += bucket_mask

		var/mutable_appearance/bucket_hand = mutable_appearance(icon='icons/obj/janitor.dmi', icon_state = "bucket_hand", appearance_flags = RESET_COLOR)
		. += bucket_hand

/obj/item/reagent_containers/cup/bucket/equipped(mob/user, slot, initial)
	. = ..()

	if(slot == ITEM_SLOT_HEAD && reagents.total_volume)
		to_chat(user, span_userdanger("Вы надеваете [declent_ru(ACCUSATIVE)] себе на голову и его содержимое выливается прямо на вас!"))
		reagents.reaction(user, REAGENT_TOUCH)
		reagents.clear_reagents()

/obj/item/reagent_containers/cup/bucket/wooden
	name = "wooden bucket"
	desc = "Деревянное ведро. Можете налить туда что-то или надеть себе на голову, никто не запрещает."
	icon_state = "woodbucket"
	item_state = "woodbucket"
	materials = null
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 50)
	resistance_flags = FLAMMABLE
	paintable = FALSE

/obj/item/reagent_containers/cup/bucket/wooden/get_ru_names()
	return alist(
		NOMINATIVE = "деревянное ведро",
		GENITIVE = "деревянного ведра",
		DATIVE = "деревянному ведру",
		ACCUSATIVE = "деревянное ведро",
		INSTRUMENTAL = "деревянным ведром",
		PREPOSITIONAL = "деревянном ведре",
	)

/obj/item/reagent_containers/cup/bucket/wooden/update_overlays()
	. = list()

/obj/item/reagent_containers/cup/bucket/wooden/shit
	name = "shit bucket"
	desc = "Омерзительно. Им кто-то недавно пользовался?!"

/obj/item/reagent_containers/cup/bucket/wooden/shit/get_ru_names()
	return alist(
		NOMINATIVE = "сральное ведро",
		GENITIVE = "срального ведра",
		DATIVE = "сральному ведру",
		ACCUSATIVE = "сральное ведро",
		INSTRUMENTAL = "сральным ведром",
		PREPOSITIONAL = "сральном ведре",
	)

// MARK: Pet bowl
/obj/item/reagent_containers/cup/pet_bowl
	name = "pet bowl"
	desc = "Миска под еду для любимых домашних животных!"
	gender = FEMALE
	icon = 'icons/obj/pet_bowl.dmi'
	icon_state = "petbowl"
	item_state = "petbowl"
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 15
	has_variable_transfer_amount = FALSE
	volume = 15
	resistance_flags = FLAMMABLE
	color = "#0085E5"

/obj/item/reagent_containers/cup/pet_bowl/get_ru_names()
	return alist(
		NOMINATIVE = "миска для животных",
		GENITIVE = "миски для животных",
		DATIVE = "миске для животных",
		ACCUSATIVE = "миску для животных",
		INSTRUMENTAL = "миской для животных",
		PREPOSITIONAL = "миске для животных",
	)

/obj/item/reagent_containers/cup/pet_bowl/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon/spraycan))
		add_fingerprint(user)
		var/obj/item/toy/crayon/spraycan/can = I
		if(can.capped)
			balloon_alert(user, "закрыто крышкой!")
			return ATTACK_CHAIN_PROCEED_NO_AFTERATTACK
		balloon_alert(user, "перекрашено")
		playsound(user.loc, 'sound/effects/spray.ogg', 20, TRUE)
		color = can.colour
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	return ..()

/obj/item/reagent_containers/cup/pet_bowl/update_overlays()
	. = ..()
	var/mutable_appearance/bowl_mask = mutable_appearance(icon = 'icons/obj/pet_bowl.dmi', icon_state = "colorable_overlay")
	. += bowl_mask
	var/mutable_appearance/bowl_nc_mask = mutable_appearance(icon = 'icons/obj/pet_bowl.dmi', icon_state = "nc_petbowl", appearance_flags = RESET_COLOR)
	. += bowl_nc_mask
	if(reagents.total_volume)
		var/datum/reagent/feed = reagents.has_reagent("afeed")
		if(feed && (feed.volume >= (reagents.total_volume - feed.volume)))
			var/image/feed_overlay = image(icon = 'icons/obj/pet_bowl.dmi', icon_state = "petfood_5", layer = FLOAT_LAYER)
			feed_overlay.appearance_flags = RESET_COLOR
			switch(feed.volume)
				if(6 to 10)
					feed_overlay.icon_state = "petfood_10"
				if(11 to 15)
					feed_overlay.icon_state = "petfood_15"
			. += feed_overlay
		else
			var/mutable_appearance/liquid_overlay = mutable_appearance(icon, "liquid_overlay", appearance_flags = RESET_COLOR)
			liquid_overlay.color = mix_color_from_reagents(reagents.reagent_list)
			. += liquid_overlay

/obj/item/reagent_containers/cup/pet_bowl/attack_animal(mob/living/simple_animal/pet)
	if(!pet.client || !pet.safe_respawn(pet, check_station_level = FALSE) || !reagents.total_volume)
		return ..()
	if(reagents.has_reagent("afeed", 1))
		pet.heal_organ_damage(5, 5)
		reagents.remove_reagent("afeed", 1)
		playsound(pet.loc, 'sound/items/eatfood.ogg', rand(10, 30), TRUE)
	else
		reagents.remove_any(1)
		playsound(pet.loc, 'sound/items/drink.ogg', rand(10, 30), TRUE)

// MARK: Coffeepot
//Coffeepot: for reference, a standard cup is 30u, to allow 20u for sugar/sweetener/milk/creamer
/obj/item/reagent_containers/cup/coffeepot
	name = "coffeepot"
	desc = "Термостойкий контейнер, предназначенный для приготовления и разлива кофе. \
			Такие поставляются в комплекте с кофемашинами. Достаточно хрупкий."
	gender = MALE
	w_class = WEIGHT_CLASS_NORMAL
	volume = 120
	icon = 'icons/obj/drinks.dmi'
	icon_state = "coffeepot"
	materials = list(MAT_METAL = 1000, MAT_GLASS = 3500)
	is_glass = TRUE
	fill_icon_thresholds = list(30, 60, 100)

/obj/item/reagent_containers/cup/coffeepot/get_ru_names()
	return alist(
		NOMINATIVE = "кофейник",
		GENITIVE = "кофейника",
		DATIVE = "кофейнику",
		ACCUSATIVE = "кофейник",
		INSTRUMENTAL = "кофейником",
		PREPOSITIONAL = "кофейнике"
	)
