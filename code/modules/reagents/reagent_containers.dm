/obj/item/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = WEIGHT_CLASS_TINY
	/// The maximum amount of reagents per transfer that will be moved out of this reagent container.
	var/amount_per_transfer_from_this = 5
	/// If TRUE, it will show how much the container transfer
	var/visible_transfer_rate = TRUE
	/// The different possible amounts of reagent to transfer out of the container
	var/list/possible_transfer_amounts = list(5,10,15,25,30)
	/// The maximum amount of reagents this container can hold
	var/volume = 30
	/// A list of what initial reagents this container should spawn with
	var/list/list_reagents = null
	/// If this container should spawn with a disease type inside of it
	var/spawned_disease = null
	/// How much of a disease specified in spawned_disease should this container spawn with
	var/disease_amount = 20
	/// Used for containers where we want to put lids on and off
	var/has_lid = FALSE
	/// To limit the temperature of a reagent container can atain when exposed to cold
	var/temperature_min = 0
	/// To limit the temperature of a reagent container can atain when exposed to heat
	var/temperature_max = 10000
	/// If TRUE pass open check in empty verb
	var/pass_open_check = FALSE

/obj/item/reagent_containers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in usr

	if(!usr.Adjacent(src) || !(ishuman(usr) || isrobot(usr)) || usr.incapacitated())
		return
	var/default = null
	if(amount_per_transfer_from_this in possible_transfer_amounts)
		default = amount_per_transfer_from_this
	var/N = input("Amount per transfer from this:", "[src]", default) as null|anything in possible_transfer_amounts

	if(!N)
		return
	if(!usr.Adjacent(src))
		to_chat(usr, "<span class='warning'>You have moved too far away!</span>")
		return

	if(usr.incapacitated())
		to_chat(usr, "<span class='warning'>You can't use your hands!</span>")
		return

	amount_per_transfer_from_this = N
	to_chat(usr, "<span class='notice'>[src] will now transfer [N] units at a time.</span>")

/obj/item/reagent_containers/AltClick()
	set_APTFT()

/obj/item/reagent_containers/verb/empty()

	set name = "Empty Container"
	set category = "Object"
	set src in usr

	if(!usr.Adjacent(src) || usr.stat || !usr.canmove || usr.incapacitated())
		return
	if(alert(usr, "Are you sure you want to empty that?", "Empty Container:", "Yes", "No") != "Yes")
		return
	if(!usr.Adjacent(src) || usr.stat || !usr.canmove || usr.incapacitated())
		return
	if(isturf(usr.loc) && loc == usr)
		if(!is_open_container() && !pass_open_check)
			to_chat(usr, "<span class='warning'>Open [src] first.</span>")
			return
		if(reagents.total_volume)
			to_chat(usr, "<span class='notice'>You empty [src] onto the floor.</span>")
			reagents.reaction(usr.loc)
			reagents.clear_reagents()
		else
			to_chat(usr, "<span class='notice'>You tried emptying [src], but there's nothing in it.</span>")

/obj/item/reagent_containers/New()
	create_reagents(volume, temperature_min, temperature_max)
	..()
	if(!possible_transfer_amounts)
		verbs -= /obj/item/reagent_containers/verb/set_APTFT

/obj/item/reagent_containers/Initialize(mapload)
	. = ..()
	if(spawned_disease)
		var/datum/disease/F = new spawned_disease
		var/list/data = list("diseases" = list(F), "blood_color" = "#A10808")
		reagents.add_reagent("blood", disease_amount, data)
	add_initial_reagents()
	update_icon()

/obj/item/reagent_containers/proc/add_initial_reagents()
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/reagent_containers/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	if(!QDELETED(src))
		..()


/obj/item/reagent_containers/proc/add_lid()
	if(has_lid)
		container_type ^= REFILLABLE | DRAINABLE
		update_icon()

/obj/item/reagent_containers/proc/remove_lid()
	if(has_lid)
		container_type |= REFILLABLE | DRAINABLE
		update_icon()

/obj/item/reagent_containers/attack_self(mob/user = usr)
	if(has_lid)
		if(is_open_container())
			to_chat(user, "<span class='notice'>You put the lid on [src].</span>")
			add_lid()
		else
			to_chat(user, "<span class='notice'>You take the lid off [src].</span>")
			remove_lid()

/obj/item/reagent_containers/attack(mob/M, mob/user, def_zone)
	if(user.a_intent == INTENT_HARM)
		return ..()

/obj/item/reagent_containers/wash(mob/user, atom/source)
	if(is_open_container())
		if(reagents.total_volume >= volume)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return
		else
			reagents.add_reagent("water", min(volume - reagents.total_volume, amount_per_transfer_from_this))
			to_chat(user, "<span class='notice'>You fill [src] from [source].</span>")
			return
	..()

/obj/item/reagent_containers/examine(mob/user)
	. = ..()
	if(visible_transfer_rate)
		. += "<span class='notice'>It will transfer [amount_per_transfer_from_this] unit[amount_per_transfer_from_this != 1 ? "s" : ""] at a time.</span>"

	if(possible_transfer_amounts)
		. += "<span class='notice'>Alt-click to change the transfer amount.</span>"

