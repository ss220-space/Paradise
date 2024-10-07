/obj/item/seeds/tower
	name = "pack of tower-cap mycelium"
	desc = "This mycelium grows into tower-cap mushrooms."
	icon_state = "mycelium-tower"
	species = "towercap"
	plantname = "Tower Caps"
	product = /obj/item/grown/log
	lifespan = 80
	endurance = 50
	maturation = 15
	production = 1
	yield = 5
	potency = 50
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	icon_dead = "towercap-dead"
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	mutatelist = list(/obj/item/seeds/tower/steel)

/obj/item/seeds/tower/steel
	name = "pack of steel-cap mycelium"
	desc = "This mycelium grows into steel logs."
	icon_state = "mycelium-steelcap"
	species = "steelcap"
	plantname = "Steel Caps"
	reagents_add = list("iron" = 0.05)
	product = /obj/item/grown/log/steel
	mutatelist = list()
	rarity = 20




/obj/item/grown/log
	seed = /obj/item/seeds/tower
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon_state = "logs"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 3
	origin_tech = "materials=1"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	var/plank_type = /obj/item/stack/sheet/wood
	var/plank_name = "wooden planks"
	var/static/list/accepted = typecacheof(list(
		/obj/item/reagent_containers/food/snacks/grown/tobacco,
		/obj/item/reagent_containers/food/snacks/grown/tea,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus,
		/obj/item/reagent_containers/food/snacks/grown/wheat,
	))


/obj/item/grown/log/attackby(obj/item/I, mob/user, params)
	if(is_sharp(I))
		if(!isturf(loc))
			add_fingerprint(user)
			to_chat(user, span_warning("You cannot chop [src] [ismob(loc) ? "in inventory" : "in [loc]"]."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have chopped [src] into planks."))
		var/seed_modifier = 0
		if(seed)
			seed_modifier = round(seed.potency / 25)
		var/obj/item/stack/planks = new plank_type(loc, 1 + seed_modifier)
		transfer_fingerprints_to(planks)
		planks.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(CheckAccepted(I))
		var/obj/item/reagent_containers/food/snacks/grown/leaf = I
		if(!leaf.dry)
			add_fingerprint(user)
			to_chat(user, span_warning("You should dry [leaf] first."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(leaf, src))
			return ..()
		to_chat(user, span_notice("You wrap [leaf] around [src], turning it into a torch."))
		var/obj/item/flashlight/flare/torch/torch = new(drop_location())
		transfer_fingerprints_to(torch)
		leaf.transfer_fingerprints_to(torch)
		torch.add_fingerprint(user)
		if(loc == user)
			user.temporarily_remove_item_from_inventory(src, force = TRUE)
			user.put_in_hands(torch)
		qdel(leaf)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/grown/log/proc/CheckAccepted(obj/item/I)
	return is_type_in_typecache(I, accepted)

/obj/item/grown/log/tree
	seed = null
	name = "wood log"
	desc = "TIMMMMM-BERRRRRRRRRRR!"

/obj/item/grown/log/steel
	seed = /obj/item/seeds/tower/steel
	name = "steel-cap log"
	desc = "It's made of metal."
	icon_state = "steellogs"
	plank_type = /obj/item/stack/rods
	plank_name = "rods"

/obj/item/grown/log/steel/CheckAccepted(obj/item/I)
	return FALSE

/obj/item/seeds/bamboo
	name = "pack of bamboo seeds"
	desc = "Plant known for their flexible and resistant logs."
	icon_state = "seed-bamboo"
	species = "bamboo"
	plantname = "Bamboo"
	product = /obj/item/grown/log/bamboo
	lifespan = 80
	endurance = 70
	maturation = 15
	production = 2
	yield = 5
	potency = 50
	growthstages = 2
	growing_icon = 'icons/obj/hydroponics/growing.dmi'
	icon_dead = "bamboo-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)

/obj/item/grown/log/bamboo
	seed = /obj/item/seeds/bamboo
	name = "bamboo log"
	desc = "A long and resistant bamboo log."
	icon_state = "bamboo"
	plank_type = /obj/item/stack/sheet/bamboo
	plank_name = "bamboo sticks"

/obj/item/grown/log/bamboo/CheckAccepted(obj/item/I)
	return FALSE

/obj/structure/punji_sticks
	name = "punji sticks"
	desc = "Don't step on this."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "punji"
	resistance_flags = FLAMMABLE
	max_integrity = 30
	density = FALSE
	anchored = TRUE

/obj/structure/punji_sticks/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 20, 30, 100, 6 SECONDS, CALTROP_BYPASS_SHOES)

/////////BONFIRES//////////

/obj/structure/bonfire
	name = "bonfire"
	desc = "For grilling, broiling, charring, smoking, heating, roasting, toasting, simmering, searing, melting, and occasionally burning things."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "bonfire"
	density = FALSE
	anchored = TRUE
	buckle_lying = 0
	pass_flags_self = PASSTABLE|LETPASSTHROW
	var/rod_installed = FALSE
	var/burning = FALSE
	var/lighter // Who lit the fucking thing
	var/fire_stack_strength = 5

/obj/structure/bonfire/dense
	density = TRUE


/obj/structure/bonfire/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/structure/bonfire/update_icon_state()
	icon_state = "bonfire[burning ? "_on_fire" : ""]"


/obj/structure/bonfire/update_overlays()
	. = ..()
	underlays.Cut()
	if(!rod_installed)
		return .
	var/static/mutable_appearance/rod
	if(isnull(rod))
		rod = mutable_appearance('icons/obj/hydroponics/equipment.dmi', "bonfire_rod")
		rod.pixel_z = 16
	underlays += rod


/obj/structure/bonfire/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/rods))
		add_fingerprint(user)
		var/obj/item/stack/rods/rods = I
		if(rod_installed)
			to_chat(user, span_warning("The [name] already has a metal rod installed."))
			return ATTACK_CHAIN_PROCEED
		if(!rods.use(1))
			to_chat(user, span_warning("You need at least one rod to do this."))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] has constructed a central rod inside [src]."),
			span_notice("You have constructed a central rod inside [src]."),
		)
		rod_installed = TRUE
		can_buckle = TRUE
		buckle_requires_restraints = TRUE
		update_icon(UPDATE_OVERLAYS)	// update underlays some day
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(is_hot(I) && StartBurning())
		add_fingerprint(user)
		lighter = user.ckey
		add_misc_logs(user, "lit a bonfire", src)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/structure/bonfire/attack_hand(mob/user)
	if(burning)
		to_chat(user, span_warning("You need to extinguish [src] before removing the logs!"))
		return
	if(!has_buckled_mobs() && do_after(user, 5 SECONDS, src))
		for(var/I in 1 to 5)
			var/obj/item/grown/log/log = new(loc)
			log.set_base_pixel_x(rand(1,4))
			log.set_base_pixel_y(rand(1,4))
			log.add_fingerprint(user)
			transfer_fingerprints_to(log)
		if(rod_installed)
			var/obj/item/stack/rods/rod = new(loc)
			rod.add_fingerprint(user)
			transfer_fingerprints_to(rod)
		qdel(src)
		return
	return ..()


/obj/structure/bonfire/proc/CheckOxygen()
	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(G.oxygen > 13)
		return 1
	return 0

/obj/structure/bonfire/proc/StartBurning()
	. = FALSE
	if(!burning && CheckOxygen())
		. = TRUE
		burning = TRUE
		update_icon(UPDATE_ICON_STATE)
		set_light(6, l_color = "#ED9200", l_on = TRUE)
		Burn()
		START_PROCESSING(SSobj, src)

/obj/structure/bonfire/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	StartBurning()


/obj/structure/bonfire/proc/on_entered(datum/source, mob/living/carbon/human/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!burning)
		return

	Burn()

	if(ishuman(arrived) && arrived.mind)
		add_attack_logs(src, arrived, "Burned by a bonfire (Lit by [lighter ? lighter : "Unknown"])", ATKLOG_ALMOSTALL)


/obj/structure/bonfire/proc/Burn()
	var/turf/current_location = get_turf(src)
	current_location.hotspot_expose(1000,500,1)
	for(var/A in current_location)
		if(A == src)
			continue
		if(isobj(A))
			var/obj/O = A
			O.fire_act(1000, 500)
		else if(isliving(A))
			var/mob/living/L = A
			L.adjust_fire_stacks(fire_stack_strength)
			L.IgniteMob()

/obj/structure/bonfire/process()
	if(!CheckOxygen())
		extinguish()
		return
	Burn()

/obj/structure/bonfire/extinguish()
	if(burning)
		burning = FALSE
		update_icon(UPDATE_ICON_STATE)
		set_light_on(FALSE)
		STOP_PROCESSING(SSobj, src)


/obj/structure/bonfire/extinguish_light(force = FALSE)
	if(force)
		extinguish()


/obj/structure/bonfire/post_buckle_mob(mob/living/target)
	target.pixel_y += 13


/obj/structure/bonfire/post_unbuckle_mob(mob/living/target)
	target.pixel_y -= 13

