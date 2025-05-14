
/obj/item/encryptionkey
	name = "Standard Encryption Key"
	desc = "Ключ шифрования, устанавливаемый в гарнитуру. Содержит в себе все необходимые протоколы декодирования сигнала для прослушивания определенной частоты."
	ru_names = list(
		NOMINATIVE = "стандартный ключ-шифратор",
		GENITIVE = "стандартного ключа-шифратора",
		DATIVE = "стандартному ключу-шифратору",
		ACCUSATIVE = "стандартный ключ-шифратор",
		INSTRUMENTAL = "стандартным ключом-шифратором",
		PREPOSITIONAL = "стандартном ключе-шифраторе"
	)
	icon = 'icons/obj/radio.dmi'
	icon_state = "cypherkey"
	item_state = ""
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "engineering=2;bluespace=1"
	var/translate_binary = FALSE
	var/translate_hive = FALSE
	var/syndie = FALSE
	var/change_voice = FALSE
	var/list/channels = list()


/obj/item/encryptionkey/syndicate
	name = "syndicate encryption key"
	desc = "Ключ шифрования, устанавливаемый в гарнитуру. Содержит в себе лучшее хакерское ПО, доступное на чёрном рынке и позволяющее получить доступ ко всем частотам НаноТрейзен."
	ru_names = list(
		NOMINATIVE = "ключ-шифратор Синдиката",
		GENITIVE = "ключа-шифратора Синдиката",
		DATIVE = "ключу-шифратору Синдиката",
		ACCUSATIVE = "ключ-шифратор Синдиката",
		INSTRUMENTAL = "ключом-шифратором Синдиката",
		PREPOSITIONAL = "ключе-шифраторе Синдиката"
	)
	icon_state = "syn_cypherkey"
	channels = list("Syndicate" = 1)
	origin_tech = "syndicate=1;engineering=3;bluespace=2"
	syndie = TRUE //Signifies that it de-crypts Syndicate transmissions
	change_voice = TRUE
	var/fake_name = "Агент ЗОВИТЕ КОДЕРА"
	var/static/list/fakename_list

/obj/item/encryptionkey/syndicate/Initialize()
	if(!LAZYLEN(fakename_list))
		fakename_list = GLOB.html_colors.Copy()
	. = ..()
	if(change_voice)
		fake_name = "Агент [pick_n_take(fakename_list)]"

/obj/item/encryptionkey/syndicate/nukeops
	change_voice = FALSE

/obj/item/encryptionkey/syndicate/taipan
	change_voice = FALSE
	icon_state = "taipan_cypherkey"
	channels = list("SyndTaipan" = 1)

/obj/item/encryptionkey/syndicate/taipan/borg
	change_voice = FALSE
	icon_state = "taipan_cypherkey"
	channels = list("SyndTaipan" = 1, "Syndicate" = 1)

/obj/item/encryptionkey/syndicate/taipan/tcomms_agent
	icon_state = "ofcom_cypherkey"
	channels = list("SyndTaipan" = 1, "Syndicate" = 1, "Common" = 1)

/obj/item/encryptionkey/syndteam
	name = "syndicate encryption key"
	desc = "Ключ шифрования, устанавливаемый в гарнитуру. Содержит в себе лучшее хакерское ПО, доступное на чёрном рынке и позволяющее получить доступ ко всем частотам НаноТрейзен."
	ru_names = list(
		NOMINATIVE = "ключ-шифратор Синдиката",
		GENITIVE = "ключа-шифратора Синдиката",
		DATIVE = "ключу-шифратору Синдиката",
		ACCUSATIVE = "ключ-шифратор Синдиката",
		INSTRUMENTAL = "ключом-шифратором Синдиката",
		PREPOSITIONAL = "ключе-шифраторе Синдиката"
	)
	icon_state = "syn_cypherkey"
	channels = list("SyndTeam" = 1, "Syndicate" = 1)
	origin_tech = "syndicate=4"
	syndie = TRUE //Signifies that it de-crypts Syndicate transmissions

/obj/item/encryptionkey/soviet
	name = "\improper Soviet encryption key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор СССП",
		GENITIVE = "ключа-шифратора СССП",
		DATIVE = "ключу-шифратору СССП",
		ACCUSATIVE = "ключ-шифратор СССП",
		INSTRUMENTAL = "ключом-шифратором СССП",
		PREPOSITIONAL = "ключе-шифраторе СССП"
	)
	icon_state = "sov_cypherkey"
	channels = list("Soviet" = 1)

/obj/item/encryptionkey/binary
	name = "binary translator key"
	desc = "Ключ шифрования, устанавливаемый в гарнитуру. Содержит в себе все необходимые протоколы для декодирования бинарных сигналов, используемых синтетиками для коммуникации."
	ru_names = list(
		NOMINATIVE = "ключ-переводчик бинарного канала",
		GENITIVE = "ключа-переводчика бинарного канала",
		DATIVE = "ключу-переводчику бинарного канала",
		ACCUSATIVE = "ключ-переводчик бинарного канала",
		INSTRUMENTAL = "ключом-переводчиком бинарного канала",
		PREPOSITIONAL = "ключе-переводчике бинарного канала"
	)
	icon_state = "bin_cypherkey"
	translate_binary = TRUE
	origin_tech = "syndicate=1;engineering=4;bluespace=3"

/obj/item/encryptionkey/headset_sec
	name = "Security Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор канала охраны",
		GENITIVE = "ключа-шифратора канала охраны",
		DATIVE = "ключу-шифратор канала охраны",
		ACCUSATIVE = "ключ-шифратор канала охраны",
		INSTRUMENTAL = "ключом-шифратором канала охраны",
		PREPOSITIONAL = "ключе-шифраторе канала охраны"
	)
	icon_state = "sec_cypherkey"
	channels = list("Security" = 1)

/obj/item/encryptionkey/headset_iaa
	name = "Internal Affairs Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор агента внутренних дел",
		GENITIVE = "ключа-шифратора агента внутренних дел",
		DATIVE = "ключу-шифратору агента внутренних дел",
		ACCUSATIVE = "ключ-шифратор агента внутренних дел",
		INSTRUMENTAL = "ключом-шифратором агента внутренних дел",
		PREPOSITIONAL = "ключе-шифраторе агента внутренних дел"
	)
	icon_state = "sec_cypherkey"
	channels = list("Security" = 1, "Procedure" = 1)

/obj/item/encryptionkey/headset_eng
	name = "Engineering Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор инженерного канала",
		GENITIVE = "ключа-шифратора инженерного канала",
		DATIVE = "ключу-шифратору инженерного канала",
		ACCUSATIVE = "ключ-шифратор инженерного канала",
		INSTRUMENTAL = "ключом-шифратором инженерного канала",
		PREPOSITIONAL = "ключе-шифраторе инженерного канала"
	)
	icon_state = "eng_cypherkey"
	channels = list("Engineering" = 1)

/obj/item/encryptionkey/headset_rob
	name = "Robotics Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор робототехников",
		GENITIVE = "ключа-шифратора робототехников",
		DATIVE = "ключу-шифратору робототехников",
		ACCUSATIVE = "ключ-шифратор робототехников",
		INSTRUMENTAL = "ключом-шифратором робототехников",
		PREPOSITIONAL = "ключе-шифраторе робототехников"
	)
	icon_state = "rob_cypherkey"
	channels = list("Engineering" = 1, "Science" = 1)

/obj/item/encryptionkey/headset_med
	name = "Medical Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор медицинского канала",
		GENITIVE = "ключа-шифратора медицинского канала",
		DATIVE = "ключу-шифратору медицинского канала",
		ACCUSATIVE = "ключ-шифратор медицинского канала",
		INSTRUMENTAL = "ключом-шифратором медицинского канала",
		PREPOSITIONAL = "ключе-шифраторе медицинского канала"
	)
	icon_state = "med_cypherkey"
	channels = list("Medical" = 1)

/obj/item/encryptionkey/headset_sci
	name = "Science Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор научного канала",
		GENITIVE = "ключа-шифратора научного канала",
		DATIVE = "ключу-шифратору научного канала",
		ACCUSATIVE = "ключ-шифратор научного канала",
		INSTRUMENTAL = "ключом-шифратором научного канала",
		PREPOSITIONAL = "ключе-шифраторе научного канала"
	)
	icon_state = "sci_cypherkey"
	channels = list("Science" = 1)

/obj/item/encryptionkey/headset_medsci
	name = "Medical Research Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор научного и медицинского канала",
		GENITIVE = "ключа-шифратора научного и медицинского канала",
		DATIVE = "ключу-шифратору научного и медицинского канала",
		ACCUSATIVE = "ключ-шифратор научного и медицинского канала",
		INSTRUMENTAL = "ключом-шифратором научного и медицинского канала",
		PREPOSITIONAL = "ключе-шифраторе научного и медицинского канала"
	)
	icon_state = "medsci_cypherkey"
	channels = list("Medical" = 1, "Science" = 1)

/obj/item/encryptionkey/headset_medsec
	name = "Medical Security Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор охранного и медицинского канала",
		GENITIVE = "ключа-шифратора охранного и медицинского канала",
		DATIVE = "ключу-шифратору охранного и медицинского канала",
		ACCUSATIVE = "ключ-шифратор охранного и медицинского канала",
		INSTRUMENTAL = "ключом-шифратором охранного и медицинского канала",
		PREPOSITIONAL = "ключе-шифраторе охранного и медицинского канала"
	)
	icon_state = "sec_cypherkey"
	channels = list("Security" = 1, "Medical" = 1)

/obj/item/encryptionkey/headset_com
	name = "Command Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор командного канала",
		GENITIVE = "ключа-шифратора командного канала",
		DATIVE = "ключу-шифратору командного канала",
		ACCUSATIVE = "ключ-шифратор командного канала",
		INSTRUMENTAL = "ключом-шифратором командного канала",
		PREPOSITIONAL = "ключе-шифраторе командного канала"
	)
	icon_state = "com_cypherkey"
	channels = list("Command" = 1)

/obj/item/encryptionkey/heads/captain
	name = "Captain's Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор капитана",
		GENITIVE = "ключа-шифратора капитана",
		DATIVE = "ключу-шифратору капитана",
		ACCUSATIVE = "ключ-шифратор капитана",
		INSTRUMENTAL = "ключом-шифратором капитана",
		PREPOSITIONAL = "ключе-шифраторе капитана"
	)
	icon_state = "cap_cypherkey"
	channels = list("Command" = 1, "Security" = 1, "Engineering" = 0, "Science" = 0, "Medical" = 0, "Supply" = 0, "Service" = 0, "Procedure" = 1)

/obj/item/encryptionkey/heads/rd
	name = "Research Director's Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор научного руководителя",
		GENITIVE = "ключа-шифратора научного руководителя",
		DATIVE = "ключу-шифратору научного руководителя",
		ACCUSATIVE = "ключ-шифратор научного руководителя",
		INSTRUMENTAL = "ключом-шифратором научного руководителя",
		PREPOSITIONAL = "ключе-шифраторе научного руководителя"
	)
	icon_state = "rd_cypherkey"
	channels = list("Science" = 1, "Command" = 1)

/obj/item/encryptionkey/heads/hos
	name = "Head of Security's Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор главы службы безопасности",
		GENITIVE = "ключа-шифратора главы службы безопасности",
		DATIVE = "ключу-шифратору главы службы безопасности",
		ACCUSATIVE = "ключ-шифратор главы службы безопасности",
		INSTRUMENTAL = "ключом-шифратором главы службы безопасности",
		PREPOSITIONAL = "ключе-шифраторе главы службы безопасности"
	)
	icon_state = "hos_cypherkey"
	channels = list("Security" = 1, "Command" = 1)

/obj/item/encryptionkey/heads/ce
	name = "Chief Engineer's Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор старшего инженера",
		GENITIVE = "ключа-шифратора старшего инженера",
		DATIVE = "ключу-шифратору старшего инженера",
		ACCUSATIVE = "ключ-шифратор старшего инженера",
		INSTRUMENTAL = "ключом-шифратором старшего инженера",
		PREPOSITIONAL = "ключе-шифраторе старшего инженера"
	)
	icon_state = "ce_cypherkey"
	channels = list("Engineering" = 1, "Command" = 1)

/obj/item/encryptionkey/heads/cmo
	name = "Chief Medical Officer's Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор главного врача",
		GENITIVE = "ключа-шифратора главного врача",
		DATIVE = "ключу-шифратору главного врача",
		ACCUSATIVE = "ключ-шифратор главного врача",
		INSTRUMENTAL = "ключом-шифратором главного врача",
		PREPOSITIONAL = "ключе-шифраторе главного врача"
	)
	icon_state = "cmo_cypherkey"
	channels = list("Medical" = 1, "Command" = 1)

/obj/item/encryptionkey/heads/hop
	name = "Head of Personnel's Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор главы персонала",
		GENITIVE = "ключа-шифратора главы персонала",
		DATIVE = "ключу-шифратору главы персонала",
		ACCUSATIVE = "ключ-шифратор главы персонала",
		INSTRUMENTAL = "ключом-шифратором главы персонала",
		PREPOSITIONAL = "ключе-шифраторе главы персонала"
	)
	icon_state = "hop_cypherkey"
	channels = list("Service" = 1, "Security" = 0, "Command" = 1)

/obj/item/encryptionkey/heads/qm
	name = "Quartermaster's Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор завхоза",
		GENITIVE = "ключа-шифратора завхоза",
		DATIVE = "ключу-шифратору завхоза",
		ACCUSATIVE = "ключ-шифратор завхоза",
		INSTRUMENTAL = "ключом-шифратором завхоза",
		PREPOSITIONAL = "ключе-шифраторе завхоза"
	)
	icon_state = "cargo_cypherkey"
	channels = list("Supply" = 1, "Command" = 1)

/obj/item/encryptionkey/heads/ntrep
	name = "Nanotrasen Representative's Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор представителя НаноТрейзен",
		GENITIVE = "ключа-шифратора представителя НаноТрейзен",
		DATIVE = "ключу-шифратору представителя НаноТрейзен",
		ACCUSATIVE = "ключ-шифратор представителя НаноТрейзен",
		INSTRUMENTAL = "ключом-шифратором представителя НаноТрейзен",
		PREPOSITIONAL = "ключе-шифраторе представителя НаноТрейзен"
	)
	icon_state = "com_cypherkey"
	channels = list("Command" = 1, "Security" = 0, "Engineering" = 0, "Science" = 0, "Medical" = 0, "Supply" = 0, "Service" = 0, "Procedure" = 1)

/obj/item/encryptionkey/heads/magistrate
	name = "Magistrate's Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор магистрата",
		GENITIVE = "ключа-шифратора магистрата",
		DATIVE = "ключу-шифратору магистрата",
		ACCUSATIVE = "ключ-шифратор магистрата",
		INSTRUMENTAL = "ключом-шифратором магистрата",
		PREPOSITIONAL = "ключе-шифраторе магистрата"
	)
	icon_state = "com_cypherkey"
	channels = list("Command" = 1, "Security" = 1, "Procedure" = 1)

/obj/item/encryptionkey/heads/blueshield
	name = "Blueshield's Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор офицера \"Синий Щит\"",
		GENITIVE = "ключа-шифратора офицера \"Синий Щит\"",
		DATIVE = "ключу-шифратору офицера \"Синий Щит\"",
		ACCUSATIVE = "ключ-шифратор офицера \"Синий Щит\"",
		INSTRUMENTAL = "ключом-шифратором офицера \"Синий Щит\"",
		PREPOSITIONAL = "ключе-шифраторе офицера \"Синий Щит\""
	)
	icon_state = "com_cypherkey"
	channels = list("Command" = 1)

/obj/item/encryptionkey/headset_cargo
	name = "Supply Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор канала снабжения",
		GENITIVE = "ключа-шифратора канала снабжения",
		DATIVE = "ключу-шифратору канала снабжения",
		ACCUSATIVE = "ключ-шифратор канала снабжения",
		INSTRUMENTAL = "ключом-шифратором канала снабжения",
		PREPOSITIONAL = "ключе-шифраторе канала снабжения"
	)
	icon_state = "cargo_cypherkey"
	channels = list("Supply" = 1)

/obj/item/encryptionkey/headset_service
	name = "Service Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор канала обслуживания",
		GENITIVE = "ключа-шифратора канала обслуживания",
		DATIVE = "ключу-шифратору канала обслуживания",
		ACCUSATIVE = "ключ-шифратор канала обслуживания",
		INSTRUMENTAL = "ключом-шифратором канала обслуживания",
		PREPOSITIONAL = "ключе-шифраторе канала обслуживания"
	)
	icon_state = "srv_cypherkey"
	channels = list("Service" = 1)

/obj/item/encryptionkey/ert
	name = "Nanotrasen ERT Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор ОБР",
		GENITIVE = "ключа-шифратора ОБР",
		DATIVE = "ключу-шифратору ОБР",
		ACCUSATIVE = "ключ-шифратор ОБР",
		INSTRUMENTAL = "ключом-шифратором ОБР",
		PREPOSITIONAL = "ключе-шифраторе ОБР"
	)
	channels = list("Response Team" = 1, "Science" = 1, "Command" = 1, "Medical" = 1, "Engineering" = 1, "Security" = 1, "Supply" = 1, "Service" = 1, "Procedure" = 1)

/obj/item/encryptionkey/centcom
	name = "Centcom Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор Центрального Командования",
		GENITIVE = "ключа-шифратора Центрального Командования",
		DATIVE = "ключу-шифратору Центрального Командования",
		ACCUSATIVE = "ключ-шифратор Центрального Командования",
		INSTRUMENTAL = "ключом-шифратором Центрального Командования",
		PREPOSITIONAL = "ключе-шифраторе Центрального Командования"
	)
	channels = list("Response Team" = 1, "Special Ops" = 1, "Science" = 1, "Command" = 1, "Medical" = 1, "Engineering" = 1, "Security" = 1, "Supply" = 1, "Service" = 1, "Procedure" = 1)

/obj/item/encryptionkey/heads/ai_integrated //ported from bay, this goes 'inside' the AI.
	name = "AI Integrated Encryption Key"
	desc = "Интегрированный в ядро ИИ ключ-шифратор."
	ru_names = list(
		NOMINATIVE = "ключ-шифратор ИИ",
		GENITIVE = "ключа-шифратора ИИ",
		DATIVE = "ключу-шифратору ИИ",
		ACCUSATIVE = "ключ-шифратор ИИ",
		INSTRUMENTAL = "ключом-шифратором ИИ",
		PREPOSITIONAL = "ключе-шифраторе ИИ"
	)
	icon_state = "cap_cypherkey"
	channels = list("Command" = 1, "Security" = 1, "Engineering" = 1, "Science" = 1, "Medical" = 1, "Supply" = 1, "Service" = 1, "AI Private" = 1, "Procedure" = 1)

/obj/item/encryptionkey/admin //totally shitspawn
	name = "Admin Radio Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор админа",
		GENITIVE = "ключа-шифратора админа",
		DATIVE = "ключу-шифратору админа",
		ACCUSATIVE = "ключ-шифратор админа",
		INSTRUMENTAL = "ключом-шифратором админа",
		PREPOSITIONAL = "ключе-шифраторе админа"
	)
	channels = list("Common" = 1, "Science" = 1, "Command" = 1, "Medical" = 1, "Engineering" = 1, "Security" = 1, "Supply" = 1, "Service" = 1, "Procedure" = 1, "AI Private" = 1, "Syndicate" = 1, \
		"Response Team" = 1, "Special Ops" = 1, "SyndTaipan" = 1, "SyndTeam" = 1, "Soviet" = 1, "Medical(I)" = 1, "Security(I)" = 1, "Spy Spider" = 1, "Spider Clan" = 1, "Alpha wave" = 1, "Beta wave" = 1, "Gamma wave" = 1)

/obj/item/encryptionkey/headset_mining_medic
	name = "Medical Mining Encryption Key"
	ru_names = list(
		NOMINATIVE = "ключ-шифратор шахтёрского врача",
		GENITIVE = "ключа-шифратора шахтёрского врача",
		DATIVE = "ключу-шифратору шахтёрского врача",
		ACCUSATIVE = "ключ-шифратор шахтёрского врача",
		INSTRUMENTAL = "ключом-шифратором шахтёрского врача",
		PREPOSITIONAL = "ключе-шифраторе шахтёрского врача"
	)
	channels = list("Medical" = 1, "Supply" = 1)
	icon_state = "minmed_cypherkey"

/* Currently unusable due to language refactoring.
/obj/item/encryptionkey/event_1
	name = "Encryption key"
	desc = "An encryption key for a radio headset. To access special radio channel, use :1."
	icon_state = "sov_cypherkey"
	channels = list("Alpha wave" = 1)

/obj/item/encryptionkey/event_2
	name = "Encryption key"
	desc = "An encryption key for a radio headset. To access special radio channel, use :2."
	icon_state = "sov_cypherkey"
	channels = list("Beta wave" = 1)

/obj/item/encryptionkey/event_3
	name = "Encryption key"
	desc = "An encryption key for a radio headset. To access special radio channel, use :3."
	icon_state = "sov_cypherkey"
	channels = list("Gamma wave" = 1)
*/
