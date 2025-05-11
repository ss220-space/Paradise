/obj/projectile/shrapnel
	name = "shrapnel"
	icon = 'icons/obj/shards.dmi'
	throwforce = 14
	throw_speed =  EMBED_THROWSPEED_THRESHOLD
	sharp = TRUE
	damage = 14
	range = 20
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

/obj/projectile/shrapnel/Initialize(mapload)
	. = ..()
	icon_state = pick("shrapnel1", "shrapnel2", "shrapnel3")
	ADD_TRAIT(src, TRAIT_SHRAPNEL, INNATE_TRAIT)
