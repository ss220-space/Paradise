/obj/machinery/the_singularitygen/tesla
	name = "energy ball generator"
	desc = "Makes the wardenclyffe look like a child's plaything when shot with a particle accelerator."
	icon = 'icons/obj/engines_and_power/tesla/tesla_generator.dmi'
	icon_state = "TheSingGen"
	creation_type = /obj/singularity/energy_ball

/obj/machinery/the_singularitygen/tesla/zap_act(power, zap_flags)
	if(zap_flags & ZAP_MACHINE_EXPLOSIVE)
		energy += power
