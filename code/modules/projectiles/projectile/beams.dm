/obj/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 23
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "laser"
	eyeblur = 4 SECONDS
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	reflectability = REFLECTABILITY_ENERGY
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_color = COLOR_SOFT_RED
	ricochets_max = 50	//Honk!
	ricochet_chance = 80

/obj/projectile/beam/get_ru_names()
	return list(
		NOMINATIVE = "лазер",
		GENITIVE = "лазера",
		DATIVE = "лазеру",
		ACCUSATIVE = "лазер",
		INSTRUMENTAL = "лазером",
		PREPOSITIONAL = "лазере",
	)

/obj/projectile/beam/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/projectile/beam/laser/light
	damage = 18

/obj/projectile/beam/laser/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 50
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser
	hitsound = 'sound/weapons/resonator_blast.ogg'

/obj/projectile/beam/laser/heavylaser/get_ru_names()
	return list(
		NOMINATIVE = "мощный лазер",
		GENITIVE = "мощного лазера",
		DATIVE = "мощному лазеру",
		ACCUSATIVE = "мощный лазер",
		INSTRUMENTAL = "мощным лазером",
		PREPOSITIONAL = "мощном лазере",
	)

/obj/projectile/beam/laser/slug
	name = "laser slug beam"
	damage = 50
	stamina = 33

/obj/projectile/beam/laser/slug/get_ru_names()
	return list(
		NOMINATIVE = "лазерный импульс",
		GENITIVE = "лазерного импульса",
		DATIVE = "лазерному импульсу",
		ACCUSATIVE = "лазерный импульс",
		INSTRUMENTAL = "лазерным импульсом",
		PREPOSITIONAL = "лазерном импульсе",
	)

/obj/projectile/beam/laser/shot
	name = "laser shot beam"
	icon_state = "lasershot"
	damage = 15

/obj/projectile/beam/laser/shot/get_ru_names()
	return list(
		NOMINATIVE = "лазерная дробь",
		GENITIVE = "лазерной дроби",
		DATIVE = "лазерной дроби",
		ACCUSATIVE = "лазерную дробь",
		INSTRUMENTAL = "лазерной дробью",
		PREPOSITIONAL = "лазерной дроби",
	)

/obj/projectile/beam/practice
	name = "practice laser"
	damage = 0
	hitsound = 'sound/weapons/tap.ogg'
	nodamage = TRUE
	log_override = TRUE

/obj/projectile/beam/practice/get_ru_names()
	return list(
		NOMINATIVE = "безвредный лазер",
		GENITIVE = "безвредного лазера",
		DATIVE = "безвредному лазеру",
		ACCUSATIVE = "безвредный лазер",
		INSTRUMENTAL = "безвредным лазером",
		PREPOSITIONAL = "безвредном лазере",
	)

/obj/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5

/obj/projectile/beam/scatter/get_ru_names()
	return list(
		NOMINATIVE = "лазерная гранула",
		GENITIVE = "лазерной гранулы",
		DATIVE = "лазерной грануле",
		ACCUSATIVE = "лазерную гранулу",
		INSTRUMENTAL = "лазерной гранулой",
		PREPOSITIONAL = "лазерной грануле",
	)

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
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/projectile/beam/xray/get_ru_names()
	return list(
		NOMINATIVE = "рентгеновский луч",
		GENITIVE = "рентгеновского луча",
		DATIVE = "рентгеновскому лучу",
		ACCUSATIVE = "рентгеновский луч",
		INSTRUMENTAL = "рентгеновским лучом",
		PREPOSITIONAL = "рентгеновском луче",
	)

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
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/projectile/beam/disabler/get_ru_names()
	return list(
		NOMINATIVE = "дизейблер",
		GENITIVE = "дизейблера",
		DATIVE = "дизейблеру",
		ACCUSATIVE = "дизейблер",
		INSTRUMENTAL = "дизейблером",
		PREPOSITIONAL = "дизейблере",
	)

/obj/projectile/beam/specter/laser
	name = "specter laser beam"
	damage = 25

/obj/projectile/beam/specter/disabler
	name = "specter paralyzer beam"
	icon_state = "omnilaser"
	damage = 30
	shockbull = TRUE
	damage_type = STAMINA
	flag = "energy"
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	hitsound_wall = 'sound/weapons/sear.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_LIGHT_CYAN

/obj/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	var/gib_allowed = TRUE
	hitsound = 'sound/weapons/resonator_blast.ogg'
	hitsound_wall = 'sound/weapons/resonator_blast.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse

/obj/projectile/beam/pulse/get_ru_names()
	return list(
		NOMINATIVE = "импульсный заряд",
		GENITIVE = "импульсного заряда",
		DATIVE = "импульсному заряду",
		ACCUSATIVE = "импульсный заряд",
		INSTRUMENTAL = "импульсным зарядом",
		PREPOSITIONAL = "импульсном заряде",
	)

/obj/projectile/beam/pulse/hitscan
	impact_effect_type = null
	light_color = null
	hitscan = TRUE
	hitscan_light_intensity = 3
	hitscan_light_color_override = LIGHT_COLOR_BLUE
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = LIGHT_COLOR_BLUE
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = LIGHT_COLOR_BLUE

/obj/projectile/beam/pulse/on_hit(atom/target, blocked = 0)
	if(istype(target, /turf) || isstructure(target) || ismachinery(target))
		target.ex_act(EXPLODE_HEAVY)
	return ..()

/obj/projectile/beam/pulse/on_hit(atom/target)
	. = ..()
	if(gib_allowed && isliving(target))
		var/mob/living/L = target
		if(L.health <= -200)
			L.visible_message(span_danger("Импульсный заряд превращает [L.declent_ru(ACCUSATIVE)] в облако пепла!"))
			L.dust()

/obj/projectile/beam/pulse/shot
	gib_allowed = FALSE
	damage = 40

/obj/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 33
	hitsound = 'sound/weapons/resonator_blast.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN

/obj/projectile/beam/emitter/get_ru_names()
	return list(
		NOMINATIVE = "импульс излучателя",
		GENITIVE = "импульса излучателя",
		DATIVE = "импульсу излучателя",
		ACCUSATIVE = "импульс излучателя",
		INSTRUMENTAL = "импульсом излучателя",
		PREPOSITIONAL = "импульсе излучателя",
	)

/obj/projectile/beam/emitter/hitscan
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/laser/emitter
	tracer_type = /obj/effect/projectile/tracer/laser/emitter
	impact_type = /obj/effect/projectile/impact/laser/emitter
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_color_override = COLOR_LIME
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = COLOR_LIME
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = COLOR_LIME

/obj/projectile/beam/emitter/singularity_pull()
	return //don't want the emitters to miss

/obj/projectile/beam/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = 'sound/weapons/tap.ogg'
	nodamage = TRUE
	damage = 0
	damage_type = STAMINA
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	log_override = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_DARK_BLUE

/obj/projectile/beam/lasertag/get_ru_names()
	return list(
		NOMINATIVE = "лазертаг",
		GENITIVE = "лазертага",
		DATIVE = "лазертагу",
		ACCUSATIVE = "лазертаг",
		INSTRUMENTAL = "лазертагом",
		PREPOSITIONAL = "лазертаге",
	)

/obj/projectile/beam/lasertag/on_hit(atom/target, blocked = 0)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.apply_damage(34, STAMINA)
	return 1

/obj/projectile/beam/lasertag/redtag
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = COLOR_SOFT_RED
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/projectile/beam/lasertag/redtag/hitscan
	hitscan = TRUE

/obj/projectile/beam/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

/obj/projectile/beam/lasertag/bluetag/hitscan
	hitscan = TRUE

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

/obj/projectile/beam/sniper/get_ru_names()
	return list(
		NOMINATIVE = "снайперский луч",
		GENITIVE = "снайперского луча",
		DATIVE = "снайперскому лучу",
		ACCUSATIVE = "снайперский луч",
		INSTRUMENTAL = "снайперским лучом",
		PREPOSITIONAL = "снайперском луче",
	)

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

/obj/projectile/beam/podsniper/disabler/get_ru_names()
	return list(
		NOMINATIVE = "луч снайперского дизейблера",
		GENITIVE = "луча снайперского дизейблера",
		DATIVE = "лучу снайперского дизейблера",
		ACCUSATIVE = "луч снайперского дизейблера",
		INSTRUMENTAL = "лучом снайперского дизейблера",
		PREPOSITIONAL = "луче снайперского дизейблера",
	)

/obj/projectile/beam/podsniper/laser
	name = "sniper laser beam"
	icon_state = "LSR_kill"
	damage = 45
	hitsound = 'sound/weapons/resonator_blast.ogg'

/obj/projectile/beam/podsniper/laser/get_ru_names()
	return list(
		NOMINATIVE = "снайперский лазер",
		GENITIVE = "снайперского лазера",
		DATIVE = "снайперскому лазеру",
		ACCUSATIVE = "снайперский лазер",
		INSTRUMENTAL = "снайперским лазером",
		PREPOSITIONAL = "снайперском лазере",
	)

/obj/projectile/beam/immolator
	name = "immolation beam"
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	immolate = 2

/obj/projectile/beam/immolator/get_ru_names()
	return list(
		NOMINATIVE = "импульс иммолятора",
		GENITIVE = "импульса иммолятора",
		DATIVE = "импульсу иммолятора",
		ACCUSATIVE = "импульс иммолятора",
		INSTRUMENTAL = "импульсом иммолятора",
		PREPOSITIONAL = "импульсе иммолятора",
	)

/obj/projectile/beam/immolator/strong
	name = "heavy immolation beam"
	damage = 45
	icon_state = "heavylaser"
	immolate = 3

/obj/projectile/beam/immolator/strong/get_ru_names()
	return list(
		NOMINATIVE = "мощный импульс иммолятора",
		GENITIVE = "мощного импульса иммолятора",
		DATIVE = "мощному импульсу иммолятора",
		ACCUSATIVE = "мощный импульс иммолятора",
		INSTRUMENTAL = "мощным импульсом иммолятора",
		PREPOSITIONAL = "мощном импульсе иммолятора",
	)

/obj/projectile/beam/immolator/weak
	name = "light immolation beam"
	damage = 8
	icon_state = "scatterlaser"
	immolate = 1

/obj/projectile/beam/immolator/weak/get_ru_names()
	return list(
		NOMINATIVE = "лёгкий импульс иммолятора",
		GENITIVE = "лёгкого импульса иммолятора",
		DATIVE = "лёгкому импульсу иммолятора",
		ACCUSATIVE = "лёгкий импульс иммолятора",
		INSTRUMENTAL = "лёгким импульсом иммолятора",
		PREPOSITIONAL = "лёгком импульсе иммолятора",
	)

/obj/projectile/beam/immolator/weak/hitscan
	color = LIGHT_COLOR_FIRE
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	impact_type = /obj/effect/projectile/impact/laser
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_color_override = LIGHT_COLOR_FIRE
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = LIGHT_COLOR_FIRE
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = LIGHT_COLOR_FIRE

/obj/projectile/beam/immolator/mech
	name = "mecha immolation beam"
	damage = 15

/obj/projectile/beam/immolator/mech/get_ru_names()
	return list(
		NOMINATIVE = "импульс иммолятора меха",
		GENITIVE = "импульса иммолятора меха",
		DATIVE = "импульсу иммолятора меха",
		ACCUSATIVE = "импульс иммолятора меха",
		INSTRUMENTAL = "импульсом иммолятора меха",
		PREPOSITIONAL = "импульсе иммолятора меха",
	)

/obj/projectile/beam/immolator/on_hit(atom/target, blocked = 0)
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
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_PURPLE

/obj/projectile/beam/instakill/get_ru_names()
	return list(
		NOMINATIVE = "инстагиб лазер",
		GENITIVE = "инстагиб лазера",
		DATIVE = "инстагиб лазеру",
		ACCUSATIVE = "инстагиб лазер",
		INSTRUMENTAL = "инстагиб лазером",
		PREPOSITIONAL = "инстагиб лазере",
	)

/obj/projectile/beam/instakill/blue
	icon_state = "blue_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_DARK_BLUE

/obj/projectile/beam/instakill/red
	icon_state = "red_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = COLOR_SOFT_RED

/obj/projectile/beam/instakill/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.visible_message(span_danger("[DECLENT_RU_CAP(L, NOMINATIVE)] взрывается!"))
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
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_LIGHT_CYAN
	hitsound = 'sound/weapons/resonator_blast.ogg'
	hitsound_wall = 'sound/weapons/sear.ogg'

/obj/projectile/beam/dominator/slaughter/get_ru_names()
	return list(
		NOMINATIVE = "луч казни",
		GENITIVE = "луча казни",
		DATIVE = "лучу казни",
		ACCUSATIVE = "луч казни",
		INSTRUMENTAL = "лучом казни",
		PREPOSITIONAL = "луче казни",
	)

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

/obj/projectile/beam/dominator/paralyzer/get_ru_names()
	return list(
		NOMINATIVE = "дизейблер",
		GENITIVE = "дизейблера",
		DATIVE = "дизейблеру",
		ACCUSATIVE = "дизейблер",
		INSTRUMENTAL = "дизейблером",
		PREPOSITIONAL = "дизейблере",
	)

/obj/projectile/beam/anomaly
	name = "луч стабилизатора аномалий"
	icon_state = "xray" // Looks mostly like "blue/red_laser" in green colour.
	damage = 0
	hitsound = 'sound/weapons/resonator_blast.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	/// The amount by which the stability of the anomaly changes upon impact.
	var/stability_delta = 0
	/// The distance the anomaly is pulled towards the shooter upon impact.
	var/pull_strength = 0
	/// The amount of time that beam increase the blocking of the anomaly's normal movement.
	var/move_block = 0
	/// The amount of time that beam increase the blocking of the anomaly's impulsive movement.
	var/move_impulces_block = 0
	/// The amount by which the strength of the anomaly's effects is temporarily reduced.
	var/anom_weaken = 0
	/// The moment at which the reduction in the effects of the anomaly will be reset.
	var/weaken_time = 0

/obj/projectile/beam/anomaly/get_ru_names()
	return list(
		NOMINATIVE = "луч стабилизатора аномалий",
		GENITIVE = "луча стабилизатора аномалий",
		DATIVE = "лучу стабилизатора аномалий",
		ACCUSATIVE = "луч стабилизатора аномалий",
		INSTRUMENTAL = "лучом стабилизатора аномалий",
		PREPOSITIONAL = "луче стабилизатора аномалий",
	)

/obj/projectile/beam/anomaly/on_hit(atom/target, blocked, hit_zone)
	if(!isanomaly(target))
		return ..()

	do_sparks(clamp(abs(stability_delta) * 2, TRUE, 10))
	var/obj/effect/anomaly/anomaly = target
	if(anomaly.tier != 4 || prob(50))
		anomaly.stability = clamp(anomaly.stability + stability_delta, 0, 100)

	anomaly.move_moment = max(world.time + move_block, anomaly.move_moment)
	anomaly.move_impulse_moment = max(world.time + move_impulces_block, anomaly.move_impulse_moment)
	if(anom_weaken)
		anomaly.weaken = anom_weaken
		anomaly.weaken_moment = world.time + weaken_time

	INVOKE_ASYNC(anomaly, TYPE_PROC_REF(/obj/effect/anomaly, go_to), get_turf(firer_source_atom), pull_strength)
	return TRUE

/obj/projectile/beam/anomaly/stabilizer
	name = "стабилизирующий луч"
	icon_state = "bluelaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/projectile/beam/anomaly/stabilizer/get_ru_names()
	return list(
		NOMINATIVE = "стабилизирующий луч",
		GENITIVE = "стабилизирующего луча",
		DATIVE = "стабилизирующему лучу",
		ACCUSATIVE = "стабилизирующий луч",
		INSTRUMENTAL = "стабилизирующим лучом",
		PREPOSITIONAL = "стабилизирующем луче",
	)

/obj/projectile/beam/anomaly/destabilizer
	name = "дестабилизирующий луч"
	icon_state = "laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = COLOR_SOFT_RED

/obj/projectile/beam/anomaly/destabilizer/get_ru_names()
	return list(
		NOMINATIVE = "дестабилизирующий луч",
		GENITIVE = "дестабилизирующего луча",
		DATIVE = "дестабилизирующему лучу",
		ACCUSATIVE = "дестабилизирующий луч",
		INSTRUMENTAL = "дестабилизирующим лучом",
		PREPOSITIONAL = "дестабилизирующем луче",
	)

/obj/projectile/beam/laser/light/rat
	name = "clockwork energy laser"
	icon_state = "brasslaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/orange_laser

/obj/projectile/beam/laser/light/rat/get_ru_names()
	return list(
		NOMINATIVE = "лазер часовой энергии",
		GENITIVE = "лазера часовой энергии",
		DATIVE = "лазеру часовой энергии",
		ACCUSATIVE = "лазер часовой энергии",
		INSTRUMENTAL = "лазером часовой энергии",
		PREPOSITIONAL = "лазере часовой энергии",
	)

/obj/projectile/beam/laser/light/rat/prehit(atom/target)
	if(isclocker(target))
		damage = 0
	return ..()
