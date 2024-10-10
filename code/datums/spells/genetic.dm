/obj/effect/proc_holder/spell/genetic
	desc = "Это заклинание вызывает у цели ряд мутаций и инвалидностей."

	var/list/active_on = list()
	/// Applied traits list.
	var/list/traits = list()
	/// Mutation defines. Set these in Initialize. Refactor this nonsense one day
	var/list/mutations = list()
	var/duration = 10 SECONDS // deciseconds


/obj/effect/proc_holder/spell/genetic/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		if(!target.dna)
			continue

		for(var/mutation in mutations)
			target.force_gene_block(mutation, TRUE)

		for(var/trait in traits)
			ADD_TRAIT(target, trait, MAGIC_TRAIT)

		active_on |= target
		target.regenerate_icons()

		addtimer(CALLBACK(src, PROC_REF(remove), target), duration, TIMER_OVERRIDE|TIMER_UNIQUE)


/obj/effect/proc_holder/spell/genetic/Destroy()
	for(var/target in active_on)
		remove(target)
	return ..()


/obj/effect/proc_holder/spell/genetic/proc/remove(mob/living/carbon/target)
	active_on -= target
	if(!QDELETED(target))
		for(var/mutation in mutations)
			target.force_gene_block(mutation, FALSE)

		for(var/trait in traits)
			REMOVE_TRAIT(target, trait, MAGIC_TRAIT)

		target.regenerate_icons()

