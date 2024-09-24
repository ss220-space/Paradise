PROCESSING_SUBSYSTEM_DEF(emp_plant)
	name = "emp plant"
	flags = SS_NO_INIT | SS_BACKGROUND | SS_KEEP_TIMING
	wait = 10 SECONDS
	ss_id = "aura_healing"


/mob/living/simple_animal/hostile/plant/emp_plant
	name = "dieffenbachia emp"
	desc = "Выглядит как большой и слегка разумный цветок."
	maxHealth = 75
	health = 75

/mob/living/simple_animal/hostile/plant/emp_plant/proc/stop_emp()
	STOP_PROCESSING(SSemp_plant, src)

/mob/living/simple_animal/hostile/plant/emp_plant/Initialize()
	. = ..()
	START_PROCESSING(SSemp_plant, src)
	RegisterSignal(src, COMSIG_MOB_DEATH, PROC_REF(stop_emp))

/mob/living/simple_animal/hostile/plant/emp_plant/process()
	empulse(src, 2, 5, FALSE, name)

/mob/living/simple_animal/hostile/plant/emp_plant/attackby(mob/living/M)
	. = ..()
	if (. == ATTACK_CHAIN_PROCEED)
		M.emp_act(2)
