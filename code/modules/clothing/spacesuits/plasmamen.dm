//I just want the light feature of the hardsuit helmet
/obj/item/clothing/head/helmet/space/plasmaman
	name = "plasma envirosuit helmet"
	desc = "Специализированный шлем, позволяющий плазменным формам жизни существовать в обогащённой кислородом среде. Он может использоваться как космический шлем."
	ru_names = list(
		NOMINATIVE = "защитный шлем плазмолюда",
		GENITIVE = "защитного шлема плазмолюда",
		DATIVE = "защитному шлему плазмолюда",
		ACCUSATIVE = "защитный шлем плазмолюда",
		INSTRUMENTAL = "защитным шлемом плазмолюда",
		PREPOSITIONAL = "защитном шлеме плазмолюда"
	)
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


/obj/item/clothing/head/helmet/space/plasmaman/click_alt(mob/user)
	weldingvisortoggle(user)
	return CLICK_ACTION_SUCCESS


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
		balloon_alert(user, "сварочный визор блокирует свет!")


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
			balloon_alert(user, "сварочный визор блокирует свет!")
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
	desc = "Шлем защитного костюма плазмолюда, созданный специально для офицеров службы безопасности."
	ru_names = list(
		NOMINATIVE = "защитный шлем службы безопасности",
		GENITIVE = "защитного шлема службы безопасности",
		DATIVE = "защитному шлему службы безопасности",
		ACCUSATIVE = "защитный шлем службы безопасности",
		INSTRUMENTAL = "защитным шлемом службы безопасности",
		PREPOSITIONAL = "защитном шлеме службы безопасности"
	)
	icon_state = "security_envirohelm"
	item_state = "security_envirohelm"
	armor = list("melee" = 35, "bullet" = 30, "laser" = 30,"energy" = 10, "bomb" = 25, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = EXAMINE_HUD_SECURITY_READ | EXAMINE_HUD_SECURITY_WRITE

/obj/item/clothing/head/helmet/space/plasmaman/security/dec
	name = "detective plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для детектива."
	ru_names = list(
		NOMINATIVE = "защитный шлем детектива",
		GENITIVE = "защитного шлема детектива",
		DATIVE = "защитному шлему детектива",
		ACCUSATIVE = "защитный шлем детектива",
		INSTRUMENTAL = "защитным шлемом детектива",
		PREPOSITIONAL = "защитном шлеме детектива"
	)
	icon_state = "white_envirohelm"
	item_state = "white_envirohelm"
	armor = list("melee" = 25, "bullet" = 5, "laser" = 25, "energy" = 10, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = EXAMINE_HUD_SECURITY_READ | EXAMINE_HUD_SECURITY_WRITE | EXAMINE_HUD_SCIENCE

/obj/item/clothing/head/helmet/space/plasmaman/security/warden
	name = "warden's plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для смотрителя."
	ru_names = list(
		NOMINATIVE = "защитный шлем смотрителя",
		GENITIVE = "защитного шлема смотрителя",
		DATIVE = "защитному шлему смотрителя",
		ACCUSATIVE = "защитный шлем смотрителя",
		INSTRUMENTAL = "защитным шлемом смотрителя",
		PREPOSITIONAL = "защитном шлеме смотрителя"
	)
	icon_state = "warden_envirohelm"
	item_state = "warden_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/security/hos
	name = "head of security plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для главы службы безопасности."
	ru_names = list(
		NOMINATIVE = "защитный шлем главы службы безопасности",
		GENITIVE = "защитного шлема главы службы безопасности",
		DATIVE = "защитному шлему главы службы безопасности",
		ACCUSATIVE = "защитный шлем главы службы безопасности",
		INSTRUMENTAL = "защитным шлемом главы службы безопасности",
		PREPOSITIONAL = "защитном шлеме главы службы безопасности"
	)
	icon_state = "hos_envirohelm"
	item_state = "hos_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/medical
	name = "medical plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для врачей."
	ru_names = list(
		NOMINATIVE = "защитный шлем врача",
		GENITIVE = "защитного шлема врача",
		DATIVE = "защитному шлему врача",
		ACCUSATIVE = "защитный шлем врача",
		INSTRUMENTAL = "защитным шлемом врача",
		PREPOSITIONAL = "защитном шлеме врача"
	)
	icon_state = "doctor_envirohelm"
	item_state = "doctor_envirohelm"
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = EXAMINE_HUD_MEDICAL

/obj/item/clothing/head/helmet/space/plasmaman/medical/brigphysician
	name = "brig physician's plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для бригмедиков."
	ru_names = list(
		NOMINATIVE = "защитный шлем бригмедика",
		GENITIVE = "защитного шлема бригмедика",
		DATIVE = "защитному шлему бригмедика",
		ACCUSATIVE = "защитный шлем бригмедика",
		INSTRUMENTAL = "защитным шлемом бригмедика",
		PREPOSITIONAL = "защитном шлеме бригмедика"
	)
	icon_state = "brigphysician_envirohelm"
	item_state = "brigphysician_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/medical/coroner
	name = "coroner's plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для патологоанатомов."
	ru_names = list(
		NOMINATIVE = "защитный шлем патологоанатома",
		GENITIVE = "защитного шлема патологоанатома",
		DATIVE = "защитному шлему патологоанатома",
		ACCUSATIVE = "защитный шлем патологоанатома",
		INSTRUMENTAL = "защитным шлемом патологоанатома",
		PREPOSITIONAL = "защитном шлеме патологоанатома"
	)
	icon_state = "coroner_envirohelm"
	item_state = "coroner_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/medical/paramedic
	name = "paramedic's plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для парамедиков."
	ru_names = list(
		NOMINATIVE = "защитный шлем парамедика",
		GENITIVE = "защитного шлема парамедика",
		DATIVE = "защитному шлему парамедика",
		ACCUSATIVE = "защитный шлем парамедика",
		INSTRUMENTAL = "защитным шлемом парамедика",
		PREPOSITIONAL = "защитном шлеме парамедика"
	)
	icon_state = "paramedic_envirohelm"
	item_state = "paramedic_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/cmo
	name = "chief medical officer's plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для главного врача."
	ru_names = list(
		NOMINATIVE = "защитный шлем главного врача",
		GENITIVE = "защитного шлема главного врача",
		DATIVE = "защитному шлему главного врача",
		ACCUSATIVE = "защитный шлем главного врача",
		INSTRUMENTAL = "защитным шлемом главного врача",
		PREPOSITIONAL = "защитном шлеме главного врача"
	)
	icon_state = "cmo_envirohelm"
	item_state = "cmo_envirohelm"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = EXAMINE_HUD_MEDICAL | EXAMINE_HUD_SCIENCE

/obj/item/clothing/head/helmet/space/plasmaman/genetics
	name = "geneticist's plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для генетиков."
	ru_names = list(
		NOMINATIVE = "защитный шлем генетика",
		GENITIVE = "защитного шлема генетика",
		DATIVE = "защитному шлему генетика",
		ACCUSATIVE = "защитный шлем генетика",
		INSTRUMENTAL = "защитным шлемом генетика",
		PREPOSITIONAL = "защитном шлеме генетика"
	)
	icon_state = "geneticist_envirohelm"
	item_state = "geneticist_envirohelm"
	HUDType = DATA_HUD_MEDICAL_ADVANCED

/obj/item/clothing/head/helmet/space/plasmaman/viro
	name = "virology plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для вирусологов."
	ru_names = list(
		NOMINATIVE = "защитный шлем вирусолога",
		GENITIVE = "защитного шлема вирусолога",
		DATIVE = "защитному шлему вирусолога",
		ACCUSATIVE = "защитный шлем вирусолога",
		INSTRUMENTAL = "защитным шлемом вирусолога",
		PREPOSITIONAL = "защитном шлеме вирусолога"
	)
	icon_state = "virologist_envirohelm"
	item_state = "virologist_envirohelm"
	examine_extensions = EXAMINE_HUD_SCIENCE

/obj/item/clothing/head/helmet/space/plasmaman/chemist
	name = "chemistry plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для химиков."
	ru_names = list(
		NOMINATIVE = "защитный шлем химика",
		GENITIVE = "защитного шлема химика",
		DATIVE = "защитному шлему химика",
		ACCUSATIVE = "защитный шлем химика",
		INSTRUMENTAL = "защитным шлемом химика",
		PREPOSITIONAL = "защитном шлеме химика"
	)
	icon_state = "chemist_envirohelm"
	item_state = "chemist_envirohelm"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	examine_extensions = EXAMINE_HUD_SCIENCE

/obj/item/clothing/head/helmet/space/plasmaman/science
	name = "science plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для учёных."
	ru_names = list(
		NOMINATIVE = "защитный шлем учёного",
		GENITIVE = "защитного шлема учёного",
		DATIVE = "защитному шлему учёного",
		ACCUSATIVE = "защитный шлем учёного",
		INSTRUMENTAL = "защитным шлемом учёного",
		PREPOSITIONAL = "защитном шлеме учёного"
	)
	icon_state = "scientist_envirohelm"
	item_state = "scientist_envirohelm"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	examine_extensions = EXAMINE_HUD_SCIENCE

/obj/item/clothing/head/helmet/space/plasmaman/science/xeno
	name = "xenobiologist plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для учёных."
	ru_names = list(
		NOMINATIVE = "защитный шлем ксенобиолога",
		GENITIVE = "защитного шлема ксенобиолога",
		DATIVE = "защитному шлему ксенобиолога",
		ACCUSATIVE = "защитный шлем ксенобиолога",
		INSTRUMENTAL = "защитным шлемом ксенобиолога",
		PREPOSITIONAL = "защитном шлеме ксенобиолога"
	)
	icon_state = "scientist_envirohelm"
	item_state = "scientist_envirohelm"
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	examine_extensions = EXAMINE_HUD_NONE
	HUDType = DATA_HUD_MEDICAL_ADVANCED

/obj/item/clothing/head/helmet/space/plasmaman/rd
	name = "research director plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для научного руководителя."
	ru_names = list(
		NOMINATIVE = "защитный шлем научного руководителя",
		GENITIVE = "защитного шлема научного руководителя",
		DATIVE = "защитному шлему научного руководителя",
		ACCUSATIVE = "защитный шлем научного руководителя",
		INSTRUMENTAL = "защитным шлемом научного руководителя",
		PREPOSITIONAL = "защитном шлеме научного руководителя"
	)
	icon_state = "rd_envirohelm"
	item_state = "rd_envirohelm"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	examine_extensions = EXAMINE_HUD_SCIENCE
	HUDType = DATA_HUD_DIAGNOSTIC

/obj/item/clothing/head/helmet/space/plasmaman/robotics
	name = "robotics plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для робототехников."
	ru_names = list(
		NOMINATIVE = "защитный шлем робототехника",
		GENITIVE = "защитного шлема робототехника",
		DATIVE = "защитному шлему робототехника",
		ACCUSATIVE = "защитный шлем робототехника",
		INSTRUMENTAL = "защитным шлемом робототехника",
		PREPOSITIONAL = "защитном шлеме робототехника"
	)
	icon_state = "roboticist_envirohelm"
	item_state = "roboticist_envirohelm"
	HUDType = DATA_HUD_DIAGNOSTIC

/obj/item/clothing/head/helmet/space/plasmaman/engineering
	name = "engineering plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для инженеров."
	ru_names = list(
		NOMINATIVE = "защитный шлем инженера",
		GENITIVE = "защитного шлема инженера",
		DATIVE = "защитному шлему инженера",
		ACCUSATIVE = "защитный шлем инженера",
		INSTRUMENTAL = "защитным шлемом инженера",
		PREPOSITIONAL = "защитном шлеме инженера"
	)
	icon_state = "engineer_envirohelm"
	item_state = "engineer_envirohelm"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 20, "energy" = 10, "bomb" = 20, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/head/helmet/space/plasmaman/engineering/mecha
	name = "mechanic plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для механика."
	ru_names = list(
		NOMINATIVE = "защитный шлем механика",
		GENITIVE = "защитного шлема механика",
		DATIVE = "защитному шлему механика",
		ACCUSATIVE = "защитный шлем механика",
		INSTRUMENTAL = "защитным шлемом механика",
		PREPOSITIONAL = "защитном шлеме механика"
	)
	icon_state = "mechanic_envirohelm"
	item_state = "mechanic_envirohelm"
	HUDType = DATA_HUD_DIAGNOSTIC

/obj/item/clothing/head/helmet/space/plasmaman/engineering/ce
	name = "chief engineer's plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для старшего инженера."
	ru_names = list(
		NOMINATIVE = "защитный шлем старшего инженера",
		GENITIVE = "защитного шлема старшего инженера",
		DATIVE = "защитному шлему старшего инженера",
		ACCUSATIVE = "защитный шлем старшего инженера",
		INSTRUMENTAL = "защитным шлемом старшего инженера",
		PREPOSITIONAL = "защитном шлеме старшего инженера"
	)
	icon_state = "ce_envirohelm"
	item_state = "ce_envirohelm"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	armor = list("melee" = 40, "bullet" = 5, "laser" = 10, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 90)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/plasmaman/atmospherics
	name = "atmospherics plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для атмосферных техников."
	ru_names = list(
		NOMINATIVE = "защитный шлем атмосферного техника",
		GENITIVE = "защитного шлема атмосферного техника",
		DATIVE = "защитному шлему атмосферного техника",
		ACCUSATIVE = "защитный шлем атмосферного техника",
		INSTRUMENTAL = "защитным шлемом атмосферного техника",
		PREPOSITIONAL = "защитном шлеме атмосферного техника"
	)
	icon_state = "atmos_envirohelm"
	item_state = "atmos_envirohelm"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 20, "energy" = 10, "bomb" = 20, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/plasmaman/cargo
	name = "cargo plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для грузчиков."
	ru_names = list(
		NOMINATIVE = "защитный шлем грузчика",
		GENITIVE = "защитного шлема грузчика",
		DATIVE = "защитному шлему грузчика",
		ACCUSATIVE = "защитный шлем грузчика",
		INSTRUMENTAL = "защитным шлемом грузчика",
		PREPOSITIONAL = "защитном шлеме грузчика"
	)
	icon_state = "cargo_envirohelm"
	item_state = "cargo_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/qm
	name = "quartermaster's plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для завхоза."
	ru_names = list(
		NOMINATIVE = "защитный шлем завхоза",
		GENITIVE = "защитного шлема завхоза",
		DATIVE = "защитному шлему завхоза",
		ACCUSATIVE = "защитный шлем завхоза",
		INSTRUMENTAL = "защитным шлемом завхоза",
		PREPOSITIONAL = "защитном шлеме завхоза"
	)
	icon_state = "qm_envirohelm"
	item_state = "qm_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/mining
	name = "mining plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для шахтёров."
	ru_names = list(
		NOMINATIVE = "защитный шлем шахтёра",
		GENITIVE = "защитного шлема шахтёра",
		DATIVE = "защитному шлему шахтёра",
		ACCUSATIVE = "защитный шлем шахтёра",
		INSTRUMENTAL = "защитным шлемом шахтёра",
		PREPOSITIONAL = "защитном шлеме шахтёра"
	)
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
	desc = "Шлем защитного костюма плазмолюда, созданный специально для священника."
	ru_names = list(
		NOMINATIVE = "защитный шлем священника",
		GENITIVE = "защитного шлема священника",
		DATIVE = "защитному шлему священника",
		ACCUSATIVE = "защитный шлем священника",
		INSTRUMENTAL = "защитным шлемом священника",
		PREPOSITIONAL = "защитном шлеме священника"
	)
	icon_state = "chap_envirohelm"
	item_state = "chap_envirohelm"
	armor = list("melee" = 20, "bullet" = 7, "laser" = 2, "energy" = 2, "bomb" = 2, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 80)

/obj/item/clothing/head/helmet/space/plasmaman/white
	name = "white plasma envirosuit helmet"
	desc = "Обычный белый защитный шлем."
	ru_names = list(
		NOMINATIVE = "защитный шлем плазмолюда белого цвета",
		GENITIVE = "защитного шлема плазмолюда белого цвета",
		DATIVE = "защитному шлему плазмолюда белого цвета",
		ACCUSATIVE = "защитный шлем плазмолюда белого цвета",
		INSTRUMENTAL = "защитным шлемом плазмолюда белого цвета",
		PREPOSITIONAL = "защитном шлеме плазмолюда белого цвета"
	)
	icon_state = "white_envirohelm"
	item_state = "white_envirohelm"
	examine_extensions = EXAMINE_HUD_SCIENCE

/obj/item/clothing/head/helmet/space/plasmaman/nt
	name = "nanotrasen plasma envirosuit helmet"
	desc = "Обычный белый защитный шлем."
	ru_names = list(
		NOMINATIVE = "защитный шлем НаноТрейзен",
		GENITIVE = "защитного шлема НаноТрейзен",
		DATIVE = "защитному шлему НаноТрейзен",
		ACCUSATIVE = "защитный шлем НаноТрейзен",
		INSTRUMENTAL = "защитным шлемом НаноТрейзен",
		PREPOSITIONAL = "защитном шлеме НаноТрейзен"
	)
	icon_state = "white_envirohelm"
	item_state = "white_envirohelm"
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/head/helmet/space/plasmaman/nt_rep
	name = "nanotrasen representative envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для представителя НаноТрейзен."
	ru_names = list(
		NOMINATIVE = "защитный шлем представителя НаноТрейзен",
		GENITIVE = "защитного шлема представителя НаноТрейзен",
		DATIVE = "защитному шлему представителя НаноТрейзен",
		ACCUSATIVE = "защитный шлем представителя НаноТрейзен",
		INSTRUMENTAL = "защитным шлемом представителя НаноТрейзен",
		PREPOSITIONAL = "защитном шлеме представителя НаноТрейзен"
	)
	icon_state = "ntrep_envirohelm"
	item_state = "ntrep_envirohelm"
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = EXAMINE_HUD_SKILLS

/obj/item/clothing/head/helmet/space/plasmaman/chef
	name = "chef plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для поваров."
	ru_names = list(
		NOMINATIVE = "защитный шлем повара",
		GENITIVE = "защитного шлема повара",
		DATIVE = "защитному шлему повара",
		ACCUSATIVE = "защитный шлем повара",
		INSTRUMENTAL = "защитным шлемом повара",
		PREPOSITIONAL = "защитном шлеме повара"
	)
	icon_state = "chef_envirohelm"
	item_state = "chef_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/librarian
	name = "librarian's plasma envirosuit helmet"
	desc = "Прототип защитного костюма плазмолюда, созданный в качестве первой попытки решить логистические проблемы с наймом плазмолюдов. Такие шлема ценятся коллекционерами."
	ru_names = list(
		NOMINATIVE = "защитный шлем библиотекаря",
		GENITIVE = "защитного шлема библиотекаря",
		DATIVE = "защитному шлему библиотекаря",
		ACCUSATIVE = "защитный шлем библиотекаря",
		INSTRUMENTAL = "защитным шлемом библиотекаря",
		PREPOSITIONAL = "защитном шлеме библиотекаря"
	)
	icon_state = "prototype_envirohelm"
	item_state = "prototype_envirohelm"
	actions_types = list(/datum/action/item_action/toggle_welding_screen/plasmaman)
	visor_icon = "prototype_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/botany
	name = "botany plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для ботаников."
	ru_names = list(
		NOMINATIVE = "защитный шлем ботаника",
		GENITIVE = "защитного шлема ботаника",
		DATIVE = "защитному шлему ботаника",
		ACCUSATIVE = "защитный шлем ботаника",
		INSTRUMENTAL = "защитным шлемом ботаника",
		PREPOSITIONAL = "защитном шлеме ботаника"
	)
	icon_state = "botany_envirohelm"
	item_state = "botany_envirohelm"
	clothing_flags = THICKMATERIAL
	HUDType = DATA_HUD_HYDROPONIC
	examine_extensions = EXAMINE_HUD_BOTANY

/obj/item/clothing/head/helmet/space/plasmaman/janitor
	name = "janitor's plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для уборщиков."
	ru_names = list(
		NOMINATIVE = "защитный шлем уборщика",
		GENITIVE = "защитного шлема уборщика",
		DATIVE = "защитному шлему уборщика",
		ACCUSATIVE = "защитный шлем уборщика",
		INSTRUMENTAL = "защитным шлемом уборщика",
		PREPOSITIONAL = "защитном шлеме уборщика"
	)
	icon_state = "janitor_envirohelm"
	item_state = "janitor_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "mime envirosuit helmet"
	desc = "Краска нанесена поверх шлема, это чудо, что она ещё не сошла. Цвета были выбраны не самые яркие."
	ru_names = list(
		NOMINATIVE = "защитный шлем мима",
		GENITIVE = "защитного шлема мима",
		DATIVE = "защитному шлему мима",
		ACCUSATIVE = "защитный шлем мима",
		INSTRUMENTAL = "защитным шлемом мима",
		PREPOSITIONAL = "защитном шлеме мима"
	)
	icon_state = "mime_envirohelm"
	item_state = "mime_envirohelm"
	visor_icon = "mime_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/clown
	name = "clown envirosuit helmet"
	desc = "Краска нанесена поверх шлема, это чудо, что она ещё не сошла. <i>'ХОНК!'</i>"
	ru_names = list(
		NOMINATIVE = "защитный шлем клоуна",
		GENITIVE = "защитного шлема клоуна",
		DATIVE = "защитному шлему клоуна",
		ACCUSATIVE = "защитный шлем клоуна",
		INSTRUMENTAL = "защитным шлемом клоуна",
		PREPOSITIONAL = "защитном шлеме клоуна"
	)
	icon_state = "clown_envirohelm"
	item_state = "clown_envirohelm"
	visor_icon = "clown_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/hop
	name = "head of personnel envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для главы персонала."
	ru_names = list(
		NOMINATIVE = "защитный шлем главы персонала",
		GENITIVE = "защитного шлема главы персонала",
		DATIVE = "защитному шлему главы персонала",
		ACCUSATIVE = "защитный шлем главы персонала",
		INSTRUMENTAL = "защитным шлемом главы персонала",
		PREPOSITIONAL = "защитном шлеме главы персонала"
	)
	icon_state = "hop_envirohelm"
	item_state = "hop_envirohelm"
	armor = list("melee" = 25, "bullet" = 15, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = EXAMINE_HUD_SKILLS

/obj/item/clothing/head/helmet/space/plasmaman/captain
	name = "captain envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, имеющий множество эмблем и маркировок, демонстрирующих, что их владелец - капитан."
	ru_names = list(
		NOMINATIVE = "защитный шлем капитана",
		GENITIVE = "защитного шлема капитана",
		DATIVE = "защитному шлему капитана",
		ACCUSATIVE = "защитный шлем капитана",
		INSTRUMENTAL = "защитным шлемом капитана",
		PREPOSITIONAL = "защитном шлеме капитана"
	)
	icon_state = "cap_envirohelm"
	item_state = "cap_envirohelm"
	armor = list("melee" = 25, "bullet" = 15, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = EXAMINE_HUD_SKILLS

/obj/item/clothing/head/helmet/space/plasmaman/blueshield
	name = "blueshield envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для офицера \"Синий Щит\"."
	ru_names = list(
		NOMINATIVE = "защитный шлем офицера \"Синий Щит\"",
		GENITIVE = "защитного шлема офицера \"Синий Щит\"",
		DATIVE = "защитному шлему офицера \"Синий Щит\"",
		ACCUSATIVE = "защитный шлем офицера \"Синий Щит\"",
		INSTRUMENTAL = "защитным шлемом офицера \"Синий Щит\"",
		PREPOSITIONAL = "защитном шлеме офицера \"Синий Щит\""
	)
	icon_state = "bs_envirohelm"
	item_state = "bs_envirohelm"
	armor = list("melee" = 35, "bullet" = 30, "laser" = 30,"energy" = 10, "bomb" = 25, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 50)
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = EXAMINE_HUD_MEDICAL

/obj/item/clothing/head/helmet/space/plasmaman/wizard
	name = "wizard plasma envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный чтобы сеять хаос в безопасности и комфорте."
	ru_names = list(
		NOMINATIVE = "магический защитный шлем плазмолюда",
		GENITIVE = "магического защитного шлема плазмолюда",
		DATIVE = "магическому защитному шлему плазмолюда",
		ACCUSATIVE = "магический защитный шлем плазмолюда",
		INSTRUMENTAL = "магическим защитным шлемом плазмолюда",
		PREPOSITIONAL = "магическом защитном шлеме плазмолюда"
	)
	icon_state = "wizard_envirohelm"
	item_state = "wizard_envirohelm"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	magical = TRUE

/obj/item/clothing/head/helmet/space/plasmaman/syndicate
	name = "syndicate officer envirosuit helmet"
	desc = "Тактический шлем защитного костюма плазмолюда, созданный для офицеров Синдиката."
	ru_names = list(
		NOMINATIVE = "защитный шлем офицера Синдиката",
		GENITIVE = "защитного шлема офицера Синдиката",
		DATIVE = "защитному шлему офицера Синдиката",
		ACCUSATIVE = "защитный шлем офицера Синдиката",
		INSTRUMENTAL = "защитным шлемом офицера Синдиката",
		PREPOSITIONAL = "защитном шлеме офицера Синдиката"
	)
	icon_state = "syndicatecentcomm_envirohelm"
	item_state = "syndicatecentcomm_envirohelm"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE


/obj/item/clothing/head/helmet/space/plasmaman/centcomm
	name = "Central command officer envirosuit helmet"
	desc = "Тактический шлем защитного костюма плазмолюда, созданный для офицеров НаноТрейзен."
	ru_names = list(
		NOMINATIVE = "защитный шлем офицера ЦК",
		GENITIVE = "защитного шлема офицера ЦК",
		DATIVE = "защитному шлему офицера ЦК",
		ACCUSATIVE = "защитный шлем офицера ЦК",
		INSTRUMENTAL = "защитным шлемом офицера ЦК",
		PREPOSITIONAL = "защитном шлеме офицера ЦК"
	)
	icon_state = "centcomm_envirohelm"
	item_state = "centcomm_envirohelm"
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = EXAMINE_HUD_SKILLS

/obj/item/clothing/head/helmet/space/plasmaman/mining_medic
	name = "mining medic envirosuit helmet"
	desc = "Шлем защитного костюма плазмолюда, созданный специально для шахтёрских врачей."
	ru_names = list(
		NOMINATIVE = "защитный шлем шахтёрского врача",
		GENITIVE = "защитного шлема шахтёрского врача",
		DATIVE = "защитному шлему шахтёрского врача",
		ACCUSATIVE = "защитный шлем шахтёрского врача",
		INSTRUMENTAL = "защитным шлемом шахтёрского врача",
		PREPOSITIONAL = "защитном шлеме шахтёрского врача"
	)
	icon_state = "mining_medic_envirohelm"
	item_state = "mining_medic_envirohelm"
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = EXAMINE_HUD_MEDICAL
