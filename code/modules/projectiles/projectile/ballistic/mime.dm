/obj/projectile/bullet/mime
	damage = 0
	stun = 2 SECONDS
	weaken = 2 SECONDS
	stamina = 45
	slur = 40 SECONDS
	stutter = 40 SECONDS

/obj/projectile/bullet/mime/on_hit(atom/target, blocked = 0)
	..(target, blocked)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.Silence(20 SECONDS)
	else if(istype(target, /obj/mecha/combat/honker))
		var/obj/mecha/chassis = target
		chassis.occupant_message("A mimetech anti-honk bullet has hit \the [chassis]!")
		chassis.use_power(chassis.get_charge() / 2)
		for(var/obj/item/mecha_parts/mecha_equipment/weapon/honker in chassis.equipment)
			honker.set_ready_state(FALSE)
