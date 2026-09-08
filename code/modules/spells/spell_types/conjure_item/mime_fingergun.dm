/datum/action/cooldown/spell/conjure_item/fingergun
	name = "Пальцы-пистолеты"
	desc = "Стреляйте из пальцев бесшумными смертоносными пулями! В вашем распоряжении будет 3 пули. Пау-пау-пау!"
	school = SCHOOL_MIME
	spell_requirements = NONE
	cooldown_time = 1 MINUTES

	button_icon_state = "fingergun"
	background_icon_state = "bg_mime"
	item_type = /obj/item/gun/projectile/revolver/fingergun

/datum/action/cooldown/spell/conjure_item/fingergun/fake
	desc = "Представьте, что вы стреляете из пальцев, как из пистолета! В вашем распоряжении будет 6 пуль. Пау-пау-пау!"
	item_type = /obj/item/gun/projectile/revolver/fingergun/fake
