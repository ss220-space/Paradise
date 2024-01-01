/obj/item/organ/internal/cyberimp
	name = "cybernetic implant"
	desc = "a state-of-the-art implant that improves a baseline's functionality"
	status = ORGAN_ROBOT
	var/implant_color = "#FFFFFF"
	var/implant_overlay
	tough = TRUE // Immune to damage
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/internal/cyberimp/New(var/mob/M = null)
	. = ..()
	if(implant_overlay)
		var/image/overlay = new /image(icon, implant_overlay)
		overlay.color = implant_color
		overlays |= overlay

/obj/item/organ/internal/cyberimp/emp_act()
	return // These shouldn't be hurt by EMPs in the standard way

//[[[[BRAIN]]]]

/obj/item/organ/internal/cyberimp/brain
	name = "cybernetic brain implant"
	desc = "injectors of extra sub-routines for the brain"
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	parent_organ_zone = BODY_ZONE_HEAD

/obj/item/organ/internal/cyberimp/brain/emp_act(severity)
	if(!owner || emp_proof)
		return
	var/stun_amount = (5 + (severity-1 ? 0 : 5)) STATUS_EFFECT_CONSTANT
	owner.Stun(stun_amount)
	to_chat(owner, "<span class='warning'>Your body seizes up!</span>")
	return stun_amount


/obj/item/organ/internal/cyberimp/brain/anti_drop
	name = "Anti-drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	var/active = FALSE
	var/l_hand_ignore = FALSE
	var/r_hand_ignore = FALSE
	var/obj/item/l_hand_obj = null
	var/obj/item/r_hand_obj = null
	implant_color = "#DE7E00"
	slot = INTERNAL_ORGAN_BRAIN_ANTIDROP
	origin_tech = "materials=4;programming=5;biotech=4"
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/internal/cyberimp/brain/anti_drop/ui_action_click()
	active = !active
	if(active)
		l_hand_obj = owner.l_hand
		r_hand_obj = owner.r_hand
		if(l_hand_obj)
			if(owner.l_hand.flags & NODROP)
				l_hand_ignore = TRUE
			else
				owner.l_hand.flags |= NODROP
				l_hand_ignore = FALSE

		if(r_hand_obj)
			if(owner.r_hand.flags & NODROP)
				r_hand_ignore = TRUE
			else
				owner.r_hand.flags |= NODROP
				r_hand_ignore = FALSE

		if(!l_hand_obj && !r_hand_obj)
			to_chat(owner, "<span class='notice'>You are not holding any items, your hands relax...</span>")
			active = 0
		else
			var/msg = 0
			msg += !l_hand_ignore && l_hand_obj ? 1 : 0
			msg += !r_hand_ignore && r_hand_obj ? 2 : 0
			switch(msg)
				if(1)
					to_chat(owner, "<span class='notice'>Your left hand's grip tightens.</span>")
				if(2)
					to_chat(owner, "<span class='notice'>Your right hand's grip tightens.</span>")
				if(3)
					to_chat(owner, "<span class='notice'>Both of your hand's grips tighten.</span>")
	else
		release_items()
		to_chat(owner, "<span class='notice'>Your hands relax...</span>")
		l_hand_obj = null
		r_hand_obj = null

/obj/item/organ/internal/cyberimp/brain/anti_drop/emp_act(severity)
	if(!owner || emp_proof)
		return
	var/range = severity ? 10 : 5
	var/atom/A
	var/obj/item/L_item = owner.l_hand
	var/obj/item/R_item = owner.r_hand

	release_items()
	..()
	if(L_item)
		A = pick(oview(range))
		L_item.throw_at(A, range, 2)
		to_chat(owner, "<span class='notice'>Your left arm spasms and throws the [L_item.name]!</span>")
		l_hand_obj = null
	if(R_item)
		A = pick(oview(range))
		R_item.throw_at(A, range, 2)
		to_chat(owner, "<span class='notice'>Your right arm spasms and throws the [R_item.name]!</span>")
		r_hand_obj = null

/obj/item/organ/internal/cyberimp/brain/anti_drop/proc/release_items()
	active = FALSE
	if(!l_hand_ignore && (l_hand_obj in owner.contents))
		l_hand_obj.flags ^= NODROP
	if(!r_hand_ignore && (r_hand_obj in owner.contents))
		r_hand_obj.flags ^= NODROP

/obj/item/organ/internal/cyberimp/brain/anti_drop/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	if(active)
		ui_action_click()
	return ..()

/obj/item/organ/internal/cyberimp/brain/anti_stun
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned. Incompatible with the Neural Jumpstarter."
	implant_color = "#FFFF00"
	slot = INTERNAL_ORGAN_BRAIN_ANTISTUN
	origin_tech = "materials=5;programming=4;biotech=5"

/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened
	name = "Hardened CNS Rebooter implant"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened/Initialize(mapload)
	. = ..()
	desc += " The implant has been hardened. It is invulnerable to EMPs."

/obj/item/organ/internal/cyberimp/brain/anti_stun/on_life()
	..()
	if(crit_fail)
		return
	if(owner.getStaminaLoss() > 60)
		owner.adjustStaminaLoss(-9)

/obj/item/organ/internal/cyberimp/brain/anti_stun/emp_act(severity)
	..()
	if(crit_fail || emp_proof)
		return
	crit_fail = TRUE
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/internal/cyberimp/brain/anti_stun/proc/reboot()
	crit_fail = FALSE

/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened
	name = "Hardened CNS Rebooter implant"
	desc = "A military-grade version of the standard implant, for NT's more elite forces."
	origin_tech = "materials=6;programming=5;biotech=5"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/brain/anti_sleep
	name = "Neural Jumpstarter implant"
	desc = "This implant will automatically attempt to jolt you awake when it detects you have fallen unconscious. Has a short cooldown, incompatible with the CNS Rebooter."
	implant_color = "#0356fc"
	slot = INTERNAL_ORGAN_BRAIN_ANTISTUN //one or the other not both.
	origin_tech = "materials=5;programming=4;biotech=5"
	var/cooldown = FALSE

/obj/item/organ/internal/cyberimp/brain/anti_sleep/on_life()
	..()
	if(crit_fail)
		return
	if(owner.stat == UNCONSCIOUS && cooldown == FALSE)
		owner.AdjustSleeping(-200 SECONDS)
		owner.AdjustParalysis(-200 SECONDS)
		to_chat(owner, "<span class='notice'>You feel a rush of energy course through your body!</span>")
		cooldown = TRUE
		addtimer(CALLBACK(src, PROC_REF(sleepy_timer_end)), 50)

/obj/item/organ/internal/cyberimp/brain/anti_sleep/proc/sleepy_timer_end()
		cooldown = FALSE
		to_chat(owner, "<span class='notice'>You hear a small beep in your head as your Neural Jumpstarter finishes recharging.</span>")

/obj/item/organ/internal/cyberimp/brain/anti_sleep/emp_act(severity)
	. = ..()
	if(crit_fail || emp_proof)
		return
	crit_fail = TRUE
	owner.AdjustSleeping(400 SECONDS)
	cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/internal/cyberimp/brain/anti_sleep/proc/reboot()
	crit_fail = FALSE
	cooldown = FALSE

/obj/item/organ/internal/cyberimp/brain/anti_sleep/hardened
	name = "Hardened Neural Jumpstarter implant"
	desc = "A military-grade version of the standard implant, for NT's more elite forces."
	origin_tech = "materials=6;programming=5;biotech=5"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/brain/anti_sleep/hardened/compatible
	name = "Hardened Neural Jumpstarter implant"
	desc = "A military-grade version of the standard implant, for NT's more elite forces. This one is compatible with the CNS Rebooter implant"
	slot = INTERNAL_ORGAN_BRAIN_ANTISLEEP
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/brain/clown_voice
	name = "Comical implant"
	desc = "<span class='sans'>Uh oh.</span>"
	implant_color = "#DEDE00"
	slot = INTERNAL_ORGAN_BRAIN_CLOWNVOICE
	origin_tech = "materials=2;biotech=2"

/obj/item/organ/internal/cyberimp/brain/speech_translator //actual translating done in human/handle_speech_problems
	name = "Speech translator implant"
	desc = "While known as a translator, this implant actually generates speech based on the user's thoughts when activated, completely bypassing the need to speak."
	implant_color = "#C0C0C0"
	slot = INTERNAL_ORGAN_BRAIN_SPEECHTRANSLATOR
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=4;biotech=6"
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/active = TRUE
	var/speech_span = ""
	var/speech_verb = "states"

/obj/item/organ/internal/cyberimp/brain/speech_translator/clown
	name = "Comical speech translator implant"
	implant_color = "#DEDE00"
	speech_span = "sans"

/obj/item/organ/internal/cyberimp/brain/speech_translator/emp_act(severity)
	if(emp_proof)
		return
	if(owner && active)
		to_chat(owner, "<span class='notice'>Your translator's safeties trigger, it is now turned off.</span>")
		active = FALSE

/obj/item/organ/internal/cyberimp/brain/speech_translator/ui_action_click()
	if(owner && !active)
		to_chat(owner, "<span class='notice'>You turn on your translator implant.</span>")
		active = TRUE
	else if(owner && active)
		to_chat(owner, "<span class='notice'>You turn off your translator implant.</span>")
		active = FALSE

//[[[[MOUTH]]]]
/obj/item/organ/internal/cyberimp/mouth
	parent_organ_zone = BODY_ZONE_PRECISE_MOUTH

/obj/item/organ/internal/cyberimp/mouth/breathing_tube
	name = "breathing tube implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	icon_state = "implant_mask"
	slot = INTERNAL_ORGAN_BREATHING_TUBE
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=2;biotech=3"

/obj/item/organ/internal/cyberimp/mouth/breathing_tube/emp_act(severity)
	if(emp_proof)
		return
	if(prob(60/severity) && owner)
		to_chat(owner, "<span class='warning'>Your breathing tube suddenly closes!</span>")
		owner.AdjustLoseBreath(4 SECONDS)

//[[[[CHEST]]]]
/obj/item/organ/internal/cyberimp/chest
	name = "cybernetic torso implant"
	desc = "implants for the organs in your torso"
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	parent_organ_zone = BODY_ZONE_CHEST

/obj/item/organ/internal/cyberimp/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant will synthesize a small amount of nutriment and pumps it directly into your bloodstream when you are starving."
	icon_state = "chest_implant"
	implant_color = "#00AA00"
	var/hunger_modificator = 0.7
	var/poison_amount = 5
	slot = INTERNAL_ORGAN_STOMACH
	origin_tech = "materials=2;powerstorage=2;biotech=2"

/obj/item/organ/internal/cyberimp/chest/nutriment/insert(mob/living/carbon/M, special, dont_remove_slot)
	M.hunger_drain *= hunger_modificator
	. = ..()

/obj/item/organ/internal/cyberimp/chest/nutriment/remove(mob/living/carbon/M, special)
	M.hunger_drain /= hunger_modificator
	. = ..()

/obj/item/organ/internal/cyberimp/chest/nutriment/emp_act(severity)
	if(!owner || emp_proof)
		return
	owner.reagents.add_reagent("????",poison_amount / severity) //food poisoning
	to_chat(owner, "<span class='warning'>You feel like your insides are burning.</span>")

/obj/item/organ/internal/cyberimp/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize a small amount of nutriment and pumps it directly into your bloodstream when you are hungry."
	icon_state = "chest_implant"
	implant_color = "#006607"
	hunger_modificator = 0.5
	poison_amount = 10
	origin_tech = "materials=4;powerstorage=3;biotech=3"

/obj/item/organ/internal/cyberimp/chest/nutriment_old
	name = "Nutriment pump implant"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	icon_state = "chest_implant"
	implant_color = "#00AA00"
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = 0
	var/poison_amount = 5
	slot = INTERNAL_ORGAN_STOMACH
	origin_tech = "materials=2;powerstorage=2;biotech=2"

/obj/item/organ/internal/cyberimp/chest/nutriment_old/on_life()
	if(!owner)
		return
	if(synthesizing)
		return
	if(owner.stat == DEAD)
		return
	if(ismachineperson(owner))
		return
	if(isvampire(owner))
		return
	if(owner.nutrition <= hunger_threshold)
		synthesizing = TRUE
		to_chat(owner, "<span class='notice'>You feel less hungry...</span>")
		owner.adjust_nutrition(50)
		addtimer(CALLBACK(src, PROC_REF(synth_cool)), 50)

/obj/item/organ/internal/cyberimp/chest/nutriment_old/proc/synth_cool()
	synthesizing = FALSE

/obj/item/organ/internal/cyberimp/chest/nutriment_old/emp_act(severity)
	if(!owner || emp_proof)
		return
	owner.reagents.add_reagent("????",poison_amount / severity) //food poisoning
	to_chat(owner, "<span class='warning'>You feel like your insides are burning.</span>")

/obj/item/organ/internal/cyberimp/chest/nutriment_old/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	icon_state = "chest_implant"
	implant_color = "#006607"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY
	poison_amount = 10
	origin_tech = "materials=4;powerstorage=3;biotech=3"

/obj/item/organ/internal/cyberimp/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	icon_state = "chest_implant"
	implant_color = "#AD0000"
	origin_tech = "materials=5;programming=4;biotech=4"
	slot = INTERNAL_ORGAN_HEART_DRIVE
	var/revive_cost = 0
	var/reviving = FALSE
	var/cooldown = 0

/obj/item/organ/internal/cyberimp/chest/reviver/hardened
	name = "Hardened reviver implant"
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/chest/reviver/hardened/Initialize(mapload)
	. = ..()
	desc += " The implant has been hardened. It is invulnerable to EMPs."

/obj/item/organ/internal/cyberimp/chest/reviver/on_life()
	if(cooldown > world.time || owner.suiciding) // don't heal while you're in cooldown!
		return
	if(reviving)
		if(owner.health <= HEALTH_THRESHOLD_CRIT)
			addtimer(CALLBACK(src, PROC_REF(heal)), 30)
		else
			reviving = FALSE
			return
	cooldown = revive_cost + world.time
	revive_cost = 0
	reviving = TRUE

/obj/item/organ/internal/cyberimp/chest/reviver/proc/heal()
	if(QDELETED(owner))
		return
	if(prob(90) && owner.getOxyLoss())
		owner.adjustOxyLoss(-3)
		revive_cost += 5
	if(prob(75) && owner.getBruteLoss())
		owner.adjustBruteLoss(-1)
		revive_cost += 20
	if(prob(75) && owner.getFireLoss())
		owner.adjustFireLoss(-1)
		revive_cost += 20
	if(prob(40) && owner.getToxLoss())
		owner.adjustToxLoss(-1)
		revive_cost += 50


/obj/item/organ/internal/cyberimp/chest/reviver/emp_act(severity)
	if(!owner || emp_proof)
		return
	if(reviving)
		revive_cost += 200
	else
		cooldown += 200
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.stat != DEAD && prob(50 / severity))
			H.set_heartattack(TRUE)
			addtimer(CALLBACK(src, PROC_REF(undo_heart_attack)), 600 / severity)

/obj/item/organ/internal/cyberimp/chest/reviver/proc/undo_heart_attack()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	H.set_heartattack(FALSE)
	if(H.stat == CONSCIOUS)
		to_chat(H, "<span class='notice'>You feel your heart beating again!</span>")

/obj/item/organ/internal/cyberimp/chest/chem_implant
	name = "Chemical sequencer implant"
	desc = "This implant can inject limited list of basic reagents into your blood."
	slot = INTERNAL_ORGAN_CHEM_IMPLANT
	w_class = WEIGHT_CLASS_TINY
	var/charge_capacity = 4
	var/charge = 4
	var/charge_tick = 0
	var/charge_delay = 16
	var/implant_level = 0
	implant_color = "#95C4E6"
	actions_types = list(/datum/action/item_action/hands_free/activate/always)
	var/available_c = list()

/obj/item/organ/internal/cyberimp/chest/chem_implant/plus
	name = "Chemical sequencer implant plus"
	desc = "This implant can inject limited list of advanced reagents into your blood."
	implant_level = 1
	implant_color = "#1F4B6B"

/obj/item/organ/internal/cyberimp/chest/chem_implant/emp_act(severity)
	if(emp_proof)
		return
	if(prob(60/severity) && owner)
		to_chat(owner, "<span class='warning'>Your chemical implant lost it's chargre!</span>")
		charge = 0

/datum/chem_implant
	var/chemname
	var/key
	var/chemdesc = "This is a chemical"
	var/chemuse = 1
	var/quantity = 8
	var/level = 0

/datum/chem_implant/epinephrine
	chemname = "Epinephrine"
	key = "epinephrine"
	chemdesc = "Stabilizes critical condition and slowly heals suffocation damage."

/datum/chem_implant/salglucose
	chemname = "Saline-Glucose Solution"
	key = "salglu_solution"
	chemdesc = "Heals all damage, but it requires more costs."
	quantity = 24

/datum/chem_implant/salbutamol
	chemname = "Salbutamol"
	key = "salbutamol"
	chemdesc = "Heals suffocation damage."
	quantity = 12

/datum/chem_implant/charcoal
	chemname = "Charcoal"
	key = "charcoal"
	chemdesc = "Slowly heals intoxication."
	quantity = 12

/datum/chem_implant/stimulative_agent
	chemname = "Stimulative Agent"
	key = "stimulative_agent"
	chemdesc = "Slowly heals intoxication."
	quantity = 4
	level = 1

/datum/chem_implant/mannitol
	chemname = "Mannitol"
	key = "mannitol"
	chemdesc = "Slowly heals your brain."
	quantity = 12
	level = 1

/datum/chem_implant/earthsblood
	chemname = "Earthsblood"
	key = "earthsblood"
	chemdesc = "Heals all damage, great for restoring wounds, but it's a little heavy on the brain."
	quantity = 8
	level = 1

/obj/item/organ/internal/cyberimp/chest/chem_implant/Initialize()
	for(var/datum in typesof(/datum/chem_implant))
		var/datum/chem_implant/C = datum
		if(initial(C.chemname) && implant_level >= C.level)
			available_c += list(list("name" = initial(C.chemname), "key" = initial(C.key), "desc" = initial(C.chemdesc), "amount" = initial(C.quantity)))
	START_PROCESSING(SSobj, src)


/obj/item/organ/internal/cyberimp/chest/chem_implant/process()
	. = ..()
	charge_tick++
	if(charge_tick >= charge_delay)
		charge_tick = 0
		if (charge < charge_capacity)
			charge++

/obj/item/organ/internal/cyberimp/chest/chem_implant/Destroy()
	STOP_PROCESSING(SSobj, src)

/obj/item/organ/internal/cyberimp/chest/chem_implant/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.not_incapacitated_turf_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ChemImplantSec", "Chemical Implant Interface", 500, 250, master_ui, state)
		ui.open()

/obj/item/organ/internal/cyberimp/chest/chem_implant/ui_data(mob/user)
	var/list/data = list()
	data["dead"] = (owner.stat > UNCONSCIOUS)
	data["health"] = owner.health
	data["current_chemicals"] = charge
	data["available_chemicals"] = available_c
	return data

/obj/item/organ/internal/cyberimp/chest/chem_implant/ui_action_click(mob/user)
	ui_interact(user)

/obj/item/organ/internal/cyberimp/chest/chem_implant/ui_status(mob/user, datum/ui_state/state)
	. = STATUS_CLOSE
	if(user.stat != DEAD)
		. = max(., STATUS_INTERACTIVE)

/obj/item/organ/internal/cyberimp/chest/chem_implant/ui_act(action, list/params)
	if(..() && owner.stat > UNCONSCIOUS)
		return
	switch(action)
		if("secreteChemicals")
			var/mob/living/held = owner
			var/datum/pai_chem/C = null
			for(var/datum in typesof(/datum/chem_implant))
				var/datum/chem_implant/test = datum
				if(initial(test.key) == params["key"])
					C = new test()
					break
			if(!C || !held || !src)
				return
			var/datum/reagent/R = GLOB.chemical_reagents_list[C.key]

			to_chat(owner, "<span class='notice'>You inject [R.name] from your chemical sequncer implant into your bloodstream.</span>")
			owner.reagents.add_reagent(C.key, C.quantity)
			charge -= C.chemuse

//BOX O' IMPLANTS

/obj/item/storage/box/cyber_implants
	name = "boxed cybernetic implant"
	desc = "A sleek, sturdy box."
	icon_state = "cyber_implants"

/obj/item/storage/box/cyber_implants/populate_contents()
	new /obj/item/autoimplanter(src)

/obj/item/storage/box/cyber_implants/thermals/populate_contents()
	..()
	new /obj/item/organ/internal/cyberimp/eyes/thermals(src)

/obj/item/storage/box/cyber_implants/xray/populate_contents()
	..()
	new /obj/item/organ/internal/cyberimp/eyes/xray(src)

/obj/item/storage/box/cyber_implants/reviver_hardened/populate_contents()
	..()
	new /obj/item/organ/internal/cyberimp/chest/reviver/hardened(src)

/obj/item/storage/box/cyber_implants/anti_stun_hardened/populate_contents()
	..()
	new /obj/item/organ/internal/cyberimp/brain/anti_stun/hardened(src)

/obj/item/storage/box/cyber_implants/anti_sleep_hardened/populate_contents()
	..()
	new /obj/item/organ/internal/cyberimp/brain/anti_sleep/hardened(src)

/obj/item/storage/box/cyber_implants/bundle
	name = "boxed cybernetic implants"
	var/list/boxed = list(/obj/item/organ/internal/cyberimp/eyes/xray,/obj/item/organ/internal/cyberimp/eyes/thermals,
						/obj/item/organ/internal/cyberimp/brain/anti_stun/hardened, /obj/item/organ/internal/cyberimp/chest/reviver/hardened)
	var/amount = 5

/obj/item/storage/box/cyber_implants/bundle/populate_contents()
	..()
	var/implant
	while(amount > 0)
		implant = pick(boxed)
		new implant(src)
		amount--
