GLOBAL_LIST_EMPTY(job_titles_ru_to_en)

// MARK: Procs

/**
 * English -> Russian
 *
 * Should be used for display purposes only, not for logic
 */
/proc/get_job_title_ru(en_title)
	return GLOB.job_titles_ru[en_title] || en_title

/**
 * Russian -> English
 *
 * Should be used for logic purposes only, not for display
 */
/proc/job_title_ru_to_en(ru_title)
	if(!length(GLOB.job_titles_ru_to_en))
		for(var/key in GLOB.job_titles_ru)
			GLOB.job_titles_ru_to_en[GLOB.job_titles_ru[key]] = key
	return GLOB.job_titles_ru_to_en[ru_title] || ru_title

// MARK: Job titles

// Command (Solo command, not department heads)
#define JOB_TITLE_RU_CAPTAIN "Капитан"
#define JOB_TITLE_RU_REPRESENTATIVE "Представитель \"Нанотрейзен\""
#define JOB_TITLE_RU_BLUESHIELD "Офицер \"Синий Щит\""

// Engineeering
#define JOB_TITLE_RU_CHIEF_ENGINEER "Главный инженер"
#define JOB_TITLE_RU_ENGINEER "Инженер"
#define JOB_TITLE_RU_ATMOSTECH "Атмосферный специалист"
#define JOB_TITLE_RU_ENGINEER_TRAINEE "Инженер-стажёр"

// Medical
#define JOB_TITLE_RU_CMO "Главный врач"
#define JOB_TITLE_RU_DOCTOR "Врач"
#define JOB_TITLE_RU_CORONER "Патологоанатом"
#define JOB_TITLE_RU_CHEMIST "Химик"
#define JOB_TITLE_RU_GENETICIST "Генетик"
#define JOB_TITLE_RU_VIROLOGIST "Вирусолог"
#define JOB_TITLE_RU_PSYCHIATRIST "Психиатр"
#define JOB_TITLE_RU_PARAMEDIC "Парамедик"
#define JOB_TITLE_RU_MEDICAL_INTERN "Интерн"

// Science
#define JOB_TITLE_RU_RD "Директор исследований"
#define JOB_TITLE_RU_SCIENTIST "Учёный"
#define JOB_TITLE_RU_ROBOTICIST "Робототехник"
#define JOB_TITLE_RU_SPACEPOD_TECHNICIAN "Челнок-инженер"
#define JOB_TITLE_RU_SCIENCE_STUDENT "Учёный-студент"

// Security
#define JOB_TITLE_RU_HOS "Глава Службы Безопасности"
#define JOB_TITLE_RU_WARDEN "Смотритель"
#define JOB_TITLE_RU_DETECTIVE "Детектив"
#define JOB_TITLE_RU_OFFICER "Офицер СБ"
#define JOB_TITLE_RU_BRIGDOC "Бриг-медик"
#define JOB_TITLE_RU_PILOT "Пилот СБ"

// Legal
#define JOB_TITLE_RU_MAGISTRATE "Магистрат"
#define JOB_TITLE_RU_LAWYER "Адвокат"

// Supply
#define JOB_TITLE_RU_QUARTERMASTER "Квартирмейстер"
#define JOB_TITLE_RU_CARGOTECH "Грузчик"
#define JOB_TITLE_RU_MINER "Шахтёр"
#define JOB_TITLE_RU_MINING_MEDIC "Шахтёрский врач"

// Service
#define JOB_TITLE_RU_HOP "Глава персонала"
#define JOB_TITLE_RU_BARTENDER "Бармен"
#define JOB_TITLE_RU_CHEF "Повар"
#define JOB_TITLE_RU_BOTANIST "Ботаник"
#define JOB_TITLE_RU_CHAPLAIN "Священник"
#define JOB_TITLE_RU_CLOWN "Клоун"
#define JOB_TITLE_RU_MIME "Мим"
#define JOB_TITLE_RU_JANITOR "Уборщик"
#define JOB_TITLE_RU_LIBRARIAN "Библиотекарь"
#define JOB_TITLE_RU_EXPLORER "Исследователь"

// Civilians
#define JOB_TITLE_RU_CIVILIAN "Гражданский"
#define JOB_TITLE_RU_PRISONER "Заключённый"

// Silicons
#define JOB_TITLE_RU_AI "Станционный ИИ"
#define JOB_TITLE_RU_CYBORG "Киборг"

// Central Command
#define JOB_TITLE_RU_CCOFFICER "Офицер ЦК \"Нанотрейзен\""
#define JOB_TITLE_RU_CCFIELD "Полевой офицер ЦК \"Нанотрейзен\""
#define JOB_TITLE_RU_CCSPECOPS "Офицер специальных операций \"Нанотрейзен\""
#define JOB_TITLE_RU_CCSUPREME "Верховный главнокомандующий \"Нанотрейзен\""
#define JOB_TITLE_RU_CCSOLGOV "Адмирал Солнечного Флота ТСФ"

// Emergency Response Team (ERT)
#define JOB_TITLE_RU_ERT_MEMBER "Оперативник ОБР"
#define JOB_TITLE_RU_ERT_LEADER "Командир ОБР"
#define JOB_TITLE_RU_ERT_OFFICER "Штурмовик ОБР"
#define JOB_TITLE_RU_ERT_ENGINEER "Инженер ОБР"
#define JOB_TITLE_RU_ERT_MEDIC "Медик ОБР"
#define JOB_TITLE_RU_ERT_INQUISITOR "Инквизитор ОБР"
#define JOB_TITLE_RU_ERT_JANITOR "Клининг-специалист ОБР"

// Syndicate
#define JOB_TITLE_RU_SYNDICATE_OFFICER "Офицер \"Синдиката\""
#define JOB_TITLE_RU_SYNDICATE_OPERATIVE "Оперативник отряда \"Атом\""
#define JOB_TITLE_RU_SYNDICATE_OPERATIVE_LEADER "Лидер отряда \"Атом\""
#define JOB_TITLE_RU_SYNDICATE_AGENT "Агент \"Синдиката\""
#define JOB_TITLE_RU_SYNDICATE_COMMANDO "Командир \"Синдиката\""

// Vox
#define JOB_TITLE_RU_VOX_RAIDER "Вокс-рейдер"
#define JOB_TITLE_RU_VOX_TRADER "Вокс-торговец"

// Battle teams for `de_kerberos_2` game mode
#define JOB_TITLE_RU_TEAM1 "Команда 1"
#define JOB_TITLE_RU_TEAM2 "Команда 2"
#define JOB_TITLE_RU_TEAM3 "Команда 3"

// Taipan
#define JOB_TITLE_RU_TAIPAN_SCIENTIST "Учёный \"Синдиката\""
#define JOB_TITLE_RU_TAIPAN_MEDIC "Медик \"Синдиката\""
#define JOB_TITLE_RU_TAIPAN_BOTANIST "Ботаник \"Синдиката\""
#define JOB_TITLE_RU_TAIPAN_CARGO "Грузчик \"Синдиката\""
#define JOB_TITLE_RU_TAIPAN_CHEF "Повар \"Синдиката\""
#define JOB_TITLE_RU_TAIPAN_ENGINEER "Инженер \"Синдиката\""
#define JOB_TITLE_RU_TAIPAN_COMMS "Офицер коммуникаций \"Синдиката\""
#define JOB_TITLE_RU_TAIPAN_RD "Директор исследований \"Синдиката\""
#define JOB_TITLE_RU_TAIPAN_CYBORG "Киборг"

// Special ones
#define JOB_TITLE_RU_DEMOTED "Разжалован"
#define JOB_TITLE_RU_TERMINATED "Контракт расторгнут"

GLOBAL_LIST_INIT(job_titles_ru, list(
// Command (Solo command, not department heads)
	JOB_TITLE_CAPTAIN = JOB_TITLE_RU_CAPTAIN,
	JOB_TITLE_REPRESENTATIVE = JOB_TITLE_RU_REPRESENTATIVE,
	JOB_TITLE_BLUESHIELD = JOB_TITLE_RU_BLUESHIELD,

// Engineeering
	JOB_TITLE_CHIEF_ENGINEER = JOB_TITLE_RU_CHIEF_ENGINEER,
	JOB_TITLE_ENGINEER = JOB_TITLE_RU_ENGINEER,
	JOB_TITLE_ATMOSTECH = JOB_TITLE_RU_ATMOSTECH,
	JOB_TITLE_ENGINEER_TRAINEE = JOB_TITLE_RU_ENGINEER_TRAINEE,

// Medical
	JOB_TITLE_CMO = JOB_TITLE_RU_CMO,
	JOB_TITLE_DOCTOR = JOB_TITLE_RU_DOCTOR,
	JOB_TITLE_CORONER = JOB_TITLE_RU_CORONER,
	JOB_TITLE_CHEMIST = JOB_TITLE_RU_CHEMIST,
	JOB_TITLE_GENETICIST = JOB_TITLE_RU_GENETICIST,
	JOB_TITLE_VIROLOGIST = JOB_TITLE_RU_VIROLOGIST,
	JOB_TITLE_PSYCHIATRIST = JOB_TITLE_RU_PSYCHIATRIST,
	JOB_TITLE_PARAMEDIC = JOB_TITLE_RU_PARAMEDIC,
	JOB_TITLE_MEDICAL_INTERN = JOB_TITLE_RU_MEDICAL_INTERN,

// Science
	JOB_TITLE_RD = JOB_TITLE_RU_RD,
	JOB_TITLE_SCIENTIST = JOB_TITLE_RU_SCIENTIST,
	JOB_TITLE_ROBOTICIST = JOB_TITLE_RU_ROBOTICIST,
	JOB_TITLE_SPACEPOD_TECHNICIAN = JOB_TITLE_RU_SPACEPOD_TECHNICIAN,
	JOB_TITLE_SCIENCE_STUDENT = JOB_TITLE_RU_SCIENCE_STUDENT,

// Security
	JOB_TITLE_HOS = JOB_TITLE_RU_HOS,
	JOB_TITLE_WARDEN = JOB_TITLE_RU_WARDEN,
	JOB_TITLE_DETECTIVE = JOB_TITLE_RU_DETECTIVE,
	JOB_TITLE_OFFICER = JOB_TITLE_RU_OFFICER,
	JOB_TITLE_BRIGDOC = JOB_TITLE_RU_BRIGDOC,
	JOB_TITLE_PILOT = JOB_TITLE_RU_PILOT,

// Legal
	JOB_TITLE_MAGISTRATE = JOB_TITLE_RU_MAGISTRATE,
	JOB_TITLE_LAWYER = JOB_TITLE_RU_LAWYER,

// Supply
	JOB_TITLE_QUARTERMASTER = JOB_TITLE_RU_QUARTERMASTER,
	JOB_TITLE_CARGOTECH = JOB_TITLE_RU_CARGOTECH,
	JOB_TITLE_MINER = JOB_TITLE_RU_MINER,
	JOB_TITLE_MINING_MEDIC = JOB_TITLE_RU_MINING_MEDIC,

// Service
	JOB_TITLE_HOP = JOB_TITLE_RU_HOP,
	JOB_TITLE_BARTENDER = JOB_TITLE_RU_BARTENDER,
	JOB_TITLE_CHEF = JOB_TITLE_RU_CHEF,
	JOB_TITLE_BOTANIST = JOB_TITLE_RU_BOTANIST,
	JOB_TITLE_CHAPLAIN = JOB_TITLE_RU_CHAPLAIN,
	JOB_TITLE_CLOWN = JOB_TITLE_RU_CLOWN,
	JOB_TITLE_MIME = JOB_TITLE_RU_MIME,
	JOB_TITLE_JANITOR = JOB_TITLE_RU_JANITOR,
	JOB_TITLE_LIBRARIAN = JOB_TITLE_RU_LIBRARIAN,
	JOB_TITLE_EXPLORER = JOB_TITLE_RU_EXPLORER,

// Civilians
	JOB_TITLE_CIVILIAN = JOB_TITLE_RU_CIVILIAN,
	JOB_TITLE_PRISONER = JOB_TITLE_RU_PRISONER,

// Silicons
	JOB_TITLE_AI = JOB_TITLE_RU_AI,
	JOB_TITLE_CYBORG = JOB_TITLE_RU_CYBORG,

// Central Command
	JOB_TITLE_CCOFFICER = JOB_TITLE_RU_CCOFFICER,
	JOB_TITLE_CCFIELD = JOB_TITLE_RU_CCFIELD,
	JOB_TITLE_CCSPECOPS = JOB_TITLE_RU_CCSPECOPS,
	JOB_TITLE_CCSUPREME = JOB_TITLE_RU_CCSUPREME,
	JOB_TITLE_CCSOLGOV = JOB_TITLE_RU_CCSOLGOV,

// Emergency Response Team (ERT)
	JOB_TITLE_ERT_MEMBER = JOB_TITLE_RU_ERT_MEMBER,
	JOB_TITLE_ERT_LEADER = JOB_TITLE_RU_ERT_LEADER,
	JOB_TITLE_ERT_OFFICER = JOB_TITLE_RU_ERT_OFFICER,
	JOB_TITLE_ERT_ENGINEER = JOB_TITLE_RU_ERT_ENGINEER,
	JOB_TITLE_ERT_MEDIC = JOB_TITLE_RU_ERT_MEDIC,
	JOB_TITLE_ERT_INQUISITOR = JOB_TITLE_RU_ERT_INQUISITOR,
	JOB_TITLE_ERT_JANITOR = JOB_TITLE_RU_ERT_JANITOR,

// Syndicate
	JOB_TITLE_SYNDICATE_OFFICER = JOB_TITLE_RU_SYNDICATE_OFFICER,
	JOB_TITLE_SYNDICATE_OPERATIVE = JOB_TITLE_RU_SYNDICATE_OPERATIVE,
	JOB_TITLE_SYNDICATE_OPERATIVE_LEADER = JOB_TITLE_RU_SYNDICATE_OPERATIVE_LEADER,
	JOB_TITLE_SYNDICATE_AGENT = JOB_TITLE_RU_SYNDICATE_AGENT,
	JOB_TITLE_SYNDICATE_COMMANDO = JOB_TITLE_RU_SYNDICATE_COMMANDO,

// Vox
	JOB_TITLE_VOX_RAIDER = JOB_TITLE_RU_VOX_RAIDER,
	JOB_TITLE_VOX_TRADER = JOB_TITLE_RU_VOX_TRADER,

// Battle teams de_kerberos_2
	JOB_TITLE_TEAM1 = JOB_TITLE_RU_TEAM1,
	JOB_TITLE_TEAM2 = JOB_TITLE_RU_TEAM2,
	JOB_TITLE_TEAM3 = JOB_TITLE_RU_TEAM3,

// Taipan
	JOB_TITLE_TAIPAN_SCIENTIST = JOB_TITLE_RU_TAIPAN_SCIENTIST,
	JOB_TITLE_TAIPAN_MEDIC = JOB_TITLE_RU_TAIPAN_MEDIC,
	JOB_TITLE_TAIPAN_BOTANIST = JOB_TITLE_RU_TAIPAN_BOTANIST,
	JOB_TITLE_TAIPAN_CARGO = JOB_TITLE_RU_TAIPAN_CARGO,
	JOB_TITLE_TAIPAN_CHEF = JOB_TITLE_RU_TAIPAN_CHEF,
	JOB_TITLE_TAIPAN_ENGINEER = JOB_TITLE_RU_TAIPAN_ENGINEER,
	JOB_TITLE_TAIPAN_COMMS = JOB_TITLE_RU_TAIPAN_COMMS,
	JOB_TITLE_TAIPAN_RD = JOB_TITLE_RU_TAIPAN_RD,
	JOB_TITLE_TAIPAN_CYBORG = JOB_TITLE_RU_TAIPAN_CYBORG,
))

// MARK: Alt job titles

// Engineer
#define ALT_JOB_TITLE_RU_CONSTRUCTION_WORKER "Монтажник"
#define ALT_JOB_TITLE_RU_POWER_ENGINEER "Оператор реакторного зала"
#define ALT_JOB_TITLE_RU_ELECTRICIAN "Электрик"
// Atmostech
#define ALT_JOB_TITLE_RU_LIFE_SUPPORT_SPECIALIST "Специалист СЖО"
// Trainee engineer
#define ALT_JOB_TITLE_RU_ENGINEER_ASSISTANT "Инженерный ассистент"

// Doctor
#define ALT_JOB_TITLE_RU_SURGEON "Хирург"
#define ALT_JOB_TITLE_RU_TRAUMATOLOGIST "Травматолог"
#define ALT_JOB_TITLE_RU_RESUSCITATOR "Реаниматолог"
#define ALT_JOB_TITLE_RU_THERAPIST "Терапевт"
// Coroner
#define ALT_JOB_TITLE_RU_THANATOLOGIST "Танатолог"
// Chemist
#define ALT_JOB_TITLE_RU_PROVISOR "Провизор"
#define ALT_JOB_TITLE_RU_PHARMACIST "Фармацевт"
// Geneticist
#define ALT_JOB_TITLE_RU_GENETIC_ENGINEER "Генный инженер"
#define ALT_JOB_TITLE_RU_BIOENGINEER "Биоинженер"
#define ALT_JOB_TITLE_RU_CLONING_SPECIALIST "Специалист по клонированию"
// Virologist
#define ALT_JOB_TITLE_RU_INFECTIOUS_DISEASE "Инфекционист"
#define ALT_JOB_TITLE_RU_EPIDEMIOLOGIST "Эпидемиолог"
#define ALT_JOB_TITLE_RU_MICROBIOLOGIST "Микробиолог"
#define ALT_JOB_TITLE_RU_IMMUNOLOGIST "Иммунолог"
// Psychiatrist
#define ALT_JOB_TITLE_RU_PSYCHOLOGIST "Психолог"
#define ALT_JOB_TITLE_RU_PSYCHOTHERAPIST "Психотерапевт"
#define ALT_JOB_TITLE_RU_PSYCHOANALYST "Психоаналитик"
#define ALT_JOB_TITLE_RU_PSYCHONEURO "Психоневролог"
// Paramedic
#define ALT_JOB_TITLE_RU_FELDSHER "Фельдшер"
// Medical intern
#define ALT_JOB_TITLE_RU_MEDICAL_TRAINEE "Врач-практикант"

// Research director
#define ALT_JOB_TITLE_RU_CHIEF_ENGINEER_RESEARCHER "Главный научный сотрудник"
// Scientist
#define ALT_JOB_TITLE_RU_ANOMALIST "Аномалист"
#define ALT_JOB_TITLE_RU_PLASMOLOGIST "Исследователь плазмы"
#define ALT_JOB_TITLE_RU_XENOBIOLOGIST "Ксенобиолог"
#define ALT_JOB_TITLE_RU_RESEARCH_ASSOCIATE "Научный сотрудник"
#define ALT_JOB_TITLE_RU_CHEMICAL_RESEARCHER "Химик-исследователь"
// Roboticist
#define ALT_JOB_TITLE_RU_BIONICS_SPECIALIST "Специалист по бионике"
#define ALT_JOB_TITLE_RU_CYBERNETIC_ENGINEER "Кибернетический инженер"
// Student scientist
#define ALT_JOB_TITLE_RU_JUNIOR_RESEARCHER "Младший научный сотрудник"

// Warden
#define ALT_JOB_TITLE_RU_OVERSEER "Надзиратель"
#define ALT_JOB_TITLE_RU_BRIG_COMMANDANT "Комендант брига"
// Detective
#define ALT_JOB_TITLE_RU_INVESTIGATOR "Следователь"
#define ALT_JOB_TITLE_RU_CRIMINOLOGIST "Криминалист"
// Security officer
#define ALT_JOB_TITLE_RU_PATROL_OFFICER "Патрульный СБ"
// Brig medic
#define ALT_JOB_TITLE_RU_SECURITY_MEDIC "Врач СБ"
#define ALT_JOB_TITLE_RU_TACTICAL_MEDIC "Тактический медик"
// Pod pilot
#define ALT_JOB_TITLE_RU_POD_OPERATOR "Оператор челнока СБ"

// Head of Personnel
#define ALT_JOB_TITLE_RU_HR_DIRECTOR "Директор по персоналу"
#define ALT_JOB_TITLE_RU_PERSONNEL_MANAGER "Кадровый менеджер"
// Bartender
#define ALT_JOB_TITLE_RU_BARISTA "Бариста"
// Chef
#define ALT_JOB_TITLE_RU_SOUS_CHEF "Су-шеф"
#define ALT_JOB_TITLE_RU_CHEF "Шеф"
#define ALT_JOB_TITLE_RU_ART_CHEF "Арт-кулинар"
// Botanist
#define ALT_JOB_TITLE_RU_HYDROPONICS_TECH "Специалист по гидропонике"
#define ALT_JOB_TITLE_RU_BOTANICAL_RESEARCHER "Ботанический исследователь"
#define ALT_JOB_TITLE_RU_AGRONOMIST "Агроном"
#define ALT_JOB_TITLE_RU_AGROBIOLOGIST "Агробиолог"
// Clown
#define ALT_JOB_TITLE_RU_COMEDIAN "Комик"
#define ALT_JOB_TITLE_RU_JESTER "Шут"
#define ALT_JOB_TITLE_RU_COMEDIANT "Комедиант"
// Mime
#define ALT_JOB_TITLE_RU_PANTHOMIMIST "Пантомим"
// Janitor
#define ALT_JOB_TITLE_RU_CLEANING_SPECIALIST "Клининг-специалист"
// Librarian
#define ALT_JOB_TITLE_RU_ARCHIVIST "Архивариус"
#define ALT_JOB_TITLE_RU_JOURNALIST "Журналист"
#define ALT_JOB_TITLE_RU_PRESS_SECRETARY "Пресс-секретарь"
#define ALT_JOB_TITLE_RU_CORRESPONDENT "Корреспондент"
// Chaplain
#define ALT_JOB_TITLE_RU_CHAPLAIN "Капеллан"
#define ALT_JOB_TITLE_RU_PREACHER "Проповедник"
#define ALT_JOB_TITLE_RU_REVEREND "Священнослужитель"
#define ALT_JOB_TITLE_RU_THEOLOGIAN "Теолог"
#define ALT_JOB_TITLE_RU_SPIRITUAL_MENTOR "Духовный наставник"
#define ALT_JOB_TITLE_RU_EXORCIST "Экзорцист"

// Quartermaster
#define ALT_JOB_TITLE_RU_CHIEF_ENGINEER_SUPPLY_MANAGER "Главный менеджер по снабжению"
#define ALT_JOB_TITLE_RU_LOGISTICS_DIRECTOR "Директор по логистике"
// Cargo technician
#define ALT_JOB_TITLE_RU_LOGISTICS_SPECIALIST "Логист"

// Nanotrasen representative
#define ALT_JOB_TITLE_RU_NT_AUDITOR "Аудитор \"Нанотрейзен\""
#define ALT_JOB_TITLE_RU_NT_INSPECTOR "Инспектор \"Нанотрейзен\""
#define ALT_JOB_TITLE_RU_NT_CONSULTANT "Консультант \"Нанотрейзен\""
// Magistrate
#define ALT_JOB_TITLE_RU_JUDGE "Судья"
// Internal affairs agent
#define ALT_JOB_TITLE_RU_LAWYER "Юрист"

// Silicons
#define ALT_JOB_TITLE_RU_CYBORG "Робот"

// Civilian
#define ALT_JOB_TITLE_RU_TOURIST "Турист"
#define ALT_JOB_TITLE_RU_ASSISTANT "Ассистент"
#define ALT_JOB_TITLE_RU_WORKER "Разнорабочий"
#define ALT_JOB_TITLE_RU_GENERAL_INTERN "Стажёр общего профиля"
// Prisoner
#define ALT_JOB_TITLE_RU_ARRESTEE "Арестант"
#define ALT_JOB_TITLE_RU_CONVICT "Осуждённый"

// MARK: Department titles

#define STATION_DEPARTMENT_RU_COMMAND "Командование"
#define STATION_DEPARTMENT_RU_MEDICAL "Медицина"
#define STATION_DEPARTMENT_RU_ENGINEERING "Инженерия"
#define STATION_DEPARTMENT_RU_SCIENCE "Наука"
#define STATION_DEPARTMENT_RU_SECURITY "Безопасность"
#define STATION_DEPARTMENT_RU_SUPPLY "Снабжение"
#define STATION_DEPARTMENT_RU_SERVICE "Обслуживание"
#define STATION_DEPARTMENT_RU_LEGAL "Юриспруденция"
#define STATION_DEPARTMENT_RU_SILICON "Синтетики"
#define STATION_DEPARTMENT_RU_CIVILIAN "Гражданские"
#define STATION_DEPARTMENT_RU_OTHER "Прочее"
