// MARK: Foam force
/obj/item/ammo_box/foambox
	name = "ammo box (Foam Darts)"
	desc = "Коробка, содержащая пенные патроны."
	icon = 'icons/obj/weapons/toy.dmi'
	icon_state = "foambox"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	max_ammo = 40

/obj/item/ammo_box/foambox/get_ru_names()
	return list(
		NOMINATIVE = "коробка с пенными патронами",
		GENITIVE = "коробки с пенными патронами",
		DATIVE = "коробке с пенными патронами",
		ACCUSATIVE = "коробку с пенными патронами",
		INSTRUMENTAL = "коробкой с пенными патронами",
		PREPOSITIONAL = "коробке с пенными патронами",
	)

/obj/item/ammo_box/foambox/riot
	icon_state = "foambox_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/foambox/sniper
	name = "ammo box (Foam Sniper Darts)"
	desc = "Коробка, содержащая снайперские пенные патроны."
	icon_state = "foambox_sniper"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper

/obj/item/ammo_box/foambox/sniper/get_ru_names()
	return list(
		NOMINATIVE = "коробка со снайперскими пенными патронами",
		GENITIVE = "коробки со снайперскими пенными патронами",
		DATIVE = "коробке со снайперскими пенными патронами",
		ACCUSATIVE = "коробку со снайперскими пенными патронами",
		INSTRUMENTAL = "коробкой со снайперскими пенными патронами",
		PREPOSITIONAL = "коробке со снайперскими пенными патронами",
	)

/obj/item/ammo_box/foambox/sniper/riot
	icon_state = "foambox_sniper_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper/riot
