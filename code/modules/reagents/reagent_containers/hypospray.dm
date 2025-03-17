////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/hypospray
	name = "hypospray"
	desc = "Гипоспрей - это стерильный автоинъектор с воздушной иглой для быстрого введения лекарств пациентам."
	ru_names = list(
        NOMINATIVE = "гипоспрей",
        GENITIVE = "гипоспрея",
        DATIVE = "гипоспрею",
        ACCUSATIVE = "гипоспрей",
        INSTRUMENTAL = "гипоспреем",
        PREPOSITIONAL = "гипоспрее"
	)
	icon = 'icons/obj/hypo.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	belt_icon = "hypospray"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = list(1,2,3,4,5,10,15,20,25,30)
	resistance_flags = ACID_PROOF
	container_type = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	var/ignore_flags = FALSE
	var/emagged = FALSE
	var/safety_hypo = FALSE

/obj/item/reagent_containers/hypospray/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!iscarbon(target) || !target.reagents)
		return .

	if(!reagents || !reagents.total_volume)
		balloon_alert(user, "пусто!")
		return .

	if(!ignore_flags && !target.can_inject(user, TRUE))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	to_chat(target, span_warning("Вы чувствуете едва заметный укол!"))
	to_chat(user, span_notice("Вы делаете [target] укол [declent_ru(INSTRUMENTAL)]."))

	var/list/injected = list()
	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		injected += reagent.name

	var/primary_reagent_name = reagents.get_master_reagent_name()
	var/fraction = min(amount_per_transfer_from_this / reagents.total_volume, 1)
	reagents.reaction(target, REAGENT_INGEST, fraction)
	var/trans = reagents.trans_to(target, amount_per_transfer_from_this)

	if(safety_hypo)
		visible_message(span_warning("[user] вкалыва[pluralize_ru(user.gender, "ет", "ют")] [target] <b>[trans]</b> единиц[declension_ru(trans, "у", "ы", "")] вещества \"[primary_reagent_name]\"."))
		playsound(loc, 'sound/goonstation/items/hypo.ogg', 80)

	to_chat(user, span_notice("Вы вкалываете <b>[trans]</b> единиц[declension_ru(trans, "у", "ы", "")]. В [declent_ru(PREPOSITIONAL)] осталось ещё <b>[reagents.total_volume]</b> единиц[declension_ru(reagents.total_volume, "а", "ы", "")]."))
	add_attack_logs(user, target, "Injected with [src] containing ([english_list(injected)])", reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)


/obj/item/reagent_containers/hypospray/on_reagent_change()
	if(safety_hypo && !emagged)
		var/found_forbidden_reagent = FALSE
		for(var/datum/reagent/R in reagents.reagent_list)
			if(!GLOB.safe_chem_list.Find(R.id))
				reagents.del_reagent(R.id)
				found_forbidden_reagent = TRUE
		if(found_forbidden_reagent)
			if(ismob(loc))
				to_chat(loc, span_warning("[capitalize(declent_ru(NOMINATIVE))] определяет и удаляет недопустимое вещество."))
			else
				visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] определяет и удаляет недопустимое вещество."))


/obj/item/reagent_containers/hypospray/emag_act(mob/user)
	if(safety_hypo && !emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		ignore_flags = TRUE
		if(user)
			balloon_alert(user, "протоколы безопасности взломаны")

/obj/item/reagent_containers/hypospray/safety
	name = "medical hypospray"
	desc = "Медицинский гипоспрей общего назначения для быстрого введения химических веществ. На курке имеется кнопка безопасности."
	ru_names = list(
        NOMINATIVE = "медицинский гипоспрей",
        GENITIVE = "медицинского гипоспрея",
        DATIVE = "медицинскому гипоспрею",
        ACCUSATIVE = "медицинский гипоспрей",
        INSTRUMENTAL = "медицинским гипоспреем",
        PREPOSITIONAL = "медицинском гипоспрее"
	)
	icon_state = "medivend_hypo"
	belt_icon = "medical_hypospray"
	safety_hypo = TRUE
	var/paint_color
	var/color_overlay = "colour_hypo"


/obj/item/reagent_containers/hypospray/safety/proc/update_state()
	update_icon(UPDATE_ICON_STATE)
	remove_filter("hypospray_handle")
	if(paint_color)
		var/icon/hypo_mask = icon('icons/obj/hypo.dmi', color_overlay)
		add_filter("hypospray_handle", 1, layering_filter(icon = hypo_mask, color = paint_color))


/obj/item/reagent_containers/hypospray/safety/update_icon_state()
	icon_state = paint_color ? "whitehypo" : "medivend_hypo"

/obj/item/reagent_containers/hypospray/safety/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon/spraycan))
		add_fingerprint(user)
		var/obj/item/toy/crayon/spraycan/can = I
		if(can.capped)
			balloon_alert(user, "баллончик закрыт!")
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(can.uses < 2)
			balloon_alert(user, "недостаточно краски!")
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		balloon_alert(user, "покрашено")
		playsound(user.loc, 'sound/effects/spray.ogg', 20, TRUE)
		paint_color = can.colour
		can.uses -= 2
		update_state()
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	if(istype(I, /obj/item/soap) && paint_color)
		add_fingerprint(user)
		balloon_alert(user, "краска смыта")
		paint_color = null
		update_state()
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	return ..()

/obj/item/reagent_containers/hypospray/safety/upgraded
	name = "upgraded medical hypospray"
	desc = "Улучшенный медицинский гипоспрей общего назначения для быстрого введения химических веществ. Эта модель имеет увеличенную емкость."
	ru_names = list(
        NOMINATIVE = "улучшенный медицинский гипоспрей",
        GENITIVE = "улучшенного медицинского гипоспрея",
        DATIVE = "улучшенному медицинскому гипоспрею",
        ACCUSATIVE = "улучшенный медицинский гипоспрей",
        INSTRUMENTAL = "улучшенным медицинским гипоспреем",
        PREPOSITIONAL = "улучшенном медицинском гипоспрее"
	)
	item_state = "upg_hypo"
	icon_state = "upg_hypo"
	volume = 60
	possible_transfer_amounts = list(1,2,5,10,15,20,25,30,40,60)
	color_overlay = "colour_upgradedhypo"

/obj/item/reagent_containers/hypospray/safety/upgraded/update_icon_state()
	icon_state = paint_color ? "upg_hypo_white" : "upg_hypo"

/obj/item/reagent_containers/hypospray/safety/upgraded/emag_act(mob/user)
	return

/obj/item/reagent_containers/hypospray/safety/ert
	name = "medical hypospray (Omnizine)"
	ru_names = list(
        NOMINATIVE = "медицинский гипоспрей (Омнизин)",
        GENITIVE = "медицинского гипоспрея (Омнизин)",
        DATIVE = "медицинскому гипоспрею (Омнизин)",
        ACCUSATIVE = "медицинский гипоспрей (Омнизин)",
        INSTRUMENTAL = "медицинским гипоспреем (Омнизин)",
        PREPOSITIONAL = "медицинском гипоспрее (Омнизин)"
	)
	list_reagents = list("omnizine" = 30)

/obj/item/reagent_containers/hypospray/CMO
	volume = 250
	possible_transfer_amounts = list(1,2,3,4,5,10,15,20,25,30,35,40,45,50)
	list_reagents = list("omnizine" = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/reagent_containers/hypospray/CMO/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/reagent_containers/hypospray/CMO/empty
	list_reagents = null

/obj/item/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "Модифицированный автоинъектор с воздушной иглой, используемый оперативниками поддержки для быстрого заживления ран в бою."
	ru_names = list(
        NOMINATIVE = "боевой инъектор",
        GENITIVE = "боевого инъектора",
        DATIVE = "боевому инъектору",
        ACCUSATIVE = "боевой инъектор",
        INSTRUMENTAL = "боевым инъектором",
        PREPOSITIONAL = "боевом инъекторе"
	)
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = null
	icon_state = "combat_hypo"
	volume = 90
	ignore_flags = 1 // So they can heal their comrades.
	list_reagents = list("epinephrine" = 30, "weak_omnizine" = 30, "salglu_solution" = 30)

/obj/item/reagent_containers/hypospray/ertm
	volume = 90
	ignore_flags = 1
	icon_state = "combat_hypo"
	possible_transfer_amounts = list(1,2,3,4,5,10,15,20,25,30)

/obj/item/reagent_containers/hypospray/ertm/hydrocodone
	amount_per_transfer_from_this = 10
	name = "Hydrocodon combat stimulant injector"
	desc = "Модифицированный автоинъектор с воздушной иглой, используемый оперативниками поддержки для быстрого заживления ран в бою. Содержит гидрокодон."
	ru_names = list(
        NOMINATIVE = "боевой инъектор (Гидрокодон)",
        GENITIVE = "боевого инъектора (Гидрокодон)",
        DATIVE = "боевому инъектору (Гидрокодон)",
        ACCUSATIVE = "боевой инъектор (Гидрокодон)",
        INSTRUMENTAL = "боевым инъектором (Гидрокодон)",
        PREPOSITIONAL = "боевом инъекторе (Гидрокодон)"
	)
	icon_state = "hypocombat-hydro"
	list_reagents = list("hydrocodone" = 90)

/obj/item/reagent_containers/hypospray/ertm/perfluorodecalin
	amount_per_transfer_from_this = 3
	name = "Perfluorodecalin combat stimulant injector"
	icon_state = "hypocombat-perfa"
	desc = "Модифицированный автоинъектор с воздушной иглой, используемый оперативниками поддержки для быстрого заживления ран в бою. Содержит Перфтордекалин."
	ru_names = list(
        NOMINATIVE = "боевой инъектор (Перфтодекалин)",
        GENITIVE = "боевого инъектора (Перфтодекалин)",
        DATIVE = "боевому инъектору (Перфтодекалин)",
        ACCUSATIVE = "боевой инъектор (Перфтодекалин)",
        INSTRUMENTAL = "боевым инъектором (Перфтодекалин)",
        PREPOSITIONAL = "боевом инъекторе (Перфтодекалин)"
	)
	list_reagents = list("perfluorodecalin" = 90)

/obj/item/reagent_containers/hypospray/ertm/pentic_acid
	amount_per_transfer_from_this = 5
	name = "Pentic acid combat stimulant injector"
	icon_state = "hypocombat-dtpa"
	desc = "Модифицированный автоинъектор с воздушной иглой, используемый оперативниками поддержки для быстрого заживления ран в бою. Содержит пентетовую кислоту."
	ru_names = list(
        NOMINATIVE = "боевой инъектор (Пентетовая кислота)",
        GENITIVE = "боевого инъектора (Пентетовая кислота)",
        DATIVE = "боевому инъектору (Пентетовая кислота)",
        ACCUSATIVE = "боевой инъектор (Пентетовая кислота)",
        INSTRUMENTAL = "боевым инъектором (Пентетовая кислота)",
        PREPOSITIONAL = "боевом инъекторе (Пентетовая кислота)"
	)
	list_reagents = list("pen_acid" = 90)

/obj/item/reagent_containers/hypospray/ertm/epinephrine
	amount_per_transfer_from_this = 5
	name = "Epinephrine combat stimulant injector"
	icon_state = "hypocombat-epi"
	desc = "Модифицированный автоинъектор с воздушной иглой, используемый оперативниками поддержки для быстрого заживления ран в бою. Содержит эпинефрин."
	ru_names = list(
        NOMINATIVE = "боевой инъектор (Эпинефрин)",
        GENITIVE = "боевого инъектора (Эпинефрин)",
        DATIVE = "боевому инъектору (Эпинефрин)",
        ACCUSATIVE = "боевой инъектор (Эпинефрин)",
        INSTRUMENTAL = "боевым инъектором (Эпинефрин)",
        PREPOSITIONAL = "боевом инъекторе (Эпинефрин)"
	)
	list_reagents = list("epinephrine" = 90)

/obj/item/reagent_containers/hypospray/ertm/mannitol
	amount_per_transfer_from_this = 5
	name = "Mannitol combat stimulant injector"
	desc = "Модифицированный автоинъектор с воздушной иглой, используемый оперативниками поддержки для быстрого заживления ран в бою. Содержит маннитол."
	ru_names = list(
        NOMINATIVE = "боевой инъектор (Маннитол)",
        GENITIVE = "боевого инъектора (Маннитол)",
        DATIVE = "боевому инъектору (Маннитол)",
        ACCUSATIVE = "боевой инъектор (Маннитол)",
        INSTRUMENTAL = "боевым инъектором (Маннитол)",
        PREPOSITIONAL = "боевом инъекторе (Маннитол)"
	)
	icon_state = "hypocombat-mani"
	list_reagents = list("mannitol" = 90)

/obj/item/reagent_containers/hypospray/ertm/oculine
	amount_per_transfer_from_this = 5
	name = "Oculine combat stimulant injector"
	icon_state = "hypocombat-ocu"
	desc = "Модифицированный автоинъектор с воздушной иглой, используемый оперативниками поддержки для быстрого заживления ран в бою. Содержит окулин."
	ru_names = list(
        NOMINATIVE = "боевой инъектор (Окулин)",
        GENITIVE = "боевого инъектора (Окулин)",
        DATIVE = "боевому инъектору (Окулин)",
        ACCUSATIVE = "боевой инъектор (Окулин)",
        INSTRUMENTAL = "боевым инъектором (Окулин)",
        PREPOSITIONAL = "боевом инъекторе (Окулин)"
	)
	list_reagents = list("oculine" = 90)

/obj/item/reagent_containers/hypospray/ertm/omnisal
	amount_per_transfer_from_this = 10
	name = "DilOmni-Salglu solution combat stimulant injector"
	icon_state = "hypocombat-womnisal"
	desc = "Модифицированный автоинъектор с воздушной иглой, используемый оперативниками поддержки для быстрого заживления ран в бою. Содержит разбавленный омнизин и физиологический раствор."
	ru_names = list(
        NOMINATIVE = "боевой инъектор (Разб. омнизин + Физраствор)",
        GENITIVE = "боевого инъектора (Разб. омнизин + Физраствор)",
        DATIVE = "боевому инъектору (Разб. омнизин + Физраствор)",
        ACCUSATIVE = "боевой инъектор (Разб. омнизин + Физраствор)",
        INSTRUMENTAL = "боевым инъектором (Разб. омнизин + Физраствор)",
        PREPOSITIONAL = "боевом инъекторе (Разб. омнизин + Физраствор)"
	)
	list_reagents = list("weak_omnizine" = 45, "salglu_solution" = 45)
	possible_transfer_amounts = list(10, 20, 30)

/obj/item/reagent_containers/hypospray/combat/nanites
	desc = "Модифицированный автоинъектор с воздушной иглой, используемый оперативниками поддержки для быстрого заживления ран в бою. Заполнен дорогостоящими медицинскими нанитами для быстрого заживления."
	ru_names = list(
        NOMINATIVE = "боевой инъектор (Боевые наниты)",
        GENITIVE = "боевого инъектора (Боевые наниты)",
        DATIVE = "боевому инъектору (Боевые наниты)",
        ACCUSATIVE = "боевой инъектор (Боевые наниты)",
        INSTRUMENTAL = "боевым инъектором (Боевые наниты)",
        PREPOSITIONAL = "боевом инъекторе (Боевые наниты)"
	)
	volume = 100
	list_reagents = list("nanites" = 100)

/obj/item/reagent_containers/hypospray/autoinjector
	name = "emergency autoinjector"
	desc = "Маленький инъектор в форме ручки, содержащий внутри дозу эпинефрина. Быстрый и безопасный способ стабилизации пациентов в критическом состоянии для персонала, не обладающего глубокими медицинскими знаниями."
	ru_names = list(
        NOMINATIVE = "аварийный автоинъектор",
        GENITIVE = "аварийного автоинъектора",
        DATIVE = "аварийному автоинъектору",
        ACCUSATIVE = "аварийный автоинъектор",
        INSTRUMENTAL = "аварийным автоинъектором",
        PREPOSITIONAL = "аварийном автоинъекторе"
	)
	icon_state = "autoinjector"
	item_state = "autoinjector"
	belt_icon = "autoinjector"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = null
	volume = 10
	ignore_flags = TRUE //so you can medipen through hardsuits
	container_type = DRAWABLE
	flags = null
	list_reagents = list("epinephrine" = 10)
	/// Whether we can rename and repaint source
	var/reskin_allowed = FALSE
	/// Currently selected skin
	var/current_skin
	/// Is it usable only on yourself?
	var/only_self = FALSE
	/// Is it used?
	var/spent = FALSE


/obj/item/reagent_containers/hypospray/autoinjector/update_icon_state()
	var/base_state
	switch(current_skin)
		if("Completely Blue")
			base_state = "ablueinjector"
		if("Blue")
			base_state = "blueinjector"
		if("Completely Red")
			base_state = "redinjector"
		if("Red")
			base_state = "lepopen"
		if("Golden")
			base_state = "goldinjector"
		if("Completely Green")
			base_state = "greeninjector"
		if("Green")
			base_state = "autoinjector"
		if("Gray")
			base_state = "stimpen"
		else
			base_state = initial(icon_state)

	icon_state = "[base_state][spent ? "0" : ""]"


/obj/item/reagent_containers/hypospray/autoinjector/attackby(obj/item/I, mob/user, params)
	if(!reskin_allowed)
		return ..()

	if(is_pen(I) || istype(I, /obj/item/flashlight/pen))
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/toy/crayon/spraycan))
		add_fingerprint(user)
		var/obj/item/toy/crayon/spraycan/can = I
		if(can.capped)
			balloon_alert(user, )
			balloon_alert(user, "баллончик закрыт!")
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(can.uses <= 0)
			balloon_alert(user, "недостаточно краски!")
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		var/static/list/injector_icons = list(
			"Completely Blue" = image('icons/obj/hypo.dmi', "ablueinjector"),
			"Blue" = image('icons/obj/hypo.dmi', "blueinjector"),
			"Completely Red" = image('icons/obj/hypo.dmi', "redinjector"),
			"Red" = image('icons/obj/hypo.dmi', "lepopen"),
			"Golden" = image('icons/obj/hypo.dmi', "goldinjector"),
			"Completely Green" = image('icons/obj/hypo.dmi', "greeninjector"),
			"Green" = image('icons/obj/hypo.dmi', "autoinjector"),
			"Gray" = image('icons/obj/hypo.dmi', "stimpen")
		)
		var/choice = show_radial_menu(user, user, injector_icons, radius = 48, custom_check = CALLBACK(src, PROC_REF(check_reskin), user))
		if(!choice || loc != user || can.loc != user || !can.uses || user.incapacitated())
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		balloon_alert(user, "покрашено")
		playsound(user.loc, 'sound/effects/spray.ogg', 20, TRUE)
		current_skin = choice
		can.uses--
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	return ..()


/obj/item/reagent_containers/hypospray/autoinjector/proc/check_reskin(mob/living/user)
	if(user.incapacitated())
		return FALSE
	if(loc != user)
		return FALSE
	return TRUE


/obj/item/reagent_containers/hypospray/autoinjector/empty()
	set hidden = TRUE


/obj/item/reagent_containers/hypospray/autoinjector/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!reagents.total_volume || spent)
		balloon_alert(user, "инъектор пуст!")
		return ATTACK_CHAIN_PROCEED
	if(only_self && target != user)
		balloon_alert(user, "только для самоиспользования!")
		return ATTACK_CHAIN_PROCEED
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		spent = TRUE
		update_icon(UPDATE_ICON_STATE)
		playsound(loc, 'sound/effects/stimpak.ogg', 35, TRUE)


/obj/item/reagent_containers/hypospray/autoinjector/examine()
	. = ..()
	if(reagents && reagents.reagent_list.len)
		. += span_notice("Не использовано.")
	else
		. += span_notice("Использовано.")


/obj/item/reagent_containers/hypospray/autoinjector/teporone //basilisks
	name = "teporone autoinjector"
	desc = "Маленький инъектор в форме ручки, содержащий внутри дозу тепорона. Быстрый способ восстановления температуры тела до естественных показателей."
	ru_names = list(
        NOMINATIVE = "автоинъектор (Тепорон)",
        GENITIVE = "автоинъектора (Тепорон)",
        DATIVE = "автоинъектору (Тепорон)",
        ACCUSATIVE = "автоинъектор (Тепорон)",
        INSTRUMENTAL = "автоинъектором (Тепорон)",
        PREPOSITIONAL = "автоинъекторе (Тепорон)"
	)
	icon_state = "lepopen"
	list_reagents = list("teporone" = 10)

/obj/item/reagent_containers/hypospray/autoinjector/stimpack //goliath kiting
	name = "stimpack autoinjector"
	desc = "Маленький инъектор в форме ручки, содержащий внутри дозу стимуляторов. Для тех случаев, когда вам срочно нужна доза адреналина."
	ru_names = list(
        NOMINATIVE = "автоинъектор (Стим-пак)",
        GENITIVE = "автоинъектора (Стим-пак)",
        DATIVE = "автоинъектору (Стим-пак)",
        ACCUSATIVE = "автоинъектор (Стим-пак)",
        INSTRUMENTAL = "автоинъектором (Стим-пак)",
        PREPOSITIONAL = "автоинъекторе (Стим-пак)"
	)
	icon_state = "stimpen"
	volume = 20
	amount_per_transfer_from_this = 20
	list_reagents = list("methamphetamine" = 10, "coffee" = 10)

/obj/item/reagent_containers/hypospray/autoinjector/stimulants
	name = "Stimulants autoinjector"
	desc = "Маленький инъектор в форме ручки, содержащий внутри дозу стимуляторов, кратковременно увеличивающих физическую силу, заживляющих повреждения, ускоряющих работу нервной системы и так далее. "
	ru_names = list(
        NOMINATIVE = "автоинъектор (Стимуляторы)",
        GENITIVE = "автоинъектора (Стимуляторы)",
        DATIVE = "автоинъектору (Стимуляторы)",
        ACCUSATIVE = "автоинъектор (Стимуляторы)",
        INSTRUMENTAL = "автоинъектором (Стимуляторы)",
        PREPOSITIONAL = "автоинъекторе (Стимуляторы)"
	)
	icon_state = "stimpen"
	amount_per_transfer_from_this = 50
	volume = 50
	list_reagents = list("stimulants" = 50)

/obj/item/reagent_containers/hypospray/autoinjector/survival
	name = "survival medipen"
	desc = "Маленький инъектор в форме ручки, содержащий внутри дозу веществ для спасения во время экстренных ситуаций, которые могут произойти на пустошах Лаваленда." + span_boldwarning("ПРЕДУПРЕЖДЕНИЕ: Не используйте более одного за раз!")
	ru_names = list(
        NOMINATIVE = "автоинъектор выживания",
        GENITIVE = "автоинъектора выживания",
        DATIVE = "автоинъектору выживания",
        ACCUSATIVE = "автоинъектор выживания",
        INSTRUMENTAL = "автоинъектором выживания",
        PREPOSITIONAL = "автоинъекторе выживания"
	)
	icon_state = "stimpen"
	belt_icon = "survival_medipen"
	volume = 42
	amount_per_transfer_from_this = 42
	list_reagents = list("salbutamol" = 10, "teporone" = 15, "epinephrine" = 10, "lavaland_extract" = 2, "weak_omnizine" = 5) //Short burst of healing, followed by minor healing from the saline

/obj/item/reagent_containers/hypospray/autoinjector/survival/luxury
	name = "luxury medipen"
	desc = "Улучшенная версия стандартного автоинъектора выживания, вмещающая в себя до 40 единиц мощных медикаментов." + span_boldwarning("ПРЕДУПРЕЖДЕНИЕ: Не используйте более одного за раз!")
	ru_names = list(
        NOMINATIVE = "улучшенный автоинъектор выживания",
        GENITIVE = "улучшенного автоинъектора выживания",
        DATIVE = "улучшенному автоинъектору выживания",
        ACCUSATIVE = "улучшенный автоинъектор выживания",
        INSTRUMENTAL = "улучшенным автоинъектором выживания",
        PREPOSITIONAL = "улучшенном автоинъекторе выживания"
	)
	icon_state = "redinjector"
	volume = 40
	amount_per_transfer_from_this = 40
	list_reagents = list("salbutamol" = 10, "adv_lava_extract" = 10, "teporone" = 10, "hydrocodone" = 10)


/obj/item/reagent_containers/hypospray/autoinjector/survival/luxury/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(lavaland_equipment_pressure_check(get_turf(user)))
		amount_per_transfer_from_this = initial(amount_per_transfer_from_this)
		return ..()

	to_chat(user, span_notice("Вы начинаете подготовливать [declent_ru(ACCUSATIVE)] к инъекции."))
	if(!do_after(user, 5 SECONDS, target)) //5 seconds release and...
		return ATTACK_CHAIN_PROCEED

	amount_per_transfer_from_this = initial(amount_per_transfer_from_this) * 0.3 //1/3 of the reagents
	return ..()


/obj/item/reagent_containers/hypospray/autoinjector/nanocalcium
	name = "protoype nanite autoinjector"
	desc = "Маленький инъектор в форме ручки, содержащий внутри дозу экспериментального вещества, предназначенного для заживления внутренних повреждений. Имеются побочные эффекты."
	ru_names = list(
        NOMINATIVE = "экспериментальный автоинъектор (Нано-Кальций)",
        GENITIVE = "экспериментального автоинъектора (Нано-Кальций)",
        DATIVE = "экспериментальному автоинъектору (Нано-Кальций)",
        ACCUSATIVE = "экспериментальный автоинъектор (Нано-Кальций)",
        INSTRUMENTAL = "экспериментальным автоинъектором (Нано-Кальций)",
        PREPOSITIONAL = "экспериментальном автоинъекторе (Нано-Кальций)"
	)
	icon_state = "bonepen"
	amount_per_transfer_from_this = 15
	volume = 15
	list_reagents = list("nanocalcium" = 15)


/obj/item/reagent_containers/hypospray/autoinjector/nanocalcium/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 20, TRUE)


/obj/item/reagent_containers/hypospray/autoinjector/selfmade
	name = "autoinjector"
	desc = "Кустарно произведённая копия автоинъектора. Из-за особенностей конструкции его невозможно использовать на ком-то, кроме себя."
	ru_names = list(
        NOMINATIVE = "самодельный автоинъектор",
        GENITIVE = "самодельного автоинъектора",
        DATIVE = "самодельному автоинъектору",
        ACCUSATIVE = "самодельный автоинъектор",
        INSTRUMENTAL = "самодельным автоинъектором",
        PREPOSITIONAL = "самодельном автоинъекторе"
	)
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list()
	only_self = TRUE
	reskin_allowed = TRUE
	container_type = OPENCONTAINER


/obj/item/reagent_containers/hypospray/autoinjector/selfmade/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		container_type = DRAINABLE


/obj/item/reagent_containers/hypospray/autoinjector/salbutamol
	name = "Salbutamol autoinjector"
	desc = "Маленький инъектор в форме ручки, содержащий внутри дозу сальбутамола для экстренной помощи при удушье."
	ru_names = list(
        NOMINATIVE = "автоинъектор (Сальбутамол)",
        GENITIVE = "автоинъектора (Сальбутамол)",
        DATIVE = "автоинъектору (Сальбутамол)",
        ACCUSATIVE = "автоинъектор (Сальбутамол)",
        INSTRUMENTAL = "автоинъектором (Сальбутамол)",
        PREPOSITIONAL = "автоинъекторе (Сальбутамол)"
	)
	icon_state = "ablueinjector"
	amount_per_transfer_from_this = 20
	volume = 20
	list_reagents = list("salbutamol" = 20)

/obj/item/reagent_containers/hypospray/autoinjector/radium
	name = "Radium autoinjector"
	desc = "Маленький инъектор в форме ручки, содержащий внутри дозу радия для экстренной первой помощи нуклеациям."
	ru_names = list(
        NOMINATIVE = "автоинъектор (Радий)",
        GENITIVE = "автоинъектора (Радий)",
        DATIVE = "автоинъектору (Радий)",
        ACCUSATIVE = "автоинъектор (Радий)",
        INSTRUMENTAL = "автоинъектором (Радий)",
        PREPOSITIONAL = "автоинъекторе (Радий)"
	)
	icon_state = "ablueinjector"
	list_reagents = list("radium" = 10)

/obj/item/reagent_containers/hypospray/autoinjector/charcoal
	name = "Charcoal autoinjector"
	desc = "Маленький инъектор в форме ручки, содержащий внутри дозу активированного угля для экстренной помощи при отравлениях."
	ru_names = list(
        NOMINATIVE = "автоинъектор (Активированный уголь)",
        GENITIVE = "автоинъектора (Активированный уголь)",
        DATIVE = "автоинъектору (Активированный уголь)",
        ACCUSATIVE = "автоинъектор (Активированный уголь)",
        INSTRUMENTAL = "автоинъектором (Активированный уголь)",
        PREPOSITIONAL = "автоинъекторе (Активированный уголь)"
	)
	icon_state = "greeninjector"
	amount_per_transfer_from_this = 20
	volume = 20
	list_reagents = list("charcoal" = 20)
