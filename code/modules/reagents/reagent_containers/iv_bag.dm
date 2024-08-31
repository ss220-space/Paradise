#define IV_DRAW 0
#define IV_INJECT 1

/obj/item/reagent_containers/iv_bag
	name = "\improper IV Bag"
	desc = "A bag with a fine needle attached at the end for injecting patients with fluids over a period of time."
	icon = 'icons/goonstation/objects/iv.dmi'
	lefthand_file = 'icons/goonstation/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/items_righthand.dmi'
	icon_state = "ivbag"
	volume = 200
	possible_transfer_amounts = list(1,5,10,15,20,25,30,50) // Everything above 10 is NOT usable on a person and is instead used for transfering to other containers
	amount_per_transfer_from_this = 1
	container_type = OPENCONTAINER
	resistance_flags = ACID_PROOF
	var/label_text
	var/mode = IV_INJECT
	var/mob/living/carbon/human/injection_target
	var/obj/item/organ/external/injection_limb

/obj/item/reagent_containers/iv_bag/empty()
	set hidden = TRUE

/obj/item/reagent_containers/iv_bag/Destroy()
	end_processing()
	return ..()

/obj/item/reagent_containers/iv_bag/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/iv_bag/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/iv_bag/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/iv_bag/attack_self(mob/user)
	..()
	mode = !mode
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/iv_bag/attack_hand()
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/iv_bag/proc/begin_processing(mob/living/carbon/human/target, zone)
	injection_target = target
	injection_limb = target.get_organ(zone)
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/iv_bag/proc/end_processing()
	add_attack_logs(injection_target, injection_target, "injection of [name](mode: [mode == IV_INJECT ? "Injecting" : "Drawing"])  stopped.")
	injection_target = null
	injection_limb = null
	STOP_PROCESSING(SSobj, src)

/obj/item/reagent_containers/iv_bag/process()
	if(!injection_target || !injection_limb)
		end_processing()
		return

	if(amount_per_transfer_from_this > 10) // Prevents people from switching to illegal transfer values while the IV is already in someone, i.e. anything over 10
		visible_message("<span class='danger'>The IV bag's needle pops out of [injection_target]'s arm. The transfer amount is too high!</span>")
		end_processing()
		return

	if(get_dist(get_turf(src), get_turf(injection_target)) > 1)
		to_chat(injection_target, "<span class='userdanger'>The [src]'s' needle is ripped out of you!</span>")
		injection_target.apply_damage(3, def_zone = injection_limb)
		end_processing()
		return

	// injection_limb.open = ORGAN_ORGANIC_ENCASED_OPEN after scalpel->hemostat->retractor
	if(injection_limb.open < ORGAN_ORGANIC_ENCASED_OPEN && HAS_TRAIT(injection_target, TRAIT_PIERCEIMMUNE))
		end_processing()
		return

	if(mode) 	// Injecting
		if(reagents.total_volume)
			var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1) 	//The amount of reagents we'll transfer to the person
			reagents.reaction(injection_target, REAGENT_INGEST, fraction) 						//React the amount we're transfering.
			reagents.trans_to(injection_target, amount_per_transfer_from_this)
			update_icon(UPDATE_OVERLAYS)
	else		// Drawing
		if(reagents.total_volume < reagents.maximum_volume)
			injection_target.transfer_blood_to(src, amount_per_transfer_from_this)
			for(var/datum/reagent/x in injection_target.reagents.reagent_list) // Pull small amounts of reagents from the person while drawing blood
				injection_target.reagents.trans_to(src, amount_per_transfer_from_this/10)
			update_icon(UPDATE_OVERLAYS)


/obj/item/reagent_containers/iv_bag/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!iscarbon(target) || !target.reagents)
		return .

	// Removing the needle
	if(injection_target)
		if(target != injection_target)
			to_chat(user, span_warning("[src] is already inserted into [injection_target]'s arm!"))
			return .
		if(target != user)
			target.visible_message(
				span_danger("[user] is trying to remove [src]'s needle from [target]'s arm!"),
				span_userdanger("[user] is trying to remove [src]'s needle from [target]'s arm!"),
				ignored_mobs = user,
			)
			to_chat(user, span_notice("You are removing [src]'s needle from [target]'s arm..."))
			if(!do_after(user, 3 SECONDS, target, NONE) || !injection_target)
				return .
			target.visible_message(
				span_danger("[user] has removed [src]'s needle from [target]'s arm!"),
				span_userdanger("[user] has removed [src]'s needle from your arm!"),
				ignored_mobs = user,
			)
			to_chat(user, span_notice("You have removed [src]'s needle from [target]'s arm."))
		else
			user.visible_message(
				span_warning("[user] has removed [src]'s needle from [p_their()] arm!"),
				span_notice("You have removed [src]'s needle from your arm."),
			)
		end_processing()
		return .|ATTACK_CHAIN_SUCCESS

	// Inserting the needle
	if(!target.can_inject(user, TRUE, def_zone))
		return .

	if(amount_per_transfer_from_this > 10) // We only want to be able to transfer 1, 5, or 10 units to people. Higher numbers are for transfering to other containers
		to_chat(user, span_warning("The IV bag can only be used on someone with a transfer amount of 1, 5 or 10."))
		return .

	if(target != user)
		target.visible_message(
			span_danger("[user] is trying to insert [src]'s needle into [target]'s arm!"),
			span_userdanger("[user] is trying to insert [src]'s needle into [target]'s arm!"),
			ignored_mobs = user,
		)
		to_chat(user, span_notice("You are inserting [src]'s needle into [target]'s arm..."))
		if(!do_after(user, 3 SECONDS, target, NONE) || injection_target)
			return .
		target.visible_message(
			span_danger("[user] has inserted [src]'s needle into [target]'s arm!"),
			span_userdanger("[user] has inserted [src]'s needle into your arm!"),
			ignored_mobs = user,
		)
		to_chat(user, span_notice("You have inserted [src]'s needle into [target]'s arm."))
	else
		user.visible_message(
			span_warning("[user] has inserted [src]'s needle into [p_their()] arm!"),
			span_notice("You have inserted [src]'s needle into your arm."),
		)
	add_attack_logs(user, target, "Inserted [name](mode: [mode == IV_INJECT ? "Injecting" : "Drawing"]) containing ([reagents.log_list()]), transfering [amount_per_transfer_from_this] units", reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)
	begin_processing(target, def_zone)
	return .|ATTACK_CHAIN_SUCCESS


/obj/item/reagent_containers/iv_bag/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(target.is_refillable() && is_drainable()) // Transferring from IV bag to other containers
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty.</span>")
			return

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")

	else if(istype(target, /obj/item/reagent_containers/glass) && !target.is_open_container())
		to_chat(user, "<span class='warning'>You cannot fill [target] while it is sealed.</span>")
		return


/obj/item/reagent_containers/iv_bag/update_overlays()
	. = ..()
	if(reagents.total_volume)
		var/percent = round((reagents.total_volume / volume) * 10) // We round the 1's place off of our percent for easy image processing.
		var/image/filling = image('icons/goonstation/objects/iv.dmi', src, "[icon_state][percent]")

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		. += filling
	if(ismob(loc) || istype(loc, /obj/item/gripper))
		switch(mode)
			if(IV_DRAW)
				. += "draw"
			if(IV_INJECT)
				. += "inject"


/obj/item/reagent_containers/iv_bag/attackby(obj/item/I, mob/user, params)
	if(is_pen(I) || istype(I, /obj/item/flashlight/pen))
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


// PRE-FILLED IV BAGS BELOW

/obj/item/reagent_containers/iv_bag/salglu
	list_reagents = list("salglu_solution" = 200)

/obj/item/reagent_containers/iv_bag/salglu/Initialize(mapload)
	name = "[initial(name)] - Saline Glucose"
	. = ..()

/obj/item/reagent_containers/iv_bag/blood // Don't use this - just an abstract type to allow blood bags to have a common blood_type var for ease of creation.
	var/blood_type = "O-"
	var/blood_species = "Human"
	amount_per_transfer_from_this = 5 // Bloodbags are set to transfer 5 units by default.

/obj/item/reagent_containers/iv_bag/blood/Initialize(mapload)
	if(blood_type != null && blood_species != null)
		name = "[initial(name)] - [blood_species] ([blood_type])"
		reagents.add_reagent("blood", 200, list("donor"=null,"diseases"=null,"blood_DNA"=null,"blood_type"=blood_type,"blood_species"=blood_species,"resistances"=null,"trace_chem"=null))
		update_icon(UPDATE_OVERLAYS)
	. = ..()

/obj/item/reagent_containers/iv_bag/blood/random/Initialize(mapload)
	blood_type = pick("A+", "A-", "B+", "B-", "O+", "O-")
	blood_species = pick("Human", "Diona", "Drask", "Grey", "Kidan", "Tajaran", "Vulpkanin", "Skrell", "Unathi", "Nian", "Vox", "Wryn")
	. = ..()

/obj/item/reagent_containers/iv_bag/blood/ABPlus
	blood_type = "AB+"

/obj/item/reagent_containers/iv_bag/blood/ABMinus
	blood_type = "AB-"

/obj/item/reagent_containers/iv_bag/blood/APlus
	blood_type = "A+"

/obj/item/reagent_containers/iv_bag/blood/AMinus
	blood_type = "A-"

/obj/item/reagent_containers/iv_bag/blood/BPlus
	blood_type = "B+"

/obj/item/reagent_containers/iv_bag/blood/BMinus
	blood_type = "B-"

/obj/item/reagent_containers/iv_bag/blood/OPlus
	blood_type = "O+"

/obj/item/reagent_containers/iv_bag/blood/OMinus
	blood_type = "O-"

/obj/item/reagent_containers/iv_bag/blood/skrell
	blood_species = "Skrell"

/obj/item/reagent_containers/iv_bag/blood/tajaran
	blood_species = "Tajaran"

/obj/item/reagent_containers/iv_bag/blood/vulpkanin
	blood_species = "Vulpkanin"

/obj/item/reagent_containers/iv_bag/blood/unathi
	blood_species = "Unathi"

/obj/item/reagent_containers/iv_bag/blood/kidan
	blood_species = "Kidan"

/obj/item/reagent_containers/iv_bag/blood/grey
	blood_species = "Grey"

/obj/item/reagent_containers/iv_bag/blood/diona
	blood_species = "Diona"

/obj/item/reagent_containers/iv_bag/blood/wryn
	blood_species = "Wryn"

/obj/item/reagent_containers/iv_bag/blood/nian
	blood_species = "Nian"

/obj/item/reagent_containers/iv_bag/blood/vox
	blood_species = "Vox"

/obj/item/reagent_containers/iv_bag/bloodsynthetic
	var/blood_type = "Synthetic"
	amount_per_transfer_from_this = 5

/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis
	var/blood_species = "Oxygen - synthetic"

/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis/Initialize(mapload)
	if(blood_type != null && blood_species != null)
		name = "[initial(name)] - Oxygenis"
		reagents.add_reagent("sbloodoxy", 200, list("donor"=null,"diseases"=null,"blood_DNA"=null,"blood_type"=blood_type,"blood_species"=blood_species,"resistances"=null,"trace_chem"=null))
		update_icon(UPDATE_OVERLAYS)

	. = ..()
/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis
	var/blood_species = "Vox - synthetic"

/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis/Initialize(mapload)
	if(blood_type != null && blood_species != null)
		name = "[initial(name)] - Nitrogenis"
		reagents.add_reagent("sbloodvox", 200, list("donor"=null,"diseases"=null,"blood_DNA"=null,"blood_type"=blood_type,"blood_species"=blood_species,"resistances"=null,"trace_chem"=null))
		update_icon(UPDATE_OVERLAYS)
	. = ..()

/obj/item/reagent_containers/iv_bag/slime
	list_reagents = list("slimejelly" = 200)

/obj/item/reagent_containers/iv_bag/slime/Initialize(mapload)
	name = "[initial(name)] - Slime Jelly"
	. = ..()
