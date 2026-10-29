/obj/structure/revenant_lamp
	name = "Призрачный маяк"
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
	var/stamina_damage_min = 2
	var/slowdown = 0.1
	var/mob/living/simple_animal/revenant/revenant_owner
	var/datum/action/cooldown/spell/aoe/revenant/soul_lamp/spell
	COOLDOWN_DECLARE(wisp_creation)

/obj/structure/revenant_lamp/Click(location, control, params)
	. = ..()
	if(isobserver(usr) && current_wisps > 0)
		current_wisps--
		var/mob/living/simple_animal/hostile/wisp/wisp = new(loc)
		wisp.possess_by_player(usr.key)
		update_orbiting()

/obj/structure/revenant_lamp/CanAllowThrough(atom/movable/mover, border_dir)
	return ..() || istype(mover, /mob/living/simple_animal/revenant)

/obj/structure/revenant_lamp/Initialize(mapload, mob/owner, datum/action/cooldown/spell/aoe/revenant/soul_lamp/lamp_spell)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	spell = lamp_spell

/obj/structure/revenant_lamp/process(seconds_per_tick)
	for(var/mob/living/carbon/human/target in view(light_range, src))
		if(target.getStaminaLoss() >= 90)
			continue
		var/staminadamage = rand(stamina_damage_min, stamina_damage_min+2)
		target.adjustStaminaLoss(staminadamage)
		var/essence = round(staminadamage/2)
		revenant_owner.change_essence_amount(essence)
		revenant_owner.change_essence_amount(count_bodies())
	for(var/mob/living/simple_animal/hostile/wisp/wisp in range(light_range, src))
		wisp.adjustHealth(-10)
	if(COOLDOWN_FINISHED(src, wisp_creation))
		create_wisps()
		COOLDOWN_START(src, wisp_creation, 60 SECONDS)

/obj/structure/revenant_lamp/proc/create_wisps()
	var/slots_avaible = wisp_max-current_wisps
	var/addwisps = min(rand(wisp_per_creation, wisp_per_creation+1), slots_avaible)
	current_wisps += addwisps
	update_orbiting()

/obj/structure/revenant_lamp/proc/update_orbiting()
	for(var/obj/effect/wisp/wisp in orbiters)
		qdel(wisp)
	for(var/i in 1 to current_wisps)
		var/obj/effect/wisp/wisp = new /obj/effect/wisp(src)
		wisp.light_range = 0
		wisp.orbit(src, radius=30)

/obj/structure/revenant_lamp/proc/update_level()
	var/remove_integrity = max_integrity - obj_integrity
	max_integrity += 150
	obj_integrity = max_integrity - remove_integrity
	light_range += 5
	wisp_max += 5
	stamina_damage_min += 1
	update_light()

/obj/structure/revenant_lamp/proc/count_bodies()
	var/counted = 0
	for(var/mob/living/carbon/human/dead in range(light_range))
		if(dead.stat == DEAD)
			counted++
	return counted

/mob/living/simple_animal/hostile/wisp
	name = "блуждающий огонёк"
	desc = "Маленький огонёк призрачного пламени. Милый, но опасный."
	icon = 'icons/effects/revenant.dmi'
	icon_state = "wisp"
	speed = 0
	maxHealth = 30
	health = 30
	melee_damage_lower = 5
	melee_damage_upper = 10
	melee_damage_type = BURN

/mob/living/simple_animal/hostile/wisp/AttackingTarget()
	if(ishuman(target) && prob(10))
		var/mob/living/carbon/human/human = target
		human.apply_status_effect(/datum/status_effect/cursed_flame, 5 SECONDS, null)
	. = ..()
