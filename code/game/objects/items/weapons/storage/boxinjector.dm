// create box for autoinjectors. I decided to make a small box for autoinjectors.
//  Autoinjectors are difficult to store as a first aid. The box is made of plastic,
//   so any sub-type of auto-injectors can be placed in it. The box will be a buff for miners,
//    medics and other pros who touch auto-injectors.
//     Boxing also has a couple of restrictions that I decided to do so this is not boxing in boxing, but something else
/obj/item/storage/boxinjector
	name = "autoinjector"
	icon = 'icons/obj/boxInjector.dmi'
	icon_state = "autoinjector-0-close"
	desc = "This box is needed for auto-injectors, which can be opened and closed and put in a regular box if it is closed."
	storage_slots = 5
	use_to_pickup = 1
	w_class = WEIGHT_CLASS_SMALL
	// foldable = /obj/item/stack/sheet/plastic  I thought that by accident it was possible to break the box, but I changed my mind
	// foldable_amt = 1
	can_hold = list(/obj/item/reagent_containers/hypospray/autoinjector)

	var/check_open = FALSE // check open box
	var/open_box = "close" // need for icon_state
	var/check_autoinjector = "autoinjector"
	update_icon() // need for new full box injectors

// close father function altClick() = attack_self()
/obj/item/storage/boxinjector/AltClick(mob/user)
	. = attack_self()

// check attack_self and open ore close box autoinjector
/obj/item/storage/boxinjector/attack_self(mob/living/user)
	. = ..()
	if(!check_open)
		check_open = TRUE
		w_class = WEIGHT_CLASS_NORMAL
		open_box = "open"

	else
		check_open = FALSE
		w_class = WEIGHT_CLASS_SMALL
		open_box = "close"

	update_icon()

// update icon for box check_autoinjector: [check_autoinjector] - this name autoinjector, [open_box] - check open box, [contents.len] - amount autoinjector
/obj/item/storage/boxinjector/update_icon()
	..()
	icon_state = "[check_autoinjector]-[contents.len]-[open_box]"



// create obj for full box autoinjectors
/obj/item/storage/boxinjector/full_autoinjector/New()
	..()
	check_autoinjector = "autoinjector"
	for(var/i; i < storage_slots; i++)
		new /obj/item/reagent_containers/hypospray/autoinjector(src)
	update_icon()

/obj/item/storage/boxinjector/full_survival/New()
	..()
	check_autoinjector = "stimpack"
	for(var/i; i < storage_slots; i++)
		new /obj/item/reagent_containers/hypospray/autoinjector/survival(src)
	update_icon()

/obj/item/storage/boxinjector/full_nanocalcium/New()
	..()
	check_autoinjector = "nanocalcium"
	for(var/i; i < storage_slots; i++)
		new /obj/item/reagent_containers/hypospray/autoinjector/nanocalcium(src)
	update_icon()

/obj/item/storage/boxinjector/full_stimulants/New()
	..()
	check_autoinjector = "stimpack"
	for(var/i; i < storage_slots; i++)
		new /obj/item/reagent_containers/hypospray/autoinjector/stimulants(src)
	update_icon()

/obj/item/storage/boxinjector/full_teporone/New()
	..()
	check_autoinjector = "teporone"
	for(var/i; i < storage_slots; i++)
		new /obj/item/reagent_containers/hypospray/autoinjector/teporone(src)
	update_icon()

/obj/item/storage/boxinjector/full_stimpack/New()
	..()
	check_autoinjector = "stimpack"
	for(var/i; i < storage_slots; i++)
		new /obj/item/reagent_containers/hypospray/autoinjector/stimpack(src)
	update_icon()




// check attack box, object for autoinjector. Update name [check_autoinjector] for update_icon
/obj/item/storage/boxinjector/attackby(obj/item/I, mob/user)
	. = ..()
	if(istype(I, /obj/item/reagent_containers/hypospray/autoinjector/stimpack))
		check_autoinjector = "stimpack"
		// can_hold = list(/obj/item/reagent_containers/hypospray/autoinjector/stimpack) heLPS PLS
	else if(istype(I, /obj/item/reagent_containers/hypospray/autoinjector/survival))
		check_autoinjector = "stimpack"
	else if(istype(I, /obj/item/reagent_containers/hypospray/autoinjector/nanocalcium))
		check_autoinjector = "nanocalcium"
	else if(istype(I, /obj/item/reagent_containers/hypospray/autoinjector/stimulants))
		check_autoinjector = "stimpack"
	else if(istype(I, /obj/item/reagent_containers/hypospray/autoinjector/teporone))
		check_autoinjector = "teporone"
	else if(istype(I, /obj/item/reagent_containers/hypospray/autoinjector))
		check_autoinjector = "autoinjector"
	update_icon()