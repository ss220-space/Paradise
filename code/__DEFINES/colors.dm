/**
 * Taken from TG to simplify porting.
 * Please do not breed colors from Paradise when porting!
 */

// Different types of atom colorations
/// Only used by rare effects like greentext coloring mobs and when admins varedit color
#define ADMIN_COLOUR_PRIORITY 1
/// e.g. purple effect of the revenant on a mob, black effect when mob electrocuted
#define TEMPORARY_COLOUR_PRIORITY 2
/// Color splashed onto an atom (e.g. paint on turf)
#define WASHABLE_COLOUR_PRIORITY 3
/// Color inherent to the atom (e.g. blob color)
#define FIXED_COLOUR_PRIORITY 4
///how many colour priority levels there are.
#define COLOUR_PRIORITY_AMOUNT 4
/// If this is a plain atom color
#define ATOM_COLOR_TYPE_NORMAL "normal"
/// If this is a color filter
#define ATOM_COLOR_TYPE_FILTER "filter"
// Indexes for color arrays
#define ATOM_COLOR_VALUE_INDEX 1
#define ATOM_COLOR_TYPE_INDEX 2
#define ATOM_PRIORITY_COLOR_FILTER "atom_priority_color"
#define ATOM_PRIORITY_COLOR_FILTER_PRIORITY -1
/// Multiply pixel's saturation by color's saturation. Paints accents while keeping dim areas dim.
#define SATURATION_MULTIPLY "multiply"
/// Always affects the original pixel's saturation and lightness.
#define SATURATION_OVERRIDE "always"

#define COLOR_DARKMODE_BACKGROUND "#202020"
#define COLOR_DARKMODE_DARKBACKGROUND "#171717"
#define COLOR_DARKMODE_TEXT "#a4bad6"

// White & Black
#define COLOR_WHITE "#ffffff"
#define COLOR_OFF_WHITE "#fff5ed"
#define COLOR_VERY_LIGHT_GRAY "#eeeeee"
#define COLOR_SILVER "#c0c0c0"
#define COLOR_GRAY "#808080"
#define COLOR_FLOORTILE_GRAY "#8d8b8b"
#define COLOR_ASSISTANT_GRAY "#6e6e6e"
#define COLOR_DARK "#454545"
#define COLOR_WEBSAFE_DARK_GRAY "#484848"
#define COLOR_ALMOST_BLACK "#333333"
#define COLOR_FULL_TONER_BLACK "#101010"
#define COLOR_PRISONER_BLACK "#292929"
#define COLOR_NEARLY_ALL_BLACK "#111111"
#define COLOR_BLACK "#000000"
#define COLOR_HALF_TRANSPARENT_BLACK "#0000007a"

// Red
#define COLOR_RED "#ff0000"
#define COLOR_CHRISTMAS_RED "#d6001c"
#define COLOR_OLD_GLORY_RED "#b22234"
#define COLOR_FRENCH_RED "#ef4135"
#define COLOR_ETHIOPIA_RED "#da121a"
#define COLOR_UNION_JACK_RED "#c8102e"
#define COLOR_MEDIUM_DARK_RED "#cc0000"
#define COLOR_PINK_RED "#ef3340"
#define COLOR_SYNDIE_RED "#f10303"
#define COLOR_SYNDIE_RED_HEAD "#760500"
#define COLOR_MOSTLY_PURE_RED "#ff3300"
#define COLOR_DARK_RED "#a50824"
#define COLOR_RED_LIGHT "#ff3333"
#define COLOR_MAROON "#800000"
#define COLOR_FIRE_LIGHT_RED "#b61c1c"
#define COLOR_SECURITY_RED "#cb0000"
#define COLOR_VIVID_RED "#ff3232"
#define COLOR_LIGHT_GRAYISH_RED "#e4c7c5"
#define COLOR_SOFT_RED "#fa8282"
#define COLOR_CULT_RED "#960000"
#define COLOR_BUBBLEGUM_RED "#950a0a"
#define COLOR_CARP_RIFT_RED "#ff330030"

// Yellow
#define COLOR_YELLOW "#ffff00"
#define COLOR_VIVID_YELLOW "#fbff23"
#define COLOR_TANGERINE_YELLOW "#ffcc00"
#define COLOR_VERY_SOFT_YELLOW "#fae48e"
#define COLOR_GOLD "#ffd700"
#define COLOR_ETHIOPIA_YELLOW "#fcdd09"
#define COLOR_LIGHT_YELLOW "#fffee0"

// Green
#define COLOR_OLIVE "#808000"
#define COLOR_OLIVE_GREEN "#677714"
#define COLOR_ASSISTANT_OLIVE "#828163"
#define COLOR_VIBRANT_LIME "#00ff00"
#define COLOR_SERVICE_LIME "#58c800"
#define COLOR_JADE "#5efb6e"
#define COLOR_EMERALD "#00cc66"
#define COLOR_LIME "#32cd32"
#define COLOR_DARK_LIME "#00aa00"
#define COLOR_VERY_PALE_LIME_GREEN "#ddffd3"
#define COLOR_HERETIC_GREEN COLOR_VERY_PALE_LIME_GREEN // i am co-opting this as heretic glow.
#define COLOR_VERY_DARK_LIME_GREEN "#003300"
#define COLOR_GREEN "#008000"
#define COLOR_CHRISTMAS_GREEN "#00873e"
#define COLOR_IRISH_GREEN "#169b62"
#define COLOR_ETHIOPIA_GREEN "#078930"
#define COLOR_DARK_MODERATE_LIME_GREEN "#44964a"
#define COLOR_PAI_GREEN "#00ff88"
#define COLOR_PALE_GREEN "#20e28e"

// Blue
#define COLOR_CYAN "#00ffff"
#define COLOR_HEALING_CYAN "#80f5ff"
#define COLOR_DARK_CYAN "#00a2ff"
#define COLOR_TEAL "#008080"
#define COLOR_BLUE "#0000ff"
#define COLOR_OLD_GLORY_BLUE "#3c3b6e"
#define COLOR_FRENCH_BLUE "#0055a4"
#define COLOR_UNION_JACK_BLUE "#012169"
#define COLOR_TRUE_BLUE "#0066cc"
#define COLOR_STRONG_BLUE "#1919c8"
#define COLOR_CENTCOM_BLUE "#134975"
#define COLOR_BRIGHT_BLUE "#2cb2e8"
#define COLOR_COMMAND_BLUE "#1b67a5"
#define COLOR_MEDICAL_BLUE "#5b97bc"
#define COLOR_MODERATE_BLUE "#555cc2"
#define COLOR_TRAM_BLUE "#6160a8"
#define COLOR_TRAM_LIGHT_BLUE "#a8a7da"
#define COLOR_AMETHYST "#822bff"
#define COLOR_BLUE_LIGHT "#33ccff"
#define COLOR_BLUE_VERY_LIGHT "#ccecff"
#define COLOR_NAVY "#000080"
#define COLOR_BLUE_GRAY "#75a2bb"

// Pink
#define COLOR_PINK "#ffc0cb"
#define COLOR_LIGHT_PINK "#ff3cc8"
#define COLOR_SCIENCE_PINK "#c96dbf"
#define COLOR_MOSTLY_PURE_PINK "#e4005b"
#define COLOR_ADMIN_PINK "#d100d1"
#define COLOR_BLUSH_PINK "#de5d83"
#define COLOR_FADED_PINK "#ff80d5"
#define COLOR_MAGENTA "#ff00ff"
#define COLOR_STRONG_MAGENTA "#b800b8"
#define COLOR_PURPLE "#800080"
#define COLOR_VIOLET "#b900f7"
#define COLOR_VOID_PURPLE "#53277e"
#define COLOR_STRONG_VIOLET "#6927c5"
#define COLOR_DARK_PURPLE "#551a8b"

// Orange
#define COLOR_ORANGE "#ff9900"
#define COLOR_IRISH_ORANGE "#ff883e"
#define COLOR_ENGINEERING_ORANGE "#ffa62b"
#define COLOR_MOSTLY_PURE_ORANGE "#ff8000"
#define COLOR_TAN_ORANGE "#ff7b00"
#define COLOR_BRIGHT_ORANGE "#e2853d"
#define COLOR_LIGHT_ORANGE "#ffc44d"
#define COLOR_PALE_ORANGE "#ffbe9d"
#define COLOR_BEIGE "#ceb689"
#define COLOR_DARK_ORANGE "#c3630c"
#define COLOR_PRISONER_ORANGE "#a54900"
#define COLOR_DARK_MODERATE_ORANGE "#8b633b"
#define COLOR_RUSTED_GLASS "#917c65"

// Brown
#define COLOR_BROWN "#ba9f6d"
#define COLOR_DARK_BROWN "#997c4f"
#define COLOR_DARKER_BROWN "#330000"
#define COLOR_ORANGE_BROWN "#a9734f"
#define COLOR_CARGO_BROWN "#b18644"
#define COLOR_DRIED_TAN "#ad7257"
#define COLOR_LIGHT_BROWN "#996666"
#define COLOR_BROWNER_BROWN "#663300"

// Gray
#define COLOR_GREEN_GRAY "#99bb76"
#define COLOR_RED_GRAY "#b4696a"
#define COLOR_PALE_BLUE_GRAY "#98c5df"
#define COLOR_PALE_GREEN_GRAY "#b7d993"
#define COLOR_PALE_RED_GRAY "#d59998"
#define COLOR_PALE_PURPLE_GRAY "#cbb1ca"
#define COLOR_PURPLE_GRAY "#ae8ca8"
#define COLOR_GOLEM_GRAY "#8e8c81"

// Color defines used by the assembly detailer.
#define COLOR_ASSEMBLY_BLACK "#545454"
#define COLOR_ASSEMBLY_BGRAY "#9497ab"
#define COLOR_ASSEMBLY_WHITE "#e2e2e2"
#define COLOR_ASSEMBLY_RED "#cc4242"
#define COLOR_ASSEMBLY_ORANGE "#e39751"
#define COLOR_ASSEMBLY_BEIGE "#af9366"
#define COLOR_ASSEMBLY_BROWN "#97670e"
#define COLOR_ASSEMBLY_GOLD "#aa9100"
#define COLOR_ASSEMBLY_YELLOW "#ceca2b"
#define COLOR_ASSEMBLY_GURKHA "#999875"
#define COLOR_ASSEMBLY_LGREEN "#789876"
#define COLOR_ASSEMBLY_GREEN "#44843c"
#define COLOR_ASSEMBLY_LBLUE "#5d99be"
#define COLOR_ASSEMBLY_BLUE "#38559e"
#define COLOR_ASSEMBLY_PURPLE "#6f6192"

// Colors for Bioluminescence plant traits.
#define COLOR_BIOLUMINESCENCE_STANDARD "#c3e381"
#define COLOR_BIOLUMINESCENCE_SHADOW "#aad84b"
#define COLOR_BIOLUMINESCENCE_YELLOW "#ffff66"
#define COLOR_BIOLUMINESCENCE_GREEN "#99ff99"
#define COLOR_BIOLUMINESCENCE_BLUE "#6699ff"
#define COLOR_BIOLUMINESCENCE_PURPLE "#d966ff"
#define COLOR_BIOLUMINESCENCE_PINK "#ffb3da"

// Colors for crayons.
#define COLOR_CRAYON_RED "#da0000"
#define COLOR_CRAYON_ORANGE "#ff9300"
#define COLOR_CRAYON_YELLOW "#fff200"
#define COLOR_CRAYON_GREEN "#a8e61d"
#define COLOR_CRAYON_BLUE "#00b7ef"
#define COLOR_CRAYON_PURPLE "#da00ff"
#define COLOR_CRAYON_BLACK "#1c1c1c"
#define COLOR_CRAYON_RAINBOW "#fff000"

// Colors for grayscale tools.
#define COLOR_TOOL_BLUE "#1861d5"
#define COLOR_TOOL_RED "#951710"
#define COLOR_TOOL_PINK "#d5188d"
#define COLOR_TOOL_BROWN "#a05212"
#define COLOR_TOOL_GREEN "#0e7f1b"
#define COLOR_TOOL_CYAN "#18a2d5"
#define COLOR_TOOL_YELLOW "#d58c18"

// Colors for xenobiology vatgrowing.
#define COLOR_SAMPLE_YELLOW "#c0b823"
#define COLOR_SAMPLE_PURPLE "#342941"
#define COLOR_SAMPLE_GREEN "#98b944"
#define COLOR_SAMPLE_BROWN "#91542d"
#define COLOR_SAMPLE_GRAY "#5e5856"

// Colors for blood greyscale sprites.
#define BLOOD_COLOR_RED "#aa1010"
#define BLOOD_COLOR_LIZARD "#035a00"
#define BLOOD_COLOR_XENO "#dffc00"
#define BLOOD_COLOR_OIL "#2c2c2c"
#define BLOOD_COLOR_MACHINE "#1f181f"
#define BLOOD_COLOR_BLACK "#1f1a00"
#define BLOOD_COLOR_DRIED "#370404" // Not to be used normally, only exists for mapper convinience.

// Main colors for UI themes.
#define COLOR_THEME_MIDNIGHT "#6086a0"
#define COLOR_THEME_PLASMAFIRE "#ffb200"
#define COLOR_THEME_RETRO "#24ca00"
#define COLOR_THEME_SLIMECORE "#4fb259"
#define COLOR_THEME_OPERATIVE "#b01232"
#define COLOR_THEME_GLASS "#75a4c4"
#define COLOR_THEME_CLOCKWORK "#CFBA47"
#define COLOR_THEME_TRASENKNOX "#3ce375"
#define COLOR_THEME_DETECTIVE "#c7b08b"

/// Colors for eigenstates.
#define COLOR_PERIWINKLEE "#9999FF"

/// Starlight!
#define COLOR_STARLIGHT "#8589fa"
/**
 * Some defines to generalise colours used in lighting.
 *
 * Important note: colors can end up significantly different from the basic html picture, especially when saturated.
 */
/// Bright light used by default in tubes and bulbs.
#define LIGHT_COLOR_DEFAULT "#f3fffa"
/// Bright but quickly dissipating neon green. rgb(100, 200, 100)
#define LIGHT_COLOR_GREEN "#64c864"
/// Bright, pale "nuclear" green. rgb(120, 255, 120)
#define LIGHT_COLOR_NUCLEAR "#78ff78"
/// Vivid, slightly blue green. rgb(60, 240, 70)
#define LIGHT_COLOR_VIVID_GREEN "#3cf046"
/// Electric green. rgb(0, 255, 0)
#define LIGHT_COLOR_ELECTRIC_GREEN "#00ff00"
/// Cold, diluted blue. rgb(100, 150, 250)
#define LIGHT_COLOR_BLUE "#6496fa"
/// Faint white blue. rgb(222, 239, 255)
#define LIGHT_COLOR_FAINT_BLUE "#deefff"
/// Light blueish green. rgb(125, 225, 175)
#define LIGHT_COLOR_BLUEGREEN "#7de1af"
/// Diluted cyan. rgb(125, 225, 225)
#define LIGHT_COLOR_CYAN "#7de1e1"
/// Faint cyan. rgb(200, 240, 255)
#define LIGHT_COLOR_FAINT_CYAN "#caf0ff"
/// Baby Blue rgb(0, 170, 220)
#define LIGHT_COLOR_BABY_BLUE "#00aadc"
/// Electric cyan rgb(0, 255, 255)
#define LIGHT_COLOR_ELECTRIC_CYAN "#00ffff"
/// More-saturated cyan. rgb(64, 206, 255)
#define LIGHT_COLOR_LIGHT_CYAN "#40ceff"
/// Saturated blue. rgb(51, 117, 248)
#define LIGHT_COLOR_DARK_BLUE "#6496fa"
/// Diluted, mid-warmth pink. rgb(225, 125, 225)
#define LIGHT_COLOR_PINK "#e17de1"
/// Dimmed yellow, leaning kaki. rgb(225, 225, 125)
#define LIGHT_COLOR_DIM_YELLOW "#e1e17d"
/// Bright yellow. rgb(255, 255, 150)
#define LIGHT_COLOR_BRIGHT_YELLOW "#ffff99"
/// Clear brown, mostly dim. rgb(150, 100, 50)
#define LIGHT_COLOR_BROWN "#966432"
/// Mostly pure orange. rgb(250, 150, 50)
#define LIGHT_COLOR_ORANGE "#fa9632"
/// Light Purple. rgb(149, 44, 244)
#define LIGHT_COLOR_PURPLE "#952cf4"
/// Less-saturated light purple. rgb(155, 81, 255)
#define LIGHT_COLOR_LAVENDER "#9b51ff"
///slightly desaturated bright yellow.
#define LIGHT_COLOR_HOLY_MAGIC "#fff743"
/// deep crimson
#define LIGHT_COLOR_BLOOD_MAGIC "#d00000"

// These ones aren't a direct colour like the ones above, because nothing would fit
/// Warm orange color, leaning strongly towards yellow. rgb(250, 160, 25)
#define LIGHT_COLOR_FIRE "#faa019"
/// Very warm yellow, leaning slightly towards orange. rgb(196, 138, 24)
#define LIGHT_COLOR_LAVA "#c48a18"
/// Bright, non-saturated red. Leaning slightly towards pink for visibility. rgb(250, 100, 75)
#define LIGHT_COLOR_FLARE "#fa644b"
/// Vivid red. Leans a bit darker to accentuate red colors and leave other channels a bit dry.  rgb(200, 25, 25)
#define LIGHT_COLOR_INTENSE_RED "#c81919"
/// Weird color, between yellow and green, very slimy. rgb(175, 200, 75)
#define LIGHT_COLOR_SLIME_LAMP "#afc84b"
/// Extremely diluted yellow, close to skin color (for some reason). rgb(255, 214, 170)
#define LIGHT_COLOR_TUNGSTEN "#ffd6aa"
/// Barely visible cyan-ish hue, as the doctor prescribed. rgb(240, 250, 250)
#define LIGHT_COLOR_HALOGEN "#f0fafa"
/// Nearly red. rgb(226, 78, 118)
#define LIGHT_COLOR_BUBBLEGUM "#e24e76"

// The GAGS greyscale_colors for each department's computer/machine circuits
#define CIRCUIT_COLOR_GENERIC "#1a7a13"
#define CIRCUIT_COLOR_COMMAND "#1b4594"
#define CIRCUIT_COLOR_SECURITY "#9a151e"
#define CIRCUIT_COLOR_SCIENCE "#bc4a9b"
#define CIRCUIT_COLOR_SERVICE "#92dcba"
#define CIRCUIT_COLOR_MEDICAL "#00ccff"
#define CIRCUIT_COLOR_ENGINEERING "#f8d700"
#define CIRCUIT_COLOR_SUPPLY "#c47749"

// Colors for pride week
#define COLOR_PRIDE_RED "#ff6666"
#define COLOR_PRIDE_ORANGE "#fc9f3c"
#define COLOR_PRIDE_YELLOW "#eaff51"
#define COLOR_PRIDE_GREEN "#41fc66"
#define COLOR_PRIDE_BLUE "#42fff2"
#define COLOR_PRIDE_PURPLE "#5d5dfc"

// Colors for status/tram/incident displays
#define COLOR_DISPLAY_RED "#be3455"
#define COLOR_DISPLAY_ORANGE "#ff9900"
#define COLOR_DISPLAY_YELLOW "#fff743"
#define COLOR_DISPLAY_GREEN "#3cf046"
#define COLOR_DISPLAY_CYAN "#22ffcc"
#define COLOR_DISPLAY_BLUE "#22ccff"
#define COLOR_DISPLAY_PURPLE "#5d5dfc"

/// The default color for admin say, used as a fallback when the preference is not enabled
#define DEFAULT_ASAY_COLOR COLOR_MOSTLY_PURE_RED

#define DEFAULT_HEX_COLOR_LEN 6

// Color filters
/// Icon filter that creates ambient occlusion
#define AMBIENT_OCCLUSION filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080faa")
/// Icon filter that creates gaussian blur
#define GAUSSIAN_BLUR(filter_size) filter(type="blur", size=filter_size)

// Wire colours.
#define	WIRE_COLOR_BLUE "#2020dd"
#define	WIRE_COLOR_CYAN "#20ddcc"
#define	WIRE_COLOR_GREEN "#20dd20"
#define	WIRE_COLOR_ORANGE "#dd7720"
#define	WIRE_COLOR_PINK "#dd20cc"
#define	WIRE_COLOR_RED "#dd1010"
#define	WIRE_COLOR_WHITE "#dddddd"
#define	WIRE_COLOR_YELLOW "#eebb20"

// Colors related to items used in construction
#define CABLE_COLOR_BLUE "blue"
	#define CABLE_HEX_COLOR_BLUE WIRE_COLOR_BLUE
#define CABLE_COLOR_BROWN "brown"
	#define CABLE_HEX_COLOR_BROWN COLOR_ORANGE_BROWN
#define CABLE_COLOR_CYAN "cyan"
	#define CABLE_HEX_COLOR_CYAN WIRE_COLOR_CYAN
#define CABLE_COLOR_GREEN "green"
	#define CABLE_HEX_COLOR_GREEN WIRE_COLOR_GREEN
#define CABLE_COLOR_ORANGE "orange"
	#define CABLE_HEX_COLOR_ORANGE WIRE_COLOR_ORANGE
#define CABLE_COLOR_PINK "pink"
	#define CABLE_HEX_COLOR_PINK WIRE_COLOR_PINK
#define CABLE_COLOR_RED "red"
	#define CABLE_HEX_COLOR_RED WIRE_COLOR_RED
#define CABLE_COLOR_WHITE "white"
	#define CABLE_HEX_COLOR_WHITE WIRE_COLOR_WHITE
#define CABLE_COLOR_YELLOW "yellow"
	#define CABLE_HEX_COLOR_YELLOW WIRE_COLOR_YELLOW

/// Windows affected by Nar'Sie turn this color.
#define NARSIE_WINDOW_COLOUR "#7d1919"

// Carp colors.
#define COLOR_CARP_PURPLE "#aba2ff"
#define COLOR_CARP_PINK "#da77a8"
#define COLOR_CARP_GREEN "#70ff25"
#define COLOR_CARP_GRAPE "#df0afb"
#define COLOR_CARP_SWAMP "#e5e75a"
#define COLOR_CARP_TURQUOISE "#04e1ed"
#define COLOR_CARP_BROWN "#ca805a"
#define COLOR_CARP_TEAL "#20e28e"
#define COLOR_CARP_LIGHT_BLUE "#4d88cc"
#define COLOR_CARP_RUSTY "#dd5f34"
#define COLOR_CARP_RED "#fd6767"
#define COLOR_CARP_YELLOW "#f3ca4a"
#define COLOR_CARP_BLUE "#09bae1"
#define COLOR_CARP_PALE_GREEN "#7ef099"
#define COLOR_CARP_SILVER "#fdfbf3"
#define COLOR_CARP_DARK_BLUE "#3a384d"
#define COLOR_CARP_DARK_GREEN "#358102"

// Slime colors.
#define COLOR_SLIME_ADAMANTINE "#135f49"
#define COLOR_SLIME_BLACK "#3b3b3b"
#define COLOR_SLIME_BLUE "#19ffff"
#define COLOR_SLIME_BLUESPACE "#ebebeb"
#define COLOR_SLIME_CERULEAN "#5783aa"
#define COLOR_SLIME_DARK_BLUE "#2e9dff"
#define COLOR_SLIME_DARK_PURPLE "#9948f7"
#define COLOR_SLIME_GOLD "#c38b07"
#define COLOR_SLIME_GREEN "#07f024"
#define COLOR_SLIME_GREY "#c2c2c2"
#define COLOR_SLIME_LIGHT_PINK "#ffe1fa"
#define COLOR_SLIME_METAL "#676767"
#define COLOR_SLIME_OIL "#242424"
#define COLOR_SLIME_ORANGE "#ffb445"
#define COLOR_SLIME_PINK "#fe5bbd"
#define COLOR_SLIME_PURPLE "#d138ff"
#define COLOR_SLIME_PYRITE "#ffc427"
#define COLOR_SLIME_RAINBOW COLOR_SLIME_GREY // only for consistency
#define COLOR_SLIME_RED "#fb4848"
#define COLOR_SLIME_SEPIA "#9b8a7a"
#define COLOR_SLIME_SILVER "#dadada"
#define COLOR_SLIME_YELLOW "#fff419"

// Gnome colors.
#define COLOR_GNOME_RED_ONE "#f10b0b"
#define COLOR_GNOME_RED_TWO "#bc5347"
#define COLOR_GNOME_RED_THREE "#b40f1a"
#define COLOR_GNOME_BLUE_ONE "#2e8ff7"
#define COLOR_GNOME_BLUE_TWO "#312bd6"
#define COLOR_GNOME_BLUE_THREE "#4e409a"
#define COLOR_GNOME_GREEN_ONE "#28da1c"
#define COLOR_GNOME_GREEN_TWO "#50a954"
#define COLOR_GNOME_YELLOW "#f6da3c"
#define COLOR_GNOME_ORANGE "#d56f2f"
#define COLOR_GNOME_BROWN_ONE "#874e2a"
#define COLOR_GNOME_BROWN_TWO "#543d2e"
#define COLOR_GNOME_PURPLE "#ac1dd7"
#define COLOR_GNOME_WHITE "#e8e8e8"
#define COLOR_GNOME_GREY "#a9a9a9"
#define COLOR_GNOME_BLACK "#303030"

// Sofa colors.
#define SOFA_BROWN "#a75400"
#define SOFA_MAROON "#830000"

// Icecream colors.
#define COLOR_ICECREAM_VANILLA "#f2eede"
#define COLOR_ICECREAM_CHOCOLATE "#93683c"
#define COLOR_ICECREAM_STRAWBERRY "#f4cbcb"
#define COLOR_ICECREAM_BLUE "#cbd5f4"
#define COLOR_ICECREAM_LEMON "#ffff9f"
#define COLOR_ICECREAM_CARAMEL "#d98736"
#define COLOR_ICECREAM_ORANGESICLE "#ffa980"
#define COLOR_ICECREAM_PEACH "#ffcc66"
#define COLOR_ICECREAM_CUSTOM "#f3f3f3"
#define COLOR_ICECREAM_CHERRY_CHOCOLATE "#800000"

// Defines for .38 ammo type colors.
#define COLOR_AMMO_TRACK "#bd0ed4"
#define COLOR_AMMO_MATCH "#ff0000a8"
#define COLOR_AMMO_RUBBER "#3d3181"
#define COLOR_AMMO_TRUESTRIKE "#ff05de"
#define COLOR_AMMO_DUMDUM "#ffe601"
#define COLOR_AMMO_HOTSHOT "#ff7b00"
#define COLOR_AMMO_ICEBLOX "#0de3ff"
#define COLOR_AMMO_HELLFIRE "#f60021"

// Defines for other ammo type colors (should this be merged with above?)
#define COLOR_AMMO_INCENDIARY "#f4001f"
#define COLOR_AMMO_ARMORPIERCE "#d9d9d9"
#define COLOR_AMMO_HOLLOWPOINT "#ff9900"

// Cerestation rocks (DELETE THIS SHIT PLEASE!)
#define COLOR_ASTEROID_ROCK "#735555"
#define COLOR_ANCIENT_ROCK "#575757"
#define COLOR_COLD_ROCK "#575764"

// Pipe colours.
#define	PIPE_COLOR_GREY "#dddddd"
#define	PIPE_COLOR_RED "#dd1010"
#define	PIPE_COLOR_BLUE "#1010dd"
#define	PIPE_COLOR_CYAN "#10ddcc"
#define	PIPE_COLOR_GREEN "#10dd10"
#define	PIPE_COLOR_YELLOW "#eebb10"
#define	PIPE_COLOR_PURPLE "#5c1ec0"

GLOBAL_LIST_INIT(cable_colors, list(
	CABLE_COLOR_BLUE = CABLE_HEX_COLOR_BLUE,
	CABLE_COLOR_CYAN = CABLE_HEX_COLOR_CYAN,
	CABLE_COLOR_GREEN = CABLE_HEX_COLOR_GREEN,
	CABLE_COLOR_ORANGE = CABLE_HEX_COLOR_ORANGE,
	CABLE_COLOR_PINK = CABLE_HEX_COLOR_PINK,
	CABLE_COLOR_RED = CABLE_HEX_COLOR_RED,
	CABLE_COLOR_WHITE = CABLE_HEX_COLOR_WHITE,
	CABLE_COLOR_YELLOW = CABLE_HEX_COLOR_YELLOW,
	CABLE_COLOR_BROWN = CABLE_HEX_COLOR_BROWN
))

GLOBAL_LIST_INIT(heretic_path_to_color, list(
		PATH_START = COLOR_LIME,
		PATH_RUST = COLOR_CARGO_BROWN,
		PATH_FLESH = COLOR_SOFT_RED,
		PATH_ASH = COLOR_VIVID_RED,
		PATH_VOID = COLOR_CYAN,
		PATH_BLADE = COLOR_SILVER,
		PATH_COSMIC = COLOR_PURPLE,
		PATH_LOCK = COLOR_YELLOW,
		PATH_MOON = COLOR_BLUE_LIGHT,
	))

#define HUSK_COLOR_TONE rgb(96, 88, 80)

// Tweak these defines to change the available color ranges.
#define CM_COLOR_SAT_MIN 0.6
#define CM_COLOR_SAT_MAX 0.7
#define CM_COLOR_LUM_MIN 0.65
#define CM_COLOR_LUM_MAX 0.75

// Lowest priority.
#define EYE_COLOR_ORGAN_PRIORITY 1
/// Base priority for atom colors, gets atom priorities added to it.
#define EYE_COLOR_ATOM_COLOR_PRIORITY 2
#define EYE_COLOR_SPECIES_PRIORITY 10
#define EYE_COLOR_WEED_PRIORITY 20
#define EYE_COLOR_HUD_PRIORITY 30
#define EYE_COLOR_LUMINESCENT_PRIORITY 40
#define EYE_COLOR_CULT_PRIORITY 50

// Client color priorities.
/// Lowest there is, used by glasses.
#define CLIENT_COLOR_GLASSES_PRIORITY 1
/// Same but for helmets.
#define CLIENT_COLOR_HELMET_PRIORITY 2
/// For heads and organs.
#define CLIENT_COLOR_ORGAN_PRIORITY 3
/// Filters which should go ontop of previous ones.
#define CLIENT_COLOR_FILTER_PRIORITY 4
/// Temporary flashing effects.
#define CLIENT_COLOR_TEMPORARY_PRIORITY 5
/// Gameplay important hints signifying antag status or near-death, should be always shown.
#define CLIENT_COLOR_IMPORTANT_PRIORITY 6
/// For effects that are meant to mask all others for technical reasons.
#define CLIENT_COLOR_OVERRIDE_PRIORITY 7

// Color matrix utilities.
#define COLOR_MATRIX_ADD(C) list(COLOR_RED, COLOR_GREEN, COLOR_BLUE, C)
#define COLOR_MATRIX_OVERLAY(C) list(COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, C)
