//ALL DEFINES RELATED TO INVENTORY OBJECTS, MANAGEMENT, ETC, GO HERE*/

// ITEM INVENTORY WEIGHT, FOR w_class
/// Usually items smaller then a human hand, ex: Playing Cards, Lighter, Scalpel, Coins/Money
#define WEIGHT_CLASS_TINY     1
/// Pockets can hold small and tiny items, ex: Flashlight, Multitool, Grenades, GPS Device
#define WEIGHT_CLASS_SMALL    2
/// Standard backpacks can carry tiny, small & normal items, ex: Fire extinguisher, Stunbaton, Gas Mask, Metal Sheets
#define WEIGHT_CLASS_NORMAL   3
/// Items that can be weilded or equipped but not stored in an inventory, ex: Defibrillator, Backpack, Space Suits
#define WEIGHT_CLASS_BULKY    4
/// Usually represents objects that require two hands to operate, ex: Shotgun, Two Handed Melee Weapons
#define WEIGHT_CLASS_HUGE     5
/// Essentially means it cannot be picked up or placed in an inventory, ex: Mech Parts, Safe
#define WEIGHT_CLASS_GIGANTIC 6

// Flags for specifically what kind of items to get in get_equipped_items
#define INCLUDE_POCKETS (1<<0)
#define INCLUDE_ACCESSORIES (1<<1)
#define INCLUDE_HELD (1<<2)

/// List of all "tools" that can work from toolboxes
GLOBAL_LIST_INIT(tool_items, list(
	/obj/item/assembly/signaler,
	/obj/item/crowbar,
	/obj/item/extinguisher/mini,
	/obj/item/flashlight,
	/obj/item/holosign_creator,
	/obj/item/lightreplacer,
	/obj/item/multitool,
	/obj/item/pipe_painter,
	/obj/item/rcd,
	/obj/item/rpd,
	/obj/item/screwdriver,
	/obj/item/stack/cable_coil,
	/obj/item/t_scanner,
	/obj/item/weldingtool,
	/obj/item/wirecutters,
	/obj/item/wrench,
))
