/obj/item/organ/internal
	origin_tech = "biotech=3"
	force = 1
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	/// Unique slot this organ occupies. See [combat.dm] for defines. DO NOT add slots with matching names to different zones - it will break internal_organs_slot list!
	var/slot = NONE
	/// Whether it shows up as an option to remove during surgery.
	var/unremovable = FALSE
	var/can_see_food = FALSE
	light_system = MOVABLE_LIGHT
	light_on = FALSE


/obj/item/organ/internal/New(mob/living/carbon/holder)
	..()
	if(istype(holder))
		insert(holder)

	if(species_type == /datum/species/diona)
		AddComponent(/datum/component/diona_internals)


/obj/item/organ/internal/proc/insert(mob/living/carbon/target, special = ORGAN_MANIPULATION_DEFAULT)
	if(!iscarbon(target) || owner == target)
		return FALSE

	. = TRUE

	do_pickup_animation(src, target)

	var/obj/item/organ/internal/replaced = target.get_organ_slot(slot)
	if(replaced)
		replaced.remove(target, ORGAN_MANIPULATION_NOEFFECT)

	owner = target
	target.internal_organs |= src
	target.internal_organs_slot[slot] = src

	if(ishuman(target))
		var/mob/living/carbon/human/h_target = target
		var/obj/item/organ/external/parent = h_target.get_organ(check_zone(parent_organ_zone))
		if(!istype(parent))
			stack_trace("[src] attempted to insert into a [parent_organ_zone], but [parent_organ_zone] wasn't an organ! [atom_loc_line(h_target)]")
		else
			LAZYOR(parent.internal_organs, src)
		h_target.update_int_organs()

	loc = null

	for(var/datum/action/action as anything in actions)
		action.Grant(target)

	if(vital)
		target.update_stat("Vital organ inserted")

	STOP_PROCESSING(SSobj, src)


/**
 * Removes the given organ from its owner.
 * Returns the removed object, which is usually just itself.
 * However, you MUST set the object's positiion yourself when you call this!
 */
/obj/item/organ/internal/remove(mob/living/carbon/target, special = ORGAN_MANIPULATION_DEFAULT)
	if(!owner)
		stack_trace("\'remove\' called on [src] without an owner! Mob: [target], [atom_loc_line(target)]")
		return

	if(target != owner)
		return

	var/mob/living/carbon/organ_owner = target || owner
	var/send_signal = FALSE

	if(iscarbon(organ_owner))
		organ_owner.internal_organs -= src
		if(organ_owner.internal_organs_slot[slot] == src)
			organ_owner.internal_organs_slot[slot] = null
			if(!special)
				send_signal = TRUE
		if(vital && !special && organ_owner.stat != DEAD)
			organ_owner.death()

	if(ishuman(organ_owner))
		var/mob/living/carbon/human/h_owner = organ_owner
		var/obj/item/organ/external/parent = h_owner.get_organ(check_zone(parent_organ_zone))
		if(isexternalorgan(parent))
			LAZYREMOVE(parent.internal_organs, src)
		else
			stack_trace("[src] attempted to remove from a [parent_organ_zone], but [parent_organ_zone] didn't exist! [atom_loc_line(target)]")
		h_owner.update_int_organs()

	for(var/datum/action/action as anything in actions)
		action.Remove(organ_owner)

	if(send_signal)
		SEND_SIGNAL(organ_owner, COMSIG_CARBON_LOSE_ORGAN, src)
		SEND_SIGNAL(src, COMSIG_ORGAN_REMOVED, organ_owner)

	owner = null
	START_PROCESSING(SSobj, src)
	return src


/obj/item/organ/internal/emp_act(severity)
	if(!is_robotic() || emp_proof)
		return
	switch(severity)
		if(1)
			internal_receive_damage(20, silent = TRUE)
		if(2)
			internal_receive_damage(7, silent = TRUE)


/obj/item/organ/internal/replaced(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
    insert(target)


/obj/item/organ/internal/item_action_slot_check(slot, mob/user, datum/action/action)
	return FALSE


/obj/item/organ/internal/proc/on_find(mob/living/finder)
	return


/obj/item/organ/internal/proc/on_life()
	return


//abstract proc called by carbon/death()
/obj/item/organ/internal/proc/on_owner_death()
 	return


/obj/item/organ/internal/proc/prepare_eat()
	if(is_robotic())
		return //no eating cybernetic implants!
	var/obj/item/reagent_containers/food/snacks/organ/S = new
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.origin_tech = origin_tech
	S.w_class = w_class
	return S


/obj/item/organ/internal/attempt_become_organ(obj/item/organ/external/parent, mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	if(parent_organ_zone != parent.limb_zone)
		return FALSE
	insert(target, special)
	return TRUE


// Rendering!
/obj/item/organ/internal/proc/render()
	return


/obj/item/reagent_containers/food/snacks/organ
	name = "appendix"
	icon_state = "appendix"
	icon = 'icons/obj/surgery.dmi'
	list_reagents = list("nutriment" = 5)


/obj/item/organ/internal/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(target != user || !ishuman(target) || !user.can_unEquip(src))
		return ..()

	var/obj/item/reagent_containers/food/snacks/snack = prepare_eat()
	if(!snack)
		return ATTACK_CHAIN_PROCEED

	user.temporarily_remove_item_from_inventory(src)
	target.put_in_active_hand(snack, silent = TRUE)
	snack.attack(target, target, params)
	qdel(src)
	return ATTACK_CHAIN_BLOCKED_ALL


/****************************************************
				INTERNAL ORGANS DEFINES
****************************************************/


// Brain is defined in brain_item.dm.

/obj/item/organ/internal/robotize(make_tough = FALSE)
	if(!is_robotic())
		var/list/states = icon_states('icons/obj/surgery.dmi') //Insensitive to specially-defined icon files for species like the Drask or whomever else. Everyone gets the same robotic heart.
		if(slot == INTERNAL_ORGAN_HEART && ("[slot]-c-on" in states) && ("[slot]-c-off" in states)) //Give the robotic heart its robotic heart icons if they exist.
			var/obj/item/organ/internal/heart/H = src
			H.icon = icon('icons/obj/surgery.dmi')
			H.icon_base = "[slot]-c"
			H.dead_icon = "[slot]-c-off"
			H.update_icon()
		else if("[slot]-c" in states) //Give the robotic organ its robotic organ icons if they exist.
			icon = icon('icons/obj/surgery.dmi')
			icon_state = "[slot]-c"
		name = "cybernetic [slot]"
	..() //Go apply all the organ flags/robotic statuses.


/obj/item/organ/internal/appendix
	name = "appendix"
	icon_state = "appendix"
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN
	slot = INTERNAL_ORGAN_APPENDIX
	var/inflamed = FALSE


/obj/item/organ/internal/appendix/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	for(var/datum/disease/appendicitis/A in M.diseases)
		A.cure()
		inflamed = TRUE
	update_icon()
	. = ..()


/obj/item/organ/internal/appendix/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	..()
	if(inflamed)
		var/datum/disease/appendicitis/D = new
		D.Contract(M)


/obj/item/organ/internal/appendix/prepare_eat()
	var/obj/S = ..()
	if(inflamed)
		S.reagents.add_reagent("????", 5)
	return S


//shadowling tumor
/obj/item/organ/internal/shadowtumor
	name = "black tumor"
	desc = "A tiny black mass with red tendrils trailing from it. It seems to shrivel in the light."
	icon_state = "blacktumor"
	origin_tech = "biotech=5"
	w_class = WEIGHT_CLASS_TINY
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_BRAIN_TUMOR
	max_integrity = 3


/obj/item/organ/internal/shadowtumor/New()
	..()
	START_PROCESSING(SSobj, src)


/obj/item/organ/internal/shadowtumor/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/organ/internal/shadowtumor/process()
	if(isturf(loc))
		var/turf/T = loc
		var/light_count = T.get_lumcount()*10
		if(light_count > 4 && obj_integrity > 0) //Die in the light
			obj_integrity--
		else if(light_count < 2 && obj_integrity < max_integrity) //Heal in the dark
			obj_integrity++
		if(obj_integrity <= 0)
			visible_message(span_warning("[src] collapses in on itself!"))
			qdel(src)


//debug and adminbus....

/obj/item/organ/internal/honktumor
	name = "banana tumor"
	desc = "A tiny yellow mass shaped like..a banana?"
	icon_state = "honktumor"
	origin_tech = "biotech=1"
	w_class = WEIGHT_CLASS_TINY
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_BRAIN_TUMOR
	var/organhonked = 0
	var/suffering_delay = 900
	var/datum/component/squeak


/obj/item/organ/internal/honktumor/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	..()
	M.force_gene_block(GLOB.clumsyblock, TRUE)
	M.force_gene_block(GLOB.comicblock, TRUE)
	organhonked = world.time
	M.AddElement(/datum/element/waddling)
	squeak = M.AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'), 50, falloff_exponent = 20)


/obj/item/organ/internal/honktumor/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	M.force_gene_block(GLOB.clumsyblock, FALSE)
	M.force_gene_block(GLOB.comicblock, FALSE)
	M.RemoveElement(/datum/element/waddling)
	QDEL_NULL(squeak)
	. = ..()


/obj/item/organ/internal/honktumor/on_life()
	if(organhonked < world.time)
		organhonked = world.time + suffering_delay
		to_chat(owner, "<font color='red' size='7'>HONK</font>")
		owner.SetSleeping(0)
		owner.Stuttering(40 SECONDS)
		owner.Deaf(60 SECONDS)
		owner.Weaken(6 SECONDS)
		SEND_SOUND(owner, sound('sound/items/airhorn.ogg'))
		if(prob(30))
			owner.Stun(20 SECONDS)
			owner.Paralyse(8 SECONDS)
		else
			owner.Jitter(1000 SECONDS)

		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(isobj(H.shoes))
				var/thingy = H.shoes
				if(H.drop_item_ground(H.shoes))
					SSmove_manager.move_away(thingy, H, 15, 2)
					spawn(20)
						if(thingy)
							SSmove_manager.stop_looping(thingy)


/obj/item/organ/internal/honktumor/cursed
	unremovable = TRUE


/obj/item/organ/internal/honktumor/cursed/on_life() //No matter what you do, no matter who you are, no matter where you go, you're always going to be a fat, stuttering dimwit.
	..()
	owner.setBrainLoss(80)
	owner.set_nutrition(9000)
	owner.overeatduration = 9000


/obj/item/organ/internal/honkbladder
	name = "honk bladder"
	desc = "a air filled sac that produces honking noises."
	icon_state = "honktumor"//Not making a new icon
	origin_tech = "biotech=1"
	w_class = WEIGHT_CLASS_TINY
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN
	slot = INTERNAL_ORGAN_HONK_BLADDER
	var/datum/component/squeak


/obj/item/organ/internal/honkbladder/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	squeak = M.AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg'), 50, falloff_exponent = 20)


/obj/item/organ/internal/honkbladder/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()

	QDEL_NULL(squeak)
	qdel(src)


/obj/item/organ/internal/beard
	name = "beard organ"
	desc = "Let they who is worthy wear the beard of Thorbjorndottir."
	icon_state = "liver"
	origin_tech = "biotech=1"
	w_class = WEIGHT_CLASS_TINY
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_HAIR


/obj/item/organ/internal/beard/on_life()

	if(!owner)
		return

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/obj/item/organ/external/head/head_organ = H.get_organ(BODY_ZONE_HEAD)
		if(!(head_organ.h_style == "Very Long Hair" || head_organ.h_style == "Mohawk"))
			if(prob(10))
				head_organ.h_style = "Mohawk"
			else
				head_organ.h_style = "Very Long Hair"
			head_organ.hair_colour = "#D8C078"
			H.update_hair()
		if(!(head_organ.f_style == "Very Long Beard"))
			head_organ.f_style = "Very Long Beard"
			head_organ.facial_colour = "#D8C078"
			H.update_fhair()


/obj/item/organ/internal/handle_germs()
	..()
	if(!ishuman(owner))
		return
	var/germs_mod = owner.dna.species.germs_growth_mod * owner.physiology.germs_growth_mod
	if(germ_level >= INFECTION_LEVEL_TWO && prob(3 * germs_mod))
		// big message from every 1 damage is not good. If germs growth rate is big, it will spam the chat.
		internal_receive_damage(1, silent = prob(30 * germs_mod))


/mob/living/carbon/human/proc/check_infections()
	var/list/infections = list()
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		if(organ.germ_level > 0)
			infections.Add(organ)
	return infections


/mob/living/carbon/human/proc/check_damaged_organs()
	var/list/damaged = list()
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		if(organ.damage > 0)
			damaged.Add(organ)
	return damaged

