/obj/item/gun/projectile/automatic/stalker_bolter
        name = "Stalker-pattern bolter"
        desc = "A powerful long-range bolter, used as a sniper weapon."
        icon_state = "sniper"
        item_state = "sniper"
        recoil = 3.5
        fire_sound = 'sound/weapons/gunshots/harbringer.ogg'
        zoomable = TRUE
        zoom_amt = 10
        weapon_weight = WEAPON_HEAVY
        fire_delay = 60
        burst_size = 1
        can_unsuppress = 1
        can_suppress = 1
        w_class = WEIGHT_CLASS_NORMAL
        slot_flags = SLOT_BACK
        actions_types = list()


/obj/item/ammo_box/magazine/bolter/sniper
        name = "sniper bolter magazine"
        icon_state = ".50mag"
        origin_tech = "combat=6"
        ammo_type = /obj/item/ammo_casing/caseless/bolter/sniper
        max_ammo = 6
        caliber = ".80"


/obj/item/ammo_casing/caseless/bolter/sniper
        name = "sniper bolter shell"
        desc = "A reactive-propelled shell that is typically loaded into sniper bolters."
        icon_state = ".50"
        projectile_type = /obj/item/projectile/bullet/bolter/sniper
        caliber = ".80"
        muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
        muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
/obj/item/projectile/bullet/bolter/sniper
        damage = 90
        stun = 1.5
        weaken = 3
        dismemberment = 50
        armour_penetration = 80
        var/breakthings = TRUE
/obj/item/projectile/bullet/bolter/sniper/on_hit(atom/target, blocked = 0, hit_zone)
        if((blocked != 100) && (!ismob(target) && breakthings))
                target.ex_act(rand(1,2))
                var/mob/living/carbon/C = target
                C.bleed(100)
        return ..()
