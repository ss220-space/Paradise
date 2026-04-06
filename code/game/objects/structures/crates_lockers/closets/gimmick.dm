/obj/structure/closet/cabinet
	name = "cabinet"
	desc = "Old will forever be in fashion."
	desc = "Старое всегда будет в моде."
	icon_state = "cabinet"
	overlay_sparking = "c_sparking"
	overlay_locked = "c_locked"
	overlay_unlocked = "c_unlocked"
	max_integrity = 70
	resistance_flags = FLAMMABLE
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25

/obj/structure/closet/cabinet/get_ru_names()
    return list(
        NOMINATIVE = "шкаф",
        GENITIVE = "шкафа",
        DATIVE = "шкафу",
        ACCUSATIVE = "шкаф",
        INSTRUMENTAL = "шкафом",
        PREPOSITIONAL = "шкафе",
    )

/obj/structure/closet/cabinet/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -40, 5)

/obj/structure/closet/acloset
	name = "strange closet"
	desc = "It looks alien!"
	desc = "Выглядит чужеродно!"
	icon_state = "acloset"

/obj/structure/closet/acloset/get_ru_names()
    return list(
        NOMINATIVE = "странный шкафчик",
        GENITIVE = "странного шкафчика",
        DATIVE = "странному шкафчику",
        ACCUSATIVE = "странный шкафчик",
        INSTRUMENTAL = "странным шкафчиком",
        PREPOSITIONAL = "странном шкафчике",
    )

/obj/structure/closet/gimmick
	name = "administrative supply closet"
	desc = "It's a storage unit for things that have no right being here."
	desc = "Это устройство для хранения вещей, которым здесь не место."
	icon_state = "syndicate1"

/obj/structure/closet/gimmick/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для административного снабжения",
        GENITIVE = "шкафчика для административного снабжения",
        DATIVE = "шкафчику для административного снабжения",
        ACCUSATIVE = "шкафчик для административного снабжения",
        INSTRUMENTAL = "шкафчиком для административного снабжения",
        PREPOSITIONAL = "шкафчике для административного снабжения",
    )

/obj/structure/closet/gimmick/russian
	name = "russian surplus closet"
	desc = "It's a storage unit for Russian standard-issue surplus."
	desc = "Это устройство для хранения российских излишков продукции."

/obj/structure/closet/gimmick/russian/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для излишков российской продукции",
        GENITIVE = "шкафчика для излишков российской продукции",
        DATIVE = "шкафчику для излишков российской продукции",
        ACCUSATIVE = "шкафчик для излишков российской продукции",
        INSTRUMENTAL = "шкафчиком для излишков российской продукции",
        PREPOSITIONAL = "шкафчике для излишков российской продукции",
	)

/obj/structure/closet/gimmick/russian/populate_contents()
	new /obj/item/clothing/head/ushanka(src)
	new /obj/item/clothing/head/ushanka(src)
	new /obj/item/clothing/head/ushanka(src)
	new /obj/item/clothing/head/ushanka(src)
	new /obj/item/clothing/head/ushanka(src)
	new /obj/item/clothing/under/soviet(src)
	new /obj/item/clothing/under/soviet(src)
	new /obj/item/clothing/under/soviet(src)
	new /obj/item/clothing/under/soviet(src)
	new /obj/item/clothing/under/soviet(src)

/obj/structure/closet/gimmick/tacticool
	name = "tacticool gear closet"
	desc = "It's a storage unit for Tacticool gear."
	desc = "Это устройство для хранения тактикульного снаряжения."

/obj/structure/closet/gimmick/tacticool/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для тактикульным снаряжением",
        GENITIVE = "шкафчика для тактикульным снаряжением",
        DATIVE = "шкафчику для тактикульным снаряжением",
        ACCUSATIVE = "шкафчик для тактикульным снаряжением",
        INSTRUMENTAL = "шкафчиком для тактикульным снаряжением",
        PREPOSITIONAL = "шкафчиком для тактикульным снаряжением",
    )

/obj/structure/closet/gimmick/tacticool/populate_contents()
	new /obj/item/clothing/glasses/eyepatch(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/clothing/head/helmet/swat(src)
	new /obj/item/clothing/head/helmet/swat(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/shoes/combat/swat(src)
	new /obj/item/clothing/shoes/combat/swat(src)
	new /obj/item/clothing/suit/space/hardsuit/deathsquad(src)
	new /obj/item/clothing/suit/space/hardsuit/deathsquad(src)
	new /obj/item/clothing/under/syndicate/tacticool(src)
	new /obj/item/clothing/under/syndicate/tacticool(src)

/obj/structure/closet/thunderdome
	name = "Thunderdome closet"
	desc = "Everything you need!"
	desc = "Всё, что вам нужно!"
	icon_state = "syndicate"
	anchored = TRUE

/obj/structure/closet/thunderdome/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик \"Тандердом\"",
        GENITIVE = "шкафчика \"Тандердом\"",
        DATIVE = "шкафчику \"Тандердом\"",
        ACCUSATIVE = "шкафчик \"Тандердом\"",
        INSTRUMENTAL = "шкафчиком \"Тандердом\"",
        PREPOSITIONAL = "шкафчике \"Тандердом\"",
    )

/obj/structure/closet/thunderdome/tdred
	name = "red-team Thunderdome closet"

/obj/structure/closet/thunderdome/tdred/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик \"Тандердом\" красной команды",
        GENITIVE = "шкафчика \"Тандердом\" красной команды",
        DATIVE = "шкафчику \"Тандердом\" красной команды",
        ACCUSATIVE = "шкафчик \"Тандердом\" красной команды",
        INSTRUMENTAL = "шкафчиком \"Тандердом\" красной команды",
        PREPOSITIONAL = "шкафчике \"Тандердом\" красной команды",
    )

/obj/structure/closet/thunderdome/tdred/populate_contents()
	new /obj/item/clothing/suit/armor/tdome/red(src)
	new /obj/item/clothing/suit/armor/tdome/red(src)
	new /obj/item/clothing/suit/armor/tdome/red(src)
	new /obj/item/melee/energy/sword/saber(src)
	new /obj/item/melee/energy/sword/saber(src)
	new /obj/item/melee/energy/sword/saber(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/melee/baton/security/loaded(src)
	new /obj/item/melee/baton/security/loaded(src)
	new /obj/item/melee/baton/security/loaded(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)

/obj/structure/closet/thunderdome/tdgreen
	name = "green-team Thunderdome closet"
	icon_state = "syndicate1"

/obj/structure/closet/thunderdome/tdgreen/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик \"Тандердом\" зелёной команды",
        GENITIVE = "шкафчика \"Тандердом\" зелёной команды",
        DATIVE = "шкафчику \"Тандердом\" зелёной команды",
        ACCUSATIVE = "шкафчик \"Тандердом\" зелёной команды",
        INSTRUMENTAL = "шкафчиком \"Тандердом\" зелёной команды",
        PREPOSITIONAL = "шкафчике \"Тандердом\" зелёной команды",
    )

/obj/structure/closet/thunderdome/tdgreen/populate_contents()
	new /obj/item/clothing/suit/armor/tdome/green(src)
	new /obj/item/clothing/suit/armor/tdome/green(src)
	new /obj/item/clothing/suit/armor/tdome/green(src)
	new /obj/item/melee/energy/sword/saber(src)
	new /obj/item/melee/energy/sword/saber(src)
	new /obj/item/melee/energy/sword/saber(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/melee/baton/security/loaded(src)
	new /obj/item/melee/baton/security/loaded(src)
	new /obj/item/melee/baton/security/loaded(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)

