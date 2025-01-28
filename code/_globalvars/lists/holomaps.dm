/// A list of fire alarms on the station, separated by Z. Used cause there are a lot of fire alarms on any given station Z.
GLOBAL_LIST_EMPTY(station_fire_alarms)

GLOBAL_LIST_EMPTY(holomap_default_legend)

/// Used in generating area preview icons.
GLOBAL_LIST_INIT(holomap_color_to_name, list(
	HOLOMAP_AREACOLOR_COMMAND = "Командование",
	HOLOMAP_AREACOLOR_SECURITY = "Безопасность",
	HOLOMAP_AREACOLOR_MEDICAL = "Медицина",
	HOLOMAP_AREACOLOR_SCIENCE = "Исследование",
	HOLOMAP_AREACOLOR_ENGINEERING = "Инженерия",
	HOLOMAP_AREACOLOR_CARGO = "Снабжение",
	HOLOMAP_AREACOLOR_HALLWAYS = "Коридоры",
	HOLOMAP_AREACOLOR_MAINTENANCE = "Тех. тоннели",
	HOLOMAP_AREACOLOR_ARRIVALS = "Зона прибытия",
	HOLOMAP_AREACOLOR_ESCAPE = "Зона отбытия",
	HOLOMAP_AREACOLOR_DORMS = "Зона отдыха",
	HOLOMAP_AREACOLOR_SERVICE = "Сервис",
	HOLOMAP_AREACOLOR_HANGAR = "Ангар",
))
