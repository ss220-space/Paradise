/// Signal called when item is attacked by coffeemaker
#define COMSIG_ITEM_ATTACKED_BY_COFFEEMAKER "item_attackedby_coffeemaker"
	/// Return flag indicating coffeemaker accepted the item
	#define COMSIG_ITEM_COFFEEMAKER_ACCEPTED (1<<0)
	/// Return flag indicating item is valid but was rejected (e.g., empty container, full storage)
	#define COMSIG_ITEM_COFFEEMAKER_REJECTED (1<<1)
