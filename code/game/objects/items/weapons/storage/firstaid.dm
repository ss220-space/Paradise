/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 *		Dice Pack (in a pill bottle)
 */

/*
 * First Aid Kits
 */
/obj/item/storage/firstaid
	name = "first-aid kit"
	desc = "Это аптечка для экстренной первой помощи."
	ru_names = list(
        NOMINATIVE = "аптечка первой помощи",
        GENITIVE = "аптечки первой помощи",
        DATIVE = "аптечке первой помощи",
        ACCUSATIVE = "аптечку первой помощи",
        INSTRUMENTAL = "аптечкой первой помощи",
        PREPOSITIONAL = "аптечке первой помощи"
	)
	gender = FEMALE
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
	req_access = list(ACCESS_MEDICAL, ACCESS_ROBOTICS) //Access and treatment are utilized for medbots.
	var/treatment_brute = "salglu_solution"
	var/treatment_oxy = "salbutamol"
	var/treatment_fire = "salglu_solution"
	var/treatment_tox = "charcoal"
	var/treatment_virus = "spaceacillin"
	var/med_bot_skin = null
	var/syndicate_aligned = FALSE


/obj/item/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "Это аптечка для экстренной первой помощи при серьёзных термических повреждениях."
	ru_names = list(
        NOMINATIVE = "аптечка первой помощи (Терм.)",
        GENITIVE = "аптечки первой помощи (Терм.)",
        DATIVE = "аптечке первой помощи (Терм.)",
        ACCUSATIVE = "аптечку первой помощи (Терм.)",
        INSTRUMENTAL = "аптечкой первой помощи (Терм.)",
        PREPOSITIONAL = "аптечке первой помощи (Терм.)"
	)
	icon_state = "ointment"
	item_state = "firstaid-ointment"
	med_bot_skin = "ointment"

/obj/item/storage/firstaid/fire/New()
	..()
	icon_state = pick("ointment", "firefirstaid")

/obj/item/storage/firstaid/fire/populate_contents()
	new /obj/item/reagent_containers/applicator/burn(src)
	new /obj/item/reagent_containers/food/pill/patch/silver_sulf/small(src)
	new /obj/item/healthanalyzer(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)

/obj/item/storage/firstaid/fire/empty/populate_contents()
	return

/obj/item/storage/firstaid/regular
	desc = "Это аптечка общего назначения для экстренной первой помощи."
	ru_names = list(
        NOMINATIVE = "аптечка первой помощи (Общая)",
        GENITIVE = "аптечки первой помощи (Общая)",
        DATIVE = "аптечке первой помощи (Общая)",
        ACCUSATIVE = "аптечку первой помощи (Общая)",
        INSTRUMENTAL = "аптечкой первой помощи (Общая)",
        PREPOSITIONAL = "аптечке первой помощи (Общая)"
	)
	icon_state = "firstaid"

/obj/item/storage/firstaid/regular/populate_contents()
	new /obj/item/reagent_containers/food/pill/patch/styptic(src)
	new /obj/item/reagent_containers/food/pill/patch/styptic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/patch/silver_sulf(src)
	new /obj/item/reagent_containers/food/pill/patch/silver_sulf(src)
	new /obj/item/healthanalyzer(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)

/obj/item/storage/firstaid/regular/empty/populate_contents()
	return

/obj/item/storage/firstaid/doctor
	desc = "Это аптечка для экстренной первой помощи при повреждениях, улучшенная версия."
	ru_names = list(
        NOMINATIVE = "аптечка первой помощи (Общая+)",
        GENITIVE = "аптечки первой помощи (Общая+)",
        DATIVE = "аптечке первой помощи (Общая+)",
        ACCUSATIVE = "аптечку первой помощи (Общая+)",
        INSTRUMENTAL = "аптечкой первой помощи (Общая+)",
        PREPOSITIONAL = "аптечке первой помощи (Общая+)"
	)
	icon_state = "firstaid"

/obj/item/storage/firstaid/doctor/populate_contents()
	new /obj/item/reagent_containers/applicator/brute(src)
	new /obj/item/reagent_containers/applicator/burn(src)
	new /obj/item/reagent_containers/food/pill/patch/styptic(src)
	new /obj/item/reagent_containers/food/pill/patch/silver_sulf(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/healthanalyzer/advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)

/obj/item/storage/firstaid/doctor/empty/populate_contents()
	return

/obj/item/storage/firstaid/toxin
	name = "toxin first aid kit"
	desc = "Это аптечка для экстренной первой помощи при отравлениях."
	ru_names = list(
        NOMINATIVE = "аптечка первой помощи (Отравления)",
        GENITIVE = "аптечки первой помощи (Отравления)",
        DATIVE = "аптечке первой помощи (Отравления)",
        ACCUSATIVE = "аптечку первой помощи (Отравления)",
        INSTRUMENTAL = "аптечкой первой помощи (Отравления)",
        PREPOSITIONAL = "аптечке первой помощи (Отравления)"
	)
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"
	med_bot_skin = "tox"

/obj/item/storage/firstaid/toxin/Initialize(mapload)
	. = ..()
	icon_state = pick("antitoxin", "antitoxfirstaid")

/obj/item/storage/firstaid/toxin/populate_contents()
	new /obj/item/reagent_containers/syringe/charcoal(src)
	new /obj/item/reagent_containers/syringe/charcoal(src)
	new /obj/item/reagent_containers/syringe/charcoal(src)
	new /obj/item/reagent_containers/food/pill/charcoal(src)
	new /obj/item/reagent_containers/food/pill/charcoal(src)
	new /obj/item/reagent_containers/food/pill/charcoal(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/firstaid/toxin/empty/populate_contents()
	return

/obj/item/storage/firstaid/o2
	name = "oxygen deprivation first aid kit"
	desc = "Это аптечка для экстренной первой помощи при удушьях."
	ru_names = list(
        NOMINATIVE = "аптечка первой помощи (Удушье)",
        GENITIVE = "аптечки первой помощи (Удушье)",
        DATIVE = "аптечке первой помощи (Удушье)",
        ACCUSATIVE = "аптечку первой помощи (Удушье)",
        INSTRUMENTAL = "аптечкой первой помощи (Удушье)",
        PREPOSITIONAL = "аптечке первой помощи (Удушье)"
	)
	icon_state = "o2"
	item_state = "firstaid-o2"
	med_bot_skin = "o2"

/obj/item/storage/firstaid/o2/populate_contents()
	new /obj/item/reagent_containers/food/pill/salbutamol(src)
	new /obj/item/reagent_containers/food/pill/salbutamol(src)
	new /obj/item/reagent_containers/food/pill/salbutamol(src)
	new /obj/item/reagent_containers/food/pill/salbutamol(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/firstaid/o2/empty/populate_contents()
	return

/obj/item/storage/firstaid/brute
	name = "brute trauma treatment kit"
	desc = "Это аптечка для экстренной первой помощи при серьёзных механических повреждениях."
	ru_names = list(
        NOMINATIVE = "аптечка первой помощи (Мех.)",
        GENITIVE = "аптечки первой помощи (Мех.)",
        DATIVE = "аптечке первой помощи (Мех.)",
        ACCUSATIVE = "аптечку первой помощи (Мех.)",
        INSTRUMENTAL = "аптечкой первой помощи (Мех.)",
        PREPOSITIONAL = "аптечке первой помощи (Мех.)"
	)
	icon_state = "brute"
	item_state = "firstaid-brute"
	med_bot_skin = "brute"

/obj/item/storage/firstaid/brute/New()
	..()
	icon_state = pick("brute", "brute2")

/obj/item/storage/firstaid/brute/populate_contents()
	new /obj/item/reagent_containers/applicator/brute(src)
	new /obj/item/reagent_containers/food/pill/patch/styptic/small(src)
	new /obj/item/healthanalyzer(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/stack/medical/bruise_pack(src)

/obj/item/storage/firstaid/brute/empty/populate_contents()
	return

/obj/item/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Это аптечка для экстренной первой помощи, продвинутая версия."
	ru_names = list(
        NOMINATIVE = "аптечка первой помощи (Продвинутая)",
        GENITIVE = "аптечки первой помощи (Продвинутая)",
        DATIVE = "аптечке первой помощи (Продвинутая)",
        ACCUSATIVE = "аптечку первой помощи (Продвинутая)",
        INSTRUMENTAL = "аптечкой первой помощи (Продвинутая)",
        PREPOSITIONAL = "аптечке первой помощи (Продвинутая)"
	)
	icon_state = "advfirstaid"
	item_state = "firstaid-advanced"
	med_bot_skin = "adv"

/obj/item/storage/firstaid/adv/populate_contents()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/stack/medical/ointment/advanced(src)
	new /obj/item/stack/medical/ointment/advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/firstaid/adv/empty/populate_contents()
	return

/obj/item/storage/firstaid/paramed
	name = "paramed first-aid kit"
	desc = "Это аптечка для экстренной первой помощи при, специализированная версия для Парамедика."
	ru_names = list(
        NOMINATIVE = "аптечка первой помощи (Парамедик)",
        GENITIVE = "аптечки первой помощи (Парамедик)",
        DATIVE = "аптечке первой помощи (Парамедик)",
        ACCUSATIVE = "аптечку первой помощи (Парамедик)",
        INSTRUMENTAL = "аптечкой первой помощи (Парамедик)",
        PREPOSITIONAL = "аптечке первой помощи (Парамедик)"
	)
	icon_state = "firstaid_paramed"
	item_state = "firstaid_paramed"
	med_bot_skin = "paramed"

/obj/item/storage/firstaid/paramed/populate_contents()
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/salbutamol(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/charcoal(src)
	new /obj/item/reagent_containers/food/pill/patch/styptic(src)
	new	/obj/item/reagent_containers/food/pill/patch/silver_sulf(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)

/obj/item/storage/firstaid/paramed/empty/populate_contents()
	return

/obj/item/storage/firstaid/machine
	name = "machine repair kit"
	desc = "Это набор для полевого ремонта синтетических форм жизни при повреждениях."
	ru_names = list(
        NOMINATIVE = "ремонтный набор (Синт.)",
        GENITIVE = "ремонтного набора (Синт.)",
        DATIVE = "ремонтному набору (Синт.)",
        ACCUSATIVE = "ремонтный набор (Синт.)",
        INSTRUMENTAL = "ремонтным набором (Синт.)",
        PREPOSITIONAL = "ремонтном наборе (Синт.)"
	)
	gender = MALE
	icon_state = "machinefirstaid"
	item_state = "firstaid-machine"
	med_bot_skin = "machine"

/obj/item/storage/firstaid/machine/populate_contents()
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/robotanalyzer(src)

/obj/item/storage/firstaid/machine/empty/populate_contents()
	return

/obj/item/storage/firstaid/tactical
	name = "NT first-aid kit"
	desc = "Тактическая аптечка, содержащая в себе всё самое необходимое для лечения в пылу боя."
	ru_names = list(
        NOMINATIVE = "тактическая аптечка НТ",
        GENITIVE = "тактической аптечки НТ",
        DATIVE = "тактической аптечке НТ",
        ACCUSATIVE = "тактическую аптечку НТ",
        INSTRUMENTAL = "тактической аптечкой НТ",
        PREPOSITIONAL = "тактической аптечке НТ"
	)
	icon_state = "NTfirstaid"
	max_w_class = WEIGHT_CLASS_NORMAL
	treatment_oxy = "perfluorodecalin"
	treatment_brute = "bicaridine"
	treatment_fire = "kelotane"
	treatment_tox = "charcoal"
	req_access = list(ACCESS_SYNDICATE)
	med_bot_skin = "bezerk"
	syndicate_aligned = FALSE

/obj/item/storage/firstaid/tactical/sst
	desc = "Тактическая аптечка, содержащая в себе всё самое необходимое для лечения в пылу боя. Узкоспециализированная версия для бойцов элитных сил."
	ru_names = list(
        NOMINATIVE = "продвинутая тактическая аптечка",
        GENITIVE = "продвинутой тактической аптечки",
        DATIVE = "продвинутой тактической аптечке",
        ACCUSATIVE = "продвинутую тактическую аптечку",
        INSTRUMENTAL = "продвинутой тактической аптечкой",
        PREPOSITIONAL = "продвинутой тактической аптечке"
	)
	syndicate_aligned = TRUE

/obj/item/storage/firstaid/tactical/populate_contents()
	new /obj/item/defibrillator/compact/loaded(src)
	new /obj/item/reagent_containers/applicator/dual/syndi(src) // Because you ain't got no time to look at what damage dey taking yo
	new /obj/item/reagent_containers/hypospray/combat(src)
	new /obj/item/clothing/glasses/hud/health/night(src)

/obj/item/storage/firstaid/tactical/empty/populate_contents()
	return

/obj/item/storage/firstaid/ertm
	name = "NT ert-aid kit"
	desc = "Тактическая аптечка, содержащая в себе всё самое необходимое для лечения в пылу боя. Продвинутая версия."
	ru_names = list(
        NOMINATIVE = "продвинутая тактическая аптечка НТ",
        GENITIVE = "продвинутой тактической аптечки НТ",
        DATIVE = "продвинутой тактической аптечке НТ",
        ACCUSATIVE = "продвинутую тактическую аптечку НТ",
        INSTRUMENTAL = "продвинутой тактической аптечкой НТ",
        PREPOSITIONAL = "продвинутой тактической аптечке НТ"
	)
	icon_state = "NTertaid"
	max_w_class = WEIGHT_CLASS_NORMAL
	treatment_oxy = "perfluorodecalin"
	treatment_brute = "bicaridine"
	treatment_fire = "kelotane"
	treatment_tox = "charcoal"
	med_bot_skin = "bezerk"

/obj/item/storage/firstaid/ertm/populate_contents()
	new /obj/item/reagent_containers/hypospray/ertm/hydrocodone(src)
	new /obj/item/reagent_containers/hypospray/ertm/perfluorodecalin(src)
	new /obj/item/reagent_containers/hypospray/ertm/pentic_acid(src)
	new /obj/item/reagent_containers/hypospray/ertm/epinephrine(src)
	new	/obj/item/reagent_containers/hypospray/ertm/mannitol(src)
	new /obj/item/reagent_containers/hypospray/ertm/oculine(src)
	new /obj/item/reagent_containers/hypospray/ertm/omnisal(src)

/obj/item/storage/firstaid/syndie
	name = "first-aid tacticool kit"
	desc = "Тактическая аптечка, содержащая в себе всё самое необходимое для лечения в пылу боя. Узкоспециализированная версия."
	ru_names = list(
        NOMINATIVE = "тактическая аптечка",
        GENITIVE = "тактической аптечки",
        DATIVE = "тактической аптечке",
        ACCUSATIVE = "тактическую аптечку",
        INSTRUMENTAL = "тактической аптечкой",
        PREPOSITIONAL = "тактической аптечке"
	)
	icon_state = "bezerk"
	max_w_class = WEIGHT_CLASS_NORMAL
	treatment_oxy = "perfluorodecalin"
	treatment_brute = "bicaridine"
	treatment_fire = "kelotane"
	treatment_tox = "charcoal"
	req_access = list(ACCESS_SYNDICATE)
	med_bot_skin = "bezerk"
	syndicate_aligned = TRUE

/obj/item/storage/firstaid/syndie/populate_contents()
	new /obj/item/reagent_containers/hypospray/combat(src)
	new /obj/item/healthanalyzer/advanced(src)
	new /obj/item/reagent_containers/applicator/dual/syndi(src)
	new /obj/item/clothing/glasses/hud/health/night(src)

/obj/item/storage/firstaid/syndie/empty/populate_contents()
	return

/obj/item/storage/firstaid/surgery
	name = "field surgery kit"
	desc = "Тактическая версия спортивной сумки с медицинскими опознавательными знаками. Содержит в себе набор инструментов для полевой хирургии."
	ru_names = list(
        NOMINATIVE = "набор полевой хирургии",
        GENITIVE = "набора полевой хирургии",
        DATIVE = "набору полевой хирургии",
        ACCUSATIVE = "набор полевой хирургии",
        INSTRUMENTAL = "набором полевой хирургии",
        PREPOSITIONAL = "наборе полевой хирургии"
	)
	gender = MALE
	icon_state = "duffel-med"
	max_w_class = WEIGHT_CLASS_BULKY
	max_combined_w_class = 21
	storage_slots = 10
	can_hold = list(/obj/item/roller,/obj/item/bonesetter,/obj/item/bonegel, /obj/item/scalpel, /obj/item/hemostat,
		/obj/item/cautery, /obj/item/retractor, /obj/item/FixOVein, /obj/item/surgicaldrill, /obj/item/circular_saw)

/obj/item/storage/firstaid/surgery/populate_contents()
	new /obj/item/roller(src)
	new /obj/item/bonesetter(src)
	new /obj/item/bonegel(src)
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/cautery(src)
	new /obj/item/retractor(src)
	new /obj/item/FixOVein(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/circular_saw(src)

/obj/item/storage/firstaid/crew
	name = "crewmember first aid kit"
	desc = "Небольшого размера подсумок, содержащий в себе минимальный набор медикаментов для экстренных ситуаций. Выдаётся сотрудникам НаноТрейзен в обязательным порядке."
	ru_names = list(
        NOMINATIVE = "экстренная аптечка",
        GENITIVE = "экстренной аптечки",
        DATIVE = "экстренной аптечке",
        ACCUSATIVE = "экстренную аптечку",
        INSTRUMENTAL = "экстренной аптечкой",
        PREPOSITIONAL = "экстренной аптечке"
	)
	icon_state = "crew_medpouch"
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(/obj/item/reagent_containers/hypospray/autoinjector, /obj/item/reagent_containers/food/pill, /obj/item/stack/medical/bruise_pack, /obj/item/stack/medical/ointment)

/obj/item/storage/firstaid/crew/populate_contents()
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/salbutamol(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/charcoal(src)
	new /obj/item/reagent_containers/food/pill/patch/styptic(src)
	new	/obj/item/reagent_containers/food/pill/patch/silver_sulf(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)

/obj/item/storage/firstaid/crew/nucleation
	name = "nucleation first aid kit"
	desc = "Небольшого размера подсумок, содержащий в себе минимальный набор медикаментов для экстренных ситуаций. Специализированная версия для сотрудников НТ, подвергшихся «синдрому суперматериальной дисплазии»."
	ru_names = list(
        NOMINATIVE = "экстренная аптечка (Нуклеация)",
        GENITIVE = "экстренной аптечки (Нуклеация)",
        DATIVE = "экстренной аптечке (Нуклеация)",
        ACCUSATIVE = "экстренную аптечку (Нуклеация)",
        INSTRUMENTAL = "экстренной аптечкой (Нуклеация)",
        PREPOSITIONAL = "экстренной аптечке (Нуклеация)"
	)

/obj/item/storage/firstaid/crew/nucleation/populate_contents()
	new /obj/item/reagent_containers/hypospray/autoinjector/radium(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/charcoal(src)
	new /obj/item/reagent_containers/food/pill/patch/styptic(src)
	new	/obj/item/reagent_containers/food/pill/patch/silver_sulf(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)

/*
 * Pill Bottles
 */

/obj/item/storage/pill_bottle
	name = "pill bottle"
	desc = "Герметичный стеклянный флакон, предназначенный для хранения таблеток."
	ru_names = list(
        NOMINATIVE = "пузырёк для таблеток",
        GENITIVE = "пузырька для таблеток",
        DATIVE = "пузырьку для таблеток",
        ACCUSATIVE = "пузырёк для таблеток",
        INSTRUMENTAL = "пузырьком для таблеток",
        PREPOSITIONAL = "пузырьке для таблеток"
	)
	gender = MALE
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	belt_icon = "pill_bottle"
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(/obj/item/reagent_containers/food/pill)
	cant_hold = list(/obj/item/reagent_containers/food/pill/patch)
	allow_quick_gather = TRUE
	use_to_pickup = TRUE
	storage_slots = 50
	max_combined_w_class = 50
	display_contents_with_number = TRUE
	pickup_sound = 'sound/items/handling/pillbottle_pickup.ogg'
	drop_sound = 'sound/items/handling/pillbottle_drop.ogg'
	var/base_name = ""
	var/label_text = ""
	var/applying_meds = FALSE //To Prevent spam clicking and generating runtimes from apply a deleting pill multiple times.
	/// Whether to render a coloured wrapper overlay on the icon.
	var/allow_wrap = TRUE
	/// The color of the wrapper overlay.
	var/wrapper_color = null
	/// The icon state of the wrapper overlay.
	var/wrapper_state = "pillbottle_wrap"

/obj/item/storage/pill_bottle/Initialize(mapload)
	. = ..()
	base_name = name
	if(allow_wrap)
		apply_wrap()


/obj/item/storage/pill_bottle/proc/apply_wrap()
	if(wrapper_color)
		cut_overlays()
		var/image/I = image(icon, wrapper_state)
		I.color = wrapper_color
		add_overlay(I)
		if(blocks_emissive)
			add_overlay(get_emissive_block())


/obj/item/storage/pill_bottle/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!iscarbon(target) || !length(contents))
		return ..()

	. = ATTACK_CHAIN_PROCEED

	// we pick random pill/patch and try to feed it
	var/obj/item/reagent_containers/food/pill/pill = locate() in contents
	if(pill)
		return pill.attack(target, user, params, def_zone, skip_attack_anim)


/obj/item/storage/pill_bottle/ert
	wrapper_color = COLOR_MAROON

/obj/item/storage/pill_bottle/ert/populate_contents()
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/charcoal(src)
	new /obj/item/reagent_containers/food/pill/charcoal(src)
	new /obj/item/reagent_containers/food/pill/charcoal(src)


/obj/item/storage/pill_bottle/MouseDrop(mob/living/carbon/user, src_location, over_location, src_control, over_control, params) // Best utilized if you're a cantankerous doctor with a Vicodin habit.
	if(iscarbon(user) && src == user.get_active_hand() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(!length(contents))
			balloon_alert(user, "пусто!")
			return FALSE

		user.visible_message(span_danger("[user] открыва[pluralize_ru(user.gender, "ет", "ют")] крышку [declent_ru(GENITIVE)] и начина[pluralize_ru(user.gender, "ет", "ют")] глотать содержимое!"))
		if(!do_after(user, 10 SECONDS, user, NONE) || src != user.get_active_hand())
			return FALSE

		for(var/obj/item/reagent_containers/food/pill/pill in src)
			pill.attack(user, user)
		user.visible_message(span_danger("[user] проглатыва[pluralize_ru(user.gender, "ет", "ют")] всё содержимое [declent_ru(GENITIVE)] за раз!"))
		return FALSE

	return ..()


/obj/item/storage/pill_bottle/attackby(obj/item/I, mob/user, params)
	if(is_pen(I) || istype(I, /obj/item/flashlight/pen))
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/item/storage/pill_bottle/patch_pack
	name = "patch pack"
	desc = "Небольшой коробок, предназначенный для хранения медицинских пластырей."
	ru_names = list(
        NOMINATIVE = "коробок для таблеток",
        GENITIVE = "коробка для пластырей",
        DATIVE = "коробку для пластырей",
        ACCUSATIVE = "коробок для пластырей",
        INSTRUMENTAL = "коробком для пластырей",
        PREPOSITIONAL = "коробке для пластырей"
	)
	icon_state = "patch_pack"
	belt_icon = "patch_pack"
	can_hold = list(/obj/item/reagent_containers/food/pill/patch)
	cant_hold = list()
	wrapper_state = "patch_pack_wrap"

/obj/item/storage/pill_bottle/patch_pack/filled/populate_contents()
	for(var/I in 1 to 10)
		new /obj/item/reagent_containers/food/pill/patch/silver_sulf(src)

	for(var/I in 1 to 10)
		new /obj/item/reagent_containers/food/pill/patch/styptic(src)


/obj/item/storage/pill_bottle/patch_pack/MouseDrop(mob/living/carbon/user, src_location, over_location, src_control, over_control, params) // Best utilized if you're a cantankerous doctor with a Vicodin habit.
	if(iscarbon(user) && src == user.get_active_hand() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(!length(contents))
			balloon_alert(user, "пусто!")
			return FALSE

		user.visible_message(span_danger("[user] откиды[pluralize_ru(user.gender, "ет", "ют")] крышку [declent_ru(GENITIVE)] и начина[pluralize_ru(user.gender, "ет", "ют")] стремительно клеить пластыри оттуда на свою кожу!"))
		if(!do_after(user, 10 SECONDS, user, NONE) || src != user.get_active_hand())
			return FALSE

		for(var/obj/item/reagent_containers/food/pill/pill in src)
			pill.attack(user, user)
		user.visible_message(span_danger("[user] обклеива[pluralize_ru(user.gender, "ет", "ют")] себя всеми пластырями, которые были в [declent_ru(PREPOSITIONAL)]!"))
		return FALSE

	return ..()

/obj/item/storage/pill_bottle/bluespace
	name = "advanced drug storage"
	desc = "Технологичное устройство на основе блюспейс-технологий, предназначенное для хранения пластырей и таблеток."
	ru_names = list(
        NOMINATIVE = "блюспейс-хранилище для лекарств",
        GENITIVE = "блюспейс-хранилищя для лекарств",
        DATIVE = "блюспейс-хранилищу для лекарств",
        ACCUSATIVE = "блюспейс-хранилище для лекарств",
        INSTRUMENTAL = "блюспейс-хранилищем для лекарств",
        PREPOSITIONAL = "блюспейс-хранилище для лекарств"
	)
	gender = NEUTER
	storage_slots = 100
	max_combined_w_class = 100
	can_hold = list(/obj/item/reagent_containers/food/pill)
	cant_hold = list()
	icon_state = "adv_drug_storage"
	item_state = "adv_drug_storage"
	belt_icon = null
	allow_wrap = FALSE
	origin_tech = "materials=2;bluespace=1;biotech=1;plasmatech=1"

/obj/item/storage/pill_bottle/charcoal
	name = "Pill bottle (Charcoal)"
	desc = "Герметичный стеклянный флакон, предназначенный для хранения таблеток. Заполнен таблетками с активированным углём."
	ru_names = list(
        NOMINATIVE = "пузырёк для таблеток (Активированный уголь)",
        GENITIVE = "пузырька для таблеток (Активированный уголь)",
        DATIVE = "пузырьку для таблеток (Активированный уголь)",
        ACCUSATIVE = "пузырёк для таблеток (Активированный уголь)",
        INSTRUMENTAL = "пузырьком для таблеток (Активированный уголь)",
        PREPOSITIONAL = "пузырьке для таблеток (Активированный уголь)"
	)
	wrapper_color = COLOR_GREEN

/obj/item/storage/pill_bottle/charcoal/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/reagent_containers/food/pill/charcoal(src)

/obj/item/storage/pill_bottle/painkillers
	name = "Pill Bottle (Salicylic Acid)"
	desc = "Герметичный стеклянный флакон, предназначенный для хранения таблеток. Заполнен таблетками с салициловой кислотой."
	ru_names = list(
        NOMINATIVE = "пузырёк для таблеток (Салициловая кислота)",
        GENITIVE = "пузырька для таблеток (Салициловая кислота)",
        DATIVE = "пузырьку для таблеток (Салициловая кислота)",
        ACCUSATIVE = "пузырёк для таблеток (Салициловая кислота)",
        INSTRUMENTAL = "пузырьком для таблеток (Салициловая кислота)",
        PREPOSITIONAL = "пузырьке для таблеток (Салициловая кислота)"
	)
	wrapper_color = COLOR_RED

/obj/item/storage/pill_bottle/painkillers/populate_contents()
	for(var/I in 1 to 8)
		new /obj/item/reagent_containers/food/pill/salicylic(src)

/obj/item/storage/pill_bottle/fakedeath
	allow_wrap = FALSE

/obj/item/storage/pill_bottle/fakedeath/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/reagent_containers/food/pill/fakedeath(src)
