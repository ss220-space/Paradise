/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Используется для стрельбы из лука. Самый примитивный вариант."
	gender = FEMALE
	icon_state = "arrow"
	item_state = "arrow"
	force = 10
	projectile_type = /obj/projectile/bullet/reusable/arrow
	muzzle_flash_effect = null
	caliber = CALIBER_ARROW

/obj/item/ammo_casing/caseless/arrow/get_ru_names()
	return list(
		NOMINATIVE = "деревянная стрела",
		GENITIVE = "деревянной стрелы",
		DATIVE = "деревянной стреле",
		ACCUSATIVE = "деревянную стрелу",
		INSTRUMENTAL = "деревянной стрелой",
		PREPOSITIONAL = "деревянной стреле",
	)

/obj/item/ammo_casing/caseless/arrow/add_notes_ammo()
	// Try to get a projectile to derive stats from
	var/obj/projectile/exam_proj = projectile_type
	var/initial_damage = initial(exam_proj.damage)
	var/initial_stamina = initial(exam_proj.stamina)
	// projectile damage multiplier for guns with snowflaked damage multipliers
	var/proj_damage_mult = 1
	// projectile stamina damage multiplier
	var/proj_stamine_mult = 1
	if(!ispath(exam_proj) || pellets == 0)
		return

	// are we in an ammo box?
	if(isammobox(loc))
		var/obj/item/ammo_box/our_box = loc
		// is our ammo box in a gun?
		if(isgun(our_box.loc))
			var/obj/item/gun/our_gun = our_box.loc
			// grab the damage multiplier
			proj_damage_mult = our_gun.damage_mod
			proj_stamine_mult = our_gun.stamina_mod
	// if not, are we just in a gun e.g. chambered
	else if(isgun(loc))
		var/obj/item/gun/our_gun = loc
		// grab the damage multiplier.
		proj_damage_mult = our_gun.damage_mod
		proj_stamine_mult = our_gun.stamina_mod

	var/list/readout = list()
	readout += "<b><u>СТРЕЛЬБА</u></b>"
	if((proj_damage_mult <= 0 && proj_stamine_mult <= 0) || (initial_damage <= 0 && initial_stamina <= 0))
		return span_boldnotice("- [DECLENT_RU_CAP(src, NOMINATIVE)] не наносит значимого ущерба при попадании.")

	// No dividing by 0
	if(initial_damage)
		var/lethal_hits_to_crit_str = span_warning("[HITS_TO_CRIT((initial(exam_proj.damage) * proj_damage_mult) * pellets)] попадан[declension_ru(HITS_TO_CRIT((initial(exam_proj.damage) * proj_damage_mult) * pellets), "ие", "ия", "ий")]")
		readout += "- Для нанесения <b>[span_red("летальных ранений")]</b> противнику [span_warning(declent_ru(INSTRUMENTAL))] потребуется примерно [lethal_hits_to_crit_str]."
	if(initial_stamina)
		var/non_lethal_hits_to_crit_str = span_warning("[HITS_TO_CRIT((initial(exam_proj.stamina) * proj_stamine_mult) * pellets)] попадан[declension_ru(HITS_TO_CRIT((initial(exam_proj.stamina) * proj_stamine_mult) * pellets), "ие", "ия", "ий")]")
		readout += "- Для <b>[span_blue("нелетального")]</b> обезвреживания противника [span_warning(declent_ru(INSTRUMENTAL))] потребуется примерно [non_lethal_hits_to_crit_str]."

	return readout.Join("\n") // Sending over a single string, rather than the whole list

/obj/item/ammo_casing/caseless/arrow/bone_tipped
	name = "bone-tipped arrow"
	desc = "Используется для стрельбы из лука. Выполнена из кости, дерева и сухожилий. Прочная и острая."
	icon_state = "bone_arrow"
	item_state = "bone_arrow"
	force = 12
	projectile_type = /obj/projectile/bullet/reusable/arrow/bone

/obj/item/ammo_casing/caseless/arrow/bone_tipped/get_ru_names()
	return list(
		NOMINATIVE = "костяная стрела",
		GENITIVE = "костяной стрелы",
		DATIVE = "костяной стреле",
		ACCUSATIVE = "костяную стрелу",
		INSTRUMENTAL = "костяной стрелой",
		PREPOSITIONAL = "костяной стреле",
	)

/obj/item/ammo_casing/caseless/arrow/jagged
	name = "jagged-tipped arrow"
	desc = "Используется для стрельбы из лука. Выполнена из зубов хищной рыбы. Невероятно острая и крепкая."
	icon_state = "jagged_arrow"
	force = 16
	projectile_type = /obj/projectile/bullet/reusable/arrow/jagged

/obj/item/ammo_casing/caseless/arrow/jagged/get_ru_names()
	return list(
		NOMINATIVE = "зазубренная стрела",
		GENITIVE = "зазубренной стрелы",
		DATIVE = "зазубренной стреле",
		ACCUSATIVE = "зазубренную стрелу",
		INSTRUMENTAL = "зазубренной стрелой",
		PREPOSITIONAL = "зазубренной стреле",
	)
