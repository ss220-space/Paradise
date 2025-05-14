/obj/item/radio/headset
	name = "radio headset"
	desc = "Обновлённая, компактная версия интеркома, которая надевается на голову. Эта модель поддерживает установку ключей-шифраторов."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура",
		GENITIVE = "радиочастотную гарнитуру",
		DATIVE = "радиочастотной гарнитуры",
		ACCUSATIVE = "радиочастотную гарнитуру",
		INSTRUMENTAL = "радиочастотной гарнитурой",
		PREPOSITIONAL = "радиочастотной гарнитуре"
	)
	gender = FEMALE
	var/radio_desc = ""
	icon_state = "headset"
	item_state = "headset"
	equip_sound = 'sound/items/handling/generic_equip4.ogg'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/ears.dmi',
		SPECIES_VOX_ARMALIS = 'icons/mob/clothing/species/armalis/ears.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/ears.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/ears.dmi'
	) //We read you loud and skree-er.
	materials = list(MAT_METAL=75)
	canhear_range = 0 // can't hear headsets from very far away

	slot_flags = ITEM_SLOT_EARS
	var/translate_binary = FALSE
	var/translate_hive = FALSE
	var/obj/item/encryptionkey/keyslot1 = null
	var/obj/item/encryptionkey/keyslot2 = null

	var/ks1type = null
	var/ks2type = null
	dog_fashion = null
	requires_tcomms = TRUE

/obj/item/radio/headset/New()
	..()
	internal_channels.Cut()

/obj/item/radio/headset/Initialize()
	. = ..()

	if(ks1type)
		keyslot1 = new ks1type(src)
		if(keyslot1.syndie)
			syndiekey = keyslot1
	if(ks2type)
		keyslot2 = new ks2type(src)
		if(keyslot2.syndie)
			syndiekey = keyslot2

	recalculateChannels(TRUE)

/obj/item/radio/headset/Destroy()
	QDEL_NULL(keyslot1)
	QDEL_NULL(keyslot2)
	return ..()

/obj/item/radio/headset/examine(mob/user)
	. = ..()
	if(in_range(src, user) && radio_desc)
		. += span_notice("Доступные частоты:")
		. += span_info("[radio_desc]")

/obj/item/radio/headset/handle_message_mode(mob/living/M, list/message_pieces, channel)
	if(channel == "special")
		if(translate_binary)
			var/datum/language/binary = GLOB.all_languages[LANGUAGE_BINARY]
			binary.broadcast(M, strip_prefixes(multilingual_to_message(message_pieces)))
			return RADIO_CONNECTION_NON_SUBSPACE
		if(translate_hive)
			var/datum/language/hivemind = GLOB.all_languages[LANGUAGE_HIVE_XENOS]
			hivemind.broadcast(M, strip_prefixes(multilingual_to_message(message_pieces)))
			return RADIO_CONNECTION_NON_SUBSPACE
		return RADIO_CONNECTION_FAIL

	return ..()

/obj/item/radio/headset/is_listening()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.l_ear == src || H.r_ear == src)
			return ..()
	else if(isanimal(loc) || isAI(loc) || istype(loc, /obj/item/paicard))
		return ..()

	return FALSE

/obj/item/radio/headset/alt
	name = "bowman headset"
	desc = "Обновлённая, компактная версия интеркома, которая надевается на голову. Эта модель поддерживает установку ключей-шифраторов и защищает от громких звуков."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура",
		GENITIVE = "тактическую гарнитуру",
		DATIVE = "тактической гарнитуры",
		ACCUSATIVE = "тактическую гарнитуру",
		INSTRUMENTAL = "тактической гарнитурой",
		PREPOSITIONAL = "тактической гарнитуре"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/syndicate
	origin_tech = "syndicate=3"
	ks1type = /obj/item/encryptionkey/syndicate/nukeops
	requires_tcomms = FALSE
	instant = TRUE // Work instantly if there are no comms
	freqlock = TRUE

/obj/item/radio/headset/syndicate/alt //undisguised bowman with flash protection
	name = "syndicate headset"
	desc = "Гарнитура Синдиката, позволяющая прослушивать все радиочастоты на станции. Обеспечивает защиту от громких звуков."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Синдиката",
		GENITIVE = "тактическую гарнитуру Синдиката",
		DATIVE = "тактической гарнитуры Синдиката",
		ACCUSATIVE = "тактическую гарнитуру Синдиката",
		INSTRUMENTAL = "тактической гарнитурой Синдиката",
		PREPOSITIONAL = "тактической гарнитуре Синдиката"
	)
	item_flags = BANGPROTECT_MINOR
	origin_tech = "syndicate=3"
	icon_state = "syndie_headset"
	item_state = "syndie_headset"

/obj/item/radio/headset/syndicate/syndteam
	ks1type = /obj/item/encryptionkey/syndteam

/obj/item/radio/headset/syndicate/alt/syndteam
	ks1type = /obj/item/encryptionkey/syndteam

/obj/item/radio/headset/syndicate/alt/lavaland
	name = "syndicate lavaland headset"

/obj/item/radio/headset/syndicate/alt/lavaland/New()
	. = ..()
	set_frequency(SYND_FREQ)

/obj/item/radio/headset/syndicate/admin_officer
	name = "syndicate officer's headset"
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура офицера Синдиката",
		GENITIVE = "тактическую гарнитуру офицера Синдиката",
		DATIVE = "тактической гарнитуры офицера Синдиката",
		ACCUSATIVE = "тактическую гарнитуру офицера Синдиката",
		INSTRUMENTAL = "тактической гарнитурой офицера Синдиката",
		PREPOSITIONAL = "тактической гарнитуре офицера Синдиката"
	)
	icon_state = "taipan_headset"
	item_state = "taipan_headset"
	ks1type = /obj/item/encryptionkey/syndteam
	ks2type = /obj/item/encryptionkey/syndicate/taipan
	freerange = TRUE
	freqlock = FALSE
	item_flags = BANGPROTECT_MINOR

/obj/item/radio/headset/syndicate/taipan
	name = "syndicate taipan headset"
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Синдиката",
		GENITIVE = "тактическую гарнитуру Синдиката",
		DATIVE = "тактической гарнитуры Синдиката",
		ACCUSATIVE = "тактическую гарнитуру Синдиката",
		INSTRUMENTAL = "тактической гарнитурой Синдиката",
		PREPOSITIONAL = "тактической гарнитуре Синдиката"
	)
	icon_state = "taipan_headset"
	item_state = "taipan_headset"
	ks1type = /obj/item/encryptionkey/syndicate/taipan
	item_flags = BANGPROTECT_MINOR

/obj/item/radio/headset/syndicate/taipan/New()
	. = ..()
	set_frequency(SYND_TAIPAN_FREQ)

/obj/item/radio/headset/syndicate/taipan/tcomms_agent
	ks1type = /obj/item/encryptionkey/syndicate/taipan/tcomms_agent
	freerange = TRUE
	freqlock = FALSE

/obj/item/radio/headset/alt/soviet
	name = "\improper Soviet bowman headset"
	desc = "Тактическая гарнитура с доступом к военной частоте СССП. Обеспечивает защиту от громких звуков."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура СССП",
		GENITIVE = "тактическую гарнитуру СССП",
		DATIVE = "тактической гарнитуры СССП",
		ACCUSATIVE = "тактическую гарнитуру СССП",
		INSTRUMENTAL = "тактической гарнитурой СССП",
		PREPOSITIONAL = "тактической гарнитуре СССП"
	)
	icon_state = "syndie_headset"
	item_state = "syndie_headset"
	ks1type = /obj/item/encryptionkey/soviet
	requires_tcomms = FALSE
	instant = TRUE
	freqlock = TRUE

/obj/item/radio/headset/binary
	origin_tech = "syndicate=3"
	ks1type = /obj/item/encryptionkey/binary

/obj/item/radio/headset/headset_sec
	name = "security radio headset"
	desc = "Данная гарнитура используется местной службой безопасности."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура службы безопасности",
		GENITIVE = "радиочастотную гарнитуру службы безопасности",
		DATIVE = "радиочастотной гарнитуры службы безопасности",
		ACCUSATIVE = "радиочастотную гарнитуру службы безопасности",
		INSTRUMENTAL = "радиочастотной гарнитурой службы безопасности",
		PREPOSITIONAL = "радиочастотной гарнитуре службы безопасности"
	)
	icon_state = "sec_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_sec

/obj/item/radio/headset/headset_sec/alt
	name = "security bowman headset"
	desc = "Данная гарнитура используется местной службой безопасности. Обеспечивает защиту от громких звуков."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура службы безопасности",
		GENITIVE = "тактическую гарнитуру службы безопасности",
		DATIVE = "тактической гарнитуры службы безопасности",
		ACCUSATIVE = "тактическую гарнитуру службы безопасности",
		INSTRUMENTAL = "тактической гарнитурой службы безопасности",
		PREPOSITIONAL = "тактической гарнитуре службы безопасности"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"

/obj/item/radio/headset/headset_brigphys
	name = "brig physician's bowman headset"
	desc = "Данная гарнитура используется медицинским персоналом, связанным с местной службой безопасности. Обеспечивает защиту от громких звуков."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура бригмедика",
		GENITIVE = "тактическую гарнитуру бригмедика",
		DATIVE = "тактической гарнитуры бригмедика",
		ACCUSATIVE = "тактическую гарнитуру бригмедика",
		INSTRUMENTAL = "тактической гарнитурой бригмедика",
		PREPOSITIONAL = "тактической гарнитуре бригмедика"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"
	ks2type = /obj/item/encryptionkey/headset_medsec

/obj/item/radio/headset/headset_iaa
	name = "internal affairs radio headset"
	desc = "Данная гарнитура используется местными юристами."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура агента внутренних дел",
		GENITIVE = "радиочастотную гарнитуру агента внутренних дел",
		DATIVE = "радиочастотной гарнитуры агента внутренних дел",
		ACCUSATIVE = "радиочастотную гарнитуру агента внутренних дел",
		INSTRUMENTAL = "радиочастотной гарнитурой агента внутренних дел",
		PREPOSITIONAL = "радиочастотной гарнитуре агента внутренних дел"
	)
	icon_state = "sec_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_iaa

/obj/item/radio/headset/headset_iaa/alt
	name = "internal affairs bowman headset"
	desc = "Данная гарнитура используется местными юристами. Обеспечивает защиту от громких звуков."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура агента внутренних дел",
		GENITIVE = "тактическую гарнитуру агента внутренних дел",
		DATIVE = "тактической гарнитуры агента внутренних дел",
		ACCUSATIVE = "тактическую гарнитуру агента внутренних дел",
		INSTRUMENTAL = "тактической гарнитурой агента внутренних дел",
		PREPOSITIONAL = "тактической гарнитуре агента внутренних дел"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"

/obj/item/radio/headset/headset_eng
	name = "engineering radio headset"
	desc = "Данная гарнитура используется в тех случаях, когда инженерам требуется обсудить количество выпитого алкоголя."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура инженерного отдела",
		GENITIVE = "радиочастотную гарнитуру инженерного отдела",
		DATIVE = "радиочастотной гарнитуры инженерного отдела",
		ACCUSATIVE = "радиочастотную гарнитуру инженерного отдела",
		INSTRUMENTAL = "радиочастотной гарнитурой инженерного отдела",
		PREPOSITIONAL = "радиочастотной гарнитуре инженерного отдела"
	)
	icon_state = "eng_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_eng

/obj/item/radio/headset/headset_rob
	name = "robotics radio headset"
	desc = "Данная гарнитура сделана для тех, кто проводит всё свое время в создании идеального роботизированного помощника."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура робототехников",
		GENITIVE = "радиочастотную гарнитуру робототехников",
		DATIVE = "радиочастотной гарнитуры робототехников",
		ACCUSATIVE = "радиочастотную гарнитуру робототехников",
		INSTRUMENTAL = "радиочастотной гарнитурой робототехников",
		PREPOSITIONAL = "радиочастотной гарнитуре робототехников"
	)
	icon_state = "rob_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_rob

/obj/item/radio/headset/headset_med
	name = "medical radio headset"
	desc = "Данная гарнитура используется тренированным медицинским персоналом. Она пропахла медицинским спиртом."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура медицинского отдела",
		GENITIVE = "радиочастотную гарнитуру медицинского отдела",
		DATIVE = "радиочастотной гарнитуры медицинского отдела",
		ACCUSATIVE = "радиочастотную гарнитуру медицинского отдела",
		INSTRUMENTAL = "радиочастотной гарнитурой медицинского отдела",
		PREPOSITIONAL = "радиочастотной гарнитуре медицинского отдела"
	)
	icon_state = "med_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_med

/obj/item/radio/headset/headset_sci
	name = "science radio headset"
	desc = "Данная гарнитура используется сотрудниками научного отдела. Судя по всему, этот образец пережил множество неудачных экспериментов."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура научного отдела",
		GENITIVE = "радиочастотную гарнитуру научного отдела",
		DATIVE = "радиочастотной гарнитуры научного отдела",
		ACCUSATIVE = "радиочастотную гарнитуру научного отдела",
		INSTRUMENTAL = "радиочастотной гарнитурой научного отдела",
		PREPOSITIONAL = "радиочастотной гарнитуре научного отдела"
	)
	icon_state = "sci_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_sci

/obj/item/radio/headset/headset_medsci
	name = "medical research radio headset"
	desc = "Данная гарнитура получилась в результате эксперимента по скрещиванию (или сращиванию?) медицинского и научного отдела."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура научного и медицинского отдела",
		GENITIVE = "радиочастотную гарнитуру научного и медицинского отдела",
		DATIVE = "радиочастотной гарнитуры научного и медицинского отдела",
		ACCUSATIVE = "радиочастотную гарнитуру научного и медицинского отдела",
		INSTRUMENTAL = "радиочастотной гарнитурой научного и медицинского отдела",
		PREPOSITIONAL = "радиочастотной гарнитуре научного и медицинского отдела"
	)
	icon_state = "medsci_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_medsci

/obj/item/radio/headset/headset_com
	name = "command radio headset"
	desc = "Данная гарнитура имеет доступ к командному отделу."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура командного отдела",
		GENITIVE = "радиочастотную гарнитуру командного отдела",
		DATIVE = "радиочастотной гарнитуры командного отдела",
		ACCUSATIVE = "радиочастотную гарнитуру командного отдела",
		INSTRUMENTAL = "радиочастотной гарнитурой командного отдела",
		PREPOSITIONAL = "радиочастотной гарнитуре командного отдела"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_com

/obj/item/radio/headset/heads/captain
	name = "captain's headset"
	desc = "Гарнитура настоящего начальника."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура капитана",
		GENITIVE = "радиочастотную гарнитуру капитана",
		DATIVE = "радиочастотной гарнитуры капитана",
		ACCUSATIVE = "радиочастотную гарнитуру капитана",
		INSTRUMENTAL = "радиочастотной гарнитурой капитана",
		PREPOSITIONAL = "радиочастотной гарнитуре капитана"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/captain

/obj/item/radio/headset/heads/captain/alt
	name = "\proper the captain's bowman headset"
	desc = "Гарнитура настоящего начальника. Обеспечивает защиту от громких звуков."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура капитана",
		GENITIVE = "тактическую гарнитуру капитана",
		DATIVE = "тактической гарнитуры капитана",
		ACCUSATIVE = "тактическую гарнитуру капитана",
		INSTRUMENTAL = "тактической гарнитурой капитана",
		PREPOSITIONAL = "тактической гарнитуре капитана"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/rd
	name = "Research Director's headset"
	desc = "Гарнитура настоящего профессионала по исследованиям. Она запачкана в чем-то липком."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура научного руководителя",
		GENITIVE = "радиочастотную гарнитуру научного руководителя",
		DATIVE = "радиочастотной гарнитуры научного руководителя",
		ACCUSATIVE = "радиочастотную гарнитуру научного руководителя",
		INSTRUMENTAL = "радиочастотной гарнитурой научного руководителя",
		PREPOSITIONAL = "радиочастотной гарнитуре научного руководителя"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/rd

/obj/item/radio/headset/heads/hos
	name = "head of security's headset"
	desc = "Эта гарнитура принадлежит тому, кто защищает никчёмные жизни на этой станции."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура главы службы безопасности",
		GENITIVE = "радиочастотную гарнитуру главы службы безопасности",
		DATIVE = "радиочастотной гарнитуры главы службы безопасности",
		ACCUSATIVE = "радиочастотную гарнитуру главы службы безопасности",
		INSTRUMENTAL = "радиочастотной гарнитурой главы службы безопасности",
		PREPOSITIONAL = "радиочастотной гарнитуре главы службы безопасности"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/hos

/obj/item/radio/headset/heads/hos/alt
	name = "\proper the head of security's bowman headset"
	desc = "Эта гарнитура принадлежит тому, кто сохраняет порядок на этой станции. Обеспечивает защиту от громких звуков."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура главы службы безопасности",
		GENITIVE = "тактическую гарнитуру главы службы безопасности",
		DATIVE = "тактической гарнитуры главы службы безопасности",
		ACCUSATIVE = "тактическую гарнитуру главы службы безопасности",
		INSTRUMENTAL = "тактической гарнитурой главы службы безопасности",
		PREPOSITIONAL = "тактической гарнитуре главы службы безопасности"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/ce
	name = "chief engineer's headset"
	desc = "Эта гарнитура принадлежит тому, кто находится во главе кучки алкоголиков."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура старшего инженера",
		GENITIVE = "радиочастотную гарнитуру старшего инженера",
		DATIVE = "радиочастотной гарнитуры старшего инженера",
		ACCUSATIVE = "радиочастотную гарнитуру старшего инженера",
		INSTRUMENTAL = "радиочастотной гарнитурой старшего инженера",
		PREPOSITIONAL = "радиочастотной гарнитуре старшего инженера"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/ce

/obj/item/radio/headset/heads/cmo
	name = "chief medical officer's headset"
	desc = "Эта гарнитура принадлежит высококвалифицированному медицинскому персоналу."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура главного врача",
		GENITIVE = "радиочастотную гарнитуру главного врача",
		DATIVE = "радиочастотной гарнитуры главного врача",
		ACCUSATIVE = "радиочастотную гарнитуру главного врача",
		INSTRUMENTAL = "радиочастотной гарнитурой главного врача",
		PREPOSITIONAL = "радиочастотной гарнитуре главного врача"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/cmo

/obj/item/radio/headset/heads/hop
	name = "head of personnel's headset"
	desc = "Эта гарнитура принадлежит тому, кто рано или поздно станет капитаном."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура главы персонала",
		GENITIVE = "радиочастотную гарнитуру главы персонала",
		DATIVE = "радиочастотной гарнитуры главы персонала",
		ACCUSATIVE = "радиочастотную гарнитуру главы персонала",
		INSTRUMENTAL = "радиочастотной гарнитурой главы персонала",
		PREPOSITIONAL = "радиочастотной гарнитуре главы персонала"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/hop

/obj/item/radio/headset/heads/qm
	name = "quartermaster's headset"
	desc = "Эта гарнитура принадлежит тому, кто рано или поздно сделает Каргонию снова великой."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура завхоза",
		GENITIVE = "радиочастотную гарнитуру завхоза",
		DATIVE = "радиочастотной гарнитуры завхоза",
		ACCUSATIVE = "радиочастотную гарнитуру завхоза",
		INSTRUMENTAL = "радиочастотной гарнитурой завхоза",
		PREPOSITIONAL = "радиочастотной гарнитуре завхоза"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/qm

/obj/item/radio/headset/headset_cargo
	name = "supply radio headset"
	desc = "Крайне дешёвая копия тактической гарнитуры, используемой службой безопасности. Данная модель не способна защитить от громких звуков, несмотря на ее внешний вид."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура отдела снабжения",
		GENITIVE = "радиочастотную гарнитуру отдела снабжения",
		DATIVE = "радиочастотной гарнитуры отдела снабжения",
		ACCUSATIVE = "радиочастотную гарнитуру отдела снабжения",
		INSTRUMENTAL = "радиочастотной гарнитурой отдела снабжения",
		PREPOSITIONAL = "радиочастотной гарнитуре отдела снабжения"
	)
	icon_state = "cargo_headset"
	item_state = "cargo_headset"
	ks2type = /obj/item/encryptionkey/headset_cargo

/obj/item/radio/headset/headset_cargo/mining
	name = "mining radio headset"
	desc = "Гарнитура, используемая шахтёрами. Она пропахла пеплом."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура шахтёров",
		GENITIVE = "радиочастотную гарнитуру шахтёров",
		DATIVE = "радиочастотной гарнитуры шахтёров",
		ACCUSATIVE = "радиочастотную гарнитуру шахтёров",
		INSTRUMENTAL = "радиочастотной гарнитурой шахтёров",
		PREPOSITIONAL = "радиочастотной гарнитуре шахтёров"
	)
	icon_state = "mine_headset"

/obj/item/radio/headset/headset_service
	name = "service radio headset"
	desc = "Гарнитура, используемая сотрудниками сервисного отдела."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура сервисного отдела",
		GENITIVE = "радиочастотную гарнитуру сервисного отдела",
		DATIVE = "радиочастотной гарнитуры сервисного отдела",
		ACCUSATIVE = "радиочастотную гарнитуру сервисного отдела",
		INSTRUMENTAL = "радиочастотной гарнитурой сервисного отдела",
		PREPOSITIONAL = "радиочастотной гарнитуре сервисного отдела"
	)
	icon_state = "srv_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_service

/obj/item/radio/headset/heads/ntrep
	name = "nanotrasen representative's headset"
	desc = "Эта гарнитура принадлежит тому, кому придется разгребать всё то, что натворили главы этой станции."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура представителя НаноТрейзен",
		GENITIVE = "радиочастотную гарнитуру представителя НаноТрейзен",
		DATIVE = "радиочастотной гарнитуры представителя НаноТрейзен",
		ACCUSATIVE = "радиочастотную гарнитуру представителя НаноТрейзен",
		INSTRUMENTAL = "радиочастотной гарнитурой представителя НаноТрейзен",
		PREPOSITIONAL = "радиочастотной гарнитуре представителя НаноТрейзен"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/ntrep

/obj/item/radio/headset/heads/magistrate
	name = "magistrate's headset"
	desc = "Эта гарнитура принадлежит тому, кого на этой станции ни во что не ставят. По крайней мере до тех пор, пока офицерам не требуется приказ на казнь."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура магистрата",
		GENITIVE = "радиочастотную гарнитуру магистрата",
		DATIVE = "радиочастотной гарнитуры магистрата",
		ACCUSATIVE = "радиочастотную гарнитуру магистрата",
		INSTRUMENTAL = "радиочастотной гарнитурой магистрата",
		PREPOSITIONAL = "радиочастотной гарнитуре магистрата"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/magistrate

/obj/item/radio/headset/heads/magistrate/alt
	name = "\proper magistrate's bowman headset"
	desc = "Эта гарнитура принадлежит тому, кого на этой станции ни во что не ставят. Обеспечивает защиту от громких звуков."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура магистрата",
		GENITIVE = "тактическую гарнитуру магистрата",
		DATIVE = "тактической гарнитуры магистрата",
		ACCUSATIVE = "тактическую гарнитуру магистрата",
		INSTRUMENTAL = "тактической гарнитурой магистрата",
		PREPOSITIONAL = "тактической гарнитуре магистрата"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/blueshield
	name = "blueshield's headset"
	desc = "Эта гарнитура принадлежит дополнительному сотруднику СБ."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура офицера \"Синий Щит\"",
		GENITIVE = "радиочастотную гарнитуру офицера \"Синий Щит\"",
		DATIVE = "радиочастотной гарнитуры офицера \"Синий Щит\"",
		ACCUSATIVE = "радиочастотную гарнитуру офицера \"Синий Щит\"",
		INSTRUMENTAL = "радиочастотной гарнитурой офицера \"Синий Щит\"",
		PREPOSITIONAL = "радиочастотной гарнитуре офицера \"Синий Щит\""
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/blueshield

/obj/item/radio/headset/heads/blueshield/alt
	name = "\proper blueshield's bowman headset"
	desc = "Эта гарнитура принадлежит дополнительному сотруднику СБ. Обеспечивает защиту от громких звуков."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура офицера \"Синий Щит\"",
		GENITIVE = "тактическую гарнитуру офицера \"Синий Щит\"",
		DATIVE = "тактической гарнитуры офицера \"Синий Щит\"",
		ACCUSATIVE = "тактическую гарнитуру офицера \"Синий Щит\"",
		INSTRUMENTAL = "тактической гарнитурой офицера \"Синий Щит\"",
		PREPOSITIONAL = "тактической гарнитуре офицера \"Синий Щит\""
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/ert
	name = "emergency response team headset"
	desc = "Эта гарнитура принадлежит тому, кто управляет начальниками."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура члена ОБР",
		GENITIVE = "радиочастотную гарнитуру члена ОБР",
		DATIVE = "радиочастотной гарнитуры члена ОБР",
		ACCUSATIVE = "радиочастотную гарнитуру члена ОБР",
		INSTRUMENTAL = "радиочастотной гарнитурой члена ОБР",
		PREPOSITIONAL = "радиочастотной гарнитуре члена ОБР"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/ert
	freqlock = TRUE

/obj/item/radio/headset/ert/alt
	name = "emergency response team's bowman headset"
	desc = "Эта гарнитура принадлежит тому, кто управляет начальниками. Обеспечивает защиту от громких звуков."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура члена ОБР",
		GENITIVE = "тактическую гарнитуру члена ОБР",
		DATIVE = "тактической гарнитуры члена ОБР",
		ACCUSATIVE = "тактическую гарнитуру члена ОБР",
		INSTRUMENTAL = "тактической гарнитурой члена ОБР",
		PREPOSITIONAL = "тактической гарнитуре члена ОБР"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/ert/alt/solgov
	name = "\improper Trans-Solar Federation Marine's bowman headset"
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура морпеха ТСФ",
		GENITIVE = "тактическую гарнитуру морпеха ТСФ",
		DATIVE = "тактической гарнитуры морпеха ТСФ",
		ACCUSATIVE = "тактическую гарнитуру морпеха ТСФ",
		INSTRUMENTAL = "тактической гарнитурой морпеха ТСФ",
		PREPOSITIONAL = "тактической гарнитуре морпеха ТСФ"
	)

/obj/item/radio/headset/ert/alt/commander
	name = "ERT commander's bowman headset"
	desc = "Эта гарнитура принадлежит тому, кто управляет начальниками. Обеспечивает защиту от громких звуков. Позволяет отдавать приказы даже в случае отказа реле телекоммуникации."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура лидера ОБР",
		GENITIVE = "тактическую гарнитуру лидера ОБР",
		DATIVE = "тактической гарнитуры лидера ОБР",
		ACCUSATIVE = "тактическую гарнитуру лидера ОБР",
		INSTRUMENTAL = "тактической гарнитурой лидера ОБР",
		PREPOSITIONAL = "тактической гарнитуре лидера ОБР"
	)
	requires_tcomms = FALSE
	instant = TRUE

/obj/item/radio/headset/ert/alt/commander/solgov
	name = "\improper Trans-Solar Federation Lieutenant's bowman headset"
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура лейтенанта ТСФ",
		GENITIVE = "тактическую гарнитуру лейтенанта ТСФ",
		DATIVE = "тактической гарнитуры лейтенанта ТСФ",
		ACCUSATIVE = "тактическую гарнитуру лейтенанта ТСФ",
		INSTRUMENTAL = "тактической гарнитурой лейтенанта ТСФ",
		PREPOSITIONAL = "тактической гарнитуре лейтенанта ТСФ"
	)

/obj/item/radio/headset/centcom
	name = "\proper centcom officer's bowman headset"
	desc = "Эта гарнитура принадлежит высшей должностной инстанции. Обеспечивает защиту от громких звуков. Позволяет отдавать приказы даже в случае отказа реле телекоммуникации."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура офицера ЦК",
		GENITIVE = "тактическую гарнитуру офицера ЦК",
		DATIVE = "тактической гарнитуры офицера ЦК",
		ACCUSATIVE = "тактическую гарнитуру офицера ЦК",
		INSTRUMENTAL = "тактической гарнитурой офицера ЦК",
		PREPOSITIONAL = "тактической гарнитуре офицера ЦК"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"
	ks2type = /obj/item/encryptionkey/centcom
	requires_tcomms = FALSE
	instant = TRUE

/obj/item/radio/headset/centcom/solgov
	name = "\improper Trans-Solar Federation General's bowman headset"
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура генерала ТСФ",
		GENITIVE = "тактическую гарнитуру генерала ТСФ",
		DATIVE = "тактической гарнитуры генерала ТСФ",
		ACCUSATIVE = "тактическую гарнитуру генерала ТСФ",
		INSTRUMENTAL = "тактической гарнитурой генерала ТСФ",
		PREPOSITIONAL = "тактической гарнитуре генерала ТСФ"
	)

/obj/item/radio/headset/heads/ai_integrated //No need to care about icons, it should be hidden inside the AI anyway.
	name = "\improper AI subspace transceiver"
	desc = "Integrated AI radio transceiver."
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "radio"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/ai_integrated
	var/myAi = null    // Atlantis: Reference back to the AI which has this radio.
	var/disabledAi = FALSE // Atlantis: Used to manually disable AI's integrated radio via intellicard menu.

/obj/item/radio/headset/headset_mining_medic
	name = "mining medic's radio headset"
	desc = "Гарнитура, используемая шахтёрским врачом. Она пропахла как медицинским спиртом, так и пеплом."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура шахтёрского врача",
		GENITIVE = "радиочастотную гарнитуру шахтёрского врача",
		DATIVE = "радиочастотной гарнитуры шахтёрского врача",
		ACCUSATIVE = "радиочастотную гарнитуру шахтёрского врача",
		INSTRUMENTAL = "радиочастотной гарнитурой шахтёрского врача",
		PREPOSITIONAL = "радиочастотной гарнитуре шахтёрского врача"
	)
	icon_state = "minmed_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_mining_medic

/obj/item/radio/headset/heads/ai_integrated/is_listening()
	if(disabledAi)
		return FALSE
	return ..()

/obj/item/radio/headset/all_channels // Its only feature is all channels.
	ks1type = /obj/item/encryptionkey/admin

/* Currently unusable due to language refactoring
/obj/item/radio/headset/event_1
	desc = "A headset linked to special long range alpha frequency in this sector."
	icon_state = "headset"
	item_state = "headset"
	ks1type = /obj/item/encryptionkey/event_1
	requires_tcomms = FALSE
	instant = TRUE
	freqlock = TRUE

/obj/item/radio/headset/event_2
	desc = "A headset linked to special long range beta frequency in this sector."
	icon_state = "headset"
	item_state = "headset"
	ks1type = /obj/item/encryptionkey/event_2
	requires_tcomms = FALSE
	instant = TRUE
	freqlock = TRUE

/obj/item/radio/headset/event_3
	desc = "A headset linked to special long range gamma frequency in this sector."
	icon_state = "headset"
	item_state = "headset"
	ks1type = /obj/item/encryptionkey/event_3
	requires_tcomms = FALSE
	instant = TRUE
	freqlock = TRUE
*/


/obj/item/radio/headset/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/encryptionkey))
		if(loc == user && (user.check_obscured_slots() & user.get_slot_by_item(src)))
			to_chat(user, span_warning("Your equipment prevents you from doing this!"))
			return ATTACK_CHAIN_PROCEED
		add_fingerprint(user)
		user.set_machine(src)
		if(keyslot1 && keyslot2)
			to_chat(user, span_warning("The headset can't hold another key!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		if(keyslot1)
			keyslot2 = I
		else
			keyslot1 = I
		recalculateChannels()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/radio/headset/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(ishuman(user) && loc == user)
		var/mob/living/carbon/human/H_user = user
		if(H_user.check_obscured_slots() & H_user.get_slot_by_item(src))
			to_chat(user, span_warning("Your equipment prevents you from doing this!"))
			return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	user.set_machine(src)
	if(keyslot1 || keyslot2)

		for(var/ch_name in channels)
			SSradio.remove_object(src, SSradio.radiochannels[ch_name])
			secure_radio_connections[ch_name] = null

		if(keyslot1)
			var/turf/T = get_turf(user)
			if(T)
				keyslot1.loc = T
				keyslot1 = null
		if(keyslot2)
			var/turf/T = get_turf(user)
			if(T)
				keyslot2.loc = T
				keyslot2 = null

		recalculateChannels()
		to_chat(user, "You pop out the encryption keys in the headset!")
		I.play_tool_sound(user, I.tool_volume)
	else
		to_chat(user, "This headset doesn't have any encryption keys!  How useless...")

/obj/item/radio/headset/recalculateChannels(setDescription = FALSE)
	channels = list()
	translate_binary = FALSE
	translate_hive = FALSE
	syndiekey = null

	if(keyslot1)
		for(var/ch_name in keyslot1.channels)
			if(ch_name in channels)
				continue
			channels += ch_name
			channels[ch_name] = keyslot1.channels[ch_name]

		if(keyslot1.translate_binary)
			translate_binary = TRUE

		if(keyslot1.translate_hive)
			translate_hive = TRUE

		if(keyslot1.syndie)
			syndiekey = keyslot1

	if(keyslot2)
		for(var/ch_name in keyslot2.channels)
			if(ch_name in channels)
				continue
			channels += ch_name
			channels[ch_name] = keyslot2.channels[ch_name]

		if(keyslot2.translate_binary)
			translate_binary = TRUE

		if(keyslot2.translate_hive)
			translate_hive = TRUE

		if(keyslot2.syndie)
			syndiekey = keyslot2


	for(var/ch_name in channels)
		if(!SSradio)
			name = "broken radio headset"
			return

		secure_radio_connections[ch_name] = SSradio.add_object(src, SSradio.radiochannels[ch_name],  RADIO_CHAT)

	if(setDescription)
		setupRadioDescription()

	return

/obj/item/radio/headset/proc/setupRadioDescription()
	var/radio_text = ""
	for(var/i = 1 to channels.len)
		var/channel = channels[i]
		var/key = get_radio_key_from_channel(channel)
		radio_text += "[key] - [channel]"
		if(i != channels.len)
			radio_text += ", "

	radio_desc = radio_text

/obj/item/radio/headset/proc/make_syndie() // Turns normal radios into Syndicate radios!
	qdel(keyslot1)
	keyslot1 = new /obj/item/encryptionkey/syndicate
	syndiekey = keyslot1
	recalculateChannels()

/obj/item/bowman_conversion_tool
	name = "bowman headset conversion tool"
	desc = "Easy-to-apply device which enchances headset with loud noise protection."
	icon = 'icons/obj/radio.dmi'
	icon_state = "bowman_conversion_tool"
	var/static/list/valid_headset_types
	var/static/list/forbidden_headset_types = list(
		/obj/item/radio/headset/syndicate,
		/obj/item/radio/headset/ninja,
		/obj/item/radio/headset/abductor
	)
	var/static/list/forbidden_headset_typecache

/obj/item/bowman_conversion_tool/Initialize(mapload)
	. = ..()
	if(!forbidden_headset_typecache)
		forbidden_headset_typecache = list()
		for(var/path in forbidden_headset_types)
			forbidden_headset_typecache += typecacheof(path)

	if(!valid_headset_types)
		valid_headset_types = list()
		for(var/headset in subtypesof(/obj/item/radio/headset))
			var/obj/item/radio/headset/temp = headset
			if(initial(temp.item_flags) & BANGPROTECT_MINOR)
				if(headset in forbidden_headset_typecache)
					continue
				valid_headset_types[initial(temp.name)] = temp

/obj/item/bowman_conversion_tool/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!istype(target, /obj/item/radio/headset))
		return
	if(!proximity)
		return
	var/headset_name = input("Please, select a mask!", "Bowman headset", null, null) as null|anything in valid_headset_types
	if(!headset_name)
		to_chat(user, span_notice("You decided not to convert your headset yet."))
		return
	var/obj/item/radio/headset/headset = target
	headset.item_flags |= BANGPROTECT_MINOR
	to_chat(user, span_notice("You selected [headset_name]. Now it's protected against loud noises."))
	var/headset_path = valid_headset_types[headset_name]
	var/obj/item/radio/headset/mask = headset_path
	headset.name = initial(mask.name)
	headset.desc = initial(mask.desc)
	headset.icon = initial(mask.icon)
	headset.icon_state = initial(mask.icon_state)
	qdel(src)
