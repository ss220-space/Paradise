//I just want the light feature of the hardsuit helmet
/obj/item/clothing/head/helmet/space/plasmaman
	name = "plasma envirosuit helmet"
	desc = "A special containment helmet that allows plasma-based lifeforms to exist safely in an oxygenated environment. It is space-worthy, and may be worn in tandem with other EVA gear."
	icon_state = "plasmaman-helm"
	item_state = "plasmaman-helm"
	strip_delay = 200
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	HUDType = 0

	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75)
	resistance_flags = FIRE_PROOF
	light_range = 4
	light_power = 1
	light_on = FALSE
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	can_toggle = TRUE
	var/on = FALSE
	var/smile = FALSE
	var/smile_color = "#FF0000"
	var/visor_icon = "envisor"
	var/smile_state = "envirohelm_smile"
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_welding_screen/plasmaman)
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDENAME
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES
	visor_flags_inv = HIDEGLASSES|HIDENAME
	icon = 'icons/obj/clothing/species/plasmaman/hats.dmi'
	species_restricted = list(SPECIES_PLASMAMAN)
	sprite_sheets = list(SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/helmet.dmi')
	var/upgradable = FALSE


/obj/item/clothing/head/helmet/space/plasmaman/Initialize(mapload)
	. = ..()
	weldingvisortoggle(silent = TRUE)


/obj/item/clothing/head/helmet/space/plasmaman/AltClick(mob/user)
	if(Adjacent(user))
		weldingvisortoggle(user)


/obj/item/clothing/head/helmet/space/plasmaman/ui_action_click(mob/user, datum/action/action, leftclick)
	if(istype(action, /datum/action/item_action/toggle_helmet_light))
		toggle_light(user)
	else if(istype(action, /datum/action/item_action/toggle_welding_screen/plasmaman))
		weldingvisortoggle(user)


/obj/item/clothing/head/helmet/space/plasmaman/weldingvisortoggle(mob/user, silent = FALSE)
	. = ..()
	if(!.)
		return .
	if(!silent)
		playsound(loc, 'sound/mecha/mechmove03.ogg', 30, TRUE) //Visors don't just come from nothing
	if(!on)
		return .
	toggle_light()
	if(user)
		to_chat(user, span_notice("Your helmet's torch can't pass through your welding visor!"))


/obj/item/clothing/head/helmet/space/plasmaman/update_icon_state()
	if(!upgradable)
		icon_state = "[initial(icon_state)][on ? "-light":""]"
		item_state = icon_state
		return

	switch(armor.getRating(MELEE))
		if(30)
			icon_state = "[initial(icon_state)][on ? "-light":""]"
			item_state = icon_state
		if(40,50)
			icon_state = "[initial(icon_state)]_reinf[on ? "-light":""]"
			item_state = icon_state
		if(60)
			icon_state = "[initial(icon_state)]_reinf_full[on ? "-light":""]"
			item_state = icon_state


/obj/item/clothing/head/helmet/space/plasmaman/proc/toggle_light(mob/user)
	if(!on && !up)
		if(user)
			to_chat(user, span_notice("Your helmet's torch can't pass through your welding visor!"))
		return FALSE

	on = !on
	update_icon(UPDATE_ICON_STATE)
	set_light_on(on)
	update_equipped_item(update_speedmods = FALSE)
	return TRUE


/obj/item/clothing/head/helmet/space/plasmaman/extinguish_light(force = FALSE)
	if(on)
		toggle_light()


/obj/item/clothing/head/helmet/space/plasmaman/equipped(mob/living/carbon/human/user, slot, initial)
	. = ..()
	if(HUDType && istype(user) && slot == ITEM_SLOT_HEAD)
		var/datum/atom_hud/H = GLOB.huds[HUDType]
		H.add_hud_to(user)


/obj/item/clothing/head/helmet/space/plasmaman/dropped(mob/living/carbon/human/user, slot, silent = FALSE)
	. = ..()
	if(HUDType && istype(user) && slot == ITEM_SLOT_HEAD)
		var/datum/atom_hud/H = GLOB.huds[HUDType]
		H.remove_hud_from(user)


/obj/item/clothing/head/helmet/space/plasmaman/security
	name = "security plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for security officers, protecting them from being flashed and burning alive, alongside other undesirables."
	icon_state = "security_envirohelm"
	item_state = "security_envirohelm"
	armor = list("melee" = 35, "bullet" = 30, "laser" = 30,"energy" = 10, "bomb" = 25, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = EXAMINE_HUD_SECURITY_READ | EXAMINE_HUD_SECURITY_WRITE

/obj/item/clothing/head/helmet/space/plasmaman/security/dec
	name = "detective plasma envirosuit helmet"
	icon_state = "white_envirohelm"
	item_state = "white_envirohelm"
	armor = list("melee" = 25, "bullet" = 5, "laser" = 25, "energy" = 10, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = EXAMINE_HUD_SECURITY_READ | EXAMINE_HUD_SECURITY_WRITE | EXAMINE_HUD_SCIENCE

/obj/item/clothing/head/helmet/space/plasmaman/security/warden
	name = "warden's plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for the warden, a pair of white stripes being added to differentiate them from other members of security."
	icon_state = "warden_envirohelm"
	item_state = "warden_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/security/hos
	name = "security plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for the head of security."
	icon_state = "hos_envirohelm"
	item_state = "hos_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/medical
	name = "medical plasma envirosuit helmet"
	desc = "An envirohelmet designed for plasmaman medical doctors, having two stripes down its length to denote as much."
	icon_state = "doctor_envirohelm"
	item_state = "doctor_envirohelm"
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = EXAMINE_HUD_MEDICAL

/obj/item/clothing/head/helmet/space/plasmaman/cmo
	name = "chief medical officer's plasma envirosuit helmet"
	desc = "An envirohelmet designed for plasmamen employed as the chief medical officer."
	icon_state = "cmo_envirohelm"
	item_state = "cmo_envirohelm"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = EXAMINE_HUD_MEDICAL | EXAMINE_HUD_SCIENCE

/obj/item/clothing/head/helmet/space/plasmaman/genetics
	name = "geneticist's plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for geneticists."
	icon_state = "geneticist_envirohelm"
	item_state = "geneticist_envirohelm"
	HUDType = DATA_HUD_MEDICAL_ADVANCED

/obj/item/clothing/head/helmet/space/plasmaman/viro
	name = "virology plasma envirosuit helmet"
	desc = "The helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create."
	icon_state = "virologist_envirohelm"
	item_state = "virologist_envirohelm"
	examine_extensions = EXAMINE_HUD_SCIENCE

/obj/item/clothing/head/helmet/space/plasmaman/chemist
	name = "chemistry plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for chemists, two orange stripes going down its face."
	icon_state = "chemist_envirohelm"
	item_state = "chemist_envirohelm"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	examine_extensions = EXAMINE_HUD_SCIENCE

/obj/item/clothing/head/helmet/space/plasmaman/science
	name = "science plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for scientists."
	icon_state = "scientist_envirohelm"
	item_state = "scientist_envirohelm"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	examine_extensions = EXAMINE_HUD_SCIENCE

/obj/item/clothing/head/helmet/space/plasmaman/science/xeno
	name = "xenobiologist plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for scientists."
	icon_state = "scientist_envirohelm"
	item_state = "scientist_envirohelm"
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	examine_extensions = EXAMINE_HUD_NONE
	HUDType = DATA_HUD_MEDICAL_ADVANCED

/obj/item/clothing/head/helmet/space/plasmaman/rd
	name = "research director plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for the research director."
	icon_state = "rd_envirohelm"
	item_state = "rd_envirohelm"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	examine_extensions = EXAMINE_HUD_SCIENCE
	HUDType = DATA_HUD_DIAGNOSTIC

/obj/item/clothing/head/helmet/space/plasmaman/robotics
	name = "robotics plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for roboticists."
	icon_state = "roboticist_envirohelm"
	item_state = "roboticist_envirohelm"
	HUDType = DATA_HUD_DIAGNOSTIC

/obj/item/clothing/head/helmet/space/plasmaman/engineering
	name = "engineering plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for engineer plasmamen, the usual purple stripes being replaced by engineering's orange."
	icon_state = "engineer_envirohelm"
	item_state = "engineer_envirohelm"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 20, "energy" = 10, "bomb" = 20, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/head/helmet/space/plasmaman/engineering/mecha
	name = "mechanic plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for engineer plasmamen, the usual purple stripes being replaced by engineering's orange."
	icon_state = "engineer_envirohelm"
	item_state = "engineer_envirohelm"
	HUDType = DATA_HUD_DIAGNOSTIC

/obj/item/clothing/head/helmet/space/plasmaman/engineering/ce
	name = "chief engineer's plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for plasmamen employed as the chief engineer."
	icon_state = "ce_envirohelm"
	item_state = "ce_envirohelm"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	armor = list("melee" = 40, "bullet" = 5, "laser" = 10, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 90)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/plasmaman/atmospherics
	name = "atmospherics plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for atmos technician plasmamen, the usual purple stripes being replaced by engineering's blue."
	icon_state = "atmos_envirohelm"
	item_state = "atmos_envirohelm"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 20, "energy" = 10, "bomb" = 20, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/plasmaman/cargo
	name = "cargo plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for cargo techs and quartermasters."
	icon_state = "cargo_envirohelm"
	item_state = "cargo_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/mining
	name = "mining plasma envirosuit helmet"
	desc = "A khaki helmet given to plasmaman miners operating on Lavaland."
	icon_state = "explorer_envirohelm"
	item_state = "explorer_envirohelm"
	visor_icon = "explorer_envisor"
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	vision_flags = SEE_TURFS
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	upgradable = TRUE

/obj/item/clothing/head/helmet/space/plasmaman/chaplain
	name = "chaplain's plasma envirosuit helmet"
	desc = "An envirohelmet specially designed for only the most pious of plasmamen. Deus Vult"
	icon_state = "chap_envirohelm"
	item_state = "chap_envirohelm"
	armor = list("melee" = 20, "bullet" = 7, "laser" = 2, "energy" = 2, "bomb" = 2, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 80)

/obj/item/clothing/head/helmet/space/plasmaman/white
	name = "white plasma envirosuit helmet"
	desc = "A generic white envirohelm."
	icon_state = "white_envirohelm"
	item_state = "white_envirohelm"
	examine_extensions = EXAMINE_HUD_SCIENCE

/obj/item/clothing/head/helmet/space/plasmaman/nt
	name = "nanotrasen plasma envirosuit helmet"
	desc = "A generic white envirohelm."
	icon_state = "white_envirohelm"
	item_state = "white_envirohelm"
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/head/helmet/space/plasmaman/nt_rep
	name = "nanotrasen representative envirosuit helmet"
	desc = "An envirohelm designed for plasmamen NT representatives."
	icon_state = "ntrep_envirohelm"
	item_state = "ntrep_envirohelm"
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = EXAMINE_HUD_SKILLS

/obj/item/clothing/head/helmet/space/plasmaman/chef
	name = "chef plasma envirosuit helmet"
	desc = "An envirohelm designed for plasmamen chefs."
	icon_state = "chef_envirohelm"
	item_state = "chef_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/librarian
	name = "librarian's plasma envirosuit helmet"
	desc = "A slight modification on a traditional voidsuit helmet, this helmet was Nanotrasen's first solution to the *logistical problems* that come with employing plasmamen. Despite their limitations, these helmets still see use by historian and old-styled plasmamen alike."
	icon_state = "prototype_envirohelm"
	item_state = "prototype_envirohelm"
	actions_types = list(/datum/action/item_action/toggle_welding_screen/plasmaman)
	visor_icon = "prototype_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/botany
	name = "botany plasma envirosuit helmet"
	desc = "A green and blue envirohelmet designating its wearer as a botanist. While not specially designed for it, it would protect against minor plant-related injuries."
	icon_state = "botany_envirohelm"
	item_state = "botany_envirohelm"
	clothing_flags = THICKMATERIAL
	HUDType = DATA_HUD_HYDROPONIC
	examine_extensions = EXAMINE_HUD_BOTANY

/obj/item/clothing/head/helmet/space/plasmaman/janitor
	name = "janitor's plasma envirosuit helmet"
	desc = "A grey helmet bearing a pair of purple stripes, designating the wearer as a janitor."
	icon_state = "janitor_envirohelm"
	item_state = "janitor_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "mime envirosuit helmet"
	desc = "The makeup is painted on, it's a miracle it doesn't chip. It's not very colourful."
	icon_state = "mime_envirohelm"
	item_state = "mime_envirohelm"
	visor_icon = "mime_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/clown
	name = "clown envirosuit helmet"
	desc = "The makeup is painted on, it's a miracle it doesn't chip. <i>'HONK!'</i>"
	icon_state = "clown_envirohelm"
	item_state = "clown_envirohelm"
	visor_icon = "clown_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/hop
	name = "head of personnel envirosuit helmet"
	desc = "A plasmaman envirohelm that reeks of bureaucracy."
	icon_state = "hop_envirohelm"
	item_state = "hop_envirohelm"
	armor = list("melee" = 25, "bullet" = 15, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = EXAMINE_HUD_SKILLS

/obj/item/clothing/head/helmet/space/plasmaman/captain
	name = "captain envirosuit helmet"
	desc = "A plasmaman envirohelm designed with the insignia and markings befitting a captain."
	icon_state = "cap_envirohelm"
	item_state = "cap_envirohelm"
	armor = list("melee" = 25, "bullet" = 15, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = EXAMINE_HUD_SKILLS

/obj/item/clothing/head/helmet/space/plasmaman/blueshield
	name = "blueshield envirosuit helmet"
	desc = "A plasmaman envirohelm designed for the blueshield."
	icon_state = "bs_envirohelm"
	item_state = "bs_envirohelm"
	armor = list("melee" = 35, "bullet" = 30, "laser" = 30,"energy" = 10, "bomb" = 25, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = EXAMINE_HUD_MEDICAL

/obj/item/clothing/head/helmet/space/plasmaman/wizard
	name = "wizard plasma envirosuit helmet"
	desc = "A magical plasmaman containment helmet designed to spread chaos in safety and comfort."
	icon_state = "wizard_envirohelm"
	item_state = "wizard_envirohelm"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	magical = TRUE

/obj/item/clothing/head/helmet/space/plasmaman/syndicate
	name = "syndicate officer envirosuit helmet"
	desc = "Tactical plasmaman envirohelm designed for Syndicate officers."
	icon_state = "syndicatecentcomm_envirohelm"
	item_state = "syndicatecentcomm_envirohelm"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE


/obj/item/clothing/head/helmet/space/plasmaman/centcomm
	name = "Central command officer envirosuit helmet"
	desc = "Central command plasmaman envirohelm designed specially for Nanotrasen officers."
	icon_state = "centcomm_envirohelm"
	item_state = "centcomm_envirohelm"
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = EXAMINE_HUD_SKILLS
