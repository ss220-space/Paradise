// Globals
/// The feed network singleton. Contains all channels (which contain all stories).
GLOBAL_DATUM_INIT(news_network, /datum/feed_network, new)
/// Global list that contains all existing newscasters in the world.
GLOBAL_LIST_EMPTY(allNewscasters)

// Screen indexes
/// Headlines screen index.
#define NEWSCASTER_HEADLINES 0
/// Available Jobs screen index.
#define NEWSCASTER_JOBS 1
/// View Channel screen index.
#define NEWSCASTER_CHANNEL 2

// Channels and main editors names
/// Station Announcements Log -  it silently publishes every announcement as a news story.
#define NEWS_CHANNEL_STATION_LOG "Журнал станционных оповещений"
/// Station Announcements - in newscaster is now public channel by default.
#define NEWS_CHANNEL_STATION "Публичные станционные оповещения"
	#define EDITOR_STATION "Автоматический листинг оповещений"
/// Nyx Daily - everyday-ish news about NT
#define NEWS_CHANNEL_NYX "Никс Дейли"
	#define EDITOR_NYX "Отдел Медиа \"Нанотрейзен\""
/// Gibson Gazette - everyhour-ish news about clickbait-worthy topics
#define NEWS_CHANNEL_GIB "Газета Гибсона"
	#define EDITOR_GIB "Редактор Майк Хаммерс"

// Censor flags
/// Censor author name.
#define CENSOR_AUTHOR (1<<0)
/// Censor story title, body and image.
#define CENSOR_STORY (1<<1)
