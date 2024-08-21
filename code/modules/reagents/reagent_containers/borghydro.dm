#define BORGHYPO_REFILL_VALUE 5

/obj/item/reagent_containers/borghypo
	name = "Cyborg Hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/hypo.dmi'
	item_state = "hypo"
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	var/mode = 1
	var/charge_cost = 50
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in seconds)
	var/bypass_protection = FALSE //If the hypospray can go through armor or thick material
	var/upgrade_path = /obj/item/reagent_containers/borghypo/upgraded

	var/list/datum/reagents/reagent_list = list()
	var/list/reagent_ids = list( \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"mannitol" = list('icons/obj/species_organs/grey.dmi', "brain2"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"), \
		"spaceacillin" = list('icons/effects/effects.dmi', "greenglow"), \
		"charcoal" = list('icons/mob/screen_corgi.dmi', "tox1"), \
		"hydrocodone" = list('icons/mob/actions/actions.dmi', "magicm"))



/obj/item/reagent_containers/borghypo/syndicate
	name = "syndicate cyborg hypospray"
	desc = "An experimental piece of Syndicate technology used to produce powerful restorative nanites used to very quickly restore injuries of all types. Also metabolizes potassium iodide, for radiation poisoning, and hydrocodone, for field surgery and pain relief."
	icon_state = "borghypo_s"
	charge_cost = 20
	recharge_time = 2
	reagent_ids = list( \
		"syndicate_nanites" = list('icons/mob/swarmer.dmi', "swarmer_ranged"), \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"), \
		"potass_iodide" = list('icons/obj/decals.dmi', "radiation"), \
		"hydrocodone" = list('icons/mob/actions/actions.dmi', "magicm"))
	bypass_protection = TRUE
	upgrade_path = null //no upgrades


/obj/item/reagent_containers/borghypo/upgraded
	name = "upgraded cyborg hypospray"
	desc = "An upgraded advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	reagent_ids = list( \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"mannitol" = list('icons/obj/species_organs/grey.dmi', "brain2"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"), \
		"spaceacillin" = list('icons/effects/effects.dmi', "greenglow"), \
		"pen_acid" = list('icons/mob/screen_corgi.dmi', "tox1"), \
		"hydrocodone" = list('icons/mob/actions/actions.dmi', "magicm"), \
		"perfluorodecalin" = list('icons/obj/surgery.dmi', "lungs"), \
		"calomel" = list('icons/obj/items.dmi', "soap"), \
		"oculine" = list('icons/obj/surgery.dmi', "eyes"))
	upgrade_path = null //no upgrades

/obj/item/reagent_containers/borghypo/upgraded/super
	bypass_protection = TRUE

/obj/item/reagent_containers/borghypo/empty()
	set hidden = TRUE


/obj/item/reagent_containers/borghypo/Initialize(mapload)
	for(var/R in reagent_ids)
		add_reagent(R)
	. = ..()

	START_PROCESSING(SSobj, src)


/obj/item/reagent_containers/borghypo/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/reagent_containers/borghypo/process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
	charge_tick++
	if(charge_tick < recharge_time)
		return FALSE
	charge_tick = 0

	var/target_loc
	if (isrobot(loc))
		target_loc = loc
	else if (isrobot(loc.loc))
		target_loc = loc.loc
	else
		return TRUE

	var/mob/living/silicon/robot/R = target_loc
	if(R && R.cell)
		var/datum/reagents/RG = reagent_list[mode]
		if(!refill_borghypo(RG, reagent_ids[mode], R)) 	//If the storage is not full recharge reagents and drain power.
			for(var/i in 1 to reagent_list.len)     	//if active mode is full loop through the list and fill the first one that is not full
				RG = reagent_list[i]
				if(refill_borghypo(RG, reagent_ids[i], R))
					break
	//update_icon()
	return TRUE


// Use this to add more chemicals for the borghypo to produce.
/obj/item/reagent_containers/borghypo/proc/add_reagent(reagent)
	reagent_ids |= reagent
	var/datum/reagents/RG = new(30)
	RG.my_atom = src
	reagent_list += RG

	var/datum/reagents/R = reagent_list[reagent_list.len]
	R.add_reagent(reagent, 30)


/obj/item/reagent_containers/borghypo/proc/refill_borghypo(datum/reagents/RG, reagent_id, mob/living/silicon/robot/R)
	if(RG.total_volume < RG.maximum_volume)
		RG.add_reagent(reagent_id, BORGHYPO_REFILL_VALUE)
		R.cell.use(charge_cost)
		return TRUE
	return FALSE


/obj/item/reagent_containers/borghypo/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!ishuman(target) || !target.reagents)
		return .

	var/datum/reagents/our_reagents = reagent_list[mode]
	if(!our_reagents.total_volume)
		to_chat(user, span_warning("The injector is empty."))
		return .

	if(!target.can_inject(user, TRUE, user.zone_selected, bypass_protection, bypass_protection))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	to_chat(user, span_notice("You inject [target] with the injector."))
	to_chat(target, span_notice("You feel a tiny prick!"))
	our_reagents.add_reagent(target)
	var/datum/reagent/injected = GLOB.chemical_reagents_list[reagent_ids[mode]]
	var/contained = injected.name
	var/trans = our_reagents.trans_to(target, amount_per_transfer_from_this)
	add_attack_logs(user, target, "Injected with [name] containing [contained], transfered [trans] units", injected.harmless ? ATKLOG_ALMOSTALL : null)
	to_chat(user, span_notice("[trans] units injected. [our_reagents.total_volume] units remaining."))


/obj/item/reagent_containers/borghypo/attack_self(mob/user)
	radial_menu(user)


/obj/item/reagent_containers/borghypo/proc/radial_menu(mob/user)
	var/list/choices = list()
	for(var/i in 1 to length(reagent_ids))
		choices[GLOB.chemical_reagents_list[reagent_ids[i]]] = image(icon = reagent_ids[reagent_ids[i]][1], icon_state = reagent_ids[reagent_ids[i]][2])
	var/choice = show_radial_menu(user, src, choices)
	if(!choice)
		return 0
	playsound(loc, 'sound/effects/pop.ogg', 50, 0)
	mode = choices.Find(choice)

	var/datum/reagent/R = GLOB.chemical_reagents_list[reagent_ids[mode]]
	amount_per_transfer_from_this  = (reagent_ids[mode] == "perfluorodecalin") ? 3 : 5
	to_chat(user, span_notice("Synthesizer is now producing '[R.name]'."))


/obj/item/reagent_containers/borghypo/examine(mob/user)
	. = ..()

	if(bypass_protection)
		. += span_boldnotice("Advanced injector is installed on this module, allowing it to pierce thick tissue and materials.")

	if(get_dist(user, src) <= 2)
		var/empty = TRUE

		for(var/datum/reagents/RS in reagent_list)
			var/datum/reagent/R = locate() in RS.reagent_list
			if(R)
				. += span_notice("It currently has [R.volume] units of [R.name] stored.")
				empty = FALSE

		if(empty)
			. += span_notice("It is currently empty. Allow some time for the internal syntheszier to produce more.")


/obj/item/reagent_containers/borghypo/basic
	name = "Basic Medical Hypospray"
	desc = "A very basic medical hypospray, capable of providing simple medical treatment in emergencies."
	reagent_ids = list( \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"))
	upgrade_path = /obj/item/reagent_containers/borghypo/basic/upgraded


/obj/item/reagent_containers/borghypo/basic/upgraded
	name = "Upgraded Basic Medical Hypospray"
	desc = "Basic medical hypospray, capable of providing standart medical treatment."
	reagent_ids = list( \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"), \
		"charcoal" = list('icons/mob/screen_corgi.dmi', "tox1"), \
		"sal_acid" = list('icons/mob/actions/actions.dmi', "fleshmend"), \
		"salbutamol" = list('icons/obj/surgery.dmi', "lungs"))
	upgrade_path = null //no upgrades

/obj/item/reagent_containers/borghypo/emagged
	name = "ERR3NU1l_INJ3C70R"
	desc = "This injector will deliver deadly chemicals into anyone not fortunate enough to end up as an enemy to Syndicate. Who could've thought NanoTrasen borgs can synthesize that?"
	icon = 'icons/obj/hypo.dmi'
	item_state = "borghypo_emag"
	icon_state = "borghypo_emag"
	amount_per_transfer_from_this = 10
	// volume = 30
	var/emagged = TRUE
	var/safety_hypo = FALSE
	reagent_ids = list( \
		"heparin" = list('icons/effects/bleed.dmi', "bleed10"), \
		"cyanide" = list('icons/mob/screen_corgi.dmi', "tox1"), \
		"sodium_thiopental" = list('icons/obj/surgery.dmi', "lungs"))
	upgrade_path = null //no upgrades



#undef BORGHYPO_REFILL_VALUE
