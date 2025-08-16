// Adminspawn only. Transforms tier3 anomaly to tier4 anomaly.

/obj/item/anomaly_upgrader
	name = "усилитель аномалий"
	desc = "Черезвычайно дорогой и высокотехнологичный прибор, способный значительно усилять большие аномалии, попадая в них. \
			Такие приборы невозможно достать без помощи кого-то с ЦК. Если вы решите его использовать, убедитесь что готовы, \
			иначе вы уже ни в чем не сможете убедиться."
	gender = MALE
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "capacitor"
	origin_tech = "magnets=11"

/obj/item/anomaly_upgrader/get_ru_names()
	return list(
		NOMINATIVE = "усилитель аномалий", \
		GENITIVE = "усилителя аномалий", \
		DATIVE = "усилителю аномалий", \
		ACCUSATIVE = "усилитель аномалий", \
		INSTRUMENTAL = "усилителем аномалий", \
		PREPOSITIONAL = "усилителе аномалий"
	)
