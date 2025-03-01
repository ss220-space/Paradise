// Globals
/// The feed network singleton. Contains all channels (which contain all stories).
GLOBAL_DATUM_INIT(news_network, /datum/feed_network, new)
/// Global list that contains all existing newscasters in the world.
GLOBAL_LIST_EMPTY(allNewscasters)

// Screen indexes
/// Headlines screen index.
#define NEWSCASTER_HEADLINES	0
/// Available Jobs screen index.
#define NEWSCASTER_JOBS			1
/// View Channel screen index.
#define NEWSCASTER_CHANNEL		2

// Channels and main editors names
/// Station Announcements - every big text like "nuke ops incoming"
#define NEWS_CHANNEL_STATION "Public Station Announcements"
	#define EDITOR_STATION "Automated Announcement Listing"
/// Nyx Daily - everyday-ish news about NT
#define NEWS_CHANNEL_NYX "Nyx Daily"
	#define EDITOR_NYX "CentComm Minister of Information"
/// Gibson Gazette - everyhour-ish news about clickbait-worthy topics
#define NEWS_CHANNEL_GIB "The Gibson Gazette"
	#define EDITOR_GIB "Editor Mike Hammers"

// Censor flags
/// Censor author name.
#define CENSOR_AUTHOR (1 << 0)
/// Censor story title, body and image.
#define CENSOR_STORY (1 << 1)
