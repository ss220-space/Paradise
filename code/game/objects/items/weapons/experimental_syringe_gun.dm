/obj/item/gun/syringe/rapidsyringe/experemental
	name = "experemental syringe gun"
	desc = "Эксперементальный шприцемет с 6 слотами для шприцев, встроенным, самовосполняющимся хранилищем химикатов и новейшей системой автозаправки шприцев."
	origin_tech = "combat=3;biotech=4,bluespace=5"
	materials = list(MAT_METAL=2000, MAT_GLASS=2000, MAT_BLUESPACE=400)
	var/obj/item/reagent_containers/glass/redy_reagents = new
	var/obj/item/reagent_containers/processed_reagents = new
	var/synth_speed = 5

/obj/item/gun/syringe/rapidsyringe/experemental/Initialize() {
	..()
	redy_reagents.reagents.total_volume = 100
	START_PROCESSING(SSobj, src)
}

/obj/item/gun/syringe/rapidsyringe/experemental/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/syringe/rapidsyringe/experemental/attackby(obj/item/A, mob/user, params, show_msg = TRUE)
	if(istype(A, /obj/item/reagent_containers/syringe))
		var/in_clip = length(syringes) + (chambered.BB ? 1 : 0)
		if(in_clip < max_syringes)
			if(!user.drop_transfer_item_to_loc(A, src))
				return
			balloon_alert(user, "заряжено!")
			syringes.Add(A)
			process_chamber() // Chamber the syringe if none is already
			return TRUE
		else
			balloon_alert(user, "недостаточно места!")
	else if(istype(A, /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/glass/RC = A;
		if (!RC.list_reagents)
			return  ..()
		redy_reagents.reagents.clear_reagents()
		RC.reagents.trans_to(redy_reagents, 100)
		processed_reagents.reagents = RC.reagents
		var/volume = processed_reagents.reagents.total_volume
		var/coeff = volume/synth_speed
		for (var/datum/reagent/R in processed_reagents.reagents.reagent_list)
			R.volume /= coeff
		balloon_alert(user, "синтезируемый набор веществ изменен!")
	else
		return ..()

/obj/item/gun/syringe/rapidsyringe/experemental/process()
	for (var/obj/item/reagent_containers/syringe/S in syringes)
		redy_reagents.reagents.trans_to(S, min(redy_reagents.reagents.total_volume, S.volume - S.reagents.total_volume))
	for (var/datum/reagent/R in processed_reagents.reagents.reagent_list)
		redy_reagents.reagents.add_reagent(R)

/datum/crafting_recipe/rapidsyringe_experemental
	name = "Experemental syringe gun"
	result = /obj/item/gun/syringe/rapidsyringe/experemental
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	reqs = list(/obj/item/relict_priduction/perfect_mix = 1,
				/obj/item/assembly/signaler/anomaly/vortex = 1,
				/obj/item/gun/syringe/rapidsyringe = 1,
				/obj/item/stock_parts/matter_bin = 1)
	time = 300
	category = CAT_WEAPONRY
