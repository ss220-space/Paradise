/**
 * ID cards, used in job datums.
 */

/obj/item/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "Стандартная идентификационная карта персонала \"Синдиката\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	registered_name = "Синлдикат"
	icon_state = "syndie"
	item_state = "syndieofficer-id"
	assignment = "Syndicate Overlord"
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

/obj/item/card/id/captains_spare
	name = "captain's spare ID"
	icon_state = "gold"
	item_state = "gold-id"
	registered_name = "Капитан"
	assignment = JOB_TITLE_RU_CAPTAIN

/obj/item/card/id/captains_spare/get_ru_names()
	return list(
		NOMINATIVE = "запасная ID-карта Капитана",
		GENITIVE = "запасной ID-карты Капитана",
		DATIVE = "запасной ID-карте Капитана",
		ACCUSATIVE = "запасную ID-карту Капитана",
		INSTRUMENTAL = "запасной ID-картой Капитана",
		PREPOSITIONAL = "запасной ID-карте Капитана",
	)

/obj/item/card/id/captains_spare/Initialize(mapload)
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/card/id/admin
	name = "admin ID card"
	desc = "Идентификационная карта для Администрации. Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника. \
			А ещё для плотного щитспауна."
	icon_state = "admin"
	item_state = "gold-id"
	registered_name = "Админ"
	assignment = "Магистр щитспауна"
	untrackable = 1

/obj/item/card/id/admin/get_ru_names()
	return list(
		NOMINATIVE = "ID-карта Администрации",
		GENITIVE = "ID-карты Администрации",
		DATIVE = "ID-карте Администрации",
		ACCUSATIVE = "ID-карту Администрации",
		INSTRUMENTAL = "ID-картой Администрации",
		PREPOSITIONAL = "ID-карте Администрации",
	)

/obj/item/card/id/admin/Initialize(mapload)
	access = get_absolutely_all_accesses()
	. = ..()

/obj/item/card/id/centcom
	name = "central command ID card"
	desc = "Стандартная идентификационная карта персонала Центрального Командования \"Нанотрейзен\" в секторе \"Эпсилон Лукусты\". \
			Служит для подтверждения личности, определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	icon_state = "centcom"
	item_state = "centcomm-id"
	registered_name = "Центральное Командование"
	assignment = "Сотрудник ЦК \"Нанотрейзен\""

/obj/item/card/id/centcom/get_ru_names()
	return list(
		NOMINATIVE = "ID-карта Центрального Командования",
		GENITIVE = "ID-карты Центрального Командования",
		DATIVE = "ID-карте Центрального Командования",
		ACCUSATIVE = "ID-карту Центрального Командования",
		INSTRUMENTAL = "ID-картой Центрального Командования",
		PREPOSITIONAL = "ID-карте Центрального Командования",
	)

/obj/item/card/id/centcom/Initialize(mapload)
	access = get_all_centcom_access()
	. = ..()

/obj/item/card/id/nanotrasen
	name = "nanotrasen ID card"
	icon_state = "nanotrasen"
	item_state = "nt-id"

/obj/item/card/id/nanotrasen/get_ru_names()
	return list(
		NOMINATIVE = "ID-карта \"Нанотрейзен\"",
		GENITIVE = "ID-карты \"Нанотрейзен\"",
		DATIVE = "ID-карте \"Нанотрейзен\"",
		ACCUSATIVE = "ID-карту \"Нанотрейзен\"",
		INSTRUMENTAL = "ID-картой \"Нанотрейзен\"",
		PREPOSITIONAL = "ID-карте \"Нанотрейзен\"",
	)

/obj/item/card/id/medical
	name = "Medical ID"
	registered_name = "Medic"
	icon_state = "medical"
	item_state = "medical-id"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/medical/intern
	name = "Intern ID"
	registered_name = "Intern"
	icon_state = "intern"
	item_state = "intern-id"

/obj/item/card/id/security
	name = "Security ID"
	registered_name = "Officer"
	icon_state = "security"
	item_state = "security-id"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)

/obj/item/card/id/security/cadet
	name = "Cadet ID"
	registered_name = "Cadet"
	icon_state = "cadet"
	item_state = "cadet-id"

/obj/item/card/id/research
	name = "Research ID"
	registered_name = "Scientist"
	icon_state = "research"
	item_state = "research-id"
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_XENOARCH, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/research/student
	name = "Student ID"
	registered_name = "Student"
	icon_state = "student"
	item_state = "student-id"

/obj/item/card/id/supply
	name = "Supply ID"
	registered_name = "Cargonian"
	icon_state = "cargo"
	item_state = "cargo-id"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/engineering
	name = "Engineering ID"
	registered_name = "Engineer"
	icon_state = "engineering"
	item_state = "engineer-id"
	access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS)

/obj/item/card/id/engineering/trainee
	name = "Trainee ID"
	registered_name = "Trainee"
	icon_state = "trainee"
	item_state = "trainee-id"

/obj/item/card/id/hos
	name = "Head of Security ID"
	registered_name = "HoS"
	icon_state = "HoS"
	item_state = "hos-id"
	access = list(
		ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT,
		ACCESS_FORENSICS_LOCKERS, ACCESS_PILOT, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
		ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS
	)

/obj/item/card/id/cmo
	name = "Chief Medical Officer ID"
	registered_name = "CMO"
	icon_state = "CMO"
	item_state = "cmo-id"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_HEADS,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE,
			ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS, ACCESS_PSYCHIATRIST, ACCESS_PARAMEDIC, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/rd
	name = "Research Director ID"
	registered_name = "RD"
	icon_state = "RD"
	item_state = "rd-id"
	access = list(
		ACCESS_RD, ACCESS_HEADS, ACCESS_TOX, ACCESS_GENETICS, ACCESS_MORGUE,
		ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_TELEPORTER, ACCESS_SEC_DOORS,
		ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_AI_UPLOAD,
		ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_GATEWAY, ACCESS_XENOARCH, ACCESS_MINISAT, ACCESS_MINERAL_STOREROOM
	)

/obj/item/card/id/ce
	name = "Chief Engineer ID"
	registered_name = "CE"
	icon_state = "CE"
	item_state = "ce-id"
	access = list(
		ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
		ACCESS_TELEPORTER, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EMERGENCY_STORAGE, ACCESS_EVA,
		ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS,
		ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINISAT, ACCESS_MECHANIC, ACCESS_MINERAL_STOREROOM
	)

/obj/item/card/id/clown
	name = "Pink ID"
	registered_name = "HONK!"
	icon_state = "clown"
	item_state = "clown-id"
	desc = "Даже вид этой карты вселяет в вас глубокий страх."
	access = list(ACCESS_CLOWN, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)

/obj/item/card/id/mime
	name = "Black and White ID"
	registered_name = "..."
	icon_state = "mime"
	item_state = "mime-id"
	desc = "..."
	access = list(ACCESS_MIME, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)

/obj/item/card/id/qm
	name = "Quartmaster ID"
	registered_name = "QM"
	icon_state = "qm"
	item_state = "qm-id"
	desc = "Слава Каргонии!"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/genetics
	name = "Genetics ID"
	registered_name = "Genetics"
	icon_state = "genetics"
	item_state = "genetics-id"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/warden
	name = "Warden ID"
	registered_name = "Warden"
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
	name = "IAA ID"
	registered_name = "IAA"
	icon_state = "IAA"
	item_state = "iaa-id"
	access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING)

/obj/item/card/id/punpun
	name = "Pun Pun ID"
	registered_name = "Пун Пун"
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/mining_medic
	name = "Mining Medic ID"
	registered_name = "Mining Medic"
	icon_state = "mining_medic"
	item_state = "mining_medic-id"
	access = list(ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS)

/obj/item/card/id/library_owl
	name = "Slavka ID"
	registered_name = "Сыч Вячеслав"
	access = list(ACCESS_LIBRARY)

/obj/item/card/id/rainbow
	name = "Rainbow ID"
	icon_state = "rainbow"
	item_state = "clown-id"

/obj/item/card/id/thunderdome/red
	name = "Thunderdome Red ID"
	registered_name = "Red Team Fighter"
	assignment = "Red Team Fighter"
	icon_state = "TDred"
	desc = "Эту ID-карту выдают тем, кто сражался внутри купола грома за красную команду. Мало кто видел хоть одну из них, и ещё меньше тех, кто выжил и сохранил её."

/obj/item/card/id/thunderdome/green
	name = "Thunderdome Green ID"
	registered_name = "Green Team Fighter"
	assignment = "Green Team Fighter"
	icon_state = "TDgreen"
	desc = "Эту ID-карту выдают тем, кто сражался внутри купола грома за зелёную команду. Мало кто видел хоть одну из них, и ещё меньше тех, кто выжил и сохранил её."

