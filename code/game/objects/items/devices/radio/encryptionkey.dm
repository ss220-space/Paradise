
/obj/item/encryptionkey
	name = "Standard Encryption Key"
	desc = "Ключ шифрования, устанавливаемый в гарнитуру. Содержит в себе все необходимые протоколы декодирования сигнала для прослушивания определенной частоты."
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

/obj/item/encryptionkey/get_ru_names()
	return list(
		NOMINATIVE = "стандартный ключ-шифратор",
		GENITIVE = "стандартного ключа-шифратора",
		DATIVE = "стандартному ключу-шифратору",
		ACCUSATIVE = "стандартный ключ-шифратор",
		INSTRUMENTAL = "стандартным ключом-шифратором",
		PREPOSITIONAL = "стандартном ключе-шифраторе"
	)


/obj/item/encryptionkey/syndicate
	name = "syndicate encryption key"
	desc = "Ключ шифрования, устанавливаемый в гарнитуру. Содержит в себе лучшее хакерское ПО, доступное на чёрном рынке и позволяющее получить доступ ко всем частотам НаноТрейзен."
	icon_state = "syn_cypherkey"
	channels = list(SYND_FREQ_NAME = 1)
	origin_tech = "syndicate=1;engineering=3;bluespace=2"
	syndie = TRUE //Signifies that it de-crypts Syndicate transmissions
	change_voice = TRUE
	var/fake_name = "Агент ЗОВИТЕ КОДЕРА"
	var/static/list/fakename_list

/obj/item/encryptionkey/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор Синдиката",
		GENITIVE = "ключа-шифратора Синдиката",
		DATIVE = "ключу-шифратору Синдиката",
		ACCUSATIVE = "ключ-шифратор Синдиката",
		INSTRUMENTAL = "ключом-шифратором Синдиката",
		PREPOSITIONAL = "ключе-шифраторе Синдиката"
	)

/obj/item/encryptionkey/syndicate/Initialize(mapload)
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
	channels = list(SYND_TAIPAN_FREQ_NAME = 1)

/obj/item/encryptionkey/syndicate/taipan/borg
	change_voice = FALSE
	icon_state = "taipan_cypherkey"
	channels = list(SYND_TAIPAN_FREQ_NAME = 1, SYND_FREQ_NAME = 1)
/obj/item/encryptionkey/syndicate/taipan/tcomms_agent
	icon_state = "ofcom_cypherkey"
	channels = list(SYND_TAIPAN_FREQ_NAME = 1, SYND_FREQ_NAME = 1, PUB_FREQ_NAME = 1)

/obj/item/encryptionkey/syndteam
	name = "syndicate encryption key"
	desc = "Ключ шифрования, устанавливаемый в гарнитуру. Содержит в себе лучшее хакерское ПО, доступное на чёрном рынке и позволяющее получить доступ ко всем частотам НаноТрейзен."
	icon_state = "syn_cypherkey"
	channels = list(SYNDTEAM_FREQ_NAME = 1, SYND_FREQ_NAME = 1)
	origin_tech = "syndicate=4"
	syndie = TRUE //Signifies that it de-crypts Syndicate transmissions

/obj/item/encryptionkey/syndteam/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор Синдиката",
		GENITIVE = "ключа-шифратора Синдиката",
		DATIVE = "ключу-шифратору Синдиката",
		ACCUSATIVE = "ключ-шифратор Синдиката",
		INSTRUMENTAL = "ключом-шифратором Синдиката",
		PREPOSITIONAL = "ключе-шифраторе Синдиката"
	)

/obj/item/encryptionkey/soviet
	name = "Soviet encryption key"
	icon_state = "sov_cypherkey"
	channels = list(SOV_FREQ_NAME = 1)

/obj/item/encryptionkey/soviet/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор СССП",
		GENITIVE = "ключа-шифратора СССП",
		DATIVE = "ключу-шифратору СССП",
		ACCUSATIVE = "ключ-шифратор СССП",
		INSTRUMENTAL = "ключом-шифратором СССП",
		PREPOSITIONAL = "ключе-шифраторе СССП"
	)

/obj/item/encryptionkey/binary
	name = "binary translator key"
	desc = "Ключ шифрования, устанавливаемый в гарнитуру. Содержит в себе все необходимые протоколы для декодирования бинарных сигналов, используемых синтетиками для коммуникации."
	icon_state = "bin_cypherkey"
	translate_binary = TRUE
	origin_tech = "syndicate=1;engineering=4;bluespace=3"

/obj/item/encryptionkey/binary/get_ru_names()
	return list(
		NOMINATIVE = "ключ-переводчик бинарного канала",
		GENITIVE = "ключа-переводчика бинарного канала",
		DATIVE = "ключу-переводчику бинарного канала",
		ACCUSATIVE = "ключ-переводчик бинарного канала",
		INSTRUMENTAL = "ключом-переводчиком бинарного канала",
		PREPOSITIONAL = "ключе-переводчике бинарного канала"
	)

/obj/item/encryptionkey/headset_sec
	name = "Security Radio Encryption Key"
	icon_state = "sec_cypherkey"
	channels = list(SEC_FREQ_NAME = 1, PRS_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_sec/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор канала охраны",
		GENITIVE = "ключа-шифратора канала охраны",
		DATIVE = "ключу-шифратор канала охраны",
		ACCUSATIVE = "ключ-шифратор канала охраны",
		INSTRUMENTAL = "ключом-шифратором канала охраны",
		PREPOSITIONAL = "ключе-шифраторе канала охраны"
	)

/obj/item/encryptionkey/prisoner
	name = "Prisoners Radio Encryption Key"
	icon_state = "prisoner_cypherkey"
	channels = list(PRS_FREQ_NAME = 1)

/obj/item/encryptionkey/prisoner/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор канала заключенных",
		GENITIVE = "ключа-шифратора канала заключенных",
		DATIVE = "ключу-шифратор канала заключенных",
		ACCUSATIVE = "ключ-шифратор канала заключенных",
		INSTRUMENTAL = "ключом-шифратором канала заключенных",
		PREPOSITIONAL = "ключе-шифраторе канала заключенных"
	)

/obj/item/encryptionkey/headset_iaa
	name = "Internal Affairs Radio Encryption Key"
	icon_state = "sec_cypherkey"
	channels = list(SEC_FREQ_NAME = 1, PROC_FREQ_NAME = 1, PRS_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_iaa/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор агента внутренних дел",
		GENITIVE = "ключа-шифратора агента внутренних дел",
		DATIVE = "ключу-шифратору агента внутренних дел",
		ACCUSATIVE = "ключ-шифратор агента внутренних дел",
		INSTRUMENTAL = "ключом-шифратором агента внутренних дел",
		PREPOSITIONAL = "ключе-шифраторе агента внутренних дел"
	)

/obj/item/encryptionkey/headset_eng
	name = "Engineering Radio Encryption Key"
	icon_state = "eng_cypherkey"
	channels = list(ENG_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_eng/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор инженерного канала",
		GENITIVE = "ключа-шифратора инженерного канала",
		DATIVE = "ключу-шифратору инженерного канала",
		ACCUSATIVE = "ключ-шифратор инженерного канала",
		INSTRUMENTAL = "ключом-шифратором инженерного канала",
		PREPOSITIONAL = "ключе-шифраторе инженерного канала"
	)

/obj/item/encryptionkey/headset_rob
	name = "Robotics Radio Encryption Key"
	icon_state = "rob_cypherkey"
	channels = list(ENG_FREQ_NAME = 1, SCI_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_rob/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор робототехников",
		GENITIVE = "ключа-шифратора робототехников",
		DATIVE = "ключу-шифратору робототехников",
		ACCUSATIVE = "ключ-шифратор робототехников",
		INSTRUMENTAL = "ключом-шифратором робототехников",
		PREPOSITIONAL = "ключе-шифраторе робототехников"
	)

/obj/item/encryptionkey/headset_med
	name = "Medical Radio Encryption Key"
	icon_state = "med_cypherkey"
	channels = list(MED_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_med/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор медицинского канала",
		GENITIVE = "ключа-шифратора медицинского канала",
		DATIVE = "ключу-шифратору медицинского канала",
		ACCUSATIVE = "ключ-шифратор медицинского канала",
		INSTRUMENTAL = "ключом-шифратором медицинского канала",
		PREPOSITIONAL = "ключе-шифраторе медицинского канала"
	)

/obj/item/encryptionkey/headset_sci
	name = "Science Radio Encryption Key"
	icon_state = "sci_cypherkey"
	channels = list(SCI_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_sci/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор научного канала",
		GENITIVE = "ключа-шифратора научного канала",
		DATIVE = "ключу-шифратору научного канала",
		ACCUSATIVE = "ключ-шифратор научного канала",
		INSTRUMENTAL = "ключом-шифратором научного канала",
		PREPOSITIONAL = "ключе-шифраторе научного канала"
	)

/obj/item/encryptionkey/headset_medsci
	name = "Medical Research Radio Encryption Key"
	icon_state = "medsci_cypherkey"
	channels = list(MED_FREQ_NAME = 1, SCI_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_medsci/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор научного и медицинского канала",
		GENITIVE = "ключа-шифратора научного и медицинского канала",
		DATIVE = "ключу-шифратору научного и медицинского канала",
		ACCUSATIVE = "ключ-шифратор научного и медицинского канала",
		INSTRUMENTAL = "ключом-шифратором научного и медицинского канала",
		PREPOSITIONAL = "ключе-шифраторе научного и медицинского канала"
	)

/obj/item/encryptionkey/headset_medsec
	name = "Medical Security Radio Encryption Key"
	icon_state = "sec_cypherkey"
	channels = list(SEC_FREQ_NAME = 1, MED_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_medsec/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор охранного и медицинского канала",
		GENITIVE = "ключа-шифратора охранного и медицинского канала",
		DATIVE = "ключу-шифратору охранного и медицинского канала",
		ACCUSATIVE = "ключ-шифратор охранного и медицинского канала",
		INSTRUMENTAL = "ключом-шифратором охранного и медицинского канала",
		PREPOSITIONAL = "ключе-шифраторе охранного и медицинского канала"
	)

/obj/item/encryptionkey/headset_com
	name = "Command Radio Encryption Key"
	icon_state = "com_cypherkey"
	channels = list(COMM_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_com/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор командного канала",
		GENITIVE = "ключа-шифратора командного канала",
		DATIVE = "ключу-шифратору командного канала",
		ACCUSATIVE = "ключ-шифратор командного канала",
		INSTRUMENTAL = "ключом-шифратором командного канала",
		PREPOSITIONAL = "ключе-шифраторе командного канала"
	)

/obj/item/encryptionkey/heads/captain
	name = "Captain's Encryption Key"
	icon_state = "cap_cypherkey"
	channels = list(COMM_FREQ_NAME = 1, SEC_FREQ_NAME = 1, ENG_FREQ_NAME = 0, SCI_FREQ_NAME = 0, MED_FREQ_NAME = 0, SUP_FREQ_NAME = 0, SRV_FREQ_NAME = 0, PRS_FREQ_NAME = 0, PROC_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/captain/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор капитана",
		GENITIVE = "ключа-шифратора капитана",
		DATIVE = "ключу-шифратору капитана",
		ACCUSATIVE = "ключ-шифратор капитана",
		INSTRUMENTAL = "ключом-шифратором капитана",
		PREPOSITIONAL = "ключе-шифраторе капитана"
	)

/obj/item/encryptionkey/heads/rd
	name = "Research Director's Encryption Key"
	icon_state = "rd_cypherkey"
	channels = list(SCI_FREQ_NAME = 1, COMM_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/rd/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор научного руководителя",
		GENITIVE = "ключа-шифратора научного руководителя",
		DATIVE = "ключу-шифратору научного руководителя",
		ACCUSATIVE = "ключ-шифратор научного руководителя",
		INSTRUMENTAL = "ключом-шифратором научного руководителя",
		PREPOSITIONAL = "ключе-шифраторе научного руководителя"
	)

/obj/item/encryptionkey/heads/hos
	name = "Head of Security's Encryption Key"
	icon_state = "hos_cypherkey"
	channels = list(SEC_FREQ_NAME = 1, COMM_FREQ_NAME = 1, PRS_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/hos/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор главы службы безопасности",
		GENITIVE = "ключа-шифратора главы службы безопасности",
		DATIVE = "ключу-шифратору главы службы безопасности",
		ACCUSATIVE = "ключ-шифратор главы службы безопасности",
		INSTRUMENTAL = "ключом-шифратором главы службы безопасности",
		PREPOSITIONAL = "ключе-шифраторе главы службы безопасности"
	)

/obj/item/encryptionkey/heads/ce
	name = "Chief Engineer's Encryption Key"
	icon_state = "ce_cypherkey"
	channels = list(ENG_FREQ_NAME = 1, COMM_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/ce/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор старшего инженера",
		GENITIVE = "ключа-шифратора старшего инженера",
		DATIVE = "ключу-шифратору старшего инженера",
		ACCUSATIVE = "ключ-шифратор старшего инженера",
		INSTRUMENTAL = "ключом-шифратором старшего инженера",
		PREPOSITIONAL = "ключе-шифраторе старшего инженера"
	)

/obj/item/encryptionkey/heads/cmo
	name = "Chief Medical Officer's Encryption Key"
	icon_state = "cmo_cypherkey"
	channels = list(MED_FREQ_NAME = 1, COMM_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/cmo/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор главного врача",
		GENITIVE = "ключа-шифратора главного врача",
		DATIVE = "ключу-шифратору главного врача",
		ACCUSATIVE = "ключ-шифратор главного врача",
		INSTRUMENTAL = "ключом-шифратором главного врача",
		PREPOSITIONAL = "ключе-шифраторе главного врача"
	)

/obj/item/encryptionkey/heads/hop
	name = "Head of Personnel's Encryption Key"
	icon_state = "hop_cypherkey"
	channels = list(SRV_FREQ_NAME = 1, SEC_FREQ_NAME = 0, COMM_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/hop/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор главы персонала",
		GENITIVE = "ключа-шифратора главы персонала",
		DATIVE = "ключу-шифратору главы персонала",
		ACCUSATIVE = "ключ-шифратор главы персонала",
		INSTRUMENTAL = "ключом-шифратором главы персонала",
		PREPOSITIONAL = "ключе-шифраторе главы персонала"
	)
/obj/item/encryptionkey/heads/qm
	name = "Quartermaster's Encryption Key"
	icon_state = "cargo_cypherkey"
	channels = list(SUP_FREQ_NAME = 1, COMM_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/qm/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор Квартирмейстера",
		GENITIVE = "ключа-шифратора Квартирмейстера",
		DATIVE = "ключу-шифратору Квартирмейстера",
		ACCUSATIVE = "ключ-шифратор Квартирмейстера",
		INSTRUMENTAL = "ключом-шифратором Квартирмейстера",
		PREPOSITIONAL = "ключе-шифраторе Квартирмейстера"
	)

/obj/item/encryptionkey/heads/ntrep
	name = "Nanotrasen Representative's Encryption Key"
	icon_state = "com_cypherkey"
	channels = list(COMM_FREQ_NAME = 1, SEC_FREQ_NAME = 0, PRS_FREQ_NAME = 0, ENG_FREQ_NAME = 0, SCI_FREQ_NAME = 0, MED_FREQ_NAME = 0, SUP_FREQ_NAME = 0, SRV_FREQ_NAME = 0, PROC_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/ntrep/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор представителя НаноТрейзен",
		GENITIVE = "ключа-шифратора представителя НаноТрейзен",
		DATIVE = "ключу-шифратору представителя НаноТрейзен",
		ACCUSATIVE = "ключ-шифратор представителя НаноТрейзен",
		INSTRUMENTAL = "ключом-шифратором представителя НаноТрейзен",
		PREPOSITIONAL = "ключе-шифраторе представителя НаноТрейзен"
	)
/obj/item/encryptionkey/heads/magistrate
	name = "Magistrate's Encryption Key"
	icon_state = "com_cypherkey"
	channels = list(COMM_FREQ_NAME = 1, SEC_FREQ_NAME = 1, PRS_FREQ_NAME = 1, PROC_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/magistrate/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор магистрата",
		GENITIVE = "ключа-шифратора магистрата",
		DATIVE = "ключу-шифратору магистрата",
		ACCUSATIVE = "ключ-шифратор магистрата",
		INSTRUMENTAL = "ключом-шифратором магистрата",
		PREPOSITIONAL = "ключе-шифраторе магистрата"
	)
/obj/item/encryptionkey/heads/blueshield
	name = "Blueshield's Encryption Key"
	icon_state = "com_cypherkey"
	channels = list(COMM_FREQ_NAME = 1)

/obj/item/encryptionkey/heads/blueshield/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор офицера \"Синий Щит\"",
		GENITIVE = "ключа-шифратора офицера \"Синий Щит\"",
		DATIVE = "ключу-шифратору офицера \"Синий Щит\"",
		ACCUSATIVE = "ключ-шифратор офицера \"Синий Щит\"",
		INSTRUMENTAL = "ключом-шифратором офицера \"Синий Щит\"",
		PREPOSITIONAL = "ключе-шифраторе офицера \"Синий Щит\""
	)

/*
/obj/item/encryptionkey/headset_mine
	name = "Mining Radio Encryption Key"
	icon_state = "mine_cypherkey"
	channels = list("Шахта" = 1)
*/
/obj/item/encryptionkey/headset_cargo
	name = "Supply Radio Encryption Key"
	icon_state = "cargo_cypherkey"
	channels = list(SUP_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_cargo/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор канала снабжения",
		GENITIVE = "ключа-шифратора канала снабжения",
		DATIVE = "ключу-шифратору канала снабжения",
		ACCUSATIVE = "ключ-шифратор канала снабжения",
		INSTRUMENTAL = "ключом-шифратором канала снабжения",
		PREPOSITIONAL = "ключе-шифраторе канала снабжения"
	)

/obj/item/encryptionkey/headset_service
	name = "Service Radio Encryption Key"
	icon_state = "srv_cypherkey"
	channels = list(SRV_FREQ_NAME = 1)

/obj/item/encryptionkey/headset_service/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор канала обслуживания",
		GENITIVE = "ключа-шифратора канала обслуживания",
		DATIVE = "ключу-шифратору канала обслуживания",
		ACCUSATIVE = "ключ-шифратор канала обслуживания",
		INSTRUMENTAL = "ключом-шифратором канала обслуживания",
		PREPOSITIONAL = "ключе-шифраторе канала обслуживания"
	)

/obj/item/encryptionkey/ert
	name = "Nanotrasen ERT Radio Encryption Key"
	channels = list(ERT_FREQ_NAME = 1, SCI_FREQ_NAME = 1, COMM_FREQ_NAME = 1, MED_FREQ_NAME = 1, ENG_FREQ_NAME = 1, SEC_FREQ_NAME = 1, PRS_FREQ_NAME = 1, SUP_FREQ_NAME = 1, SRV_FREQ_NAME = 1, PROC_FREQ_NAME = 1)

/obj/item/encryptionkey/ert/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор ОБР",
		GENITIVE = "ключа-шифратора ОБР",
		DATIVE = "ключу-шифратору ОБР",
		ACCUSATIVE = "ключ-шифратор ОБР",
		INSTRUMENTAL = "ключом-шифратором ОБР",
		PREPOSITIONAL = "ключе-шифраторе ОБР"
	)

/obj/item/encryptionkey/centcom
	name = "Centcom Radio Encryption Key"
	channels = list(ERT_FREQ_NAME = 1, DTH_FREQ_NAME = 1, SCI_FREQ_NAME = 1, COMM_FREQ_NAME = 1, MED_FREQ_NAME = 1, ENG_FREQ_NAME = 1, SEC_FREQ_NAME = 1, PRS_FREQ_NAME = 1, SUP_FREQ_NAME = 1, SRV_FREQ_NAME = 1, PROC_FREQ_NAME = 1)


/obj/item/encryptionkey/centcom/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор Центрального командования",
		GENITIVE = "ключа-шифратора Центрального командования",
		DATIVE = "ключу-шифратору Центрального командования",
		ACCUSATIVE = "ключ-шифратор Центрального командования",
		INSTRUMENTAL = "ключом-шифратором Центрального командования",
		PREPOSITIONAL = "ключе-шифраторе Центрального командования"
	)
/obj/item/encryptionkey/heads/ai_integrated //ported from bay, this goes 'inside' the AI.
	name = "AI Integrated Encryption Key"
	desc = "Интегрированный в ядро ИИ ключ-шифратор."
	icon_state = "cap_cypherkey"
	channels = list(COMM_FREQ_NAME = 1, SEC_FREQ_NAME = 1, PRS_FREQ_NAME = 1, ENG_FREQ_NAME = 1, SCI_FREQ_NAME = 1, MED_FREQ_NAME = 1, SUP_FREQ_NAME = 1, SRV_FREQ_NAME = 1, AI_FREQ_NAME = 1, PROC_FREQ_NAME = 1)


/obj/item/encryptionkey/heads/ai_integrated/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор ИИ",
		GENITIVE = "ключа-шифратора ИИ",
		DATIVE = "ключу-шифратору ИИ",
		ACCUSATIVE = "ключ-шифратор ИИ",
		INSTRUMENTAL = "ключом-шифратором ИИ",
		PREPOSITIONAL = "ключе-шифраторе ИИ"
	)

/obj/item/encryptionkey/admin //totally shitspawn
	name = "Admin Radio Encryption Key"
	channels = list(PUB_FREQ_NAME = 1, SCI_FREQ_NAME = 1, COMM_FREQ_NAME = 1, MED_FREQ_NAME = 1, ENG_FREQ_NAME = 1, SEC_FREQ_NAME = 1, PRS_FREQ_NAME = 1, SUP_FREQ_NAME = 1, SRV_FREQ_NAME = 1, PROC_FREQ_NAME = 1, AI_FREQ_NAME = 1, SYND_FREQ_NAME = 1,  \
		ERT_FREQ_NAME = 1, DTH_FREQ_NAME = 1, SYND_TAIPAN_FREQ_NAME = 1, SYNDTEAM_FREQ_NAME = 1, SOV_FREQ_NAME = 1, MED_I_FREQ_NAME = 1, SEC_I_FREQ_NAME = 1, SPY_SPIDER_FREQ_NAME = 1, NINJA_FREQ_NAME = 1, EVENT_ALPHA_FREQ_NAME = 1, EVENT_BETA_FREQ_NAME = 1, EVENT_GAMMA_FREQ_NAME = 1)

/obj/item/encryptionkey/admin/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор админа",
		GENITIVE = "ключа-шифратора админа",
		DATIVE = "ключу-шифратору админа",
		ACCUSATIVE = "ключ-шифратор админа",
		INSTRUMENTAL = "ключом-шифратором админа",
		PREPOSITIONAL = "ключе-шифраторе админа"
	)

/obj/item/encryptionkey/headset_mining_medic
	name = "Medical Mining Encryption Key"
	channels = list(MED_FREQ_NAME = 1, SUP_FREQ_NAME = 1)
	icon_state = "minmed_cypherkey"

/obj/item/encryptionkey/headset_mining_medic/get_ru_names()
	return list(
		NOMINATIVE = "ключ-шифратор шахтёрского врача",
		GENITIVE = "ключа-шифратора шахтёрского врача",
		DATIVE = "ключу-шифратору шахтёрского врача",
		ACCUSATIVE = "ключ-шифратор шахтёрского врача",
		INSTRUMENTAL = "ключом-шифратором шахтёрского врача",
		PREPOSITIONAL = "ключе-шифраторе шахтёрского врача"
	)

/* Currently unusable due to language refactoring.
/obj/item/encryptionkey/event_1
	name = "Encryption key"
	desc = "An encryption key for a radio headset. To access special radio channel, use :1."
	icon_state = "sov_cypherkey"
	channels = list(EVENT_ALPHA_FREQ_NAME = 1)

/obj/item/encryptionkey/event_2
	name = "Encryption key"
	desc = "An encryption key for a radio headset. To access special radio channel, use :2."
	icon_state = "sov_cypherkey"
	channels = list(EVENT_BETA_FREQ_NAME = 1)

/obj/item/encryptionkey/event_3
	name = "Encryption key"
	desc = "An encryption key for a radio headset. To access special radio channel, use :3."
	icon_state = "sov_cypherkey"
	channels = list(EVENT_GAMMA_FRE_NAME = 1)
*/
