// Language keys.
#define LANGUAGE_NONE				"Нет"
#define LANGUAGE_NOISE				"Шум"
#define LANGUAGE_UNATHI				"Синта'Унати"
#define LANGUAGE_TAJARAN			"Сик'таир"
#define LANGUAGE_VULPKANIN			"Канилунц"
#define LANGUAGE_SKRELL				"Скреллианский"
#define LANGUAGE_VOX				"Вокс-пиджин"
#define LANGUAGE_DIONA				"Песнь корней"
#define LANGUAGE_TRINARY			"Троичный"
#define LANGUAGE_KIDAN				"Хитин"
#define LANGUAGE_SLIME				"Пузырчатый"
#define LANGUAGE_GREY				"Псисвязь"
#define LANGUAGE_DRASK				"Орлуум"
#define LANGUAGE_MOTH				"Ткачий язык"
#define LANGUAGE_GALACTIC_COMMON	"Общегалактический"
#define LANGUAGE_SOL_COMMON			"Общесолнечный"
#define LANGUAGE_TRADER				"Торговый"
#define LANGUAGE_GUTTER				"Гангстерский"
#define LANGUAGE_CLOWN				"Клоунский"
#define LANGUAGE_NEO_RUSSIAN		"Неорусский"
#define LANGUAGE_WRYN				"Разум улья вринов"
#define LANGUAGE_XENOS				"Ксеноморфский"
#define LANGUAGE_HIVE_XENOS			"Разум улья ксеноморфов"
#define LANGUAGE_HIVE_TERRORSPIDER	"Разум улья Пауков Ужаса"
#define LANGUAGE_HIVE_CHANGELING	"Разум улья генокрадов"
#define LANGUAGE_HIVE_EVENTLING		"Инфильтрованный коллективный разум генокрадов"
#define LANGUAGE_HIVE_SHADOWLING	"Коллективный разум тенеморфов"
#define LANGUAGE_HIVE_ABDUCTOR		"Псисвязь абдукторов"
#define LANGUAGE_HIVE_GOLEM			"Псисвязь големов"
#define LANGUAGE_HIVE_BORER			"Кортикальная связь"
#define LANGUAGE_BINARY				"Бинарный канал"
#define LANGUAGE_DRONE_BINARY		"Канал дронов"
#define LANGUAGE_DRONE				"Дрон"
#define LANGUAGE_HIVE_SWARMER		"Связь роевиков"
#define LANGUAGE_MONKEY_HUMAN		"Шимпанзиный"
#define LANGUAGE_MONKEY_SKRELL		"Неарский"
#define LANGUAGE_MONKEY_UNATHI		"Стокский"
#define LANGUAGE_MONKEY_TAJARAN		"Фарвный"
#define LANGUAGE_MONKEY_VULPKANIN	"Вульпинский"
#define LANGUAGE_ANGEL				"Ангельское пение"


// Language flags.
#define WHITELISTED (1<<0)	// Language is available if the speaker is whitelisted.
#define RESTRICTED (1<<1)	// Language can only be accquired by spawning or an admin.
#define HIVEMIND (1<<4)		// Broadcast to all mobs with this language.
#define NONGLOBAL (1<<5)	// Do not add to general languages list
#define INNATE (1<<6)		// All mobs can be assumed to speak and understand this language (audible emotes)
#define NO_TALK_MSG (1<<7)	// Do not show the "\The [speaker] talks into \the [radio]" message
#define NO_STUTTER (1<<8)	// No stuttering, slurring, or other speech problems
#define NOBABEL (1<<9)		// Not granted by book of babel. Typically antag languages.
#define UNIQUE (1<<10)		// Secondary languages for species.

//Auto-accent level defines.
#define AUTOHISS_OFF 0
#define AUTOHISS_BASIC 1
#define AUTOHISS_FULL 2
#define AUTOHISS_NUM 3 //Number of auto-accent options.
