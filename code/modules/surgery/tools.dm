/obj/item/retractor
	name = "retractor"
	desc = "Инструмент, используемый для расширения полостей при операциях."
	ru_names = list(
		NOMINATIVE = "ретрактор",
		GENITIVE = "ретрактора",
		DATIVE = "ретрактору",
		ACCUSATIVE = "ретрактор",
		INSTRUMENTAL = "ретрактором",
		PREPOSITIONAL = "ретракторе",
	)
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	item_state = "retractor"
	materials = list(MAT_METAL=6000, MAT_GLASS=3000)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=1;biotech=1"
	tool_behaviour = TOOL_RETRACTOR

/obj/item/retractor/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/retractor/laser
	name = "Advanced Laser Retractors"
	desc = "Ретрактор с лазерным наконечником. Последнее слово техники в сфере хирургических операций!"
	ru_names = list(
		NOMINATIVE = "лазерный ретрактор",
		GENITIVE = "лазерного ретрактора",
		DATIVE = "лазерному ретрактору",
		ACCUSATIVE = "лазерный ретрактор",
		INSTRUMENTAL = "лазерным ретрактором",
		PREPOSITIONAL = "лазерном ретракторе",
	)
	icon_state = "retractor_laser"
	item_state = "retractor_laser"
	toolspeed = 0.4

/obj/item/retractor/augment
	desc = "Микромеханический манипулятор, используемый в хирургии для расширения полостей и закрепления надрезов."
	ru_names = list(
		NOMINATIVE = "микромеханический манипулятор",
		GENITIVE = "микромеханического манипулятора",
		DATIVE = "микромеханическому манипулятору",
		ACCUSATIVE = "микромеханический манипулятор",
		INSTRUMENTAL = "микромеханическим манипулятором",
		PREPOSITIONAL = "микромеханическом манипуляторе",
	)
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5

/obj/item/hemostat
	name = "hemostat"
	desc = "Инструмент для зажима кровоточащих сосудов во время операций."
	ru_names = list(
		NOMINATIVE = "гемостат",
		GENITIVE = "гемостата",
		DATIVE = "гемостату",
		ACCUSATIVE = "гемостат",
		INSTRUMENTAL = "гемостатом",
		PREPOSITIONAL = "гемостате",
	)
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	item_state = "hemostat"
	materials = list(MAT_METAL=5000, MAT_GLASS=2500)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "pinched")
	tool_behaviour = TOOL_HEMOSTAT

/obj/item/hemostat/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/hemostat/laser
	name = "Advanced Laser Hemostat"
	desc = "Гемостат с лазерным зажимом. Последнее слово техники в сфере хирургических операций!"
	ru_names = list(
		NOMINATIVE = "лазерный гемостат",
		GENITIVE = "лазерного гемостата",
		DATIVE = "лазерному гемостату",
		ACCUSATIVE = "лазерный гемостат",
		INSTRUMENTAL = "лазерным гемостатом",
		PREPOSITIONAL = "лазерном гемостате",
	)
	icon_state = "hemostat_laser"
	item_state = "hemostat_laser"
	toolspeed = 0.4

/obj/item/hemostat/augment
	desc = "Хирургический инструмент, состоящий из нескольких зажимов и сервомоторов. Используется для перекрытия сосудов и остановки возникающего кровотечения во время операции."
	toolspeed = 0.5

/obj/item/cautery
	name = "cautery"
	desc = "Хирургический инструмент, используемый для прижигания открытых ран и надрезов."
	ru_names = list(
		NOMINATIVE = "прижигатель",
		GENITIVE = "прижигателя",
		DATIVE = "прижигателю",
		ACCUSATIVE = "прижигатель",
		INSTRUMENTAL = "прижигателем",
		PREPOSITIONAL = "прижигателе",
	)
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	item_state = "cautery"
	materials = list(MAT_METAL=2500, MAT_GLASS=750)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("burnt")
	tool_behaviour = TOOL_CAUTERY

/obj/item/cautery/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/cautery/augment
	desc = "Нагревательный элемент, используемый для прижигания ран."
	toolspeed = 0.5

/obj/item/surgicaldrill
	name = "surgical drill"
	desc = "Инструмент, предназначенный для сверления отверстий. Постарайтесь не попасть себе в глаз!"
	icon = 'icons/obj/surgery.dmi'
	ru_names = list(
		NOMINATIVE = "хирургическая дрель",
		GENITIVE = "хирургической дрели",
		DATIVE = "хирургической дрели",
		ACCUSATIVE = "хирургическую дрель",
		INSTRUMENTAL = "хирургической дрелью",
		PREPOSITIONAL = "хирургической дрели",
	)
	icon_state = "drill"
	item_state = "drills"
	hitsound = 'sound/weapons/drill.ogg'
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	flags = CONDUCT
	force = 15.0
	sharp = 1
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("drilled")
	tool_behaviour = TOOL_DRILL

/obj/item/surgicaldrill/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/surgicaldrill/suicide_act(mob/living/user)
	user.visible_message(
		span_suicide("[user] наматыва[pluralize_ru(user.gender, "ет", "ют")] себя на [declent_ru(ACCUSATIVE)]!\n\
		Похоже, что [genderize_ru(user.gender, "он", "она", "оно", "они")] соверша[pluralize_ru(user.gender, "ет", "ют")] суицид!")
		)

	addtimer(CALLBACK(src, PROC_REF(second_act), user), 2.5 SECONDS)
	user.SpinAnimation(3, 10)

	ADD_TRAIT(user, TRAIT_IMMOBILIZED, UNIQUE_TRAIT_SOURCE(src))
	playsound(user, 'sound/machines/juicer.ogg', 20, TRUE)
	
	return OBLITERATION

/obj/item/surgicaldrill/proc/second_act(mob/user)
	if(!user)
		return

	for(var/obj/item/item in user.get_equipped_items())
		user.drop_item_ground(item)

	user.gib()

/obj/item/surgicaldrill/laser
	name = "Advanced Laser Surgical Drill"
	desc = "Хирургическая дрель с узконаправленным лазерным элементом. Последнее слово техники в сфере хирургических операций!"
	ru_names = list(
		NOMINATIVE = "лазерная дрель",
		GENITIVE = "лазерной дрели",
		DATIVE = "лазерной дрели",
		ACCUSATIVE = "лазерную дрель",
		INSTRUMENTAL = "лазерной дрелью",
		PREPOSITIONAL = "лазерной дрели",
	)
	icon_state = "drill_laser"
	item_state = "drill_laser"
	toolspeed = 0.4

/obj/item/surgicaldrill/augment
	desc = "Небольшая электрическая дрель, находящаяся внутри вашей руки. Края затуплены, чтобы не повредить ткани. Не может пронзить небеса."
	hitsound = 'sound/weapons/circsawhit.ogg'
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5

/obj/item/scalpel
	name = "scalpel"
	desc = "Резать, резать и еще раз резать."
	ru_names = list(
		NOMINATIVE = "скальпель",
		GENITIVE = "скальпеля",
		DATIVE = "скальпелю",
		ACCUSATIVE = "скальпель",
		INSTRUMENTAL = "скальпелем",
		PREPOSITIONAL = "скальпеле",
	)
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	item_state = "scalpel"
	flags = CONDUCT
	force = 10.0
	sharp = 1
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	embed_chance = 10
	embedded_ignore_throwspeed_threshold = TRUE
	materials = list(MAT_METAL=4000, MAT_GLASS=1000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	tool_behaviour = TOOL_SCALPEL

/obj/item/scalpel/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)
	AddComponent(/datum/component/surgery_initiator)


/obj/item/scalpel/suicide_act(mob/user)
	to_chat(viewers(user), pick(span_suicide("[user] [declent_ru(INSTRUMENTAL)] среза[pluralize_ru(user.gender, "ет", "ют")] свою кожу! Похоже, что [genderize_ru(user.gender, "он", "она", "оно", "они")] соверша[pluralize_ru(user.gender, "ет", "ют")] суицид!"),
						span_suicide("[user] реж[pluralize_ru(user.gender, "ет", "ут")] своё горло с помощью [declent_ru(GENITIVE)]! Похоже, что [genderize_ru(user.gender, "он", "она", "оно", "они")] соверша[pluralize_ru(user.gender, "ет", "ют")] суицид!"),
						span_suicide("[user] вонза[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(NOMINATIVE)] в свой желудок! Похоже, что [genderize_ru(user.gender, "он", "она", "оно", "они")] пыта[pluralize_ru(user.gender, "ет", "ют")]ся совершить сэппуку!")))
	return BRUTELOSS


/obj/item/scalpel/augment
	desc = "Миниатюрное сверхострое лезвие, которое крепится напрямую к вашей кости, обеспечивая дополнительную точность."
	toolspeed = 0.5

/*
 * Researchable Scalpels
 */
/obj/item/scalpel/laser //parent type
	name = "laser scalpel"
	desc = "Скальпель, оборудованный направленным лазером."
	ru_names = list(
		NOMINATIVE = "лазерный скальпель",
		GENITIVE = "лазерного скальпеля",
		DATIVE = "лазерному скальпелю",
		ACCUSATIVE = "лазерный скальпель",
		INSTRUMENTAL = "лазерным скальпелем",
		PREPOSITIONAL = "лазерном скальпеле",
	)
	icon_state = "scalpel_laser1_on"
	damtype = "fire"
	hitsound = 'sound/weapons/sear.ogg'

/obj/item/scalpel/laser/laser1 //lasers also count as catuarys
	name = "Basic Laser Scalpel"
	desc = "Скальпель, дополненный направленным лазером. Может быть усовершенствован."
	icon_state = "scalpel_laser1_on"
	toolspeed = 0.8

/obj/item/scalpel/laser/laser2
	name = "Improved Laser Scalpel"
	desc = "Скальпель, дополненный направленным лазером. Усовершенствованная версия лазерного скальпеля."
	icon_state = "scalpel_laser2_on"
	toolspeed = 0.6

/obj/item/scalpel/laser/laser3
	name = "Advanced Laser Scalpel"
	desc = "Скальпель, дополненный направленным лазером. Высокоточная, модернизированная версия лазерного скальпеля."
	icon_state = "scalpel_laser3_on"
	toolspeed = 0.4

/obj/item/scalpel/laser/manager //super tool! Retractor/hemostat
	name = "incision management system"
	desc = "Этот небольшой хирургический аппарат по праву можно называть продолжением руки хирурга. Всего за несколько мгновений подготавливает и обрабатывает разрез, позволяя почти сразу перейти к основной стадии операции."
	icon_state = "scalpel_manager_on"
	ru_names = list(
		NOMINATIVE = "система обработки надрезов",
		GENITIVE = "системы обработки надрезов",
		DATIVE = "системе обработки надрезов",
		ACCUSATIVE = "систему обработки надрезов",
		INSTRUMENTAL = "системой обработки надрезов",
		PREPOSITIONAL = "системе обработки надрезов",
	)
	icon
	toolspeed = 0.2

/obj/item/scalpel/laser/manager/Initialize(mapload)
	. = ..()
	// this one can automatically retry its steps, too!
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/scalpel/laser/manager/debug
	name = "debug IMS"
	desc = "Чудо современной медицины. Этот инструмент действует как любой другой хирургический инструмент и заканчивается в кратчайшие сроки. А как ты вообще это заполучил?"
	toolspeed = 0.01

/obj/item/scalpel/laser/manager/debug/attack_self(mob/user)
	. = ..()
	toolspeed = toolspeed == 0.5 ? 0.01 : 0.5
	to_chat(user, "Установленная скорость инструмента у [declent_ru(GENITIVE)] - [toolspeed].")
	balloon_alert(user, "скорость изменена")
	playsound(src, 'sound/effects/pop.ogg', 50, 0)		//Change the mode

/obj/item/circular_saw
	name = "circular saw"
	desc = "Инструмент, чтобы резать кости."
	ru_names = list(
		NOMINATIVE = "хирургическая пила",
		GENITIVE = "хирургической пилы",
		DATIVE = "хирургической пиле",
		ACCUSATIVE = "хирургическую пилу",
		INSTRUMENTAL = "хирургической пилой",
		PREPOSITIONAL = "хирургической пиле",
	)
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	hitsound = 'sound/weapons/circsawhit.ogg'
	mob_throw_hit_sound =  'sound/weapons/pierce.ogg'
	flags = CONDUCT
	force = 15.0
	sharp = 1
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	embed_chance = 20
	embedded_ignore_throwspeed_threshold = TRUE
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	origin_tech = "biotech=1;combat=1"
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	tool_behaviour = TOOL_SAW

/obj/item/circular_saw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/circular_saw/laser
	name = "Advanced Laser Circular Saw"
	desc = "Пила с круглым лазерным диском. Последнее слово техники в сфере хирургических операций!"
	ru_names = list(
		NOMINATIVE = "лазерная хирургическая пила",
		GENITIVE = "лазерной хирургической пилы",
		DATIVE = "лазерной хирургической пиле",
		ACCUSATIVE = "лазерную хирургическую пилу",
		INSTRUMENTAL = "лазерной хирургической пилой",
		PREPOSITIONAL = "лазерной хирургической пиле",
	)
	icon_state = "saw_laser"
	item_state = "saw_laser"
	origin_tech = "biotech=1;material=1"
	toolspeed = 0.6

/obj/item/circular_saw/augment
	desc = "Маленькая, но очень быстро вращающаяся пила. Края притуплены, чтобы предотвратить случайный порез внутри носителя."
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5

//misc, formerly from code/defines/weapons.dm
/obj/item/bonegel
	name = "bone gel"
	desc = "Небольшой баллончик, содержищий в себе гель, сращивающий и заживляющий кости."
	ru_names = list(
		NOMINATIVE = "костяной гель",
		GENITIVE = "костяного геля",
		DATIVE = "костяному гелю",
		ACCUSATIVE = "костяной гель",
		INSTRUMENTAL = "костяным гелем",
		PREPOSITIONAL = "костяном геле",
	)
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	item_state = "bone-gel"
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 1.0
	origin_tech = "materials=1;biotech=1"
	tool_behaviour = TOOL_BONEGEL

/obj/item/bonegel/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/bonegel/augment
	toolspeed = 0.5

/obj/item/FixOVein
	name = "FixOVein"
	desc = "Небольшой баллончик, содержищий в себе гель, сращивающий и заживляющий кровеносные сосуды."
	ru_names = list(
		NOMINATIVE = "гель для сосудов",
		GENITIVE = "гели для сосудов",
		DATIVE = "гелю для сосудов",
		ACCUSATIVE = "гель для сосудов",
		INSTRUMENTAL = "гелью для сосудов",
		PREPOSITIONAL = "геле для сосудов",
	)
	ic
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein"
	item_state = "fixovein"
	force = 0
	throwforce = 1.0
	origin_tech = "materials=1;biotech=1"
	w_class = WEIGHT_CLASS_SMALL
	tool_behaviour = TOOL_FIXOVEIN

/obj/item/FixOVein/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/FixOVein/augment
	toolspeed = 0.5

/obj/item/bonesetter
	name = "bone setter"
	desc = "Хирургический инструмент, предназначенный для вправления и закрепления костей."
	ru_names = list(
		NOMINATIVE = "костоправ",
		GENITIVE = "костоправа",
		DATIVE = "костоправу",
		ACCUSATIVE = "костоправ",
		INSTRUMENTAL = "костоправом",
		PREPOSITIONAL = "костоправе",
	)
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	item_state = "bone setter"
	force = 8.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "hit", "bludgeoned")
	origin_tech = "materials=1;biotech=1"
	tool_behaviour = TOOL_BONESET

/obj/item/bonesetter/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/bonesetter/laser
	name = "Advanced Laser Bone Setter"
	desc = "Инструмент для правки костей, оборудованный лазерными элементами. Последнее слово техники в сфере хирургических операций!"
	ru_names = list(
		NOMINATIVE = "лазерный костоправ",
		GENITIVE = "лазерного костоправа",
		DATIVE = "лазерному костоправу",
		ACCUSATIVE = "лазерный костоправ",
		INSTRUMENTAL = "лазерным костоправом",
		PREPOSITIONAL = "лазерном костоправе",
	)
	icon_state = "bonesetter_laser"
	item_state = "bonesetter_laser"
	toolspeed = 0.4

/obj/item/bonesetter/augment
	toolspeed = 0.5

/obj/item/surgical_drapes
	name = "surgical drapes"
	desc = "Хирургическая простыня, обеспечивающая оптимальную безопасность и инфекционный контроль."
	ru_names = list(
		NOMINATIVE = "хирургическая простыня",
		GENITIVE = "хирургической простыни",
		DATIVE = "хирургической простыне",
		ACCUSATIVE = "хирургическую простыню",
		INSTRUMENTAL = "хирургической простынёй",
		PREPOSITIONAL = "хирургической простыне",
	)
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "biotech=1"
	attack_verb = list("slapped")
