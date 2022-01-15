
/obj/singularity/mish_SINGULARITY
	name = "Михаил"
	desc = "A gravitational singularity."
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray"

/obj/singularity/mish_SINGULARITY/expand()
	. = ..()
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray"
	pixel_x = 0
	pixel_y = 0
	grav_pull = 0

/obj/singularity/mish_SINGULARITY/singularity_act()
	return 0

/obj/singularity/mish_SINGULARITY/New(loc, var/starting_energy = 50, var/temp = 0)
	starting_energy = 250
	. = ..(loc, starting_energy, temp)
