/*
	Changeling Mutations! ~By Miauw (ALL OF IT :V)
	Contains:
		Arm Blade
		Space Suit
		Shield
		Armor
*/

//Parent to shields and blades because muh copypasted code.
/datum/action/changeling/weapon
	abstract_type = /datum/action/changeling/weapon
	name = "Organic Weapon"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at coderbus"
	chemical_cost = 1000
	genetic_damage = 1000
	req_human = TRUE
	var/silent = FALSE
	var/weapon_type
	var/weapon_check_type
	var/weapon_name_simple

/datum/action/changeling/weapon/try_to_sting(mob/user, mob/target)
	if(istype(user.get_active_hand(), weapon_check_type) || istype(user.get_inactive_hand(), weapon_check_type))
		retract(user, any_hand = TRUE)
		return
	..(user, target)

/datum/action/changeling/weapon/sting_action(mob/user)
	SEND_SIGNAL(user, COMSIG_MOB_WEAPON_APPEARS)
	if(!user.can_unEquip(user.get_active_hand(), silent = TRUE))
		to_chat(user, "[user.get_active_hand()] is stuck to your hand, you cannot grow a [weapon_name_simple] over it!")
		return FALSE

	var/obj/item/weapon = new weapon_type(user, silent, src)
	user.put_in_hands(weapon)

	RegisterSignal(user, COMSIG_MOB_KEY_DROP_ITEM_DOWN, PROC_REF(retract), override = TRUE)
	RegisterSignal(user, COMSIG_MOB_WEAPON_APPEARS, PROC_REF(retract), override = TRUE)
	playsound(owner.loc, 'sound/effects/bone_break_1.ogg', 100, TRUE)

	return weapon

/datum/action/changeling/weapon/proc/retract(mob/user, any_hand = FALSE)
	SIGNAL_HANDLER

	if(!ischangeling(user))
		return

	if(!any_hand && !istype(user.get_active_hand(), weapon_check_type))
		return

	var/done = FALSE
	if(istype(user.get_active_hand(), weapon_check_type))
		qdel(user.get_active_hand())
		done = TRUE

	if(istype(user.get_inactive_hand(), weapon_check_type))
		qdel(user.get_inactive_hand())
		done = TRUE

	if(done)
		. = COMPONENT_CANCEL_DROP
		if(!silent)
			playsound(owner.loc, 'sound/effects/bone_break_2.ogg', 100, TRUE)
			user.visible_message(span_warning("With a sickening crunch, [user] reforms [user.p_their()] [weapon_name_simple] into an arm!"),
								span_notice("We assimilate the [weapon_name_simple] back into our body."),
								span_warning("You hear organic matter ripping and tearing!"))

//Parent to space suits and armor.
/datum/action/changeling/suit
	name = "Organic Suit"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at coderbus"
	chemical_cost = 1000
	req_human = TRUE
	var/helmet_type = /obj/item
	var/suit_type = /obj/item
	var/suit_name_simple = "    "
	var/helmet_name_simple = "     "
	var/recharge_slowdown = 0
	var/blood_on_castoff = FALSE

/datum/action/changeling/suit/try_to_sting(mob/living/carbon/human/user, mob/target)
	if(!istype(user))
		return FALSE

	if(istype(user.wear_suit, suit_type) || istype(user.head, helmet_type))
		user.visible_message(span_warning("[user] casts off [user.p_their()] [suit_name_simple]!"), span_warning("We cast off our [suit_name_simple][genetic_damage > 0 ? ", temporarily weakening our genomes." : "."]"), span_warning("You hear the organic matter ripping and tearing!"))
		playsound(owner.loc, 'sound/effects/bone_break_2.ogg', 100, TRUE)
		qdel(user.wear_suit)
		qdel(user.head)
		user.update_worn_oversuit()
		user.update_worn_head()
		user.update_hair()
		user.update_fhair()

		if(blood_on_castoff)
			user.add_splatter_floor()
			playsound(user.loc, 'sound/effects/splat.ogg', 50, TRUE) //So real sounds

		cling.chem_recharge_slowdown -= recharge_slowdown
		return FALSE
	..(user, target)

/datum/action/changeling/suit/sting_action(mob/living/carbon/human/user)
	if(!user.can_unEquip(user.wear_suit))
		to_chat(user, "\the [user.wear_suit] is stuck to your body, you cannot grow a [suit_name_simple] over it!")
		return FALSE

	if(!user.can_unEquip(user.head))
		to_chat(user, "\the [user.head] is stuck on your head, you cannot grow a [helmet_name_simple] over it!")
		return FALSE

	user.drop_item_ground(user.head)
	user.drop_item_ground(user.wear_suit)

	user.equip_to_slot_or_del(new suit_type(user), ITEM_SLOT_CLOTH_OUTER)
	user.equip_to_slot_or_del(new helmet_type(user), ITEM_SLOT_HEAD)

	cling.chem_recharge_slowdown += recharge_slowdown
	return TRUE

//fancy headers yo
/***************************************\
|***************ARM BLADE***************|
\***************************************/
/datum/action/changeling/weapon/arm_blade
	name = "Arm Blade"
	desc = "We reform one of our arms into a deadly blade. Costs 10 chemicals."
	helptext = "We may retract our armblade in the same manner as we form it. Cannot be used while in lesser form."
	button_icon_state = "armblade"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 10
	genetic_damage = 10
	max_genetic_damage = 20
	weapon_type = /obj/item/melee/changeling/arm_blade
	weapon_check_type = /obj/item/melee/changeling // so we can't have maul and armblade at the same time
	weapon_name_simple = "blade"

/obj/item/melee/changeling/arm_blade
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter"
	icon_state = "arm_blade"
	item_state = "arm_blade"
	item_flags = ABSTRACT|DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	sharp = TRUE
	force = 45
	armour_penetration = -30
	block_chance = 50
	block_type = MELEE_ATTACKS
	hitsound = 'sound/weapons/armblade.ogg'
	throw_range = 0
	throw_speed = 0
	gender = FEMALE
	var/datum/action/changeling/weapon/parent_action

/obj/item/melee/changeling/arm_blade/get_ru_names()
	return list(
		NOMINATIVE = "рука-клинок",
		GENITIVE = "руки-клинка",
		DATIVE = "руке-клинку",
		ACCUSATIVE = "руку-клинок",
		INSTRUMENTAL = "рукой-клинком",
		PREPOSITIONAL = "руке-клинке",
	)

/obj/item/melee/changeling/arm_blade/Initialize(mapload, silent, new_parent_action)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	parent_action = new_parent_action

/obj/item/melee/changeling/arm_blade/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		swing_sound = SFX_BLADE_SWING_LIGHT \
	)

/obj/item/melee/changeling/arm_blade/Destroy()
	. = ..()

	if(!parent_action)
		return

	parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
	parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_WEAPON_APPEARS)
	parent_action = null

/obj/item/melee/changeling/arm_blade/afterattack(atom/target, mob/user, proximity, params)
	. = ..()

	if(!proximity)
		return

	if(is_airlock(target))
		var/obj/machinery/door/airlock/airlock = target

		if(!airlock.requiresID() || airlock.allowed(user)) //This is to prevent stupid shit like hitting a door with an arm blade, the door opening because you have acces and still getting a "the airlocks motors resist our efforts to force it" message.
			return

		if(airlock.locked)
			to_chat(user, span_notice("The airlock's bolts prevent it from being forced."))
			return

		if(airlock.arePowerSystemsOn())
			user.visible_message(span_warning("[user] jams [src] into the airlock and starts prying it open!"), \
								span_warning("We start forcing the airlock open."), \
								span_italics("You hear a metal screeching sound."))

			playsound(airlock, 'sound/machines/airlock_alien_prying.ogg', 150, TRUE)
			if(!do_after(user, 3 SECONDS, airlock))
				return

		//user.say("Heeeeeeeeeerrre's Johnny!")
		user.visible_message(span_warning("[user] forces the airlock to open with [user.p_their()] [name]!"), \
							span_warning("We force the airlock to open."), \
							span_warning("You hear a metal screeching sound."))
		airlock.open(2)

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/O = H.get_organ(user.zone_selected)
		if(O && O.brute_dam >= 50)
			O.droplimb()

/***************************************\
|**************FLESHY MAUL**************|
\***************************************/
/datum/action/changeling/weapon/fleshy_maul
	name = "Fleshy Maul"
	desc = "We reform one of our arms into a enourmous maul. Costs 10 chemicals."
	helptext = "We may retract our maul in the same manner as we form it. Cannot be used while in lesser form."
	button_icon_state = "flesh_maul"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 10
	genetic_damage = 10
	max_genetic_damage = 20
	weapon_type = /obj/item/melee/changeling/fleshy_maul
	weapon_check_type = /obj/item/melee/changeling
	weapon_name_simple = "maul"

/obj/item/melee/changeling/fleshy_maul
	name = "fleshy maul"
	desc = "An enormous maul made out of bone and flesh that crushes limbs in the dust"
	icon_state = "flesh_maul"
	item_state = "flesh_maul"
	item_flags = ABSTRACT|DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 25
	armour_penetration = 35
	hitsound = SFX_SWING_HIT
	throw_range = 0
	throw_speed = 0
	gender = MALE
	var/datum/action/changeling/weapon/parent_action

/obj/item/melee/changeling/fleshy_maul/get_ru_names()
	return list(
		NOMINATIVE = "молот из плоти",
		GENITIVE = "молота из плоти",
		DATIVE = "молоту из плоти",
		ACCUSATIVE = "молот из плоти",
		INSTRUMENTAL = "молотом из плоти",
		PREPOSITIONAL = "молоте из плоти",
	)

/obj/item/melee/changeling/fleshy_maul/Initialize(mapload, silent, new_parent_action)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	parent_action = new_parent_action

/obj/item/melee/changeling/fleshy_maul/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = 180, \
		swing_speed_mod = 2, \
		afterswing_slowdown = 0.3, \
		no_multi_hit = TRUE, \
		swing_sound = SFX_BLUNT_SWING_HEAVY, \
	)

/obj/item/melee/changeling/fleshy_maul/Destroy()
	. = ..()

	if(!parent_action)
		return

	parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
	parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_WEAPON_APPEARS)
	parent_action = null

/obj/item/melee/changeling/fleshy_maul/afterattack(atom/target, mob/living/user, proximity, params)
	. = ..()

	if(!proximity)
		return

	if(isstructure(target))
		var/obj/structure/S = target
		if(!QDELETED(S))
			S.attack_generic(user, 80, BRUTE, MELEE, 0)

	else if(iswallturf(target))
		var/turf/simulated/wall/wall = target
		user.do_attack_animation(wall)
		user.changeNext_move(attack_speed)
		wall.take_damage(30)
		playsound(src, 'sound/weapons/smash.ogg', 50, TRUE)

	else if(isliving(target))
		var/mob/living/M = target
		M.Slowed(2 SECONDS, 5)
		var/atom/throw_target = get_edge_target_turf(M, user.dir)
		RegisterSignal(M, COMSIG_MOVABLE_IMPACT, PROC_REF(bump_impact))
		M.throw_at(throw_target, 1, 14, user, callback = CALLBACK(src, PROC_REF(unregister_bump_impact), M))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/external/O = H.get_organ(user.zone_selected)
			if(O.brute_dam > 20)
				O.fracture()

/obj/item/melee/changeling/fleshy_maul/proc/bump_impact(mob/living/target, atom/hit_atom, throwingdatum)
	if(target && !iscarbon(hit_atom) && hit_atom.density)
		target.Weaken(1 SECONDS)

/obj/item/melee/changeling/fleshy_maul/proc/unregister_bump_impact(mob/living/target)
	UnregisterSignal(target, COMSIG_MOVABLE_IMPACT)

/***************************************\
|***********COMBAT TENTACLES*************|
\***************************************/
/datum/action/changeling/weapon/tentacle
	name = "Tentacle"
	desc = "We ready a tentacle to grab items or victims with. Costs 10 chemicals."
	helptext = "We can use it once to retrieve a distant item. If used on living creatures, the effect depends on the intent: \
	Help will simply drag them closer, Disarm will grab whatever they are holding instead of them, Grab will put the victim in our hold after catching it, \
	and Harm will stun it, and stab it if we are also holding a sharp weapon. Cannot be used while in lesser form."
	button_icon_state = "tentacle"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 10
	genetic_damage = 5
	max_genetic_damage = 10
	weapon_type = /obj/item/gun/magic/tentacle
	weapon_check_type = /obj/item/gun/magic/tentacle
	weapon_name_simple = "tentacle"
	silent = TRUE

/obj/item/gun/magic/tentacle
	name = "tentacle"
	desc = "A fleshy tentacle that can stretch out and grab things or people."
	icon = 'icons/obj/items.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "tentacle"
	item_state = "tentacle"
	item_flags = ABSTRACT|NOBLUDGEON|DROPDEL
	slot_flags = NONE
	ammo_type = /obj/item/ammo_casing/magic/tentacle
	fire_sound = 'sound/effects/splat.ogg'
	force = 0
	max_charges = 1
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0
	var/datum/action/changeling/weapon/parent_action

/obj/item/gun/magic/tentacle/Initialize(mapload, silent, new_parent_action)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	parent_action = new_parent_action
	if(ismob(loc))
		if(!silent)
			loc.visible_message(span_warning("[loc.name]\'s arm starts stretching inhumanly!"), \
								span_warning("Our arm twists and mutates, transforming it into a tentacle."), \
								span_italics("You hear organic matter ripping and tearing!"))
			playsound(loc, 'sound/effects/bone_break_1.ogg', 100, TRUE)
		else
			to_chat(loc, span_notice("You prepare to extend a tentacle."))

/obj/item/gun/magic/tentacle/Destroy()
	if(parent_action)
		parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
		parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_WEAPON_APPEARS)
		parent_action = null
		playsound(loc, 'sound/effects/bone_break_2.ogg', 100, TRUE)
	return ..()

/obj/item/gun/magic/tentacle/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, span_warning("The [name] is not ready yet."))

/obj/item/gun/magic/tentacle/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] coils [src] tightly around [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide."))
	return OXYLOSS

/***************************************\
|****************SHIELD*****************|
\***************************************/
/datum/action/changeling/weapon/shield
	name = "Organic Shield"
	desc = "We reform one of our arms into a hard shield. Costs 20 chemicals."
	helptext = "Organic tissue cannot resist damage forever. The shield will break after it is hit too much. The more genomes we absorb, the stronger it is. Cannot be used while in lesser form."
	button_icon_state = "organic_shield"
	power_type = CHANGELING_PURCHASABLE_POWER
	chemical_cost = 20
	dna_cost = 1
	genetic_damage = 12
	max_genetic_damage = 20
	weapon_type = /obj/item/shield/changeling
	weapon_check_type = /obj/item/shield/changeling
	weapon_name_simple = "shield"

/datum/action/changeling/weapon/shield/sting_action(mob/user)
	var/obj/item/shield/changeling/shield = ..(user)
	if(!shield)
		return FALSE

	shield.remaining_uses = round(cling.absorbed_count * 3)
	return TRUE

/obj/item/shield/changeling
	name = "shield-like mass"
	desc = "A mass of tough, boney tissue. You can still see the fingers as a twisted pattern in the shield."
	item_flags = DROPDEL
	icon_state = "ling_shield"
	var/remaining_uses //Set by the changeling ability.

/obj/item/shield/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		loc.visible_message(span_warning("The end of [loc.name]\'s hand inflates rapidly, forming a huge shield-like mass!"), \
							span_warning("We inflate our hand into a strong shield."), \
							span_italics("You hear organic matter ripping and tearing!"))
		playsound(loc, 'sound/effects/bone_break_1.ogg', 100, TRUE)

/obj/item/shield/changeling/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(remaining_uses < 1)
		if(ishuman(loc))
			var/mob/living/carbon/human/user = loc
			user.visible_message(span_warning("With a sickening crunch, [user] reforms [user.p_their()] shield into an arm!"), \
								span_notice("We assimilate our shield into our body."), \
								span_italics("You hear organic matter ripping and tearing!"))
			playsound(loc, 'sound/effects/bone_break_2.ogg', 100, TRUE)
			user.temporarily_remove_item_from_inventory(src, force = TRUE)
		qdel(src)
		return FALSE
	else
		remaining_uses--
		return ..()

/***************************************\
|*********SPACE SUIT + HELMET***********|
\***************************************/
/datum/action/changeling/suit/organic_space_suit
	name = "Organic Space Suit"
	desc = "We grow an organic suit to protect ourselves from space exposure. Costs 20 chemicals."
	helptext = "We must constantly repair our form to make it space proof, reducing chemical production while we are protected. Cannot be used in lesser form."
	button_icon_state = "organic_suit"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 20
	genetic_damage = 8
	max_genetic_damage = 20
	suit_type = /obj/item/clothing/suit/space/changeling
	helmet_type = /obj/item/clothing/head/helmet/space/changeling
	suit_name_simple = "flesh shell"
	helmet_name_simple = "space helmet"
	recharge_slowdown = 0.5
	blood_on_castoff = TRUE

/obj/item/clothing/suit/space/changeling
	name = "flesh mass"
	icon_state = "lingspacesuit"
	desc = "A huge, bulky mass of pressure and temperature-resistant organic tissue, evolved to facilitate space travel."
	clothing_flags = STOPSPRESSUREDMAGE
	flags_inv = HIDETAIL
	item_flags = DROPDEL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 90, ACID = 90) //No armor at all
	species_restricted = null
	faction_restricted = null
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
	)

/obj/item/clothing/suit/space/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		loc.visible_message(span_warning("[loc.name]\'s flesh rapidly inflates, forming a bloated mass around [loc.p_their()] body!"), \
							span_warning("We inflate our flesh, creating a spaceproof suit!"), \
							span_italics("You hear organic matter ripping and tearing!"))
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/changeling/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		user.reagents.add_reagent("perfluorodecalin", REAGENTS_METABOLISM)

/obj/item/clothing/head/helmet/space/changeling
	name = "flesh mass"
	icon_state = "lingspacehelmet"
	desc = "A covering of pressure and temperature-resistant organic tissue with a glass-like chitin front."
	clothing_flags = STOPSPRESSUREDMAGE
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDEHAIR
	item_flags = DROPDEL
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 90, ACID = 90)
	species_restricted = null
	faction_restricted = null
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/helmet.dmi',
	)

/obj/item/clothing/head/helmet/space/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)

/***************************************\
|*****************ARMOR*****************|
\***************************************/
/datum/action/changeling/suit/armor
	name = "Chitinous Armor"
	desc = "We turn our skin into tough chitin to protect us from damage. Costs 25 chemicals."
	helptext = "Upkeep of the armor requires a low expenditure of chemicals. The armor is strong against brute force, but does not provide much protection from lasers. Cannot be used in lesser form."
	button_icon_state = "chitinous_armor"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 25
	genetic_damage = 11
	max_genetic_damage = 20
	suit_type = /obj/item/clothing/suit/armor/changeling
	helmet_type = /obj/item/clothing/head/helmet/changeling
	suit_name_simple = "armor"
	helmet_name_simple = "helmet"
	recharge_slowdown = 0.25

/obj/item/clothing/suit/armor/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin."
	icon_state = "lingarmor"
	item_flags = DROPDEL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 20, BOMB = 10, BIO = 4, FIRE = 90, ACID = 90)
	flags_inv = HIDEJUMPSUIT
	cold_protection = 0
	heat_protection = 0
	species_restricted = null
	faction_restricted = null
	hide_tail_by_species = list(SPECIES_VULPKANIN, SPECIES_UNATHI, SPECIES_ASHWALKER_BASIC, SPECIES_ASHWALKER_SHAMAN, SPECIES_DRACONOID)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
	)

/obj/item/clothing/suit/armor/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		loc.visible_message(span_warning("[loc.name]\'s flesh turns black, quickly transforming into a hard, chitinous mass!"), \
							span_warning("We harden our flesh, creating a suit of armor!"), \
							span_italics("You hear organic matter ripping and tearing!"))
		playsound(loc, 'sound/effects/bone_break_1.ogg', 100, TRUE)

/obj/item/clothing/head/helmet/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin with transparent chitin in front."
	icon_state = "lingarmorhelmet"
	flags_inv = HIDEHEADSETS|HIDEHAIR
	item_flags = DROPDEL
	flags_cover = MASKCOVERSEYES|MASKCOVERSMOUTH
	armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 20, BOMB = 10, BIO = 4, FIRE = 90, ACID = 90)
	species_restricted = null
	faction_restricted = null

/obj/item/clothing/head/helmet/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)

