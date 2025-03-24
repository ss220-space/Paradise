/**********************************
*******Interactions code by HONKERTRON feat TestUnit********
***********************************/

/mob/living/carbon/human/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(src == usr)
		interact(over_object)


/mob/proc/make_interaction()
	return

//Distant interactions
/mob/living/carbon/human/verb/interact(mob/M as mob)
	set name = "Interact"
	set category = "IC"

	if (ishuman(M) && usr != M && src != M)
		partner = M
		make_interaction(machine)


/mob/living/carbon/human/proc/is_nude()
	return (!wear_suit && !w_uniform) ? 1 : 0 //TODO: Nudity check for underwear

/mob/living/carbon/human/make_interaction()
	set_machine(src)

	var/mob/living/carbon/human/H = usr
	var/mob/living/carbon/human/P = H.partner
	var/obj/item/organ/external/temp = H.bodyparts_by_name[BODY_ZONE_PRECISE_R_HAND]
	var/hashands = (temp?.is_usable())
	if (!hashands)
		temp = H.bodyparts_by_name[BODY_ZONE_PRECISE_L_HAND]
		hashands = (temp?.is_usable())
	temp = P.bodyparts_by_name[BODY_ZONE_PRECISE_R_HAND]
	var/hashands_p = (temp?.is_usable())
	if (!hashands_p)
		temp = P.bodyparts_by_name[BODY_ZONE_PRECISE_L_HAND]
		hashands = (temp?.is_usable())
	var/mouthfree = !((H.head && (H.head.flags_cover & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags_cover & MASKCOVERSMOUTH)))
	var/mouthfree_p = !((P.head && (P.head.flags_cover & HEADCOVERSMOUTH)) || (P.wear_mask && (P.wear_mask.flags_cover & MASKCOVERSMOUTH)))


	var/dat = {"<b><hr><span style='font-size: 3;'>[H.partner]</span></b><br><hr>"}

	dat +=  {"• <a href='byond://?src=[UID()];interaction=bow'>Отвесить поклон.</a><br>"}
	if (hashands)
		dat +=  {"<span style='font-size: 3;'><b>Руки:</b></span><br>"}
		dat +=  {"• <a href='byond://?src=[UID()];interaction=wave'>Приветливо помахать.</a><br>"}
		dat +=  {"• <a href='byond://?src=[UID()];interaction=bow_affably'>Приветливо кивнуть.</a><br>"}
		if (Adjacent(P))
			dat +=  {"• <a href='byond://?src=[UID()];interaction=handshake'>Пожать руку.</a><br>"}
			dat +=  {"• <a href='byond://?src=[UID()];interaction=hug'>Обнимашки!</a><br>"}
			dat +=  {"• <a href='byond://?src=[UID()];interaction=cheer'>Похлопать по плечу</a><br>"}
			dat +=  {"• <a href='byond://?src=[UID()];interaction=five'>Дать пять.</a><br>"}
			if (hashands_p)
				dat +=  {"• <a href='byond://?src=[UID()];interaction=give'>Передать предмет.</a><br>"}
			dat +=  {"• <a href='byond://?src=[UID()];interaction=slap'><span style='color: darkred;'>Дать пощечину!</span></a><br>"}
			if (P.dna.species.name == SPECIES_MOTH)
				dat +=  {"• <a href='byond://?src=[UID()];interaction=pullwing'><span style='color: darkred;'>Дёрнуть за крылья!</span></a><br>"}
			if ((P.dna.species.name == SPECIES_TAJARAN)  || (P.dna.species.name == SPECIES_VOX)|| (P.dna.species.name == SPECIES_VULPKANIN) || (P.dna.species.name == SPECIES_UNATHI))
				dat +=  {"• <a href='byond://?src=[UID()];interaction=pull'><span style='color: darkred;'>Дёрнуть за хвост!</span></a><br>"}
				if(P.can_inject(H))
					dat +=  {"• <a href='byond://?src=[UID()];interaction=pet'>Погладить.</a><br>"}
					dat +=  {"• <a href='byond://?src=[UID()];interaction=scratch'>Почесать.</a><br>"}
			dat +=  {"• <a href='byond://?src=[UID()];interaction=knock'><span style='color: darkred;'>Дать подзатыльник.</span></a><br>"}
		dat +=  {"• <a href='byond://?src=[UID()];interaction=fuckyou'><span style='color: darkred;'>Показать средний палец.</span></a><br>"}
		dat +=  {"• <a href='byond://?src=[UID()];interaction=threaten'><span style='color: darkred;'>Погрозить кулаком.</span></a><br>"}

	if (mouthfree && H.dna.species.name != SPECIES_DIONA)
		dat += {"<span style='font-size: 3;'><b>Лицо:</b></span><br>"}
		dat += {"• <a href='byond://?src=[UID()];interaction=kiss'>Поцеловать.</a><br>"}
		if (Adjacent(P))
			if (mouthfree_p)
				dat += {"• <a href='byond://?src=[UID()];interaction=lick'>Лизнуть в щеку.</a><br>"}
			dat +=  {"• <a href='byond://?src=[UID()];interaction=spit'><span style='color: darkred;'>Плюнуть.</span></a><br>"}
		dat +=  {"• <a href='byond://?src=[UID()];interaction=tongue'><span style='color: darkred;'>Показать язык.</span></a><br>"}

	var/datum/browser/popup = new(usr, "interactions", "Взаимодействие", 340, 520)
	popup.set_content(dat)
	popup.open()


/mob/living/carbon/human
	var/mob/living/carbon/human/partner
	var/mob/living/carbon/human/last_interract
