/obj/item/clothing/gloves/color
	dying_key = DYE_REGISTRY_GLOVES

/obj/item/clothing/gloves/color/yellow
	name = "insulated gloves"
	desc = "Защищают владельца от удара током."
	ru_names = list(
		NOMINATIVE = "изоляционные перчатки",
		GENITIVE = "изоляционных перчаток",
		DATIVE = "изоляционным перчаткам",
		ACCUSATIVE = "изоляционные перчатки",
		INSTRUMENTAL = "изоляционными перчатками",
		PREPOSITIONAL = "изоляционных перчатках"
	)
	icon_state = "yellow"
	item_state = "ygloves"
	belt_icon = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	item_color="yellow"
	resistance_flags = NONE

/obj/item/clothing/gloves/color/yellow/power
	description_antag = "Это перчатки с усилением, способные выпускать электрические разряды при контакте с кабелями под напряжением"
	var/old_mclick_override
	var/datum/middleClickOverride/power_gloves/mclick_override = new /datum/middleClickOverride/power_gloves
	var/last_shocked = 0
	var/shock_delay = 40
	var/unlimited_power = FALSE // Does this really need explanation?


/obj/item/clothing/gloves/color/yellow/power/equipped(mob/living/carbon/human/user, slot, initial)
	. = ..()

	if(!ishuman(user) || slot != ITEM_SLOT_GLOVES)
		return .

	if(user.middleClickOverride)
		old_mclick_override = user.middleClickOverride
	user.middleClickOverride = mclick_override
	if(!unlimited_power)
		to_chat(user, span_notice("Вы чувствуете, как в [declent_ru(PREPOSITIONAL)] накапливается электричество."))
	else
		to_chat(user, span_biggerdanger("Вы чувствуете, что обладаете БЕСКОНЕЧНОЙ СИЛОЙ!!!"))


/obj/item/clothing/gloves/color/yellow/power/dropped(mob/living/carbon/human/user, slot, silent = FALSE)
	. = ..()

	if(!ishuman(user) || slot != ITEM_SLOT_GLOVES || user.middleClickOverride != mclick_override)
		return .

	if(old_mclick_override)
		user.middleClickOverride = old_mclick_override
		old_mclick_override = null
	else
		user.middleClickOverride = null


/obj/item/clothing/gloves/color/yellow/power/unlimited
	name = "UNLIMITED POWER gloves"
	desc = "Эти перчатки обладают БЕСКОНЕЧНОЙ СИЛОЙ."
	ru_names = list(
		NOMINATIVE = "перчатки БЕСКОНЕЧНОЙ СИЛЫ",
		GENITIVE = "перчаток БЕСКОНЕЧНОЙ СИЛЫ",
		DATIVE = "перчаткам БЕСКОНЕЧНОЙ СИЛЫ",
		ACCUSATIVE = "перчатки БЕСКОНЕЧНОЙ СИЛЫ",
		INSTRUMENTAL = "перчатками БЕСКОНЕЧНОЙ СИЛЫ",
		PREPOSITIONAL = "перчатках БЕСКОНЕЧНОЙ СИЛЫ"
	)

	shock_delay = 0
	unlimited_power = TRUE

/obj/item/clothing/gloves/color/yellow/fake
	siemens_coefficient = 1

/obj/item/clothing/gloves/color/yellow/fake/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += span_notice("На ощупь они не похожи на резину...")


/obj/item/clothing/gloves/color/fyellow                             //Cheap Chinese Crap
	name = "budget insulated gloves"
	desc = "Эти перчатки – дешевые копии желанных перчаток, и это ни в коем случае не может плохо закончиться."
	ru_names = list(
		NOMINATIVE = "бюджетные изоляционные перчатки",
		GENITIVE = "бюджетных изоляционных перчаток",
		DATIVE = "бюджетным изоляционным перчаткам",
		ACCUSATIVE = "бюджетные изоляционные перчатки",
		INSTRUMENTAL = "бюджетными изоляционными перчатками",
		PREPOSITIONAL = "бюджетных изоляционных перчатках"
	)
	icon_state = "fyellow"
	item_state = "ygloves"
	siemens_coefficient = 0			//Set to a default of 0
	belt_icon = "ygloves"
	permeability_coefficient = 0.05
	item_color="yellow"
	resistance_flags = NONE
	toolspeedmod = 0.2
	clothing_traits = list(TRAIT_NO_GUNS)


/obj/item/clothing/gloves/color/fyellow/old
	name = "worn out insulated gloves"
	desc = "Старые потрёпанные перчатки. Будем надеяться, что ещё работают."
	ru_names = list(
		NOMINATIVE = "изношенные изоляционные перчатки",
		GENITIVE = "изношенных изоляционных перчаток",
		DATIVE = "изношенным изоляционным перчаткам",
		ACCUSATIVE = "изношенные изоляционные перчатки",
		INSTRUMENTAL = "изношенными изоляционными перчатками",
		PREPOSITIONAL = "изношенных изоляционных перчатках"
	)


/obj/item/clothing/gloves/color/fyellow/old/New()
	..()
	siemens_coefficient = pick(0,0,0,0.5,0.5,0.5,0.75)

/obj/item/clothing/gloves/color/black
	name = "black gloves"
	desc = "Эти перчатки огнеупорны."
	ru_names = list(
		NOMINATIVE = "чёрные перчатки",
		GENITIVE = "чёрных перчаток",
		DATIVE = "чёрным перчаткам",
		ACCUSATIVE = "чёрные перчатки",
		INSTRUMENTAL = "чёрными перчатками",
		PREPOSITIONAL = "чёрных перчатках"
	)
	icon_state = "black"
	item_state = "bgloves"
	item_color="black"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	var/can_be_cut = 1


/obj/item/clothing/gloves/color/black/hos
	item_color = "hosred"		//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/color/black/ce
	item_color = "chief"			//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/color/black/thief
	pickpocket = TRUE


/obj/item/clothing/gloves/color/black/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!can_be_cut || icon_state != initial(icon_state))	// only if not dyed
		to_chat(user, span_warning("Вы не можете обрезать [declent_ru(ACCUSATIVE)]!"))
		return .
	if(loc == user)
		to_chat(user, span_warning("Вы  не можете обрезать [declent_ru(PREPOSITIONAL)] не снимая их с рук!"))
		return .
	var/confirm = tgui_alert(user, "Обрезать кончики перчаток? Предупреждение: это может нарушить их функциональность.", "Обрезка кончиков?", list("Да", "Нет"))
	if(confirm != "Да" || icon_state != initial(icon_state) || !Adjacent(user) || user.incapacitated())
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	to_chat(user, span_notice("Вы обрезали кончики на [declent_ru(PREPOSITIONAL)]."))
	var/obj/item/clothing/gloves/fingerless/new_gloves = new(loc)
	transfer_fingerprints_to(new_gloves)
	new_gloves.add_fingerprint(user)
	if(pickpocket)
		new_gloves.pickpocket = FALSE
	qdel(src)


/obj/item/clothing/gloves/color/black/goliath
	name = "goliath gloves"
	desc = "Примитивные перчатки, которые облегчают переноску."
	ru_names = list(
		NOMINATIVE = "перчатки из шкуры голиафа",
		GENITIVE = "перчаток из шкуры голиафа",
		DATIVE = "перчаткам из шкуры голиафа",
		ACCUSATIVE = "перчатки из шкуры голиафа",
		INSTRUMENTAL = "перчатками из шкуры голиафа",
		PREPOSITIONAL = "перчатках из шкуры голиафа"
	)
	icon_state = "goligloves"
	item_state = "goligloves"
	armor = list("melee" = 20, "bullet" = 10, "laser" = 10, "energy" = 5, "bomb" = 0, "bio" = 0, "rad" = 20, "fire" = 50, "acid" = 50)
	can_be_cut = FALSE

/obj/item/clothing/gloves/color/black/ballistic
	name = "armored gloves"
	desc = "Перчатки с дополнительной защитой."
	ru_names = list(
		NOMINATIVE = "бронированные перчатки",
		GENITIVE = "бронированных перчаток",
		DATIVE = "бронированным перчаткам",
		ACCUSATIVE = "бронированные перчатки",
		INSTRUMENTAL = "бронированными перчатками",
		PREPOSITIONAL = "бронированных перчатках"
	)
	icon_state = "armored_gloves"
	item_state = "armored_gloves"
	armor = list("melee" = 5, "bullet" = 25, "laser" = 10, "energy" = 5, "bomb" = 5, "bio" = 0, "rad" = 0, "fire" = 75, "acid" = 75)
	can_be_cut = FALSE
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/gloves.dmi'
		)

/obj/item/clothing/gloves/color/orange
	name = "orange gloves"
	desc = "Пара перчаток, в которых, кажется, нет ничего особенного."
	ru_names = list(
		NOMINATIVE = "оранжевые перчатки",
		GENITIVE = "оранжевых перчаток",
		DATIVE = "оранжевым перчаткам",
		ACCUSATIVE = "оранжевые перчатки",
		INSTRUMENTAL = "оранжевыми перчатками",
		PREPOSITIONAL = "оранжевых перчатках"
	)
	icon_state = "orange"
	item_state = "orangegloves"
	item_color="orange"

/obj/item/clothing/gloves/color/red
	name = "red gloves"
	desc = "Пара перчаток, в которых, кажется, нет ничего особенного."
	ru_names = list(
		NOMINATIVE = "красные перчатки",
		GENITIVE = "красных перчаток",
		DATIVE = "красным перчаткам",
		ACCUSATIVE = "красные перчатки",
		INSTRUMENTAL = "красными перчатками",
		PREPOSITIONAL = "красных перчатках"
	)
	icon_state = "red"
	item_state = "redgloves"
	item_color = "red"

/obj/item/clothing/gloves/color/red/insulated
	name = "insulated gloves"
	desc = "Защищают владельца от удара током."
	ru_names = list(
		NOMINATIVE = "изоляционные перчатки",
		GENITIVE = "изоляционных перчаток",
		DATIVE = "изоляционным перчаткам",
		ACCUSATIVE = "изоляционные перчатки",
		INSTRUMENTAL = "изоляционными перчатками",
		PREPOSITIONAL = "изоляционных перчатках"
	)
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	resistance_flags = NONE

/obj/item/clothing/gloves/color/rainbow
	name = "rainbow gloves"
	desc = "Пара перчаток, в которых, кажется, нет ничего особенного."
	ru_names = list(
		NOMINATIVE = "радужные перчатки",
		GENITIVE = "радужных перчаток",
		DATIVE = "радужным перчаткам",
		ACCUSATIVE = "радужные перчатки",
		INSTRUMENTAL = "радужными перчатками",
		PREPOSITIONAL = "радужных перчатках"
	)
	icon_state = "rainbow"
	item_state = "rainbowgloves"
	item_color = "rainbow"

/obj/item/clothing/gloves/color/rainbow/clown
	item_color = "clown"

/obj/item/clothing/gloves/color/blue
	name = "blue gloves"
	desc = "Пара перчаток, в которых, кажется, нет ничего особенного."
	ru_names = list(
		NOMINATIVE = "синие перчатки",
		GENITIVE = "синих перчаток",
		DATIVE = "синим перчаткам",
		ACCUSATIVE = "синие перчатки",
		INSTRUMENTAL = "синими перчатками",
		PREPOSITIONAL = "синих перчатках"
	)
	icon_state = "blue"
	item_state = "bluegloves"
	item_color="blue"

/obj/item/clothing/gloves/color/purple
	name = "purple gloves"
	desc = "Пара перчаток, в которых, кажется, нет ничего особенного."
	ru_names = list(
		NOMINATIVE = "фиолетовые перчатки",
		GENITIVE = "фиолетовых перчаток",
		DATIVE = "фиолетовым перчаткам",
		ACCUSATIVE = "фиолетовые перчатки",
		INSTRUMENTAL = "фиолетовыми перчатками",
		PREPOSITIONAL = "фиолетовых перчатках"
	)
	icon_state = "purple"
	item_state = "purplegloves"
	item_color="purple"

/obj/item/clothing/gloves/color/green
	name = "green gloves"
	desc = "Пара перчаток, в которых, кажется, нет ничего особенного."
	ru_names = list(
		NOMINATIVE = "зелёные перчатки",
		GENITIVE = "зелёных перчаток",
		DATIVE = "зелёным перчаткам",
		ACCUSATIVE = "зелёные перчатки",
		INSTRUMENTAL = "зелёными перчатками",
		PREPOSITIONAL = "зелёных перчатках"
	)
	icon_state = "green"
	item_state = "greengloves"
	item_color="green"

/obj/item/clothing/gloves/color/grey
	name = "grey gloves"
	desc = "Пара перчаток, в которых, кажется, нет ничего особенного."
	ru_names = list(
		NOMINATIVE = "серые перчатки",
		GENITIVE = "серых перчаток",
		DATIVE = "серым перчаткам",
		ACCUSATIVE = "серые перчатки",
		INSTRUMENTAL = "серыми перчатками",
		PREPOSITIONAL = "серых перчатках"
	)
	icon_state = "gray"
	item_state = "graygloves"
	item_color="grey"

/obj/item/clothing/gloves/color/grey/rd
	item_color = "director"			//Exists for washing machines. Is not different from gray gloves in any way.

/obj/item/clothing/gloves/color/grey/hop
	item_color = "hop"				//Exists for washing machines. Is not different from gray gloves in any way.

/obj/item/clothing/gloves/color/light_brown
	name = "light brown gloves"
	desc = "Пара перчаток, в которых, кажется, нет ничего особенного."
	ru_names = list(
		NOMINATIVE = "светло-коричневые перчатки",
		GENITIVE = "светло-коричневых перчаток",
		DATIVE = "светло-коричневым перчаткам",
		ACCUSATIVE = "светло-коричневые перчатки",
		INSTRUMENTAL = "светло-коричневыми перчатками",
		PREPOSITIONAL = "светло-коричневых перчатках"
	)
	icon_state = "lightbrown"
	item_state = "lightbrowngloves"
	item_color="light brown"

/obj/item/clothing/gloves/color/brown
	name = "brown gloves"
	desc = "Пара перчаток, в которых, кажется, нет ничего особенного."
	ru_names = list(
		NOMINATIVE = "коричневые перчатки",
		GENITIVE = "коричневых перчаток",
		DATIVE = "коричневым перчаткам",
		ACCUSATIVE = "коричневые перчатки",
		INSTRUMENTAL = "коричневыми перчатками",
		PREPOSITIONAL = "коричневых перчатках"
	)
	icon_state = "brown"
	item_state = "browngloves"
	item_color="brown"

/obj/item/clothing/gloves/color/brown/cargo
	name = "cargo gloves"
	ru_names = list(
		NOMINATIVE = "перчатки грузчика",
		GENITIVE = "перчаток грузчика",
		DATIVE = "перчаткам грузчика",
		ACCUSATIVE = "перчатки грузчика",
		INSTRUMENTAL = "перчатками грузчика",
		PREPOSITIONAL = "перчатках грузчика"
	)
	item_color = "cargo"				//Exists for washing machines. Is not different from brown gloves in any way.

/obj/item/clothing/gloves/color/latex
	name = "latex gloves"
	desc = "Дешёвые стерильные перчатки белого цвета, изготовленные из латекса. \
			Обеспечивают защиту от биологических загрязнений и практически не пропускают вредные вещества."
	ru_names = list(
		NOMINATIVE = "латексные перчатки",
		GENITIVE = "латексных перчаток",
		DATIVE = "латексным перчаткам",
		ACCUSATIVE = "латексные перчатки",
		INSTRUMENTAL = "латексными перчатками",
		PREPOSITIONAL = "латексных перчатках"
	)
	icon_state = "latex"
	item_state = "lgloves"
	belt_icon = "latex_gloves"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	item_color= "white"
	transfer_prints = TRUE
	resistance_flags = NONE
	clothing_traits = list(TRAIT_QUICK_CARRY)

/obj/item/clothing/gloves/color/latex/nitrile
	name = "nitrile gloves"
	desc = "Высокопрочные стерильные перчатки, изготовленные из синтетического нитрила. \
			Обеспечивают защиту от биологических загрязнений и практически не пропускают вредные вещества. \
			Обычно используются врачами и криминалистами."
	ru_names = list(
		NOMINATIVE = "нитриловые перчатки",
		GENITIVE = "нитриловых перчаток",
		DATIVE = "нитриловым перчаткам",
		ACCUSATIVE = "нитриловые перчатки",
		INSTRUMENTAL = "нитриловыми перчатками",
		PREPOSITIONAL = "нитриловых перчатках"
	)
	icon_state = "nitrile"
	item_state = "nitrile"
	transfer_prints = FALSE
	item_color = "medical"
	clothing_traits = list(TRAIT_QUICKER_CARRY)

/obj/item/clothing/gloves/color/latex/modified
	name = "modified medical gloves"
	desc = "Передовые медицинские перчатки, созданные из сверхтонкого гибридного полимера, сочетающего эластичность латекса и прочность нитрила. \
			Обеспечивают защиту от биологических загрязнений и практически не пропускают вредные вещества. \
			Обеспечивают удобство и повышенную точность при проведении хирургических операций."
	ru_names = list(
		NOMINATIVE = "модифицированные медперчатки",
		GENITIVE = "модифицированных медперчаток",
		DATIVE = "модифицированным медперчаткам",
		ACCUSATIVE = "модифицированные медперчатки",
		INSTRUMENTAL = "модифицированными медперчатками",
		PREPOSITIONAL = "модифицированных медперчатках"
	)
	icon_state = "modified"
	item_state = "modified"
	item_color = "modified"
	surgeryspeedmod = -0.3

/obj/item/clothing/gloves/color/latex/inugami
	name = "medical gloves Inugami"
	desc = "Перчатки медицинского назначения серии Inugami — прототип, разработанный для использования хирургами. \
			Изготовлены из полимерного материала, обеспечивающего защиту от биологических загрязнений и практически не пропускающего вредные вещества. \
			Оснащены встроенными наночипами, существенно повышающими скорость выполнения хирургических операций."
	ru_names = list(
		NOMINATIVE = "медицинские перчатки Inugami",
		GENITIVE = "медицинских перчаток Inugami",
		DATIVE = "медицинским перчаткам Inugami",
		ACCUSATIVE = "медицинские перчатки Inugami",
		INSTRUMENTAL = "медицинскими перчатками Inugami",
		PREPOSITIONAL = "медицинских перчатках Inugami",
	)
	icon_state = "inugami_gl"
	item_state = "inugami_gl"
	item_color = null
	surgery_step_time = 0.5 SECONDS
	surgery_germ_chance = 50

/obj/item/clothing/gloves/color/latex/inugami/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/defib, ignore_hardsuits = TRUE, safe_by_default = TRUE, emp_proof = TRUE, emag_proof = TRUE)

/obj/item/clothing/gloves/color/latex/inugami/equipped(mob/living/carbon/human/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		RegisterSignal(user, COMSIG_SURGERY_STEP_INIT, PROC_REF(on_surgery_step_init))
	else
		UnregisterSignal(user, COMSIG_SURGERY_STEP_INIT)

/obj/item/clothing/gloves/color/latex/inugami/dropped(mob/living/carbon/human/user, slot, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_SURGERY_STEP_INIT)

/obj/item/clothing/gloves/color/latex/inugami/proc/on_surgery_step_init(user, time_pointer)
	SIGNAL_HANDLER
	*time_pointer = surgery_step_time

/obj/item/clothing/gloves/color/white
	name = "white gloves"
	desc = "Выглядят довольно элегантно."
	ru_names = list(
		NOMINATIVE = "белые перчатки",
		GENITIVE = "белых перчаток",
		DATIVE = "белым перчаткам",
		ACCUSATIVE = "белые перчатки",
		INSTRUMENTAL = "белыми перчатками",
		PREPOSITIONAL = "белых перчатках"
	)
	icon_state = "white"
	item_state = "wgloves"
	item_color="mime"

/obj/item/clothing/gloves/color/white/redcoat
	item_color = "redcoat"		//Exists for washing machines. Is not different from white gloves in any way.


/obj/item/clothing/gloves/color/captain
	desc = "Роскошные синие перчатки с красивой золотой отделкой. Шикарно."
	name = "captain's gloves"
	ru_names = list(
		NOMINATIVE = "капитанские перчатки",
		GENITIVE = "капитанских перчаток",
		DATIVE = "капитанским перчаткам",
		ACCUSATIVE = "капитанские перчатки",
		INSTRUMENTAL = "капитанскими перчатками",
		PREPOSITIONAL = "капитанских перчатках"
	)
	icon_state = "captain"
	item_state = "egloves"
	item_color = "captain"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 60
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 30, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 75, "acid" = 75)
