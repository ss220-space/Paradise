/obj/projectile/limb
	name = "limb"
	icon = 'icons/mob/human_races/r_human.dmi'
	icon_state = "l_arm"
	speed = 2
	range = 3
	flag = "melee"
	damage = 20
	stun = 0.5
	eyeblur = 20

/obj/projectile/limb/New(loc, obj/item/organ/external/limb)
	..(loc)
	if(istype(limb))
		name = limb.name
		ru_names = get_ru_names_cached()
		icon = limb.icobase
		icon_state = limb.icon_name
