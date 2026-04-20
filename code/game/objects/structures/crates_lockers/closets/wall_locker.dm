/obj/structure/closet/walllocker
	desc = "A wall mounted storage locker."
	name = "wall locker"
	icon = 'icons/obj/walllocker.dmi'
	icon_state = "wall-locker"
	density = FALSE
	anchored = TRUE
	ignore_density_closed = TRUE
	no_overlays = TRUE
	icon_closed = "wall-locker"
	icon_opened = "wall-lockeropen"

/obj/structure/closet/walllocker/close()
	. = ..()
	density = FALSE // It's a locker in a wall, you aren't going to be walking into it.

/obj/structure/closet/walllocker/emerglocker
	name = "emergency locker"
	desc = "A wall mounted locker with emergency supplies."
	icon_state = "emerg"
	icon_closed = "emerg"
	icon_opened = "emergopen"

#define EMERGENCY_CONTENTS_SMALL "small"
#define EMERGENCY_CONTENTS_AID "aid"
#define EMERGENCY_CONTENTS_TANK "tank"
#define EMERGENCY_CONTENTS_BOTH "both"

/obj/structure/closet/walllocker/emerglocker/populate_contents()
	switch(pickweight(list(
		EMERGENCY_CONTENTS_SMALL = 55,
		EMERGENCY_CONTENTS_AID   = 25,
		EMERGENCY_CONTENTS_TANK  = 10,
		EMERGENCY_CONTENTS_BOTH  = 10
	)))
		if(EMERGENCY_CONTENTS_SMALL)
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/clothing/mask/breath(src)
		if(EMERGENCY_CONTENTS_AID)
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/storage/toolbox/emergency(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/storage/firstaid/o2(src)
		if(EMERGENCY_CONTENTS_TANK)
			new /obj/item/tank/internals/emergency_oxygen/engi(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/tank/internals/emergency_oxygen/engi(src)
			new /obj/item/clothing/mask/breath(src)
		if(EMERGENCY_CONTENTS_BOTH)
			new /obj/item/storage/toolbox/emergency(src)
			new /obj/item/tank/internals/emergency_oxygen/engi(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/storage/firstaid/o2(src)

#undef EMERGENCY_CONTENTS_SMALL
#undef EMERGENCY_CONTENTS_AID
#undef EMERGENCY_CONTENTS_TANK
#undef EMERGENCY_CONTENTS_BOTH

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/closet/walllocker/emerglocker, 32, 32)
