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
	to_chat(user, span_notice("You started catching fish."))
	if(do_after(fisher, 10 SECONDS, target = fishing_turf))
		catch_fish()
		fishing_turf.cut_overlay(bobber)
	else
		to_chat(user, span_warning("You need to stand still in order to fishing something!"))



/obj/item/twohanded/fishingrod/proc/catch_fish()
	if(!fisher) //uh oh
		return

	to_chat(fisher, "кажется, вы что-то поймали!")

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

