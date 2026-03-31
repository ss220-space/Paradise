/obj/projectile/energy/vortex_blast
	name = "vortex blast"
	damage = 2
	range = 5
	icon_state = "magspear"
	hitsound = 'sound/weapons/sear.ogg' //Gets a bit spamy, suppressed is needed to suffer less
	hitsound_wall = null
	suppressed = TRUE

/obj/projectile/energy/vortex_blast/get_ru_names()
	return list(
		NOMINATIVE = "вортекс-выстрел",
		GENITIVE = "вортекс-выстрела",
		DATIVE = "вортекс-выстрелу",
		ACCUSATIVE = "вортекс-выстрел",
		INSTRUMENTAL = "вортекс-выстрелом",
		PREPOSITIONAL = "вортекс-выстреле",
	)

/obj/projectile/energy/vortex_blast/prehit(atom/target)
	. = ..()
	if(ishuman(target))
		return
	if(isliving(target))
		damage *= 6 //Up damage if not a human as we are not doing shenanigins
		return
	damage *= 15 //objects tend to fall apart as atoms are ripped up

/obj/projectile/energy/vortex_blast/on_hit(atom/target, blocked = 0)
	if(blocked >= 100)
		return ..()
	if(ishuman(target))
		var/mob/living/carbon/human/livivng_target = target
		var/obj/item/organ/external/affecting = livivng_target.get_organ(ran_zone(def_zone))
		livivng_target.apply_damage(2, BRUTE, affecting, livivng_target.run_armor_check(affecting, ENERGY))
		livivng_target.apply_damage(2, TOX, affecting, livivng_target.run_armor_check(affecting, ENERGY))
		livivng_target.apply_damage(2, CLONE, affecting, livivng_target.run_armor_check(affecting, ENERGY))
		livivng_target.adjustBrainLoss(3)
	..()
