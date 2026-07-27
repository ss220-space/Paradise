// Gems that can be mined or obtained on Lavaland
// Only for Syndicate for now, NT has quests
/datum/export/gem
	cost = CARGO_CRATE_VALUE * 1
	k_elasticity = 0
	unit_name = "rare gem"
	export_types = list(/obj/item/gem)
	sales_market = EXPORT_NONE

/datum/export/gem/get_base_cost(obj/item/gem/stone)
	return cost * stone.sell_multiplier
