/obj/structure/blob/special/captured_nuke //alternative to blob just straight up destroying nukes
	name = "blob captured nuke"
	icon_state = "blob"
	desc = "Ядерная боеголовка спуталась в щупальцах блоба, пульсирующих ужасающим зеленым свечением."
	max_integrity = BLOB_CAP_NUKE_MAX_HP
	health_regen = BLOB_CAP_NUKE_HP_REGEN
	point_return = BLOB_REFUND_CAP_NUKE_COST

/obj/structure/blob/special/captured_nuke/Initialize(mapload, owner_overmind, obj/machinery/nuclearbomb/N)
	. = ..()
	START_PROCESSING(SSobj, src)
	N?.forceMove(src)
	update_icon(UPDATE_OVERLAYS)


/obj/structure/blob/special/captured_nuke/update_overlays()
	. = ..()
	. += mutable_appearance('icons/mob/blob.dmi', "blob_nuke_overlay", appearance_flags = RESET_COLOR)


/obj/structure/blob/special/captured_nuke/Destroy()
	for(var/obj/machinery/nuclearbomb/O in contents)
		O.forceMove(loc)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blob/special/captured_nuke/process()
	if(COOLDOWN_FINISHED(src, heal_timestamp))
		RegenHealth()
		COOLDOWN_START(src, heal_timestamp, 20)

