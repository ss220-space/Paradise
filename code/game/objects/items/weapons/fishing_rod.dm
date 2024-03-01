//Fishing rode and related stuff
/obj/item/twohanded/fishingrod
	name = "ol' reliable"
	desc = "Hey! I caught a miner!"
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "fishing_rod0"
	item_state = "fishing_rod"
	w_class = WEIGHT_CLASS_BULKY

	var/fishing = FALSE
	var/obj/item/reagent_containers/food/snacks/bait/bait = null //what bait is attached to the rod

	var/static/mutable_appearance/bobber = mutable_appearance('icons/obj/fish_items.dmi',"bobber")

	var/datum/component/simple_fishing/fishing_component
	var/mob/fisher

	var/reward_fish = null

/obj/item/twohanded/fishingrod/Destroy()
	. = ..()
	QDEL_NULL(bait)

/obj/item/twohanded/fishingrod/examine(mob/user)
	. = ..()
	if(bait)
		. += span_notice("there is a [bait] on the hook")
		. += span_notice("You can remove it with \"Alt+click\"")


/obj/item/twohanded/fishingrod/update_icon_state()
	icon_state = "fishing_rod[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/fishingrod/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	var/datum/component/simple_fishing/fc = target.GetComponent(/datum/component/simple_fishing)
	if(!fc)
		return ..()
	if(!fishing)
		if(!HAS_TRAIT(src, TRAIT_WIELDED))
			to_chat(user, span_warning("You need to wield the rod in both hands before you can cast it!"))
			return
		start_fishing(fc,user)
	else
		if(fc != fishing_component)
			to_chat(user, span_warning("You are not fishing here."))
			return

/obj/item/twohanded/fishingrod/proc/start_fishing(datum/component/simple_fishing/fc, mob/user)
	fishing_component = fc
	var/turf/fishing_turf = fishing_component.parent
	fishing_turf.add_overlay(bobber)
	fisher = user
	if(!bait)
		to_chat(user, span_warning("It's a foolish decision to fish without bait."))
		return
	to_chat(user, span_notice("You started fishing."))
	if(do_after(fisher, 10 SECONDS, target = fishing_turf))
		catch_fish()
		fishing_turf.cut_overlay(bobber)
	else
		to_chat(user, span_warning("You need to stand still in order to fishing something!"))
		fishing_turf.cut_overlay(bobber)
		return



/obj/item/twohanded/fishingrod/proc/catch_fish()
	if(!fisher) //uh oh
		return

	if(!bait) //double check
		return

	calculate_fishing_chance()

	new reward_fish(loc)
	to_chat(fisher, span_notice("You caught [reward_fish]!"))

	attack_self(fisher) //Unwield fishing rod

	fisher.put_in_hands(reward_fish)
	bait = null
	update_icon(UPDATE_OVERLAYS)


/* /obj/item/twohanded/fishingrod/proc/calculate_fishing_chance() // I fucking hate it

	var/list/fishable_list = fishing_component.catchable_fish
	var/list/bait_list = list()
	for(var/fish in fishable_list) //After this stage, bait_list will have 1-2 fish in bait_list
		var/obj/item/lavaland_fish/cooler_fish = fish
		if(bait == cooler_fish.favorite_bait)
			fishable_list -= cooler_fish
			bait_list += cooler_fish
	if(!bait_list.len) //if something went wrong and list is empty
		reward_fish = pick(fishable_list)
		return
	else
		var/probe_chance = 100 * bait_list.len
		var/bait_chance = 0
		for(var/i in bait_list) //after this stage, we will got a number more than 0, but less than probe_chance
			var/obj/item/lavaland_fish/fishy = i
			bait_chance += fishy.bait_chance
		switch(rand(0, probe_chance))									//	So, what the hell is this?
			if(0 to bait_chance) //one of the bait fish					//	This algorithm is taking bait_chance - all numbers
				for(var/other_fish in bait_list)						//	from fishing.dm and compares it, and increase chance
					var/obj/item/lavaland_fish/fishy = other_fish
					var/number =  fishy.bait_chance						//	for any fish that remains in bait_list
					var/rounded_number = round(number / bait_list.len)	//
					switch(rand(0, bait_chance))						//
						if(0 to rounded_number)							//	Example: we got 4 fishes with 50% chances each, bait_chance - 200,
							reward_fish = other_fish					//	probe chance - 400. each fish has 50/4 - 12.5% to get caught. If you
							return										//	unlucky, it decreases bait chances, and try algorithm again
						else											//  Last fish in list always have 100% chance to get caught
							bait_chance = bait_chance - number


			else //unlucky, normal fish
				reward_fish = pick(fishable_list)

*/







/obj/item/twohanded/fishingrod/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/reagent_containers/food/snacks/bait))
		return

	if(bait)
		to_chat(user, span_warning("[src] already have a bait!"))
		return

	var/obj/item/reagent_containers/food/snacks/bait/worm = I
	if(!user.drop_transfer_item_to_loc(I, src))
		return
	bait = worm
	to_chat(user, span_notice("You've baited the hook with [worm]."))
	update_icon(UPDATE_OVERLAYS)


/obj/item/twohanded/fishingrod/AltClick(mob/user)
	if(bait)
		user.put_in_hands(bait)
		to_chat(user, span_notice("You take the [bait] off the fishing rod."))
		bait = null
		update_icon(UPDATE_OVERLAYS)

/obj/item/twohanded/fishingrod/update_overlays()
	. = ..()
	cut_overlays()
	if(bait)
		add_overlay(bait.rod_overlay)

