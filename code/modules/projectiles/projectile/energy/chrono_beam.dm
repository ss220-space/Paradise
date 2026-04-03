/obj/projectile/energy/chrono_beam
	name = "eradication beam"
	icon_state = "chronobolt"
	range = CHRONO_BEAM_RANGE
	color = null
	nodamage = TRUE
	var/obj/item/gun/energy/chrono_gun/gun = null

/obj/projectile/energy/chrono_beam/Destroy()
	gun = null
	. = ..()

/obj/projectile/energy/chrono_beam/fire()
	gun = firer.get_active_hand()
	if(istype(gun))
		return ..()
	else
		return 0

/obj/projectile/energy/chrono_beam/on_hit(atom/target)
	if(target && gun && isliving(target))
		var/obj/structure/chrono_field/F = new(target.loc, target, gun)
		gun.field_connect(F)
