/obj/item/retractor
	name = "retractor"
	desc = "Инструмент для расширения полостей при операциях."
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
	desc = "Ретрактор с лазерным наконечником. В два раза практичнее родителя!"
	icon_state = "retractor_laser"
	item_state = "retractor_laser"
	toolspeed = 0.4

/obj/item/retractor/augment
	desc = "Микромеханический манипулятор для расширения полостей при операциях."
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5

/obj/item/hemostat
	name = "hemostat"
	desc = "Инструмент для остановки кровотечения."
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
	desc = "Гемостат с лазерным зажимом. В два раза практичнее родителя!"
	icon_state = "hemostat_laser"
	item_state = "hemostat_laser"
	toolspeed = 0.4

/obj/item/hemostat/augment
	desc = "Крошечные сервомоторы приводят в действие пару клещей, чтобы остановить кровотечение."
	toolspeed = 0.5

/obj/item/cautery
	name = "cautery"
	desc = "Останавливает кровотечение."
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
	desc = "Нагретый наконечник, прижигающий раны."
	toolspeed = 0.5

/obj/item/surgicaldrill
	name = "surgical drill"
	desc = "Инструмент, предназначенный для сверления отверстий. Постарайтесь не попасть в глаз"
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
	user.visible_message(span_suicide("[user] наматыва[pluralize_ru(user.gender, "ет", "ют")] себя на [declent_ru(ACCUSATIVE)]! Похоже, что [genderize_ru(user.gender, "он", "она", "оно", "они")] соверша[pluralize_ru(user.gender, "ет", "ют")] суицид!"))
	addtimer(CALLBACK(src, PROC_REF(second_act), user), 2.5 SECONDS)
	user.SpinAnimation(3, 10)
	user.Immobilize(5 SECONDS)
	playsound(user, 'sound/machines/juicer.ogg', 20, TRUE)
	return OBLITERATION

/obj/item/surgicaldrill/proc/second_act(mob/user)
	if(!user)
		return

	for(var/obj/item/W in user)
		user.drop_item_ground(W)

	user.gib()

/obj/item/surgicaldrill/laser
	name = "Advanced Laser Surgical Drill"
	desc = "Хирургическая дрель с направленной лазерной насадко. В два раза практичнее родителя!"
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
						span_suicide("[user] реж[pluralize_ru(user.gender, "ет", "ют")] своё горло с помощью [declent_ru(GENITIVE)]! Похоже, что [genderize_ru(user.gender, "он", "она", "оно", "они")] соверша[pluralize_ru(user.gender, "ет", "ют")] суицид!"),
						span_suicide("[user] вонза[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(NOMINATIVE)] в свой желудок! Похоже, что [genderize_ru(user.gender, "он", "она", "оно", "они")] пыта[pluralize_ru(user.gender, "ет", "ют")]ся совершить сэппуку.")))
	return BRUTELOSS


/obj/item/scalpel/augment
	desc = "Ультраострое лезвие крепится непосредственно к кости, обеспечивая дополнительную точность."
	toolspeed = 0.5

/*
 * Researchable Scalpels
 */
/obj/item/scalpel/laser //parent type
	name = "laser scalpel"
	desc = "Скальпель, дополненный направленным лазером."
	icon_state = "scalpel_laser1_on"
	damtype = "fire"
	hitsound = 'sound/weapons/sear.ogg'
	ru_names = list(
		NOMINATIVE = "лазерный скальпель",
		GENITIVE = "лазерного скальпеля",
		DATIVE = "лазерному скальпелю",
		ACCUSATIVE = "лазерный скальпель",
		INSTRUMENTAL = "лазерным скальпелем",
		PREPOSITIONAL = "лазерном скальпеле",
	)

/obj/item/scalpel/laser/laser1 //lasers also count as catuarys
	name = "Basic Laser Scalpel"
	desc = "Скальпель, дополненный направленным лазером.  Может быть усовершенствован."
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
	desc = "Настоящее продолжение дела хирурга, это чудо мгновенно и полностью подготавливает разрез, позволяя немедленно приступить к работе."
	icon_state = "scalpel_manager_on"
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
	to_chat(user, "У [declent_ru(GENITIVE)] установлена ​​скорость инструмента[toolspeed]")
	playsound(src, 'sound/effects/pop.ogg', 50, 0)		//Change the mode

/obj/item/circular_saw
	name = "circular saw"
	desc = "Инструмент, чтобы резать кости."
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
	desc = "Пила с круглым лазерным диском. В два раза практичнее родителя!"
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
	name = "Гель для костей."
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
	name = "Инструмент, для прижигания внутренних кровотечений."
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
	name = "Инструмент для правления костей"
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
	desc = "Инструмент для правки костей, но с лазерными зубами. В два раза практичнее родителя!"
	icon_state = "bonesetter_laser"
	item_state = "bonesetter_laser"
	toolspeed = 0.4

/obj/item/bonesetter/augment
	toolspeed = 0.5

/obj/item/surgical_drapes
	name = "surgical drapes"
	desc = "Хирургическая простыня марки Nanotrasen. Обеспечивает оптимальную безопасность и инфекционный контроль."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "biotech=1"
	attack_verb = list("slapped")
