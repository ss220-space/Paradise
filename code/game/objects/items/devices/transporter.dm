//Transporter
//This item allow regular player to change value of pixel_x and pixel_y vars for some types of objects and items

/obj/item/transporter
	name = "transporter"
	icon = 'icons/obj/device.dmi'
	icon_state = "transporter"
	item_state = "transporter"
	desc = "A special device, that allow user to change a position of certain objects"
	usesound = 'sound/items/ratchet.ogg'
	hitsound = "swing_hit"

	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT

	force = 5
	throwforce = 7
	materials = list(MAT_METAL=150, MAT_GLASS = 50)
	origin_tech = "materials=1;engineering=1"

	var/target_x = 0
	var/target_y = 0
	var/ignore_type = 0 //For admin building

	var/static/list/allowed_types = list(
		/obj/machinery/firealarm,
		/obj/machinery/power/apc,
		/obj/machinery/alarm,
		/obj/machinery/status_display,
		/obj/machinery/requests_console,
		/obj/item/twohanded/required/kirbyplants,
		/obj/structure/extinguisher_cabinet,
		/obj/structure/sign,
		/obj/item/radio/intercom,
		/obj/machinery/atm,
		/obj/structure/closet/fireaxecabinet,
		/obj/machinery/photocopier,
		/obj/machinery/microscope,
		/obj/machinery/computer,
		/obj/machinery/newscaster,
		/obj/machinery/flasher,
		/obj/machinery/door_control,
		/obj/machinery/camera,
		/obj/structure/reagent_dispensers,
		/obj/machinery/disposal,
		/obj/structure/filingcabinet,
		/obj/structure/closet,
		/obj/structure/rack,
		/obj/machinery/light,
		/obj/machinery/recharger,
		/obj/item/flag,
		/obj/structure/bookcase,
		/obj/machinery/vending,
		/obj/machinery/smartfridge,
		/obj/structure/sink,
		/obj/machinery/shower,
		/obj/machinery/iv_drip,
		/obj/machinery/holosign_switch,
		/obj/machinery/light_switch,
		/obj/structure/window,
		/obj/structure/dresser,
		/obj/machinery/suit_storage_unit,
		/obj/structure/disposaloutlet,
		/obj/item/bedsheet
	)

/obj/item/transporter/attack_self(var/mob/user)
	target_x = round(input(user, "Enter the target X-axis moving between -32 and 32") as null|num)
	if (target_x > 32)
		target_x = 32
	else if (target_x < -32)
		target_x = -32
	target_y = round(input(user, "Enter the target Y-axis moving between -32 and 232") as null|num)
	if (target_y > 32)
		target_y = 32
	else if (target_y < -32)
		target_y = -32

/obj/item/transporter/afterattack(var/atom/A, var/mob/user, proximity, params)
	if(user.a_intent == INTENT_HELP)
		if(!proximity)
			return

		var/obj/target = A

		if((is_type_in_list(target, allowed_types)) || ignore_type)
			target.pixel_x = target_x
			target.pixel_y = target_y
			playsound(loc, usesound, 30, TRUE)
			return
		else
			to_chat(user, "<span class='warning'>\The [src] can't be used on this type of object</span>")
			return

/obj/item/transporter/attack_obj(mob/living/target, mob/living/user, def_zone)
	if(user.a_intent == INTENT_HELP)
		return FALSE
	..()

