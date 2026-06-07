/obj/projectile/energy/hulkspit
	name = "spit"
	icon_state = "neurotoxin"
	damage = 15
	damage_type = TOX

/obj/projectile/energy/hulkspit/on_hit(atom/target, def_zone = BODY_ZONE_CHEST, blocked = 0)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.Knockdown(4 SECONDS)
		M.adjust_fire_stacks(20)
		M.IgniteMob()
