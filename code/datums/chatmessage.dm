/// How long the chat message's spawn-in animation will occur for
#define CHAT_MESSAGE_SPAWN_TIME		(0.2 SECONDS)
/// How long the chat message will exist prior to any exponential decay
#define CHAT_MESSAGE_LIFESPAN		(5 SECONDS)
/// How long the chat message's end of life fading animation will occur for
#define CHAT_MESSAGE_EOL_FADE		(0.7 SECONDS)
/// Grace period for fade before we actually delete the chat message
#define CHAT_MESSAGE_GRACE_PERIOD 	(0.2 SECONDS)
/// Factor of how much the message index (number of messages) will account to exponential decay
#define CHAT_MESSAGE_EXP_DECAY		0.7
/// Factor of how much height will account to exponential decay
#define CHAT_MESSAGE_HEIGHT_DECAY	0.9
/// Approximate height in pixels of an 'average' line, used for height decay
#define CHAT_MESSAGE_APPROX_LHEIGHT	11
/// Max width of chat message in pixels
#define CHAT_MESSAGE_WIDTH			112
/// Max length of chat message in characters
#define CHAT_MESSAGE_MAX_LENGTH		110
/// Maximum precision of float before rounding errors occur (in this context)
#define CHAT_LAYER_Z_STEP			0.0001
/// The number of z-layer 'slices' usable by the chat message layering
#define CHAT_LAYER_MAX_Z			(CHAT_LAYER_MAX - CHAT_LAYER) / CHAT_LAYER_Z_STEP
/// The dimensions of the chat message icons
#define CHAT_MESSAGE_ICON_SIZE 		9


/**
  * # Chat Message Overlay
  *
  * Datum for generating a message overlay on the map
  */
/datum/chatmessage
	/// The visual element of the chat messsage
	var/image/message
	/// The original source of this message
	var/atom/message_source
	/// Current turf this message registered on
	var/turf/message_turf
	/// The list of locs chained from message_source to the turf level
	/// We need to listen for possible Moved() on all of these locs and change message loc accordingly
	var/list/signal_targets
	/// The client who heard this message
	var/client/owned_by
	/// Contains the approximate amount of lines for height decay
	var/approx_lines
	/// The current index used for adjusting the layer of each sequential chat message such that recent messages will overlay older ones
	var/static/current_z_idx = 0
	/// When we started animating the message
	var/animate_start = 0
	/// Our animation lifespan, how long this message will last
	var/animate_lifespan = 0


/**
 * Constructs a chat message overlay
 *
 * Arguments:
 * * text - The text content of the overlay
 * * target - The target atom to display the overlay at
 * * owner - The mob that owns this overlay, only this mob will be able to view it
 * * extra_classes - Extra classes to apply to the span that holds the text
 * * lifespan - The lifespan of the message in deciseconds
 */
/datum/chatmessage/New(text, atom/target, mob/owner, list/extra_classes, lifespan = CHAT_MESSAGE_LIFESPAN)
	. = ..()
	if(!isatom(target) || isarea(target))
		CRASH("Invalid target given for chatmessage")
	if(QDELETED(owner) || !istype(owner) || !owner.client)
		stack_trace("/datum/chatmessage created with [isnull(owner) ? "null" : "invalid"] mob owner")
		qdel(src)
		return
	INVOKE_ASYNC(src, PROC_REF(generate_image), text, target, owner, extra_classes, lifespan)


/datum/chatmessage/Destroy()
	if(!QDELETED(owned_by))
		if(REALTIMEOFDAY < animate_start + animate_lifespan)
			stack_trace("Del'd before we finished fading, with [(animate_start + animate_lifespan) - REALTIMEOFDAY] time left")

		if(owned_by.seen_messages)
			LAZYREMOVEASSOC(owned_by.seen_messages, message_turf, src)
		owned_by.images.Remove(message)

	if(signal_targets)
		for(var/target in signal_targets)
			UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
			UnregisterSignal(target, COMSIG_MOVABLE_Z_CHANGED)
		signal_targets.Cut()
	owned_by = null
	message_source = null
	message_turf = null
	message = null
	return ..()


/**
  * Calls qdel on the chatmessage when its parent is deleted, used to register qdel signal
  */
/datum/chatmessage/proc/on_parent_qdel()
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)


/**
 * Generates a chat message image representation
 *
 * Arguments:
 * * text - The text content of the overlay
 * * target - The target atom to display the overlay at
 * * owner - The mob that owns this overlay, only this mob will be able to view it
 * * extra_classes - Extra classes to apply to the span that holds the text
 * * lifespan - The lifespan of the message in deciseconds
 */
/datum/chatmessage/proc/generate_image(text, atom/target, mob/owner, list/extra_classes, lifespan)
	// Register client who owns this message
	owned_by = owner.client
	RegisterSignal(owned_by, COMSIG_PARENT_QDELETING, PROC_REF(on_parent_qdel))

	// Remove spans in the message from things like the recorder
	var/static/regex/span_check = new(@"<\/?span[^>]*>", "gi")
	text = replacetext(text, span_check, "")

	// Clip message
	if(length_char(text) > CHAT_MESSAGE_MAX_LENGTH)
		text = copytext_char(text, 1, CHAT_MESSAGE_MAX_LENGTH + 1) + "..." // BYOND index moment

	// Get rid of any URL schemes that might cause BYOND to automatically wrap something in an anchor tag
	var/static/regex/url_scheme = new(@"[A-Za-z][A-Za-z0-9+-\.]*:\/\/", "g")
	text = replacetext(text, url_scheme, "")

	// Reject whitespace
	var/static/regex/whitespace = new(@"^\s*$")
	if(whitespace.Find(text))
		qdel(src)
		return

	var/list/prefixes
	var/chat_color_name_to_use

	/// Cached icons to show
	var/static/list/chat_icons

	// Append radio icon
	if(LAZYIN(extra_classes, "radio"))
		var/icon/radio_icon = LAZYACCESS(chat_icons, "radio")
		if(isnull(radio_icon))
			radio_icon = icon('icons/effects/chat_icons.dmi', "radio")
			radio_icon.Scale(CHAT_MESSAGE_ICON_SIZE, CHAT_MESSAGE_ICON_SIZE)
			LAZYSET(chat_icons, "radio", radio_icon)
		LAZYADD(prefixes, "\icon[radio_icon]")

	// Append emote icon
	var/emote_message = LAZYIN(extra_classes, "emote")
	if(emote_message)
		var/icon/emote_icon = LAZYACCESS(chat_icons, "emote")
		if(isnull(emote_icon))
			emote_icon = icon('icons/effects/chat_icons.dmi', "emote")
			emote_icon.Scale(CHAT_MESSAGE_ICON_SIZE, CHAT_MESSAGE_ICON_SIZE)
			LAZYSET(chat_icons, "emote", emote_icon)
		LAZYADD(prefixes, "\icon[emote_icon]")
		// use face name for nonverbal messages
		chat_color_name_to_use = target.get_visible_name(add_id_name = FALSE)

	if(isnull(chat_color_name_to_use))
		chat_color_name_to_use = target.GetVoice()

	// Calculate target color if not already present
	if(!target.chat_color || target.chat_color_name != chat_color_name_to_use)
		target.chat_color = colorize_string(chat_color_name_to_use)
		target.chat_color_darkened = colorize_string(chat_color_name_to_use, 0.85, 0.85)
		target.chat_color_name = chat_color_name_to_use

	text = "[prefixes?.Join("&nbsp;")][text]"

	// We dim italicized text and emotes to make them more distinguishable from regular text
	var/tgt_color = emote_message || LAZYIN(extra_classes, "italics") ? target.chat_color_darkened : target.chat_color

	// Approximate text height
	var/complete_text = "<span style='color: [tgt_color]'><span class='center [extra_classes?.Join(" ")]'>[text]</span></span>"

	var/mheight
	WXH_TO_HEIGHT(owned_by.MeasureText(complete_text, null, CHAT_MESSAGE_WIDTH), mheight)

	if(!VERB_SHOULD_YIELD)
		return finish_image_generation(mheight, target, owner, complete_text, lifespan)

	var/datum/callback/our_callback = CALLBACK(src, PROC_REF(finish_image_generation), mheight, target, owner, complete_text, lifespan)
	SSrunechat.message_queue += our_callback


///finishes the image generation after the MeasureText() call in generate_image().
///necessary because after that call the proc can resume at the end of the tick and cause overtime.
/datum/chatmessage/proc/finish_image_generation(mheight, atom/target, mob/owner, complete_text, lifespan)
	message_source = target
	message_turf = isturf(target) ? target : get_turf(target)
	if(QDELETED(target) || !message_turf)
		qdel(src)
		return

	var/rough_time = REALTIMEOFDAY
	approx_lines = max(1, mheight / CHAT_MESSAGE_APPROX_LHEIGHT)
	var/starting_height = target.maptext_height

	// Translate any existing messages upwards, apply exponential decay factors to timers
	if(owned_by.seen_messages)
		var/idx = 1
		var/combined_height = approx_lines
		for(var/datum/chatmessage/m as anything in owned_by.seen_messages[message_turf])
			combined_height += m.approx_lines

			var/time_spent = rough_time - m.animate_start
			var/time_before_fade = m.animate_lifespan - CHAT_MESSAGE_EOL_FADE

			// When choosing to update the remaining time we have to be careful not to update the
			// scheduled time once the EOL has been executed.
			if(time_spent >= time_before_fade)
				if(m.message.pixel_y < starting_height)
					var/max_height = m.message.pixel_y + m.approx_lines * CHAT_MESSAGE_APPROX_LHEIGHT - starting_height
					if(max_height > 0)
						animate(m.message, pixel_y = m.message.pixel_y + max_height, time = CHAT_MESSAGE_SPAWN_TIME, flags = ANIMATION_PARALLEL)
				else if(mheight + starting_height >= m.message.pixel_y)
					animate(m.message, pixel_y = m.message.pixel_y + mheight, time = CHAT_MESSAGE_SPAWN_TIME, flags = ANIMATION_PARALLEL)
				continue

			var/remaining_time = time_before_fade * (CHAT_MESSAGE_EXP_DECAY ** idx++) * (CHAT_MESSAGE_HEIGHT_DECAY ** combined_height)
			// Ensure we don't accidentially spike alpha up or something silly like that
			m.message.alpha = m.get_current_alpha(time_spent)
			if(remaining_time > 0)
				// Stay faded in for a while, then
				animate(m.message, alpha = 255, remaining_time)
				// Fade out
				animate(alpha = 0, time = CHAT_MESSAGE_EOL_FADE)
				m.animate_lifespan = remaining_time + CHAT_MESSAGE_EOL_FADE
			else
				// Your time has come my son
				animate(alpha = 0, time = CHAT_MESSAGE_EOL_FADE)

			// We run this after the alpha animate, because we don't want to interrup it, but also don't want to block it by running first
			// Sooo instead we do this. bit messy but it fuckin works
			if(m.message.pixel_y < starting_height)
				var/max_height = m.message.pixel_y + m.approx_lines * CHAT_MESSAGE_APPROX_LHEIGHT - starting_height
				if(max_height > 0)
					animate(m.message, pixel_y = m.message.pixel_y + max_height, time = CHAT_MESSAGE_SPAWN_TIME, flags = ANIMATION_PARALLEL)
			else if(mheight + starting_height >= m.message.pixel_y)
				animate(m.message, pixel_y = m.message.pixel_y + mheight, time = CHAT_MESSAGE_SPAWN_TIME, flags = ANIMATION_PARALLEL)

	// Reset z index if relevant
	if(current_z_idx >= CHAT_LAYER_MAX_Z)
		current_z_idx = 0

	// Build message image
	message = image(loc = null, layer = CHAT_LAYER + CHAT_LAYER_Z_STEP * current_z_idx++)
	SET_PLANE_EXPLICIT(message, RUNECHAT_PLANE, message_turf)
	message.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA|KEEP_APART
	message.alpha = 0
	message.pixel_y = starting_height
	message.pixel_x = -target.base_pixel_x
	message.maptext_width = CHAT_MESSAGE_WIDTH
	message.maptext_height = mheight * 1.25 // We add extra because some characters are superscript, like actions
	message.maptext_x = (CHAT_MESSAGE_WIDTH - owner.bound_width) * -0.5
	message.maptext = MAPTEXT(complete_text)

	animate_start = rough_time
	animate_lifespan = lifespan

	if(ismovable(target))
		signal_targets = list()
		// message loc for movables is always set to the top-most /atom/movable sitting on the turf
		var/atom/movable/message_loc = target
		while(message_loc.loc && !isturf(message_loc.loc))
			message_loc = message_loc.loc
			signal_targets += message_loc
		message.loc = message_loc
		// we listen for Moved() on the target and every nested loc if the target is outside of the turf contents
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(adjust_message_loc))
		for(var/listening_target in signal_targets)
			RegisterSignal(listening_target, COMSIG_MOVABLE_MOVED, PROC_REF(adjust_message_loc))
			RegisterSignal(listening_target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(adjust_message_z))
	else
		// its always turf otherwise
		message.loc = message_turf

	// View the message
	LAZYADDASSOCLIST(owned_by.seen_messages, message_turf, src)
	owned_by.images |= message

	// Fade in
	animate(message, alpha = 255, time = CHAT_MESSAGE_SPAWN_TIME)
	// Stay faded in
	animate(alpha = 255, time = lifespan - CHAT_MESSAGE_SPAWN_TIME - CHAT_MESSAGE_EOL_FADE)
	// Fade out
	animate(alpha = 0, time = CHAT_MESSAGE_EOL_FADE)

	// Register with the runechat SS to handle destruction
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), lifespan + CHAT_MESSAGE_GRACE_PERIOD, TIMER_DELETE_ME, SSrunechat)


/// Returns the current alpha of the message based on the time spent
/datum/chatmessage/proc/get_current_alpha(time_spent)
	if(time_spent < CHAT_MESSAGE_SPAWN_TIME)
		return (time_spent / CHAT_MESSAGE_SPAWN_TIME) * 255

	var/time_before_fade = animate_lifespan - CHAT_MESSAGE_EOL_FADE
	if(time_spent <= time_before_fade)
		return 255

	return (1 - ((time_spent - time_before_fade) / CHAT_MESSAGE_EOL_FADE)) * 255


/datum/chatmessage/proc/adjust_message_z(datum/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	// Replanes the message if the user of the message changed z
	if(!same_z_layer)
		SET_PLANE_EXPLICIT(message, RUNECHAT_PLANE, new_turf)


/datum/chatmessage/proc/adjust_message_loc(atom/movable/signal_movable, atom/old_loc, movement_dir, forced)
	SIGNAL_HANDLER

	if(QDELETED(owned_by) || QDELETED(src) || QDELETED(message_source))
		return

	var/turf/new_turf = get_turf(message_source)
	// nullspace? we are done
	if(!new_turf)
		qdel(src)
		return

	// turf changed, re-register message to the new turf so they line up properly
	if(message_turf != new_turf)
		LAZYREMOVEASSOC(owned_by.seen_messages, message_turf, src)
		LAZYADDASSOCLIST(owned_by.seen_messages, new_turf, src)
		message_turf = new_turf

	// message_source moving from turf to another turf, skip next
	if(signal_movable == message_source && isturf(old_loc) && isturf(message_source.loc))
		return

	var/list/previous_signal_targets = signal_targets
	var/list/next_signal_targets = list()

	// message loc for movables is always set to the top-most /atom/movable sitting on the turf
	var/atom/movable/message_loc = message_source
	while(message_loc.loc && !isturf(message_loc.loc))
		message_loc = message_loc.loc
		next_signal_targets += message_loc
	message.loc = message_loc

	for(var/obsolete_target in previous_signal_targets - next_signal_targets)
		UnregisterSignal(obsolete_target, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(obsolete_target, COMSIG_MOVABLE_Z_CHANGED)

	// we listen for Moved() on every nested loc if the target is outside of the turf contents
	for(var/new_target in next_signal_targets - previous_signal_targets)
		RegisterSignal(new_target, COMSIG_MOVABLE_MOVED, PROC_REF(adjust_message_loc))
		RegisterSignal(new_target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(adjust_message_z))

	signal_targets = next_signal_targets


/**
 * Creates a message overlay at a defined location for a given speaker
 *
 * Arguments:
 * * speaker - The atom who is saying this message
 * * raw_message - The text content of the message
 * * spans - Additional classes to be added to the message
 */
/mob/proc/create_chat_message(atom/movable/speaker, raw_message, list/spans)
	if(!SStimer.can_fire || !SSrunechat.can_fire)
		return

	// Ensure the list we are using, if present, is a copy so we don't modify the list provided to us
	spans = spans ? spans.Copy() : null

	// Display visual above source
	new /datum/chatmessage(raw_message, speaker, src, spans)


/**
  * Proc to allow atoms to set their own runechat colour
  *
  * This is a proc designed to be overridden in places if you want a specific atom to use a specific runechat colour
  * Exampls include consoles using a colour based on their screen colour, and mobs using a colour based off of a customisation property
  *
  */
/atom/proc/get_runechat_color()
	return chat_color


// Tweak these defines to change the available color ranges
#define CM_COLOR_SAT_MIN 0.6
#define CM_COLOR_SAT_MAX 0.7
#define CM_COLOR_LUM_MIN 0.65
#define CM_COLOR_LUM_MAX 0.75


/**
 * Gets a color for a name, will return the same color for a given string consistently within a round.atom
 *
 * Note that this proc aims to produce pastel-ish colors using the HSL colorspace. These seem to be favorable for displaying on the map.
 *
 * Arguments:
 * * name - The name to generate a color for
 * * sat_shift - A value between 0 and 1 that will be multiplied against the saturation
 * * lum_shift - A value between 0 and 1 that will be multiplied against the luminescence
 */
/datum/chatmessage/proc/colorize_string(name, sat_shift = 1, lum_shift = 1)
	// seed to help randomness
	var/static/rseed = rand(1, 26)

	// get hsl using the selected 6 characters of the md5 hash
	var/hash = copytext(md5(name + GLOB.round_id), rseed, rseed + 6)
	var/h = hex2num(copytext(hash, 1, 3)) * (360 / 255)
	var/s = (hex2num(copytext(hash, 3, 5)) >> 2) * ((CM_COLOR_SAT_MAX - CM_COLOR_SAT_MIN) / 63) + CM_COLOR_SAT_MIN
	var/l = (hex2num(copytext(hash, 5, 7)) >> 2) * ((CM_COLOR_LUM_MAX - CM_COLOR_LUM_MIN) / 63) + CM_COLOR_LUM_MIN

	// adjust for shifts
	s *= clamp(sat_shift, 0, 1)
	l *= clamp(lum_shift, 0, 1)

	// convert to rgb
	var/h_int = round(h/60) // mapping each section of H to 60 degree sections
	var/c = (1 - abs(2 * l - 1)) * s
	var/x = c * (1 - abs((h / 60) % 2 - 1))
	var/m = l - c * 0.5
	x = (x + m) * 255
	c = (c + m) * 255
	m *= 255
	switch(h_int)
		if(0)
			return "#[num2hex(c, 2)][num2hex(x, 2)][num2hex(m, 2)]"
		if(1)
			return "#[num2hex(x, 2)][num2hex(c, 2)][num2hex(m, 2)]"
		if(2)
			return "#[num2hex(m, 2)][num2hex(c, 2)][num2hex(x, 2)]"
		if(3)
			return "#[num2hex(m, 2)][num2hex(x, 2)][num2hex(c, 2)]"
		if(4)
			return "#[num2hex(x, 2)][num2hex(m, 2)][num2hex(c, 2)]"
		if(5)
			return "#[num2hex(c, 2)][num2hex(m, 2)][num2hex(x, 2)]"


#undef CHAT_MESSAGE_SPAWN_TIME
#undef CHAT_MESSAGE_LIFESPAN
#undef CHAT_MESSAGE_EOL_FADE
#undef CHAT_MESSAGE_GRACE_PERIOD
#undef CHAT_MESSAGE_EXP_DECAY
#undef CHAT_MESSAGE_HEIGHT_DECAY
#undef CHAT_MESSAGE_APPROX_LHEIGHT
#undef CHAT_MESSAGE_WIDTH
#undef CHAT_MESSAGE_MAX_LENGTH
#undef CHAT_LAYER_Z_STEP
#undef CHAT_LAYER_MAX_Z
#undef CHAT_MESSAGE_ICON_SIZE
#undef CM_COLOR_LUM_MAX
#undef CM_COLOR_LUM_MIN
#undef CM_COLOR_SAT_MAX
#undef CM_COLOR_SAT_MIN

