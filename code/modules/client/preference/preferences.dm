GLOBAL_LIST_EMPTY(preferences_datums)
GLOBAL_PROTECT(preferences_datums) // These feel like something that shouldnt be fucked with

GLOBAL_LIST_INIT(special_role_times, list( //minimum age (in days) for accounts to play these roles
	ROLE_PAI = 0,
	ROLE_THUNDERDOME = 0,
	ROLE_POSIBRAIN = 0,
	ROLE_GUARDIAN = 0,
	ROLE_TRAITOR = 7,
	ROLE_MALF_AI = 7,
	ROLE_THIEF = 7,
	ROLE_CHANGELING = 14,
	ROLE_SHADOWLING = 14,
	ROLE_WIZARD = 14,
	ROLE_REV = 14,
	ROLE_VAMPIRE = 14,
	ROLE_BLOB = 14,
	ROLE_REVENANT = 14,
	ROLE_OPERATIVE = 21,
	ROLE_CULTIST = 21,
	ROLE_CLOCKER = 21,
	ROLE_RAIDER = 21,
	ROLE_ALIEN = 21,
	ROLE_DEMON = 21,
	ROLE_SENTIENT = 21,
	ROLE_ELITE = 21,
// 	ROLE_GANG = 21,
	ROLE_BORER = 21,
	ROLE_NINJA = 21,
	ROLE_GSPIDER = 21,
	ROLE_ABDUCTOR = 30,
	ROLE_DEVIL = 14
))

/proc/player_old_enough_antag(client/C, role, req_job_rank)
	if(available_in_days_antag(C, role))
		return FALSE	//available_in_days>0 = still some days required = player not old enough
	if(role_available_in_playtime(C, role))
		return FALSE	//available_in_playtime>0 = still some more playtime required = they are not eligible
	if(!req_job_rank)
		return TRUE
	var/datum/job/job = SSjobs.GetJob(req_job_rank)
	if(!job)
		stack_trace("Invalid job title: [req_job_rank]")
		return FALSE
	if(job.available_in_playtime(C))
		return TRUE


/proc/available_in_days_antag(client/C, role)
	if(!C)
		return 0
	if(!role)
		return 0
	if(!CONFIG_GET(flag/use_age_restriction_for_antags))
		return 0
	if(!isnum(C.player_age))
		return 0 //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced
	var/minimal_player_age_antag = GLOB.special_role_times[num2text(role)]
	if(!isnum(minimal_player_age_antag))
		return 0

	return max(0, minimal_player_age_antag - C.player_age)

/proc/check_client_age(client/C, var/days) // If days isn't provided, returns the age of the client. If it is provided, it returns the days until the player_age is equal to or greater than the days variable
	if(!days)
		return C.player_age
	else
		return max(0, days - C.player_age)

#define MAX_SAVE_SLOTS 30 // Save slots for regular players
#define MAX_SAVE_SLOTS_MEMBER 30 // Save slots for BYOND members

#define TAB_CHAR 	0
#define TAB_GAME 	1
#define TAB_SPEC 	2
#define TAB_GEAR 	3
#define TAB_KEYS 	4
#define TAB_TOGGLES 5

/datum/preferences
	var/client/parent
	//doohickeys for savefiles
//	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
//	var/savefile_version = 0
	var/max_save_slots = MAX_SAVE_SLOTS
	var/max_gear_slots = 0

	//non-preference stuff
	var/warns = 0
	var/last_ip
	var/last_id

	//game-preferences
	var/lastchangelog = "1"				//Saved changlog timestamp (unix epoch) to detect if there was a change. Dont set this to 0 unless you want the last changelog date to be 4x longer than the expected lifespan of the universe.
	var/exp
	var/ooccolor = "#b82e00"
	var/list/be_special = list()				//Special role selection
	var/UI_style = "Midnight"
	var/toggles = TOGGLES_DEFAULT
	var/toggles2 = TOGGLES_2_DEFAULT // Created because 1 column has a bitflag limit of 24 (BYOND limitation not MySQL)
	var/sound = SOUND_DEFAULT
	var/UI_style_color = "#ffffff"
	var/UI_style_alpha = 255
	var/clientfps = 0
	var/atklog = ATKLOG_ALL
	var/fuid							// forum userid

	//character preferences
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we are a random name every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/spawnpoint = "Arrivals Shuttle" //where this character will spawn (0-2).
	var/b_type = "A+"					//blood type (not-chooseable)
	var/underwear = "Nude"					//underwear type
	var/underwear_color = "#ffffff"			//underwear color if underwear allows it
	var/undershirt = "Nude"					//undershirt type
	var/undershirt_color = "#ffffff"			//undershirt color if undershirt allows it
	var/socks = "Nude"					//socks type
	var/backbag = GBACKPACK				//backpack type
	var/ha_style = "None"				//Head accessory style
	var/hacc_colour = "#000000"			//Head accessory colour
	var/list/m_styles = list(
		"head" = "None",
		"body" = "None",
		"tail" = "None",
		"wing" = "None"
		)			//Marking styles.
	var/list/m_colours = list(
		"head" = "#000000",
		"body" = "#000000",
		"tail" = "#000000"
		)		//Marking colours.
	var/h_style = "Bald"				//Hair type
	var/h_colour = "#000000"			//Hair color
	var/h_sec_colour = "#000000"		//Secondary hair color
	var/h_grad_style = "None"
	var/h_grad_colour = "#000000"
	var/h_grad_alpha = 200
	var/h_grad_offset_x = 0
	var/h_grad_offset_y = 0
	var/f_style = "Shaved"				//Facial hair type
	var/f_colour = "#000000"			//Facial hair color
	var/f_sec_colour = "#000000"		//Secondary facial hair color
	var/s_tone = 0						//Skin tone
	var/s_colour = "#000000"			//Skin color
	var/e_colour = "#000000"			//Eye color
	var/alt_head = "None"				//Alt head style.
	var/species = SPECIES_HUMAN
	var/language = "None"		//Secondary language for choise.
	var/autohiss_mode = AUTOHISS_FULL	//Species autohiss level. OFF, BASIC, FULL.

	var/tts_seed = null

	var/custom_emotes_tmp = null

	/// Custom emote text ("name" = "emote text")
	var/list/custom_emotes = list()

	var/body_accessory = null

	var/speciesprefs = 0//I hate having to do this, I really do (Using this for oldvox code, making names universal I guess

		//Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null

		//Jobs, uses bitflags
	var/job_support_high = 0
	var/job_support_med = 0
	var/job_support_low = 0

	var/job_medsci_high = 0
	var/job_medsci_med = 0
	var/job_medsci_low = 0

	var/job_engsec_high = 0
	var/job_engsec_med = 0
	var/job_engsec_low = 0

	var/job_karma_high = 0
	var/job_karma_med = 0
	var/job_karma_low = 0

	//Special role pref
	var/uplink_pref = "pda"

	//Keeps track of preferrence for not getting any wanted jobs
	var/alternate_option = 2

	// maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()
	var/list/rlimb_data = list()

	var/list/player_alt_titles = new()		// the default name of a job like "Medical Doctor"
//	var/accent = "en-us"
//	var/voice = "m1"
//	var/pitch = 50
//	var/talkspeed = 175
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/exploit_record = ""
	var/disabilities = 0

	var/nanotrasen_relation = "Neutral"

	// 0 = character settings, 1 = game preferences
	var/current_tab = TAB_CHAR

	// OOC Metadata:
	var/metadata = ""
	var/slot_name = ""
	var/saved = FALSE // Indicates whether the character comes from the database or not

	/// Volume mixer, indexed by channel as TEXT (numerical indexes will not work). Volume goes from 0 to 100.
	var/list/volume_mixer = list(
		"1016" = 100, // CHANNEL_GENERAL
		"1024" = 100, // CHANNEL_LOBBYMUSIC
		"1023" = 100, // CHANNEL_ADMIN
		"1022" = 100, // CHANNEL_VOX
		"1021" = 100, // CHANNEL_JUKEBOX
		"1020" = 100, // CHANNEL_HEARTBEAT
		"1019" = 100, // CHANNEL_BUZZ
		"1018" = 100, // CHANNEL_AMBIENCE
		"1014" = 50, // CHANNEL_TTS_LOCAL
		"1013" = 20, // CHANNEL_TTS_RADIO
		"1012" = 50, // CHANNEL_RADIO_NOISE
		"1011" = 100, // CHANNEL_BOSS_MUSIC
		"1010" = 100, // CHANNEL_INTERACTION_SOUNDS
	)
	/// The volume mixer save timer handle. Used to debounce the DB call to save, to avoid spamming.
	var/volume_mixer_saving = null

	// BYOND membership
	var/unlock_content = 0

	//Gear stuff
	var/list/loadout_gear = list()
	var/list/choosen_gears = list()
	var/gear_tab = "General"
	// Parallax
	var/parallax = PARALLAX_HIGH
	var/multiz_detail = MULTIZ_DETAIL_DEFAULT

	var/discord_id = null
	var/discord_name = null

	/// Active keybinds (currently useable by the mob/client)
	var/list/datum/keybindings = list()
	/// Keybinding overrides ("name" => ["key"...])
	var/list/keybindings_overrides = null
	/// View range preference for this client
	var/viewrange = DEFAULT_CLIENT_VIEWSIZE
	/// How dark things are if client is a ghost, 0-255
	var/ghost_darkness_level = LIGHTING_PLANE_ALPHA_VISIBLE

	/// Minigames notification about their end, start and etc.
	var/minigames_notifications = TRUE

	///TRUE when a player declines to be included for the selection process of game mode antagonists.
	var/skip_antag = FALSE


/datum/preferences/New(client/C)
	parent = C
	b_type = pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")
	max_gear_slots = CONFIG_GET(number/max_loadout_points)
	var/loaded_preferences_successfully = FALSE
	if(istype(C))
		if(!IsGuestKey(C.key))
			unlock_content = C.IsByondMember()
			if(unlock_content)
				max_save_slots = MAX_SAVE_SLOTS_MEMBER

		loaded_preferences_successfully = load_preferences(C) // Do not call this with no client/C, it generates a runtime / SQL error
		if(loaded_preferences_successfully)
			if(load_character(C))
				C?.prefs?.init_custom_emotes(C.prefs.custom_emotes)
				return
	//we couldn't load character data so just randomize the character appearance + name
	random_character()		//let's create a random character then - rather than a fat, bald and naked man.
	real_name = random_name(gender)
	if(!SSdbcore.IsConnected())
		init_keybindings() //we want default keybinds, even if DB is not connected
		return
	if(istype(C))
		if(!loaded_preferences_successfully)
			save_preferences(C) // Do not call this with no client/C, it generates a runtime / SQL error
		save_character(C)		// Do not call this with no client/C, it generates a runtime / SQL error
		C.prefs?.init_custom_emotes(C.prefs.custom_emotes)

/datum/preferences/proc/color_square(colour)
	return "<span style='font-face: fixedsys; background-color: [colour]; color: [colour]'>___</span>"

// Hello I am a proc full of snowflake species checks how are you
/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)
		return
	update_preview_icon()
	user << browse_rsc(preview_icon_front, "previewicon.png")
	user << browse_rsc(preview_icon_side, "previewicon2.png")
	SStitle.update_preview(user.client)

	var/list/dat = list()
	dat += {"<meta charset="UTF-8">"}
	dat += "<center>"
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=[TAB_CHAR]' [current_tab == TAB_CHAR ? "class='linkOn'" : ""]>Character Settings</a>"
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=[TAB_GAME]' [current_tab == TAB_GAME ? "class='linkOn'" : ""]>Game Preferences</a>"
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=[TAB_SPEC]' [current_tab == TAB_SPEC ? "class='linkOn'" : ""]>Special Roles</a>"
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=[TAB_GEAR]' [current_tab == TAB_GEAR ? "class='linkOn'" : ""]>Loadout</a>"
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=[TAB_KEYS]' [current_tab == TAB_KEYS ? "class='linkOn'" : ""]>Key Bindings</a>"
	dat += "<a href='byond://?_src_=prefs;preference=tab;tab=[TAB_TOGGLES]' [current_tab == TAB_TOGGLES ? "class='linkOn'" : ""]>General Preferences</a>"
	dat += "</center>"
	dat += "<HR>"

	switch(current_tab)
		if(TAB_CHAR) // Character Settings
			var/datum/species/S = GLOB.all_species[species]
			if(!istype(S)) //The species was invalid. Set the species to the default, fetch the datum for that species and generate a random character.
				species = initial(species)
				S = GLOB.all_species[species]
				random_character()
			dat += "<div class='statusDisplay' style='max-width: 128px; position: absolute; left: 150px; top: 150px'><img src=previewicon.png class='charPreview'><img src=previewicon2.png class='charPreview'></div>"
			dat += "<table width='100%'><tr><td width='405px' height='25px' valign='top'>"
			dat += "<b>Name: </b>"
			dat += "<a href='byond://?_src_=prefs;preference=name;task=input'><b>[real_name]</b></a>"
			dat += "<a href='byond://?_src_=prefs;preference=name;task=random'>(Randomize)</a>"
			dat += "<a href='byond://?_src_=prefs;preference=name'><span class='[be_random_name ? "good" : "bad"]'>(Always&nbsp;Randomize)</span></a><br>"
			dat += "</td><td width='405px' height='25px' valign='left'>"
			dat += "<center>"
			dat += "Slot <b>[default_slot][saved ? "" : " (empty)"]</b><br>"
			dat += "<a href=\"byond://?_src_=prefs;preference=open_load_dialog\">Load slot</a> - "
			dat += "<a href=\"byond://?_src_=prefs;preference=save\">Save slot</a> - "
			dat += "<a href=\"byond://?_src_=prefs;preference=reload\">Reload slot</a>"
			if(saved)
				dat += " - <a href=\"byond://?_src_=prefs;preference=clear\"><span class='bad'>Clear slot</span></a>"
			dat += "</center>"
			dat += "</td></tr></table>"
			dat += "<table width='100%'><tr><td width='405px' height='200px' valign='top'>"
			dat += "<h2>Identity</h2>"
			if(appearance_isbanned(user))
				dat += "<b>You are banned from using custom names and appearances. \
				You can continue to adjust your characters, but you will be randomised once you join the game.\
				</b><br>"
			dat += "<b>Gender:</b> <a href='byond://?_src_=prefs;preference=gender'>[gender == MALE ? "Male" : (gender == FEMALE ? "Female" : "Genderless")]</a>"
			dat += "<br>"
			dat += "<b>Age:</b> <a href='byond://?_src_=prefs;preference=age;task=input'>[age]</a><br>"
			dat += "<b>Body:</b> <a href='byond://?_src_=prefs;preference=all;task=random'>(&reg;)</a><br>"
			dat += "<b>Species:</b> <a href='byond://?_src_=prefs;preference=species;task=input'>[species]</a><br>"
			switch(species)
				if(SPECIES_VOX)
					dat += "<b>N2 Tank:</b> <a href='byond://?_src_=prefs;preference=speciesprefs;task=input'>[speciesprefs ? "Large N2 Tank" : "Specialized N2 Tank"]</a><br>"
				if(SPECIES_GREY)
					dat += "<b>Wingdings:</b> Set in disabilities<br>"
					dat += "<b>Voice Translator:</b> <a href='byond://?_src_=prefs;preference=speciesprefs;task=input'>[speciesprefs ? "Yes" : "No"]</a><br>"
				if(SPECIES_MACNINEPERSON)
					dat += "<b>Synthetic Shell:</b> <a href='byond://?_src_=prefs;preference=ipcloadouts;task=input'>Selections</a><br>"
				if(SPECIES_WRYN)
					dat += "<b>Comb Deafness:</b> <a href='byond://?_src_=prefs;preference=speciesprefs;task=input'>[speciesprefs ? "Yes" : "No"]</a><br>"
			dat += "<b>Secondary Language:</b> <a href='byond://?_src_=prefs;preference=language;task=input'>[language]</a><br>"
			if(S.autohiss_basic_map)
				dat += "<b>Auto-accent:</b> <a href='byond://?_src_=prefs;preference=autohiss_mode;task=input'>[autohiss_mode == AUTOHISS_FULL ? "Full" : (autohiss_mode == AUTOHISS_BASIC ? "Basic" : "Off")]</a><br>"
			dat += "<b>Blood Type:</b> <a href='byond://?_src_=prefs;preference=b_type;task=input'>[b_type]</a><br>"
			if(S.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
				dat += "<b>Skin Tone:</b> <a href='byond://?_src_=prefs;preference=s_tone;task=input'>[S.bodyflags & HAS_ICON_SKIN_TONE ? "[s_tone]" : "[-s_tone + 35]/220"]</a><br>"
			dat += "<b>Disabilities:</b> <a href='byond://?_src_=prefs;preference=disabilities'>\[Set\]</a><br>"
			dat += "<b>Nanotrasen Relation:</b> <a href='byond://?_src_=prefs;preference=nt_relation;task=input'>[nanotrasen_relation]</a><br>"
			dat += "<a href='byond://?_src_=prefs;preference=flavor_text;task=input'>Set Flavor Text</a><br>"
			dat += "[TextPreview(flavor_text)]<br>"

			dat += "<h2>Hair & Accessories</h2>"

			if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species that have head accessories.
				var/headaccessoryname = "Head Accessory: "
				if(species == SPECIES_UNATHI)
					headaccessoryname = "Horns: "
				dat += "<b>[headaccessoryname]</b>"
				dat += "<a href='byond://?_src_=prefs;preference=ha_style;task=input'>[ha_style]</a> "
				dat += "<a href='byond://?_src_=prefs;preference=headaccessory;task=input'>Color</a> [color_square(hacc_colour)]<br>"

			if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
				dat += "<b>Head Markings:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=m_style_head;task=input'>[m_styles["head"]]</a>"
				dat += "<a href='byond://?_src_=prefs;preference=m_head_colour;task=input'>Color</a> [color_square(m_colours["head"])]<br>"
			if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings/tattoos.
				dat += "<b>Body Markings:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=m_style_body;task=input'>[m_styles["body"]]</a>"
				dat += "<a href='byond://?_src_=prefs;preference=m_body_colour;task=input'>Color</a> [color_square(m_colours["body"])]<br>"
			if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
				dat += "<b>Tail Markings:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=m_style_tail;task=input'>[m_styles["tail"]]</a>"
				dat += "<a href='byond://?_src_=prefs;preference=m_tail_colour;task=input'>Color</a> [color_square(m_colours["tail"])]<br>"

			dat += "<b>Hair:</b> "
			dat += "<a href='byond://?_src_=prefs;preference=h_style;task=input'>[h_style]</a>"
			dat += "<a href='byond://?_src_=prefs;preference=hair;task=input'>Color</a> [color_square(h_colour)]"
			var/datum/sprite_accessory/temp_hair_style = GLOB.hair_styles_public_list[h_style]
			if(temp_hair_style && temp_hair_style.secondary_theme && !temp_hair_style.no_sec_colour)
				dat += " <a href='byond://?_src_=prefs;preference=secondary_hair;task=input'>Color #2</a> [color_square(h_sec_colour)]"
				// Hair gradient
			dat += "<br>"
			dat += "- <b>Gradient:</b>"
			dat += " <a href='byond://?_src_=prefs;preference=h_grad_style;task=input'>[h_grad_style]</a>"
			dat += " <a href='byond://?_src_=prefs;preference=h_grad_colour;task=input'>Color</a> [color_square(h_grad_colour)]"
			dat += " <a href='byond://?_src_=prefs;preference=h_grad_alpha;task=input'>[h_grad_alpha]</a>"
			dat += "<br>"
			dat += "- <b>Gradient Offset:</b> <a href='byond://?_src_=prefs;preference=h_grad_offset;task=input'>[h_grad_offset_x],[h_grad_offset_y]</a>"
			dat += "<br>"

			dat += "<b>Facial Hair:</b> "
			dat += "<a href='byond://?_src_=prefs;preference=f_style;task=input'>[f_style ? "[f_style]" : "Shaved"]</a>"
			dat += "<a href='byond://?_src_=prefs;preference=facial;task=input'>Color</a> [color_square(f_colour)]"
			var/datum/sprite_accessory/temp_facial_hair_style = GLOB.facial_hair_styles_list[f_style]
			if(temp_facial_hair_style && temp_facial_hair_style.secondary_theme && !temp_facial_hair_style.no_sec_colour)
				dat += " <a href='byond://?_src_=prefs;preference=secondary_facial;task=input'>Color #2</a> [color_square(f_sec_colour)]"
			dat += "<br>"


			if(!(S.bodyflags & ALL_RPARTS))
				dat += "<b>Eyes:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=eyes;task=input'>Color</a> [color_square(e_colour)]<br>"

			if((S.bodyflags & HAS_SKIN_COLOR) || ((S.bodyflags & HAS_BODYACC_COLOR) && GLOB.body_accessory_by_species[species]) || check_rights(R_ADMIN, 0, user))
				dat += "<b>Body Color:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=skin;task=input'>Color</a> [color_square(s_colour)]<br>"

			if(GLOB.body_accessory_by_species[species] || check_rights(R_ADMIN, 0, user))
				dat += "<b>Body Accessory:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=body_accessory;task=input'>[body_accessory ? "[body_accessory]" : "None"]</a><br>"

			dat += "</td><td width='405px' height='200px' valign='top'>"
			dat += "<h2>Occupation Choices</h2>"
			dat += "<a href='byond://?_src_=prefs;preference=job;task=menu'>Set Occupation Preferences</a><br>"
			if(jobban_isbanned(user, "Records"))
				dat += "<b>You are banned from using character records.</b><br>"
			else
				dat += "<a href=\"byond://?_src_=prefs;preference=records;record=1\">Character Records</a><br>"

			dat += "<h2>Special Role</h2>"
			dat += "<b>Uplink Location:</b> <a href='byond://?_src_=prefs;preference=uplink_pref;task=input'>[uplink_pref]</a><br>"

			if(CONFIG_GET(flag/tts_enabled))
				dat += "<h2>Text-to-Speech</h2>"
				dat += "<b>Выбор голоса:</b> <a href='byond://?_src_=prefs;preference=tts_seed;task=input'>Эксплорер TTS голосов</a><br>"

			dat += "<h2>Limbs</h2>"
			if(S.bodyflags & HAS_ALT_HEADS) //Species with alt heads.
				dat += "<b>Alternate Head:</b> "
				dat += "<a href='byond://?_src_=prefs;preference=alt_head;task=input'>[alt_head]</a><br>"
			dat += "<b>Limbs and Parts:</b> <a href='byond://?_src_=prefs;preference=limbs;task=input'>Adjust</a><br>"
			if(species != SPECIES_SLIMEPERSON && species != SPECIES_MACNINEPERSON)
				dat += "<b>Internal Organs:</b> <a href='byond://?_src_=prefs;preference=organs;task=input'>Adjust</a><br>"

			//display limbs below
			var/ind = 0
			for(var/name in organ_data)
				var/status = organ_data[name]
				var/organ_name = null
				switch(name)
					if(BODY_ZONE_CHEST)
						organ_name = "torso"
					if(BODY_ZONE_PRECISE_GROIN)
						organ_name = "lower body"
					if(BODY_ZONE_HEAD)
						organ_name = "head"
					if(BODY_ZONE_L_ARM)
						organ_name = "left arm"
					if(BODY_ZONE_R_ARM)
						organ_name = "right arm"
					if(BODY_ZONE_L_LEG)
						organ_name = "left leg"
					if(BODY_ZONE_R_LEG)
						organ_name = "right leg"
					if(BODY_ZONE_PRECISE_L_FOOT)
						organ_name = "left foot"
					if(BODY_ZONE_PRECISE_R_FOOT)
						organ_name = "right foot"
					if(BODY_ZONE_PRECISE_L_HAND)
						organ_name = "left hand"
					if(BODY_ZONE_PRECISE_R_HAND)
						organ_name = "right hand"
					if(INTERNAL_ORGAN_EYES)
						organ_name = "eyes"
					if(INTERNAL_ORGAN_EARS)
						organ_name = "ears"
					if(INTERNAL_ORGAN_HEART)
						organ_name = "heart"
					if(INTERNAL_ORGAN_LUNGS)
						organ_name = "lungs"
					if(INTERNAL_ORGAN_LIVER)
						organ_name = "liver"
					if(INTERNAL_ORGAN_KIDNEYS)
						organ_name = "kidneys"

				if(status in list("cyborg", "amputated", "cybernetic"))
					++ind
					if(ind > 1) dat += ", "

				switch(status)
					if("cyborg")
						var/datum/robolimb/R
						if(rlimb_data[name] && GLOB.all_robolimbs[rlimb_data[name]])
							R = GLOB.all_robolimbs[rlimb_data[name]]
						else
							R = GLOB.basic_robolimb
						dat += "\t[R.company] [organ_name] prosthesis"
					if("amputated")
						dat += "\tAmputated [organ_name]"
					if("cybernetic")
						dat += "\tCybernetic [organ_name]"
			if(!ind)
				dat += "\[...\]<br>"
			else
				dat += "<br>"

			dat += "<h2>Clothing</h2>"
			if(S.clothing_flags & HAS_UNDERWEAR)
				dat += "<b>Underwear:</b> <a href='byond://?_src_=prefs;preference=underwear;task=input'>[underwear]</a><BR>"
				var/datum/sprite_accessory/underwear/uwear = GLOB.underwear_list[underwear]
				if(uwear?.allow_change_color)
					dat += "<b>Underwear Color:</b> <a href='byond://?_src_=prefs;preference=underwear_color;task=input'>Color</a> [color_square(underwear_color)]<BR>"
			if(S.clothing_flags & HAS_UNDERSHIRT)
				dat += "<b>Undershirt:</b> <a href='byond://?_src_=prefs;preference=undershirt;task=input'>[undershirt]</a><BR>"
				var/datum/sprite_accessory/undershirt/ushirt = GLOB.undershirt_list[undershirt]
				if(ushirt?.allow_change_color)
					dat += "<b>Undershirt Color:</b> <a href='byond://?_src_=prefs;preference=undershirt_color;task=input'>Color</a> [color_square(undershirt_color)]<BR>"
			if(S.clothing_flags & HAS_SOCKS)
				dat += "<b>Socks:</b> <a href='byond://?_src_=prefs;preference=socks;task=input'>[socks]</a><BR>"
			dat += "<b>Backpack Type:</b> <a href='byond://?_src_=prefs;preference=bag;task=input'>[backbag]</a><br>"

			dat += "</td></tr></table>"

		if(TAB_GAME) // General Preferences
			// LEFT SIDE OF THE PAGE
			dat += "<table><tr><td width='405px' height='300px' valign='top'>"
			dat += "<h2>Game Settings</h2>"
			if(user.client.holder)
				dat += "<b>Adminhelp sound:</b> <a href='byond://?_src_=prefs;preference=hear_adminhelps'><b>[(sound & SOUND_ADMINHELP)?"On":"Off"]</b></a><br>"
			dat += "<b>AFK Cryoing:</b> <a href='byond://?_src_=prefs;preference=afk_watch'>[(toggles2 & PREFTOGGLE_2_AFKWATCH) ? "Yes" : "No"]</a><br>"
			dat += "<b>Ambient Occlusion:</b> <a href='byond://?_src_=prefs;preference=ambientocclusion'><b>[toggles & PREFTOGGLE_AMBIENT_OCCLUSION ? "Enabled" : "Disabled"]</b></a><br>"
			dat += "<b>Attack Animations:</b> <a href='byond://?_src_=prefs;preference=ghost_att_anim'>[(toggles2 & PREFTOGGLE_2_ITEMATTACK) ? "Yes" : "No"]</a><br>"
			if(unlock_content)
				dat += "<b>BYOND Membership Publicity:</b> <a href='byond://?_src_=prefs;preference=publicity'><b>[(toggles & PREFTOGGLE_MEMBER_PUBLIC) ? "Public" : "Hidden"]</b></a><br>"
			dat += "<b>Show Runechat Chat Bubbles:</b> <a href='byond://?_src_=prefs;preference=chat_on_map'>[toggles2 & PREFTOGGLE_2_RUNECHAT ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>CKEY Anonymity:</b> <a href='byond://?_src_=prefs;preference=anonmode'><b>[toggles2 & PREFTOGGLE_2_ANON ? "Anonymous" : "Not Anonymous"]</b></a><br>"
			if(user.client.donator_level > 0)
				dat += "<b>Donator Publicity:</b> <a href='byond://?_src_=prefs;preference=donor_public'><b>[(toggles & PREFTOGGLE_DONATOR_PUBLIC) ? "Public" : "Hidden"]</b></a><br>"
			dat += "<b>Vote Popups:</b> <a href='byond://?_src_=prefs;preference=vote_popup'>[(toggles2 & PREFTOGGLE_2_DISABLE_VOTE_POPUPS) ? "No" : "Yes"]</a><br>"
			dat += "<b>FPS:</b>	 <a href='byond://?_src_=prefs;preference=clientfps;task=input'>[clientfps]</a><br>"
			dat += "<b>Ghost Ears:</b> <a href='byond://?_src_=prefs;preference=ghost_ears'><b>[(toggles & PREFTOGGLE_CHAT_GHOSTEARS) ? "All Speech" : "Nearest Creatures"]</b></a><br>"
			dat += "<b>Ghost Radio:</b> <a href='byond://?_src_=prefs;preference=ghost_radio'><b>[(toggles & PREFTOGGLE_CHAT_GHOSTRADIO) ? "All Chatter" : "Nearest Speakers"]</b></a><br>"
			dat += "<b>Ghost Sight:</b> <a href='byond://?_src_=prefs;preference=ghost_sight'><b>[(toggles & PREFTOGGLE_CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearest Creatures"]</b></a><br>"
			dat += "<b>Ghost PDA:</b> <a href='byond://?_src_=prefs;preference=ghost_pda'><b>[(toggles & PREFTOGGLE_CHAT_GHOSTPDA) ? "All PDA Messages" : "No PDA Messages"]</b></a><br>"
			dat += "<b>Item Outlines:</b> <a href='byond://?_src_=prefs;preference=item_outlines'><b>[(toggles2 & PREFTOGGLE_2_SEE_ITEM_OUTLINES) ? "Yes" : "No"]</b></a><br>"
			if(check_rights(R_ADMIN,0))
				dat += "<b>OOC Color:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : GLOB.normal_ooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='byond://?_src_=prefs;preference=ooccolor;task=input'><b>Change</b></a><br>"
			if(CONFIG_GET(flag/allow_metadata))
				dat += "<b>OOC Notes:</b> <a href='byond://?_src_=prefs;preference=metadata;task=input'><b>Edit</b></a><br>"
			dat += "<b>Parallax (Fancy Space):</b> <a href='byond://?_src_=prefs;preference=parallax'>"
			switch (parallax)
				if(PARALLAX_LOW)
					dat += "Low"
				if(PARALLAX_MED)
					dat += "Medium"
				if(PARALLAX_INSANE)
					dat += "Insane"
				if(PARALLAX_DISABLE)
					dat += "Disabled"
				else
					dat += "High"
			dat += "</a><br>"
			dat += "<b>Parallax Multi-Z (3D effect):</b> <a href='byond://?_src_=prefs;preference=parallax_multiz'>[toggles2 & PREFTOGGLE_2_PARALLAX_MULTIZ ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Multi-Z Detail:</b> <a href='byond://?_src_=prefs;preference=multiz_detail'>"
			switch (multiz_detail)
				if(MULTIZ_DETAIL_DEFAULT)
					dat += "Default"
				if(MULTIZ_DETAIL_LOW)
					dat += "Low"
				if(MULTIZ_DETAIL_MEDIUM)
					dat += "Medium"
				if(MULTIZ_DETAIL_HIGH)
					dat += "High"
				else
					dat += "ERROR"
			dat += "</a><br>"
			dat += "<b>Play Admin MIDIs:</b> <a href='byond://?_src_=prefs;preference=hear_midis'><b>[(sound & SOUND_MIDI) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Play Lobby Music:</b> <a href='byond://?_src_=prefs;preference=lobby_music'><b>[(sound & SOUND_LOBBY) ? "Yes" : "No"]</b></a><br>"
			dat += "<b>Randomized Character Slot:</b> <a href='byond://?_src_=prefs;preference=randomslot'><b>[toggles2 & PREFTOGGLE_2_RANDOMSLOT ? "Yes" : "No"]</b></a><br>"
			dat += "<b>View Range:</b> <a href='byond://?_src_=prefs;preference=setviewrange'>[viewrange]</a><br>"
			dat += "<b>Window Flashing:</b> <a href='byond://?_src_=prefs;preference=winflash'>[(toggles2 & PREFTOGGLE_2_WINDOWFLASHING) ? "Yes" : "No"]</a><br>"
			// RIGHT SIDE OF THE PAGE
			dat += "</td><td width='405px' height='300px' valign='top'>"
			dat += "<h2>Interface Settings</h2>"
			dat += "<b>Custom UI settings:</b><br>"
			dat += " - <b>Alpha (transparency):</b> <a href='byond://?_src_=prefs;preference=UIalpha'><b>[UI_style_alpha]</b></a><br>"
			dat += " - <b>Color:</b> <a href='byond://?_src_=prefs;preference=UIcolor'><b>[UI_style_color]</b></a> <span style='border: 1px solid #161616; background-color: [UI_style_color];'>&nbsp;&nbsp;&nbsp;</span><br>"
			dat += " - <b>UI Style:</b> <a href='byond://?_src_=prefs;preference=ui'><b>[UI_style]</b></a><br>"
			dat += "<b>Fancy TGUI:</b> <a href='byond://?_src_=prefs;preference=tgui'>[(toggles2 & PREFTOGGLE_2_FANCYUI) ? "Yes" : "No"]</a><br>"
			dat += "<b> - TGUI strip menu size:</b> <a href='byond://?_src_=prefs;preference=tgui_strip_menu'>[toggles2 & PREFTOGGLE_2_BIG_STRIP_MENU ? "Full-size" : "Miniature"]</a><br>"
			dat += "<b> - TGUI Say Theme:</b> <a href='byond://?_src_=prefs;preference=tgui_say_light_mode'>[(toggles2 & PREFTOGGLE_2_ENABLE_TGUI_SAY_LIGHT_MODE) ? "Light" : "Dark"]</a><br>"
			dat += "<b> - TGUI Input:</b> <a href='byond://?_src_=prefs;preference=tgui_input'>[(toggles2 & PREFTOGGLE_2_DISABLE_TGUI_INPUT) ? "No" : "Yes"]</a><br>"
			dat += "<b> - TGUI Input - Large Buttons:</b> <a href='byond://?_src_=prefs;preference=tgui_input_large'>[(toggles2 & PREFTOGGLE_2_LARGE_INPUT_BUTTONS) ? "Yes" : "No"]</a><br>"
			dat += "<b> - TGUI Input - Swap Buttons:</b> <a href='byond://?_src_=prefs;preference=tgui_input_swap'>[(toggles2 & PREFTOGGLE_2_SWAP_INPUT_BUTTONS) ? "Yes" : "No"]</a><br>"
			dat += "<b>Title menu style:</b> <a href='byond://?_src_=prefs;preference=pixelated_menu'>[(toggles2 & PREFTOGGLE_2_PIXELATED_MENU) ? "Pixelated" : "Basic"]</a><br>"
			dat += "</td></tr></table>"

		if(TAB_SPEC) // Antagonist's Preferences
			dat += "<table><tr><td width='340px' height='300px' valign='top'>"
			dat += "<h2>Special Role Settings</h2>"
			if(jobban_isbanned(user, "Syndicate"))
				dat += "<b>You are banned from special roles.</b>"
				be_special = list()
			else
				var/static/last_left = round(GLOB.special_roles.len / 2)
				for(var/i in GLOB.special_roles)
					if(jobban_isbanned(user, i))
						dat += "<b>Be [capitalize(i)]:</b> <font color=red><b> \[BANNED]</b></font><br>"
					else if(!player_old_enough_antag(user.client, i))
						var/available_in_days_antag = available_in_days_antag(user.client, i)
						var/role_available_in_playtime = get_exp_format(role_available_in_playtime(user.client, i))
						if(available_in_days_antag)
							dat += "<b>Be [capitalize(i)]:</b> <font color=red><b> \[IN [(available_in_days_antag)] DAYS]</b></font><br>"
						else if(role_available_in_playtime)
							dat += "<b>Be [capitalize(i)]:</b> <font color=red><b> \[IN [(role_available_in_playtime)]]</b></font><br>"
						else
							dat += "<b>Be [capitalize(i)]:</b> <font color=red><b> \[ERROR]</b></font><br>"
					else
						var/is_special = (i in src.be_special)
						dat += "<b>Be [capitalize(i)]:</b><a href='byond://?_src_=prefs;preference=be_special;role=[i]' style='background-color: [is_special ? "#3b7502" : "#bd0802"]'<b>[(is_special) ? "Yes" : "No"]</b></a><br>"
					if(GLOB.special_roles[last_left] == i)
						dat += "<h2>Total Playtime:</h2>"
						if(!CONFIG_GET(flag/use_exp_tracking))
							dat += "<span class='warning'>Playtime tracking is not enabled.</span>"
						else
							dat += "<b>Your [EXP_TYPE_CREW] playtime is [user.client.get_exp_type(EXP_TYPE_CREW)]</b><br>"
						dat += "</td><td width='340px' height='300px' valign='top'><br/><br/>"
			dat += "</td></tr></table>"

		if(TAB_GEAR)
			var/total_cost = 0
			var/list/type_blacklist = list()
			if(loadout_gear && loadout_gear.len)
				for(var/i = 1, i <= loadout_gear.len, i++)
					var/datum/gear/G = GLOB.gear_datums[loadout_gear[i]]
					if(G)
						if(!G.subtype_cost_overlap)
							if(G.subtype_path in type_blacklist)
								continue
							type_blacklist += G.subtype_path
						total_cost += G.cost

			var/fcolor =  "#3366CC"
			if(total_cost < max_gear_slots)
				fcolor = "#E67300"
			dat += "<table align='center' width='100%' border='4px solid' >"
			dat += "<tr><td colspan=4><center><b><font color='[fcolor]'>[total_cost]/[max_gear_slots]</font> loadout points spent.</b> \[<a href='byond://?_src_=prefs;preference=gear;clear_loadout=1'>Clear Loadout</a>\]</center></td></tr>"
			dat += "<tr><td colspan=4><center><b>"

			var/firstcat = 1
			var/list/own_categories = GLOB.loadout_categories.Copy()
			var/datum/loadout_category/choosen = new("Selected")
			choosen.gear = choosen_gears
			own_categories[choosen.category] = choosen
			for(var/category in own_categories)
				if(firstcat)
					firstcat = 0
				else
					dat += " |"
				if(category == gear_tab)
					dat += " <span class='linkOff'>[category]</span> "
				else
					dat += " <a style=[category == choosen.category ? "'background: steelblue'" : "''"] href='byond://?_src_=prefs;preference=gear;select_category=[category]'>[category]</a> "
			dat += "</b></center></td></tr>"

			var/datum/loadout_category/LC = own_categories[gear_tab]
			dat += "<tr><td colspan=4><b><center>[LC.category]</center></b></td></tr>"
			for(var/gear_name in LC.gear)
				var/datum/gear/G = LC.gear[gear_name]
				var/datum/gear/ticked = choosen_gears[G.display_name]
				dat += "<tr align='center' style='vertical-align:top;'><td width=15%><a style='white-space:normal;vertical-align:middle' [ticked ? "class='linkOn' " : ""]href='byond://?_src_=prefs;preference=gear;toggle_gear=[G.display_name]'>[G.display_name]</a><br/><img src=data:image/jpeg;base64,[ticked ? ticked.base64icon : G.base64icon] class='loadoutPreview'>"
				if(ticked)
					for(var/datum/gear_tweak/tweak in ticked.gear_tweaks)
						dat += "<br/><a href='byond://?_src_=prefs;preference=gear;gear=[ticked.display_name];tweak=\ref[tweak]'>[tweak.get_contents(get_tweak_metadata(ticked, tweak))]</a>"
				dat += "</td><td width = 5% align='center' style='vertical-align:middle'><b>[G.cost]</b></td><td style='vertical-align:middle'>"
				if(G.allowed_roles)
					dat += "<font size=2>Restrictions: "
					for(var/role in G.allowed_roles)
						dat += role + " "
					dat += "</font>"
				dat += "</td><td style='vertical-align:middle'><font size=2>[G.get_header_tips()]<i>[ticked ? ticked.description : G.description] <br/></i></font></td></tr>"
			dat += "</table>"
		if(TAB_KEYS)
			dat += "<div align='center'><b>All Key Bindings:&nbsp;</b>"
			dat += "<a href='byond://?_src_=prefs;preference=keybindings;all=reset'>Reset to Default</a>&nbsp;"
			dat += "<a href='byond://?_src_=prefs;preference=keybindings;all=clear'>Clear</a><br /></div>"
			dat += "<tr><td colspan=4><hr></td></tr>"
			dat += "<tr><td colspan=4><div align='center'><b>Пожалуйста, обратите внимание, что некоторые привязки клавиш переопределяются другими категориями.</b></div></td></tr>"
			dat += "<tr><td colspan=4><div align='center'><b>Убедитесь, что вы привязали их все или тот конкретный, который вам нужен.</b></div></td></tr>"
			dat += "<tr><td colspan=4><hr></td></tr>"
			dat += "<tr><td colspan=4><div align='center'><b>Пользователи могут повторно привязать и использовать следующие ключи:</b></div></td></tr>"
			dat += "<tr><td colspan=4><div align='center'><b>Стрелки, Функциональные (буквы (за исключением х и ъ) и т.п.), Insert, Del, Home, End, PageUp, PageDn.</b></div></td></tr>"
			dat += "<table align='center' width='100%'>"

			// Lookup lists to make our life easier
			var/static/list/keybindings_by_cat
			if(!keybindings_by_cat)
				keybindings_by_cat = list()
				for(var/kb in GLOB.keybindings)
					var/datum/keybinding/KB = kb
					keybindings_by_cat["[KB.category]"] += list(KB)

			for(var/cat in GLOB.keybindings_groups)
				dat += "<tr><td colspan=4><hr></td></tr>"
				dat += "<tr><td colspan=3><h2>[cat]</h2></td></tr>"
				for(var/kb in keybindings_by_cat["[GLOB.keybindings_groups[cat]]"])
					var/datum/keybinding/KB = kb
					var/kb_uid = KB.UID() // Cache this to reduce proc jumps
					var/override_keys = (keybindings_overrides && keybindings_overrides[KB.name])
					var/list/keys = override_keys || KB.keys
					var/keys_buttons = ""
					for(var/key in keys)
						var/disp_key = key
						if(override_keys)
							disp_key = "<b>[disp_key]</b>"
						keys_buttons += "<a href='byond://?_src_=prefs;preference=keybindings;set=[kb_uid];old=[url_encode(key)];'>[disp_key]</a>&nbsp;"
					dat += "<tr>"
					dat += "<td style='width: 25%'>[KB.name]</td>"
					dat += "<td style='width: 45%'>[keys_buttons][(length(keys) < 5) ? "<a href='byond://?_src_=prefs;preference=keybindings;set=[kb_uid];'><span class='good'>+</span></a></td>" : "</td>"]"
					dat += "<td style='width: 20%'><a href='byond://?_src_=prefs;preference=keybindings;reset=[kb_uid]'>Reset to Default</a> <a href='byond://?_src_=prefs;preference=keybindings;clear=[kb_uid]'>Clear</a></td>"
					if(KB.category == KB_CATEGORY_EMOTE_CUSTOM)
						var/datum/keybinding/custom/custom_emote_keybind = kb
						if(custom_emote_keybind.donor_exclusive && !((user.client.donator_level >= 2) || user.client.holder || unlock_content))
							dat += "</tr>"
							dat += "<tr>"
							dat += "<td><b>Использование этой эмоции ограничено для поддержавших проект и членов byond.</b></td>"
							dat += "</tr>"
							continue
						dat += "</tr>"
						dat += "<tr>"
						var/emote_text = user.client.prefs.custom_emotes[custom_emote_keybind.name] //check if this emote keybind has an associated value on the character save
						if(!emote_text)
							dat += "<td style='width: 25%'>[custom_emote_keybind.default_emote_text]</td>"
						else
							dat += "<td style='width: 25%'><i>\"[user.client.prefs.real_name] [emote_text]\"</i></td>"
						dat += "<td style='width: 45%'><a href='byond://?_src_=prefs;preference=keybindings;custom_emote_set=[kb_uid];'>Change Text</a></td>"
						dat += "<td style='width: 20%'><a href='byond://?_src_=prefs;preference=keybindings;custom_emote_reset=[kb_uid];'>Reset to Default</a></td>"
						dat += "<tr><td colspan=4><br></td></tr>"
					dat += "</tr>"
				dat += "<tr><td colspan=4><br></td></tr>"

			dat += "</table>"

		if(TAB_TOGGLES)
			dat += "<div align='center'><b>Preference Toggles:&nbsp;</b>"

			dat += "<table align='center' width='100%'>"

			// Lookup lists to make our life easier
			var/static/list/pref_toggles_by_category
			if(!pref_toggles_by_category)
				pref_toggles_by_category = list()
				for(var/datum/preference_toggle/toggle as anything in GLOB.preference_toggles)
					pref_toggles_by_category["[toggle.preftoggle_category]"] += list(toggle)

			for(var/category in GLOB.preference_toggle_groups)
				dat += "<tr><td colspan=4><hr></td></tr>"
				dat += "<tr><td colspan=3><h2>[category]</h2></td></tr>"
				for(var/datum/preference_toggle/toggle as anything in pref_toggles_by_category["[GLOB.preference_toggle_groups[category]]"])
					dat += "<tr>"
					dat += "<td style='width: 25%'>[toggle.name]</td>"
					dat += "<td style='width: 45%'>[toggle.description]</td>"
					if(toggle.preftoggle_category == PREFTOGGLE_CATEGORY_ADMIN)
						if(!check_rights(toggle.rights_required, 0, (user)))
							dat += "<td style='width: 20%'><b>Admin Restricted.</b></td>"
							dat += "</tr>"
							continue
					switch(toggle.preftoggle_toggle)
						if(PREFTOGGLE_SPECIAL)
							dat += "<td style='width: 20%'><a href='byond://?_src_=prefs;preference=preference_toggles;toggle=[toggle.UID()];'>Adjust</a></td>"
						if(PREFTOGGLE_TOGGLE1)
							dat += "<td style='width: 20%'><a href='byond://?_src_=prefs;preference=preference_toggles;toggle=[toggle.UID()];'>[(toggles & toggle.preftoggle_bitflag) ? "<span class='good'>Enabled</span>" : "<span class='bad'>Disabled</span>"]</a></td>"
						if(PREFTOGGLE_TOGGLE2)
							dat += "<td style='width: 20%'><a href='byond://?_src_=prefs;preference=preference_toggles;toggle=[toggle.UID()];'>[(toggles2 & toggle.preftoggle_bitflag) ? "<span class='good'>Enabled</span>" : "<span class='bad'>Disabled</span>"]</a></td>"
						if(PREFTOGGLE_SOUND)
							dat += "<td style='width: 20%'><a href='byond://?_src_=prefs;preference=preference_toggles;toggle=[toggle.UID()];'>[(sound & toggle.preftoggle_bitflag) ? "<span class='good'>Enabled</span>" : "<span class='bad'>Disabled</span>"]</a></td>"
					dat += "</tr>"
				dat += "<tr><td colspan=4><br></td></tr>"

	dat += "<hr><center>"
	if(!IsGuestKey(user.key))
		dat += "<a href='byond://?_src_=prefs;preference=load'>Undo</a> - "
		dat += "<a href='byond://?_src_=prefs;preference=save'>Save Setup</a> - "

	dat += "<a href='byond://?_src_=prefs;preference=reset_all'>Reset Setup</a>"
	dat += "</center>"

	var/datum/browser/popup = new(user, "preferences", "<div align='center'>Character Setup</div>", 820, 770)
	popup.set_content(dat.Join(""))
	popup.open(FALSE)


/datum/preferences/proc/get_gear_metadata(var/datum/gear/G)
	. = loadout_gear[G.display_name]
	if(!.)
		. = list()
		loadout_gear[G.display_name] = .

/datum/preferences/proc/get_tweak_metadata(var/datum/gear/G, var/datum/gear_tweak/tweak)
	var/list/metadata = get_gear_metadata(G)
	. = metadata["[tweak]"]
	if(!.)
		. = tweak.get_default()
		metadata["[tweak]"] = .

/datum/preferences/proc/set_tweak_metadata(var/datum/gear/G, var/datum/gear_tweak/tweak, var/new_metadata)
	var/list/metadata = get_gear_metadata(G)
	metadata["[tweak]"] = new_metadata
	tweak.update_gear_intro(new_metadata)


/datum/preferences/proc/SetChoices(mob/user, limit = 17, list/splitJobs = list(JOB_TITLE_RD, JOB_TITLE_JUDGE), widthPerColumn = 400, height = 700)
	if(!SSjobs)
		return

	//limit - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//widthPerColumn - Screen's width for every column.
	//height - Screen's height.
	var/width = widthPerColumn


	var/list/html = list()
	html += "<body>"
	if(!length(SSjobs.occupations))
		html += "Подсистема вакансий ещё не успела создать вакансии, пожалуйста, повторите попытку позже"
		html += "<center><a href='byond://?_src_=prefs;preference=job;task=close'>Принять</a></center><br>" // Easier to press up here.
	else
		html += "<tt><center>"
		html += "<b>Выберите предпочитаемые должности</b><br>Определите приоритет на получение желаемой работы.<br><br>"
		html += "<center><a href='byond://?_src_=prefs;preference=job;task=close'>Сохранить</a></center><br>" // Easier to press up here.
		html += "<div align='center'>Левый клик - для повышения предпочтения профессии, правый - для понижения.<br></div>"
		html += "<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='byond://?_src_=prefs;preference=job;task=setJobLevel;level=' + level + ';text=' + encodeURIComponent(rank); return false; }</script>"
		html += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
		html += "<table width='100%' cellpadding='1' cellspacing='0'>"
		var/index = -1

		//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
		var/datum/job/lastJob
		if(!SSjobs)
			return
		for(var/J in SSjobs.occupations)
			var/datum/job/job = J

			if(job.admin_only)
				continue

			if(job.hidden_from_job_prefs)
				continue

			if(!job.can_novice_play(user.client))
				continue

			index += 1
			if((index >= limit) || (job.title in splitJobs))
				if((index < limit) && (lastJob != null))
					// Dynamic window width
					width += widthPerColumn
					//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
					//the last job's selection color. Creating a rather nice effect.
					for(var/i in 1 to limit - index)
						html += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
				html += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
				index = 0

			var/color
			color = "dark"
			if(job.admin_only)
				color = "light"
			html += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
			var/rank
			if(job.alt_titles)
				rank = "<a href=\"?_src_=prefs;preference=job;task=alt_title;job=\ref[job]\">[GetPlayerAltTitle(job)]</a>"
			else
				rank = job.title
			if((job_support_low & JOB_FLAG_CIVILIAN) && (job.title != "Civilian"))
				rank = "<font class='text-muted'>[GetPlayerAltTitle(job)]</font>"
			lastJob = job
			if(jobban_isbanned(user, job.title))
				html += "<del class='[color]'>[rank]</del></td><td><span class='btn btn-sm btn-danger text-light border border-secondary disabled' style='padding: 0px 4px;'><b> \[ЗАБАНЕНО]</b></span></td></tr>"
				continue
			var/available_in_playtime = job.available_in_playtime(user.client)
			if(available_in_playtime)
				html += "<del class='[color]'>[rank]</del></td><td><span class='btn btn-sm btn-danger text-light border border-secondary disabled' style='padding: 0px 4px;'><b> \[" + get_exp_format(available_in_playtime) + " за " + job.get_exp_req_type()  + "\]</b></span></td></tr>"
				continue
			if(job.barred_by_disability(user.client))
				html += "<del class='[color]'>[rank]</del></td><td><span class='btn btn-sm btn-danger text-light border border-secondary disabled' style='padding: 0px 4px;'><b> \[ИНВАЛИДНОСТЬ\]</b></span></td></tr>"
				continue
			if(!job.player_old_enough(user.client))
				var/available_in_days = job.available_in_days(user.client)
				html += "<del class='[color]'>[rank]</del></td><td><span class='btn btn-sm btn-danger text-light border border-secondary disabled' style='padding: 0px 4px;'><b> \[ЧЕРЕЗ [(available_in_days)] ДНЕЙ]</b></span></td></tr>"
				continue
			if(!job.character_old_enough(user.client))
				html += "<del class='[color]'>[rank]</del></td><td><span class='btn btn-sm btn-danger text-light border border-secondary disabled' style='padding: 0px 4px;'><b> \[ВОЗРАСТ ОТ [(job.min_age_allowed)]]</b></span></td></tr>"
				continue
			if(job.species_in_blacklist(user.client))
				html += "<del class='[color]'>[rank]</del></td><td><span class='btn btn-sm btn-danger text-light border border-secondary disabled' style='padding: 0px 4px;'><b> \[НЕДОСТУПНО ДЛЯ ДАННОЙ РАСЫ]</b></span></td></tr>"
				continue
			if((job.title in GLOB.command_positions) || (job.title == JOB_TITLE_AI))//Bold head jobs
				html += "<b><span class='[color]'>[rank]</span></b>"
			else
				html += "<span class='[color]'>[rank]</span>"
			if((job_support_low & JOB_FLAG_CIVILIAN) && (job.title != "Civilian"))
				html += "</td><td></td></tr>"
				continue

			html += "</td><td width='40%'>"

			var/prefLevelLabel = "ОШИБКА"
			var/prefLevelColor = "bg-danger"
			var/prefUpperLevel = -1 // level to assign on left click
			var/prefLowerLevel = -1 // level to assign on right click

			if(GetJobDepartment(job, 1) & job.flag)
				prefLevelLabel = "Высокий"
				prefLevelColor = "btn-primary text-light"
				prefUpperLevel = 4
				prefLowerLevel = 2
			else if(GetJobDepartment(job, 2) & job.flag)
				prefLevelLabel = "Средний"
				prefLevelColor = "btn-success text-light"
				prefUpperLevel = 1
				prefLowerLevel = 3
			else if(GetJobDepartment(job, 3) & job.flag)
				prefLevelLabel = "Низкий"
				prefLevelColor = "btn-warning text-dark"
				prefUpperLevel = 2
				prefLowerLevel = 4
			else
				prefLevelLabel = "НИКОГДА"
				prefLevelColor = "btn-outline-secondary"
				prefUpperLevel = 3
				prefLowerLevel = 1


			html += "<a class='nobg' href='byond://?_src_=prefs;preference=job;task=setJobLevel;level=[prefUpperLevel];text=[job.title]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[job.title]\");'>"

			if(job.title == "Civilian")//Civilian is special
				if(job_support_low & JOB_FLAG_CIVILIAN)
					html += " <span class='btn btn-sm btn-primary text-light border border-secondary' style='padding: 0px 4px;'>Да</span></a>"
				else
					html += " <span class='btn btn-sm btn-outline-secondary' style='padding: 0px 4px; background-color: #f8f9fa;' onmouseover=\"this.style.backgroundColor='#6c757d';\" onmouseout=\"this.style.backgroundColor='#f8f9fa';\">Нет</span></a>"
				html += "</td></tr>"
				index += 1
				html += "<tr bgcolor='[lastJob ? lastJob.selection_color : "#ffffff"]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
				continue

			if(prefLowerLevel>1)
				html += "<span class='btn btn-sm [prefLevelColor] border border-secondary' style='padding: 0px 4px;'>[prefLevelLabel]</span></a>"
			else
				html += "<span class='btn btn-sm [prefLevelColor]' style='padding: 0px 4px; background-color: #f8f9fa;' onmouseover=\"this.style.backgroundColor='#6c757d';\" onmouseout=\"this.style.backgroundColor='#f8f9fa';\">[prefLevelLabel]</span></a>"

			html += "</td></tr>"

		index += 1
		for(var/i in 1 to limit - index) // Finish the column so it is even
			html += "<tr bgcolor='[lastJob ? lastJob.selection_color : "#ffffff"]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"

		html += "</td></tr></table>"
		html += "</center></table>"

		switch(alternate_option)
			if(GET_RANDOM_JOB)
				html += "<center><br><u><a href='byond://?_src_=prefs;preference=job;task=random'>Получить случайную работу, если предпочитаемая работа недоступна</a></u></center><br>"
			if(BE_ASSISTANT)
				html += "<center><br><u><a href='byond://?_src_=prefs;preference=job;task=random'>Стать гражданским, если предпочитаемая работа недоступна</a></u></center><br>"
			if(RETURN_TO_LOBBY)
				html += "<center><br><u><a href='byond://?_src_=prefs;preference=job;task=random'>Вернуться в лобби, если предпочитаемая работа недоступна</a></u></center><br>"

		html += "<center><a href='byond://?_src_=prefs;preference=job;task=reset'>Сброс</a></center>"
		html += "<center><br><a href='byond://?_src_=prefs;preference=job;task=learnaboutselection'>Узнать о \"Выборе должности\"</a></center>"
		html += "</tt>"

	user << browse(null, "window=preferences")
//		user << browse(HTML, "window=mob_occupation;size=[width]x[height]")
	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Предпочитаемые должности</div>", width, height)
	popup.set_window_options("can_close=0")
	var/html_string = html.Join()
	popup.set_content(html_string)
	popup.add_stylesheet("bootstrap.min.css", 'html/browser/bootstrap.min.css')
	popup.open(0)
	return

/datum/preferences/proc/init_keybindings(overrides, raw)
	if(raw)
		try
			overrides = json_decode(raw)
		catch
			overrides = list()
	keybindings = list()
	keybindings_overrides = overrides
	for(var/datum/keybinding/keybinding as anything in GLOB.keybindings)
		var/list/keys = keybinding.keys
		if(overrides?[keybinding.name])
			keys = overrides[keybinding.name]
		for(var/key in keys)
			LAZYADD(keybindings[key], keybinding)

	parent?.update_active_keybindings()
	return keybindings

/datum/preferences/proc/null_longtextfix(raw)
	var/text
	if(raw)
		try
			text = raw
		catch
			text = ""
	return text

/datum/preferences/proc/capture_keybinding(mob/user, datum/keybinding/KB, old)
	var/HTML = {"
	<div id='focus' style="outline: 0;" tabindex=0>Keybinding: [KB.name]<br><br><b>Press any key to change<br>Press ESC to clear</b></div>
	<script>
	var deedDone = false;
	document.onkeyup = function(e) {
		if(deedDone){ return; }
		var alt = e.altKey ? 1 : 0;
		var ctrl = e.ctrlKey ? 1 : 0;
		var shift = e.shiftKey ? 1 : 0;
		var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
		var escPressed = e.keyCode == 27 ? 1 : 0;
		var url = 'byond://?_src_=prefs;preference=keybindings;set=[KB.UID()];old=[url_encode(old)];clear_key='+escPressed+';key='+encodeURIComponent(e.key)+';alt='+alt+';ctrl='+ctrl+';shift='+shift+';numpad='+numpad+';key_code='+e.keyCode;
		window.location=url;
		deedDone = true;
	}
	document.getElementById('focus').focus();
	</script>
	"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "capturekeypress", src)

/datum/preferences/proc/SetJobPreferenceLevel(var/datum/job/job, var/level)
	if(!job)
		return 0

	if(level == 1) // to high
		// remove any other job(s) set to high
		job_support_med |= job_support_high
		job_engsec_med |= job_engsec_high
		job_medsci_med |= job_medsci_high
		job_karma_med |= job_karma_high
		job_support_high = 0
		job_engsec_high = 0
		job_medsci_high = 0
		job_karma_high = 0

	if(job.department_flag == JOBCAT_SUPPORT)
		job_support_low &= ~job.flag
		job_support_med &= ~job.flag
		job_support_high &= ~job.flag

		switch(level)
			if(1)
				job_support_high |= job.flag
			if(2)
				job_support_med |= job.flag
			if(3)
				job_support_low |= job.flag

		return 1
	else if(job.department_flag == JOBCAT_ENGSEC)
		job_engsec_low &= ~job.flag
		job_engsec_med &= ~job.flag
		job_engsec_high &= ~job.flag

		switch(level)
			if(1)
				job_engsec_high |= job.flag
			if(2)
				job_engsec_med |= job.flag
			if(3)
				job_engsec_low |= job.flag

		return 1
	else if(job.department_flag == JOBCAT_MEDSCI)
		job_medsci_low &= ~job.flag
		job_medsci_med &= ~job.flag
		job_medsci_high &= ~job.flag

		switch(level)
			if(1)
				job_medsci_high |= job.flag
			if(2)
				job_medsci_med |= job.flag
			if(3)
				job_medsci_low |= job.flag

		return 1
	else if(job.department_flag == JOBCAT_KARMA)
		job_karma_low &= ~job.flag
		job_karma_med &= ~job.flag
		job_karma_high &= ~job.flag

		switch(level)
			if(1)
				job_karma_high |= job.flag
			if(2)
				job_karma_med |= job.flag
			if(3)
				job_karma_low |= job.flag

		return 1

	return 0

/datum/preferences/proc/UpdateJobPreference(mob/user, role, desiredLvl)
	var/datum/job/job = SSjobs.GetJob(role)

	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if(!isnum(desiredLvl))
		to_chat(user, "<span class='warning'>UpdateJobPreference - desired level was not a number. Please notify coders!</span>")
		ShowChoices(user)
		return

	if(role == "Civilian")
		if(job_support_low & job.flag)
			job_support_low &= ~job.flag
		else
			job_support_low |= job.flag
		SetChoices(user)
		return 1

	SetJobPreferenceLevel(job, desiredLvl)
	SetChoices(user)

	return 1

/datum/preferences/proc/ShowDisabilityState(mob/user, flag, label)
	return "<li><b>[label]:</b> <a href=\"?_src_=prefs;task=input;preference=disabilities;disability=[flag]\">[disabilities & flag ? "Yes" : "No"]</a></li>"

/datum/preferences/proc/SetDisabilities(mob/user)
	var/datum/species/S = GLOB.all_species[species]
	var/HTML = "<body>"
	HTML += "<tt><center>"

	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_WINGDINGS))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_WINGDINGS, "Speak in Wingdings")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_NEARSIGHTED))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_NEARSIGHTED, "Nearsighted")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_COLOURBLIND))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_COLOURBLIND, "Colourblind")
	if(!(S.blacklisted_disabilities &  DISABILITY_FLAG_BLIND))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_BLIND, "Blind")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_DEAF))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_DEAF, "Deaf")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_MUTE))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_MUTE, "Mute")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_OBESITY))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_OBESITY, "Obese")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_NERVOUS))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_NERVOUS, "Stutter")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_SWEDISH))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_SWEDISH, "Swedish accent")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_AULD_IMPERIAL))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_AULD_IMPERIAL, "Староимпѣрская рѣчь")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_LISP))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_LISP, "Lisp")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_DIZZY))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_DIZZY, "Dizziness")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_NICOTINE_ADDICT))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_NICOTINE_ADDICT, "Nicotine addict")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_TEA_ADDICT))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_TEA_ADDICT, "Tea addict")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_COFFEE_ADDICT))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_COFFEE_ADDICT, "Coffee addict")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_ALCOHOLE_ADDICT))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_ALCOHOLE_ADDICT, "Alcohole addict")
	if(!(S.blacklisted_disabilities & DISABILITY_FLAG_PARAPLEGIA))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_PARAPLEGIA, "Paraplegia")

	HTML += {"</ul>
		<a href=\"?_src_=prefs;task=close;preference=disabilities\">\[Done\]</a>
		<a href=\"?_src_=prefs;task=reset;preference=disabilities\">\[Reset\]</a>
		</center></tt>"}

	var/datum/browser/popup = new(user, "disabil", "<div align='center'>Choose Disabilities</div>", 350, 380)
	popup.set_content(HTML)
	popup.open(0)

/datum/preferences/proc/SetRecords(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"

	HTML += "<a href=\"byond://?_src_=prefs;preference=records;task=med_record\">Medical Records</a><br>"

	if(length(med_record) <= 40)
		HTML += "[med_record]"
	else
		HTML += "[copytext_char(med_record, 1, 37)]..."

	HTML += "<br><a href=\"byond://?_src_=prefs;preference=records;task=gen_record\">Employment Records</a><br>"

	if(length(gen_record) <= 40)
		HTML += "[gen_record]"
	else
		HTML += "[copytext_char(gen_record, 1, 37)]..."

	HTML += "<br><a href=\"byond://?_src_=prefs;preference=records;task=sec_record\">Security Records</a><br>"

	if(length(sec_record) <= 40)
		HTML += "[sec_record]"
	else
		HTML += "[copytext_char(sec_record, 1, 37)]..."

	HTML += "<br><a href=\"byond://?_src_=prefs;preference=records;task=exploit_record\">Exploitable Records</a><br>"

	if(length(exploit_record) <= 40)
		HTML += "[exploit_record]"
	else
		HTML += "[copytext_char(exploit_record, 1, 37)]..."

	HTML += "<br><br><a href=\"byond://?_src_=prefs;preference=records;records=-1\">\[Done\]</a>"
	HTML += "</center></tt>"

	var/datum/browser/popup = new(user, "records", "<div align='center'>Character Records</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(0)

/datum/preferences/proc/GetPlayerAltTitle(datum/job/job)
	return player_alt_titles.Find(job.title) > 0 \
		? player_alt_titles[job.title] \
		: job.title

/datum/preferences/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	if(player_alt_titles.Find(job.title))
		player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		player_alt_titles[job.title] = new_title

/datum/preferences/proc/SetJob(mob/user, role)
	var/datum/job/job = SSjobs.GetJob(role)
	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if(role == "Civilian")
		if(job_support_low & job.flag)
			job_support_low &= ~job.flag
		else
			job_support_low |= job.flag
		SetChoices(user)
		return 1

	if(GetJobDepartment(job, 1) & job.flag)
		SetJobDepartment(job, 1)
	else if(GetJobDepartment(job, 2) & job.flag)
		SetJobDepartment(job, 2)
	else if(GetJobDepartment(job, 3) & job.flag)
		SetJobDepartment(job, 3)
	else//job = Never
		SetJobDepartment(job, 4)

	SetChoices(user)
	return 1

/datum/preferences/proc/ResetJobs()
	job_support_high = 0
	job_support_med = 0
	job_support_low = 0

	job_medsci_high = 0
	job_medsci_med = 0
	job_medsci_low = 0

	job_engsec_high = 0
	job_engsec_med = 0
	job_engsec_low = 0

	job_karma_high = 0
	job_karma_med = 0
	job_karma_low = 0


/datum/preferences/proc/GetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)	return 0
	switch(job.department_flag)
		if(JOBCAT_SUPPORT)
			switch(level)
				if(1)
					return job_support_high
				if(2)
					return job_support_med
				if(3)
					return job_support_low
		if(JOBCAT_MEDSCI)
			switch(level)
				if(1)
					return job_medsci_high
				if(2)
					return job_medsci_med
				if(3)
					return job_medsci_low
		if(JOBCAT_ENGSEC)
			switch(level)
				if(1)
					return job_engsec_high
				if(2)
					return job_engsec_med
				if(3)
					return job_engsec_low
		if(JOBCAT_KARMA)
			switch(level)
				if(1)
					return job_karma_high
				if(2)
					return job_karma_med
				if(3)
					return job_karma_low
	return 0

/datum/preferences/proc/SetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)	return 0
	switch(level)
		if(1)//Only one of these should ever be active at once so clear them all here
			job_support_high = 0
			job_medsci_high = 0
			job_engsec_high = 0
			job_karma_high = 0
			return 1
		if(2)//Set current highs to med, then reset them
			job_support_med |= job_support_high
			job_medsci_med |= job_medsci_high
			job_engsec_med |= job_engsec_high
			job_karma_med |= job_karma_high
			job_support_high = 0
			job_medsci_high = 0
			job_engsec_high = 0
			job_karma_high = 0

	switch(job.department_flag)
		if(JOBCAT_SUPPORT)
			switch(level)
				if(2)
					job_support_high = job.flag
					job_support_med &= ~job.flag
				if(3)
					job_support_med |= job.flag
					job_support_low &= ~job.flag
				else
					job_support_low |= job.flag
		if(JOBCAT_MEDSCI)
			switch(level)
				if(2)
					job_medsci_high = job.flag
					job_medsci_med &= ~job.flag
				if(3)
					job_medsci_med |= job.flag
					job_medsci_low &= ~job.flag
				else
					job_medsci_low |= job.flag
		if(JOBCAT_ENGSEC)
			switch(level)
				if(2)
					job_engsec_high = job.flag
					job_engsec_med &= ~job.flag
				if(3)
					job_engsec_med |= job.flag
					job_engsec_low &= ~job.flag
				else
					job_engsec_low |= job.flag
		if(JOBCAT_KARMA)
			switch(level)
				if(2)
					job_karma_high = job.flag
					job_karma_med &= ~job.flag
				if(3)
					job_karma_med |= job.flag
					job_karma_low &= ~job.flag
				else
					job_karma_low |= job.flag
	return 1

/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(!user)	return

	var/datum/species/S = GLOB.all_species[species]
	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("reset")
				ResetJobs()
				SetChoices(user)
			if("learnaboutselection")
				if(CONFIG_GET(string/wikiurl))
					if(tgui_alert(user, "Would you like to open the Job selection info in your browser?", "Open Job Selection", list("Yes", "No")) == "Yes")
						user << link("[CONFIG_GET(string/wikiurl)]/index.php/Job_Selection_and_Assignment")
				else
					to_chat(user, "<span class='danger'>The Wiki URL is not set in the server configuration.</span>")
			if("random")
				if(alternate_option == GET_RANDOM_JOB || alternate_option == BE_ASSISTANT)
					alternate_option += 1
				else if(alternate_option == RETURN_TO_LOBBY)
					alternate_option = 0
				else
					return 0
				SetChoices(user)
			if("alt_title")
				var/datum/job/job = locate(href_list["job"])
				if(job)
					var/choices = list(job.title) + job.alt_titles
					var/choice = tgui_input_list(user, "Pick a title for [job.title].", "Character Generation", choices)
					if(choice)
						SetPlayerAltTitle(job, choice)
						SetChoices(user)
			if("input")
				SetJob(user, href_list["text"])
			if("setJobLevel")
				UpdateJobPreference(user, href_list["text"], text2num(href_list["level"]))
			else
				SetChoices(user)
		return 1
	else if(href_list["preference"] == "disabilities")

		switch(href_list["task"])
			if("close")
				user << browse(null, "window=disabil")
				ShowChoices(user)
			if("reset")
				disabilities=0
				SetDisabilities(user)
			if("input")
				var/dflag=text2num(href_list["disability"])
				if(dflag >= 0) // Toggle it.
					disabilities ^= text2num(href_list["disability"]) //MAGIC
				SetDisabilities(user)
			else
				SetDisabilities(user)
		return 1

	else if(href_list["preference"] == "records")
		if(text2num(href_list["record"]) >= 1)
			SetRecords(user)
			return
		else
			user << browse(null, "window=records")
		if(href_list["task"] == "med_record")
			var/medmsg = tgui_input_text(usr, "Set your medical notes here.", "Medical Records", med_record, max_length = MAX_PAPER_MESSAGE_LEN, multiline = TRUE)
			if(isnull(medmsg))
				return
			med_record = medmsg
			SetRecords(user)

		if(href_list["task"] == "sec_record")
			var/secmsg = tgui_input_text(usr, "Set your security notes here.", "Security Records", sec_record, max_length = MAX_PAPER_MESSAGE_LEN, multiline = TRUE)
			if(isnull(secmsg))
				return
			sec_record = secmsg
			SetRecords(user)

		if(href_list["task"] == "gen_record")
			var/genmsg = tgui_input_text(usr, "Set your employment notes here.", "Employment Records", gen_record, max_length = MAX_PAPER_MESSAGE_LEN, multiline = TRUE)
			if(isnull(genmsg))
				return
			gen_record = genmsg
			SetRecords(user)

		if(href_list["task"] == "exploit_record")
			var/expmsg = tgui_input_text(usr, "Set your exploitable notes here. This info is available to traitors only.", "Exploitable Records", exploit_record, max_length = MAX_PAPER_MESSAGE_LEN, multiline = TRUE)
			if(isnull(expmsg))
				return
			exploit_record = expmsg
			SetRecords(user)


	if(href_list["preference"] == "gear")
		if(href_list["toggle_gear"])
			var/datum/gear/TG = GLOB.gear_datums[href_list["toggle_gear"]]
			if(TG.display_name in loadout_gear)
				loadout_gear -= TG.display_name
				choosen_gears -= TG.display_name
			else
				if(!TG.can_select(cl = user.client, species_name = S.name)) // all gear checks there, no jobs while prefs
					return
				var/total_cost = 0
				var/list/type_blacklist = list()
				for(var/gear_name in loadout_gear)
					var/datum/gear/G = GLOB.gear_datums[gear_name]
					if(istype(G))
						if(!G.subtype_cost_overlap)
							if(G.subtype_path in type_blacklist)
								continue
							type_blacklist += G.subtype_path
						total_cost += G.cost

				if((total_cost + TG.cost) <= max_gear_slots)
					loadout_gear += TG.display_name
					choosen_gears[TG.display_name] += new TG.type
		else if(href_list["gear"] && href_list["tweak"])
			var/datum/gear/gear = choosen_gears[href_list["gear"]]
			var/datum/gear_tweak/tweak = locate(href_list["tweak"])
			if(!tweak || !istype(gear) || !(tweak in gear.gear_tweaks))
				return
			var/metadata = tweak.get_metadata(user, get_tweak_metadata(gear, tweak))
			if(!metadata)
				return
			set_tweak_metadata(gear, tweak, metadata)
		else if(href_list["select_category"])
			gear_tab = href_list["select_category"]
		else if(href_list["clear_loadout"])
			loadout_gear.Cut()
			choosen_gears.Cut()

		ShowChoices(user)
		return

	switch(href_list["task"])
		if("random")
			var/datum/robolimb/robohead
			if(S.bodyflags & ALL_RPARTS)
				var/head_model = "[!rlimb_data["head"] ? "Morpheus Cyberkinetics" : rlimb_data["head"]]"
				robohead = GLOB.all_robolimbs[head_model]
			switch(href_list["preference"])
				if("name")
					real_name = random_name(gender,species)
					user.client << output(real_name, "title_browser:update_current_character")
				if("age")
					age = rand(AGE_MIN, AGE_MAX)
				if("hair")
					if(species in list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_TAJARAN, SPECIES_SKRELL, SPECIES_MACNINEPERSON, SPECIES_WRYN, SPECIES_VULPKANIN, SPECIES_VOX))
						h_colour = rand_hex_color()
				if("secondary_hair")
					if(species in list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_TAJARAN, SPECIES_SKRELL, SPECIES_MACNINEPERSON, SPECIES_WRYN, SPECIES_VULPKANIN, SPECIES_VOX))
						h_sec_colour = rand_hex_color()
				if("h_style")
					h_style = random_hair_style(gender, species, robohead)
				if("facial")
					if(species in list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_TAJARAN, SPECIES_SKRELL, SPECIES_MACNINEPERSON, SPECIES_WRYN, SPECIES_VULPKANIN, SPECIES_VOX))
						f_colour = rand_hex_color()
				if("secondary_facial")
					if(species in list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_TAJARAN, SPECIES_SKRELL, SPECIES_MACNINEPERSON, SPECIES_WRYN, SPECIES_VULPKANIN, SPECIES_VOX))
						f_sec_colour = rand_hex_color()
				if("f_style")
					f_style = random_facial_hair_style(gender, species, robohead)
				if("headaccessory")
					if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species that have head accessories.
						hacc_colour = rand_hex_color()
				if("ha_style")
					if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species that have head accessories.
						ha_style = random_head_accessory(species)
				if("m_style_head")
					if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
						m_styles["head"] = random_marking_style("head", species, robohead, null, alt_head)
				if("m_head_colour")
					if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
						m_colours["head"] = rand_hex_color()
				if("m_style_body")
					if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings.
						m_styles["body"] = random_marking_style("body", species, gender = src.gender)
				if("m_body_colour")
					if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings.
						m_colours["body"] = rand_hex_color()
				if("m_style_tail")
					if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
						m_styles["tail"] = random_marking_style("tail", species, null, body_accessory)
				if("m_tail_colour")
					if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
						m_colours["tail"] = rand_hex_color()
				if("underwear")
					underwear = random_underwear(gender, species)
					ShowChoices(user)
				if("undershirt")
					undershirt = random_undershirt(gender, species)
					ShowChoices(user)
				if("socks")
					socks = random_socks(gender, species)
					ShowChoices(user)
				if("eyes")
					e_colour = rand_hex_color()
				if("s_tone")
					if(S.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
						s_tone = random_skin_tone()
				if("s_color")
					if(S.bodyflags & HAS_SKIN_COLOR)
						s_colour = rand_hex_color()
				if("bag")
					backbag = pick(GLOB.backbaglist)
				/*if("skin_style")
					h_style = random_skin_style(gender)*/
				if("all")
					random_character()
		if("input")
			switch(href_list["preference"])
				if("name")
					var/raw_name = clean_input("Choose your character's name:", "Character Preference", , user)
					if(!isnull(raw_name)) // Check to ensure that the user entered text (rather than cancel.)
						var/new_name = reject_bad_name(raw_name, 1)
						if(new_name)
							real_name = new_name
							user.client << output(real_name, "title_browser:update_current_character")
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")

				if("age")
					var/new_age = tgui_input_number(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference", age, AGE_MAX, AGE_MIN)
					if(!new_age)
						return
					age = max(min(round(text2num(new_age)), AGE_MAX), AGE_MIN)
				if("species")
					var/list/new_species = list(SPECIES_HUMAN)
					var/prev_species = species
					new_species += CONFIG_GET(str_list/playable_species)

					species = tgui_input_list(user, "Please select a species", "Character Generation", sortTim(new_species, cmp = /proc/cmp_text_asc))
					if(!species)
						species = prev_species
						return
					var/datum/species/NS = GLOB.all_species[species]
					if(!istype(NS)) //The species was invalid. Notify the user and fail out.
						species = prev_species
						to_chat(user, "<span class='warning'>Invalid species, please pick something else.</span>")
						return
					if(prev_species != species)
						if(NS.has_gender && gender == PLURAL)
							gender = pick(MALE,FEMALE)
						var/datum/robolimb/robohead
						if(NS.bodyflags & ALL_RPARTS)
							var/head_model = "[!rlimb_data["head"] ? "Morpheus Cyberkinetics" : rlimb_data["head"]]"
							robohead = GLOB.all_robolimbs[head_model]
						//grab one of the valid hair styles for the newly chosen species
						h_style = random_hair_style(gender, species, robohead)

						//grab one of the valid facial hair styles for the newly chosen species
						f_style = random_facial_hair_style(gender, species, robohead)

						if(NS.bodyflags & HAS_HEAD_ACCESSORY) //Species that have head accessories.
							ha_style = random_head_accessory(species)
						else
							ha_style = "None" // No Vulp ears on Unathi
							hacc_colour = rand_hex_color()

						if(NS.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
							m_styles["head"] = random_marking_style("head", species, robohead, null, alt_head)
						else
							m_styles["head"] = "None"
							m_colours["head"] = "#000000"

						if(NS.bodyflags & HAS_BODY_MARKINGS) //Species with body markings/tattoos.
							m_styles["body"] = random_marking_style("body", species, gender = src.gender)
						else
							m_styles["body"] = "None"
							m_colours["body"] = "#000000"

						if(NS.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
							m_styles["tail"] = random_marking_style("tail", species, null, body_accessory)
						else
							m_styles["tail"] = "None"
							m_colours["tail"] = "#000000"

						// Don't wear another species' underwear!
						var/datum/sprite_accessory/SA = GLOB.underwear_list[underwear]
						if(!SA || !(species in SA.species_allowed))
							underwear = random_underwear(gender, species)

						SA = GLOB.undershirt_list[undershirt]
						if(!SA || !(species in SA.species_allowed))
							undershirt = random_undershirt(gender, species)

						SA = GLOB.socks_list[socks]
						if(!SA || !(species in SA.species_allowed))
							socks = random_socks(gender, species)

						//reset skin tone and colour
						if(NS.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
							random_skin_tone(species)
						else
							s_tone = 0

						if(!(NS.bodyflags & HAS_SKIN_COLOR))
							s_colour = "#000000"

						alt_head = "None" //No alt heads on species that don't have them.
						speciesprefs = 0 //My Vox tank shouldn't change how my future Grey talks.
						language = LANGUAGE_NONE
						body_accessory = null //no vulptail on humans damnit
						body_accessory = random_body_accessory(NS.name, NS.optional_body_accessory)

						//Reset prosthetics.
						organ_data = list()
						rlimb_data = list()

						if(!(NS.autohiss_basic_map))
							autohiss_mode = AUTOHISS_OFF
				if("speciesprefs")
					speciesprefs = !speciesprefs //Starts 0, so if someone clicks the button up top there, this won't be 0 anymore. If they click it again, it'll go back to 0.
				if("language")
//						var/languages_available
					var/list/new_languages = list("None")
/*
					if(CONFIG_GET(flag/usealienwhitelist))
						for(var/L in GLOB.all_languages)
							var/datum/language/lang = GLOB.all_languages[L]
							if((!(lang.flags & RESTRICTED)) && (is_alien_whitelisted(user, L)||(!( lang.flags & WHITELISTED ))))
								new_languages += lang
								languages_available = 1

						if(!(languages_available))
							alert(user, "There are not currently any available secondary languages.")
					else
*/
					for(var/language_name in GLOB.all_languages)
						var/datum/language/lang = GLOB.all_languages[language_name]
						if(lang.flags & UNIQUE)
							if(language_name in S.secondary_langs)
								new_languages += language_name
						else if(!(lang.flags & RESTRICTED))
							new_languages += language_name

					var/new_language = tgui_input_list(user, "Please select a secondary language", "Character Generation", sortTim(new_languages, cmp = /proc/cmp_text_asc))
					if(!new_language)
						return
					language = new_language

				if("autohiss_mode")
					if(S.autohiss_basic_map)
						var/list/autohiss_choice = list("Off" = AUTOHISS_OFF, "Basic" = AUTOHISS_BASIC, "Full" = AUTOHISS_FULL)
						var/new_autohiss_pref = tgui_input_list(user, "Choose your character's auto-accent level:", "Character Preference", autohiss_choice)
						if(!new_autohiss_pref)
							return
						autohiss_mode = autohiss_choice[new_autohiss_pref]

				if("metadata")
					var/new_metadata = tgui_input_text(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference", metadata, multiline = TRUE, encode = FALSE)
					if(isnull(new_metadata))
						return
					metadata = new_metadata

				if("b_type")
					var/new_b_type = tgui_input_list(user, "Choose your character's blood-type:", "Character Preference", list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" ))
					if(new_b_type)
						b_type = new_b_type

				if("hair")
					if(species in list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_TAJARAN, SPECIES_SKRELL, SPECIES_MACNINEPERSON, SPECIES_VULPKANIN, SPECIES_VOX)) //Species that have hair. (No HAS_HAIR flag)
						var/input = "Choose your character's hair colour:"
						var/new_hair = input(user, input, "Character Preference", h_colour) as color|null
						if(new_hair)
							h_colour = new_hair

				if("secondary_hair")
					if(species in list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_TAJARAN, SPECIES_SKRELL, SPECIES_MACNINEPERSON, SPECIES_VULPKANIN, SPECIES_VOX))
						var/datum/sprite_accessory/hair_style = GLOB.hair_styles_public_list[h_style]
						if(hair_style.secondary_theme && !hair_style.no_sec_colour)
							var/new_hair = input(user, "Choose your character's secondary hair colour:", "Character Preference", h_sec_colour) as color|null
							if(new_hair)
								h_sec_colour = new_hair

				if("h_style")
					var/list/valid_hairstyles = list()
					for(var/hairstyle in GLOB.hair_styles_public_list)
						var/datum/sprite_accessory/SA = GLOB.hair_styles_public_list[hairstyle]

						if(hairstyle == "Bald") //Just in case.
							valid_hairstyles += hairstyle
							continue
						if(S.bodyflags & ALL_RPARTS) //Species that can use prosthetic heads.
							var/head_model
							if(!rlimb_data["head"]) //Handle situations where the head is default.
								head_model = "Morpheus Cyberkinetics"
							else
								head_model = rlimb_data["head"]
							var/datum/robolimb/robohead = GLOB.all_robolimbs[head_model]
							if((species in SA.species_allowed) && robohead.is_monitor && ((SA.models_allowed && (robohead.company in SA.models_allowed)) || !SA.models_allowed)) //If this is a hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
								valid_hairstyles += hairstyle //Give them their hairstyles if they do.
							else
								if(!robohead.is_monitor && (SPECIES_HUMAN in SA.species_allowed)) /*If the hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																							But if the user has a robotic humanoid head and the hairstyle can fit humans, let them use it as a wig. */
									valid_hairstyles += hairstyle
						else //If the user is not a species who can have robotic heads, use the default handling.
							if(species in SA.species_allowed) //If the user's head is of a species the hairstyle allows, add it to the list.
								valid_hairstyles += hairstyle

					sortTim(valid_hairstyles, cmp = /proc/cmp_text_asc) //this alphabetizes the list
					var/new_h_style = tgui_input_list(user, "Choose your character's hair style:", "Character Preference", valid_hairstyles)
					if(new_h_style)
						h_style = new_h_style

				if("h_grad_style")
					var/result = tgui_input_list(user, "Choose your character's hair gradient style:", "Character Preference", GLOB.hair_gradients_list)
					if(result)
						h_grad_style = result

				if("h_grad_offset")
					var/result = input(user, "Enter your character's hair gradient offset as a comma-separated value (x,y). Example:\n0,0 (no offset)\n5,0 (5 pixels to the right)", "Character Preference") as null|text
					if(!result)
						return
					var/list/expl = splittext(result, ",")
					if(length(expl) == 2)
						h_grad_offset_x = clamp(text2num(expl[1]) || 0, -16, 16)
						h_grad_offset_y = clamp(text2num(expl[2]) || 0, -16, 16)

				if("h_grad_colour")
					var/result = input(user, "Choose your character's hair gradient colour:", "Character Preference", h_grad_colour) as color|null
					if(result)
						h_grad_colour = result

				if("h_grad_alpha")
					var/result = tgui_input_number(user, "Choose your character's hair gradient alpha (0-255):", "Character Preference", h_grad_alpha, 255)
					if(isnull(result))
						return
					h_grad_alpha = clamp(result, 0, 255)

				if("headaccessory")
					if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species with head accessories.
						var/input = "Choose the colour of your your character's head accessory:"
						var/new_head_accessory = input(user, input, "Character Preference", hacc_colour) as color|null
						if(new_head_accessory)
							hacc_colour = new_head_accessory

				if("ha_style")
					if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species with head accessories.
						var/list/valid_head_accessory_styles = list()
						for(var/head_accessory_style in GLOB.head_accessory_styles_list)
							var/datum/sprite_accessory/H = GLOB.head_accessory_styles_list[head_accessory_style]
							if(!(species in H.species_allowed))
								continue

							valid_head_accessory_styles += head_accessory_style

						sortTim(valid_head_accessory_styles, cmp = /proc/cmp_text_asc)
						var/new_head_accessory_style = tgui_input_list(user, "Choose the style of your character's head accessory:", "Character Preference", valid_head_accessory_styles)
						if(new_head_accessory_style)
							ha_style = new_head_accessory_style

				if("alt_head")
					if(organ_data["head"] == "cyborg")
						return
					if(S.bodyflags & HAS_ALT_HEADS) //Species with alt heads.
						var/list/valid_alt_heads = list()
						valid_alt_heads["None"] = GLOB.alt_heads_list["None"] //The only null entry should be the "None" option
						for(var/alternate_head in GLOB.alt_heads_list)
							var/datum/sprite_accessory/alt_heads/head = GLOB.alt_heads_list[alternate_head]
							if(!(species in head.species_allowed))
								continue

							valid_alt_heads += alternate_head

						var/new_alt_head = tgui_input_list(user, "Choose your character's alternate head style:", "Character Preference", valid_alt_heads)
						if(new_alt_head)
							alt_head = new_alt_head
						if(m_styles["head"])
							var/head_marking = m_styles["head"]
							var/datum/sprite_accessory/body_markings/head/head_marking_style = GLOB.marking_styles_list[head_marking]
							if(!head_marking_style.heads_allowed || (!("All" in head_marking_style.heads_allowed) && !(alt_head in head_marking_style.heads_allowed)))
								m_styles["head"] = "None"

				if("m_style_head")
					if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
						var/list/valid_markings = list()
						valid_markings["None"] = GLOB.marking_styles_list["None"]
						for(var/markingstyle in GLOB.marking_styles_list)
							var/datum/sprite_accessory/body_markings/head/M = GLOB.marking_styles_list[markingstyle]
							if(!(species in M.species_allowed))
								continue
							if(M.marking_location != "head")
								continue
							if(alt_head && alt_head != "None")
								if(!("All" in M.heads_allowed) && !(alt_head in M.heads_allowed))
									continue
							else
								if(M.heads_allowed && !("All" in M.heads_allowed))
									continue

							if(S.bodyflags & ALL_RPARTS) //Species that can use prosthetic heads.
								var/head_model
								if(!rlimb_data["head"]) //Handle situations where the head is default.
									head_model = "Morpheus Cyberkinetics"
								else
									head_model = rlimb_data["head"]
								var/datum/robolimb/robohead = GLOB.all_robolimbs[head_model]
								if(robohead.is_monitor && M.name != "None") //If the character can have prosthetic heads and they have the default Morpheus head (or another monitor-head), no optic markings.
									continue
								else if(!robohead.is_monitor && M.name != "None") //Otherwise, if they DON'T have the default head and the head's not a monitor but the head's not in the style's list of allowed models, skip.
									if(!(robohead.company in M.models_allowed))
										continue

							valid_markings += markingstyle
						sortTim(valid_markings, cmp = /proc/cmp_text_asc)
						var/new_marking_style = tgui_input_list(user, "Choose the style of your character's head markings:", "Character Preference", valid_markings)
						if(new_marking_style)
							m_styles["head"] = new_marking_style

				if("m_head_colour")
					if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
						var/input = "Choose the colour of your your character's head markings:"
						var/new_markings = input(user, input, "Character Preference", m_colours["head"]) as color|null
						if(new_markings)
							m_colours["head"] = new_markings

				if("m_style_body")
					if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings/tattoos.
						var/list/valid_markings = list()
						valid_markings["None"] = GLOB.marking_styles_list["None"]
						for(var/markingstyle in GLOB.marking_styles_list)
							var/datum/sprite_accessory/M = GLOB.marking_styles_list[markingstyle]
							if(gender == M.unsuitable_gender)
								continue
							if(!(species in M.species_allowed))
								continue
							if(M.marking_location != "body")
								continue

							valid_markings += markingstyle
						sortTim(valid_markings, cmp = /proc/cmp_text_asc)
						var/new_marking_style = tgui_input_list(user, "Choose the style of your character's body markings:", "Character Preference", valid_markings)
						if(new_marking_style)
							m_styles["body"] = new_marking_style

				if("m_body_colour")
					if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings/tattoos.
						var/input = "Choose the colour of your your character's body markings:"
						var/new_markings = input(user, input, "Character Preference", m_colours["body"]) as color|null
						if(new_markings)
							m_colours["body"] = new_markings

				if("m_style_tail")
					if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
						var/list/valid_markings = list()
						valid_markings["None"] = GLOB.marking_styles_list["None"]
						for(var/markingstyle in GLOB.marking_styles_list)
							var/datum/sprite_accessory/body_markings/tail/M = GLOB.marking_styles_list[markingstyle]
							if(M.marking_location != "tail")
								continue
							if(!(species in M.species_allowed))
								continue
							if(!body_accessory)
								if(M.tails_allowed)
									continue
							else
								if(!M.tails_allowed || !(body_accessory in M.tails_allowed))
									continue

							valid_markings += markingstyle
						sortTim(valid_markings, cmp = /proc/cmp_text_asc)
						var/new_marking_style = tgui_input_list(user, "Choose the style of your character's tail markings:", "Character Preference", valid_markings)
						if(new_marking_style)
							m_styles["tail"] = new_marking_style

				if("m_tail_colour")
					if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
						var/input = "Choose the colour of your your character's tail markings:"
						var/new_markings = input(user, input, "Character Preference", m_colours["tail"]) as color|null
						if(new_markings)
							m_colours["tail"] = new_markings

				if("body_accessory")
					var/list/possible_body_accessories = list()
					for(var/B in GLOB.body_accessory_by_name)
						var/datum/body_accessory/accessory = GLOB.body_accessory_by_name[B]
						if(!istype(accessory))
							possible_body_accessories += "None" //the only null entry should be the "None" option
							continue
						if(species in accessory.allowed_species)
							possible_body_accessories += B
					if(S.optional_body_accessory)
						possible_body_accessories.Add("None") //the only null entry should be the "None" option
					else
						possible_body_accessories.Remove("None") // in case an admin is viewing it
					sortTim(possible_body_accessories, cmp = /proc/cmp_text_asc)
					var/new_body_accessory = tgui_input_list(user, "Choose your body accessory:", "Character Preference", possible_body_accessories)
					if(new_body_accessory)
						m_styles["tail"] = "None"
						body_accessory = (new_body_accessory == "None") ? null : new_body_accessory


				if("facial")
					if(species in list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_TAJARAN, SPECIES_SKRELL, SPECIES_MACNINEPERSON, SPECIES_VULPKANIN, SPECIES_VOX)) //Species that have facial hair. (No HAS_HAIR_FACIAL flag)
						var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference", f_colour) as color|null
						if(new_facial)
							f_colour = new_facial

				if("secondary_facial")
					if(species in list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_TAJARAN, SPECIES_SKRELL, SPECIES_MACNINEPERSON, SPECIES_VULPKANIN, SPECIES_VOX))
						var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[f_style]
						if(facial_hair_style.secondary_theme && !facial_hair_style.no_sec_colour)
							var/new_facial = input(user, "Choose your character's secondary facial-hair colour:", "Character Preference", f_sec_colour) as color|null
							if(new_facial)
								f_sec_colour = new_facial

				if("f_style")
					var/list/valid_facial_hairstyles = list()
					for(var/facialhairstyle in GLOB.facial_hair_styles_list)
						var/datum/sprite_accessory/SA = GLOB.facial_hair_styles_list[facialhairstyle]

						if(facialhairstyle == "Shaved") //Just in case.
							valid_facial_hairstyles += facialhairstyle
							continue
						if(gender == SA.unsuitable_gender)
							continue
						if(S.bodyflags & ALL_RPARTS) //Species that can use prosthetic heads.
							var/head_model
							if(!rlimb_data["head"]) //Handle situations where the head is default.
								head_model = "Morpheus Cyberkinetics"
							else
								head_model = rlimb_data["head"]
							var/datum/robolimb/robohead = GLOB.all_robolimbs[head_model]
							if((species in SA.species_allowed) && robohead.is_monitor && ((SA.models_allowed && (robohead.company in SA.models_allowed)) || !SA.models_allowed)) //If this is a facial hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
								valid_facial_hairstyles += facialhairstyle //Give them their facial hairstyles if they do.
							else
								if(!robohead.is_monitor && (SPECIES_HUMAN in SA.species_allowed)) /*If the facial hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																							But if the user has a robotic humanoid head and the facial hairstyle can fit humans, let them use it as a wig. */
									valid_facial_hairstyles += facialhairstyle
						else //If the user is not a species who can have robotic heads, use the default handling.
							if(species in SA.species_allowed) //If the user's head is of a species the facial hair style allows, add it to the list.
								valid_facial_hairstyles += facialhairstyle
					sortTim(valid_facial_hairstyles, cmp = /proc/cmp_text_asc)
					var/new_f_style = tgui_input_list(user, "Choose your character's facial-hair style:", "Character Preference", valid_facial_hairstyles)
					if(new_f_style)
						f_style = new_f_style

				if("underwear")
					var/list/valid_underwear = list()
					for(var/underwear in GLOB.underwear_list)
						var/datum/sprite_accessory/SA = GLOB.underwear_list[underwear]
						if(gender == SA.unsuitable_gender)
							continue
						if(!(species in SA.species_allowed))
							continue
						valid_underwear[underwear] = GLOB.underwear_list[underwear]
					sortTim(valid_underwear, cmp = /proc/cmp_text_asc)
					var/new_underwear = tgui_input_list(user, "Choose your character's underwear:", "Character Preference", valid_underwear)
					ShowChoices(user)
					if(new_underwear)
						underwear = new_underwear

				if("underwear_color")
					var/new_uwear_color = input(user, "Choose your character's underwear colour:", "Character Preference", underwear_color) as color|null
					if(new_uwear_color)
						underwear_color = new_uwear_color

				if("undershirt")
					var/list/valid_undershirts = list()
					for(var/undershirt in GLOB.undershirt_list)
						var/datum/sprite_accessory/SA = GLOB.undershirt_list[undershirt]
						if(gender == MALE && SA.unsuitable_gender)
							continue
						if(!(species in SA.species_allowed))
							continue
						valid_undershirts[undershirt] = GLOB.undershirt_list[undershirt]
					sortTim(valid_undershirts, cmp = /proc/cmp_text_asc)
					var/new_undershirt = tgui_input_list(user, "Choose your character's undershirt:", "Character Preference", valid_undershirts)
					ShowChoices(user)
					if(new_undershirt)
						undershirt = new_undershirt

				if("undershirt_color")
					var/new_ushirt_color = input(user, "Choose your character's undershirt colour:", "Character Preference", undershirt_color) as color|null
					if(new_ushirt_color)
						undershirt_color = new_ushirt_color

				if("socks")
					var/list/valid_sockstyles = list()
					for(var/sockstyle in GLOB.socks_list)
						var/datum/sprite_accessory/SA = GLOB.socks_list[sockstyle]
						if(gender == SA.unsuitable_gender)
							continue
						if(!(species in SA.species_allowed))
							continue
						valid_sockstyles[sockstyle] = GLOB.socks_list[sockstyle]
					sortTim(valid_sockstyles, cmp = /proc/cmp_text_asc)
					var/new_socks = tgui_input_list(user, "Choose your character's socks:", "Character Preference", valid_sockstyles)
					ShowChoices(user)
					if(new_socks)
						socks = new_socks

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference", e_colour) as color|null
					if(new_eyes)
						e_colour = new_eyes

				if("s_tone")
					if(S.bodyflags & HAS_SKIN_TONE)
						var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
						if(!new_s_tone)
							return
						s_tone = 35 - max(min(round(new_s_tone), 220), 1)
					else if(S.bodyflags & HAS_ICON_SKIN_TONE)
						var/const/MAX_LINE_ENTRIES = 4
						var/prompt = "Choose your character's skin tone: 1-[S.icon_skin_tones.len]\n("
						for(var/i = 1 to S.icon_skin_tones.len)
							if(i > MAX_LINE_ENTRIES && !((i - 1) % MAX_LINE_ENTRIES))
								prompt += "\n"
							prompt += "[i] = [S.icon_skin_tones[i]]"
							if(i != S.icon_skin_tones.len)
								prompt += ", "
						prompt += ")"
						var/skin_c = tgui_input_number(user, prompt, "Character Preference", s_tone, length(S.icon_skin_tones), 1)
						if(!skin_c)
							return
						s_tone = skin_c

				if("skin")
					if((S.bodyflags & HAS_SKIN_COLOR) || ((S.bodyflags & HAS_BODYACC_COLOR) && GLOB.body_accessory_by_species[species]) || check_rights(R_ADMIN, 0, user))
						var/new_skin = input(user, "Choose your character's skin colour: ", "Character Preference", s_colour) as color|null
						if(new_skin)
							s_colour = new_skin

				if("ooccolor")
					var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference", ooccolor) as color|null
					if(new_ooccolor)
						ooccolor = new_ooccolor

				if("bag")
					var/new_backbag = tgui_input_list(user, "Choose your character's style of bag:", "Character Preference", GLOB.backbaglist)
					if(new_backbag)
						backbag = new_backbag

				if("nt_relation")
					var/new_relation = tgui_input_list(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference", list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed"))
					if(new_relation)
						nanotrasen_relation = new_relation

				if("flavor_text")
					var/msg = tgui_input_text(usr, "Set the flavor text in your 'examine' verb. The flavor text should be a physical descriptor of your character at a glance. SFW Drawn Art of your character is acceptable.", "Flavor Text", flavor_text, max_length = MAX_PAPER_MESSAGE_LEN, multiline = TRUE)
					if(isnull(msg))
						return
					flavor_text = msg

				if("ipcloadouts")
					var/choice
					var/datum/robolimb/R
					var/static/robolimb_companies = list()
					var/rparts = list(BODY_ZONE_CHEST,
						BODY_ZONE_PRECISE_GROIN,
						BODY_ZONE_HEAD, BODY_ZONE_L_ARM,
						BODY_ZONE_PRECISE_L_HAND,
						BODY_ZONE_R_ARM,
						BODY_ZONE_PRECISE_R_HAND,
						BODY_ZONE_R_LEG,
						BODY_ZONE_PRECISE_R_FOOT,
						BODY_ZONE_L_LEG,
						BODY_ZONE_PRECISE_L_FOOT)
					if(!length(robolimb_companies))
						for(var/comp in typesof(/datum/robolimb))	//This loop populates a list of companies that shells
							R = new comp()
							if(!R.unavailable_at_chargen && R.has_subtypes && (species in R.species_allowed))	//Needs to be available at chargen and not a Monitor Model and species in species_allowed
								robolimb_companies[R.company] = R
					R = new() //Re-initialize R.
					choice = tgui_input_list(user, "Which manufacturer model would you like to use?", "Character Preference",  robolimb_companies)
					if(!choice)
						return
					R.company = choice
					for(var/limb in rparts)
						if(limb == BODY_ZONE_HEAD)
							ha_style = "None"
							alt_head = null
							h_style = GLOB.hair_styles_public_list["Bald"]
							f_style = GLOB.facial_hair_styles_list["Shaved"]
							m_styles["head"] = "None"
						rlimb_data[limb] = choice
						organ_data[limb] = "cyborg"

				if("uplink_pref")
					var/new_uplink_pref = tgui_input_list(user, "Choose your preferred uplink location:", "Character Preference", list("pda", "headset"))
					if(new_uplink_pref)
						uplink_pref = new_uplink_pref

				if("tts_seed")
					var/static/list/explorer_users = list()
					var/datum/ui_module/tts_seeds_explorer/explorer = explorer_users[user]
					if(!explorer)
						explorer = new()
						explorer_users[user] = explorer
					explorer.ui_interact(user)
					return

				if("limbs")
					var/valid_limbs = list("Left Leg", "Right Leg", "Left Arm", "Right Arm", "Left Foot", "Right Foot", "Left Hand", "Right Hand")
					if(S.bodyflags & ALL_RPARTS)
						valid_limbs = list("Torso", "Lower Body", "Head", "Left Leg", "Right Leg", "Left Arm", "Right Arm", "Left Foot", "Right Foot", "Left Hand", "Right Hand")
					var/limb_name = tgui_input_list(user, "Which limb do you want to change?", "Limbs and Parts", valid_limbs)
					if(!limb_name)
						return

					var/limb = null
					var/second_limb = null // if you try to change the arm, the hand should also change
					var/third_limb = null  // if you try to unchange the hand, the arm should also change
					var/valid_limb_states = list("Normal", "Prosthesis")
					var/no_amputate = FALSE

					switch(limb_name)
						if("Torso")
							limb = BODY_ZONE_CHEST
							second_limb = BODY_ZONE_PRECISE_GROIN
							no_amputate = 1
						if("Lower Body")
							limb = BODY_ZONE_PRECISE_GROIN
							no_amputate = 1
						if("Head")
							limb = BODY_ZONE_HEAD
							no_amputate = 1
						if("Left Leg")
							limb = BODY_ZONE_L_LEG
							second_limb = BODY_ZONE_PRECISE_L_FOOT
						if("Right Leg")
							limb = BODY_ZONE_R_LEG
							second_limb = BODY_ZONE_PRECISE_R_FOOT
						if("Left Arm")
							limb = BODY_ZONE_L_ARM
							second_limb = BODY_ZONE_PRECISE_L_HAND
						if("Right Arm")
							limb = BODY_ZONE_R_ARM
							second_limb = BODY_ZONE_PRECISE_R_HAND
						if("Left Foot")
							limb = BODY_ZONE_PRECISE_L_FOOT
							if(!(S.bodyflags & ALL_RPARTS))
								third_limb = BODY_ZONE_L_LEG
						if("Right Foot")
							limb = BODY_ZONE_PRECISE_R_FOOT
							if(!(S.bodyflags & ALL_RPARTS))
								third_limb = BODY_ZONE_R_LEG
						if("Left Hand")
							limb = BODY_ZONE_PRECISE_L_HAND
							if(!(S.bodyflags & ALL_RPARTS))
								third_limb = BODY_ZONE_L_ARM
						if("Right Hand")
							limb = BODY_ZONE_PRECISE_R_HAND
							if(!(S.bodyflags & ALL_RPARTS))
								third_limb = BODY_ZONE_R_ARM

					if(!no_amputate)	// I don't want this in my menu if it's not an option, heck.
						valid_limb_states += "Amputated"
					if(TRAIT_NO_ROBOPARTS in S.inherent_traits)
						valid_limb_states -= "Prosthesis"

					var/new_state = tgui_input_list(user, "What state do you wish the limb to be in?", "[limb_name]", valid_limb_states)
					if(!new_state) return

					switch(new_state)
						if("Normal")
							if(limb == BODY_ZONE_HEAD)
								m_styles["head"] = "None"
								h_style = GLOB.hair_styles_public_list["Bald"]
								f_style = GLOB.facial_hair_styles_list["Shaved"]
							organ_data[limb] = null
							rlimb_data[limb] = null
							if(third_limb)
								organ_data[third_limb] = null
								rlimb_data[third_limb] = null
						if("Amputated")
							organ_data[limb] = "amputated"
							rlimb_data[limb] = null
							if(second_limb)
								organ_data[second_limb] = "amputated"
								rlimb_data[second_limb] = null
						if("Prosthesis")
							var/choice
							var/subchoice
							var/datum/robolimb/R = new()
							var/in_model
							var/robolimb_companies = list()
							for(var/limb_type in typesof(/datum/robolimb)) //This loop populates a list of companies that offer the limb the user selected previously as one of their cybernetic products.
								R = new limb_type()
								if(!R.unavailable_at_chargen && (limb in R.parts) && R.has_subtypes) //Ensures users can only choose companies that offer the parts they want, that singular models get added to the list as well companies that offer more than one model, and...
									if(species in R.species_allowed)
										robolimb_companies[R.company] = R //List only main brands that have the parts we're looking for.
							R = new() //Re-initialize R.

							choice = tgui_input_list(user, "Which manufacturer do you wish to use for this limb?", "[limb_name] - Prosthesis", robolimb_companies) //Choose from a list of companies that offer the part the user wants.
							if(!choice)
								return
							R.company = choice
							R = GLOB.all_robolimbs[R.company]
							if(R.has_subtypes == 1) //If the company the user selected provides more than just one base model, lets handle it.
								var/list/robolimb_models = list()
								for(var/limb_type in typesof(R)) //Handling the different models of parts that manufacturers can provide.
									var/datum/robolimb/L = new limb_type()
									if(limb in L.parts) //Make sure that only models that provide the parts the user needs populate the list.
										robolimb_models[L.company] = L
										if(robolimb_models.len == 1) //If there's only one model available in the list, autoselect it to avoid having to bother the user with a dialog that provides only one option.
											subchoice = L.company //If there ends up being more than one model populating the list, subchoice will be overwritten later anyway, so this isn't a problem.
										if(second_limb in L.parts) //If the child limb of the limb the user selected is also present in the model's parts list, state it's been found so the second limb can be set later.
											in_model = 1
								if(robolimb_models.len > 1) //If there's more than one model in the list that can provide the part the user wants, let them choose.
									subchoice = tgui_input_list(user, "Which model of [choice] [limb_name] do you wish to use?", "[limb_name] - Prosthesis - Model", robolimb_models)
								if(subchoice)
									choice = subchoice
							if(limb in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN))
								if(!(S.bodyflags & ALL_RPARTS))
									return
								if(limb == BODY_ZONE_HEAD)
									ha_style = "None"
									alt_head = null
									h_style = GLOB.hair_styles_public_list["Bald"]
									f_style = GLOB.facial_hair_styles_list["Shaved"]
									m_styles["head"] = "None"
							rlimb_data[limb] = choice
							organ_data[limb] = "cyborg"
							if(second_limb)
								if(subchoice)
									if(in_model)
										rlimb_data[second_limb] = choice
										organ_data[second_limb] = "cyborg"
								else
									rlimb_data[second_limb] = choice
									organ_data[second_limb] = "cyborg"
				if("organs")
					var/organ_name = tgui_input_list(user, "Which internal function do you want to change?", "Internal Organs", list("Eyes", "Ears", "Heart", "Lungs", "Liver", "Kidneys"))
					if(!organ_name)
						return

					var/organ = null
					switch(organ_name)
						if("Eyes")
							organ = INTERNAL_ORGAN_EYES
						if("Ears")
							organ = INTERNAL_ORGAN_EARS
						if("Heart")
							organ = INTERNAL_ORGAN_HEART
						if("Lungs")
							organ = INTERNAL_ORGAN_LUNGS
						if("Liver")
							organ = INTERNAL_ORGAN_LIVER
						if("Kidneys")
							organ = INTERNAL_ORGAN_KIDNEYS

					var/list/allowed_organs_type = list("Normal", "Cybernetic")
					if(TRAIT_NO_ROBOPARTS in S.inherent_traits)
						allowed_organs_type -= "Cybernetic"
					var/new_state = tgui_input_list(user, "What state do you wish the organ to be in?", "[organ_name]", allowed_organs_type)
					if(!new_state) return

					switch(new_state)
						if("Normal")
							organ_data[organ] = null
						if("Cybernetic")
							organ_data[organ] = "cybernetic"

				if("clientfps")
					var/desiredfps = tgui_input_number(user, "Выберите желаемый FPS.\n  0 = значение по умолчанию ([CONFIG_GET(number/clientfps)]) < РЕКОМЕНДОВАНО\n -1 = синхронизировано с сервером ([world.fps])\n20/40/50 = Может помочь при проблемах с плавностью.", "Character Preference", clientfps, 120, -1)
					if(!isnull(desiredfps))
						clientfps = desiredfps
						if(clientfps)
							parent.fps = clientfps
						else
							parent.fps = CONFIG_GET(number/clientfps)


		else
			switch(href_list["preference"])
				if("publicity")
					if(unlock_content)
						toggles ^= PREFTOGGLE_MEMBER_PUBLIC

				if("donor_public")
					if(user.client.donator_level > 0)
						toggles ^= PREFTOGGLE_DONATOR_PUBLIC

				if("gender")
					if(!S.has_gender)
						var/newgender = tgui_input_list(user, "Choose Gender:", "Gender", list("Male", "Female", "Genderless"))
						switch(newgender)
							if("Male")
								gender = MALE
							if("Female")
								gender = FEMALE
							if("Genderless")
								gender = PLURAL
					else
						if(gender == MALE)
							gender = FEMALE
						else
							gender = MALE

					var/datum/robolimb/robohead
					if(S.bodyflags & ALL_RPARTS)
						var/head_model = "[!rlimb_data["head"] ? "Morpheus Cyberkinetics" : rlimb_data["head"]]"
						robohead = GLOB.all_robolimbs[head_model]

					h_style = random_hair_style(gender, species, robohead)
					f_style = random_facial_hair_style(gender, species, robohead)

					m_styles["body"] = random_marking_style("body", species, gender = src.gender)
					underwear = random_underwear(gender)

				if("hear_adminhelps")
					sound ^= SOUND_ADMINHELP
				if("ui")
					var/new_UI_style = tgui_input_list(user, "Choose your UI style", "UI style", list("Midnight", "Plasmafire", "Retro", "Slimecore", "Operative", "White"))
					if(!new_UI_style)
						return
					switch(new_UI_style)
						if("Midnight")
							UI_style = "Midnight"
						if("Plasmafire")
							UI_style = "Plasmafire"
						if("Retro")
							UI_style = "Retro"
						if("Slimecore")
							UI_style = "Slimecore"
						if("Operative")
							UI_style = "Operative"
						if("White")
							UI_style = "White"

					if(ishuman(usr)) //mid-round preference changes, for aesthetics
						var/mob/living/carbon/human/H = usr
						H.remake_hud()

				if("chat_on_map")
					toggles2 ^= PREFTOGGLE_2_RUNECHAT

				if("tgui")
					toggles2 ^= PREFTOGGLE_2_FANCYUI

				if("tgui_input")
					toggles2 ^= PREFTOGGLE_2_DISABLE_TGUI_INPUT

				if("tgui_input_large")
					toggles2 ^= PREFTOGGLE_2_LARGE_INPUT_BUTTONS

				if("tgui_input_swap")
					toggles2 ^= PREFTOGGLE_2_SWAP_INPUT_BUTTONS

				if("tgui_strip_menu")
					toggles2 ^= PREFTOGGLE_2_BIG_STRIP_MENU

				if("vote_popup")
					toggles2 ^= PREFTOGGLE_2_DISABLE_VOTE_POPUPS

				if("tgui_say_light_mode")
					toggles2 ^= PREFTOGGLE_2_ENABLE_TGUI_SAY_LIGHT_MODE
					user?.client?.tgui_say?.load()

				if("pixelated_menu")
					toggles2 ^= PREFTOGGLE_2_PIXELATED_MENU
					if(user?.client)
						SStitle?.show_title_screen_to(user.client)

				if("ghost_att_anim")
					toggles2 ^= PREFTOGGLE_2_ITEMATTACK

				if("winflash")
					toggles2 ^= PREFTOGGLE_2_WINDOWFLASHING

				if("setviewrange")
					var/list/viewrange_options = list(
						"15x15 (Classic)" = "15x15",
						"17x15 (Wide)" = "17x15",
						"19x15 (Ultrawide)" = "19x15"
					)

					var/new_range = tgui_input_list(user, "Select a view range", "Range", viewrange_options)
					if(!new_range)
						return
					var/actual_new_range = viewrange_options[new_range]

					if(actual_new_range == parent.view)
						return
					viewrange = actual_new_range
					parent.change_view(actual_new_range)

				if("afk_watch")
					if(!(toggles2 & PREFTOGGLE_2_AFKWATCH))
						to_chat(user, "<span class='info'>You will now get put into cryo dorms after [CONFIG_GET(number/auto_cryo_afk)] minutes. \
								Then after [CONFIG_GET(number/auto_despawn_afk)] minutes you will be fully despawned. You will receive a visual and auditory warning before you will be put into cryodorms.</span>")
					else
						to_chat(user, "<span class='info'>Automatic cryoing turned off.</span>")
					toggles2 ^= PREFTOGGLE_2_AFKWATCH

				if("UIcolor")
					var/UI_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!", UI_style_color) as color|null
					if(!UI_style_color_new) return
					UI_style_color = UI_style_color_new

					if(ishuman(usr)) //mid-round preference changes, for aesthetics
						var/mob/living/carbon/human/H = usr
						H.remake_hud()

				if("UIalpha")
					var/UI_style_alpha_new = tgui_input_number(user, "Select a new alpha(transparence) parameter for UI, between 50 and 255", "UI Alpha", UI_style_alpha, 255, 50)
					if(!UI_style_alpha_new)
						return
					UI_style_alpha = UI_style_alpha_new

					if(ishuman(usr)) //mid-round preference changes, for aesthetics
						var/mob/living/carbon/human/H = usr
						H.remake_hud()

				if("be_special")
					var/r = href_list["role"]
					if(r in GLOB.special_roles)
						be_special ^= r

				if("name")
					be_random_name = !be_random_name

				if("randomslot")
					toggles2 ^= PREFTOGGLE_2_RANDOMSLOT

				if("hear_midis")
					sound ^= SOUND_MIDI

				if("lobby_music")
					sound ^= SOUND_LOBBY
					if((sound & SOUND_LOBBY) && user.client)
						user.client.playtitlemusic()
					else
						// user.stop_sound_channel(CHANNEL_LOBBYMUSIC)
						user.client?.tgui_panel?.stop_music()

				if("ghost_ears")
					toggles ^= PREFTOGGLE_CHAT_GHOSTEARS

				if("ghost_sight")
					toggles ^= PREFTOGGLE_CHAT_GHOSTSIGHT

				if("ghost_radio")
					toggles ^= PREFTOGGLE_CHAT_GHOSTRADIO

				if("ghost_pda")
					toggles ^= PREFTOGGLE_CHAT_GHOSTPDA

				if("anonmode")
					toggles2 ^= PREFTOGGLE_2_ANON

				if("item_outlines")
					toggles2 ^= PREFTOGGLE_2_SEE_ITEM_OUTLINES

				if("save")
					save_preferences(user)
					save_character(user)

				if("reload")
					load_preferences(user)
					load_character(user)

				if("clear")
					if(!saved || real_name != input("This will clear the current slot permanently. Please enter the character's full name to confirm."))
						return FALSE
					clear_character_slot(user)

				if("open_load_dialog")
					if(!IsGuestKey(user.key))
						open_load_dialog(user)
						return 1

				if("close_load_dialog")
					close_load_dialog(user)

				if("changeslot")
					if(!load_character(user,text2num(href_list["num"])))
						random_character()
						real_name = random_name(gender)
						save_character(user)
					close_load_dialog(user)
					user.client << output(real_name, "title_browser:update_current_character")

				if("tab")
					if(href_list["tab"])
						current_tab = text2num(href_list["tab"])

				if("ambientocclusion")
					toggles ^= PREFTOGGLE_AMBIENT_OCCLUSION
					if(length(parent?.screen))
						for(var/atom/movable/screen/plane_master/plane_master as anything in parent.mob?.hud_used?.get_true_plane_masters(RENDER_PLANE_GAME_WORLD))
							plane_master.show_to(parent.mob)

				if("parallax")
					var/parallax_styles = list(
						"Off" = PARALLAX_DISABLE,
						"Low" = PARALLAX_LOW,
						"Medium" = PARALLAX_MED,
						"High" = PARALLAX_HIGH,
						"Insane" = PARALLAX_INSANE
					)

					var/new_parallax = tgui_input_list(user, "Pick a parallax style", "Parallax Style", parallax_styles)
					if(!new_parallax)
						return
					/*
					if(multiz_detail != MULTIZ_DETAIL_DEFAULT && parallax_styles[new_parallax] == PARALLAX_DISABLE)
						to_chat(user, span_warning("Due to technical difficulties you can't set with non-default Multi-Z settings. Please turn on \"Parallax\" in order to limit Multi-Z."))
						return
					*/

					parallax = parallax_styles[new_parallax]
					if(parent && parent.mob && parent.mob.hud_used)
						parent.mob.hud_used.update_parallax_pref()

				if("multiz_detail")
					var/multiz_det_styles = list(
						"Default" = MULTIZ_DETAIL_DEFAULT,
						"Low" = MULTIZ_DETAIL_LOW,
						"Medium" = MULTIZ_DETAIL_MEDIUM,
						"High" = MULTIZ_DETAIL_HIGH,
					)

					var/new_value = tgui_input_list(user, "Pick a Multi-z Detail", "Multi-z Detail", multiz_det_styles)
					if(!new_value)
						return
					/*
					if(parallax == PARALLAX_DISABLE && multiz_det_styles[new_value] != MULTIZ_DETAIL_DEFAULT)
						to_chat(user, span_warning("Due to technical difficulties you can't set with disabled parallax. Please set \"Multi-Z Detail\" to default in order to disable Parallax."))
						return
					*/

					multiz_detail = multiz_det_styles[new_value]
					var/datum/hud/my_hud = parent.mob?.hud_used
					if(!my_hud)
						return

					for(var/group_key as anything in my_hud.master_groups)
						var/datum/plane_master_group/group = my_hud.master_groups[group_key]
						group.transform_lower_turfs(my_hud, my_hud.current_plane_offset)

				if("parallax_multiz")
					toggles2 ^= PREFTOGGLE_2_PARALLAX_MULTIZ
					var/datum/hud/my_hud = parent.mob?.hud_used
					if(!my_hud)
						return

					for(var/group_key as anything in my_hud.master_groups)
						var/datum/plane_master_group/group = my_hud.master_groups[group_key]
						group.transform_lower_turfs(my_hud, my_hud.current_plane_offset)

				if("keybindings")
					if(!keybindings_overrides)
						keybindings_overrides = list()

					if(href_list["set"])
						var/datum/keybinding/KB = locateUID(href_list["set"])
						if(KB)
							if(href_list["key"])
								var/old_key = href_list["old"]
								var/new_key = copytext(url_decode(href_list["key"]), 1, 16)
								var/alt_mod = text2num(href_list["alt"]) ? "Alt" : ""
								var/ctrl_mod = text2num(href_list["ctrl"]) ? "Ctrl" : ""
								var/shift_mod = text2num(href_list["shift"]) ? "Shift" : ""
								var/numpad = (text2num(href_list["numpad"]) && text2num(new_key)) ? "Numpad" : ""
								var/clear = text2num(href_list["clear_key"])

								if(new_key == "Unidentified") //There doesn't seem to be any any key!
									capture_keybinding(user, KB, href_list["old"])
									return

								if(!(length_char(new_key) == 1 && text2ascii(new_key) >= 0x80)) // Don't uppercase unicode stuff
									new_key = uppertext(new_key)
								new_key = sanitize_russian_key_to_english(uppertext(new_key))
								new_key = sanitize_specsymbols_key_to_numbers(new_key)

								// Map for JS keys
								var/static/list/key_map = list(
									"UP" = "North",
									"RIGHT" = "East",
									"DOWN" = "South",
									"LEFT" = "West",
									"INSERT" = "Insert",
									"HOME" = "Northwest",
									"PAGEUP" = "Northeast",
									"DEL" = "Delete",
									"END" = "Southwest",
									"PAGEDOWN" = "Southeast",
									"SPACEBAR" = "Space",
									"ALT" = "Alt",
									"SHIFT" = "Shift",
									"CONTROL" = "Ctrl",
									"DIVIDE" = "Divide",
									"MULTIPLY" = "Multiply",
									"ADD" = "Add",
									"SUBTRACT" = "Subtract",
									"DECIMAL" = "Decimal",
									"CLEAR" = "Center"
								)

								new_key = key_map[new_key] || new_key

								var/full_key
								switch(new_key)
									if("ALT")
										full_key = "Alt[ctrl_mod][shift_mod]"
									if("CONTROL")
										full_key = "[alt_mod]Ctrl[shift_mod]"
									if("SHIFT")
										full_key = "[alt_mod][ctrl_mod]Shift"
									else
										full_key = "[alt_mod][ctrl_mod][shift_mod][numpad][new_key]"

								// Update overrides
								var/list/key_overrides = keybindings_overrides[KB.name] || KB.keys?.Copy() || list()
								var/index = key_overrides.Find(old_key)
								var/changed = FALSE
								if(clear) // Clear
									key_overrides -= old_key
									changed = TRUE
								else if(old_key != full_key)
									if(index) // Replace
										var/cur_index = key_overrides.Find(full_key)
										if(cur_index)
											key_overrides[cur_index] = old_key
										key_overrides[index] = full_key
										changed = TRUE
									else // Add
										key_overrides -= (old_key || full_key) // Defaults to the new key itself, as to reorder it
										key_overrides += full_key
										changed = TRUE
								else
									changed = isnull(keybindings_overrides[KB.name]) // Sets it in the JSON

								if(changed)
									if(!length(key_overrides) && !length(KB.keys))
										keybindings_overrides -= KB.name
									else
										keybindings_overrides[KB.name] = key_overrides

								user << browse(null, "window=capturekeypress")
							else
								capture_keybinding(user, KB, href_list["old"])
								return

					else if(href_list["reset"])
						var/datum/keybinding/KB = locateUID(href_list["reset"])
						if(KB)
							keybindings_overrides -= KB.name

					else if(href_list["clear"])
						var/datum/keybinding/KB = locateUID(href_list["clear"])
						if(KB)
							if(length(KB.keys))
								keybindings_overrides[KB.name] = list()
							else
								keybindings_overrides -= KB.name

					else if(href_list["all"])
						var/yes = tgui_alert(user, "Really [href_list["all"]] all key bindings?", "Confirm", list("Yes", "No")) == "Yes"
						if(yes)
							switch(href_list["all"])
								if("reset")
									keybindings_overrides = list()
								if("clear")
									for(var/kb in GLOB.keybindings)
										var/datum/keybinding/KB = kb
										keybindings_overrides[KB.name] = list()

					else if(href_list["custom_emote_set"])
						var/datum/keybinding/custom/custom_emote_keybind = locateUID(href_list["custom_emote_set"])
						if(custom_emote_keybind)
							var/emote_text = user.client.prefs.custom_emotes[custom_emote_keybind.name]
							var/desired_emote = tgui_input_text(user, "Enter your custom emote text, 128 character limit.", "Custom Emote Setter", emote_text, max_length = 128)
							if(desired_emote && (desired_emote != custom_emote_keybind.default_emote_text)) //don't let them save the default custom emote text
								user.client.prefs.custom_emotes[custom_emote_keybind.name] = desired_emote
							save_character(user)

					else if(href_list["custom_emote_reset"])
						var/datum/keybinding/custom/custom_emote_keybind = locateUID(href_list["custom_emote_reset"])
						if(custom_emote_keybind)
							user.client.prefs.custom_emotes.Remove(custom_emote_keybind.name)
							save_character(user)

					init_keybindings(keybindings_overrides)
					save_preferences(user) //Ideally we want to save people's keybinds when they enter them

				if("preference_toggles")
					if(href_list["toggle"])
						var/datum/preference_toggle/toggle = locateUID(href_list["toggle"])
						toggle.set_toggles(user.client)

	ShowChoices(user)
	return TRUE

/datum/preferences/proc/copy_to(mob/living/carbon/human/character)
	var/datum/species/S = GLOB.all_species[species]
	character.set_species(S.type) // Yell at me if this causes everything to melt
	if(be_random_name)
		real_name = random_name(gender,species)

	if(CONFIG_GET(flag/humans_need_surnames))
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace)	//we need a surname
			real_name += " [character.gender==FEMALE ? pick(GLOB.last_names_female) : pick(GLOB.last_names)]"
		else if(firstspace == name_length)
			real_name += "[character.gender==FEMALE ? pick(GLOB.last_names_female) : pick(GLOB.last_names)]"


	character.add_language(language)


	character.real_name = real_name
	character.dna.real_name = real_name
	character.name = character.real_name

	character.flavor_text = flavor_text
	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record
	character.exploit_record = exploit_record

	character.change_gender(gender)
	character.age = age

	character.tts_seed = tts_seed
	character.dna.tts_seed_dna = tts_seed

	//Head-specific
	var/obj/item/organ/external/head/H = character.get_organ(BODY_ZONE_HEAD)

	H.hair_colour = h_colour

	H.sec_hair_colour = h_sec_colour

	H.facial_colour = f_colour

	H.sec_facial_colour = f_sec_colour

	H.h_style = h_style
	H.f_style = f_style

	H.alt_head = alt_head

	H.h_grad_style = h_grad_style
	H.h_grad_offset_x = h_grad_offset_x
	H.h_grad_offset_y = h_grad_offset_y
	H.h_grad_colour = h_grad_colour
	H.h_grad_alpha = h_grad_alpha
	//End of head-specific.

	character.skin_colour = s_colour

	character.s_tone = s_tone

	// Destroy/cyborgize organs
	for(var/name in organ_data)

		var/status = organ_data[name]
		var/obj/item/organ/external/O = character.bodyparts_by_name[name]
		if(O)
			if(status == "amputated")
				qdel(O.remove(character))

			else if(status == "cyborg")
				if(rlimb_data[name])
					O.robotize(company = rlimb_data[name], convert_all = FALSE)
				else
					O.robotize()
		else
			var/obj/item/organ/internal/I = character.internal_organs_slot[name]
			if(I && status == "cybernetic")
				I.robotize()

	character.dna.blood_type = b_type

	character.underwear = underwear
	character.color_underwear = underwear_color
	character.undershirt = undershirt
	character.color_undershirt = undershirt_color
	character.socks = socks

	if(character.dna.species.bodyflags & HAS_HEAD_ACCESSORY)
		H.headacc_colour = hacc_colour
		H.ha_style = ha_style
	if(character.dna.species.bodyflags & HAS_MARKINGS)
		character.m_colours = m_colours
		character.m_styles = m_styles

	if(body_accessory)
		character.body_accessory = GLOB.body_accessory_by_name["[body_accessory]"]

	character.backbag = backbag

	//Debugging report to track down a bug, which randomly assigned the plural gender to people.
	if(character.dna.species.has_gender && (character.gender in list(PLURAL, NEUTER)))
		if(isliving(src)) //Ghosts get neuter by default
			message_admins("[key_name_admin(character)] has spawned with their gender as plural or neuter. Please notify coders.")
			character.change_gender(MALE)

	character.change_eye_color(e_colour)
	character.original_eye_color = e_colour

	var/datum/species/new_species = character.dna.species

	if((disabilities & DISABILITY_FLAG_COFFEE_ADDICT) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_COFFEE_ADDICT))
		var/datum/reagent/new_reagent = new /datum/reagent/consumable/drink/coffee()
		new_reagent.last_addiction_dose = world.timeofday
		character.reagents.addiction_list.Add(new_reagent)

	if((disabilities & DISABILITY_FLAG_TEA_ADDICT) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_TEA_ADDICT))
		var/datum/reagent/new_reagent = new /datum/reagent/consumable/drink/tea()
		new_reagent.last_addiction_dose = world.timeofday
		character.reagents.addiction_list.Add(new_reagent)

	if((disabilities & DISABILITY_FLAG_NICOTINE_ADDICT) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_NICOTINE_ADDICT))
		var/datum/reagent/new_reagent = new /datum/reagent/nicotine()
		new_reagent.last_addiction_dose = world.timeofday
		character.reagents.addiction_list.Add(new_reagent)

	if((disabilities & DISABILITY_FLAG_ALCOHOLE_ADDICT) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_ALCOHOLE_ADDICT))
		var/datum/reagent/new_reagent = new /datum/reagent/consumable/ethanol()
		new_reagent.last_addiction_dose = world.timeofday
		character.reagents.addiction_list.Add(new_reagent)

	if((disabilities & DISABILITY_FLAG_OBESITY) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_OBESITY))
		character.force_gene_block(GLOB.obesityblock, TRUE, TRUE)
		character.overeatduration = 600

	if((disabilities & DISABILITY_FLAG_NEARSIGHTED) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_NEARSIGHTED))
		character.force_gene_block(GLOB.glassesblock, TRUE, TRUE)

	if((disabilities & DISABILITY_FLAG_BLIND) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_BLIND))
		character.force_gene_block(GLOB.blindblock, TRUE, TRUE)

	if((disabilities & DISABILITY_FLAG_DEAF) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_DEAF))
		character.force_gene_block(GLOB.deafblock, TRUE, TRUE)

	if((disabilities & DISABILITY_FLAG_COLOURBLIND) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_COLOURBLIND))
		character.force_gene_block(GLOB.colourblindblock, TRUE, TRUE)

	if((disabilities & DISABILITY_FLAG_MUTE) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_MUTE))
		character.force_gene_block(GLOB.muteblock, TRUE, TRUE)

	if((disabilities & DISABILITY_FLAG_NERVOUS) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_NERVOUS))
		character.force_gene_block(GLOB.nervousblock, TRUE, TRUE)

	if((disabilities & DISABILITY_FLAG_SWEDISH) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_SWEDISH))
		character.force_gene_block(GLOB.swedeblock, TRUE, TRUE)

	if((disabilities & DISABILITY_FLAG_AULD_IMPERIAL) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_AULD_IMPERIAL))
		character.force_gene_block(GLOB.auld_imperial_block, TRUE, TRUE)

	if((disabilities & DISABILITY_FLAG_LISP) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_LISP))
		character.force_gene_block(GLOB.lispblock, TRUE, TRUE)

	if((disabilities & DISABILITY_FLAG_DIZZY) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_DIZZY))
		character.force_gene_block(GLOB.dizzyblock, TRUE, TRUE)

	if((disabilities & DISABILITY_FLAG_WINGDINGS) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_WINGDINGS))
		character.force_gene_block(GLOB.wingdingsblock, TRUE, TRUE)

	if((disabilities & DISABILITY_FLAG_PARAPLEGIA) && !(new_species.blacklisted_disabilities & DISABILITY_FLAG_PARAPLEGIA))
		character.force_gene_block(GLOB.paraplegiablock, TRUE, TRUE)

	character.dna.species.handle_dna(character)

	if(character.dna.dirtySE)
		character.dna.UpdateSE()

	character.dna.ready_dna(character, flatten_SE = FALSE)
	character.sync_organ_dna(assimilate=1)
	character.UpdateAppearance()

	// Do the initial caching of the player's body icons.
	character.regenerate_icons()

/datum/preferences/proc/open_load_dialog(mob/user)

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT slot, real_name FROM [format_table_name("characters")] WHERE ckey=:ckey ORDER BY slot", list(
		"ckey" = user.ckey
	))
	var/list/slotnames[max_save_slots]

	if(!query.warn_execute())
		qdel(query)
		return

	while(query.NextRow())
		slotnames[text2num(query.item[1])] = query.item[2]
	qdel(query)

	var/dat = {"<meta charset="UTF-8"><body>"}
	dat += "<tt><center>"
	dat += "<b>Select a character slot to load</b><hr>"
	var/name

	for(var/i in 1 to max_save_slots)
		name = slotnames[i] || "Character [i]"
		if(i == default_slot)
			name = "<b>[name]</b>"
		dat += "<a href='byond://?_src_=prefs;preference=changeslot;num=[i];'>[name]</a><br>"

	dat += "<hr>"
	dat += "<a href='byond://?_src_=prefs;preference=close_load_dialog'>Close</a><br>"
	dat += "</center></tt>"
//		user << browse(dat, "window=saves;size=300x390")
	var/datum/browser/popup = new(user, "saves", "<div align='center'>Character Saves</div>", 300, 390)
	popup.set_content(dat)
	popup.open(0)

/datum/preferences/proc/close_load_dialog(mob/user)
	user << browse(null, "window=saves")

//Check if the user has ANY job selected.
/datum/preferences/proc/check_any_job()
	return(job_support_high || job_support_med || job_support_low || job_medsci_high || job_medsci_med || job_medsci_low || job_engsec_high || job_engsec_med || job_engsec_low || job_karma_high || job_karma_med || job_karma_low)
