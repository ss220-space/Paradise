/obj/item/radio/headset/ninja
	name = "Ninja headset"
	desc = "Headset developed by a fearfull Spider Clan. \
	It is able to hear and translate binary communications between cyborgs, and can copy radio channels from other headsets and encryption keys! \
	Protects ears from flashbangs."
	item_flags = BANGPROTECT_MINOR
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "headset_green"
	ks2type = /obj/item/encryptionkey/spider_clan
	requires_tcomms = FALSE
	instant = TRUE
	freqlock = TRUE
	translate_binary = TRUE
	default_frequency = NINJA_FREQ
	var/list/scanned_channels
	var/scan_hive = FALSE


/obj/item/radio/headset/ninja/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/radio/headset))
		var/obj/item/radio/headset/target_headset = I
		if(!do_after(user, 2 SECONDS, user, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_warning("Сканирование прервано!")))
			return .
		to_chat(user, span_notice("Вы сканируете \"[target_headset.name]\" и копируете доступные в нём каналы в память вашего собственного наушника."))
		LAZYINITLIST(scanned_channels)
		scanned_channels |= target_headset.channels
		if(target_headset.syndiekey)
			to_chat(user, span_notice("\"[target_headset.name]\" способен прослушивать все частоты станции! Джекпот!"))
			make_syndie()
		if(target_headset.translate_hive)
			scan_hive = TRUE
		recalculate_channels()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/encryptionkey))
		to_chat(user, span_notice("Ваш наушник не принимает ключи. Вставьте его в любой другой наушник и проанализируйте сам наушник встроенным сканером."))
		return ATTACK_CHAIN_PROCEED

	return ..()

/obj/item/radio/headset/ninja/get_base_channels()
	. = ..()
	. |= scanned_channels

/obj/item/radio/headset/ninja/load_keyslot(obj/item/encryptionkey/key)
	. = ..()
	translate_hive |= scan_hive

/obj/item/radio/headset/ninja/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	user.set_machine(src)
	to_chat(user, "У этого наушника нет даже одного винтика! Это просто бессмысленная трата времени...")

/obj/item/encryptionkey/spider_clan
	name = "Spider Clan Encryption Key"
	desc = "An encryption key for a radio headset. Made by Spider Clan. (TM) To access the binary channel, use :+."
	icon_state = "bin_cypherkey"
	translate_binary = TRUE
	channels = list(NINJA_FREQ_NAME = 1)
