/**
 * # Shell Item
 *
 * Printed out by protolathes. Screwdriver to complete the shell.
 */
/obj/item/shell
	name = "assembly"
	desc = "Сборка корпуса, которую можно завершить с помощью отвертки."
	icon = 'icons/obj/circuits.dmi'
	abstract_type = /obj/item/shell
	var/shell_to_spawn
	var/screw_delay = 3 SECONDS

/obj/item/shell/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_CLONE_IN_EXPERIMENTATOR, INNATE_TRAIT)

/obj/item/shell/screwdriver_act(mob/living/user, obj/item/tool)
	user.visible_message(
		span_notice("[user] начина[PLUR_ET_UT(user)] завершать сборку [declent_ru(ACCUSATIVE)]."),
		ignored_mobs = user,
	)
	balloon_alert(user, "завершение сборки...")

	tool.play_tool_sound(src)
	if(!do_after(user, screw_delay, src))
		return

	user.visible_message(
		span_notice("[user] заверша[PLUR_ET_UT(user)] сборку [declent_ru(ACCUSATIVE)]."),
		ignored_mobs = user,
	)

	var/turf/drop_loc = drop_location()

	qdel(src)
	if(drop_loc)
		drop_loc.balloon_alert(user, "сборка завершена")
		new shell_to_spawn(drop_loc)

	return TRUE

/obj/item/shell/bot
	name = "bot assembly"
	icon_state = "setup_medium_box-open"
	shell_to_spawn = /obj/structure/bot

/obj/item/shell/bot/get_ru_names()
	return list(
		NOMINATIVE = "бот",
		GENITIVE = "бота",
		DATIVE = "боту",
		ACCUSATIVE = "бота",
		INSTRUMENTAL = "ботом",
		PREPOSITIONAL = "боте"
	)

/obj/item/shell/money_bot
	name = "money bot assembly"
	icon_state = "setup_large-open"
	shell_to_spawn = /obj/structure/money_bot

/obj/item/shell/money_bot/get_ru_names()
	return list(
		NOMINATIVE = "бот-банкомат",
		GENITIVE = "бота-банкомата",
		DATIVE = "боту-банкомату",
		ACCUSATIVE = "бота-банкомата",
		INSTRUMENTAL = "ботом-банкоматом",
		PREPOSITIONAL = "боте-банкомате"
	)

/obj/item/shell/drone
	name = "drone assembly"
	icon_state = "setup_medium_med-open"
	shell_to_spawn = /mob/living/simple_animal/circuit_drone
	w_class = WEIGHT_CLASS_HUGE

/obj/item/shell/drone/get_ru_names()
	return list(
		NOMINATIVE = "программируемый дрон",
		GENITIVE = "программируемого дрона",
		DATIVE = "программируемому дрону",
		ACCUSATIVE = "программируемый дрон",
		INSTRUMENTAL = "программируемым дроном",
		PREPOSITIONAL = "программируемом дроне"
	)

/obj/item/shell/server
	name = "server assembly"
	icon_state = "setup_stationary-open"
	shell_to_spawn = /obj/structure/server
	w_class = WEIGHT_CLASS_HUGE
	screw_delay = 10 SECONDS

/obj/item/shell/server/get_ru_names()
	return list(
		NOMINATIVE = "сервер",
		GENITIVE = "сервера",
		DATIVE = "серверу",
		ACCUSATIVE = "сервер",
		INSTRUMENTAL = "сервером",
		PREPOSITIONAL = "сервере"
	)

/obj/item/shell/airlock
	name = "circuit airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "construction"
	shell_to_spawn = /obj/machinery/door/airlock/shell
	screw_delay = 10 SECONDS
	w_class = WEIGHT_CLASS_HUGE

/obj/item/shell/airlock/get_ru_names()
	return list(
		NOMINATIVE = "программируемый шлюз",
		GENITIVE = "программируемого шлюза",
		DATIVE = "программируемому шлюзу",
		ACCUSATIVE = "программируемый шлюз",
		INSTRUMENTAL = "программируемым шлюзом",
		PREPOSITIONAL = "программируемом шлюзе"
	)

/obj/item/shell/dispenser
	name = "circuit dispenser assembly"
	icon_state = "setup_drone_arms-open"
	shell_to_spawn = /obj/structure/dispenser_bot

/obj/item/shell/dispenser/get_ru_names()
	return list(
		NOMINATIVE = "бот-раздатчик",
		GENITIVE = "бота-раздатчика",
		DATIVE = "боту-раздатчику",
		ACCUSATIVE = "бота-раздатчика",
		INSTRUMENTAL = "ботом-раздатчиком",
		PREPOSITIONAL = "боте-раздатчике"
	)

/obj/item/shell/bci
	name = "brain-computer interface assembly"
	icon_state = "bci-open"
	shell_to_spawn = /obj/item/organ/internal/cyberimp/brain/bci
	w_class = WEIGHT_CLASS_TINY

/obj/item/shell/bci/get_ru_names()
	return list(
		NOMINATIVE = "интерфейс \"Мозг-Компьютер\"",
		GENITIVE = "интерфейса \"Мозг-Компьютер\"",
		DATIVE = "интерфейсу \"Мозг-Компьютер\"",
		ACCUSATIVE = "интерфейс \"Мозг-Компьютер\"",
		INSTRUMENTAL = "интерфейсом \"Мозг-Компьютер\"",
		PREPOSITIONAL = "интерфейсе \"Мозг-Компьютер\""
	)

/obj/item/shell/manipulator
	name = "manipulator assembly"
	icon_state = "setup_large_arm-open"
	shell_to_spawn = /obj/structure/wiremod_manipulator

/obj/item/shell/manipulator/get_ru_names()
	return list(
		NOMINATIVE = "манипулятор",
		GENITIVE = "манипулятора",
		DATIVE = "манипулятору",
		ACCUSATIVE = "манипулятор",
		INSTRUMENTAL = "манипулятором",
		PREPOSITIONAL = "манипуляторе"
	)

// /obj/item/shell/scanner_gate
// 	name = "scanner gate assembly"
// 	icon = 'icons/obj/machines/scangate.dmi'
// 	icon_state = "scangate_black_open"
// 	shell_to_spawn = /obj/structure/scanner_gate_shell
