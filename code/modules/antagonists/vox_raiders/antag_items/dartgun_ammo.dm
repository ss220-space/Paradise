/obj/item/storage/dart_cartridge
	name = "dart cartridge"
	desc = "Подставка для дротиков."
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "darts-0"
	item_state = "rcdammo"
	origin_tech = "materials=2"
	storage_slots = 5
	can_hold = list(
		/obj/item/reagent_containers/syringe/dart,
	)
	var/icon_state_base = "darts"
	var/overlay_state = "darts_overlay"
	var/overlay_state_color
	/// Which dart shall we fill it with
	var/list/dart_fill_types = list()
	/// How many darts will we fill
	var/dart_fill_num = 5
	/// Maximum display of darts on the overlay
	var/dart_overlay_num = 5

/obj/item/storage/dart_cartridge/update_icon_state()
	var/num = length(contents)
	if(!num)
		icon_state = "[icon_state_base]-0"
	else if(num > dart_overlay_num)
		icon_state = "[icon_state_base]-[dart_overlay_num]"
	else
		icon_state = "[icon_state_base]-[num]"
	return TRUE

/obj/item/storage/dart_cartridge/update_overlays()
	. = ..()
	if(overlay_state_color)
		. += "[overlay_state]_[overlay_state_color]"

/obj/item/storage/dart_cartridge/populate_contents()
	if(!length(dart_fill_types))
		return
	var/spawn_first = length(dart_fill_types) == 1
	for(var/i in 1 to dart_fill_num + 1)
		var/dart_type = spawn_first? dart_fill_types[1] : pick(dart_fill_types)
		new dart_type(src)

/obj/item/reagent_containers/syringe/dart
	name = "dart"
	desc = "Дротик содержащий химические коктейли."
	icon = 'icons/obj/dart.dmi'
	amount_per_transfer_from_this = 15

/obj/item/storage/dart_cartridge/extended
	name = "extended dart cartridge"
	desc = "Расширенная подставка для дротиков и шприцов."
	overlay_state_color = "ext"
	can_hold = list(
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/syringe/dart,
	)

/obj/item/storage/dart_cartridge/big
	name = "capacious dart cartridge"
	desc = "Увеличенная подставка для дротиков."
	overlay_state_color = "big"
	storage_slots = 10
	dart_fill_num = 10

/obj/item/storage/dart_cartridge/combat
	name = "combat dart cartridge"
	desc = "Подставка для боевых дротиков для нанесения повреждений."
	overlay_state_color = "red"
	dart_fill_types = list(/obj/item/reagent_containers/syringe/dart/combat)

/obj/item/storage/dart_cartridge/medical
	name = "medical dart cartridge"
	overlay_state_color = "teal"
	desc = "Подставка для полезных дротиков для восстановления."
	dart_fill_types = list(
		/obj/item/reagent_containers/syringe/dart/medical,
		/obj/item/reagent_containers/syringe/dart/medical,
		/obj/item/reagent_containers/syringe/dart/medical,
		/obj/item/reagent_containers/syringe/dart/medical/tainted,
		/obj/item/reagent_containers/syringe/dart/medical/tainted,
		/obj/item/reagent_containers/syringe/dart/medical/heal,
	)

/obj/item/storage/dart_cartridge/pain
	name = "pain dart cartridge"
	overlay_state_color = "yellow"
	desc = "Подставка для вредных дротиков, приносящих боль и страдания."
	dart_fill_types = list(/obj/item/reagent_containers/syringe/dart/pain)

/obj/item/storage/dart_cartridge/drugs
	name = "drugs dart cartridge"
	overlay_state_color = "purple"
	desc = "Подставка для вредных дротиков-наркотиков."
	dart_fill_types = list(/obj/item/reagent_containers/syringe/dart/drugs)

/obj/item/storage/dart_cartridge/big/random
	name = "big random dart cartridge"
	desc = "Случайный набор дротиков с химикатами."
	dart_fill_types = list(
		/obj/item/reagent_containers/syringe/dart/combat,
		/obj/item/reagent_containers/syringe/dart/medical,
		/obj/item/reagent_containers/syringe/dart/pain,
		/obj/item/reagent_containers/syringe/dart/drugs,
		/obj/item/reagent_containers/syringe/dart/pancuronium,
		/obj/item/reagent_containers/syringe/dart/sarin,
		/obj/item/reagent_containers/syringe/dart/capulettium,
		/obj/item/reagent_containers/syringe/dart/bioterror,
		/obj/item/reagent_containers/syringe/dart/heparin,
		/obj/item/reagent_containers/syringe/dart/calomel,
		/obj/item/reagent_containers/syringe/dart/epinephrine,
		/obj/item/reagent_containers/syringe/dart/charcoal,
		/obj/item/reagent_containers/syringe/dart/antiviral,
	)

/obj/item/reagent_containers/syringe/dart/combat
	name = "combat dart"
	desc = "Боевой дротик, заставляющий цель потерять равновесие и впоследствии обездвижиться."
	list_reagents = list(
		/datum/reagent/space_drugs = 5,
		/datum/reagent/medicine/ether = 5,
		/datum/reagent/medicine/haloperidol = 5,
	)

/obj/item/reagent_containers/syringe/dart/pain
	name = "pain dart"
	desc = "Зудящий порошок с примесью гистамина для страданий."
	list_reagents = list(
		/datum/reagent/itching_powder = 10,
		/datum/reagent/histamine = 5,
	)

/obj/item/reagent_containers/syringe/dart/drugs
	name = "pain dart"
	desc = "Отвратительная смесь наркотиков, вызывающая галлюцинации, потерю координации и рассудка."
	list_reagents = list(
		/datum/reagent/space_drugs = 5,
		/datum/reagent/lsd = 5,
		/datum/reagent/fliptonium = 2,
		/datum/reagent/jenkem = 2,
	)

/obj/item/reagent_containers/syringe/dart/antiviral
	name = "dart (spaceacillin)"
	desc = "Содержит противовирусные вещества."
	list_reagents = list(/datum/reagent/medicine/spaceacillin = 15)

/obj/item/reagent_containers/syringe/dart/charcoal
	name = "dart (charcoal)"
	desc = "Содержит древесный уголь для лечения токсинов и повреждений от них."
	list_reagents = list(/datum/reagent/medicine/charcoal = 15)

/obj/item/reagent_containers/syringe/dart/epinephrine
	name = "dart (Epinephrine)"
	desc = "Содержит адреналин для стабилизации пациентов."
	list_reagents = list(/datum/reagent/medicine/epinephrine = 15)

/obj/item/reagent_containers/syringe/dart/calomel
	name = "dart (calomel)"
	desc = "Содержит токсичный каломель для очистки от других веществ в организме."
	list_reagents = list(/datum/reagent/medicine/calomel = 15)

/obj/item/reagent_containers/syringe/dart/heparin
	name = "dart (heparin)"
	desc = "Содержит гепарин, антикоагулянт крови."
	list_reagents = list(/datum/reagent/heparin = 15)

/obj/item/reagent_containers/syringe/dart/bioterror
	name = "bioterror dart"
	desc = "Содержит несколько парализующих реагентов."
	list_reagents = list(
		/datum/reagent/consumable/ethanol/neurotoxin = 5,
		/datum/reagent/capulettium = 5,
		/datum/reagent/sodium_thiopental = 5,
	)

/obj/item/reagent_containers/syringe/dart/capulettium
	name = "capulettium dart"
	desc = "Для упокоения целей."
	list_reagents = list(/datum/reagent/capulettium = 15)

/obj/item/reagent_containers/syringe/dart/sarin
	name = "toxin dart"
	desc = "Смертельный нейротоксин в малых дозах."
	list_reagents = list(/datum/reagent/sarin = 15)

/obj/item/reagent_containers/syringe/dart/pancuronium
	name = "pancuronium dart"
	desc = "Мощный парализующий яд"
	list_reagents = list(/datum/reagent/pancuronium = 15)

/obj/item/reagent_containers/syringe/dart/medical
	name = "medical dart"
	desc = "Медицинский дротик для восстановления большинства повреждений."
	list_reagents = list(
		/datum/reagent/medicine/silver_sulfadiazine = 5,
		/datum/reagent/medicine/styptic_powder = 5,
		/datum/reagent/medicine/charcoal = 5,
	)

/obj/item/reagent_containers/syringe/dart/medical/tainted
	name = "tainted medical dart"
	desc = "На вид будто этой капсулой зачерпнули из первичного бульона. Непонятно кто это сделал, но кажется оно должно лечить. Пахнет мерзко."
	list_reagents = list(
		/datum/reagent/medicine/menthol = 3,
		/datum/reagent/consumable/drink/doctor_delight = 3,
		/datum/reagent/consumable/ethanol/synthanol/synthnsoda = 3,
		/datum/reagent/consumable/drink/tomatojuice = 3,
		/datum/reagent/consumable/drink/milk = 3,
	)

/obj/item/reagent_containers/syringe/dart/medical/heal
	name = "heal medical dart"
	desc = "Медицинский дротик для лечения тяжелых травм."
	list_reagents = list(
		/datum/reagent/medicine/silver_sulfadiazine = 5,
		/datum/reagent/medicine/styptic_powder = 5,
		/datum/reagent/medicine/synthflesh = 5,
	)

/obj/item/reagent_containers/syringe/dart/medical/stabilizing
	name = "stabilizing medical dart"
	desc = "Медицинский дротик для стабилизации пациента."
	list_reagents = list(
		/datum/reagent/medicine/epinephrine = 5,
		/datum/reagent/mutagen/mutagenvirusfood/sugar = 5,
		/datum/reagent/medicine/omnizine_diluted = 5,
	)

/obj/item/reagent_containers/syringe/dart/medical/advanced
	name = "advanced medical dart"
	desc = "Медицинский дротик стимулирующий быструю регенерацию."
	list_reagents = list(
		/datum/reagent/medicine/bicaridine = 5,
		/datum/reagent/medicine/kelotane = 5,
		/datum/reagent/medicine/omnizine = 5,
	)

/obj/item/reagent_containers/syringe/dart/medical/combat
	name = "combat medical dart"
	desc = "передовой дротик с эксперементальными стимулянтами."
	list_reagents = list(
		/datum/reagent/lube/combat = 5,
		/datum/reagent/surge_plus = 5,
		/datum/reagent/medicine/syndicate_nanites = 5,
	)
