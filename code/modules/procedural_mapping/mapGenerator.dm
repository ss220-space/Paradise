/datum/mapGenerator

	//Map information
	var/list/map = list()

	//mapGeneratorModule information
	var/list/modules = list()

/datum/mapGenerator/New()
	..()
	initialiseModules()

///Defines the region the map represents, sets map
///Returns the map
/datum/mapGenerator/proc/defineRegion(turf/Start, turf/End, replace = 0)
	if(!checkRegion(Start, End))
		return 0

	if(replace)
		undefineRegion()

	map |= block(Start,End)
	return map

///Defines the region the map represents, as a CIRCLE!, sets map
///Returns the map
/datum/mapGenerator/proc/defineCircularRegion(turf/Start, turf/End, replace = 0)
	if(!checkRegion(Start, End))
		return 0

	var/centerX = max(abs((End.x+Start.x)/2),1)
	var/centerY = max(abs((End.y+Start.y)/2),1)

	var/lilZ = min(Start.z,End.z)
	var/bigZ = max(Start.z,End.z)

	var/sphereMagic = max(abs(bigZ-(lilZ/2)),1) //Spherical maps! woo!

	var/radius = abs(max(centerX,centerY)) //take the biggest displacement as the radius

	if(replace)
		undefineRegion()

	//Even sphere correction engage
	var/offByOneOffset = 1
	if(bigZ % 2 == 0)
		offByOneOffset = 0

	for(var/i = lilZ, i <= bigZ+offByOneOffset, i++)
		var/theRadius = radius
		if(i != sphereMagic)
			theRadius = max(radius/max((2*abs(sphereMagic-i)),1),1)

		map |= circle_range(locate(centerX,centerY,i),theRadius)

	return map

///Empties the map list, he's dead jim.
/datum/mapGenerator/proc/undefineRegion()
	map = list() //bai bai

///Checks for and Rejects bad region coordinates
///Returns 1/0
/datum/mapGenerator/proc/checkRegion(turf/Start, turf/End)
	. = 1

	if(!Start || !End)
		return 0 //Just bail

	if(Start.x > world.maxx || End.x > world.maxx)
		. = 0
	if(Start.y > world.maxy || End.y > world.maxy)
		. = 0
	if(Start.z > world.maxz || End.z > world.maxz)
		. = 0

///Requests the mapGeneratorModule(s) to (re)generate
/datum/mapGenerator/proc/generate()
	syncModules()
	if(!modules || !length(modules))
		return
	for(var/datum/mapGeneratorModule/mod in modules)
		spawn(0)
			mod.generate()

///Requests the mapGeneratorModule(s) to (re)generate this one turf
/datum/mapGenerator/proc/generateOneTurf(turf/T)
	if(!T)
		return
	syncModules()
	if(!modules || !length(modules))
		return
	for(var/datum/mapGeneratorModule/mod in modules)
		spawn(0)
			mod.place(T)

///Replaces all paths in the module list with actual module datums
/datum/mapGenerator/proc/initialiseModules()
	for(var/path in modules)
		if(ispath(path))
			modules.Remove(path)
			modules |= new path
	syncModules()

///Sync mapGeneratorModule(s) to mapGenerator
/datum/mapGenerator/proc/syncModules()
	for(var/datum/mapGeneratorModule/mod in modules)
		mod.sync(src)

ADMIN_VERB(debug_nature_map_generator, R_DEBUG, "Test Nature Map Generator", "Test the nature map generator", ADMIN_CATEGORY_MAPPING)
	var/datum/mapGenerator/nature/N = new()
	var/startInput = tgui_input_text(user, "Start turf of Map, (X;Y;Z)", "Map Gen Settings", "1;1;1")
	var/endInput = tgui_input_text(user, "End turf of Map (X;Y;Z)", "Map Gen Settings", "[world.maxx];[world.maxy];[user.mob ? user.mob.z : 1]")
	//maxx maxy and current z so that if you fuck up, you only fuck up one entire z level instead of the entire universe
	if(!startInput || !endInput)
		to_chat(user, "Missing Input")
		return

	var/list/startCoords = splittext(startInput, ";")
	var/list/endCoords = splittext(endInput, ";")
	if(!startCoords || !endCoords)
		to_chat(user, "Invalid Coords")
		to_chat(user, "Start Input: [startInput]")
		to_chat(user, "End Input: [endInput]")
		return

	var/turf/Start = locate(text2num(startCoords[1]),text2num(startCoords[2]),text2num(startCoords[3]))
	var/turf/End = locate(text2num(endCoords[1]),text2num(endCoords[2]),text2num(endCoords[3]))
	if(!Start || !End)
		to_chat(user, "Invalid Turfs")
		to_chat(user, "Start Coords: [startCoords[1]] - [startCoords[2]] - [startCoords[3]]")
		to_chat(user, "End Coords: [endCoords[1]] - [endCoords[2]] - [endCoords[3]]")
		return

	var/static/list/clusters = list(
		"None" = CLUSTER_CHECK_NONE,
		"All" = CLUSTER_CHECK_ALL,
		"Sames" = CLUSTER_CHECK_SAMES,
		"Differents" = CLUSTER_CHECK_DIFFERENTS,
		"Same turfs" = CLUSTER_CHECK_SAME_TURFS,
		"Same atoms" = CLUSTER_CHECK_SAME_ATOMS,
		"Different turfs" = CLUSTER_CHECK_DIFFERENT_TURFS,
		"Different atoms" = CLUSTER_CHECK_DIFFERENT_ATOMS,
		"All turfs" = CLUSTER_CHECK_ALL_TURFS,
		"All atoms" = CLUSTER_CHECK_ALL_ATOMS,
	)

	var/moduleClusters = tgui_input_list(user, "Cluster Flags (Cancel to leave unchanged from defaults)", "Map Gen Settings", clusters)
	//null for default

	var/theCluster = 0
	if(moduleClusters != "None")
		if(!clusters[moduleClusters])
			to_chat(user, "Invalid Cluster Flags")
			return
		theCluster = clusters[moduleClusters]
	else
		theCluster =  CLUSTER_CHECK_NONE

	if(theCluster)
		for(var/datum/mapGeneratorModule/M as anything in N.modules)
			M.clusterCheckFlags = theCluster

	to_chat(user, "Defining Region")
	N.defineRegion(Start, End)
	to_chat(user, "Region Defined")
	to_chat(user, "Generating Region")
	N.generate()
	to_chat(user, "Generated Region")
