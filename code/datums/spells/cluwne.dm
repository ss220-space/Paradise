/obj/effect/proc_holder/spell/touch/cluwne
	name = "Curse of the Cluwne"
	desc = "Turns the target into a fat and cursed monstrosity of a clown."
	hand_path = /obj/item/melee/touch_attack/cluwne

	school = "transmutation"

	base_cooldown = 1 MINUTES
	clothes_req = TRUE
	cooldown_min = 20 SECONDS //100 deciseconds reduction per rank

	action_icon_state = "cluwne"


/mob/living/carbon/human/proc/makeCluwne()
	if(!get_int_organ(/obj/item/organ/internal/brain/cluwne))
		var/obj/item/organ/internal/brain/cluwne/idiot_brain = new
		internal_organs |= idiot_brain	//Well, everything's for recursion prevention.
		idiot_brain.insert(src, make_cluwne = FALSE)
		idiot_brain.dna = dna.Clone()
	else
		return
	to_chat(src, span_danger("You feel funny."))
	setBrainLoss(80)
	set_nutrition(9000)
	overeatduration = 9000
	Confused(60 SECONDS)
	if(mind)
		mind.assigned_role = "Cluwne"

	var/obj/item/organ/internal/honktumor/cursed/tumor = new
	tumor.insert(src)
	force_gene_block(GLOB.nervousblock, TRUE)
	rename_character(newname = "cluwne")

	drop_item_ground(w_uniform, force = TRUE)
	drop_item_ground(shoes, force = TRUE)
	drop_item_ground(gloves, force = TRUE)
	if(!istype(wear_mask, /obj/item/clothing/mask/cursedclown)) //Infinite loops otherwise
		drop_item_ground(wear_mask, force = TRUE)
	equip_to_slot_or_del(new /obj/item/clothing/under/cursedclown, ITEM_SLOT_CLOTH_INNER)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/cursedclown, ITEM_SLOT_GLOVES)
	equip_to_slot_or_del(new /obj/item/clothing/mask/cursedclown, ITEM_SLOT_MASK)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/cursedclown, ITEM_SLOT_FEET)
	grant_mimicking()

/mob/living/carbon/human/proc/makeAntiCluwne()
	to_chat(src, "<span class='danger'>You don't feel very funny.</span>")
	adjustBrainLoss(-120)
	set_nutrition(NUTRITION_LEVEL_STARVING)
	overeatduration = 0
	SetConfused(0)
	SetJitter(0)
	if(mind)
		mind.assigned_role = "Lawyer"

	var/obj/item/organ/internal/honktumor/cursed/tumor = get_int_organ(/obj/item/organ/internal/honktumor/cursed)
	if(tumor)
		tumor.remove(src)
	else
		force_gene_block(GLOB.comicblock, FALSE)
		force_gene_block(GLOB.clumsyblock, FALSE)
	force_gene_block(GLOB.nervousblock, FALSE)

	var/obj/item/clothing/under/U = w_uniform
	drop_item_ground(w_uniform, force = TRUE)
	if(U)
		qdel(U)

	var/obj/item/clothing/shoes/S = shoes
	drop_item_ground(shoes, force = TRUE)
	if(S)
		qdel(S)

	if(istype(wear_mask, /obj/item/clothing/mask/cursedclown))
		drop_item_ground(wear_mask, force = TRUE)

	if(istype(gloves, /obj/item/clothing/gloves/cursedclown))
		var/obj/item/clothing/gloves/G = gloves
		drop_item_ground(gloves, force = TRUE)
		qdel(G)

	equip_to_slot_or_del(new /obj/item/clothing/under/lawyer/black, ITEM_SLOT_CLOTH_INNER)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/black, ITEM_SLOT_FEET)

