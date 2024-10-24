/obj/item/ammo_casing/a357
	desc = "A .357 bullet casing."
	materials = list(MAT_METAL = 3750)
	caliber = ".357"
	projectile_type = /obj/item/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/rubber9mm
	desc = "A 9mm rubber bullet casing."
	icon_state = "r-casing"
	materials = list(MAT_METAL = 650)
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/weakbullet4

/obj/item/ammo_casing/fortynr
	desc = "A 40nr bullet casing."
	materials = list(MAT_METAL = 1100)
	caliber = "40nr"
	projectile_type = /obj/item/projectile/bullet/weakbullet3/fortynr

/obj/item/ammo_casing/a762
	desc = "A 7.62x54mm bullet casing."
	icon_state = "762-casing"
	materials = list(MAT_METAL = 4000)
	caliber = "7.62x54mm"
	projectile_type = /obj/item/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/a762/enchanted
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/item/projectile/bullet/weakbullet3

/obj/item/ammo_casing/ftt762
	desc = "A fusty 7.62x25mm TT bullet casing."
	icon_state = "r-casing"
	materials = list(MAT_METAL = 1000)
	caliber = "7.62x25mm"
	projectile_type = /obj/item/projectile/bullet/ftt762
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/a50
	desc = "A .50AE bullet casing."
	materials = list(MAT_METAL = 4000)
	caliber = ".50ae" //change to diffrent caliber because players got deagle in uplink
	projectile_type = /obj/item/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/c38
	desc = "A .38 bullet casing."
	icon_state = "r-casing"
	materials = list(MAT_METAL = 650)
	caliber = ".38"
	projectile_type = /obj/item/projectile/bullet/weakbullet2
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/c38/hp
	desc = "A .38 Hollow-Point bullet casing."
	icon_state = "rhp-casing"
	materials = list(MAT_METAL = 5000)
	projectile_type = /obj/item/projectile/bullet/hp38

/obj/item/ammo_casing/c38/invisible
	projectile_type = /obj/item/projectile/bullet/weakbullet2/invisible
	muzzle_flash_effect = null // invisible eh

/obj/item/ammo_casing/c38/invisible/fake
	projectile_type = /obj/item/projectile/bullet/weakbullet2/invisible/fake

/obj/item/ammo_casing/c38/c36
	desc = "A .36 bullet casing."
	caliber = ".36"
	projectile_type = /obj/item/projectile/bullet/midbullet2

/obj/item/ammo_casing/c10mm
	desc = "A 10mm bullet casing."
	materials = list(MAT_METAL = 1500)
	caliber = "10mm"
	projectile_type = /obj/item/projectile/bullet/midbullet3
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/c10mm/ap
	materials = list(MAT_METAL = 2000, MAT_SILVER = 200)
	projectile_type = /obj/item/projectile/bullet/midbullet3/ap

/obj/item/ammo_casing/c10mm/fire
	materials = list(MAT_METAL = 2000, MAT_SILVER = 200, MAT_PLASMA = 300)
	projectile_type = /obj/item/projectile/bullet/midbullet3/fire
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/c10mm/hp
	materials = list(MAT_METAL = 2000, MAT_SILVER = 200)
	projectile_type = /obj/item/projectile/bullet/midbullet3/hp

/obj/item/ammo_casing/c10mm/blood
	materials = list(MAT_METAL = 2000, MAT_SILVER = 200, MAT_PLASMA = 300)
	projectile_type = /obj/item/projectile/bullet/midbullet3/blood
	muzzle_flash_color = LIGHT_COLOR_PURE_RED

/obj/item/ammo_casing/c9mm
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/item/projectile/bullet/weakbullet3
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_WEAK
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/c9mm/ap
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150)
	projectile_type = /obj/item/projectile/bullet/armourpiercing

/obj/item/ammo_casing/c9mm/tox
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_URANIUM = 200)
	projectile_type = /obj/item/projectile/bullet/toxinbullet

/obj/item/ammo_casing/c9mm/inc
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_PLASMA = 200)
	projectile_type = /obj/item/projectile/bullet/incendiary/firebullet
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/c46x30mm
	desc = "A 4.6x30mm bullet casing."
	materials = list(MAT_METAL = 500)
	caliber = "4.6x30mm"
	projectile_type = /obj/item/projectile/bullet/weakbullet3/foursix
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_WEAK
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/c9mmte
	desc = "A 9mm TE bullet casing."
	materials = list(MAT_METAL = 500)
	caliber = "9mm TE"
	projectile_type = /obj/item/projectile/bullet/weakbullet4/c9mmte
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_WEAK
	muzzle_flash_range = MUZZLE_FLASH_RANGE_WEAK

/obj/item/ammo_casing/c46x30mm/ap
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150)
	projectile_type = /obj/item/projectile/bullet/weakbullet3/foursix/ap

/obj/item/ammo_casing/c46x30mm/tox
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_URANIUM = 200)
	projectile_type = /obj/item/projectile/bullet/weakbullet3/foursix/tox

/obj/item/ammo_casing/c46x30mm/inc
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_PLASMA = 200)
	projectile_type = /obj/item/projectile/bullet/incendiary/foursix
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/rubber45
	desc = "A .45 rubber bullet casing."
	icon_state = "r-casing"
	materials = list(MAT_METAL = 650)
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/midbullet_r
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/c45
	desc = "A .45 bullet casing."
	materials = list(MAT_METAL = 1500)
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/midbullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/c45/nostamina
	materials = list(MAT_METAL = 1500)
	projectile_type = /obj/item/projectile/bullet/midbullet3

/obj/item/ammo_casing/revolver/improvised
	name = "improvised shell"
	desc = "Full metal shell leaking oil. This is clearly an unreliable bullet."
	icon_state = "rev-improv-casing"
	materials = list(MAT_METAL = 100)
	caliber = ".257"
	projectile_type = /obj/item/projectile/bullet/weakbullet3/c257
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/revolver/improvised/phosphorus
	desc = "Full metal shell leaking oil and phosphorous. This is clearly an unreliable bullet."
	icon_state = "rev-phosphor-casing"
	projectile_type = /obj/item/projectile/bullet/weakbullet3/c257/phosphorus

/obj/item/ammo_casing/n762
	desc = "A 7.62x38mm bullet casing."
	materials = list(MAT_METAL = 4000)
	caliber = "7.62x38mm"
	projectile_type = /obj/item/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/caseless/magspear
	name = "magnetic spear"
	desc = "A reusable spear that is typically loaded into kinetic spearguns."
	projectile_type = /obj/item/projectile/bullet/reusable/magspear
	caliber = "spear"
	icon_state = "magspear"
	throwforce = 15 //still deadly when thrown
	throw_speed = 3
	muzzle_flash_color = null

/obj/item/ammo_casing/caseless/rocket
	name = "\improper PM-9HE"
	desc = "An 84mm High Explosive rocket. Fire at people and pray."
	caliber = "84mm"
	w_class = WEIGHT_CLASS_NORMAL //thats the rocket!
	icon_state = "84mm-he"
	projectile_type = /obj/item/projectile/bullet/a84mm_he
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'	// better than default casing but not ideal

/obj/item/ammo_casing/caseless/rocket/hedp
	name = "\improper PM-9HEDP"
	desc = "An 84mm High Explosive Dual Purpose rocket. Pointy end toward mechs and unarmed civilians."
	icon_state = "84mm-hedp"
	projectile_type = /obj/item/projectile/bullet/a84mm_hedp

/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A 12 gauge lead slug."
	icon_state = "slugshell"
	materials = list(MAT_METAL = 4000)
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	caliber = ".12"
	projectile_type = /obj/item/projectile/bullet/slug
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge buckshot shell."
	icon_state = "buckshotshell"
	projectile_type = /obj/item/projectile/bullet/pellet
	pellets = 6
	variance = 17

/obj/item/ammo_casing/shotgun/assassination
	name = "assassination shell"
	desc = "A specialist shrapnel shell that has been laced with a silencing toxin."
	materials = list(MAT_METAL = 1500, MAT_GLASS = 200)
	projectile_type = /obj/item/projectile/bullet/pellet/assassination
	muzzle_flash_effect = null
	icon_state = "buckshotshell"
	pellets = 6
	variance = 15

/obj/item/ammo_casing/shotgun/buckshot/nuclear
	projectile_type = /obj/item/projectile/bullet/pellet/nuclear

/obj/item/ammo_casing/shotgun/rubbershot
	name = "rubber shot"
	desc = "A shotgun casing filled with densely-packed rubber balls, used to incapacitate crowds from a distance."
	icon_state = "rubbershotshell"
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/item/projectile/bullet/pellet/rubber
	pellets = 6
	variance = 17

/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"
	desc = "A dart for use in shotguns. Can be injected with up to 30 units of any chemical."
	icon_state = "rubbershotshell"
	container_type = OPENCONTAINER
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	projectile_type = /obj/item/projectile/bullet/dart
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	can_be_box_inserted = FALSE


/obj/item/ammo_casing/shotgun/dart/Initialize(mapload)
	. = ..()
	create_reagents(30)


/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag slug"
	desc = "A weak beanbag slug for riot control."
	icon_state = "beanbagshell"
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/item/projectile/bullet/weakbullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/shotgun/beanbag/fake
	description_antag = "Специальный патрон для усыпления жертв. Крайне эффективен против целей с алкоголем внутри. Любой стан по противнику после выстрела дополнительно приводит ко сну, не позволяя ему кричать о помощи."
	projectile_type = /obj/item/projectile/bullet/weakbullet/booze

/obj/item/ammo_casing/shotgun/stunslug
	name = "taser slug"
	desc = "A stunning taser slug."
	icon_state = "stunslugshell"
	materials = list(MAT_METAL = 250)
	projectile_type = /obj/item/projectile/bullet/stunshot
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = "#FFFF00"

/obj/item/ammo_casing/shotgun/meteorshot
	name = "meteorshot shell"
	desc = "A shotgun shell rigged with CMC technology, which launches a massive slug when fired."
	icon_state = "meteorshotshell"
	projectile_type = /obj/item/projectile/bullet/meteorshot

/obj/item/ammo_casing/shotgun/breaching
	name = "breaching shell"
	desc = "An economic version of the meteorshot, utilizing similar technologies. Great for busting down doors."
	icon_state = "meteorshotshell"
	projectile_type = /obj/item/projectile/bullet/meteorshot/weak

/obj/item/ammo_casing/shotgun/pulseslug
	name = "pulse slug"
	desc = "A delicate device which can be loaded into a shotgun. The primer acts as a button which triggers the gain medium and fires a powerful \
	energy blast. While the heat and power drain limit it to one use, it can still allow an operator to engage targets that ballistic ammunition \
	would have difficulty with."
	icon_state = "pulseslugshell"
	projectile_type = /obj/item/projectile/beam/pulse/shot
	muzzle_flash_color = LIGHT_COLOR_DARKBLUE

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "An incendiary-coated shotgun slug."
	icon_state = "incendiaryshell"
	projectile_type = /obj/item/projectile/bullet/incendiary/shell
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/shotgun/frag12
	name = "FRAG-12 slug"
	desc = "A high explosive breaching round for a 12 gauge shotgun."
	icon_state = "frag12shell"
	projectile_type = /obj/item/projectile/bullet/frag12

/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath
	name = "dragonsbreath shell"
	desc = "A shotgun shell which fires a spread of incendiary pellets."
	icon_state = "dragonsbreathshell"
	projectile_type = /obj/item/projectile/bullet/incendiary/shell/dragonsbreath
	pellets = 4
	variance = 25
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/nuclear
	projectile_type = /obj/item/projectile/bullet/incendiary/shell/dragonsbreath/nuclear
	pellets = 6
	variance = 20

/obj/item/ammo_casing/shotgun/ion
	name = "ion shell"
	desc = "An advanced shotgun shell which uses a subspace ansible crystal to produce an effect similar to a standard ion rifle. \
	The unique properties of the crystal splot the pulse into a spread of individually weaker bolts."
	icon_state = "ionshell"
	projectile_type = /obj/item/projectile/ion/weak
	pellets = 4
	variance = 35
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = LIGHT_COLOR_LIGHTBLUE

/obj/item/ammo_casing/shotgun/laserslug
	name = "laser slug"
	desc = "An advanced shotgun shell that uses a micro laser to replicate the effects of a laser weapon in a ballistic package."
	icon_state = "laserslugshell"
	projectile_type = /obj/item/projectile/beam/laser/slug
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = LIGHT_COLOR_DARKRED

/obj/item/ammo_casing/shotgun/lasershot
	name = "laser shot"
	desc = "An advanced shotgun shell that uses a micro lasers to replicate the effects of a buckshot in laser appearance."
	icon_state = "lasershotshell"
	projectile_type = /obj/item/projectile/beam/laser/shot
	pellets = 6
	variance = 17
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = LIGHT_COLOR_DARKRED

/obj/item/ammo_casing/shotgun/bioterror
	name = "bioterror shell"
	desc = "A shotgun shell filled with deadly toxins."
	icon_state = "bioterrorshell"
	projectile_type = /obj/item/projectile/bullet/pellet/bioterror
	pellets = 4
	variance = 17

/obj/item/ammo_casing/shotgun/tranquilizer
	name = "tranquilizer darts"
	desc = "A tranquilizer round used to subdue individuals utilizing stimulants."
	icon_state = "tranquilizershell"
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	projectile_type = /obj/item/projectile/bullet/dart/syringe/tranquilizer
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/shotgun/flechette
	name = "flechette"
	desc = "A shotgun casing filled with tiny steel darts, used to penetrate armor. Beehive incoming!"
	icon_state = "flechetteshell"
	projectile_type = /obj/item/projectile/bullet/pellet/flechette
	pellets = 4
	variance = 13

/obj/item/ammo_casing/shotgun/improvised
	name = "improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards."
	icon_state = "improvisedshell"
	materials = list(MAT_METAL = 250)
	projectile_type = /obj/item/projectile/bullet/pellet/weak
	pellets = 10
	variance = 20
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/shotgun/improvised/overload
	name = "overloaded improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards. This one has been packed with even more \
	propellant. It's like playing russian roulette, with a shotgun."
	projectile_type = /obj/item/projectile/bullet/pellet/overload
	pellets = 4
	variance = 40
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/shotgun/techshell
	name = "unloaded technological shell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	icon_state = "techshell"
	materials = list(MAT_METAL = 1000, MAT_GLASS = 200)
	projectile_type = null

/obj/item/ammo_casing/a556
	desc = "A 5.56mm bullet casing."
	materials = list(MAT_METAL = 3250)
	caliber = "5.56mm"
	projectile_type = /obj/item/projectile/bullet/heavybullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/a545
	desc = "A 5.45x39mm bullet casing."
	caliber = "5.45x39mm"
	projectile_type = /obj/item/projectile/bullet/midbullet3
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/a545/fusty
	desc = "A fusty 5.45x39mm bullet casing."
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/item/projectile/bullet/f545
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/rocket
	name = "rocket shell"
	desc = "A high explosive designed to be fired from a launcher."
	icon_state = "rocketshell"
	materials = list(MAT_METAL = 10000)
	caliber = "rocket"
	projectile_type = /obj/item/missile
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/caseless
	desc = "A caseless bullet casing."

/obj/item/ammo_casing/caseless/fire(atom/target, mob/living/user, params, distro, quiet, zone_override = "", spread, atom/firer_source_atom)
	if(..())
		qdel(src)
		return TRUE
	return FALSE

/obj/item/ammo_casing/caseless/a75
	desc = "A .75 bullet casing."
	caliber = ".75"
	materials = list(MAT_METAL = 8000)
	projectile_type = /obj/item/projectile/bullet/gyro
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/a40mm
	name = "40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	icon_state = "40mmHE"
	materials = list(MAT_METAL = 8000)
	caliber = "40mm"
	projectile_type = /obj/item/projectile/bullet/a40mm
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/caseless/foam_dart
	name = "foam dart"
	desc = "It's nerf or nothing! Ages 8 and up."
	icon = 'icons/obj/weapons/toy.dmi'
	icon_state = "foamdart"
	materials = list(MAT_METAL = 10)
	caliber = "foam_force"
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart
	muzzle_flash_effect = null
	var/modified = FALSE
	harmful = FALSE


/obj/item/ammo_casing/caseless/foam_dart/update_icon_state()
	if(modified)
		icon_state = "foamdart_empty"
		if(BB)
			BB.icon_state = "foamdart_empty"
	else
		icon_state = initial(icon_state)
		if(BB)
			BB.icon_state = initial(BB.icon_state)


/obj/item/ammo_casing/caseless/foam_dart/update_desc(updates)
	. = ..()
	desc = modified ? "Its nerf or nothing! ... Although, this one doesn't look too safe." : initial(desc)


/obj/item/ammo_casing/caseless/foam_dart/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		add_fingerprint(user)
		var/obj/item/projectile/bullet/reusable/foam_dart/bullet = BB
		if(!bullet)
			to_chat(user, span_warning("The [name] has no bullet."))
			return ATTACK_CHAIN_PROCEED
		if(!modified)
			to_chat(user, span_warning("The [name] should be modified first."))
			return ATTACK_CHAIN_PROCEED
		if(bullet.pen)
			to_chat(user, span_warning("The [name] already has a pen inserted."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		harmful = TRUE
		I.forceMove(bullet)
		bullet.log_override = FALSE
		bullet.pen = I
		bullet.damage = 5
		bullet.nodamage = FALSE
		to_chat(user, span_notice("You have inserted [I] into [src]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/ammo_casing/caseless/foam_dart/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!BB)
		add_fingerprint(user)
		to_chat(user, span_warning("The [name] has no bullet."))
		return .
	if(modified)
		add_fingerprint(user)
		to_chat(user, span_warning("The [name] is already modified."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	modified = TRUE
	BB.damage_type = BRUTE
	update_icon()


/obj/item/ammo_casing/caseless/foam_dart/attack_self(mob/living/user)
	var/obj/item/projectile/bullet/reusable/foam_dart/FD = BB
	if(FD.pen)
		FD.damage = initial(FD.damage)
		FD.nodamage = initial(FD.nodamage)
		user.put_in_hands(FD.pen)
		to_chat(user, span_notice("You remove [FD.pen] from [src]."))
		FD.pen = null

/obj/item/ammo_casing/caseless/foam_dart/riot
	name = "riot foam dart"
	desc = "Whose smart idea was it to use toys as crowd control? Ages 18 and up."
	icon_state = "foamdart_riot"
	materials = list(MAT_METAL = 650)
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart/riot

/obj/item/ammo_casing/caseless/foam_dart/sniper
	name = "foam sniper dart"
	desc = "For the big nerf! Ages 8 and up."
	icon_state = "foamdartsniper"
	materials = list(MAT_METAL = 20)
	caliber = "foam_force_sniper"
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart/sniper


/obj/item/ammo_casing/caseless/foam_dart/sniper/update_icon_state()
	if(modified)
		icon_state = "foamdartsniper_empty"
		if(BB)
			BB.icon_state = "foamdartsniper_empty"
	else
		icon_state = initial(icon_state)
		if(BB)
			BB.icon_state = initial(BB.icon_state)


/obj/item/ammo_casing/caseless/foam_dart/sniper/update_desc(updates)
	. = ..()
	desc = modified ? "Its nerf or nothing! ... Although, this one doesn't look too safe." : initial(desc)


/obj/item/ammo_casing/caseless/foam_dart/sniper/riot
	name = "riot foam sniper dart"
	desc = "For the bigger brother of the crowd control toy. Ages 18 and up."
	icon_state = "foamdartsniper_riot"
	materials = list(MAT_METAL = 1800)
	caliber = "foam_force_sniper"
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart/sniper/riot

/obj/item/ammo_casing/cap
	desc = "A cap for children toys."
	materials = list(MAT_METAL = 10)
	caliber = "cap"
	projectile_type = /obj/item/projectile/bullet/cap
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/laser
	desc = "An experimental laser casing."
	icon_state = "lasercasing"
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 200)
	caliber = "laser"
	projectile_type = /obj/item/projectile/beam/laser
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash/energy
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_WEAK
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = LIGHT_COLOR_DARKRED
