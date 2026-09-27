/turf/simulated/floor/indestructible/bitrunning_transport
	name = "circuit floor"
	desc = "Под ногами по плите бегут ручейки закодированных данных. Сюда складывают зашифрованный груз."
	icon_state = "bitrunning"

/turf/simulated/floor/indestructible/bitrunning_transport/get_ru_names()
	return alist(
		NOMINATIVE = "плита выдачи",
		GENITIVE = "плиты выдачи",
		DATIVE = "плите выдачи",
		ACCUSATIVE = "плиту выдачи",
		INSTRUMENTAL = "плитой выдачи",
		PREPOSITIONAL = "плите выдачи",
	)

/turf/simulated/floor/indestructible/binary
	name = "tear in the fabric of reality"
	icon_state = "binary"

/turf/simulated/floor/indestructible/binary/get_ru_names()
	return alist(
		NOMINATIVE = "разрыв в ткани реальности",
		GENITIVE = "разрыва в ткани реальности",
		DATIVE = "разрыву в ткани реальности",
		ACCUSATIVE = "разрыв в ткани реальности",
		INSTRUMENTAL = "разрывом в ткани реальности",
		PREPOSITIONAL = "разрыве в ткани реальности",
	)

/turf/simulated/wall/indestructible/binary
	name = "tear in the fabric of reality"
	icon = 'icons/turf/floors.dmi'
	icon_state = "binary"
	smooth = SMOOTH_FALSE

/turf/simulated/wall/indestructible/binary/get_ru_names()
	return alist(
		NOMINATIVE = "разрыв в ткани реальности",
		GENITIVE = "разрыва в ткани реальности",
		DATIVE = "разрыву в ткани реальности",
		ACCUSATIVE = "разрыв в ткани реальности",
		INSTRUMENTAL = "разрывом в ткани реальности",
		PREPOSITIONAL = "разрыве в ткани реальности",
	)

/obj/effect/baseturf_helper/virtual_domain
	name = "virtual domain baseturf editor"
	baseturf = /turf/simulated/floor/indestructible/binary
