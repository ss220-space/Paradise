// Gun defines
#define ATTACHMENT_SLOT_MUZZLE "muzzle"
#define ATTACHMENT_SLOT_RAIL "rail"
#define ATTACHMENT_SLOT_STOCK "stock"
#define ATTACHMENT_SLOT_UNDER "under"
#define ATTACHMENT_SLOT_MAGAZINE "magazine"

/proc/gun_module_slot_ru_name(slot)
	switch(slot)
		if(ATTACHMENT_SLOT_MUZZLE)
			return "ствол"
		if(ATTACHMENT_SLOT_RAIL)
			return "планка"
		if(ATTACHMENT_SLOT_STOCK)
			return "приклад"
		if(ATTACHMENT_SLOT_UNDER)
			return "нижний обвес"
		if(ATTACHMENT_SLOT_MAGAZINE)
			return "магазин"
		else
			return "неизвестный слот"
