///////////////////////////////
//          WARNING          //
////////////////////////////////////////////////////////////////////////
// Do NOT touch the values associated with these defines, as they are //
// used by the game database to keep track of job flags. Do NOT touch //
////////////////////////////////////////////////////////////////////////

#define JOBCAT_ENGSEC			(1<<0)

#define JOB_FLAG_CAPTAIN			(1<<0)
#define JOB_FLAG_HOS				(1<<1)
#define JOB_FLAG_WARDEN			(1<<2)
#define JOB_FLAG_DETECTIVE			(1<<3)
#define JOB_FLAG_OFFICER			(1<<4)
#define JOB_FLAG_CHIEF				(1<<5)
#define JOB_FLAG_ENGINEER			(1<<6)
#define JOB_FLAG_ATMOSTECH			(1<<7)
#define JOB_FLAG_AI				(1<<8)
#define JOB_FLAG_CYBORG			(1<<9)
#define JOB_FLAG_CENTCOM			(1<<10)
#define JOB_FLAG_SYNDICATE			(1<<11)
#define JOB_FLAG_ENGINEER_TRAINEE	(1<<12)

#define JOBCAT_MEDSCI			(1<<1)

#define JOB_FLAG_RD				(1<<0)
#define JOB_FLAG_SCIENTIST			(1<<1)
#define JOB_FLAG_CHEMIST			(1<<2)
#define JOB_FLAG_CMO				(1<<3)
#define JOB_FLAG_DOCTOR			(1<<4)
#define JOB_FLAG_GENETICIST		(1<<5)
#define JOB_FLAG_VIROLOGIST		(1<<6)
#define JOB_FLAG_PSYCHIATRIST		(1<<7)
#define JOB_FLAG_ROBOTICIST		(1<<8)
#define JOB_FLAG_PARAMEDIC			(1<<9)
#define JOB_FLAG_CORONER			(1<<10)
#define JOB_FLAG_SCIENTIST_STUDENT	(1<<11)
#define JOB_FLAG_INTERN			(1<<12)


#define JOBCAT_SUPPORT			(1<<2)

#define JOB_FLAG_HOP				(1<<0)
#define JOB_FLAG_BARTENDER			(1<<1)
#define JOB_FLAG_BOTANIST			(1<<2)
#define JOB_FLAG_CHEF				(1<<3)
#define JOB_FLAG_JANITOR			(1<<4)
#define JOB_FLAG_LIBRARIAN			(1<<5)
#define JOB_FLAG_QUARTERMASTER		(1<<6)
#define JOB_FLAG_CARGOTECH			(1<<7)
#define JOB_FLAG_MINER				(1<<8)
#define JOB_FLAG_LAWYER			(1<<9)
#define JOB_FLAG_CHAPLAIN			(1<<10)
#define JOB_FLAG_CLOWN				(1<<11)
#define JOB_FLAG_MIME				(1<<12)
#define JOB_FLAG_CIVILIAN			(1<<13)
#define JOB_FLAG_EXPLORER			(1<<14)

#define JOBCAT_KARMA				(1<<3)

#define JOB_FLAG_REPRESENTATIVE				(1<<0)
#define JOB_FLAG_BLUESHIELD		(1<<1)
#define JOB_FLAG_BARBER			(1<<3)
#define JOB_FLAG_MECHANIC			(1<<4)
#define JOB_FLAG_BRIGDOC			(1<<5)
#define JOB_FLAG_JUDGE				(1<<6)
#define JOB_FLAG_PILOT				(1<<7)

///Определения ниже используются в качестве названий должностей
#define JOB_TITLE_CIVILIAN "Гражданский"

#define JOB_TITLE_CHIEF "Главный Инженер"
#define JOB_TITLE_ENGINEER "Станционный Инженер"
#define JOB_TITLE_ENGINEER_TRAINEE "Стажёр"
#define JOB_TITLE_ATMOSTECH "Атмосферный Техник"
#define JOB_TITLE_MECHANIC "Механик"

#define JOB_TITLE_CMO "Главный Врач"
#define JOB_TITLE_DOCTOR "Врач"
#define JOB_TITLE_INTERN "Интерн"
#define JOB_TITLE_CORONER "Патологоанатом"
#define JOB_TITLE_CHEMIST "Химик"
#define JOB_TITLE_GENETICIST "Генетик"
#define JOB_TITLE_VIROLOGIST "Вирусолог"
#define JOB_TITLE_PSYCHIATRIST "Психиатр"
#define JOB_TITLE_PARAMEDIC "Парамедик"

#define JOB_TITLE_RD "Директор Исследований"
#define JOB_TITLE_SCIENTIST "Ученый"
#define JOB_TITLE_SCIENTIST_STUDENT "Студент"
#define JOB_TITLE_ROBOTICIST "Робототехник"

#define JOB_TITLE_HOS "Глава службы безопасности"
#define JOB_TITLE_WARDEN "Смотритель"
#define JOB_TITLE_DETECTIVE "Детектив"
#define JOB_TITLE_OFFICER "Офицер"
#define JOB_TITLE_BRIGDOC "Врач брига"
#define JOB_TITLE_PILOT "Пилот"

#define JOB_TITLE_AI "ИИ"
#define JOB_TITLE_CYBORG "Киборг"

#define JOB_TITLE_CAPTAIN "Капитан"
#define JOB_TITLE_HOP "Глава Персонала"
#define JOB_TITLE_REPRESENTATIVE "Представитель NanoTrasen"
#define JOB_TITLE_BLUESHIELD "Офицер «Синий щит»"
#define JOB_TITLE_JUDGE "Магистрат"
#define JOB_TITLE_LAWYER "Агент Внутренних Дел"

#define JOB_TITLE_CHAPLAIN "Священник"

#define JOB_TITLE_QUARTERMASTER "Квартирмейстер"
#define JOB_TITLE_CARGOTECH "Грузчик"
#define JOB_TITLE_MINER "Шахтер"

#define JOB_TITLE_BARTENDER "Бармен"
#define JOB_TITLE_CHEF "Повар"
#define JOB_TITLE_BOTANIST "Ботаник"
#define JOB_TITLE_CLOWN "Клоун"
#define JOB_TITLE_MIME "Мим"
#define JOB_TITLE_JANITOR "Уборщик"
#define JOB_TITLE_LIBRARIAN "Библиотекарь"
#define JOB_TITLE_BARBER "Парикмахер"
#define JOB_TITLE_EXPLORER "Исследователь"

#define JOB_TITLE_SYNDICATE "Офицер Синдиката"
#define JOB_TITLE_CCOFFICER "Офицер Флота Nanotrasen"
#define JOB_TITLE_CCFIELD "Полевой Офицер Флота Nanotrasen"
#define JOB_TITLE_CCSPECOPS "Офицер Специальных Операций"
#define JOB_TITLE_CCSUPREME "Верховный Главнокомандующий"
#define JOB_TITLE_CCSOLGOV "Генерал Солнечной Федерации"

///Всё, что связано с гост-ролями Taipan.

#define TAIPAN_SCIENTIST	"Учёный Космической Базы Синдиката"
#define TAIPAN_MEDIC 		"Медик Космической Базы Синдиката"
#define TAIPAN_BOTANIST		"Ботаник Космической базы Синдиката"
#define TAIPAN_CARGO		"Грузчик Космической базы Синдиката"
#define TAIPAN_CHEF			"Повар Космической базы Синдиката"
#define TAIPAN_ENGINEER		"Инженер Космической базы Синдиката"
#define TAIPAN_COMMS 		"Офицер Связи Космической базы Синдиката"
#define TAIPAN_RD			"Директор Исследований Космической базы Синдиката"
#define CYBORG				"Киборг"

#define TAIPAN_HUD_SCIENTIST	1
#define TAIPAN_HUD_MEDIC 		2
#define TAIPAN_HUD_BOTANIST		3
#define TAIPAN_HUD_CARGO		4
#define TAIPAN_HUD_CHEF			5
#define TAIPAN_HUD_ENGINEER		6
#define TAIPAN_HUD_COMMS 		7
#define TAIPAN_HUD_RD			8
#define TAIPAN_HUD_CYBORG		9
