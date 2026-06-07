// MARK: 84mm HEDP
/obj/projectile/bullet/a84mm_hedp
	name = "HEDP rocket"
	desc = "ИСПОЛЬЗУЙ ПНЕВМАТИЧЕСКИЙ ПИСТОЛЕТ"
	icon_state = "84mm-hedp"
	damage = 80
	//shrapnel thing
	var/shrapnel_range = 5
	var/max_shrapnel = 5
	var/embed_prob = 100
	var/embedded_type = /obj/item/embedded/shrapnel
	speed = 0.8 //rockets need to be slower than bullets
	var/anti_armour_damage = 200
	armour_penetration = 100
	dismemberment = 100
	ricochets_max = 0

/obj/projectile/bullet/a84mm_hedp/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flash_range = 1, adminlog = FALSE, flame_range = 6)

	if(ismecha(target))
		var/obj/mecha/M = target
		M.take_damage(anti_armour_damage)
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.take_overall_damage(anti_armour_damage*0.75, anti_armour_damage*0.25)

	for(var/turf/T in view(shrapnel_range, loc))
		for(var/mob/living/carbon/human/H in T)
			var/shrapnel_amount = max_shrapnel - T.Distance(target)
			if(shrapnel_amount > 0)
				embed_shrapnel(H, shrapnel_amount)

/obj/projectile/bullet/a84mm_hedp/proc/embed_shrapnel(mob/living/carbon/human/H, amount)
	for(var/i = 0, i < amount, i++)
		if(prob(embed_prob - H.getarmor(attack_flag = BOMB)))
			var/obj/item/embedded/S = new embedded_type(src)
			H.hitby(S, skipcatch = 1)
			S.throwforce = 1
			S.throw_speed = 1
			S.sharp = FALSE
		else
			to_chat(H, span_warning("Шрапнель отскакивает от вашей брони!"))

// MARK: 84mm HE
/obj/projectile/bullet/a84mm_he
	name = "HE missile"
	desc = "Boom."
	icon_state = "84mm-he"
	damage = 30
	speed = 0.8
	ricochets_max = 0

/obj/projectile/bullet/a84mm_he/on_hit(atom/target, blocked=0)
	..()
	explosion(target, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 5, flash_range = 7) //devastating

// MARK: 40mm
/obj/projectile/bullet/a40mm
	name = "40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60
	ricochets_max = 0

/obj/projectile/bullet/a40mm/get_ru_names()
	return list(
		NOMINATIVE = "40мм граната",
		GENITIVE = "40мм гранаты",
		DATIVE = "40мм гранате",
		ACCUSATIVE = "40мм гранату",
		INSTRUMENTAL = "40мм гранатой",
		PREPOSITIONAL = "40мм гранате",
	)

/obj/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 0, light_impact_range = 2, flash_range = 1, adminlog = TRUE, flame_range = 3, cause = "[type] fired by [key_name(firer)]")
	return 1

// MARK: Bombarda grenade
/obj/projectile/grenade/improvised
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = null
	hitsound = SFX_BULLET
	hitsound_wall = SFX_RICOCHET

/obj/projectile/grenade/improvised/exp_shot
	icon_state = "exp_shot"

/obj/projectile/grenade/improvised/exp_shot/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	explosion(loc, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2, flame_range = 3, cause = src)

/obj/projectile/grenade/improvised/flame_shot
	icon_state = "flame_shot"

/obj/projectile/grenade/improvised/flame_shot/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	explosion(loc, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flame_range = 8, cause = src)
	fireflash(loc, 2, 682)

/obj/projectile/grenade/improvised/smoke_shot
	icon_state = "smoke_shot"

/obj/projectile/grenade/improvised/smoke_shot/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
	smoke.set_up(amount = 18, location = loc)
	smoke.effect_type = /obj/effect/particle_effect/fluid/smoke/bad/bombarda
	smoke.start()

// MARK: GL-06 grenade
/obj/projectile/grenade/a40mm/secgl
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = null
	hitsound = "bullet"
	hitsound_wall = "ricochet"
	damage = 5
	stamina = 15
	armour_penetration = -30

/obj/projectile/grenade/a40mm/secgl/solid
	icon_state = "secgl_projectile_solid"
	damage = 20
	tile_dropoff = 1
	stamina = 120
	tile_dropoff_s = 5
	min_stamina = 90

/obj/projectile/grenade/a40mm/secgl/flash
	icon_state = "secgl_porjectile_flash"

/obj/projectile/grenade/a40mm/secgl/flash/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	// VFX and SFX
	do_sparks(rand(5, 9), FALSE, src)
	playsound(loc, 'sound/effects/bang.ogg', 100, TRUE)
	new /obj/effect/dummy/lighting_obj(loc, range + 2, 10, light_color, 0.2 SECONDS)
	// Blob damage
	for(var/obj/structure/blob/blob in get_hear(range + 1, loc))
		var/damage = round(30 / (get_dist(blob, loc) + 1))
		blob.take_damage(damage, BURN, MELEE, FALSE)
	// Stunning & damaging mechanic
	bang(loc, src, 7, direct_bang = FALSE)

/obj/projectile/grenade/a40mm/secgl/gas
	icon_state = "secgl_projectile_gas"

/obj/projectile/grenade/a40mm/secgl/gas/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	var/obj/item/grenade/grenade = new /obj/item/grenade/chem_grenade/teargas(loc)
	grenade.prime()

/obj/projectile/grenade/a40mm/secgl/barricade
	icon_state = "secgl_projectile_barricade"

/obj/projectile/grenade/a40mm/secgl/barricade/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	var/obj/item/grenade/grenade = new /obj/item/grenade/barrier(loc)
	grenade.prime()

/obj/projectile/grenade/a40mm/secgl/exp
	icon_state = "secgl_projectile_exp"

/obj/projectile/grenade/a40mm/secgl/exp/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	var/obj/item/grenade/grenade = new /obj/item/grenade/frag/less(loc)
	grenade.prime()

/obj/item/grenade/frag/less
	range = 2
	shrapnel_radius = 3
	
/obj/projectile/grenade/a40mm/secgl/paint
	icon_state = "secgl_projectile_paint"
	var/paint_color = "#e99518"

/obj/projectile/grenade/a40mm/secgl/paint/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	var/obj/effect/decal/cleanable/blood/paint/paint = new(loc)
	paint.basecolor = paint_color
	paint.update_icon()
	var/mob/living/carbon/human/human = target
	if(istype(human))
		human.add_blood(human.get_blood_dna_list(), color = paint_color)
		var/datum/component/paint_splatter/component = human.GetComponent(/datum/component/paint_splatter)
		if(component)
			component.restart_live_timer(amount = 25)
			return
		human.AddComponent(/datum/component/paint_splatter, color = paint_color, amount = 25, chance = 50, duration = 60 SECONDS)
