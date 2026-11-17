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
	return alist(
		NOMINATIVE = "криптографический считыватель",
		GENITIVE = "криптографического считывателя",
		DATIVE = "криптографическому считывателю",
		ACCUSATIVE = "криптографический считыватель",
		INSTRUMENTAL = "криптографическим считывателем",
		PREPOSITIONAL = "криптографическом считывателе",
	)

/obj/item/card/emag/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

/obj/item/card/emag/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(interacting_with.emag_act(user, src))
		SSblackbox.record_feedback("tally", "atom_emagged")
		add_attack_logs(user, interacting_with, "emagged")
		return ITEM_INTERACT_SUCCESS
	return NONE // In a perfect world this would be blocking, but this is not a perfect world

/obj/item/card/emag/halloween
	name = "hack-o'-lantern"
	desc = "Это тыква с торчащим из неё криптографическим секвенсором."
	icon_state = "hack_o_lantern"

/obj/item/card/emag/halloween/get_ru_names()
	return alist(
		NOMINATIVE = "светильник Хака",
		GENITIVE = "светильника Хака",
		DATIVE = "светильнику Хака",
		ACCUSATIVE = "светильник Хака",
		INSTRUMENTAL = "светильником Хака",
		PREPOSITIONAL = "светильнике Хака",
	)

/obj/item/card/emag_broken
	name = "broken cryptographic sequencer"
	desc = "ID-карта с повреждённой магнитной лентой и сгоревшими микросхемами. \
			Судя по всему, свою первоначальную функцию этот девайс уже не выполнит."
	icon_state = "emag"
	item_state = "card-id"
	gender = MALE
	origin_tech = "magnets=2;syndicate=1"

/obj/item/card/emag_broken/get_ru_names()
	return alist(
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
	return alist(
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

/obj/item/card/cmag/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return
	INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, cmag_act), user)

/obj/item/card/cmag/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(interacting_with.cmag_act(user, src))
		SSblackbox.record_feedback("tally", "atom_cmagged")
		add_attack_logs(user, interacting_with, "cmagged")
		return ITEM_INTERACT_SUCCESS
	return NONE
