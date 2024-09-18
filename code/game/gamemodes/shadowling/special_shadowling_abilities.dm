//In here: Hatch and Ascendance
GLOBAL_LIST_INIT(possibleShadowlingNames, list("U'ruan", "Y`shej", "Nex", "Hel-uae", "Noaey'gief", "Mii`mahza", "Amerziox", "Gyrg-mylin", "Kanet'pruunance", "Vigistaezian")) //Unpronouncable 2: electric boogalo)


/obj/effect/proc_holder/spell/shadowling_hatch
	name = "Hatch"
	desc = "Casts off your disguise."
	base_cooldown = 5 MINUTES
	clothes_req = FALSE
	action_icon_state = "hatch"
	var/cycles_unused = 0


/obj/effect/proc_holder/spell/shadowling_hatch/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_hatch/cast(list/targets, mob/living/carbon/human/user = usr)
	if(user.stat || !ishuman(user) || !user || !is_shadow(user) || isinspace(user))
		return

	if(!isturf(user.loc))
		revert_cast(user)
		to_chat(user, span_warning("You must be standing on a floor to hatch!"))
		return

	if(tgui_alert(user,"Are you sure you want to hatch? You cannot undo this!", "Hatch", list("Yes", "No")) != "Yes")
		to_chat(user, span_warning("You decide against hatching for now."))
		revert_cast(user)
		return

	ADD_TRAIT(user, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))
	user.visible_message(span_warning("[user]'s things suddenly slip off. They hunch over and vomit up a copious amount of purple goo which begins to shape around them!"), \
						span_shadowling("You remove any equipment which would hinder your hatching and begin regurgitating the resin which will protect you."))

	for(var/obj/item/item as anything in user.get_equipped_items(TRUE, TRUE))
		user.drop_item_ground(item, force = TRUE)


	sleep(5 SECONDS)
	if(QDELETED(user))
		return

	var/turf/shadowturf = get_turf(user)
	for(var/turf/simulated/floor/F in orange(1, user))
		new /obj/structure/alien/resin/wall/shadowling(F)

	for(var/obj/structure/alien/resin/wall/shadowling/R in shadowturf) //extremely hacky
		qdel(R)
		new /obj/structure/alien/weeds/node(shadowturf) //Dim lighting in the chrysalis -- removes itself afterwards

	//Can't die while hatching
	ADD_TRAIT(user, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src))

	user.visible_message(span_warning("A chrysalis forms around [user], sealing [user.p_them()] inside."), \
						span_shadowling("You create your chrysalis and begin to contort within."))

	sleep(10 SECONDS)
	if(QDELETED(user))
		return

	user.visible_message(span_boldwarning("The skin on [user]'s back begins to split apart. Black spines slowly emerge from the divide."), \
						span_shadowling("Spines pierce your back. Your claws break apart your fingers. You feel excruciating pain as your true form begins its exit."))

	sleep(9 SECONDS)
	if(QDELETED(user))
		return

	user.visible_message(span_boldwarning("[user], skin shifting, begins tearing at the walls around [user.p_them()]."), \
						span_shadowling("Your false skin slips away. You begin tearing at the fragile membrane protecting you."))

	sleep(8 SECONDS)
	if(QDELETED(user))
		return

	playsound(user.loc, 'sound/weapons/slash.ogg', 15, TRUE, SILENCED_SOUND_EXTRARANGE)
	to_chat(user, span_boldnotice("You rip and slice."))


	sleep(1 SECONDS)
	if(QDELETED(user))
		return

	playsound(user.loc, 'sound/weapons/slashmiss.ogg', 15, TRUE, SILENCED_SOUND_EXTRARANGE)
	to_chat(user, span_boldnotice("The chrysalis falls like water before you."))

	sleep(1 SECONDS)
	if(QDELETED(user))
		return

	playsound(user.loc, 'sound/weapons/slice.ogg', 15, TRUE, SILENCED_SOUND_EXTRARANGE)
	to_chat(user, span_boldnotice("You are free!"))

	sleep(1 SECONDS)
	if(QDELETED(user))
		return

	playsound(user.loc, 'sound/effects/ghost.ogg', 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/newNameId = pick(GLOB.possibleShadowlingNames)
	GLOB.possibleShadowlingNames.Remove(newNameId)
	user.real_name = newNameId
	user.name = user.real_name
	to_chat(user, span_mind_control("YOU LIVE!!!"))
	user.remove_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), UNIQUE_TRAIT_SOURCE(src))

	for(var/obj/structure/alien/resin/wall/shadowling/resin in orange(user, 1))
		qdel(resin)

	for(var/obj/structure/alien/weeds/node/node in shadowturf)
		qdel(node)

	user.visible_message(span_warning("The chrysalis explodes in a shower of purple flesh and fluid!"))
	user.underwear = "None"
	user.undershirt = "None"
	user.socks = "None"
	user.faction |= "faithless"

	user.set_species(/datum/species/shadow/ling)	//can't be a shadowling without being a shadowling
	user.equip_to_slot_or_del(new /obj/item/clothing/under/shadowling(user), ITEM_SLOT_CLOTH_INNER)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/shadowling(user), ITEM_SLOT_FEET)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(user), ITEM_SLOT_CLOTH_OUTER)
	user.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(user), ITEM_SLOT_HEAD)
	user.equip_to_slot_or_del(new /obj/item/clothing/gloves/shadowling(user), ITEM_SLOT_GLOVES)
	user.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/shadowling(user), ITEM_SLOT_MASK)
	user.equip_to_slot_or_del(new /obj/item/clothing/glasses/shadowling(user), ITEM_SLOT_EYES)

	user.mind.RemoveSpell(src)

	sleep(1 SECONDS)
	if(QDELETED(user))
		return

	to_chat(user, span_shadowling("<b><i>Your powers are awoken. You may now live to your fullest extent. Remember your goal. Cooperate with your thralls and allies.</b></i>"))
	user.ExtinguishMob()
	user.set_nutrition(NUTRITION_LEVEL_FED + 50)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_vision(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_enthrall(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_glare(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_veil(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_shadow_walk(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_icy_veins(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_collective_mind(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_regen_armor(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_extend_shuttle(null))

	QDEL_NULL(user.hud_used)
	user.hud_used = new /datum/hud/human(user, ui_style2icon(user.client.prefs.UI_style), user.client.prefs.UI_style_color, user.client.prefs.UI_style_alpha)
	user.hud_used.show_hud(user.hud_used.hud_version)


/obj/effect/proc_holder/spell/shadowling_ascend
	name = "Ascend"
	desc = "Enters your true form."
	base_cooldown = 5 MINUTES
	clothes_req = FALSE
	action_icon_state = "ascend"


/obj/effect/proc_holder/spell/shadowling_ascend/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_ascend/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!shadowling_check(user))
		return

	if(tgui_alert(user, "It is time to ascend. Are you sure about this?", "Ascend", list("Yes", "No")) != "Yes")
		to_chat(user, span_warning("You decide against ascending for now."))
		revert_cast(user)
		return

	ADD_TRAIT(user, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	user.visible_message(span_warning("[user] gently rises into the air, red light glowing in its eyes."), \
						span_shadowling("You rise into the air and get ready for your transformation."))

	sleep(5 SECONDS)
	if(QDELETED(user))
		return

	user.visible_message(span_warning("[user]'s skin begins to crack and harden."), \
						span_shadowling("Your flesh begins creating a shield around yourself."))

	sleep(10 SECONDS)
	if(QDELETED(user))
		return
	user.visible_message(span_warning("The small horns on [user]'s head slowly grow and elongate."), \
						span_shadowling("Your body continues to mutate. Your telepathic abilities grow."))	// Nothing was here.

	sleep(9 SECONDS)
	if(QDELETED(user))
		return
	user.visible_message(span_warning("[user]'s body begins to violently stretch and contort."), \
						span_shadowling("You begin to rend apart the final barriers to godhood."))

	sleep(4 SECONDS)
	if(QDELETED(user))
		return
	to_chat(user, span_boldwarning("Yes!"))

	sleep(1 SECONDS)
	if(QDELETED(user))
		return
	to_chat(user, span_big(span_boldwarning("YES!!")))

	sleep(1 SECONDS)
	if(QDELETED(user))
		return
	to_chat(user, span_reallybig(span_boldwarning("YE--")))

	sleep(0.1 SECONDS)
	if(QDELETED(user))
		return
	for(var/mob/living/mob in orange(7, user))
		mob.Weaken(20 SECONDS)
		to_chat(mob, span_userdanger("An immense pressure slams you onto the ground!"))

	for(var/obj/machinery/power/apc/apc in GLOB.apcs)
		INVOKE_ASYNC(apc, TYPE_PROC_REF(/obj/machinery/power/apc, overload_lighting))

	var/mob/living/simple_animal/ascendant_shadowling/ascendant = new (user.loc)
	ascendant.announce("VYSHA NERADA YEKHEZET U'RUU!!", 5, 'sound/hallucinations/veryfar_noise.ogg')
	for(var/obj/effect/proc_holder/spell/spell as anything in user.mind.spell_list)
		if(spell == src)
			continue
		user.mind.RemoveSpell(spell)

	user.mind.transfer_to(ascendant)
	ascendant.name = user.real_name
	ascendant.languages = user.languages
	ascendant.mind.AddSpell(new /obj/effect/proc_holder/spell/ascendant_annihilate(null))
	ascendant.mind.AddSpell(new /obj/effect/proc_holder/spell/ascendant_hypnosis(null))
	ascendant.mind.AddSpell(new /obj/effect/proc_holder/spell/ascendant_phase_shift(null))
	ascendant.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/ascendant_storm(null))
	ascendant.mind.AddSpell(new /obj/effect/proc_holder/spell/ascendant_transmit(null))
	ascendant.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_revive_thrall/ascendant(null))

	if(ascendant.real_name)
		ascendant.real_name = user.real_name

	user.invisibility = INVISIBILITY_OBSERVER	//This is pretty bad, but is also necessary for the shuttle call to function properly
	user.forceMove(ascendant)

	sleep(5 SECONDS)
	if(QDELETED(user))
		return

	if(!SSticker.mode.shadowling_ascended)
		SSshuttle.emergency.request(null, 0.3)
		SSshuttle.emergency.canRecall = FALSE

	SSticker.mode.shadowling_ascended = TRUE
	ascendant.mind.RemoveSpell(src)
	qdel(user)


/**
 * Testing purpose.
 */
/mob/living/carbon/human/proc/make_unhatched_shadowling()
	for(var/obj/item/item as anything in get_equipped_items(TRUE, TRUE))
		drop_item_ground(item, force = TRUE)

	var/newNameId = pick(GLOB.possibleShadowlingNames)
	GLOB.possibleShadowlingNames.Remove(newNameId)
	real_name = newNameId
	name = real_name

	underwear = "None"
	undershirt = "None"
	socks = "None"
	faction |= "faithless"
	add_language(LANGUAGE_HIVE_SHADOWLING)

	set_species(/datum/species/shadow/ling)
	equip_to_slot_or_del(new /obj/item/clothing/under/shadowling(src), ITEM_SLOT_CLOTH_INNER)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/shadowling(src), ITEM_SLOT_FEET)
	equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(src), ITEM_SLOT_CLOTH_OUTER)
	equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(src), ITEM_SLOT_HEAD)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/shadowling(src), ITEM_SLOT_GLOVES)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/shadowling(src), ITEM_SLOT_MASK)
	equip_to_slot_or_del(new /obj/item/clothing/glasses/shadowling(src), ITEM_SLOT_EYES)

	to_chat(src, span_shadowling("<b><i>Your powers are awoken. You may now live to your fullest extent. Remember your goal. Cooperate with your thralls and allies.</b></i>"))

	ExtinguishMob()
	set_nutrition(NUTRITION_LEVEL_FED + 50)
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_vision(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_enthrall(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_glare(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_veil(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_shadow_walk(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_icy_veins(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_collective_mind(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_regen_armor(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_extend_shuttle(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_screech(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_blindness_smoke(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_null_charge(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_revive_thrall(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_ascend(null))

	mind.special_role = SPECIAL_ROLE_SHADOWLING
	SSticker.mode.shadows += mind
	SSticker.mode.update_shadow_icons_added(mind)

