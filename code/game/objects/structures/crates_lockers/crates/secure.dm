#define SECURE_CRATE_STAGE_NO_BROKEN 0
#define SECURE_CRATE_STAGE_PANEL_OPEN 3
#define SECURE_CRATE_STAGE_WIRES_PREPARED 2
#define SECURE_CRATE_STAGE_OPENED 1

// MARK: Secure crate
/obj/structure/closet/crate/secure
	name = "secure crate"
	desc = "A secure crate."
	icon_state = "securecrate"
	overlay_locked = "securecrater"
	overlay_unlocked = "securecrateg"
	overlay_sparking = "securecratesparks"
	max_integrity = 500
	armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 80, ACID = 80)
	damage_deflection = 25
	secure = TRUE
	locked = TRUE
	can_be_emaged = TRUE
	overlay_lightmask = "securecrate_lightmask"
	can_be_emissive = TRUE

	var/tamperproof = 0
	/// Overlay for crate with broken lock
	var/overlay_broken = "securecrateemag"

/obj/structure/closet/crate/secure/update_overlays()
	. = ..()
	if(locked)
		. += overlay_locked
	else if(broken && overlay_broken)
		. += overlay_broken
	else
		. += overlay_unlocked

/obj/structure/closet/crate/secure/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	if(prob(tamperproof) && damage_amount >= DAMAGE_PRECISION)
		boom()
	else
		return ..()

/obj/structure/closet/crate/secure/proc/boom(mob/user)
	if(user)
		to_chat(user, span_danger("The crate's anti-tamper system activates!"))
		investigate_log("[key_name_log(user)] has detonated a [src]", INVESTIGATE_BOMB)
		add_attack_logs(user, src, "has detonated", ATKLOG_MOST)
	dump_contents()
	explosion(get_turf(src), heavy_impact_range = 1, light_impact_range = 5, flash_range = 5, cause = src)
	qdel(src)

/obj/structure/closet/crate/secure/click_alt(mob/living/user)
	togglelock(user)
	return CLICK_ACTION_SUCCESS

/obj/structure/closet/crate/secure/closed_item_click(mob/user)
	togglelock(user)

/obj/structure/closet/crate/secure/emag_act(mob/user)
	if(!locked)
		return
	add_attack_logs(user, src, "emagged")
	locked = FALSE
	broken = TRUE
	playsound(loc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	flick_overlay_view(mutable_appearance(icon, overlay_sparking), sparking_duration)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), sparking_duration)
	if(!user)
		return
	balloon_alert(user, "разблокировано")

/obj/structure/closet/crate/secure/emp_act(severity)
	for(var/obj/object in src)
		object.emp_act(severity)
	if(broken || opened)
		return
	if(prob(50 / severity))
		locked = !locked
		playsound(loc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		flick_overlay_view(mutable_appearance(icon, overlay_sparking), sparking_duration)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), sparking_duration)
	if(prob(20 / severity))
		if(locked)
			req_access = list()
			req_access += pick(get_all_accesses())
		else
			open()

/obj/structure/closet/crate/secure/syndicate/emag_act(mob/user)
	if(!locked || broken)
		return
	if(user)
		balloon_alert(user, "не удалось!")
	playsound(loc, 'sound/misc/sadtrombone.ogg', 60, TRUE)

/obj/structure/closet/crate/secure/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!locked || broken != SECURE_CRATE_STAGE_NO_BROKEN || user.a_intent == INTENT_HARM)
		return
	. = TRUE
	balloon_alert(user, "откручиваем панель...")
	if(!tool.use_tool(src, user, 160, volume = tool.tool_volume))
		return
	if(prob(95)) // EZ
		if(broken == SECURE_CRATE_STAGE_PANEL_OPEN)
			return
		balloon_alert(user, "панель снята")
		desc += " Панель управления снята."
		broken = SECURE_CRATE_STAGE_PANEL_OPEN
		//icon_state = icon_off // Crates has no icon_off :(
		return
	// Bad day)
	var/mob/living/carbon/human/human = user
	var/obj/item/organ/external/affecting = human.get_organ(user.r_hand == tool ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
	user.apply_damage(5, BRUTE , affecting)
	user.emote("scream")
	to_chat(user, span_warning("[tool.declent_ru(NOMINATIVE)] сорвал[GEND_SYA_AS_OS_IS(tool)]ась и повредил[GEND_A_O_I(tool)] [affecting.declent_ru(ACCUSATIVE)]!"))

/obj/structure/closet/crate/secure/wirecutter_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!locked || broken != SECURE_CRATE_STAGE_PANEL_OPEN || user.a_intent == INTENT_HARM)
		return
	. = TRUE
	balloon_alert(user, "подготавливаем провода...")
	if(!tool.use_tool(src, user, 16 SECONDS, volume = tool.tool_volume))
		return
	if(prob(80)) // Good hacker!
		if(broken == SECURE_CRATE_STAGE_WIRES_PREPARED)
			return
		balloon_alert(user, "провода подготовлены")
		desc += " Провода отключены и торчат наружу."
		broken = SECURE_CRATE_STAGE_WIRES_PREPARED
		return
	balloon_alert(user, "не тот провод!")
	do_sparks(5, TRUE, src)
	electrocute_mob(user, get_area(src), src, 0.5, TRUE)

/obj/structure/closet/crate/secure/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!locked || broken != SECURE_CRATE_STAGE_WIRES_PREPARED || user.a_intent == INTENT_HARM)
		return
	. = TRUE
	balloon_alert(user, "подключаем провода...")
	if(!tool.use_tool(src, user, 16 SECONDS, volume = tool.tool_volume))
		return
	if(prob(80)) // Good hacker!
		if(broken == SECURE_CRATE_STAGE_NO_BROKEN || broken == SECURE_CRATE_STAGE_OPENED)
			return
		balloon_alert(user, "взломано!")
		desc += " Замок отключён."
		broken = SECURE_CRATE_STAGE_OPENED // Can be emagged
		emag_act(user)
		return
	balloon_alert(user, "не тот провод!")
	do_sparks(5, TRUE, src)
	electrocute_mob(user, get_area(src), src, 0.5, TRUE)

// MARK: Specific secure crates
/obj/structure/closet/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "weapons crate"
	icon_state = "weaponcrate"
	overlay_locked = "heavycrate_locked"
	overlay_unlocked = "heavycrate_unlocked"
	overlay_sparking = "heavycrate_sparks"
	overlay_broken = "heavycrate_hacking"
	overlay_lightmask = "heavysecurecrate_lightmask"

/obj/structure/closet/crate/secure/weapon/veihit
	name = "highrisk crate"
	icon_state = "mortar"
	overlay_locked = "mortar_locked"
	overlay_unlocked = "mortar_unlocked"
	overlay_sparking = "mortar_sparks"
	overlay_broken = "mortar_hacking"
	overlay_lightmask = "mortar_lightmask"

/obj/structure/closet/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "plasma crate"
	icon_state = "plasmacrate"
	overlay_locked = "heavycrate_locked"
	overlay_unlocked = "heavycrate_unlocked"
	overlay_sparking = "heavycrate_sparks"
	overlay_broken = "heavycrate_hacking"
	overlay_lightmask = "heavysecurecrate_lightmask"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "gear crate"
	icon_state = "secgearcrate"

/obj/structure/closet/crate/secure/hydrosec
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	name = "secure hydroponics crate"
	icon_state = "hydrosecurecrate"

/obj/structure/closet/crate/secure/bin
	desc = "A secure bin."
	name = "secure bin"
	icon_state = "largebins"
	overlay_locked = "largebinr"
	overlay_unlocked = "largebing"
	overlay_sparking = "largebinsparks"
	overlay_broken = "largebinemag"

/obj/structure/closet/crate/secure/large
	name = "large crate"
	desc = "A hefty metal crate with an electronic locking system."
	icon_state = "largemetal"
	overlay_locked = "largemetalr"
	overlay_unlocked = "largemetalg"
	overlay_broken = ""

/obj/structure/closet/crate/secure/large/close()
	. = ..()
	if(!.)//we can hold up to one large item
		return
	var/found = FALSE
	for(var/obj/structure/structure in loc)
		if(structure == src)
			continue
		if(structure.anchored)
			continue
		found = TRUE
		structure.forceMove(src)
		break
	if(found)
		return
	for(var/obj/machinery/machinery in loc)
		if(machinery.anchored)
			continue
		machinery.forceMove(src)
		break

/obj/structure/closet/crate/secure/large/reinforced
	desc = "A hefty, reinforced metal crate with an electronic locking system."
	icon_state = "largermetal"

/obj/structure/closet/crate/secure/scisec
	name = "secure science crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's scientists."
	icon_state = "scisecurecrate"

/obj/structure/closet/crate/engineering
	name = "engineering crate"
	desc = "An engineering crate."
	icon_state = "engicrate"

/obj/structure/closet/crate/secure/engineering
	name = "secure engineering crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's engineers."
	icon_state = "engisecurecrate"

/obj/structure/closet/crate/secure/biohazard
	name = "secure biohazard crate"
	desc = "An protected biohazard crate."
	icon_state = "biohazard"

/obj/structure/closet/crate/secure/syndicate
	name = "secure suspicious crate"
	desc = "Definitely a property of an evil corporation! And it has a hardened lock! And a microphone?"
	icon_state = "syndiesecurecrate"
	material_drop = /obj/item/stack/sheet/mineral/plastitanium
	can_be_emaged = FALSE

// MARK: Blood crates
/obj/structure/closet/crate/secure/blood
	name = "secure human blood crate"
	desc = "Ящик, содержащий капельницы с человеческой кровью."
	icon_state = "bloodcrate"
	material_drop = /obj/item/stack/sheet/mineral/plastitanium
	req_access = list(ACCESS_MEDICAL)

/obj/structure/closet/crate/secure/blood/get_ru_names()
	return list(
		NOMINATIVE = "комплект донорской крови (человеческий)",
		GENITIVE = "комплекта донорской крови (человеческий)",
		DATIVE = "комплекту донорской крови (человеческий)",
		ACCUSATIVE = "комплект донорской крови (человеческий)",
		INSTRUMENTAL = "комплектом донорской крови (человеческий)",
		PREPOSITIONAL = "комплекте донорской крови (человеческий)",
	)

/obj/structure/closet/crate/secure/blood/xeno
	name = "secure xenoblood crate"
	desc = "Ящик, содержащий капельницы с кровью различных рас."
	icon_state = "xenobloodcrate"

/obj/structure/closet/crate/secure/blood/xeno/get_ru_names()
	return list(
		NOMINATIVE = "комплект донорской крови (ксено)",
		GENITIVE = "комплекта донорской крови (ксено)",
		DATIVE = "комплекту донорской крови (ксено)",
		ACCUSATIVE = "комплект донорской крови (ксено)",
		INSTRUMENTAL = "комплектом донорской крови (ксено)",
		PREPOSITIONAL = "комплекте донорской крови (ксено)",
	)

/obj/structure/closet/crate/secure/blood/mixed
	name = "secure mixed blood crate"
	desc = "Ящик, содержащий капельницы с различной кровью."
	icon_state = "mixbloodcrate"

/obj/structure/closet/crate/secure/blood/mixed/get_ru_names()
	return list(
		NOMINATIVE = "комплект донорской крови (смешанная)",
		GENITIVE = "комплекта донорской крови (смешанная)",
		DATIVE = "комплекту донорской крови (смешанная)",
		ACCUSATIVE = "комплект донорской крови (смешанная)",
		INSTRUMENTAL = "комплектом донорской крови (смешанная)",
		PREPOSITIONAL = "комплекте донорской крови (смешанная)",
	)

/obj/structure/closet/crate/secure/blood/nitrogenis
	name = "secure nitrogenis blood crate"
	desc = "Ящик, содержащий капельницы с синтетической кровью (Азот)."
	icon_state = "syntheticbloodcrate"

/obj/structure/closet/crate/secure/blood/nitrogenis/get_ru_names()
	return list(
		NOMINATIVE = "комплект донорской крови (синтетическая кровь — азот)",
		GENITIVE = "комплекта донорской крови (синтетическая кровь — азот)",
		DATIVE = "комплекту донорской крови (синтетическая кровь — азот)",
		ACCUSATIVE = "комплект донорской крови (синтетическая кровь — азот)",
		INSTRUMENTAL = "комплектом донорской крови (синтетическая кровь — азот)",
		PREPOSITIONAL = "комплекте донорской крови (синтетическая кровь — азот)",
	)

/obj/structure/closet/crate/secure/blood/oxygenis
	name = "secure synthetic blood crate"
	desc = "Ящик, содержащий капельницы с синтетической кровью (Кислород)."
	icon_state = "nitrogenbloodcrate"

/obj/structure/closet/crate/secure/blood/oxygenis/get_ru_names()
	return list(
		NOMINATIVE = "комплект донорской крови (синтетическая кровь — кислород)",
		GENITIVE = "комплекта донорской крови (синтетическая кровь — кислород)",
		DATIVE = "комплекту донорской крови (синтетическая кровь — кислород)",
		ACCUSATIVE = "комплект донорской крови (синтетическая кровь — кислород)",
		INSTRUMENTAL = "комплектом донорской крови (синтетическая кровь — кислород)",
		PREPOSITIONAL = "комплекте донорской крови (синтетическая кровь — кислород)",
	)

#undef SECURE_CRATE_STAGE_NO_BROKEN
#undef SECURE_CRATE_STAGE_PANEL_OPEN
#undef SECURE_CRATE_STAGE_WIRES_PREPARED
#undef SECURE_CRATE_STAGE_OPENED
