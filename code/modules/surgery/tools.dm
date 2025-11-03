/obj/item/retractor
	name = "retractor"
	desc = "Инструмент, используемый для расширения полостей при операциях."
	gender = MALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	item_state = "retractor"
	materials = list(MAT_METAL=6000, MAT_GLASS=3000)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=1;biotech=1"
	tool_behaviour = TOOL_RETRACTOR

/obj/item/retractor/get_ru_names()
	return list(
		NOMINATIVE = "ретрактор",
		GENITIVE = "ретрактора",
		DATIVE = "ретрактору",
		ACCUSATIVE = "ретрактор",
		INSTRUMENTAL = "ретрактором",
		PREPOSITIONAL = "ретракторе",
	)

/obj/item/retractor/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/retractor/laser
	name = "Advanced Laser Retractors"
	desc = "Ретрактор с лазерным наконечником. Последнее слово техники в сфере хирургических операций!"
	icon_state = "retractor_laser"
	item_state = "retractor_laser"
	toolspeed = 0.4

/obj/item/retractor/laser/get_ru_names()
	return list(
		NOMINATIVE = "лазерный ретрактор",
		GENITIVE = "лазерного ретрактора",
		DATIVE = "лазерному ретрактору",
		ACCUSATIVE = "лазерный ретрактор",
		INSTRUMENTAL = "лазерным ретрактором",
		PREPOSITIONAL = "лазерном ретракторе",
	)

/obj/item/retractor/augment
	desc = "Микромеханический манипулятор, используемый в хирургии для расширения полостей и закрепления надрезов."
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5

/obj/item/retractor/augment/get_ru_names()
	return list(
		NOMINATIVE = "микромеханический манипулятор",
		GENITIVE = "микромеханического манипулятора",
		DATIVE = "микромеханическому манипулятору",
		ACCUSATIVE = "микромеханический манипулятор",
		INSTRUMENTAL = "микромеханическим манипулятором",
		PREPOSITIONAL = "микромеханическом манипуляторе",
	)

/obj/item/retractor/primitive_retractor
	name = "primitive bone retractor"
	desc = "Примитивный инструмент, сделанный из кости. Используется для расширения полостей при операциях."
	icon_state = "primitive_retractor"
	item_state = "primitive_retractor"

/obj/item/retractor/primitive_retractor/get_ru_names()
	return list(
		NOMINATIVE = "примитивный ретрактор",
		GENITIVE = "примитивного ретрактора",
		DATIVE = "примитивному ретрактору",
		ACCUSATIVE = "примитивный ретрактор",
		INSTRUMENTAL = "примитивным ретрактором",
		PREPOSITIONAL = "примитивном ретракторе",
	)

/obj/item/hemostat
	name = "hemostat"
	desc = "Инструмент для зажима кровоточащих сосудов во время операций."
	gender = MALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	item_state = "hemostat"
	materials = list(MAT_METAL=5000, MAT_GLASS=2500)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("атаковал", "ущипнул")
	tool_behaviour = TOOL_HEMOSTAT

/obj/item/hemostat/get_ru_names()
	return list(
		NOMINATIVE = "гемостат",
		GENITIVE = "гемостата",
		DATIVE = "гемостату",
		ACCUSATIVE = "гемостат",
		INSTRUMENTAL = "гемостатом",
		PREPOSITIONAL = "гемостате",
	)

/obj/item/hemostat/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/hemostat/laser
	name = "Advanced Laser Hemostat"
	desc = "Гемостат с лазерным зажимом. Последнее слово техники в сфере хирургических операций!"
	icon_state = "hemostat_laser"
	item_state = "hemostat_laser"
	toolspeed = 0.4

/obj/item/hemostat/laser/get_ru_names()
	return list(
		NOMINATIVE = "лазерный гемостат",
		GENITIVE = "лазерного гемостата",
		DATIVE = "лазерному гемостату",
		ACCUSATIVE = "лазерный гемостат",
		INSTRUMENTAL = "лазерным гемостатом",
		PREPOSITIONAL = "лазерном гемостате",
	)

/obj/item/hemostat/augment
	desc = "Хирургический инструмент, состоящий из нескольких зажимов и сервомоторов. Используется для перекрытия сосудов и остановки возникающего кровотечения во время операции."
	toolspeed = 0.5

/obj/item/hemostat/primitive_hemostat
	name = "primitive hemostat"
	desc = "Примитивный инструмент, сделанный из кости. Используется для зажима кровоточащих сосудов во время операций."
	icon_state = "primitive_hemostat"
	item_state = "primitive_hemostat"

/obj/item/hemostat/primitive_hemostat/get_ru_names()
	return list(
		NOMINATIVE = "примитивный гемостат",
		GENITIVE = "примитивного гемостата",
		DATIVE = "примитивному гемостату",
		ACCUSATIVE = "примитивный гемостат",
		INSTRUMENTAL = "примитивным гемостатом",
		PREPOSITIONAL = "примитивном гемостате",
	)

/obj/item/cautery
	name = "cautery"
	desc = "Хирургический инструмент, используемый для прижигания открытых ран и надрезов."
	gender = MALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	item_state = "cautery"
	materials = list(MAT_METAL=2500, MAT_GLASS=750)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("подпалил")
	tool_behaviour = TOOL_CAUTERY

/obj/item/cautery/get_ru_names()
	return list(
		NOMINATIVE = "прижигатель",
		GENITIVE = "прижигателя",
		DATIVE = "прижигателю",
		ACCUSATIVE = "прижигатель",
		INSTRUMENTAL = "прижигателем",
		PREPOSITIONAL = "прижигателе",
	)

/obj/item/cautery/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/cautery/augment
	desc = "Нагревательный элемент, используемый для прижигания ран."
	toolspeed = 0.5

/obj/item/cautery/primitive_cautery
	name = "primitive cautery"
	desc = "Примитивный инструмент, сделанный из кости. Используется для прижигания ран."
	icon_state = "primitive_cautery"
	item_state = "primitive_cautery"

/obj/item/cautery/primitive_cautery/get_ru_names()
	return list(
		NOMINATIVE = "примитивный прижигатель",
		GENITIVE = "примитивного прижигателя",
		DATIVE = "примитивному прижигателю",
		ACCUSATIVE = "примитивный прижигатель",
		INSTRUMENTAL = "примитивным прижигателем",
		PREPOSITIONAL = "примитивном прижигателе",
	)

/obj/item/surgicaldrill
	name = "surgical drill"
	desc = "Инструмент, предназначенный для сверления отверстий. Постарайтесь не попасть себе в глаз!"
	icon = 'icons/obj/surgery.dmi'
	gender = FEMALE
	icon_state = "drill"
	item_state = "drills"
	hitsound = 'sound/weapons/drill.ogg'
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	flags = CONDUCT
	force = 15
	sharp = 1
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("продырявил")
	tool_behaviour = TOOL_DRILL

/obj/item/surgicaldrill/get_ru_names()
	return list(
		NOMINATIVE = "хирургическая дрель",
		GENITIVE = "хирургической дрели",
		DATIVE = "хирургической дрели",
		ACCUSATIVE = "хирургическую дрель",
		INSTRUMENTAL = "хирургической дрелью",
		PREPOSITIONAL = "хирургической дрели",
	)

/obj/item/surgicaldrill/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/surgicaldrill/suicide_act(mob/living/user)
	user.visible_message(
		span_suicide("[user] наматыва[PLUR_ET_YUT(user)] себя на [declent_ru(ACCUSATIVE)]!\n\
		Похоже, что [GEND_HE_SHE(user)] соверша[PLUR_ET_YUT(user)] суицид!")
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
	icon_state = "drill_laser"
	item_state = "drill_laser"
	toolspeed = 0.4

/obj/item/surgicaldrill/laser/get_ru_names()
	return list(
		NOMINATIVE = "лазерная дрель",
		GENITIVE = "лазерной дрели",
		DATIVE = "лазерной дрели",
		ACCUSATIVE = "лазерную дрель",
		INSTRUMENTAL = "лазерной дрелью",
		PREPOSITIONAL = "лазерной дрели",
	)

/obj/item/surgicaldrill/augment
	desc = "Небольшая электрическая дрель, находящаяся внутри вашей руки. Края затуплены, чтобы не повредить ткани. Не может пронзить небеса."
	hitsound = 'sound/weapons/circsawhit.ogg'
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5

/obj/item/scalpel
	name = "scalpel"
	desc = "Резать, резать и ещё раз резать."
	gender = MALE
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
	attack_verb = list("атаковал", "полоснул", "уколол", "поранил", "порезал")
	hitsound = 'sound/weapons/bladeslice.ogg'
	tool_behaviour = TOOL_SCALPEL

/obj/item/scalpel/get_ru_names()
	return list(
		NOMINATIVE = "скальпель",
		GENITIVE = "скальпеля",
		DATIVE = "скальпелю",
		ACCUSATIVE = "скальпель",
		INSTRUMENTAL = "скальпелем",
		PREPOSITIONAL = "скальпеле",
	)

/obj/item/scalpel/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)
	AddComponent(/datum/component/surgery_initiator)


/obj/item/scalpel/suicide_act(mob/user)
	to_chat(viewers(user), pick(span_suicide("[user] [declent_ru(INSTRUMENTAL)] среза[PLUR_ET_YUT(user)] свою кожу! Похоже, что [GEND_HE_SHE(user)] соверша[PLUR_ET_YUT(user)] суицид!"),
						span_suicide("[user] реж[PLUR_ET_UT(user)] своё горло с помощью [declent_ru(GENITIVE)]! Похоже, что [GEND_HE_SHE(user)] соверша[PLUR_ET_YUT(user)] суицид!"),
						span_suicide("[user] вонза[PLUR_ET_YUT(user)] [declent_ru(NOMINATIVE)] в свой желудок! Похоже, что [GEND_HE_SHE(user)] пыта[PLUR_ET_YUT(user)]ся совершить сэппуку!")))
	return BRUTELOSS


/obj/item/scalpel/augment
	desc = "Миниатюрное сверхострое лезвие, которое крепится напрямую к вашей кости, обеспечивая дополнительную точность."
	toolspeed = 0.5

/obj/item/scalpel/primitive_scalpel
	name = "primitive scalpel"
	desc = "Примитивный скальпель, сделанный из кости. Несмотря на материал, из которого сделан, всё ещё крайне эффективен."
	icon_state = "primitive_scalpel"
	item_state = "primitive_scalpel"

/obj/item/scalpel/primitive_scalpel/get_ru_names()
	return list(
		NOMINATIVE = "примитивный скальпель",
		GENITIVE = "примитивного скальпеля",
		DATIVE = "примитивному скальпелю",
		ACCUSATIVE = "примитивный скальпель",
		INSTRUMENTAL = "примитивным скальпелем",
		PREPOSITIONAL = "примитивном скальпеле",
	)

/*
 * Researchable Scalpels
 */
/obj/item/scalpel/laser //parent type
	name = "laser scalpel"
	desc = "Скальпель, оборудованный направленным лазером."
	icon_state = "scalpel_laser1_on"
	damtype = "fire"
	hitsound = 'sound/weapons/sear.ogg'

/obj/item/scalpel/laser/get_ru_names()
	return list(
		NOMINATIVE = "лазерный скальпель",
		GENITIVE = "лазерного скальпеля",
		DATIVE = "лазерному скальпелю",
		ACCUSATIVE = "лазерный скальпель",
		INSTRUMENTAL = "лазерным скальпелем",
		PREPOSITIONAL = "лазерном скальпеле",
	)

/obj/item/scalpel/laser/laser1 //lasers also count as catuarys
	name = "Basic Laser Scalpel"
	desc = "Скальпель, дополненный направленным лазером. Может быть усовершенствован."
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
	icon
	toolspeed = 0.2

/obj/item/scalpel/laser/manager/get_ru_names()
	return list(
		NOMINATIVE = "система обработки надрезов",
		GENITIVE = "системы обработки надрезов",
		DATIVE = "системе обработки надрезов",
		ACCUSATIVE = "систему обработки надрезов",
		INSTRUMENTAL = "системой обработки надрезов",
		PREPOSITIONAL = "системе обработки надрезов",
	)

/obj/item/scalpel/laser/manager/Initialize(mapload)
	. = ..()
	// this one can automatically retry its steps, too!
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/circular_saw
	name = "circular saw"
	desc = "Инструмент, чтобы резать кости."
	gender = FEMALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	hitsound = 'sound/weapons/circsawhit.ogg'
	mob_throw_hit_sound =  'sound/weapons/pierce.ogg'
	flags = CONDUCT
	force = 15
	sharp = 1
	throwforce = 9
	throw_speed = 3
	throw_range = 5
	embed_chance = 20
	embedded_ignore_throwspeed_threshold = TRUE
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	origin_tech = "biotech=1;combat=1"
	attack_verb = list("атаковал", "полоснул", "пропилил", "порезал")
	tool_behaviour = TOOL_SAW

/obj/item/circular_saw/get_ru_names()
	return list(
		NOMINATIVE = "хирургическая пила",
		GENITIVE = "хирургической пилы",
		DATIVE = "хирургической пиле",
		ACCUSATIVE = "хирургическую пилу",
		INSTRUMENTAL = "хирургической пилой",
		PREPOSITIONAL = "хирургической пиле",
	)

/obj/item/circular_saw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/circular_saw/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		no_multi_hit = TRUE, \
	)

/obj/item/circular_saw/laser
	name = "Advanced Laser Circular Saw"
	desc = "Пила с круглым лазерным диском. Последнее слово техники в сфере хирургических операций!"
	icon_state = "saw_laser"
	item_state = "saw_laser"
	origin_tech = "biotech=1;material=1"
	toolspeed = 0.6

/obj/item/circular_saw/laser/get_ru_names()
	return list(
		NOMINATIVE = "лазерная хирургическая пила",
		GENITIVE = "лазерной хирургической пилы",
		DATIVE = "лазерной хирургической пиле",
		ACCUSATIVE = "лазерную хирургическую пилу",
		INSTRUMENTAL = "лазерной хирургической пилой",
		PREPOSITIONAL = "лазерной хирургической пиле",
	)

/obj/item/circular_saw/augment
	desc = "Маленькая, но очень быстро вращающаяся пила. Края притуплены, чтобы предотвратить случайный порез внутри носителя."
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5

/obj/item/primitive_saw
	name = "primitive circular saw"
	desc = "Примитивная хирургическая пила, сделанная из крепкой кости."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "primitive_saw"
	item_state = "primitive_saw"
	hitsound = 'sound/weapons/slice.ogg'
	mob_throw_hit_sound =  'sound/weapons/pierce.ogg'
	flags = CONDUCT
	force = 15.0
	sharp = 1
	throwforce = 9
	throw_speed = 3
	throw_range = 5
	embed_chance = 20
	embedded_ignore_throwspeed_threshold = TRUE
	attack_verb = list("атаковал", "полоснул", "пропилил", "порезал")

/obj/item/primitive_saw/get_ru_names()
	return list(
		NOMINATIVE = "примитивная хирургическая пила",
		GENITIVE = "примитивной хирургической пилы",
		DATIVE = "примитивной хирургической пиле",
		ACCUSATIVE = "примитивную хирургическую пилу",
		INSTRUMENTAL = "примитивной хирургической пилой",
		PREPOSITIONAL = "примитивной хирургической пиле",
	)

/obj/item/primitive_saw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

//misc, formerly from code/defines/weapons.dm
/obj/item/bonegel
	name = "bone gel"
	desc = "Небольшой баллончик, содержищий в себе гель, сращивающий и заживляющий кости."
	gender = MALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	item_state = "bone-gel"
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 1.0
	origin_tech = "materials=1;biotech=1"
	tool_behaviour = TOOL_BONEGEL

/obj/item/bonegel/get_ru_names()
	return list(
		NOMINATIVE = "костяной гель",
		GENITIVE = "костяного геля",
		DATIVE = "костяному гелю",
		ACCUSATIVE = "костяной гель",
		INSTRUMENTAL = "костяным гелем",
		PREPOSITIONAL = "костяном геле",
	)

/obj/item/bonegel/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/bonegel/augment
	toolspeed = 0.5

/obj/item/bonegel/primitive_bonegel
	name = "primitive bone gel"
	desc = "Примитивная смесь, используется для заживления костей."
	icon_state = "primitive_bonegel"
	item_state = "primitive_bonegel"

/obj/item/bonegel/primitive_bonegel/get_ru_names()
	return list(
		NOMINATIVE = "примитивный костяной гель",
		GENITIVE = "примитивного костяного геля",
		DATIVE = "примитивному костяному гелю",
		ACCUSATIVE = "примитивный костяной гель",
		INSTRUMENTAL = "примитивным костяным гелем",
		PREPOSITIONAL = "примитивном костяном геле",
	)

/obj/item/FixOVein
	name = "FixOVein"
	desc = "Небольшой баллончик, содержищий в себе гель, сращивающий и заживляющий кровеносные сосуды."
	gender = MALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein"
	item_state = "fixovein"
	throwforce = 1.0
	origin_tech = "materials=1;biotech=1"
	w_class = WEIGHT_CLASS_SMALL
	tool_behaviour = TOOL_FIXOVEIN

/obj/item/FixOVein/get_ru_names()
	return list(
		NOMINATIVE = "гель для сосудов",
		GENITIVE = "гели для сосудов",
		DATIVE = "гелю для сосудов",
		ACCUSATIVE = "гель для сосудов",
		INSTRUMENTAL = "гелью для сосудов",
		PREPOSITIONAL = "геле для сосудов",
	)

/obj/item/FixOVein/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/FixOVein/augment
	toolspeed = 0.5

/obj/item/FixOVein/primitive_FixOVein
	name = "primitive FixOVein"
	desc = "Примитивное средство для сращивания сосудов."
	gender = FEMALE
	icon_state = "primitive_fixovein"
	item_state = "primitive_fixovein"

/obj/item/FixOVein/primitive_FixOVein/get_ru_names()
	return list(
		NOMINATIVE = "нить для сращивания сосудов",
		GENITIVE = "нити для сращивания сосудов",
		DATIVE = "нити для сращивания сосудов",
		ACCUSATIVE = "нить для сращивания сосудов",
		INSTRUMENTAL = "нитью для сращивания сосудов",
		PREPOSITIONAL = "нити для сращивания сосудов",
	)

/obj/item/bonesetter
	name = "bone setter"
	desc = "Хирургический инструмент, предназначенный для вправления и закрепления костей."
	gender = MALE
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	item_state = "bone setter"
	force = 8.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("атаковал", "ударил")
	origin_tech = "materials=1;biotech=1"
	tool_behaviour = TOOL_BONESET

/obj/item/bonesetter/get_ru_names()
	return list(
		NOMINATIVE = "костоправ",
		GENITIVE = "костоправа",
		DATIVE = "костоправу",
		ACCUSATIVE = "костоправ",
		INSTRUMENTAL = "костоправом",
		PREPOSITIONAL = "костоправе",
	)

/obj/item/bonesetter/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/bonesetter/laser
	name = "Advanced Laser Bone Setter"
	desc = "Инструмент для правки костей, оборудованный лазерными элементами. Последнее слово техники в сфере хирургических операций!"
	icon_state = "bonesetter_laser"
	item_state = "bonesetter_laser"
	toolspeed = 0.4

/obj/item/bonesetter/laser/get_ru_names()
	return list(
		NOMINATIVE = "лазерный костоправ",
		GENITIVE = "лазерного костоправа",
		DATIVE = "лазерному костоправу",
		ACCUSATIVE = "лазерный костоправ",
		INSTRUMENTAL = "лазерным костоправом",
		PREPOSITIONAL = "лазерном костоправе",
	)

/obj/item/bonesetter/augment
	toolspeed = 0.5

/obj/item/bonesetter/primitive_bonesetter
	name = "primitive bone setter"
	desc = "Примитивный инструмент, сделанный из кости. Используется для правки костей."
	icon_state = "primitive_bonesetter"
	item_state = "primitive_bonesetter"

/obj/item/bonesetter/primitive_bonesetter/get_ru_names()
	return list(
		NOMINATIVE = "примитивный костоправ",
		GENITIVE = "примитивного костоправа",
		DATIVE = "примитивному костоправу",
		ACCUSATIVE = "примитивный костоправ",
		INSTRUMENTAL = "примитивным костоправом",
		PREPOSITIONAL = "примитивном костоправе",
	)

/obj/item/surgical_drapes
	name = "surgical drapes"
	desc = "Хирургическая простыня, обеспечивающая оптимальную безопасность и инфекционный контроль."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "biotech=1"
	attack_verb = list("шлёпнул")

/obj/item/surgical_drapes/get_ru_names()
	return list(
		NOMINATIVE = "хирургическая простыня",
		GENITIVE = "хирургической простыни",
		DATIVE = "хирургической простыне",
		ACCUSATIVE = "хирургическую простыню",
		INSTRUMENTAL = "хирургической простынёй",
		PREPOSITIONAL = "хирургической простыне",
	)
