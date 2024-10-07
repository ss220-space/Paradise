/obj/machinery/cooker/deepfryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon = 'icons/obj/machines/cooking_machines.dmi'
	icon_state = "fryer_off"
	thiscooktype = "deep fried"
	burns = 1
	firechance = 100
	cooktime = 200
	foodcolor = "#FFAD33"
	officon = "fryer_off"
	onicon = "fryer_on"
	openicon = "fryer_open"
	has_specials = 1
	upgradeable = 1

/obj/machinery/cooker/deepfryer/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/deepfryer(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/cooker/deepfryer/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/deepfryer(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/cooker/deepfryer/RefreshParts()
	var/E = 0
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		E += L.rating
	E -= 2		//Standard parts is 0 (1+1-2), Tier 5 parts is 8 (5+5-2)
	cooktime = (200 - (E * 20))		//Effectively each laser improves cooktime by 20 per rating beyond the first (200 base, 40 max upgrade)

/obj/machinery/cooker/deepfryer/gettype()
	var/obj/item/reagent_containers/food/snacks/deepfryholder/type = new(get_turf(src))
	return type


/obj/machinery/cooker/deepfryer/special_grab_attack(atom/movable/grabbed_thing, mob/living/grabber)
	if(!ishuman(grabbed_thing) || !Adjacent(grabbed_thing))
		return
	var/mob/living/carbon/human/victim = grabbed_thing
	var/obj/item/organ/external/head/head = victim.get_organ(BODY_ZONE_HEAD)
	if(!head)
		to_chat(grabber, span_warning("This person doesn't have a head!"))
		return
	add_fingerprint(grabber)
	victim.visible_message(
		span_danger("[grabber] dunks [victim]'s face into [src]!"),
		span_userdanger("[grabber] dunks your face into [src]!"),
	)
	if(victim.has_pain())
		victim.emote("scream")
	victim.apply_damage(25, BURN, BODY_ZONE_HEAD) //25 fire damage and disfigurement because your face was just deep fried!
	head.disfigure()
	add_attack_logs(grabber, victim, "Deep-fried with [src]")
	//Removes the grip so the person MIGHT have a small chance to run the fuck away and to prevent rapid dunks.
	grabber.stop_pulling()


/obj/machinery/cooker/deepfryer/checkSpecials(obj/item/I)
	if(!I)
		return 0
	for(var/Type in subtypesof(/datum/deepfryer_special))
		var/datum/deepfryer_special/P = new Type()
		if(!P.validate(I))
			continue
		return P
	return 0

/obj/machinery/cooker/deepfryer/cookSpecial(special)
	if(!special)
		return 0
	var/datum/deepfryer_special/recipe = special
	if(!recipe.output)
		return 0
	new recipe.output(get_turf(src))

/obj/machinery/cooker/deepfryer/on_deconstruction()
	dropContents()

//////////////////////////////////
//		Deepfryer Special		//
//		Interaction Datums		//
//////////////////////////////////

/datum/deepfryer_special
	var/input		//Thing that goes in
	var/output		//Thing that comes out

/datum/deepfryer_special/proc/validate(obj/item/I)
	return istype(I, input)

/datum/deepfryer_special/shrimp
	input = /obj/item/reagent_containers/food/snacks/shrimp
	output = /obj/item/reagent_containers/food/snacks/fried_shrimp

/datum/deepfryer_special/banana
	input = /obj/item/reagent_containers/food/snacks/grown/banana
	output = /obj/item/reagent_containers/food/snacks/friedbanana

/datum/deepfryer_special/fries
	input = /obj/item/reagent_containers/food/snacks/rawsticks
	output = /obj/item/reagent_containers/food/snacks/fries

/datum/deepfryer_special/corn_chips
	input = /obj/item/reagent_containers/food/snacks/grown/corn
	output = /obj/item/reagent_containers/food/snacks/cornchips

/datum/deepfryer_special/fried_tofu
	input = /obj/item/reagent_containers/food/snacks/tofu
	output = /obj/item/reagent_containers/food/snacks/fried_tofu

/datum/deepfryer_special/chimichanga
	input = /obj/item/reagent_containers/food/snacks/burrito
	output = /obj/item/reagent_containers/food/snacks/chimichanga

/datum/deepfryer_special/potato_chips
	input = /obj/item/reagent_containers/food/snacks/grown/potato/wedges
	output = /obj/item/reagent_containers/food/snacks/chips

/datum/deepfryer_special/carrotfries
	input = /obj/item/reagent_containers/food/snacks/grown/carrot/wedges
	output = /obj/item/reagent_containers/food/snacks/carrotfries

/datum/deepfryer_special/onionrings
	input = /obj/item/reagent_containers/food/snacks/onion_slice
	output = /obj/item/reagent_containers/food/snacks/onionrings

/datum/deepfryer_special/fried_vox
	input = /obj/item/organ/external
	output = /obj/item/reagent_containers/food/snacks/fried_vox

/datum/deepfryer_special/fried_vox/validate(var/obj/item/I)
	if(!..())
		return FALSE
	var/obj/item/organ/external/E = I
	return istype(E.dna.species, /datum/species/vox)
