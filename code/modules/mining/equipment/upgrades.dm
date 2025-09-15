//plasma magmite is exclusively used to upgrade mining equipment, by using it on a heated world anvil to make upgradeparts.
/obj/item/magmite
	name = "plasma magmite"
	desc = "Образец плазменного магмита, кристаллизовавшийся в глубинах планеты. Кажется, он теряет силу по мере удаления от поверхности планеты!"
	icon = 'icons/obj/mining.dmi'
	icon_state = "Magmite ore"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/magmite_parts
	name = "plasma magmite upgrade parts"
	desc = "Выкованные на легендарной Мировой Кузне, эти детали можно использовать для улучшения различных видов шахтёрского оборудования."
	icon = 'icons/obj/mining.dmi'
	icon_state = "upgrade_parts"
	w_class = WEIGHT_CLASS_NORMAL
	var/inert = FALSE

/obj/item/magmite_parts/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(go_inert)), 50 SECONDS) //you know...


/obj/item/magmite_parts/update_icon_state()
	icon_state = "upgrade_parts[inert ? "_inert" : ""]"


/obj/item/magmite_parts/update_name(updates = ALL)
	. = ..()
	name = initial(name)
	if(inert)
		name = "inert [name]"


/obj/item/magmite_parts/update_desc(updates = ALL)
	. = ..()
	desc = inert ? "Похоже, он потерял своё магматическое свечение." : initial(desc)


/obj/item/magmite_parts/proc/go_inert()
	if(inert)
		return
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] теряет свечение!"))
	inert = TRUE
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)


/obj/item/magmite_parts/proc/restore()
	if(!inert)
		return
	inert = FALSE
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
	addtimer(CALLBACK(src, PROC_REF(go_inert)), 50 SECONDS)


/obj/item/magmite_parts/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return

	if(inert)
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] кажется неактивным! Возможно, Мировая Кузня сможет восстановить его!"))
		return

	switch(target.type)
		if(/obj/item/gun/energy/kinetic_accelerator/experimental)
			var/obj/item/gun/energy/kinetic_accelerator/gun = target
			if(gun.bayonet)
				gun.set_bayonet(null)
			if(gun.gun_light)
				gun.set_gun_light(null)
			gun.deattach_modkits()
			qdel(gun)
			var/obj/item/gun/energy/kinetic_accelerator/mega/newgun = new(get_turf(user))
			user.put_in_hands(newgun)
			to_chat(user, span_notice("Грубые щупальца обвивают кинетический акселератор, объединяя детали в мега-кинетический акселератор."))
			qdel(src)
		if(/obj/item/gun/energy/plasmacutter/adv)
			var/obj/item/gun/energy/plasmacutter/adv/gun = target
			qdel(gun)
			var/obj/item/gun/energy/plasmacutter/adv/mega/newgun = new(get_turf(user))
			user.put_in_hands(newgun)
			to_chat(user, span_notice("Грубые щупальца обвивают плазменный резак, объединяя детали в мега-плазменный резак."))
			qdel(src)
		if(/obj/item/gun/energy/plasmacutter/shotgun)
			var/obj/item/gun/energy/plasmacutter/shotgun/gun = target
			qdel(gun)
			var/obj/item/gun/energy/plasmacutter/shotgun/mega/newgun = new(get_turf(user))
			user.put_in_hands(newgun)
			to_chat(user, span_notice("Грубые щупальца обвивают плазменный дробовик, объединяя детали в мега-плазменный дробовик."))
			qdel(src)
		if(/obj/item/twohanded/kinetic_crusher) //sure hope there is a better way to do it..
			var/obj/item/twohanded/kinetic_crusher/gun = target
			for(var/t in gun.trophies)
				var/obj/item/crusher_trophy/T = t
				T.remove_from(gun, user)
			qdel(gun)
			var/obj/item/twohanded/kinetic_crusher/mega/newgun = new(get_turf(user))
			user.put_in_hands(newgun)
			to_chat(user, span_notice("Грубые щупальца обвивают кинетический крушитель, объединяя детали в мега-кинетический крушитель."))
			qdel(src)

