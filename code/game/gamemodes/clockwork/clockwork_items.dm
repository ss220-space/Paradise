/obj/item/clockwork
	name = "clockwork item name"
	icon = 'icons/obj/clockwork.dmi'
	resistance_flags = FIRE_PROOF | ACID_PROOF

// A Clockwork slab. Ratvar's tool to cast most of essential spells.
/obj/item/clockwork/clockslab
	name = "clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "clock_slab"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clockwork/clockslab/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/spell_enchant, GLOB.clockslab_spells)

//Ratvarian spear
/obj/item/twohanded/ratvarian_spear
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "ratvarian_spear0"
	slot_flags = SLOT_BACK
	force = 10
	force_unwielded = 10
	force_wielded = 20
	throwforce = 35
	armour_penetration = 40
	sharp = TRUE
	embed_chance = 70
	embedded_ignore_throwspeed_threshold = TRUE
	attack_verb = list("stabbed", "poked", "slashed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_HUGE
	needs_permit = TRUE

/obj/item/twohanded/ratvarian_spear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/spell_enchant, GLOB.spear_spells)

/obj/item/twohanded/ratvarian_spear/update_icon_state()
	icon_state = "ratvarian_spear[HAS_TRAIT(src, TRAIT_WIELDED)]"

/obj/item/twohanded/ratvarian_spear/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/living = hit_atom
	if(isclocker(living))
		if(ishuman(living) && !living.restrained() && living.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			living.visible_message(span_warning("[living] catches [src] out of the air!"))
		else
			do_sparks(5, TRUE, living)
			living.visible_message(span_warning("[src] bounces off of [living], as if repelled by an unseen force!"))
		return
	. = ..()

/obj/item/twohanded/ratvarian_spear/attack(mob/living/M, mob/living/user, def_zone)
	if(!isclocker(user))
		user.emote("scream")
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			human.embed_item_inside(src)
			to_chat(user, span_clocklarge("\"How does it feel it now?\""))
		else
			user.drop_item_ground(src)
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
		return
	. = ..()

/obj/item/twohanded/ratvarian_spear/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity || !wielded || !isliving(target) || isclocker(target))
		return
	return ..()

/obj/item/twohanded/ratvarian_spear/pickup(mob/living/user)
	. = ..()
	if(!isclocker(user))
		to_chat(user, span_clocklarge("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.Confused(20 SECONDS)
		user.Jitter(12 SECONDS)

//Ratvarian borg spear
/obj/item/clock_borg_spear
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "ratvarian_spear0"
	force = 20
	armour_penetration = 30
	sharp = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/clock_borg_spear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/spell_enchant, GLOB.spear_spells)

/obj/item/clock_borg_spear/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity || !isliving(target) || isclocker(target))
		return
	return ..()

//Clock hammer
/obj/item/twohanded/clock_hammer
	name = "hammer clock"
	desc = "A heavy hammer of an elder god. Used to shine like in past times."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clock_hammer0"
	slot_flags = SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 20
	armour_penetration = 40
	throwforce = 30
	throw_range = 7
	w_class = WEIGHT_CLASS_HUGE
	needs_permit = TRUE

/obj/item/twohanded/clock_hammer/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/spell_enchant, GLOB.hammer_spells)

/obj/item/twohanded/clock_hammer/update_icon_state()
	icon_state = "clock_hammer[HAS_TRAIT(src, TRAIT_WIELDED)]"

/obj/item/twohanded/clock_hammer/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/living = hit_atom
	if(isclocker(living))
		if(ishuman(living) && !living.restrained() && living.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			living.visible_message(span_warning("[living] catches [src] out of the air!"))
		else
			do_sparks(5, TRUE, living)
			living.visible_message(span_warning("[src] bounces off of [living], as if repelled by an unseen force!"))
		return
	. = ..()

/obj/item/twohanded/clock_hammer/attack(mob/living/M, mob/living/user, def_zone)
	if(!isclocker(user))
		user.Weaken(10 SECONDS)
		user.drop_item_ground(src, force = TRUE)
		user.emote("scream")
		user.visible_message(span_warning("A powerful force shoves [user] away from [M]!"), span_clocklarge("\"Don't hit yourself.\""))

		var/wforce = rand(force_unwielded, force_wielded)
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			human.apply_damage(wforce, BRUTE, BODY_ZONE_HEAD)
		else
			user.adjustBruteLoss(wforce)
		return
	. = ..()

/obj/item/twohanded/clock_hammer/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity || !wielded || !isliving(target) || isclocker(target))
		return
	return ..()

/obj/item/twohanded/clock_hammer/pickup(mob/living/user)
	. = ..()
	if(!isclocker(user))
		to_chat(user, span_clocklarge("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.Confused(20 SECONDS)
		user.Jitter(12 SECONDS)

//Clock sword
/obj/item/melee/clock_sword
	name = "rustless sword"
	desc = "A simplish sword that barely made for fighting, but still has some powders to give."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clock_sword"
	item_state = "clock_sword"
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 20
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration = 10
	sharp = TRUE
	attack_verb = list("lunged at", "stabbed")
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/melee/clock_sword/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/spell_enchant, GLOB.sword_spells)

/obj/item/melee/clock_sword/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/living = hit_atom
	if(isclocker(living))
		if(ishuman(living) && !living.restrained() && living.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			living.visible_message(span_warning("[living] catches [src] out of the air!"))
		else
			do_sparks(5, TRUE, living)
			living.visible_message(span_warning("[src] bounces off of [living], as if repelled by an unseen force!"))
		return
	. = ..()

/obj/item/melee/clock_sword/attack(mob/living/M, mob/living/user, def_zone)
	if(!isclocker(user))
		user.emote("scream")
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			human.embed_item_inside(src)
			to_chat(user, span_clocklarge("\"How does it feel it now?\""))
		else
			user.drop_item_ground(src)
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
		return
	. = ..()

/obj/item/melee/clock_sword/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag || !isliving(target) || isclocker(target))
		return
	return ..()

/obj/item/melee/clock_sword/pickup(mob/living/user)
	. = ..()
	if(!isclocker(user))
		to_chat(user, span_clocklarge("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.Confused(20 SECONDS)
		user.Jitter(12 SECONDS)

//Buckler
/obj/item/shield/clock_buckler
	name = "brass buckler"
	desc = "Small shield that protects on arm only. But with the right use it can protect a full body."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "brass_buckler"
	item_state = "brass_buckler"
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 3
	attack_verb = list("bumped", "prodded", "shoved", "bashed")
	hitsound = 'sound/weapons/smash.ogg'
	block_chance = 30

/obj/item/shield/clock_buckler/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/spell_enchant, GLOB.shield_spells)

/obj/item/shield/clock_buckler/equipped(mob/living/user, slot, initial)
	. = ..()
	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
			user.visible_message(span_warning("As [user] picks [src] up, it flickers off their arms!"), span_warning("The buckler flicker off your arms, leaving only nausea!"))
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Weaken(10 SECONDS)
		else
			to_chat(user, span_clocklarge("\"Did you like having head?\""))
			to_chat(user, span_userdanger("The buckler suddenly hits you in the head!"))
			user.emote("scream")
			user.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
		user.drop_item_ground(src)

// Clockwork robe. Basic robe from clockwork slab.
/obj/item/clothing/suit/hooded/clockrobe
	name = "clock robes"
	desc = "A set of robes worn by the followers of a clockwork cult."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_robe"
	item_state = "clockwork_robe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/clockhood
	allowed = list(/obj/item/clockwork, /obj/item/twohanded/ratvarian_spear, /obj/item/twohanded/clock_hammer, /obj/item/melee/clock_sword)
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDEJUMPSUIT
	magical = TRUE
	sprite_sheets = list(
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Ash Walker" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Ash Walker Shaman" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Draconid" = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/suit/hooded/clockrobe_fake
	name = "clock robes"
	desc = "A set of robes worn by the followers of a clockwork cult. But now its just a good armour."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_robe"
	item_state = "clockwork_robe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/clockhood_fake
	allowed = list(/obj/item/flashlight, /obj/item/tank, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe) // some miners stuff
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDEJUMPSUIT
	magical = TRUE
	sprite_sheets = list(
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/suit/hooded/clockrobe/can_store_weighted()
	return TRUE

/obj/item/clothing/suit/hooded/clockrobe/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/spell_enchant, GLOB.robe_spells)

/obj/item/clothing/head/hooded/clockhood
	name = "clock hood"
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockhood"
	item_state = "clockhood"
	desc = "A hood worn by the followers of ratvar."
	flags = BLOCKHAIR
	flags_inv = HIDENAME
	flags_cover = HEADCOVERSEYES
	armor = list("melee" = 30, "bullet" = 10, "laser" = 5, "energy" = 5, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 10)
	magical = TRUE

/obj/item/clothing/head/hooded/clockhood_fake
	name = "clock hood"
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockhood"
	item_state = "clockhood"
	desc = "A hood worn by the followers of ratvar. but now its just a simple hood."
	flags = BLOCKHAIR
	flags_inv = HIDENAME
	flags_cover = HEADCOVERSEYES
	armor = list("melee" = 30, "bullet" = 10, "laser" = 5, "energy" = 5, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 10)
	magical = TRUE

/obj/item/clothing/suit/hooded/clockrobe/equipped(mob/living/user, slot, initial)
	. = ..()

	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
			user.visible_message(span_warning("As [user] picks [src] up, it flickers off their arms!"), span_warning("The robe flicker off your arms, leaving only nausea!"))
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Weaken(10 SECONDS)
		else
			to_chat(user, span_clocklarge("\"I think this armor is too hot for you to handle.\""))
			user.emote("scream")
			user.apply_damage(7, BURN, BODY_ZONE_CHEST)
			user.IgniteMob()
		user.drop_item_ground(src)

// Clockwork Armour. Basically greater robe with more and better spells.
/obj/item/clothing/suit/armor/clockwork
	name = "clockwork cuirass"
	desc = "A bulky cuirass made of brass."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_cuirass"
	item_state = "clockwork_cuirass"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 50, "bullet" = 40, "laser" = 50, "energy" = 30, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	flags_inv = HIDEJUMPSUIT
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/clockwork, /obj/item/twohanded/ratvarian_spear, /obj/item/twohanded/clock_hammer, /obj/item/melee/clock_sword)
	hide_tail_by_species = list("Vulpkanin")
	sprite_sheets = list(
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		"Ash Walker" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Ash Walker Shaman" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Draconid" = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/suit/armor/clockwork_fake
	name = "clockwork cuirass"
	desc = "A bulky cuirass made of brass. This looks tarnished."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_cuirass"
	item_state = "clockwork_cuirass"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF | ACID_PROOF
	allowed = list(/obj/item/flashlight, /obj/item/tank, /obj/item/resonator,
		/obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator,
		/obj/item/pickaxe, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe,
		/obj/item/clockwork, /obj/item/twohanded/ratvarian_spear, /obj/item/twohanded/clock_hammer, /obj/item/melee/clock_sword)
	flags_inv = HIDEJUMPSUIT
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	sprite_sheets = list(
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/suit/armor/clockwork/can_store_weighted()
	return TRUE

/obj/item/clothing/suit/armor/clockwork/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/spell_enchant, GLOB.armour_spells)

/obj/item/clothing/suit/armor/clockwork/IsReflect(def_zone)
	if(!ishuman(loc))
		return FALSE
	var/mob/living/carbon/human/owner = loc
	if(SEND_SIGNAL(src, COMSIG_CLOCK_ARMOR_REFLECT, owner))
		return TRUE
	return FALSE

/obj/item/clothing/suit/armor/clockwork/equipped(mob/living/user, slot, initial)
	. = ..()

	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
			user.visible_message(span_warning("As [user] puts [src] on, it flickers off their body!"), span_warning("The curiass flickers off your body, leaving only nausea!"))
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20)
				C.Weaken(10 SECONDS)
		else
			to_chat(user, span_clocklarge("\"I think this armor is too hot for you to handle.\""))
			user.emote("scream")
			user.apply_damage(15, BURN, BODY_ZONE_CHEST)
			user.adjust_fire_stacks(2)
			user.IgniteMob()
		user.drop_item_ground(src)

// Gloves
/obj/item/clothing/gloves/clockwork
	name = "clockwork gauntlets"
	desc = "Heavy, fire-resistant gauntlets with brass reinforcement."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_gauntlets"
	item_state = "clockwork_gauntlets"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 40, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	var/north_star = FALSE
	var/fire_casting = FALSE

/obj/item/clothing/gloves/clockwork_fake
	name = "clockwork gauntlets"
	desc = "Heavy, fire-resistant gauntlets with brass reinforcement. Even without magic an excellent gloves."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_gauntlets"
	item_state = "clockwork_gauntlets"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 40, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)

/obj/item/clothing/gloves/clockwork/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/spell_enchant, GLOB.gloves_spell)

/obj/item/clothing/gloves/clockwork/equipped(mob/living/user, slot, initial)
	. = ..()

	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
			user.visible_message(span_warning("As [user] puts [src] on, it flickers off their arms!"), span_warning("The gauntlets flicker off your arms, leaving only nausea!"))
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Weaken(10 SECONDS)
		else
			to_chat(user, span_clocklarge("\"Did you like having arms?\""))
			to_chat(user, span_userdanger("The gauntlets suddenly squeeze tight, crushing your arms before you manage to get them off!"))
			user.emote("scream")
			user.apply_damage(7, BRUTE, BODY_ZONE_L_ARM)
			user.apply_damage(7, BRUTE, BODY_ZONE_R_ARM)
		user.drop_item_ground(src)

// Shoes
/obj/item/clothing/shoes/clockwork
	name = "clockwork treads"
	desc = "Industrial boots made of brass. They're very heavy."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_treads"
	item_state = "clockwork_treads"
	strip_delay = 60
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 40, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)

/obj/item/clothing/shoes/clockwork_fake
	name = "clockwork treads"
	desc = "Industrial boots made of brass. They're very heavy, and magic can't deny it."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_treads"
	item_state = "clockwork_treads"
	strip_delay = 60
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 40, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)

/obj/item/clothing/shoes/clockwork/equipped(mob/living/user, slot, initial)
	. = ..()

	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
			user.visible_message(span_warning("As [user] puts [src] on, it flickers off their feet!"), span_warning("The treads flicker off your feet, leaving only nausea!"))
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Weaken(10 SECONDS)
		else
			to_chat(user, span_clocklarge("\"Let's see if you can dance with these.\""))
			to_chat(user, span_userdanger("The treads turn searing hot as you scramble to get them off!"))
			user.emote("scream")
			user.apply_damage(7, BURN, BODY_ZONE_L_LEG)
			user.apply_damage(7, BURN, BODY_ZONE_R_LEG)
		user.drop_item_ground(src)

// Helmet
/obj/item/clothing/head/helmet/clockwork
	name = "clockwork helmet"
	desc = "A heavy helmet made of brass."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_helmet"
	item_state = "clockwork_helmet"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDENAME
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES
	armor = list(melee = 45, bullet = 65, laser = 10, energy = 0, bomb = 60, bio = 0, rad = 0, fire = 100, acid = 100)
	sprite_sheets = list(
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/helmet.dmi'
		)

/obj/item/clothing/head/helmet/clockwork_fake
	name = "clockwork helmet"
	desc = "A heavy helmet made of brass."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_helmet"
	item_state = "clockwork_helmet"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDENAME
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES
	armor = list(melee = 45, bullet = 65, laser = 10, energy = 0, bomb = 60, bio = 0, rad = 0, fire = 100, acid = 100)

/obj/item/clothing/head/helmet/clockwork/equipped(mob/living/user, slot, initial)
	. = ..()

	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
			user.visible_message(span_warning("As [user] puts [src] on, it flickers off their head!"), span_warning("The helmet flickers off your head, leaving only nausea!"))
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20)
				C.Weaken(10 SECONDS)
		else
			to_chat(user, span_heavybrass("\"Do you have a hole in your head? You're about to have.\""))
			to_chat(user, span_userdanger("The helmet tries to drive a spike through your head as you scramble to remove it!"))
			user.emote("scream")
			user.apply_damage(30, BRUTE, BODY_ZONE_HEAD)
			user.adjustBrainLoss(30)
		user.drop_item_ground(src)

// Glasses
/obj/item/clothing/glasses/clockwork
	name = "judicial visor"
	desc = "A strange purple-lensed visor. Looking at it inspires an odd sense of guilt."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "judicial_visor_0"
	item_state = "sunglasses"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/active = FALSE //If the visor is online
	actions_types = list(/datum/action/item_action/toggle)
	flash_protect = TRUE
	see_in_dark = 0
	lighting_alpha = null

/obj/item/clothing/glasses/clockwork/equipped(mob/living/user, slot, initial)
	. = ..()

	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, span_clocklarge("\"I think you need some different glasses. This too bright for you.\""))
			user.flash_eyes()
			user.Weaken(2 SECONDS)
			playsound(loc, 'sound/weapons/flash.ogg', 50, TRUE)
		else
			to_chat(user, span_clocklarge("\"Consider yourself judged, whelp.\""))
			to_chat(user, span_userdanger("You suddenly catch fire!"))
			user.adjust_fire_stacks(5)
			user.IgniteMob()
		user.drop_item_ground(src)

/obj/item/clothing/glasses/clockwork/attack_self(mob/user)
	if(!isclocker(user))
		to_chat(user, span_warning("You fiddle around with [src], to no avail."))
		return
	active = !active

	icon_state = "judicial_visor_[active]"
	flash_protect = !active
	see_in_dark = active ? 8 : 0
	lighting_alpha = active ? LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE : null
	switch(active)
		if(TRUE)
			to_chat(user, span_notice("You toggle [src], its lens begins to glow."))
		if(FALSE)
			to_chat(user, span_notice("You toggle [src], its lens darkens once more."))

	user.update_action_buttons_icon()
	user.update_inv_glasses()
	user.update_sight()

/*
 * Consumables.
 */

//Intergration Cog. Can be used on an open APC to replace its guts with clockwork variants, and begin passively siphoning power from it
/obj/item/clockwork/integration_cog
	name = "integration cog"
	desc = "A small cogwheel that fits in the palm of your hand."
	icon_state = "gear"
	w_class = WEIGHT_CLASS_TINY

/obj/item/clockwork/integration_cog/Initialize()
	. = ..()
	transform *= 0.5 //little cog!

/obj/machinery/integration_cog
	name = "integration cog"
	desc = "You shouldn't see that! Call dev on that!"
	icon = null
	anchored = TRUE
	active_power_usage = 100 // In summary it costs 500 power. Most areas costs around 800, with top being medbay at around 8000. Fair number.
	var/obj/machinery/power/apc/apc
	var/next_whoosh = 120

/obj/machinery/integration_cog/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/machinery/power/apc))
		apc = loc
	else
		log_runtime(EXCEPTION("Invalid location for Integration cog"))

/obj/machinery/integration_cog/emp_act(severity)
	return

/obj/machinery/integration_cog/process(seconds_per_tick)
	if(apc.cell?.charge > 0 && apc.operating)
		adjust_clockwork_power(CLOCK_POWER_COG * seconds_per_tick)
		if(next_whoosh <= 0)
			playsound(apc, 'sound/machines/clockcult/steam_whoosh.ogg', 5, TRUE, SILENCED_SOUND_EXTRARANGE)
			new/obj/effect/temp_visual/small_smoke(get_turf(apc))
			next_whoosh = 60 + rand(60) // 1-2 minutes
		next_whoosh -= seconds_per_tick
		return TRUE
	return FALSE

/obj/machinery/integration_cog/auto_use_power()
	if(powered(EQUIP))
		use_power(active_power_usage, EQUIP)
	if(powered(LIGHT))
		use_power(active_power_usage, LIGHT)
	if(powered(ENVIRON))
		use_power(active_power_usage, ENVIRON)
	use_power(200)
	adjust_clockwork_power(CLOCK_POWER_COG)
	return 1

//Clockwork module
/obj/item/borg/upgrade/clockwork
	name = "Clockwork Module"
	desc = "An unique brass board, used by cyborg warriors."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clock_mod"

/obj/item/borg/upgrade/clockwork/action(mob/living/silicon/robot/R)
	if(..())
		if(R.module?.type == /obj/item/robot_module/clockwork)
			R.pdahide = TRUE
		else
			R.ratvar_act()
		R.opened = FALSE
		R.locked = TRUE
		return TRUE

// A drone shell. Just click on it and it will boot up itself!
/obj/item/clockwork/cogscarab
	name = "unactivated cogscarab"
	desc = "A strange, drone-like machine. It looks lifeless."
	icon_state = "cogscarab_shell"
	var/searching = FALSE

/obj/item/clockwork/cogscarab/attack_self(mob/user)
	if(!isclocker(user))
		to_chat(user, span_warning("You fiddle around with [src], to no avail."))
		return FALSE
	if(searching)
		return
	searching = TRUE
	to_chat(user, span_notice("You're trying to boot up [src] as the gears inside start to hum."))
	var/list/candidates = SSghost_spawns.poll_candidates("Would you like to play as a Servant of Ratvar?", ROLE_CLOCKER, FALSE, poll_time = 10 SECONDS, source = /mob/living/silicon/robot/cogscarab)
	if(candidates.len)
		var/mob/dead/observer/O = pick(candidates)
		var/mob/living/silicon/robot/cogscarab/cog = new /mob/living/silicon/robot/cogscarab(get_turf(src))
		cog.key = O.key
		if(SSticker.mode.add_clocker(cog.mind))
			cog.create_log(CONVERSION_LOG, "[cog.mind] became clock drone by [user.name]")
		user.drop_item_ground(src)
		qdel(src)
	else
		visible_message(span_notice("[src] stops to hum. Perhaps you could try again?"))
		searching = FALSE
	return TRUE

// A real fighter. Doesn't have any ability except passive range reflect chance but a good soldier with solid speed and attack.
/obj/item/clockwork/marauder
	name = "unactivated marauder"
	desc = "The stalwart apparition of a soldier. It looks lifeless."
	icon_state = "marauder_shell"

/obj/item/clockwork/marauder/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/mmi/robotic_brain/clockwork))
		if(!isclocker(user))
			to_chat(user, span_danger("An overwhelming feeling of dread comes over you as you attempt to place the soul vessel into the marauder shell."))
			user.Confused(10 SECONDS)
			user.Jitter(8 SECONDS)
			return
		if(isdrone(user))
			to_chat(user, span_warning("You are not dexterous enough to do this!"))
			return
		var/obj/item/mmi/robotic_brain/clockwork/soul = I
		if(!soul.brainmob.mind)
			to_chat(user, span_warning("There is no soul in [I]!"))
			return
		var/mob/living/simple_animal/hostile/clockwork/marauder/cog = new (get_turf(src))
		soul.brainmob.mind.transfer_to(cog)
		playsound(cog, 'sound/effects/constructform.ogg', 50)
		user.temporarily_remove_item_from_inventory(soul)
		qdel(soul)
		qdel(src)

//Shard
/obj/item/clockwork/shard
	name = "A brass shard"
	desc = "Unique crystal powered by some unknown magic."
	icon_state = "shard"
	sharp = TRUE //youch!!
	force = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clockwork/shard/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/spell_enchant, GLOB.shard_spells)

/obj/item/clockwork/shard/attack_self(mob/user)
	if(!isclocker(user) && isliving(user))
		var/mob/living/L = user
		user.emote("scream")
		if(ishuman(L))
			to_chat(L, span_danger("[src] pierces into your hand!"))
			var/mob/living/carbon/human/H = L
			H.embed_item_inside(src)
			to_chat(user, span_clocklarge("\"How does it feel it now?\""))
		else
			to_chat(L, span_danger("[src] pierces into you!"))
			L.adjustBruteLoss(force)
		return
	return ..()

/obj/item/clockwork/shard/attack(mob/living/M, mob/living/user, def_zone)
	if(!isclocker(user))
		user.emote("scream")
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			human.embed_item_inside(src)
			to_chat(user, span_clocklarge("\"How does it feel it now?\""))
		else
			user.drop_item_ground(src)
			to_chat(user, span_clocklarge("\"Now now, this is for my servants, not you.\""))
		return
	. = ..()

/obj/item/clockwork/shard/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!ishuman(target) || !isclocker(user) || !proximity)
		return
	var/mob/living/carbon/human/human = target
	if(human.stat == DEAD && isclocker(human)) // dead clocker
		user.temporarily_remove_item_from_inventory(src)
		qdel(src)
		if(!human.client)
			give_ghost(human)
		else
			human.revive()
			human.set_species(/datum/species/golem/clockwork)
			to_chat(human, span_clocklarge("<b>\"You are back once again.\"</b>"))

/obj/item/clockwork/shard/pickup(mob/living/user)
	. = ..()
	if(!isclocker(user))
		to_chat(user, span_clocklarge("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.Confused(20 SECONDS)
		user.Jitter(12 SECONDS)

/obj/item/clockwork/shard/proc/give_ghost(mob/living/carbon/human/golem)
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Would you like to play as a Brass Golem?", ROLE_CLOCKER, TRUE, poll_time = 10 SECONDS, source = /obj/item/clockwork/clockslab)
	if(length(candidates))
		var/mob/dead/observer/C = pick(candidates)
		golem.ghostize(FALSE)
		golem.key = C.key
		golem.revive()
		golem.set_species(/datum/species/golem/clockwork)
		add_game_logs("has become Brass Golem.", golem)
		SEND_SOUND(golem, 'sound/ambience/antag/clockcult.ogg')
	else
		golem.visible_message(span_warning("[golem] twitches as their body twists and rapidly changes the form!"))
		new /obj/effect/mob_spawn/human/golem/clockwork(get_turf(golem))
		golem.dust()

/obj/effect/temp_visual/ratvar/reconstruct
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_active"
	layer = BELOW_OBJ_LAYER
	alpha = 128
	duration = 40
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/ratvar/reconstruct/Initialize(mapload)
	. = ..()
	transform = matrix() * 0.1
	reconstruct()

/obj/effect/temp_visual/ratvar/reconstruct/proc/reconstruct()
	playsound(src, 'sound/magic/clockwork/reconstruct.ogg', 50, TRUE)
	animate(src, transform = matrix() * 1, time = 2 SECONDS)
	sleep(20)
	for(var/atom/affected in range(4, get_turf(src)))
		if(isliving(affected))
			var/mob/living/living = affected
			living.ratvar_act(TRUE)
			if(!isclocker(living) && !ishuman(living))
				continue
			living.heal_overall_damage(60, 60, TRUE, FALSE, TRUE)
			living.reagents?.add_reagent("epinephrine", 5)
			var/mob/living/carbon/human/H = living
			for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
				bodypart.stop_internal_bleeding()
				bodypart.mend_fracture()
		else
			affected.ratvar_act()
	animate(src, transform = matrix() * 0.1, time = 2 SECONDS)
