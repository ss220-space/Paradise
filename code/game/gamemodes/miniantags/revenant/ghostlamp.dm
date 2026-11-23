/obj/structure/revenant_lamp
	name = "spirit lamp"
	desc = "Огромная жуткая лампа. Вам не хочется находиться рядом с ней."
	icon = 'icons/effects/32x64.dmi'
	icon_state = "revenantlamp"
	light_range = 2
	light_color = "#9f00fc"
	layer = LARGE_MOB_LAYER
	density = TRUE
	anchored = TRUE
	max_integrity = 150
	var/wisp_max = 5
	var/wisp_per_creation = 1
	var/current_wisps = 0
	var/list/wisps = list()
	var/max_wisp_per_level = 5
	var/stamina_damage_min = 2
	var/slowdown = 0.1
	var/mob/living/simple_animal/revenant/revenant_owner
	var/datum/action/cooldown/spell/aoe/revenant/soul_lamp/spell
	var/max_stamina_damage = 90
	var/wisp_heal = 10
	var/wisp_creation_time = 60 SECONDS
	var/light_increase = 5
	var/integrity_increase = 150
	var/flame_cd = 20 SECONDS
	COOLDOWN_DECLARE(wisp_creation)
	COOLDOWN_DECLARE(flame_cooldown)

/obj/structure/revenant_lamp/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(!COOLDOWN_FINISHED(src, flame_cooldown))
		return
	revenant_fire_ring(src.loc, 3)
	for(var/mob/living/carbon/human/target in range(3))
		target.apply_damage(10, BURN)
		target.apply_status_effect(/datum/status_effect/cursed_flame, 5 SECONDS, revenant_owner)
		COOLDOWN_START(src, flame_cooldown, flame_cd)

/obj/structure/revenant_lamp/Destroy(force)
	. = ..()
	QDEL_LIST(wisps)
	revenant_owner = null
	spell = null

/obj/structure/revenant_lamp/get_ru_names()
	return alist(
		NOMINATIVE = "призрачный маяк",
		GENITIVE = "призрачного маяка",
		DATIVE = "призрачному маяку",
		ACCUSATIVE = "призрачный маяк",
		INSTRUMENTAL = "призрачным маяком",
		PREPOSITIONAL = "призрачном маяке",
	)

/obj/structure/revenant_lamp/Click(location, control, params)
	. = ..()
	if(!isobserver(usr) || !length(wisps))
		return
	var/mob/living/simple_animal/hostile/wisp/wisp = pick(wisps)
	wisp.Click(location, control, params)
	current_wisps--
	LAZYREMOVE(wisps, wisp)

/obj/structure/revenant_lamp/CanAllowThrough(atom/movable/mover, border_dir)
	return ..() || istype(mover, /mob/living/simple_animal/revenant)

/obj/structure/revenant_lamp/Initialize(mapload, mob/owner, datum/action/cooldown/spell/aoe/revenant/soul_lamp/lamp_spell)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	spell = lamp_spell
	revenant_owner = owner

/obj/structure/revenant_lamp/process(seconds_per_tick)
	for(var/mob/living/carbon/human/target in view(light_range, src))
		if(target.getStaminaLoss() >= max_stamina_damage)
			continue
		var/staminadamage = rand(stamina_damage_min, stamina_damage_min + 2)
		target.adjustStaminaLoss(staminadamage)
		var/essence = round(staminadamage / 2)
		revenant_owner.change_essence_amount(essence, TRUE)
		revenant_owner.change_essence_amount(count_bodies(), TRUE)
	for(var/mob/living/simple_animal/hostile/wisp/wisp in range(light_range, src))
		wisp.adjustHealth(-wisp_heal)
	if(COOLDOWN_FINISHED(src, wisp_creation))
		create_wisps()
		COOLDOWN_START(src, wisp_creation, wisp_creation_time)

/obj/structure/revenant_lamp/proc/create_wisps()
	var/slots_avaible = wisp_max-current_wisps
	var/addwisps = min(rand(wisp_per_creation, wisp_per_creation+1), slots_avaible)
	for(var/i in 1 to addwisps)
		var/mob/living/simple_animal/hostile/wisp/wisp = new(src)
		LAZYADD(wisps, wisp)
		INVOKE_ASYNC(wisp, TYPE_PROC_REF(/atom/movable, orbit), src, rand(30, 40), rand(0, 1))
	current_wisps += addwisps

/obj/structure/revenant_lamp/proc/update_level()
	var/remove_integrity = max_integrity - obj_integrity
	max_integrity += integrity_increase
	obj_integrity = max_integrity - remove_integrity
	light_range += light_increase
	wisp_max += max_wisp_per_level
	stamina_damage_min++
	flame_cd -= flame_cd/2
	update_light()

/obj/structure/revenant_lamp/proc/count_bodies()
	var/counted = 0
	for(var/mob/living/carbon/human/dead in range(light_range))
		if(dead.stat == DEAD)
			counted++
	return counted

/mob/living/simple_animal/hostile/wisp
	name = "will-o'-the-wisp"
	desc = "Маленький огонёк призрачного пламени. Милый, но опасный."
	icon = 'icons/effects/revenant.dmi'
	icon_state = "wisp"
	faction = list("Revenant")
	speed = 0
	maxHealth = 30
	health = 30
	melee_damage_lower = 5
	melee_damage_upper = 10
	melee_damage_type = STAMINA
	obj_damage = 5
	del_on_death = TRUE

/mob/living/simple_animal/hostile/wisp/Click(location, control, params)
	. = ..()
	if(!isobserver(usr) || ckey)
		return
	possess_by_player(usr.key)

/mob/living/simple_animal/hostile/wisp/get_ru_names()
	return alist(
		NOMINATIVE = "блуждающий огонёк",
		GENITIVE = "блуждающего огонька",
		DATIVE = "блуждающему огоньку",
		ACCUSATIVE = "блуждающий огонёк",
		INSTRUMENTAL = "блуждающим огоньком",
		PREPOSITIONAL = "блуждающем огоньке",
	)

/mob/living/simple_animal/hostile/wisp/AttackingTarget()
	if(ishuman(target) && prob(10))
		var/mob/living/carbon/human/human = target
		human.apply_status_effect(/datum/status_effect/cursed_flame, 5 SECONDS, null)
	return ..()
