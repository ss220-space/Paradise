/datum/disease/virus/pierrot_throat
	name = "Pierrot's Throat"
	agent = "H0NI<42 Virus"
	desc = "If left untreated the subject will probably drive others to insanity."
	max_stages = 4
	spread_flags = AIRBORNE
	cures = list("banana")
	cure_prob = 75
	permeability_mod = 0.75
	severity = MEDIUM
	possible_mutations = list(/datum/disease/virus/pierrot_throat/advanced, /datum/disease/virus/wizarditis)

/datum/disease/virus/pierrot_throat/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel a little silly.</span>")
		if(2)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You start seeing rainbows.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Your thoughts are interrupted by a loud <b>HONK!</b></span>")
		if(4)
			if(prob(5))
				affected_mob.say(pick(list("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk...")))


/datum/disease/virus/pierrot_throat/advanced
	name = "Advanced Pierrot's Throat"
	agent = "H0NI<42.B4n4 Virus"
	desc = "If left untreated the subject will probably drive others to insanity and go insane themselves."
	severity = DANGEROUS
	possible_mutations = null

/datum/disease/virus/pierrot_throat/advanced/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>You feel like making a joke.</span>")
		if(2)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You don't just start seeing rainbows... YOU ARE RAINBOWS!</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Your thoughts are interrupted by a loud <b>HONK!</b></span>")
				affected_mob << 'sound/items/airhorn.ogg'
		if(4)
			if(prob(5))
				affected_mob.say(pick(list("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk...")))

			if(!istype(affected_mob.wear_mask, /obj/item/clothing/mask/gas/clown_hat/nodrop))
				affected_mob.drop_item_ground(affected_mob.wear_mask, force = TRUE)
				affected_mob.equip_to_slot(new /obj/item/clothing/mask/gas/clown_hat/nodrop(src), slot_wear_mask)
