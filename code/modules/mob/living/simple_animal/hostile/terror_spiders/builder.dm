

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 BUILDER TERROR --------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: similar to alien drona
// -------------: AI: wraps web, protects hive
// -------------: SPECIAL: wraps web realy fast
// -------------: TO FIGHT IT: shoot it from range. Kite it.

/mob/living/simple_animal/hostile/poison/terror_spider/builder
	name = "Builder of Terror"
	desc = "An ominous-looking blue spider, "
	gender = MALE
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_drone"
	icon_living = "terror_drone"
	icon_dead = "terror_drone_dead"
	maxHealth = 100
	health = 100
	regeneration = 1
	delay_web = 10
	melee_damage_lower = 5
	melee_damage_upper = 10
	spider_opens_doors = 2
	ranged = 1
	rapid = 2
	ranged_cooldown_time = 40
	speed = 0.3
	projectilesound = 'sound/creatures/terrorspiders/spit.ogg'
	projectiletype = /obj/item/projectile/terrorspider/builder
	web_type = /obj/structure/spider/terrorweb/queen/builder
	ventcrawler = 0
	can_wrap = FALSE
	spider_intro_text = "Будучи Строителем Ужаса, ваша задача - постройка и защита гнезда. Бесконечно плетите паутину, используйте свои замедляющие плевки и замораживающие укусы для защиты яиц и яйцекладущих пауков."
	var/enrage = 0

/mob/living/simple_animal/hostile/poison/terror_spider/builder/spider_specialattack(mob/living/carbon/human/L, poisonable)
	L.slowed = 2
	if(!poisonable)
		return ..()
	if(L.reagents.has_reagent("frostoil", 100))
		return ..()
	var/inject_target = pick("chest", "head")
	if(L.stunned || L.can_inject(null, FALSE, inject_target, FALSE))
		L.reagents.add_reagent("frostoil", 20)
		visible_message("<span class='danger'>[src] buries its long fangs deep into the [inject_target] of [target]!</span>")
	else
		L.reagents.add_reagent("frostoil", 10)
		visible_message("<span class='danger'>[src] buries its long fangs deep into the [inject_target] of [target]!</span>")
	L.attack_animal(src)

/obj/structure/spider/terrorweb/queen/builder
	max_integrity = 40
	opacity = 1
	name = "drone web"
	desc = "Extremely thick web."

/obj/item/projectile/terrorspider/builder
	name = "drone acid"
	damage = 0
	stamina = 11
	damage_type = BURN

/obj/item/projectile/terrorspider/drone/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.slowed = 1

	return ..()
