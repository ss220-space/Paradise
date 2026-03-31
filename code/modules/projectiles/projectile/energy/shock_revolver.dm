// MARK: Shock revolver
/obj/projectile/energy/shock_revolver
	name = "shock bolt"
	icon_state = "purple_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	damage = 10 //A worse lasergun
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_LOW_POWER_GEN
	var/zap_range = 3
	var/power = 1e4

/obj/projectile/energy/shock_revolver/get_ru_names()
	return list(
		NOMINATIVE = "шоковый заряд",
		GENITIVE = "шокового заряда",
		DATIVE = "шоковому заряду",
		ACCUSATIVE = "шоковый заряд",
		INSTRUMENTAL = "шоковым зарядом",
		PREPOSITIONAL = "шоковом заряде",
	)

/obj/item/ammo_casing/energy/shock_revolver/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	. = ..()
	var/obj/projectile/energy/shock_revolver/P = BB
	spawn(1)
		P.chain = P.Beam(user, icon_state = "purple_lightning", icon = 'icons/effects/effects.dmi', time = 1000, maxdistance = 30)

/obj/projectile/energy/shock_revolver/on_hit(atom/target)
	. = ..()
	tesla_zap(source = src, zap_range = zap_range, power = power, cutoff = 1e3, zap_flags = zap_flags)
	qdel(src)

/obj/projectile/energy/shock_revolver/Destroy()
	QDEL_NULL(chain)
	return ..()

// MARK: Shock revolver - Ancient
/obj/projectile/energy/shock_revolver/ancient
	damage = 5

/obj/projectile/energy/shock_revolver/ancient/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(isancientrobotleg(mover))
		return TRUE
