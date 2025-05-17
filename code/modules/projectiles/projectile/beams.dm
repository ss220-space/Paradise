/obj/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "laser"
	eyeblur = 4 SECONDS
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	reflectability = REFLECTABILITY_ENERGY
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_DARKRED
	ricochets_max = 50	//Honk!
	ricochet_chance = 80

/obj/projectile/beam/laser

/obj/projectile/beam/laser/light
	damage = 15

/obj/projectile/beam/laser/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 50
	hitsound = 'sound/weapons/resonator_blast.ogg'

/obj/projectile/beam/laser/slug
	name = "laser slug beam"
	damage = 50
	stamina = 33

/obj/projectile/beam/laser/shot
	name = "laser shot beam"
	icon_state = "lasershot"
	damage = 15

/obj/projectile/beam/practice
	name = "practice laser"
	damage = 0
	hitsound = 'sound/weapons/tap.ogg'
	nodamage = TRUE
	log_override = TRUE

/obj/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5

/obj/projectile/beam/xray
	name = "x-ray beam"
	icon_state = "xray"
	damage = 10
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	tile_dropoff = 0.75
	irradiate = 40
	forcedodge = -1
	range = 15
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN

/obj/projectile/beam/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	damage = 25
	shockbull = TRUE
	damage_type = STAMINA
	flag = "energy"
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_CYAN

/obj/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	var/gib_allowed = TRUE
	hitsound = 'sound/weapons/resonator_blast.ogg'
	hitsound_wall = 'sound/weapons/resonator_blast.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_DARKBLUE

/obj/projectile/beam/pulse/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target, /turf) || isstructure(target) || ismachinery(target))
		target.ex_act(2)
	..()

/obj/projectile/beam/pulse/on_hit(atom/target)
	. = ..()
	if(gib_allowed && isliving(target))
		var/mob/living/L = target
		if(L.health <= -200)
			L.visible_message(span_danger("[L] has been terminated!"))
			L.dust()

/obj/projectile/beam/pulse/shot
	gib_allowed = FALSE
	damage = 40

/obj/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30
	hitsound = 'sound/weapons/resonator_blast.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN

/obj/projectile/beam/emitter/singularity_pull()
	return //don't want the emitters to miss

/obj/projectile/beam/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = 'sound/weapons/tap.ogg'
	nodamage = TRUE
	damage = 0
	damage_type = STAMINA
	flag = "laser"
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	log_override = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_DARKBLUE

/obj/projectile/beam/lasertag/on_hit(atom/target, blocked = 0)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.apply_damage(34, STAMINA)
	return 1

/obj/projectile/beam/lasertag/omni
	name = "laser tag beam"
	icon_state = "omnilaser"

/obj/projectile/beam/lasertag/redtag
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_DARKRED

/obj/projectile/beam/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)
	light_color = LIGHT_COLOR_BLUE

/obj/projectile/beam/sniper
	name = "sniper beam"
	icon_state = "sniperlaser"
	//speed = 0.75
	//range = 100
	damage = 60
	hitsound = 'sound/weapons/resonator_blast.ogg'
	weaken = 4 SECONDS
	stutter = 4 SECONDS
	stamina = 40
	forced_accuracy = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_PINK

/obj/projectile/beam/podsniper/disabler
	name = "sniper disabler beam"
	icon_state = "LSR_disabler"
	damage = 40
	damage_type = STAMINA
	hitsound = 'sound/weapons/resonator_blast.ogg'
	flag = ENERGY
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_CYAN

/obj/projectile/beam/podsniper/laser
	name = "sniper laser beam"
	icon_state = "LSR_kill"
	damage = 45
	damage_type = BURN
	hitsound = 'sound/weapons/resonator_blast.ogg'
	flag = LASER
	eyeblur = 4 SECONDS
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_DARKRED

/obj/projectile/beam/immolator
	name = "immolation beam"
	hitsound = 'sound/weapons/plasma_cutter.ogg'

/obj/projectile/beam/immolator/strong
	name = "heavy immolation beam"
	damage = 45
	icon_state = "heavylaser"

/obj/projectile/beam/immolator/weak
	name = "light immolation beam"
	damage = 8
	icon_state = "scatterlaser"

/obj/projectile/beam/immolator/mech
	name = "mecha immolation beam"
	damage = 15

/obj/projectile/beam/immolator/on_hit(var/atom/target, var/blocked = 0)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(1)
		M.IgniteMob()

/obj/projectile/beam/instakill
	name = "instagib laser"
	icon_state = "purple_laser"
	damage = 200
	hitsound = 'sound/weapons/resonator_blast.ogg'
	damage_type = BURN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_PURPLE

/obj/projectile/beam/instakill/blue
	icon_state = "blue_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_DARKBLUE

/obj/projectile/beam/instakill/red
	icon_state = "red_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_DARKRED

/obj/projectile/beam/instakill/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.visible_message("<span class='danger'>[L] explodes!</span>")
		L.gib()

/obj/projectile/beam/dominator/eliminator
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	icon_state = "blue_laser"
	light_color = LIGHT_COLOR_LIGHT_CYAN

/obj/projectile/beam/dominator/slaughter
	name = "execution slaughter beam"
	icon_state = "blue_laser"
	damage = 50
	stamina = 33
	damage_type = BURN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_LIGHT_CYAN
	hitsound = 'sound/weapons/resonator_blast.ogg'
	hitsound_wall = 'sound/weapons/sear.ogg'

/obj/projectile/beam/dominator/paralyzer
	name = "paralyzer beam"
	icon_state = "omnilaser"
	damage = 25
	shockbull = TRUE
	damage_type = STAMINA
	flag = "energy"
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	hitsound_wall = 'sound/weapons/sear.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_LIGHT_CYAN


/obj/projectile/beam/anomaly
	name = "луч стабилизатора аномалий"
	ru_names = list(
		NOMINATIVE = "луч стабилизатора аномалий", \
		GENITIVE = "луча стабилизатора аномалий", \
		DATIVE = "лучу стабилизатора аномалий", \
		ACCUSATIVE = "луч стабилизатора аномалий", \
		INSTRUMENTAL = "лучом стабилизатора аномалий", \
		PREPOSITIONAL = "луче стабилизатора аномалий"
	)
	icon_state = "xray" // Looks mostly like "blue/red_laser" in green colour.
	damage = 0
	hitsound = 'sound/weapons/resonator_blast.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	/// The amount by which the stability of the anomaly changes upon impact.
	var/stability_delta = 0
	/// The distance the anomaly is pulled towards the shooter upon impact.
	var/pull_strenght = 0
	/// The amount of time that beam increase the blocking of the anomaly's normal movement.
	var/move_block = 0
	/// The amount of time that beam increase the blocking of the anomaly's impulsive movement.
	var/move_impulces_block = 0
	/// The amount by which the strength of the anomaly's effects is temporarily reduced.
	var/anom_weaken = 0
	/// The moment at which the reduction in the effects of the anomaly will be reset.
	var/weaken_time = 0

/obj/projectile/beam/anomaly/on_hit(atom/target, blocked, hit_zone)
	if(!isanomaly(target))
		return ..()

	do_sparks(clamp(abs(stability_delta) * 2, 3, 10))
	var/obj/effect/anomaly/anomaly = target
	if(anomaly.tier != 4 || prob(50))
		anomaly.stability = clamp(anomaly.stability + stability_delta, 0, 100)

	anomaly.move_moment = max(world.time + move_block, anomaly.move_moment)
	anomaly.move_impulse_moment = max(world.time + move_impulces_block, anomaly.move_impulse_moment)
	if(anom_weaken)
		anomaly.weaken = anom_weaken
		anomaly.weaken_moment = world.time + weaken_time

	INVOKE_ASYNC(anomaly, TYPE_PROC_REF(/obj/effect/anomaly, go_to), get_turf(firer_source_atom), pull_strenght)
	return TRUE

/obj/projectile/beam/anomaly/stabilizer
	name = "стабилизирующий луч"
	ru_names = list(
		NOMINATIVE = "стабилизирующий луч", \
		GENITIVE = "стабилизирующего луча", \
		DATIVE = "стабилизирующему лучу", \
		ACCUSATIVE = "стабилизирующий луч", \
		INSTRUMENTAL = "стабилизирующим лучом", \
		PREPOSITIONAL = "стабилизирующем луче"
	)
	icon_state = "bluelaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/projectile/beam/anomaly/destabilizer
	name = "дестабилизирующий луч"
	ru_names = list(
		NOMINATIVE = "дестабилизирующий луч", \
		GENITIVE = "дестабилизирующего луча", \
		DATIVE = "дестабилизирующему лучу", \
		ACCUSATIVE = "дестабилизирующий луч", \
		INSTRUMENTAL = "дестабилизирующим лучом", \
		PREPOSITIONAL = "дестабилизирующем луче"
	)
	icon_state = "laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED
