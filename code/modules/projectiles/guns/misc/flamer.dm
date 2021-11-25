/obj/item/gun/projectile/automatic/flamer
        name = "\improper grimdark flamethrower"
        desc = "A brutal flamer, used by ERT inquisitors and xenophobic terroristic groups."
        icon_state = "flamer"
        item_state = "flamethrower"
        w_class = WEIGHT_CLASS_NORMAL
        origin_tech = "combat=4;materials=2;illegal=3"
        mag_type = /obj/item/ammo_box/magazine/flamer
        fire_sound = 'sound/weapons/gunshots/flamer.ogg'
        magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
        magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
        can_suppress = 0
        burst_size = 1


/obj/item/projectile/flamer
        name = "flamer burst"
        icon_state = "blastwave"
        damage = 35
        damage_type = BURN
        nodamage = FALSE
        forcedodge = FALSE
        range = 5


/obj/item/projectile/flamer/Move()
        ..()
        var/turf/location = get_turf(src)
        if(location)
                new /obj/effect/hotspot(location)
                location.hotspot_expose(700, 50, 1)


/obj/item/projectile/flamer/on_hit(var/atom/target, var/blocked = 0)
        . = ..()
        if(iscarbon(target))
                var/mob/living/carbon/M = target
                M.adjust_fire_stacks(4)
                M.IgniteMob()