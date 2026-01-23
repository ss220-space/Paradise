GLOBAL_LIST_EMPTY(job_titles_ru_to_en)

/**
 * Get job title in Russian by English job title
 * 
 * Should be used for display purposes only, not the logic
 */
/proc/get_job_title_ru(en_title)
	return GLOB.job_titles_ru[en_title] || en_title

/// Get job title in English by Russian job title

/**
 * Get job title in English by Russian job title
 *
 * Should be used for logic purposes only, not the display
 */
/proc/job_title_ru_to_en(ru_title)
	if(!length(GLOB.job_titles_ru_to_en))
		for(var/key in GLOB.job_titles_ru)
			GLOB.job_titles_ru_to_en[GLOB.job_titles_ru[key]] = key
	return GLOB.job_titles_ru_to_en[ru_title] || ru_title

// MARK: Russian job titles

// Command (Solo command, not department heads)
#define JOB_TITLE_RU_CAPTAIN "Капитан"
#define JOB_TITLE_RU_REPRESENTATIVE "Представитель \"Нанотрейзен\""
#define JOB_TITLE_RU_BLUESHIELD "Офицер \"Синий Щит\""

// Engineeering
#define JOB_TITLE_RU_CHIEF "Главный инженер"
#define JOB_TITLE_RU_ENGINEER "Инженер"
#define JOB_TITLE_RU_ENGINEER_TRAINEE "Стажёр"
#define JOB_TITLE_RU_ATMOSTECH "Атмосферный техник"
#define JOB_TITLE_RU_MECHANIC "Механик"

// Medical
#define JOB_TITLE_RU_CMO "Главный врач"
#define JOB_TITLE_RU_DOCTOR "Врач"
#define JOB_TITLE_RU_INTERN "Интерн"
#define JOB_TITLE_RU_CORONER "Патологоанатом"
#define JOB_TITLE_RU_CHEMIST "Химик"
#define JOB_TITLE_RU_GENETICIST "Генетик"
#define JOB_TITLE_RU_VIROLOGIST "Вирусолог"
#define JOB_TITLE_RU_PSYCHIATRIST "Психиатр"
#define JOB_TITLE_RU_PARAMEDIC "Парамедик"

// Science
#define JOB_TITLE_RU_RD "Научный руководитель"
#define JOB_TITLE_RU_SCIENTIST "Учёный"
#define JOB_TITLE_RU_SCIENTIST_STUDENT "Студент"
#define JOB_TITLE_RU_ROBOTICIST "Робототехник"

// Security
#define JOB_TITLE_RU_HOS "Глава службы безопасности"
#define JOB_TITLE_RU_WARDEN "Смотритель"
#define JOB_TITLE_RU_DETECTIVE "Детектив"
#define JOB_TITLE_RU_OFFICER "Офицер службы безопасности"
#define JOB_TITLE_RU_BRIGDOC "Бриг-медик"
#define JOB_TITLE_RU_PILOT "Пилот"

// Legal
#define JOB_TITLE_RU_JUDGE "Магистрат"
#define JOB_TITLE_RU_LAWYER "Агент внутренних дел"

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
#define JOB_TITLE_RU_AI "ИИ"
#define JOB_TITLE_RU_CYBORG "Робот"

// Central Command
#define JOB_TITLE_RU_CCOFFICER "Офицер ЦК \"Нанотрейзен\""
#define JOB_TITLE_RU_CCFIELD "Полевой офицер ЦК \"Нанотрейзен\""
#define JOB_TITLE_RU_CCSPECOPS "Офицер специальных операций \"Нанотрейзен\""
#define JOB_TITLE_RU_CCSUPREME "Верховный главнокомандующий \"Нанотрейзен\""
#define JOB_TITLE_RU_CCSOLGOV "Адмирал \"Флота Глубокого Космоса\" ТСФ"

// Syndicate
#define JOB_TITLE_RU_SYNDICATE_OFFICER "Офицер \"Синдиката\""
#define JOB_TITLE_RU_SYNDICATE_OPERATIVE "Оперативник отряда \"Атом\""
#define JOB_TITLE_RU_SYNDICATE_OPERATIVE_LEADER "Лидер отряда \"Атом\""
#define JOB_TITLE_RU_SYNDICATE_AGENT "Агент \"Синдиката\""
#define JOB_TITLE_RU_SYNDICATE_COMMANDO "Командир \"Синдиката\""

// Vox
#define JOB_TITLE_RU_VOX_RAIDER "Вокс-рейдер"
#define JOB_TITLE_RU_VOX_TRADER "Вокс-торговец"

// Battle teams de_kerberos_2
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
#define JOB_TITLE_RU_TAIPAN_COMMS "Офицер связи \"Синдиката\""
#define JOB_TITLE_RU_TAIPAN_RD "Научный руководитель \"Синдиката\""
#define JOB_TITLE_RU_TAIPAN_CYBORG "Робот"

// Other
#define JOB_TITLE_RU_DEMOTED "Разжалован"
#define JOB_TITLE_RU_TERMINATED "Уволен"

GLOBAL_LIST_INIT(job_titles_ru, list(
// Command (Solo command, not department heads)
	JOB_TITLE_CAPTAIN = JOB_TITLE_RU_CAPTAIN,
	JOB_TITLE_REPRESENTATIVE = JOB_TITLE_RU_REPRESENTATIVE,
	JOB_TITLE_BLUESHIELD = JOB_TITLE_RU_BLUESHIELD,

// Engineeering
	JOB_TITLE_CHIEF = JOB_TITLE_RU_CHIEF,
	JOB_TITLE_ENGINEER = JOB_TITLE_RU_ENGINEER,
	JOB_TITLE_ENGINEER_TRAINEE = JOB_TITLE_RU_ENGINEER_TRAINEE,
	JOB_TITLE_ATMOSTECH = JOB_TITLE_RU_ATMOSTECH,
	JOB_TITLE_MECHANIC = JOB_TITLE_RU_MECHANIC,

// Medical
	JOB_TITLE_CMO = JOB_TITLE_RU_CMO,
	JOB_TITLE_DOCTOR = JOB_TITLE_RU_DOCTOR,
	JOB_TITLE_INTERN = JOB_TITLE_RU_INTERN,
	JOB_TITLE_CORONER = JOB_TITLE_RU_CORONER,
	JOB_TITLE_CHEMIST = JOB_TITLE_RU_CHEMIST,
	JOB_TITLE_GENETICIST = JOB_TITLE_RU_GENETICIST,
	JOB_TITLE_VIROLOGIST = JOB_TITLE_RU_VIROLOGIST,
	JOB_TITLE_PSYCHIATRIST = JOB_TITLE_RU_PSYCHIATRIST,
	JOB_TITLE_PARAMEDIC = JOB_TITLE_RU_PARAMEDIC,

// Science
	JOB_TITLE_RD = JOB_TITLE_RU_RD,
	JOB_TITLE_SCIENTIST = JOB_TITLE_RU_SCIENTIST,
	JOB_TITLE_SCIENTIST_STUDENT = JOB_TITLE_RU_SCIENTIST_STUDENT,
	JOB_TITLE_ROBOTICIST = JOB_TITLE_RU_ROBOTICIST,

// Security
	JOB_TITLE_HOS = JOB_TITLE_RU_HOS,
	JOB_TITLE_WARDEN = JOB_TITLE_RU_WARDEN,
	JOB_TITLE_DETECTIVE = JOB_TITLE_RU_DETECTIVE,
	JOB_TITLE_OFFICER = JOB_TITLE_RU_OFFICER,
	JOB_TITLE_BRIGDOC = JOB_TITLE_RU_BRIGDOC,
	JOB_TITLE_PILOT = JOB_TITLE_RU_PILOT,

// Legal
	JOB_TITLE_JUDGE = JOB_TITLE_RU_JUDGE,
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

// MARK: Alt Russian job titles

// Civilian
#define ALT_JOB_TITLE_RU_TOURIST "Турист"
#define ALT_JOB_TITLE_RU_BUSSINESSMAN "Бизнесмен"
#define ALT_JOB_TITLE_RU_TRADER "Торговец"
#define ALT_JOB_TITLE_RU_ASSISTANT "Ассистент"
#define ALT_JOB_TITLE_RU_FREELANCER "Фрилансер"
#define ALT_JOB_TITLE_RU_WORKER "Разнорабочий"
// Prisoner
#define ALT_JOB_TITLE_RU_ARRESTEE "Арестант"
// Engineer
#define ALT_JOB_TITLE_RU_MAINTENANCE_TECHNICIAN "Технический специалист"
#define ALT_JOB_TITLE_RU_ENGINE_TECHNICIAN "Инженер-двигателист"
#define ALT_JOB_TITLE_RU_ELECTRICIAN "Инженер-электрик"
// Trainee engineer
#define ALT_JOB_TITLE_RU_ENGINEER_STUDENT "Студент-инженер"
#define ALT_JOB_TITLE_RU_ENGINEER_ASSISTANT "Инженерный ассистент"
// Doctor
#define ALT_JOB_TITLE_RU_SURGEON "Хирург"
#define ALT_JOB_TITLE_RU_NURSE "Санитар"
// Medical intern
#define ALT_JOB_TITLE_RU_MEDICAL_STUDENT "Студент-врач"
#define ALT_JOB_TITLE_RU_MEDICAL_ASSISTANT "Медицинский ассистент"
// Chemist
#define ALT_JOB_TITLE_RU_PHARMACIST "Фармацевт"
// Virologist
#define ALT_JOB_TITLE_RU_MICROBIOLOGIST "Микробиолог"
// Psychiatrist
#define ALT_JOB_TITLE_RU_PSYCHOLOGIST "Психолог"
#define ALT_JOB_TITLE_RU_THERAPIST "Психотерапевт"
// Scientist
#define ALT_JOB_TITLE_RU_ANOMALIST "Аномалист"
#define ALT_JOB_TITLE_RU_PLASMA_RESEARCHER "Исследователь плазмы"
#define ALT_JOB_TITLE_RU_XENOBIOLOGIST "Ксенобиолог"
#define ALT_JOB_TITLE_RU_CHEMICAL_RESEARCHER "Химический исследователь"
// Student scientist
#define ALT_JOB_TITLE_RU_SCIENCE_STUDENT "Студент-учёный"
#define ALT_JOB_TITLE_RU_SCIENCE_ASSISTANT "Научный ассистент"
#define ALT_JOB_TITLE_RU_ROBOTICIST_STUDENT "Студент-робототехник"
// Roboticist
#define ALT_JOB_TITLE_RU_BIOMECHANICAL_ENGINEER "Биомеханический инженер"
#define ALT_JOB_TITLE_RU_CYBERNETIC_ENGINEER "Кибернетический инженер"
// Warden
#define ALT_JOB_TITLE_RU_BRIG_SERGEANT "Бриг-сержант"
#define ALT_JOB_TITLE_RU_OVERSEER "Надзиратель"
// Detective
#define ALT_JOB_TITLE_RU_INVESTIGATOR "Следователь"
#define ALT_JOB_TITLE_RU_CRIMINOLOGIST "Криминалист"
// Security officer
#define ALT_JOB_TITLE_RU_SECURITY_TRAINER "Инструктор службы безопасности"
#define ALT_JOB_TITLE_RU_PATROL_OFFICER "Патрульный офицер"
#define ALT_JOB_TITLE_RU_SECURITY_CADET "Кадет"
// Security cadet (not usable right now because Cadet role was removed)
#define ALT_JOB_TITLE_RU_JUNIOR_OFFICER "Младший офицер"
#define ALT_JOB_TITLE_RU_SECURITY_TRAINEE "Стажёр службы безопасности"
// Brig medic
#define ALT_JOB_TITLE_RU_SECURITY_MEDIC "Врач службы безопасности"
#define ALT_JOB_TITLE_RU_COMBAT_MEDIC "Боевой медик"
// Bartender
#define ALT_JOB_TITLE_RU_DRINK_ARTIST "Мастер коктейлей"
// Chef
#define ALT_JOB_TITLE_RU_CULINARY_ARTIST "Кулинарный художник"
#define ALT_JOB_TITLE_RU_SOUS_CHEF "Су-шеф"
#define ALT_JOB_TITLE_RU_BUTCHER "Мясник"
// Botanist
#define ALT_JOB_TITLE_RU_HYDROPONIST "Гидропоник"
#define ALT_JOB_TITLE_RU_BOTANICAL_RESEARCHER "Ботанический исследователь"
// Clown
#define ALT_JOB_TITLE_RU_COMEDIAN "Комик"
#define ALT_JOB_TITLE_RU_JESTER "Шут"
#define ALT_JOB_TITLE_RU_COMEDIANT "Комедиант"
// Mime
#define ALT_JOB_TITLE_RU_PANTHOMIMIST "Пантомимист"
// Janitor
#define ALT_JOB_TITLE_RU_CLEANING_SPECIALIST "Клининговый специалист"
// Librarian
#define ALT_JOB_TITLE_RU_ARCHIVIST "Архивариус"
#define ALT_JOB_TITLE_RU_JOURNALIST "Журналист"
// Chaplain
#define ALT_JOB_TITLE_RU_SPIRITUAL_ADVISOR "Духовный наставник"
#define ALT_JOB_TITLE_RU_CHAPLAIN "Капеллан"
#define ALT_JOB_TITLE_RU_PREACHER "Проповедник"
#define ALT_JOB_TITLE_RU_REVEREND "Священнослужитель"
#define ALT_JOB_TITLE_RU_ORACLE "Оракул"
#define ALT_JOB_TITLE_RU_NUN "Монахиня"
#define ALT_JOB_TITLE_RU_MONK "Монах"
#define ALT_JOB_TITLE_RU_IMAM "Имам"
#define ALT_JOB_TITLE_RU_RABBI "Раввин"
#define ALT_JOB_TITLE_RU_PASTOR "Пастор"
// Nanotrasen representative
#define ALT_JOB_TITLE_RU_NT_AUDITOR "Аудитор \"Нанотрейзен\""
#define ALT_JOB_TITLE_RU_NT_INSPECTOR "Инспектор \"Нанотрейзен\""
#define ALT_JOB_TITLE_RU_NT_CONSULTANT "Консультант \"Нанотрейзен\""
// Magistrate
#define ALT_JOB_TITLE_RU_JUDGE "Судья"
// Internal affairs agent
#define ALT_JOB_TITLE_RU_LAWYER "Юрист"
#define ALT_JOB_TITLE_RU_ATTORNEY "Адвокат"
// Quartermaster
#define ALT_JOB_TITLE_RU_CHIEF_SUPPLY_MANAGER "Главный менеджер по снабжению"
#define ALT_JOB_TITLE_RU_QM_ALT "Заведующий складом"
// Cargo technician
#define ALT_JOB_TITLE_RU_LOGISTICS_SPECIALIST "Специалист по логистике"
#define ALT_JOB_TITLE_RU_WAREHOUSE_WORKER "Работник склада"
#define ALT_JOB_TITLE_RU_SUPPLY_MANAGER "Менеджер по снабжению"

// MARK: Russian department titles

#define STATION_DEPARTMENT_RU_COMMAND "Командование"
#define STATION_DEPARTMENT_RU_MEDICAL "Медицина"
#define STATION_DEPARTMENT_RU_ENGINEERING "Инженерия"
#define STATION_DEPARTMENT_RU_SCIENCE "Наука"
#define STATION_DEPARTMENT_RU_SECURITY "Безопасность"
#define STATION_DEPARTMENT_RU_SUPPLY "Снабжение"
#define STATION_DEPARTMENT_RU_SERVICE "Обслуживание"
#define STATION_DEPARTMENT_RU_LEGAL "Юриспруденция"
#define STATION_DEPARTMENT_RU_SILICON "Силиконы"
#define STATION_DEPARTMENT_RU_CIVILIAN "Гражданские"
#define STATION_DEPARTMENT_RU_OTHER "прочее"
