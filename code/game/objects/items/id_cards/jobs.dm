/**
 * ID cards, used in job datums.
 */

/obj/item/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "Стандартная идентификационная карта персонала \"Синдиката\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	icon_state = "syndie"
	item_state = "syndieofficer-id"
	assignment = JOB_TITLE_RU_SYNDICATE_OFFICER
	untrackable = 1
	access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_COMMAND, ACCESS_EXTERNAL_AIRLOCKS)

/obj/item/card/id/syndicate_command/get_ru_names()
	return list(
		NOMINATIVE = "ID-карта \"Синдиката\"",
		GENITIVE = "ID-карты \"Синдиката\"",
		DATIVE = "ID-карте \"Синдиката\"",
		ACCUSATIVE = "ID-карту \"Синдиката\"",
		INSTRUMENTAL = "ID-картой \"Синдиката\"",
		PREPOSITIONAL = "ID-карте \"Синдиката\"",
	)

/obj/item/card/id/centcom
	name = "central command ID card"
	desc = "Стандартная идентификационная карта персонала Центрального Командования \"Нанотрейзен\" в секторе \"Эпсилон Лукусты\". \
			Служит для подтверждения личности, определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	icon_state = "centcom"
	item_state = "centcomm-id"

/obj/item/card/id/centcom/get_ru_names()
	return list(
		NOMINATIVE = "ID-карта ЦК",
		GENITIVE = "ID-карты ЦК",
		DATIVE = "ID-карте ЦК",
		ACCUSATIVE = "ID-карту ЦК",
		INSTRUMENTAL = "ID-картой ЦК",
		PREPOSITIONAL = "ID-карте ЦК",
	)

/obj/item/card/id/centcom/Initialize(mapload)
	access = get_all_centcom_access()
	. = ..()

/obj/item/card/id/nanotrasen
	icon_state = "nanotrasen"
	item_state = "nt-id"

/obj/item/card/id/medical
	icon_state = "medical"
	item_state = "medical-id"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/medical/intern
	icon_state = "intern"
	item_state = "intern-id"

/obj/item/card/id/security
	icon_state = "security"
	item_state = "security-id"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)

/obj/item/card/id/security/cadet
	icon_state = "cadet"
	item_state = "cadet-id"

/obj/item/card/id/research
	icon_state = "research"
	item_state = "research-id"
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_XENOARCH, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/research/student
	icon_state = "student"
	item_state = "student-id"

/obj/item/card/id/supply
	icon_state = "cargo"
	item_state = "cargo-id"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/engineering
	icon_state = "engineering"
	item_state = "engineer-id"
	access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS)

/obj/item/card/id/engineering/trainee
	icon_state = "trainee"
	item_state = "trainee-id"

/obj/item/card/id/hos
	icon_state = "HoS"
	item_state = "hos-id"
	access = list(
		ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT,
		ACCESS_FORENSICS_LOCKERS, ACCESS_PILOT, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
		ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS
	)

/obj/item/card/id/cmo
	icon_state = "CMO"
	item_state = "cmo-id"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_HEADS,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE,
			ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS, ACCESS_PSYCHIATRIST, ACCESS_PARAMEDIC, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/rd
	icon_state = "RD"
	item_state = "rd-id"
	access = list(
		ACCESS_RD, ACCESS_HEADS, ACCESS_TOX, ACCESS_GENETICS, ACCESS_MORGUE,
		ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_TELEPORTER, ACCESS_SEC_DOORS,
		ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_AI_UPLOAD,
		ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_GATEWAY, ACCESS_XENOARCH, ACCESS_MINISAT, ACCESS_MINERAL_STOREROOM
	)

/obj/item/card/id/ce
	icon_state = "CE"
	item_state = "ce-id"
	access = list(
		ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
		ACCESS_TELEPORTER, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EMERGENCY_STORAGE, ACCESS_EVA,
		ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS,
		ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINISAT, ACCESS_MECHANIC, ACCESS_MINERAL_STOREROOM
	)

/obj/item/card/id/clown
	icon_state = "clown"
	item_state = "clown-id"
	access = list(ACCESS_CLOWN, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)

/obj/item/card/id/mime
	icon_state = "mime"
	item_state = "mime-id"
	access = list(ACCESS_MIME, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)

/obj/item/card/id/qm
	icon_state = "qm"
	item_state = "qm-id"
	desc = "Слава Каргонии!"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/genetics
	icon_state = "genetics"
	item_state = "genetics-id"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/warden
	icon_state = "warden"
	item_state = "warden-id"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)

/obj/item/card/id/warden/battle
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_ARMORY_REAL)

/obj/item/card/id/warden/battle/ComponentInitialize()
	AddElement(/datum/element/high_value_item)

/obj/item/card/id/warden/battle/Initialize(mapload)
	GLOB.poi_list += src
	. = ..()

/obj/item/card/id/warden/battle/Destroy()
	GLOB.poi_list -= src
	. = ..()

/obj/item/card/id/lawyer
	icon_state = "IAA"
	item_state = "iaa-id"
	access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING)

/obj/item/card/id/mining_medic
	icon_state = "mining_medic"
	item_state = "mining_medic-id"
	access = list(ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS)

/obj/item/card/id/investor
	icon_state = "investor"
	item_state = "investor-id"
	access = list(ACCESS_HEADS, ACCESS_INVESTOR, ACCESS_ALL_PERSONAL_LOCKERS)
