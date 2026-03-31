/*
 * Наследуем от саботажника, чтобы иметь возможность легко интегрировать этому боргу свой хамелион проектор
 */
/mob/living/silicon/robot/syndicate/saboteur/ninja
	base_icon = "ninja"
	icon_state = "ninja"
	faction = list(ROLE_NINJA)
	designation = "Spider Clan"
	modtype = /obj/item/robot_module/ninja
	req_access = list(ACCESS_SYNDICATE)
	brute_mod = 0.7 //30% less damage
	burn_mod = 0.7
	playstyle_string = null
	has_transform_animation = FALSE

/mob/living/silicon/robot/syndicate/saboteur/ninja/New(loc)
	..()
	mmi = new /obj/item/mmi/robotic_brain/ninja(src)

/mob/living/silicon/robot/syndicate/saboteur/ninja/init(alien = FALSE, mob/living/silicon/ai/ai_to_sync_to = null)
	. = ..()
	laws = new /datum/ai_laws/ninja_override(src)
	QDEL_NULL(module)	//Удаление модуля саботёра который мы наследуем
	module = new /obj/item/robot_module/ninja(src)
	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)
	radio = new /obj/item/radio/borg/ninja(src)
	radio.recalculate_channels()
	//languages
	module.add_languages(src)
	//subsystems
	module.add_subsystems_and_actions(src)

/obj/item/radio/borg/ninja
	keyslot = new /obj/item/encryptionkey/spider_clan
	freqlock = FALSE
	freerange = TRUE

/obj/item/radio/borg/ninja/Initialize(mapload)
	. = ..()
	set_frequency(NINJA_FREQ)
