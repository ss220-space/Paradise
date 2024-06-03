/mob/living/silicon/gib()
	death(1)
	var/atom/movable/overlay/animation = null
	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	icon = null
	invisibility = INVISIBILITY_ABSTRACT

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	playsound(src.loc, 'sound/goonstation/effects/robogib.ogg', 50, 1)

	robogibs(loc)

	drop_hat()

	GLOB.dead_mob_list -= src
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/silicon/dust()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	icon = null
	invisibility = INVISIBILITY_ABSTRACT
	dust_animation()
	GLOB.dead_mob_list -= src
	QDEL_IN(src, 15)
	return TRUE

/mob/living/silicon/dust_animation()
	//hmmm
	var/atom/movable/overlay/animation = null

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	QDEL_IN(animation, 15)

/mob/living/silicon/death(gibbed)
	. = ..()
	if(!gibbed)
		if(death_sound)
			playsound(get_turf(src), death_sound, 200, 1)
