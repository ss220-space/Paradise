// Theft objectives.
//
// Separated into datums so we can prevent roles from getting certain objectives.

GLOBAL_LIST_INIT(potential_theft_objectives, subtypesof(/datum/theft_objective/highrisk))
GLOBAL_LIST_INIT(potential_theft_objectives_hard, subtypesof(/datum/theft_objective/hard))
GLOBAL_LIST_INIT(potential_theft_objectives_easy, subtypesof(/datum/theft_objective/easy))
GLOBAL_LIST_INIT(potential_theft_objectives_collect, subtypesof(/datum/theft_objective/collect) + subtypesof(/datum/theft_objective/number))

#define THEFT_FLAG_SPECIAL 	1//unused, maybe someone will use it some day, I'll leave it here for the children
#define THEFT_FLAG_HIGHRISK 2
#define THEFT_FLAG_UNIQUE 	3
#define THEFT_FLAG_HARD 	4
#define THEFT_FLAG_EASY 	5
#define THEFT_FLAG_COLLECT 	6


/datum/objective/steal/proc/get_theft_list_objectives()
	switch(type_theft_flag)
		if(THEFT_FLAG_HARD)
			return GLOB.potential_theft_objectives_hard
		if(THEFT_FLAG_EASY)
			return GLOB.potential_theft_objectives_easy
		if(THEFT_FLAG_COLLECT)
			return GLOB.potential_theft_objectives_collect
		else
			return GLOB.potential_theft_objectives
/datum/theft_objective
	var/name = "this objective is impossible, yell at a coder"
	var/obj/typepath=/obj/effect/debugging
	var/list/protected_jobs = list()
	var/list/altitems = list()
	var/flags = 0
	var/location_override

/datum/theft_objective/proc/check_completion(var/datum/mind/owner)
	if(!owner.current)
		return 0
	if(!isliving(owner.current))
		return 0
	var/list/all_items = owner.current.get_contents()
	for(var/obj/I in all_items) //Check for items
		if(istype(I, typepath) && check_special_completion(I))
			return 1
	return 0

/datum/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return 1

/datum/theft_objective/highrisk
	flags = THEFT_FLAG_HIGHRISK


/datum/theft_objective/highrisk/antique_laser_gun
	name = "the captain's antique laser gun"
	typepath = /obj/item/gun/energy/laser/captain
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/captains_jetpack
	name = "the captain's deluxe jetpack"
	typepath = /obj/item/tank/jetpack/oxygen/captain
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/captains_rapier
	name = "the captain's rapier"
	typepath = /obj/item/melee/rapier
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/hoslaser
	name = "the head of security's X-01 multiphase energy gun"
	typepath = /obj/item/gun/energy/gun/hos
	protected_jobs = list("Head Of Security")

/datum/theft_objective/highrisk/hand_tele
	name = "a hand teleporter"
	typepath = /obj/item/hand_tele
	protected_jobs = list("Captain", "Research Director", "Chief Engineer")

/datum/theft_objective/highrisk/ai
	name = "a functional AI"
	typepath = /obj/item/aicard
	location_override = "AI Satellite. An intellicard for transportation can be found in Tech Storage, Science Department or manufactured"

/datum/theft_objective/highrisk/ai/check_special_completion(var/obj/item/aicard/C)
	if(..())
		for(var/mob/living/silicon/ai/A in C)
			if(istype(A, /mob/living/silicon/ai) && A.stat != 2) //See if any AI's are alive inside that card.
				return 1
	return 0

/datum/theft_objective/highrisk/defib
	name = "a compact defibrillator"
	typepath = /obj/item/defibrillator/compact
	protected_jobs = list("Chief Medical Officer", "Paramedic")

/datum/theft_objective/highrisk/magboots
	name = "the chief engineer's advanced magnetic boots"
	typepath = /obj/item/clothing/shoes/magboots/advance
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/highrisk/blueprints
	name = "the station blueprints"
	typepath = /obj/item/areaeditor/blueprints/ce
	protected_jobs = list("Chief Engineer")
	altitems = list(/obj/item/photo)

/datum/objective_item/highrisk/blueprints/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/areaeditor/blueprints/ce))
		return 1
	if(istype(I, /obj/item/photo))
		var/obj/item/photo/P = I
		if(P.blueprints)
			return 1
	return 0

/datum/theft_objective/highrisk/capmedal
	name = "the medal of captaincy"
	typepath = /obj/item/clothing/accessory/medal/gold/captain
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/nukedisc
	name = "the nuclear authentication disk"
	typepath = /obj/item/disk/nuclear
	protected_jobs = list("Captain")

/datum/theft_objective/highrisk/reactive
	name = "the reactive teleport armor"
	typepath = /obj/item/clothing/suit/armor/reactive/teleport
	protected_jobs = list("Research Director")

/datum/theft_objective/highrisk/documents
	name = "any set of secret documents of any organization"
	typepath = /obj/item/documents //Any set of secret documents. Doesn't have to be NT's

/datum/theft_objective/highrisk/hypospray
	name = "the Chief Medical Officer's hypospray"
	typepath = /obj/item/reagent_containers/hypospray/CMO
	protected_jobs = list("Chief Medical Officer")

/datum/theft_objective/highrisk/ablative
	name = "an ablative armor vest"
	typepath = /obj/item/clothing/suit/armor/laserproof
	protected_jobs = list("Head of Security", "Warden")

/datum/theft_objective/highrisk/krav
	name = "the warden's krav maga martial arts gloves"
	typepath = /obj/item/clothing/gloves/color/black/krav_maga/sec
	protected_jobs = list("Head Of Security", "Warden")

/datum/theft_objective/number
	flags = THEFT_FLAG_COLLECT
	var/min=0
	var/max=0
	var/step=1
	var/required_amount=0

/datum/theft_objective/number/New()
	if(min==max)
		required_amount=min
	else
		var/lower=min/step
		var/upper=min/step
		required_amount=rand(lower,upper)*step
	name = "Украсть [name] в количестве [required_amount] штук."

/datum/theft_objective/number/check_completion(var/datum/mind/owner)
	if(!owner.current)
		return 0
	if(!isliving(owner.current))
		return 0
	var/list/all_items = owner.current.get_contents()
	var/found_amount=0.0
	for(var/obj/item/I in all_items)
		if(istype(I, typepath))
			found_amount += getAmountStolen(I)
	return found_amount >= required_amount

/datum/theft_objective/number/proc/getAmountStolen(var/obj/item/I)
	return I:amount

/datum/theft_objective/number/baton
	typepath = /obj/item/melee/baton
	min=4
	max=8

/datum/theft_objective/number/laser
	typepath = /obj/item/gun/energy/laser
	min=3
	max=5

/datum/theft_objective/number/wt550
	typepath = /obj/item/gun/projectile/automatic/wt550
	min=2
	max=3

/datum/theft_objective/number/riot_armor
	typepath = /obj/item/clothing/suit/armor/riot
	min=2
	max=3

/datum/theft_objective/number/riot_shield
	typepath = /obj/item/shield/riot
	min=2
	max=3

/datum/theft_objective/number/bulletproof_armor
	typepath = /obj/item/clothing/suit/armor/bulletproof
	min=2
	max=3

/datum/theft_objective/number/bulletproof_armor
	typepath = /obj/item/megaphone
	min=4
	max=7


/datum/theft_objective/number/bulletproof_armor
	typepath = /obj/item/melee/classic_baton/telescopic
	min=3
	max=5



/datum/theft_objective/unique
	flags = THEFT_FLAG_UNIQUE

/datum/theft_objective/unique/docs_red
	name = "the \"Red\" secret documents"
	typepath = /obj/item/documents/syndicate/red

/datum/theft_objective/unique/docs_blue
	name = "the \"Blue\" secret documents"
	typepath = /obj/item/documents/syndicate/blue


/datum/theft_objective/hard
	flags = THEFT_FLAG_HARD
/datum/theft_objective/hard/capduck
	typepath = /obj/item/bikehorn/rubberducky/captain
	name = "любимая уточка капитана"
	protected_jobs = list("Captain")

/datum/theft_objective/hard/capspare
	typepath = /obj/item/card/id/captains_spare
	name = "запасную карту капитана с каюты"
	protected_jobs = list("Captain")

/datum/theft_objective/hard/goldcup
	typepath = /obj/item/reagent_containers/food/drinks/trophy/gold_cup	//!!!Необходимо добавить в сейф
	name = "золотой кубок"
	protected_jobs = list("Captain")


/datum/theft_objective/easy
	flags = THEFT_FLAG_EASY
/datum/theft_objective/easy/hatntrep
	typepath = /obj/item/clothing/head/ntrep
	name = "головной убор представителя"
/datum/theft_objective/easy/hatcapparade
	typepath = /obj/item/clothing/head/caphat/parade
	name = "парадную фуражку капитана"
/datum/theft_objective/easy/hatrd
	typepath = /obj/item/clothing/head/beret/purple
	name = "берет РД"
/datum/theft_objective/easy/hathos
	typepath = /obj/item/clothing/head/HoS
	name = "головной убор Главы Службы Безопасности"
/datum/theft_objective/easy/hatwarden
	typepath = /obj/item/clothing/head/warden
	name = "полицейскую фуражку Вардена
/datum/theft_objective/easy/hatwardenberet
	typepath = /obj/item/clothing/head/beret/sec/warden
	name = "берет Вардена"


/datum/theft_objective/collect
	flags = THEFT_FLAG_COLLECT
	var/min=0
	var/max=0
	var/step=1
	var/required_amount=0
	var/list/obj/item/typepath_list = list()
	var/list/obj/item/choosen_typepath_list = list()

/datum/theft_objective/collect/New()
	if(min==max)
		required_amount=min
	else
		var/lower=min/step
		var/upper=min/step
		required_amount=rand(lower,upper)*step

	var/list/obj/item/possible_typepath_list = typepath_list.Copy()
	for(var/i=0, i < required_amount, i++)
		var/obj/item/O = pick(possible_typepath_list)
		possible_typepath_list.Remove(O)
		choosen_typepath_list.Add(O)
		name += "[O.name][i < required_amount-1 ? ', ' : '.']"

/datum/theft_objective/collect/check_completion(var/datum/mind/owner)
	if(!owner.current)
		return 0
	if(!isliving(owner.current))
		return 0
	var/list/all_items = owner.current.get_contents()
	var/found_amount=0.0
	for(var/obj/item/I in all_items)
		for(var/obj/item/type_item in choosen_typepath_list)
			if(istype(I, type_item))
				found_amount += getAmountStolen(I)
	return found_amount >= required_amount

/datum/theft_objective/collect/proc/getAmountStolen(var/obj/item/I)
	return I:amount

/datum/theft_objective/collect/figure
	var/min=3
	var/max=10
	var/list/obj/item/typepath_list = subtypesof(/obj/item/toy/figure)

/datum/theft_objective/collect/figure
	var/min=3
	var/max=10
	var/list/obj/item/typepath_list = list
