/obj/item/storage/wallet
	name = "leather wallet"
	desc = "Made from genuine leather, it is of the highest quality."
	storage_slots = 10
	icon = 'icons/obj/wallets.dmi'
	icon_state = "brown_wallet"
	item_state = "brown_wallet"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	can_hold = list(
		/obj/item/lipstick,
		/obj/item/stack/spacecash,
		/obj/item/card,
		/obj/item/clothing/mask/cigarette,
		/obj/item/flashlight/pen,
		/obj/item/seeds,
		/obj/item/stack/medical,
		/obj/item/toy/crayon,
		/obj/item/coin,
		/obj/item/dice,
		/obj/item/disk,
		/obj/item/implanter,
		/obj/item/lighter,
		/obj/item/match,
		/obj/item/paper,
		/obj/item/pen,
		/obj/item/photo,
		/obj/item/reagent_containers/dropper,
		/obj/item/stamp,
		/obj/item/encryptionkey,
		/obj/item/clothing/gloves/ring,
		/obj/item/reagent_containers/food/pill/patch,
		/obj/item/spacepod_equipment/key,
		/obj/item/key,
	)
	slot_flags = ITEM_SLOT_ID

	var/obj/item/card/id/front_id = null
	var/image/front_id_overlay = null



/obj/item/storage/wallet/remove_from_storage(obj/item/I, atom/new_location)
	. = ..()
	if(. && istype(I, /obj/item/card/id))
		refresh_ID()


/obj/item/storage/wallet/handle_item_insertion(obj/item/I, prevent_warning = FALSE)
	. = ..()
	if(. && istype(I, /obj/item/card/id))
		refresh_ID()


/obj/item/storage/wallet/swap_items(obj/item/item_1, obj/item/item_2, mob/user)
	. = ..()
	if(.)
		refresh_ID()

/obj/item/storage/wallet/orient2hud(mob/user)
	. = ..()
	refresh_ID()


/obj/item/storage/wallet/proc/refresh_ID()
	// Locate the first ID in the wallet
	front_id = (locate(/obj/item/card/id) in contents)

	if(ishuman(loc))
		var/mob/living/carbon/human/wearing_human = loc
		if(wearing_human.wear_id == src)
			wearing_human.sec_hud_set_ID()

	update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)


/obj/item/storage/wallet/update_overlays()
	. = ..()
	if(!front_id)
		return
	var/front_id_icon_state_holder = front_id.icon_state
	if(copytext(front_id_icon_state_holder,1,4) == "ERT")
		front_id_icon_state_holder = "ERT"
	else if(!icon_exists(icon, front_id_icon_state_holder))
		front_id_icon_state_holder = "id"
	. += mutable_appearance('icons/obj/wallets.dmi', front_id_icon_state_holder)


/obj/item/storage/wallet/update_name(updates = ALL)
	. = ..()
	if(front_id)
		name = "[item_color] leather wallet with [front_id] on the front"
	else
		name = "[item_color] leather wallet"


/obj/item/storage/wallet/GetID()
	return front_id ? front_id : ..()


/obj/item/storage/wallet/GetAccess()
	return front_id ? front_id.GetAccess() : ..()


/obj/item/storage/wallet/random/populate_contents()
	var/cash = pick(/obj/item/stack/spacecash,
		/obj/item/stack/spacecash/c10,
		/obj/item/stack/spacecash/c100,
		/obj/item/stack/spacecash/c500,
		/obj/item/stack/spacecash/c1000)
	var/coin = pickweight(list(/obj/item/coin/iron = 3,
							   /obj/item/coin/silver = 2,
							   /obj/item/coin/gold = 1))
	new cash(src)
	if(prob(50))
		new cash(src)
	new coin(src)

//////////////////////////////////////
//			Color Wallets			//
//////////////////////////////////////

/obj/item/storage/wallet/color
	name = "cheap wallet"
	desc = "A cheap wallet from the arcade."
	storage_slots = 5		//smaller storage than normal wallets
	icon = 'icons/obj/wallets.dmi'


/obj/item/storage/wallet/color/Initialize(mapload)
	. = ..()
	if(!item_color)
		var/color_wallet = pick(subtypesof(/obj/item/storage/wallet/color))
		new color_wallet(src.loc)
		qdel(src)
		return
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE)


/obj/item/storage/wallet/color/update_icon_state()
	icon_state = "[item_color]_wallet"


/obj/item/storage/wallet/color/update_desc(updates = ALL)
	. = ..()
	desc = "[item_color] wallet made from... leather?"


/obj/item/storage/wallet/color/blue
	icon_state = "blue_wallet"
	item_color = "blue"

/obj/item/storage/wallet/color/red
	icon_state = "red_wallet"
	item_color = "red"

/obj/item/storage/wallet/color/yellow
	icon_state = "yellow_wallet"
	item_color = "yellow"

/obj/item/storage/wallet/color/green
	icon_state = "green_wallet"
	item_color = "green"

/obj/item/storage/wallet/color/pink
	icon_state = "pink_wallet"
	item_color = "pink"

/obj/item/storage/wallet/color/black
	icon_state = "black_wallet"
	item_color = "black"
