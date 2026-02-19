/mob/living/carbon/human/examine(mob/user)
	var/skipgloves = 0
	var/skipsuitstorage = 0
	var/skipjumpsuit = 0
	var/skipshoes = 0
	var/skipmask = 0
	var/skipears = 0
	var/skipeyes = 0
	var/skipface = 0
	var/skipprostheses = 0

	//exosuits and helmets obscure our view and stuff.
	if(wear_suit)
		skipgloves = wear_suit.flags_inv & HIDEGLOVES
		skipsuitstorage = wear_suit.flags_inv & HIDESUITSTORAGE
		skipjumpsuit = wear_suit.flags_inv & HIDEJUMPSUIT
		skipshoes = wear_suit.flags_inv & HIDESHOES
		skipprostheses = wear_suit.flags_inv & (HIDEGLOVES|HIDEJUMPSUIT|HIDESHOES)

	if(head)
		skipmask = head.flags_inv & HIDEMASK
		skipeyes = head.flags_inv & HIDEGLASSES
		skipears = head.flags_inv & HIDEHEADSETS
		skipface = head.flags_inv & HIDENAME

	if(wear_mask)
		skipface |= wear_mask.flags_inv & HIDENAME
		skipeyes |= wear_mask.flags_inv & HIDEGLASSES
		skipears |= wear_mask.flags_inv & HIDEHEADSETS

	var/msg = "Это <em>[name]</em>"

	var/displayed_species = get_visible_species()
	var/examine_color = dna.species.flesh_color
	var/ru_species = list(
		SPECIES_ABDUCTOR = "абдуктор",
		SPECIES_DIONA = "диона",
		SPECIES_DRASK = "драск",
		SPECIES_GOLEM_BASIC = "голем",
		SPECIES_GOLEM_RANDOM = "случайный голем",
		SPECIES_GOLEM_ADAMANTINE = "адамантиновый голем",
		SPECIES_GOLEM_PLASMA = "плазменный голем",
		SPECIES_GOLEM_DIAMOND = "алмазный голем",
		SPECIES_GOLEM_GOLD = "золотой голем",
		SPECIES_GOLEM_SILVER = "серебряный голем",
		SPECIES_GOLEM_PLASTEEL = "пласталевый голем",
		SPECIES_GOLEM_TITANIUM = "титановый голем",
		SPECIES_GOLEM_PLASTITANIUM = "пластитановый голем",
		SPECIES_GOLEM_ALLOY = "голем из инопланетных сплавов",
		SPECIES_GOLEM_WOOD = "деревянный голем",
		SPECIES_GOLEM_URANIUM = "урановый голем",
		SPECIES_GOLEM_PLASTIC = "пластиковый голем",
		SPECIES_GOLEM_SAND = "песчаный голем",
		SPECIES_GOLEM_GLASS = "стеклянный голем",
		SPECIES_GOLEM_BLUESPACE = "блюспейс-голем",
		SPECIES_GOLEM_BANANIUM = "бананиевый голем",
		SPECIES_GOLEM_TRANQUILLITITE = "транквилитовый голем",
		SPECIES_GOLEM_CLOCKWORK = "латунный голем",
		SPECIES_GREY = "серый",
		SPECIES_HUMAN = "человек",
		SPECIES_KIDAN = "кидан",
		SPECIES_MACNINEPERSON = "КПБ",
		SPECIES_MONKEY = "шимпанзе",
		SPECIES_FARWA = "фарва",
		SPECIES_WOLPIN = "вульпин",
		SPECIES_NEARA = "неара",
		SPECIES_STOK = "сток",
		SPECIES_MOTH = "ниан",
		SPECIES_NUCLEATION = "нуклеация",
		SPECIES_PLASMAMAN = "плазмолюд",
		SPECIES_SHADOW_BASIC = "тень",
		SPECIES_SHADOWLING = "тенеморф",
		SPECIES_LESSER_SHADOWLING = "низший тенеморф",
		SPECIES_SKELETON = "скелет",
		SPECIES_SKRELL = "скрелл",
		SPECIES_SLIMEPERSON = "слаймолюд",
		SPECIES_TAJARAN = "таяран",
		SPECIES_UNATHI = "унати",
		SPECIES_ASHWALKER_BASIC = "пеплоходец",
		SPECIES_ASHWALKER_SHAMAN = "шаман пеплоходец",
		SPECIES_DRACONOID = "драконид",
		SPECIES_VOX = "вокс",
		SPECIES_VOX_ARMALIS = "вокс армалис",
		SPECIES_VULPKANIN = "вульпканин",
		SPECIES_WRYN = "врин"
	)
	if(skipjumpsuit && (skipface || HAS_TRAIT(src, TRAIT_NO_SPECIES_EXAMINE))) //either obscured or on the nospecies list
		msg += ".\n"    //omit the species when examining
	else
		msg += ",<b><font color='[examine_color]'> [ru_species[displayed_species]]</font></b>.\n"

	//uniform
	if(w_uniform && !skipjumpsuit && !(w_uniform.item_flags & ABSTRACT))
		//Ties
		var/tie_msg
		if(istype(w_uniform, /obj/item/clothing/under) && LAZYLEN(w_uniform.accessories))
			tie_msg += " c [accessory_list(w_uniform)]"

		if(w_uniform.blood_DNA)
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(w_uniform, user)] <b>[w_uniform.declent_ru(ACCUSATIVE)]</b> [span_warning(w_uniform.blood_color != "#030303" ? "со следами крови":"со следами масла")][tie_msg] на теле.\n"
		else
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(w_uniform, user)] <b>[w_uniform.declent_ru(ACCUSATIVE)]</b>[tie_msg] на теле.\n"

	//head
	if(head && !(head.item_flags & ABSTRACT))
		if(head.blood_DNA)
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(head, user)] <b>[head.declent_ru(ACCUSATIVE)]</b> [span_warning(head.blood_color != "#030303" ? "со следами крови":"со следами масла")] на голове.\n"
		else
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(head, user)] <b>[head.declent_ru(ACCUSATIVE)]</b> на голове.\n"

	//neck
	if(neck && !(neck.item_flags & ABSTRACT))
		if(neck.blood_DNA)
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(neck, user)] <b>[neck.declent_ru(ACCUSATIVE)]</b> [span_warning(neck.blood_color != "#030303" ? "со следами крови":"со следами масла")] на шее.\n"
		else
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(neck, user)] <b>[neck.declent_ru(ACCUSATIVE)]</b> на шее.\n"

	//suit/armour
	if(wear_suit && !(wear_suit.item_flags & ABSTRACT))
		if(wear_suit.blood_DNA)
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(wear_suit, user)] <b>[wear_suit.declent_ru(ACCUSATIVE)]</b> [span_warning(wear_suit.blood_color != "#030303" ? "со следами крови":"со следами масла")].\n"
		else
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(wear_suit, user)] <b>[wear_suit.declent_ru(ACCUSATIVE)]</b>.\n"

		//suit/armour storage
		if(s_store && !skipsuitstorage)
			if(s_store.blood_DNA)
				msg += "На [GEND_HIS_HER(src)] [icon2html(wear_suit, user)] <b>[wear_suit.declent_ru(PREPOSITIONAL)]</b> вис[PLUR_IT_YAT(s_store)] [icon2html(s_store, user)] <b>[s_store.declent_ru(NOMINATIVE)]</b> [span_warning(s_store.blood_color != "#030303" ? "со следами крови":"со следами масла")].\n"
			else
				msg += "На [GEND_HIS_HER(src)] [icon2html(wear_suit, user)] <b>[wear_suit.declent_ru(PREPOSITIONAL)]</b> вис[PLUR_IT_YAT(s_store)] [icon2html(s_store, user)] <b>[s_store.declent_ru(NOMINATIVE)]</b>.\n"

	//back
	if(back && !(back.item_flags & ABSTRACT))
		if(back.blood_DNA)
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(back, user)] <b>[back.declent_ru(NOMINATIVE)]</b> [span_warning(back.blood_color != "#030303" ? "со следами крови":"со следами масла")] на спине.\n"
		else
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(back, user)] <b>[back.declent_ru(NOMINATIVE)]</b> на спине.\n"

	//left hand
	if(l_hand && !(l_hand.item_flags & ABSTRACT))
		if(l_hand.blood_DNA)
			msg += "[GEND_HE_SHE_CAP(src)] держ[PLUR_IT_AT(src)] [icon2html(l_hand, user)] <b>[l_hand.declent_ru(ACCUSATIVE)]</b> [span_warning(l_hand.blood_color != "#030303" ? "со следами крови":"со следами масла")] в левой руке.\n"
		else
			msg += "[GEND_HE_SHE_CAP(src)] держ[PLUR_IT_AT(src)] [icon2html(l_hand, user)] <b>[l_hand.declent_ru(ACCUSATIVE)]</b> в левой руке.\n"

	//right hand
	if(r_hand && !(r_hand.item_flags & ABSTRACT))
		if(r_hand.blood_DNA)
			msg += "[GEND_HE_SHE_CAP(src)] держ[PLUR_IT_AT(src)] [icon2html(r_hand, user)] <b>[r_hand.declent_ru(ACCUSATIVE)]</b> [span_warning(r_hand.blood_color != "#030303" ? "со следами крови":"со следами масла")] в правой руке.\n"
		else
			msg += "[GEND_HE_SHE_CAP(src)] держ[PLUR_IT_AT(src)] [icon2html(r_hand, user)] <b>[r_hand.declent_ru(ACCUSATIVE)]</b> в правой руке.\n"

	//gloves
	if(!skipgloves)
		if(gloves && !(gloves.item_flags & ABSTRACT))
			if(gloves.blood_DNA)
				msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(gloves, user)] <b>[gloves.declent_ru(NOMINATIVE)]</b> [span_warning(gloves.blood_color != "#030303" ? "со следами крови":"со следами масла")] на руках.\n"
			else
				msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(gloves, user)] <b>[gloves.declent_ru(NOMINATIVE)]</b> на руках.\n"
		else if(blood_DNA)
			msg += "[GEND_HIS_HER_CAP(src)] руки [hand_blood_color != "#030303" ? "измазаны кровью":"измазаны маслом"].\n"
		else if(isclocker(src) && HAS_TRAIT(src, TRAIT_CLOCK_HANDS))
			msg += span_clockitalic("[GEND_HIS_HER_CAP(src)] руки сверкают янтарём.\n")

	//handcuffed?
	if(handcuffed)
		msg += span_warning("[GEND_HE_SHE_CAP(src)] [icon2html(handcuffed, user)] скован[GEND_A_O_Y(src)] <b>[handcuffed.declent_ru(INSTRUMENTAL)]</b>.\n")

	//belt
	if(belt)
		if(belt.blood_DNA)
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(belt, user)] <b>[belt.declent_ru(NOMINATIVE)]</b> [span_warning(belt.blood_color != "#030303" ? "со следами крови":"со следами масла")] на талии.\n"
		else
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(belt, user)] <b>[belt.declent_ru(NOMINATIVE)]</b> на талии.\n"

	//shoes
	if(!skipshoes)
		if(shoes && !(shoes.item_flags & ABSTRACT))
			if(shoes.blood_DNA)
				msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(shoes, user)] <b>[shoes.declent_ru(ACCUSATIVE)]</b> [span_warning(shoes.blood_color != "#030303" ? "со следами крови":"со следами масла")] на ногах.\n"
			else
				msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(shoes, user)] <b>[shoes.declent_ru(ACCUSATIVE)]</b> на ногах.\n"
		else if(blood_DNA)
			msg += "[GEND_HIS_HER_CAP(src)] ступни [span_warning(hand_blood_color != "#030303" ? "измазаны в крови":"измазаны в масле")].\n"

	//legcuffed?
	if(legcuffed)
		msg += span_warning("[GEND_HIS_HER_CAP(src)] ноги [icon2html(legcuffed, user)] скованы [legcuffed.declent_ru(INSTRUMENTAL)].\n")

	//mask
	if(wear_mask && !skipmask && !(wear_mask.item_flags & ABSTRACT))
		if(wear_mask.blood_DNA)
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(wear_mask, user)] <b>[wear_mask.declent_ru(ACCUSATIVE)]</b> [span_warning(wear_mask.blood_color != "#030303" ? "со следами крови":"со следами масла")] на лице.\n"
		else
			msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(wear_mask, user)] <b>[wear_mask.declent_ru(ACCUSATIVE)]</b> на лице.\n"

	//eyes
	if(!skipeyes)
		if(glasses && !(glasses.item_flags & ABSTRACT))
			if(glasses.blood_DNA)
				msg += "[GEND_HIS_HER_CAP(src)] глаза закрыты [icon2html(glasses, user)] <b>[glasses.declent_ru(INSTRUMENTAL)]</b> [span_warning(glasses.blood_color != "#030303" ? "со следами крови":"со следами масла")].\n"
			else
				msg += "[GEND_HIS_HER_CAP(src)] глаза закрыты [icon2html(glasses, user)] <b>[glasses.declent_ru(INSTRUMENTAL)]</b>.\n"
		else if(HAS_TRAIT(src, TRAIT_RED_EYES) && get_int_organ(/obj/item/organ/internal/eyes))
			msg += span_boldwarning("[GEND_HIS_HER_CAP(src)] глаза горят кроваво-красным цветом.\n")

	//left ear
	if(l_ear && !skipears)
		msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(l_ear, user)] <b>[l_ear.declent_ru(ACCUSATIVE)]</b> на левом ухе.\n"

	//right ear
	if(r_ear && !skipears)
		msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(r_ear, user)] <b>[r_ear.declent_ru(ACCUSATIVE)]</b> на правом ухе.\n"

	//ID
	if(wear_id)
		msg += "[GEND_HE_SHE_CAP(src)] нос[PLUR_IT_YAT(src)] [icon2html(wear_id, user)] <b>[wear_id.declent_ru(ACCUSATIVE)]</b> на креплении ID-карты.\n"

	var/rolled_down = FALSE
	if(w_uniform && istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/jumpsuit = w_uniform
		rolled_down = jumpsuit.rolled_down

	var/list/strength_list = list()
	SEND_SIGNAL(src, COMSIG_GET_STRENGTH, strength_list)
	var/datum/strength_level/strength_level = !length(strength_list) ? STRENGTH_LEVEL_DEFAULT : strength_list[1]
	if((rolled_down || !w_uniform || (w_uniform.item_flags & ABSTRACT)) && (!wear_suit || (wear_suit.item_flags & ABSTRACT)) && strength_level != STRENGTH_LEVEL_DEFAULT)
		msg += span_notice("[GEND_HE_SHE_CAP(src)] выгляд[PLUR_IT_YAT(src)] [strength_level.strength_examine][GEND_YM_OI_YM_YMI(src)].\n")

	//Status effects
	var/status_examines = get_status_effect_examinations()
	if(status_examines)
		msg += status_examines

	var/appears_dead = FALSE
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_FAKEDEATH))
		appears_dead = TRUE
		if(suiciding)
			msg += span_warning("Выгляд[PLUR_IT_YAT(src)] так, будто [GEND_HE_SHE(src)] покончил[GEND_A_O_I(src)] с собой... надежды на восстановление нет.\n")
		if(mind && !mind.hasSoul)
			msg += span_boldwarning("<span style='font-size: large;'>[GEND_HIS_HER_CAP(src)] душа — моя. Не тратьте свое время.</span>\n")
		msg += span_deadsay("[GEND_HE_SHE_CAP(src)] выгляд[PLUR_IT_YAT(src)] безжизненно и не реагиру[PLUR_ET_YUT(src)]. Нет никаких признаков жизни.")
		if(get_int_organ(/obj/item/organ/internal/brain))
			if(!key)
				var/foundghost = FALSE
				if(mind)
					for(var/mob/dead/observer/G in GLOB.player_list)
						if(G.mind == mind)
							foundghost = TRUE
							if(G.can_reenter_corpse == 0)
								foundghost = FALSE
							break
				if(!foundghost)
					msg += span_deadsay(" [GEND_HIS_HER_CAP(src)] душа покинула тело")
		msg += span_deadsay("...\n")

	if(!get_int_organ(/obj/item/organ/internal/brain))
		msg += span_warning("Кажется, у н[GEND_HIS_HER(src)] отсутствует мозг...\n")

	var/list/wound_flavor_text = list()
	for(var/limb_zone in dna.species.has_limbs)

		var/obj/item/organ/external/bodypart = bodyparts_by_name[limb_zone]

		if(!bodypart)
			wound_flavor_text[limb_zone] = span_warning("<b>У н[GEND_HIS_HER(src)] отсутствует [GLOB.body_zone[limb_zone][NOMINATIVE]]!</b>\n")
		else
			if(!ismachineperson(src) && !skipprostheses)
				if(bodypart.is_robotic())
					wound_flavor_text[limb_zone] = span_warning("[GEND_HIS_HER_CAP(src)] [GLOB.body_zone[limb_zone][NOMINATIVE]] роботизированная.\n")

				else if(bodypart.is_splinted())
					wound_flavor_text[limb_zone] = span_warning("У н[GEND_HIS_HER(src)] наложена шина на [GLOB.body_zone[limb_zone][ACCUSATIVE]]!\n")

				else if(!bodypart.properly_attached)
					wound_flavor_text[limb_zone] = span_warning("[GEND_HIS_HER_CAP(src)] [GLOB.body_zone[limb_zone][NOMINATIVE]] едва держится!\n")

			if(bodypart.open)
				if(bodypart.is_robotic())
					msg += span_warning("<b>Технический люк на [GLOB.body_zone[limb_zone][PREPOSITIONAL]] открыт.</b>\n")
				else
					msg += span_warning("<b>У н[GEND_HIS_HER(src)] открытый разрез на [GLOB.body_zone[limb_zone][PREPOSITIONAL]].</b>\n")

			for(var/obj/item/embed in bodypart.embedded_objects)
				msg += span_warning("<b>В [GEND_HIS_HER(src)] [GLOB.body_zone[limb_zone][PREPOSITIONAL]] застрял [icon2html(embed, user)] [embed.declent_ru(NOMINATIVE)]!</b>\n")

	//Handles the text strings being added to the actual description.
	//If they have something that covers the limb, and it is not missing, put flavortext.  If it is covered but bleeding, add other flavortext.
	if(wound_flavor_text[BODY_ZONE_HEAD] && !skipmask && !(wear_mask && istype(wear_mask, /obj/item/clothing/mask/gas)))
		msg += wound_flavor_text[BODY_ZONE_HEAD]
	if(wound_flavor_text[BODY_ZONE_CHEST] && !w_uniform && !skipjumpsuit) //No need.  A missing chest gibs you.
		msg += wound_flavor_text[BODY_ZONE_CHEST]
	if(wound_flavor_text[BODY_ZONE_L_ARM] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text[BODY_ZONE_L_ARM]
	if(wound_flavor_text[BODY_ZONE_PRECISE_L_HAND] && !gloves && !skipgloves)
		msg += wound_flavor_text[BODY_ZONE_PRECISE_L_HAND]
	if(wound_flavor_text[BODY_ZONE_R_ARM] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text[BODY_ZONE_R_ARM]
	if(wound_flavor_text[BODY_ZONE_PRECISE_R_HAND] && !gloves && !skipgloves)
		msg += wound_flavor_text[BODY_ZONE_PRECISE_R_HAND]
	if(wound_flavor_text[BODY_ZONE_PRECISE_GROIN] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text[BODY_ZONE_PRECISE_GROIN]
	if(wound_flavor_text[BODY_ZONE_L_LEG] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text[BODY_ZONE_L_LEG]
	if(wound_flavor_text[BODY_ZONE_PRECISE_L_FOOT] && !shoes && !skipshoes)
		msg += wound_flavor_text[BODY_ZONE_PRECISE_L_FOOT]
	if(wound_flavor_text[BODY_ZONE_R_LEG] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text[BODY_ZONE_R_LEG]
	if(wound_flavor_text[BODY_ZONE_PRECISE_R_FOOT] && !shoes  && !skipshoes)
		msg += wound_flavor_text[BODY_ZONE_PRECISE_R_FOOT]

	var/damage = getBruteLoss() //no need to calculate each of these twice

	if(damage)
		var/brute_message = !ismachineperson(src) ? "ушибы" : "вмятины"
		if(damage < 60)
			msg += span_warning("У н[GEND_HIS_HER(src)] [damage < 30 ? "незначительные" : "умеренные"] [brute_message].\n")
		else
			msg += span_warning("<b>У н[GEND_HIS_HER(src)] серьёзные [brute_message]!</b>\n")

	damage = getFireLoss()
	if(damage)
		if(damage < 60)
			msg += span_warning("У н[GEND_HIS_HER(src)] [damage < 30 ? "незначительные" : "умеренные"] ожоги.\n")
		else
			msg += span_warning("<b>У н[GEND_HIS_HER(src)] серьёзные ожоги!</b>\n")
	damage = getCloneLoss()
	if(damage)
		if(damage < 60)
			msg += span_warning("У н[GEND_HIS_HER(src)] [damage < 30 ? "незначительное" : "умеренное"] клеточное повреждение.\n")
		else
			msg += span_warning("<b>У н[GEND_HIS_HER(src)] серьёзное клеточное повреждение.</b>\n")

	if(fire_stacks > 0)
		msg += span_warning("[GEND_HE_SHE_CAP(src)] покрыт[GEND_A_O_Y(src)] чем-то легковоспламеняющимся.\n")
	if(fire_stacks < 0)
		msg += span_warning("[GEND_HE_SHE_CAP(src)] выгляд[PLUR_IT_YAT(src)] немного мокр[GEND_YM_OI_YM_YMI(src)].\n")

	switch(wetlevel)
		if(1)
			msg += span_warning("[GEND_HE_SHE_CAP(src)] выгляд[PLUR_IT_YAT(src)] слегка влажн[GEND_YM_OI_YM_YMI(src)].\n")
		if(2)
			msg += span_warning("[GEND_HE_SHE_CAP(src)] выгляд[PLUR_IT_YAT(src)] чуть мокр[GEND_YM_OI_YM_YMI(src)].\n")
		if(3)
			msg += span_warning("[GEND_HE_SHE_CAP(src)] выгляд[PLUR_IT_YAT(src)] мокр[GEND_YM_OI_YM_YMI(src)].\n")
		if(4)
			msg += span_warning("[GEND_HE_SHE_CAP(src)] выгляд[PLUR_IT_YAT(src)] очень мокр[GEND_YM_OI_YM_YMI(src)].\n")
		if(5)
			msg += span_warning("[GEND_HE_SHE_CAP(src)] выгляд[PLUR_IT_YAT(src)] полностью промокш[GEND_IM_EI_IM_IMI(src)].\n")

	if(nutrition < NUTRITION_LEVEL_HYPOGLYCEMIA)
		msg += span_warning("[GEND_HE_SHE_CAP(src)] сильно истощен[GEND_A_O_Y(src)].\n")

	if(HAS_TRAIT(src, TRAIT_FAT))
		msg += span_warning("[GEND_HE_SHE_CAP(src)] страда[PLUR_ET_YUT(src)] болезненным ожирением.\n")
		if(user.nutrition < NUTRITION_LEVEL_HYPOGLYCEMIA)
			msg += span_warning("[GEND_HE_SHE_CAP(src)] выгляд[PLUR_IT_YAT(src)] пухл[GEND_YM_OI_YM_YMI(src)] и аппетитн[GEND_YM_OI_YM_YMI(src)] — как маленький поросёнок. Вкусный поросёнок.\n")

	else if(nutrition >= NUTRITION_LEVEL_FAT)
		msg += span_warning("[GEND_HE_SHE_CAP(src)] выгляд[PLUR_IT_YAT(src)] довольно полн[GEND_YM_OI_YM_YMI(src)].\n")

	if(dna.species.can_be_pale && blood_volume < BLOOD_VOLUME_PALE && ((get_covered_bodyparts() & FULL_BODY) != FULL_BODY))
		msg += span_warning("У н[GEND_HIS_HER(src)] бледная кожа.\n")

	var/datum/antagonist/vampire/vampire_datum = mind?.has_antag_datum(/datum/antagonist/vampire)
	if(istype(vampire_datum) && vampire_datum.draining)
		msg += span_warning("<b>[GEND_HE_SHE_CAP(src)] впил[GEND_SYA_AS_OS_IS(src)] своими клыками в шею [vampire_datum.draining].\n</b>")

	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(!bodypart.tourniquet)
			continue
		if(bodypart.tourniquet.applied_bodypart != bodypart)
			continue
		msg += span_warning("<a href='byond://?src=[UID()];tourniquet_object=[bodypart.tourniquet.UID()];limb=[bodypart.UID()]' class='warning'>[GEND_HIS_HER_CAP(src)] [bodypart.declent_ru(NOMINATIVE)] пережат[GEND_A_O_Y(src)] [icon2html(bodypart.tourniquet, src)] [bodypart.tourniquet.declent_ru(INSTRUMENTAL)]!</a>\n")

	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(!bodypart.bleeding_amount)
			if(bodypart.bleedsuppress)
				msg += span_warning("У н[GEND_HIS_HER(src)] [bodypart.declent_ru(NOMINATIVE)] перевязан[GEND_A_O_Y(src)] чем-то.\n")
			continue

		var/suppressed = bodypart.bleeding_amount <= bodypart.bleedsuppress
		if(suppressed)
			msg += span_warning("[capitalize(GEND_HIS_HER(src))] [bodypart.declent_ru(NOMINATIVE)] перевязан[GEND_A_O_Y(bodypart)] чем-то окровавленным.\n")
		else if(bodypart.has_arterial_bleeding())
			msg += span_warning(span_bold("Из [GEND_HIS_HER(src)] [bodypart.declent_ru(GENITIVE)] хлещет кровь!\n"))
		else if(bodypart.has_heavy_bleeding())
			msg += span_warning(span_bold("[GEND_HIS_HER_CAP(src)] [bodypart.declent_ru(NOMINATIVE)] обильно кровоточ[PLUR_IT_AT(bodypart)]!\n"))
		else
			msg += span_warning(span_bold("[GEND_HIS_HER_CAP(src)] [bodypart.declent_ru(NOMINATIVE)] кровоточ[PLUR_IT_AT(bodypart)]!\n"))

	if(reagents.has_reagent("teslium"))
		msg += span_warning("[GEND_HE_SHE_CAP(src)] излуча[PLUR_ET_YUT(src)] мягкое голубое свечение!\n")

	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			msg += "[GEND_HE_SHE_CAP(src)] не реагиру[PLUR_ET_YUT(src)] на происходящее вокруг и, кажется, сп[PLUR_IT_YAT(src)].\n"
		if(stat == CONSCIOUS)
			if(getBrainLoss() >= 60)
				msg += "На [GEND_HIS_HER(src)] лице застыло глупое выражение.\n"
			if(health < HEALTH_THRESHOLD_CRIT && health > HEALTH_THRESHOLD_DEAD)
				msg += "[GEND_HE_SHE_CAP(src)] почти без сознания.\n"

		if(get_int_organ(/obj/item/organ/internal/brain))
			if(dna.species.show_ssd)
				if(!key)
					msg += span_deadsay("[GEND_HE_SHE_CAP(src)] в полной кататонии. Должно быть, тяготы жизни в глубоком космосе оказались непосильны для н[GEND_HIS_HER(src)]. Шансы на восстановление ничтожны.\n")
				else if(!client)
					msg += span_deadsay("[GEND_HE_SHE_CAP(src)] внезапно заснул[GEND_A_O_I(src)]. [GEND_HE_SHE_CAP(src)] может скоро проснуться.\n")

		if(HAS_TRAIT_FROM(src, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT))
			msg += span_italics("[GEND_HE_SHE_CAP(src)] двигает своё тело неестественно и откровенно нечеловеческим образом.\n")

	if(!(skipface || (wear_mask && (wear_mask.flags_inv & HIDENAME || wear_mask.flags_cover & MASKCOVERSMOUTH))) && is_thrall(src) && in_range(user,src))
		msg += span_italics("[GEND_HIS_HER_CAP(src)] черты лица выглядят неестественно напряжёнными и застывшими.\n")

	var/obj/item/organ/internal/cyberimp/tail/blade/implant = get_organ_slot(INTERNAL_ORGAN_TAIL_DEVICE)
	if(istype(implant) && implant.activated)
		msg += span_italics("Вы замечаете странный [implant.biological ? "нарост" : "блеск"] на [GEND_HIS_HER(src)] хвосте.\n")

	if(get_gravity(src) < -NO_GRAVITY && !buckled)
		msg += "[GEND_HE_SHE_CAP(src)] наход[PLUR_IT_YAT(src)]ся на потолке.\n"

	if(user.no_gravity() && !buckled)
		msg += "[GEND_HE_SHE_CAP(src)] не подвержен[GEND_A_O_Y(src)] действию гравитации.\n"

	if(decaylevel == 1)
		msg += "[GEND_HE_SHE_CAP(src)] начал[GEND_A_O_I(src)] разлагаться и неприятно пахнуть.\n"
	if(decaylevel == 2)
		msg += "[GEND_HE_SHE_CAP(src)] раздут[GEND_A_O_Y(src)] и отвратительно пахн[PLUR_ET_YUT(src)].\n"
	if(decaylevel == 3)
		msg += "[GEND_HE_SHE_CAP(src)] почернел[GEND_A_O_I(src)] и гниёт, кожа слезает лоскутами. Зловоние неописуемо.\n"
	if(decaylevel == 4)
		msg += "[GEND_HE_SHE_CAP(src)] почти полностью разложил[GEND_SYA_AS_OS_IS(src)]. От н[GEND_HIS_HER(src)] остался лишь скелет.\n"

	if(hasHUD(user, EXAMINE_HUD_SECURITY_READ))
		var/perpname = get_visible_name(add_id_name = FALSE)
		var/criminal = "None"
		var/commentLatest = "ОШИБКА: Не удалось найти запись в базе данных о данном лице." //If there is no datacore present, give this

		if(perpname)
			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.security)
						if(R.fields["id"] == E.fields["id"])
							criminal = R.fields["criminal"]
							if(LAZYLEN(R.fields["comments"])) //if the commentlist is present
								var/list/comments = R.fields["comments"]
								commentLatest = LAZYACCESS(comments, length(comments)) //get the latest entry from the comment log
							else
								commentLatest = "Нет записей." //If present but without entries (=target is recognized crew)

			var/criminal_status = hasHUD(user, EXAMINE_HUD_SECURITY_WRITE) ? "<a href='byond://?src=[UID()];criminal=1'>\[[criminal]\]</a>" : "\[[criminal]\]"
			msg += "[span_deptradio("Криминальный статус:")] [criminal_status]\n"
			msg += "[span_deptradio("Записи службы безопасности:")] <a href='byond://?src=[UID()];secrecordComment=`'>\[Посмотреть записи\]</a> <a href='byond://?src=[UID()];secrecordadd=`'>\[Добавить комментарий\]</a>\n"
			msg += "[span_deptradio("Последние данные:")] [commentLatest]\n"

	if(hasHUD(user, EXAMINE_HUD_SKILLS))
		var/perpname = get_visible_name(add_id_name = FALSE)
		var/skills

		if(perpname)
			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					skills = E.fields["notes"]
			if(skills)
				var/char_limit = 40
				if(length(skills) <= char_limit)
					msg += "[span_deptradio("Личное дело:")] [skills]\n"
				else
					msg += "[span_deptradio("Личное дело:")] [copytext_preserve_html(skills, 1, char_limit-3)]...<a href='byond://?src=[UID()];employment_more=1'>Подробнее...</a>\n"

	if(hasHUD(user,EXAMINE_HUD_MEDICAL))
		var/perpname = get_visible_name(add_id_name = FALSE)
		var/medical = "None"

		for(var/datum/data/record/E in GLOB.data_core.general)
			if(E.fields["name"] == perpname)
				for(var/datum/data/record/R in GLOB.data_core.general)
					if(R.fields["id"] == E.fields["id"])
						medical = R.fields["p_stat"]

		msg += "[span_deptradio("Состояние:")] [span_notice(get_desc_for_medical_status(hud_list[STATUS_HUD].icon_state))]\n"
		msg += "[span_deptradio("Психологический статус:")] <a href='byond://?src=[UID()];medical=1'>\[[medical]\]</a>\n"
		msg += "[span_deptradio("Медицинские записи:")] <a href='byond://?src=[UID()];medrecord=`'>\[View\]</a> <a href='byond://?src=[UID()];medrecordadd=`'>\[Добавить комментарий\]</a>\n"

	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(print_flavor_text() && !skipface && !head_organ?.is_disfigured())
		msg += "[print_flavor_text()]\n"

	if(pose)
		if(findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0)
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\n[p_they(TRUE)] [p_are()] [pose]"

	. = list(msg)
	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)

/mob/living/carbon/human/get_examine_time()
	return 1 SECONDS

/**
 * Shows any and all examine text related to any status effects the user has.
 */
/mob/living/proc/get_status_effect_examinations()
	var/list/examine_list = list()

	for(var/datum/status_effect/effect as anything in status_effects)
		var/effect_text = effect.get_examine_text()
		if(!effect_text)
			continue

		examine_list += effect_text

	if(!length(examine_list))
		return

	return examine_list.Join("\n") + "\n"

//Helper procedure. Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic() to determine HUD access to security and medical records.
/proc/hasHUD(mob/M, hud_exam)
	if(ishuman(M))
		var/have_hud_exam = 0
		var/mob/living/carbon/human/H = M

		if(istype(H.glasses, /obj/item/clothing/glasses))
			var/obj/item/clothing/glasses/glasses = H.glasses
			if(glasses?.examine_extensions)
				have_hud_exam |= glasses.examine_extensions

		if(istype(H.head, /obj/item/clothing/head/helmet/space))
			var/obj/item/clothing/head/helmet/space/helmet = H.head
			if(helmet?.examine_extensions)
				have_hud_exam |= helmet.examine_extensions

		if(ismodhelmet(H.head))
			var/obj/item/clothing/head/mod/our_shitcode = H.head
			if(our_shitcode?.examine_extensions)
				have_hud_exam |= our_shitcode.examine_extensions

		var/obj/item/organ/internal/cyberimp/eyes/hud/CIH = H.get_int_organ(/obj/item/organ/internal/cyberimp/eyes/hud)
		if(CIH?.examine_extensions)
			have_hud_exam |= CIH.examine_extensions

		if(H.check_smart_brain())
			have_hud_exam |= EXAMINE_HUD_SCIENCE

		return (have_hud_exam & hud_exam)

	else if(isrobot(M) || isAI(M)) //Stand-in/Stopgap to prevent pAIs from freely altering records, pending a more advanced Records system
		return hud_exam & EXAMINE_HUD_SECURITY_READ || hud_exam & EXAMINE_HUD_SECURITY_WRITE || hud_exam & EXAMINE_HUD_MEDICAL

	else if(ispAI(M))
		var/mob/living/silicon/pai/P = M
		if(P.adv_secHUD)
			return hud_exam & EXAMINE_HUD_SECURITY_READ || hud_exam & EXAMINE_HUD_SECURITY_WRITE

	else if(isobserver(M))
		var/mob/dead/observer/O = M
		if(DATA_HUD_SECURITY_ADVANCED in O.data_hud_seen)
			return hud_exam & EXAMINE_HUD_SECURITY_READ || hud_exam & EXAMINE_HUD_SKILLS

	return FALSE
