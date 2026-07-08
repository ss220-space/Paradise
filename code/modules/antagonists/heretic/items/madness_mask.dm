// The spooky "void" / "abyssal" / "madness" mask for heretics.
/obj/item/clothing/mask/madness_mask
	name = "madness mask"
	desc = "Маска, созданная из страданий. Когда вы смотрите в щели для глаз, Нечто смотрит оттуда на вас."
	icon_state = "mad_mask"
	item_state = null
	flags_cover = MASKCOVERSEYES
	flags_inv = HIDENAME
	//flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	///Who is wearing this
	var/mob/living/carbon/human/local_user


/obj/item/clothing/mask/madness_mask/get_ru_names()
	return alist(
		NOMINATIVE = "маска безумия",
		GENITIVE = "маски безумия",
		DATIVE = "маске безумия",
		ACCUSATIVE = "маску безумия",
		INSTRUMENTAL = "маской безумия",
		PREPOSITIONAL = "маске безумия",
	)


/obj/item/clothing/mask/madness_mask/Destroy()
	local_user = null
	return ..()


/obj/item/clothing/mask/madness_mask/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		. += span_danger("Эти пустые глазницы пугают вас... Лучше избегать их.")
		return

	. += span_notice("При ношении активно высасывает рассудок и выносливость находящихся рядом язычников.")
	. += span_notice("Если надеть на лицо нееретика, он не сможет добровольно снять её.")


/obj/item/clothing/mask/madness_mask/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_MASK))
		return

	if(!ishuman(user) || !user.mind)
		return

	local_user = user
	START_PROCESSING(SSobj, src)

	if(IS_HERETIC_OR_MONSTER(user))
		return

	ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
	to_chat(user, span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] крепко прижимается к вашему лицу. Вы чувствуете, как ваша душа бьётся в ужасе, пытаясь вырваться из тела!"))


/obj/item/clothing/mask/madness_mask/dropped(mob/M)
	local_user = null
	STOP_PROCESSING(SSobj, src)
	REMOVE_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
	return ..()


/obj/item/clothing/mask/madness_mask/process()
	if(!local_user)
		return PROCESS_KILL

	if(IS_HERETIC_OR_MONSTER(local_user))
		if(HAS_TRAIT(src, TRAIT_NODROP))
			REMOVE_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
	// A non-heretic wearer must never be able to take the mask off, no matter how it ended up on them (heretic strip, etc.).
	else if(!HAS_TRAIT(src, TRAIT_NODROP))
		ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

	for(var/mob/living/carbon/human/human_in_range in view(local_user))
		if(IS_HERETIC_OR_MONSTER(human_in_range) || human_in_range.is_blind())
			continue

		if(human_in_range.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
			continue

		// master220's hallucination STATUS engine gates each fire behind its own cooldown + a 20% roll, so on
		// its own a fresh victim can stand here a minute seeing nothing. Spawn a hallucination DIRECTLY instead,
		// the same reliable trick the "chaos" holoparasite (guardian_hallucination) uses (process ticks every
		// 2s; prob(10) is about one hallucination per ~20s). Draws from the FULL pool incl. the disruptive
		// MAJORS (xeno that attacks, fake bullets, fire, etc.), unlike the moon path's visual-only set.
		// Fired ASYNC because hallucinate_living() can sleep for several seconds and this is a process() tick.
		if(prob(10))
			INVOKE_ASYNC(human_in_range, TYPE_PROC_REF(/mob/living, hallucinate_living), pickweight(GLOB.minor_medium_major_hallutinations))

		// Also keep the ambient hallucination status pinned near TG's 120 SECONDS cap (Hallucinate() only ever
		// raises), so hallucinations keep coming for up to ~120 SECONDS after the victim leaves the mask's sight.
		if(prob(60))
			human_in_range.Hallucinate(120 SECONDS)

		if(prob(40))
			human_in_range.Jitter(10 SECONDS)

		if(human_in_range.getStaminaLoss() <= 85 && prob(30))
			human_in_range.emote(pick("giggle", "laugh"))
			human_in_range.adjustStaminaLoss(10)

		if(prob(25))
			human_in_range.Dizzy(10 SECONDS)
