// Basic lighters
/obj/item/lighter
	name = "cheap lighter"
	desc = "A cheap-as-free lighter."
	icon = 'icons/obj/items.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 4
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	attack_verb = null
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 2
	light_on = FALSE
	light_power = 1
	var/lit = FALSE
	var/icon_on = "lighter-g-on"
	var/icon_off = "lighter-g"
	/// Cooldown until the next turned on message/sound can be activated
	var/next_on_message
	/// Cooldown until the next turned off message/sound can be activated
	var/next_off_message

/obj/item/lighter/random/New()
	..()
	var/color = pick("r","c","y","g")
	icon_on = "lighter-[color]-on"
	icon_off = "lighter-[color]"
	icon_state = icon_off

/obj/item/lighter/attack_self(mob/living/user)
	. = ..()
	if(!lit)
		turn_on_lighter(user)
	else
		turn_off_lighter(user)

/obj/item/lighter/proc/turn_on_lighter(mob/living/user)
	lit = TRUE
	w_class = WEIGHT_CLASS_BULKY
	icon_state = icon_on
	force = 5
	damtype = BURN
	hitsound = 'sound/items/welder.ogg'
	attack_verb = list("burnt", "singed")

	attempt_light(user)
	set_light_on(TRUE)
	START_PROCESSING(SSobj, src)

/obj/item/lighter/proc/attempt_light(mob/living/user)
	if(prob(75) || issilicon(user)) // Robots can never burn themselves trying to light it.
		to_chat(user, span_notice("You light [src]."))
	else if(HAS_TRAIT(user, TRAIT_BADASS))
		to_chat(user, span_notice("[src]'s flames lick your hand as you light it, but you don't flinch."))
	else
		user.apply_damage(5, BURN, def_zone = user.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)	//INFERNO
		to_chat(user, span_notice("You light [src], but you burn your hand in the process."))
	if(world.time > next_on_message)
		playsound(src, 'sound/items/lighter/plastic_strike.ogg', 25, TRUE)
		next_on_message = world.time + 5 SECONDS

/obj/item/lighter/proc/turn_off_lighter(mob/living/user)
	lit = FALSE
	w_class = WEIGHT_CLASS_TINY
	icon_state = icon_off
	damtype = BRUTE
	hitsound = "swing_hit"
	force = 0
	attack_verb = null //human_defense.dm takes care of it

	show_off_message(user)
	set_light_on(FALSE)
	STOP_PROCESSING(SSobj, src)

/obj/item/lighter/extinguish_light(force = FALSE)
	if(!force)
		return
	turn_off_lighter()

/obj/item/lighter/proc/show_off_message(mob/living/user)
	to_chat(user, "<span class='notice'>You shut off [src].")
	if(world.time > next_off_message)
		playsound(src, 'sound/items/lighter/plastic_close.ogg', 25, TRUE)
		next_off_message = world.time + 5 SECONDS


/obj/item/lighter/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!lit)
		return ..()

	var/return_flags = ATTACK_CHAIN_PROCEED

	if(target.IgniteMob())
		return_flags |= ATTACK_CHAIN_SUCCESS
		add_attack_logs(user, target, "set on fire", ATKLOG_FEW)

	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH || !istype(target.wear_mask, /obj/item/clothing/mask/cigarette))
		return ..() | return_flags

	var/obj/item/clothing/mask/cigarette/cig = target.wear_mask
	if(cig.lit)
		to_chat(user, span_notice("The [cig.name] is already lit."))
		return return_flags

	if(target == user)
		return cig.attackby(src, user, params) | return_flags

	return_flags |= ATTACK_CHAIN_SUCCESS
	. = return_flags

	if(istype(src, /obj/item/lighter/zippo))
		cig.light(span_rose("[user] whips the [name] out and holds it for [target]. [user.p_their(TRUE)] arm is as steady as the unflickering flame [user.p_they()] light[user.p_s()] [cig] with."))
	else
		cig.light(span_notice("[user] holds the [name] out for [target], and lights the [cig.name]."))

	playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)
	target.update_inv_wear_mask()


/obj/item/lighter/process()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5)
	return

// Zippo lighters
/obj/item/lighter/zippo
	name = "zippo lighter"
	desc = "The zippo."
	icon_state = "zippo"
	item_state = "zippo"
	icon_on = "zippoon"
	icon_off = "zippo"


/obj/item/lighter/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>[S] can't hold [src] while it's lit!</span>")
		return FALSE
	else
		return TRUE

/obj/item/lighter/zippo/turn_on_lighter(mob/living/user)
	. = ..()
	if(world.time > next_on_message)
		user.visible_message("<span class='rose'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>")
		playsound(src.loc, 'sound/items/zippolight.ogg', 25, 1)
		next_on_message = world.time + 5 SECONDS
	else
		to_chat(user, "<span class='notice'>You light [src].</span>")

/obj/item/lighter/zippo/turn_off_lighter(mob/living/user)
	. = ..()
	if(!user)
		return

	if(world.time > next_off_message)
		user.visible_message("<span class='rose'>You hear a quiet click, as [user] shuts off [src] without even looking at what [user.p_theyre()] doing. Wow.")
		playsound(src.loc, 'sound/items/zippoclose.ogg', 25, 1)
		next_off_message = world.time + 5 SECONDS
	else
		to_chat(user, "<span class='notice'>You shut off [src].")

/obj/item/lighter/zippo/show_off_message(mob/living/user)
	return

/obj/item/lighter/zippo/attempt_light(mob/living/user)
	return

//EXTRA LIGHTERS
/obj/item/lighter/zippo/nt_rep
	name = "gold engraved zippo"
	desc = "An engraved golden Zippo lighter with the letters NT on it."
	icon_state = "zippo_nt_off"
	item_state = "ntzippo"
	icon_on = "zippo_nt_on"
	icon_off = "zippo_nt_off"

/obj/item/lighter/zippo/blue
	name = "blue zippo lighter"
	desc = "A zippo lighter made of some blue metal."
	icon_state = "bluezippo"
	item_state = "bluezippo"
	icon_on = "bluezippoon"
	icon_off = "bluezippo"

/obj/item/lighter/zippo/black
	name = "black zippo lighter"
	desc = "A black zippo lighter."
	icon_state = "blackzippo"
	item_state = "chapzippo"
	icon_on = "blackzippoon"
	icon_off = "blackzippo"

/obj/item/lighter/zippo/engraved
	name = "engraved zippo lighter"
	desc = "A intricately engraved zippo lighter."
	icon_state = "engravedzippo"
	item_state = "engravedzippo"
	icon_on = "engravedzippoon"
	icon_off = "engravedzippo"

/obj/item/lighter/zippo/gonzofist
	name = "Gonzo Fist zippo"
	desc = "A Zippo lighter with the iconic Gonzo Fist on a matte black finish."
	icon_state = "gonzozippo"
	item_state = "gonzozippo"
	icon_on = "gonzozippoon"
	icon_off = "gonzozippo"

/obj/item/lighter/zippo/cap
	name = "Captain's zippo"
	desc = "A limited edition gold Zippo espesially for NT Captains. Looks extremely expensive."
	icon_state = "zippo_cap"
	item_state = "capzippo"
	icon_on = "zippo_cap_on"
	icon_off = "zippo_cap"

/obj/item/lighter/zippo/hop
	name = "Head of personnel zippo"
	desc = "A limited edition Zippo for NT Heads. Tries it best to look like captain's."
	icon_state = "zippo_hop"
	item_state = "hopzippo"
	icon_on = "zippo_hop_on"
	icon_off = "zippo_hop"

/obj/item/lighter/zippo/hos
	name = "Head of Security zippo"
	desc = "A limited edition Zippo for NT Heads. Fuel it with clown's tears."
	icon_state = "zippo_hos"
	item_state = "hoszippo"
	icon_on = "zippo_hos_on"
	icon_off = "zippo_hos"

/obj/item/lighter/zippo/cmo
	name = "Chief Medical Officer zippo"
	desc = "A limited edition Zippo for NT Heads. Made of hypoallergenic steel."
	icon_state = "zippo_cmo"
	item_state = "bluezippo"
	icon_on = "zippo_cmo_on"
	icon_off = "zippo_cmo"

/obj/item/lighter/zippo/ce
	name = "Chief Engineer zippo"
	desc = "A limited edition Zippo for NT Heads. Somebody've tried to repair cover with blue tape."
	icon_state = "zippo_ce"
	item_state = "cezippo"
	icon_on = "zippo_ce_on"
	icon_off = "zippo_ce"

/obj/item/lighter/zippo/rd
	name = "Research Director zippo"
	desc = "A limited edition Zippo for NT Heads. Uses advanced tech to make fire from plasma."
	icon_state = "zippo_rd"
	item_state = "rdzippo"
	icon_on = "zippo_rd_on"
	icon_off = "zippo_rd"

/obj/item/lighter/zippo/qm
	name = "Quartermaster Lighter"
	desc = "It costs 400.000 credits to fire this lighter for 12 seconds."
	icon_state = "zippo_qm"
	item_state = "qmzippo"
	icon_on = "zippo_qm_on"
	icon_off = "zippo_qm"

//Ninja-Zippo//
/obj/item/lighter/zippo/ninja
	name = "\"Shinobi on a rice field\" zippo"
	desc = "A custom made Zippo. It looks almost like a bag of noodles. There is a blood stain on it, and it smells like burnt rice..."
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "zippo_ninja"
	item_state = "zippo_ninja"
	icon_on = "zippo_ninja_on"
	icon_off = "zippo_ninja"

///////////
//MATCHES//
///////////
/obj/item/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = FALSE
	var/burnt = FALSE
	var/smoketime = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1"
	attack_verb = null
	pickup_sound = 'sound/items/handling/generic_small_pickup.ogg'
	drop_sound = 'sound/items/handling/generic_small_drop.ogg'


/obj/item/match/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		matchburnout()
	if(location)
		location.hotspot_expose(700, 5)


/obj/item/match/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	matchignite()


/obj/item/match/extinguish_light(force = FALSE)
	if(!force)
		return
	matchburnout()


/obj/item/match/update_icon_state()
	icon_state = lit ? "match_lit" : "match_burnt"
	item_state = lit ? "cigon" : "cigoff"


/obj/item/match/update_name(updates = ALL)
	. = ..()
	var/init_name = initial(name)
	name = lit ? "lit [init_name]" : burnt ? "burnt [init_name]" : initial(name)


/obj/item/match/update_desc(updates = ALL)
	. = ..()
	var/init_name = initial(name)
	desc = lit ? "A [init_name]. This one is lit." : burnt ? "A [init_name]. This one has seen better days." : initial(desc)


/obj/item/match/proc/matchignite()
	if(!lit && !burnt)
		lit = TRUE
		damtype = FIRE
		force = 3
		hitsound = 'sound/weapons/tap.ogg'
		attack_verb = list("burnt","singed")
		START_PROCESSING(SSobj, src)
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
		return TRUE


/obj/item/match/proc/matchburnout()
	if(lit)
		lit = FALSE
		burnt = TRUE
		damtype = BRUTE
		force = initial(force)
		attack_verb = list("flicked")
		STOP_PROCESSING(SSobj, src)
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
		return TRUE


/obj/item/match/dropped(mob/user, slot, silent = FALSE)
	matchburnout()
	. = ..()


/obj/item/match/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!lit)
		return ..()

	var/return_flags = ATTACK_CHAIN_PROCEED

	if(target.IgniteMob())
		return_flags |= ATTACK_CHAIN_SUCCESS
		add_attack_logs(user, target, "set on fire", ATKLOG_FEW)

	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(target)
	if(!cig || user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		return ..() | return_flags

	if(cig.lit)
		to_chat(user, span_notice("The [cig.name] is already lit."))
		return return_flags

	if(target == user)
		return cig.attackby(src, user, params) | return_flags

	return_flags |= ATTACK_CHAIN_SUCCESS
	. = return_flags

	if(istype(src, /obj/item/match/unathi))
		if(prob(50))
			cig.light(span_rose("[user] spits fire at [target], lighting [cig] and nearly burning [user.p_their()] face!"))
			matchburnout()
		else
			cig.light(span_rose("[user] spits fire at [target], burning [user.p_their()] face and lighting [cig] in the process."))
			target.apply_damage(5, BURN, def_zone = BODY_ZONE_HEAD)
			playsound(src, 'sound/effects/unathiignite.ogg', 40, FALSE)
	else
		cig.light(span_notice("[user] holds [src] out for [target], and lights [cig]."))
		playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)


/obj/item/match/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(burnt)
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()


/obj/item/proc/help_light_cig(mob/living/M)
	var/mask_item = M.get_item_by_slot(ITEM_SLOT_MASK)
	if(istype(mask_item, /obj/item/clothing/mask/cigarette))
		return mask_item


/obj/item/match/firebrand
	name = "firebrand"
	desc = "An unlit firebrand. It makes you wonder why it's not just called a stick."
	smoketime = 20 //40 seconds


/obj/item/match/firebrand/Initialize(mapload)
	. = ..()
	matchignite()


/obj/item/match/unathi
	name = "small blaze"
	desc = "A little flame of your own, currently located dangerously in your mouth."
	icon_state = "match_unathi"
	attack_verb = null
	force = 0
	item_flags = DROPDEL|ABSTRACT
	origin_tech = null
	lit = TRUE
	w_class = WEIGHT_CLASS_BULKY //to prevent it going to pockets


/obj/item/match/unathi/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/match/unathi/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	return	// we are already burning


/obj/item/match/unathi/matchburnout()
	if(!lit)
		return
	lit = FALSE //to avoid a qdel loop
	qdel(src)


/obj/item/match/unathi/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

