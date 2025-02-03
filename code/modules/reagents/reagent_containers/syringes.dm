#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1
#define SYRINGE_BROKEN 2

/obj/item/reagent_containers/syringe
	name = "syringe"
	desc = "Это шприц. Он предназачен для введения и извлечения веществ из кровотока субъекта, а также для многих других целей."
	ru_names = list(
        NOMINATIVE = "шприц",
        GENITIVE = "шприца",
        DATIVE = "шприцу",
        ACCUSATIVE = "шприц",
        INSTRUMENTAL = "шприцем",
        PREPOSITIONAL = "шприце"
	)
	icon = 'icons/goonstation/objects/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	belt_icon = "syringe"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null
	volume = 15
	sharp = TRUE
	pass_open_check = TRUE
	var/busy = FALSE
	var/mode = SYRINGE_DRAW
	var/projectile_type = /obj/item/projectile/bullet/dart/syringe
	materials = list(MAT_METAL=10, MAT_GLASS=20)
	container_type = TRANSPARENT

/obj/item/reagent_containers/syringe/Initialize(mapload)
	if(list_reagents) //syringe starts in inject mode if its already got something inside
		mode = SYRINGE_INJECT
	. = ..()

/obj/item/reagent_containers/syringe/set_APTFT()
	set hidden = TRUE

/obj/item/reagent_containers/syringe/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/syringe/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	update_icon()

/obj/item/reagent_containers/syringe/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	update_icon()

/obj/item/reagent_containers/syringe/attack_self(mob/user)
	mode = !mode
	update_icon()

/obj/item/reagent_containers/syringe/attack_hand()
	..()
	update_icon()


/obj/item/reagent_containers/syringe/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED


/obj/item/reagent_containers/syringe/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(!target.reagents)
		return

	var/mob/living/L
	if(isliving(target))
		L = target
		if(!L.can_inject(user, TRUE))
			return

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.holder_full())
				balloon_alert(user, "шприц полон!")
				return

			if(L) //living mob
				var/drawn_amount = reagents.maximum_volume - reagents.total_volume
				if(target != user)
					target.visible_message(span_danger("[user] пыта[pluralize_ru(user.gender, "ет", "ют")]ся взять образец крови у [target]!"), \
											span_userdanger("[user] пыта[pluralize_ru(user.gender, "ет", "ют")]ся взять у вас образец крови!"))
					busy = TRUE
					if(!do_after(user, 3 SECONDS, target, NONE))
						busy = FALSE
						return
					if(reagents.holder_full())
						return
				busy = FALSE
				if(L.transfer_blood_to(src, drawn_amount))
					L.visible_message(span_danger("[user] взял[genderize_ru(user.gender, "", "а", "о", "и")] образец крови у [L]!"), \
										span_userdanger("[user] взял[genderize_ru(user.gender, "", "а", "о", "и")] у вас образец крови!"))
				else
					balloon_alert(user, "больше крови не взять!")

			else //if not mob
				if(!target.reagents.total_volume)
					balloon_alert(user, "пусто!")
					return

				if(!target.is_drawable(user))
					balloon_alert(user, "отсюда вещество не забрать!")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, span_notice("Вы заполняете [declent_ru(ACCUSATIVE)] <b>[trans]</b> единиц[declension_ru(trans, "ей", "ами", "ами")] вещества. Теперь он содержит <b>[reagents.total_volume]</b> единиц[declension_ru(reagents.total_volume, "у", "ы", "")] вещества."))
			if(reagents.holder_full())
				mode = !mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				balloon_alert(user, "шприц пуст!")
				return

			if(!L && !target.is_injectable(user)) //only checks on non-living mobs, due to how can_inject() handles
				balloon_alert(user, "сюда вещество не ввести!")
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				balloon_alert(user, "нет места!")
				return

			if(L) //living mob
				if(!L.can_inject(user, TRUE))
					return
				if(L != user)
					L.visible_message(span_danger("[user] пыта[pluralize_ru(user.gender, "ет", "ют")]ся сделать [L] укол [declent_ru(INSTRUMENTAL)]!"), \
										span_userdanger("[user] пыта[pluralize_ru(user.gender, "ет", "ют")]ся сделать вам укол [declent_ru(INSTRUMENTAL)]!"))
					if(!do_after(user, 3 SECONDS, L, NONE))
						return
					if(!reagents.total_volume)
						return
					if(L.reagents.total_volume >= L.reagents.maximum_volume)
						return
					L.visible_message(span_danger("[user] дела[pluralize_ru(user.gender, "ет", "ют")] [L] укол [declent_ru(INSTRUMENTAL)]!"), \
										span_userdanger("[user] дела[pluralize_ru(user.gender, "ет", "ют")] вам укол [declent_ru(INSTRUMENTAL)]!"))

			add_attack_logs(user, target, "Injected with [name] containing [reagents.log_list()], transfered [amount_per_transfer_from_this] units", reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)

			var/fraction = min(amount_per_transfer_from_this / reagents.total_volume, 1)
			reagents.reaction(L, REAGENT_INGEST, fraction)
			reagents.trans_to(target, amount_per_transfer_from_this)
			to_chat(user, span_notice("Вы вкололи <b>[amount_per_transfer_from_this]</b> единиц[declension_ru(amount_per_transfer_from_this, "у", "ы", "")] вещества с помощью [declent_ru(GENITIVE)]. В нём остаётся <b>[reagents.total_volume]</b> единиц[declension_ru(reagents.total_volume, "а", "ы", "")] вещества."))
			if(istype(target, /obj/item/reagent_containers/food))
				var/obj/item/reagent_containers/food/F = target
				F.log_eating = TRUE

			if(reagents.total_volume <= 0 && mode == SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()


/obj/item/reagent_containers/syringe/update_icon_state()
	var/rounded_vol
	if(reagents?.total_volume)
		rounded_vol = clamp(round((reagents.total_volume / volume * 15), 5), 1, 15)
	else
		rounded_vol = 0
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"


/obj/item/reagent_containers/syringe/update_overlays()
	. = ..()
	var/rounded_vol
	if(reagents && reagents.total_volume)
		rounded_vol = clamp(round((reagents.total_volume / volume * 15), 5), 1, 15)
		var/image/filling_overlay = mutable_appearance('icons/obj/reagentfillings.dmi', "syringe[rounded_vol]")
		filling_overlay.icon += mix_color_from_reagents(reagents.reagent_list)
		. += filling_overlay
	if(ismob(loc) || istype(loc, /obj/item/gripper))
		var/injoverlay
		switch(mode)
			if(SYRINGE_DRAW)
				injoverlay = "draw"
			if(SYRINGE_INJECT)
				injoverlay = "inject"
		. += injoverlay
		update_equipped_item(update_speedmods = FALSE)


/obj/item/reagent_containers/syringe/antiviral
	name = "Syringe (spaceacillin)"
	desc = "Щприц с антибиотическим средством."
	ru_names = list(
        NOMINATIVE = "шприц (Космоциллин)",
        GENITIVE = "шприца (Космоциллин)",
        DATIVE = "шприцу (Космоциллин)",
        ACCUSATIVE = "шприц (Космоциллин)",
        INSTRUMENTAL = "шприцем (Космоциллин)",
        PREPOSITIONAL = "шприце (Космоциллин)"
	)
	list_reagents = list("spaceacillin" = 15)

/obj/item/reagent_containers/syringe/charcoal
	name = "Syringe (charcoal)"
	desc = "Шприц со средством против отравлений."
	ru_names = list(
        NOMINATIVE = "шприц (Активированный уголь)",
        GENITIVE = "шприца (Активированный уголь)",
        DATIVE = "шприцу (Активированный уголь)",
        ACCUSATIVE = "шприц (Активированный уголь)",
        INSTRUMENTAL = "шприцем (Активированный уголь)",
        PREPOSITIONAL = "шприце (Активированный уголь)"
	)
	list_reagents = list("charcoal" = 15)

/obj/item/reagent_containers/syringe/epinephrine
	name = "Syringe (Epinephrine)"
	desc = "Шприц со средством для стабилизации критических пациентов."
	ru_names = list(
        NOMINATIVE = "шприц (Эпинефрин)",
        GENITIVE = "шприца (Эпинефрин)",
        DATIVE = "шприцу (Эпинефрин)",
        ACCUSATIVE = "шприц (Эпинефрин)",
        INSTRUMENTAL = "шприцем (Эпинефрин)",
        PREPOSITIONAL = "шприце (Эпинефрин)"
	)
	list_reagents = list("epinephrine" = 15)

/obj/item/reagent_containers/syringe/insulin
	name = "Syringe (insulin)"
	desc = "Шприц со средством для борьбы с диабетической комой."
	ru_names = list(
        NOMINATIVE = "шприц (Инсулин)",
        GENITIVE = "шприца (Инсулин)",
        DATIVE = "шприцу (Инсулин)",
        ACCUSATIVE = "шприц (Инсулин)",
        INSTRUMENTAL = "шприцем (Инсулин)",
        PREPOSITIONAL = "шприце (Инсулин)"
	)
	list_reagents = list("insulin" = 15)

/obj/item/reagent_containers/syringe/calomel
	name = "Syringe (calomel)"
	desc = "Шприц со средством для выведения веществ из кровотока."
	ru_names = list(
        NOMINATIVE = "шприц (Каломель)",
        GENITIVE = "шприца (Каломель)",
        DATIVE = "шприцу (Каломель)",
        ACCUSATIVE = "шприц (Каломель)",
        INSTRUMENTAL = "шприцем (Каломель)",
        PREPOSITIONAL = "шприце (Каломель)"
	)
	list_reagents = list("calomel" = 15)

/obj/item/reagent_containers/syringe/heparin
	name = "Syringe (heparin)"
	desc = "Шприц с антикоагулянтом."
	ru_names = list(
        NOMINATIVE = "шприц (Гепарин)",
        GENITIVE = "шприца (Гепарин)",
        DATIVE = "шприцу (Гепарин)",
        ACCUSATIVE = "шприц (Гепарин)",
        INSTRUMENTAL = "шприцем (Гепарин)",
        PREPOSITIONAL = "шприце (Гепарин)"
	)
	list_reagents = list("heparin" = 15)

/obj/item/reagent_containers/syringe/bioterror
	name = "bioterror syringe"
	desc = "Щприц с несколькими нервно-паралитическими ядами."
	ru_names = list(
        NOMINATIVE = "шприц (Нейротоксины)",
        GENITIVE = "шприца (Нейротоксины)",
        DATIVE = "шприцу (Нейротоксины)",
        ACCUSATIVE = "шприц (Нейротоксины)",
        INSTRUMENTAL = "шприцем (Нейротоксины)",
        PREPOSITIONAL = "шприце (Нейротоксины)"
	)
	list_reagents = list("neurotoxin" = 5, "capulettium_plus" = 5, "sodium_thiopental" = 5)

/obj/item/reagent_containers/syringe/gluttony
	name = "Gluttony's Blessing"
	desc = "Странный шприц, измазанный в зелёной жиже."
	ru_names = list(
        NOMINATIVE = "шприц (Благословение Чревоугодия)",
        GENITIVE = "шприца (Благословение Чревоугодия)",
        DATIVE = "шприцу (Благословение Чревоугодия)",
        ACCUSATIVE = "шприц (Благословение Чревоугодия)",
        INSTRUMENTAL = "шприцем (Благословение Чревоугодия)",
        PREPOSITIONAL = "шприце (Благословение Чревоугодия)"
	)
	amount_per_transfer_from_this = 1
	volume = 1
	list_reagents = list("gluttonytoxin" = 1)

/obj/item/reagent_containers/syringe/capulettium_plus
	name = "capulettium plus syringe"
	desc = "Шприц со средством для имитации смерти."
	ru_names = list(
        NOMINATIVE = "шприц (Капулеттий+)",
        GENITIVE = "шприца (Капулеттий+)",
        DATIVE = "шприцу (Капулеттий+)",
        ACCUSATIVE = "шприц (Капулеттий+)",
        INSTRUMENTAL = "шприцем (Капулеттий+)",
        PREPOSITIONAL = "шприце (Капулеттий+)"
	)
	list_reagents = list("capulettium_plus" = 15)

/obj/item/reagent_containers/syringe/sarin
	name = "sarin syringe"
	desc = "Щприц со смертельно опасным нервно-паралитическим ядом."
	ru_names = list(
        NOMINATIVE = "шприц (Зарин)",
        GENITIVE = "шприца (Зарин)",
        DATIVE = "шприцу (Зарин)",
        ACCUSATIVE = "шприц (Зарин)",
        INSTRUMENTAL = "шприцем (Зарин)",
        PREPOSITIONAL = "шприце (Зарин)"
	)
	list_reagents = list("sarin" = 15)

/obj/item/reagent_containers/syringe/pancuronium
	name = "pancuronium syringe"
	desc = "Шприц с парализующим веществом."
	ru_names = list(
        NOMINATIVE = "шприц (Панкуроний+)",
        GENITIVE = "шприца (Панкуроний+)",
        DATIVE = "шприцу (Панкуроний+)",
        ACCUSATIVE = "шприц (Панкуроний+)",
        INSTRUMENTAL = "шприцем (Панкуроний+)",
        PREPOSITIONAL = "шприце (Панкуроний+)"
	)
	list_reagents = list("pancuronium" = 15)

/obj/item/reagent_containers/syringe/lethal
	name = "lethal injection syringe"
	desc = "Шприц, используемый для смертельных инъекций. Вмещает в себя вплоть до <b>50</b> единиц вещества."
	ru_names = list(
        NOMINATIVE = "шприц (Смертельная инъекция)",
        GENITIVE = "шприца (Смертельная инъекция)",
        DATIVE = "шприцу (Смертельная инъекция)",
        ACCUSATIVE = "шприц (Смертельная инъекция)",
        INSTRUMENTAL = "шприцем (Смертельная инъекция)",
        PREPOSITIONAL = "шприце (Смертельная инъекция)"
	)
	amount_per_transfer_from_this = 50
	volume = 50
	list_reagents = list("toxin" = 15, "pancuronium" = 10, "cyanide" = 5, "facid" = 10, "fluorine" = 10)
