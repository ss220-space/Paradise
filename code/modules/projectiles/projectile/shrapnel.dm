/obj/projectile/shrapnel
	name = "shrapnel"
	icon = 'icons/obj/shards.dmi'
	throw_speed =  EMBED_THROWSPEED_THRESHOLD
	sharp = TRUE
	damage = 10
	range = 20
	armour_penetration = 30
	dismemberment = 5
	ricochets_max = 2
	ricochet_chance = 70
	hitsound = 'sound/weapons/pierce.ogg'
	ru_names = list(
		NOMINATIVE = "шрапнель",
		GENITIVE = "шрапнели",
		DATIVE = "шрапнели",
		ACCUSATIVE = "шрапнель",
		INSTRUMENTAL = "шрапнелью",
		PREPOSITIONAL = "шрапнели"
	)
	var/embedded_type = /obj/item/embedded/shrapnel

/obj/projectile/shrapnel/Initialize(mapload)
	. = ..()
	icon_state = pick("shrapnel1", "shrapnel2", "shrapnel3")
	ADD_TRAIT(src, TRAIT_SHRAPNEL, INNATE_TRAIT)

/obj/projectile/shrapnel/shrapnel_hit(atom/target)
	var/obj/item/embedded/shrapnel = new embedded_type(src)
	shrapnel.throwforce = damage
	shrapnel.icon = icon
	shrapnel.icon_state = icon_state
	shrapnel.throw_speed = throw_speed
	shrapnel.armour_penetration = armour_penetration
	shrapnel.sharp = sharp
	target.hitby(shrapnel, skipcatch = TRUE)
	qdel(src)

/obj/item/embedded/shrapnel
	name = "shrapnel"
	ru_names = list(
		NOMINATIVE = "шрапнель",
		GENITIVE = "шрапнели",
		DATIVE = "шрапнели",
		ACCUSATIVE = "шрапнель",
		INSTRUMENTAL = "шрапнелью",
		PREPOSITIONAL = "шрапнели"
	)
	icon = 'icons/obj/shards.dmi'
	throwforce = 10
	throw_speed =  EMBED_THROWSPEED_THRESHOLD
	embed_chance = 100
	embedded_fall_chance = 0
	w_class = WEIGHT_CLASS_SMALL
	sharp = TRUE
	hitsound = 'sound/weapons/pierce.ogg'

/obj/item/embedded/shrapnel/New()
	..()
	icon_state = pick("shrapnel1", "shrapnel2", "shrapnel3")
