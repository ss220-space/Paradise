///////////////////////////Veil Render//////////////////////

/obj/item/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/charged = 1
	var/spawn_type = /obj/singularity/narsie/wizard
	var/spawn_amt = 1
	var/activate_descriptor = "reality"
	var/rend_desc = "You should run now."

/obj/item/veilrender/attack_self(mob/user as mob)
	if(charged)
		new /obj/effect/rend(get_turf(user), spawn_type, spawn_amt, rend_desc)
		charged = 0
		user.visible_message("<span class='userdanger'>[src] hums with power as [user] deals a blow to [activate_descriptor] itself!</span>")
	else
		to_chat(user, "<span class='danger'>The unearthly energies that powered the blade are now dormant.</span>")


/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now."
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = TRUE
	anchored = TRUE
	var/spawn_path = /mob/living/simple_animal/cow //defaulty cows to prevent unintentional narsies
	var/spawn_amt_left = 20

/obj/effect/rend/New(loc, var/spawn_type, var/spawn_amt, var/desc)
	..()
	src.spawn_path = spawn_type
	src.spawn_amt_left = spawn_amt
	src.desc = desc

	START_PROCESSING(SSobj, src)
	//return

/obj/effect/rend/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/rend/process()
	for(var/mob/M in loc)
		return
	new spawn_path(loc)
	spawn_amt_left--
	if(spawn_amt_left <= 0)
		qdel(src)


/obj/effect/rend/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/nullrod))
		add_fingerprint(user)
		user.visible_message(span_danger("[user] seals [src] with [I]."))
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/effect/rend/singularity_pull()
	return

/obj/effect/rend/singularity_pull()
	return

/obj/item/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."
	spawn_type = /mob/living/simple_animal/cow
	spawn_amt = 20
	activate_descriptor = "hunger"
	rend_desc = "Reverberates with the sound of ten thousand moos."

/obj/item/veilrender/honkrender
	name = "honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus."
	spawn_type = /mob/living/simple_animal/hostile/retaliate/clown
	spawn_amt = 10
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of endless laughter."
	icon_state = "clownrender"


/obj/item/veilrender/crabrender
	name = "crab render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast aquarium."
	spawn_type = /mob/living/simple_animal/crab
	spawn_amt = 10
	activate_descriptor = "sea life"
	rend_desc = "Gently wafting with the sounds of endless clacking."

/////////////////////////////////////////Scrying///////////////////

/obj/item/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, staring into it gives you vision beyond mortal means."
	icon = 'icons/obj/weapons/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 7
	throw_range = 15
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'

/obj/item/scrying/attack_self(mob/user as mob)
	to_chat(user, "<span class='notice'> You can see...everything!</span>")
	visible_message("<span class='danger'>[user] stares into [src], [user.p_their()] eyes glazing over.</span>")
	user.ghostize(1)

/////////////////////Multiverse Blade////////////////////
GLOBAL_LIST_EMPTY(multiverse)

/obj/item/multisword
	name = "multiverse sword"
	desc = "A weapon capable of conquering the universe and beyond. Activate it to summon copies of yourself from others dimensions to fight by your side."
	icon_state = "energy_katana"
	item_state = "energy_katana"
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 20
	throwforce = 10
	sharp = 1
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/faction = list("unassigned")
	var/cooldown = 0
	var/cooldown_between_uses = 400 //time in deciseconds between uses--default of 40 seconds.
	var/assigned = "unassigned"
	var/evil = TRUE
	var/probability_evil = 30 //what's the probability this sword will be evil when activated?
	var/duplicate_self = 0 //Do we want the species randomized along with equipment should the user be duplicated in their entirety?
	var/sword_type = /obj/item/multisword //type of sword to equip.

/obj/item/multisword/New()
	..()
	GLOB.multiverse |= src


/obj/item/multisword/Destroy()
	GLOB.multiverse.Remove(src)
	return ..()


/obj/item/multisword/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(target.real_name == user.real_name)	//to prevent accidental friendly fire or out and out grief.
		to_chat(user, span_warning("The [name] detects benevolent energies in your target and redirects your attack!"))
		return ATTACK_CHAIN_PROCEED
	return ..()


/obj/item/multisword/attack_self(mob/user)
	if(user.mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)
		to_chat(user, "<span class='warning'>You know better than to touch your teacher's stuff.</span>")
		return
	if(cooldown < world.time)
		var/faction_check = 0
		for(var/F in faction)
			if(F in user.faction)
				faction_check = 1
				break
		if(faction_check == 0)
			faction = list("[user.real_name]")
			assigned = "[user.real_name]"
			user.faction = list("[user.real_name]")
			to_chat(user, "You bind the sword to yourself. You can now use it to summon help.")
			if(!usr.mind.special_role)
				var/list/messages = list()
				if(prob(probability_evil))
					messages.Add("<span class='warning'><B>With your new found power you could easily conquer the station!</B></span>")
					var/datum/objective/hijackclone/hijack_objective = new /datum/objective/hijackclone
					hijack_objective.explanation_text = "Ensure only [usr.real_name] and [usr.p_their()] copies are on the shuttle!"
					hijack_objective.owner = usr.mind
					usr.mind.objectives += hijack_objective
					messages.Add(user.mind.prepare_announce_objectives(FALSE))
					SSticker.mode.traitors += usr.mind
					usr.mind.special_role = "[usr.real_name] Prime"
					evil = TRUE
				else
					messages.Add("<span class='warning'><B>With your new found power you could easily defend the station!</B></span>")
					var/datum/objective/survive/new_objective = new /datum/objective/survive
					new_objective.explanation_text = "Survive, and help defend the innocent from the mobs of multiverse clones."
					new_objective.owner = usr.mind
					usr.mind.objectives += new_objective
					messages.Add(user.mind.prepare_announce_objectives(FALSE))
					SSticker.mode.traitors += usr.mind
					usr.mind.special_role = "[usr.real_name] Prime"
					evil = FALSE
				to_chat(user, chat_box_red(messages.Join("<br>")))
		else
			cooldown = world.time + cooldown_between_uses
			for(var/obj/item/multisword/M in GLOB.multiverse)
				if(M.assigned == assigned)
					M.cooldown = cooldown

			var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_wizard")
			var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as the wizard apprentice of [user.real_name]?", ROLE_WIZARD, TRUE, 10 SECONDS, source = source)
			if(candidates.len)
				var/mob/C = pick(candidates)
				spawn_copy(C.client, get_turf(user.loc), user)
				to_chat(user, "<span class='warning'><B>The sword flashes, and you find yourself face to face with...you!</B></span>")

			else
				to_chat(user, "You fail to summon any copies of yourself. Perhaps you should try again in a bit.")
	else
		to_chat(user, "<span class='warning'><B>[src] is recharging! Keep in mind it shares a cooldown with the swords wielded by your copies.</span>")


/obj/item/multisword/proc/spawn_copy(var/client/C, var/turf/T, mob/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	if(duplicate_self)
		user.client.prefs.copy_to(M)
	else
		C.prefs.copy_to(M)
	M.key = C.key
	M.mind.name = user.real_name
	to_chat(M, "<B>You are an alternate version of [user.real_name] from another universe! Help [user.p_them()] accomplish [user.p_their()] goals at all costs.</B>")
	M.faction = list("[user.real_name]")
	if(duplicate_self)
		M.set_species(user.dna.species.type) //duplicate the sword user's species.
	else
		if(prob(50))
			var/list/list_all_species = list(/datum/species/human, /datum/species/unathi, /datum/species/skrell, /datum/species/tajaran, /datum/species/kidan, /datum/species/golem, /datum/species/diona, /datum/species/machine, /datum/species/slime, /datum/species/grey, /datum/species/vulpkanin)
			M.set_species(pick(list_all_species))
	M.real_name = user.real_name //this is clear down here in case the user happens to become a golem; that way they have the proper name.
	M.name = user.real_name
	if(duplicate_self)
		M.dna = user.dna.Clone()
		M.UpdateAppearance()
		M.check_genes()
	M.update_body()
	M.update_hair()
	M.update_fhair()

	equip_copy(M)

	if(evil)
		var/datum/objective/hijackclone/hijack_objective = new /datum/objective/hijackclone
		hijack_objective.explanation_text = "Ensure only [usr.real_name] and [usr.p_their()] copies are on the shuttle!"
		hijack_objective.owner = usr.mind
		usr.mind.objectives += hijack_objective
		var/list/messages = list(M.mind.prepare_announce_objectives(FALSE))
		to_chat(M, chat_box_red(messages.Join("<br>")))
		M.mind.special_role = SPECIAL_ROLE_MULTIVERSE
		add_game_logs("[M.key] was made a multiverse traveller with the objective to help [usr.real_name] hijack.", M)
	else
		var/datum/objective/protect/new_objective = new /datum/objective/protect
		new_objective.explanation_text = "Protect [usr.real_name], your copy, and help [usr.p_them()] defend the innocent from the mobs of multiverse clones."
		new_objective.owner = M.mind
		M.mind.objectives += new_objective
		var/list/messages = list(M.mind.prepare_announce_objectives(FALSE))
		to_chat(M, chat_box_red(messages.Join("<br>")))
		M.mind.special_role = SPECIAL_ROLE_MULTIVERSE
		add_game_logs("[M.key] was made a multiverse traveller with the objective to help [usr.real_name] protect the station.", M)

/obj/item/multisword/proc/equip_copy(var/mob/living/carbon/human/M)

	var/obj/item/multisword/sword = new sword_type
	sword.assigned = assigned
	sword.faction = list("[assigned]")
	sword.evil = evil

	if(duplicate_self)
		//Duplicates the user's current equipent
		var/mob/living/carbon/human/H = usr

		var/obj/head = H.get_item_by_slot(ITEM_SLOT_HEAD)
		if(head)
			M.equip_to_slot_or_del(new head.type(M), ITEM_SLOT_HEAD)

		var/obj/mask = H.get_item_by_slot(ITEM_SLOT_MASK)
		if(mask)
			M.equip_to_slot_or_del(new mask.type(M), ITEM_SLOT_MASK)

		var/obj/glasses = H.get_item_by_slot(ITEM_SLOT_EYES)
		if(glasses)
			M.equip_to_slot_or_del(new glasses.type(M), ITEM_SLOT_EYES)

		var/obj/left_ear = H.get_item_by_slot(ITEM_SLOT_EAR_LEFT)
		if(left_ear)
			M.equip_to_slot_or_del(new left_ear.type(M), ITEM_SLOT_EAR_LEFT)

		var/obj/right_ear = H.get_item_by_slot(ITEM_SLOT_EAR_RIGHT)
		if(right_ear)
			M.equip_to_slot_or_del(new right_ear.type(M), ITEM_SLOT_EAR_RIGHT)

		var/obj/uniform = H.get_item_by_slot(ITEM_SLOT_CLOTH_INNER)
		if(uniform)
			M.equip_to_slot_or_del(new uniform.type(M), ITEM_SLOT_CLOTH_INNER)

		var/obj/suit = H.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER)
		if(suit)
			M.equip_to_slot_or_del(new suit.type(M), ITEM_SLOT_CLOTH_OUTER)

		var/obj/gloves = H.get_item_by_slot(ITEM_SLOT_GLOVES)
		if(gloves)
			M.equip_to_slot_or_del(new gloves.type(M), ITEM_SLOT_GLOVES)

		var/obj/shoes = H.get_item_by_slot(ITEM_SLOT_FEET)
		if(shoes)
			M.equip_to_slot_or_del(new shoes.type(M), ITEM_SLOT_FEET)

		var/obj/belt = H.get_item_by_slot(ITEM_SLOT_BELT)
		if(belt)
			M.equip_to_slot_or_del(new belt.type(M), ITEM_SLOT_BELT)

		var/obj/pda = H.get_item_by_slot(ITEM_SLOT_PDA)
		if(pda)
			M.equip_to_slot_or_del(new pda.type(M), ITEM_SLOT_PDA)

		var/obj/back = H.get_item_by_slot(ITEM_SLOT_BACK)
		if(back)
			M.equip_to_slot_or_del(new back.type(M), ITEM_SLOT_BACK)

		var/obj/suit_storage = H.get_item_by_slot(ITEM_SLOT_SUITSTORE)
		if(suit_storage)
			M.equip_to_slot_or_del(new suit_storage.type(M), ITEM_SLOT_SUITSTORE)

		var/obj/left_pocket = H.get_item_by_slot(ITEM_SLOT_POCKET_LEFT)
		if(left_pocket)
			M.equip_to_slot_or_del(new left_pocket.type(M), ITEM_SLOT_POCKET_LEFT)

		var/obj/right_pocket = H.get_item_by_slot(ITEM_SLOT_POCKET_RIGHT)
		if(right_pocket)
			M.equip_to_slot_or_del(new right_pocket.type(M), ITEM_SLOT_POCKET_RIGHT)

		M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT) //Don't duplicate what's equipped to hands, or else duplicate swords could be generated...or weird cases of factionless swords.
	else
		if(istajaran(M) || isunathi(M))
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), ITEM_SLOT_FEET)	//If they can't wear shoes, give them a pair of sandals.

		var/randomize = pick("mobster","roman","wizard","cyborg","syndicate","assistant", "animu", "cultist", "highlander", "clown", "killer", "pirate", "soviet", "officer", "gladiator")

		switch(randomize)
			if("mobster")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/fedora(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), ITEM_SLOT_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_EAR_LEFT)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), ITEM_SLOT_EYES)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket/really_black(M), ITEM_SLOT_CLOTH_INNER)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)

			if("roman")
				var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
				M.equip_to_slot_or_del(new hat(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/roman(M), ITEM_SLOT_CLOTH_INNER)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(new /obj/item/shield/riot/roman(M), ITEM_SLOT_HAND_LEFT)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)

			if("wizard")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(M), ITEM_SLOT_CLOTH_INNER)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/red(M), ITEM_SLOT_CLOTH_OUTER)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_EAR_LEFT)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/red(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)

			if("cyborg")
				if(!ismachineperson(M))
					for(var/obj/item/organ/external/bodypart as anything in M.bodyparts)
						bodypart.robotize(make_tough = TRUE)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), ITEM_SLOT_EYES)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)

			if("syndicate")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), ITEM_SLOT_CLOTH_INNER)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), ITEM_SLOT_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_EAR_LEFT)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(M), ITEM_SLOT_CLOTH_OUTER)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M),ITEM_SLOT_MASK)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)

			if("assistant")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(M), ITEM_SLOT_CLOTH_INNER)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_EAR_LEFT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)

			if("animu")
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_EAR_LEFT)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/schoolgirl(M), ITEM_SLOT_CLOTH_INNER)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)

			if("cultist")
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/cultrobes/alt(M), ITEM_SLOT_CLOTH_OUTER)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_EAR_LEFT)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)

			if("highlander")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(M), ITEM_SLOT_CLOTH_INNER)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_EAR_LEFT)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/beret(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)

			if("clown")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(M), ITEM_SLOT_CLOTH_INNER)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_EAR_LEFT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(M), ITEM_SLOT_MASK)
				M.equip_to_slot_or_del(new /obj/item/bikehorn(M), ITEM_SLOT_POCKET_LEFT)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)

			if("killer")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/overalls(M), ITEM_SLOT_CLOTH_INNER)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/latex(M), ITEM_SLOT_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(M), ITEM_SLOT_MASK)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/welding(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_EAR_LEFT)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(M), ITEM_SLOT_CLOTH_OUTER)
				M.equip_to_slot_or_del(new /obj/item/kitchen/knife(M), ITEM_SLOT_POCKET_LEFT)
				M.equip_to_slot_or_del(new /obj/item/scalpel(M), ITEM_SLOT_POCKET_RIGHT)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)
				for(var/obj/item/carried_item in M.contents)
					if(!istype(carried_item, /obj/item/implant))
						carried_item.add_mob_blood(M)

			if("pirate")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(M), ITEM_SLOT_CLOTH_INNER)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), ITEM_SLOT_EYES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_EAR_LEFT)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)

			if("soviet")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/hgpiratecap(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), ITEM_SLOT_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_EAR_LEFT)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/hgpirate(M), ITEM_SLOT_CLOTH_OUTER)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), ITEM_SLOT_CLOTH_INNER)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)

			if("officer")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/deathsquad/beret(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), ITEM_SLOT_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/havana(M), ITEM_SLOT_MASK)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_EAR_LEFT)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/jacket/miljacket(M), ITEM_SLOT_CLOTH_OUTER)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), ITEM_SLOT_CLOTH_INNER)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), ITEM_SLOT_EYES)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)

			if("gladiator")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/gladiator(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/gladiator(M), ITEM_SLOT_CLOTH_INNER)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_EAR_LEFT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), ITEM_SLOT_FEET)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_HAND_RIGHT)


			else
				return

	var/obj/item/card/id/W = new /obj/item/card/id
	if(duplicate_self)
		var/obj/item/duplicated_access = usr.get_item_by_slot(ITEM_SLOT_ID)
		if(duplicated_access && duplicated_access.GetID())
			var/obj/item/card/id/duplicated_id = duplicated_access.GetID()
			W.access = duplicated_id.access
			W.icon_state = duplicated_id.icon_state
		else
			W.access += ACCESS_MAINT_TUNNELS
			W.icon_state = "centcom"
	else
		W.access += ACCESS_MAINT_TUNNELS
		W.icon_state = "centcom"
	W.assignment = "Multiverse Traveller"
	W.registered_name = M.real_name
	W.update_label(M.real_name)
	W.SetOwnerInfo(M)
	M.equip_to_slot_or_del(W, ITEM_SLOT_ID)

	if(isvox(M))
		M.dna.species.after_equip_job(null, M) //Nitrogen tanks
	if(isplasmaman(M))
		M.dna.species.after_equip_job(null, M) //No fireballs from other dimensions.

	M.update_icons()

/obj/item/multisword/pure_evil
	probability_evil = 100

/obj/item/multisword/pike //If We are to be used and spent, let it be for a noble purpose.
	name = "phantom pike"
	desc = "A fishing pike that appears to be imbued with a peculiar energy."
	icon_state = "harpoon"
	item_state = "harpoon"
	cooldown_between_uses = 200 //Half the time
	probability_evil = 100
	duplicate_self = 1
	sword_type = /obj/item/multisword/pike


/////////////////////////////////////////Necromantic Stone///////////////////

/obj/item/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	item_state = "electronic"
	origin_tech = "bluespace=4;materials=4"
	w_class = WEIGHT_CLASS_TINY
	var/list/spooky_scaries = list()
	var/unlimited = 0
	var/heresy = 0

/obj/item/necromantic_stone/unlimited
	unlimited = 1

/obj/item/necromantic_stone/attack(mob/living/carbon/human/target, mob/living/carbon/human/user, params, def_zone, skip_attack_anim = FALSE)
	if(!istype(target))
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(!istype(user))
		return .

	if(target.stat != DEAD)
		to_chat(user, span_warning("This artifact can only affect the dead!"))
		return .

	if((!target.mind || !target.client) && !target.grab_ghost())
		to_chat(user, span_warning("There is no soul connected to this body..."))
		return .

	check_spooky()//clean out/refresh the list

	if(spooky_scaries.len >= 3 && !unlimited)
		to_chat(user, span_warning("This artifact can only affect three undead at a time!"))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	if(heresy)
		spawnheresy(target)//oh god why
	else
		target.set_species(/datum/species/skeleton)
		target.visible_message(span_warning("A massive amount of flesh sloughs off [target] and a skeleton rises up!"))
		target.grab_ghost() // yoinks the ghost if its not in the body
		target.revive()
		equip_skeleton(target)
	spooky_scaries |= target
	to_chat(target, "[span_userdanger("You have been revived by ")]<B>[user.real_name]!</B>")
	to_chat(target, span_userdanger("[user.p_theyre(TRUE)] your master now, assist them even if it costs you your new life!"))
	desc = "A shard capable of resurrecting humans as skeleton thralls[unlimited ? "." : ", [spooky_scaries.len]/3 active thralls."]"


/obj/item/necromantic_stone/proc/check_spooky()
	if(unlimited) //no point, the list isn't used.
		return
	for(var/X in spooky_scaries)
		if(!ishuman(X))
			spooky_scaries.Remove(X)
			continue
		var/mob/living/carbon/human/H = X
		if(H.stat == DEAD)
			spooky_scaries.Remove(X)
			continue
	listclearnulls(spooky_scaries)

//Funny gimmick, skeletons always seem to wear roman/ancient armour
//Voodoo Zombie Pirates added for paradise
/obj/item/necromantic_stone/proc/equip_skeleton(mob/living/carbon/human/H as mob)
	for(var/obj/item/I in H)
		H.drop_item_ground(I)
	var/randomSpooky = "roman"//defualt
	randomSpooky = pick("roman","pirate","yand","clown")

	switch(randomSpooky)
		if("roman")
			var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
			H.equip_to_slot_or_del(new hat(H), ITEM_SLOT_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/roman(H), ITEM_SLOT_CLOTH_INNER)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), ITEM_SLOT_FEET)
			H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), ITEM_SLOT_HAND_LEFT)
			H.equip_to_slot_or_del(new /obj/item/claymore(H), ITEM_SLOT_HAND_RIGHT)
			H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), ITEM_SLOT_BACK)
		if("pirate")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(H), ITEM_SLOT_CLOTH_INNER)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/pirate_brown(H),  ITEM_SLOT_CLOTH_OUTER)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(H), ITEM_SLOT_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), ITEM_SLOT_FEET)
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(H), ITEM_SLOT_EYES)
			H.equip_to_slot_or_del(new /obj/item/claymore(H), ITEM_SLOT_HAND_RIGHT)
			H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), ITEM_SLOT_BACK)
			H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), ITEM_SLOT_HAND_LEFT)
		if("yand")//mine is an evil laugh
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), ITEM_SLOT_FEET)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(H), ITEM_SLOT_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/schoolgirl(H), ITEM_SLOT_CLOTH_INNER)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(H),  ITEM_SLOT_CLOTH_OUTER)
			H.equip_to_slot_or_del(new /obj/item/katana(H), ITEM_SLOT_HAND_RIGHT)
			H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), ITEM_SLOT_HAND_LEFT)
			H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), ITEM_SLOT_BACK)
		if("clown")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(H), ITEM_SLOT_CLOTH_INNER)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(H), ITEM_SLOT_FEET)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), ITEM_SLOT_MASK)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/stalhelm(H), ITEM_SLOT_HEAD)
			H.equip_to_slot_or_del(new /obj/item/bikehorn(H), ITEM_SLOT_POCKET_LEFT)
			H.equip_to_slot_or_del(new /obj/item/claymore(H), ITEM_SLOT_HAND_RIGHT)
			H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), ITEM_SLOT_HAND_LEFT)
			H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), ITEM_SLOT_BACK)

/obj/item/necromantic_stone/proc/spawnheresy(mob/living/carbon/human/H as mob)
	H.set_species(/datum/species/human)
	if(H.gender == MALE)
		H.change_gender(FEMALE)

	var/list/anime_hair =list("Odango", "Kusanagi Hair", "Pigtails", "Hime Cut", "Floorlength Braid", "Ombre", "Twincurls", "Twincurls 2")
	H.change_hair(pick(anime_hair))

	var/list/anime_hair_colours = list(list(216, 192, 120),
	list(140,170,74),list(0,0,0))

	var/list/chosen_colour = pick(anime_hair_colours)
	H.change_hair_color(chosen_colour[1], chosen_colour[2], chosen_colour[3])

	H.update_dna()
	H.update_body()
	H.grab_ghost()
	H.revive()
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), ITEM_SLOT_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(H), ITEM_SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/schoolgirl(H), ITEM_SLOT_CLOTH_INNER)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(H),  ITEM_SLOT_CLOTH_OUTER)
	H.equip_to_slot_or_del(new /obj/item/katana(H), ITEM_SLOT_HAND_RIGHT)
	H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), ITEM_SLOT_HAND_LEFT)
	H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), ITEM_SLOT_BACK)
	if(!H.real_name || H.real_name == "unknown")
		H.real_name = "Neko-chan"
	else
		H.real_name = "[H.name]-chan"
	H.say("NYA!~")

/obj/item/necromantic_stone/nya
	name = "nya-cromantic stone"
	desc = "A shard capable of resurrecting humans as creatures of Vile Heresy. Even the Wizard Federation fears it.."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "nyacrostone"
	item_state = "electronic"
	origin_tech = "bluespace=4;materials=4"
	w_class = WEIGHT_CLASS_TINY
	heresy = 1
	unlimited = 1

/////////////////////////////////////////Voodoo///////////////////


/obj/item/voodoo
	name = "wicker doll"
	desc = "Something creepy about it."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "voodoo"
	item_state = "electronic"
	var/mob/living/carbon/human/target = null
	var/list/mob/living/carbon/human/possible = list()
	var/obj/item/link = null
	var/cooldown_time = 3 SECONDS
	COOLDOWN_DECLARE(cooldown)
	max_integrity = 10
	resistance_flags = FLAMMABLE


/obj/item/voodoo/attackby(obj/item/I, mob/user, params)
	if(target && COOLDOWN_FINISHED(src, cooldown))
		add_fingerprint(user)
		if(is_hot(I))
			to_chat(target, span_userdanger("You suddenly feel very hot."))
			target.adjust_bodytemperature(50)
		else if(is_pointed(I))
			to_chat(target, span_userdanger("You feel a stabbing pain in [parse_zone(user.zone_selected)]!"))
			target.Weaken(4 SECONDS)
		else if(istype(I, /obj/item/bikehorn))
			to_chat(target, span_userdanger("HONK!"))
			target.playsound_local(null, 'sound/items/airhorn.ogg', 150, TRUE)
			target.Deaf(6 SECONDS)
		GiveHint(target)
		COOLDOWN_START(src, cooldown, cooldown_time)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(!link && I.loc == user && I.w_class <= WEIGHT_CLASS_SMALL)
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		add_fingerprint(user)
		link = I
		to_chat(user, span_notice("You attach [I] to the doll."))
		update_targets()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/voodoo/check_eye(mob/user)
	if(loc != user)
		user.reset_perspective(null)
		user.unset_machine()

/obj/item/voodoo/attack_self(mob/user as mob)
	if(!target && possible.len)
		target = tgui_input_list(user, "Select your victim!", "Voodoo", possible)
		return

	if(user.zone_selected == BODY_ZONE_CHEST)
		if(link)
			target = null
			link.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>You remove the [link] from the doll.</span>")
			link = null
			update_targets()
			return

	if(target && cooldown < world.time)
		switch(user.zone_selected)
			if(BODY_ZONE_PRECISE_MOUTH)
				var/wgw =  sanitize(input(user, "What would you like the victim to say", "Voodoo", null)  as text)
				target.say(wgw)
				add_attack_logs(user, target, "force say ([wgw]) with a voodoo doll.")
				add_say_logs(target, wgw, src)
			if(BODY_ZONE_PRECISE_EYES)
				user.set_machine(src)
				user.reset_perspective(target)
				spawn(100)
					user.reset_perspective(null)
					user.unset_machine()
			if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
				to_chat(user, "<span class='notice'>You move the doll's legs around.</span>")
				var/turf/T = get_step(target,pick(GLOB.cardinal))
				target.Move(T)
			if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
				//use active hand on random nearby mob
				var/list/nearby_mobs = list()
				for(var/mob/living/L in range(1,target))
					if(L!=target)
						nearby_mobs |= L
				if(nearby_mobs.len)
					var/mob/living/T = pick(nearby_mobs)
					add_attack_logs(user, target, "force click on [T] with a voodoo doll.")
					target.ClickOn(T)
					GiveHint(target)
			if(BODY_ZONE_HEAD)
				to_chat(user, "<span class='notice'>You smack the doll's head with your hand.</span>")
				target.Dizzy(20 SECONDS)
				to_chat(target, "<span class='warning'>You suddenly feel as if your head was hit with a hammer!</span>")
				GiveHint(target,user)
		cooldown = world.time + cooldown_time

/obj/item/voodoo/proc/update_targets()
	possible = list()
	if(!link)
		return
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		if(H.stat != DEAD && (md5(H.dna.uni_identity) in link.fingerprints))
			possible |= H

/obj/item/voodoo/proc/GiveHint(mob/victim,force=0)
	if(prob(50) || force)
		var/way = dir2text(get_dir(victim,get_turf(src)))
		to_chat(victim, "<span class='notice'>You feel a dark presence from [way]</span>")
	if(prob(20) || force)
		var/area/A = get_area(src)
		to_chat(victim, "<span class='notice'>You feel a dark presence from [A.name]</span>")

/obj/item/voodoo/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(target)
		target.adjust_fire_stacks(20)
		target.IgniteMob()
		GiveHint(target,1)
	return ..()

/obj/item/organ/internal/heart/cursed/wizard
	pump_delay = 60
	heal_brute = 25
	heal_burn = 25
	heal_oxy = 25
