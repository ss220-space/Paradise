/datum/reagent/consumable/drink/cold
	name = "Cold drink"
	adj_temp_cool = 5

/datum/reagent/consumable/drink/cold/tonic
	name = "Tonic Water"
	id = "tonic"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	color = "#664300" // rgb: 102, 67, 0
	adj_dizzy = -10 SECONDS
	adj_drowsy = -6 SECONDS
	adj_sleepy = -4 SECONDS
	drink_icon = "glass_clear"
	drink_name = "Glass of Tonic Water"
	drink_desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	taste_description = "bitterness"

/datum/reagent/consumable/drink/cold/sodawater
	name = "Soda Water"
	id = "sodawater"
	description = "A can of club soda. Why not make a scotch and soda?"
	color = "#619494" // rgb: 97, 148, 148
	adj_dizzy = -10 SECONDS
	adj_drowsy = -6 SECONDS
	drink_icon = "glass_clear"
	drink_name = "Glass of Soda Water"
	drink_desc = "Soda water. Why not make a scotch and soda?"
	taste_description = "fizz"

/datum/reagent/consumable/drink/cold/ice
	name = "Ice"
	id = "ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148
	adj_temp_cool = 0
	drink_icon = "iceglass"
	drink_name = "Glass of ice"
	drink_desc = "Generally, you're supposed to put something else in there too..."
	taste_description = "cold"

/datum/reagent/consumable/drink/cold/ice/on_mob_life(mob/living/M)
	M.bodytemperature = max(M.bodytemperature - 5 * TEMPERATURE_DAMAGE_COEFFICIENT, 0)
	return ..()

/datum/reagent/consumable/drink/cold/space_cola
	name = "Cola"
	id = "cola"
	description = "A refreshing beverage."
	reagent_state = LIQUID
	color = "#100800" // rgb: 16, 8, 0
	adj_drowsy = -10 SECONDS
	drink_icon = "glass_brown"
	drink_name = "Glass of Space Cola"
	drink_desc = "A glass of refreshing Space Cola"
	taste_description = "cola"

/datum/reagent/consumable/drink/cold/energy
	name = "Energy Drink"
	id = "energetik"
	description = "A refreshing beverage."
	reagent_state = LIQUID
	color = "#a9c725"
	adj_drowsy = -6 SECONDS
	adj_sleepy = -4 SECONDS
	adj_dizzy = -10 SECONDS
	heart_rate_increase = 1
	minor_addiction = TRUE
	overdose_threshold = 45
	addiction_chance = 1
	addiction_threshold = 200
	drink_icon = "lemonglass"
	drink_name = "Glass of Classic Energy Drink"
	drink_desc = "A glass of of invigorating energy drink"
	taste_description = "tutti frutti"

/datum/reagent/consumable/drink/cold/energy/New()
	addict_supertype = /datum/reagent/consumable/drink/cold/energy

/datum/reagent/consumable/drink/cold/energy/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustStaminaLoss(-1, FALSE)
	if(M.reagents.get_reagent_amount("coffee") > 0)
		if(prob(0.5))
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(!H.undergoing_cardiac_arrest())
					H.set_heartattack(TRUE)
	if(locate(/datum/reagent/consumable/drink/cold/energy) in (M.reagents.reagent_list - src))
		if(prob(0.5))
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(!H.undergoing_cardiac_arrest())
					H.set_heartattack(TRUE)
	return ..() | update_flags

/datum/reagent/consumable/drink/cold/energy/overdose_process(mob/living/M, severity)
	if(volume > 45)
		M.Jitter(10 SECONDS)
	return list(0, STATUS_UPDATE_NONE)

/datum/reagent/consumable/drink/cold/energy/trop
	name = "Tropickal Energy"
	id = "trop_eng"
	taste_description = "mango and coconut"

/datum/reagent/consumable/drink/cold/energy/milk
	name = "Milk Energy"
	id = "milk_eng"
	taste_description = "milk and taurin"

/datum/reagent/consumable/drink/cold/energy/grey
	name = "GreyPower Energy"
	id = "grey_eng"
	color = "#9dc2d1"
	taste_description = "robust"

/datum/reagent/consumable/drink/cold/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	description = "Cola, cola never changes."
	color = "#100800" // rgb: 16, 8, 0
	adj_sleepy = -4 SECONDS
	drink_icon = "nuka_colaglass"
	drink_name = "Nuka Cola"
	drink_desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland"
	harmless = FALSE
	taste_description = "radioactive cola"

/datum/reagent/consumable/drink/cold/nuka_cola/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Jitter(40 SECONDS)
	M.Druggy(60 SECONDS)
	M.AdjustDizzy(10 SECONDS)
	M.SetDrowsy(0)
	ADD_TRAIT(M, TRAIT_GOTTAGONOTSOFAST, id)
	return ..() | update_flags

/datum/reagent/consumable/drink/cold/nuka_cola/on_mob_delete(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_GOTTAGONOTSOFAST, id)
	..()

/datum/reagent/consumable/drink/cold/spacemountainwind
	name = "Space Mountain Wind"
	id = "spacemountainwind"
	description = "Blows right through you like a space wind."
	color = "#102000" // rgb: 16, 32, 0
	adj_drowsy = -14 SECONDS
	adj_sleepy = -2 SECONDS
	drink_icon = "Space_mountain_wind_glass"
	drink_name = "Glass of Space Mountain Wind"
	drink_desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."
	taste_description = "lime soda"

/datum/reagent/consumable/drink/cold/dr_gibb
	name = "Dr. Gibb"
	id = "dr_gibb"
	description = "A delicious blend of 42 different flavours"
	color = "#102000" // rgb: 16, 32, 0
	adj_drowsy = -12 SECONDS
	drink_icon = "dr_gibb_glass"
	drink_name = "Glass of Dr. Gibb"
	drink_desc = "Dr. Gibb. Not as dangerous as the name might imply."
	taste_description = "cherry soda"

/datum/reagent/consumable/drink/cold/space_up
	name = "Space-Up"
	id = "space_up"
	description = "Tastes like a hull breach in your mouth."
	color = "#202800" // rgb: 32, 40, 0
	adj_temp_cool = 8
	drink_icon = "space-up_glass"
	drink_name = "Glass of Space-up"
	drink_desc = "Space-up. It helps keep your cool."
	taste_description = "lemon soda"

/datum/reagent/consumable/drink/cold/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	id = "lemon_lime"
	color = "#878F00" // rgb: 135, 40, 0
	adj_temp_cool = 8
	taste_description = "citrus soda"

/datum/reagent/consumable/drink/cold/lemonade
	name = "Lemonade"
	description = "Oh the nostalgia..."
	id = "lemonade"
	color = "#FFFF00" // rgb: 255, 255, 0
	drink_icon = "lemonade"
	drink_name = "Lemonade"
	drink_desc = "Oh the nostalgia..."
	taste_description = "lemonade"

/datum/reagent/consumable/drink/cold/kiraspecial
	name = "Kira Special"
	description = "Long live the guy who everyone had mistaken for a girl. Baka!"
	id = "kiraspecial"
	color = "#CCCC99" // rgb: 204, 204, 153
	drink_icon = "kiraspecial"
	drink_name = "Kira Special"
	drink_desc = "Long live the guy who everyone had mistaken for a girl. Baka!"
	taste_description = "citrus soda"

/datum/reagent/consumable/drink/cold/brownstar
	name = "Brown Star"
	description = "It's not what it sounds like..."
	id = "brownstar"
	color = "#9F3400" // rgb: 159, 052, 000
	adj_temp_cool = 2
	drink_icon = "brownstar"
	drink_name = "Brown Star"
	drink_desc = "Its not what it sounds like..."
	taste_description = "orange soda"

/datum/reagent/consumable/drink/cold/milkshake
	name = "Milkshake"
	description = "Glorious brainfreezing mixture."
	id = "milkshake"
	color = "#AEE5E4" // rgb" 174, 229, 228
	adj_temp_cool = 9
	drink_icon = "milkshake"
	drink_name = "Milkshake"
	drink_desc = "Glorious brainfreezing mixture."
	taste_description = "milkshake"

/datum/reagent/consumable/drink/cold/rewriter
	name = "Rewriter"
	description = "The secret of the sanctuary of the Librarian..."
	id = "rewriter"
	color = "#485000" // rgb:72, 080, 0
	drink_icon = "rewriter"
	drink_name = "Rewriter"
	drink_desc = "The secret of the sanctuary of the Librarian..."
	taste_description = "coffee...soda?"

/datum/reagent/consumable/drink/cold/rewriter/on_mob_life(mob/living/M)
	M.Jitter(10 SECONDS)
	return ..()


/datum/reagent/consumable/drink/cold/zaza
	name = "Zaza"
	description = "The sharp delicious smell of cherries emanates from the drink."
	id = "zaza"
	color = "#b10023" // rgb:177, 0, 35
	drink_icon = "zaza"
	drink_name = "Zaza"
	drink_desc = "A glass filled with cherry drink, for a great Zaza Friday."
	taste_description = "delicious shugary water taste"
	var/alternate_taste_description = "something messing flavor of this juice... just sugary water taste"
	var/healamount = 0.5


/datum/reagent/consumable/drink/cold/zaza/on_mob_life(mob/living/user)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(user) && prob(40))
		update_flags |= user.adjustBruteLoss(-healamount, FALSE)
		update_flags |= user.adjustFireLoss(-healamount, FALSE)
	return ..() | update_flags


/datum/reagent/consumable/drink/cold/zaza/taste_amplification(mob/living/user)
	. = list()
	var/taste_desc = ismindshielded(user) ? alternate_taste_description : taste_description
	var/taste_amount = volume * taste_mult
	.[taste_desc] = taste_amount


/datum/reagent/consumable/drink/cold/zaza/fizzy
	description = "The sharp delicious smell of cherries emanates from the sparkling drink."
	color = "#f30028" // rgb:243, 0, 40
	id = "zazafizzy"
	drink_icon = "zaza_fizzy"
	drink_desc = "A glass filled with cherry drink, for a great Zaza Friday. Now with bubbles!"
	taste_description = "delicious fizzy water taste"
	alternate_taste_description = "something messing flavor of this drink... just fizzy water taste"
	healamount = 0.25


