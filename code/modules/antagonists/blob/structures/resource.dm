/obj/structure/blob/special/resource
	name = "resource blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	desc = "Тонкий шпиль слегка покачивающихся щупалец."
	max_integrity = BLOB_RESOURCE_MAX_HP
	point_return = BLOB_REFUND_RESOURCE_COST
	resistance_flags = LAVA_PROOF
	armor = list("melee" = 0, "bullet" = 0, "laser" = 25, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)
	var/resource_delay = 0
	var/point_rate = BLOB_RESOURCE_POINT_RATE

/obj/structure/blob/special/resource/scannerreport()
	return "Постепенно снабжает блоба ресурсами, увеличивая скорость расширения."

/obj/structure/blob/special/resource/link_to_overmind(mob/camera/blob/owner_overmind)
	. = ..()
	overmind.resource_blobs += src

/obj/structure/blob/special/resource/Destroy()
	if(overmind)
		overmind.resource_blobs -= src
	return ..()

/obj/structure/blob/special/resource/Be_Pulsed()
	. = ..()
	if(resource_delay > world.time)
		return
	flick("blob_resource_glow", src)
	if(overmind)
		overmind.add_points(point_rate)
		balloon_alert(overmind, "+[point_rate] resource\s")
		resource_delay = world.time + BLOB_RESOURCE_GATHER_DELAY + overmind.resource_blobs.len * BLOB_RESOURCE_GATHER_ADDED_DELAY //4 seconds plus a quarter second for each resource blob the overmind has
	else
		resource_delay = world.time + BLOB_RESOURCE_GATHER_DELAY
