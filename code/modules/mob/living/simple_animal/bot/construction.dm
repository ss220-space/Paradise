//Bot Construction

//Cleanbot assembly
/obj/item/bucket_sensor
	desc = "It's a bucket. With a sensor attached."
	name = "proxy bucket"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "bucket_proxy"
	force = 3
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	var/created_name = "Cleanbot"
	var/robot_arm = /obj/item/robot_parts/l_arm


/obj/item/bucket_sensor/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_pen(I))
		var/new_name = rename_interactive(user, I, prompt = "Enter new robot name")
		if(!isnull(new_name))
			created_name = new_name
			add_game_logs("[key_name(user)] has renamed a robot to [new_name]", user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	add_fingerprint(user)
	if(!istype(I, /obj/item/robot_parts/l_arm) && !istype(I, /obj/item/robot_parts/r_arm))
		to_chat(user, span_warning("You need a cyborg arm to finish the construction."))
		return ATTACK_CHAIN_PROCEED

	if(!isturf(loc))
		to_chat(user, span_warning("You cannot finish the construction [ismob(loc) ? "in inventory" : "in [loc]"]."))
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(I, src))
		return ..()

	to_chat(user, span_notice("You have added the robot arm to the bucket and sensor assembly. Beep boop!"))
	var/mob/living/simple_animal/bot/cleanbot/new_bot = new(loc)
	transfer_fingerprints_to(new_bot)
	I.transfer_fingerprints_to(new_bot)
	new_bot.add_fingerprint(user)
	new_bot.name = created_name
	new_bot.robot_arm = I.type
	qdel(src)
	qdel(I)
	return ATTACK_CHAIN_BLOCKED_ALL



//Edbot Assembly

/obj/item/ed209_assembly
	name = "\improper ED-209 assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed209_frame"
	item_state = "ed209_frame"
	var/build_step = 0
	var/created_name = "\improper ED-209 Security Robot" //To preserve the name if it's a unique securitron I guess
	var/lasercolor = ""
	var/new_name = ""


/obj/item/ed209_assembly/update_name(updates = ALL)
	. = ..()
	switch(build_step)
		if(1,2)
			name = "legs/frame assembly"
		if(3)
			name = "vest/legs/frame assembly"
		if(4)
			name = "shielded frame assembly"
		if(5)
			name = "covered and shielded frame assembly"
		if(6)
			name = "covered, shielded and sensored frame assembly"
		if(7)
			name = "wired ED-209 assembly"
		if(8)
			name = new_name
		if(9)
			name = "armed [name]"


/obj/item/ed209_assembly/update_icon_state()
	switch(build_step)
		if(1)
			item_state = "ed209_leg"
			icon_state = "ed209_leg"
		if(2)
			item_state = "ed209_legs"
			icon_state = "ed209_legs"
		if(3,4)
			item_state = "[lasercolor]ed209_shell"
			icon_state = "[lasercolor]ed209_shell"
		if(5)
			item_state = "[lasercolor]ed209_hat"
			icon_state = "[lasercolor]ed209_hat"
		if(6,7)
			item_state = "[lasercolor]ed209_prox"
			icon_state = "[lasercolor]ed209_prox"
		if(8,9)
			item_state = "[lasercolor]ed209_taser"
			icon_state = "[lasercolor]ed209_taser"



/obj/item/ed209_assembly/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_pen(I))
		var/new_name = rename_interactive(user, I, prompt = "Enter new robot name")
		if(!isnull(new_name))
			created_name = new_name
			add_game_logs("[key_name(user)] has renamed a robot to [new_name]", user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	switch(build_step)
		if(0, 1)
			add_fingerprint(user)
			if(!istype(I, /obj/item/robot_parts/l_leg) && !istype(I, /obj/item/robot_parts/r_leg))
				to_chat(user, span_warning("You need a cyborg leg to continue the construction."))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			qdel(I)
			build_step++
			to_chat(user, span_notice("You have added the the robot leg to the ED-209 assembly."))
			update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
			return ATTACK_CHAIN_PROCEED_SUCCESS

		if(2)
			add_fingerprint(user)
			var/newcolor = ""
			if(istype(I, /obj/item/clothing/suit/redtag))
				newcolor = "r"
			else if(istype(I, /obj/item/clothing/suit/bluetag))
				newcolor = "b"
			if(!newcolor && !istype(I, /obj/item/clothing/suit/armor/vest))
				to_chat(user, span_warning("You need a helmet to continue the construction."))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			lasercolor = newcolor
			build_step++
			to_chat(user, span_notice("You have added [I] to the ED-209 assembly."))
			update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
			qdel(I)
			return ATTACK_CHAIN_PROCEED_SUCCESS

		if(4)
			add_fingerprint(user)
			switch(lasercolor)
				if("b")
					if(!istype(I, /obj/item/clothing/head/helmet/bluetaghelm))
						to_chat(user, span_warning("You need a blue laser tag helmet to continue the construction."))
						return ATTACK_CHAIN_PROCEED
				if("r")
					if(!istype(I, /obj/item/clothing/head/helmet/redtaghelm))
						to_chat(user, span_warning("You need a red laser tag helmet to continue the construction."))
						return ATTACK_CHAIN_PROCEED
				if("")
					if(!istype(I, /obj/item/clothing/head/helmet))
						to_chat(user, span_warning("You need a standard helmet to continue the construction."))
						return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			build_step++
			to_chat(user, span_notice("You have added [I] to the ED-209 assembly."))
			update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
			qdel(I)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(5)
			add_fingerprint(user)
			if(!isprox(I))
				to_chat(user, span_warning("You need a proximity sensor to continue the construction."))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			qdel(I)
			build_step++
			to_chat(user, span_notice("You have added the proximity sensor to the ED-209 assembly."))
			update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(6)
			add_fingerprint(user)
			var/obj/item/stack/cable_coil/coil = I
			if(!iscoil(I) || coil.get_amount() < 1)
				to_chat(user, span_warning("You need at least one length of cable to continue the construction."))
				return ATTACK_CHAIN_PROCEED
			coil.play_tool_sound(src)
			to_chat(user, span_notice("You start to wire the ED-209 assembly..."))
			if(!do_after(user, 4 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || build_step != 6 || QDELETED(coil) || !coil.use(1))
				return ATTACK_CHAIN_PROCEED
			build_step++
			to_chat(user, span_notice("You have wired the ED-209 assembly."))
			update_appearance(UPDATE_NAME)
			return ATTACK_CHAIN_PROCEED_SUCCESS

		if(7)
			add_fingerprint(user)
			new_name = ""
			switch(lasercolor)
				if("b")
					if(!istype(I, /obj/item/gun/energy/laser/tag/blue))
						to_chat(user, span_warning("You need a blue laser tag gun to continue the construction."))
						return ATTACK_CHAIN_PROCEED
					new_name = "bluetag ED-209 assembly"
				if("r")
					if(!istype(I, /obj/item/gun/energy/laser/tag/red))
						to_chat(user, span_warning("You need a red laser tag gun to continue the construction."))
						return ATTACK_CHAIN_PROCEED
					new_name = "redtag ED-209 assembly"
				if("")
					if(!istype(I, /obj/item/gun/energy/gun/advtaser))
						to_chat(user, span_warning("You need a hybrid taser to continue the construction."))
						return ATTACK_CHAIN_PROCEED
					new_name = "taser ED-209 assembly"
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			build_step++
			to_chat(user, span_notice("You have added [I] to the ED-209 assembly."))
			update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
			qdel(I)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(9)
			add_fingerprint(user)
			if(!istype(I, /obj/item/stock_parts/cell))
				to_chat(user, span_warning("You need a power cell to complete the assembly."))
				return ATTACK_CHAIN_PROCEED
			if(!isturf(loc))
				to_chat(user, span_warning("You cannot finish the construction [ismob(loc) ? "in inventory" : "in [loc]"]."))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			to_chat(user, span_notice("You have completed the ED-209 assembly. Beep boop!"))
			var/mob/living/simple_animal/bot/ed209/new_bot = new(loc, created_name, lasercolor)
			transfer_fingerprints_to(new_bot)
			I.transfer_fingerprints_to(new_bot)
			new_bot.add_fingerprint(user)
			qdel(I)
			qdel(src)
			return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/ed209_assembly/welder_act(mob/living/user, obj/item/I)
	if(build_step != 3)
		return FALSE
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	build_step++
	to_chat(user, span_notice("You have welded the the armor to [src]."))
	update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)


/obj/item/ed209_assembly/screwdriver_act(mob/living/user, obj/item/I)
	if(build_step != 8)
		return FALSE
	. = TRUE
	to_chat(user, span_notice("You start attaching the gun to the frame..."))
	if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume) || build_step != 8)
		return .
	build_step++
	update_appearance(UPDATE_NAME)
	to_chat(user, span_notice("You attach the gun to the frame."))


//Floorbot assemblies
/obj/item/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top"
	name = "tiles and toolbox"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles"
	force = 3
	throwforce = 10
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	var/created_name = "Floorbot"
	var/toolbox = /obj/item/storage/toolbox/mechanical
	var/toolbox_color = "" //Blank for blue, r for red, y for yellow, etc.

/obj/item/toolbox_tiles/sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached"
	name = "tiles, toolbox and sensor arrangement"
	icon_state = "toolbox_tiles_sensor"


/obj/item/storage/toolbox/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || !istype(I, /obj/item/stack/tile/plasteel))
		return ..()

	. = ATTACK_CHAIN_PROCEED

	add_fingerprint(user)
	var/obj/item/stack/tile/plasteel/plasteel = I
	if(istype(I, /obj/item/storage/toolbox/green/memetic))
		to_chat(user, "<i><b><font face = Tempus Sans ITC>Nice try...</font></b></i>")
		return .

	if(length(contents))
		to_chat(user, span_warning("The [name] should be empty to start the floorbot construction."))
		return .

	if(!plasteel.use(10))
		to_chat(user, span_warning("You need at least ten sheets of plasteel to start the floorbot construction."))
		return .

	. |= ATTACK_CHAIN_BLOCKED_ALL

	hide_from_all_viewers()

	var/obj/item/toolbox_tiles/assembly = new(drop_location())
	assembly.toolbox = type
	switch(assembly.toolbox)
		if(/obj/item/storage/toolbox/mechanical/old)
			assembly.toolbox_color = "ob"
		if(/obj/item/storage/toolbox/emergency)
			assembly.toolbox_color = "r"
		if(/obj/item/storage/toolbox/emergency/old)
			assembly.toolbox_color = "or"
		if(/obj/item/storage/toolbox/electrical)
			assembly.toolbox_color = "y"
		if(/obj/item/storage/toolbox/green)
			assembly.toolbox_color = "g"
		if(/obj/item/storage/toolbox/syndicate)
			assembly.toolbox_color = "s"
		if(/obj/item/storage/toolbox/fakesyndi)
			assembly.toolbox_color = "s"
	assembly.update_icon(UPDATE_ICON_STATE)
	transfer_fingerprints_to(assembly)
	assembly.add_fingerprint(user)
	if(loc == user)
		user.temporarily_remove_item_from_inventory(src, force = TRUE)
		user.put_in_hands(assembly)
	to_chat(user, span_notice("You have reinforced the toolbox with plasteel sheets. Now it is suitable for further floorbot construction."))
	qdel(src)


/obj/item/toolbox_tiles/update_icon_state()
	icon_state = "[toolbox_color]toolbox_tiles"


/obj/item/toolbox_tiles/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_pen(I))
		var/new_name = rename_interactive(user, I, prompt = "Enter new robot name")
		if(!isnull(new_name))
			created_name = new_name
			add_game_logs("[key_name(user)] has renamed a robot to [new_name]", user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	add_fingerprint(user)
	if(!isprox(I))
		to_chat(user, span_warning("You need a proximity sensor to continue the construction."))
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(I, src))
		return ..()
	var/obj/item/toolbox_tiles/sensor/assembly = new(drop_location())
	assembly.created_name = created_name
	assembly.toolbox_color = toolbox_color
	assembly.update_icon(UPDATE_ICON_STATE)
	I.transfer_fingerprints_to(assembly)
	transfer_fingerprints_to(assembly)
	assembly.add_fingerprint(user)
	if(loc == user)
		user.temporarily_remove_item_from_inventory(src, force = TRUE)
		user.put_in_hands(assembly)
	to_chat(user, span_notice("You have added the proximity sensor to the floorbot assembly."))
	qdel(I)
	qdel(src)
	return ATTACK_CHAIN_BLOCKED_ALL



/obj/item/toolbox_tiles/sensor/update_icon_state()
	icon_state = "[toolbox_color]toolbox_tiles_sensor"


/obj/item/toolbox_tiles/sensor/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_pen(I))
		var/new_name = rename_interactive(user, I, prompt = "Enter new robot name")
		if(!isnull(new_name))
			created_name = new_name
			add_game_logs("[key_name(user)] has renamed a robot to [new_name]", user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	add_fingerprint(user)
	if(!istype(I, /obj/item/robot_parts/l_arm) && !istype(I, /obj/item/robot_parts/r_arm))
		to_chat(user, span_warning("You need a cyborg arm to finish the construction."))
		return ATTACK_CHAIN_PROCEED

	if(!isturf(loc))
		to_chat(user, span_warning("You cannot finish the construction [ismob(loc) ? "in inventory" : "in [loc]"]."))
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(I, src))
		return ..()

	var/mob/living/simple_animal/bot/floorbot/new_bot = new(loc, toolbox_color)
	I.transfer_fingerprints_to(new_bot)
	transfer_fingerprints_to(new_bot)
	new_bot.add_fingerprint(user)
	new_bot.name = created_name
	new_bot.robot_arm = I.type
	to_chat(user, span_notice("You have completed the floorbot assembly. Beep boop!"))
	qdel(I)
	qdel(src)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/item/storage/firstaid/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || (!istype(I, /obj/item/robot_parts/l_arm) && !istype(I, /obj/item/robot_parts/r_arm)))
		return ..()

	. = ATTACK_CHAIN_PROCEED

	add_fingerprint(user)
	if(length(contents))
		to_chat(user, span_warning("The [name] should be empty to start the medibot construction."))
		return .

	. |= ATTACK_CHAIN_BLOCKED_ALL

	hide_from_all_viewers()

	var/obj/item/firstaid_arm_assembly/assembly = new(drop_location(), med_bot_skin)
	assembly.req_access = req_access
	assembly.syndicate_aligned = syndicate_aligned
	assembly.treatment_oxy = treatment_oxy
	assembly.treatment_brute = treatment_brute
	assembly.treatment_fire = treatment_fire
	assembly.treatment_tox = treatment_tox
	assembly.treatment_virus = treatment_virus
	assembly.robot_arm = I.type
	transfer_fingerprints_to(assembly)
	I.transfer_fingerprints_to(assembly)
	assembly.add_fingerprint(user)
	if(loc == user)
		user.temporarily_remove_item_from_inventory(src, force = TRUE)
		user.put_in_hands(assembly)
	to_chat(user, span_notice("You have added the cyborg arm to [src]. Now it is suitable for further medibot construction."))
	qdel(I)
	qdel(src)


/obj/item/firstaid_arm_assembly
	name = "incomplete medibot assembly."
	desc = "A first aid kit with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "firstaid_arm"
	w_class = WEIGHT_CLASS_NORMAL
	req_access = list(ACCESS_MEDICAL, ACCESS_ROBOTICS)
	var/build_step = 0
	var/created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null //Same as medbot, set to tox or ointment for the respective kits.
	var/syndicate_aligned = FALSE
	var/treatment_brute = "salglu_solution"
	var/treatment_oxy = "salbutamol"
	var/treatment_fire = "salglu_solution"
	var/treatment_tox = "charcoal"
	var/treatment_virus = "spaceacillin"
	var/robot_arm = /obj/item/robot_parts/l_arm


/obj/item/firstaid_arm_assembly/Initialize(mapload, new_skin)
	. = ..()
	if(new_skin)
		skin = new_skin
	update_icon(UPDATE_OVERLAYS)


/obj/item/firstaid_arm_assembly/update_overlays()
	. = ..()
	if(skin)
		. += image('icons/obj/aibots.dmi', "kit_skin_[skin]")
	if(build_step > 0)
		. += image('icons/obj/aibots.dmi', "na_scanner")


/obj/item/firstaid_arm_assembly/update_name(updates = ALL)
	. = ..()
	if(build_step == 1)
		name = "First aid/robot arm/health analyzer assembly"


/obj/item/firstaid_arm_assembly/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_pen(I))
		var/new_name = rename_interactive(user, I, prompt = "Enter new robot name")
		if(!isnull(new_name))
			created_name = new_name
			add_game_logs("[key_name(user)] has renamed a robot to [new_name]", user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	switch(build_step)
		if(0)
			add_fingerprint(user)
			if(!istype(I, /obj/item/healthanalyzer))
				to_chat(user, span_warning("You need a health analyzer to continue the construction."))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			to_chat(user, span_notice("You have added the health analyzer to the medibot assembly."))
			build_step++
			update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)
			qdel(I)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(1)
			add_fingerprint(user)
			if(!isprox(I))
				to_chat(user, span_warning("You need a proximity sensor to complete the assembly."))
				return ATTACK_CHAIN_PROCEED
			if(!isturf(loc))
				to_chat(user, span_warning("You cannot finish the construction [ismob(loc) ? "in inventory" : "in [loc]"]."))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			to_chat(user, span_notice("You have completed the medibot assembly. Beep boop!"))
			var/mob/living/simple_animal/bot/medbot/new_bot
			if(syndicate_aligned)
				// syndicate medibots are a special case that have so many unique vars on them,
				// it's not worth passing them through construction phases
				new_bot = new /mob/living/simple_animal/bot/medbot/syndicate(loc)
			else
				new_bot = new /mob/living/simple_animal/bot/medbot(loc, skin)
				new_bot.name = created_name
				new_bot.bot_core.req_access = req_access
				new_bot.treatment_oxy = treatment_oxy
				new_bot.treatment_brute = treatment_brute
				new_bot.treatment_fire = treatment_fire
				new_bot.treatment_tox = treatment_tox
				new_bot.treatment_virus = treatment_virus
				new_bot.robot_arm = robot_arm
			transfer_fingerprints_to(new_bot)
			I.transfer_fingerprints_to(new_bot)
			new_bot.add_fingerprint(user)
			qdel(I)
			qdel(src)
			return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


//Secbot Assembly
/obj/item/secbot_assembly
	name = "incomplete securitron assembly"
	desc = "Some sort of bizarre assembly made from a proximity sensor, helmet, and signaler."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/created_name = "Securitron" //To preserve the name if it's a unique securitron I guess
	var/build_step = 0
	var/robot_arm = /obj/item/robot_parts/l_arm


/obj/item/secbot_assembly/update_name(updates = ALL)
	. = ..()
	switch(build_step)
		if(2)
			name = "helmet/signaler/prox sensor assembly"
		if(3)
			name = "helmet/signaler/prox sensor/robot arm assembly"


/obj/item/secbot_assembly/update_overlays()
	. = ..()
	switch(build_step)
		if(1)
			. += "hs_hole"
		if(2)
			. += "hs_eye"
		if(3)
			. += "hs_arm"


/obj/item/clothing/head/helmet/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || !issignaler(I))
		return ..()

	. = ATTACK_CHAIN_PROCEED
	add_fingerprint(user)
	var/obj/item/assembly/signaler/signaler = I
	if(signaler.secured)
		to_chat(user, span_warning("The [signaler.name] should be unsecured."))
		return ATTACK_CHAIN_PROCEED

	. |= ATTACK_CHAIN_BLOCKED_ALL

	var/obj/item/secbot_assembly/assembly = new(drop_location())
	I.transfer_fingerprints_to(assembly)
	transfer_fingerprints_to(assembly)
	assembly.add_fingerprint(user)
	if(loc == user)
		user.temporarily_remove_item_from_inventory(src, force = TRUE)
		user.put_in_hands(assembly)
	to_chat(user, span_notice("You have added the the signaler to the helmet. Now it is suitable for further securitron construction."))
	qdel(I)
	qdel(src)


/obj/item/secbot_assembly/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_pen(I))
		var/new_name = rename_interactive(user, I, prompt = "Enter new robot name")
		if(!isnull(new_name))
			created_name = new_name
			add_game_logs("[key_name(user)] has renamed a robot to [new_name]", user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	switch(build_step)
		if(1)
			add_fingerprint(user)
			if(!isprox(I))
				to_chat(user, span_warning("You need a proximity sensor to continue the construction."))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			to_chat(user, span_notice("You have added the proximity sensor to the securitron assembly."))
			build_step++
			update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)
			qdel(I)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(2)
			add_fingerprint(user)
			if(!istype(I, /obj/item/robot_parts/l_arm) && !istype(I, /obj/item/robot_parts/r_arm))
				to_chat(user, span_warning("You need a cyborg arm to continue the construction."))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			to_chat(user, span_notice("You have added the cyborg arm to the securitron assembly."))
			build_step++
			robot_arm = I.type
			update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)
			qdel(I)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(3)
			add_fingerprint(user)
			if(!istype(I, /obj/item/melee/baton/security))
				to_chat(user, span_warning("You need a stunbaton to complete the assembly."))
				return ATTACK_CHAIN_PROCEED
			if(!isturf(loc))
				to_chat(user, span_warning("You cannot finish the construction [ismob(loc) ? "in inventory" : "in [loc]"]."))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			to_chat(user, span_notice("You have completed the securitron assembly. Beep boop!"))
			var/mob/living/simple_animal/bot/secbot/new_bot = new(loc)
			new_bot.name = created_name
			new_bot.robot_arm = robot_arm
			transfer_fingerprints_to(new_bot)
			I.transfer_fingerprints_to(new_bot)
			new_bot.add_fingerprint(user)
			qdel(I)
			qdel(src)
			return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/secbot_assembly/screwdriver_act(mob/living/user, obj/item/I)
	if(build_step != 0 && build_step != 2 && build_step != 3)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	var/atom/drop_loc = drop_location()
	switch(build_step)
		if(0)
			var/obj/item/assembly/signaler/signaler = new(drop_loc)
			transfer_fingerprints_to(signaler)
			signaler.add_fingerprint(user)
			var/obj/item/clothing/head/helmet/helmet = new(drop_loc)
			transfer_fingerprints_to(helmet)
			helmet.add_fingerprint(user)
			to_chat(user, span_notice("You have disconnected the signaler from the helmet."))
			qdel(src)
		if(2)
			var/obj/item/assembly/prox_sensor/sensor = new(drop_loc)
			transfer_fingerprints_to(sensor)
			sensor.add_fingerprint(user)
			build_step--
			to_chat(user, span_notice("You have detached the proximity sensor from the securitron assembly."))
			update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)
		if(3)
			var/obj/item/robot_parts/new_arm = new robot_arm(drop_loc)
			transfer_fingerprints_to(new_arm)
			new_arm.add_fingerprint(user)
			build_step--
			to_chat(user, span_notice("You have removed the cyborg arm from the securitron assembly."))
			update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)


/obj/item/secbot_assembly/wrench_act(mob/living/user, obj/item/I)
	if(build_step != 3)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	to_chat(user, span_notice("You have adjusted the arm slots for extra weapons."))
	var/obj/item/griefsky_assembly/destroyer_of_the_worlds = new(drop_location())
	transfer_fingerprints_to(destroyer_of_the_worlds)
	destroyer_of_the_worlds.add_fingerprint(user)
	if(loc == user)
		user.temporarily_remove_item_from_inventory(src, force = TRUE)
		user.put_in_hands(destroyer_of_the_worlds)
	qdel(src)


/obj/item/secbot_assembly/welder_act(mob/living/user, obj/item/I)
	if(build_step != 0 && build_step != 1)
		return FALSE
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	if(build_step == 1)
		build_step = 0
		to_chat(user, span_notice("You have welded shut the hole in the securitron assembly."))
	else
		build_step = 1
		to_chat(user, span_notice("You have welded a hole in the securitron assembly."))
	update_appearance(UPDATE_OVERLAYS)


//General Griefsky

/obj/item/griefsky_assembly
	name = "\improper General Griefsky assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "griefsky_assembly"
	item_state = "griefsky_assembly"
	var/build_step = 0
	var/toy_step = 0


/obj/item/griefsky_assembly/update_name(updates = ALL)
	. = ..()
	name = toy_step > 0 ? "\improper Genewul Giftskee assembly" : "\improper General Griefsky assembly"


/obj/item/griefsky_assembly/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	add_fingerprint(user)
	var/energy_sword = istype(I, /obj/item/melee/energy/sword)
	var/toy_sword = istype(I, /obj/item/toy/sword)
	if(!energy_sword && !toy_sword)
		if(build_step == 0 && toy_step == 0)
			to_chat(user, span_warning("You need a toy sword or an energy sword to continue the construction."))
			return ATTACK_CHAIN_PROCEED
		if(build_step > 0)
			to_chat(user, span_warning("You need an energy sword to continue the construction."))
			return ATTACK_CHAIN_PROCEED
		if(toy_step > 0)
			to_chat(user, span_warning("You need a toy sword to continue the construction."))
			return ATTACK_CHAIN_PROCEED
		return ATTACK_CHAIN_PROCEED

	if(energy_sword)
		if(toy_step > 0)
			to_chat(user, span_warning("The energy sword is incompatible with the Genewul Giftskee assembly."))
			return ATTACK_CHAIN_PROCEED
		if(build_step == 3)
			if(!isturf(loc))
				to_chat(user, span_warning("You cannot finish the construction [ismob(loc) ? "in inventory" : "in [loc]"]."))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			to_chat(user, span_notice("You have completed the General Griefsky assembly. Its war crimes time!"))
			var/mob/living/simple_animal/bot/secbot/griefsky/destroyer_of_the_worlds = new(loc)
			transfer_fingerprints_to(destroyer_of_the_worlds)
			I.transfer_fingerprints_to(destroyer_of_the_worlds)
			destroyer_of_the_worlds.add_fingerprint(user)
			qdel(I)
			qdel(src)
			return ATTACK_CHAIN_BLOCKED_ALL
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		build_step++
		I.transfer_fingerprints_to(src)
		update_appearance(UPDATE_NAME)
		to_chat(user, span_notice("You have added the energy sword to the General Griefsky assembly. It prays for more!"))
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(build_step > 0)
		to_chat(user, span_warning("The toy sword is incompatible with the General Griefsky assembly."))
		return ATTACK_CHAIN_PROCEED
	if(toy_step == 3)
		if(!isturf(loc))
			to_chat(user, span_warning("You cannot finish the construction [ismob(loc) ? "in inventory" : "in [loc]"]."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You have completed the Genewul Giftskee assembly. Its party time!"))
		var/mob/living/simple_animal/bot/secbot/griefsky/toy/destroyer_of_the_pinatas = new(loc)
		transfer_fingerprints_to(destroyer_of_the_pinatas)
		I.transfer_fingerprints_to(destroyer_of_the_pinatas)
		destroyer_of_the_pinatas.add_fingerprint(user)
		qdel(I)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL
	if(!user.drop_transfer_item_to_loc(I, src))
		return ..()
	toy_step++
	I.transfer_fingerprints_to(src)
	update_appearance(UPDATE_NAME)
	to_chat(user, span_notice("You have added the toy sword to the Genewul Giftskee assembly. It prays for more!"))
	qdel(I)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/item/griefsky_assembly/screwdriver_act(mob/living/user, obj/item/I)
	if(build_step == 0 && toy_step == 0)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	var/obj/item/sword
	if(build_step)
		sword = new /obj/item/melee/energy/sword(drop_location())
		to_chat(user, span_notice("You have detached the energy sword from the Griefsky assembly."))
		build_step--
	else if(toy_step)
		sword = new /obj/item/toy/sword(drop_location())
		to_chat(user, span_notice("You have detached the toy sword from the Griefsky assembly."))
		toy_step--
	transfer_fingerprints_to(sword)
	sword.add_fingerprint(user)
	update_appearance(UPDATE_NAME)


/obj/item/storage/box/clown/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || (!istype(I, /obj/item/robot_parts/l_arm) && !istype(I, /obj/item/robot_parts/r_arm)))
		return ..()

	. = ATTACK_CHAIN_PROCEED

	add_fingerprint(user)
	if(length(contents))
		to_chat(user, span_warning("The [name] should be empty to start the honkbot construction."))
		return .

	. |= ATTACK_CHAIN_BLOCKED_ALL

	hide_from_all_viewers()

	var/obj/item/honkbot_arm_assembly/assembly = new(drop_location())
	assembly.robot_arm = I.type
	transfer_fingerprints_to(assembly)
	I.transfer_fingerprints_to(assembly)
	assembly.add_fingerprint(user)
	if(loc == user)
		user.temporarily_remove_item_from_inventory(src, force = TRUE)
		user.put_in_hands(assembly)
	to_chat(user, span_notice("You have added the cyborg arm to [src]. Now it is suitable for further honkbot construction."))
	qdel(I)
	qdel(src)


/obj/item/honkbot_arm_assembly
	name = "incomplete honkbot assembly"
	desc = "A clown box with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "honkbot_arm"
	w_class = WEIGHT_CLASS_NORMAL
	req_access = list(ACCESS_CLOWN, ACCESS_ROBOTICS, ACCESS_MIME)
	var/build_step = 0
	var/created_name = "Honkbot" //To preserve the name if it's a unique medbot I guess
	var/robot_arm = /obj/item/robot_parts/l_arm


/obj/item/honkbot_arm_assembly/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	switch(build_step)
		if(0)
			add_fingerprint(user)
			if(!isprox(I))
				to_chat(user, span_warning("You need a proximity sensor to continue the construction."))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			to_chat(user, span_notice("You have added the proximity sensor to the honkbot assembly."))
			build_step++
			update_appearance(UPDATE_ICON_STATE)
			qdel(I)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(1)
			add_fingerprint(user)
			if(!istype(I, /obj/item/bikehorn))
				to_chat(user, span_warning("You need a bike horn to continue the construction."))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			to_chat(user, span_notice("You have added the bike horn to the honkbot assembly."))
			build_step++
			update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
			qdel(I)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(2)
			add_fingerprint(user)
			if(!istype(I, /obj/item/instrument/trombone))
				to_chat(user, span_warning("You need a trombone to complete the assembly."))
				return ATTACK_CHAIN_PROCEED
			if(!isturf(loc))
				to_chat(user, span_warning("You cannot finish the construction [ismob(loc) ? "in inventory" : "in [loc]"]."))
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()
			to_chat(user, span_notice("You have completed the honkbot assembly. HONK!"))
			var/mob/living/simple_animal/bot/honkbot/new_bot = new(loc)
			new_bot.robot_arm = robot_arm
			transfer_fingerprints_to(new_bot)
			I.transfer_fingerprints_to(new_bot)
			new_bot.add_fingerprint(user)
			qdel(I)
			qdel(src)
			return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/honkbot_arm_assembly/update_icon_state()
	icon_state = build_step == 1 ? "honkbot_proxy" : "honkbot_arm"


/obj/item/honkbot_arm_assembly/update_desc(updates = ALL)
	. = ..()
	if(build_step == 2)
		desc = "A clown box with a robot arm and a bikehorn permanently grafted to it. It needs a trombone to be finished"
		return .
	desc = initial(desc)

