/* In this file:
 *
 * Plasma floor
 * Gold floor
 * Silver floor
 * Bananium floor
 * Diamond floor
 * Uranium floor
 * Shuttle floor (Titanium)
 */

/turf/simulated/floor/mineral
	name = "mineral floor"
	icon_state = ""
	var/list/icons = list()

/turf/simulated/floor/mineral/broken_states()
	return list("[initial(icon_state)]_dam")


/turf/simulated/floor/mineral/update_icon_state()
	if(!broken && !burnt && !(icon_state in icons))
		icon_state = initial(icon_state)


//PLASMA
/turf/simulated/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	floor_tile = /obj/item/stack/tile/mineral/plasma
	icons = list("plasma","plasma_dam")

/turf/simulated/floor/mineral/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		PlasmaBurn()


/turf/simulated/floor/mineral/plasma/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	var/hot_temp = is_hot(I)
	if(hot_temp > 300)//If the temperature of the object is over 300, then ignite
		add_attack_logs(user, src, "Ignited using [I]", ATKLOG_FEW)
		investigate_log("was <span class='warning'>ignited</span> by [key_name_log(user)]",INVESTIGATE_ATMOS)
		ignite(hot_temp)
		return .|ATTACK_CHAIN_BLOCKED_ALL


/turf/simulated/floor/mineral/plasma/welder_act(mob/user, obj/item/I)
	if(I.use_tool(src, user, volume = I.tool_volume))
		user.visible_message(span_danger("[user] sets [src] on fire!"),\
						span_danger("[src] disintegrates into a cloud of plasma!"),\
						span_warning("You hear a 'whoompf' and a roar."))
		ignite(2500) //Big enough to ignite
		add_attack_logs(user, src, "Ignited using [I]", ATKLOG_FEW)
		investigate_log("was <span class='warning'>ignited</span> by [key_name_log(user)]",INVESTIGATE_ATMOS)

/turf/simulated/floor/mineral/plasma/proc/PlasmaBurn()
	make_plating(FALSE)
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 20)

/turf/simulated/floor/mineral/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn()

//GOLD
/turf/simulated/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	floor_tile = /obj/item/stack/tile/mineral/gold
	icons = list("gold","gold_dam")

/turf/simulated/floor/mineral/gold/fancy
	icon_state = "goldfancy"
	floor_tile = /obj/item/stack/tile/mineral/gold/fancy
	icons = list("goldfancy","goldfancy_dam")

//SILVER
/turf/simulated/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	floor_tile = /obj/item/stack/tile/mineral/silver
	icons = list("silver","silver_dam")

/turf/simulated/floor/mineral/silver/fancy
	icon_state = "silverfancy"
	floor_tile = /obj/item/stack/tile/mineral/silver/fancy
	icons = list("silverfancy","silverfancy_dam")

//TITANIUM (shuttle)

/turf/simulated/floor/mineral/titanium
	name = "shuttle floor"
	icon_state = "titanium"
	floor_tile = /obj/item/stack/tile/mineral/titanium

/turf/simulated/floor/mineral/titanium/broken_states()
	return list("titanium_dam1","titanium_dam2","titanium_dam3","titanium_dam4","titanium_dam5")

/turf/simulated/floor/mineral/titanium/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/mineral/titanium/blue
	icon_state = "titanium_blue"

/turf/simulated/floor/mineral/titanium/blue/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/mineral/titanium/yellow
	icon_state = "titanium_yellow"

/turf/simulated/floor/mineral/titanium/yellow/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/mineral/titanium/purple
	icon_state = "titanium_purple"
	floor_tile = /obj/item/stack/tile/mineral/titanium/purple

/turf/simulated/floor/mineral/titanium/purple/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

//PLASTITANIUM (syndieshuttle)
/turf/simulated/floor/mineral/plastitanium
	name = "shuttle floor"
	icon_state = "plastitanium"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium

/turf/simulated/floor/mineral/plastitanium/broken_states()
	return list("plastitanium_dam1","plastitanium_dam2","plastitanium_dam3","plastitanium_dam4","plastitanium_dam5")

/turf/simulated/floor/mineral/plastitanium/red
	icon_state = "plastitanium_red"

/turf/simulated/floor/mineral/plastitanium/red/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/mineral/plastitanium/red/brig
	name = "brig floor"

//BANANIUM
/turf/simulated/floor/mineral/bananium
	name = "bananium floor"
	icon_state = "bananium"
	floor_tile = /obj/item/stack/tile/mineral/bananium
	icons = list("bananium","bananium_dam")
	var/spam_flag = 0

/turf/simulated/floor/mineral/bananium/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived))
		squeek()


/turf/simulated/floor/mineral/bananium/attackby(obj/item/I, mob/user, params)
	. = ..()
	honk()


/turf/simulated/floor/mineral/bananium/attack_hand(mob/user)
	.=..()
	if(!.)
		honk()

/turf/simulated/floor/mineral/bananium/proc/honk()
	if(spam_flag < world.time)
		playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
		spam_flag = world.time + 20

/turf/simulated/floor/mineral/bananium/proc/squeek()
	if(spam_flag < world.time)
		playsound(src, "clownstep", 50, 1)
		spam_flag = world.time + 10

/turf/simulated/floor/mineral/bananium/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB


/turf/simulated/floor/mineral/bananium/lubed/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_LUBE, INFINITY, 0, INFINITY, TRUE)

/turf/simulated/floor/mineral/bananium/lubed/pry_tile(obj/item/C, mob/user, silent = FALSE) //I want to get off Mr Honk's Wild Ride
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		to_chat(H, span_warning("You lose your footing trying to pry off the tile!"))
		H.slip(10 SECONDS, src, TURF_WET_LUBE)
	return

//TRANQUILLITE
/turf/simulated/floor/mineral/tranquillite
	name = "silent floor"
	icon_state = "tranquillite"
	floor_tile = /obj/item/stack/tile/mineral/tranquillite
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null

//DIAMOND
/turf/simulated/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	floor_tile = /obj/item/stack/tile/mineral/diamond
	icons = list("diamond","diamond_dam")

//URANIUM
/turf/simulated/floor/mineral/uranium
	name = "uranium floor"
	icon_state = "uranium"
	floor_tile = /obj/item/stack/tile/mineral/uranium
	icons = list("uranium","uranium_dam")
	var/last_event = 0
	var/active = null

/turf/simulated/floor/mineral/uranium/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/radioactivity, \
				rad_per_interaction = 1, \
				rad_interaction_radius = 3, \
				rad_interaction_cooldown = 1.5 SECONDS \
	)

// ALIEN ALLOY
/turf/simulated/floor/mineral/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	floor_tile = /obj/item/stack/tile/mineral/abductor
	icons = list("alienpod1", "alienpod2", "alienpod3", "alienpod4", "alienpod5", "alienpod6", "alienpod7", "alienpod8", "alienpod9")

/turf/simulated/floor/mineral/abductor/Initialize(mapload)
	. = ..()
	icon_state = "alienpod[rand(1,9)]"

/turf/simulated/floor/mineral/abductor/break_tile()
	return //unbreakable

/turf/simulated/floor/mineral/abductor/burn_tile()
	return //unburnable

/turf/simulated/floor/mineral/abductor/make_plating(make_floor_tile, mob/user)
	if(make_floor_tile && floor_tile && !broken && !burnt)
		var/obj/item/stack/stack_dropped = new floor_tile(src)
		if(istype(user))
			var/obj/item/stack/stack_offhand = user.get_inactive_hand()
			if(istype(stack_dropped) && istype(stack_offhand) && stack_offhand.can_merge(stack_dropped, inhand = TRUE))
				user.put_in_hands(stack_dropped, ignore_anim = FALSE)
	return ChangeTurf(/turf/simulated/floor/plating/abductor2)

/turf/simulated/floor/plating/abductor2
	name = "alien plating"
	icon_state = "alienplating"

/turf/simulated/floor/plating/abductor2/break_tile()
	return //unbreakable

/turf/simulated/floor/plating/abductor2/burn_tile()
	return //unburnable
