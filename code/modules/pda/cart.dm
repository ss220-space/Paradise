/obj/item/cartridge
	name = "generic cartridge"
	desc = "Картридж данных для КПК."
	ru_names = list(
		NOMINATIVE = "картридж",
		GENITIVE = "картриджа",
		DATIVE = "картриджу",
		ACCUSATIVE = "картридж",
		INSTRUMENTAL = "картриджем",
		PREPOSITIONAL = "картридже"
	)
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_TINY

	var/obj/item/integrated_radio/radio = null

	var/charges = 0

	var/list/stored_data = list()
	var/list/programs = list()
	var/list/messenger_plugins = list()

/obj/item/cartridge/Destroy()
	QDEL_NULL(radio)
	QDEL_LIST(programs)
	QDEL_LIST(messenger_plugins)
	return ..()

/obj/item/cartridge/proc/update_programs(obj/item/pda/pda)
	for(var/A in programs)
		var/datum/data/pda/P = A
		P.pda = pda
	for(var/A in messenger_plugins)
		var/datum/data/pda/messenger_plugin/P = A
		P.pda = pda

/obj/item/cartridge/proc/stamp_act(stamp)
	var/result = FALSE
	for(var/A in programs)
		var/datum/data/pda/P = A
		result = result || P.stamp_act(stamp)
	for(var/A in messenger_plugins)
		var/datum/data/pda/messenger_plugin/P = A
		result = result || P.stamp_act(stamp)
	return result

/obj/item/cartridge/proc/on_id_updated()
	for(var/A in programs)
		var/datum/data/pda/P = A
		P.on_id_updated()
	for(var/A in messenger_plugins)
		var/datum/data/pda/messenger_plugin/P = A
		P.on_id_updated()

/obj/item/cartridge/engineering
	name = "Power-ON Cartridge"
	ru_names = list(
		NOMINATIVE = "картридж управления питанием",
		GENITIVE = "картриджа управления питанием",
		DATIVE = "картриджу управления питанием",
		ACCUSATIVE = "картридж управления питанием",
		INSTRUMENTAL = "картриджем управления питанием",
		PREPOSITIONAL = "картридже управления питанием"
	)
	icon_state = "cart-e"
	programs = list(
		new/datum/data/pda/app/power,
		new/datum/data/pda/utility/scanmode/halogen)

/obj/item/cartridge/atmos
	name = "BreatheDeep Cartridge"
	ru_names = list(
		NOMINATIVE = "картридж \"ДышиГлубже\"",
		GENITIVE = "картриджа \"ДышиГлубже\"",
		DATIVE = "картриджу \"ДышиГлубже\"",
		ACCUSATIVE = "картридж \"ДышиГлубже\"",
		INSTRUMENTAL = "картриджем \"ДышиГлубже\"",
		PREPOSITIONAL = "картридже \"ДышиГлубже\""
	)
	icon_state = "cart-a"
	programs = list(new/datum/data/pda/utility/scanmode/gas)

/obj/item/cartridge/medical
	name = "Med-U Cartridge"
	ru_names = list(
		NOMINATIVE = "картридж \"Мед-U\"",
		GENITIVE = "картриджа \"Мед-U\"",
		DATIVE = "картриджу \"Мед-U\"",
		ACCUSATIVE = "картридж \"Мед-U\"",
		INSTRUMENTAL = "картриджем \"Мед-U\"",
		PREPOSITIONAL = "картридже \"Мед-U\""
	)
	icon_state = "cart-m"
	programs = list(
		new/datum/data/pda/app/crew_records/medical,
		new/datum/data/pda/utility/scanmode/medical)

/obj/item/cartridge/chemistry
	name = "ChemWhiz Cartridge"
	ru_names = list(
		NOMINATIVE = "картридж \"ХимВиз\"",
		GENITIVE = "картриджа \"ХимВиз\"",
		DATIVE = "картриджу \"ХимВиз\"",
		ACCUSATIVE = "картридж \"ХимВиз\"",
		INSTRUMENTAL = "картриджем \"ХимВиз\"",
		PREPOSITIONAL = "картридже \"ХимВиз\""
	)
	icon_state = "cart-chem"
	programs = list(new/datum/data/pda/utility/scanmode/reagent)

/obj/item/cartridge/security
	name = "R.O.B.U.S.T. Cartridge"
	ru_names = list(
		NOMINATIVE = "картридж \"Р.О.Б.А.С.Т.\"",
		GENITIVE = "картриджа \"Р.О.Б.А.С.Т.\"",
		DATIVE = "картриджу \"Р.О.Б.А.С.Т.\"",
		ACCUSATIVE = "картридж \"Р.О.Б.А.С.Т.\"",
		INSTRUMENTAL = "картриджем \"Р.О.Б.А.С.Т.\"",
		PREPOSITIONAL = "картридже \"Р.О.Б.А.С.Т.\""
	)
	icon_state = "cart-s"
	programs = list(
		new/datum/data/pda/app/crew_records/security,
		new/datum/data/pda/app/secbot_control)

/obj/item/cartridge/security/Initialize(mapload)
	. = ..()
	radio = new /obj/item/integrated_radio/beepsky(src)

/obj/item/cartridge/detective
	name = "D.E.T.E.C.T. Cartridge"
	ru_names = list(
		NOMINATIVE = "картридж \"Д.Е.Т.Е.К.Т.\"",
		GENITIVE = "картриджа \"Д.Е.Т.Е.К.Т.\"",
		DATIVE = "картриджу \"Д.Е.Т.Е.К.Т.\"",
		ACCUSATIVE = "картридж \"Д.Е.Т.Е.К.Т.\"",
		INSTRUMENTAL = "картриджем \"Д.Е.Т.Е.К.Т.\"",
		PREPOSITIONAL = "картридже \"Д.Е.Т.Е.К.Т.\""
	)
	icon_state = "cart-s"
	programs = list(
		new/datum/data/pda/app/crew_records/medical,
		new/datum/data/pda/utility/scanmode/medical,

		new/datum/data/pda/app/crew_records/security)


/obj/item/cartridge/janitor
	name = "CustodiPRO Cartridge"
	desc = "Лучший дизайн для чистки помещений."
		ru_names = list(
		NOMINATIVE = "картридж \"КастодиПРО\"",
		GENITIVE = "картриджа \"КастодиПРО\"",
		DATIVE = "картриджу \"КастодиПРО\"",
		ACCUSATIVE = "картридж \"КастодиПРО\"",
		INSTRUMENTAL = "картриджем \"КастодиПРО\"",
		PREPOSITIONAL = "картридже \"КастодиПРО\""
	)
	icon_state = "cart-j"
	programs = list(new/datum/data/pda/app/janitor)

/obj/item/cartridge/lawyer
	name = "P.R.O.V.E. Cartridge"
	ru_names = list(
		NOMINATIVE = "картридж \"П.Р.У.В.\"",
		GENITIVE = "картриджа \"П.Р.У.В.\"",
		DATIVE = "картриджу \"П.Р.У.В.\"",
		ACCUSATIVE = "картридж \"П.Р.У.В.\"",
		INSTRUMENTAL = "картриджем \"П.Р.У.В.\"",
		PREPOSITIONAL = "картридже \"П.Р.У.В.\""
	)
	icon_state = "cart-s"
	programs = list(new/datum/data/pda/app/crew_records/security)

/obj/item/cartridge/clown
	name = "Honkworks 5.0"
	ru_names = list(
		NOMINATIVE = "картридж \"Хонкворкс 5.0\"",
		GENITIVE = "картриджа \"Хонкворкс 5.0\"",
		DATIVE = "картриджу \"Хонкворкс 5.0\"",
		ACCUSATIVE = "картридж \"Хонкворкс 5.0\"",
		INSTRUMENTAL = "картриджем \"Хонкворкс 5.0\"",
		PREPOSITIONAL = "картридже \"Хонкворкс 5.0\""
	)
	icon_state = "cart-clown"
	charges = 5
	programs = list(new/datum/data/pda/utility/honk)
	messenger_plugins = list(new/datum/data/pda/messenger_plugin/virus/clown)

/obj/item/cartridge/mime
	name = "Gestur-O 1000"
	ru_names = list(
		NOMINATIVE = "картридж \"Жест-O 1000\"",
		GENITIVE = "картриджа \"Жест-O 1000\"",
		DATIVE = "картриджу \"Жест-O 1000\"",
		ACCUSATIVE = "картридж \"Жест-O 1000\"",
		INSTRUMENTAL = "картриджем \"Жест-O 1000\"",
		PREPOSITIONAL = "картридже \"Жест-O 1000\""
	)
	icon_state = "cart-mi"
	charges = 5
	messenger_plugins = list(new/datum/data/pda/messenger_plugin/virus/mime)

/*
/obj/item/cartridge/botanist
	name = "Green Thumb v4.20"
	icon_state = "cart-b"
	access_flora = 1
*/

/obj/item/cartridge/signal
	name = "generic signaler cartridge"
	desc = "Картридж данных со встроенным модулем сигнализатора."
	ru_names = list(
		NOMINATIVE = "картридж универсального сигнализатора",
		GENITIVE = "картриджа универсального сигнализатора",
		DATIVE = "картриджу универсального сигнализатора",
		ACCUSATIVE = "картридж универсального сигнализатора",
		INSTRUMENTAL = "картриджем универсального сигнализатора",
		PREPOSITIONAL = "картридже универсального сигнализатора"
	)
	programs = list(new/datum/data/pda/app/signaller)

/obj/item/cartridge/signal/Initialize(mapload)
	. = ..()
	radio = new /obj/item/integrated_radio/signal(src)

/obj/item/cartridge/signal/toxins
	name = "Signal Ace 2"
	desc = "В комплекте со встроенным радиосигнализатором!"
	ru_names = list(
		NOMINATIVE = "картридж \"сигнализатор-ас 2\"",
		GENITIVE = "картриджа \"сигнализатор-ас 2\"",
		DATIVE = "картриджу \"сигнализатор-ас 2\"",
		ACCUSATIVE = "картридж \"сигнализатор-ас 2\"",
		INSTRUMENTAL = "картриджем \"сигнализатор-ас 2\"",
		PREPOSITIONAL = "картридже \"сигнализатор-ас 2\""
	)
	icon_state = "cart-tox"
	programs = list(
		new/datum/data/pda/utility/scanmode/gas,

		new/datum/data/pda/utility/scanmode/reagent,

		new/datum/data/pda/app/signaller)

/obj/item/cartridge/quartermaster
	name = "Space Parts & Space Vendors Cartridge"
	desc = "Идеально подходит для Квартирмейстера!"
	ru_names = list(
		NOMINATIVE = "картридж деталей и поставщиков космических товаров",
		GENITIVE = "картриджа деталей и поставщиков космических товаров",
		DATIVE = "картриджу деталей и поставщиков космических товаров",
		ACCUSATIVE = "картридж деталей и поставщиков космических товаров",
		INSTRUMENTAL = "картриджем деталей и поставщиков космических товаров",
		PREPOSITIONAL = "картридже деталей и поставщиков космических товаров"
	)
	icon_state = "cart-q"
	programs = list(
		new/datum/data/pda/app/supply,
		new/datum/data/pda/app/mule_control)

/obj/item/cartridge/quartermaster/Initialize(mapload)
	. = ..()
	radio = new /obj/item/integrated_radio/mule(src)

/obj/item/cartridge/head
	name = "Easy-Record DELUXE"
	ru_names = list(
		NOMINATIVE = "картридж редактирования",
		GENITIVE = "картриджа редактирования",
		DATIVE = "картриджу редактирования",
		ACCUSATIVE = "картридж редактирования",
		INSTRUMENTAL = "картриджем редактирования",
		PREPOSITIONAL = "картридже редактирования"
	)
	icon_state = "cart-h"
	programs = list(new/datum/data/pda/app/status_display)

/obj/item/cartridge/hop
	name = "HumanResources9001"
	ru_names = list(
		NOMINATIVE = "картридж \"ЭйчАр-9001\"",
		GENITIVE = "картриджа \"ЭйчАр-9001\"",
		DATIVE = "картриджу \"ЭйчАр-9001\"",
		ACCUSATIVE = "картридж \"ЭйчАр-9001\"",
		INSTRUMENTAL = "картриджем \"ЭйчАр-9001\"",
		PREPOSITIONAL = "картридже \"ЭйчАр-9001\""
	)
	icon_state = "cart-h"
	programs = list(
		new/datum/data/pda/app/crew_records/security,

		new/datum/data/pda/app/janitor,

		new/datum/data/pda/app/supply,
		new/datum/data/pda/app/mule_control,

		new/datum/data/pda/app/status_display)

/obj/item/cartridge/hop/Initialize(mapload)
	. = ..()
	radio = new /obj/item/integrated_radio/mule(src)

/obj/item/cartridge/hos
	name = "R.O.B.U.S.T. DELUXE"
	ru_names = list(
		NOMINATIVE = "картридж \"Р.О.Б.А.С.Т.\" делюкс",
		GENITIVE = "картриджа \"Р.О.Б.А.С.Т.\" делюкс",
		DATIVE = "картриджу \"Р.О.Б.А.С.Т.\" делюкс",
		ACCUSATIVE = "картридж \"Р.О.Б.А.С.Т.\" делюкс",
		INSTRUMENTAL = "картриджем \"Р.О.Б.А.С.Т.\" делюкс",
		PREPOSITIONAL = "картридже \"Р.О.Б.А.С.Т.\" делюкс"
	)
	icon_state = "cart-hos"
	programs = list(
		new/datum/data/pda/app/crew_records/security,
		new/datum/data/pda/app/secbot_control,

		new/datum/data/pda/app/status_display)

/obj/item/cartridge/hos/Initialize(mapload)
	. = ..()
	radio = new /obj/item/integrated_radio/beepsky(src)

/obj/item/cartridge/ce
	name = "Power-On DELUXE"
	ru_names = list(
		NOMINATIVE = "картридж управления питанием делюкс",
		GENITIVE = "картриджа управления питанием делюкс",
		DATIVE = "картриджу управления питанием делюкс",
		ACCUSATIVE = "картридж управления питанием делюкс",
		INSTRUMENTAL = "картриджем управления питанием делюкс",
		PREPOSITIONAL = "картридже управления питанием делюкс"
	)
	icon_state = "cart-ce"
	programs = list(
		new/datum/data/pda/app/power,
		new/datum/data/pda/utility/scanmode/halogen,

		new/datum/data/pda/utility/scanmode/gas,

		new/datum/data/pda/app/status_display)

/obj/item/cartridge/cmo
	name = "Med-U DELUXE"
	ru_names = list(
		NOMINATIVE = "картридж \"Мед-U\" делюкс",
		GENITIVE = "картриджа \"Мед-U\" делюкс",
		DATIVE = "картриджу \"Мед-U\" делюкс",
		ACCUSATIVE = "картридж \"Мед-U\" делюкс",
		INSTRUMENTAL = "картриджем \"Мед-U\" делюкс",
		PREPOSITIONAL = "картридже \"Мед-U\" делюкс"
	)
	icon_state = "cart-cmo"
	programs = list(
		new/datum/data/pda/app/crew_records/medical,
		new/datum/data/pda/utility/scanmode/medical,

		new/datum/data/pda/utility/scanmode/reagent,

		new/datum/data/pda/app/status_display)

/obj/item/cartridge/rd
	name = "Signal Ace DELUXE"
	ru_names = list(
		NOMINATIVE = "картридж \"сигнализатор-ас\" делюкс",
		GENITIVE = "картриджа \"сигнализатор-ас\" делюкс",
		DATIVE = "картриджу \"сигнализатор-ас\" делюкс",
		ACCUSATIVE = "картридж \"сигнализатор-ас\" делюкс",
		INSTRUMENTAL = "картриджем \"сигнализатор-ас\" делюкс",
		PREPOSITIONAL = "картридже \"сигнализатор-ас\" делюкс"
	)
	icon_state = "cart-rd"
	programs = list(
		new/datum/data/pda/utility/scanmode/gas,

		new/datum/data/pda/utility/scanmode/reagent,

		new/datum/data/pda/app/signaller,

		new/datum/data/pda/app/status_display)

/obj/item/cartridge/rd/Initialize(mapload)
	. = ..()
	radio = new /obj/item/integrated_radio/signal(src)

/obj/item/cartridge/captain
	name = "Value-PAK Cartridge"
	desc = "На 200% функциональнее!"
	ru_names = list(
		NOMINATIVE = "картридж \"всё в одном\"",
		GENITIVE = "картриджа \"всё в одном\"",
		DATIVE = "картриджу \"всё в одном\"",
		ACCUSATIVE = "картридж \"всё в одном\"",
		INSTRUMENTAL = "картриджем \"всё в одном\"",
		PREPOSITIONAL = "картридже \"всё в одном\""
	)
	icon_state = "cart-c"
	programs = list(
		new/datum/data/pda/app/power,
		new/datum/data/pda/utility/scanmode/halogen,

		new/datum/data/pda/utility/scanmode/gas,

		new/datum/data/pda/app/crew_records/medical,
		new/datum/data/pda/utility/scanmode/medical,

		new/datum/data/pda/utility/scanmode/reagent,

		new/datum/data/pda/app/crew_records/security,
		new/datum/data/pda/app/secbot_control,

		new/datum/data/pda/app/janitor,

		new/datum/data/pda/app/supply,

		new/datum/data/pda/app/status_display)

/obj/item/cartridge/captain/Initialize(mapload)
	. = ..()
	radio = new /obj/item/integrated_radio/beepsky(src)

/obj/item/cartridge/supervisor
	name = "Easy-Record DELUXE"
	ru_names = list(
		NOMINATIVE = "картридж редактирования делюкс",
		GENITIVE = "картриджа редактирования делюкс",
		DATIVE = "картриджу редактирования делюкс",
		ACCUSATIVE = "картридж редактирования делюкс",
		INSTRUMENTAL = "картриджем редактирования делюкс",
		PREPOSITIONAL = "картридже редактирования делюкс"
	)
	icon_state = "cart-h"
	programs = list(
		new/datum/data/pda/app/crew_records/security,

		new/datum/data/pda/app/status_display)

/obj/item/cartridge/centcom
	name = "Value-PAK Cartridge"
	desc = "На 200% функциональнее!"
	ru_names = list(
		NOMINATIVE = "картридж \"всё в одном\"",
		GENITIVE = "картриджа \"всё в одном\"",
		DATIVE = "картриджу \"всё в одном\"",
		ACCUSATIVE = "картридж \"всё в одном\"",
		INSTRUMENTAL = "картриджем \"всё в одном\"",
		PREPOSITIONAL = "картридже \"всё в одном\""
	)
	icon_state = "cart-c"
	programs = list(
		new/datum/data/pda/app/power,
		new/datum/data/pda/utility/scanmode/halogen,

		new/datum/data/pda/utility/scanmode/gas,

		new/datum/data/pda/app/crew_records/medical,
		new/datum/data/pda/utility/scanmode/medical,

		new/datum/data/pda/utility/scanmode/reagent,

		new/datum/data/pda/app/crew_records/security,
		new/datum/data/pda/app/secbot_control,

		new/datum/data/pda/app/janitor,

		new/datum/data/pda/app/supply,

		new/datum/data/pda/app/status_display)

/obj/item/cartridge/centcom/Initialize(mapload)
	. = ..()
	radio = new /obj/item/integrated_radio/beepsky(src)

/obj/item/cartridge/syndicate
	name = "Detomatix Cartridge"
	ru_names = list(
		NOMINATIVE = "картридж детонатикс",
		GENITIVE = "картриджа детонатикс",
		DATIVE = "картриджу детонатикс",
		ACCUSATIVE = "картридж детонатикс",
		INSTRUMENTAL = "картриджем детонатикс",
		PREPOSITIONAL = "картридже детонатикс"
	)
	icon_state = "cart"
	var/initial_remote_door_id = "smindicate" //Make sure this matches the syndicate shuttle's shield/door id!!	//don't ask about the name, testing.
	charges = 4
	programs = list(new/datum/data/pda/utility/toggle_door)
	messenger_plugins = list(new/datum/data/pda/messenger_plugin/virus/detonate)

/obj/item/cartridge/syndicate/Initialize(mapload)
	. = ..()
	var/datum/data/pda/utility/toggle_door/D = programs[1]
	if(istype(D))
		D.remote_door_id = initial_remote_door_id

/obj/item/cartridge/frame
	name = "F.R.A.M.E. cartridge"
	ru_names = list(
		NOMINATIVE = "картридж П.О.Д.С.Т.А.В.А.",
		GENITIVE = "картриджа П.О.Д.С.Т.А.В.А.",
		DATIVE = "картриджу П.О.Д.С.Т.А.В.А.",
		ACCUSATIVE = "картридж П.О.Д.С.Т.А.В.А.",
		INSTRUMENTAL = "картриджем П.О.Д.С.Т.А.В.А.",
		PREPOSITIONAL = "картридже П.О.Д.С.Т.А.В.А."
	)
	icon_state = "cart"
	charges = 5
	var/telecrystals = 0
	messenger_plugins = list(new/datum/data/pda/messenger_plugin/virus/frame)
