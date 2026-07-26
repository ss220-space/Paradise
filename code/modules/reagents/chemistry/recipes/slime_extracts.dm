
/datum/chemical_reaction/slime
	abstract_type = /datum/chemical_reaction/slime
	/// amount of loot (count of call spawn_loot proc)
	var/loot_amount = 1

/datum/chemical_reaction/slime/on_reaction(datum/reagents/holder, created_volume)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/turf/spawn_point = get_turf(holder.my_atom)
	if(!spawn_point)
		spawn_point = get_turf(usr)

	var/mob/user = get_mob_by_key(holder.my_atom.fingerprintslast)
	if(!user)
		user = usr
	CALCULATE_SKILL_MOD(user, XENOBIO_DOUBLE_LOOT_MOD, skill_resource_mod)
	var/actual_amount = prob(100 * skill_resource_mod) ? loot_amount * 2 : loot_amount
	for(var/i = 1, i <= actual_amount, i++)
		spawn_loot(holder, spawn_point)

/datum/chemical_reaction/slime/proc/spawn_loot(datum/reagents/holder, turf/spawn_point)
	// override for specific loot spawn
	return


// MARK: Grey
/datum/chemical_reaction/slime/slimespawn
	name = "Slime Spawn"
	id = "m_spawn"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/grey
	required_other = 1

/datum/chemical_reaction/slime/slimespawn/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/mob/living/simple_animal/slime/S = new(spawn_point, "grey")
	S.visible_message(span_danger("Infused with plasma, the core begins to quiver and grow, and a new baby slime emerges from it!"))

/datum/chemical_reaction/slime/slimeinaprov
	name = "Slime epinephrine"
	id = "m_inaprov"
	result = "epinephrine"
	required_reagents = list("water" = 5)
	result_amount = 3
	required_other = 1
	required_container = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime/slimemonkey
	name = "Slime Monkey"
	id = "m_monkey"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/grey
	required_other = 1
	loot_amount = 3

/datum/chemical_reaction/slime/slimemonkey/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/reagent_containers/food/snacks/monkeycube/M = new
	M.forceMove(spawn_point)

// MARK: Green
/datum/chemical_reaction/slime/slimemutate
	name = "Mutation Toxin"
	id = "mutationtoxin"
	result = "mutationtoxin"
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/green

/datum/chemical_reaction/slime/slimepotionbio
	name = "Slime Bio Resistence Potion"
	id = "m_slime_potion_BioR"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/green
	required_other = 1

/datum/chemical_reaction/slime/slimepotionbio/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/clothing/bio/B = new
	B.forceMove(holder)

// MARK: Metal
/datum/chemical_reaction/slime/slimemetal
	name = "Slime Metal"
	id = "m_metal"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/metal
	required_other = 1

/datum/chemical_reaction/slime/slimemetal/spawn_loot(datum/reagents/holder, turf/spawn_point)
	new /obj/item/stack/sheet/plasteel (spawn_point, 5)
	new /obj/item/stack/sheet/metal (spawn_point, 15)

/datum/chemical_reaction/slime/slimeglass
	name = "Slime Glass"
	id = "m_glass"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/metal
	required_other = 1

/datum/chemical_reaction/slime/slimeglass/spawn_loot(datum/reagents/holder, turf/spawn_point)
	new /obj/item/stack/sheet/rglass (spawn_point, 5)
	new /obj/item/stack/sheet/glass (spawn_point, 15)

// MARK: Gold
/datum/chemical_reaction/slime/slimemobspawn
	name = "Slime Crit"
	id = "m_tele"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/gold
	required_other = TRUE

/datum/chemical_reaction/slime/slimemobspawn/spawn_loot(datum/reagents/holder, turf/spawn_point)
	summon_mobs(holder, spawn_point)

/datum/chemical_reaction/slime/slimemobspawn/proc/summon_mobs(datum/reagents/holder, turf/T)
	T.visible_message(span_danger("The slime extract begins to vibrate violently!"))
	if(SSmobs.xenobiology_mobs < MAX_GOLD_CORE_MOBS)
		addtimer(CALLBACK(src, PROC_REF(chemical_mob_spawn), holder, 5, "Gold Slime", HOSTILE_SPAWN, "chemicalsummon", TRUE, TRUE), 50)
		SSmobs.xenobiology_mobs += 5
	else
		T.visible_message(span_danger("The slime extract sputters out, there's too many mobs to make any more!"))

/datum/chemical_reaction/slime/slimemobspawn/lesser
	name = "Slime Crit Lesser"
	id = "m_tele3"
	required_reagents = list("blood" = 1)

/datum/chemical_reaction/slime/slimemobspawn/lesser/summon_mobs(datum/reagents/holder, turf/T)
	T.visible_message(span_danger("The slime extract begins to vibrate violently!"))
	if(SSmobs.xenobiology_mobs < MAX_GOLD_CORE_MOBS)
		addtimer(CALLBACK(src, PROC_REF(chemical_mob_spawn), holder, 3, "Lesser Gold Slime", HOSTILE_SPAWN, "neutral", TRUE, TRUE), 50)
		SSmobs.xenobiology_mobs += 3
	else
		T.visible_message(span_danger("The slime extract sputters out, there's too many mobs to make any more!"))

/datum/chemical_reaction/slime/slimemobspawn/friendly
	name = "Slime Crit Friendly"
	id = "m_tele5"
	required_reagents = list("water" = 1)

/datum/chemical_reaction/slime/slimemobspawn/friendly/summon_mobs(datum/reagents/holder, turf/T)
	T.visible_message(span_danger("The slime extract begins to vibrate adorably!"))
	if(SSmobs.xenobiology_mobs < MAX_GOLD_CORE_MOBS)
		addtimer(CALLBACK(src, PROC_REF(chemical_mob_spawn), holder, 1, "Friendly Gold Slime", FRIENDLY_SPAWN, "neutral", TRUE, TRUE), 50)
		SSmobs.xenobiology_mobs += 1
	else
		T.visible_message(span_danger("The slime extract sputters out, there's too many mobs to make any more!"))

// MARK: Silver
/datum/chemical_reaction/slime/slimebork
	name = "Slime Bork"
	id = "m_tele2"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slime/slimebork/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/list/blocked = list(/obj/item/reagent_containers/food/snacks,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/sliceable,
		/obj/item/reagent_containers/food/snacks/margheritaslice,
		/obj/item/reagent_containers/food/snacks/meatpizzaslice,
		/obj/item/reagent_containers/food/snacks/mushroompizzaslice,
		/obj/item/reagent_containers/food/snacks/vegetablepizzaslice,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat/slab,
		/obj/item/reagent_containers/food/snacks/grown,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/deepfryholder,
		/obj/item/reagent_containers/food/snacks/monstermeat,
		/obj/item/reagent_containers/food/snacks/grown/tomato/debug,
		)
	blocked |= typesof(/obj/item/reagent_containers/food/snacks/customizable)

	var/list/borks = typesof(/obj/item/reagent_containers/food/snacks) - blocked
	// BORK BORK BORK

	playsound(spawn_point, 'sound/effects/phasein.ogg', 100, TRUE)

	for(var/mob/living/carbon/C in viewers(spawn_point, null))
		C.flash_eyes()

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.forceMove(spawn_point)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH, SOUTH, EAST, WEST))

/datum/chemical_reaction/slime/slimebork2
	name = "Slime Bork 2"
	id = "m_tele4"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slime/slimebork2/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/list/borks = subtypesof(/obj/item/reagent_containers/food/drinks)
	var/list/blocked = list(/obj/item/reagent_containers/food/drinks/cans/adminbooze,
							/obj/item/reagent_containers/food/drinks/cans/madminmalt,
							/obj/item/reagent_containers/food/drinks/shaker,
							/obj/item/reagent_containers/food/drinks/britcup,
							/obj/item/reagent_containers/food/drinks/sillycup,
							/obj/item/reagent_containers/food/drinks/cans,
							/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass,
							/obj/item/reagent_containers/food/drinks/drinkingglass,
							/obj/item/reagent_containers/food/drinks/bottle,
							/obj/item/reagent_containers/food/drinks/mushroom_bowl
							)
	blocked += typesof(/obj/item/reagent_containers/food/drinks/flask)
	blocked += typesof(/obj/item/reagent_containers/food/drinks/trophy)
	blocked += typesof(/obj/item/reagent_containers/food/drinks/cans/bottler)
	borks -= blocked
	// BORK BORK BORK

	playsound(spawn_point, 'sound/effects/phasein.ogg', 100, TRUE)

	for(var/mob/living/carbon/M in viewers(spawn_point, null))
		M.flash_eyes()

	for(var/i = 1, i <= 4 + rand(1, 2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.forceMove(spawn_point)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH, SOUTH, EAST, WEST))

// MARK: Blue
/datum/chemical_reaction/slime/slimefrost
	name = "Slime Frost Oil"
	id = "m_frostoil"
	result = "frostoil"
	required_reagents = list("plasma_dust" = 1)
	result_amount = 10
	required_container = /obj/item/slime_extract/blue
	required_other = 1

/datum/chemical_reaction/slime/slimestabilizer
	name = "Slime Stabilizer"
	id = "m_slimestabilizer"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/blue
	required_other = 1

/datum/chemical_reaction/slime/slimestabilizer/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/slime/stabilizer/P = new
	P.forceMove(spawn_point)

// MARK: Dark Blue
/datum/chemical_reaction/slime/slimefreeze
	name = "Slime Freeze"
	id = "m_freeze"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkblue
	required_other = 1

/datum/chemical_reaction/slime/slimefreeze/spawn_loot(datum/reagents/holder, turf/spawn_point)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	spawn_point.visible_message(span_danger("The slime extract begins to vibrate adorably!"))
	addtimer(CALLBACK(src, PROC_REF(delayed_freeze), holder, spawn_point), 5 SECONDS)

/datum/chemical_reaction/slime/slimefreeze/proc/delayed_freeze(datum/reagents/holder, turf/spawn_point)
	playsound(spawn_point, 'sound/effects/phasein.ogg', 100, TRUE)
	for(var/mob/living/victim in range(spawn_point, 7))
		victim.adjust_bodytemperature(-240)
		to_chat(victim, span_notice("You feel a chill!"))

/datum/chemical_reaction/slime/slimefireproof
	name = "Slime Fireproof"
	id = "m_fireproof"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkblue
	required_other = 1

/datum/chemical_reaction/slime/slimefireproof/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/clothing/fireproof/P = new
	P.forceMove(spawn_point)

// MARK: Orange
/datum/chemical_reaction/slime/slimecasp
	name = "Slime Capsaicin Oil"
	id = "m_capsaicinoil"
	result = "capsaicin"
	required_reagents = list("blood" = 1)
	result_amount = 10
	required_container = /obj/item/slime_extract/orange
	required_other = 1

/datum/chemical_reaction/slime/slimefire
	name = "Slime fire"
	id = "m_fire"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/orange
	required_other = 1

/datum/chemical_reaction/slime/slimefire/spawn_loot(datum/reagents/holder, turf/spawn_point)
	spawn_point.visible_message(span_danger("The slime extract begins to vibrate adorably !"))
	addtimer(CALLBACK(src, PROC_REF(reaction_result), holder, spawn_point), 5 SECONDS)

/datum/chemical_reaction/slime/slimefire/proc/reaction_result(datum/reagents/holder, turf/spawn_point)
	if(!holder?.my_atom)
		return

	var/turf/simulated/location = spawn_point
	if(!istype(location))
		return

	var/datum/gas_mixture/air = new()
	air.set_temperature(1000)
	air.set_toxins(20)
	location.blind_release_air(air)

// MARK: Yellow
/datum/chemical_reaction/slime/slimeoverload
	name = "Slime EMP"
	id = "m_emp"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slime/slimeoverload/spawn_loot(datum/reagents/holder, turf/spawn_point)
	empulse(get_turf(holder.my_atom), 3, 7, TRUE, "Slime core")

/datum/chemical_reaction/slime/slimecell
	name = "Slime Powercell"
	id = "m_cell"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slime/slimecell/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/stock_parts/cell/high/slime/P = new
	P.forceMove(spawn_point)

/datum/chemical_reaction/slime/slimeglow
	name = "Slime Glow"
	id = "m_glow"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slime/slimeglow/spawn_loot(datum/reagents/holder, turf/spawn_point)
	spawn_point.visible_message(span_danger("The slime begins to emit a soft light. Squeezing it will cause it to grow brightly."))
	var/obj/item/flashlight/slime/F = new
	F.forceMove(spawn_point)

// MARK: Purple
/datum/chemical_reaction/slime/slimepsteroid
	name = "Slime Steroid"
	id = "m_steroid"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/purple
	required_other = 1

/datum/chemical_reaction/slime/slimepsteroid/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/slime/steroid/P = new
	P.forceMove(spawn_point)

/datum/chemical_reaction/slime/slimejam
	name = "Slime Jam"
	id = "m_jam"
	result = "slimejelly"
	required_reagents = list("sugar" = 1)
	result_amount = 10
	required_container = /obj/item/slime_extract/purple
	required_other = 1

// MARK: Dark Purple
/datum/chemical_reaction/slime/slimeplasma
	name = "Slime Plasma"
	id = "m_plasma"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkpurple
	required_other = 1

/datum/chemical_reaction/slime/slimeplasma/spawn_loot(datum/reagents/holder, turf/spawn_point)
	new /obj/item/stack/sheet/mineral/plasma(spawn_point, 3)

/datum/chemical_reaction/slime/slimeplasmaglass
	name = "Slime Plasma Glass"
	id = "m_plasma_glass"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 2
	required_container = /obj/item/slime_extract/darkpurple
	required_other = 1

/datum/chemical_reaction/slime/slimeplasmaglass/spawn_loot(datum/reagents/holder, turf/spawn_point)
	new /obj/item/stack/sheet/plasmaglass(spawn_point, 2)

// MARK: Red
/datum/chemical_reaction/slime/slimemutator
	name = "Slime Mutator"
	id = "m_slimemutator"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slime/slimemutator/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/slime/mutator/P = new
	P.forceMove(spawn_point)

/datum/chemical_reaction/slime/slimebloodlust
	name = "Bloodlust"
	id = "m_bloodlust"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slime/slimebloodlust/spawn_loot(datum/reagents/holder, turf/spawn_point)
	for(var/mob/living/simple_animal/slime/slime in viewers(spawn_point, null))
		if(slime.docile) //Undoes docility, but doesn't make rabid.
			slime.visible_message(span_danger("[slime] forgets its training, becoming wild once again!"))
			slime.docile = FALSE
			slime.update_appearance(UPDATE_NAME)
			continue
		slime.rabid = 1
		slime.visible_message(span_danger("The [slime] is driven into a frenzy!"))

/datum/chemical_reaction/slime/slimespeed
	name = "Slime Speed"
	id = "m_speed"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slime/slimespeed/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/speed/P = new
	P.forceMove(spawn_point)

// MARK: Pink
/datum/chemical_reaction/slime/docility
	name = "Docility Potion"
	id = "m_potion"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/pink
	required_other = 1

/datum/chemical_reaction/slime/docility/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/slime/docility/P = new
	P.forceMove(spawn_point)

// MARK: Black
/datum/chemical_reaction/slime/slimemutate2
	name = "Advanced Mutation Toxin"
	id = "mutationtoxin2"
	result = "amutationtoxin"
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/black

/datum/chemical_reaction/slime/slimeacid
	name = "Slime Acid Resistence Potion"
	id = "m_slime_potion_AcidR"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/black
	required_other = 1

/datum/chemical_reaction/slime/slimeacid/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/clothing/acidproof/A = new
	A.forceMove(spawn_point)

// MARK: Oil
/datum/chemical_reaction/slime/slimeexplosion
	name = "Slime Explosion"
	id = "m_explosion"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/oil
	required_other = 1

/datum/chemical_reaction/slime/slimeexplosion/spawn_loot(datum/reagents/holder, turf/spawn_point)
	message_admins("[ADMIN_LOOKUPFLW(usr)] has primed a [name] for detonation at [ADMIN_VERBOSEJMP(spawn_point)]")
	add_attack_logs(usr, src, "has primed for detonation", ATKLOG_MOST)
	spawn_point.visible_message(span_danger("The slime extract begins to vibrate violently !"))
	spawn(50)
		if(holder?.my_atom)
			explosion(get_turf(holder.my_atom), devastation_range = 1, heavy_impact_range = 3, light_impact_range = 6, cause = src)

/datum/chemical_reaction/slime/slimepotionexplosion
	name = "Slime Explosion Resistence Potion"
	id = "m_slime_potion_ExplosionR"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/oil
	required_other = 1

/datum/chemical_reaction/slime/slimepotionexplosion/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/clothing/explosionresistencte/E = new
	E.forceMove(spawn_point)

// MARK: Light Pink
/datum/chemical_reaction/slime/slimepotion2
	name = "Slime Potion 2"
	id = "m_potion2"
	result = null
	result_amount = 1
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list("plasma_dust" = 1)
	required_other = 1

/datum/chemical_reaction/slime/slimepotion2/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/sentience/P = new
	P.forceMove(spawn_point)

// MARK: Adamantine
/datum/chemical_reaction/slime/slimegolem
	name = "Slime Golem"
	id = "m_golem"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/adamantine
	required_other = 1

/datum/chemical_reaction/slime/slimegolem/spawn_loot(datum/reagents/holder, turf/spawn_point)
	new /obj/item/stack/sheet/mineral/adamantine(spawn_point)

/datum/chemical_reaction/slime/moenkeylanguage
	name = "Moenky language"
	id = "monkeylanguage"
	result = "monkeylanguage"
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/pink
	required_other = 1

// MARK: Bluespace
/datum/chemical_reaction/slime/slimefloor2
	name = "Bluespace Floor"
	id = "m_floor2"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1

/datum/chemical_reaction/slime/slimefloor2/spawn_loot(datum/reagents/holder, turf/spawn_point)
	new /obj/item/stack/tile/bluespace(spawn_point, 25)

/datum/chemical_reaction/slime/slimeteleportation
	name = "Slime Steroid 2"
	id = "m_steroid2"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1

/datum/chemical_reaction/slime/slimeteleportation/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/clothing/teleportation/T = new
	T.forceMove(spawn_point)

/datum/chemical_reaction/slime/slimecrystal
	name = "Slime Crystal"
	id = "m_crystal"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1

/datum/chemical_reaction/slime/slimecrystal/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/stack/ore/bluespace_crystal/BC = new(spawn_point)
	BC.visible_message(span_notice("The [BC.name] appears out of thin air!"))

// MARK: Cerulean
/datum/chemical_reaction/slime/slimepsteroid2
	name = "Slime Steroid 2"
	id = "m_steroid2"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/cerulean
	required_other = 1

/datum/chemical_reaction/slime/slimepsteroid2/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/enhancer/P = new
	P.forceMove(spawn_point)

/datum/chemical_reaction/slime/slime_territory
	name = "Slime Territory"
	id = "s_territory"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/cerulean
	required_other = 1

/datum/chemical_reaction/slime/slime_territory/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/areaeditor/blueprints/slime/P = new
	P.forceMove(spawn_point)

// MARK: Sepia
/datum/chemical_reaction/slime/slimestop
	name = "Slime Stop"
	id = "m_stop"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slime/slimestop/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/mob/user = get_mob_by_key(holder.my_atom.fingerprintslast)
	var/color_matrix = COLOR_MATRIX_INVERT
	user.add_atom_colour(color_matrix, TEMPORARY_COLOUR_PRIORITY)
	addtimer(CALLBACK(src, PROC_REF(spawn_stoptime), holder), 3 SECONDS)

/datum/chemical_reaction/slime/slimestop/proc/spawn_stoptime(datum/reagents/holder)
	var/mob/user = get_mob_by_key(holder.my_atom.fingerprintslast)
	user.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	new /obj/effect/timestop/slowing(get_turf(holder.my_atom), 2, null, list(user))

/datum/chemical_reaction/slime/slimepotionlaser
	name = "Slime Laser Resistence Potion"
	id = "m_slime_potion_LaserR"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slime/slimepotionlaser/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/clothing/laserresistance/L = new
	L.forceMove(spawn_point)

/datum/chemical_reaction/slime/slimecamera
	name = "Slime Camera"
	id = "m_camera"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slime/slimecamera/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/camera/P = new
	P.forceMove(spawn_point)
	var/obj/item/camera_film/Z = new
	Z.forceMove(spawn_point)

/datum/chemical_reaction/slime/slimefloor
	name = "Sepia Floor"
	id = "m_floor"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slime/slimefloor/spawn_loot(datum/reagents/holder, turf/spawn_point)
	new /obj/item/stack/tile/sepia(spawn_point, 25)

// MARK: Pyrite
/datum/chemical_reaction/slime/slimepaint
	name = "Slime Paint"
	id = "s_paint"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/pyrite
	required_other = 1

/datum/chemical_reaction/slime/slimepaint/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/list/paints = subtypesof(/obj/item/reagent_containers/glass/paint)
	var/chosen = pick(paints)
	var/obj/P = new chosen
	if(P)
		P.forceMove(spawn_point)

// MARK: Rainbow
/datum/chemical_reaction/slime/slimeRNG
	name = "Random Core"
	id = "slimerng"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/slimeRNG/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/mob/living/simple_animal/slime/random/S = new (spawn_point)
	S.visible_message(span_danger("Infused with plasma, the core begins to quiver and grow, and a new baby slime emerges from it!"))

/datum/chemical_reaction/slime/slime_transfer
	name = "Transfer Potion"
	id = "slimetransfer"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/slime_transfer/spawn_loot(datum/reagents/holder, turf/spawn_point)
	var/obj/item/slimepotion/transference/P = new
	P.forceMove(spawn_point)
