/datum/species/golem
	name = "Golem"
	name_plural = "Golems"

	icobase = 'icons/mob/human_races/r_golem.dmi'
	deform = 'icons/mob/human_races/r_golem.dmi'

	species_traits = list(NO_BREATHE, NO_BLOOD, NO_PAIN, RADIMMUNE, NOGUNS, PIERCEIMMUNE)
	dies_at_threshold = TRUE
	speed_mod = 2
	brute_mod = 0.45 //55% damage reduction
	burn_mod = 0.45
	tox_mod = 0.45
	clone_mod = 0.45
	brain_mod = 0.45
	stamina_mod = 0.45
	siemens_coeff = 0
	punchdamagelow = 5
	punchdamagehigh = 14
	punchstunthreshold = 11 //about 40% chance to stun
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_w_uniform, slot_s_store)
	nojumpsuit = TRUE

	dietflags = DIET_OMNI		//golems can eat anything because they are magic or something
	reagent_tag = PROCESS_ORG

	warning_low_pressure = -INFINITY
	hazard_low_pressure = -INFINITY
	hazard_high_pressure = INFINITY
	warning_high_pressure = INFINITY

	cold_level_1 = -INFINITY
	cold_level_2 = -INFINITY
	cold_level_3 = -INFINITY

	heat_level_1 = INFINITY
	heat_level_2 = INFINITY
	heat_level_3 = INFINITY

	blood_color = "#515573"
	flesh_color = "#137E8F"
	skinned_type = /obj/item/stack/sheet/metal

	blacklisted = TRUE // To prevent golem subtypes from overwhelming the odds when random species changes, only the Random Golem type can be chosen
	dangerous_existence = TRUE

	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/golem,
		"adamantine_resonator" = /obj/item/organ/internal/adamantine_resonator
		) //Has standard darksight of 2.

	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest/unbreakable/sturdy),
		"groin" =  list("path" = /obj/item/organ/external/groin/unbreakable/sturdy),
		"head" =   list("path" = /obj/item/organ/external/head/unbreakable/sturdy),
		"l_arm" =  list("path" = /obj/item/organ/external/arm/unbreakable/sturdy),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right/unbreakable/sturdy),
		"l_leg" =  list("path" = /obj/item/organ/external/leg/unbreakable/sturdy),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right/unbreakable/sturdy),
		"l_hand" = list("path" = /obj/item/organ/external/hand/unbreakable/sturdy),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right/unbreakable/sturdy),
		"l_foot" = list("path" = /obj/item/organ/external/foot/unbreakable/sturdy),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right/unbreakable/sturdy))

	suicide_messages = list(
		"рассыпается в прах!",
		"разбивает его тело на части!")

	var/golem_colour = rgb(170, 170, 170)
	var/info_text = "Как <span class='danger'>Железный Голем</span>, у вас нет отличительных особенностей."
	var/random_eligible = TRUE
	var/prefix = "Железный"
	var/list/special_names = list("Человек", "Ржавчик", "Утюг", "Металлист",  "Мужик", "Сплав", "Брусок", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай")
	var/human_surname_chance = 3
	var/special_name_chance = 5
	var/owner //dobby is a free golem

/datum/species/golem/get_random_name()
	var/golem_surname = pick(GLOB.golem_names)
	// 3% chance that our golem has a human surname, because cultural contamination
	if(prob(human_surname_chance))
		golem_surname = pick(GLOB.last_names)
	else if(special_names && special_names.len && prob(special_name_chance))
		golem_surname = pick(special_names)

	var/golem_name = "[prefix] [golem_surname]"
	return golem_name

/datum/species/golem/on_species_gain(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.mind.assigned_role = "Golem"
		if(owner)
			H.mind.special_role = SPECIAL_ROLE_GOLEM
		else
			H.mind.special_role = SPECIAL_ROLE_FREE_GOLEM
	H.real_name = get_random_name()
	H.name = H.real_name
	to_chat(H, info_text)

//Random Golem

/datum/species/golem/random
	name = "Random Golem"
	blacklisted = FALSE
	dangerous_existence = FALSE
	var/static/list/random_golem_types

/datum/species/golem/random/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(!random_golem_types)
		random_golem_types = subtypesof(/datum/species/golem) - type
		for(var/V in random_golem_types)
			var/datum/species/golem/G = V
			if(!initial(G.random_eligible))
				random_golem_types -= G
	var/datum/species/golem/golem_type = pick(random_golem_types)
	var/mob/living/carbon/human/H = C
	H.set_species(golem_type)

//Golem subtypes

//Leader golems, can resonate to communicate with all other golems
/datum/species/golem/adamantine
	name = "Adamantine Golem"
	skinned_type = /obj/item/stack/sheet/mineral/adamantine
	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/golem,
		"adamantine_resonator" = /obj/item/organ/internal/adamantine_resonator,
		"vocal_cords" = /obj/item/organ/internal/vocal_cords/adamantine
		)
	golem_colour = rgb(68, 238, 221)
	info_text = "Как <span class='danger'>Адамантиновый Голем</span>, вы обладаете особенным голосовыми связками, позволяющие вас \"резонировать\" послания всем големам."
	prefix = "Адамантиновый"
	special_names = list("Сплав", "Брусок", "Мужик", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай")

//The suicide bombers of golemkind
/datum/species/golem/plasma
	name = "Plasma Golem"
	skinned_type = /obj/item/stack/ore/plasma
	golem_colour = rgb(170, 51, 221)
	heat_level_1 = 360
	heat_level_2 = 400
	heat_level_3 = 460
	info_text = "Как <span class='danger'>Плазма Голем</span>, вы легко сгораете. Будьте отсторожны, если вы сильно нагреетесь - вы взорветесь!"
	heatmod = 0 //fine until they blow up
	prefix = "Плазма"
	special_names = list("Потоп", "Прилив", "Разлив", "Залив", "Мужик", "Наводнение", "Поток", "Ливень", "Пожар", "Стержень", "Минерал", "Мужик", "Горец", "Сгоратель")
	var/boom_warning = FALSE
	var/datum/action/innate/ignite/ignite

/datum/species/golem/plasma/handle_life(mob/living/carbon/human/H)
	if(H.bodytemperature > 750)
		if(!boom_warning && H.on_fire)
			to_chat(H, "<span class='userdanger'>Вы чувствуете что можете взорваться в любой момент!</span>")
			boom_warning = TRUE
	else
		if(boom_warning)
			to_chat(H, "<span class='notice'>Вы чувствуете себя стабильней.</span>")
			boom_warning = FALSE

	if(H.bodytemperature > 850 && H.on_fire && prob(25))
		explosion(get_turf(H), 1, 2, 4, flame_range = 5)
		msg_admin_attack("Plasma Golem ([H.name]) exploded with radius 1, 2, 4 (flame_range: 5) at ([H.x],[H.y],[H.z]). User Ckey: [key_name_admin(H)]", ATKLOG_FEW)
		log_game("Plasma Golem ([H.name]) exploded with radius 1, 2, 4 (flame_range: 5) at ([H.x],[H.y],[H.z]). User Ckey: [key_name_admin(H)]", ATKLOG_FEW)
		if(H)
			H.gib()
	if(H.fire_stacks < 2) //flammable
		H.adjust_fire_stacks(1)
	..()

/datum/species/golem/plasma/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		ignite = new
		ignite.Grant(C)

/datum/species/golem/plasma/on_species_loss(mob/living/carbon/C)
	if(ignite)
		ignite.Remove(C)
	..()

/datum/action/innate/ignite
	name = "Ignite"
	desc = "Подожгите себя и достигните взрыва!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "sacredflame"

/datum/action/innate/ignite/Activate()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.fire_stacks)
			to_chat(owner, "<span class='notice'>Вы подожгли себя!</span>")
		else
			to_chat(owner, "<span class='warning'>Вы попытались поджечь себя, но провалились!</span>")
		H.IgniteMob() //firestacks are already there passively

//Harder to hurt
/datum/species/golem/diamond
	name = "Diamond Golem"
	golem_colour = rgb(0, 255, 255)
	brute_mod = 0.3 //70% damage reduction up from 55%
	burn_mod = 0.3
	tox_mod = 0.3
	clone_mod = 0.3
	brain_mod = 0.3
	stamina_mod = 0.3
	skinned_type = /obj/item/stack/ore/diamond
	info_text = "Как <span class='danger'>Алмазный Голем</span>, вы более устойчивы, чем обычный голем."
	prefix = "Алмазный"
	special_names = list("Back")
	special_names = list("Сплав", "Брусок", "Мужик", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай")

//Faster but softer and less armoured
/datum/species/golem/gold
	name = "Gold Golem"
	golem_colour = rgb(204, 204, 0)
	speed_mod = 1
	brute_mod = 0.75 //25% damage reduction down from 55%
	burn_mod = 0.75
	tox_mod = 0.75
	clone_mod = 0.75
	brain_mod = 0.75
	stamina_mod = 0.75
	skinned_type = /obj/item/stack/ore/gold
	info_text = "Как <span class='danger'>Золотой Голем</span>, вы быстрее, но менее устойчивы, чем обычный голем."
	prefix = "Золотой"
	special_names = list("Мальчик", "Мужик", "Человек", "Ручник", "Молодежник", "Понтовщик", "Мост", "Яблочник", "Ювелир", "Дорогуша", "Дурак", "Брусок", "Закат", "Дым", "Шелк", "Сплав", "Ремесленник", "Мёд")

//Heavier, thus higher chance of stunning when punching
/datum/species/golem/silver
	name = "Silver Golem"
	golem_colour = rgb(221, 221, 221)
	punchstunthreshold = 9 //60% chance, from 40%
	skinned_type = /obj/item/stack/ore/silver
	info_text = "Как <span class='danger'>Серебрянный Голем</span>, ваши атаки имеют более высокий шанс оглушения."
	prefix = "Серебряный"
	special_names = list("Серфер", "Чарриот", "Мужик", "Глушитель", "Тихон", "Анестетик", "Ювелир")

//Harder to stun, deals more damage, but it's even slower
/datum/species/golem/plasteel
	name = "Plasteel Golem"
	golem_colour = rgb(187, 187, 187)
	stun_mod = 0.4
	punchdamagelow = 12
	punchdamagehigh = 21
	punchstunthreshold = 18 //still 40% stun chance
	speed_mod = 4 //pretty fucking slow
	skinned_type = /obj/item/stack/ore/iron
	info_text = "Как <span class='danger'>Пласталиевый Голем</span>, вы медленнее, но вас сложнее оглушить и вы наносите сильные удары кулаком."
	prefix = "Plasteel"
	special_names = list("Сплав", "Брусок", "Мужик", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай")
	unarmed_type = /datum/unarmed_attack/golem/plasteel

/datum/unarmed_attack/golem/plasteel
	attack_verb = list("smash")
	attack_sound = 'sound/effects/meteorimpact.ogg'

//More resistant to burn damage and immune to ashstorm
/datum/species/golem/titanium
	name = "Titanium Golem"
	golem_colour = rgb(255, 255, 255)
	skinned_type = /obj/item/stack/ore/titanium
	info_text = "Как <span class='danger'>Титаниевый Голем</span>, вы устойчивы к урону от ожогов и невосприимчивы к пепельным бурям."
	burn_mod = 0.405
	prefix = "Титаниевый"
	special_names = list("Диоксид", "Сплав", "Брусок", "Мужик", "Минерал", "Кусок", "Кирпич", "Буреходец", "Пожарник", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай")

/datum/species/golem/titanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "ash"

/datum/species/golem/titanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"

//Even more resistant to burn damage and immune to ashstorms and lava
/datum/species/golem/plastitanium
	name = "Plastitanium Golem"
	golem_colour = rgb(136, 136, 136)
	skinned_type = /obj/item/stack/ore/titanium
	info_text = "Как <span class='danger'>Пластитаниумный Голем</span>, вы очень устойчивы к ожогам и невосприимчивы к пепельным бурям и лаве."
	burn_mod = 0.36
	prefix = "Пластаниумный"
	special_names = list("Сплав", "Брусок", "Кусок", "Мужик", "Кирпич", "Минерал", "Буреходец", "Пожарник", "Лавоходец", "Лавоплавунец", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай")

/datum/species/golem/plastitanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "lava"
	C.weather_immunities |= "ash"

/datum/species/golem/plastitanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"
	C.weather_immunities -= "lava"

//Fast and regenerates... but can only speak like an abductor
/datum/species/golem/alloy
	name = "Alien Alloy Golem"
	golem_colour = rgb(51, 51, 51)
	skinned_type = /obj/item/stack/sheet/mineral/abductor
	language = "Golem Mindlink"
	default_language = "Golem Mindlink"
	speed_mod = 1 //faster
	info_text = "Как <span class='danger'>Голем из инопланетных сплавов</span>, вы сделаны из передовых инопланетных материалов: вы быстрее и со временем регенерируете. Однако, вы можете разговаривать только с другими големами из сплава."
	prefix = "Инопланетный"
	special_names = list("Инопришеленец", "Технологичный Голем", "Наблюдатель", "Незнакомец", "Странник", "Чужак", "Посланник", "Минерал", "Мужик", "Пришеленец") //ominous and unknown

//Regenerates because self-repairing super-advanced alien tech
/datum/species/golem/alloy/handle_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	H.adjustBruteLoss(-2)
	H.adjustFireLoss(-2)
	H.adjustToxLoss(-2)
	H.adjustOxyLoss(-2)

/datum/species/golem/alloy/can_understand(mob/other) //Can understand everyone, but they can only speak over their mindlink
	return TRUE

/datum/species/golem/alloy/on_species_gain(mob/living/carbon/human/H)
	..()
	H.languages.Cut()
	H.add_language("Golem Mindlink")

//Regenerates like dionas, less resistant
/datum/species/golem/wood
	name = "Wood Golem"
	golem_colour = rgb(158, 112, 75)
	skinned_type = /obj/item/stack/sheet/wood
	species_traits = list(NO_BREATHE, NO_BLOOD, NO_PAIN, RADIMMUNE, NOGUNS, PIERCEIMMUNE, IS_PLANT)
	//Can burn and take damage from heat
	brute_mod = 0.7 //30% damage reduction down from 55%
	burn_mod = 0.875
	tox_mod = 0.7
	clone_mod = 0.7
	brain_mod = 0.7
	stamina_mod = 0.7
	heatmod = 1.5

	heat_level_1 = 300
	heat_level_2 = 340
	heat_level_3 = 400

	dietflags = DIET_HERB		// Plants eat...plants? -- естественное развитие растений в природе

	info_text = "Как <span class='danger'>Деревянный Голем</span>, вы обладаете особенностями растений: вы получаете урон от экстремальных температур, способный вас поджечь, и у вас меньше брони, чем у обычного голема. Вы регенерируете при свете и увадяете во тьме."
	prefix = "" // Убран префикс "деревяный", ибо выходит масло масляное вида "Деревяная Ветка", "Деревяный Дуб". Что не логично и мешает давать имена.
	special_names = list("Короед", "Грут", "Пень", "Дубень", "Дуболом", "Ива", "Катальпа", "Дуб", "Сок", "Ветка", "Ветка", "Клен", "Береза", "Вяз", "Липа", "Тополь ", "Лиственница", "Осина", "Ясень", "Бук", "Каштан", "Кедр", "Каштан", "Кипарис", "Пихта", "Боярышник", "Лещина", "Гикори", "Айронвуд", "Можжевельник", "Лист", "Мангровый лес", "Пальма", "Азимина", "Сосна", "Тополь", "Красное дерево", "Редбад", "Сассафрас", "Ель", "Сумак", "Ствол", "Орех", "Тис")
	human_surname_chance = 0
	special_name_chance = 100

/datum/species/golem/wood/handle_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.5
		if(light_amount > 0)
			H.clear_alert("nolight")
		else
			H.throw_alert("nolight", /obj/screen/alert/nolight)
		H.adjust_nutrition(light_amount * 10)
		if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
			H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
		if(light_amount > 0.2 && !H.suiciding) //if there's enough light, heal
			H.adjustBruteLoss(-1)
			H.adjustFireLoss(-1)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.adjustBruteLoss(2)
	..()

/datum/species/golem/wood/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "glyphosate" || R.id == "atrazine")
		H.adjustToxLoss(3) //Deal aditional damage
		return TRUE
	return ..()

//Radioactive
/datum/species/golem/uranium
	name = "Uranium Golem"
	golem_colour = rgb(119, 255, 0)
	skinned_type = /obj/item/stack/ore/uranium
	info_text = "Как <span class='danger'>Урановый Голем</span>, вы излучаете радиацию. Это не вредит другим големам, но влияет на органические формы жизни."
	prefix = "Урановый"
	special_names = list("Оксид", "Стержень", "Мужик", "Сплав", "Расплав", "Светоч", "Сиятель", "Свет", "Блеск", "Лучезарец", "Блестатель")

/datum/species/golem/uranium/handle_life(mob/living/carbon/human/H)
	for(var/mob/living/L in range(2, H))
		if(ishuman(L))
			var/mob/living/carbon/human/I = L
			if(!(RADIMMUNE in I.dna.species.species_traits))
				L.apply_effect(10, IRRADIATE)
				if(prob(25)) //reduce spam
					to_chat(L, "<span class='danger'>Вас окутывает мягкое зеленое свечение, исходящее от [H].</span>")
	..()

//Ventcrawler
/datum/species/golem/plastic
	name = "Plastic Golem"
	prefix = "Пластиковый"
	special_names = null
	ventcrawler = VENTCRAWLER_NUDE
	golem_colour = rgb(255, 255, 255)
	skinned_type = /obj/item/stack/sheet/plastic
	info_text = "Как <span class='danger'>Пластиковый Голем</span>, вы способны ползать по вентиляции, если вы раздеты."

//Immune to physical bullets and resistant to brute, but very vulnerable to burn damage. Dusts on death.
/datum/species/golem/sand
	name = "Sand Golem"
	golem_colour = rgb(255, 220, 143)
	skinned_type = /obj/item/stack/ore/glass //this is sand
	brute_mod = 0.25
	burn_mod = 3 //melts easily
	tox_mod = 1
	clone_mod = 1
	brain_mod = 1
	stamina_mod = 1
	info_text = "Как <span class='danger'>Песчаный Голем</span>, вы невосприимчивы к физическим пулям и получаете очень мало грубого урона, но чрезвычайно уязвимы к урону от горения и энергетического оружя. Вы также превратитесь в песок после смерти, что предотвратит любую форму восстановления."
	unarmed_type = /datum/unarmed_attack/golem/sand
	prefix = "Песчаный"
	special_names = list("Замок", "Вихрь", "Мужик", "Ураган", "Смерч", "Волчок", "Бархан", "Червь", "Шторм")

/datum/species/golem/sand/handle_death(gibbed, mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] рассыпался в кучу песка!</span>")
	for(var/obj/item/W in H)
		H.unEquip(W)
	for(var/i=1, i <= rand(3, 5), i++)
		new /obj/item/stack/ore/glass(get_turf(H))
	qdel(H)

/datum/species/golem/sand/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H))
		if(P.flag == "bullet" || P.flag == "bomb")
			playsound(H, 'sound/effects/shovel_dig.ogg', 70, 1)
			H.visible_message("<span class='danger'>[P.name] безвредно тонет в песчаном теле [H]!</span>", \
			"<span class='userdanger'>[P.name] безвредно тонет в песчаном теле  [H]!</span>")
			return FALSE
	return TRUE

/datum/unarmed_attack/golem/sand
	attack_sound = 'sound/effects/shovel_dig.ogg'

//Reflects lasers and resistant to burn damage, but very vulnerable to brute damage. Shatters on death.
/datum/species/golem/glass
	name = "Glass Golem"
	golem_colour = rgb(90, 150, 180)
	skinned_type = /obj/item/shard
	brute_mod = 3 //very fragile
	burn_mod = 0.25
	tox_mod = 1
	clone_mod = 1
	brain_mod = 1
	stamina_mod = 1
	info_text = "Как <span class='danger'>Стеклянный Голем</span>, вы отражаете лазеры и энергетическое оружие и очень устойчивы к урону от горения. Однако вы чрезвычайно уязвимы к грубому урону. После смерти вы разобьется без всякой надежды на восстановление."
	unarmed_type = /datum/unarmed_attack/golem/glass
	prefix = "Стеклянная"
	special_names = list("Линза", "Призма", "Бусинка", "Жемчужина")
	//special_names = list("Волокно", "Преломление", "Отражение")

/datum/species/golem/glass/handle_death(gibbed, mob/living/carbon/human/H)
	playsound(H, "shatter", 70, 1)
	H.visible_message("<span class='danger'>[H] разбился в дребезги!</span>")
	for(var/obj/item/W in H)
		H.unEquip(W)
	for(var/i=1, i <= rand(3, 5), i++)
		new /obj/item/shard(get_turf(H))
	qdel(H)

/datum/species/golem/glass/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H)) //self-shots don't reflect
		if(P.is_reflectable)
			H.visible_message("<span class='danger'>[P.name] отразился от стеклянной кожи [H]!</span>", \
			"<span class='userdanger'>The [P.name] отразился от стеклянной кожи [H]!</span>")

			P.reflect_back(H)

			return FALSE
	return TRUE

/datum/unarmed_attack/golem/glass
	attack_sound = 'sound/effects/glassbr2.ogg'

//Teleports when hit or when it wants to
/datum/species/golem/bluespace
	name = "Bluespace Golem"
	golem_colour = rgb(51, 51, 255)
	skinned_type = /obj/item/stack/ore/bluespace_crystal
	info_text = "Как <span class='danger'>Блюспейс Голем</span>, вы пространственно нестабильны: Вы будете телепортироваться при ударе, и вы можете телепортироваться вручную на большое расстояние.."
	prefix = "Блюспейс"
	special_names = list("Кристалл", "Поликристалл", "Прыгун", "Скакун", "Транзит", "Прыжок", "Скачок", "Разрыв", "Мужик", "Попрыгун")
	unarmed_type = /datum/unarmed_attack/golem/bluespace

	var/datum/action/innate/unstable_teleport/unstable_teleport
	var/teleport_cooldown = 100
	var/last_teleport = 0
	var/tele_range = 6

/datum/species/golem/bluespace/proc/reactive_teleport(mob/living/carbon/human/H)
	H.visible_message("<span class='warning'>[H] телепортировался!</span>", "<span class='danger'>Вы дестабилизируетесь и телепортируетесь!</span>")
	var/list/turfs = new/list()
	for(var/turf/T in orange(tele_range, H))
		if(T.density)
			continue
		if(T.x>world.maxx-tele_range || T.x<tele_range)
			continue
		if(T.y>world.maxy-tele_range || T.y<tele_range)
			continue
		turfs += T
	if(!turfs.len)
		turfs += pick(/turf in orange(tele_range, H))
	var/turf/picked = pick(turfs)
	if(!isturf(picked))
		return
	if(H.buckled)
		H.buckled.unbuckle_mob(H, force = TRUE)
	do_teleport(H, picked)
	return TRUE

/datum/species/golem/bluespace/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == H) //No throwing stuff at yourself to trigger the teleport
			return 0
		else
			reactive_teleport(H)

/datum/species/golem/bluespace/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_teleport + teleport_cooldown && M != H &&  M.a_intent != INTENT_HELP)
		reactive_teleport(H)

/datum/species/golem/bluespace/spec_attacked_by(obj/item/I, mob/living/user, obj/item/organ/external/affecting, intent, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown && user != H)
		reactive_teleport(H)

/datum/species/golem/bluespace/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(world.time > last_teleport + teleport_cooldown)
		reactive_teleport(H)
	return TRUE

/datum/species/golem/bluespace/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		unstable_teleport = new
		unstable_teleport.Grant(C)
		last_teleport = world.time

/datum/species/golem/bluespace/on_species_loss(mob/living/carbon/C)
	if(unstable_teleport)
		unstable_teleport.Remove(C)
	..()

/datum/action/innate/unstable_teleport
	name = "Unstable Teleport"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "blink"
	icon_icon = 'icons/mob/actions/actions.dmi'
	var/activated = FALSE // To prevent spamming
	var/cooldown = 150
	var/last_teleport = 0
	var/tele_range = 6

/datum/action/innate/unstable_teleport/IsAvailable()
	if(..())
		if(world.time > last_teleport + cooldown && !activated)
			return 1
		return 0

/datum/action/innate/unstable_teleport/Activate()
	activated = TRUE
	var/mob/living/carbon/human/H = owner
	H.visible_message("<span class='warning'>[H] начинает вибрировать!</span>", "<span class='danger'>Вы начали заряжать свое блюспейс ядро...</span>")
	playsound(get_turf(H), 'sound/weapons/flash.ogg', 25, 1)
	addtimer(CALLBACK(src, .proc/teleport, H), 15)

/datum/action/innate/unstable_teleport/proc/teleport(mob/living/carbon/human/H)
	activated = FALSE
	H.visible_message("<span class='warning'>[H] телепортировался!</span>", "<span class='danger'>Вы телепортировались!</span>")
	var/list/turfs = new/list()
	for(var/turf/T in orange(tele_range, H))
		if(istype(T, /turf/space))
			continue
		if(T.density)
			continue
		if(T.x>world.maxx-tele_range || T.x<tele_range)
			continue
		if(T.y>world.maxy-tele_range || T.y<tele_range)
			continue
		turfs += T
	if(!turfs.len)
		turfs += pick(/turf in orange(tele_range, H))
	var/turf/picked = pick(turfs)
	if(!isturf(picked))
		return
	if(H.buckled)
		H.buckled.unbuckle_mob(H, force = TRUE)
	do_teleport(H, picked)
	last_teleport = world.time
	UpdateButtonIcon() //action icon looks unavailable
	sleep(cooldown + 5)
	UpdateButtonIcon() //action icon looks available again

/datum/unarmed_attack/golem/bluespace
	attack_verb = "bluespace punch"
	attack_sound = 'sound/effects/phasein.ogg'

//honk
/datum/species/golem/bananium
	name = "Bananium Golem"
	golem_colour = rgb(255, 255, 0)
	punchdamagelow = 0
	punchdamagehigh = 1
	punchstunthreshold = 2 //Harmless and can't stun
	skinned_type = /obj/item/stack/ore/bananium
	info_text = "As a <span class='danger'>Бананиумовый Голем</span>, вы созданы для розыгрышей. Ваше тело издает естественные гудки, и удары по людям издают безвредные гудки. Ваша кожа также истекает бананами, когда она повреждена."
	prefix = "Bananium" //требуется перевед имен клоуна
	special_names = null
	unarmed_type = /datum/unarmed_attack/golem/bananium

	var/last_honk = 0
	var/honkooldown = 0
	var/last_banana = 0
	var/banana_cooldown = 100
	var/active = null

/datum/species/golem/bananium/on_species_gain(mob/living/carbon/human/H)
	..()
	last_banana = world.time
	last_honk = world.time
	H.mutations.Add(COMIC)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/bottle/bottleofbanana(H), slot_r_store)
	H.equip_to_slot_or_del(new /obj/item/bikehorn(H), slot_l_store)
	H.AddElement(/datum/element/waddling)

/datum/species/golem/bananium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.RemoveElement(/datum/element/waddling)

/datum/species/golem/bananium/get_random_name()
	var/clown_name = pick(GLOB.clown_names)
	var/golem_name = "[prefix] [clown_name]" //Без перевода, так как требуется переводы имен роли
	return golem_name

/datum/species/golem/bananium/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_banana + banana_cooldown && M != H &&  M.a_intent != INTENT_HELP)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/spec_attacked_by(obj/item/I, mob/living/user, obj/item/organ/external/affecting, intent, mob/living/carbon/human/H)
	..()
	if(world.time > last_banana + banana_cooldown && user != H)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(world.time > last_banana + banana_cooldown)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time
	return TRUE

/datum/species/golem/bananium/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == H) //No throwing stuff at yourself to make bananas
			return 0
		else
			new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
			last_banana = world.time

/datum/species/golem/bananium/handle_life(mob/living/carbon/human/H)
	if(!active)
		if(world.time > last_honk + honkooldown)
			active = 1
			playsound(get_turf(H), 'sound/items/bikehorn.ogg', 50, 1)
			last_honk = world.time
			honkooldown = rand(20, 80)
			active = null
	..()

/datum/species/golem/bananium/handle_death(gibbed, mob/living/carbon/human/H)
	playsound(get_turf(H), 'sound/misc/sadtrombone.ogg', 70, 0)

/datum/unarmed_attack/golem/bananium
	attack_verb = list("HONK")
	attack_sound = 'sound/items/airhorn2.ogg'
	animation_type = ATTACK_EFFECT_DISARM
	harmless = TRUE

//...
/datum/species/golem/tranquillite
	name = "Tranquillite Golem"
	prefix = "Tranquillite" //требуется перевод имен Мима
	special_names = null
	golem_colour = rgb(255, 255, 255)
	skinned_type = /obj/item/stack/ore/tranquillite
	info_text = "As a <span class='danger'>Транквиллитовый Голем</span>, вы можете создавать невидимые стены и регенерировать выпивая бутылки с ничем."
	unarmed_type = /datum/unarmed_attack/golem/tranquillite

/datum/species/golem/tranquillite/get_random_name()
	var/mime_name = pick(GLOB.mime_names)
	var/golem_name = "[prefix] [mime_name]" //Без перевода, так как требуется переводы имен роли
	return golem_name

/datum/species/golem/tranquillite/on_species_gain(mob/living/carbon/human/H)
	..()
	H.equip_to_slot_or_del(new 	/obj/item/clothing/head/beret(H), slot_head)
	H.equip_to_slot_or_del(new 	/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_r_store)
	H.equip_to_slot_or_del(new 	/obj/item/cane(H), slot_l_hand)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall(null))
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
		H.mind.miming = TRUE

/datum/unarmed_attack/golem/tranquillite
	attack_sound = null
