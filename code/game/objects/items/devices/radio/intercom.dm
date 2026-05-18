#define INTERCOM_BUILD_NO_CIRCUIT 0
#define INTERCOM_BUILD_CIRCUIT 1
#define INTERCOM_BUILD_WIRED 2
#define INTERCOM_BUILD_SECURED 3

// MARK: General
/obj/item/radio/intercom
	name = "station intercom (General)"
	desc = "Станционный интерком общего назначения. Представляет собой устройство из прочного полимерно-металлического корпуса \
			с передней панелью, оснащённой микрофоном, динамиком и дисплеем. Встроенное телекоммуникационное оборудование поддерживает \
			широкий диапазон приёма и передачи сигналов, обеспечивая двустороннюю связь по радиочастотам объекта."
	gender = MALE
	icon_state = "intercom_on"
	base_icon_state = "intercom"
	anchored = TRUE
	w_class = WEIGHT_CLASS_BULKY
	canhear_range = 2
	blocks_emissive = FALSE
	dog_fashion = null
	var/circuitry_installed = TRUE
	/// Current buildstage of the object
	var/buildstage = INTERCOM_BUILD_NO_CIRCUIT

/obj/item/radio/intercom/get_ru_names()
	return list(
		NOMINATIVE = "станционный интерком (Общий)",
		GENITIVE = "станционного интеркома (Общий)",
		DATIVE = "станционному интеркому (Общий)",
		ACCUSATIVE = "станционный интерком (Общий)",
		INSTRUMENTAL = "станционным интеркомом (Общий)",
		PREPOSITIONAL = "станционном интеркоме (Общий)",
	)

/obj/item/radio/intercom/Initialize(mapload, direction, buildstage = INTERCOM_BUILD_SECURED)
	. = ..()
	src.buildstage = buildstage
	if(buildstage)
		update_operating_status()
	else
		if(direction)
			setDir(direction)
			set_pixel_offsets_from_dir(28, -28, 28, -28)
		b_stat = TRUE
		set_on(FALSE)
	GLOB.global_intercoms |= src
	update_icon()

/obj/item/radio/intercom/Destroy()
	GLOB.global_intercoms -= src
	return ..()

/obj/item/radio/intercom/attack_ai(mob/user)
	add_hiddenprint(user)
	add_fingerprint(user)
	attack_self(user)

/obj/item/radio/intercom/attack_hand(mob/user)
	add_fingerprint(user)
	attack_self(user)

/obj/item/radio/intercom/receive_range(freq, level)
	if(!is_listening())
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		// TODO: Integrate radio with the space manager
		if(isnull(position) || !(position.z in level))
			return -1
	if(freq in SSradio.ANTAG_FREQS)
		if(!(syndiekey))
			return -1//Prevents broadcast of messages over devices lacking the encryption
	return canhear_range

/obj/item/radio/intercom/examine(mob/user)
	. = ..()
	switch(buildstage)
		if(INTERCOM_BUILD_NO_CIRCUIT)
			. += span_notice("Каркас <b>приварен</b> к стене, но в нём отсутствует <i>электронная плата</i>.")
		if(INTERCOM_BUILD_CIRCUIT)
			. += span_notice("Динамик необходимо <i>подключить</i>, а плату можно <b>вытащить</b>.")
		if(INTERCOM_BUILD_WIRED)
			. += span_notice("Интерком <b>подключён</b>, а сервисная панель <i>открыта</i>.")

/obj/item/radio/intercom/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/tape_roll)) //eww
		return ATTACK_CHAIN_BLOCKED_ALL
	if(user.a_intent == INTENT_HARM)
		return ..()
	switch(buildstage)
		if(INTERCOM_BUILD_NO_CIRCUIT)
			if(!istype(I, /obj/item/intercom_electronics))
				return ..()
			add_fingerprint(user)
			playsound(loc, I.usesound, 50, TRUE)
			user.balloon_alert(user, "установка платы...")
			if(!do_after(user, 1 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || buildstage != INTERCOM_BUILD_NO_CIRCUIT)
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ATTACK_CHAIN_PROCEED
			user.balloon_alert(user, "плата установлена")
			buildstage = INTERCOM_BUILD_CIRCUIT
			qdel(I)
			return ATTACK_CHAIN_BLOCKED_ALL
		if(INTERCOM_BUILD_CIRCUIT)
			if(!iscoil(I))
				return ..()
			add_fingerprint(user)
			var/obj/item/stack/cable_coil/coil = I
			if(coil.get_amount() < 5)
				user.balloon_alert(user, "недостаточно проводов!")
				return ATTACK_CHAIN_PROCEED
			playsound(loc, coil.usesound, 50, TRUE)
			user.balloon_alert(user, "установка проводки...")
			if(!do_after(user, 2 SECONDS * coil.toolspeed, src, category = DA_CAT_TOOL) || buildstage != INTERCOM_BUILD_CIRCUIT || QDELETED(coil))
				return ATTACK_CHAIN_PROCEED
			if(!coil.use(5))
				user.balloon_alert(user, "установка проводки прервана!")
				return ATTACK_CHAIN_PROCEED
			user.balloon_alert(user, "проводка установлена")
			buildstage = INTERCOM_BUILD_WIRED
			return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

/obj/item/radio/intercom/crowbar_act(mob/user, obj/item/I)
	if(buildstage != INTERCOM_BUILD_CIRCUIT)
		return FALSE
	. = TRUE
	user.balloon_alert(user, "извлечение платы...")
	if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume) || buildstage != INTERCOM_BUILD_CIRCUIT)
		return .
	new /obj/item/intercom_electronics(drop_location())
	user.balloon_alert(user, "плата извлечена")
	buildstage = INTERCOM_BUILD_NO_CIRCUIT

/obj/item/radio/intercom/screwdriver_act(mob/user, obj/item/I)
	if(buildstage != INTERCOM_BUILD_WIRED)
		return ..()
	. = TRUE
	if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume) || buildstage != INTERCOM_BUILD_WIRED)
		return
	set_on(TRUE)
	b_stat = FALSE
	buildstage = INTERCOM_BUILD_SECURED
	user.balloon_alert(user, "корпус заблокирован")
	update_icon()
	update_operating_status()
	for(var/i = 1 to 5)
		wires.on_cut(i, TRUE)

/obj/item/radio/intercom/wirecutter_act(mob/user, obj/item/I)
	if(!(buildstage == INTERCOM_BUILD_SECURED && b_stat && wires.is_all_cut()))
		return ..()
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	WIRECUTTER_SNIP_MESSAGE
	new /obj/item/stack/cable_coil(drop_location(), 5)
	set_on(FALSE)
	b_stat = TRUE
	buildstage = INTERCOM_BUILD_CIRCUIT
	update_icon()
	update_operating_status(FALSE)

/obj/item/radio/intercom/welder_act(mob/user, obj/item/I)
	if(buildstage != INTERCOM_BUILD_NO_CIRCUIT)
		return FALSE
	. = TRUE
	if(!I.tool_use_check(user, 3))
		return .
	user.balloon_alert(user, "демонтаж корпуса...")
	if(!I.use_tool(src, user, 1 SECONDS, amount = 3, volume = I.tool_volume) || buildstage != INTERCOM_BUILD_NO_CIRCUIT)
		return .
	user.balloon_alert(user, "корпус демонтирован")
	new /obj/item/mounted/frame/intercom(drop_location())
	qdel(src)

/obj/item/radio/intercom/update_icon_state()
	if(!circuitry_installed)
		icon_state = "[base_icon_state]_frame"
		return
	icon_state = "[base_icon_state][on ? "_on" : "_off"][b_stat ? "_open" : ""]"

/obj/item/radio/intercom/update_overlays()
	. = ..()
	underlays.Cut()
	if(on && buildstage == INTERCOM_BUILD_SECURED)
		underlays += emissive_appearance(icon, "intercom_lightmask", src)

/obj/item/radio/intercom/proc/update_operating_status(on = TRUE)
	var/area/current_area = get_area(src)
	if(!current_area)
		return
	if(on)
		RegisterSignal(current_area, COMSIG_AREA_POWER_CHANGE, PROC_REF(AreaPowerCheck))
	else
		UnregisterSignal(current_area, COMSIG_AREA_POWER_CHANGE)

/**
 * Proc called whenever the intercom's area loses or gains power. Responsible for setting the `on` variable and calling `update_icon()`.
 *
 * Normally called after the intercom's area receives the `COMSIG_AREA_POWER_CHANGE` signal, but it can also be called directly.
 *
 * Arguments:
 * source - the area that just had a power change.
 */
/obj/item/radio/intercom/proc/AreaPowerCheck(datum/source)
	SIGNAL_HANDLER

	var/area/current_area = get_area(src)
	if(!current_area)
		set_on(FALSE)
	else
		set_on(current_area.powered(EQUIP)) // set "on" to the equipment power status of our area.
	update_icon()

// MARK: Custom
/obj/item/radio/intercom/custom
	name = "station intercom (Custom)"
	should_be_listening = FALSE

/obj/item/radio/intercom/custom/get_ru_names()
	return list(
		NOMINATIVE = "станционный интерком (Персонализированный)",
		GENITIVE = "станционного интеркома (Персонализированный)",
		DATIVE = "станционному интеркому (Персонализированный)",
		ACCUSATIVE = "станционный интерком (Персонализированный)",
		INSTRUMENTAL = "станционным интеркомом (Персонализированный)",
		PREPOSITIONAL = "станционном интеркоме (Персонализированный)",
	)

// MARK: Interrogation
/obj/item/radio/intercom/interrogation
	name = "station intercom (Interrogation)"
	desc = "Специализированный станционный интерком. Представляет собой устройство из прочного полимерно-металлического корпуса \
			с передней панелью, оснащённой микрофоном, динамиком и дисплеем. Встроенное телекоммуникационное оборудование поддерживает \
			широкий диапазон приёма и передачи сигналов, обеспечивая двустороннюю связь по радиочастотам объекта. \
			По умолчанию преднастроен на специализированную частоту для проведения допроса подозреваемых."
	default_frequency = AIRLOCK_FREQ

/obj/item/radio/intercom/interrogation/get_ru_names()
	return list(
		NOMINATIVE = "станционный интерком (Допросный)",
		GENITIVE = "станционного интеркома (Допросный)",
		DATIVE = "станционному интеркому (Допросный)",
		ACCUSATIVE = "станционный интерком (Допросный)",
		INSTRUMENTAL = "станционным интеркомом (Допросный)",
		PREPOSITIONAL = "станционном интеркоме (Допросный)",
	)

// MARK: Private
/obj/item/radio/intercom/private
	name = "station intercom (Private)"
	desc = "Специализированный станционный интерком. Представляет собой устройство из прочного полимерно-металлического корпуса \
			с передней панелью, оснащённой микрофоном, динамиком и дисплеем. Встроенное телекоммуникационное оборудование поддерживает \
			широкий диапазон приёма и передачи сигналов, обеспечивая двустороннюю связь по радиочастотам объекта. \
			По умолчанию преднастроен на частоту Искусственного Интеллекта объекта."
	default_frequency = AI_FREQ

/obj/item/radio/intercom/private/get_ru_names()
	return list(
		NOMINATIVE = "станционный интерком (Приватный)",
		GENITIVE = "станционного интеркома (Приватный)",
		DATIVE = "станционному интеркому (Приватный)",
		ACCUSATIVE = "станционный интерком (Приватный)",
		INSTRUMENTAL = "станционным интеркомом (Приватный)",
		PREPOSITIONAL = "станционном интеркоме (Приватный)",
	)

// MARK: Command
/obj/item/radio/intercom/command
	name = "station intercom (Command)"
	desc = "Специализированный станционный интерком. Представляет собой устройство из прочного полимерно-металлического корпуса \
			с передней панелью, оснащённой микрофоном, динамиком и дисплеем. Встроенное телекоммуникационное оборудование поддерживает \
			широкий диапазон приёма и передачи сигналов, обеспечивая двустороннюю связь по радиочастотам объекта. \
			По умолчанию преднастроен на частоту командного состава объекта."
	default_frequency = COMM_FREQ

/obj/item/radio/intercom/command/get_ru_names()
	return list(
		NOMINATIVE = "станционный интерком (Командный)",
		GENITIVE = "станционного интеркома (Командный)",
		DATIVE = "станционному интеркому (Командный)",
		ACCUSATIVE = "станционный интерком (Командный)",
		INSTRUMENTAL = "станционным интеркомом (Командный)",
		PREPOSITIONAL = "станционном интеркоме (Командный)",
	)

// MARK: Special Operations
/obj/item/radio/intercom/specops
	name = "Special Operations intercom"
	desc = "Специализированный станционный интерком. Представляет собой устройство из прочного полимерно-металлического корпуса \
			с передней панелью, оснащённой микрофоном, динамиком и дисплеем. Встроенное телекоммуникационное оборудование поддерживает \
			широкий диапазон приёма и передачи сигналов, обеспечивая двустороннюю связь по радиочастотам объекта. \
			По умолчанию преднастроен на частоту Отряда Быстрого Реагирования."
	default_frequency = ERT_FREQ

/obj/item/radio/intercom/specops/get_ru_names()
	return list(
		NOMINATIVE = "интерком спецопераций",
		GENITIVE = "интеркома спецопераций",
		DATIVE = "интеркому спецопераций",
		ACCUSATIVE = "интерком спецопераций",
		INSTRUMENTAL = "интеркомом спецопераций",
		PREPOSITIONAL = "интеркоме спецопераций",
	)

/obj/item/radio/intercom/department
	canhear_range = 5

// MARK: Medbay
/obj/item/radio/intercom/department/medbay
	name = "station intercom (Medbay)"
	desc = "Специализированный станционный интерком. Представляет собой устройство из прочного полимерно-металлического корпуса \
			с передней панелью, оснащённой микрофоном, динамиком и дисплеем. Встроенное телекоммуникационное оборудование поддерживает \
			широкий диапазон приёма и передачи сигналов, обеспечивая двустороннюю связь по радиочастотам объекта. \
			По умолчанию преднастроен на внутреннюю частоту медицинского отдела объекта."
	default_frequency = MED_I_FREQ

/obj/item/radio/intercom/department/medbay/get_ru_names()
	return list(
		NOMINATIVE = "станционный интерком (Медицинский)",
		GENITIVE = "станционного интеркома (Медицинский)",
		DATIVE = "станционному интеркому (Медицинский)",
		ACCUSATIVE = "станционный интерком (Медицинский)",
		INSTRUMENTAL = "станционным интеркомом (Медицинский)",
		PREPOSITIONAL = "станционном интеркоме (Медицинский)",
	)

// MARK: Security
/obj/item/radio/intercom/department/security
	name = "station intercom (Security)"
	desc = "Специализированный станционный интерком. Представляет собой устройство из прочного полимерно-металлического корпуса \
			с передней панелью, оснащённой микрофоном, динамиком и дисплеем. Встроенное телекоммуникационное оборудование поддерживает \
			широкий диапазон приёма и передачи сигналов, обеспечивая двустороннюю связь по радиочастотам объекта. \
			По умолчанию преднастроен на внутреннюю частоту службы безопасности объекта."
	default_frequency = SEC_I_FREQ

/obj/item/radio/intercom/department/security/get_ru_names()
	return list(
		NOMINATIVE = "станционный интерком (Служба безопасности)",
		GENITIVE = "станционного интеркома (Служба безопасности)",
		DATIVE = "станционному интеркому (Служба безопасности)",
		ACCUSATIVE = "станционный интерком (Служба безопасности)",
		INSTRUMENTAL = "станционным интеркомом (Служба безопасности)",
		PREPOSITIONAL = "станционном интеркоме (Служба безопасности)",
	)

/obj/item/radio/intercom/department/medbay/get_internal_channels()
	return GLOB.default_medbay_channels

/obj/item/radio/intercom/department/security/get_internal_channels()
	return GLOB.default_security_channels

// MARK: Syndicate
/obj/item/radio/intercom/syndicate
	name = "syndicate intercom"
	desc = "Модернизированный вариант стандартного интеркома. Представляет собой устройство из прочного полимерно-металлического корпуса \
			с передней панелью, оснащённой микрофоном, динамиком и дисплеем. Помимо стандартного телекоммуникацонного оборудования, \
			внутри установлен специальный ключ шифрования, позволяющий прослушивать закрытые каналы \"Нанотрейзен\", \
			а также подключаться к зашифрованной частоте сотрудников \"Синдиката\"."
	syndiekey = new /obj/item/encryptionkey/syndicate/nukeops
	default_frequency = SYND_FREQ

/obj/item/radio/intercom/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "нелегальный интерком",
		GENITIVE = "нелегального интеркома",
		DATIVE = "нелегальному интеркому",
		ACCUSATIVE = "нелегальный интерком",
		INSTRUMENTAL = "нелегальным интеркомом",
		PREPOSITIONAL = "нелегальном интеркоме",
	)

/obj/item/radio/intercom/syndicate/get_internal_channels()
	return GLOB.default_syndicate_channels

// MARK: Pirate
/obj/item/radio/intercom/pirate
	name = "pirate radio intercom"
	desc = "Самодельный интерком, собранный из разнообразных дешёвых радиокомпонентов. Представляет собой кустарное устройство из низкокачественно \
			металлического корпуса с передней панелью, оснащённой микрофоном, динамиком и дисплеем. Встроенное телекоммуникационное оборудование \
			позволяет подключаться к широкому диапазону радиочастот, однако не обладает протоколами защиты и шифрования."

/obj/item/radio/intercom/pirate/get_ru_names()
	return list(
		NOMINATIVE = "пиратский интерком",
		GENITIVE = "пиратского интеркома",
		DATIVE = "пиратскому интеркому",
		ACCUSATIVE = "пиратский интерком",
		INSTRUMENTAL = "пиратским интеркомом",
		PREPOSITIONAL = "пиратском интеркоме",
	)

/obj/item/radio/intercom/pirate/get_internal_channels()
	return GLOB.default_pirate_channels

/obj/item/intercom_electronics
	name = "intercom electronics"
	desc = "Компактная печатная плата, предназначенная для установки в интерком. \
			Поддерживает передачу и приём голосовых сигналов через встроенные радиомодули. \
			Совместима со всеми стандартными типами интеркомов."
	gender = FEMALE
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50, MAT_GLASS=50)
	origin_tech = "engineering=2;programming=1"
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/intercom_electronics/get_ru_names()
	return list(
		NOMINATIVE = "печатная плата интеркома",
		GENITIVE = "печатной платы интеркома",
		DATIVE = "печатной плате интеркома",
		ACCUSATIVE = "печатную плату интеркома",
		INSTRUMENTAL = "печатной платой интеркома",
		PREPOSITIONAL = "печатной плате интеркома",
	)

/obj/item/radio/intercom/locked
	freqlock = TRUE

// MARK: AI private
/obj/item/radio/intercom/locked/ai_private
	name = "AI intercom"
	desc = "Специализированный станционный интерком. Представляет собой устройство из прочного полимерно-металлического корпуса \
			с передней панелью, оснащённой микрофоном, динамиком и дисплеем. Встроенное телекоммуникационное оборудование преднастроено \
			на закрытый канал Искусственного Интеллекта, обеспечивая приватную коммуникацию. \
			Возможность смены частоты заблокирована на программном уровне."
	default_frequency = AI_FREQ

/obj/item/radio/intercom/locked/ai_private/get_ru_names()
	return list(
		NOMINATIVE = "интерком ИИ",
		GENITIVE = "интеркома ИИ",
		DATIVE = "интеркому ИИ",
		ACCUSATIVE = "интерком ИИ",
		INSTRUMENTAL = "интеркомом ИИ",
		PREPOSITIONAL = "интеркоме ИИ",
	)

// MARK: Confessional
/obj/item/radio/intercom/locked/confessional
	name = "confessional intercom"
	desc = "Специализированный станционный интерком. Представляет собой устройство из прочного полимерно-металлического корпуса \
			с передней панелью, оснащённой микрофоном, динамиком и дисплеем. Встроенное телекоммуникационное оборудование преднастроено \
			на закрытый канал, предназначенный для приватной коммуникации со священнослужителями в исповедальных комнатах. \
			Возможность смены частоты заблокирована на программном уровне."
	default_frequency = 1480

/obj/item/radio/intercom/locked/confessional/get_ru_names()
	return list(
		NOMINATIVE = "исповедальный интерком",
		GENITIVE = "исповедального интеркома",
		DATIVE = "исповедальному интеркому",
		ACCUSATIVE = "исповедальный интерком",
		INSTRUMENTAL = "исповедальным интеркомом",
		PREPOSITIONAL = "исповедальном интеркоме",
	)

// MARK: Prison
/obj/item/radio/intercom/locked/prison
	name = "prison intercom"
	desc = "Специализированный станционный интерком. Представляет собой устройство из прочного полимерно-металлического корпуса \
			с передней панелью, оснащённой микрофоном, динамиком и дисплеем. Встроенное телекоммуникационное оборудование преднастроено \
			на общую частоту. Возможность смены частоты заблокирована на уровне прошивки, а микрофон отключён на аппаратном уровне."

/obj/item/radio/intercom/locked/prison/get_ru_names()
	return list(
		NOMINATIVE = "тюремный интерком",
		GENITIVE = "тюремного интеркома",
		DATIVE = "тюремному интеркому",
		ACCUSATIVE = "тюремный интерком",
		INSTRUMENTAL = "тюремным интеркомом",
		PREPOSITIONAL = "тюремном интеркоме",
	)

/obj/item/radio/intercom/locked/prison/Initialize(mapload, buildstage = INTERCOM_BUILD_SECURED)
	. = ..()
	wires.cut(WIRE_RADIO_TRANSMIT)

#undef INTERCOM_BUILD_NO_CIRCUIT
#undef INTERCOM_BUILD_CIRCUIT
#undef INTERCOM_BUILD_WIRED
#undef INTERCOM_BUILD_SECURED

// MARK: Mapping Dir Helpers
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom, 27, 27)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/custom, 27, 27)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/interrogation, 27, 27)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/private, 27, 27)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/command, 27, 27)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/specops, 27, 27)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/department/medbay, 27, 27)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/department/security, 27, 27)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/syndicate, 27, 27)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/pirate, 27, 27)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/locked/ai_private, 27, 27)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/locked/confessional, 27, 27)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/locked/prison, 27, 27)
