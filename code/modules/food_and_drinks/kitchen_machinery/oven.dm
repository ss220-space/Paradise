/obj/machinery/cooking
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/machines/cooking_machines.dmi'
	icon_state = "oven_off"
	layer = 2.9
	density = 1
	anchored = TRUE
	use_power = IDLE_POWER_USE
	var/candy = FALSE
	idle_power_usage = 5
	var/on = FALSE	//Is it making food already?
	var/list/food_choices = list()


/obj/machinery/cooking/Initialize(mapload)
	. = ..()
	updatefood()


/obj/machinery/cooking/update_icon_state()
	icon_state = "[candy ? "mixer" : "oven"][on ? "_on" : "_off"]"


/obj/machinery/cooking/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(on)
		to_chat(user, "The machine is already running.")
		return
	else
		var/obj/item/F = I
		var/obj/item/reagent_containers/food/snacks/customizable/C
		C = input("Select food to make.", "Cooking", C) in food_choices
		if(!C)
			return
		else
			to_chat(user, "You put [F] into [src] for cooking.")
			user.drop_transfer_item_to_loc(F, src)
			on = TRUE
			update_icon(UPDATE_ICON_STATE)
			sleep(10 SECONDS)
			on = FALSE
			update_icon(UPDATE_ICON_STATE)
			C.loc = get_turf(src)
			C.attackby(F,user, params)
			playsound(loc, 'sound/machines/ding.ogg', 50, 1)
			updatefood()


/obj/machinery/cooking/proc/updatefood()
	return

/obj/machinery/cooking/oven
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/machines/cooking_machines.dmi'
	icon_state = "oven_off"

/obj/machinery/cooking/oven/updatefood()
	for(var/U in food_choices)
		food_choices.Remove(U)
	for(var/U in subtypesof(/obj/item/reagent_containers/food/snacks/customizable/cook))
		var/obj/item/reagent_containers/food/snacks/customizable/cook/V = new U
		food_choices += V


/obj/machinery/cooking/candy
	name = "candy machine"
	desc = "Get yer box of deep fried deep fried deep fried deep fried cotton candy cereal sandwich cookies here!"
	icon = 'icons/obj/machines/cooking_machines.dmi'
	icon_state = "mixer_off"
	candy = TRUE

/obj/machinery/cooking/candy/updatefood()
	for(var/U in food_choices)
		food_choices.Remove(U)
	for(var/U in subtypesof(/obj/item/reagent_containers/food/snacks/customizable/candy))
		var/obj/item/reagent_containers/food/snacks/customizable/candy/V = new U
		food_choices += V

