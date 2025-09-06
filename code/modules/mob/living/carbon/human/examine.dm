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

	var/msg = "Это "

	if(!(skipjumpsuit && skipface) && icon) //big suits/masks/helmets make it hard to tell their gender
		msg += "[bicon(icon(icon, dir=SOUTH))] " //fucking BYOND: this should stop dreamseeker crashing if we -somehow- examine somebody before their icon is generated
	msg += "<em>[name]</em>"

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
		SPECIES_GREY = "грей",
		SPECIES_HUMAN = "человек",
		SPECIES_KIDAN = "кидан",
		SPECIES_MACNINEPERSON = "машина",
		SPECIES_MONKEY = "шимпанзе",
		SPECIES_FARWA = "фарва",
		SPECIES_WOLPIN = "вульпин",
		SPECIES_NEARA = "неара",
		SPECIES_STOK ="сток",
		SPECIES_MOTH = "ниан",
		SPECIES_NUCLEATION = "нуклеация",
		SPECIES_PLASMAMAN = "плазмамен",
		SPECIES_SHADOW_BASIC = "тень",
		SPECIES_SHADOWLING = "тенелинг",
		SPECIES_LESSER_SHADOWLING = "низший тенелинг",
		SPECIES_SKELETON = "скелет",
		SPECIES_SKRELL = "скрелл",
		SPECIES_SLIMEPERSON = "слаймолюд",
		SPECIES_TAJARAN = "таяран",
		SPECIES_UNATHI = "унатх",
		SPECIES_ASHWALKER_BASIC = "пеплоходец",
		SPECIES_ASHWALKER_SHAMAN = "шаман пеплоходец",
		SPECIES_DRACONOID = "драконид",
		SPECIES_VOX = "вокс",
		SPECIES_VOX_ARMALIS = "вокс армалис",
		SPECIES_VULPKANIN = "вульпканин",
		SPECIES_WRYN = "врин"
	)
	if(skipjumpsuit && (skipface || HAS_TRAIT(src, TRAIT_NO_SPECIES_EXAMINE))) //either obscured or on the nospecies list
		msg += "!\n"    //omit the species when examining
	else
		msg += ",<b><font color='[examine_color]'> [ru_species[displayed_species]]</font></b>!\n"

	//uniform
	if(w_uniform && !skipjumpsuit && !(w_uniform.item_flags & ABSTRACT))
		//Ties
		var/tie_msg
		if(istype(w_uniform, /obj/item/clothing/under) && LAZYLEN(w_uniform.accessories))
			tie_msg += " c [accessory_list(w_uniform)]"

		if(w_uniform.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(w_uniform)] [w_uniform.declent_ru(ACCUSATIVE)] [w_uniform.blood_color != "#030303" ? "со следами крови":"со следами масла"][tie_msg]!\n")
		else
			msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(w_uniform)] [w_uniform.declent_ru(ACCUSATIVE)].\n"

	//head
	if(head && !(head.item_flags & ABSTRACT))
		if(head.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(head)] [head.declent_ru(ACCUSATIVE)] [head.blood_color != "#030303" ? "со следами крови":"со следами масла"] на голове!\n")
		else
			msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(head)] [head.declent_ru(ACCUSATIVE)] на голове.\n"

	//neck
	if(neck && !(neck.item_flags & ABSTRACT))
		if(neck.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(neck)] [neck.declent_ru(ACCUSATIVE)] [neck.blood_color != "#030303" ? "со следами крови":"со следами масла"] на шее!\n")
		else
			msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(neck)] [neck.declent_ru(ACCUSATIVE)] на шее.\n"

	//suit/armour
	if(wear_suit && !(wear_suit.item_flags & ABSTRACT))
		if(wear_suit.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(wear_suit)] [wear_suit.declent_ru(ACCUSATIVE)] [wear_suit.blood_color != "#030303" ? "со следами крови":"со следами масла"]!\n")
		else
			msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(wear_suit)] [wear_suit.declent_ru(ACCUSATIVE)].\n"

		//suit/armour storage
		if(s_store && !skipsuitstorage)
			if(s_store.blood_DNA)
				msg += span_warning("На [genderize_ru(gender, "его", "её", "его", "их")] [bicon(wear_suit)] [wear_suit.declent_ru(PREPOSITIONAL)] вис[pluralize_ru(s_store.gender, "ит", "ят")] [bicon(s_store)] [s_store.declent_ru(NOMINATIVE)] [s_store.blood_color != "#030303" ? "со следами крови":"со следами масла"]!\n")
			else
				msg += "На [genderize_ru(gender, "его", "её", "его", "их")] [bicon(wear_suit)] [wear_suit.declent_ru(PREPOSITIONAL)] вис[pluralize_ru(s_store.gender, "ит", "ят")] [bicon(s_store)] [s_store.declent_ru(NOMINATIVE)].\n"

	//back
	if(back && !(back.item_flags & ABSTRACT))
		if(back.blood_DNA)
			msg += span_warning("На [genderize_ru(gender, "его", "её", "его", "их")] спине вис[pluralize_ru(back.gender, "ит", "ят")] [bicon(back)] [back.declent_ru(NOMINATIVE)] [back.blood_color != "#030303" ? "со следами крови":"со следами масла"]!\n")
		else
			msg += "На [genderize_ru(gender, "его", "её", "его", "их")] спине вис[pluralize_ru(back.gender, "ит", "ят")] [bicon(back)] [back.declent_ru(NOMINATIVE)].\n"

	//left hand
	if(l_hand && !(l_hand.item_flags & ABSTRACT))
		if(l_hand.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] держ[pluralize_ru(gender, "ит", "ат")] [bicon(l_hand)] [l_hand.declent_ru(ACCUSATIVE)] [l_hand.blood_color != "#030303" ? "со следами крови":"со следами масла"] в левой руке!\n")
		else
			msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] держ[pluralize_ru(gender, "ит", "ат")] [bicon(l_hand)] [l_hand.declent_ru(ACCUSATIVE)] в левой руке.\n"

	//right hand
	if(r_hand && !(r_hand.item_flags & ABSTRACT))
		if(r_hand.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] держ[pluralize_ru(gender, "ит", "ат")] [bicon(r_hand)] [r_hand.declent_ru(ACCUSATIVE)] [r_hand.blood_color != "#030303" ? "со следами крови":"со следами масла"] в правой руке!\n")
		else
			msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] держ[pluralize_ru(gender, "ит", "ат")] [bicon(r_hand)] [r_hand.declent_ru(ACCUSATIVE)] в правой руке.\n"

	//gloves
	if(!skipgloves)
		if(gloves && !(gloves.item_flags & ABSTRACT))
			if(gloves.blood_DNA)
				msg += span_warning("На [genderize_ru(gender, "его", "её", "его", "их")] руках [bicon(gloves)] [gloves.declent_ru(NOMINATIVE)] [gloves.blood_color != "#030303" ? "со следами крови":"со следами масла"]!\n")
			else
				msg += "На [genderize_ru(gender, "его", "её", "его", "их")] руках [bicon(gloves)] [gloves.declent_ru(NOMINATIVE)].\n"
		else if(blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Его", "Её", "Его", "Их")] руки [hand_blood_color != "#030303" ? "измазаны кровью":"измазаны маслом"]!\n")
		else if(isclocker(src) && HAS_TRAIT(src, CLOCK_HANDS))
			msg += span_clockitalic("[genderize_ru(gender, "Его", "Её", "Его", "Их")] руки сверкают янтарём!\n")

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable/zipties))
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] [bicon(handcuffed)] скован[genderize_ru(gender, "", "а", "о", "ы")] стяжками!\n")
		else if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] [bicon(handcuffed)] скован[genderize_ru(gender, "", "а", "о", "ы")] самодельными стяжками!\n")
		else
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] [bicon(handcuffed)] скован[genderize_ru(gender, "", "а", "о", "ы")] наручниками!\n")

	//belt
	if(belt)
		if(belt.blood_DNA)
			msg += span_warning("На [genderize_ru(gender, "его", "её", "его", "их")] талии вис[pluralize_ru(belt.gender, "ит", "ят")] [bicon(belt)] [belt.declent_ru(NOMINATIVE)] [belt.blood_color != "#030303" ? "со следами крови":"со следами масла"]!\n")
		else
			msg += "На [genderize_ru(gender, "его", "её", "его", "их")] талии вис[pluralize_ru(belt.gender, "ит", "ят")] [bicon(belt)] [belt.declent_ru(NOMINATIVE)].\n"

	//shoes
	if(!skipshoes)
		if(shoes && !(shoes.item_flags & ABSTRACT))
			if(shoes.blood_DNA)
				msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(shoes)] [shoes.declent_ru(ACCUSATIVE)] [shoes.blood_color != "#030303" ? "со следами крови":"со следами масла"] на ногах!\n")
			else
				msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(shoes)] [shoes.declent_ru(ACCUSATIVE)] на ногах.\n"
		else if(blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Его", "Её", "Его", "Их")] ступни [hand_blood_color != "#030303" ? "измазаны в крови":"измазаны в масле"]!\n")

	//legcuffed?
	if(legcuffed)
		msg += span_warning("[genderize_ru(gender, "Его", "Её", "Его", "Их")] ноги [bicon(legcuffed)] скованы [legcuffed.declent_ru(INSTRUMENTAL)]!\n")

	//mask
	if(wear_mask && !skipmask && !(wear_mask.item_flags & ABSTRACT))
		if(wear_mask.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(wear_mask)] [wear_mask.declent_ru(ACCUSATIVE)] [wear_mask.blood_color != "#030303" ? "со следами крови":"со следами масла"] на лице!\n")
		else
			msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(wear_mask)] [wear_mask.declent_ru(ACCUSATIVE)] на лице.\n"

	//eyes
	if(!skipeyes)
		if(glasses && !(glasses.item_flags & ABSTRACT))
			if(glasses.blood_DNA)
				msg += span_warning("[genderize_ru(gender, "Его", "Её", "Его", "Их")] глаза закрыты [bicon(glasses)] [glasses.declent_ru(INSTRUMENTAL)] [glasses.blood_color != "#030303" ? "со следами крови":"со следами масла"]!\n")
			else
				msg += "[genderize_ru(gender, "Его", "Её", "Его", "Их")] глаза закрыты [bicon(glasses)] [glasses.declent_ru(INSTRUMENTAL)].\n"
		else if(iscultist(src) && HAS_TRAIT(src, CULT_EYES) && get_int_organ(/obj/item/organ/internal/eyes))
			msg += span_boldwarning("[genderize_ru(gender, "Его", "Её", "Его", "Их")] глаза неестественно горят кроваво-красным!\n")

	//left ear
	if(l_ear && !skipears)
		msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(l_ear)] [l_ear.declent_ru(ACCUSATIVE)] на левом ухе.\n"

	//right ear
	if(r_ear && !skipears)
		msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(r_ear)] [r_ear.declent_ru(ACCUSATIVE)] на правом ухе.\n"

	//ID
	if(wear_id)
		msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] нос[pluralize_ru(gender, "ит", "ят")] [bicon(wear_id)] [wear_id.declent_ru(ACCUSATIVE)].\n"

	var/rolled_down = FALSE
	if(w_uniform && istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/jumpsuit = w_uniform
		rolled_down = jumpsuit.rolled_down

	var/list/strength_list = list()
	SEND_SIGNAL(src, COMSIG_GET_STRENGTH, strength_list)
	var/datum/strength_level/strength_level = !strength_list.len ? STRENGTH_LEVEL_DEFAULT : strength_list[1]
	if((rolled_down || !w_uniform || (w_uniform.item_flags & ABSTRACT)) && (!wear_suit || (wear_suit.item_flags & ABSTRACT)) && strength_level != STRENGTH_LEVEL_DEFAULT)
		msg += span_notice("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] выгляд[pluralize_ru(gender, "ит", "ят")] [strength_level.strength_examine][genderize_ru(gender, "ым", "ой", "ым", "ыми")].\n")

	//Status effects
	var/status_examines = get_status_effect_examinations()
	if(status_examines)
		msg += status_examines

	var/appears_dead = FALSE
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_FAKEDEATH))
		appears_dead = TRUE
		if(suiciding)
			msg += span_warning("Выгляд[pluralize_ru(gender, "ит", "ят")] так, будто [genderize_ru(gender, "он", "она", "оно", "они")] покончил[genderize_ru(gender, "", "а", "о", "и")] с собой... надежды на восстановление нет.\n")
		if(mind && !mind.hasSoul)
			msg += span_boldwarning("<span style='font-size: large;'>[capitalize(genderize_ru(gender, "его", "её", "его", "их"))] душа – моя. Не тратьте свое время.</span>\n")
		msg += span_deadsay("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] безжизнен[genderize_ru(gender, "", "на", "но", "ны")] и не реагиру[pluralize_ru(gender,"ет","ют")]. Нет никаких признаков жизни.")
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
					msg += span_deadsay(" [genderize_ru(gender, "Его", "Её", "Его", "Их")] душа покинула тело")
		msg += span_deadsay("...\n")

	if(!get_int_organ(/obj/item/organ/internal/brain))
		msg += span_warning("Кажется, у [genderize_ru(gender, "него", "неё", "него", "них")] отсутствует мозг...\n")

	var/list/wound_flavor_text = list()
	for(var/limb_zone in dna.species.has_limbs)

		var/obj/item/organ/external/bodypart = bodyparts_by_name[limb_zone]

		if(!bodypart)
			wound_flavor_text[limb_zone] = span_warning("<b>У [genderize_ru(gender, "него", "неё", "него", "них")] отсутствует [GLOB.body_zone[limb_zone][NOMINATIVE]]!</b>\n")
		else
			if(!ismachineperson(src) && !skipprostheses)
				if(bodypart.is_robotic())
					wound_flavor_text[limb_zone] = span_warning("[genderize_ru(gender, "Его", "Её", "Его", "Их")] [GLOB.body_zone[limb_zone][NOMINATIVE]] роботизированная.\n")

				else if(bodypart.is_splinted())
					wound_flavor_text[limb_zone] = span_warning("У [genderize_ru(gender, "него", "неё", "него", "них")] наложена шина на [GLOB.body_zone[limb_zone][ACCUSATIVE]]!\n")

				else if(!bodypart.properly_attached)
					wound_flavor_text[limb_zone] = span_warning("[genderize_ru(gender, "Его", "Её", "Его", "Их")] [GLOB.body_zone[limb_zone][NOMINATIVE]] едва держится!\n")

			if(bodypart.open)
				if(bodypart.is_robotic())
					msg += span_warning("<b>Технический люк на [GLOB.body_zone[limb_zone][PREPOSITIONAL]] открыт.</b>\n")
				else
					msg += span_warning("<b>У [genderize_ru(gender, "него", "неё", "него", "них")] открытый разрез на [GLOB.body_zone[limb_zone][PREPOSITIONAL]].</b>\n")

			for(var/obj/item/embed in bodypart.embedded_objects)
				msg += span_warning("<b>В [genderize_ru(gender, "его", "её", "его", "их")] [GLOB.body_zone[limb_zone][PREPOSITIONAL]] застрял [bicon(embed)] [embed.declent_ru(NOMINATIVE)]!</b>\n")

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
			msg += span_warning("У [genderize_ru(gender, "него", "неё", "него", "них")] [damage < 30 ? "незначительные" : "умеренные"] [brute_message].\n")
		else
			msg += span_warning("<b>У [genderize_ru(gender, "него", "неё", "него", "них")] серьёзные [brute_message]!</b>\n")

	damage = getFireLoss()
	if(damage)
		if(damage < 60)
			msg += span_warning("У [genderize_ru(gender, "него", "неё", "него", "них")] [damage < 30 ? "незначительные" : "умеренные"] ожоги.\n")
		else
			msg += span_warning("<b>У [genderize_ru(gender, "него", "неё", "него", "них")] серьёзные ожоги!</b>\n")
	damage = getCloneLoss()
	if(damage)
		if(damage < 60)
			msg += span_warning("У [genderize_ru(gender, "него", "неё", "него", "них")] [damage < 30 ? "незначительное" : "умеренное"] клеточное повреждение.\n")
		else
			msg += span_warning("<b>У [genderize_ru(gender, "него", "неё", "него", "них")] серьёзное клеточное повреждение.</b>\n")


	if(fire_stacks > 0)
		msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] [genderize_ru(gender, "покрыт", "покрыта", "покрыто", "покрыты")] чем-то легковоспламеняющимся.\n")
	if(fire_stacks < 0)
		msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] выглядит немного мокрым.\n")

	switch(wetlevel)
		if(1)
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] выгляд[pluralize_ru(gender, "ит", "ят")] слегка влажным.\n")
		if(2)
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] выгляд[pluralize_ru(gender, "ит", "ят")] чуть мокрым.\n")
		if(3)
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] выгляд[pluralize_ru(gender, "ит", "ят")] мокрым.\n")
		if(4)
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] выгляд[pluralize_ru(gender, "ит", "ят")] очень мокрым.\n")
		if(5)
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] выгляд[pluralize_ru(gender, "ит", "ят")] полностью промокшим.\n")

	if(nutrition < NUTRITION_LEVEL_HYPOGLYCEMIA)
		msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] сильно истощён[genderize_ru(gender, "", "а", "о", "ы")].\n")

	if(HAS_TRAIT(src, TRAIT_FAT))
		msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] страда[pluralize_ru(gender, "ет", "ют")] болезненным ожирением.\n")
		if(user.nutrition < NUTRITION_LEVEL_HYPOGLYCEMIA)
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] выгляд[pluralize_ru(gender, "ит", "ят")] пухлым и аппетитным — как маленький поросёнок. Вкусный поросёнок.\n")

	else if(nutrition >= NUTRITION_LEVEL_FAT)
		msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] выгляд[pluralize_ru(gender, "ит", "ят")] довольно полным.\n")

	if(dna.species.can_be_pale && blood_volume < BLOOD_VOLUME_PALE && ((get_covered_bodyparts() & FULL_BODY) != FULL_BODY))
		msg += span_warning("У [genderize_ru(gender, "него", "неё", "него", "них")] бледная кожа.\n")

	var/datum/antagonist/vampire/vampire_datum = mind?.has_antag_datum(/datum/antagonist/vampire)
	if(istype(vampire_datum) && vampire_datum.draining)
		msg += span_warning("<b>[genderize_ru(gender, "Он", "Она", "Оно", "Они")] впил[genderize_ru(gender, "ся", "ась", "ось", "ись")] своими клыками в шею [vampire_datum.draining].\n</b>")

	if(bleedsuppress)
		msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] перевязан[genderize_ru(gender, "", "а", "о", "ы")] чем-то.\n")
	else if(bleed_rate)
		msg += span_warning("<b>[genderize_ru(gender, "Он", "Она", "Оно", "Они")] кровоточ[pluralize_ru(gender, "ит", "ат")]!</b>\n")

	if(reagents.has_reagent("teslium"))
		msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] излуча[pluralize_ru(gender, "ет", "ют")] мягкое голубое свечение!\n")

	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			msg += "[genderize_ru(user.gender, "Он", "Она", "Оно", "Они")] не реагиру[pluralize_ru(gender, "ет", "ют")] на происходящее вокруг и, кажется, сп[pluralize_ru(gender, "ит", "ят")].\n"
		if(stat == CONSCIOUS)
			if(getBrainLoss() >= 60)
				msg += "На [genderize_ru(user.gender, "его", "её", "его", "их")] лице застыло глупое выражение.\n"
			if(health < HEALTH_THRESHOLD_CRIT && health > HEALTH_THRESHOLD_DEAD)
				msg += "[genderize_ru(user.gender, "Он", "Она", "Оно", "Они")] почти без сознания.\n"


		if(get_int_organ(/obj/item/organ/internal/brain))
			if(dna.species.show_ssd)
				if(!key)
					msg += span_deadsay("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] в полной кататонии. Должно быть, тяготы жизни в глубоком космосе оказались непосильны для [genderize_ru(gender, "него", "неё", "него", "них")]. Шансы на восстановление ничтожны.\n")
				else if(!client)
					msg += span_deadsay("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] внезапно заснул[genderize_ru(gender, "", "а", "о", "и")]. [genderize_ru(gender, "Он", "Она", "Оно", "Они")] может скоро проснуться.\n")

		if(HAS_TRAIT_FROM(src, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT))
			msg += span_italics("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] двигает своё тело неестественно и откровенно нечеловеческим образом.\n")

	if(!(skipface || ( wear_mask && ( wear_mask.flags_inv & HIDENAME || wear_mask.flags_cover & MASKCOVERSMOUTH) ) ) && is_thrall(src) && in_range(user,src))
		msg += span_italics("[genderize_ru(gender, "Его", "Её", "Их", "Их")] черты лица выглядят неестественно напряжёнными и застывшими.\n")

	var/obj/item/organ/internal/cyberimp/tail/blade/implant = get_organ_slot(INTERNAL_ORGAN_TAIL_DEVICE)
	if(istype(implant) && implant.activated)
		msg += span_italics("Вы замечаете странный [implant.biological ? "нарост" : "блеск"] на [genderize_ru(gender, "его", "её", "его", "их")] хвосте.\n")


	if(get_gravity(src) < -NO_GRAVITY && !buckled)
		msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] наход[pluralize_ru(gender, "и", "я")]тся на потолке.\n"

	if(user.no_gravity() && !buckled)
		msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] не подвержен[genderize_ru(gender, "", "а", "о", "ы")] действию гравитации.\n"

	if(decaylevel == 1)
		msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] начал[genderize_ru(gender, "", "а", "о", "и")] разлагаться и неприятно пахнуть.\n"
	if(decaylevel == 2)
		msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] раздут[genderize_ru(gender, "", "а", "о", "ы")] и отвратительно пахн[pluralize_ru(gender, "ет", "ют")].\n"
	if(decaylevel == 3)
		msg += "[genderize_ru(gender, "Он почернел", "Она почернела", "Оно почернело", "Они почернели")] и гниёт, кожа слезает лоскутами. Зловоние неописуемо.\n"
	if(decaylevel == 4)
		msg += "[genderize_ru(gender, "Он", "Она", "Оно", "Они")] почти полностью разложил[genderize_ru(gender, "ся", "ась", "ось", "ись")]. От [genderize_ru(gender, "него", "неё", "него", "них")] остался лишь скелет.\n"

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
								commentLatest = LAZYACCESS(comments, comments.len) //get the latest entry from the comment log
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

		msg += "[span_deptradio("Психологический статус:")] <a href='byond://?src=[UID()];medical=1'>\[[medical]\]</a>\n"
		msg += "[span_deptradio("Медицинские записи:")] <a href='byond://?src=[UID()];medrecord=`'>\[View\]</a> <a href='byond://?src=[UID()];medrecordadd=`'>\[Добавить комментарий\]</a>\n"

	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(print_flavor_text() && !skipface && !head_organ?.is_disfigured())
		msg += "[print_flavor_text()]\n"

	if(pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
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
