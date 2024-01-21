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
	density = 1
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

/obj/effect/rend/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/nullrod))
		user.visible_message("<span class='danger'>[user] seals \the [src] with \the [I].</span>")
		qdel(src)
		return
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
	slot_flags = SLOT_FLAG_BELT
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

/obj/item/multisword/attack(mob/living/M as mob, mob/living/user as mob)  //to prevent accidental friendly fire or out and out grief.
	if(M.real_name == user.real_name)
		to_chat(user, "<span class='warning'>The [src] detects benevolent energies in your target and redirects your attack!</span>")
		return
	..()

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
		domutcheck(M, null)
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

		var/obj/head = H.get_item_by_slot(SLOT_HUD_HEAD)
		if(head)
			M.equip_to_slot_or_del(new head.type(M), SLOT_HUD_HEAD)

		var/obj/mask = H.get_item_by_slot(SLOT_HUD_WEAR_MASK)
		if(mask)
			M.equip_to_slot_or_del(new mask.type(M), SLOT_HUD_WEAR_MASK)

		var/obj/glasses = H.get_item_by_slot(SLOT_HUD_GLASSES)
		if(glasses)
			M.equip_to_slot_or_del(new glasses.type(M), SLOT_HUD_GLASSES)

		var/obj/left_ear = H.get_item_by_slot(SLOT_HUD_LEFT_EAR)
		if(left_ear)
			M.equip_to_slot_or_del(new left_ear.type(M), SLOT_HUD_LEFT_EAR)

		var/obj/right_ear = H.get_item_by_slot(SLOT_HUD_RIGHT_EAR)
		if(right_ear)
			M.equip_to_slot_or_del(new right_ear.type(M), SLOT_HUD_RIGHT_EAR)

		var/obj/uniform = H.get_item_by_slot(SLOT_HUD_JUMPSUIT)
		if(uniform)
			M.equip_to_slot_or_del(new uniform.type(M), SLOT_HUD_JUMPSUIT)

		var/obj/suit = H.get_item_by_slot(SLOT_HUD_OUTER_SUIT)
		if(suit)
			M.equip_to_slot_or_del(new suit.type(M), SLOT_HUD_OUTER_SUIT)

		var/obj/gloves = H.get_item_by_slot(SLOT_HUD_GLOVES)
		if(gloves)
			M.equip_to_slot_or_del(new gloves.type(M), SLOT_HUD_GLOVES)

		var/obj/shoes = H.get_item_by_slot(SLOT_HUD_SHOES)
		if(shoes)
			M.equip_to_slot_or_del(new shoes.type(M), SLOT_HUD_SHOES)

		var/obj/belt = H.get_item_by_slot(SLOT_HUD_BELT)
		if(belt)
			M.equip_to_slot_or_del(new belt.type(M), SLOT_HUD_BELT)

		var/obj/pda = H.get_item_by_slot(SLOT_HUD_WEAR_PDA)
		if(pda)
			M.equip_to_slot_or_del(new pda.type(M), SLOT_HUD_WEAR_PDA)

		var/obj/back = H.get_item_by_slot(SLOT_HUD_BACK)
		if(back)
			M.equip_to_slot_or_del(new back.type(M), SLOT_HUD_BACK)

		var/obj/suit_storage = H.get_item_by_slot(SLOT_HUD_SUIT_STORE)
		if(suit_storage)
			M.equip_to_slot_or_del(new suit_storage.type(M), SLOT_HUD_SUIT_STORE)

		var/obj/left_pocket = H.get_item_by_slot(SLOT_HUD_LEFT_STORE)
		if(left_pocket)
			M.equip_to_slot_or_del(new left_pocket.type(M), SLOT_HUD_LEFT_STORE)

		var/obj/right_pocket = H.get_item_by_slot(SLOT_HUD_RIGHT_STORE)
		if(right_pocket)
			M.equip_to_slot_or_del(new right_pocket.type(M), SLOT_HUD_RIGHT_STORE)

		M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND) //Don't duplicate what's equipped to hands, or else duplicate swords could be generated...or weird cases of factionless swords.
	else
		if(istajaran(M) || isunathi(M))
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), SLOT_HUD_SHOES)	//If they can't wear shoes, give them a pair of sandals.

		var/randomize = pick("mobster","roman","wizard","cyborg","syndicate","assistant", "animu", "cultist", "highlander", "clown", "killer", "pirate", "soviet", "officer", "gladiator")

		switch(randomize)
			if("mobster")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/fedora(M), SLOT_HUD_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), SLOT_HUD_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), SLOT_HUD_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), SLOT_HUD_GLASSES)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket/really_black(M), SLOT_HUD_JUMPSUIT)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)

			if("roman")
				var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
				M.equip_to_slot_or_del(new hat(M), SLOT_HUD_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/roman(M), SLOT_HUD_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(new /obj/item/shield/riot/roman(M), SLOT_HUD_LEFT_HAND)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)

			if("wizard")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(M), SLOT_HUD_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/red(M), SLOT_HUD_OUTER_SUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), SLOT_HUD_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/red(M), SLOT_HUD_HEAD)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)

			if("cyborg")
				if(!ismachineperson(M))
					for(var/obj/item/organ/external/bodypart as anything in M.bodyparts)
						bodypart.robotize(make_tough = TRUE)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), SLOT_HUD_GLASSES)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)

			if("syndicate")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), SLOT_HUD_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), SLOT_HUD_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat(M), SLOT_HUD_HEAD)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), SLOT_HUD_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(M), SLOT_HUD_OUTER_SUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M),SLOT_HUD_WEAR_MASK)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)

			if("assistant")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(M), SLOT_HUD_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), SLOT_HUD_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)

			if("animu")
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), SLOT_HUD_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(M), SLOT_HUD_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/schoolgirl(M), SLOT_HUD_JUMPSUIT)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)

			if("cultist")
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/cultrobes/alt(M), SLOT_HUD_OUTER_SUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), SLOT_HUD_LEFT_EAR)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)

			if("highlander")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(M), SLOT_HUD_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), SLOT_HUD_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/beret(M), SLOT_HUD_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)

			if("clown")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(M), SLOT_HUD_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), SLOT_HUD_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(M), SLOT_HUD_WEAR_MASK)
				M.equip_to_slot_or_del(new /obj/item/bikehorn(M), SLOT_HUD_LEFT_STORE)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)

			if("killer")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/overalls(M), SLOT_HUD_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/latex(M), SLOT_HUD_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(M), SLOT_HUD_WEAR_MASK)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/welding(M), SLOT_HUD_HEAD)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), SLOT_HUD_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(M), SLOT_HUD_OUTER_SUIT)
				M.equip_to_slot_or_del(new /obj/item/kitchen/knife(M), SLOT_HUD_LEFT_STORE)
				M.equip_to_slot_or_del(new /obj/item/scalpel(M), SLOT_HUD_RIGHT_STORE)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)
				for(var/obj/item/carried_item in M.contents)
					if(!istype(carried_item, /obj/item/implant))
						carried_item.add_mob_blood(M)

			if("pirate")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(M), SLOT_HUD_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(M), SLOT_HUD_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), SLOT_HUD_GLASSES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), SLOT_HUD_LEFT_EAR)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)

			if("soviet")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/hgpiratecap(M), SLOT_HUD_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), SLOT_HUD_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), SLOT_HUD_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/hgpirate(M), SLOT_HUD_OUTER_SUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), SLOT_HUD_JUMPSUIT)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)

			if("officer")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/deathsquad/beret(M), SLOT_HUD_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), SLOT_HUD_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/havana(M), SLOT_HUD_WEAR_MASK)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), SLOT_HUD_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/jacket/miljacket(M), SLOT_HUD_OUTER_SUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), SLOT_HUD_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), SLOT_HUD_GLASSES)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)

			if("gladiator")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/gladiator(M), SLOT_HUD_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/gladiator(M), SLOT_HUD_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), SLOT_HUD_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), SLOT_HUD_SHOES)
				M.equip_to_slot_or_del(sword, SLOT_HUD_RIGHT_HAND)


			else
				return

	var/obj/item/card/id/W = new /obj/item/card/id
	if(duplicate_self)
		var/obj/item/duplicated_access = usr.get_item_by_slot(SLOT_HUD_WEAR_ID)
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
	M.equip_to_slot_or_del(W, SLOT_HUD_WEAR_ID)

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

/obj/item/necromantic_stone/attack(mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)

	if(!istype(M))
		return ..()

	if(!istype(user))
		return

	if(M.stat != DEAD)
		to_chat(user, "<span class='warning'>This artifact can only affect the dead!</span>")
		return

	if((!M.mind || !M.client) && !M.grab_ghost())
		to_chat(user,"<span class='warning'>There is no soul connected to this body...</span>")
		return

	check_spooky()//clean out/refresh the list

	if(spooky_scaries.len >= 3 && !unlimited)
		to_chat(user, "<span class='warning'>This artifact can only affect three undead at a time!</span>")
		return
	if(heresy)
		spawnheresy(M)//oh god why
	else
		M.set_species(/datum/species/skeleton)
		M.visible_message("<span class = 'warning'> A massive amount of flesh sloughs off [M] and a skeleton rises up!</span>")
		M.grab_ghost() // yoinks the ghost if its not in the body
		M.revive()
		equip_skeleton(M)
	spooky_scaries |= M
	to_chat(M, "<span class='userdanger'>You have been revived by </span><B>[user.real_name]!</B>")
	to_chat(M, "<span class='userdanger'>[user.p_theyre(TRUE)] your master now, assist them even if it costs you your new life!</span>")
	desc = "A shard capable of resurrecting humans as skeleton thralls[unlimited ? "." : ", [spooky_scaries.len]/3 active thralls."]"

/obj/item/necromantic_stone/proc/check_spooky()
	if(unlimited) //no point, the list isn't used.
		return
	for(var/X in spooky_scaries)
		if(!istype(X, /mob/living/carbon/human))
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
			H.equip_to_slot_or_del(new hat(H), SLOT_HUD_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/roman(H), SLOT_HUD_JUMPSUIT)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), SLOT_HUD_SHOES)
			H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), SLOT_HUD_LEFT_HAND)
			H.equip_to_slot_or_del(new /obj/item/claymore(H), SLOT_HUD_RIGHT_HAND)
			H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), SLOT_HUD_BACK)
		if("pirate")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(H), SLOT_HUD_JUMPSUIT)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/pirate_brown(H),  SLOT_HUD_OUTER_SUIT)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(H), SLOT_HUD_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), SLOT_HUD_SHOES)
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(H), SLOT_HUD_GLASSES)
			H.equip_to_slot_or_del(new /obj/item/claymore(H), SLOT_HUD_RIGHT_HAND)
			H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), SLOT_HUD_BACK)
			H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), SLOT_HUD_LEFT_HAND)
		if("yand")//mine is an evil laugh
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), SLOT_HUD_SHOES)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(H), SLOT_HUD_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/schoolgirl(H), SLOT_HUD_JUMPSUIT)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(H),  SLOT_HUD_OUTER_SUIT)
			H.equip_to_slot_or_del(new /obj/item/katana(H), SLOT_HUD_RIGHT_HAND)
			H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), SLOT_HUD_LEFT_HAND)
			H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), SLOT_HUD_BACK)
		if("clown")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(H), SLOT_HUD_JUMPSUIT)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(H), SLOT_HUD_SHOES)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), SLOT_HUD_WEAR_MASK)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/stalhelm(H), SLOT_HUD_HEAD)
			H.equip_to_slot_or_del(new /obj/item/bikehorn(H), SLOT_HUD_LEFT_STORE)
			H.equip_to_slot_or_del(new /obj/item/claymore(H), SLOT_HUD_RIGHT_HAND)
			H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), SLOT_HUD_LEFT_HAND)
			H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), SLOT_HUD_BACK)

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
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), SLOT_HUD_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(H), SLOT_HUD_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/schoolgirl(H), SLOT_HUD_JUMPSUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(H),  SLOT_HUD_OUTER_SUIT)
	H.equip_to_slot_or_del(new /obj/item/katana(H), SLOT_HUD_RIGHT_HAND)
	H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), SLOT_HUD_LEFT_HAND)
	H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), SLOT_HUD_BACK)
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
	var/cooldown_time = 30 //3s
	var/cooldown = 0
	max_integrity = 10
	resistance_flags = FLAMMABLE

/obj/item/voodoo/attackby(obj/item/I as obj, mob/user as mob, params)
	if(target && cooldown < world.time)
		if(is_hot(I))
			to_chat(target, "<span class='userdanger'>You suddenly feel very hot</span>")
			target.adjust_bodytemperature(50)
			GiveHint(target)
		else if(is_pointed(I))
			to_chat(target, "<span class='userdanger'>You feel a stabbing pain in [parse_zone(user.zone_selected)]!</span>")
			target.Weaken(4 SECONDS)
			GiveHint(target)
		else if(istype(I,/obj/item/bikehorn))
			to_chat(target, "<span class='userdanger'>HONK</span>")
			target << 'sound/items/airhorn.ogg'
			target.Deaf(6 SECONDS)
			GiveHint(target)
		cooldown = world.time +cooldown_time
		return

	if(!link)
		if(I.loc == user && istype(I) && I.w_class <= WEIGHT_CLASS_SMALL)
			user.drop_transfer_item_to_loc(I, src)
			link = I
			to_chat(user, "You attach [I] to the doll.")
			update_targets()
		return
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
			link.loc = get_turf(src)
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
