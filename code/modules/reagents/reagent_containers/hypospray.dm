////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/hypo.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	belt_icon = "hypospray"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = list(1,2,3,4,5,10,15,20,25,30)
	resistance_flags = ACID_PROOF
	container_type = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	var/ignore_flags = FALSE
	var/emagged = FALSE
	var/safety_hypo = FALSE

/obj/item/reagent_containers/hypospray/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!iscarbon(target) || !target.reagents)
		return .

	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("The [name] is empty!"))
		return .

	if(!ignore_flags && !target.can_inject(user, TRUE))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	to_chat(target, span_warning("You feel a tiny prick!"))
	to_chat(user, span_notice("You inject [target] with [src]."))

	var/list/injected = list()
	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		injected += reagent.name

	var/primary_reagent_name = reagents.get_master_reagent_name()
	var/fraction = min(amount_per_transfer_from_this / reagents.total_volume, 1)
	reagents.reaction(target, REAGENT_INGEST, fraction)
	var/trans = reagents.trans_to(target, amount_per_transfer_from_this)

	if(safety_hypo)
		visible_message(span_warning("[user] injects [target] with [trans] units of [primary_reagent_name]."))
		playsound(loc, 'sound/goonstation/items/hypo.ogg', 80)

	to_chat(user, span_notice("Injected [trans] unit\s. The [name] holds [reagents.total_volume] unit\s."))
	add_attack_logs(user, target, "Injected with [src] containing ([english_list(injected)])", reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)


/obj/item/reagent_containers/hypospray/on_reagent_change()
	if(safety_hypo && !emagged)
		var/found_forbidden_reagent = FALSE
		for(var/datum/reagent/R in reagents.reagent_list)
			if(!GLOB.safe_chem_list.Find(R.id))
				reagents.del_reagent(R.id)
				found_forbidden_reagent = TRUE
		if(found_forbidden_reagent)
			if(ismob(loc))
				to_chat(loc, "<span class='warning'>[src] identifies and removes a harmful substance.</span>")
			else
				visible_message("<span class='warning'>[src] identifies and removes a harmful substance.</span>")


/obj/item/reagent_containers/hypospray/emag_act(mob/user)
	if(safety_hypo && !emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		ignore_flags = TRUE
		if(user)
			to_chat(user, "<span class='warning'>You short out the safeties on [src].</span>")

/obj/item/reagent_containers/hypospray/safety
	name = "medical hypospray"
	desc = "A general use medical hypospray for quick injection of chemicals. There is a safety button by the trigger."
	icon_state = "medivend_hypo"
	belt_icon = "medical_hypospray"
	safety_hypo = TRUE
	var/paint_color
	var/color_overlay = "colour_hypo"


/obj/item/reagent_containers/hypospray/safety/proc/update_state()
	update_icon(UPDATE_ICON_STATE)
	remove_filter("hypospray_handle")
	if(paint_color)
		var/icon/hypo_mask = icon('icons/obj/hypo.dmi', color_overlay)
		add_filter("hypospray_handle", 1, layering_filter(icon = hypo_mask, color = paint_color))


/obj/item/reagent_containers/hypospray/safety/update_icon_state()
	icon_state = paint_color ? "whitehypo" : "medivend_hypo"

/obj/item/reagent_containers/hypospray/safety/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon/spraycan))
		add_fingerprint(user)
		var/obj/item/toy/crayon/spraycan/can = I
		if(can.capped)
			to_chat(user, span_warning("The cap on [can] is sealed."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(can.uses < 2)
			to_chat(user, span_warning("There is not enough paint in [can]."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		to_chat(user, span_notice("You have painted [src]."))
		playsound(user.loc, 'sound/effects/spray.ogg', 20, TRUE)
		paint_color = can.colour
		can.uses -= 2
		update_state()
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	if(istype(I, /obj/item/soap) && paint_color)
		add_fingerprint(user)
		to_chat(user, span_notice("You wash off the paint layer from the hypospray."))
		paint_color = null
		update_state()
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	return ..()

/obj/item/reagent_containers/hypospray/safety/upgraded
	name = "upgraded medical hypospray"
	desc = "Improved general-purpose medical hypospray for rapid administration of chemicals. This model has increased capacity."
	item_state = "upg_hypo"
	icon_state = "upg_hypo"
	volume = 60
	possible_transfer_amounts = list(1,2,5,10,15,20,25,30,40,60)
	color_overlay = "colour_upgradedhypo"

/obj/item/reagent_containers/hypospray/safety/upgraded/update_icon_state()
	icon_state = paint_color ? "upg_hypo_white" : "upg_hypo"

/obj/item/reagent_containers/hypospray/safety/upgraded/emag_act(mob/user)
	return

/obj/item/reagent_containers/hypospray/safety/ert
	name = "medical hypospray (Omnizine)"
	list_reagents = list("omnizine" = 30)

/obj/item/reagent_containers/hypospray/CMO
	volume = 250
	possible_transfer_amounts = list(1,2,3,4,5,10,15,20,25,30,35,40,45,50)
	list_reagents = list("omnizine" = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/reagent_containers/hypospray/CMO/empty
	list_reagents = null

/obj/item/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat."
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = null
	icon_state = "combat_hypo"
	volume = 90
	ignore_flags = 1 // So they can heal their comrades.
	list_reagents = list("epinephrine" = 30, "weak_omnizine" = 30, "salglu_solution" = 30)

/obj/item/reagent_containers/hypospray/ertm
	volume = 90
	ignore_flags = 1
	icon_state = "combat_hypo"
	possible_transfer_amounts = list(1,2,3,4,5,10,15,20,25,30)

/obj/item/reagent_containers/hypospray/ertm/hydrocodone
	amount_per_transfer_from_this = 10
	name = "Hydrocodon combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat. Contains hydrocodone."
	icon_state = "hypocombat-hydro"
	list_reagents = list("hydrocodone" = 90)

/obj/item/reagent_containers/hypospray/ertm/perfluorodecalin
	amount_per_transfer_from_this = 3
	name = "Perfluorodecalin combat stimulant injector"
	icon_state = "hypocombat-perfa"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat. Contains perfluorodecalin."
	list_reagents = list("perfluorodecalin" = 90)

/obj/item/reagent_containers/hypospray/ertm/pentic_acid
	amount_per_transfer_from_this = 5
	name = "Pentic acid combat stimulant injector"
	icon_state = "hypocombat-dtpa"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat. Contains pentic acid."
	list_reagents = list("pen_acid" = 90)

/obj/item/reagent_containers/hypospray/ertm/epinephrine
	amount_per_transfer_from_this = 5
	name = "Epinephrine combat stimulant injector"
	icon_state = "hypocombat-epi"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat. Contains epinephrine."
	list_reagents = list("epinephrine" = 90)

/obj/item/reagent_containers/hypospray/ertm/mannitol
	amount_per_transfer_from_this = 5
	name = "Mannitol combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat. Contains mannitol."
	icon_state = "hypocombat-mani"
	list_reagents = list("mannitol" = 90)

/obj/item/reagent_containers/hypospray/ertm/oculine
	amount_per_transfer_from_this = 5
	name = "Oculine combat stimulant injector"
	icon_state = "hypocombat-ocu"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat. Contains oculine."
	list_reagents = list("oculine" = 90)

/obj/item/reagent_containers/hypospray/ertm/omnisal
	amount_per_transfer_from_this = 10
	name = "DilOmni-Salglu solution combat stimulant injector"
	icon_state = "hypocombat-womnisal"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat. Contains a solution of dilute omnisin and saline."
	list_reagents = list("weak_omnizine" = 45, "salglu_solution" = 45)
	possible_transfer_amounts = list(10, 20, 30)

/obj/item/reagent_containers/hypospray/combat/nanites
	desc = "A modified air-needle autoinjector for use in combat situations. Prefilled with expensive medical nanites for rapid healing."
	volume = 100
	list_reagents = list("nanites" = 100)

/obj/item/reagent_containers/hypospray/autoinjector
	name = "emergency autoinjector"
	desc = "A rapid and safe way to stabilize patients in critical condition for personnel without advanced medical knowledge."
	icon_state = "autoinjector"
	item_state = "autoinjector"
	belt_icon = "autoinjector"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = null
	volume = 10
	ignore_flags = TRUE //so you can medipen through hardsuits
	container_type = DRAWABLE
	flags = null
	list_reagents = list("epinephrine" = 10)
	/// Whether we can rename and repaint source
	var/reskin_allowed = FALSE
	/// Currently selected skin
	var/current_skin
	/// Is it usable only on yourself?
	var/only_self = FALSE
	/// Is it used?
	var/spent = FALSE


/obj/item/reagent_containers/hypospray/autoinjector/update_icon_state()
	var/base_state
	switch(current_skin)
		if("Completely Blue")
			base_state = "ablueinjector"
		if("Blue")
			base_state = "blueinjector"
		if("Completely Red")
			base_state = "redinjector"
		if("Red")
			base_state = "lepopen"
		if("Golden")
			base_state = "goldinjector"
		if("Completely Green")
			base_state = "greeninjector"
		if("Green")
			base_state = "autoinjector"
		if("Gray")
			base_state = "stimpen"
		else
			base_state = initial(icon_state)

	icon_state = "[base_state][spent ? "0" : ""]"


/obj/item/reagent_containers/hypospray/autoinjector/attackby(obj/item/I, mob/user, params)
	if(!reskin_allowed)
		return ..()

	if(is_pen(I) || istype(I, /obj/item/flashlight/pen))
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/toy/crayon/spraycan))
		add_fingerprint(user)
		var/obj/item/toy/crayon/spraycan/can = I
		if(can.capped)
			to_chat(user, span_warning("The cap on [can] is sealed."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(can.uses <= 0)
			to_chat(user, span_warning("There is not enough paint in [can]."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		var/static/list/injector_icons = list(
			"Completely Blue" = image('icons/obj/hypo.dmi', "ablueinjector"),
			"Blue" = image('icons/obj/hypo.dmi', "blueinjector"),
			"Completely Red" = image('icons/obj/hypo.dmi', "redinjector"),
			"Red" = image('icons/obj/hypo.dmi', "lepopen"),
			"Golden" = image('icons/obj/hypo.dmi', "goldinjector"),
			"Completely Green" = image('icons/obj/hypo.dmi', "greeninjector"),
			"Green" = image('icons/obj/hypo.dmi', "autoinjector"),
			"Gray" = image('icons/obj/hypo.dmi', "stimpen")
		)
		var/choice = show_radial_menu(user, user, injector_icons, radius = 48, custom_check = CALLBACK(src, PROC_REF(check_reskin), user))
		if(!choice || loc != user || can.loc != user || !can.uses || user.incapacitated())
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		to_chat(user, span_notice("You have painted [src]."))
		playsound(user.loc, 'sound/effects/spray.ogg', 20, TRUE)
		current_skin = choice
		can.uses--
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	return ..()


/obj/item/reagent_containers/hypospray/autoinjector/proc/check_reskin(mob/living/user)
	if(user.incapacitated())
		return FALSE
	if(loc != user)
		return FALSE
	return TRUE


/obj/item/reagent_containers/hypospray/autoinjector/empty()
	set hidden = TRUE


/obj/item/reagent_containers/hypospray/autoinjector/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!reagents.total_volume || spent)
		to_chat(user, span_warning("The [name] is empty!"))
		return ATTACK_CHAIN_PROCEED
	if(only_self && target != user)
		to_chat(user, span_warning("The [name] can only be used on yourself."))
		return ATTACK_CHAIN_PROCEED
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		spent = TRUE
		update_icon(UPDATE_ICON_STATE)
		playsound(loc, 'sound/effects/stimpak.ogg', 35, TRUE)


/obj/item/reagent_containers/hypospray/autoinjector/examine()
	. = ..()
	if(reagents && reagents.reagent_list.len)
		. += "<span class='notice'>It is currently loaded.</span>"
	else
		. += "<span class='notice'>It is spent.</span>"


/obj/item/reagent_containers/hypospray/autoinjector/teporone //basilisks
	name = "teporone autoinjector"
	desc = "A rapid way to regulate your body's temperature in the event of a hardsuit malfunction."
	icon_state = "lepopen"
	list_reagents = list("teporone" = 10)

/obj/item/reagent_containers/hypospray/autoinjector/stimpack //goliath kiting
	name = "stimpack autoinjector"
	desc = "A rapid way to stimulate your body's adrenaline, allowing for freer movement in restrictive armor."
	icon_state = "stimpen"
	volume = 20
	amount_per_transfer_from_this = 20
	list_reagents = list("methamphetamine" = 10, "coffee" = 10)

/obj/item/reagent_containers/hypospray/autoinjector/stimulants
	name = "Stimulants autoinjector"
	desc = "Rapidly stimulates and regenerates the body's organ system."
	icon_state = "stimpen"
	amount_per_transfer_from_this = 50
	volume = 50
	list_reagents = list("stimulants" = 50)

/obj/item/reagent_containers/hypospray/autoinjector/survival
	name = "survival medipen"
	desc = "A medipen for surviving in the harshest of environments, heals and protects from environmental hazards. <br><span class='boldwarning'>WARNING: Do not inject more than one pen in quick succession.</span>"
	icon_state = "stimpen"
	belt_icon = "survival_medipen"
	volume = 42
	amount_per_transfer_from_this = 42
	list_reagents = list("salbutamol" = 10, "teporone" = 15, "epinephrine" = 10, "lavaland_extract" = 2, "weak_omnizine" = 5) //Short burst of healing, followed by minor healing from the saline

/obj/item/reagent_containers/hypospray/autoinjector/survival/luxury
	name = "luxury medipen"
	desc = "Cutting edge bluespace technology allowed Nanotrasen to compact 40 of volume into a single medipen. Contains rare and powerful chemicals used to aid in exploration of very hard enviroments.  <br><span class='boldwarning'>WARNING: more than one pen injection in quick succession WILL result in quick death.</span>"
	icon_state = "redinjector"
	volume = 40
	amount_per_transfer_from_this = 40
	list_reagents = list("salbutamol" = 10, "adv_lava_extract" = 10, "teporone" = 10, "hydrocodone" = 10)


/obj/item/reagent_containers/hypospray/autoinjector/survival/luxury/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(lavaland_equipment_pressure_check(get_turf(user)))
		amount_per_transfer_from_this = initial(amount_per_transfer_from_this)
		return ..()

	to_chat(user, span_notice("You start manually releasing the low-pressure gauge..."))
	if(!do_after(user, 5 SECONDS, target)) //5 seconds release and...
		return ATTACK_CHAIN_PROCEED

	amount_per_transfer_from_this = initial(amount_per_transfer_from_this) * 0.3 //1/3 of the reagents
	return ..()


/obj/item/reagent_containers/hypospray/autoinjector/nanocalcium
	name = "protoype nanite autoinjector"
	desc = "After a short period of time the nanites will slow the body's systems and assist with body repair. Nanomachines son."
	icon_state = "bonepen"
	amount_per_transfer_from_this = 15
	volume = 15
	list_reagents = list("nanocalcium" = 15)


/obj/item/reagent_containers/hypospray/autoinjector/nanocalcium/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 20, TRUE)


/obj/item/reagent_containers/hypospray/autoinjector/selfmade
	name = "autoinjector"
	desc = "Самодельное подобие инжектора. Не похоже что вы сможете уколоть кого-то ещё кроме себя используя его."
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list()
	only_self = TRUE
	reskin_allowed = TRUE
	container_type = OPENCONTAINER


/obj/item/reagent_containers/hypospray/autoinjector/selfmade/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		container_type = DRAINABLE


/obj/item/reagent_containers/hypospray/autoinjector/salbutamol
	name = "Salbutamol autoinjector"
	desc = "A medipen used for basic oxygen damage treatment"
	icon_state = "ablueinjector"
	amount_per_transfer_from_this = 20
	volume = 20
	list_reagents = list("salbutamol" = 20)

/obj/item/reagent_containers/hypospray/autoinjector/radium
	name = "Radium autoinjector"
	desc = "A small medipen used for basic nucleation treatment."
	icon_state = "ablueinjector"
	list_reagents = list("radium" = 10)

/obj/item/reagent_containers/hypospray/autoinjector/charcoal
	name = "Charcoal autoinjector"
	desc = "A medipen used for basic toxin damage treatment"
	icon_state = "greeninjector"
	amount_per_transfer_from_this = 20
	volume = 20
	list_reagents = list("charcoal" = 20)
