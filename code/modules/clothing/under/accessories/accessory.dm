/obj/item/clothing/accessory
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "bluetie"
	item_state = ""	//no inhands
	slot_flags = ITEM_SLOT_ACCESSORY
	w_class = WEIGHT_CLASS_SMALL
	pickup_sound = 'sound/items/handling/accessory_pickup.ogg'
	drop_sound = 'sound/items/handling/accessory_drop.ogg'
	var/slot = ACCESSORY_SLOT_DECOR
	/// the suit the tie may be attached to
	var/obj/item/clothing/under/has_suit
	/// Allow accessories of the same type.
	var/allow_duplicates = TRUE
	/// Overlay used when the accessory is attached to the clothing.
	var/mutable_appearance/acc_overlay


/obj/item/clothing/accessory/Initialize(mapload)
	. = ..()
	if(icon_exists('icons/obj/clothing/ties_overlay.dmi', icon_state))
		acc_overlay = mutable_appearance('icons/obj/clothing/ties_overlay.dmi', icon_state)


/obj/item/clothing/accessory/Destroy()
	on_removed()
	acc_overlay = null
	return ..()


/**
 * Accessory being attached to passed suit.
 *
 * Arguments:
 * * new_suit - suit we are attached onto
 * * attacher - mob who is trying to attach an accessory. Note that attacher is NOT a mob who wears the suit currently, but the one who is doing this action.
 *
 * Returns the suit we are attached to.
 */
/obj/item/clothing/accessory/proc/on_attached(obj/item/clothing/under/new_suit, mob/attacher)
	if(!istype(new_suit))
		return null

	has_suit = new_suit
	LAZYADD(has_suit.accessories, src)

	if(acc_overlay)
		has_suit.update_icon(UPDATE_OVERLAYS)

	if(loc != has_suit)
		forceMove(new_suit)

	if(actions)
		LAZYADD(has_suit.actions, actions)

	if(ismob(has_suit.loc))
		var/mob/wearer = has_suit.loc
		wearer.update_inv_w_uniform()
		for(var/datum/action/action as anything in actions)
			action.Grant(wearer)

	// This proc can run before /obj/Initialize has run for U and src,
	// we have to check that the armor list has been transformed into a datum before we try to call a proc on it
	// This is safe to do as /obj/Initialize only handles setting up the datum if actually needed.
	if(islist(has_suit.armor) || isnull(has_suit.armor))
		has_suit.armor = getArmor(arglist(has_suit.armor))

	has_suit.armor = has_suit.armor.attachArmor(armor)
	return has_suit


/**
 * Accessory being removed from the suit.
 * But still stays inside it's contents. You need to forceMove it separetly.
 *
 * Arguments:
 * * new_suit - suit we are attached onto
 * * attacher - mob who is trying to detach an accessory. Note that detacher is NOT a mob who wears the suit currently, but the one who is doing this action.
 *
 * Returns the suit we were detached from.
 */
/obj/item/clothing/accessory/proc/on_removed(mob/detacher)
	if(!has_suit)
		return null

	LAZYREMOVE(has_suit.accessories, src)
	LAZYREMOVE(has_suit.actions, actions)

	if(acc_overlay)
		has_suit.update_icon(UPDATE_OVERLAYS)

	if(ismob(has_suit.loc))
		var/mob/wearer = has_suit.loc
		wearer.update_inv_w_uniform()
		for(var/datum/action/action as anything in actions)
			action.Remove(wearer)

	has_suit.armor = has_suit.armor.detachArmor(armor)
	. = has_suit
	has_suit = null


/obj/item/clothing/accessory/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	// This code lets you put accessories on other people by attacking their sprite with the accessory
	if(!ishuman(target) || user == target)
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(!istype(target.w_uniform, /obj/item/clothing/under))
		to_chat(user, span_warning("[target] is not wearing anything to attach [src] to."))
		return .

	if(ITEM_SLOT_CLOTH_INNER & target.check_obscured_slots())
		to_chat(user, span_notice("[target]'s body is covered, and you cannot attach [src]."))
		return .

	var/obj/item/clothing/under/uniform = target.w_uniform
	if(uniform_check(target, user, uniform))
		return .

	user.visible_message(
		span_notice("[user] is putting [name] on [target]'s [uniform.name]!"),
		span_notice("You start to put [name] on [target]'s [uniform.name]..."),
	)
	if(!do_after(user, 4 SECONDS, target, extra_checks = CALLBACK(src, PROC_REF(uniform_check), target, user, uniform), max_interact_count = 1))
		return .

	if(!uniform.attach_accessory(src, user, unequip = TRUE))
		return .

	. = ATTACK_CHAIN_BLOCKED_ALL
	user.visible_message(
		span_notice("[user] has put [name] on [target]'s [uniform.name]!"),
		span_notice("You have finished puting [name] on [target]'s [uniform.name]..."),
	)


/obj/item/clothing/accessory/proc/uniform_check(mob/living/carbon/human/target, mob/living/user, obj/item/clothing/under/uniform)
	SHOULD_CALL_PARENT(TRUE)
	if(target.w_uniform != uniform)
		return FALSE
	return TRUE


/obj/item/clothing/accessory/attack_hand(mob/user)
	if(has_suit)
		return	//we aren't an object on the ground so don't call parent
	. = ..()


/// If we need to do something special when clothing with accessory is equipped by the user.
/obj/item/clothing/accessory/proc/attached_equip(mob/user)
	return


/// If we need to do something special when clothing with accessory is removed from the user
/obj/item/clothing/accessory/proc/attached_unequip(mob/user)
	return


/// Additional info when examine accessory on the suit
/obj/item/clothing/accessory/proc/attached_examine(mob/user)
	return span_notice("\A [src] is attached to it.")


/obj/item/clothing/accessory/blue
	name = "blue tie"
	icon_state = "bluetie"

/obj/item/clothing/accessory/red
	name = "red tie"
	icon_state = "redtie"

/obj/item/clothing/accessory/black
	name = "black tie"
	icon_state = "blacktie"

/obj/item/clothing/accessory/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"

/obj/item/clothing/accessory/waistcoat // No overlay
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "waistcoat"
	item_state = "waistcoat"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/accessory/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"


/obj/item/clothing/accessory/stethoscope/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ishuman(target))
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(user == target)
		user.visible_message(
			"[user] places [src] against [user.p_their()] chest and listens attentively.",
			"You place [src] against your chest..."
		)
	else
		user.visible_message(
			"[user] places [src] against [target]'s chest and listens attentively.",
			"You place [src] against [target]'s chest..."
		)

	if(!do_after(user, 5 SECONDS, target, NONE, max_interact_count = 1))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	var/obj/item/organ/internal/heart = target.get_int_organ(/obj/item/organ/internal/heart)
	var/obj/item/organ/internal/lungs = target.get_int_organ(/obj/item/organ/internal/lungs)
	var/msg = ""
	if(heart && target.pulse)
		var/color = "notice"
		var/heart_sound
		switch(heart.damage)
			if(0 to 1)
				heart_sound = "healthy"
			if(1 to 25)
				heart_sound = "offbeat"
			if(25 to 50)
				heart_sound = "uneven"
				color = "warning"
			if(50 to INFINITY)
				heart_sound = "weak, unhealthy"
				color = "warning"

		msg += "You hear <span class='[color]'>[heart_sound]</span> heart pulse"

	if(lungs && !HAS_TRAIT(target, TRAIT_NO_BREATH))
		var/color = "notice"
		var/lung_sound
		var/respiration = TRUE
		switch(lungs.damage)
			if(0 to 1)
				lung_sound = "healthy"
			if(1 to 25)
				lung_sound = "labored"
			if(25 to 50)
				lung_sound = "pained"
				color = "warning"
			if(50 to INFINITY)
				respiration = FALSE
				lung_sound = "gurgling"
				color = "warning"
		if(msg)
			msg += " and <span class='[color]'>[lung_sound]</span>[respiration ? " lungs respiration" : ""]"
		else
			msg += "You hear <span class='[color]'>[lung_sound]</span>[respiration ? " lungs respiration" : ""]"

	if(msg)
		to_chat(user, "[msg].")
	else
		to_chat(user, span_warning("You don't hear anything!"))


//Medals
/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	materials = list(MAT_METAL=1000)
	resistance_flags = FIRE_PROOF

// GOLD (awarded by centcom)
/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	materials = list(MAT_GOLD=1000)

/obj/item/clothing/accessory/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by CentComm. To recieve such a medal is the highest honor and as such, very few exist."
	icon_state = "ion"

// SILVER (awarded by Captain)

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	materials = list(MAT_SILVER=1000)

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal of valor"
	desc = "An award issued by Captains to crew members whose exceptional performance and service to the station has been commended by the station's top leadership."

/obj/item/clothing/accessory/medal/silver/leadership
	name = "medal of command"
	desc = "An award issued by Captains to heads of department who do an excellent job managing their department. Made of pure silver."


// BRONZE (awarded by heads of department, except for the bronze heart)



/obj/item/clothing/accessory/medal/security
	name = "robust security medal"
	desc = "An award issued by the HoS to security staff who excel at upholding the law."

/obj/item/clothing/accessory/medal/science
	name = "smart science medal"
	desc = "An award issued by the RD to science staff who advance the frontiers of knowledge."

/obj/item/clothing/accessory/medal/engineering
	name = "excellent engineering medal"
	desc = "An award issued by the CE to engineering staff whose dedication keep the station running at its best."

/obj/item/clothing/accessory/medal/service
	name = "superior service medal"
	desc = "An award issued by the HoP to service staff who go above and beyond."

/obj/item/clothing/accessory/medal/medical
	name = "magnificient medical medal"
	desc = "An award issued by the CMO to medical staff who excel at saving lives."

/obj/item/clothing/accessory/medal/legal
	name = "meritous legal medal"
	desc = "An award issued by the Magistrate to legal staff who uphold the rule of law."

/obj/item/clothing/accessory/medal/heart
	name = "bronze heart medal"
	desc = "A rarely-awarded medal for those who sacrifice themselves in the line of duty to save their fellow crew."
	icon_state = "bronze_heart"

// Plasma, from NT research departments. For now, used by the HRD-MDE project for the moderate 2 fauna, drake and hierophant.
/obj/item/clothing/accessory/medal/plasma
	name = "plasma medal"
	desc = "An eccentric medal made of plasma."
	icon_state = "plasma"
	materials = list(MAT_PLASMA = 1000)


/obj/item/clothing/accessory/medal/plasma/temperature_expose(datum/gas_mixture/air, temperature, volume)
	..()
	if(temperature > T0C + 200)
		burn_up()

/obj/item/clothing/accessory/medal/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay)
	. = ..()
	burn_up()

/obj/item/clothing/accessory/medal/plasma/proc/burn_up()
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS | LINDA_SPAWN_OXYGEN, 10) //Technically twice as much plasma as it should spawn but a little more never hurt anyone.
	visible_message("<span class='warning'>[src] bursts into flame!</span>")
	qdel(src)

// Alloy, for the vetus speculator, or abductors I guess.

/obj/item/clothing/accessory/medal/alloy
	name = "alloy medal"
	desc = "An eccentric medal made of some strange alloy."
	icon_state = "alloy"
	materials = list(MAT_METAL = 500, MAT_PLASMA = 500)

// Mostly mining medals past here

/obj/item/clothing/accessory/medal/gold/bubblegum
	name = "bubblegum HRD-MDE award"
	desc = "An award which represents magnificant contributions to the HRD-MDE project in the form of analysing Bubblegum, and the related blood space."

/obj/item/clothing/accessory/medal/gold/heroism/hardmode_full //Kill every hardmode boss. In a shift. Good luck.
	name = "medal of incredible dedication"
	desc = "An extremely rare golden medal awarded only by CentComm. This medal was issued for miners who went above and beyond for the HRD-MDE project. Engraved on it is the phrase <i>'mori quam foedari'...</i>"

/obj/item/clothing/accessory/medal/silver/colossus
	name = "colossus HRD-MDE award"
	desc = "An award which represents major contributions to the HRD-MDE project in the form of analysing a colossus."

/obj/item/clothing/accessory/medal/silver/legion
	name = "legion HRD-MDE award"
	desc = "An award which represents major contributions to the HRD-MDE project in the form of analysing the Legion."

/obj/item/clothing/accessory/medal/blood_drunk
	name = "blood drunk HRD-MDE award"
	desc = "A award which represents minor contributions to the HRD-MDE project in the form of analysing the blood drunk miner."

/obj/item/clothing/accessory/medal/plasma/hierophant
	name = "hierophant HRD-MDE award"
	desc = "An award which represents moderate contributions to the HRD-MDE project in the form of analysing the Hierophant."


/obj/item/clothing/accessory/medal/plasma/ash_drake
	name = "ash drake HRD-MDE award"
	desc = "An award which represents moderate contributions to the HRD-MDE project in the form of analysing an ash drake."

/obj/item/clothing/accessory/medal/alloy/vetus
	name = "vetus speculator HRD-MDE award"
	desc = "An award which represents major contributions to the HRD-MDE project in the form of analysing the Vetus Speculator."

/*
	Holobadges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on the badge with a Security-access ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/accessory/holobadge
	name = "holobadge"
	desc = "This glowing blue badge marks the holder as THE LAW."
	icon_state = "holobadge"
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_ACCESSORY
	actions_types = list(/datum/action/item_action/accessory/holobadge)

	var/emagged = FALSE //Emagging removes Sec check.
	var/stored_name = null

/obj/item/clothing/accessory/holobadge/cord
	icon_state = "holobadge-cord"

/obj/item/clothing/accessory/holobadge/detective
	name = "detective holobadge"
	desc = "This glowing yellow badge marks the holder as THE DETECTIVE."
	icon_state = "holobadge_dec"


/obj/item/clothing/accessory/holobadge/attack_self(mob/user)
	. = ..()
	if(.)
		return .

	if(!stored_name)
		to_chat(user, "Waving around a badge before swiping an ID would be pretty pointless.")
		return

	user.visible_message(
		span_userdanger("[user] displays [user.p_their()] Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security."),
		span_userdanger("You display your Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security."),
	)


/obj/item/clothing/accessory/holobadge/attack(mob/living/carbon/human/target, mob/living/user, def_zone, skip_attack_anim = FALSE)
	if(user == target)
		user.visible_message(
			span_userdanger("[user] starts thrusting [src] to [user.p_their()] own face! What a dumbass?"),
			span_userdanger("You start consistently thrusting [src] to your own face. You are the law!"),
		)
	else
		user.visible_message(
			span_userdanger("[user] invades [target]'s personal space, thrusting [src] to [target.p_their()] face insistently!"),
			span_userdanger("You invade [target]'s personal space, thrusting [src] to [target.p_their()] face insistently. You are the law!"),
		)
	return ATTACK_CHAIN_PROCEED_SUCCESS


/obj/item/clothing/accessory/holobadge/attackby(obj/item/I, mob/user, params)
	var/obj/item/card/id/id = I.GetID()
	if(id)
		add_fingerprint(user)
		if(!(ACCESS_SEC_DOORS in id.access) && !emagged)
			to_chat(user, span_warning("The [name] rejects your insufficient access rights."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You imprint your ID details onto the badge."))
		stored_name = id.registered_name
		update_appearance(UPDATE_NAME|UPDATE_DESC)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/clothing/accessory/holobadge/update_name(updates = ALL)
	. = ..()
	name = "[initial(name)][stored_name ? " ([stored_name])" : ""]"


/obj/item/clothing/accessory/holobadge/update_desc(updates = ALL)
	. = ..()
	desc = "[stored_name ? "This glowing blue badge marks [stored_name] as THE LAW." : "[initial(desc)]"]"


/obj/item/clothing/accessory/holobadge/emag_act(mob/user)
	if(emagged)
		if(user)
			to_chat(user, span_warning("[src] is already cracked."))
		return

	emagged = TRUE
	if(user)
		to_chat(user, span_warning("You swipe the card and crack the holobadge security checks."))
	. = ..()


/obj/item/clothing/accessory/holobadge/on_attached(obj/item/clothing/under/new_suit, mob/attacher)
	. = ..()
	if(.)
		has_suit.verbs += /obj/item/clothing/accessory/holobadge/verb/holobadge_verb


/obj/item/clothing/accessory/holobadge/on_removed(mob/detacher)
	. = ..()
	if(.)
		var/obj/item/clothing/under/old_suit = .
		old_suit.verbs -= /obj/item/clothing/accessory/holobadge/verb/holobadge_verb


//For the holobadge hotkey
/obj/item/clothing/accessory/holobadge/verb/holobadge_verb()
	set name = "Holobadge"
	set category = "Object"
	set src in usr
	if(!isliving(usr) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	var/obj/item/clothing/accessory/holobadge/holobadge_ref = null
	if(istype(src, /obj/item/clothing/accessory/holobadge))
		holobadge_ref = src
	else if(istype(src, /obj/item/clothing/under))
		var/obj/item/clothing/under/suit = src
		if(LAZYLEN(suit.accessories))
			holobadge_ref = locate() in suit.accessories

	if(!holobadge_ref)
		to_chat(usr, span_warning("Something is very wrong."))

	if(!holobadge_ref.stored_name)
		to_chat(usr, "Waving around a badge before swiping an ID would be pretty pointless.")
		return

	usr.visible_message(
		span_warning("[usr] displays [usr.p_their()] Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [holobadge_ref.stored_name], NT Security."),
		span_warning("You display your Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [holobadge_ref.stored_name], NT Security."),
	)


///////////
//SCARVES//
///////////

/obj/item/clothing/accessory/scarf // No overlay
	name = "scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/accessory/scarf/red
	name = "red scarf"
	icon_state = "redscarf"

/obj/item/clothing/accessory/scarf/green
	name = "green scarf"
	icon_state = "greenscarf"

/obj/item/clothing/accessory/scarf/darkblue
	name = "dark blue scarf"
	icon_state = "darkbluescarf"

/obj/item/clothing/accessory/scarf/purple
	name = "purple scarf"
	icon_state = "purplescarf"

/obj/item/clothing/accessory/scarf/yellow
	name = "yellow scarf"
	icon_state = "yellowscarf"

/obj/item/clothing/accessory/scarf/orange
	name = "orange scarf"
	icon_state = "orangescarf"

/obj/item/clothing/accessory/scarf/lightblue
	name = "light blue scarf"
	icon_state = "lightbluescarf"

/obj/item/clothing/accessory/scarf/white
	name = "white scarf"
	icon_state = "whitescarf"

/obj/item/clothing/accessory/scarf/black
	name = "black scarf"
	icon_state = "blackscarf"

/obj/item/clothing/accessory/scarf/zebra
	name = "zebra scarf"
	icon_state = "zebrascarf"

/obj/item/clothing/accessory/scarf/christmas
	name = "christmas scarf"
	icon_state = "christmasscarf"

//The three following scarves don't have the scarf subtype
//This is because Ian can equip anything from that subtype
//However, these 3 don't have corgi versions of their sprites
/obj/item/clothing/accessory/stripedredscarf
	name = "striped red scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	icon_state = "stripedredscarf"

/obj/item/clothing/accessory/stripedgreenscarf
	name = "striped green scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	icon_state = "stripedgreenscarf"

/obj/item/clothing/accessory/stripedbluescarf
	name = "striped blue scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	icon_state = "stripedbluescarf"

//Necklaces
/obj/item/clothing/accessory/necklace
	name = "necklace"
	desc = "A simple necklace."
	icon_state = "necklace"
	item_state = "necklace"

/obj/item/clothing/accessory/necklace/dope
	name = "gold necklace"
	desc = "Damn, it feels good to be a gangster."
	icon_state = "bling"
	item_state = "bling"

/obj/item/clothing/accessory/necklace/skullcodpiece
	name = "skull codpiece"
	desc = "A skull shaped ornament, intended to protect the important things in life."
	icon_state = "skull"
	item_state = "skull"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 20, "bio" = 20, "rad" = 5, "fire" = 0, "acid" = 25)
	allow_duplicates = FALSE

/obj/item/clothing/accessory/necklace/talisman
	name = "bone talisman"
	desc = "A hunter's talisman, some say the old gods smile on those who wear it."
	icon_state = "talisman"
	item_state = "talisman"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 20, "bio" = 20, "rad" = 5, "fire" = 0, "acid" = 25)
	allow_duplicates = FALSE

/obj/item/clothing/accessory/necklace/locket
	name = "gold locket"
	desc = "A gold locket that seems to have space for a photo within."
	icon_state = "locket"
	item_state = "locket"
	/// Item inside locket.
	var/obj/item/held_item


/obj/item/clothing/accessory/necklace/locket/Destroy()
	QDEL_NULL(held_item)
	return ..()


/obj/item/clothing/accessory/necklace/locket/attack_self(mob/user)
	. = ..()
	if(.)
		return .

	up = !up
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_notice("You flip [src] [up ? "open": "closed"][held_item ? " and [held_item] falls out!" : "."]"))
	if(up && held_item)
		held_item.forceMove(drop_location())
		held_item = null


/obj/item/clothing/accessory/necklace/locket/update_icon_state()
	icon_state = "[replacetext("[icon_state]", "_open", "")][up ? "_open" : ""]"


/obj/item/clothing/accessory/necklace/locket/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo))
		add_fingerprint(user)
		if(!up)
			to_chat(user, span_warning("You have to open [src] first."))
			return ATTACK_CHAIN_PROCEED
		if(held_item)
			to_chat(user, span_warning("The [name] already has something inside it."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		held_item = I
		to_chat(user, span_notice("You slip [I] into [src]."))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/clothing/accessory/ntrjacket
	name = "black light jacket"
	desc = "For the formidable guardians of work procedures. Looks like it can clip on to a uniform."
	icon_state = "jacket_ntrf"
	item_state = "jacket_ntrf"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

//Cowboy Shirts
/obj/item/clothing/accessory/cowboyshirt
	name = "black cowboy shirt"
	desc = "For a real western look. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt"
	item_state = "cowboyshirt"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/short_sleeved
	name = "shortsleeved black cowboy shirt"
	desc = "For when it's a hot day in the west. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_s"
	item_state = "cowboyshirt_s"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/white
	name = "white cowboy shirt"
	desc = "For the rancher in us all. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_white"
	item_state = "cowboyshirt_white"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/white/short_sleeved
	name = "short sleeved white cowboy shirt"
	desc = "Best for midday cattle tending. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_whites"
	item_state = "cowboyshirt_whites"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/pink
	name = "pink cowboy shirt"
	desc = "For only the manliest of men, or girliest of girls. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_pink"
	item_state = "cowboyshirt_pink"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/pink/short_sleeved
	name = "short sleeved pink cowboy shirt"
	desc = "For a real buckle bunny. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_pinks"
	item_state = "cowboyshirt_pinks"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/navy
	name = "navy cowboy shirt"
	desc = "Now yer a real cowboy. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_navy"
	item_state = "cowboyshirt_navy"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/navy/short_sleeved
	name = "short sleeved navy cowboy shirt"
	desc = "Sometimes ya need to roll up your sleeves. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_navys"
	item_state = "cowboyshirt_navys"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/red
	name = "red cowboy shirt"
	desc = "It's high noon. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_red"
	item_state = "cowboyshirt_red"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/red/short_sleeved
	name = "short sleeved red cowboy shirt"
	desc = "Life on the open range is quite dangeorus, you never know what to expect. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_reds"
	item_state = "cowboyshirt_reds"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/accessory/corset
	name = "black corset"
	desc = "A black corset for those fancy nights out."
	icon_state = "corset"
	item_state = "corset"


/obj/item/clothing/accessory/corset/red
	name = "red corset"
	desc = "A red corset those fancy nights out."
	icon_state = "corset_red"
	item_state = "corset_red"

/obj/item/clothing/accessory/corset/blue
	name = "blue corset"
	desc = "A blue corset for those fancy nights out."
	icon_state = "corset_blue"
	item_state = "corset_blue"

/obj/item/clothing/accessory/petcollar
	name = "pet collar"
	desc = "The latest fashion accessory for your favorite pets!"
	icon_state = "petcollar"
	actions_types = list(/datum/action/item_action/accessory/petcollar)
	var/tagname = null
	var/obj/item/card/id/access_id


/obj/item/clothing/accessory/petcollar/Destroy()
	QDEL_NULL(access_id)
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/clothing/accessory/petcollar/proc/remove_id(mob/living/user)
	if(access_id)
		to_chat(user, span_notice("You unclip \the [access_id] from \the [src]."))
		access_id.forceMove(get_turf(user))
		user.put_in_hands(access_id)
		access_id = null
		return
	to_chat(user, span_notice("There is no ID card in \the [src]."))


/obj/item/clothing/accessory/petcollar/attack_self(mob/user)
	. = ..()
	if(.)
		return .
	remove_id(user)


/obj/item/clothing/accessory/petcollar/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		if(istype(loc, /obj/item/clothing/under))
			return ..()
		var/new_tag = tgui_input_text(user, "Would you like to change the name on the tag?", "Name your new pet", tagname ? tagname : "Spot", MAX_NAME_LEN)
		if(!isnull(new_tag))
			update_appearance(UPDATE_NAME)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/card/id))
		add_fingerprint(user)
		if(access_id)
			to_chat(user, span_notice("There is already [access_id] clipped onto [src]."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		access_id = I
		to_chat(user, span_notice("The [I.name] clips onto [src] snugly."))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/clothing/accessory/petcollar/update_name(updates = ALL)
	. = ..()
	name = "[initial(name)][tagname ? " - [tagname]" : ""]"


/obj/item/clothing/accessory/petcollar/GetAccess()
	return access_id ? access_id.GetAccess() : ..()


/obj/item/clothing/accessory/petcollar/GetID()
	return access_id ? access_id : ..()


/obj/item/clothing/accessory/petcollar/examine(mob/user)
	. = ..()
	if(access_id)
		. += span_notice("There is [bicon(access_id)] \a [access_id] clipped onto it.")


/obj/item/clothing/accessory/petcollar/equipped(mob/living/simple_animal/user, slot, initial = FALSE)
	. = ..()

	if(istype(user))
		START_PROCESSING(SSobj, src)


/obj/item/clothing/accessory/petcollar/dropped(mob/living/simple_animal/user, slot, silent = FALSE)
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clothing/accessory/petcollar/process()
	var/mob/living/simple_animal/M = loc
	// if it wasn't intentionally unequipped but isn't being worn, possibly gibbed
	if(istype(M) && src == M.pcollar && M.stat != DEAD)
		return
	var/announce_channel = "Common"			// Channel toggler for mobs, who dies in specific locations.
	var/area/t = get_area(M)
	var/obj/item/radio/headset/all_channels/a = new /obj/item/radio/headset/all_channels(src)
	if(M.z == level_name_to_num(RAMSS_TAIPAN))
		announce_channel = "SyndTaipan"		// Taipan channel for Руж.
	else if(istype(t, /area/centcom))
		announce_channel = "Response Team"	// For animals who dare to infiltrate CC.
	else if(istype(t, /area/syndicate_mothership) || istype(t, /area/shuttle/syndicate_elite) || istype(t, /area/shuttle/syndicate_sit))
		announce_channel = "SyndTeam"		// Just to be sure ...
	else if(istype(t, /area/ninja))
		announce_channel = "Spider Clan"	// Even ninja may have a little pet.
	else if(istype(t, /area/ussp_centcom))
		announce_channel = "Soviet"			// MISHA, FU!
	else if((M.z == level_name_to_num(CENTCOMM) || z == level_name_to_num(ADMIN_ZONE)) && SSticker.current_state != GAME_STATE_FINISHED)
		a.autosay("[M] has been vandalized in Space!", "[M]'s Death Alarm")	// For the rest of CC map locations like Abductors UFO, Vox home or TSF home.
		qdel(a)
		STOP_PROCESSING(SSobj, src)
		return
	a.autosay("[M] has been vandalized in [t.name]!", "[M]'s Death Alarm", announce_channel)
	qdel(a)
	STOP_PROCESSING(SSobj, src)


/proc/english_accessory_list(obj/item/clothing/under/uniform)
	if(!istype(uniform) || !LAZYLEN(uniform.accessories))
		return
	var/list/A = uniform.accessories
	var/total = A.len
	if(total == 1)
		return "\a [A[1]]"
	else if(total == 2)
		return "\a [A[1]] and \a [A[2]]"
	else
		var/output = ""
		var/index = 1
		var/comma_text = ", "
		while(index < total)
			output += "\a [A[index]][comma_text]"
			index++

		return "[output]and \a [A[index]]"

/obj/item/clothing/accessory/head_strip
	name = "captain's strip"
	desc = "Плотно сшитая круглая нашивка из синего бархата с позолотой, по центру красуется логотип корпорации Nanotrasen прошитый золотыми металлическими нитями. Награда выданная центральным командованием за выдающиеся управление станцией."
	icon_state = "capstrip"
	item_state = "capstrip"
	var/strip_bubble_icon = "CAP"
	var/cached_bubble_icon = null


/obj/item/clothing/accessory/head_strip/attack_self(mob/user)
	. = ..()
	if(.)
		return .
	fluff_attack_self_action(user)


/obj/item/clothing/accessory/head_strip/proc/fluff_attack_self_action(mob/user)
	user.visible_message(
		span_notice("[user] shows [user.p_their()] [name]."),
		span_notice("You show your [name]."),
	)


/obj/item/clothing/accessory/head_strip/uniform_check(mob/living/carbon/human/target, mob/living/user, obj/item/clothing/under/uniform)
	. = ..()
	if(. && locate(/obj/item/clothing/accessory/head_strip, uniform.contents))
		to_chat(user, span_warning("You can have only one strip attached to this uniform!"))
		return FALSE


/obj/item/clothing/accessory/head_strip/on_attached(obj/item/clothing/under/new_suit, mob/attacher)
	. = ..()
	if(. && ismob(has_suit.loc))
		var/mob/wearer = has_suit.loc
		cached_bubble_icon = wearer.bubble_icon
		wearer.bubble_icon = strip_bubble_icon


/obj/item/clothing/accessory/head_strip/on_removed(mob/detacher)
	. = ..()
	if(.)
		var/obj/item/clothing/under/old_suit = .
		if(ismob(old_suit.loc))
			var/mob/wearer = old_suit.loc
			wearer.bubble_icon = cached_bubble_icon


/obj/item/clothing/accessory/head_strip/rd
	name = "Research Director's strip"
	desc = "Плотно сшитая круглая нашивка из фиолетового бархата, по центру красуется логотип корпорации Nanotrasen прошитый розоватыми металлическими нитями. Награда выданная центральным командованием за выдающиеся успехи в области исследований."
	icon_state = "rdstrip"
	item_state = "rdstrip"
	strip_bubble_icon = "RD"

/obj/item/clothing/accessory/head_strip/ce
	name = "Chief Engineer's strip"
	desc = "Плотно сшитая круглая нашивка из серо-желтого бархата, по центру красуется логотип корпорации Nanotrasen прошитый голубыми металлическими нитями. Награда выданная центральным командованием за выдающиеся успехи в области инженерии."
	icon_state = "cestrip"
	item_state = "cestrip"
	strip_bubble_icon = "CE"

/obj/item/clothing/accessory/head_strip/t4ce
	name = "Grand Chief Engineer's strip"
	desc = "Плотно сшитая круглая нашивка из серого бархата, по центру красуется логотип корпорации Nanotrasen прошитый желтыми металлическими нитями. Если присмотреться, можно заметить проходящее по нитям электричество и небольшие искорки."
	icon_state = "t4cestrip"
	item_state = "t4cestrip"
	strip_bubble_icon = "T4CE"

/obj/item/clothing/accessory/head_strip/cmo
	name = "Chief Medical Officer's strip"
	desc = "Плотно сшитая круглая нашивка из голубого бархата, по центру красуется логотип корпорации Nanotrasen прошитый белыми металлическими нитями. Награда выданная центральным командованием за выдающиеся успехи в области медицины."
	icon_state = "cmostrip"
	item_state = "cmostrip"
	strip_bubble_icon = "CMO"

/obj/item/clothing/accessory/head_strip/hop
	name = "Head of Personnel's strip"
	desc = "Плотно сшитая круглая нашивка из синего бархата с красной окантовкой, по центру красуется логотип корпорации Nanotrasen прошитый белыми металлическими нитями. Награда выданная центральным командованием за выдающиеся управление персоналом."
	icon_state = "hopstrip"
	item_state = "hopstrip"
	strip_bubble_icon = "HOP"

/obj/item/clothing/accessory/head_strip/hos
	name = "Head of Security's strip"
	desc = "Плотно сшитая круглая нашивка из черно-красного бархата, по центру красуется логотип корпорации Nanotrasen прошитый бело-красными металлическими нитями. Награда выданная центральным командованием за выдающиеся успехи при службе на корпорацию. "
	icon_state = "hosstrip"
	item_state = "hosstrip"
	strip_bubble_icon = "HOS"

/obj/item/clothing/accessory/head_strip/qm
	name = "Quatermaster's strip"
	desc = "Плотно сшитая круглая нашивка из коричневого бархата, по центру красуется логотип корпорации Nanotrasen прошитый белыми металлическими нитями. Награда выданная центральным командованием за выдающиеся успехи в области логистики и погрузки."
	icon_state = "qmstrip"
	item_state = "qmstrip"
	strip_bubble_icon = "QM"

/obj/item/clothing/accessory/head_strip/bs
	name = "Blueshield's strip"
	desc = "Плотно сшитая круглая нашивка из синего бархата с темно-синей окантовкой, по центру красуется логотип корпорации Nanotrasen прошитый белыми металлическими нитями. Награда выданная центральным командованием за выдающиеся успехи при службе на корпорацию."
	icon_state = "bsstrip"
	item_state = "bsstrip"
	strip_bubble_icon = "BS"

/obj/item/clothing/accessory/head_strip/ntr
	name = "NanoTrasen Representative's strip"
	desc = "Плотно сшитая круглая нашивка из чёрного бархата с золотистой окантовкой, по центру красуется логотип корпорации Nanotrasen прошитый белыми металлическими нитями. Награда выданная центральным командованием за выдающиеся заслуги при службе на корпорацию."
	icon_state = "ntrstrip"
	item_state = "ntrstrip"
	strip_bubble_icon = "NTR"

/obj/item/clothing/accessory/head_strip/lawyers_badge
	name = "attorney's badge"
	desc = "Fills you with the conviction of JUSTICE. Lawyers tend to want to show it to everyone they meet."
	icon_state = "lawyerbadge"
	item_state = "lawyerbadge"
	strip_bubble_icon = "lawyer"


/obj/item/clothing/accessory/head_strip/lawyers_badge/fluff_attack_self_action(mob/user)
	if(prob(1))
		user.say("The testimony contradicts the evidence!")


/obj/item/clothing/accessory/head_strip/cheese_badge
	name = "great fellow's badge"
	desc = "Плотно сшитая круглая нашивка из желто-оранжевого бархата, по центру красуется то ли корона, то ли головка сыра. Слегка отдает запахом Монтерей Джека."
	icon_state = "cheesebadge"
	item_state = "cheesebadge"
	strip_bubble_icon = "cheese"

/obj/item/clothing/accessory/head_strip/cheese_badge/fluff_attack_self_action(mob/user)
	if(prob(1))
		user.say("CHEE-EE-EE-EE-EE-EESE!")

/obj/item/clothing/accessory/head_strip/clown
	name = "clown's strip"
	desc = "Плотно сшитая круглая нашивка с изображением клоуна. Идеально подойдет для совершения военных преступлений, ведь это не военное преступление, если тебе было весело!"
	icon_state = "clownstrip"
	item_state = "clownstrip"
	strip_bubble_icon = "clown"

/obj/item/clothing/accessory/medal/smile
	name = "smiling pin"
	desc = "Позолоченный значок с улыбающейся рожецей. Символ невиданной гордости самим собой!"
	icon_state = "smile"
	materials = list(MAT_METAL = 300, MAT_GOLD = 200)
	w_class = WEIGHT_CLASS_TINY


/obj/item/clothing/accessory/medal/smile/attack_self(mob/user)
	. = ..()
	if(.)
		return .
	if(prob(5))
		user.emote("smile")


/obj/item/clothing/accessory/medal/smile/examine(mob/user)
	. = ..()
	user.emote("smile")

