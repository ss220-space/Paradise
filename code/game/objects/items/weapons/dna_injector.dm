/obj/item/dnainjector
	name = "DNA-Injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "dnainjector"
	item_state = "autoinjector"
	belt_icon = "autoinjector"
	var/block = 0
	var/datum/dna2/record/buf = null
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "biotech=1"

	var/damage_coeff = 1
	var/used = FALSE

	// USE ONLY IN PREMADE SYRINGES.  WILL NOT WORK OTHERWISE.
	var/datatype = 0
	var/value = 0
	var/forcedmutation = FALSE //Will it give the mutation, guaranteed?

/obj/item/dnainjector/Initialize()
	. = ..()
	if(datatype && block)
		buf = new
		buf.dna = new
		buf.types = datatype
		buf.dna.ResetSE()
		SetValue(value)

/obj/item/dnainjector/Destroy()
	QDEL_NULL(buf)
	return ..()


/obj/item/dnainjector/update_icon_state()
	icon_state = "[initial(icon_state)][used ? "0" : ""]"


/obj/item/dnainjector/update_desc(updates = ALL)
	. = ..()
	desc = used ? "[initial(desc)] This one is used up." : initial(desc)


/obj/item/dnainjector/proc/GetRealBlock(selblock)
	if(selblock == 0)
		return block
	else
		return selblock

/obj/item/dnainjector/proc/GetState(selblock = 0)
	var/real_block = GetRealBlock(selblock)
	if(buf.types & DNA2_BUF_SE)
		return buf.dna.GetSEState(real_block)
	else
		return buf.dna.GetUIState(real_block)

/obj/item/dnainjector/proc/SetState(on, selblock = 0)
	var/real_block = GetRealBlock(selblock)
	if(buf.types & DNA2_BUF_SE)
		return buf.dna.SetSEState(real_block,on)
	else
		return buf.dna.SetUIState(real_block,on)

/obj/item/dnainjector/proc/GetValue(selblock = 0)
	var/real_block = GetRealBlock(selblock)
	if(buf.types & DNA2_BUF_SE)
		return buf.dna.GetSEValue(real_block)
	else
		return buf.dna.GetUIValue(real_block)

/obj/item/dnainjector/proc/SetValue(val, selblock = 0)
	var/real_block = GetRealBlock(selblock)
	if(buf.types & DNA2_BUF_SE)
		return buf.dna.SetSEValue(real_block,val)
	else
		return buf.dna.SetUIValue(real_block,val)


/obj/item/dnainjector/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(used)
		to_chat(user, span_warning("This injector is used up!"))
		return ATTACK_CHAIN_PROCEED

	. = ATTACK_CHAIN_PROCEED_SUCCESS
	target.apply_effect(rand(20 / (damage_coeff  ** 2), 50 / (damage_coeff  ** 2)), IRRADIATE, 0, 1)

	if(!ishuman(target) || HAS_TRAIT(target, TRAIT_NO_DNA))
		return .

	if(!user.IsAdvancedToolUser())
		return .

	if(!buf)
		log_runtime(EXCEPTION("[src] used by [user] on [target] failed to initialize properly."), src)
		return .

	var/attack_log = "injected with the Isolated [name]"

	if(buf.types & DNA2_BUF_SE)
		if(block)
			if(GetState() && block == GLOB.monkeyblock)
				attack_log = "injected with the Isolated [name] (MONKEY)"
				message_admins("[ADMIN_LOOKUPFLW(user)] injected [key_name_admin(target)] with the Isolated [name] <span class='warning'>(MONKEY)</span>")

		else
			if(GetState(GLOB.monkeyblock))
				attack_log = "injected with the Isolated [name] (MONKEY)"
				message_admins("[ADMIN_LOOKUPFLW(user)] injected [key_name_admin(target)] with the Isolated [name] <span class='warning'>(MONKEY)</span>")

	if(target != user)
		target.visible_message(
			span_danger("[user] is trying to inject [target] with [src]!"),
			span_userdanger("[user] is trying to inject [target] with [src]!"),
		)
		if(!do_after(user, 3 SECONDS, target, NONE))
			return .
		target.visible_message(
			span_danger("[user] injects [target] with the syringe with [src]!"),
			span_userdanger("[user] injects [target] with the syringe with [src]!"),
		)
	else
		to_chat(user, span_notice("You inject yourself with [src]."))

	add_attack_logs(user, target, attack_log, ATKLOG_ALL)
	used = TRUE
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
	INVOKE_ASYNC(src, PROC_REF(async_update), target)	//Some mutations have sleeps in them, like monkey


/obj/item/dnainjector/proc/async_update(mob/living/carbon/human/target)
	var/datum/dna/target_dna = target.dna
	var/prev_UE = target_dna.unique_enzymes

	// UI in syringe
	if(buf.types & DNA2_BUF_UI)
		if(!block) //isolated block?
			target_dna.UI = buf.dna.UI.Copy()
			target_dna.UpdateUI()
			target.UpdateAppearance()

			if(buf.types & DNA2_BUF_UE) //unique enzymes? yes
				target.real_name = buf.dna.real_name
				target.name = buf.dna.real_name
				target_dna.real_name = buf.dna.real_name
				target_dna.unique_enzymes = buf.dna.unique_enzymes
		else
			target_dna.SetUIValue(block, GetValue())
			target.UpdateAppearance()

	// SE in syringe
	if(buf.types & DNA2_BUF_SE)
		if(!block) //isolated block?
			target_dna.SE = buf.dna.SE.Copy()
			target_dna.UpdateSE()
		else
			target_dna.SetSEValue(block, GetValue())
		target.check_genes(forcedmutation ? MUTCHK_FORCED : NONE)

	target.sync_organ_dna(assimilate = FALSE, old_ue = prev_UE)


/obj/item/dnainjector/hulkmut
	name = "DNA-Injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/hulkmut/Initialize()
	block = GLOB.hulkblock
	return ..()

/obj/item/dnainjector/antihulk
	name = "DNA-Injector (Anti-Hulk)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antihulk/Initialize()
	block = GLOB.hulkblock
	return ..()

/obj/item/dnainjector/xraymut
	name = "DNA-Injector (X-ray)"
	desc = "Finally you can see what the Captain does."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/xraymut/Initialize()
	block = GLOB.xrayblock
	return ..()

/obj/item/dnainjector/antixray
	name = "DNA-Injector (Anti-X-ray)"
	desc = "It will make you see harder."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antixray/Initialize()
	block = GLOB.xrayblock
	return ..()

/obj/item/dnainjector/farvisionmut
	name = "DNA-Injector (Far vision)"
	desc = "This will make you far-sighted."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/farvisionmut/Initialize()
	block = GLOB.farvisionblock
	return ..()

/obj/item/dnainjector/antifarvision
	name = "DNA-Injector (Anti-Far vision)"
	desc = "This will make you normal-sighted."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antifarvision/Initialize()
	block = GLOB.farvisionblock
	return ..()

/obj/item/dnainjector/firemut
	name = "DNA-Injector (Fire)"
	desc = "Gives you fire."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/firemut/Initialize()
	block = GLOB.fireblock
	return ..()

/obj/item/dnainjector/antifire
	name = "DNA-Injector (Anti-Fire)"
	desc = "Cures fire."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antifire/Initialize()
	block = GLOB.fireblock
	return ..()

/obj/item/dnainjector/telemut
	name = "DNA-Injector (Tele.)"
	desc = "Super brain man!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/telemut/Initialize()
	block = GLOB.teleblock
	return ..()

/obj/item/dnainjector/telemut/darkbundle
	name = "DNA-injector"
	desc = "Good. Let the hate flow through you."


/obj/item/dnainjector/antitele
	name = "DNA-Injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antitele/Initialize()
	block = GLOB.teleblock
	return ..()

/obj/item/dnainjector/nobreath
	name = "DNA-Injector (Breathless)"
	desc = "Hold your breath and count to infinity."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/nobreath/Initialize()
	block = GLOB.breathlessblock
	return ..()

/obj/item/dnainjector/antinobreath
	name = "DNA-Injector (Anti-Breathless)"
	desc = "Hold your breath and count to 100."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antinobreath/Initialize()
	block = GLOB.breathlessblock
	return ..()

/obj/item/dnainjector/remoteview
	name = "DNA-Injector (Remote View)"
	desc = "Stare into the distance for a reason."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/remoteview/Initialize()
	block = GLOB.remoteviewblock
	return ..()

/obj/item/dnainjector/antiremoteview
	name = "DNA-Injector (Anti-Remote View)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antiremoteview/Initialize()
	block = GLOB.remoteviewblock
	return ..()

/obj/item/dnainjector/regenerate
	name = "DNA-Injector (Regeneration)"
	desc = "Healthy but hungry."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/regenerate/Initialize()
	block = GLOB.regenerateblock
	return ..()

/obj/item/dnainjector/antiregenerate
	name = "DNA-Injector (Anti-Regeneration)"
	desc = "Sickly but sated."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antiregenerate/Initialize()
	block = GLOB.regenerateblock
	return ..()

/obj/item/dnainjector/runfast
	name = "DNA-Injector (Increase Run)"
	desc = "Running Man."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/runfast/Initialize()
	block = GLOB.increaserunblock
	return ..()

/obj/item/dnainjector/antirunfast
	name = "DNA-Injector (Anti-Increase Run)"
	desc = "Walking Man."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antirunfast/Initialize()
	block = GLOB.increaserunblock
	return ..()

/obj/item/dnainjector/morph
	name = "DNA-Injector (Morph)"
	desc = "A total makeover."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/morph/Initialize()
	block = GLOB.morphblock
	return ..()

/obj/item/dnainjector/antimorph
	name = "DNA-Injector (Anti-Morph)"
	desc = "Cures identity crisis."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antimorph/Initialize()
	block = GLOB.morphblock
	return ..()

/obj/item/dnainjector/noprints
	name = "DNA-Injector (No Prints)"
	desc = "Better than a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/noprints/Initialize()
	block = GLOB.noprintsblock
	return ..()

/obj/item/dnainjector/antinoprints
	name = "DNA-Injector (Anti-No Prints)"
	desc = "Not quite as good as a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antinoprints/Initialize()
	block = GLOB.noprintsblock
	return ..()

/obj/item/dnainjector/insulation
	name = "DNA-Injector (Shock Immunity)"
	desc = "Better than a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/insulation/Initialize()
	block = GLOB.shockimmunityblock
	return ..()

/obj/item/dnainjector/antiinsulation
	name = "DNA-Injector (Anti-Shock Immunity)"
	desc = "Not quite as good as a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antiinsulation/Initialize()
	block = GLOB.shockimmunityblock
	return ..()

/obj/item/dnainjector/midgit
	name = "DNA-Injector (Small Size)"
	desc = "Makes you shrink."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/midgit/Initialize()
	block = GLOB.smallsizeblock
	return ..()

/obj/item/dnainjector/antimidgit
	name = "DNA-Injector (Anti-Small Size)"
	desc = "Makes you grow. But not too much."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antimidgit/Initialize()
	block = GLOB.smallsizeblock
	return ..()

/////////////////////////////////////
/obj/item/dnainjector/antiglasses
	name = "DNA-Injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antiglasses/Initialize()
	block = GLOB.glassesblock
	return ..()

/obj/item/dnainjector/glassesmut
	name = "DNA-Injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/glassesmut/Initialize()
	block = GLOB.glassesblock
	return ..()

/obj/item/dnainjector/epimut
	name = "DNA-Injector (Epi.)"
	desc = "Shake shake shake the room!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/epimut/Initialize()
	block = GLOB.epilepsyblock
	return ..()

/obj/item/dnainjector/antiepi
	name = "DNA-Injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antiepi/Initialize()
	block = GLOB.epilepsyblock
	return ..()

/obj/item/dnainjector/anticough
	name = "DNA-Injector (Anti-Cough)"
	desc = "Will stop that awful noise."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/anticough/Initialize()
	block = GLOB.coughblock
	return ..()

/obj/item/dnainjector/coughmut
	name = "DNA-Injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/coughmut/Initialize()
	block = GLOB.coughblock
	return ..()

/obj/item/dnainjector/clumsymut
	name = "DNA-Injector (Clumsy)"
	desc = "Makes clumsy minions."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/clumsymut/Initialize()
	block = GLOB.clumsyblock
	return ..()

/obj/item/dnainjector/anticlumsy
	name = "DNA-Injector (Anti-Clumy)"
	desc = "Cleans up confusion."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/anticlumsy/Initialize()
	block = GLOB.clumsyblock
	return ..()

/obj/item/dnainjector/antitour
	name = "DNA-Injector (Anti-Tour.)"
	desc = "Will cure tourrets."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antitour/Initialize()
	block = GLOB.twitchblock
	return ..()

/obj/item/dnainjector/tourmut
	name = "DNA-Injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/tourmut/Initialize()
	block = GLOB.twitchblock
	return ..()

/obj/item/dnainjector/stuttmut
	name = "DNA-Injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/stuttmut/Initialize()
	block = GLOB.nervousblock
	return ..()


/obj/item/dnainjector/antistutt
	name = "DNA-Injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antistutt/Initialize()
	block = GLOB.nervousblock
	return ..()

/obj/item/dnainjector/blindmut
	name = "DNA-Injector (Blind)"
	desc = "Makes you not see anything."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/blindmut/Initialize()
	block = GLOB.blindblock
	return ..()

/obj/item/dnainjector/antiblind
	name = "DNA-Injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antiblind/Initialize()
	block = GLOB.blindblock
	return ..()

/obj/item/dnainjector/telemut
	name = "DNA-Injector (Tele.)"
	desc = "Super brain man!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/telemut/Initialize()
	block = GLOB.teleblock
	return ..()

/obj/item/dnainjector/antitele
	name = "DNA-Injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antitele/Initialize()
	block = GLOB.teleblock
	return ..()

/obj/item/dnainjector/deafmut
	name = "DNA-Injector (Deaf)"
	desc = "Sorry, what did you say?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/deafmut/Initialize()
	block = GLOB.deafblock
	return ..()

/obj/item/dnainjector/antideaf
	name = "DNA-Injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antideaf/Initialize()
	block = GLOB.deafblock
	return ..()

/obj/item/dnainjector/hallucination
	name = "DNA-Injector (Halluctination)"
	desc = "What you see isn't always what you get."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/hallucination/Initialize()
	block = GLOB.hallucinationblock
	return ..()

/obj/item/dnainjector/antihallucination
	name = "DNA-Injector (Anti-Hallucination)"
	desc = "What you see is what you get."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/antihallucination/Initialize()
	block = GLOB.hallucinationblock
	return ..()

/obj/item/dnainjector/h2m
	name = "DNA-Injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/h2m/Initialize()
	block = GLOB.monkeyblock
	return ..()

/obj/item/dnainjector/m2h
	name = "DNA-Injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/m2h/Initialize()
	block = GLOB.monkeyblock
	return ..()


/obj/item/dnainjector/comic
	name = "DNA-Injector (Comic)"
	desc = "Honk!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	forcedmutation = TRUE

/obj/item/dnainjector/comic/Initialize()
	block = GLOB.comicblock
	return ..()

/obj/item/dnainjector/anticomic
	name = "DNA-Injector (Anti-Comic)"
	desc = "Honk...?"
	datatype = DNA2_BUF_SE
	value = 0x001
	forcedmutation = TRUE

/obj/item/dnainjector/anticomic/Initialize()
	block = GLOB.comicblock
	return ..()
