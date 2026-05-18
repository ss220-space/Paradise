/obj/item/clothing/suit/armor/vox_merc
	name = "vox mercenary vest"
	desc = "Специализированный бронекостюм воксов-наемников. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными для большинства атмосфер с приемлимым давлением."
	icon_state = "vox-merc"
	item_color = "vox-merc"
	item_state = "armor"
	blood_overlay_type = "armor"
	species_restricted = list(SPECIES_VOX)
	icon = 'icons/obj/clothing/species/vox/suits.dmi'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
	)
	allowed = list(
		/obj/item/gun,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/restraints/handcuffs,
		/obj/item/tank/internals,
	)
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 20, BOMB = 25, FIRE = 50, ACID = 50)
	strip_delay = 8 SECONDS
	put_on_delay = 6 SECONDS

/obj/item/clothing/suit/armor/vox_merc/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/head/helmet/vox_merc
	name = "vox mercenary helmet"
	desc = "Специализированный шлем воксов-наемников."
	icon_state = "vox-merc"
	item_color = "vox-merc"
	species_restricted = list(SPECIES_VOX)
	icon = 'icons/obj/clothing/species/vox/hats.dmi'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
	)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 20, BOMB = 25, FIRE = 50, ACID = 50)
	flags_inv = HIDEMASK | HIDEHEADSETS | HIDEHEADHAIR
	dog_fashion = null

/obj/item/clothing/head/helmet/vox_merc/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

// Storm Trooper

/obj/item/clothing/suit/armor/vox_merc/stormtrooper
	name = "vox mercenary storm vest"
	desc = "Специализированный бронекостюм воксов-наемников. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными для большинства атмосфер с приемлимым давлением. \
			\nШтурмовой бронекостюм воксов разработан под их структуру тела и прикрывает наиболее уязвимые места, превосходно защищает носителя от огнестрельного вооружения и ближних атак."
	icon_state = "vox-merc-stormtrooper"
	item_color = "vox-merc-stormtrooper"
	w_class = WEIGHT_CLASS_BULKY
	armor = list(MELEE = 115, BULLET = 115, LASER = 50, ENERGY = 30, BOMB = 15, FIRE = 50, ACID = 50)
	strip_delay = 12 SECONDS
	put_on_delay = 8 SECONDS
	slowdown = 1

/obj/item/clothing/head/helmet/vox_merc/stormtrooper
	icon_state = "vox-merc-stormtrooper"
	item_color = "vox-merc-stormtrooper"
	armor = list(MELEE = 115, BULLET = 115, LASER = 50, ENERGY = 30, BOMB = 15, FIRE = 50, ACID = 50)

// Field Medic

/obj/item/clothing/suit/armor/vox_merc/fieldmedic
	name = "vox mercenary field medic vest"
	desc = "Специализированный бронекостюм воксов-наемников. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными для большинства атмосфер с приемлимым давлением. \
			\nМедицинский полевой костюм предназначен для защиты владельца от биологических угроз, радиации и кислотной атмосферы. Дает слабую защиту от внешне поступаемых энергетических снарядов, равномерно рассеивая остаточную энергию. Костюм абсолютно не предназначен для защиты в ближнем бою или от взрывчатых веществ за счет свое внутреннего строения, повреждающий носителя от осколков костюма при нарушении целостности. Имеет хранилище для ношения аптечек и контейнеров с химикатами."
	icon_state = "vox-merc-fieldmedic"
	item_color = "vox-merc-fieldmedic"
	armor = list(MELEE = -15, BULLET = 20, LASER = 50, ENERGY = 40, BOMB = -15, FIRE = 80, ACID = INFINITY)
	strip_delay = 6 SECONDS
	put_on_delay = 4 SECONDS
	allowed = list(
		/obj/item/flashlight,
		/obj/item/storage/firstaid,
		/obj/item/gun,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/restraints/handcuffs,
		/obj/item/tank/internals,
		/obj/item/analyzer,
		/obj/item/stack/medical,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/applicator,
		/obj/item/healthanalyzer,
		/obj/item/flashlight/pen,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/food/pill,
		/obj/item/storage/pill_bottle,
		/obj/item/paper,
		/obj/item/robotanalyzer,
	)

/obj/item/clothing/head/helmet/vox_merc/fieldmedic
	name = "vox mercenary field medic helmet"
	icon_state = "vox-merc-fieldmedic"
	item_color = "vox-merc-fieldmedic"
	armor = list(MELEE = -15, BULLET = 20, LASER = 50, ENERGY = 40, BOMB = -15, FIRE = 80, ACID = INFINITY)
	flags_inv = HIDEMASK

// Bomber

/obj/item/clothing/suit/armor/vox_merc/bomber
	name = "vox mercenary bomber vest"
	desc = "Специализированный бронекостюм воксов-наемников. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными для большинства атмосфер с приемлимым давлением. \
			\nОсобый разработанный штурмовой тяжелый костюм для действий в условиях крайне взрывоопасной атмосферы. Абсолютная жаростойкость, повышенная стойкость к кислотным жидкостям и лазерному воздействию делают эту броню основной для воксов действующих внутри активно разрушающихся комплексов и кораблей."
	icon_state = "vox-merc-bomber"
	item_color = "vox-merc-bomber"
	armor = list(MELEE = 80, BULLET = 20, LASER = 115, ENERGY = 75, BOMB = 200, FIRE = INFINITY, ACID = 150)
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 12 SECONDS
	put_on_delay = 8 SECONDS
	slowdown = 1.5

/obj/item/clothing/head/helmet/vox_merc/bomber
	name = "vox mercenary bomber helmet"
	icon_state = "vox-merc-bomber"
	item_color = "vox-merc-bomber"
	armor = list(MELEE = 80, BULLET = 20, LASER = 115, ENERGY = 75, BOMB = 200, FIRE = INFINITY, ACID = 150)
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT

// Laminar

/obj/item/clothing/suit/armor/vox_merc/laminar
	name = "vox mercenary laminar vest"
	desc = "Специализированный бронекостюм воксов-наемников. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными для большинства атмосфер с приемлимым давлением. \
			\nКомпактный и мобильный костюм отлично помещается в рюкзаке, сформирован из легких пластин позволяющий получить хорошие защитные свойства в совокупности с удобством для носителя, не мешающий его передвижению. Но, в отличии от других моделей, не дает приемлимых защитных параметров от воздействий внешней агрессивной среды и не защищает руки."
	icon_state = "vox-merc-laminar"
	item_color = "vox-merc-laminar"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET	// Руки уязвимые зоны.
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET
	armor = list(MELEE = 20, BULLET = 20, LASER = 40, ENERGY = 40, BOMB = 15, FIRE = 20, ACID = 20)
	strip_delay = 2 SECONDS
	put_on_delay = 1 SECONDS

/obj/item/clothing/head/helmet/vox_merc/laminar
	name = "vox mercenary laminar helmet"
	icon_state = "vox-merc-laminar"
	item_color = "vox-merc-laminar"
	w_class = WEIGHT_CLASS_SMALL
	armor = list(MELEE = 20, BULLET = 20, LASER = 40, ENERGY = 40, BOMB = 15, FIRE = 20, ACID = 20)
	flags_inv = HIDEHEADSETS|HIDEGLASSES

/obj/item/clothing/suit/armor/vox_merc/laminar/scout
	name = "vox mercenary laminar scout vest"
	desc = "Компактный и мобильный костюм сформированный из лёгких пластин и за счет их особого размещения, увеличивает погашение импульсов перенаправляя их в ускорение носителя, но взамен теряя значимые защитные свойства. "
	armor = list(MELEE = 20, BULLET = 20, LASER = 10, ENERGY = 40, BOMB = 40, FIRE = 20, ACID = 20)
	slowdown = -0.35

// Stealth

// Crew Steath Suit
/obj/item/clothing/suit/armor/vox_merc/stealth
	name = "vox mercenary stealth suit"
	desc = "Специализированный маскировочный костюм воксов-наемников. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными для большинства атмосфер с приемлимым давлением. \
			Костюм с маскировочной системой, напрямую связанная с телом носителя. При снимании костюма возможно ощущение легкого недомогания."
	icon_state = "vox-merc-stealth"
	item_color = "vox-merc-stealth"
	blood_overlay_type = "suit"
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 15, FIRE = INFINITY, ACID = 80)
	strip_delay = 6 SECONDS
	put_on_delay = 4 SECONDS
	actions_types = list(/datum/action/cooldown/disguise_self/vox)

/datum/action/cooldown/disguise_self/vox
	name = "Маскировка"
	desc = "Замаскируйтесь под члена экипажа с его голосом в текущей зоне. \
			Внимательный осмотр выдаст вас. Если повредить маскировку — она сбросится."

/datum/action/cooldown/disguise_self
	name = "Disguise Self"
	desc = "Disguise yourself as a crewmember, based on your current location. Also changes your voice. Takes two seconds to cast, must stand still. \
		The illusion isn't strong enough for more thorough examinations, but will fool people at a glance. \
		You will lose control over the illusion if you're attacked, shoved, or a object is thrown at you, no matter how soft."

	cooldown_time = 3 SECONDS
	base_icon_state = "disguise_self"

/datum/action/cooldown/disguise_self/Activate(atom/target)
	var/mob/user = owner
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_user = user

	human_user.emote("spin")
	to_chat(human_user, span_notice("You start spinning in place and casting [src]..."))
	if(do_after(human_user, 2 SECONDS, FALSE, human_user))
		finish_disguise(human_user)
		return TRUE

	human_user.slip(weaken = 1 SECONDS, slipped_on = "your own foot", lube_flags = SLIP_IGNORE_NO_SLIP_WATER|SLIP_WHEN_LYING)
	to_chat(human_user, span_danger("You must stand still to cast [src]!"))
	return FALSE

/datum/action/cooldown/disguise_self/proc/finish_disguise(mob/living/carbon/human/human_target)
	human_target.apply_status_effect(STATUS_EFFECT_MAGIC_DISGUISE)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = 4, location = get_turf(human_target.loc))
	smoke.start()

// Smoke Helmet
/obj/item/clothing/head/helmet/vox_merc/stealth
	name = "vox mercenary stealth helmet"
	desc = "Специализированный шлем воксов-наемников со встроенной системой дымогенератора."
	icon_state = "vox-merc-stealth"
	item_color = "vox-merc-stealth"
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 15, FIRE = INFINITY, ACID = 80)
	flags_inv =  HIDEMASK|HIDEHEADSETS|HIDEGLASSES
	actions_types = list(/datum/action/cooldown/smoke)

/datum/action/cooldown/smoke
	name = "Дымовой занавес"
	desc = "Выпустить дымовую занавесу скрывающее поле зрение всех находящихся в нём в ближайшей зоне."
	cooldown_time = 12 SECONDS

/datum/action/cooldown/smoke/Activate(atom/target)
	. = ..()
	var/datum/effect_system/fluid_spread/smoke/bad/smoke = new ()
	smoke.set_up(amount = 12, location = target)
	smoke.start()

// Vox space gear (vaccuum suit, low pressure armour)
// Can't be equipped by any other species due to bone structure and vox cybernetics.
/obj/item/clothing/suit/space/vox
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs,/obj/item/tank/internals)
	armor = list(melee = 40, bullet = 40, laser = 30, energy = 15, bomb = 30, bio = 30, fire = 80, acid = 85)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	icon = 'icons/obj/clothing/species/vox/suits.dmi'
	icon_state = null
	species_restricted = list(SPECIES_VOX, SPECIES_VOX_ARMALIS)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_VOX_ARMALIS = 'icons/mob/clothing/species/armalis/suit.dmi',
	)

/obj/item/clothing/head/helmet/space/vox
	armor = list(melee = 40, bullet = 40, laser = 30, energy = 15, bomb = 30, bio = 30, fire = 80, acid = 85)
	clothing_flags = STOPSPRESSUREDAMAGE
	flags_cover = HEADCOVERSEYES
	icon = 'icons/obj/clothing/species/vox/hats.dmi'
	icon_state = null
	species_restricted = list(SPECIES_VOX, SPECIES_VOX_ARMALIS)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_VOX_ARMALIS = 'icons/mob/clothing/species/armalis/head.dmi',
	)

/obj/item/clothing/head/helmet/space/vox/pressure
	name = "alien helmet"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "Hey, wasn't this a prop in \"The Abyss\"?"

/obj/item/clothing/suit/space/vox/pressure
	name = "alien pressure suit"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "A huge, armoured, pressurized suit, designed for distinctly nonhuman proportions."

/obj/item/clothing/head/helmet/space/vox/carapace
	name = "alien visor"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/space/vox/carapace
	name = "alien carapace armour"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "An armoured, segmented carapace with glowing purple lights. It looks pretty run-down."

/obj/item/clothing/head/helmet/space/vox/stealth
	name = "alien stealth helmet"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A smoothly contoured, matte-black alien helmet."

/obj/item/clothing/suit/space/vox/stealth
	name = "alien stealth suit"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A sleek black suit. It seems to have a tail, and is very heavy."

/obj/item/clothing/head/helmet/space/vox/medic
	name = "alien goggled helmet"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An alien helmet with enormous goggled lenses."

/obj/item/clothing/suit/space/vox/medic
	name = "alien armour"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An almost organic looking nonhuman pressure suit."
