/obj/structure/foodcart
	name = "food cart"
	desc = "A cart for transporting food and drinks."
	icon = 'icons/obj/foodcart.dmi'
	icon_state = "cart"
	anchored = FALSE
	density = TRUE
	pull_push_slowdown = 1
	//Food slots
	var/list/food_slots[6]
	//var/obj/item/reagent_containers/food/snacks/food1 = null
	//var/obj/item/reagent_containers/food/snacks/food2 = null
	//var/obj/item/reagent_containers/food/snacks/food3 = null
	//var/obj/item/reagent_containers/food/snacks/food4 = null
	//var/obj/item/reagent_containers/food/snacks/food5 = null
	//var/obj/item/reagent_containers/food/snacks/food6 = null
	//Drink slots
	var/list/drink_slots[6]
	//var/obj/item/reagent_containers/food/drinks/drink1 = null
	//var/obj/item/reagent_containers/food/drinks/drink2 = null
	//var/obj/item/reagent_containers/food/drinks/drink3 = null
	//var/obj/item/reagent_containers/food/drinks/drink4 = null
	//var/obj/item/reagent_containers/food/drinks/drink5 = null
	//var/obj/item/reagent_containers/food/drinks/drink6 = null


/obj/structure/foodcart/proc/put_in_cart(obj/item/I, mob/user)
	. = user.drop_transfer_item_to_loc(I, src)
	if(.)
		to_chat(user, span_notice("You put [I] into [src]."))


/obj/structure/foodcart/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || I.is_robot_module())
		return ..()

	if(istype(I, /obj/item/reagent_containers/food/snacks))
		add_fingerprint(user)
		for(var/slot = 1 to length(food_slots))
			if(food_slots[slot])
				continue
			if(put_in_cart(I, user))
				food_slots[slot] = I
				updateUsrDialog()
				return ATTACK_CHAIN_BLOCKED_ALL
			return ..()
		to_chat(user, span_warning("The [name]'s snacks compartment is full!"))
		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/reagent_containers/food/drinks))
		add_fingerprint(user)
		for(var/slot = 1 to length(drink_slots))
			if(drink_slots[slot])
				continue
			if(put_in_cart(I, user))
				drink_slots[slot] = I
				updateUsrDialog()
				return ATTACK_CHAIN_BLOCKED_ALL
			return ..()
		to_chat(user, span_warning("The [name]'s drinks compartment is full!"))
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/structure/foodcart/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(isinspace())
		to_chat(user, span_warning("That was a dumb idea."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	set_anchored(!anchored)
	if(anchored)
		user.visible_message(
			span_notice("[user] tightens [name]'s casters."),
			span_notice("You have tightened [name]'s casters."),
			span_italics("You hear ratchet."),
		)
	else
		user.visible_message(
			span_notice("[user] loosens [name]'s casters."),
			span_notice("You have loosened [name]'s casters."),
			span_italics("You hear ratchet."),
		)



/obj/structure/foodcart/attack_hand(mob/user)
	add_fingerprint(user)
	user.set_machine(src)
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	if(food_slots[1])
		dat += "<a href='byond://?src=[UID()];f1=1'>[food_slots[1]]</a><br>"
	if(food_slots[2])
		dat += "<a href='byond://?src=[UID()];f2=1'>[food_slots[2]]</a><br>"
	if(food_slots[3])
		dat += "<a href='byond://?src=[UID()];f3=1'>[food_slots[3]]</a><br>"
	if(food_slots[4])
		dat += "<a href='byond://?src=[UID()];f4=1'>[food_slots[4]]</a><br>"
	if(food_slots[5])
		dat += "<a href='byond://?src=[UID()];f5=1'>[food_slots[5]]</a><br>"
	if(food_slots[6])
		dat += "<a href='byond://?src=[UID()];f6=1'>[food_slots[6]]</a><br>"
	if(drink_slots[1])
		dat += "<a href='byond://?src=[UID()];d1=1'>[drink_slots[1]]</a><br>"
	if(drink_slots[2])
		dat += "<a href='byond://?src=[UID()];d2=1'>[drink_slots[2]]</a><br>"
	if(drink_slots[3])
		dat += "<a href='byond://?src=[UID()];d3=1'>[drink_slots[3]]</a><br>"
	if(drink_slots[4])
		dat += "<a href='byond://?src=[UID()];d4=1'>[drink_slots[4]]</a><br>"
	if(drink_slots[5])
		dat += "<a href='byond://?src=[UID()];d5=1'>[drink_slots[5]]</a><br>"
	if(drink_slots[6])
		dat += "<a href='byond://?src=[UID()];d6=1'>[drink_slots[6]]</a><br>"
	var/datum/browser/popup = new(user, "foodcart", name, 240, 160)
	popup.set_content(dat)
	popup.open()

/obj/structure/foodcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	if(href_list["f1"])
		if(food_slots[1])
			var/obj/item/food = food_slots[1]
			food.forceMove_turf()
			user.put_in_hands(food, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [food] from [src].</span>")
			food_slots[1] = null
	if(href_list["f2"])
		if(food_slots[2])
			var/obj/item/food = food_slots[2]
			food.forceMove_turf()
			user.put_in_hands(food, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [food] from [src].</span>")
			food_slots[2] = null
	if(href_list["f3"])
		if(food_slots[3])
			var/obj/item/food = food_slots[3]
			food.forceMove_turf()
			user.put_in_hands(food, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [food] from [src].</span>")
			food_slots[3] = null
	if(href_list["f4"])
		if(food_slots[4])
			var/obj/item/food = food_slots[4]
			food.forceMove_turf()
			user.put_in_hands(food, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [food] from [src].</span>")
			food_slots[4] = null
	if(href_list["f5"])
		if(food_slots[5])
			var/obj/item/food = food_slots[5]
			food.forceMove_turf()
			user.put_in_hands(food, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [food] from [src].</span>")
			food_slots[5] = null
	if(href_list["f6"])
		if(food_slots[6])
			var/obj/item/food = food_slots[6]
			food.forceMove_turf()
			user.put_in_hands(food, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [food] from [src].</span>")
			food_slots[6] = null
	if(href_list["d1"])
		if(drink_slots[1])
			var/obj/item/drink = drink_slots[1]
			drink.forceMove_turf()
			user.put_in_hands(drink, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [drink] from [src].</span>")
			drink_slots[1] = null
	if(href_list["d2"])
		if(drink_slots[2])
			var/obj/item/drink = drink_slots[2]
			drink.forceMove_turf()
			user.put_in_hands(drink, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [drink] from [src].</span>")
			drink_slots[2] = null
	if(href_list["d3"])
		if(drink_slots[3])
			var/obj/item/drink = drink_slots[3]
			drink.forceMove_turf()
			user.put_in_hands(drink, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [drink] from [src].</span>")
			drink_slots[3] = null
	if(href_list["d4"])
		if(drink_slots[4])
			var/obj/item/drink = drink_slots[4]
			drink.forceMove_turf()
			user.put_in_hands(drink, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [drink] from [src].</span>")
			drink_slots[4] = null
	if(href_list["d5"])
		if(drink_slots[5])
			var/obj/item/drink = drink_slots[5]
			drink.forceMove_turf()
			user.put_in_hands(drink, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [drink] from [src].</span>")
			drink_slots[5] = null
	if(href_list["d6"])
		if(drink_slots[6])
			var/obj/item/drink = drink_slots[6]
			drink.forceMove_turf()
			user.put_in_hands(drink, ignore_anim = FALSE)
			to_chat(user, "<span class='notice'>You take [drink] from [src].</span>")
			drink_slots[6] = null

	updateUsrDialog()

/obj/structure/foodcart/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 4)
	qdel(src)
