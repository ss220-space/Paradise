/*
CONTAINS:
CIGARETTES
CIGARS
SMOKING PIPES
HOLO-CIGAR

CIGARETTE PACKETS ARE IN FANCY.DM
LIGHTERS ARE IN LIGHTERS.DM
*/

//////////////////
//FINE SMOKABLES//
//////////////////

/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	slot_flags = ITEM_SLOT_MASK|ITEM_SLOT_EARS
	w_class = WEIGHT_CLASS_TINY
	body_parts_covered = null
	attack_verb = null
	container_type = INJECTABLE
	undyeable = TRUE
	var/lit = FALSE
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	var/icon_off = "cigoff"
	var/type_butt = /obj/item/cigbutt
	var/lastHolder = null
	var/smoketime = 150
	var/chem_volume = 60
	var/list/list_reagents = list("nicotine" = 40)
	var/first_puff = TRUE // the first puff is a bit more reagents ingested

	pickup_sound = 'sound/items/handling/generic_small_pickup.ogg'
	drop_sound = 'sound/items/handling/generic_small_drop.ogg'
	equip_sound = 'sound/items/handling/generic_equip5.ogg'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID =  'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
	)


/obj/item/clothing/mask/cigarette/Initialize(mapload)
	. = ..()
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 30
	reagents.set_reacting(FALSE) // so it doesn't react until you light it
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/clothing/mask/cigarette/Destroy()
	QDEL_NULL(reagents)
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/clothing/mask/cigarette/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(target.on_fire)
		user.do_attack_animation(target)
		light(span_notice("[user] coldly lights the [name] with the burning body of [target]. Clearly, [user.p_they()] offer[user.p_s()] the warmest of regards..."))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/item/clothing/mask/cigarette/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit && !istype(S, /obj/item/storage/ashtray))
		to_chat(user, "<span class='warning'>[S] can't hold [initial(name)] while it's lit!</span>") // initial(name) so it doesn't say "lit" twice in a row
		return FALSE
	else
		return TRUE

/obj/item/clothing/mask/cigarette/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	light()

/obj/item/clothing/mask/cigarette/catch_fire()
	if(!lit)
		light("<span class='warning'>The [name] is lit by the flames!</span>")

/obj/item/clothing/mask/cigarette/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(I.tool_use_check(user, 0)) //Don't need to flash eyes because you are a badass
		light("<span class='notice'>[user] casually lights the [name] with [I], what a badass.</span>")


/obj/item/clothing/mask/cigarette/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/lighter/zippo))
		add_fingerprint(user)
		var/obj/item/lighter/zippo/zippo = I
		if(!zippo.lit)
			return ..()
		light(span_rose("With a single flick of [user.p_their()] wrist, [user] smoothly lights [user.p_their()] [name] with [user.p_their()] [zippo]. Damn [user.p_theyre()] cool."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/lighter))
		add_fingerprint(user)
		var/obj/item/lighter/lighter = I
		if(!lighter.lit)
			return ..()
		light(span_notice("After some fiddling, [user] manages to light [user.p_their()] [name] with [lighter]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/match/unathi))
		add_fingerprint(user)
		var/obj/item/match/unathi/match = I
		if(!match.lit)
			return ..()
		playsound(user.loc, 'sound/effects/unathiignite.ogg', 40, FALSE)
		light(span_rose("[user] spits fire at [user.p_their()] [name], igniting it."))
		match.matchburnout()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/match))
		add_fingerprint(user)
		var/obj/item/match/match = I
		if(!match.lit)
			return ..()
		light(span_notice("[user] lights [user.p_their()] [name] with [user.p_their()] [match.name]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/melee/energy/sword/saber))
		add_fingerprint(user)
		var/obj/item/melee/energy/sword/saber/saber = I
		if(!saber.active)
			return ..()
		light(span_warning("[user] makes a violent slashing motion, barely missing [user.p_their()] nose as light flashes. [user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [name] with [saber] in the process."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(isigniter(I))
		add_fingerprint(user)
		light(span_notice("[user] fiddles with [I], and manages to light [user.p_their()] [name]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/gun/magic/wand/fireball))
		add_fingerprint(user)
		var/obj/item/gun/magic/wand/fireball/wand = I
		if(!wand.charges)
			return ..()
		if(prob(50) || user.mind.assigned_role == "Wizard")
			light(span_notice("Holy shit, did [user] just manage to light [user.p_their()] [name] with [wand], with only moderate eyebrow singing?"))
		else
			to_chat(user, span_warning("Unsure which end of the wand is which, [user] fails to light [name] with [wand]."))
			explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2)
		wand.charges--
		wand.update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/flashlight/flare))
		add_fingerprint(user)
		var/obj/item/flashlight/flare/flare = I
		if(!flare.on || !flare.can_fire_cigs)
			return ..()
		light(span_notice("[user] can't find other flame than [flare] just for light [user.p_their()] [name], someone help this dude."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/candle))
		add_fingerprint(user)
		var/obj/item/candle/candle = I
		if(!candle.lit)
			return ..()
		light(span_notice("[user] lights [user.p_their()] [name] with [user.p_their()] [candle]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/clothing/mask/cigarette))
		add_fingerprint(user)
		var/obj/item/clothing/mask/cigarette/cigarette = I
		if(!cigarette.lit)
			return ..()
		light(span_notice("[user] lights [user.p_their()] [name] with [cigarette]. Someone please give [user.p_their()] zippo..."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/clothing/mask/cigarette/afterattack(obj/item/reagent_containers/glass/glass, mob/user, proximity, params)
	..()
	if(!proximity)
		return
	if(istype(glass))	//you can dip cigarettes into beakers
		var/transfered = glass.reagents.trans_to(src, chem_volume)
		if(transfered)	//if reagents were transfered, show the message
			to_chat(user, "<span class='notice'>You dip \the [src] into \the [glass].</span>")
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				to_chat(user, "<span class='notice'>[glass] is empty.</span>")
			else
				to_chat(user, "<span class='notice'>[src] is full.</span>")


/obj/item/clothing/mask/cigarette/update_icon_state()
	icon_state = lit ? icon_on : icon_off
	item_state = lit ? icon_on : initial(item_state)
	update_equipped_item(update_speedmods = FALSE)


/obj/item/clothing/mask/cigarette/update_name(updates = ALL)
	. = ..()
	name = lit ? "lit [initial(name)]" : initial(name)


/obj/item/clothing/mask/cigarette/proc/light(flavor_text = null)
	if(lit)
		return

	lit = TRUE
	attack_verb = list("burnt", "singed")
	hitsound = 'sound/items/welder.ogg'
	damtype = FIRE
	force = 4

	if(check_reagents_explosion())
		return

	reagents.set_reacting(TRUE)
	reagents.handle_reactions()
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
	if(flavor_text)
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
	START_PROCESSING(SSobj, src)
	playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)


/obj/item/clothing/mask/cigarette/proc/check_reagents_explosion()
	var/reagent = ""
	var/reagent_divisor = 2.5
	if(reagents.get_reagent_amount("plasma"))
		reagent = "plasma"
	else if(reagents.get_reagent_amount("fuel"))
		reagent = "fuel"
		reagent_divisor = 5
	if(!reagent)
		return FALSE

	var/datum/effect_system/reagents_explosion/explosion = new
	explosion.set_up(round(reagents.get_reagent_amount(reagent) / reagent_divisor, 1), get_turf(src), 0, 0)
	if(ismob(loc))
		var/mob/user = loc
		user.temporarily_remove_item_from_inventory(src, force = TRUE)
	qdel(src)
	return TRUE


/obj/item/clothing/mask/cigarette/process()
	var/mob/living/M = loc
	if(isliving(loc))
		M.IgniteMob()
	smoketime--
	if(reagents.total_volume <= 0 || smoketime < 1)
		die()
		return
	smoke()

/obj/item/clothing/mask/cigarette/extinguish_light(force = FALSE)
	if(!force)
		return
	die()

/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on the lit [src], putting it out instantly.</span>")
		die()
	return ..()

/obj/item/clothing/mask/cigarette/proc/smoke()
	var/turf/location = get_turf(src)
	var/is_being_smoked = FALSE
	// Check whether this is actually in a mouth, being smoked
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		if(src == C.wear_mask)
			// There used to be a species check here, but synthetics can smoke now
			is_being_smoked = TRUE
	if(location)
		location.hotspot_expose(700, 5)
	if(reagents && reagents.total_volume)	//	check if it has any reagents at all
		if(is_being_smoked) // if it's being smoked, transfer reagents to the mob
			var/mob/living/carbon/C = loc
			for(var/datum/reagent/R in reagents.reagent_list)
				reagents.trans_id_to(C, R.id, first_puff ? 1 : max(REAGENTS_METABOLISM / reagents.reagent_list.len, 0.1)) //transfer at least .1 of each chem
			first_puff = FALSE
			if(!reagents.total_volume) // There were reagents, but now they're gone
				to_chat(C, "<span class='notice'>Your [name] loses its flavor.</span>")
		else // else just remove some of the reagents
			reagents.remove_any(REAGENTS_METABOLISM)

/obj/item/clothing/mask/cigarette/proc/die()
	var/turf/T = get_turf(src)
	var/obj/item/butt = new type_butt(T)
	transfer_fingerprints_to(butt)
	if(ismob(loc))
		var/mob/living/M = loc
		to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
		M.temporarily_remove_item_from_inventory(src, force = TRUE)		//Force the un-equip so the overlays update
	STOP_PROCESSING(SSobj, src)
	qdel(src)


/obj/item/clothing/mask/cigarette/menthol
	list_reagents = list("nicotine" = 40, "menthol" = 20)

/obj/item/clothing/mask/cigarette/random

/obj/item/clothing/mask/cigarette/random/New()
	list_reagents = list("nicotine" = 40, pick("fuel","saltpetre","synaptizine","green_vomit","potass_iodide","msg","lexorin","mannitol","spaceacillin","cryoxadone","holywater","tea","egg","haloperidol","mutagen","omnizine","carpet","aranesp","cryostylane","chocolate","bilk","cheese","rum","blood","charcoal","coffee","ectoplasm","space_drugs","milk","mutadone","antihol","teporone","insulin","salbutamol","toxin") = 20)
	..()

/obj/item/clothing/mask/cigarette/syndicate
	list_reagents = list("nicotine" = 40, "syndiezine" = 20)

/obj/item/clothing/mask/cigarette/medical_marijuana
	list_reagents = list("thc" = 40, "cbd" = 20)

/obj/item/clothing/mask/cigarette/robustgold
	list_reagents = list("nicotine" = 40, "gold" = 1)

/obj/item/clothing/mask/cigarette/shadyjims
	list_reagents = list("nicotine" = 40, "lipolicide" = 7.5, "ammonia" = 2, "atrazine" = 1, "toxin" = 1.5)

/obj/item/clothing/mask/cigarette/rollie
	name = "rollie"
	desc = "A roll of dried plant matter wrapped in thin paper."
	icon_state = "spliffoff"
	icon_on = "spliffon"
	icon_off = "spliffoff"
	type_butt = /obj/item/cigbutt/roach
	throw_speed = 0.5
	item_state = "spliffoff"

/obj/item/clothing/mask/cigarette/rollie/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)


/obj/item/cigbutt/roach
	name = "roach"
	desc = "A manky old roach, or for non-stoners, a used rollup."
	icon_state = "roach"

/obj/item/cigbutt/roach/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

////////////
// CIGARS //
////////////

/obj/item/clothing/mask/cigarette/cigar
	name = "Premium Cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff"
	type_butt = /obj/item/cigbutt/cigarbutt
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 300
	chem_volume = 120
	list_reagents = list("nicotine" = 120)
	muhtar_fashion = /datum/muhtar_fashion/mask/cigar

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "Cohiba Robusto Cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "Premium Havanian Cigar"
	desc = "A cigar fit for only the best for the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 450
	chem_volume = 180
	list_reagents = list("nicotine" = 180)

/obj/item/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1

/obj/item/cigbutt/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	transform = turn(transform,rand(0,360))

/obj/item/cigbutt/decompile_act(obj/item/matter_decompiler/C, mob/user)
	C.stored_comms["wood"] += 1
	qdel(src)
	return TRUE

/obj/item/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"


/obj/item/clothing/mask/cigarette/cigar/attackby(obj/item/I, mob/user, params)
	var/static/list/lighters = typecacheof(list(
		/obj/item/lighter,
		/obj/item/match,
		/obj/item/melee/energy/sword/saber,
		/obj/item/gun/magic/wand/fireball,
		/obj/item/assembly/igniter,
		/obj/item/flashlight/flare,
		/obj/item/candle,
		/obj/item/clothing/mask/cigarette,
	))
	var/static/list/acceptable_lighters = typecacheof(list(
		/obj/item/lighter/zippo,
		/obj/item/match,
	))
	if(!is_type_in_typecache(I, lighters))
		return ..()
	if(!is_type_in_typecache(I, acceptable_lighters))
		add_fingerprint(user)
		to_chat(user, span_notice("The [name] straight out REFUSES to be lit by such uncivilized means."))
		return ATTACK_CHAIN_PROCEED
	return ..()


/////////////////
//SMOKING PIPES//
/////////////////

/obj/item/clothing/mask/cigarette/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	icon_state = "pipeoff"
	item_state = "pipeoff"
	icon_on = "pipeon"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	smoketime = 500
	chem_volume = 200
	list_reagents = list("nicotine" = 200)

/obj/item/clothing/mask/cigarette/pipe/light(flavor_text = null)
	if(!lit)
		lit = TRUE
		damtype = FIRE
		update_icon(UPDATE_ICON_STATE)
		if(flavor_text)
			var/turf/T = get_turf(src)
			T.visible_message(flavor_text)
		START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/cigarette/pipe/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		new /obj/effect/decal/cleanable/ash(location)
		lit = FALSE
		update_icon(UPDATE_ICON_STATE)
		if(ismob(loc))
			var/mob/living/M = loc
			to_chat(M, "<span class='notice'>Your [name] goes out, and you empty the ash.</span>")
		STOP_PROCESSING(SSobj, src)
		return
	smoke()

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user) //Refills the pipe. Can be changed to an attackby later, if loose tobacco is added to vendors or something.
	if(lit)
		user.visible_message("<span class='notice'>[user] puts out [src].</span>")
		lit = FALSE
		update_icon(UPDATE_ICON_STATE)
		STOP_PROCESSING(SSobj, src)
		return
	if(smoketime <= 0)
		to_chat(user, "<span class='notice'>You refill the pipe with tobacco.</span>")
		reagents.add_reagent("nicotine", chem_volume)
		smoketime = initial(smoketime)
		first_puff = TRUE


/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/I, mob/user, params)
	var/static/list/lighters = typecacheof(list(
		/obj/item/lighter,
		/obj/item/match,
		/obj/item/melee/energy/sword/saber,
		/obj/item/gun/magic/wand/fireball,
		/obj/item/assembly/igniter,
		/obj/item/flashlight/flare,
		/obj/item/candle,
		/obj/item/clothing/mask/cigarette,
	))
	var/static/list/acceptable_lighters = typecacheof(list(
		/obj/item/lighter/zippo,
		/obj/item/match,
	))
	if(!is_type_in_typecache(I, lighters))
		return ..()
	if(!is_type_in_typecache(I, acceptable_lighters))
		add_fingerprint(user)
		to_chat(user, span_notice("The [name] straight out REFUSES to be lit by such uncivilized means."))
		return ATTACK_CHAIN_PROCEED
	return ..()


/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters."
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	smoketime = 800
	chem_volume = 40

/obj/item/clothing/mask/cigarette/pipe/oldpipe
	name = "robust smoking pipe"
	desc = "A worn out smoking pipe. Looks robust"
	icon_state = "oldpipeoff"
	item_state = "oldpipeoff"
	icon_on = "oldpipeon"
	icon_off = "oldpipeoff"

///////////
//ROLLING//
///////////

/obj/item/rollingpaper
	name = "rolling paper"
	desc = "A thin piece of paper used to make fine smokeables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper"
	w_class = WEIGHT_CLASS_TINY

/obj/item/rollingpaper/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(istype(target, /obj/item/reagent_containers/food/snacks/grown))
		var/obj/item/reagent_containers/food/snacks/grown/O = target
		if(O.dry)
			user.temporarily_remove_item_from_inventory(target, force = TRUE)
			user.temporarily_remove_item_from_inventory(src, force = TRUE)
			var/obj/item/clothing/mask/cigarette/rollie/R = new /obj/item/clothing/mask/cigarette/rollie(user.loc)
			R.chem_volume = target.reagents.total_volume
			target.reagents.trans_to(R, R.chem_volume)
			user.put_in_active_hand(R)
			to_chat(user, "<span class='notice'>You roll the [target.name] into a rolling paper.</span>")
			R.desc = "Dried [target.name] rolled up in a thin piece of paper."
			qdel(target)
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to dry this first!</span>")
	else
		..()

//////////////
//HOLO CIGAR//
//////////////

/obj/item/clothing/mask/holo_cigar
	name = "Holo-Cigar"
	desc = "A sleek electronic cigar imported straight from Sol. You feel badass merely glimpsing it..."
	icon_state = "holocigaroff"
	var/enabled = FALSE
	/// Tracks if this is the first cycle smoking the cigar.
	var/has_smoked = FALSE

/obj/item/clothing/mask/holo_cigar/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/holo_cigar/update_icon_state()
	icon_state = "holocigar[enabled ? "on" : "off"]"

/obj/item/clothing/mask/holo_cigar/examine(mob/user)
	. = ..()
	if(enabled)
		. += "[src] hums softly as it synthesizes nicotine."
	else
		. += "[src] seems to be inactive."

/obj/item/clothing/mask/holo_cigar/process()
	if(!iscarbon(loc))
		return

	var/mob/living/carbon/C = loc
	if(C.wear_mask != src)
		return

	if(!has_smoked)
		C.reagents.add_reagent("nicotine", 2)
		has_smoked = TRUE
	else
		C.reagents.add_reagent("nicotine", REAGENTS_METABOLISM)

/obj/item/clothing/mask/holo_cigar/equipped(mob/user, slot, initial)
	. = ..()
	if(enabled && slot == ITEM_SLOT_MASK)
		if(!HAS_TRAIT_FROM(user, TRAIT_BADASS, HOLO_CIGAR_TRAIT))
			ADD_TRAIT(user, TRAIT_BADASS, HOLO_CIGAR_TRAIT)
			to_chat(user, span_notice("You feel more badass while smoking [src]."))

/obj/item/clothing/mask/holo_cigar/dropped(mob/user, slot, silent)
	. = ..()
	has_smoked = FALSE
	if(HAS_TRAIT_FROM(user, TRAIT_BADASS, HOLO_CIGAR_TRAIT))
		REMOVE_TRAIT(user, TRAIT_BADASS, HOLO_CIGAR_TRAIT)
		to_chat(user, span_notice("You feel less badass."))

/obj/item/clothing/mask/holo_cigar/attack_self(mob/user)
	. = ..()
	if(enabled)
		enabled = FALSE
		to_chat(user, span_notice("You disable the holo-cigar."))
		STOP_PROCESSING(SSobj, src)
	else
		enabled = TRUE
		to_chat(user, span_notice("You enable the holo-cigar."))
		START_PROCESSING(SSobj, src)

	update_appearance(UPDATE_ICON_STATE)
