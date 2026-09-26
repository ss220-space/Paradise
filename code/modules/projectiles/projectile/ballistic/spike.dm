/obj/projectile/bullet/spike
	name = "alloy spike"
	desc = "It's about a foot of weird silvery metal with a wicked point."
	damage = 25
	stun = 2 SECONDS
	armour_penetration = 30
	icon_state = "magspear"

/obj/projectile/bullet/spike/on_hit(atom/target, blocked = 0)
	if((blocked != 100) && ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed(50)
	..()
