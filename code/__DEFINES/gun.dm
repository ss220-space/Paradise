// Gun defines
#define ATTACHMENT_SLOT_MUZZLE "muzzle"
#define ATTACHMENT_SLOT_RAIL "rail"
#define ATTACHMENT_SLOT_UNDER "under"

/proc/gun_module_slot_ru_name(slot)
	switch(slot)
		if(ATTACHMENT_SLOT_MUZZLE)
			return "ствол"
		if(ATTACHMENT_SLOT_RAIL)
			return "планка"
		if(ATTACHMENT_SLOT_UNDER)
			return "нижний обвес"
		else
			return "неизвестный слот"
