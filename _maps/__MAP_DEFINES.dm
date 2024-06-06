
// Linkage flags
	#define CROSSLINKED 2
	#define SELFLOOPING 1
	#define UNAFFECTED 0
// Attributes (In text for the convenience of those using VV)
	#define BLOCK_TELEPORT "Blocks Teleport"
	// Impedes with the casting of some spells
	#define IMPEDES_MAGIC "Impedes Magic"
	// A level that indicates a main station level. Optimally on telecomms z-level.
	#define MAIN_STATION "Main Station"
	// A level the station exists on
	#define STATION_LEVEL "Station Level"
	// A level affected by Code Red announcements, cargo telepads, or similar
	#define STATION_CONTACT "Station Contact"
	// A level dedicated to admin use
	#define ADMIN_LEVEL "Admin Level"
	// A level that can be navigated to through space
	#define REACHABLE "Reachable"
	// For away missions - used by some consoles
	#define AWAY_LEVEL "Away"
	// Allows weather
	#define HAS_WEATHER "Weather"
	// Enhances telecomms signals
	#define BOOSTS_SIGNAL "Boosts signals"
	// Currently used for determining mining score
	#define ORE_LEVEL "Mining"
	// Levels the AI can control bots on
	#define AI_OK "AI Allowed"
	/// Ruins will spawn on this z-level
	#define SPAWN_RUINS "Spawn Ruins"
	// Ghost role Taipan z-level.
	#define TAIPAN "RaMSS Taipan"

// Level names
	#define CENTCOMM "CentComm"
	#define ADMIN_ZONE "Admin Zone"
	#define TELECOMMS "Telecomms Satellite"
	#define DERELICT "Derelicted Station"
	#define MINING "Lavaland"
	#define EMPTY_AREA "Empty Area"
	#define AWAY_MISSION "Away Mission"
	#define RAMSS_TAIPAN "RAMSS Taipan"

/*
2024-01-14, the typical z-levels for a single-level station are:
1: CentCom
2: Admin Zone
3: Station
4: Mining
5: Taipan
6: Away mission
7-11: Randomized space
*/

// Whether this z level is linked up/down. Bool.
#define ZTRAIT_UP "Up"
#define ZTRAIT_DOWN "Down"

#define ZTRAIT_GRAVITY "Gravity"	// overrides Z-level gravity making it always on. Unless it's space turf or openspace in a space area. See atom/proc/has_gravity()
#define ZTRAIT_BASETURF "Baseturf"	// overrides Z-level baseturf. set type path by ZTRAIT_BASETURF = "/turf/..."

// 3 Is already big one hella station.
// Making over 3 may consider some big impact on space levels but it saned to top.
// So it "may" have issues if over 3.
#define MULTIZ_WARN 3

#define DEFAULT_STATION_TRATS list(MAIN_STATION, STATION_LEVEL, STATION_CONTACT, REACHABLE, AI_OK)

// Convenience define
#define DECLARE_LEVEL(NAME,LINKS,TRAITS) list("name" = NAME, "linkage" = LINKS, "traits" = TRAITS)

//Ruin Generation

#define SPACERUIN_MAP_EDGE_PAD 15
#define PLACEMENT_TRIES 100 //How many times we try to fit the ruin somewhere until giving up (really should just swap to some packing algo)

#define PLACE_DEFAULT "random"
#define PLACE_SAME_Z "same"
#define PLACE_SPACE_RUIN "space"
#define PLACE_LAVA_RUIN "lavaland"

#define MAX_RUIN_SIZE_VALUE 170 // Which ruin should be considered large and create a separate level of space for it.
