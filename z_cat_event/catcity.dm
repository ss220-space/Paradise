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

/turf/simulated/floor/indestructible/cat_floor/Initialize(mapload)
    . = ..()
    var/icon/I = icon(icon, icon_state)
    if(prob(20))
        I.Blend(icon(icon, "dec[rand(1,6)]"), ICON_OVERLAY)
        icon = I
        return
    if(prob(25))
        I.Blend(icon(icon, "claws[rand(1,3)]"), ICON_OVERLAY)
        icon = I

/turf/simulated/floor/indestructible/cat_floor/pink
    icon_state = "carpet_p"

/turf/simulated/floor/indestructible/cat_floor/blue
    icon_state = "carpet_b"

/turf/simulated/floor/indestructible/cat_floor/yellow
    icon_state = "carpet_y"

/turf/simulated/floor/indestructible/cat_floor/white
    icon_state = "carpet_w"
