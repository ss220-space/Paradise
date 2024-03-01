#define BAIT_AFFECT 80

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
		fishing = TRUE
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
		fishing = FALSE
		return
	to_chat(user, span_notice("You started fishing."))
	if(do_after(fisher, 1 SECONDS, target = fishing_turf)) //нормально - 10
		catch_fish()
		fishing = FALSE
		fishing_turf.cut_overlay(bobber)
	else
		to_chat(user, span_warning("You need to stand still in order to fishing something!"))
		fishing_turf.cut_overlay(bobber)
		fishing = FALSE
		return



/obj/item/twohanded/fishingrod/proc/catch_fish()
	if(!fisher) //uh oh
		return

	if(!bait) //double check
		return

	calculate_fishing_chance()

	var/fish =  new reward_fish(loc)
	to_chat(fisher, span_notice("You caught [fish]!"))

	attack_self(fisher) //Unwield fishing rod

	fisher.put_in_hands(fish)
	bait = null
	update_icon(UPDATE_OVERLAYS)


/obj/item/twohanded/fishingrod/proc/calculate_fishing_chance() // I fucking hate it

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

	if(prob(BAIT_AFFECT))
		reward_fish = pick(bait_list)
	else
		reward_fish = pick(fishable_list)

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


#undef BAIT_AFFECT
