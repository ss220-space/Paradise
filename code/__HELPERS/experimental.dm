/*
 * Experimental procs by ESwordTheCat!
 */

/obj/machinery/proc/getArea()
	var/area/A = loc.loc

	if(A != myArea)
		myArea = A

	. = myArea
