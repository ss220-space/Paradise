GLOBAL_LIST_EMPTY(bump_teleporters)

/obj/effect/bump_teleporter
    name = "bump-teleporter"
    icon = 'icons/mob/screen_gen.dmi'
    icon_state = "x2"
    var/id = null                           // id of this bump_teleporter.
    var/id_target = null                    // id of bump_teleporter which this moves you to.
    var/takes_special_items = 0            // Flag indicating whether this teleporter takes special items.
    var/list/items_to_remove = list()      // List of items to remove for this teleporter.
    invisibility = INVISIBILITY_ABSTRACT    // nope, can't see this
    anchored = 1
    density = 1
    opacity = 0

/obj/effect/bump_teleporter/New()
    ..()
    GLOB.bump_teleporters += src

/obj/effect/bump_teleporter/Destroy()
    GLOB.bump_teleporters -= src
    return ..()

/obj/effect/bump_teleporter/singularity_act()
    return

/obj/effect/bump_teleporter/singularity_pull()
    return

/obj/effect/bump_teleporter/Bumped(atom/movable/moving_atom)
    if (!ismob(moving_atom))
        // user.loc = src.loc    // Stop at teleporter location
        return

    if (!id_target)
        // user.loc = src.loc    // Stop at teleporter location, there is nowhere to teleport to.
        return

    for (var/obj/effect/bump_teleporter/BT in GLOB.bump_teleporters)
        if (BT.id == src.id_target)
            if (BT.takes_special_items)
                for (var/obj/item/I in moving_atom.contents)
                    if (I.type in BT.items_to_remove)
                        qdel(I)

            moving_atom.loc = BT.loc // Teleport to location with correct id.
            return
