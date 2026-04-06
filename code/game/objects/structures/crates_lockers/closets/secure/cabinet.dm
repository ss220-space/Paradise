/obj/structure/closet/secure_closet/cabinet //Tribute to all those poor mappers who gave their life copypasting these sacred strings // :(
	name = "secure cabinet"
	desc = "Старое всегда будет в моде."
	icon_state = "cabinet"
	overlay_sparking = "c_sparking"
	overlay_locked = "c_locked"
	overlay_unlocked = "c_unlocked"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25

/obj/structure/closet/secure_closet/cabinet/get_ru_names()
    return list(
        NOMINATIVE = "защищённый шкаф",
        GENITIVE = "защищённого шкафа",
        DATIVE = "защищённому шкафу",
        ACCUSATIVE = "защищённый шкаф",
        INSTRUMENTAL = "защищённым шкафом",
        PREPOSITIONAL = "защищённом шкафе",
    )
