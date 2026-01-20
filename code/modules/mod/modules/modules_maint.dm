//Maint modules for MODsuits

// MARK: Springlock
/// Springlock Mechanism - allows your modsuit to activate faster, but reagents are very dangerous.
/obj/item/mod/module/springlock
	name = "MOD springlock module"
	desc = "Модуль для МЭК, представляющий собой пружинный экзоскелет, располагающийся по всей площади костюма под его внешней \
			оболочкой. При активации раскрывается, значительно ускоряя процесс облачения пользователя в костюм, однако имеет критический \
			недостаток: при воздействии влаги пружинный механизм имеет тенденцию \"защёлкиваться\" в исходное положение."
	icon_state = "springlock"
	complexity = 3 // it is inside every part of your suit, so
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	incompatible_modules = list(/obj/item/mod/module/springlock, /obj/item/mod/module/activation_upgrade)
	/// How much faster will your suit deploy?
	var/activation_step_time_booster = 2
	/// Is this the syndicate version, which can be toggled on multitool?
	var/nineteen_eighty_seven_edition = FALSE
	/// If this is true, the suit will prevent you from retracting for 10 seconds, so an antag can smoke bomb you.
	var/dont_let_you_come_back = FALSE
	/// If this is true, we are about to spring shut on someone, and should not remove the retraction blocking.
	var/incoming_jumpscare = FALSE
	/// In order not to make 1000 snups, we make sanity check
	COOLDOWN_DECLARE(springlock_cooldown)

/obj/item/mod/module/holster/get_ru_names() //i have to look on fucking fnaf wiki to find out how to translate this shit
	return list(
		NOMINATIVE = "пружинный модуль",
		GENITIVE = "пружинного модуля",
		DATIVE = "пружинному модулю",
		ACCUSATIVE = "пружинный модуль",
		INSTRUMENTAL = "пружинным модулем",
		PREPOSITIONAL = "пружинном модуле",
	)

/obj/item/mod/module/springlock/on_install()
	. = ..()
	mod.activation_step_time *= (1 / activation_step_time_booster)

/obj/item/mod/module/springlock/on_uninstall(deleting = FALSE)
	. = ..()
	mod.activation_step_time *= activation_step_time_booster

/obj/item/mod/module/springlock/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_wearer_exposed), override = TRUE)
	if(dont_let_you_come_back)
		RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(on_activate_spring_block))
		addtimer(CALLBACK(src, PROC_REF(remove_retraction_block)), 10 SECONDS)

/obj/item/mod/module/springlock/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_ATOM_EXPOSE_REAGENTS)

/obj/item/mod/module/springlock/multitool_act(mob/living/user, obj/item/I)
	if(!nineteen_eighty_seven_edition)
		return
	. = TRUE
	if(dont_let_you_come_back)
		to_chat(user, span_notice("Система блокировки снятия костюма отключена."))
		dont_let_you_come_back = FALSE
		return
	to_chat(user, span_notice("Вы включили систему блокировки снятия костюма. Следующие 10 секунд после активации костюма его невозможно будет выключить."))
	dont_let_you_come_back = TRUE


/// Signal fired when wearer is exposed to reagents
/obj/item/mod/module/springlock/proc/on_wearer_exposed(atom/source, list/reagents, datum/reagents/source_reagents, methods, volume_modifier, show_message)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, springlock_cooldown))
		return
	COOLDOWN_START(src, springlock_cooldown, 5 MINUTES)
	remove_retraction_block() //No double signals
	to_chat(mod.wearer, span_danger("[capitalize(declent_ru(NOMINATIVE))] изда[PLUR_YOT_UT(src)] мерзкий щёлкающий звук..."))
	incoming_jumpscare = TRUE
	playsound(src, 'sound/items/modsuit/springlock.ogg', 75, TRUE)
	addtimer(CALLBACK(src, PROC_REF(snap_shut)), rand(3 SECONDS, 5 SECONDS))
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(on_activate_spring_block))

/// Signal fired when wearer attempts to activate/deactivate suits
/obj/item/mod/module/springlock/proc/on_activate_spring_block(datum/source, user)
	SIGNAL_HANDLER

	to_chat(mod.wearer, span_userdanger("Кажется, пружинные замки костюма не работают..."))
	return MOD_CANCEL_ACTIVATE

/// Removes the retraction blocker from the springlock so long as they are not about to be killed
/obj/item/mod/module/springlock/proc/remove_retraction_block()
	if(!incoming_jumpscare)
		UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)

/// Delayed death proc of the suit after the wearer is exposed to reagents
/obj/item/mod/module/springlock/proc/snap_shut()
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	if(!mod.wearer) //while there is a guaranteed user when on_wearer_exposed() fires, that isn't the same case for this proc
		return
	mod.wearer.visible_message(
		span_danger("Пружинные замки в костюме [mod.wearer.declent_ru(GENITIVE)] слетают и впиваются в пользователя, разрывая его изнутри!"),
		span_biggerdanger("<b>ХРЯСЬ!</b>")
	)
	mod.wearer.emote("scream")
	playsound(mod.wearer, 'sound/effects/snap.ogg', 75, TRUE, frequency = 0.5)
	playsound(mod.wearer, 'sound/effects/splat.ogg', 50, TRUE, frequency = 0.5)
	mod.wearer.adjustBruteLoss(1987) //boggers, bogchamp, etc //why not just poggers, also this caps at 595 damage but comedy
	mod.wearer.client?.give_award(/datum/award/achievement/misc/springlock, mod.wearer)
	incoming_jumpscare = FALSE

// MARK: Balloon blower
/// Balloon Blower - Blows a balloon.
/obj/item/mod/module/balloon
	name = "MOD balloon blower module"
	desc = "Странный модуль для МЭК, изобретённый множество лет назад какими-то находчивыми мимами. Всего лишь надувает шарики."
	icon_state = "bloon"
	module_type = MODULE_USABLE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/balloon)
	cooldown_time = 15 SECONDS
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)

/obj/item/mod/module/balloon/get_ru_names()
	return list(
		NOMINATIVE = "модуль надувания шариков",
		GENITIVE = "модуля надувания шариков",
		DATIVE = "модулю надувания шариков",
		ACCUSATIVE = "модуль надувания шариков",
		INSTRUMENTAL = "модулем надувания шариков",
		PREPOSITIONAL = "модуле надувания шариков",
	)

/obj/item/mod/module/balloon/on_use()
	if(!do_after(mod.wearer, 5 SECONDS, target = mod.wearer))
		return FALSE
	mod.wearer.adjustOxyLoss(20)
	playsound(src, 'sound/items/modsuit/inflate_bloon.ogg', 50, TRUE)
	var/obj/item/toy/balloon/balloon = new(get_turf(src))
	mod.wearer.put_in_hands(balloon)
	drain_power(use_energy_cost)

// MARK: Stamper
/// Stamper - Extends a stamp that can switch between accept/deny modes.
/obj/item/mod/module/stamp
	name = "MOD stamper module"
	desc = "Модуль для МЭК, устанавливаемый в запястье костюма и выполняющий функцию электронной печати \
			с возможностью переключения между режимами \"Отказано\" и \"Одобрено\"."
	icon_state = "stamp"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/stamp/mod
	incompatible_modules = list(/obj/item/mod/module/stamp)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/stamp/get_ru_names()
	return list(
		NOMINATIVE = "модуль печати",
		GENITIVE = "модуля печати",
		DATIVE = "модулю печати",
		ACCUSATIVE = "модуль печати",
		INSTRUMENTAL = "модулем печати",
		PREPOSITIONAL = "модуле печати",
	)

#define STAMP_MODE_OK "ok"
#define STAMP_MODE_DENY "deny"

/obj/item/stamp/mod
	name = "MOD electronic stamp"
	desc = "Электронная печать. Переключается между режимами \"Отказано\" и \"Одобрено\"."
	/// Stamp mode
	var/stamp_mode = STAMP_MODE_OK

/obj/item/stamp/mod/get_ru_names()
	return list(
		NOMINATIVE = "электропечать МЭК",
		GENITIVE = "электропечати МЭК",
		DATIVE = "электропечати МЭК",
		ACCUSATIVE = "электропечать МЭК",
		INSTRUMENTAL = "электропечатью МЭК",
		PREPOSITIONAL = "электропечати МЭК",
	)

/obj/item/stamp/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, MODSUIT_TRAIT)

/obj/item/stamp/mod/attack_self(mob/user, modifiers)
	. = ..()
	if(stamp_mode == STAMP_MODE_OK)
		stamp_mode = STAMP_MODE_DENY
	else
		stamp_mode = STAMP_MODE_DENY
	update_icon(UPDATE_ICON_STATE)

/obj/item/stamp/mod/update_icon_state()
	icon_state = "stamp_" + stamp_mode

#undef STAMP_MODE_OK
#undef STAMP_MODE_DENY

// MARK: Paper dispenser
/// Paper Dispenser - Dispenses (sometimes burning) paper sheets.
/obj/item/mod/module/paper_dispenser
	name = "MOD paper dispenser module"
	desc = "Модуль для МЭК, предназначенный для бюрократов. Печатает тёплые, белоснежные, хрустящие листы бумаги превосходного качества. \
			По крайней мере, в большинстве случаев."
	icon_state = "paper_maker"
	module_type = MODULE_USABLE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/paper_dispenser)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	/// The total number of sheets created by this MOD. The more sheets, them more likely they set on fire.
	var/num_sheets_dispensed = 0

/obj/item/mod/module/paper_dispenser/get_ru_names()
	return list(
		NOMINATIVE = "модуль выдачи бумаги",
		GENITIVE = "модуля выдачи бумаги",
		DATIVE = "модулю выдачи бумаги",
		ACCUSATIVE = "модуль выдачи бумаги",
		INSTRUMENTAL = "модулем выдачи бумаги",
		PREPOSITIONAL = "модуле выдачи бумаги",
	)

/obj/item/mod/module/paper_dispenser/on_use()
	if(!do_after(mod.wearer, 1 SECONDS, target = mod.wearer))
		return FALSE

	var/obj/item/paper/crisp_paper = new(get_turf(src))
	crisp_paper.desc = "Хрустящий и тёплый на ощупь лист бумаги. Судя по всему, напечатан совсем недавно."

	var/obj/structure/table/nearby_table = locate() in range(1, mod.wearer)
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
	balloon_alert(mod.wearer, "бумага напечатана")

	mod.wearer.put_in_hands(crisp_paper)
	if(nearby_table)
		mod.wearer.drop_transfer_item_to_loc(crisp_paper, nearby_table.drop_location(), silent = FALSE)

	// Up to a 30% chance to set the sheet on fire, +2% per sheet made
	if(prob(min(num_sheets_dispensed * 2, 30)))
		if(crisp_paper in list(mod.wearer.get_active_hand(), mod.wearer.get_inactive_hand()))
			mod.wearer.drop_item_ground(crisp_paper, force = TRUE)
		// originally here was "PC LOAD LETTER!", actual HP printer error message that became some kind of western "meme" after film "Office Space", do with that information whatever you want
		crisp_paper.balloon_alert(mod.wearer, UNLINT("ОШИБКА: НЕТ БУМАГИ!"))
		crisp_paper.visible_message(span_warning("[capitalize(crisp_paper)] сгора[PLUR_ET_UT(crisp_paper)] в ярком пламени!"))
		crisp_paper.fire_act(1000, 100)

	drain_power(use_energy_cost)
	num_sheets_dispensed++
