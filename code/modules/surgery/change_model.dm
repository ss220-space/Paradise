/datum/surgery/cybernetic_repair/change_model
	name = "Change Model"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/rewrite_name)
	possible_locs = list("chest")

/datum/surgery_step/robotics/external/rewrite_name
	name = "write a model name"
	allowed_tools = list(
		/obj/item/pen = 100,
		/obj/item/hand_labeler = 100,
	)

	time = 64

/datum/surgery_step/robotics/external/rewrite_name/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	user.visible_message("[user] begins to alter [target]'s appearance.",
	"<span class='notice'You begin to alter [target]'s appearance...</span>")
	..()

/datum/surgery_step/robotics/external/rewrite_name/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/list/names = list()
	var/list_size = 10
	//IDs in hand
	if(istype(user, /mob/living/carbon/human)) //Only 'humans' can hold ID cards
		var/mob/living/carbon/human/H = user
		var/obj/item/card/id/id = H.get_id_from_hands()
		if(istype(id))
			names += id.registered_name
			list_size-- //To stop list bloat

	//IDs on body
	var/list/id_list = list()
	for(var/obj/item/I in range(0, target)) //Get ID cards
		if(I.GetID())
			id_list += I.GetID()

	for(var/obj/item/card/id/id in id_list) //Add card names to 'names'
		if(id.registered_name != target.real_name)
			names += id.registered_name
			list_size--

	if(!isabductor(user))
		for(var/i in 1 to list_size)
			names += random_name(target.gender, target.dna.species.name)

	else //Abductors get to pick fancy names
		list_size-- //One less cause they get a normal name too
		for(var/i in 1 to list_size)
			names += "Subject [target.gender == MALE ? "I" : "O"]-[pick("A", "B", "C", "D", "E")]-[rand(10000, 99999)]"
		names += random_name(target.gender, target.dna.species.name) //give one normal name in case they want to do regular plastic surgery
	var/chosen_name = input(user, "Choose a new name to assign.", "Metal Surgery") as null|anything in names
	if(!chosen_name)
		return
	var/oldname = target.real_name
	var/new_name = chosen_name
	target.real_name = new_name
	user.visible_message("[user] alters [oldname]'s appearance completely, [target.p_they()] [target.p_are()] now [new_name]!", "<span class='notice'>You alter [oldname]'s appearance completely, [target.p_they()] [target.p_are()] now [new_name].</span>")
	target.sec_hud_set_ID()
	return TRUE

/datum/surgery_step/robotics/external/rewrite_name/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to change the model on [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool] slips, failing to change the model on [target]'s [affected.name].</span>")
	return 0
