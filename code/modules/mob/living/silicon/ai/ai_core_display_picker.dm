/**
 * AI Core Display Picker TGUI
 * Allows AIs to select core display options with search functionality
 */
/datum/ai_core_display_picker
	var/mob/living/silicon/ai/ai_user

/datum/ai_core_display_picker/New(mob/living/silicon/ai/user)
	ai_user = user

/datum/ai_core_display_picker/Destroy(force)
	ai_user = null
	return ..()

/datum/ai_core_display_picker/ui_status(mob/user, datum/ui_state/state)
	if(!ai_user || user != ai_user || ai_user.incapacitated())
		return UI_CLOSE
	return ..()

/datum/ai_core_display_picker/ui_state(mob/user)
	return GLOB.always_state

/datum/ai_core_display_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiCoreDisplayPicker")
		ui.open()

/datum/ai_core_display_picker/ui_close(mob/user)
	if(ai_user)
		ai_user.core_display_picker = null

/datum/ai_core_display_picker/ui_data(mob/user)
	var/list/data = list()

	// If no override is set, find the actual current display from the AI's icon state
	var/current_display = ai_user.display_icon_override
	if(!current_display)
		// Default to "Blue" if no override
		current_display = "ai"

	// Try to identify current display
	for(var/display_name, state in GLOB.ai_core_display_screens)
		if(state == current_display)
			current_display = display_name
			break

	data["current_display"] = current_display

	// Get icon for current display
	var/current_icon_state = GLOB.ai_core_display_screens[current_display]
	data["current_icon"] = list(
		"icon" = 'icons/mob/ai.dmi',
		"icon_state" = current_icon_state
	)

	var/list/options = list()

	for(var/option_name, icon_state in GLOB.ai_core_display_screens)
		var/list/option_data = list(
			"name" = option_name,
			"icon_state" = icon_state,
			"icon" = 'icons/mob/ai.dmi'
		)
		options += list(option_data)

	data["options"] = options

	return data

/datum/ai_core_display_picker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_option")
			var/chosen_option = params["option"]
			if(chosen_option in GLOB.ai_core_display_screens)
				ai_user.display_icon_override = chosen_option
				ai_user.set_core_display_icon(chosen_option)
				return TRUE

/mob/living/silicon/ai/proc/set_core_display_icon(input, client/C)
	portrait_appearance = null

	display_icon_override = resolve_ai_icon(input)

	update_appearance()

GLOBAL_ALIST_INIT(ai_core_display_screens, alist(
	"Portrait" = "ai-portrait",
	"Clown" = "ai-clown",
	"Monochrome" = "ai-mono",
	"Inverted" = "ai-u",
	"Firewall" = "ai-magma",
	"Green" = "ai-weird",
	"Red" = "ai-red",
	"Static" = "ai-static",
	"Text" = "ai-text",
	"Smiley" = "ai-smiley",
	"Matrix" = "ai-matrix",
	"Angry" = "ai-angryface",
	"Dorf" = "ai-dorf",
	"Bliss" = "ai-bliss",
	"Triumvirate" = "ai-triumvirate",
	"Triumvirate Static" = "ai-triumvirate-malf",
	"Red October" = "ai-redoctober",
	"Sparkles" = "ai-sparkles",
	"ANIMA" = "ai-anima",
	"President" = "ai-president",
	"NT" = "ai-nt",
	"NT2" = "ai-nanotrasen",
	"Rainbow" = "ai-rainbow",
	"Angel" = "ai-angel",
	"Heartline" = "ai-heartline",
	"Hades" = "ai-hades",
	"Helios" = "ai-helios",
	"Syndicat Meow" = "ai-syndicatmeow",
	"Too Deep" = "ai-toodeep",
	"Goon" = "ai-goon",
	"Murica" = "ai-murica",
	"Fuzzy" = "ai-fuzz",
	"Glitchman" = "ai-glitchman",
	"House" = "ai-house",
	"Database" = "ai-database",
	"Alien" = "ai-alien",
	"Cheese" = "ai-cheese",
	"Voiddonut" = "ai-voiddonut",
	"Bee" = "ai-bee",
	"Fox" = "ai-fox",
	"Tiger" = "ai-tiger",
	"Vox" = "ai-vox",
	"Liz" = "ai-liz",
	"Darkmatter" = "ai-darkmatter",
	"Nadburn" = "ai-nadburn",
	"Rainbowslime" = "ai-rainbowslime",
	"Borb" = "ai-borb",
	"Catamari" = "ai-catamari",
	"Hippy" = "ai-hippy",
	"Anonymous" = "ai-anon",
	"AMAI" = "ai-am",
	"HAL" = "ai-hal",
	"Banned" = "ai-banned",
	":thinking:" = "ai-:thinking:",
	"Malf" = "ai-malf",
	"Ravensdale" = "ravensdale-ai",
	"Gentoo" = "ai-gentoo",
	"Too deep" = "ai-too deep",
	"Random" = "ai-random",
	"Gondola" = "ai-gondola",
	"Hal 9000" = "ai-hal 9000",
	"Alffd" = "alffd-ai",
))
	/// A form of resolve_ai_icon that is guaranteed to never sleep.
/// Not always accurate, but always synchronous.
/proc/resolve_ai_icon_sync(input)
	SHOULD_NOT_SLEEP(TRUE)

	if(!input || !(input in GLOB.ai_core_display_screens))
		return "ai"
	else
		if(input == "Random")
			input = pick(GLOB.ai_core_display_screens - "Random")
		return GLOB.ai_core_display_screens[input]

/proc/resolve_ai_icon(input)
	if(input == "Portrait")
		var/datum/portrait_picker/tgui = new(usr)//create the datum
		tgui.ui_interact(usr)//datum has a tgui component, here we open the window
		return "ai-portrait" //just take this until they decide

	return resolve_ai_icon_sync(input)
