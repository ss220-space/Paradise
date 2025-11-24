//Based

/obj/effect/mob_spawn/human/hermit
	name = "emergency cryostasis sleeper"
	desc = "Гудящая криокапсула с силуэтом гуманоида внутри."
	gender = FEMALE
	mob_name = "a stranded hermit"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "bodyscanner"
	roundstart = FALSE
	death = FALSE
	allow_species_pick = TRUE
	allow_prefs_prompt = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	outfit = /datum/outfit/hermit
	mob_species = /datum/species/human
	description = "Вы — выживший, застрявший на Лаваленде в аварийном шаттле. Корабль это якорь вашего выживания, он потребляет ресурсы, конвертирует их, а ещё его можно починить. Эта роль для тех, кто хочет получить иной опыт от игры, отличный от станционного."
	flavour_text = "Вы застряли на этой безбожной планете дольше, чем планировали. Каждый день вы занимаетесь рутинными, уже ставшими ритуалом делами. Осталось совсем чуть чуть и ваш \
	корабль наконец взлетит. Эти мысли развеиваются очередным воспоминанием о том, как вы сюда попали...\n"
	assignedrole = "Hermit"

/obj/effect/mob_spawn/human/hermit/get_ru_names()
	return list(
		NOMINATIVE = "аварийная капсула криостазиса"
		GENITIVE = "аварийной капсулы криостазиса"
		DATIVE = "аварийной капсуле криостазиса"
		ACCUSATIVE = "аварийную капсулу криостазиса"
		INSTRUMENTAL = "аварийной капсулой криостазиса"
		PREPOSITIONAL = "аварийной капсуле криостазиса"
	)

/datum/outfit/hermit
	name = "Lavaland Survivor"

/obj/effect/mob_spawn/human/hermit/Initialize(mapload)
	. = ..()
	var/arrpee = rand(1,4)
	switch(arrpee)
		if(1)
			flavour_text += "Вы были торговцем с Бизель. Запах сварочной плазмы, смешанный с ароматом специй из портовых кафе. \
			Гул тяжёлых грузовиков, плывущих между ангарами. Бизель был не планетой, а пульсирующим узлом, местом, где царил строгий коррумпированный порядок. \
			Сделки заключались в тишине кабинетов, а безопасность обеспечивали частные армии с ТСФ. \
			Заказ казался рядовым — доставить чертежи на окраину системы. Условия были просты: никаких вопросов, двойная ставка. \
			Вы приняли его, как и десятки других. И теперь за вами охотятся. Вы чудом сбежали на этом утлом спасательном челноке. \
			Эти чертежи с вами — смертный приговор. Но это и ваш единственный шанс. Найдите покупателя в этом секторе и сбыйте его с рук, \
			желательно за 20 000 кредитов или больше. Этой суммы будет достаточно чтобы \"стереть свой след\" в этой истории."
			outfit.glasses = /obj/item/clothing/glasses/sunglasses/big
			outfit.mask = /obj/item/clothing/mask/cigarette/menthol
			outfit.uniform = /obj/item/clothing/under/solgov/civ
			outfit.shoes = /obj/item/clothing/shoes/leather
			outfit.back = /obj/item/storage/backpack/satchel/hermit
			outfit.belt = /obj/item/melee/baton
			outfit.l_pocket = /obj/item/lighter/zippo
			outfit.r_pocket = /obj/item/radio/hermit/trade
			outfit.id = /obj/item/card/id/away/hermit/trade
		if(2)
			flavour_text += "Вы были инженером проектировщиком на экспериментальной фабрике \"Системы Энштейна\". Вы работали над проектом \"Прометей\" — новым типом термоядерного \
			двигателя, который должен был дать второй шанс ядерной энергетики показать себя. Вы были горды за свои достижения, пока не увидели итоговый отчёт о стабильности. \
			Цифры не сходились. Реакция была не контролируема, она была осуждена на катастрофу. Вы возмутились, но вам вежливо предложили \"не вмешиваться не в своё дело\". \
			Вы можно было подумать были уже готовы уйти, но оказалось, что теперь ваши разработки были переписаны под их \"кооперативную собственность\", вы более не владели своим изобретением. \
			Тогда вы приняли решение, на презентации вопреки закону вы выгрузили все свои разработки на диск и скрылись, вас сражу же объявили вором, и несостоявшемся сотруднике что хочет заполучить всю славу себе, \
			все ваши достижения были вычеркнуты из истории компании. Вы заложили всё своё имущество чтобы выкупить этот аварийный шаттл и улететь туда где вам и вашим исследованиям никто не помешает. \
			Закончите свой проект и попытайтесь найти инвесторов на стороне. Войдите в историю."
			outfit.glasses = /obj/item/clothing/glasses/welding/superior
			outfit.mask = /obj/item/clothing/mask/gas
			outfit.uniform = /obj/item/clothing/under/rank/miner
			outfit.shoes = /obj/item/clothing/shoes/magboots/hermit
			outfit.back = /obj/item/storage/backpack/industrial/hermit
			outfit.belt = /obj/item/crowbar/power
			outfit.r_pocket = /obj/item/reagent_containers/food/drinks/oilcan/full
			outfit.id = /obj/item/card/id/away/hermit/einstein_engine
		if(3)
			flavour_text += "Вы были старшим медицинским специалистом на ИСН \"Ананси\". Официально — вы лечили больных с колоний и ближайших судов. \
			Неофициально — вы были смотрителем для \"испытуемых\" каторжников с Рида, по делу психологической и физической устойчивости к местной флоре. \
			Вы закрывали на это глаза, пока в одну из смен не увидели, как от нового препарата человек не разложился изнутри. Вы не смогли молчать. \
			И в тот же миг вы превратились в мишень. Пользуясь репутацией и полномочиями вы смогли выкрасть документы из архива и сбежать на спасательной капсуле. \
			После чего \"Ананси\" объявили вас психически нестабильным деструктивным элементом. Теперь у вас в кармане информационная бомба, компромат, \
			способный потрясти одну из самых могущественных корпораций. Они сделают всё, чтобы вы никогда не достигли цивилизованного пространства. \
			Вы должны выжить и обнародовать правду через представителей и посольство нейтральных сторон."
			outfit.glasses = /obj/item/clothing/glasses/hud/health/sunglasses
			outfit.mask = /obj/item/clothing/mask/breath/medical
			outfit.uniform = /obj/item/clothing/under/rank/chief_medical_officer
			outfit.shoes = /obj/item/clothing/shoes/white
			outfit.back = /obj/item/storage/backpack/satchel_med/hermit
			outfit.belt = /obj/item/storage/belt/medical
			outfit.r_pocket = /obj/item/melee/baton/telescopic
			outfit.neck = /obj/item/clothing/neck/cloak/chief_medical_officer
			outfit.id = /obj/item/card/id/away/hermit/medic
		if(4)
			flavour_text += "Вы были осуждённым каторжником на Риде. Рид — это ад  вырезанный из льда и камня. Вы отбывали срок за преступление, которого не помните, \
			на рудниках, где срок измеряется не годами, а количеством породы, которую вы поднимаете на поверхность. Побег был безумием. Шанс выжить в ледяной пустоши — нулевой. \
			Но лучше умереть свободным, чем сгнить заживо. Вы организовали бунт. Пока охранники отбивались от обезумевших зеков, вы пробились в ангар. \
			Этот шаттл — ваша украденная свобода. Вы рванули вперёд, не глядя на координаты, лишь бы подальше от этого места. Теперь вы один, с клеймом беглого каторжника. \
			Но вы свободны. И будете драться за эту свободу до конца, зубами и когтями."
			outfit.glasses = /obj/item/clothing/glasses/welding
			outfit.mask = /obj/item/clothing/mask/gas
			outfit.uniform = /obj/item/clothing/under/color/orange
			outfit.shoes = /obj/item/clothing/shoes/workboots
			outfit.back = /obj/item/storage/backpack/explorer
			outfit.belt = /obj/item/pickaxe/drill/jackhammer
			outfit.l_pocket = /obj/item/reagent_containers/food/drinks/flask/thermos

/obj/effect/mob_spawn/human/hermit/Destroy()
	new /obj/machinery/bodyscanner/hermit(get_turf(src))
	return ..()

/obj/effect/mob_spawn/human/hermit/special(mob/living/carbon/human/H)
	GLOB.human_names_list += H.real_name
	return ..()

/obj/machinery/bodyscanner/hermit
	name = "empty cryostasis sleeper"
	desc = "Сложное медицинское устройство, используется для сканирования физического состояния гуманоидов и поддержанию их в состоянии криосна."

//////////////
//MARK: UNIQ EQUIPMENT
//////////////

/obj/item/documents/hermit
	name = "documents marked \"CORPORATE SECRET\""

/obj/item/documents/hermit/get_ru_names()
	return list(
		NOMINATIVE = "документы с грифом КОРПОРАТИВНАЯ ТАЙНА",
		GENITIVE = "документов с грифом КОРПОРАТИВНАЯ ТАЙНА",
		DATIVE = "документам с грифом КОРПОРАТИВНАЯ ТАЙНА",
		ACCUSATIVE = "документы с грифом КОРПОРАТИВНАЯ ТАЙНА",
		INSTRUMENTAL = "документами с грифом КОРПОРАТИВНАЯ ТАЙНА",
		PREPOSITIONAL = "документах с грифом КОРПОРАТИВНАЯ ТАЙНА"
	)

//Trade

/obj/item/radio/hermit/trade
	name = "tactical shortwave radio"
	desc = "портативная рация, способная взаимодействовать с локальными телекоммуникационными сетями. При близком рассмотрении становится понятно что это дешёвый ширпотреб в красивой обёртке."
	icon_state = "walkietalkie_sec"
	item_state = "walkietalkie_sec"

/obj/item/radio/hermit/trade/get_ru_names()
	return list(
		NOMINATIVE = "тактическая коротковолновая рация",
		GENITIVE = "тактической коротковолновой рации",
		DATIVE = "тактической коротковолновой рации",
		ACCUSATIVE = "тактическую коротковолновую рацию",
		INSTRUMENTAL = "тактической коротковолновой рацией",
		PREPOSITIONAL = "тактической коротковолновой рации"
	)

/obj/item/storage/backpack/satchel/hermit
	name = "leather briefcase"
	desc = "Портфель на лямке из толстой дублёной кожи, с потёртостями, не первой молодости, но безупречно ухоженный. На нём тисненая символика солнечной гвардии."

/obj/item/storage/backpack/satchel/hermit/get_ru_names()
	return list(
		NOMINATIVE = "кожаный портфель",
		GENITIVE = "кожаного портфеля",
		DATIVE = "кожаному портфелю",
		ACCUSATIVE = "кожаный портфель",
		INSTRUMENTAL = "кожаным портфелем",
		PREPOSITIONAL = "кожаном портфеле"
	)

/obj/item/storage/backpack/satchel/hermit/populate_contents()
	new /obj/item/documents/hermit/shellguard(src)

/obj/item/card/id/away/hermit/trade
	name = "biesel certificate"
	desc = "Удостоверение о разрешении торговых операций на объектах \"Бизель\". Действительна до 2570 года."
	icon_state = "centcom"
	item_state = "centcom"
	access = list(10, 11, 160)

/obj/item/card/id/away/hermit/trade/get_ru_names()
	return list(
		NOMINATIVE = "сертификат с Бизель",
		GENITIVE = "сертификата с Бизель",
		DATIVE = "сертификату с Бизель",
		ACCUSATIVE = "сертификат с Бизель",
		INSTRUMENTAL = "сертификатом с Бизель",
		PREPOSITIONAL = "сертификате с Бизель"
	)

/obj/item/documents/hermit/shellguard
	name = "documents SG marked \"CORPORATE SECRET\""
	desc = "\"Совершенно секретные\" документы корпорации \"Стальная Гвардия\", напечатанные на специальной бумаге, защищенной от копирования. Эти документы содержат технические характеристики, чертежи и подробности о новейших импульсных винтовках основанных на химических кислородно йодных лазерах. Эти бумаги содержат превосходные оружейные данные!"
	icon_state = "docs_red"
	sell_multiplier = 1
	sell_interest = ALL
	origin_tech = "combat=7;engineering=5"


//Eng

/obj/item/clothing/shoes/magboots/hermit
	name = "retro magboots"
	desc = "Магнитные ботинки от корпорации \"Системы Энштейна\" выполненые в старом стиле со всеми нюансами. Они не такие удобные как современные модели, но надёжности им не занимать."
	slowdown_active = SHOES_SLOWDOWN
	active_traits = list(TRAIT_NEGATES_GRAVITY, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_SLIDE, TRAIT_GUSTPROTECTION)
	slowdown_active = 3
	armor = list(MELEE = 30, BULLET = 5, LASER = 5, ENERGY = 30, BOMB = 30, BIO = 0, RAD = 30, FIRE = 90, ACID = 0)
	origin_tech = "magnets=2;engineering=3"

/obj/item/clothing/shoes/magboots/hermit/get_ru_names()
	return list(
		NOMINATIVE = "старые магнитные ботинки",
		GENITIVE = "старых магнитных ботинок",
		DATIVE = "старым магнитным ботинкам",
		ACCUSATIVE = "старые магнитные ботинки",
		INSTRUMENTAL = "старыми магнитными ботинками",
		PREPOSITIONAL = "старых магнитных ботинках"
	)

/obj/item/storage/backpack/industrial/hermit

/obj/item/storage/backpack/industrial/hermit/populate_contents()
	new /obj/item/documents/hermit/einstein_engine(src)

/obj/item/card/id/away/hermit/einstein_engine
	name = "Level 3 access card"
	desc = "Ключ карта среднего доступа на объектах \"Системы Энштейна\"."
	icon_state = "guest"
	item_state = "guestpass—id"
	access = list(10, 11, 32)

/obj/item/card/id/away/hermit/einstein_engine/get_ru_names()
	return list(
		NOMINATIVE = "ключ—карта 3 уровня",
		GENITIVE = "ключ—карты 3 уровня",
		DATIVE = "ключ—карте 3 уровня",
		ACCUSATIVE = "ключ—карту 3 уровня",
		INSTRUMENTAL = "ключ—картой 3 уровня",
		PREPOSITIONAL = "ключ—карте 3 уровня"
	)

/obj/item/documents/hermit/einstein_engine
	name = "documents EI marked \"CORPORATE SECRET\""
	desc = "\"Совершенно секретные\" документы корпорации \"Системы Энштейна\", напечатанные на специальной бумаге, защищенной от копирования. Эти документы содержат технические характеристики, чертежи проекта \"Прометей\". Эти бумаги могут сильно ударить по активам НаноТрайзен и всех причастных к её плазменной промышленности. Тут... Есть печати ТСФ и СССП?"
	icon_state = "docs_red"
	sell_multiplier = 1
	sell_interest = list(INTEREST_SYNDICATE, INTEREST_NANOTRASEN)
	origin_tech = "engineering=7;power=6"


//Med

/obj/item/storage/backpack/satchel_med/hermit

/obj/item/storage/backpack/satchel_med/hermit/populate_contents()
	new /obj/item/documents/hermit/medical(src)

/obj/item/card/id/away/hermit/medic
	name = "senior medical specialist ID"
	desc = "Карточка, используемая для идентификации личности и доступа на ИСН \"Ананси\"."
	icon_state = "CMO"
	item_state = "CMO"
	access = list(5, 6, 45, 33, 39, 9, 76)

/obj/item/card/id/away/hermit/medic/get_ru_names()
	return list(
		NOMINATIVE = "ID—карта старшего медицинского специалиста",
		GENITIVE = "ID—карты старшего медицинского специалиста",
		DATIVE = "ID—карте старшего медицинского специалиста",
		ACCUSATIVE = "ID—карту старшего медицинского специалиста",
		INSTRUMENTAL = "ID—картой старшего медицинского специалиста",
		PREPOSITIONAL = "ID—карте старшего медицинского специалиста"
	)

/obj/item/documents/hermit/medical
	name = "documents NT marked \"CORPORATE SECRET\""
	desc = "\"Совершенно секретные\" архивные документы корпорации \"Нанотрейзен\", напечатанные на специальной бумаге, защищенной от копирования. Здесь содержится компоментирующая информация о неэтичных опытах над преступниками со всеми подробностями. Подписаны как вторым красным крестом, так и \"Нанотрейзен\"."
	icon_state = "docs_verified"
	sell_multiplier = 1
	sell_interest = list(INTEREST_SYNDICATE, INTEREST_NANOTRASEN)

//////////////////////////
//MARK: RANDOM SPAWNER
//////////////////////////

/obj/effect/spawner/hermit_random_structure
	name = "random_structure"
	icon = 'icons/misc/landmarks.dmi'
	icon_state = "standart"

/obj/effect/spawner/hermit_random_structure/Initialize(mapload)
	. = ..()
	var/static/list/possible_objects = list(
		/obj/structure/reagent_dispensers/watertank = 100,
		/obj/structure/reagent_dispensers/fueltank = 100,
		/obj/machinery/portable_atmospherics/canister = 100,
		/obj/machinery/portable_atmospherics/canister/air = 100,
		/obj/machinery/portable_atmospherics/canister/carbon_dioxide = 100,
		/obj/machinery/portable_atmospherics/canister/custom_mix = 100,
		/obj/machinery/portable_atmospherics/canister/oxygen = 25,
		/obj/machinery/portable_atmospherics/canister/nitrogen = 100,
		/obj/machinery/portable_atmospherics/canister/sleeping_agent = 100,
		/obj/machinery/portable_atmospherics/canister/toxins = 100,
		/obj/machinery/portable_atmospherics/pump = 100,
		/obj/machinery/portable_atmospherics/scrubber = 100,
		/obj/machinery/space_heater = 100,
		/obj/machinery/field/generator = 50,
		/obj/machinery/floodlight = 100,
		/obj/machinery/shieldgen = 50,
		/obj/machinery/power/emitter = 25,
		/obj/machinery/power/tesla_coil = 100,
		/obj/machinery/power/grounding_rod = 100,
		/obj/structure/reagent_dispensers/oil = 100
	)
	var/chosen_type = pickweight(possible_objects)
	new chosen_type(loc)

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/hermit_random_sleeper
	name = "random_sleeper"
	icon = 'icons/misc/landmarks.dmi'
	icon_state = "standart"

/obj/effect/spawner/hermit_random_sleeper/Initialize(mapload)
	. = ..()
	var/choice = rand(1, 100)
	if(choice <= 25)
		new /obj/machinery/sleeper(loc)
	else if(choice <= 90)
		new /obj/machinery/constructable_frame/machine_frame(loc)
		new /obj/item/circuitboard/sleeper(loc)
	else
		new /obj/machinery/sleeper/upgraded(loc)

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/hermit_random_firstaid
	name = "random_firstaid"
	icon = 'icons/misc/landmarks.dmi'
	icon_state = "standart"

/obj/effect/spawner/hermit_random_firstaid/Initialize(mapload)
	. = ..()
	var/static/list/firstaid_kits = list(
		/obj/item/storage/firstaid,
		/obj/item/storage/firstaid/brute,
		/obj/item/storage/firstaid/fire,
		/obj/item/storage/firstaid/o2,
		/obj/item/storage/firstaid/tactical,
		/obj/item/storage/firstaid/toxin,
		/obj/item/storage/firstaid/with_mousetrap,
		/obj/item/storage/firstaid/with_mousetrap/tactical,
		/obj/item/storage/firstaid/machine,
		/obj/item/storage/firstaid/surgery,
		/obj/item/storage/firstaid/regular
	)
	var/chosen_type = pick(firstaid_kits)
	new chosen_type(loc)

	return INITIALIZE_HINT_QDEL

//////////////////////////
//MARK:SHIP
//////////////////////////

//Radiostation

/obj/item/radio/hermit
	name = "radio"
	gender = MALE
	desc = "Блок радиосвязи, конструкция не приспособлена к ношению."
	icon = 'icons/obj/robot_component.dmi'
	item_state = "cell"
	icon_state = "radio"
	belt_icon = "emergency_syndi"
	materials = list(MAT_METAL=150)

/obj/item/radio/intercom/hermit
	name = "rack—mounted intercom"
	desc = "Автономный модуль связи. Выполняющий функции бортового самописца и радио приёмника."
	icon = 'icons/obj/machines/computer3.dmi'
	icon_state = "rackframe"
	density = TRUE
	circuitry_installed = FALSE

/obj/item/radio/intercom/hermit/get_ru_names()
	ru_names = list(
		NOMINATIVE = "автономный модуль связи",
		GENITIVE = "автономного модуля связи",
		DATIVE = "автономному модулю связи",
		ACCUSATIVE = "автономный модуль связи",
		INSTRUMENTAL = "автономным модулем связи",
		PREPOSITIONAL = "автономном модуле связи",
	)

/obj/item/radio/intercom/rackmounted/Initialize(mapload, direction, buildstage = 2)
	. = ..()
	update_icon()

/obj/item/radio/intercom/hermit/update_icon_state()
	icon_state = "rackframe"

/obj/item/radio/intercom/hermit/update_overlays()
	. = ..()
	underlays.Cut()

/obj/item/radio/intercom/hermit/Destroy()
	return ..()

/obj/item/radio/intercom/hermit/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	user.visible_message("<span class='warning'>[user] начинает разбирать [src].</span>", "<span class='notice'>Начинаю разбирать [src]...</span>")
	if(I.use_tool(src, user, 30, volume=50))
		deconstruct(TRUE)

/obj/item/radio/intercom/hermit/crowbar_act(mob/user, obj/item/I)
	attackby(I, user)
	return TRUE

/obj/item/radio/intercom/hermit/screwdriver_act(mob/user, obj/item/I)
	attackby(I, user)
	return TRUE

/obj/item/radio/intercom/hermit/wirecutter_act(mob/user, obj/item/I)
	attackby(I, user)
	return TRUE

/obj/item/radio/intercom/hermit/welder_act(mob/user, obj/item/I)
	attackby(I, user)
	return TRUE

/obj/item/radio/intercom/hermit/deconstruct(disassembled = TRUE)
	if(!loc)
		return
	new /obj/item/broken_device(drop_location())
	new /obj/item/circuitboard/broken(drop_location())
	new /obj/item/radio/hermit(drop_location())
	new /obj/machinery/constructable_frame/machine_frame(drop_location())
	qdel(src)

//Computer

/obj/machinery/computer/shuttle/autumn
	name = "Autumn BEES console"
	desc = "Используется для управления шаттлом \"Осень\"."
	req_access = list(ACCESS_HERMIT_AUTUMN)
	circuit = /obj/item/circuitboard/shuttle/autumn
	shuttleId = "autumn"
	possible_destinations = "autumn_lavaland;autumn_space;autumn_hotel;autumn_ipc"

/obj/item/circuitboard/shuttle/autumn
	board_name = "Autumn BEES Ship"
	build_path = /obj/machinery/computer/shuttle/autumn

/area/shuttle/hermit/autumn
	name = "Autumn BEES"
	icon_state = "away"

//Door

/obj/effect/spawner/airlock/w_to_e/long/square/hermit
	required_access = list(ACCESS_HERMIT_AUTUMN)

//Safe

/obj/item/storage/secure/safe/hermit/autumn

/obj/item/storage/secure/safe/hermit/autumn/populate_contents()
	new /obj/item/card/id/away/hermit/autumn(src)
	new /obj/item/pda/hermit/autumn(src)
	new /obj/item/areaeditor/create_area_only/hermit/autumn(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/craft_blueprints/hermit/autumn(src)

//Camera

/obj/machinery/computer/camera_advanced/hermit/autumn
	desc = "Используется для доступа к различным камерам, установленным на \"Autumn BEES\"."
	icon_keyboard = "accelerator_key"
	networks = list("Autumn")

//EVA

/obj/machinery/suit_storage_unit/hermit
	suit_type = /obj/item/clothing/suit/space/nasavoid
	helmet_type = /obj/item/clothing/head/helmet/space/nasavoid
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/jetpack/void
	req_access = list(ACCESS_HERMIT_AUTUMN)

//Pda and id

/obj/item/card/id/away/hermit/autumn
	name = "\"Autumn BEES\" Access Key"
	desc = "Криптографическая ключ карта для доступа к системам \"Autumn BEES\"."
	icon_state = "TDgreen"
	access = list(ACCESS_HERMIT_AUTUMN)

/obj/item/card/id/away/hermit/autumn/get_ru_names()
	ru_names = list(
		NOMINATIVE = "ключ—карта",
		GENITIVE = "ключ—карты",
		DATIVE = "ключ—карте",
		ACCUSATIVE = "ключ—карту",
		INSTRUMENTAL = "ключ—картой",
		PREPOSITIONAL = "ключ—карте",
	)

/obj/item/pda/hermit/autumn
	name = "\"Autumn BEES\" PDA"
	default_cartridge = /obj/item/cartridge/engineering
	icon_state = "pda—engineer"
	desc = "Специализированный карманный компьютер \"Autumn BEES\". Привязан к кораблю."
	model_name = "Backup Emergency Evacuation Shuttle OS"
	owner = "Autumn BEES"

//Blueprints

/obj/item/areaeditor/create_area_only/hermit/autumn
	station_name_overrride = "Autumn BEES"
	fluffnotice = "Чертежи эвакуационного шаттла \"Осень\". Есть штамп о проведённом техническом осмотре."

/obj/item/craft_blueprints/hermit/autumn
	name = "\"Autumn BEES\" circuitboard blueprints"
	desc = "Рукописные чертежи на специальной бумаге, это схема какого—то компьютера."
	crafting_name = "платы консоли управления"
	crafting_item = /obj/item/circuitboard/shuttle/autumn
	tools = list(TOOL_WELDER, TOOL_MULTITOOL)
	components = list(
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/plastic = 5,
		/obj/item/gem/ruby = 1,
	)

/obj/item/craft_blueprints/hermit/autumn/get_ru_names()
	return list(
		NOMINATIVE = "чертежи платы",
		GENITIVE = "чертежей платы",
		DATIVE = "чертежам платы",
		ACCUSATIVE = "чертежи платы",
		INSTRUMENTAL = "чертежами платы",
		PREPOSITIONAL = "чертежах платы"
	)
