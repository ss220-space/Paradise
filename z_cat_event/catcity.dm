/turf/simulated/wall/indestructible/box_wall
    icon = 'z_cat_event/catcity.dmi'
    name = "коробка-стена"
    desc = "Гениальное изобретение кошек, которое позволяет им строить целые города из коробок."

/turf/simulated/wall/indestructible/box_wall/Initialize(mapload)
    . = ..()
    icon_state = pick("box1", "box2", "box3")

/turf/simulated/floor/indestructible/cat_floor
    icon = 'z_cat_event/catcity.dmi'
    name = "котопол"
    desc = "Ковёр, который кошки постелили на пол, чтобы им было удобно ходить."
    footstep = FOOTSTEP_CARPET
    barefootstep = FOOTSTEP_CARPET_BAREFOOT
    clawfootstep = FOOTSTEP_CARPET_BAREFOOT
    var/overlay_icon_state

/turf/simulated/floor/indestructible/cat_floor/Initialize(mapload)
    . = ..()
    if(prob(20))
        overlay_icon_state = "dec[rand(1, 6)]"
    else if(prob(25))
        overlay_icon_state = "claws[rand(1, 3)]"
    if(overlay_icon_state)
        update_appearance(UPDATE_OVERLAYS)

/turf/simulated/floor/indestructible/cat_floor/update_overlays()
    . = ..()
    if(overlay_icon_state)
        . += mutable_appearance(icon, overlay_icon_state)

/turf/simulated/floor/indestructible/cat_floor/pink
    icon_state = "carpet_p"

/turf/simulated/floor/indestructible/cat_floor/blue
    icon_state = "carpet_b"

/turf/simulated/floor/indestructible/cat_floor/yellow
    icon_state = "carpet_y"

/turf/simulated/floor/indestructible/cat_floor/white
    icon_state = "carpet_w"
