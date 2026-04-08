/obj/projectile/bullet/reusable/arrow //only for wooden bow!
	name = "arrow"
	icon_state = "arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	range = 10
	damage = 25
	miss_sound = SFX_ARROW_MISS
	var/faction_bonus_damage = 13
	var/nemesis_factions = MINING_FACTIONS
	var/nemesis_faction = FALSE

/obj/projectile/bullet/reusable/arrow/prehit(atom/target)
	var/mob/living/H = target

	if(!ismob(H) || !LAZYLEN(nemesis_factions))
		return

	for(var/faction in H.faction)
		if(faction in nemesis_factions)
			nemesis_faction = TRUE
			damage += faction_bonus_damage
			break

	return ..()

/obj/projectile/bullet/reusable/arrow/bone //A fully upgraded normal arrow; it's got the stats to show. Still *less* damage than a slug, slower, and with negative AP. Only for bone bow!
	name = "bone-tipped arrow"
	icon_state = "bone_arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone_tipped
	range = 12
	damage = 45
	armour_penetration = -10
	faction_bonus_damage = 23

/obj/projectile/bullet/reusable/arrow/jagged //alternative arrow, made from fishing
	name = "jagged-tipped arrow"
	icon_state = "jagged_arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/jagged
	range = 12
	damage = 50
	armour_penetration = -30
	faction_bonus_damage = 60
