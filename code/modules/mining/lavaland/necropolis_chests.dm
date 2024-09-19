//The chests dropped by mob spawner tendrils. Also contains associated loot.

/obj/structure/closet/crate/necropolis
	name = "necropolis chest"
	desc = "It's watching you closely."
	icon_state = "necrocrate"
	icon_opened = "necrocrateopen"
	icon_closed = "necrocrate"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/closet/crate/necropolis/tendril
	desc = "It's watching you suspiciously."

/obj/structure/closet/crate/necropolis/tendril/populate_contents()
	switch(rand(1, 32))
		if(1)
			new /obj/item/shared_storage(src)
		if(2)
			new /obj/item/clothing/head/helmet/space/cult(src)
			new /obj/item/clothing/suit/space/cult(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(3)
			new /obj/item/soulstone/anybody(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(4)
			new /obj/item/organ/internal/cyberimp/arm/katana(src)
		if(5)
			new /obj/item/book_of_babel(src)
		if(6)
			new /obj/item/pickaxe/diamond(src)
		if(7)
			new /obj/item/clothing/suit/hooded/cultrobes(src)
			new /obj/item/bedsheet/cult(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(8)
			new /obj/item/spellbook/oneuse/summonitem(src)
		if(9)
			new /obj/item/rod_of_asclepius(src)
		if(10)
			new /obj/item/organ/internal/heart/cursed/wizard(src)
		if(11)
			new /obj/item/ship_in_a_bottle(src)
		if(12)
			new /obj/item/grenade/clusterbuster/inferno(src)
		if(13)
			new /obj/item/jacobs_ladder(src)
		if(14)
			new /obj/item/nullrod/scythe/talking(src)
		if(15)//select and spawn a random nullrod that a chaplain could choose from
			var/path = pick(subtypesof(/obj/item/nullrod))
			new path(src)
		if(16)
			new /obj/item/borg/upgrade/modkit/lifesteal(src)
			new /obj/item/bedsheet/cult(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(17)
			new /obj/item/organ/internal/heart/gland/heals(src)
		if(18)
			new /obj/item/warp_cube/red(src)
		if(19)
			new /obj/item/wisp_lantern(src)
		if(20)
			new /obj/item/immortality_talisman(src)
		if(21)
			new /obj/item/gun/magic/hook(src)
		if(22)
			new /obj/item/voodoo(src)
		if(23, 24)
			switch(rand(1, 4))
				if(1)
					new /obj/item/clothing/suit/space/hardsuit/champion(src)
				if(2)
					new /obj/item/clothing/suit/space/hardsuit/champion/templar(src)
					new /obj/item/reagent_containers/food/drinks/bottle/holywater/hell(src)
				if(3)
					new /obj/item/clothing/suit/space/hardsuit/champion/templar/premium(src)
					new /obj/item/reagent_containers/food/drinks/bottle/holywater(src)
				if(4)
					new /obj/item/clothing/suit/space/hardsuit/champion/inquisitor(src)
					new /obj/item/reagent_containers/food/drinks/bottle/holywater/hell(src)
		if(25)
			new /obj/item/eflowers(src)
		if(26)
			new /obj/item/rune_scimmy(src)
		if(27)
			new /obj/item/dnainjector/midgit(src)
			new /obj/item/grenade/plastic/miningcharge/mega(src)
			new /obj/item/grenade/plastic/miningcharge/mega(src)
			new /obj/item/grenade/plastic/miningcharge/mega(src)
		if(28)
			switch(rand(1, 4))
				if(1)
					new /obj/item/twohanded/kinetic_crusher/mega(src)
				if(2)
					new /obj/item/gun/energy/plasmacutter/shotgun/mega(src)
				if(3)
					new /obj/item/gun/energy/plasmacutter/adv/mega(src)
				if(4)
					new /obj/item/gun/energy/kinetic_accelerator/mega(src)
		if(29)
			new /obj/item/clothing/suit/hooded/clockrobe_fake(src)
			new /obj/item/clothing/gloves/clockwork_fake(src)
			new /obj/item/clothing/shoes/clockwork_fake(src)
			new /obj/item/stack/sheet/brass_fake/fifty(src)
		if(30)
			new /obj/item/clothing/suit/armor/clockwork_fake(src)
			new /obj/item/clothing/head/helmet/clockwork_fake(src)
			new /obj/item/stack/sheet/brass_fake/fifty(src)
		if(31)
			new /obj/item/spellbook/oneuse/goliath_dash(src)
		if(32)
			new /obj/item/spellbook/oneuse/watchers_look(src)

/obj/structure/closet/crate/necropolis/puzzle
	name = "puzzling chest"

/obj/structure/closet/crate/necropolis/puzzle/populate_contents()
	var/loot = rand(1,3)
	switch(loot)
		if(1)
			new /obj/item/soulstone/anybody(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(2)
			new /obj/item/wisp_lantern(src)
		if(3)
			new /obj/item/prisoncube(src)

//KA modkit design discs
/obj/item/disk/design_disk/modkit_disc
	name = "KA Mod Disk"
	desc = "A design disc containing the design for a unique kinetic accelerator modkit. It's compatible with a research console."
	icon_state = "datadisk1"
	var/modkit_design = /datum/design/unique_modkit

/obj/item/disk/design_disk/modkit_disc/New()
	. = ..()
	blueprint = new modkit_design

/obj/item/disk/design_disk/modkit_disc/mob_and_turf_aoe
	name = "Offensive Mining Explosion Mod Disk"
	modkit_design = /datum/design/unique_modkit/offensive_turf_aoe

/obj/item/disk/design_disk/modkit_disc/rapid_repeater
	name = "Rapid Repeater Mod Disk"
	modkit_design = /datum/design/unique_modkit/rapid_repeater

/obj/item/disk/design_disk/modkit_disc/resonator_blast
	name = "Resonator Blast Mod Disk"
	modkit_design = /datum/design/unique_modkit/resonator_blast

/obj/item/disk/design_disk/modkit_disc/bounty
	name = "Death Syphon Mod Disk"
	modkit_design = /datum/design/unique_modkit/bounty

/datum/design/unique_modkit
	build_type = PROTOLATHE
	req_tech = null	// Unreachable by tech researching.

/datum/design/unique_modkit/offensive_turf_aoe
	name = "Kinetic Accelerator Offensive Mining Explosion Mod"
	desc = "A device which causes kinetic accelerators to fire AoE blasts that destroy rock and damage creatures."
	id = "hyperaoemod"
	materials = list(MAT_METAL = 7000, MAT_GLASS = 3000, MAT_SILVER= 3000, MAT_GOLD = 3000, MAT_DIAMOND = 4000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs
	category = list("Mining")

/datum/design/unique_modkit/rapid_repeater
	name = "Kinetic Accelerator Rapid Repeater Mod"
	desc = "A device which greatly reduces a kinetic accelerator's cooldown on striking a living target or rock, but greatly increases its base cooldown."
	id = "repeatermod"
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_URANIUM = 8000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/repeater
	category = list("Mining")

/datum/design/unique_modkit/resonator_blast
	name = "Kinetic Accelerator Resonator Blast Mod"
	desc = "A device which causes kinetic accelerators to fire shots that leave and detonate resonator blasts."
	id = "resonatormod"
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_SILVER= 5000, MAT_URANIUM = 5000)
	build_path = /obj/item/borg/upgrade/modkit/resonator_blasts
	category = list("Mining")

/datum/design/unique_modkit/bounty
	name = "Kinetic Accelerator Death Syphon Mod"
	desc = "A device which causes kinetic accelerators to permanently gain damage against creature types killed with it."
	id = "bountymod"
	materials = list(MAT_METAL = 4000, MAT_SILVER = 4000, MAT_GOLD = 4000, MAT_BLUESPACE = 4000)
	reagents_list = list("blood" = 40)
	build_path = /obj/item/borg/upgrade/modkit/bounty
	category = list("Mining")

//Spooky special loot

//Rod of Asclepius
/obj/item/rod_of_asclepius
	name = "\improper Rod of Asclepius"
	desc = "A wooden rod about the size of your forearm with a snake carved around it, winding its way up the sides of the rod. Something about it seems to inspire in you the responsibilty and duty to help others."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "asclepius_dormant"
	item_state = "asclepius_dormant"
	var/activated = FALSE
	var/usedHand

/obj/item/rod_of_asclepius/attack_self(mob/user)
	if(activated)
		return
	if(!iscarbon(user))
		to_chat(user, "<span class='warning'>The snake carving seems to come alive, if only for a moment, before returning to its dormant state, almost as if it finds you incapable of holding its oath.</span>")
		return
	var/mob/living/carbon/itemUser = user
	if(itemUser.l_hand == src)
		usedHand = 1
	if(itemUser.r_hand == src)
		usedHand = 0
	if(itemUser.has_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH))
		to_chat(user, "<span class='warning'>You can't possibly handle the responsibility of more than one rod!</span>")
		return
	var/failText = "<span class='warning'>The snake seems unsatisfied with your incomplete oath and returns to its previous place on the rod, returning to its dormant, wooden state. You must stand still while completing your oath!</span>"
	to_chat(itemUser, "<span class='notice'>The wooden snake that was carved into the rod seems to suddenly come alive and begins to slither down your arm! The compulsion to help others grows abnormally strong...</span>")
	if(do_after(itemUser, 4 SECONDS, itemUser, max_interact_count = 1))
		itemUser.say("Клянусь Аполлоном врачом, Асклепием, всеми богами и богинями, беря их в свидетели, исполнять честно, соответственно моим силам и здравому смыслу, следующую клятву:")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 4 SECONDS, itemUser))
		itemUser.say("Я буду применять во благо больного все необходимые меры, воздерживаясь от причинения всякого вреда и несправедливости.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 4 SECONDS, itemUser))
		itemUser.say("Я буду предотвращать болезнь всякий раз, как смогу, поскольку предотвращение предпочтительнее, чем лечение.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 4 SECONDS, itemUser))
		itemUser.say("Я не выдам никому просимого у меня смертельного средства и не покажу пути для исполнения подобного замысла.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 4 SECONDS, itemUser))
		itemUser.say("Я буду уважать личную жизнь своих пациентов, поскольку их проблемы раскрываются мне не для того, чтобы о них мог узнать весь мир. Особенно с большой осторожностью я обязуюсь поступать в вопросах жизни и смерти. Если мне будет дано спасти жизнь — я выражу благодарность. Но также может оказаться в моей власти и лишение жизни, эта колоссальная ответственность должна встречаться с великим смирением и осознанием моей собственной бренности.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 4 SECONDS, itemUser))
		itemUser.say("Я буду помнить, что остаюсь членом общества, но с особыми обязательствами ко всем моим собратьям, как к немощным, так и к здоровым телом и умом.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 4 SECONDS, itemUser))
		itemUser.say("Пока я не нарушаю эту клятву, да смогу я наслаждаться этим, заслуженно чтимым, искусством, пока я живу и меня вспоминают с любовью. Да буду я всегда действовать так, чтобы сохранить лучшие традиции моего призвания, и буду долго я испытывать радость исцеления тех, кто обращается за моей помощью.")
	else
		to_chat(itemUser, failText)
		return
	to_chat(itemUser, "<span class='notice'>The snake, satisfied with your oath, attaches itself and the rod to your forearm with an inseparable grip. Your thoughts seem to only revolve around the core idea of helping others, and harm is nothing more than a distant, wicked memory...</span>")
	var/datum/status_effect/hippocraticOath/effect = itemUser.apply_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH)
	effect.hand = usedHand
	activated()

/obj/item/rod_of_asclepius/proc/activated()
	item_flags |= DROPDEL
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(type))
	desc = "A short wooden rod with a mystical snake inseparably gripping itself and the rod to your forearm. It flows with a healing energy that disperses amongst yourself and those around you. "
	icon_state = "asclepius_active"
	item_state = "asclepius_active"
	activated = TRUE


// enchanced flowers
#define COOLDOWN_SUMMON (1 MINUTES)

/obj/item/eflowers
	name ="enchanted flowers"
	desc ="A charming bunch of flowers, most animals seem to find the bearer amicable after momentary contact with it. Squeeze the bouquet to summon tamed creatures. Megafauna cannot be summoned. <b>Megafauna need to be exposed 35 times to become friendly.</b>"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "eflower"
	var/next_summon = 0
	var/list/summons = list()
	attack_verb = list("thumped", "brushed", "bumped")

/obj/item/eflowers/attack_self(mob/user)
	var/turf/T = get_turf(user)
	var/area/A = get_area(user)
	if(next_summon > world.time)
		to_chat(user, span_warning("You can't do that yet!"))
		return
	if(is_station_level(T.z) && !A.outdoors)
		to_chat(user, span_warning("You feel like calling a bunch of animals indoors is a bad idea."))
		return
	user.visible_message(span_warning("[user] holds the bouquet out, summoning their allies!"))
	for(var/mob/m in summons)
		m.forceMove(T)
	playsound(T, 'sound/effects/splat.ogg', 80, 5, -1)
	next_summon = world.time + COOLDOWN_SUMMON

/obj/item/eflowers/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	var/mob/living/simple_animal/M = target
	if(istype(M))
		if(M.client)
			to_chat(user, span_warning("[M] is too intelligent to tame!"))
			return
		if(M.stat)
			to_chat(user, span_warning("[M] is dead!"))
			return
		if(M.faction == user.faction)
			to_chat(user, span_warning("[M] is already on your side!"))
			return
		if(M.sentience_type == SENTIENCE_BOSS)
			var/datum/status_effect/taming/G = M.has_status_effect(STATUS_EFFECT_TAMING)
			if(!G)
				M.apply_status_effect(STATUS_EFFECT_TAMING, user)
			else
				G.add_tame(G.tame_buildup)
				if(ISMULTIPLE(G.tame_crit-G.tame_amount, 5))
					to_chat(user, span_notice("[M] has to be exposed [G.tame_crit-G.tame_amount] more times to accept your gift!"))
			return
		if(M.sentience_type != SENTIENCE_ORGANIC)
			to_chat(user, span_warning("[M] cannot be tamed!"))
			return
		if(!do_after(user, 1.5 SECONDS, M))
			return
		M.visible_message(span_notice("[M] seems happy with you after exposure to the bouquet!"))
		M.add_atom_colour("#11c42f", FIXED_COLOUR_PRIORITY)
		M.drop_loot()
		M.faction = user.faction
		summons |= M
	..()

//Runite Scimitar. Some weird runescape reference
/obj/item/rune_scimmy
	name = "rune scimitar"
	desc = "A curved sword smelted from an unknown metal. Looking at it gives you the otherworldly urge to pawn it off for '30k', whatever that means."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "rune_scimmy"
	force = 28
	slot_flags = ITEM_SLOT_BELT
	damtype = BRUTE
	sharp = TRUE
	hitsound = 'sound/weapons/rs_slash.ogg'
	attack_verb = list("slashed","pk'd","atk'd")

/obj/item/organ/internal/cyberimp/arm/katana
	name = "dark shard"
	desc = "An eerie metal shard surrounded by dark energies."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "cursed_katana_organ"
	status = NONE
	item_flags = NO_PIXEL_RANDOM_DROP
	contents = newlist(/obj/item/cursed_katana)

/obj/item/organ/internal/cyberimp/arm/katana/prepare_eat()
	return

/obj/item/organ/internal/cyberimp/arm/katana/attack_self(mob/living/carbon/user, modifiers)
	. = ..()
	to_chat(user, span_warning("The mass goes up your arm and inside it!"))
	playsound(user, 'sound/misc/demon_consume.ogg', 50, TRUE)
	RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(user_death))

	user.drop_item_ground(src, force = TRUE, silent = TRUE)
	insert(user)

/obj/item/organ/internal/cyberimp/arm/katana/emp_act() //Organic, no emp stuff
	return

/obj/item/organ/internal/cyberimp/arm/katana/Retract()
	var/obj/item/cursed_katana/katana = active_item
	if(!katana || katana.shattered)
		return FALSE
	if(!katana.drew_blood)
		to_chat(owner, span_userdanger("[katana] lashes out at you in hunger!"))
		playsound(owner, 'sound/misc/demon_attack1.ogg', 50, TRUE)
		owner.apply_damage(25, BRUTE, parent_organ_zone, TRUE)
	katana.drew_blood = FALSE
	katana.clean_blood()
	return ..()

/obj/item/organ/internal/cyberimp/arm/katana/Extend()
	for(var/obj/item/cursed_katana/katana in contents)
		if(katana.shattered)
			to_chat(owner,  span_warning("Your cursed katana has not reformed yet!"))
			return FALSE
	return ..()

/obj/item/organ/internal/cyberimp/arm/katana/proc/user_death(mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(user_death_async), user)

/obj/item/organ/internal/cyberimp/arm/katana/proc/user_death_async(mob/user)
	remove(user)
	user.visible_message(span_warning("[user] begins to turn to dust, his soul being contained within [src]!"), span_userdanger("You feel your body begin to turn to dust, your soul being drawn into [src]!"))
	forceMove(get_turf(user))
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob, dust)), 1 SECONDS)

/obj/item/organ/internal/cyberimp/arm/katana/remove(mob/living/carbon/M, special)
	UnregisterSignal(M, COMSIG_MOB_DEATH)
	. = ..()

#define ATTACK_STRIKE "Hilt Strike"
#define ATTACK_SLICE "Wide Slice"
#define ATTACK_DASH "Dash Attack"
#define ATTACK_CUT "Tendon Cut"
#define ATTACK_HEAL "Dark Heal"
#define ATTACK_SHATTER "Shatter"

/obj/item/cursed_katana
	name = "cursed katana"
	desc = "A katana used to seal something vile away long ago. \
	Even with the weapon destroyed, all the pieces containing the creature have coagulated back together to find a new host."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "cursed_katana"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 15
	armour_penetration = 15
	block_chance = 50
	sharp = TRUE
	w_class = WEIGHT_CLASS_HUGE
	attack_verb = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/shattered = FALSE
	var/drew_blood = FALSE
	var/static/list/combo_list = list(
		ATTACK_STRIKE = list(COMBO_STEPS = list(HARM_SLASH, HARM_SLASH, DISARM_SLASH), COMBO_PROC = PROC_REF(strike)),
		ATTACK_SLICE = list(COMBO_STEPS = list(DISARM_SLASH, HARM_SLASH, HARM_SLASH), COMBO_PROC = PROC_REF(slice)),
		ATTACK_DASH = list(COMBO_STEPS = list(HARM_SLASH, DISARM_SLASH, DISARM_SLASH), COMBO_PROC = PROC_REF(dash)),
		ATTACK_CUT = list(COMBO_STEPS = list(DISARM_SLASH, DISARM_SLASH, HARM_SLASH), COMBO_PROC = PROC_REF(cut)),
		ATTACK_HEAL = list(COMBO_STEPS = list(HARM_SLASH, DISARM_SLASH, HARM_SLASH, DISARM_SLASH), COMBO_PROC = PROC_REF(heal)),
		ATTACK_SHATTER = list(COMBO_STEPS = list(DISARM_SLASH, HARM_SLASH, DISARM_SLASH, HARM_SLASH), COMBO_PROC = PROC_REF(shatter)),
		)

/obj/item/cursed_katana/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/combo_attacks, \
		combos = combo_list, \
		max_combo_length = 4, \
		reset_message = span_notice("принята небоевая стойка"), \
		can_attack_callback = CALLBACK(src, PROC_REF(can_combo_attack)) \
	)


/obj/item/cursed_katana/examine(mob/user)
	. = ..()
	. += drew_blood ? ("<span class='notice'>It's sated... for now.</span>") : ("<span class='danger'>It will not be sated until it tastes blood.</span>")


/obj/item/cursed_katana/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(can_combo_attack(user, target))
		drew_blood = TRUE
		if(ishostile(target))
			user.changeNext_move(CLICK_CD_RAPID)
	return ..()


/obj/item/cursed_katana/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/cursed_katana/proc/can_combo_attack(mob/user, mob/living/target)
	return target.stat != DEAD && target != user

/obj/item/cursed_katana/proc/strike(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] strikes [target] with [src]'s hilt!"),
		span_notice("You hilt strike [target]!"))
	to_chat(target, span_userdanger("You've been struck by [user]!"))
	playsound(src, 'sound/weapons/genhit3.ogg', 50, TRUE)
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(strike_throw_impact))
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	target.throw_at(throw_target, 5, 3, user, FALSE, callback = CALLBACK(target, TYPE_PROC_REF(/datum, UnregisterSignal), target, COMSIG_MOVABLE_IMPACT))
	target.apply_damage(17, BRUTE, BODY_ZONE_CHEST)
	to_chat(target,  span_userdanger("You've been struck by [user]!"))
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)

/obj/item/cursed_katana/proc/strike_throw_impact(mob/living/source, atom/hit_atom, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	source.apply_damage(5, BRUTE, BODY_ZONE_CHEST)
	if(ishostile(source))
		var/mob/living/simple_animal/hostile/target = source
		target.ranged_cooldown = world.time + 5 SECONDS
	else if(iscarbon(source))
		var/mob/living/carbon/target = source
		target.AdjustConfused(8 SECONDS)
	return NONE

/obj/item/cursed_katana/proc/slice(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] does a wide slice!"),
		span_notice("You do a wide slice!"))
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, TRUE)
	var/turf/user_turf = get_turf(user)
	var/dir_to_target = get_dir(user_turf, get_turf(target))
	var/static/list/cursed_katana_slice_angles = list(0, -45, 45, -90, 90) //so that the animation animates towards the target clicked and not towards a side target
	for(var/iteration in cursed_katana_slice_angles)
		var/turf/T = get_step(user_turf, turn(dir_to_target, iteration))
		user.do_attack_animation(T, ATTACK_EFFECT_CLAW)
		for(var/mob/living/additional_target in T)
			if(user.Adjacent(additional_target) && additional_target.density)
				additional_target.apply_damage(15, BRUTE, BODY_ZONE_CHEST, TRUE)
				to_chat(additional_target, span_userdanger("You've been sliced by [user]!"))
	target.apply_damage(5, BRUTE, BODY_ZONE_CHEST, TRUE)

/obj/item/cursed_katana/proc/heal(mob/living/target, mob/living/user)
	user.visible_message(span_warning("[user] lets [src] feast on [target]'s blood!"),
		span_warning("You let [src] feast on [target], and it heals you, at a price!"))
	target.apply_damage(15, BRUTE, BODY_ZONE_CHEST, TRUE)
	user.apply_status_effect(STATUS_EFFECT_SHADOW_MEND)

/obj/item/cursed_katana/proc/cut(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] cuts [target]'s tendons!"),
		span_notice("You tendon cut [target]!"))
	to_chat(target, span_userdanger("Your tendons have been cut by [user]!"))
	target.apply_damage(15, BRUTE, BODY_ZONE_CHEST, TRUE)
	user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(src, 'sound/weapons/rapierhit.ogg', 50, TRUE)
	var/datum/status_effect/saw_bleed/bloodletting/A = target.has_status_effect(STATUS_EFFECT_BLOODLETTING)
	if(!A)
		target.apply_status_effect(STATUS_EFFECT_BLOODLETTING)
	else
		A.add_bleed(6)


/obj/item/cursed_katana/proc/dash(mob/living/target, mob/user)
	var/turf/dash_target = get_turf(target)
	var/turf/user_turf = get_turf(user)
	if(!is_teleport_allowed(dash_target.z)) //No teleporting at CC
		to_chat(user, span_userdanger("You can not dash here!"))
		return
	user.visible_message(span_warning("[user] dashes through [target]!"),
		span_notice("You dash through [target]!"))
	to_chat(target, span_userdanger("[user] dashes through you!"))
	playsound(src, 'sound/magic/blink.ogg', 50, TRUE)
	target.apply_damage(17, BRUTE, BODY_ZONE_CHEST, TRUE)
	for(var/distance in 1 to 9)
		var/turf/current_dash_target = dash_target
		current_dash_target = get_step(current_dash_target, user.dir)
		if(current_dash_target.is_blocked_turf(TRUE))
			break
		dash_target = current_dash_target
		for(var/mob/living/additional_target in dash_target) //Slash through every mob you cut through
			additional_target.apply_damage(15, BRUTE, BODY_ZONE_CHEST, TRUE)
			to_chat(additional_target, span_userdanger("You've been sliced by [user]!"))
	user_turf.Beam(dash_target, icon_state = "warp_beam", time = 0.3 SECONDS, maxdistance = INFINITY)
	user.forceMove(dash_target)

/obj/item/cursed_katana/proc/shatter(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] shatters [src] over [target]!"),
		span_notice("You shatter [src] over [target]!"))
	to_chat(target, span_userdanger("[user] shatters [src] over you!"))
	target.apply_damage((ishostile(target) ? 75 : 35), BRUTE, BODY_ZONE_CHEST, TRUE)
	target.Weaken(3 SECONDS)
	target.apply_damage(60, STAMINA) //Takes 4 hits to do, breaks your weapon. Perfectly fine.
	user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	playsound(src, 'sound/effects/glassbr3.ogg', 100, TRUE)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		for(var/obj/item/organ/internal/cyberimp/arm/katana/O in H.internal_organs)
			if(O.active_item == src)
				O.Retract()
	shattered = TRUE
	addtimer(CALLBACK(src, PROC_REF(coagulate), user), 45 SECONDS)

/obj/item/cursed_katana/proc/coagulate(mob/user)
	if(QDELETED(user))
		return
	to_chat(user, span_notice("[src] reforms!"))
	shattered = FALSE
	playsound(user, 'sound/misc/demon_consume.ogg', 50, TRUE)

#undef ATTACK_STRIKE
#undef ATTACK_SLICE
#undef ATTACK_DASH
#undef ATTACK_CUT
#undef ATTACK_HEAL
#undef ATTACK_SHATTER
