/obj/item/destabilizing_crystal
	name = "destabilizing crystal"
	desc = "Кристалл, способный дестабилизировать суперматерию и вызвать резонансный каскад. Осторожно примените его на \
		полностью стабильном кристалле суперматерии и запустите расслоение. Не позволяйте никому остановить вас."
	icon = 'icons/obj/engines_and_power/supermatter.dmi'
	icon_state = "destabilizing_crystal"
	flags = CONDUCT
	item_flags = NO_PIXEL_RANDOM_DROP
	throwforce = 5
	throw_speed = 1
	throw_range = 2

/obj/item/destabilizing_crystal/get_ru_names()
	return alist(
		NOMINATIVE = "дестабилизирующий кристалл",
		GENITIVE = "дестабилизирующего кристалла",
		DATIVE = "дестабилизирующему кристаллу",
		ACCUSATIVE = "дестабилизирующий кристалл",
		INSTRUMENTAL = "дестабилизирующим кристаллом",
		PREPOSITIONAL = "дестабилизирующем кристалле",
	)
