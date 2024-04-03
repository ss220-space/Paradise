/datum/disease/virus/transformation
	name = "Transformation"
	stage_prob = 10
	max_stages = 5
	spread_flags = NON_CONTAGIOUS
	severity = DANGEROUS
	can_immunity = FALSE
	infectable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/alien)
	var/list/stage1
	var/list/stage2
	var/list/stage3
	var/list/stage4
	var/list/stage5
	var/list/transform_message
	var/new_form
	var/is_new_mind = FALSE
	var/transformed = FALSE
	var/cure_after_transform = TRUE

/datum/disease/virus/transformation/stage_act()
	if(!..() || !affected_mob)
		return FALSE

	switch(stage)
		if(1)
			if(prob(stage_prob) && stage1)
				to_chat(affected_mob, pick(stage1))
		if(2)
			if(prob(stage_prob) && stage2)
				to_chat(affected_mob, pick(stage2))
		if(3)
			if(prob(stage_prob*2) && stage3)
				to_chat(affected_mob, pick(stage3))
		if(4)
			if(prob(stage_prob*2) && stage4)
				to_chat(affected_mob, pick(stage4))
		if(5)
			if(prob(stage_prob*2) && stage5)
				to_chat(affected_mob, pick(stage5))
			if(!transformed)
				if(transform_message)
					to_chat(affected_mob, pick(transform_message))
				do_disease_transformation()
				if(cure_after_transform)
					cure()
	return TRUE

/datum/disease/virus/transformation/proc/do_disease_transformation()
	if(istype(affected_mob) && new_form)
		if(jobban_isbanned(affected_mob, new_form))
			affected_mob.death(1)
			return

		if(affected_mob.notransform)
			return

		affected_mob.notransform = 1
		affected_mob.canmove = FALSE
		affected_mob.icon = null
		affected_mob.cut_overlays()
		affected_mob.invisibility = INVISIBILITY_ABSTRACT

		for(var/obj/item/W in affected_mob)
			if(istype(W, /obj/item/implant))
				qdel(W)
				continue
			affected_mob.drop_item_ground(W) //Если вещь снимается - снимаем

		if(isobj(affected_mob.loc))
			var/obj/O = affected_mob.loc
			O.force_eject_occupant(affected_mob)

		var/mob/living/new_mob = new new_form(affected_mob.loc)
		if(istype(new_mob))
			new_mob.a_intent = "harm"
			if(affected_mob.mind)
				affected_mob.mind.transfer_to(new_mob)
				if(is_new_mind)
					new_mob.mind.wipe_memory()
			else
				new_mob.key = affected_mob.key

		qdel(affected_mob)
		transformed = TRUE
		return new_mob

/datum/disease/virus/transformation/jungle_fever
	name = "Jungle Fever"
	agent = "Kongey Vibrion M-909"
	desc = "Monkeys with this disease will bite humans, causing humans to mutate into a monkey."
	stage_prob = 2
	cure_prob = 5
	cures = list("banana")
	spread_flags = BITES
	infectable_mobtypes = list(/mob/living/carbon/human)
	severity = BIOHAZARD
	cure_after_transform = FALSE
	stage1	= null
	stage2	= null
	stage3	= null
	stage4	= list(span_warning("Your back hurts."), span_warning("You breathe through your mouth."),
					span_warning("You have a craving for bananas."), span_warning("Your mind feels clouded."))
	stage5	= list(span_warning("You feel like monkeying around."))
	new_form = /mob/living/carbon/human/lesser/monkey

/datum/disease/virus/transformation/jungle_fever/do_disease_transformation()
	var/mob/living/carbon/human/H = affected_mob
	if(!istype(H))
		return
	if(!issmall(H))
		if(istype(H.dna.species.primitive_form))
			H.monkeyize()
			transformed = TRUE
		else
			var/mob/living/new_mob = ..()
			var/datum/disease/virus/transformation/jungle_fever/D = Contract(new_mob)
			D?.stage = 5
			D.transformed = TRUE
	else
		transformed = TRUE

/datum/disease/virus/transformation/jungle_fever/stage_act()
	if(!..() || !affected_mob)
		return FALSE

	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, span_notice("Your [pick("back", "arm", "leg", "elbow", "head")] itches."))
		if(3)
			if(prob(4))
				to_chat(affected_mob, span_danger("You feel a stabbing pain in your head."))
				affected_mob.AdjustConfused(20 SECONDS)
		if(4, 5)
			if(prob(4))
				affected_mob.say(pick("Иииик, уку уку!", "Иии-ииик!", "Ииии!", "Ун, ун."))

/datum/disease/virus/transformation/robot
	name = "Robotic Transformation"
	agent = "R2D2 Nanomachines"
	desc = "This disease, actually acute nanomachine infection, converts the victim into a cyborg."
	cures = list("copper")
	cure_prob = 5
	is_new_mind = TRUE
	stage1 = null
	stage2 = list(span_notice("Your joints feel stiff."), span_danger("Beep...boop.."))
	stage3 = list(span_danger("Your joints feel very stiff."), span_notice("Your skin feels loose."), span_danger("You can feel something move...inside."))
	stage4 = list(span_danger("Your skin feels very loose."), span_danger("You can feel... something...inside you."))
	transform_message = list(span_danger("Your skin feels as if it's about to burst off!"))
	new_form = /mob/living/silicon/robot

/datum/disease/virus/transformation/robot/stage_act()
	if(!..() || !affected_mob)
		return FALSE

	switch(stage)
		if(3)
			if(prob(8))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...bop"))
			if(prob(4))
				to_chat(affected_mob, span_danger("You feel a stabbing pain in your head."))
				affected_mob.Paralyse(4 SECONDS)
		if(4)
			if(prob(20))
				affected_mob.say(pick("beep, beep!", "Boop bop boop beep.", "kkkiiiill mmme", "I wwwaaannntt tttoo dddiiieeee..."))


/datum/disease/virus/transformation/xeno
	name = "Xenomorph Transformation"
	agent = "Rip-LEY Alien Microbes"
	desc = "This disease changes the victim into a xenomorph."
	cures = list("spaceacillin", "glycerol")
	cure_prob = 5
	stage1 = null
	stage2 = list("Your throat feels scratchy.", span_danger("Kill..."))
	stage3 = list(span_danger("Your throat feels very scratchy."), "Your skin feels tight.", span_danger("You can feel something move...inside."))
	stage4 = list(span_danger("Your skin feels very tight."), span_danger("Your blood boils!"), span_danger("You can feel... something...inside you."))
	transform_message = list(span_danger("<FONT size = 5><B>Теперь вы ксеноморф.</B></FONT></span>\n\
	<B>Вы чувствуете боль от превращения! Вы желаете укусить того, кто с вами это сделал, благо, память вас не покинула и вы всё помните.</B>"))
	new_form = null

/datum/disease/virus/transformation/xeno/New()
	..()
	new_form = pick(/mob/living/carbon/alien/humanoid/hunter, /mob/living/carbon/alien/humanoid/drone/no_queen, /mob/living/carbon/alien/humanoid/sentinel)

/datum/disease/virus/transformation/xeno/stage_act()
	if(!..() || !affected_mob)
		return FALSE

	switch(stage)
		if(3)
			if(prob(4))
				to_chat(affected_mob, span_danger("You feel a stabbing pain in your head."))
				affected_mob.Paralyse(4 SECONDS)
		if(4)
			if(prob(20))
				affected_mob.say(pick("You look delicious.", "Going to... devour you...", "Hsssshhhhh!"))


/datum/disease/virus/transformation/slime
	name = "Advanced Mutation Transformation"
	agent = "Advanced Mutation Toxin"
	desc = "This highly concentrated extract converts anything into more of itself."
	cures = list("frostoil")
	cure_prob = 80
	stage1 = list(span_notice("You don't feel very well."))
	stage2 = list(span_notice("Your skin feels a little slimy."))
	stage3 = list(span_danger("Your appendages are melting away."), span_danger("Your limbs begin to lose their shape."))
	stage4 = list(span_danger("You are turning into a slime."))
	transform_message = list(span_danger("You have become a slime."))
	new_form = /mob/living/simple_animal/slime/random

/datum/disease/virus/transformation/slime/stage_act()
	if(!..() || !affected_mob)
		return FALSE

	switch(stage)
		if(1)
			if(isslimeperson(affected_mob))
				stage = 5
		if(3)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/human = affected_mob
				if(!isslimeperson(human))
					human.set_species(/datum/species/slime)

/datum/disease/virus/transformation/corgi
	name = "The Barkening"
	agent = "Fell Doge Majicks"
	desc = "This disease transforms the victim into a corgi."
	cure_text = "Death"
	cures = list("adminordrazine")
	stage1	= list(span_notice("BARK."))
	stage2	= list(span_notice("You feel the need to wear silly hats."))
	stage3	= list(span_danger("Must... eat... chocolate...."), span_danger("YAP"))
	stage4	= list(span_danger("Visions of washing machines assail your mind!"))
	transform_message	= list(span_danger("AUUUUUU!!!"))
	new_form = /mob/living/simple_animal/pet/dog/corgi
	is_new_mind = TRUE

/datum/disease/virus/transformation/corgi/stage_act()
	if(!..() || !affected_mob)
		return FALSE

	switch(stage)
		if(3)
			if(prob(8))
				affected_mob.say(pick("YAP", "Woof!"))
		if(4)
			if(prob(20))
				affected_mob.say(pick("Bark!", "AUUUUUU"))

/datum/disease/virus/transformation/morph
	name = "Gluttony's Blessing"
	agent = "Gluttony's Blessing"
	desc = "A 'gift' from somewhere terrible."
	cure_text = "Nothing"
	cures = list("adminordrazine")
	stage_prob = 20
	stage1 = list(span_notice("Your stomach rumbles."))
	stage2 = list(span_notice("Your skin feels saggy."))
	stage3 = list(span_danger("Your appendages are melting away."), span_danger("Your limbs begin to lose their shape."))
	stage4 = list(span_danger("You're ravenous."))
	transform_message = list(span_danger("<FONT size = 5><B>ТЕПЕРЬ ВЫ МОРФ!</B></FONT></span> \n \
	Хоть Вы и трансформировались в отвратительную зелёную жижу, но это не повлияло на Ваше сознание \
	и память. Вы не являетесь антагонистом."))
	new_form = /mob/living/simple_animal/hostile/morph
