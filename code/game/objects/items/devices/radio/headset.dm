/obj/item/radio/headset
	name = "radio headset"
	desc = "Радиочастотная гарнитура общего назначения, использующая телекоммуникационные системы \
			для поддержания двусторонней связи по основной частоте объекта."
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
	equip_sound = 'sound/items/handling/equip/generic_equip4.ogg'
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
		. += span_notice("<b>Доступные частоты:</b>")
		. += span_notice("[radio_desc]")

/obj/item/radio/headset/handle_message_mode(mob/living/M, list/message_pieces, channel)
	if(channel == SPEC_FREQ_NAME)
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
	desc = "Тактическая гарнитура, разработанная по военным технологиям. \
			Система активного шумоподавления защищает органы слуха пользователя от громких звуков. \
			Встроенное телекоммуникационное оборудование позволяет поддерживать двустороннюю связь по основной частоте объекта."
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
	desc = "Тактическая гарнитура, разработанная по технологиям Синдиката. \
			Система активного шумоподавления защищает органы слуха пользователя от громких звуков. \
			Использует особые протоколы связи для доступа к зашифрованным каналам Синдиката и прослушивания закрытых каналов НаноТрейзен. \
			Работает автономно без необходимости прямого подключения к местным телекоммуникационным системам."
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
	desc = "Тактическая гарнитура, разработанная по технологиям Синдиката. \
			Система активного шумоподавления защищает органы слуха пользователя от громких звуков. \
			Использует особые протоколы связи для доступа к зашифрованным каналам Синдиката и прослушивания закрытых каналов НаноТрейзен. \
			Работает автономно без необходимости прямого подключения к местным телекоммуникационным системам. \
			Специальная модель для сотрудников Синдиката, оперирующих на поверхности Лазиса."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Синдиката (Лазис)",
		GENITIVE = "тактическую гарнитуру Синдиката (Лазис)",
		DATIVE = "тактической гарнитуры Синдиката (Лазис)",
		ACCUSATIVE = "тактическую гарнитуру Синдиката (Лазис)",
		INSTRUMENTAL = "тактической гарнитурой Синдиката (Лазис)",
		PREPOSITIONAL = "тактической гарнитуре Синдиката (Лазис)"
	)

/obj/item/radio/headset/syndicate/alt/lavaland/New()
	. = ..()
	set_frequency(SYND_FREQ)

/obj/item/radio/headset/syndicate/admin_officer
	name = "syndicate officer's headset"
	desc = "Тактическая гарнитура, разработанная по технологиям Синдиката. \
			Система активного шумоподавления защищает органы слуха пользователя от громких звуков. \
			Использует особые протоколы связи для доступа к зашифрованным каналам Синдиката и прослушивания закрытых каналов НаноТрейзен. \
			Работает автономно без необходимости прямого подключения к местным телекоммуникационным системам. \
			Элитная модель, созданная для командного состава Синдиката."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Офицера Синдиката",
		GENITIVE = "тактическую гарнитуру Офицера Синдиката",
		DATIVE = "тактической гарнитуры Офицера Синдиката",
		ACCUSATIVE = "тактическую гарнитуру Офицера Синдиката",
		INSTRUMENTAL = "тактической гарнитурой Офицера Синдиката",
		PREPOSITIONAL = "тактической гарнитуре Офицера Синдиката"
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
	desc = "Тактическая гарнитура, разработанная по технологиям Синдиката. \
			Система активного шумоподавления защищает органы слуха пользователя от громких звуков. \
			Использует особые протоколы связи для доступа к зашифрованным каналам Синдиката и прослушивания закрытых каналов НаноТрейзен. \
			Работает автономно без необходимости прямого подключения к местным телекоммуникационным системам. \
			Специальная модель для сотрудников Синдиката, оперирующих в секторе Эпсилон Лукусты."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Синдиката (Тайпан)",
		GENITIVE = "тактическую гарнитуру Синдиката (Тайпан)",
		DATIVE = "тактической гарнитуры Синдиката (Тайпан)",
		ACCUSATIVE = "тактическую гарнитуру Синдиката (Тайпан)",
		INSTRUMENTAL = "тактической гарнитурой Синдиката (Тайпан)",
		PREPOSITIONAL = "тактической гарнитуре Синдиката (Тайпан)"
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
	name = "Soviet bowman headset"
	desc = "Тактическая гарнитура, разработанная по технологиям СССП. \
			Система активного шумоподавления защищает органы слуха пользователя от громких звуков. \
			Использует особые протоколы связи для доступа к военным частотам сил СССП. \
			Работает автономно без необходимости прямого подключения к местным телекоммуникационным системам."
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
	desc = "Радиочастотная гарнитура, выполненная из ударопрочного полимера. \
			Поддерживает двустороннюю связь по зашифрованным частотам объекта. \
			Используется сотрудниками местной службы безопасности."
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
	desc = "Тактическая гарнитура, выполненная из передовых ударопрочных полимеров. \
			Система активного шумоподавления защищает органы слуха пользователя от громких звуков в боевых и чрезвычайных ситуациях. \
			Встроенное телекоммуникационное оборудование позволяет поддерживать устойчивую двустороннюю связь \
			по зашифрованным частотам объекта в условиях повышенного уровня внешнего шума. \
			Используется сотрудниками местной службы безопасности."
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
	desc = "Тактическая гарнитура, выполненная из антисептического пластика повышенной прочности. \
			Система активного шумоподавления защищает органы слуха пользователя от громких звуков. \
			Встроенное телекоммуникационное оборудование позволяет поддерживать двустороннюю связь по частотам медицинского персонала и \
			службой безопасности. Используется медицинскими сотрудниками в составе местной службы безопасности."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Бригмедика",
		GENITIVE = "тактическую гарнитуру Бригмедика",
		DATIVE = "тактической гарнитуры Бригмедика",
		ACCUSATIVE = "тактическую гарнитуру Бригмедика",
		INSTRUMENTAL = "тактической гарнитурой Бригмедика",
		PREPOSITIONAL = "тактической гарнитуре Бригмедика"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"
	ks2type = /obj/item/encryptionkey/headset_medsec

/obj/item/radio/headset/headset_iaa
	name = "internal affairs radio headset"
	desc = "Радиочастотная гарнитура, выполненная из ударопрочного полимера. \
			Поддерживает двустороннюю связь по зашифрованным частотам объекта. \
			Используется местным юридическим персоналом."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура Агента Внутренних Дел",
		GENITIVE = "радиочастотную гарнитуру Агента Внутренних Дел",
		DATIVE = "радиочастотной гарнитуры Агента Внутренних Дел",
		ACCUSATIVE = "радиочастотную гарнитуру Агента Внутренних Дел",
		INSTRUMENTAL = "радиочастотной гарнитурой Агента Внутренних Дел",
		PREPOSITIONAL = "радиочастотной гарнитуре Агента Внутренних Дел"
	)
	icon_state = "sec_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_iaa

/obj/item/radio/headset/headset_iaa/alt
	name = "internal affairs bowman headset"
	desc = "Тактическая гарнитура, выполненная из ударопрочного полимера. \
			Система активного шумоподавления защищает органы слуха пользователя от громких звуков. \
			Встроенное телекоммуникационное оборудование позволяет поддерживать устойчивую двустороннюю связь \
			по зашифрованным частотам объекта. Используется местным юридическим персоналом."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Агента Внутренних Дел",
		GENITIVE = "тактическую гарнитуру Агента Внутренних Дел",
		DATIVE = "тактической гарнитуры Агента Внутренних Дел",
		ACCUSATIVE = "тактическую гарнитуру Агента Внутренних Дел",
		INSTRUMENTAL = "тактической гарнитурой Агента Внутренних Дел",
		PREPOSITIONAL = "тактической гарнитуре Агента Внутренних Дел"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"

/obj/item/radio/headset/headset_eng
	name = "engineering radio headset"
	desc = "Высокопрочная радиочастотная гарнитура, устойчивая к термическому и механическому воздействиям. \
			Поддерживает двустороннюю связь по зашифрованным частотам, \
			подключена к системе оповещений инженерного оборудования. \
			Используется местным инженерным персоналом."
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
	desc = "Радиочастотная гарнитура, оснащённая защитой от электромагнитных помех. \
			Поддерживает двустороннюю связь по зашифрованным частотам объекта. \
			Используется местными робототехниками."
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
	desc = "Радиочастотная гарнитура, выполненная из антисептического пластика, устойчивого к биологическим загрязнениям. \
			Поддерживает двустороннюю связь по зашифрованным частотам объекта. \
			Используется местным медицинским персоналом."
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
	desc = "Высокопрочная радиочастотная гарнитура, устойчивая к \
			биологическому, термическому, химическому и механическому воздействиям. \
			Поддерживает двустороннюю связь по зашифрованным частотам, \
			подключена к исследовательским системам объекта. \
			Используется местным научным персоналом."
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
	desc = "Высокопрочная радиочастотная гарнитура, устойчивая к биологическим и химическим факторам. \
			Поддерживает двустороннюю связь по зашифрованным частотам, \
			подключена к частотам медицинского и научного отделов. \
			Используется местными сотрудниками, работающими на периферии медицинской и научной деятельности."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура научного и медицинского отделов",
		GENITIVE = "радиочастотную гарнитуру научного и медицинского отделов",
		DATIVE = "радиочастотной гарнитуры научного и медицинского отделов",
		ACCUSATIVE = "радиочастотную гарнитуру научного и медицинского отделов",
		INSTRUMENTAL = "радиочастотной гарнитурой научного и медицинского отделов",
		PREPOSITIONAL = "радиочастотной гарнитуре научного и медицинского отделов"
	)
	icon_state = "medsci_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_medsci

/obj/item/radio/headset/headset_com
	name = "command radio headset"
	desc = "Специализированная радиочастотная гарнитура, выполненная из ударопрочных полимеров. \
			Оснащена улучшенным телекоммуникационным оборудованием, \
			обеспечивающим выдающееся качество связи для контроля ситуации в реальном времени. \
			Используется местным командным составом."
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
	desc = "Элитная радиочастотная гарнитура, выполненная из титано-алюминевого сплава с покрытием, устойчивым к широкому спектру воздействий. \
			Встроенные телекоммуникационные протоколы поддерживают двустороннюю связь по всем частотам объекта, \
			обеспечиваяя контроль над ситуацией в реальном времени. Используется местным Капитаном."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура Капитана",
		GENITIVE = "радиочастотную гарнитуру Капитана",
		DATIVE = "радиочастотной гарнитуры Капитана",
		ACCUSATIVE = "радиочастотную гарнитуру Капитана",
		INSTRUMENTAL = "радиочастотной гарнитурой Капитана",
		PREPOSITIONAL = "радиочастотной гарнитуре Капитана"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/captain

/obj/item/radio/headset/heads/captain/alt
	name = "\proper the captain's bowman headset"
	desc = "Элитная тактическая гарнитура, выполненная из передовых титано-алюминиевых сплавов с каркасом из композитных полимеров. \
			Система активного шумоподавления поддерживает громкость окружения на комфортном уровне, \
			защищая органы слуха пользователя от громких звуков и обеспечивая отличную слышимость. \
			Встроенное телекоммуникационное оборудование позволяет поддерживать \
			устойчивую двустороннюю связь высокого качества по всем частотам объекта. \
			Используется местным Капитаном."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Капитана",
		GENITIVE = "тактическую гарнитуру Капитана",
		DATIVE = "тактической гарнитуры Капитана",
		ACCUSATIVE = "тактическую гарнитуру Капитана",
		INSTRUMENTAL = "тактической гарнитурой Капитана",
		PREPOSITIONAL = "тактической гарнитуре Капитана"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/rd
	name = "Research Director's headset"
	desc = "Специализированная радиочастотная гарнитура, выполненная из композитных материалов, \
			устойчивых к биологическому, термическому, химическому и механическому воздействиям. \
			Встроенные телекоммуникационные протоколы поддерживают \
			двустороннюю связь с исследовательским оборудованием, \
			а также обеспечивают доступ к командным и научным частотам. \
			Используется местным Научным Руководителем."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура Научного Руководителя",
		GENITIVE = "радиочастотную гарнитуру Научного Руководителя",
		DATIVE = "радиочастотной гарнитуры Научного Руководителя",
		ACCUSATIVE = "радиочастотную гарнитуру Научного Руководителя",
		INSTRUMENTAL = "радиочастотной гарнитурой Научного Руководителя",
		PREPOSITIONAL = "радиочастотной гарнитуре Научного Руководителя"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/rd

/obj/item/radio/headset/heads/hos
	name = "head of security's headset"
	desc = "Специализированная радиочастотная гарнитура, выполненная из титано-алюминевого сплава, \
			устойчивого к экстремальным механическим воздействиям. \
			Встроенные телекоммуникационные протоколы поддерживают двустороннюю связь по зашифрованным частотам объекта, \
			обеспечивая отличное качество коммуникации с составом службы безопасности и командования в реальном времени. \
			Используется местным Главой Службы Безопасности."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура Главы Службы Безопасности",
		GENITIVE = "радиочастотную гарнитуру Главы Службы Безопасности",
		DATIVE = "радиочастотной гарнитуры Главы Службы Безопасности",
		ACCUSATIVE = "радиочастотную гарнитуру Главы Службы Безопасности",
		INSTRUMENTAL = "радиочастотной гарнитурой Главы Службы Безопасности",
		PREPOSITIONAL = "радиочастотной гарнитуре Главы Службы Безопасности"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/hos

/obj/item/radio/headset/heads/hos/alt
	name = "\proper the head of security's bowman headset"
	desc = "Специализированная тактическая гарнитура, выполненная из титано-алюминевого сплава с каркасом из композитного полимера. \
			Система активного шумоподавления поддерживает громкость окружения на комфортном уровне, \
			защищая органы слуха пользователя от громких звуков и обеспечивая \
			отличную слышимость в условиях интенсивного боя. \
			Встроенное телекоммуникационное оборудование позволяет поддерживать \
			связь с составом службы безопасности и командным составом в реальном времени. \
			Используется местным Главой Службы Безопасности."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Главы Службы Безопасности",
		GENITIVE = "тактическую гарнитуру Главы Службы Безопасности",
		DATIVE = "тактической гарнитуры Главы Службы Безопасности",
		ACCUSATIVE = "тактическую гарнитуру Главы Службы Безопасности",
		INSTRUMENTAL = "тактической гарнитурой Главы Службы Безопасности",
		PREPOSITIONAL = "тактической гарнитуре Главы Службы Безопасности"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/ce
	name = "chief engineer's headset"
	desc = "Специализированная радиочастотная гарнитура, выполненная из композитных материалов, \
			устойчивых к термическому и механическому воздействиям. \
			Встроенные телекоммуникационные протоколы поддерживают \
			двустороннюю связь с системой оповещений инженерного оборудования, \
			а также инженерной и командной частотами. Используется местным Главным Инженером."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура Главного Инженера",
		GENITIVE = "радиочастотную гарнитуру Главного Инженера",
		DATIVE = "радиочастотной гарнитуры Главного Инженера",
		ACCUSATIVE = "радиочастотную гарнитуру Главного Инженера",
		INSTRUMENTAL = "радиочастотной гарнитурой Главного Инженера",
		PREPOSITIONAL = "радиочастотной гарнитуре Главного Инженера"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/ce

/obj/item/radio/headset/heads/cmo
	name = "chief medical officer's headset"
	desc = "Специализированная радиочастотная гарнитура, выполненная из \
			антисептического пластика, устойчивого к биологическим загрязнениям. \
			Встроенные телекоммуникационные протоколы поддерживают \
			двустороннюю связь с медицинской и командной частотами. \
			Используется местным Главным Врачом."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура Главного Врача",
		GENITIVE = "радиочастотную гарнитуру Главного Врача",
		DATIVE = "радиочастотной гарнитуры Главного Врача",
		ACCUSATIVE = "радиочастотную гарнитуру Главного Врача",
		INSTRUMENTAL = "радиочастотной гарнитурой Главного Врача",
		PREPOSITIONAL = "радиочастотной гарнитуре Главного Врача"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/cmo

/obj/item/radio/headset/heads/hop
	name = "head of personnel's headset"
	desc = "Специализированная радиочастотная гарнитура, выполненная из ударопрочных полимеров. \
			Оснащена улучшенным телекоммуникационным оборудованием, \
			обеспечивающим доступ к частотам обслуживающего персонала и командования. \
			Используется местным Главой Персонала."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура Главы Персонала",
		GENITIVE = "радиочастотную гарнитуру Главы Персонала",
		DATIVE = "радиочастотной гарнитуры Главы Персонала",
		ACCUSATIVE = "радиочастотную гарнитуру Главы Персонала",
		INSTRUMENTAL = "радиочастотной гарнитурой Главы Персонала",
		PREPOSITIONAL = "радиочастотной гарнитуре Главы Персонала"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/hop

/obj/item/radio/headset/heads/qm
	name = "quartermaster's headset"
	desc = "Специализированная радиочастотная гарнитура, выполненная из ударопрочных полимеров, \
			обеспечивающих защиту от термических и механических воздействий. \
			Оснащена улучшенным телекоммуникационным оборудованием, \
			обеспечивающим доступ к частотам снабжения и командования. \
			Используется местным Квартирмейстеромом."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура Квартирмейстера",
		GENITIVE = "радиочастотную гарнитуру Квартирмейстера",
		DATIVE = "радиочастотной гарнитуры Квартирмейстера",
		ACCUSATIVE = "радиочастотную гарнитуру Квартирмейстера",
		INSTRUMENTAL = "радиочастотной гарнитурой Квартирмейстера",
		PREPOSITIONAL = "радиочастотной гарнитуре Квартирмейстера"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/qm

/obj/item/radio/headset/headset_cargo
	name = "supply radio headset"
	desc = "Высокопрочная радиочастотная гарнитура, устойчивая к механическому воздействию. \
			Поддерживает двустороннюю связь по зашифрованным частотам отдела снабжения. \
			Несмотря на дизайн, схожий с тактическими гарнитурами, не обладает системой шумоподавления \
			и не защищает органы слуха от громких звуков. \
			Используется местным персоналом отдела снабжения."
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
	desc = "Высокопрочная радиочастотная гарнитура, устойчивая к механическому и термическому воздействиям. \
			Поддерживает двустороннюю связь по зашифрованным частотам отдела снабжения. \
			Оснащена системой защиты от пылевого засорения. \
			Используется местными шахтёрами."
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
	desc = "Радиочастотная гарнитура, поддерживающая двустороннюю связь \
			по зашифрованным частотам отдела обслуживания. \
			Используется местным обслуживающим персоналом."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура отдела обслуживания",
		GENITIVE = "радиочастотную гарнитуру отдела обслуживания",
		DATIVE = "радиочастотной гарнитуры отдела обслуживания",
		ACCUSATIVE = "радиочастотную гарнитуру отдела обслуживания",
		INSTRUMENTAL = "радиочастотной гарнитурой отдела обслуживания",
		PREPOSITIONAL = "радиочастотной гарнитуре отдела обслуживания"
	)
	icon_state = "srv_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_service

/obj/item/radio/headset/heads/ntrep
	name = "nanotrasen representative's headset"
	desc = "Специализированная радиочастотная гарнитура, выполненная из ударопрочных полимеров. \
			Оснащена улучшенным телекоммуникационным оборудованием, \
			обеспечивающим доступ к большей части зашифрованных частот объекта. \
			Используется местным Представителем НаноТрейзен."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура Представителя НаноТрейзен",
		GENITIVE = "радиочастотную гарнитуру Представителя НаноТрейзен",
		DATIVE = "радиочастотной гарнитуры Представителя НаноТрейзен",
		ACCUSATIVE = "радиочастотную гарнитуру Представителя НаноТрейзен",
		INSTRUMENTAL = "радиочастотной гарнитурой Представителя НаноТрейзен",
		PREPOSITIONAL = "радиочастотной гарнитуре Представителя НаноТрейзен"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/ntrep

/obj/item/radio/headset/heads/magistrate
	name = "magistrate's headset"
	desc = "Специализированная радиочастотная гарнитура, выполненная из ударопрочных полимеров. \
			Оснащена улучшенным телекоммуникационным оборудованием, \
			обеспечивающим доступ к зашифрованным частотам объекта \
			для коммуникации по вопросам права. Используется местным Магистратом."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура Магистрата",
		GENITIVE = "радиочастотную гарнитуру Магистрата",
		DATIVE = "радиочастотной гарнитуры Магистрата",
		ACCUSATIVE = "радиочастотную гарнитуру Магистрата",
		INSTRUMENTAL = "радиочастотной гарнитурой Магистрата",
		PREPOSITIONAL = "радиочастотной гарнитуре Магистрата"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/magistrate

/obj/item/radio/headset/heads/magistrate/alt
	name = "\proper magistrate's bowman headset"
	desc = "Специализированная тактическая гарнитура, выполненная из композитных полимеров. \
			Система активного шумоподавления защищает органы слуха пользователя от громких звуков. \
			Встроенное телекоммуникационное оборудование позволяет поддерживать устойчивую двустороннюю связь \
			по зашифрованным частотам объекта для коммуникации по правовым вопросам. \
			Используется местным Магистратом."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Магистрата",
		GENITIVE = "тактическую гарнитуру Магистрата",
		DATIVE = "тактической гарнитуры Магистрата",
		ACCUSATIVE = "тактическую гарнитуру Магистрата",
		INSTRUMENTAL = "тактической гарнитурой Магистрата",
		PREPOSITIONAL = "тактической гарнитуре Магистрата"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/blueshield
	name = "blueshield's headset"
	desc = "Специализированная радиочастотная гарнитура, выполненная из титано-алюминевого сплава, \
			устойчивого к экстремальным механическим воздействиям. \
			Встроенные телекоммуникационные протоколы поддерживают двустороннюю связь по зашифрованным частотам объекта, \
			обеспечивая отличное качество коммуникации с командным составом. \
			Используется местным Офицером \"Синий Щит\"."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура Офицера \"Синий Щит\"",
		GENITIVE = "радиочастотную гарнитуру Офицера \"Синий Щит\"",
		DATIVE = "радиочастотной гарнитуры Офицера \"Синий Щит\"",
		ACCUSATIVE = "радиочастотную гарнитуру Офицера \"Синий Щит\"",
		INSTRUMENTAL = "радиочастотной гарнитурой Офицера \"Синий Щит\"",
		PREPOSITIONAL = "радиочастотной гарнитуре Офицера \"Синий Щит\""
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/blueshield

/obj/item/radio/headset/heads/blueshield/alt
	name = "\proper blueshield's bowman headset"
	desc = "Специализированная тактическая гарнитура, выполненная из титано-алюминевого сплава с каркасом из композитного полимера. \
			Система активного шумоподавления поддерживает громкость окружения на комфортном уровне, \
			защищая органы слуха пользователя от громких звуков и обеспечивая \
			отличную слышимость в условиях интенсивного боя. \
			Встроенное телекоммуникационное оборудование позволяет поддерживать \
			связь с командным составом в реальном времени. \
			Используется местным Офицером \"Синий Щит\"."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Офицера \"Синий Щит\"",
		GENITIVE = "тактическую гарнитуру Офицера \"Синий Щит\"",
		DATIVE = "тактической гарнитуры Офицера \"Синий Щит\"",
		ACCUSATIVE = "тактическую гарнитуру Офицера \"Синий Щит\"",
		INSTRUMENTAL = "тактической гарнитурой Офицера \"Синий Щит\"",
		PREPOSITIONAL = "тактической гарнитуре Офицера \"Синий Щит\""
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/ert
	name = "emergency response team headset"
	desc = "Элитная радиочастотная гарнитура, выполненная из титано-алюминевого сплава с покрытием, устойчивым к широкому спектру воздействий. \
			Встроенные телекоммуникационные протоколы поддерживают двустороннюю связь по всем частотам объекта и \
			закрытой частоте ОБР, обеспечивая контроль над ситуацией в реальном времени. \
			Работает автономно без необходимости прямого подключения к местным телекоммуникационным системам. \
			Используется Оперативниками ОБР."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура Оперативника ОБР",
		GENITIVE = "радиочастотную гарнитуру Оперативника ОБР",
		DATIVE = "радиочастотной гарнитуры Оперативника ОБР",
		ACCUSATIVE = "радиочастотную гарнитуру Оперативника ОБР",
		INSTRUMENTAL = "радиочастотной гарнитурой Оперативника ОБР",
		PREPOSITIONAL = "радиочастотной гарнитуре Оперативника ОБР"
	)
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/ert
	freqlock = TRUE

/obj/item/radio/headset/ert/alt
	name = "emergency response team's bowman headset"
	desc = "Элитная тактическая гарнитура, выполненная из передовых титано-алюминиевых сплавов с каркасом из композитных полимеров. \
			Система активного шумоподавления поддерживает громкость окружения на комфортном уровне, \
			защищая органы слуха пользователя от громких звуков и обеспечивая отличную слышимость в условиях интенсивного боя. \
			Встроенные телекоммуникационные протоколы поддерживают двустороннюю связь по всем частотам объекта и \
			закрытой частоте ОБР, обеспечивая контроль над ситуацией в реальном времени. \
			Используется Оперативниками ОБР."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Оперативника ОБР",
		GENITIVE = "тактическую гарнитуру Оперативника ОБР",
		DATIVE = "тактической гарнитуры Оперативника ОБР",
		ACCUSATIVE = "тактическую гарнитуру Оперативника ОБР",
		INSTRUMENTAL = "тактической гарнитурой Оперативника ОБР",
		PREPOSITIONAL = "тактической гарнитуре Оперативника ОБР"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/ert/alt/solgov
	name = "Trans-Solar Federation Marine's bowman headset"
	desc = "Элитная тактическая гарнитура, выполненная из передовых титано-алюминиевых сплавов с каркасом из композитных полимеров. \
			Система активного шумоподавления поддерживает громкость окружения на комфортном уровне, \
			защищая органы слуха пользователя от громких звуков и обеспечивая отличную слышимость в условиях интенсивного боя. \
			Встроенные телекоммуникационные протоколы поддерживают двустороннюю связь по всем частотам объекта и \
			закрытой частоте отряда морской пехоты, обеспечивая контроль над ситуацией в реальном времени. \
			Используется личным составом Корпуса Морской Пехоты ТСФ."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура КМП ТСФ",
		GENITIVE = "тактическую гарнитуру КМП ТСФ",
		DATIVE = "тактической гарнитуры КМП ТСФ",
		ACCUSATIVE = "тактическую гарнитуру КМП ТСФ",
		INSTRUMENTAL = "тактической гарнитурой КМП ТСФ",
		PREPOSITIONAL = "тактической гарнитуре КМП ТСФ"
	)

/obj/item/radio/headset/ert/alt/commander
	name = "ERT commander's bowman headset"
	desc = "Элитная тактическая гарнитура, выполненная из передовых титано-алюминиевых сплавов с каркасом из композитных полимеров. \
			Система активного шумоподавления поддерживает громкость окружения на комфортном уровне, \
			защищая органы слуха пользователя от громких звуков и обеспечивая отличную слышимость в условиях интенсивного боя. \
			Встроенные телекоммуникационные протоколы поддерживают двустороннюю связь по всем частотам объекта и \
			закрытой частоте ОБР, обеспечивая контроль над ситуацией в реальном времени. \
			Работает автономно без необходимости прямого подключения к местным телекоммуникационным системам. \
			Используется Командиром ОБР."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Командира ОБР",
		GENITIVE = "тактическую гарнитуру Командира ОБР",
		DATIVE = "тактической гарнитуры Командира ОБР",
		ACCUSATIVE = "тактическую гарнитуру Командира ОБР",
		INSTRUMENTAL = "тактической гарнитурой Командира ОБР",
		PREPOSITIONAL = "тактической гарнитуре Командира ОБР"
	)
	requires_tcomms = FALSE
	instant = TRUE

/obj/item/radio/headset/ert/alt/commander/solgov
	name = "Trans-Solar Federation Lieutenant's bowman headset"
	desc = "Элитная тактическая гарнитура, выполненная из передовых титано-алюминиевых сплавов с каркасом из композитных полимеров. \
			Система активного шумоподавления поддерживает громкость окружения на комфортном уровне, \
			защищая органы слуха пользователя от громких звуков и обеспечивая отличную слышимость в условиях интенсивного боя. \
			Встроенные телекоммуникационные протоколы поддерживают двустороннюю связь по всем частотам объекта и \
			закрытой частоте отряда морской пехоты, обеспечивая контроль над ситуацией в реальном времени. \
			Работает автономно без необходимости прямого подключения к местным телекоммуникационным системам. \
			Используется Лейтенантами ТСФ."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Лейтенанта ТСФ",
		GENITIVE = "тактическую гарнитуру Лейтенанта ТСФ",
		DATIVE = "тактической гарнитуры Лейтенанта ТСФ",
		ACCUSATIVE = "тактическую гарнитуру Лейтенанта ТСФ",
		INSTRUMENTAL = "тактической гарнитурой Лейтенанта ТСФ",
		PREPOSITIONAL = "тактической гарнитуре Лейтенанта ТСФ"
	)

/obj/item/radio/headset/centcom
	name = "\proper centcom officer's bowman headset"
	desc = "Элитная тактическая гарнитура, выполненная из передовых титано-алюминиевых сплавов с каркасом из композитных полимеров. \
			Система активного шумоподавления поддерживает громкость окружения на комфортном уровне, \
			защищая органы слуха пользователя от громких звуков и обеспечивая отличную слышимость. \
			Встроенное телекоммуникационное оборудование позволяет поддерживать \
			устойчивую двустороннюю связь высокого качества по всем частотам объекта, \
			а также по закрытым частотам ОБР и Отряда Зачистки. \
			Работает автономно без необходимости прямого подключения к местным телекоммуникационным системам. \
			Используется местным Офицером ЦК."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Офицера ЦК",
		GENITIVE = "тактическую гарнитуру Офицера ЦК",
		DATIVE = "тактической гарнитуры Офицера ЦК",
		ACCUSATIVE = "тактическую гарнитуру Офицера ЦК",
		INSTRUMENTAL = "тактической гарнитурой Офицера ЦК",
		PREPOSITIONAL = "тактической гарнитуре Офицера ЦК"
	)
	item_flags = BANGPROTECT_MINOR
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"
	ks2type = /obj/item/encryptionkey/centcom
	requires_tcomms = FALSE
	instant = TRUE

/obj/item/radio/headset/centcom/solgov
	name = "Trans-Solar Federation General's bowman headset"
	desc = "Элитная тактическая гарнитура, выполненная из передовых титано-алюминиевых сплавов с каркасом из композитных полимеров. \
			Система активного шумоподавления поддерживает громкость окружения на комфортном уровне, \
			защищая органы слуха пользователя от громких звуков и обеспечивая отличную слышимость в условиях интенсивного боя. \
			Встроенное телекоммуникационное оборудование позволяет поддерживать \
			устойчивую двустороннюю связь высокого качества по всем частотам объекта, \
			а также по закрытым частотам КМП и элитных подразделений ТСФ, обеспечивая контроль над ситуацией в реальном времени. \
			Работает автономно без необходимости прямого подключения к местным телекоммуникационным системам. \
			Используется Генералами ТСФ."
	ru_names = list(
		NOMINATIVE = "тактическая гарнитура Генерала ТСФ",
		GENITIVE = "тактическую гарнитуру Генерала ТСФ",
		DATIVE = "тактической гарнитуры Генерала ТСФ",
		ACCUSATIVE = "тактическую гарнитуру Генерала ТСФ",
		INSTRUMENTAL = "тактической гарнитурой Генерала ТСФ",
		PREPOSITIONAL = "тактической гарнитуре Генерала ТСФ"
	)

/obj/item/radio/headset/heads/ai_integrated //No need to care about icons, it should be hidden inside the AI anyway.
	name = "AI subspace transceiver"
	desc = "Интегрированный радиопередатчик ИИ. \
			Обеспечивает связь с серверами, базами данных, основными частотами и \
			дополнительными зашифрованными частотами роботизированных систем объекта через защищённый интерфейс."
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "radio"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/ai_integrated
	var/myAi = null	// Atlantis: Reference back to the AI which has this radio.
	var/disabledAi = FALSE // Atlantis: Used to manually disable AI's integrated radio via intellicard menu.

/obj/item/radio/headset/headset_mining_medic
	name = "mining medic's radio headset"
	desc = "Высокопрочная радиочастотная гарнитура, изготовленная из антисептического пластика с термоустойчивым покрытием. \
			Поддерживает двустороннюю связь по зашифрованным частотам медицинского отдела и отдела снабжения. \
			Оснащена системой защиты от пылевого засорения. \
			Используется местным медицинском персоналом, работающим на поверхности Лазиса."
	ru_names = list(
		NOMINATIVE = "радиочастотная гарнитура Шахтёрского Врача",
		GENITIVE = "радиочастотную гарнитуру Шахтёрского Врача",
		DATIVE = "радиочастотной гарнитуры Шахтёрского Врача",
		ACCUSATIVE = "радиочастотную гарнитуру Шахтёрского Врача",
		INSTRUMENTAL = "радиочастотной гарнитурой Шахтёрского Врача",
		PREPOSITIONAL = "радиочастотной гарнитуре Шахтёрского Врача"
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
			user.balloon_alert(user, "закрыто одеждой!")
			return ATTACK_CHAIN_PROCEED
		add_fingerprint(user)
		user.set_machine(src)
		if(keyslot1 && keyslot2)
			user.balloon_alert(user, "слоты для ключей заняты!")
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
			user.balloon_alert(user, "закрыто одеждой!")
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
		user.balloon_alert(user, "ключ извлечён")
		I.play_tool_sound(user, I.tool_volume)
	else
		user.balloon_alert(user, "слот для ключа пуст!")

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
			ru_names = list(
				NOMINATIVE = "сломанная радиочастотная гарнитура",
				GENITIVE = "сломанную радиочастотную гарнитуру",
				DATIVE = "сломанной радиочастотной гарнитуры",
				ACCUSATIVE = "сломанную радиочастотную гарнитуру",
				INSTRUMENTAL = "сломанной радиочастотной гарнитурой",
				PREPOSITIONAL = "сломанной радиочастотной гарнитуре"
			)
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
	desc = "Инструмент для модификации радиочастотной гарнитуры в гарнитуру тактического типа."
	ru_names = list(
		NOMINATIVE = "инструмент для модификации гарнитуры",
		GENITIVE = "инструмента для модификации гарнитуры",
		DATIVE = "инструменту для модификации гарнитуры",
		ACCUSATIVE = "инструмент для модификации гарнитуры",
		INSTRUMENTAL = "инструментом для модификации гарнитуры",
		PREPOSITIONAL = "инструменте для модификации гарнитуры"
	)
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
	var/headset_name = tgui_input_list(usr, "Выберите тип гарнитуры", "Тактическая гарнитура", valid_headset_types, null)
	if(!headset_name)
		user.balloon_alert(user, "модификация прервана!")
		return
	var/obj/item/radio/headset/headset = target
	headset.item_flags |= BANGPROTECT_MINOR
	var/headset_path = valid_headset_types[headset_name]
	var/obj/item/radio/headset/mask = headset_path
	headset.name = initial(mask.name)
	headset.ru_names = initial(mask.ru_names)
	headset.desc = initial(mask.desc)
	headset.icon = initial(mask.icon)
	headset.icon_state = initial(mask.icon_state)
	to_chat(user, span_notice("Вы модифицировали гарнитуру в [headset.declent_ru(ACCUSATIVE)]. Теперь она защищает ваши органы слуха от громких звуков."))
	qdel(src)
