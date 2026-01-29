/datum/action/item_action/advanced/ninja/ninjanet
	name = "Энергетическая сеть"
	desc = "Захватывает противника в сеть из энергии. Затраты энергии: 4000"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	charge_type = ADV_ACTION_TYPE_TOGGLE
	button_icon_state = "energynet"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Pure Energy Net Generator"

/obj/item/clothing/suit/space/space_ninja/proc/toggle_ninja_net_emitter()
	var/mob/living/carbon/human/ninja = affecting
	if(net_emitter)
		qdel(net_emitter)
		net_emitter = null
	else
		net_emitter = new
		net_emitter.my_suit = src
		for(var/datum/action/item_action/advanced/ninja/ninjanet/ninja_action in actions)
			net_emitter.my_action = ninja_action
			ninja_action.action_ready = TRUE
			ninja_action.use_action()
			break
		ninja.put_in_hands(net_emitter)

/obj/item/ninja_net_emitter
	name = "Energy Net Emitter"
	desc = "Спрятанный в костюме Ниндзя девайс. Выстреливает мощной энергетической сеткой, которая мгновенно запутывает и обездвиживает цель."
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "net_emitter"
	item_state = ""
	w_class = WEIGHT_CLASS_BULKY
	item_flags = DROPDEL|ABSTRACT|NOBLUDGEON
	var/obj/item/clothing/suit/space/space_ninja/my_suit = null
	var/datum/action/item_action/advanced/ninja/ninjanet/my_action = null

/obj/item/ninja_net_emitter/get_ru_names()
	return list(
		NOMINATIVE = "энергосетемёт",
		GENITIVE = "энергосетемёта",
		DATIVE = "энергосетемёту",
		ACCUSATIVE = "энергосетемёт",
		INSTRUMENTAL = "энергосетемётом",
		PREPOSITIONAL = "энергосетемёте",
	)

/obj/item/ninja_net_emitter/Destroy()
	. = ..()
	my_suit.net_emitter = null
	my_suit = null
	my_action.action_ready = FALSE
	my_action.use_action()
	my_action = null

/obj/item/ninja_net_emitter/equip_to_best_slot(mob/user, force = FALSE, drop_on_fail = FALSE, qdel_on_fail = FALSE)
	qdel(src)

/obj/item/ninja_net_emitter/run_drop_held_item(mob/user)
	qdel(src)

/obj/item/ninja_net_emitter/attack_self(mob/user)
	return

/obj/item/ninja_net_emitter/afterattack(atom/target, mob/living/user, proximity, params)
	var/mob/target_mob = get_mob_in_atom_without_warning(target)
	ensnare(target_mob, user)

/obj/item/ninja_net_emitter/proc/ensnare(mob/living/target, mob/living/ninja)
	if(isnull(target))
		return
	if(QDELETED(target) || !(target in oview(ninja)) || !isliving(target) || ninja.incapacitated())
		return
	for(var/turf/between_turf in get_line(get_turf(ninja), get_turf(target)))
		if(between_turf.density)//Don't want them shooting nets through walls. It's kind of cheesy.
			balloon_alert(ninja, "невозможно!")
			return
	if(locate(/obj/structure/energy_net) in get_turf(target))//Check if they are already being affected by an energy net.
		balloon_alert(ninja, "цель уже запутана!")
		return
	if(!my_suit.ninjacost(4000, N_STEALTH_CANCEL))
		ninja.Beam(target, "n_beam", time = 15)
		var/obj/structure/energy_net/net = new /obj/structure/energy_net(target.drop_location())
		net.affected_mob = target
		ninja.visible_message(span_warning("[DECLENT_RU_CAP(ninja, NOMINATIVE)] запутыва[PLUR_ET_YUT(ninja)] [target.declent_ru(ACCUSATIVE)] [declent_ru(INSTRUMENTAL)]!"), span_notice("Вы запутываете [target.declent_ru(ACCUSATIVE)] [declent_ru(INSTRUMENTAL)]!"))
		if(target.buckled)
			target.buckled.unbuckle_mob(target, TRUE)
		net.buckle_mob(target, TRUE) //No moving for you!
		qdel(src)
