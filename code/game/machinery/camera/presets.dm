// PRESETS

// EMP

/obj/machinery/camera/emp_proof/Initialize(mapload, list/network, c_tag, obj/item/camera_assembly/input_assembly)
	var/obj/item/camera_assembly/new_assembly = new(src)
	new_assembly.upgrades.Add(new /obj/item/stack/sheet/mineral/plasma(new_assembly))
	. = ..(input_assembly = new_assembly)
// X-RAY


/obj/machinery/camera/xray/Initialize(mapload, list/network, c_tag, obj/item/camera_assembly/input_assembly)
	var/obj/item/camera_assembly/new_assembly = new(src)
	new_assembly.upgrades.Add(new /obj/item/analyzer(new_assembly))
	. = ..(input_assembly = new_assembly)
// MOTION

/obj/machinery/camera/motion/Initialize(mapload, list/network, c_tag, obj/item/camera_assembly/input_assembly)
	var/obj/item/camera_assembly/new_assembly = new(src)
	new_assembly.upgrades.Add(new /obj/item/assembly/prox_sensor(new_assembly))
	. = ..(input_assembly = new_assembly)
// ALL UPGRADES


/obj/machinery/camera/all/Initialize(mapload, list/network, c_tag, obj/item/camera_assembly/input_assembly)
	var/obj/item/camera_assembly/new_assembly = new(src)
	new_assembly.upgrades.Add(new /obj/item/stack/sheet/mineral/plasma(new_assembly), new /obj/item/assembly/prox_sensor(new_assembly), new /obj/item/analyzer(new_assembly))
	. = ..(input_assembly = new_assembly)
// AUTONAME

// This camera type automatically sets it's name to whatever the area that it's in is called.
/obj/machinery/camera/autoname/Initialize(mapload)
	var/static/list/autonames_in_areas = list()

	var/area/camera_area = get_area(src)
	if(!camera_area)
		c_tag = "Unknown #[rand(1, 100)]"
		stack_trace("Camera with tag [c_tag] was spawned without an area, please report this to your nearest coder.")
		return ..()

	c_tag = "[sanitize(camera_area.name)] #[++autonames_in_areas[camera_area]]" // increase the number, then print it (this is what ++ before does)
	return ..() // We do this here so the camera is not added to the cameranet until it has a name.


// CHECKS

/obj/machinery/camera/proc/isEmpProof()
	return locate(/obj/item/stack/sheet/mineral/plasma) in assembly.upgrades

/obj/machinery/camera/proc/isXRay()
	return locate(/obj/item/analyzer) in assembly.upgrades

/obj/machinery/camera/proc/isMotion()
	return locate(/obj/item/assembly/prox_sensor) in assembly.upgrades


/obj/machinery/camera/proc/setPowerUsage()
	var/mult = 1
	if(isXRay())
		mult++
	if(isMotion())
		mult++
	active_power_usage = mult*initial(active_power_usage)
