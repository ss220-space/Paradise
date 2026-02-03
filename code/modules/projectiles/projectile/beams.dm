/obj/projectile/beam
	name = "laser"
	icon_state = "beam"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 23
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "laser"
	eyeblur = 0 SECONDS
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

/obj/projectile/beam/heavylaser
	name = "heavy laser beam"
	icon_state = "heavybeam"
	damage = 50
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser
	hitsound = 'sound/weapons/resonator_blast.ogg'

/obj/projectile/beam/heavylaser/get_ru_names()
	return list(
		NOMINATIVE = "мощный лазер",
		GENITIVE = "мощного лазера",
		DATIVE = "мощному лазеру",
		ACCUSATIVE = "мощный лазер",
		INSTRUMENTAL = "мощным лазером",
		PREPOSITIONAL = "мощном лазере",
	)

/obj/projectile/beam/slug
	icon_state = "heavybeam"
	name = "laser slug beam"
	damage = 50
	stamina = 33

/obj/projectile/beam/slug/get_ru_names()
	return list(
		NOMINATIVE = "лазерный импульс",
		GENITIVE = "лазерного импульса",
		DATIVE = "лазерному импульсу",
		ACCUSATIVE = "лазерный импульс",
		INSTRUMENTAL = "лазерным импульсом",
		PREPOSITIONAL = "лазерном импульсе",
	)

/obj/projectile/beam/weak
	icon_state = "weakbeam"
	damage = 10

/obj/projectile/beam/weak/get_ru_names()
	return list(
		NOMINATIVE = "слабый лазер",
		GENITIVE = "слабого лазера",
		DATIVE = "слабому лазеру",
		ACCUSATIVE = "слабый лазер",
		INSTRUMENTAL = "слабым лазером",
		PREPOSITIONAL = "слабом лазере",
	)

/obj/projectile/beam/weak/rat
	name = "clockwork energy laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/orange_laser

/obj/projectile/beam/weak/rat/get_ru_names()
	return list(
		NOMINATIVE = "лазер часовой энергии",
		GENITIVE = "лазера часовой энергии",
		DATIVE = "лазеру часовой энергии",
		ACCUSATIVE = "лазер часовой энергии",
		INSTRUMENTAL = "лазером часовой энергии",
		PREPOSITIONAL = "лазере часовой энергии",
	)

/obj/projectile/beam/weak/rat/prehit(atom/target)
	if(isclocker(target))
		damage = 0
	return ..()

/obj/projectile/beam/heavy
	damage = 45
	name = "heavy laser beam"
	icon_state = "heavybeam"
	hitsound = 'sound/weapons/resonator_blast.ogg'

/obj/projectile/beam/heavy/get_ru_names()
	return list(
		NOMINATIVE = "мощный лазер",
		GENITIVE = "мощного лазера",
		DATIVE = "мощному лазеру",
		ACCUSATIVE = "мощный лазер",
		INSTRUMENTAL = "мощным лазером",
		PREPOSITIONAL = "мощном лазере",
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
	icon_state = "weakbeam"
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
	icon_state = "heavybeam"
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

/obj/projectile/beam/pulse
	name = "pulse"
	icon_state = "heavybeam"
	damage = 50
	var/gib_allowed = TRUE
	hitsound = 'sound/weapons/resonator_blast.ogg'
	hitsound_wall = 'sound/weapons/resonator_blast.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/laser/heavy
	muzzle_type = /obj/effect/projectile/muzzle/laser/heavy
	impact_type = /obj/effect/projectile/impact/laser/heavy

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
	icon_state = "heavybeam"
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
	tracer_type = /obj/effect/projectile/tracer/laser/heavy
	muzzle_type = /obj/effect/projectile/muzzle/laser/heavy
	impact_type = /obj/effect/projectile/impact/laser/heavy
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
	icon_state = "weakbeam"
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
	suit_types = list(/obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = COLOR_SOFT_RED
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/projectile/beam/lasertag/bluetag
	suit_types = list(/obj/item/clothing/suit/redtag)
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

/obj/projectile/beam/heavysniper
	name = "sniper beam"
	icon_state = "sniperbeam"
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

/obj/projectile/beam/heavysniper/get_ru_names()
	return list(
		NOMINATIVE = "снайперский луч",
		GENITIVE = "снайперского луча",
		DATIVE = "снайперскому лучу",
		ACCUSATIVE = "снайперский луч",
		INSTRUMENTAL = "снайперским лучом",
		PREPOSITIONAL = "снайперском луче",
	)

/obj/projectile/beam/immolator
	name = "immolation beam"
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	icon_state = "heavybeam"
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
	icon_state = "weakbeam"

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

/obj/projectile/beam/slaughter
	name = "execution slaughter beam"
	icon_state = "atomball"
	damage = 50
	stamina = 33
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_LIGHT_CYAN
	hitsound = 'sound/weapons/resonator_blast.ogg'
	hitsound_wall = 'sound/weapons/sear.ogg'

/obj/projectile/beam/slaughter/get_ru_names()
	return list(
		NOMINATIVE = "луч казни",
		GENITIVE = "луча казни",
		DATIVE = "лучу казни",
		ACCUSATIVE = "луч казни",
		INSTRUMENTAL = "лучом казни",
		PREPOSITIONAL = "луче казни",
	)

/obj/projectile/beam/ricochet
	icon_state = "atomball"
	damage = 30
	range = 100
	hitscan = FALSE
	ricochet_chance = 100
	ricochets_max = 10
	speed = 3
	flag = BULLET
	hitsound = 'sound/weapons/atomichitsound.ogg'
	hitsound_wall = 'sound/weapons/atomichitsound.ogg'
	light_color = COLOR_VIVID_YELLOW
	light_range = 5

/obj/projectile/beam/ricochet/get_ru_names()
	return list(
		NOMINATIVE = "энергетический шар",
		GENITIVE = "энергетического шара",
		DATIVE = "энергетическому шару",
		ACCUSATIVE = "энергетический шар",
		INSTRUMENTAL = "энергетическим шаром",
		PREPOSITIONAL = "энергетическом шаре",
	)

/obj/projectile/beam/anomaly
	name = "луч стабилизатора аномалий"
	icon_state = "pellet" // Looks mostly like "blue/red_laser" in green colour.
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

/obj/projectile/beam/disabler //parent type for all disabler beams
	name = "disabler beam"
	damage = 25
	shockbull = TRUE
	damage_type = STAMINA
	flag = "energy"
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_LIGHT_CYAN
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

/obj/projectile/beam/disabler/weak
	damage = 12
	icon_state = "weakbeam"

/obj/projectile/beam/disabler/weak/get_ru_names()
	return list(
		NOMINATIVE = "слабый дизейблер",
		GENITIVE = "слабого дизейблера",
		DATIVE = "слабому дизейблеру",
		ACCUSATIVE = "слабый дизейблер",
		INSTRUMENTAL = "слабым дизейблером",
		PREPOSITIONAL = "слабом дизейблере",
	)

/obj/projectile/beam/disabler/heavy
	name = "heavy disabler beam"
	icon_state = "heavybeam"
	damage = 40
	hitsound = 'sound/weapons/resonator_blast.ogg'
	flag = ENERGY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser

/obj/projectile/beam/disabler/heavy/get_ru_names()
	return list(
		NOMINATIVE = "мощный дизейблер",
		GENITIVE = "мощного дизейблера",
		DATIVE = "мощному дизейблеру",
		ACCUSATIVE = "мощный дизейблер",
		INSTRUMENTAL = "мощным дизейблером",
		PREPOSITIONAL = "мощном дизейблере",
	)

/obj/projectile/beam/laser //parent type for hitscan-laser beams
	name = "laser beam"
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser
	hitscan = TRUE
	damage = 20

/obj/projectile/beam/laser/get_ru_names()
	return list(
		NOMINATIVE = "лазерный луч",
		GENITIVE = "лазерного луча",
		DATIVE = "лазерному лучу",
		ACCUSATIVE = "лазерный луч",
		INSTRUMENTAL = "лазерным лучом",
		PREPOSITIONAL = "лазерном луче",
	)

/obj/projectile/beam/laser/heavy
	name = "heavy laser beam"
	tracer_type = /obj/effect/projectile/tracer/laser/heavy
	muzzle_type = /obj/effect/projectile/muzzle/laser/heavy
	impact_type = /obj/effect/projectile/impact/laser/heavy
	damage = 40

/obj/projectile/beam/laser/heavy/get_ru_names()
	return list(
		NOMINATIVE = "мощный лазерный луч",
		GENITIVE = "мощного лазерного луча",
		DATIVE = "мощному лазерному лучу",
		ACCUSATIVE = "мощный лазерный луч",
		INSTRUMENTAL = "мощным лазерным лучом",
		PREPOSITIONAL = "мощном лазерном луче",
	)

/obj/projectile/beam/laser/pierce
	name = "armorpierce laser beam"
	tracer_type = /obj/effect/projectile/tracer/laser/armorpierce
	muzzle_type = /obj/effect/projectile/muzzle/laser/armorpierce
	impact_type = /obj/effect/projectile/impact/laser/armorpierce
	armour_penetration = 50
	damage = 25
	forcedodge = 2

/obj/projectile/beam/laser/pierce/get_ru_names()
	return list(
		NOMINATIVE = "бронебойный лазерный луч",
		GENITIVE = "бронебойного лазерного луча",
		DATIVE = "бронебойному лазерному лучу",
		ACCUSATIVE = "бронебойный лазерный луч",
		INSTRUMENTAL = "бронебойным лазерным лучом",
		PREPOSITIONAL = "бронебойном лазерном луче",
	)

/obj/projectile/beam/laser/slug
	name = "laserslug beam"
	tracer_type = /obj/effect/projectile/tracer/laser/heavy
	muzzle_type = /obj/effect/projectile/muzzle/laser/heavy
	impact_type = /obj/effect/projectile/impact/laser/heavy
	damage = 25
	armour_penetration = 25

/obj/projectile/beam/laser/slug/get_ru_names()
	return list(
		NOMINATIVE = "сфокусированный лазерный луч",
		GENITIVE = "сфокусированного лазерного луча",
		DATIVE = "сфокусированному лазерному лучу",
		ACCUSATIVE = "сфокусированный лазерный луч",
		INSTRUMENTAL = "сфокусированным лазерным лучом",
		PREPOSITIONAL = "сфокусированном лазерном луче",
	)

/obj/projectile/beam/laser/weak
	name = "weak laser beam"
	tracer_type = /obj/effect/projectile/tracer/laser/light
	muzzle_type = /obj/effect/projectile/muzzle/laser/light
	impact_type = /obj/effect/projectile/impact/laser/light
	damage = 10
	armour_penetration = -30

/obj/projectile/beam/laser/weak/get_ru_names()
	return list(
		NOMINATIVE = "слабый лазерный луч",
		GENITIVE = "слабого лазерного луча",
		DATIVE = "слабому лазерному лучу",
		ACCUSATIVE = "слабый лазерный луч",
		INSTRUMENTAL = "слабым лазерным лучом",
		PREPOSITIONAL = "слабом лазерном луче",
	)
