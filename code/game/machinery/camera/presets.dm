// PRESETS

// EMP
/obj/machinery/camera/emp_proof

/obj/machinery/camera/emp_proof/Initialize(mapload, networks, input_assembly)
	var/obj/item/camera_assembly/new_assembly = new(src)
	new_assembly.upgrades.Add(new /obj/item/stack/sheet/mineral/plasma(new_assembly))
	. = ..(input_assembly = new_assembly)
// X-RAY

/obj/machinery/camera/xray

/obj/machinery/camera/xray/Initialize(mapload, networks, input_assembly)
	var/obj/item/camera_assembly/new_assembly = new(src)
	new_assembly.upgrades.Add(new /obj/item/analyzer(new_assembly))
	. = ..(input_assembly = new_assembly)
// MOTION
/obj/machinery/camera/motion

/obj/machinery/camera/motion/Initialize(mapload, networks, input_assembly)
	var/obj/item/camera_assembly/new_assembly = new(src)
	new_assembly.upgrades.Add(new /obj/item/assembly/prox_sensor(new_assembly))
	. = ..(input_assembly = new_assembly)
// ALL UPGRADES
/obj/machinery/camera/all


/obj/machinery/camera/all/Initialize(mapload, networks, input_assembly)
	var/obj/item/camera_assembly/new_assembly = new(src)
	new_assembly.upgrades.Add(new /obj/item/stack/sheet/mineral/plasma(new_assembly))
	new_assembly.upgrades.Add(new /obj/item/assembly/prox_sensor(new_assembly))
	new_assembly.upgrades.Add(new /obj/item/analyzer(new_assembly))
	. = ..(input_assembly = new_assembly)
// AUTONAME

/obj/machinery/camera/autoname
	var/number = 0 //camera number in area

//This camera type automatically sets it's name to whatever the area that it's in is called.
/obj/machinery/camera/autoname/Initialize(mapload)
	. = ..()
	number = 1
	var/area/A = get_area(src)
	if(A)
		for(var/obj/machinery/camera/autoname/C in GLOB.machines)
			if(C == src)
				continue
			var/area/CA = get_area(C)
			if(CA.type == A.type)
				if(C.number)
					number = max(number, C.number + 1)
		var/cam_tag = "[A.name] #[number]"
		c_tag = sanitize(cam_tag)


// CHECKS

/obj/machinery/camera/proc/isEmpProof()
	var/O = locate(/obj/item/stack/sheet/mineral/plasma) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isXRay()
	var/O = locate(/obj/item/analyzer) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isMotion()
	var/O = locate(/obj/item/assembly/prox_sensor) in assembly.upgrades
	return O


/obj/machinery/camera/proc/setPowerUsage()
	var/mult = 1
	if(isXRay())
		mult++
	if(isMotion())
		mult++
	active_power_usage = mult*initial(active_power_usage)
