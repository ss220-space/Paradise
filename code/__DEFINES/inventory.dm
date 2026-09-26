//ALL DEFINES RELATED TO INVENTORY OBJECTS, MANAGEMENT, ETC, GO HERE*/

// ITEM INVENTORY WEIGHT, FOR w_class
/// Usually items smaller then a human hand, ex: Playing Cards, Lighter, Scalpel, Coins/Money
#define WEIGHT_CLASS_TINY 1
/// Pockets can hold small and tiny items, ex: Flashlight, Grenades, GPS Device
#define WEIGHT_CLASS_SMALL 2
/// Standard backpacks can carry tiny, small & normal items, ex: Fire extinguisher, Stunbaton, Gas Mask, Metal Sheets
#define WEIGHT_CLASS_NORMAL 3
/// Items that can be weilded or equipped but not stored in an inventory, ex: Defibrillator, Backpack, Space Suits
#define WEIGHT_CLASS_BULKY 4
/// Usually represents objects that require two hands to operate, ex: Shotgun, Two Handed Melee Weapons
#define WEIGHT_CLASS_HUGE 5
/// Essentially means it cannot be picked up or placed in an inventory, ex: Mech Parts, Safe
#define WEIGHT_CLASS_GIGANTIC 6

// Inventory depth: limits how many nested storage items you can access directly.
// 1: stuff in mob, 2: stuff in backpack, 3: stuff in box in backpack, etc
#define REACH_DEPTH_SELF 1
/// A storage depth ontop of SELF. REACH_DEPTH_STORAGE(1) would allow an item inside of a backpack you are carrying.
#define REACH_DEPTH_STORAGE(level) (level + REACH_DEPTH_SELF)

// Flags for specifically what kind of items to get in get_equipped_items
#define INCLUDE_POCKETS (1<<0)
#define INCLUDE_ACCESSORIES (1<<1)
#define INCLUDE_HELD (1<<2)
