// =============== HEADSETS ===============

/obj/item/radio/headset/vox
	name = "vox headset"
	desc = "Наушник дальней связи для поддержания связи со стаей."
	origin_tech = "syndicate=3"
	ks1type = /obj/item/encryptionkey/vox
	requires_tcomms = FALSE
	instant = TRUE // Work instantly if there are no comms
	freqlock = TRUE
	default_frequency = VOX_RAID_FREQ

/obj/item/radio/headset/vox/get_ru_names()
	return alist(
		NOMINATIVE = "радиочастотная гарнитура воксов-рейдеров",
		GENITIVE = "радиочастотную гарнитуру воксов-рейдеров",
		DATIVE = "радиочастотной гарнитуры воксов-рейдеров",
		ACCUSATIVE = "радиочастотную гарнитуру воксов-рейдеров",
		INSTRUMENTAL = "радиочастотной гарнитурой воксов-рейдеров",
		PREPOSITIONAL = "радиочастотной гарнитуре воксов-рейдеров",
	)

/obj/item/radio/headset/vox/alt
	name = "vox protect headset"
	desc = "Наушник дальней связи для поддержания связи со стаей. Защищает ушные раковины от громких звуков"
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"
	item_flags = BANGPROTECT_MINOR

/obj/item/radio/headset/vox/alt/get_ru_names()
	return alist(
		NOMINATIVE = "тактическая гарнитура воксов-рейдеров",
		GENITIVE = "тактическую гарнитуру воксов-рейдеров",
		DATIVE = "тактической гарнитуры воксов-рейдеров",
		ACCUSATIVE = "тактическую гарнитуру воксов-рейдеров",
		INSTRUMENTAL = "тактической гарнитурой воксов-рейдеров",
		PREPOSITIONAL = "тактической гарнитуре воксов-рейдеров",
	)

/obj/item/encryptionkey/vox
	name = "vox raider key"
	icon = 'icons/obj/machines/trader_machine.dmi'
	icon_state = "vox_key"
	greyscale_config = null
	channels = list(VOX_RAID_FREQ_NAME = 1, SYND_FREQ_NAME = 1)
	origin_tech = "syndicate=3"
	syndie = TRUE

/obj/item/encryptionkey/vox/get_ru_names()
	return alist(
		NOMINATIVE = "ключ-шифратор воксов-рейдеров",
		GENITIVE = "ключа-шифратора воксов-рейдеров",
		DATIVE = "ключу-шифратору воксов-рейдеров",
		ACCUSATIVE = "ключ-шифратор воксов-рейдеров",
		INSTRUMENTAL = "ключом-шифратором воксов-рейдеров",
		PREPOSITIONAL = "ключе-шифраторе воксов-рейдеров",
	)
