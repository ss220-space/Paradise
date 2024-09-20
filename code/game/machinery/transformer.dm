/obj/machinery/transformer
	name = "Automatic Robotic Factory 5000"
	desc = "A large metalic machine with an entrance and an exit. A sign on the side reads, 'human go in, robot come out', human must be lying down and alive. Has to cooldown between each use."
	icon = 'icons/obj/machines/recycling.dmi'
	icon_state = "separator-AO1"
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	density = TRUE
	dir = WEST	// we are using this to offset acceptdir
	processing_flags = START_PROCESSING_MANUALLY
	/// Whether this machine transforms dead mobs into cyborgs
	var/transform_dead = FALSE
	/// Whether this machine transforms standing mobs into cyborgs
	var/transform_standing = TRUE
	/// How long we have to wait between processing mobs
	var/cooldown_duration = 1 MINUTES
	/// The created cyborg's cell
	var/robot_cell_type = /obj/item/stock_parts/cell/high/plus
	/// The direction that mobs must be moving in to get transformed
	var/acceptdir = EAST
	/// Master AI that created this factory
	var/mob/living/silicon/ai/masterAI
	/// Cooldown timestamp for transformations
	COOLDOWN_DECLARE(cooldown_timer)


/obj/machinery/transformer/Initialize(mapload, mob/living/silicon/ai/masterAI)
	. = ..()
	src.masterAI = masterAI
	initialize_belts()
	GLOB.disable_robotics_consoles = TRUE


/// Used to create all of the belts the transformer will be using. All belts should be pushing `WEST`.
/obj/machinery/transformer/proc/initialize_belts()
	var/turf/our_turf = loc
	if(!isturf(our_turf))
		return

	// Belt under the factory.
	new /obj/machinery/conveyor/auto(our_turf, WEST)

	// Get the turf 1 tile to the EAST.
	var/turf/east = locate(our_turf.x + 1, our_turf.y, our_turf.z)
	if(isfloorturf(east))
		new /obj/machinery/conveyor/auto(east, WEST)

	// Get the turf 1 tile to the WEST.
	var/turf/west = locate(our_turf.x - 1, our_turf.y, our_turf.z)
	if(isfloorturf(west))
		new /obj/machinery/conveyor/auto(west, WEST)


/obj/machinery/transformer/examine(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, cooldown_timer) && (issilicon(user) || isobserver(user)))
		. += span_notice("It will be ready in <b>[DisplayTimeText(COOLDOWN_TIMELEFT(src, cooldown_timer))]</b>.")


/obj/machinery/transformer/power_change(forced = FALSE)
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/transformer/update_icon_state()
	if(!COOLDOWN_FINISHED(src, cooldown_timer) || (stat & (BROKEN|NOPOWER)))
		icon_state = "separator-AO0"
	else
		icon_state = initial(icon_state)


/obj/machinery/transformer/setDir(newdir)
	var/old_dir = dir
	. = ..()
	if(dir == old_dir)
		return .
	var/obj/machinery/conveyor/conveyor = locate() in loc
	if(conveyor)
		conveyor.setDir(dir)
		acceptdir = REVERSE_DIR(dir)


/obj/machinery/transformer/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	// Allows items to go through to stop them from blocking the conveyor belt.
	if(isitem(mover) && get_dir(src, mover) == acceptdir)
		return TRUE


/obj/machinery/transformer/Bumped(atom/movable/moving_atom)
	. = ..()

	if(!COOLDOWN_FINISHED(src, cooldown_timer) || acceptdir != get_dir(loc, moving_atom.loc))
		return .

	transformer_bumped(moving_atom)


/obj/machinery/transformer/proc/transformer_bumped(mob/living/carbon/human/victim)
	if(!ishuman(victim) || (!transform_standing && victim.body_position == STANDING_UP))
		return
	victim.forceMove(loc)
	do_transform(victim)


/obj/machinery/transformer/process()
	if(COOLDOWN_FINISHED(src, cooldown_timer))
		update_icon(UPDATE_ICON_STATE)
		return PROCESS_KILL


/// Transforms a human mob into a cyborg, connects them to the malf AI which placed the factory.
/obj/machinery/transformer/proc/do_transform(mob/living/carbon/human/victim)
	if(!COOLDOWN_FINISHED(src, cooldown_timer) || stat & (BROKEN|NOPOWER))
		return

	if(!transform_dead && victim.stat == DEAD)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		return

	// Activate the cooldown
	COOLDOWN_START(src, cooldown_timer, cooldown_duration)
	begin_processing()
	update_icon(UPDATE_ICON_STATE)

	playsound(src, 'sound/items/welder.ogg', 50, TRUE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/machines/ping.ogg', 50, FALSE), 3 SECONDS)
	use_power(5000) // Use a lot of power.

	victim.emote("scream") // It is painful
	if(!masterAI) // If the factory was placed via admin spawning or other means, it wont have an owner_AI.
		var/mob/living/silicon/robot/new_borg = victim.Robotize(robot_cell_type)
		SSticker?.score?.save_silicon_laws(new_borg, additional_info = "malf AI factory transformation", log_all_laws = TRUE)
		new_borg.emagged = TRUE
		return

	var/mob/living/silicon/robot/new_borg = victim.Robotize(robot_cell_type, FALSE, masterAI)
	new_borg.emagged = TRUE

	if(new_borg.mind && !new_borg.client && !new_borg.grab_ghost()) // Make sure this is an actual player first and not just a humanized monkey or something.
		message_admins("[key_name_admin(new_borg)] was just transformed by a borg factory, but they were SSD. Polling ghosts for a replacement.")
		var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a malfunctioning cyborg?", ROLE_MALF_AI, poll_time = 15 SECONDS)
		if(!length(candidates))
			return
		var/mob/dead/observer/observer = pick(candidates)
		new_borg.key = observer.key
		log_game("[new_borg.key] has become malfunctioning cyborg.")
	SSticker?.score?.save_silicon_laws(new_borg, additional_info = "malf AI factory transformation", log_all_laws = TRUE)


/obj/machinery/transformer/mime
	name = "Mimetech Greyscaler"
	desc = "Turns anything placed inside black and white."


/obj/machinery/transformer/mime/transformer_bumped(atom/movable/moving_atom)
	if(isitem(moving_atom))
		moving_atom.forceMove(loc)
		do_transform_mime(moving_atom)
	else if(ismob(moving_atom))
		to_chat(moving_atom, span_warning("Only items can be greyscaled."))


/obj/machinery/transformer/proc/do_transform_mime(obj/item/item)
	if(!COOLDOWN_FINISHED(src, cooldown_timer) || (stat & (BROKEN|NOPOWER)))
		return

	playsound(src, 'sound/items/welder.ogg', 50, TRUE)
	use_power(5000) // Use a lot of power.

	var/icon/newicon = new(item.icon, item.icon_state)
	newicon.GrayScale()
	item.icon = newicon

	// Activate the cooldown
	COOLDOWN_START(src, cooldown_timer, cooldown_duration)
	begin_processing()
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/transformer/xray
	name = "Automatic X-Ray 5000"
	desc = "A large metalic machine with an entrance and an exit. A sign on the side reads, 'backpack go in, backpack come out', 'human go in, irradiated human come out'."
	transform_standing = FALSE
	dir = EAST
	acceptdir = WEST


/obj/machinery/transformer/xray/initialize_belts()
	var/turf/our_turf = loc
	if(!isturf(our_turf))
		return

	// Belt under the factory.
	new /obj/machinery/conveyor/auto(our_turf, EAST)

	// Get the turf 1 tile to the EAST.
	var/turf/east = locate(our_turf.x + 1, our_turf.y, our_turf.z)
	if(isfloorturf(east))
		new /obj/machinery/conveyor/auto(east, EAST)

	// Get the turf 2 tiles to the EAST.
	var/turf/east2 = locate(our_turf.x + 2, our_turf.y, our_turf.z)
	if(isfloorturf(east2))
		new /obj/machinery/conveyor/auto(east2, EAST)

	// Get the turf 1 tile to the WEST.
	var/turf/west = locate(our_turf.x - 1, our_turf.y, our_turf.z)
	if(isfloorturf(west))
		new /obj/machinery/conveyor/auto(west, EAST)

	// Get the turf 2 tiles to the WEST.
	var/turf/west2 = locate(our_turf.x - 2, our_turf.y, our_turf.z)
	if(isfloorturf(west2))
		new /obj/machinery/conveyor/auto(west2, EAST)


/obj/machinery/transformer/xray/transformer_bumped(atom/movable/moving_atom)
	if(ishuman(moving_atom))
		var/mob/living/carbon/human/victim = moving_atom
		if(transform_standing || victim.body_position == LYING_DOWN)
			victim.forceMove(loc)
			irradiate(victim)

	else if(isitem(moving_atom))
		moving_atom.forceMove(loc)
		scan(moving_atom)


/obj/machinery/transformer/xray/proc/irradiate(mob/living/carbon/human/victim)
	if(stat & (BROKEN|NOPOWER))
		return

	flick("separator-AO0", src)
	playsound(loc, 'sound/effects/alert.ogg', 50, FALSE)
	sleep(0.5 SECONDS)
	victim.apply_effect((rand(150,200)), IRRADIATE, 0)
	if(prob(5))
		if(prob(75))
			randmutb(victim) // Applies bad mutation
		else
			randmutg(victim) // Applies good mutation
		victim.check_genes(MUTCHK_FORCED)


/obj/machinery/transformer/xray/proc/scan(obj/item/I)
	if(scan_rec(I))
		playsound(src, 'sound/effects/alert.ogg', 50, FALSE)
		flick("separator-AO0",src)
	else
		playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
		sleep(30)


/obj/machinery/transformer/xray/proc/scan_rec(obj/item/I)
	if(isgun(I))
		return TRUE
	if(istype(I, /obj/item/transfer_valve))
		return TRUE
	if(istype(I, /obj/item/kitchen/knife))
		return TRUE
	if(istype(I, /obj/item/grenade/plastic/c4))
		return TRUE
	if(istype(I, /obj/item/melee))
		return TRUE
	for(var/obj/item/C in I.contents)
		if(scan_rec(C))
			return TRUE
	return FALSE


/obj/machinery/transformer/equipper
	name = "Auto-equipper 9000"
	desc = "Either in employ of people who cannot dress themselves, or Wallace and Gromit."
	var/selected_outfit = /datum/outfit/job/assistant
	var/prestrip = TRUE


/obj/machinery/transformer/equipper/do_transform(mob/living/carbon/human/victim)
	if(!ispath(selected_outfit, /datum/outfit))
		to_chat(victim, span_warning("This equipper is not properly configured! 'selected_outfit': '[selected_outfit]'"))
		return

	if(prestrip)
		for(var/obj/item/item as anything in victim.get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
			qdel(item)

	victim.equipOutfit(selected_outfit)
	victim.dna.species.after_equip_job(null, victim)


/obj/machinery/transformer/transmogrifier
	name = "species transmogrifier"
	desc = "As promoted in Calvin & Hobbes!"
	var/datum/species/target_species = /datum/species/human


/obj/machinery/transformer/transmogrifier/do_transform(mob/living/carbon/human/victim)
	if(!ispath(target_species))
		to_chat(victim, span_warning("'[target_species]' is not a valid species!"))
		return
	victim.set_species(target_species)


/obj/machinery/transformer/dnascrambler
	name = "genetic scrambler"
	desc = "Step right in and become a new you!"


/obj/machinery/transformer/dnascrambler/do_transform(mob/living/carbon/human/victim)
	scramble(TRUE, victim, 100)
	victim.generate_name()
	victim.sync_organ_dna(assimilate = TRUE)
	victim.update_body()
	victim.reset_hair()
	victim.dna.ResetUIFrom(victim)


/obj/machinery/transformer/gene_applier
	name = "genetic blueprint applier"
	desc = "Here begin the clone wars. Upload a template by using a genetics disk on this machine."
	var/datum/dna/template
	var/locked = FALSE // For admins sealing the deal


/obj/machinery/transformer/gene_applier/do_transform(mob/living/carbon/human/victim)
	if(!istype(template))
		to_chat(victim, span_warning("No genetic template configured!"))
		return
	var/prev_ue = victim.dna.unique_enzymes
	victim.set_species(template.species.type)
	victim.dna = template.Clone()
	victim.real_name = template.real_name
	victim.sync_organ_dna(assimilate = FALSE, old_ue = prev_ue)
	victim.UpdateAppearance()
	victim.check_genes(MUTCHK_FORCED)


/obj/machinery/transformer/gene_applier/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/disk/data))
		add_fingerprint(user)
		if(locked)
			to_chat(user, span_warning("Access Denied."))
			playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
			return ATTACK_CHAIN_PROCEED
		var/obj/item/disk/data/disk = I
		if(!disk.buf)
			to_chat(user, span_warning("Error: No data found."))
			return ATTACK_CHAIN_PROCEED
		template = disk.buf.dna.Clone()
		to_chat(user, span_notice("Upload of gene template for '[template.real_name]' complete!"))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

