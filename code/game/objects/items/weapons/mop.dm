#define MOP_SOUND_CD 2 SECONDS // How many seconds before the mopping sound triggers again

/obj/item/mop
	name = "mop"
	desc = "The world of janitalia wouldn't be complete without a mop."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	force = 3
	throwforce = 5
	throw_speed = 3
	attack_verb = list("ударил", "огрел")
	resistance_flags = FLAMMABLE
	var/mopping = 0
	var/mopcount = 0
	var/mopcap = 5
	var/mopspeed = 30
	/// The cooldown between each mopping sound effect
	var/mop_sound_cooldown
	/// Max range of mopping.
	var/mop_range = 1
	var/static/list/clean_blacklist = typecacheof(list(
		/obj/item/reagent_containers/glass/bucket,
		/obj/structure/mopbucket,
		/obj/structure/janitorialcart,
	))

/obj/item/mop/Initialize(mapload)
	. = ..()
	create_reagents(mopcap)
	GLOB.janitorial_equipment += src
	AddComponent(/datum/component/cleaner, mopspeed, pre_clean_callback=CALLBACK(src, PROC_REF(should_clean)), on_cleaned_callback = CALLBACK(src, PROC_REF(apply_reagents)))

/obj/item/mop/Destroy()
	GLOB.janitorial_equipment -= src
	return ..()

///Checks whether or not we should clean.
/obj/item/mop/proc/should_clean(datum/cleaning_source, atom/atom_to_clean, mob/living/cleaner)
	if(clean_blacklist[atom_to_clean.type])
		return CLEAN_BLOCKED|CLEAN_DONT_BLOCK_INTERACTION
	if(reagents.total_volume < 0.1)
		cleaner.balloon_alert(cleaner, "mop is dry!")
		return CLEAN_BLOCKED
	/*
	if(reagents.has_reagent(amount = 1/*, chemical_flags = REAGENT_CLEANS*/))
		return CLEAN_ALLOWED
	*/
	if(reagents.has_reagent(/datum/reagent/water, 1) || reagents.has_reagent(/datum/reagent/space_cleaner, 1))
		return CLEAN_ALLOWED
	return CLEAN_ALLOWED|CLEAN_NO_XP|CLEAN_NO_WASH


/**
 * Applies reagents to the cleaned floor and removes them from the mop.
 *
 * Arguments
 * * cleaning_source the source of the cleaning
 * * cleaned_turf the turf that is being cleaned
 * * cleaner the mob that is doing the cleaning
 */
/obj/item/mop/proc/apply_reagents(datum/cleaning_source, turf/cleaned_turf, mob/living/cleaner, clean_succeeded)
	if(!clean_succeeded)
		return
	reagents.reaction(cleaned_turf, REAGENT_TOUCH, 10) //Needed for proper floor wetting.
	var/val2remove = 1
	//if(cleaner?.mind)
		//val2remove = round(cleaner.mind.get_skill_modifier(/datum/skill/cleaning, SKILL_SPEED_MODIFIER), 0.1)
	reagents.remove_all(val2remove) //reaction() doesn't use up the reagents

/obj/item/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal. Just think of all the viscera you will clean up with this!"
	name = "advanced mop"
	mopcap = 10
	icon_state = "advmop"
	item_state = "advmop"
	origin_tech = "materials=3;engineering=3"
	force = 6
	throwforce = 8
	throw_range = 4
	mopspeed = 20
	mop_range = 2
	var/refill_enabled = TRUE //Self-refill toggle for when a janitor decides to mop with something other than water.
	var/refill_rate = 1 //Rate per process() tick mop refills itself
	var/refill_reagent = /datum/reagent/water //Determins what reagent to use for refilling, just in case someone wanted to make a HOLY MOP OF PURGING

/obj/item/mop/advanced/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/mop/advanced/attack_self(mob/user)
	refill_enabled = !refill_enabled
	if(refill_enabled)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	to_chat(user, span_notice("You set the condenser switch to the '[refill_enabled ? "ON" : "OFF"]' position."))
	playsound(user, 'sound/machines/click.ogg', 30, TRUE)

/obj/item/mop/advanced/process()

	if(reagents.total_volume < mopcap)
		reagents.add_reagent(refill_reagent, refill_rate)

/obj/item/mop/advanced/examine(mob/user)
	. = ..()
	. += span_notice("The condenser switch is set to <b>[refill_enabled ? "ON" : "OFF"]</b>.")

/obj/item/mop/advanced/Destroy()
	if(refill_enabled)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mop/advanced/cyborg

#undef MOP_SOUND_CD
