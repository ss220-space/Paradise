/**
 * Maximum pressure a canister can withstand is 9.2e13 kPa at a minimum of 2.7K which would contain a horrifying 4,098,150,709.4 moles.
 * We don't want players making that much credits so we limit the total amount earned to MAX_GAS_CREDITS
*/
/datum/export/gas_canister
	cost = CARGO_CRATE_VALUE * 0.05 //Base cost of canister. You get more for nice gases inside.
	unit_name = "Gas Canister"
	export_types = list(/obj/machinery/portable_atmospherics/canister)

/datum/export/gas_canister/get_base_cost(obj/machinery/portable_atmospherics/canister/canister)
	var/datum/gas_mixture/canister_mix = canister.return_obj_air()
	if(!canister_mix.total_moles())
		return 0

	var/static/list/gases_to_check = list(
		TLV_BZ = 1,
		TLV_NITRIUM = 1,
		TLV_HYPERNOBLIUM = 1,
		TLV_MIASMA = 1,
		TLV_TRITIUM = 1,
		TLV_PLUOXIUM = 1,
		TLV_FREON = 1,
		TLV_H2 = 1,
		TLV_HELIUM = 1,
		TLV_PROTO_NITRATE = 1,
		TLV_ZAUKER = 1,
		TLV_HEALIUM = 1,
		TLV_ANTINOBLIUM = 1,
		TLV_HALON = 1,
	)

	var/worth = cost
	for(var/gas_id, amount in canister_mix.get_interesting())
		if(!(gas_id in gases_to_check))
			continue
		worth += get_gas_value(gas_id, amount)
		if(worth > MAX_GAS_CREDITS)
			worth = MAX_GAS_CREDITS
			break

	return worth

/datum/export/gas_canister/proc/get_gas_value(gas_id, moles)

	return ROUND_UP(GLOB.gas_meta[gas_id][META_BASE_VALUE] * moles)

