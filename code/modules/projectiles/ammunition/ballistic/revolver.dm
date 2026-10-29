// MARK: .357
/obj/item/ammo_casing/a357
	ammo_marking = ".357 Magnum"
	materials = list(MAT_METAL = 3750)
	caliber = CALIBER_DOT_357
	projectile_type = /obj/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

// MARK: .38
/obj/item/ammo_casing/c38
	ammo_marking = ".38"
	icon_state = "r-casing"
	materials = list(MAT_METAL = 650)
	caliber = CALIBER_DOT_38
	projectile_type = /obj/projectile/bullet/weakbullet2
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/c38/hp
	ammo_marking = ".38 HP"
	extra_info = "Экспансивная пуля обладает повышенным травмирующим действием в ущерб проникающей способности."
	icon_state = "rhp-casing"
	materials = list(MAT_METAL = 5000)
	projectile_type = /obj/projectile/bullet/hp38

/obj/item/ammo_casing/c38/invisible
	projectile_type = /obj/projectile/bullet/weakbullet2/invisible
	muzzle_flash_effect = null // invisible eh
	harmful = FALSE

/obj/item/ammo_casing/c38/invisible/fake
	projectile_type = /obj/projectile/bullet/weakbullet2/invisible/fake

// MARK: 7.62x38mm
/obj/item/ammo_casing/n762
	ammo_marking = "7.62x38 мм"
	materials = list(MAT_METAL = 4000)
	caliber = CALIBER_7_DOT_62X38MM
	projectile_type = /obj/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

// MARK: .257 Improvised
/obj/item/ammo_casing/revolver/improvised
	desc = "Полностью металлическая гильза, из которой течёт масло. Это явно ненадёжный патрон."
	ammo_marking = ".257"
	icon_state = "rev-improv-casing"
	materials = list(MAT_METAL = 100)
	caliber = CALIBER_DOT_257
	projectile_type = /obj/projectile/bullet/weakbullet3/c257
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/revolver/improvised/update_desc(updates = ALL)
	. = ..()
	desc = initial(desc)

/obj/item/ammo_casing/revolver/improvised/phosphorus
	desc = "Полностью металлическая гильза, из которой течёт масло и фосфор. Это явно ненадёжный патрон."
	ammo_marking = ".257 \"Фосфор\""
	icon_state = "rev-phosphor-casing"
	projectile_type = /obj/projectile/bullet/weakbullet3/c257/phosphorus

/obj/item/ammo_casing/pea
	name = "pea bullet casing"
	desc = "Причудливая гороховая пуля."
	projectile_type = /obj/projectile/bullet/midbullet3/pea
	icon_state = "pea"
	/// Damage we achieve at 100 potency
	var/max_damage = 25
	/// Damage set by the plant
	var/damage = 25 //max potency, is set

/obj/item/ammo_casing/pea/get_ru_names()
	return alist(
		NOMINATIVE = "гильза гороховой пули",
		GENITIVE = "гильзы гороховой пули",
		DATIVE = "гильзе гороховой пули",
		ACCUSATIVE = "гильзу гороховой пули",
		INSTRUMENTAL = "гильзой гороховой пули",
		PREPOSITIONAL = "гильзе гороховой пули",
	)

/obj/item/ammo_casing/pea/Initialize(mapload)
	. = ..()
	create_reagents(60)

/obj/item/ammo_casing/pea/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	. = ..()
	if(isnull(BB))
		return
	BB.damage = damage

/obj/item/ammo_casing/pea/attack_self(mob/user)
	. = ..()
	if(isnull(BB))
		return
	var/obj/item/reagent_containers/food/snacks/grown/peas/peas = new(user.drop_location())
	user.put_in_hands(peas)
	to_chat(user, span_notice("Вы отделяете [peas.declent_ru(ACCUSATIVE)] от [declent_ru(GENITIVE)]."))
	BB = null
	update_appearance()
