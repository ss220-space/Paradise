/obj/item/gun/syringe/rapidsyringe/experimental
	name = "experimental syringe gun"
	desc = "Эксперементальный шприцемет с 6 слотами для шприцев, встроенным, самовосполняющимся хранилищем химикатов и новейшей системой автозаправки шприцев."
	origin_tech = "combat=3;biotech=4;bluespace=5"
	icon = 'icons/obj/weapons/techrelic.dmi'
	item_state = "strynggun"
	lefthand_file = 'icons/mob/inhands/relics_production/inhandl.dmi'
	righthand_file = 'icons/mob/inhands/relics_production/inhandr.dmi'
	icon_state = "strynggun"
	materials = list(MAT_METAL=2000, MAT_GLASS=2000, MAT_BLUESPACE=400)
	var/obj/item/reagent_containers/glass/beaker/large/ready_reagents = new
	var/obj/item/reagent_containers/glass/beaker/large/processed_reagents = new
	var/synth_speed = 5
	var/bank_size = 100
	origin_tech = "bluespace=4;biotech=5"

/obj/item/gun/syringe/rapidsyringe/experimental/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/gun/syringe/rapidsyringe/experimental/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/syringe/rapidsyringe/experimental/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/reagent_containers/syringe))
		var/in_clip = length(syringes) + (chambered.BB ? 1 : 0)
		if(in_clip < max_syringes)
			if(!user.drop_transfer_item_to_loc(A, src))
				return ..()
			balloon_alert(user, "заряжено!")
			syringes.Add(A)
			process_chamber() // Chamber the syringe if none is already
			return ATTACK_CHAIN_BLOCKED_ALL
		else
			balloon_alert(user, "недостаточно места!")
			return ATTACK_CHAIN_PROCEED
	else if(istype(A, /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/glass/RC = A
		if (!RC.reagents.reagent_list)
			return  ..()
		ready_reagents.reagents.clear_reagents()
		processed_reagents.reagents.clear_reagents()
		RC.reagents.trans_to(ready_reagents, bank_size)
		ready_reagents.reagents.trans_to(processed_reagents, synth_speed)
		balloon_alert(user, "синтезируемый набор веществ изменен!")
		return ATTACK_CHAIN_BLOCKED_ALL
	else
		return ..()

/obj/item/gun/syringe/rapidsyringe/experimental/process()
	for (var/obj/item/reagent_containers/syringe/S in syringes)
		ready_reagents.reagents.trans_to(S, ready_reagents.reagents.total_volume)
	for (var/datum/reagent/R in processed_reagents.reagents.reagent_list)
		if (R.can_synth)
			ready_reagents.reagents.add_reagent(R.id, R.volume)

/datum/crafting_recipe/rapidsyringe_experimental
	name = "Experemintal syringe gun"
	result = /obj/item/gun/syringe/rapidsyringe/experimental
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	reqs = list(/obj/item/relict_production/perfect_mix = 1,
				/obj/item/assembly/signaler/anomaly/vortex = 1,
				/obj/item/gun/syringe/rapidsyringe = 1,
				/obj/item/stock_parts/matter_bin = 1)
	time = 300
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
