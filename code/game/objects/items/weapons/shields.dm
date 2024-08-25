/obj/item/shield
	name = "shield"
	block_chance = 50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)
	obj_integrity = 380
	max_integrity = 380

/obj/item/shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == THROWN_PROJECTILE_ATTACK)
		final_block_chance += 30
	. = ..()
	if(.)
		var/damage_type = BRUTE
		if(istype(hitby, /obj/item/projectile))
			var/obj/item/projectile/P = hitby
			if(P.shield_buster)
				take_damage(180, damage_type, sound_effect = FALSE) //2 shots for tele, 3 for riot
		if(isobj(hitby))
			var/obj/hitby_obj = hitby
			damage_type = hitby_obj.damtype
		take_damage(damage, damage_type, sound_effect = FALSE)

/obj/item/shield/obj_destruction(damage_flag)
	playsound(src, 'sound/weapons/smash.ogg', 50)
	..()

/obj/item/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon_state = "riot"
	slot_flags = ITEM_SLOT_BACK
	force = 10
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	obj_integrity = 400
	max_integrity = 400
	w_class = WEIGHT_CLASS_BULKY
	materials = list(MAT_GLASS=7500, MAT_METAL=1000)
	origin_tech = "materials=3;combat=4"
	attack_verb = list("shoved", "bashed")
	/// Shield bash cooldown
	COOLDOWN_DECLARE(cooldown)


/obj/item/shield/riot/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/melee/baton) && COOLDOWN_FINISHED(src, cooldown))
		COOLDOWN_START(src, cooldown, 2.5 SECONDS)
		user.visible_message(
			span_warning("[user] bashes [src] with [I]!"),
			span_notice("You bash [src] with [I]."),
			span_italics("You hear heavy bashing noises."),
		)
		playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, TRUE)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/item/shield/riot/roman
	name = "roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"
	item_state = "roman_shield"
	materials = list(MAT_METAL=8500)
	obj_integrity = 380
	max_integrity = 380

/obj/item/shield/riot/roman/fake
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>. It appears to be a bit flimsy."
	block_chance = 0
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0)

/obj/item/shield/riot/buckler
	name = "wooden buckler"
	desc = "A medieval wooden buckler."
	icon_state = "buckler"
	item_state = "buckler"
	materials = list()
	origin_tech = "materials=1;combat=3;biotech=2"
	resistance_flags = FLAMMABLE
	block_chance = 30
	obj_integrity = 380
	max_integrity = 380

/obj/item/shield/riot/goliath
	name = "goliath shield"
	desc = "A shield made from interwoven plates of goliath hide."
	icon_state = "goliath_shield"
	item_state = "goliath_shield"
	materials = list()
	origin_tech = "materials=1;combat=3;biotech=2"
	block_chance = 30
	obj_integrity = 380
	max_integrity = 380

/obj/item/shield/energy
	name = "energy combat shield"
	desc = "A shield that reflects almost all energy projectiles, but is useless against physical attacks. It can be retracted, expanded, and stored anywhere."
	icon_state = "eshield0" // eshield1 for expanded
	force = 3
	throwforce = 3
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=4;magnets=5;syndicate=6"
	attack_verb = list("shoved", "bashed")
	var/active = 0

/obj/item/shield/energy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(istype(hitby, /obj/item/projectile))
		var/obj/item/projectile/P = hitby
		if(P.shield_buster && active)
			toggle(owner, TRUE)
			to_chat(owner, "<span class='warning'>[hitby] overloaded your [src]!</span>")
	return FALSE

/obj/item/shield/energy/IsReflect()
	return (active)

/obj/item/shield/energy/attack_self(mob/living/carbon/human/user)
	toggle(user, FALSE)

/obj/item/shield/energy/proc/toggle(mob/living/carbon/human/user, forced)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50) && !forced)
		to_chat(user, "<span class='warning'>You beat yourself in the head with [src].</span>")
		user.take_organ_damage(5)
	active = !active
	if(active)
		force = 10
		throwforce = 8
		throw_speed = 2
		update_icon()
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 35, 1)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		update_icon()
		w_class = WEIGHT_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 35, 1)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	if(!forced)
		add_fingerprint(user)
	return

/obj/item/shield/energy/update_icon_state()
	icon_state = "eshield[active]"

/obj/item/shield/energy/syndie
	icon_state = "syndieshield0"
	desc = "Reverse-engineered shield that reflects almost all energy projectiles, but is useless against physical attacks. It can be retracted, expanded, and stored anywhere. Property of Gorlex marauders."

/obj/item/shield/energy/syndie/update_icon_state()
	icon_state = "syndieshield[active]"

/obj/item/shield/riot/tele
	name = "telescopic shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	icon_state = "teleriot0"
	origin_tech = "materials=3;combat=4;engineering=4"
	slot_flags = null
	force = 3
	throwforce = 3
	throw_speed = 3
	throw_range = 4
	w_class = WEIGHT_CLASS_NORMAL
	obj_integrity = 360
	max_integrity = 360
	var/active = 0

/obj/item/shield/riot/tele/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return FALSE


/obj/item/shield/riot/tele/update_icon_state()
	icon_state = "teleriot[active]"


/obj/item/shield/riot/tele/attack_self(mob/living/user)
	active = !active
	update_icon(UPDATE_ICON_STATE)
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)

	if(active)
		force = 8
		throwforce = 5
		throw_speed = 2
		w_class = WEIGHT_CLASS_BULKY
		slot_flags = ITEM_SLOT_BACK
		to_chat(user, "<span class='notice'>You extend \the [src].</span>")
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = WEIGHT_CLASS_NORMAL
		slot_flags = NONE
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	update_equipped_item()
	add_fingerprint(user)

