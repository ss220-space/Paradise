/*ALL DEFINES RELATED TO CONSTRUCTION, CONSTRUCTING THINGS, OR CONSTRUCTED OBJECTS GO HERE*/

//Defines for construction states

//girder construction states
#define GIRDER_NORMAL 0
#define GIRDER_REINF_STRUTS 1
#define GIRDER_REINF 2
#define GIRDER_DISPLACED 3
#define GIRDER_DISASSEMBLED 4

//rwall construction states
#define RWALL_INTACT 0
#define RWALL_SUPPORT_LINES 1
#define RWALL_COVER 2
#define RWALL_CUT_COVER 3
#define RWALL_BOLTS 4
#define RWALL_SUPPORT_RODS 5
#define RWALL_SHEATH 6

//window construction states
#define WINDOW_OUT_OF_FRAME 0
#define WINDOW_IN_FRAME 1
#define WINDOW_SCREWED_TO_FRAME 2

//airlock assembly construction states
#define AIRLOCK_ASSEMBLY_NEEDS_WIRES 0
#define AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS 1
#define AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER 2

//used by airlocks and airlock wires.
#define AICONTROLDISABLED_OFF 0 // Silicons can control the airlock normally.
#define AICONTROLDISABLED_ON 1 // Silicons cannot control the airlock, but can hack the airlock.
#define AICONTROLDISABLED_BYPASS 2 // Silicons can control the airlock because they succeeded on the hack
#define AICONTROLDISABLED_PERMA 3 // Wire cutting an airlock on AICONTROLDISABLED_BYPASS toggles it between AICONTROLDISABLED_BYPASS and this.

//plastic flaps construction states
#define PLASTIC_FLAPS_NORMAL 0
#define PLASTIC_FLAPS_DETACHED 1

//ai core defines
#define EMPTY_CORE 0
#define CIRCUIT_CORE 1
#define SCREWED_CORE 2
#define CABLED_CORE 3
#define GLASS_CORE 4
#define AI_READY_CORE 5

//let's just pretend fulltile windows being children of border windows is fine
#define FULLTILE_WINDOW_DIR NORTHEAST

//Material defines, for determining how much of a given material an item contains
#define MAT_METAL "metal"
#define MAT_GLASS "glass"
#define MAT_SILVER "silver"
#define MAT_GOLD "gold"
#define MAT_DIAMOND "diamond"
#define MAT_URANIUM "uranium"
#define MAT_PLASMA "plasma"
#define MAT_BLUESPACE "bluespace"
#define MAT_BANANIUM "bananium"
#define MAT_TRANQUILLITE "tranquillite"
#define MAT_TITANIUM "titanium"
#define MAT_BIOMASS "biomass"
#define MAT_PLASTIC "plastic"
//The amount of materials you get from a sheet of mineral like iron/diamond/glass etc
#define MINERAL_MATERIAL_AMOUNT 2000
//The maximum size of a stack object.
#define MAX_STACK_SIZE 50
//maximum amount of cable in a coil
#define MAXCOIL 30
//Determines how much material is contained in one sheet
#define SHEET_VOLUME 1000 //cm3

// Mounted Frames BITMASK
#define MOUNTED_FRAME_SIMFLOOR (1<<0)
#define MOUNTED_FRAME_NOSPACE (1<<1)

//Defines for amount of material retrieved from sheets & other items
/// The amount of materials you get from a sheet of mineral like iron/diamond/glass etc. 100 Units.
#define SHEET_MATERIAL_AMOUNT MINERAL_MATERIAL_AMOUNT
/// The amount of materials you get from half a sheet. Used in standard object quantities. 50 units.
#define HALF_SHEET_MATERIAL_AMOUNT (SHEET_MATERIAL_AMOUNT / 2)
/// The amount of materials used in the smallest of objects, like pens and screwdrivers. 10 units.
#define SMALL_MATERIAL_AMOUNT (HALF_SHEET_MATERIAL_AMOUNT / 5)
/// The amount of material that goes into a coin, which determines the value of the coin.
#define COIN_MATERIAL_AMOUNT (HALF_SHEET_MATERIAL_AMOUNT * 0.4)
