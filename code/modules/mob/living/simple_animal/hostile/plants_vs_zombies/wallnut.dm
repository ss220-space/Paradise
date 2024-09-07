/mob/living/simple_animal/hostile/plant/wallnut
	name = "wallnut"
	desc = "Выглядит как большой и слегка разумный орех."
	maxHealth = 100
	health = 100

/mob/living/simple_animal/hostile/plant/wallnut/big
	name = "big wallnut"
	desc = "Выглядит как гиганский и слегка разумный орех."
	maxHealth = 250
	health = 250

/obj/item/seeds/terraformers_plant/wallnut/on_grow(obj/machinery/hydroponics/tray)
	. = ..()
	tray.connected_simplemob = null // Unpin the simplmob from the tray
	tray.dig_out()

/mob/living/simple_animal/hostile/plant/wallnut/AltClick(mob/living/M) // Not only humanoids.
	if (!("terraformers" in M.faction))
		return

	if (status_flags & CANPUSH)
		balloon_alert(M, "объект зафиксирован")
		status_flags &= ~CANPUSH
		move_resist = MOVE_FORCE_OVERPOWERING
	else
		balloon_alert(M, "объект откреплен")
		status_flags |= CANPUSH
		move_resist = MOVE_FORCE_DEFAULT

/mob/living/simple_animal/hostile/plant/wallnut/lantern
	name = "Jack-o'-lantern"
	desc = "Выглядит как что-то большое, светящееся и немного разумное."
	maxHealth = 30
	health = 30
	light_power = 20
	light_range = 14
	light_system = STATIC_LIGHT
