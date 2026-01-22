/**
 * Emag (cryptographic sequencer) and Cmag (jestographic sequencer).
 */

/obj/item/card/emag
	name = "cryptographic sequencer"
	desc = "ID-карта \"Нанотрейзен\" с прикреплённой магнитной лентой и какими-то микросхемами. \
			Судя по всему, это устройство предназначено для взлома систем безопасности электронных устройств."
	icon_state = "emag"
	item_state = "card-id"
	gender = MALE
	origin_tech = "magnets=2;syndicate=3"
	item_flags = NOBLUDGEON|NO_MAT_REDEMPTION

/obj/item/card/emag/get_ru_names()
	return list(
		NOMINATIVE = "криптографический считыватель",
		GENITIVE = "криптографического считывателя",
		DATIVE = "криптографическому считывателю",
		ACCUSATIVE = "криптографический считыватель",
		INSTRUMENTAL = "криптографическим считывателем",
		PREPOSITIONAL = "криптографическом считывателе",
	)

/obj/item/card/emag/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

/obj/item/card/emag/afterattack(atom/target, mob/user, proximity, params)
	var/atom/A = target
	if(!proximity)
		return
	A.emag_act(user)

/obj/item/card/emag_broken
	name = "broken cryptographic sequencer"
	desc = "ID-карта с повреждённой магнитной лентой и сгоревшими микросхемами. \
			Судя по всему, свою первоначальную функцию этот девайс уже не выполнит."
	icon_state = "emag"
	item_state = "card-id"
	gender = MALE
	origin_tech = "magnets=2;syndicate=1"

/obj/item/card/emag_broken/get_ru_names()
	return list(
		NOMINATIVE = "сломанный криптографический считыватель",
		GENITIVE = "сломанного криптографического считывателя",
		DATIVE = "сломанному криптографическому считывателю",
		ACCUSATIVE = "сломанный криптографический считыватель",
		INSTRUMENTAL = "сломанным криптографическим считывателем",
		PREPOSITIONAL = "сломанном криптографическом считывателе",
	)

/obj/item/card/cmag
	desc = "ID-карта, покрытая слоем жидкого бананиума."
	name = "jestographic sequencer"
	icon_state = "cmag"
	item_state = "card-id"
	gender = MALE
	origin_tech = "magnets=2;syndicate=2"
	item_flags = NOBLUDGEON|NO_MAT_REDEMPTION

/obj/item/card/cmag/get_ru_names()
	return list(
		NOMINATIVE = "шутографический считыватель",
		GENITIVE = "шутографического считывателя",
		DATIVE = "шутографическому считывателю",
		ACCUSATIVE = "шутографический считыватель",
		INSTRUMENTAL = "шутографическим считывателем",
		PREPOSITIONAL = "шутографическом считывателе",
	)

/obj/item/card/cmag/ComponentInitialize()
	AddComponent(/datum/component/slippery, 4 SECONDS, lube_flags = (SLIDE|SLIP_WHEN_LYING))

/obj/item/card/cmag/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

/obj/item/card/cmag/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, cmag_act), user)
