//this is designed to replace the destructive analyzer

#define SCANTYPE_POKE 1
#define SCANTYPE_IRRADIATE 2
#define SCANTYPE_GAS 3
#define SCANTYPE_HEAT 4
#define SCANTYPE_COLD 5
#define SCANTYPE_OBLITERATE 6
#define SCANTYPE_DISCOVER 7

#define EFFECT_PROB_VERYLOW 20
#define EFFECT_PROB_LOW 35
#define EFFECT_PROB_MEDIUM 50
#define EFFECT_PROB_HIGH 75
#define EFFECT_PROB_VERYHIGH 95

#define FAIL 8
/obj/machinery/r_n_d/experimentor
	name = "E.X.P.E.R.I-MENTOR"
	icon = 'icons/obj/machines/heavy_lathe.dmi'
	icon_state = "h_lathe"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	var/recentlyExperimented = FALSE
	var/mob/trackedIan
	var/mob/trackedRuntime
	var/badThingCoeff = 0
	var/resetTime = 15
	var/cloneMode = FALSE
	var/cloneCount = 0
	var/clone_next = FALSE // Clones the next inserted technological item.
	/// The distance to your rnd console. Useful for creative mapping.
	var/console_dist = 3
	var/list/item_reactions = list()
	var/list/valid_items = list() //valid items for special reactions like transforming
	var/list/critical_items = list() //items that can cause critical reactions


/obj/machinery/r_n_d/experimentor/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD


/obj/machinery/r_n_d/experimentor/LateInitialize()
	. = ..()
	console_connect()


/obj/machinery/r_n_d/experimentor/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/* //uncomment to enable forced reactions.
/obj/machinery/r_n_d/experimentor/verb/forceReaction()
	set name = "Force Experimentor Reaction"
	set category = "Debug"
	set src in oview(1)
	var/reaction = input(usr,"What reaction?") in list(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)
	var/oldReaction = item_reactions["[loaded_item.type]"]
	item_reactions["[loaded_item.type]"] = reaction
	experiment(item_reactions["[loaded_item.type]"],loaded_item)
	spawn(10)
		if(loaded_item)
			item_reactions["[loaded_item.type]"] = oldReaction
*/

/obj/machinery/r_n_d/experimentor/proc/SetTypeReactions()
	var/probWeight = 0
	for(var/I in typesof(/obj/item))
		if(istype(I,/obj/item/relic))
			continue
		item_reactions["[I]"] = pick(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)
		if(ispath(I,/obj/item/stock_parts) || ispath(I,/obj/item/grenade/chem_grenade) || ispath(I,/obj/item/kitchen))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null) //check it's an actual usable item, in a hacky way
				valid_items += 15
				valid_items += I
				probWeight++

		if(ispath(I,/obj/item/reagent_containers/food))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null) //check it's an actual usable item, in a hacky way
				valid_items += rand(1,max(2,35-probWeight))
				valid_items += I

		if(ispath(I,/obj/item/rcd) || ispath(I,/obj/item/grenade) || ispath(I,/obj/item/aicard) || ispath(I,/obj/item/storage/backpack/holding) || ispath(I,/obj/item/slime_extract) || ispath(I,/obj/item/onetankbomb) || ispath(I,/obj/item/transfer_valve))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null)
				critical_items += I


/obj/machinery/r_n_d/experimentor/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/experimentor(src)
	component_parts += new /obj/item/stock_parts/scanning_module(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	spawn(1)
		trackedIan = locate(/mob/living/simple_animal/pet/dog/corgi/Ian) in GLOB.mob_living_list
		trackedRuntime = locate(/mob/living/simple_animal/pet/cat/Runtime) in GLOB.mob_living_list
	SetTypeReactions()
	RefreshParts()

/obj/machinery/r_n_d/experimentor/RefreshParts()
	badThingCoeff = initial(badThingCoeff)
	resetTime = initial(resetTime)
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		resetTime -= M.rating
	for(var/obj/item/stock_parts/scanning_module/M in component_parts)
		badThingCoeff += M.rating*2
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		badThingCoeff += M.rating

/obj/machinery/r_n_d/experimentor/proc/checkCircumstances(obj/item/O)
	//snowflake check to only take "made" bombs
	if(istype(O,/obj/item/transfer_valve))
		var/obj/item/transfer_valve/T = O
		if(!T.tank_one || !T.tank_two || !T.attached_device)
			return FALSE
	return TRUE


/obj/machinery/r_n_d/experimentor/update_icon_state()
	icon_state = "h_lathe[recentlyExperimented ? "_wloop" : ""]"


/obj/machinery/r_n_d/experimentor/attackby(obj/item/I, mob/user, params)
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	add_fingerprint(user)
	if(disabled)
		to_chat(user, span_warning("The [name] is offline."))
		return ATTACK_CHAIN_PROCEED

	if(!linked_console)
		to_chat(user, span_warning("The [name] should be linked to an R&D console first."))
		return ATTACK_CHAIN_PROCEED

	if(loaded_item)
		to_chat(user, span_warning("The [name] is already loaded."))
		return ATTACK_CHAIN_PROCEED

	if(!checkCircumstances(I))
		to_chat(user, span_warning("The [I.name] is not yet valid for [src] and must be completed."))
		return ATTACK_CHAIN_PROCEED

	if(!I.origin_tech)
		to_chat(user, span_warning("The [I.name] has no technological origin."))
		return ATTACK_CHAIN_PROCEED

	if(clone_next)
		var/list/temp_tech = ConvertReqString2List(I.origin_tech)
		var/techs_sum = 0
		for(var/T in temp_tech)
			techs_sum += temp_tech[T]

		if(istype(I, /obj/item/relic) || (techs_sum > 4 || isstorage(I)) && !istype(I, /obj/item/storage/backpack/holding))
			to_chat(user, span_warning("Этот предмет слишком сложен для копирования. Попробуйте вставить что-то попроще."))
			return ATTACK_CHAIN_PROCEED

		if (I.type in subtypesof(/obj/item/stack))
			var/obj/item/stack/stack = I
			if (stack.amount > 1)
				to_chat(user, span_warning("Предмет должен быть цельным."))
				return ATTACK_CHAIN_PROCEED

		investigate_log("Experimentor has made a clone of [I]", INVESTIGATE_EXPERIMENTOR)
		throwSmoke(get_turf(pick(oview(1,src))))
		for (var/i = 1; i <= badThingCoeff; i++)
			visible_message(span_notice("A duplicate [I] pops out!"))
			var/type_to_make = I.type
			new type_to_make(get_turf(pick(oview(1,src))))

		clone_next = FALSE
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(I, src))
		return ATTACK_CHAIN_PROCEED

	loaded_item = I
	to_chat(user, span_notice("You have added [I] to [src]."))
	flick("h_lathe_load", src)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/machinery/r_n_d/experimentor/screwdriver_act(mob/living/user, obj/item/I)
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return TRUE
	. = default_deconstruction_screwdriver(user, "h_lathe_maint", "h_lathe", I)
	if(. && linked_console)
		linked_console.linked_destroy = null
		linked_console = null


/obj/machinery/r_n_d/experimentor/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return .
	if(!panel_open)
		add_fingerprint(user)
		to_chat(user, span_warning("Open the maintenance panel first."))
		return .
	ejectItem()
	default_deconstruction_crowbar(user, I)


/obj/machinery/r_n_d/experimentor/attack_hand(mob/user)
	if(..())
		return TRUE

	add_fingerprint(user)
	user.set_machine(src)
	var/dat = {"<meta charset="UTF-8"><center>"}
	if(!linked_console)
		dat += "<b><a href='byond://?src=[UID()];function=search'>Scan for R&D Console</A></b><br>"
	if(loaded_item)
		dat += "<b>Loaded Item:</b> [loaded_item]<br>"
		dat += "<b>Technology</b>:<br>"
		var/list/D = ConvertReqString2List(loaded_item.origin_tech)
		for(var/T in D)
			dat += "[T]<br>"
		dat += "<br><br>Available tests:"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_POKE]'>Poke</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_IRRADIATE];'>Irradiate</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_GAS]'>Gas</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_HEAT]'>Burn</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_COLD]'>Freeze</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_OBLITERATE]'>Destroy</A></b><br>"
		dat += "<br><b><a href='byond://?src=[UID()];function=eject'>Eject</A>"
	else
		dat += "<b>Nothing loaded.</b>"
	dat += "<br><a href='byond://?src=[UID()];function=refresh'>Refresh</A><br>"
	dat += "<br><a href='byond://?src=[UID()];close=1'>Close</A><br></center>"
	var/datum/browser/popup = new(user, "experimentor","Experimentor", 700, 400, src)
	popup.set_content(dat)
	popup.open()


/obj/machinery/r_n_d/experimentor/proc/matchReaction(matching,reaction)
	var/obj/item/D = matching
	if(D)
		if(istype(D, /obj/item/relic) || item_reactions.Find("[D.type]"))
			var/tor = item_reactions["[D.type]"]
			if(istype(D, /obj/item/relic) || tor == text2num(reaction))
				return text2num(reaction)
			else
				return FAIL
		else
			return FAIL
	else
		return FAIL

/obj/machinery/r_n_d/experimentor/proc/ejectItem(delete=FALSE)
	if(loaded_item)
		if(cloneMode && cloneCount > 0)
			visible_message("<span class='notice'>A duplicate [loaded_item] pops out!</span>")
			var/type_to_make = loaded_item.type
			new type_to_make(get_turf(pick(oview(1,src))))
			--cloneCount
			if(cloneCount == 0)
				cloneMode = FALSE
			return
		var/turf/dropturf = get_turf(pick(view(1,src)))
		if(!dropturf) //Failsafe to prevent the object being lost in the void forever.
			dropturf = get_turf(src)
		loaded_item.loc = dropturf
		if(delete)
			qdel(loaded_item)
		loaded_item = null

/obj/machinery/r_n_d/experimentor/proc/throwSmoke(turf/where)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1,0, where, 0)
	smoke.start()

/obj/machinery/r_n_d/experimentor/proc/pickWeighted(list/from)
	var/result = FALSE
	var/counter = 1
	while(!result)
		var/probtocheck = from[counter]
		if(prob(probtocheck))
			result = TRUE
			return from[counter+1]
		if(counter + 2 < from.len)
			counter = counter + 2
		else
			counter = 1

/obj/machinery/r_n_d/experimentor/proc/scan_poke(exp, obj/item/exp_on, chosenchem, criticalReaction, isRelict)
	visible_message("[src] prods at [exp_on] with mechanical arms.")
	if(!isRelict)
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("[exp_on] is gripped in just the right way, enhancing its focus.")
			badThingCoeff++
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions and destroys [exp_on], lashing its arms out at nearby people!</span>")
			for(var/mob/living/m in oview(1, src))
				m.apply_damage(15,BRUTE,pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN))
				investigate_log("Experimentor dealt minor brute to [key_name_log(m)].", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions!</span>")
			exp = SCANTYPE_OBLITERATE
		if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, throwing the [exp_on]!</span>")
			var/mob/living/target = locate(/mob/living) in oview(7,src)
			if(target)
				var/obj/item/throwing = loaded_item
				investigate_log("Experimentor has thrown [loaded_item] at [key_name_log(target)]", INVESTIGATE_EXPERIMENTOR)
				ejectItem()
				if(throwing)
					throwing.throw_at(target, 10, 1)
	else if(prob(EFFECT_PROB_VERYLOW))
		visible_message("<span class='warning'>The [exp_on] begins to vibrate!</span>")
		playsound(src.loc, 'sound/effects/supermatter.ogg', 50, 3, -1)
		ejectItem()
		throwSmoke(get_turf(exp_on))
		var/obj/item/relict_production/strange_teleporter/teleporter = new /obj/item/relict_production/strange_teleporter(get_turf(exp_on))
		teleporter.icon_state = exp_on.icon_state
		qdel(exp_on)
	else
		exp = FAIL


/obj/machinery/r_n_d/experimentor/proc/scan_irradiate(exp, obj/item/exp_on, chosenchem, criticalReaction, isRelict)
	visible_message("<span class='danger'>[src] reflects radioactive rays at [exp_on]!</span>")
	if(!isRelict)
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("[exp_on] has activated an unknown subroutine!")
			cloneMode = TRUE
			cloneCount = badThingCoeff
			investigate_log("Experimentor has made a clone of [exp_on]", INVESTIGATE_EXPERIMENTOR)
			ejectItem()
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, melting [exp_on] and leaking radiation!</span>")
			for(var/mob/living/m in oview(1, src))
				m.apply_effect(25,IRRADIATE)
				investigate_log("Experimentor has irradiated [key_name_log(m)]", INVESTIGATE_EXPERIMENTOR) //One entry per person so we know what was irradiated.
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, spewing toxic waste!</span>")
			for(var/turf/T in oview(1, src))
				if(!T.density)
					if(prob(EFFECT_PROB_VERYHIGH))
						new /obj/effect/decal/cleanable/greenglow(T)
		if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			var/savedName = "[exp_on]"
			ejectItem(TRUE)
			var/newPath = pickWeighted(valid_items)
			loaded_item = new newPath(src)
			visible_message("<span class='warning'>[src] malfunctions, transforming [savedName] into [loaded_item]!</span>")
			investigate_log("Experimentor has transformed [savedName] into [loaded_item]", INVESTIGATE_EXPERIMENTOR)
			if(istype(loaded_item,/obj/item/grenade/chem_grenade))
				var/obj/item/grenade/chem_grenade/CG = loaded_item
				CG.prime()
			ejectItem()
	else if(prob(EFFECT_PROB_VERYLOW))
		visible_message("<span class='warning'>The [exp_on] has activated an unknown subroutine!</span>")
		clone_next = TRUE
		ejectItem()
		qdel(exp_on)

		var/T = rand(1, linked_console.files.known_tech.len)
		var/datum/tech/KT = linked_console.files.known_tech[linked_console.files.known_tech[T]]
		var/new_level = linked_console.files.UpdateTech(linked_console.files.known_tech[T], KT.level + 1)
		var/tech_log = "[T] [new_level], "
		if(tech_log)
			investigate_log("[usr] increased tech experimentoring [loaded_item]: [tech_log]. ", INVESTIGATE_RESEARCH)
	else
		exp = FAIL


/obj/machinery/r_n_d/experimentor/proc/scan_gas(exp, obj/item/exp_on, chosenchem, criticalReaction, isRelict)
	visible_message("<span class='warning'>[src] fills its chamber with gas, [exp_on] included.</span>")
	if(!isRelict)
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("[exp_on] achieves the perfect mix!")
			new /obj/item/stack/sheet/mineral/plasma(get_turf(pick(oview(1,src))))
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] destroys [exp_on], leaking dangerous gas!</span>")
			chosenchem = pick("carbon","radium","toxin","condensedcapsaicin","psilocybin","space_drugs","ethanol","beepskysmash")
			var/datum/reagents/inner_reagent = new/datum/reagents(400)
			inner_reagent.my_atom = src
			inner_reagent.add_reagent(chosenchem , 375)
			investigate_log("Experimentor has released [chosenchem] smoke.", INVESTIGATE_EXPERIMENTOR)
			var/datum/effect_system/smoke_spread/chem/smoke = new
			smoke.set_up(inner_reagent, src, TRUE)
			playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			qdel(inner_reagent)
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src]'s chemical chamber has sprung a leak!</span>")
			chosenchem = pick("mutationtoxin","nanomachines","sacid")
			var/datum/reagents/inner_reagent = new/datum/reagents(400)
			inner_reagent.my_atom = src
			inner_reagent.add_reagent(chosenchem , 375)
			var/datum/effect_system/smoke_spread/chem/smoke = new
			smoke.set_up(inner_reagent, src, TRUE)
			playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			qdel(inner_reagent)
			ejectItem(TRUE)
			warn_admins(usr, "[chosenchem] smoke")
			investigate_log("Experimentor has released <font color='red'>[chosenchem]</font> smoke!", INVESTIGATE_EXPERIMENTOR)
		if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("[src] malfunctions, spewing harmless gas.>")
			throwSmoke(src.loc)
		if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] melts [exp_on], ionizing the air around it!</span>")
			empulse(src.loc, 4, 0) //change this to 4,6 once the EXPERI-Mentor is moved.
			investigate_log("Experimentor has generated an Electromagnetic Pulse.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
	else if(prob(EFFECT_PROB_LOW))
		visible_message("[exp_on] achieves the perfect mix!")
		playsound(src.loc, 'sound/effects/supermatter.ogg', 50, 3, -1)
		ejectItem()
		throwSmoke(get_turf(exp_on))
		new /obj/item/relict_production/perfect_mix(get_turf(exp_on))
		qdel(exp_on)
	else
		exp = FAIL


/obj/machinery/r_n_d/experimentor/proc/scan_heat(exp, obj/item/exp_on, chosenchem, criticalReaction, isRelict)
	visible_message("[src] raises [exp_on]'s temperature.")
	if(!isRelict)
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("<span class='warning'>[src]'s emergency coolant system gives off a small ding!</span>")
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			var/obj/item/reagent_containers/food/drinks/coffee/C = new /obj/item/reagent_containers/food/drinks/coffee(get_turf(pick(oview(1,src))))
			chosenchem = pick("plasma","capsaicin","ethanol")
			C.reagents.remove_any(25)
			C.reagents.add_reagent(chosenchem , 50)
			C.name = "Cup of Suspicious Liquid"
			C.desc = "It has a large hazard symbol printed on the side in fading ink."
			investigate_log("Experimentor has made a cup of [chosenchem] coffee.", INVESTIGATE_EXPERIMENTOR)
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			var/turf/start = get_turf(src)
			var/mob/M = locate(/mob/living) in view(src, 3)
			var/turf/MT = get_turf(M)
			if(MT)
				visible_message("<span class='danger'>[src] dangerously overheats, launching a flaming fuel orb!</span>")
				investigate_log("Experimentor has launched a <font color='red'>fireball</font> at [key_name_log(M)]!", INVESTIGATE_EXPERIMENTOR)
				var/obj/item/projectile/magic/fireball/FB = new /obj/item/projectile/magic/fireball(start)
				FB.original = MT
				FB.current = start
				FB.yo = MT.y - start.y
				FB.xo = MT.x - start.x
				FB.fire()
		if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, melting [exp_on] and releasing a burst of flame!</span>")
			explosion(src.loc, -1, 0, 0, 0, 0, flame_range = 2, cause = "Experimentor Fire")
			investigate_log("Experimentor started a fire.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, melting [exp_on] and leaking hot air!</span>")
			var/datum/gas_mixture/env = src.loc.return_air()
			var/transfer_moles = 0.25 * env.total_moles()
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			if(removed)
				var/heat_capacity = removed.heat_capacity()
				if(heat_capacity == 0 || heat_capacity == null)
					heat_capacity = 1
				removed.temperature = min((removed.temperature*heat_capacity + 100000)/heat_capacity, 1000)
			env.merge(removed)
			air_update_turf()
			investigate_log("Experimentor has released hot air.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, activating its emergency coolant systems!</span>")
			throwSmoke(src.loc)
			for(var/mob/living/m in oview(1, src))
				m.apply_damage(5,BURN,pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN))
				investigate_log("Experimentor has dealt minor burn damage to [key_name_log(m)]", INVESTIGATE_EXPERIMENTOR)
			ejectItem()
	else if(prob(EFFECT_PROB_LOW))
		visible_message("[exp_on] begins to shake, and in the distance the sound of rampaging animals arises!")
		playsound(src.loc, 'sound/effects/supermatter.ogg', 50, 3, -1)
		ejectItem()
		throwSmoke(get_turf(exp_on))
		var/obj/item/relict_production/pet_spray/R = new /obj/item/relict_production/pet_spray(get_turf(exp_on))
		R.icon_state = exp_on.icon_state
		qdel(exp_on)
	else
		exp = FAIL


/obj/machinery/r_n_d/experimentor/proc/scan_cold(exp, obj/item/exp_on, chosenchem, criticalReaction, isRelict)
	visible_message("[src] lowers [exp_on]'s temperature.")
	if(!isRelict)
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("<span class='warning'>[src]'s emergency coolant system gives off a small ding!</span>")
			var/obj/item/reagent_containers/food/drinks/coffee/C = new /obj/item/reagent_containers/food/drinks/coffee(get_turf(pick(oview(1,src))))
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1) //Ding! Your death coffee is ready!
			chosenchem = pick("uranium","frostoil","ephedrine")
			C.reagents.remove_any(25)
			C.reagents.add_reagent(chosenchem , 50)
			C.name = "Cup of Suspicious Liquid"
			C.desc = "It has a large hazard symbol printed on the side in fading ink."
			investigate_log("Experimentor has made a cup of [chosenchem] coffee.", INVESTIGATE_EXPERIMENTOR)
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, shattering [exp_on] and releasing a dangerous cloud of coolant!</span>")
			var/datum/reagents/inner_reagent = new/datum/reagents(400)
			inner_reagent.my_atom = src
			inner_reagent.add_reagent("frostoil" , 375)
			investigate_log("Experimentor has released frostoil gas.", INVESTIGATE_EXPERIMENTOR)
			var/datum/effect_system/smoke_spread/chem/smoke = new
			smoke.set_up(inner_reagent, src, TRUE)
			playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			qdel(inner_reagent)
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, shattering [exp_on] and leaking cold air!</span>")
			var/datum/gas_mixture/env = src.loc.return_air()
			var/transfer_moles = 0.25 * env.total_moles()
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			if(removed)
				var/heat_capacity = removed.heat_capacity()
				if(heat_capacity == 0 || heat_capacity == null)
					heat_capacity = 1
				removed.temperature = (removed.temperature*heat_capacity - 75000)/heat_capacity
			env.merge(removed)
			air_update_turf()
			investigate_log("Experimentor has released cold air.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, releasing a flurry of chilly air as [exp_on] pops out!</span>")
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(1,0, src.loc, 0)
			smoke.start()
			ejectItem()
	else if(prob(EFFECT_PROB_LOW))
		visible_message("[exp_on] emits a loud pop!")
		playsound(src.loc, 'sound/effects/supermatter.ogg', 50, 3, -1)
		ejectItem()
		throwSmoke(get_turf(exp_on))
		var/obj/item/relict_production/R = new /obj/item/relict_production/rapid_dupe(get_turf(exp_on))
		R.icon_state = exp_on.icon_state
		qdel(exp_on)
	else
		exp = FAIL


/obj/machinery/r_n_d/experimentor/proc/scan_obliterate(exp, obj/item/exp_on, chosenchem, criticalReaction, isRelict)
	visible_message("<span class='warning'>[exp_on] activates the crushing mechanism.</span>")
	if(!isRelict)
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("<span class='warning'>[src]'s crushing mechanism slowly and smoothly descends, flattening the [exp_on]!</span>")
			new /obj/item/stack/sheet/plasteel(get_turf(pick(oview(1,src))))
		if(linked_console.linked_lathe)
			var/datum/component/material_container/linked_materials = linked_console.linked_lathe.GetComponent(/datum/component/material_container)
			for(var/material in exp_on.materials)
				linked_materials.insert_amount( min((linked_materials.max_amount - linked_materials.total_amount), (exp_on.materials[material])), material)
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src]'s crusher goes way too many levels too high, crushing right through space-time!</span>")
			playsound(src.loc, 'sound/effects/supermatter.ogg', 50, 1, -3)
			investigate_log("Experimentor has triggered the 'throw things' reaction.", INVESTIGATE_EXPERIMENTOR)
			for(var/atom/movable/AM in oview(7,src))
				if(!AM.anchored)
					spawn(0)
						AM.throw_at(src,10,1)

		if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='danger'>[src]'s crusher goes one level too high, crushing right into space-time!</span>")
			playsound(src.loc, 'sound/effects/supermatter.ogg', 50, 1, -3)
			investigate_log("Experimentor has triggered the 'minor throw things' reaction.", INVESTIGATE_EXPERIMENTOR)
			var/list/throwAt = list()
			for(var/atom/movable/AM in oview(7,src))
				if(!AM.anchored)
					throwAt.Add(AM)
			for(var/counter = 1, counter < throwAt.len, ++counter)
				var/atom/movable/cast = throwAt[counter]
				spawn(0)
					cast.throw_at(pick(throwAt),10,1)
		ejectItem(TRUE)
	else if(prob(EFFECT_PROB_LOW))
		visible_message("<span class='warning'>[src]'s crushing mechanism slowly and smoothly descends, flattening the [exp_on]!</span>")
		badThingCoeff++
		var/list/obj/item/stack/sheet/mineral/minreals = list(/obj/item/stack/sheet/mineral/diamond, /obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/glass,/obj/item/stack/sheet/metal,/obj/item/stack/sheet/mineral/plasma,/obj/item/stack/sheet/mineral/silver,/obj/item/stack/sheet/mineral/titanium,/obj/item/stack/sheet/mineral/uranium,/obj/item/stack/sheet/mineral/tranquillite,/obj/item/stack/sheet/mineral/bananium)
		// Plastinium and abductor alloy are alloys, not processed ores.
		for (var/i = 1; i <= 3; ++i)
			var/obj/item/stack/sheet/mineral/m0 = pick(minreals)
			var/obj/item/stack/sheet/mineral/M = new m0(get_turf(exp_on))
			M.amount = 10
		qdel(exp_on)
		ejectItem(TRUE)
	else
		exp = FAIL


/obj/machinery/r_n_d/experimentor/proc/experiment(exp, obj/item/exp_on)
	recentlyExperimented = TRUE
	update_icon(UPDATE_ICON_STATE)
	var/chosenchem
	var/criticalReaction = (exp_on.type in critical_items) ? TRUE : FALSE
	var/isRelict = istype(exp_on, /obj/item/relic)

	if(exp == SCANTYPE_POKE)
		scan_poke(exp, exp_on, chosenchem, criticalReaction, isRelict)
	if(exp == SCANTYPE_IRRADIATE)
		scan_irradiate(exp, exp_on, chosenchem, criticalReaction, isRelict)
	if(exp == SCANTYPE_GAS)
		scan_gas(exp, exp_on, chosenchem, criticalReaction, isRelict)
	if(exp == SCANTYPE_HEAT)
		scan_heat(exp, exp_on, chosenchem, criticalReaction, isRelict)
	if(exp == SCANTYPE_COLD)
		scan_cold(exp, exp_on, chosenchem, criticalReaction, isRelict)
	if(exp == SCANTYPE_OBLITERATE)
		scan_obliterate(exp, exp_on, chosenchem, criticalReaction, isRelict)

	if(exp == FAIL)
		var/a = pick("rumbles","shakes","vibrates","shudders")
		var/b = pick("crushes","spins","viscerates","smashes","insults")
		visible_message("<span class='warning'>[exp_on] [a], and [b], the experiment was a failure.</span>")

	if(prob(EFFECT_PROB_VERYLOW) && prob(13))
		visible_message("<span class='warning'>Experimentor draws the life essence of those nearby!</span>")
		for(var/mob/living/m in view(4,src))
			to_chat(m, "<span class='danger'>You feel your flesh being torn from you, mists of blood drifting to [src]!</span>")
			m.take_overall_damage(50)
			investigate_log("Experimentor has taken 50 brute a blood sacrifice from [key_name_log(m)]", INVESTIGATE_EXPERIMENTOR)

	if(prob(EFFECT_PROB_VERYLOW-badThingCoeff) && prob(87))
		var/globalMalf = rand(1,87)
		if(globalMalf < 15)
			visible_message("<span class='warning'>[src]'s onboard detection system has malfunctioned!</span>")
			item_reactions["[exp_on.type]"] = pick(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)
			ejectItem()
		if(globalMalf > 16 && globalMalf < 35)
			visible_message("<span class='warning'>[src] melts [exp_on], ian-izing the air around it!</span>")
			throwSmoke(src.loc)
			if(trackedIan)
				throwSmoke(trackedIan.loc)
				trackedIan.forceMove(loc)
				investigate_log("Experimentor has stolen Ian!", INVESTIGATE_EXPERIMENTOR) //...if anyone ever fixes it...
			else
				new /mob/living/simple_animal/pet/dog/corgi(src.loc)
				investigate_log("Experimentor has spawned a new corgi.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		if(globalMalf > 36 && globalMalf < 59)
			visible_message("<span class='warning'>[src] encounters a run-time error!</span>")
			throwSmoke(src.loc)
			if(trackedRuntime)
				throwSmoke(trackedRuntime.loc)
				trackedRuntime.loc = src.loc
				investigate_log("Experimentor has stolen Runtime!", INVESTIGATE_EXPERIMENTOR)
			else
				new /mob/living/simple_animal/pet/cat(src.loc)
				investigate_log("Experimentor failed to steal runtime, and instead spawned a new cat.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		if(globalMalf > 60)
			visible_message("<span class='warning'>[src] begins to smoke and hiss, shaking violently!</span>")
			use_power(500000)
			investigate_log("Experimentor has drained power from its APC", INVESTIGATE_EXPERIMENTOR)

	addtimer(CALLBACK(src, PROC_REF(reset_machine)), resetTime)


/obj/machinery/r_n_d/experimentor/proc/reset_machine()
	recentlyExperimented = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/r_n_d/experimentor/proc/console_connect()
	var/obj/machinery/computer/rdconsole/D = locate(/obj/machinery/computer/rdconsole) in oview(console_dist, src)
	if(D)
		linked_console = D


/obj/machinery/r_n_d/experimentor/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)

	var/scantype = href_list["function"]
	var/obj/item/process = locate(href_list["item"]) in src

	if(href_list["close"])
		usr << browse(null, "window=experimentor")
		return
	else if(scantype == "search")
		console_connect()
	else if(scantype == "eject")
		ejectItem()
	else if(scantype == "refresh")
		src.updateUsrDialog()
	else
		if(recentlyExperimented)
			to_chat(usr, "<span class='warning'>[src] has been used too recently!</span>")
			return
		else if(!loaded_item)
			updateUsrDialog() //Set the interface to unloaded mode
			to_chat(usr, "<span class='warning'>[src] is not currently loaded!</span>")
			return
		else if(!process || process != loaded_item) //Interface exploit protection (such as hrefs or swapping items with interface set to old item)
			updateUsrDialog() //Refresh interface to update interface hrefs
			to_chat(usr, "<span class='danger'>Interface failure detected in [src]. Please try again.</span>")
			return
		var/dotype
		if(text2num(scantype) == SCANTYPE_DISCOVER)
			dotype = SCANTYPE_DISCOVER
		else
			dotype = matchReaction(process,scantype)
		experiment(dotype,process)
		use_power(750)
		if(dotype != FAIL)
			if(process && process.origin_tech)
				var/list/temp_tech = ConvertReqString2List(process.origin_tech)
				var/tech_log
				for(var/T in temp_tech)
					var/new_level = linked_console.files.UpdateTech(T, temp_tech[T])
					if(new_level)
						tech_log += "[T] [new_level], "
				if(tech_log)
					investigate_log("[usr] increased tech experimentoring [loaded_item]: [tech_log]. ", INVESTIGATE_RESEARCH)
	src.updateUsrDialog()
	return

//~~~~~~~~Admin logging proc, aka the Powergamer Alarm~~~~~~~~
/obj/machinery/r_n_d/experimentor/proc/warn_admins(mob/user, ReactionName)
	message_admins("Experimentor reaction: [ReactionName] generated by [key_name_admin(user)] at [ADMIN_COORDJMP(src)]")
	add_game_logs("Experimentor reaction: [ReactionName] generated by [key_name_log(user)] in [COORD(src)]", user)

#undef SCANTYPE_POKE
#undef SCANTYPE_IRRADIATE
#undef SCANTYPE_GAS
#undef SCANTYPE_HEAT
#undef SCANTYPE_COLD
#undef SCANTYPE_OBLITERATE
#undef SCANTYPE_DISCOVER

#undef EFFECT_PROB_VERYLOW
#undef EFFECT_PROB_LOW
#undef EFFECT_PROB_MEDIUM
#undef EFFECT_PROB_HIGH
#undef EFFECT_PROB_VERYHIGH

#undef FAIL

/obj/item/relict_production
	name = "perfect mix"
	desc = "Странный объект без эффекта и иконки. Щитспавн онли."
	icon_state = ""
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "bluespace=3;materials=3"
	var/cooldown = 5 SECONDS
	COOLDOWN_DECLARE(relict_production_cooldown)

/obj/item/relict_production/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, relict_production_cooldown))
		to_chat(user, "<span class='notice'>[src] is not ready yet.</span>")
		return FALSE
	COOLDOWN_START(src, relict_production_cooldown, cooldown)
	return TRUE

/obj/item/relict_production/perfect_mix
	name = "perfect mix"
	desc = "Странный объект из которого можно бесконечно заполнять емкости какой-то жидкостью."
	icon_state = "beaker"
	item_state = "beaker"
	icon = 'icons/obj/weapons/techrelic.dmi'
	lefthand_file = 'icons/mob/inhands/relics_production/inhandl.dmi'
	righthand_file = 'icons/mob/inhands/relics_production/inhandr.dmi'
	origin_tech = "materials=4;bluespace=3"
	var/datum/reagent/inner_reagent
	var/transfer = 10

/obj/item/relict_production/perfect_mix/New()
	. = ..()
	inner_reagent = pick(/datum/reagent/uranium, /datum/reagent/plasma, /datum/reagent/consumable/capsaicin, /datum/reagent/consumable/frostoil, /datum/reagent/space_cleaner, /datum/reagent/consumable/drink/coffee, pick(/datum/reagent/consumable/drink/non_alcoholic_beer, /datum/reagent/consumable/ethanol/beer, /datum/reagent/beer2))

/obj/item/relict_production/perfect_mix/afterattack(atom/target, mob/user, proximity)
	if(istype(target, /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/glass/beaker = target
		beaker.reagents.add_reagent(inner_reagent.id, transfer)
		to_chat(user, "<span class='notice'>You have poured 10 units of content into this.</span>")
	else
		to_chat(user, "<span class='notice'>You can't pour [src]'s content into this.</span>")

/obj/item/relict_production/strange_teleporter
	name = "strange teleporter"
	desc = "Странный объект телепортирующий вас при активации."
	icon_state = "prox-multitool2"
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "materials=4;bluespace=4"
	cooldown = 10 SECONDS

/obj/item/relict_production/strange_teleporter/attack_self(mob/user)
	if(!..())
		return
	to_chat(user, "<span class='notice'>[src] begins to vibrate!</span>")
	spawn(rand(10,30))
		var/turf/userturf = get_turf(user)
		if(src.loc == user && is_teleport_allowed(userturf.z))
			visible_message("<span class='notice'>The [src] twists and bends, relocating itself!</span>")
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(5, get_turf(user))
			smoke.start()
			do_teleport(user, userturf, 8, asoundin = 'sound/effects/phasein.ogg')
			smoke = new
			smoke.set_up(5, get_turf(user))
			smoke.start()

/obj/item/relict_production/pet_spray
	name = "pet spray"
	desc = "Странный объект создающий враждебных существ."
	icon_state = "armor-igniter-analyzer"
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "biotech=5"
	cooldown = 60 SECONDS

/obj/item/relict_production/pet_spray/attack_self(mob/user)
	if(!..())
		return
	var/message = "<span class='danger'>[src] begins to shake, and in the distance the sound of rampaging animals arises!</span>"
	visible_message(message)
	to_chat(user, message)
	var/amount = rand(1,3)
	var/list/possible_mobs = list(/mob/living/simple_animal/hostile/bear,
		/mob/living/simple_animal/hostile/poison/bees,
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/hostile/alien,
		/mob/living/simple_animal/butterfly,
		/mob/living/simple_animal/pet/dog/corgi
	)
	var/mob/to_spawn = pick(possible_mobs)

	for(var/i in 1 to amount)
		var/mob/living/simple_animal/S
		S = new to_spawn(get_turf(src))
		S.faction |= "petSpraySummon"
		S.gold_core_spawnable = HOSTILE_SPAWN
		S.low_priority_targets += user.UID()
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(S, pick(NORTH, SOUTH, EAST, WEST))

	if(prob(60))
		to_chat(user, "<span class='warning'>[src] falls apart!</span>")
		qdel(src)

/obj/item/relict_production/rapid_dupe
	name = "rapid dupe"
	desc = "Странный объект создающий другие странные объекты при контакте с аномалиями."
	icon_state = "shock_kit"
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "materials=5"

//////////////////////////////////SPECIAL ITEMS////////////////////////////////////////

/obj/item/relic
	name = "strange object"
	desc = "What mysteries could this hold?"
	icon_state = "shock_kit"
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"
	var/realName = "defined object"
	var/revealed = FALSE
	var/realProc

/obj/item/relic/New()
	..()
	icon_state = pick("shock_kit","armor-igniter-analyzer","infra-igniter0","infra-igniter1","radio-multitool","prox-radio1","radio-radio","timer-multitool0","radio-igniter-tank")
	realName = "[pick("broken","twisted","spun","improved","silly","regular","badly made")] [pick("device","object","toy","suspicious tech","gear")]"
