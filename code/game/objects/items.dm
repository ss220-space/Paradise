GLOBAL_DATUM_INIT(fire_overlay, /mutable_appearance, mutable_appearance('icons/goonstation/effects/fire.dmi', "fire"))
/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	pass_flags_self = PASSITEM
	pass_flags = PASSTABLE

	move_resist = null // Set in the Initialise depending on the item size. Unless it's overriden by a specific item

	max_integrity = 200

	suicidal_hands = TRUE

	obj_flags = IGNORE_HITS

	// Item flags
	/// Flags only used with items.
	var/item_flags = NONE
	/// This is used to determine on which slots an item can fit.
	var/slot_flags = NONE
	/// Additional slot flags, mostly used by humans.
	var/slot_flags_2 = NONE
	/// This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	var/flags_inv = NONE
	/// These flags will be added/removed (^=) to/from flags_inv in [/proc/check_obscured_slots()]
	/// if check_transparent argument is set to `TRUE`. Used in carbon's update icons shenanigans.
	/// Example: you can see someone's mask through their transparent visor, but you cannot reach it
	var/flags_inv_transparent = NONE
	/// Special cover flags used for protection calculations.
	var/flags_cover = NONE

	/// Used as the dye color source in the washing machine only (at the moment). Can be a hex color or a key corresponding to a registry entry, see washing_machine.dm
	var/dye_color
	/// Whether the item is unaffected by standard dying.
	var/undyeable = FALSE
	/// What dye registry should be looked at when dying this item; see washing_machine.dm
	var/dying_key

	/// The click cooldown given after attacking. Lower numbers means faster attacks
	var/attack_speed = CLICK_CD_MELEE

	/// Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]".
	var/list/attack_verb
	/// Sound played when you hit something with the item.
	var/hitsound
	/// Played when the item is used, for example tools.
	var/usesound
	/// Used when yate into a mob.
	var/mob_throw_hit_sound
	///Sound used when equipping the item into a valid slot.
	var/equip_sound = list(
		'sound/items/handling/generic_equip1.ogg',
		'sound/items/handling/generic_equip2.ogg',
		'sound/items/handling/generic_equip3.ogg',
		'sound/items/handling/generic_equip4.ogg',
		'sound/items/handling/generic_equip5.ogg',
	)
	///Sound used when picking the item up (into your hands)
	var/pickup_sound = list(
		'sound/items/handling/generic_pickup1.ogg',
		'sound/items/handling/generic_pickup2.ogg',
		'sound/items/handling/generic_pickup3.ogg',
	)
	///Sound used when dropping the item.
	var/drop_sound = list(
		'sound/items/handling/generic_drop1.ogg',
		'sound/items/handling/generic_drop2.ogg',
		'sound/items/handling/generic_drop3.ogg',
		'sound/items/handling/generic_drop4.ogg',
		'sound/items/handling/generic_drop5.ogg',
	)
	///Whether or not we use stealthy audio levels for this item's attack sounds
	var/stealthy_audio = FALSE
	var/w_class = WEIGHT_CLASS_NORMAL
	pressure_resistance = 4
	//	causeerrorheresoifixthis
	var/obj/item/master = null

	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	var/list/actions = null //list of /datum/action's that this item has.
	var/list/actions_types = null //list of paths of action datums to give to the item on New().
	var/list/action_icon = null //list of icons-sheets for a given action to override the icon.
	var/list/action_icon_state = null //list of icon states for a given action to override the icon_state.

	var/list/materials = null
	var/materials_coeff = 1
	var/item_color = null

	/// if you want to color icon in hands, but not a icon of item
	var/item_state_color
	var/item_state_alpha

	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/armour_penetration = 0 //percentage of armour effectiveness to remove
	var/shields_penetration = 0 //amount by which block_chance decreases
	/// Allows you to override the attack animation with an attack effect
	var/attack_effect_override
	var/list/allowed = null //suit storage stuff.
	var/obj/item/uplink/hidden/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.

	var/needs_permit = 0			//Used by security bots to determine if this item is safe for public use.

	var/strip_delay = DEFAULT_ITEM_STRIP_DELAY
	var/put_on_delay = DEFAULT_ITEM_PUTON_DELAY
	var/breakouttime = 0

	var/block_chance = 0
	var/hit_reaction_chance = 0 //If you want to have something unrelated to blocking/armour piercing etc. Maybe not needed, but trying to think ahead/allow more freedom

	// Needs to be in /obj/item because corgis can wear a lot of
	// non-clothing items
	var/datum/dog_fashion/dog_fashion = null
	var/datum/muhtar_fashion/muhtar_fashion = null
	var/datum/snake_fashion/snake_fashion = null

	/// UID of a /mob that threw the item.
	var/thrownby

	//So items can have custom embedd values
	//Because customisation is king
	var/embed_chance = EMBED_CHANCE
	var/embedded_fall_chance = EMBEDDED_ITEM_FALLOUT
	var/embedded_pain_chance = EMBEDDED_PAIN_CHANCE
	var/embedded_pain_multiplier = EMBEDDED_PAIN_MULTIPLIER  //The coefficient of multiplication for the damage this item does while embedded (this*w_class)
	var/embedded_fall_pain_multiplier = EMBEDDED_FALL_PAIN_MULTIPLIER //The coefficient of multiplication for the damage this item does when falling out of a limb (this*w_class)
	var/embedded_impact_pain_multiplier = EMBEDDED_IMPACT_PAIN_MULTIPLIER //The coefficient of multiplication for the damage this item does when first embedded (this*w_class)
	var/embedded_unsafe_removal_pain_multiplier = EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER //The coefficient of multiplication for the damage removing this without surgery causes (this*w_class)
	var/embedded_unsafe_removal_time = EMBEDDED_UNSAFE_REMOVAL_TIME //A time in ticks, multiplied by the w_class.
	var/embedded_ignore_throwspeed_threshold = FALSE

	var/tool_behaviour = NONE //What kind of tool are we?
	var/tool_enabled = TRUE //If we can turn on or off, are we currently active? Mostly for welders and this will normally be TRUE
	var/tool_volume = 50 //How loud are we when we use our tool?
	var/toolspeed = 1 // If this item is a tool, the speed multiplier

	/* Species-specific sprites, concept stolen from Paradise//vg/.
	ex:
	sprite_sheets = list(
		SPECIES_TAJARAN = 'icons/cat/are/bad'
		)
	If index term exists and icon_override is not set, this sprite sheet will be used.
	*/
	///Sprite sheets to render species clothing, takes priority over "onmob_sheets" var, but only takes one dmi
	var/list/sprite_sheets = null
	var/list/sprite_sheets_inhand = null //Used to override inhand items. Use a single .dmi and suffix the icon states inside with _l and _r for each hand.

	///Sprite sheets used to render clothing, if none of sprite_sheets are used
	var/list/onmob_sheets = list(
		ITEM_SLOT_EAR_LEFT_STRING = DEFAULT_ICON_LEFT_EAR,
		ITEM_SLOT_EAR_RIGHT_STRING = DEFAULT_ICON_RIGHT_EAR,
		ITEM_SLOT_BELT_STRING = DEFAULT_ICON_BELT,
		ITEM_SLOT_BACK_STRING = DEFAULT_ICON_BACK,
		ITEM_SLOT_CLOTH_OUTER_STRING = DEFAULT_ICON_OUTER_SUIT,
		ITEM_SLOT_CLOTH_INNER_STRING = DEFAULT_ICON_JUMPSUIT,
		ITEM_SLOT_MASK_STRING = DEFAULT_ICON_WEAR_MASK,
		ITEM_SLOT_HEAD_STRING = DEFAULT_ICON_HEAD,
		ITEM_SLOT_FEET_STRING = DEFAULT_ICON_SHOES,
		ITEM_SLOT_ID_STRING = DEFAULT_ICON_WEAR_ID,
		ITEM_SLOT_NECK_STRING = DEFAULT_ICON_NECK,
		ITEM_SLOT_EYES_STRING = DEFAULT_ICON_GLASSES,
		ITEM_SLOT_GLOVES_STRING = DEFAULT_ICON_GLOVES,
		ITEM_SLOT_SUITSTORE_STRING = DEFAULT_ICON_SUITSTORE,
		ITEM_SLOT_HANDCUFFED_STRING = DEFAULT_ICON_HANDCUFFED,
		ITEM_SLOT_LEGCUFFED_STRING = DEFAULT_ICON_LEGCUFFED,
		ITEM_SLOT_ACCESSORY_STRING = DEFAULT_ICON_ACCESSORY,
		ITEM_SLOT_COLLAR_STRING = DEFAULT_ICON_COLLAR
	)
	var/belt_icon = null
	var/item_state = null
	//Dimensions of the lefthand_file and righthand_file vars
	//eg: 32x32 sprite, 64x64 sprite, etc.
	var/inhand_x_dimension = 32
	var/inhand_y_dimension = 32
	var/lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	var/righthand_file = 'icons/mob/inhands/items_righthand.dmi'

	//Tooltip vars
	var/tip_timer = 0

	// item hover FX
	/// Holder var for the item outline filter, null when no outline filter on the item.
	var/outline_filter

	//Clockwork enchantment
	var/enchant_type = NO_SPELL // What's the type on enchantment on it? 0
	var/list/enchants = null // List(datum)

	//eat_items.dm
	var/material_type = MATERIAL_CLASS_NONE
	var/max_bites = 1 			//The maximum amount of bites before item is depleted
	var/current_bites = 0	//How many bites did
	var/integrity_bite = 10		// Integrity used
	var/nutritional_value = 20 	// How much nutrition add
	var/is_only_grab_intent = FALSE	//Grab if help_intent was used

	///In deciseconds, how long an item takes to equip/unequip; counts only for normal clothing slots, not pockets, hands etc.
	var/equip_delay_self = 0 SECONDS

	///Datum used in item pixel shift TGUI
	var/datum/ui_module/item_pixel_shift/item_pixel_shift

/obj/item/New()
	..()
	for(var/path in actions_types)
		if(action_icon && action_icon_state)
			new path(src, action_icon[path], action_icon_state[path])
		else
			new path(src)

	if(!move_resist)
		determine_move_resist()


/obj/item/Initialize(mapload)
	. = ..()
	if(isstorage(loc)) //marks all items in storage as being such
		item_flags |= IN_STORAGE
	if(!hitsound)
		if(damtype == "fire")
			hitsound = 'sound/items/welder.ogg'
		if(damtype == "brute")
			hitsound = "swing_hit"


/obj/item/proc/determine_move_resist()
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			move_resist = MOVE_FORCE_EXTREMELY_WEAK
		if(WEIGHT_CLASS_SMALL)
			move_resist = MOVE_FORCE_VERY_WEAK
		if(WEIGHT_CLASS_NORMAL)
			move_resist = MOVE_FORCE_WEAK
		if(WEIGHT_CLASS_BULKY)
			move_resist = MOVE_FORCE_NORMAL
		if(WEIGHT_CLASS_HUGE)
			move_resist = MOVE_FORCE_NORMAL
		if(WEIGHT_CLASS_GIGANTIC)
			move_resist = MOVE_FORCE_NORMAL


/obj/item/Destroy()
	item_flags &= ~DROPDEL	//prevent reqdels
	QDEL_NULL(hidden_uplink)

	if(ismob(loc))
		var/mob/M = loc
		M.drop_item_ground(src, TRUE)
	else
		remove_item_from_storage(get_turf(src))

	//Reason behind why it's not QDEL_LIST: works badly with lazy removal in Destroy() of item_action
	for(var/i in actions)
		qdel(i)

	QDEL_NULL(item_pixel_shift)

	return ..()


/obj/item/proc/check_allowed_items(atom/target, not_inside, target_self)
	if(((src in target) && !target_self) || (!isturf(target.loc) && !isturf(target) && not_inside))
		return FALSE
	else
		return TRUE

/obj/item/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc && !QDELETED(src))
		qdel(src)


/obj/item/examine(mob/user)
	var/size
	switch(src.w_class)
		if(WEIGHT_CLASS_TINY)
			size = "tiny"
		if(WEIGHT_CLASS_SMALL)
			size = "small"
		if(WEIGHT_CLASS_NORMAL)
			size = "normal-sized"
		if(WEIGHT_CLASS_BULKY)
			size = "bulky"
		if(WEIGHT_CLASS_HUGE)
			size = "huge"
		if(WEIGHT_CLASS_GIGANTIC)
			size = "gigantic"

	var/material_string = item_string_material(user)

	. = ..(user, "", "It is a [size] item. [material_string]")

	if(user.research_scanner) //Mob has a research scanner active.
		var/msg = "*--------* <BR>"

		if(origin_tech)
			msg += "<span class='notice'>Testing potentials:</span><BR>"
			var/list/techlvls = params2list(origin_tech)
			for(var/T in techlvls) //This needs to use the better names.
				msg += "Tech: [CallTechName(T)] | Magnitude: [techlvls[T]] <BR>"
		else
			msg += "<span class='danger'>No tech origins detected.</span><BR>"


		if(length(materials))
			msg += "<span class='notice'>Extractable materials:<BR>"
			for(var/mat in materials)
				msg += "[CallMaterialName(mat)]<BR>" //Capitize first word, remove the "$"
		else
			msg += "<span class='danger'>No extractable materials detected.</span><BR>"
		msg += "*--------*"
		. += msg

	if(isclocker(user) && enchant_type)
		if(enchant_type == CASTING_SPELL)
			. += "<span class='notice'>The last spell hasn't expired yet!</span><BR>"
		for(var/datum/spell_enchant/S in enchants)
			if(S.enchantment == enchant_type)
				. += "<span class='notice'>It has a sealed spell \"[S.name]\" inside.</span><BR>"
				break


/obj/item/burn()
	if(!QDELETED(src))
		var/turf/T = get_turf(src)
		var/obj/effect/decal/cleanable/ash/A = new(T)
		A.desc += "\nLooks like this used to be \an [name] some time ago."
		..()


/obj/item/acid_melt()
	if(!QDELETED(src))
		var/turf/T = get_turf(src)
		var/obj/effect/decal/cleanable/molten_object/MO = new(T)
		MO.pixel_x = rand(-16,16)
		MO.pixel_y = rand(-16,16)
		MO.desc = "Looks like this was \an [src] some time ago."
		..()


/obj/item/proc/afterattack(atom/target, mob/user, proximity, params)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, proximity, params)


/obj/item/attack_hand(mob/user, pickupfireoverride = FALSE)
	. = ..()
	if(.)
		return TRUE

	if(!user)
		return

	if((resistance_flags & ON_FIRE) && !pickupfireoverride)
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if(H.gloves && (H.gloves.max_heat_protection_temperature > 360))
				extinguish()
				to_chat(user, span_notice("You put out the fire on [src]."))
			else
				to_chat(user, span_warning("You burn your hand on [src]!"))
				H.apply_damage(5, BURN, def_zone = H.hand ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)	// 5 burn damage
				return
		else
			extinguish()

	if(acid_level > 20 && !ismob(loc))	// so we can still remove the clothes on us that have acid.
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if(!H.gloves || (!(H.gloves.resistance_flags & (UNACIDABLE|ACID_PROOF))))
				to_chat(user, span_warning("The acid on [src] burns your hand!"))
				H.apply_damage(5, BURN, def_zone = H.hand ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)	// 5 burn damage

	if(throwing)
		throwing.finalize()

	//if(anchored)
	//	return

	if(loc == user)
		if(!allow_attack_hand_drop(user))
			return

		// inventory unequip delay
		if(equip_delay_self > 0 && !user.is_general_slot(user.get_slot_by_item(src)))
			user.visible_message(
				span_notice("[user] начинает снимать [name]..."),
				span_notice("Вы начинаете снимать [name]..."),
			)
			if(!do_after(user, equip_delay_self, user, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_warning("Снятие [name] было прервано!")))
				return

		if(!user.temporarily_remove_item_from_inventory(src, silent = FALSE))
			return

	else if(isliving(loc))
		return

	. = pickup(user)

	if(. && !user.put_in_active_hand(src, ignore_anim = FALSE))
		user.drop_item_ground(src)
		return FALSE

	add_fingerprint(user)


/**
 * If we want to stop manual unequipping of item by hands, but only for user himself (almost NODROP)
 */
/obj/item/proc/allow_attack_hand_drop(mob/user)
	return TRUE


/**
 * If xenos can manipulate with this item.
 */
/obj/item/proc/allowed_for_alien()
	return FALSE


/obj/item/attack_alien(mob/user)
	var/mob/living/carbon/alien/A = user

	if(!A.has_fine_manipulation)
		to_chat(user, span_warning("Your claws aren't capable of such fine manipulation!"))
		return

	if(!allowed_for_alien())
		to_chat(user, span_warning("Looks like [src] has no use for me!"))
		return

	attack_hand(A)


/obj/item/attack_ai(mob/user as mob)
	if(istype(src.loc, /obj/item/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!isrobot(user))
			return
		var/mob/living/silicon/robot/R = user
		if(!R.low_power_mode) //can't equip modules with an empty cell.
			R.activate_module(src)
			R.hud_used.update_robot_modules_display()


// Due to storage type consolidation this should get used more now.
// I have cleaned it up a little, but it could probably use more.  -Sayu
/obj/item/attackby(obj/item/I, mob/user, params)
	if(isstorage(I))
		var/obj/item/storage/storage = I
		if(!storage.use_to_pickup)
			return ..()
		if(storage.pickup_all_on_tile) //Mode is set to collect all items on a tile and we clicked on a valid one.
			if(!isturf(loc))
				return ..()
			var/success = FALSE
			var/failure = FALSE
			for(var/obj/item/item as anything in loc)
				if(!storage.can_be_inserted(item, stop_messages = TRUE))
					failure = TRUE
					continue
				success = TRUE
				item.do_pickup_animation(user)
				storage.handle_item_insertion(item, prevent_warning = TRUE)
			if(success && !failure)
				playsound(loc, 'sound/items/handling/generic_pickup3.ogg', PICKUP_SOUND_VOLUME, channel = CHANNEL_INTERACTION_SOUNDS, ignore_walls = FALSE)
				to_chat(user, span_notice("You put everything in [storage]."))
				return ATTACK_CHAIN_BLOCKED_ALL
			if(success)
				playsound(loc, 'sound/items/handling/generic_pickup3.ogg', PICKUP_SOUND_VOLUME, channel = CHANNEL_INTERACTION_SOUNDS, ignore_walls = FALSE)
				to_chat(user, span_notice("You put some things in [storage]."))
				return ATTACK_CHAIN_BLOCKED_ALL
			to_chat(user, span_notice("You fail to pick up anything with [storage]."))
			return ATTACK_CHAIN_PROCEED

		if(storage.can_be_inserted(src))
			I.do_pickup_animation(user)
			storage.handle_item_insertion(src)
			return ATTACK_CHAIN_BLOCKED_ALL

		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/stack/tape_roll))
		if(isstorage(src)) //Don't tape the bag if we can put the duct tape inside it instead
			var/obj/item/storage/bag = src
			if(bag.can_be_inserted(I))
				return ..()
		var/obj/item/stack/tape_roll/tape = I
		var/list/clickparams = params2list(params)
		var/x_offset = text2num(clickparams["icon-x"])
		var/y_offset = text2num(clickparams["icon-y"])
		add_fingerprint(user)
		if(GetComponent(/datum/component/ducttape))
			to_chat(user, span_notice("[src] already has some tape attached!"))
			return ATTACK_CHAIN_PROCEED
		if(!tape.use(1))
			to_chat(user, span_notice("You don't have enough tape to do that!"))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You apply some tape to [src]."))
		AddComponent(/datum/component/ducttape, x_offset, y_offset)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/proc/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/signal_result = (SEND_SIGNAL(src, COMSIG_ITEM_HIT_REACT, owner, hitby, damage, attack_type) & COMPONENT_BLOCK_SUCCESSFUL) + prob(final_block_chance)
	if(signal_result != 0)
		owner.visible_message(span_danger("[owner] blocks [attack_text] with [src]!"))
		return signal_result
	return FALSE


// Generic use proc. Depending on the item, it uses up fuel, charges, sheets, etc.
// Returns TRUE on success, FALSE on failure.
/obj/item/proc/use(used)
	return !used


//Generic refill proc. Transfers something (e.g. fuel, charge) from an atom to our tool. returns TRUE if it was successful, FALSE otherwise
//Not sure if there should be an argument that indicates what exactly is being refilled
/obj/item/proc/refill(mob/user, atom/A, amount)
	return FALSE


/obj/item/proc/talk_into(mob/M, var/text, var/channel=null)
	return


/**
 * When item is officially left user
 */
/obj/item/proc/dropped(mob/user, slot, silent = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	// Remove any item actions we temporary gave out
	for(var/datum/action/action_item_has as anything in actions)
		action_item_has.Remove(user)

	if((item_flags & DROPDEL) && !QDELETED(src))
		qdel(src)

	item_flags &= ~IN_INVENTORY
	mouse_opacity = initial(mouse_opacity)
	remove_outline()

	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED, user, slot)
	if(!silent && !(item_flags & ABSTRACT) && drop_sound)
		var/chosen_sound = drop_sound
		if(islist(drop_sound) && length(drop_sound))
			chosen_sound = pick(drop_sound)
		playsound(src, chosen_sound, DROP_SOUND_VOLUME, channel = CHANNEL_INTERACTION_SOUNDS, ignore_walls = FALSE)
	return TRUE


/**
 * Called just as an item is picked up (loc is not yet changed)
 */
/obj/item/proc/pickup(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ITEM_PICKUP, user)

	item_flags |= IN_INVENTORY

	return TRUE


/**
 * Called when this item is removed from a storage item, which is passed on as S.
 * The loc variable is already set to the new destination before this is called.
 */
/obj/item/proc/on_exit_storage(obj/item/storage/S as obj)
	item_flags &= ~IN_STORAGE

	do_drop_animation(S)


/**
 * Called when this item is added into a storage item, which is passed on as S.
 * The loc variable is already set to the storage item.
 */
/obj/item/proc/on_enter_storage(obj/item/storage/S as obj)
	item_flags |= IN_STORAGE


/**
  * Called to check if this item can be put into a storage item.
  *
  * Return `FALSE` if `src` can't be inserted, and `TRUE` if it can.
  * Arguments:
  * * S - The [/obj/item/storage] that `src` is being inserted into.
  * * user - The mob trying to insert the item.
  */
/obj/item/proc/can_enter_storage(obj/item/storage/S, mob/user)
	return TRUE


/**
 * Called when "found" in pockets and storage items. Returns 1 if the search should end.
 */
/obj/item/proc/on_found(mob/finder as mob)
	return


/**
 * Called when the giver gives it to the receiver.
 */
/obj/item/proc/on_give(mob/living/carbon/giver, mob/living/carbon/receiver)
	return


/**
 * Called after an item is placed in an equipment slot.
 * Note that hands count as slots.
 *
 * Arguments:
 * * 'user' is mob that equipped it
 * * 'slot' uses the slot_X defines found in setup.dm for items that can be placed in multiple slots
 * * 'initial' is used to indicate whether or not this is the initial equipment (job datums etc) or just a player doing it
 */
/obj/item/proc/equipped(mob/user, slot, initial = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	// Give out actions our item has to people who equip it.
	for(var/datum/action/action_item_has as anything in actions)
		give_item_action(slot, user, action_item_has)

	mouse_opacity = MOUSE_OPACITY_OPAQUE
	item_flags |= IN_INVENTORY

	if(!initial && !(item_flags & ABSTRACT))
		if(equip_sound && !user.is_general_slot(slot))
			var/chosen_sound = equip_sound
			if(islist(equip_sound) && length(equip_sound))
				chosen_sound = pick(equip_sound)
			playsound(src, chosen_sound, EQUIP_SOUND_VOLUME, channel = CHANNEL_INTERACTION_SOUNDS, ignore_walls = FALSE)
		else if(slot & ITEM_SLOT_POCKETS)
			playsound(src, 'sound/items/handling/generic_equip3.ogg', EQUIP_SOUND_VOLUME, channel = CHANNEL_INTERACTION_SOUNDS, ignore_walls = FALSE)
		else if(pickup_sound && (slot & ITEM_SLOT_HANDS))
			var/chosen_sound = pickup_sound
			if(islist(pickup_sound) && length(pickup_sound))
				chosen_sound = pick(pickup_sound)
			playsound(src, chosen_sound, PICKUP_SOUND_VOLUME, channel = CHANNEL_INTERACTION_SOUNDS, ignore_walls = FALSE)

	user.update_equipment_speed_mods()
	SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED, user, slot)
	return TRUE


/// Gives one of our item actions to a mob, when equipped to a certain slot
/obj/item/proc/give_item_action(slot, mob/user, datum/action/action)
	// Some items only give their actions buttons when in a specific slot.
	if(!item_action_slot_check(slot, user, action) || SEND_SIGNAL(src, COMSIG_ITEM_UI_ACTION_SLOT_CHECKED, slot, user, action) & COMPONENT_ITEM_ACTION_SLOT_INVALID)
		// There is a chance we still have our item action currently,
		// and are moving it from a "valid slot" to an "invalid slot".
		// So call Remove() here regardless, even if excessive.
		action.Remove(user)
		return
	action.Grant(user)


/**
 * Some items only give their actions buttons when in a specific slot.
 */
/obj/item/proc/item_action_slot_check(slot, mob/user, datum/action/action)
	//these aren't true slots, so avoid granting actions there
	if(slot & (ITEM_SLOT_BACKPACK|ITEM_SLOT_LEGCUFFED|ITEM_SLOT_HANDCUFFED))
		return FALSE
	return TRUE


/**
 * Returns `TRUE` if the item is equipped by a mob, `FALSE` otherwise.
 * This might need some error trapping, not sure if get_equipped_items() is safe for non-human mobs.
 */
/obj/item/proc/is_equipped(include_pockets = FALSE, include_hands = FALSE)
	if(!ismob(loc))
		return FALSE

	var/mob/M = loc
	if(src in M.get_equipped_items(include_pockets, include_hands))
		return TRUE
	else
		return FALSE


/**
 * This proc is called whenever mob's client presses 'drop_held_object' hotkey
 * Not for robots since they have their own key in [keybindinds/robot.dm]
 * You can easily overriride it for different behavior on other items.
 */
/obj/item/proc/run_drop_held_item(mob/user)
	user.drop_from_active_hand()


/**
* Puts item into best inventory slot.
* If all slots are filled, item attempts to move in storage: container in offhand, belt, backpack.
* Proc is a real action after mob's client quick_equip hotkey is pressed. You can override it for diferent behavior.
*
* Arguments:
* * 'force' - set to `TRUE` if you want to ignore equip delay and clothing obscuration.
* * 'drop_on_fail' - set to `TRUE` if item should be dropped on equip fail.
* * 'qdel_on_fail' - set to `TRUE` if item should be deleted on equip fail.
* * 'silent' - set to `TRUE` if you want no warning messages on fail.
*/
/obj/item/proc/equip_to_best_slot(mob/user, force = FALSE, drop_on_fail = FALSE, qdel_on_fail = FALSE, silent = FALSE)

	if(user.equip_to_appropriate_slot(src, force, silent = TRUE))
		return TRUE

	if(equip_delay_self > 0)
		if(!silent)
			to_chat(user, span_warning("Вы должны экипировать [name] вручную!"))
		return FALSE

	//If storage is active - insert there
	if(user.s_active && user.s_active.can_be_inserted(src, TRUE))
		user.s_active.handle_item_insertion(src)
		return TRUE

	//Checking for storage item in offhand, then belt, then backpack
	var/list/possible = list( \
		user.get_inactive_hand(), \
		user.get_item_by_slot(ITEM_SLOT_BELT), \
		user.get_item_by_slot(ITEM_SLOT_BACK) \
	)

	for(var/obj/item/storage/container in possible)
		if(!container)
			continue
		if(container.can_be_inserted(src, TRUE))
			return container.handle_item_insertion(src)

	var/our_name = name

	if(drop_on_fail)
		if(src in user.get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
			user.drop_item_ground(src)
		else
			forceMove(drop_location())

	else if(qdel_on_fail)
		if(src in user.get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
			user.temporarily_remove_item_from_inventory(src, force = TRUE)
		qdel(src)

	if(!silent)
		to_chat(user, span_warning("Вы не можете надеть [our_name]!"))

	return FALSE


/**
 * Additional can equip checks when equipping is done by the user, and not by the code: [/mob/verb/quick_equip]
 */
/obj/item/proc/user_can_equip(mob/user, silent = FALSE)
	// if an item is already on user you cannot reequip it anywhere if it has NODROP trait
	if(loc == user && HAS_TRAIT(src, TRAIT_NODROP))
		if(!silent)
			to_chat(user, span_warning("Неведомая сила не позволяет Вам надеть [name]."))
		return FALSE
	return TRUE


/**
 * Mob 'M' is attempting to equip this item into the slot passed through as 'slot'. Return `TRUE` if it can do this and `FALSE` if it can't.
 * IF this is being done by a mob other than M, it will include the mob equipper, who is trying to equip the item to mob M. equipper will be null otherwise.
 * If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
 *
 * Arguments:
 * * 'disable_warning' set to `TRUE` if you wish no text outputs
 * * 'slot' is the slot we are trying to equip to
 * * 'bypass_equip_delay_self' for whether we want to bypass the equip delay
 * * 'bypass_obscured' for whether we want to ignore clothing obscuration
 * * 'bypass_incapacitated' wheter we are ignoring user's incapacitated status (uded only for hands currently)
 */
/obj/item/proc/mob_can_equip(mob/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE, bypass_incapacitated = FALSE)
	return M.can_equip(src, slot, disable_warning, bypass_equip_delay_self, bypass_obscured, bypass_incapacitated)


/obj/item/verb/verb_pickup()
	set src in oview(1)
	set name = "Pick up"

	if(usr.incapacitated() || !isturf(loc) || !Adjacent(usr))
		return
	if(!iscarbon(usr))
		to_chat(usr, span_warning("You can't pick things up!"))
		return
	usr.UnarmedAttack(src)


/**
 * This proc is executed when someone clicks the on-screen UI button.
 * The default action is attack_self().
 * Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
 */
/obj/item/proc/ui_action_click(mob/user, datum/action/action, leftclick)
	if(SEND_SIGNAL(src, COMSIG_ITEM_UI_ACTION_CLICK, user, action, leftclick) & COMPONENT_ACTION_HANDLED)
		return
	attack_self(user)


/**
 * This proc determines if and at what% an object will reflect energy projectiles if it's in l_hand,r_hand or wear_suit
 */
/obj/item/proc/IsReflect(def_zone)
	return FALSE


/obj/item/proc/get_loc_turf()
	var/atom/L = loc
	while(L && !istype(L, /turf/))
		L = L.loc
	return loc


/obj/item/proc/eyestab(mob/living/carbon/human/target, mob/living/user)
	. = ATTACK_CHAIN_PROCEED

	if(isalien(target) || isslime(target))//Aliens don't have eyes. slimes also don't have eyes!
		to_chat(user, span_warning("You cannot locate any eyes on this creature!"))
		return .

	var/target_is_human = ishuman(target)

	if(target_is_human && \
		(target.head && target.head.flags_cover & HEADCOVERSEYES) || \
		(target.wear_mask && target.wear_mask.flags_cover & MASKCOVERSEYES) || \
		(target.glasses && target.glasses.flags_cover & GLASSESCOVERSEYES))
		// you can't stab someone in the eyes wearing a mask!
		to_chat(user, span_danger("You're going to need to remove that mask/helmet/glasses first!"))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	if(!iscarbon(user))
		target.LAssailant = null
	else
		target.LAssailant = user

	add_fingerprint(user)
	playsound(loc, hitsound, 30, TRUE, -1)
	user.do_attack_animation(target)

	if(target != user)
		target.visible_message(
			span_danger("[user] has stabbed [target] in the eye with [src]!"),
			span_userdanger("[user] stabs you in the eye with [src]!"),
		)
	else
		user.visible_message(
			span_danger("[user] has stabbed [user.p_them()]self in the eyes with [src]!"),
			span_userdanger("You stab yourself in the eyes with [src]!"),
		)

	add_attack_logs(user, target, "Eye-stabbed with [src] ([uppertext(user.a_intent)])")

	if(target_is_human)
		var/obj/item/organ/internal/eyes/eyes = target.get_int_organ(/obj/item/organ/internal/eyes)
		if(!eyes) // should still get stabbed in the head
			target.apply_damage(rand(10, 14), def_zone = BODY_ZONE_HEAD)
			return .

		eyes.internal_receive_damage(rand(3, 4), silent = TRUE)

		if(eyes.damage >= eyes.min_bruised_damage)
			if(target.stat != DEAD && !eyes.is_robotic())	//robot eyes bleeding might be a bit silly
				to_chat(target, span_danger("Your eyes start to bleed profusely!"))
			if(prob(50))
				if(target.stat != DEAD)
					to_chat(target, span_danger("You drop what you're holding and clutch at your eyes!"))
				target.AdjustEyeBlurry(20 SECONDS)
				target.Paralyse(2 SECONDS)
			if(eyes.damage >= eyes.min_broken_damage && target.stat != DEAD)
				to_chat(target, span_danger("You go blind!"))

		target.apply_damage(7, def_zone = BODY_ZONE_HEAD)
		target.AdjustEyeBlurry(rand(6 SECONDS, 8 SECONDS))

	else
		target.apply_damage(7)


/obj/item/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FOUR)
		throw_at(S, 14, 3, spin = 0)
	else
		return


/obj/item/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(QDELETED(hit_atom))
		return

	SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, throwingdatum)

	var/itempush = TRUE
	if(w_class < WEIGHT_CLASS_BULKY)
		itempush = FALSE // too light to push anything

	var/is_hot = is_hot(src)
	var/volume = get_volume_by_throwforce_and_or_w_class()
	var/impact_throwforce = throwforce

	. = hit_atom.hitby(src, FALSE, itempush, throwingdatum = throwingdatum)

	if(isliving(hit_atom)) //Living mobs handle hit sounds differently.
		var/mob/living/living = hit_atom
		var/item_catched = FALSE
		if(. && living.is_in_hands(src))
			item_catched = TRUE

		if(is_hot && !item_catched)
			living.IgniteMob()

		if(impact_throwforce > 0 && !item_catched)
			if(mob_throw_hit_sound)
				playsound(living, mob_throw_hit_sound, volume, TRUE, -1)
			else if(hitsound)
				playsound(living, hitsound, volume, TRUE, -1)
			else
				playsound(living, 'sound/weapons/genhit.ogg', volume, TRUE, -1)
		else
			playsound(living, 'sound/weapons/throwtap.ogg', volume, TRUE, -1)

	else
		playsound(src, drop_sound, YEET_SOUND_VOLUME, ignore_walls = FALSE)


/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force, dodgeable)
	thrownby = thrower?.UID()
	callback = CALLBACK(src, PROC_REF(after_throw), callback) //replace their callback with our own
	. = ..(target, range, speed, thrower, spin, diagonals_first, callback, force, dodgeable)


/obj/item/proc/after_throw(datum/callback/callback)
	if(callback) //call the original callback
		. = callback.Invoke()
	throw_speed = initial(throw_speed) //explosions change this.
	item_flags &= ~IN_INVENTORY


/obj/item/proc/pwr_drain()
	return FALSE // Process Kill


/obj/item/proc/remove_item_from_storage(atom/newLoc) //please use this if you're going to snowflake an item out of a obj/item/storage
	if(!newLoc)
		return FALSE
	if(isstorage(loc))
		var/obj/item/storage/S = loc
		S.remove_from_storage(src,newLoc)
		return TRUE
	return FALSE


/obj/item/proc/wash(mob/user, atom/source)
	if(item_flags & ABSTRACT) //Abstract items like grabs won't wash. No-drop items will though because it's still technically an item in your hand.
		return
	to_chat(user, "<span class='notice'>You start washing [src]...</span>")
	if(!do_after(user, 4 SECONDS, source))
		return
	clean_blood()
	acid_level = 0
	user.visible_message("<span class='notice'>[user] washes [src] using [source].</span>", \
						"<span class='notice'>You wash [src] using [source].</span>")
	return TRUE


/// Returns an effectiveness of an item as a crunch, which allow mobs to stand if they are missing a leg/foot?
/obj/item/proc/is_crutch()
	return 0


// Return true if you don't want regular throw handling
/obj/item/proc/override_throw(mob/user, atom/target)
	return FALSE


/obj/item/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	return SEND_SIGNAL(src, COMSIG_ATOM_HITBY, AM, skipcatch, hitpush, blocked, throwingdatum)


/obj/item/attack_animal(mob/living/simple_animal/M)
	if(!(obj_flags & IGNORE_HITS))
		return ..()
	return FALSE


/obj/item/mech_melee_attack(obj/mecha/M)
	return FALSE


/obj/item/proc/openTip(location, control, params, user)
	openToolTip(user, src, params, title = name, content = "[desc]", theme = "")


/obj/item/MouseEntered(location, control, params)
	if(item_flags & (IN_INVENTORY|IN_STORAGE))
		var/timedelay = 8
		var/mob/user = usr
		tip_timer = addtimer(CALLBACK(src, PROC_REF(openTip), location, control, params, user), timedelay, TIMER_STOPPABLE)
		if(QDELETED(src))
			return
		var/mob/living/L = user
		if(!(user.client.prefs.toggles2 & PREFTOGGLE_2_SEE_ITEM_OUTLINES))
			return
		if(istype(L) && L.incapacitated())
			apply_outline(L, COLOR_RED_GRAY) //if they're dead or handcuffed, let's show the outline as red to indicate that they can't interact with that right now
		else
			apply_outline(L) //if the player's alive and well we send the command with no color set, so it uses the theme's color


/obj/item/MouseExited()
	deltimer(tip_timer) //delete any in-progress timer if the mouse is moved off the item before it finishes
	closeToolTip(usr)
	remove_outline()


/obj/item/MouseDrop_T(atom/dropping, mob/user, params)
	if(!user || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || src == dropping)
		return FALSE

	if(loc && dropping.loc == loc && isstorage(loc) && loc.Adjacent(user)) // Are we trying to swap two items in the storage?
		var/obj/item/storage/S = loc
		S.swap_items(src, dropping, user)
		return TRUE
	remove_outline() //get rid of the hover effect in case the mouse exit isn't called if someone drags and drops an item and somthing goes wrong


/obj/item/proc/apply_outline(mob/user, outline_color = null)
	if(!(item_flags & (IN_INVENTORY|IN_STORAGE)) || QDELETED(src) || isobserver(user)) //cancel if the item isn't in an inventory, is being deleted, or if the person hovering is a ghost (so that people spectating you don't randomly make your items glow)
		return
	var/theme = lowertext(user.client.prefs.UI_style)
	if(!outline_color) //if we weren't provided with a color, take the theme's color
		switch(theme) //yeah it kinda has to be this way
			if("midnight")
				outline_color = COLOR_THEME_MIDNIGHT
			if("plasmafire")
				outline_color = COLOR_THEME_PLASMAFIRE
			if("retro")
				outline_color = COLOR_THEME_RETRO //just as garish as the rest of this theme
			if("slimecore")
				outline_color = COLOR_THEME_SLIMECORE
			if("operative")
				outline_color = COLOR_THEME_OPERATIVE
			if("clockwork")
				outline_color = COLOR_THEME_CLOCKWORK //if you want free gbp go fix the fact that clockwork's tooltip css is glass'
			if("glass")
				outline_color = COLOR_THEME_GLASS
			else //this should never happen, hopefully
				outline_color = COLOR_WHITE
	if(color)
		outline_color = COLOR_WHITE //if the item is recolored then the outline will be too, let's make the outline white so it becomes the same color instead of some ugly mix of the theme and the tint
	if(outline_filter)
		filters -= outline_filter
	outline_filter = filter(type = "outline", size = 1, color = outline_color)
	filters += outline_filter


/obj/item/proc/remove_outline()
	if(outline_filter)
		filters -= outline_filter
		outline_filter = null


// Returns a numeric value for sorting items used as parts in machines, so they can be replaced by the rped
/obj/item/proc/get_part_rating()
	return 0


/obj/item/proc/update_equipped_item(update_buttons = TRUE, update_speedmods = TRUE)
	if(!ismob(loc) || QDELETED(src) || QDELETED(loc))
		return

	var/mob/owner = loc
	var/slot = owner.get_slot_by_item(src)

	switch(slot)
		if(ITEM_SLOT_CLOTH_OUTER)
			owner.wear_suit_update(src)

		if(ITEM_SLOT_CLOTH_INNER)
			owner.update_inv_w_uniform()

		if(ITEM_SLOT_GLOVES)
			owner.update_inv_gloves()

		if(ITEM_SLOT_NECK)
			owner.update_inv_neck()

		if(ITEM_SLOT_EYES)
			owner.wear_glasses_update(src)

		if(ITEM_SLOT_HEAD)
			owner.update_head(src)

		if(ITEM_SLOT_EAR_LEFT, ITEM_SLOT_EAR_RIGHT)
			owner.update_inv_ears()

		if(ITEM_SLOT_FEET)
			owner.update_inv_shoes()

		if(ITEM_SLOT_BELT)
			owner.update_inv_belt()

		if(ITEM_SLOT_MASK)
			owner.wear_mask_update(src)

		if(ITEM_SLOT_ID)
			if(ishuman(owner))
				var/mob/living/carbon/human/h_owner = owner
				h_owner.sec_hud_set_ID()
			owner.update_inv_wear_id()

		if(ITEM_SLOT_PDA)
			owner.update_inv_wear_pda()

		if(ITEM_SLOT_POCKET_LEFT, ITEM_SLOT_POCKET_RIGHT)
			owner.update_inv_pockets()

		if(ITEM_SLOT_SUITSTORE)
			owner.update_inv_s_store()

		if(ITEM_SLOT_BACK)
			owner.update_inv_back()

		if(ITEM_SLOT_HAND_LEFT)
			owner.update_inv_l_hand()

		if(ITEM_SLOT_HAND_RIGHT)
			owner.update_inv_r_hand()

		if(ITEM_SLOT_HANDCUFFED)
			owner.update_inv_handcuffed()

		if(ITEM_SLOT_LEGCUFFED)
			owner.update_inv_legcuffed()

	if(update_speedmods)
		owner.update_equipment_speed_mods()

	if(update_buttons)
		for(var/datum/action/action as anything in actions)
			action.UpdateButtonIcon()


/obj/item/proc/update_materials_coeff(new_coeff)
	if(new_coeff <= 1)
		materials_coeff = new_coeff
	else
		materials_coeff = 1 / new_coeff
	for(var/material in materials)
		materials[material] *= materials_coeff


/obj/item/proc/deplete_spell()
	enchant_type = NO_SPELL
	var/enchant_action = locate(/datum/action/item_action/activate/enchant) in actions
	if(enchant_action)
		qdel(enchant_action)
	update_icon()


/obj/item/update_atom_colour()
	. = ..()
	update_equipped_item()


/obj/item/proc/add_tape()
	return


/obj/item/proc/remove_tape()
	return

/*
/obj/item/doMove(atom/destination)
	if(!ismob(loc))
		return ..()

	var/mob/user = loc
	user.drop_item_ground(src, force = TRUE)
	return ..()
*/

/**
 * Simple helper we need to call before putting any item in hands, to allow fancy animation.
 * Item will be forceMoved() to turf below its holder.
 */
/obj/item/proc/forceMove_turf()
	var/turf/newloc = get_turf(src)
	if(!newloc)
		CRASH("Item holder is not in turf contents.")
	forceMove(newloc)


/**
 * Proc that checks if item is on user
 */
/obj/item/proc/is_on_user(mob/living/user)
	return user = get(src, /mob/living)


/obj/item/proc/do_pickup_animation(atom/target)

	if(!CONFIG_GET(flag/item_animations_enabled))
		return

	if(!isturf(loc) || !target)
		return

	if(get_turf(src) == get_turf(target))	// No need for pickup animation if item is on user or on the same turf
		return

	var/image/transfer_animation = image(icon = src, loc = src.loc, layer = MOB_LAYER + 0.1)
	SET_PLANE(transfer_animation, GAME_PLANE, loc)
	transfer_animation.transform.Scale(0.75)
	transfer_animation.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	var/target_x = target.pixel_x
	var/target_y = target.pixel_y
	var/direction = get_dir(get_turf(src), target)

	if(direction & NORTH)
		target_y += 32
	else if(direction & SOUTH)
		target_y -= 32
	if(direction & EAST)
		target_x += 32
	else if(direction & WEST)
		target_x -= 32
	if(!direction)
		target_y += 10
		transfer_animation.pixel_x += 6 * (prob(50) ? 1 : -1)

	flick_overlay_view(transfer_animation, 4)
	var/matrix/animation_matrix = new(transfer_animation.transform)
	animation_matrix.Turn(pick(-30, 30))
	animation_matrix.Scale(0.65)

	animate(transfer_animation, alpha = 175, pixel_x = target_x, pixel_y = target_y, time = 3, transform = animation_matrix, easing = CUBIC_EASING)
	animate(alpha = 0, transform = matrix().Scale(0.7), time = 1)


/obj/item/proc/do_drop_animation(atom/moving_from)

	if(!CONFIG_GET(flag/item_animations_enabled))
		return

	if(!isturf(loc) || !istype(moving_from))
		return

	var/from_x = moving_from.pixel_x
	var/from_y = moving_from.pixel_y
	var/direction = get_dir(moving_from, get_turf(src))

	if(direction & NORTH)
		from_y -= 32
	else if(direction & SOUTH)
		from_y += 32
	if(direction & EAST)
		from_x -= 32
	else if(direction & WEST)
		from_x += 32
	if(!direction)
		from_y += 10
		from_x += 6 * (prob(50) ? 1 : -1) //6 to the right or left, helps break up the straight upward move

	//We're moving from these chords to our current ones
	var/old_x = pixel_x
	var/old_y = pixel_y
	var/old_alpha = alpha
	var/matrix/old_transform = transform
	var/matrix/animation_matrix = new(old_transform)
	animation_matrix.Turn(pick(-30, 30))
	animation_matrix.Scale(0.7) // Shrink to start, end up normal sized

	pixel_x = from_x
	pixel_y = from_y
	alpha = 0
	transform = animation_matrix

	// This is instant on byond's end, but to our clients this looks like a quick drop
	animate(src, alpha = old_alpha, pixel_x = old_x, pixel_y = old_y, transform = old_transform, time = 3, easing = CUBIC_EASING)


/// Default item sharpening effect.
/// Return `FALSE` to stop sharpening.
/obj/item/proc/sharpen_act(obj/item/whetstone/whetstone, mob/user)
	name = "[whetstone.prefix] [name]"
	force = clamp(force + whetstone.increment, 0, whetstone.max)
	throwforce = clamp(throwforce + whetstone.increment, 0, whetstone.max)
	set_sharpness(TRUE)
	return TRUE


/// Called on [/datum/element/openspace_item_click_handler/proc/on_afterattack]. Check the relative file for information.
/obj/item/proc/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	stack_trace("Undefined handle_openspace_click() behaviour. Ascertain the openspace_item_click_handler element has been attached to the right item and that its proc override doesn't call parent.")


/obj/item/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	return


/// Conditional proc that allows ventcrawling with an item, if it has trait TRAIT_VENTCRAWLER_ITEM_BASED.
/obj/item/proc/used_for_ventcrawling(mob/living/user, provide_feedback = TRUE)
	return FALSE

/obj/item/proc/canStrip(mob/stripper, mob/owner)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	return !HAS_TRAIT(src, TRAIT_NODROP) && !(item_flags & ABSTRACT)
