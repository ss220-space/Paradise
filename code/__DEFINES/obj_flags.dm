// If you want some flags for object USE THIS INSTEAD OF flags OR flags_2

// Flags for the obj_flags var on /obj

/// Does this object prevent same-direction things from being built on it?
#define BLOCKS_CONSTRUCTION_DIR (1<<0)
/// Should this object block z falling from loc?
#define BLOCK_Z_OUT_DOWN (1<<1)
/// Should this object block z uprise from loc?
#define BLOCK_Z_OUT_UP (1<<2)
/// Should this object block z falling from above?
#define BLOCK_Z_IN_DOWN (1<<3)
/// Should this object block z uprise from below?
#define BLOCK_Z_IN_UP (1<<4)
/// Objects will not leave any components after being destroyed
#define NODECONSTRUCT (1<<5)
/// Objects will ignore item attacks
#define IGNORE_HITS (1<<6)


// Flags for the item_flags var on /obj/item

/// Items is currently being removed from the inventory.
#define BEING_REMOVED (1<<0)
/// Is this item equipped into an inventory slot or hand of a mob? used for tooltips
#define IN_INVENTORY (1<<1)
/// Is this item inside a storage object?
#define IN_STORAGE (1<<2)
/// For all things that are technically items but used for various different stuff <= wow thanks for the fucking insight sherlock
#define ABSTRACT (1<<3)
/// This flags makes it so an item cannot be picked up in hands
#define NOPICKUP (1<<4)
/// When dropped, it calls qdel on itself
#define DROPDEL (1<<5)
/// Prevents from sharpening item with whetstone
#define NOSHARPENING (1<<6)
/// If an item has this flag, it will slow you, but only if in hands.
#define SLOWS_WHILE_IN_HAND (1<<7)
/// When an item has this it will skip all the procedures in default /obj/item/proc/attack() and /obj/item/proc/attack_obj()
#define NOBLUDGEON (1<<8)
/// When dropped, it wont have a randomized pixel_x/pixel_y
#define NO_PIXEL_RANDOM_DROP (1<<9)
/// Whether any slowdowns applied by the item are ignored
#define IGNORE_SLOWDOWN (1<<10)
/// Applies HEARING_PROTECTION_MINOR if present, helmet or ear items ONLY!
#define BANGPROTECT_MINOR (1<<11)
/// Applies HEARING_PROTECTION_TOTAL if present, helmet or ear items ONLY!
#define BANGPROTECT_TOTAL (1<<12)
/// Stops you from putting things like an RCD or other items into an ORM or protolathe for materials.
#define NO_MAT_REDEMPTION (1<<13)
/// An item worn in the ear slots will heal your ears each Life() tick, even if normally your ears would be too damaged to heal.
#define HEALS_EARS (1<<14)
/// An item will allow its usage even when UI is blocked but user is conscious, not incapacitated and has no hands blocked trait.
#define DENY_UI_BLOCKED (1<<15)
/// When an item has this it produces no "X has been hit by Y with Z" message in the default /mob/living/proc/send_item_attack_message()
#define SKIP_ATTACK_MESSAGE (1<<16)


// Flags for the clothing_flags var on /obj/item/clothing

/// Prevents usage of syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag
#define THICKMATERIAL (1<<0)
/// Used for external suit or helmet to stop pressure damage
#define STOPSPRESSUREDMAGE (1<<1)
/// Used for masks and helmets to allow internals usage
#define AIRTIGHT (1<<2)
/// Blocks the effect that chemical clouds would have on a mob, mask and helmets ONLY!
#define BLOCK_GAS_SMOKE_EFFECT (1<<3)
/// Prevents capsaicin effects, mask and helmets ONLY!
#define BLOCK_CAPSAICIN (1<<4)
/// Whether this item ignores any manipulations with slowdown variable, like slime speed potions
#define FIXED_SLOWDOWN (1<<5)
/// Checks for finger coverage, prevents damage from nettles
#define FINGERS_COVERED (1<<6)

