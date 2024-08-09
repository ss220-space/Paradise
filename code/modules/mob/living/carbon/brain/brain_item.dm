/obj/item/organ/internal/brain
	name = "brain"
	max_damage = 120
	icon_state = "brain2"
	force = 1.0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=5"
	attack_verb = list("attacked", "slapped", "whacked")
	var/mob/living/carbon/brain/brainmob = null
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_BRAIN
	vital = TRUE
	hidden_pain = TRUE //the brain has no pain receptors, and brain damage is meant to be a stealthy damage type.
	var/mmi_icon = 'icons/obj/assemblies.dmi'
	var/mmi_icon_state = "mmi_full"
	/// If it's a fake brain without a mob assigned that should still be treated like a real brain.
	var/decoy_brain = FALSE

/obj/item/organ/internal/brain/xeno
	name = "xenomorph brain"
	desc = "We barely understand the brains of terrestial animals. Who knows what we may find in the brain of such an advanced species?"
	icon_state = "brain-x"
	origin_tech = "biotech=6"
	mmi_icon = 'icons/mob/alien.dmi'
	mmi_icon_state = "AlienMMI"

/obj/item/organ/internal/brain/Destroy()
	QDEL_NULL(brainmob)
	return ..()

/obj/item/organ/internal/brain/proc/transfer_identity(var/mob/living/carbon/H)
	brainmob = new(src)
	if(isnull(dna)) // someone didn't set this right...
		log_runtime(EXCEPTION("[src] at [loc] did not contain a dna datum at time of removal."), src)
		dna = H.dna.Clone()
	name = "\the [dna.real_name]'s [initial(src.name)]"
	brainmob.dna = dna.Clone() // Silly baycode, what you do
//	brainmob.dna = H.dna.Clone() Putting in and taking out a brain doesn't make it a carbon copy of the original brain of the body you put it in
	brainmob.name = dna.real_name
	brainmob.real_name = dna.real_name
	brainmob.timeofhostdeath = H.timeofdeath
	if(H.mind)
		H.mind.transfer_to(brainmob)

	to_chat(brainmob, "<span class='notice'>You feel slightly disoriented. That's normal when you're just a [initial(src.name)].</span>")

/obj/item/organ/internal/brain/examine(mob/user) // -- TLE
	. = ..()
	if(brainmob && brainmob.client)//if there be a brain inside... the brain.
		. += "You can feel a bright spark of life in this one!"
		return
	if(brainmob?.mind)
		var/foundghost = FALSE
		for(var/mob/dead/observer/G in GLOB.player_list)
			if(G.mind == brainmob.mind)
				foundghost = G.can_reenter_corpse
				break
		if(foundghost)
			. += "You can feel the small spark of life still left in this one."
			return

	. += "This one seems particularly lifeless. Perhaps it will regain some of its luster later.."

/obj/item/organ/internal/brain/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT)
	if(dna)
		name = "[dna.real_name]'s [initial(name)]"

	if(!owner)
		return ..() // Probably a redundant removal; just bail

	var/obj/item/organ/internal/brain/our_brain = src
	if(!special)
		var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()
		if(borer)
			borer.leave_host() //Should remove borer if the brain is removed - RR

		if(owner.mind && !decoy_brain)	//don't transfer if the owner does not have a mind.
			our_brain.transfer_identity(user)

	if(ishuman(owner))
		owner.update_hair()

	owner.thought_bubble_image = initial(owner.thought_bubble_image)
	. = ..()


/obj/item/organ/internal/brain/insert(mob/living/target, special = ORGAN_MANIPULATION_DEFAULT)

	name = "[initial(name)]"
	var/brain_already_exists = FALSE
	if(ishuman(target)) // No more IPC multibrain shenanigans
		if(target.get_int_organ(/obj/item/organ/internal/brain))
			brain_already_exists = TRUE

		var/mob/living/carbon/human/H = target
		H.update_hair()

	var/target_changeling = ischangeling(target)
	if(target_changeling)
		decoy_brain = TRUE

	if(!brain_already_exists)
		if(brainmob && !target_changeling)
			if(target.key)
				target.ghostize()
			if(brainmob.mind)
				brainmob.mind.transfer_to(target)
			else
				target.key = brainmob.key
		else if(brainmob?.mind && target_changeling)
			brainmob.mind.current = null
			brainmob.ghostize()
	else
		log_debug("Multibrain shenanigans at ([target.x],[target.y],[target.z]), mob '[target]'")

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.special_post_clone_handling()

	..(target, special)


/obj/item/organ/internal/brain/internal_receive_damage(amount = 0, silent = FALSE) //brains are special; if they receive damage by other means, we really just want the damage to be passed ot the owner and back onto the brain.
	owner?.apply_damage(amount, BRAIN)


/obj/item/organ/internal/brain/necrotize(silent = FALSE) //Brain also has special handling for when it necrotizes
	if(..() && owner && vital)
		owner.setBrainLoss(120)


/obj/item/organ/internal/brain/prepare_eat()
	return // Too important to eat.

/obj/item/organ/internal/brain/slime
	species_type = /datum/species/slime
	name = "slime core"
	desc = "A complex, organic knot of jelly and crystalline particles."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "green slime extract"
	mmi_icon_state = "slime_mmi"

/obj/item/organ/internal/brain/golem
	name = "Runic mind"
	desc = "A tightly furled roll of paper, covered with indecipherable runes."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"

/obj/item/organ/internal/brain/Destroy() //copypasted from MMIs.
	QDEL_NULL(brainmob)
	return ..()

/obj/item/organ/internal/brain/cluwne

/obj/item/organ/internal/brain/cluwne/insert(mob/living/target, special = ORGAN_MANIPULATION_DEFAULT, make_cluwne = TRUE)
	..(target, special)
	if(ishuman(target) && make_cluwne)
		var/mob/living/carbon/human/H = target
		H.makeCluwne() //No matter where you go, no matter what you do, you cannot escape

