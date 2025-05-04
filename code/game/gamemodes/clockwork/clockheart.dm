/obj/structure/clockwork/functional/heart
	name = "The heart of Ratvar"
	ru_names = list(
		NOMINATIVE = "Сердце Ратвара",
		GENITIVE = "Сердца Ратвара",
		DATIVE = "Сердцу Ратвара",
		ACCUSATIVE = "Сердце Ратвара",
		INSTRUMENTAL = "Сердцем Ратвара",
		PREPOSITIONAL = "Сердце Ратвара",
	)
	desc = "Огромный механизм из латуни, напоминающий сердце. От его громкого тиканья у вас начинает болеть голова..."
	icon = 'icons/obj/clockheart.dmi'
	icon_state = "heart"
	pixel_x = -32
	pixel_y = -32
	layer = ABOVE_WINDOW_LAYER
	var/curse_dial = TRUE
	var/curse_upper = TRUE
	var/curse_lower = TRUE

/obj/structure/clockwork/functional/heart/Initialize(mapload)
	START_PROCESSING(SSprocessing, src)
	. = ..()

/obj/structure/clockwork/functional/heart/update_overlays()
	if(curse_dial)
		add_overlay("narsie_curse1")
	if(curse_upper)
		add_overlay("narsie_curse2")
	if(curse_lower)
		add_overlay("narsie_curse3")
	. = ..()

/obj/structure/clockwork/functional/heart/process(seconds_per_tick)
	update_overlays()
	. = ..()

