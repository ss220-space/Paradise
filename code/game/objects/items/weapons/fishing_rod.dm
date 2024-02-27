//Fishing rode and related stuff
/obj/item/twohanded/fishingrod
	name = "ol' reliable"
	desc = "Hey! I caught a miner!"
	icon_state = "fishing_rod0"
	item_state = ""
	w_class = WEIGHT_CLASS_SMALL
	var/w_class_on = WEIGHT_CLASS_BULKY

	var/fishing = FALSE

	var/static/mutable_appearance/bobber = mutable_appearance('icons/obj/fish_items.dmi',"bobber")

	var/datum/component/simple_fishing/fishing_component
	var/mob/fisher

/obj/item/twohanded/fishingrod/wield()
	w_class = w_class_on
	item_state = "fishing_rod"

/obj/item/twohanded/fishingrod/unwield()
	w_class = initial(w_class)
	item_state = ""

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
			to_chat(user, span_warning("You are not fishing here!"))
			return

/obj/item/twohanded/fishingrod/proc/start_fishing(datum/component/simple_fishing/fc, mob/user)
	fishing_component = fc
	var/turf/fishing_turf = fishing_component.parent
	fishing_turf.add_overlay(bobber)
	fisher = user
	//тут будет чек на наживку? пока его нет
	//тут ретурн
	to_chat(user, span_notice("You start catching fish."))
	if(do_after(fisher, 10 SECONDS, target = fishing_turf))
		catch_fish()
	fishing_turf.cut_overlay(bobber)


/obj/item/twohanded/fishingrod/proc/catch_fish()
	if(!fisher) //uh oh
		return

	to_chat(fisher, "кажется, вы что-то поймали!")
