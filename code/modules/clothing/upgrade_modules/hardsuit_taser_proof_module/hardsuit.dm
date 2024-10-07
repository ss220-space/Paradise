/obj/item/clothing/suit/space/hardsuit
	var/obj/item/hardsuit_taser_proof/taser_proof = null

/obj/item/clothing/suit/space/hardsuit/Initialize(mapload)
	. = ..()
	if(taser_proof && ispath(taser_proof))
		taser_proof = new taser_proof(src)
		taser_proof.hardsuit = src


/obj/item/clothing/suit/space/hardsuit/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(taser_proof)
		var/blocked = taser_proof.hit_reaction(owner, hitby, attack_text, final_block_chance, damage, attack_type)
		if(blocked)
			return TRUE
	. = ..()

//////Taser-proof Hardsuits

/obj/item/clothing/suit/space/hardsuit/deathsquad
	taser_proof = /obj/item/hardsuit_taser_proof/ert_locked
