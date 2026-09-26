#define BAD_INIT_QDEL_BEFORE 1
#define BAD_INIT_DIDNT_INIT 2
#define BAD_INIT_SLEPT 4
#define BAD_INIT_NO_HINT 8

// Lootpanel icon render modes for [/atom/var/looting_icon_mode], used by [/datum/search_object].
/// Cheap render via icon2html(). Default for plain atoms with a simple, file-backed icon.
#define LOOT_ICON_ICON_TO_HTML 0
/// Expensive flat render via flat_icon2html(), unique per instance. For appearances that vary per
/// instance (mobs, silicons, ghosts) so each preview reflects that specific object.
#define LOOT_ICON_FLAT_ICON 1
/// Flat render shared across all instances of a type, cached by typepath in
/// [/datum/search_object/var/icon_cache]. For complex but type-uniform icons (e.g. many overlays).
#define LOOT_ICON_FLAT_ICON_TYPE_CACHABLE 2
