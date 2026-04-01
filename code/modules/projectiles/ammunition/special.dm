// MARK: Magic
/obj/item/ammo_casing/magic
	name = "magic casing"
	desc = "I didn't even know magic needed ammo..."
	projectile_type = /obj/projectile/magic
	muzzle_flash_color = COLOR_BLUE_GRAY
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash/magic

/obj/item/ammo_casing/magic/change
	projectile_type = /obj/projectile/magic/change

/obj/item/ammo_casing/magic/animate
	projectile_type = /obj/projectile/magic/animate

/obj/item/ammo_casing/magic/heal
	projectile_type = /obj/projectile/magic/resurrection
	harmful = FALSE

/obj/item/ammo_casing/magic/death
	projectile_type = /obj/projectile/magic/death

/obj/item/ammo_casing/magic/teleport
	projectile_type = /obj/projectile/magic/teleport
	harmful = FALSE

/obj/item/ammo_casing/magic/door
	projectile_type = /obj/projectile/magic/door
	harmful = FALSE

/obj/item/ammo_casing/magic/fireball
	projectile_type = /obj/projectile/magic/fireball

/obj/item/ammo_casing/magic/chaos

/obj/item/ammo_casing/magic/spellblade
	projectile_type = /obj/projectile/magic/spellblade

/obj/item/ammo_casing/magic/slipping
	projectile_type = /obj/projectile/magic/slipping

/obj/item/ammo_casing/magic/chaos/newshot()
	projectile_type = pick(typesof(/obj/projectile/magic))
	..()

/obj/item/ammo_casing/magic/arcane_barrage
	projectile_type = /obj/projectile/magic/arcane_barrage

/obj/item/ammo_casing/magic/forcebolt
	projectile_type = /obj/projectile/forcebolt

/obj/item/ammo_casing/magic/arcane_barrage/blood
	projectile_type = /obj/projectile/magic/arcane_barrage/blood
	muzzle_flash_effect = /obj/effect/temp_visual/emp/cult

// MARK: Chrono Beam
/obj/item/ammo_casing/energy/chrono_beam
	name = "eradication beam"
	projectile_type = /obj/projectile/energy/chrono_beam
	muzzle_flash_color = null
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "chronobolt"
	e_cost = 0

// MARK: Tentacle
/obj/item/ammo_casing/magic/tentacle
	name = "tentacle"
	desc = "A tentacle."
	projectile_type = /obj/projectile/tentacle
	caliber = "tentacle"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "tentacle_end"
	muzzle_flash_effect = null
	var/obj/item/gun/magic/tentacle/gun //the item that shot it

/obj/item/ammo_casing/magic/tentacle/Initialize(mapload)
	gun = loc
	. = ..()

/obj/item/ammo_casing/magic/tentacle/Destroy()
	gun = null
	return ..()

// MARK: Jōhyō
/obj/item/ammo_casing/magic/johyo
	name = "Jōhyō"
	desc = "Кинжал, прикреплённый к верёвке. Просто и эффективно."
	projectile_type = /obj/projectile/johyo
	muzzle_flash_effect = null
	caliber = "kunai"
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "kunai"

/obj/item/ammo_casing/magic/johyo/get_ru_names()
	return list(
		NOMINATIVE = "джохё",
		GENITIVE = "джохё",
		DATIVE = "джохё",
		ACCUSATIVE = "джохё",
		INSTRUMENTAL = "джохё",
		PREPOSITIONAL = "джохё",
	)

// MARK: Skull Gun
/obj/item/ammo_casing/magic/skull_gun_casing
	name = "skull gun casing"
	desc = "Что это за..."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "ashen_skull"
	projectile_type = /obj/projectile/skull_projectile
	muzzle_flash_effect = null
	caliber = "skulls"

/obj/item/ammo_casing/magic/skull_gun_casing/get_ru_names()
	return list(
		NOMINATIVE = "гильза для черепного пистолета",
		GENITIVE = "гильзы для черепного пистолета",
		DATIVE = "гильзе для черепного пистолета",
		ACCUSATIVE = "гильзу для черепного пистолета",
		INSTRUMENTAL = "гильзой для черепного пистолета",
		PREPOSITIONAL = "гильзе для черепного пистолета",
	)

/obj/item/ammo_casing/magic/frost
	projectile_type = /obj/projectile/magic/frost

// MARK: Hook
/obj/item/ammo_casing/magic/hook
	name = "hook"
	desc = "Это крюк."
	projectile_type = /obj/projectile/hook
	caliber = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "hook"
	muzzle_flash_effect = null

/obj/item/ammo_casing/magic/hook/get_ru_names()
	return list(
		NOMINATIVE = "крюк",
		GENITIVE = "крюка",
		DATIVE = "крюку",
		ACCUSATIVE = "крюк",
		INSTRUMENTAL = "крюком",
		PREPOSITIONAL = "крюке",
	)

// MARK: Contractor Hook
/obj/item/ammo_casing/magic/contractor_hook
	name = "Hardlight hook"
	desc = "Крюк из твёрдого света. Хватит его разглядывать, уворачивайся!"
	projectile_type = /obj/projectile/contractor_hook
	caliber = "hardlight_hook"
	icon_state = "hard_hook"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	muzzle_flash_effect = null

/obj/item/ammo_casing/magic/contractor_hook/get_ru_names()
	return list(
		NOMINATIVE = "крюк из твёрдого света",
		GENITIVE = "крюка из твёрдого света",
		DATIVE = "крюку из твёрдого света",
		ACCUSATIVE = "крюк из твёрдого света",
		INSTRUMENTAL = "крюком из твёрдого света",
		PREPOSITIONAL = "крюке из твёрдого света",
	)

// MARK: Syringe Gun
/obj/item/ammo_casing/syringegun
	name = "syringe gun spring"
	desc = "A high-power spring that throws syringes."
	projectile_type = null
	muzzle_flash_effect = null
