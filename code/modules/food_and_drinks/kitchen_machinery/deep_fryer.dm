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
	E -= 2		//Standard parts is 0 (1+1-2), Tier 4 parts is 6 (4+4-2)
	cooktime = (200 - (E * 20))		//Effectively each laser improves cooktime by 20 per rating beyond the first (200 base, 80 max upgrade)

/obj/machinery/cooker/deepfryer/gettype()
	var/obj/item/reagent_containers/food/snacks/deepfryholder/type = new(get_turf(src))
	return type

/obj/machinery/cooker/deepfryer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/holder/mouse))
		if(on)
			to_chat(user, span_warning("There are no place for [I]!"))
			return
		var/obj/item/holder/mouse/mouse_holder = I
		user.drop_item_ground(mouse_holder)
		mouse_holder.forceMove(src)
		for(var/mob/living/simple_animal/mouse/mouse in mouse_holder)
			fry_mouse(mouse)
		qdel(mouse_holder)
	. = ..()

/obj/machinery/cooker/deepfryer/MouseDrop_T(mob/living/dropping, mob/living/user, params)
	if(istype(dropping, /mob/living/simple_animal/mouse) && dropping == user)
		if(on)
			to_chat(user, span_warning("There are no place for [dropping]!"))
			return
		dropping.forceMove(get_turf(src))
		fry_mouse(dropping)

/obj/machinery/cooker/deepfryer/AltClick(mob/user)
	if(istype(user, /mob/living/simple_animal/mouse))
		if(on)
			to_chat(user, span_warning("There are no place for [user]!"))
			return
		user.forceMove(get_turf(src))
		fry_mouse(user)

/obj/machinery/cooker/deepfryer/proc/fry_mouse(mob/living/simple_animal/mouse/mouse)
	on = TRUE
	update_icon(UPDATE_ICON_STATE)
	mouse.del_on_death = TRUE
	mouse.death()
	sleep(3 SECONDS)
	on = FALSE
	update_icon(UPDATE_ICON_STATE)
	new /obj/item/reagent_containers/food/snacks/fry_mouse(get_turf(src))

/obj/machinery/cooker/deepfryer/special_attack(obj/item/grab/G, mob/user)
	if(ishuman(G.affecting))
		if(G.state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return 0
		var/mob/living/carbon/human/C = G.affecting
		var/obj/item/organ/external/head/head = C.get_organ(BODY_ZONE_HEAD)
		if(!head)
			to_chat(user, "<span class='warning'>This person doesn't have a head!</span>")
			return 0
		add_fingerprint(user)
		C.visible_message("<span class='danger'>[user] dunks [C]'s face into [src]!</span>", \
						"<span class='userdanger'>[user] dunks your face into [src]!</span>")
		C.emote("scream")
		user.changeNext_move(CLICK_CD_MELEE)
		C.apply_damage(25, BURN, BODY_ZONE_HEAD) //25 fire damage and disfigurement because your face was just deep fried!
		head.disfigure()
		add_attack_logs(user, G.affecting, "Deep-fried with [src]")
		qdel(G) //Removes the grip so the person MIGHT have a small chance to run the fuck away and to prevent rapid dunks.
		return 0
	return 0


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
