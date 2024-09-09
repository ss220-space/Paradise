/obj/item/flag
	name = "flag"
	desc = "It's a flag."
	icon = 'icons/obj/flag.dmi'
	icon_state = "ntflag"
	lefthand_file = 'icons/mob/inhands/flags_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/flags_righthand.dmi'
	item_flags = NO_PIXEL_RANDOM_DROP
	w_class = WEIGHT_CLASS_BULKY
	max_integrity = 40
	resistance_flags = FLAMMABLE
	custom_fire_overlay = "fire"
	var/rolled = FALSE


/obj/item/flag/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !is_hot(I) || (resistance_flags & ON_FIRE))
		return .
	. |= ATTACK_CHAIN_SUCCESS
	user.visible_message(
		span_warning("[user] lights [src] with [I]."),
		span_notice("You light [src] with [I]."),
		span_italics("You hear a low whoosh."),
	)
	fire_act()


/obj/item/flag/attack_self(mob/user)
	rolled = !rolled
	user.visible_message("<span class='notice'>[user] [rolled ? "rolls up" : "unfurls"] [src].</span>", "<span class='notice'>You [rolled ? "roll up" : "unfurl"] [src].</span>", "<span class='warning'>You hear fabric rustling.</span>")
	update_icon(UPDATE_ICON_STATE)

/obj/item/flag/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = FALSE)
	..()
	update_icon(UPDATE_ICON_STATE)

/obj/item/flag/extinguish()
	..()
	update_icon(UPDATE_ICON_STATE)


/obj/item/flag/update_icon_state()
	updateFlagIcon()
	item_state = icon_state
	if(rolled)
		icon_state = "[icon_state]_rolled"
		custom_fire_overlay = "fire_rolled"
	else
		custom_fire_overlay = initial(custom_fire_overlay)
	if(resistance_flags & ON_FIRE)
		item_state = "[item_state]_fire"
	update_equipped_item(update_speedmods = FALSE)


/obj/item/flag/proc/updateFlagIcon()
	icon_state = initial(icon_state)


/obj/item/flag/nt
	name = "Nanotrasen flag"
	desc = "A flag proudly boasting the logo of NT."
	icon_state = "ntflag"

/obj/item/flag/clown
	name = "Clown Planet flag"
	desc = "The banner of His Majesty, King Squiggles the Eighth."
	icon_state = "clownflag"

/obj/item/flag/mime
	name = "Mime Revolution flag"
	desc = "The banner of the glorious revolutionary forces fighting the oppressors on Clown Planet."
	icon_state = "mimeflag"

/obj/item/flag/ian
	name = "Ian flag"
	desc = "The banner of Ian, because SQUEEEEE."
	icon_state = "ianflag"


//Species flags

/obj/item/flag/species/slime
	name = "Slime People flag"
	desc = "A flag proudly proclaiming the superior heritage of Slime People."
	icon_state = "slimeflag"

/obj/item/flag/species/skrell
	name = "Skrell flag"
	desc = "A flag proudly proclaiming the superior heritage of Skrell."
	icon_state = "skrellflag"

/obj/item/flag/species/vox
	name = "Vox flag"
	desc = "A flag proudly proclaiming the superior heritage of Vox."
	icon_state = "voxflag"

/obj/item/flag/species/machine
	name = "Synthetics flag"
	desc = "A flag proudly proclaiming the superior heritage of Synthetics."
	icon_state = "machineflag"

/obj/item/flag/species/diona
	name = "Diona flag"
	desc = "A flag proudly proclaiming the superior heritage of Dionae."
	icon_state = "dionaflag"

/obj/item/flag/species/human
	name = "Human flag"
	desc = "A flag proudly proclaiming the superior heritage of Humans."
	icon_state = "humanflag"

/obj/item/flag/species/greys
	name = "Greys flag"
	desc = "A flag proudly proclaiming the superior heritage of Greys."
	icon_state = "greysflag"

/obj/item/flag/species/kidan
	name = "Kidan flag"
	desc = "A flag proudly proclaiming the superior heritage of Kidan."
	icon_state = "kidanflag"

/obj/item/flag/species/taj
	name = "Tajaran flag"
	desc = "A flag proudly proclaiming the superior heritage of Tajaran."
	icon_state = "tajflag"

/obj/item/flag/species/unathi
	name = "Unathi flag"
	desc = "A flag proudly proclaiming the superior heritage of Unathi."
	icon_state = "unathiflag"

/obj/item/flag/species/vulp
	name = "Vulpkanin flag"
	desc = "A flag proudly proclaiming the superior heritage of Vulpkanin."
	icon_state = "vulpflag"

/obj/item/flag/species/drask
	name = "Drask flag"
	desc = "A flag proudly proclaiming the superior heritage of Drask."
	icon_state = "draskflag"

/obj/item/flag/species/plasma
	name = "Plasmaman flag"
	desc = "A flag proudly proclaiming the superior heritage of Plasmamen."
	icon_state = "plasmaflag"

/obj/item/flag/species/nian
	name = "NIAN flag"
	desc = "A flag proudly proclaiming the superior heritage of Nian."
	icon_state = "nianflag"

/obj/item/flag/species/wryn
	name = "Wryn flag"
	desc = "A flag proudly proclaiming the superior heritage of Wryn."
	icon_state = "wrynflag"

//Department Flags

/obj/item/flag/cargo
	name = "Cargonia flag"
	desc = "The flag of the independent, sovereign nation of Cargonia."
	icon_state = "cargoflag"

/obj/item/flag/med
	name = "Medistan flag"
	desc = "The flag of the independent, sovereign nation of Medistan."
	icon_state = "medflag"

/obj/item/flag/sec
	name = "Brigston flag"
	desc = "The flag of the independent, sovereign nation of Brigston."
	icon_state = "secflag"

/obj/item/flag/rnd
	name = "Scientopia flag"
	desc = "The flag of the independent, sovereign nation of Scientopia."
	icon_state = "rndflag"

/obj/item/flag/atmos
	name = "Atmosia flag"
	desc = "The flag of the independent, sovereign nation of Atmosia."
	icon_state = "atmosflag"

/obj/item/flag/command
	name = "Command flag"
	desc = "The flag of the independent, sovereign nation of Command."
	icon_state = "ntflag"

//Antags

/obj/item/flag/grey
	name = "Greytide flag"
	desc = "A banner made from an old grey jumpsuit."
	icon_state = "greyflag"

/obj/item/flag/syndi
	name = "Syndicate flag"
	desc = "A flag proudly boasting the logo of the Syndicate, in defiance of NT."
	icon_state = "syndiflag"

/obj/item/flag/wiz
	name = "Wizard Federation flag"
	desc = "A flag proudly boasting the logo of the Wizard Federation, sworn enemies of NT."
	icon_state = "wizflag"

/obj/item/flag/cult
	name = "Nar'Sie Cultist flag"
	desc = "A flag proudly boasting the logo of the cultists, sworn enemies of NT."
	icon_state = "cultflag"

/obj/item/flag/ninja
	name = "Spider Clan flag"
	desc = "A flag proudly boasting the logo of the fearfull Spider Clan, known for their assassins, they work for the ones who pay them most."
	icon_state = "ninjaflag"

/obj/item/flag/ussp
	name = "USSP flag"
	desc = "A flag proudly boasting the logo of the Union of Soviet Socialist Planets, proclaiming the superior heritage of Revolution and Soviet People."
	icon_state = "usspflag"

//Chameleon

/obj/item/flag/chameleon
	name = "Chameleon flag"
	desc = "A poor recreation of the official NT flag. It seems to shimmer a little."
	icon_state = "ntflag"
	origin_tech = "syndicate=1;magnets=4"
	var/updated_icon_state = null
	var/used = FALSE
	var/obj/item/grenade/boobytrap = null
	var/mob/trapper = null


/obj/item/flag/chameleon/Initialize(mapload)
	updated_icon_state = icon_state
	. = ..()


/obj/item/flag/chameleon/Destroy()
	QDEL_NULL(boobytrap)
	return ..()


/obj/item/flag/chameleon/attack_self(mob/user)
	if(used)
		return ..()

	var/list/flag_types = typesof(/obj/item/flag) - list(/obj/item/flag, /obj/item/flag/chameleon, /obj/item/flag/chameleon/depot)
	var/list/flag = list()

	for(var/flag_type in flag_types)
		var/obj/item/flag/F = new flag_type
		flag[capitalize(F.name)] = F

	var/list/show_flag = list("EXIT" = null) + sortList(flag)

	var/input_flag = input(user, "Choose a flag to disguise as.", "Choose a flag.") in show_flag

	if(user && (src in user.contents))

		var/obj/item/flag/chosen_flag = flag[input_flag]

		if(chosen_flag && !used)
			name = chosen_flag.name
			icon_state = chosen_flag.icon_state
			updated_icon_state = icon_state
			desc = chosen_flag.desc
			used = TRUE


/obj/item/flag/chameleon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/grenade))
		if(boobytrap)
			to_chat(user, span_warning("There is already [boobytrap] installed."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		boobytrap = I
		trapper = user
		to_chat(user, span_notice("You hide [I] in the [src]. It will detonate some time after the flag is lit on fire."))
		var/turf/bombturf = get_turf(src)
		add_game_logs("has hidden [I] in the [src] ready for detonation at [AREACOORD(bombturf)].", user)
		investigate_log("[key_name_log(user)] has hidden [I] in the [src] ready for detonation.", INVESTIGATE_BOMB)
		add_attack_logs(user, src, "has hidden [I] ready for detonation in", ATKLOG_MOST)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(is_hot(I) && !(resistance_flags & ON_FIRE) && boobytrap && trapper)
		var/turf/bombturf = get_turf(src)
		add_game_logs("has lit the [src] trapped with [boobytrap] by [key_name_log(trapper)] at [AREACOORD(bombturf)].", user)
		investigate_log("[key_name_log(user)] has lit the [src] trapped with [boobytrap] by [key_name_log(trapper)].", INVESTIGATE_BOMB)
		add_attack_logs(user, src, "has lit (booby trapped with [boobytrap]", ATKLOG_FEW)
		burn()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/flag/chameleon/screwdriver_act(mob/user, obj/item/I)
	if(!boobytrap || user != trapper)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You remove [boobytrap] from [src].</span>")
	boobytrap.forceMove(get_turf(src))
	boobytrap = null
	trapper = null

/obj/item/flag/chameleon/burn()
	if(boobytrap)
		fire_act()
		addtimer(CALLBACK(src, PROC_REF(prime_boobytrap)), boobytrap.det_time)
	else
		..()

/obj/item/flag/chameleon/proc/prime_boobytrap()
	boobytrap.forceMove(get_turf(loc))
	boobytrap.prime()
	boobytrap = null
	burn()

/obj/item/flag/chameleon/updateFlagIcon()
	icon_state = updated_icon_state

/obj/item/flag/chameleon/depot/New()
	..()
	boobytrap = new /obj/item/grenade/gas/plasma(src)
