// The purpose of "Decor" structures is to look like pre-existing objects without having functionality

/obj/structure/decor
	name = "Non-existent Decor"
	desc = "Yell at a coder!"
	anchored = TRUE
	density = TRUE

/obj/structure/decor/ifv
	name = "destroyed M34 IFV"
	desc = "Уничтоженная БМП. Так просто не поднять – сорок шесть тонн..."
	icon = 'icons/obj/ifv_prop.dmi'
	icon_state = "ifv_destroyed"
	resistance_flags = INDESTRUCTIBLE

/obj/structure/decor/ifv/get_ru_names()
	return alist(
		NOMINATIVE = "уничтоженная БМП M34",
		GENITIVE = "уничтоженной БМП M34",
		DATIVE = "уничтоженной БМП M34",
		ACCUSATIVE = "уничтоженную БМП M34",
		INSTRUMENTAL = "уничтоженной БМП M34",
		PREPOSITIONAL = "уничтоженной БМП M34",
	)
