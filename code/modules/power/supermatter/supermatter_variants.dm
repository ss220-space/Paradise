/// Normal SM designated as main engine.
/obj/machinery/atmospherics/supermatter_crystal/engine
	is_main_engine = TRUE

/// Shard SM.
/obj/machinery/atmospherics/supermatter_crystal/shard
	name = "supermatter shard"
	desc = "Странно полупрозрачный и переливающийся кристалл, который выглядит так, будто когда-то был частью более крупной структуры."
	base_icon_state = "darkmatter_shard"
	icon_state = "darkmatter_shard"
	anchored = FALSE
	gasefficency = 0.125
	explosion_power = 12
	layer = ABOVE_MOB_LAYER
	moveable = TRUE

/obj/machinery/atmospherics/supermatter_crystal/shard/get_ru_names()
	return list(
		NOMINATIVE = "осколок суперматерии",
		GENITIVE = "осколка суперматерии",
		DATIVE = "осколку суперматерии",
		ACCUSATIVE = "осколок суперматерии",
		INSTRUMENTAL = "осколком суперматерии",
		PREPOSITIONAL = "осколке суперматерии"
	)

/// Shard SM designated as the main engine.
/obj/machinery/atmospherics/supermatter_crystal/shard/engine
	name = "anchored supermatter shard"
	crystal_can_run_events = FALSE // Do not make the crystal begin to delaminate whilst it's still docked at CC.
	anchored = TRUE
	moveable = FALSE

/obj/machinery/atmospherics/supermatter_crystal/shard/engine/get_ru_names()
	return list(
		NOMINATIVE = "закрепленный осколок суперматерии",
		GENITIVE = "закрепленного осколка суперматерии",
		DATIVE = "закрепленному осколку суперматерии",
		ACCUSATIVE = "закрепленный осколок суперматерии",
		INSTRUMENTAL = "закрепленным осколком суперматерии",
		PREPOSITIONAL = "закрепленном осколке суперматерии"
	)

/// When you wanna make a supermatter shard for the dramatic effect, but don't want it exploding suddenly
/obj/machinery/atmospherics/supermatter_crystal/shard/hugbox
	name = "anchored supermatter shard"
	takes_damage = FALSE
	produces_gas = FALSE
	power_changes = FALSE
	processes = FALSE //SHUT IT DOWN
	moveable = FALSE
	anchored = TRUE

/obj/machinery/atmospherics/supermatter_crystal/shard/hugbox/get_ru_names()
	return list(
		NOMINATIVE = "закрепленный осколок суперматерии",
		GENITIVE = "закрепленного осколка суперматерии",
		DATIVE = "закрепленному осколку суперматерии",
		ACCUSATIVE = "закрепленный осколок суперматерии",
		INSTRUMENTAL = "закрепленным осколком суперматерии",
		PREPOSITIONAL = "закрепленном осколке суперматерии"
	)

/// Hugbox shard with crystal visuals, used in the Supermatter/Hyperfractal shuttle
/obj/machinery/atmospherics/supermatter_crystal/shard/hugbox/fakecrystal
	name = "supermatter crystal"
	base_icon_state = "darkmatter"
	icon_state = "darkmatter"

/obj/machinery/atmospherics/supermatter_crystal/shard/hugbox/fakecrystal/get_ru_names()
	return list(
		NOMINATIVE = "кристалл суперматерии",
		GENITIVE = "кристалла суперматерии",
		DATIVE = "кристаллу суперматерии",
		ACCUSATIVE = "кристалл суперматерии",
		INSTRUMENTAL = "кристаллом суперматерии",
		PREPOSITIONAL = "кристалле суперматерии"
	)
