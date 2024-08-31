
/obj/item/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	bitesize = 6
	list_reagents = list("protein" = 3, "carpotoxin" = 2, "vitamin" = 2)
	tastes = list("white fish" = 1)
	foodtype = MEAT | TOXIC
	log_eating = TRUE

/obj/item/reagent_containers/food/snacks/salmonmeat
	name = "raw salmon"
	desc = "A fillet of raw salmon."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	bitesize = 6
	list_reagents = list("protein" = 3, "vitamin" = 2)
	tastes = list("raw salmon" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/salmonmeat/snailmeat
	name = "snail meat"
	desc = "Сырая космо-улитка в собственном соку."
	filling_color = "#6bb4a8"
	list_reagents = list("protein" = 5, "vitamin" = 5)

/obj/item/reagent_containers/food/snacks/salmonmeat/turtlemeat
	name = "snail meat"
	desc = "Сырая космо-улитка в собственном соку."
	filling_color = "#2fa24c"
	list_reagents = list("protein" = 10, "vitamin" = 8)

/obj/item/reagent_containers/food/snacks/salmonsteak
	name = "salmon steak"
	desc = "A fillet of freshly-grilled salmon meat."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "salmonsteak"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 3
	list_reagents = list("nutriment" = 4, "vitamin" = 2)
	tastes = list("cooked salmon" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/catfishmeat
	name = "raw catfish"
	desc = "A fillet of raw catfish."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	bitesize = 6
	list_reagents = list("protein" = 3, "vitamin" = 2)
	tastes = list("catfish" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishfingers"
	filling_color = "#FFDEFE"
	bitesize = 1
	list_reagents = list("nutriment" = 4)
	tastes = list("fish" = 1, "bread" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/fishburger
	name = "Fillet-O-Carp sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishburger"
	filling_color = "#FFDEFE"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "fish" = 4)
	foodtype = MEAT | GRAIN

/obj/item/reagent_containers/food/snacks/cubancarp
	name = "cuban carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	filling_color = "#E9ADFF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "capsaicin" = 1)
	tastes = list("fish" = 4, "batter" = 1, "hot peppers" = 1)
	foodtype = MEAT | GRAIN

/obj/item/reagent_containers/food/snacks/fishandchips
	name = "fish and chips"
	desc = "I do say so myself old chap. Indubitably!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishandchips"
	filling_color = "#E3D796"
	bitesize = 3
	list_reagents = list("nutriment" = 6)
	tastes = list("fish" = 1, "chips" = 1)
	foodtype = MEAT | GRAIN | FRIED

/obj/item/reagent_containers/food/snacks/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sashimi"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "capsaicin" = 5)
	tastes = list("raw carp" = 1, "hot peppers" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/fried_shrimp
	name = "fried shrimp"
	desc = "Just one of the many things you can do with shrimp!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimp_fried"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("shrimp" = 1, "bread crumbs" = 1)
	foodtype = MEAT | FRIED

/obj/item/reagent_containers/food/snacks/boiled_shrimp
	name = "boiled shrimp"
	desc = "Just one of the many things you can do with shrimp!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimp_cooked"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("shrimp" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/shrimp_skewer
	name = "shrimp skewer"
	desc = "Four shrimp lightly grilled on a skewer. Yummy!"
	trash = /obj/item/stack/rods
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimpskewer"
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("shrimp" = 4)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/fish_skewer
	name = "fish skewer"
	desc = "A whole fish battered and grilled on a skewer. Hope you're hungry!"
	trash = /obj/item/stack/rods
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishskewer"
	bitesize = 3
	list_reagents = list("protein" = 6, "vitamin" = 4)
	tastes = list("shrimp" = 1, "batter" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/sliceable/Ebi_maki
	name = "ebi maki roll"
	desc = "A large unsliced roll of Ebi Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Ebi_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Ebi
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("shrimp" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/sushi_Ebi
	name = "ebi sushi"
	desc = "A simple sushi consisting of cooked shrimp and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Ebi"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("shrimp" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/sliceable/Ikura_maki
	name = "ikura maki roll"
	desc = "A large unsliced roll of Ikura Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Ikura_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Ikura
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8, "protein" = 4)
	tastes = list("salmon roe" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = EGG

/obj/item/reagent_containers/food/snacks/sushi_Ikura
	name = "ikura sushi"
	desc = "A simple sushi consisting of salmon roe."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Ikura"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 1)
	tastes = list("salmon roe" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = EGG

/obj/item/reagent_containers/food/snacks/sliceable/Sake_maki
	name = "sake maki roll"
	desc = "A large unsliced roll of Sake Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Sake_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Sake
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("raw salmon" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/sushi_Sake
	name = "sake sushi"
	desc = "A simple sushi consisting of raw salmon and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Sake"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("raw salmon" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/sliceable/SmokedSalmon_maki
	name = "smoked salmon maki roll"
	desc = "A large unsliced roll of Smoked Salmon Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "SmokedSalmon_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_SmokedSalmon
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("smoked salmon" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/sushi_SmokedSalmon
	name = "smoked salmon sushi"
	desc = "A simple sushi consisting of cooked salmon and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_SmokedSalmon"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("smoked salmon" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/sliceable/Tamago_maki
	name = "tamago maki roll"
	desc = "A large unsliced roll of Tamago Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Tamago_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Tamago
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("egg" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/sushi_Tamago
	name = "tamago sushi"
	desc = "A simple sushi consisting of egg and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Tamago"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("egg" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/sliceable/Inari_maki
	name = "inari maki roll"
	desc = "A large unsliced roll of Inari Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Inari_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Inari
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("fried tofu" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/sushi_Inari
	name = "inari sushi"
	desc = "A piece of fried tofu stuffed with rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Inari"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("fried tofu" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/sliceable/Masago_maki
	name = "masago maki roll"
	desc = "A large unsliced roll of Masago Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Masago_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Masago
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8, "protein" = 4)
	tastes = list("goldfish roe" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = EGG

/obj/item/reagent_containers/food/snacks/sushi_Masago
	name = "masago sushi"
	desc = "A simple sushi consisting of goldfish roe."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Masago"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 1)
	tastes = list("goldfish roe" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = EGG

/obj/item/reagent_containers/food/snacks/sliceable/Tobiko_maki
	name = "tobiko maki roll"
	desc = "A large unsliced roll of Tobkio Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Tobiko_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Tobiko
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8, "protein" = 4)
	tastes = list("shark roe" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = EGG

/obj/item/reagent_containers/food/snacks/sushi_Tobiko
	name = "tobiko sushi"
	desc = "A simple sushi consisting of shark roe."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Masago"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 1)
	tastes = list("shark roe" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = EGG

/obj/item/reagent_containers/food/snacks/sliceable/TobikoEgg_maki
	name = "tobiko and egg maki roll"
	desc = "A large unsliced roll of Tobkio and Egg Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "TobikoEgg_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_TobikoEgg
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8, "protein" = 4)
	tastes = list("shark roe" = 1, "rice" = 1, "egg" = 1, "seaweed" = 1)
	foodtype = EGG

/obj/item/reagent_containers/food/snacks/sushi_TobikoEgg
	name = "tobiko and egg sushi"
	desc = "A sushi consisting of shark roe and an egg."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_TobikoEgg"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 1)
	tastes = list("shark roe" = 1, "rice" = 1, "egg" = 1, "seaweed" = 1)
	foodtype = EGG

/obj/item/reagent_containers/food/snacks/sliceable/Tai_maki
	name = "tai maki roll"
	desc = "A large unsliced roll of Tai Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Tai_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Tai
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("catfish" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/sushi_Tai
	name = "tai sushi"
	desc = "A simple sushi consisting of catfish and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Tai"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("catfish" = 1, "rice" = 1, "seaweed" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/sushi_Unagi
	name = "unagi sushi"
	desc = "A simple sushi consisting of eel and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Hokki"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("grilled eel" = 1, "seaweed" = 1)
	foodtype = MEAT


/obj/item/reagent_containers/food/snacks/crayfish_raw_small
	name = "small raw crayfish"
	desc = "A raw crayfish of a small size."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state  = "crayfish_raw_small"
	item_state = "crayfish_raw"
	filling_color = "#2e2b2eff"
	bitesize = 0.2	// its pretty hard to peel a crayfish, requires a lot of finess!
	list_reagents = list("protein" = 1.5, "vitamin" = 1)
	tastes = list("raw crayfish" = 1)
	foodtype = MEAT|RAW


/obj/item/reagent_containers/food/snacks/crayfish_raw
	name = "raw crayfish"
	desc = "A standard sized raw crayfish. Its eyes look ominous as it clicks its pincers."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "crayfish_raw"
	item_state = "crayfish_raw"
	filling_color = "#2e2b2eff"
	bitesize = 0.3
	list_reagents = list("protein" = 3, "vitamin" = 2)
	tastes = list("raw crayfish" = 1)
	foodtype = MEAT|RAW
	///Cooldown timestamp for pinching.
	COOLDOWN_DECLARE(pinch_cooldown)


/obj/item/reagent_containers/food/snacks/crayfish_raw/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!COOLDOWN_FINISHED(src, pinch_cooldown))
		return ..()

	. = ATTACK_CHAIN_PROCEED_SUCCESS
	COOLDOWN_START(src, pinch_cooldown, 5 SECONDS)

	user.do_attack_animation(target)

	target.visible_message(
		span_warning("Crayfish furiously claws at [target], while [target.p_they()] tried to eat it!"),
		span_warning("Crayfish furiously claws at you, preventing the bite!"),
	)

	playsound(target, 'sound/items/wirecutter.ogg', 100, TRUE)

	if(target.has_pain())
		target.emote("scream")

	target.apply_damage(5, BRUTE, def_zone)


/obj/item/reagent_containers/food/snacks/crayfish_cooked_small
	name = "cooked small crayfish"
	desc = "Boiled crayfish, aromatic and well seasoned... But wheres the beer?"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "crayfish_cooked_small"
	item_state = "crayfish_cooked"
	filling_color = "#751717"
	bitesize = 0.4	// but cooked one is easier!
	list_reagents = list("nutriment" = 2, "vitamin" = 1)
	tastes = list("crayfish" = 1)
	foodtype = MEAT


/obj/item/reagent_containers/food/snacks/crayfish_cooked_small/mr_chang
	name = "spicy small lobster"
	desc = "Wait, thats not a lobster! But still tasty dish with a special Mr.Chang's ingredient."
	list_reagents = list("nutriment" = 1, "msg" = 2, "sugar" = 1)
	foodtype = MEAT|FRIED


/obj/item/reagent_containers/food/snacks/crayfish_cooked
	name = "cooked crayfish"
	desc = "Boiled crayfish, aromatic and well seasoned... But wheres the beer?"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "crayfish_cooked"
	item_state = "crayfish_cooked"
	filling_color = "#751717"
	bitesize = 0.5
	list_reagents = list("nutriment" = 4, "vitamin" = 2)
	tastes = list("crayfish" = 1)
	foodtype = MEAT


/obj/item/reagent_containers/food/snacks/crayfish_cooked/mr_chang
	name = "spicy lobster"
	desc = "Wait, thats not a lobster! But still tasty dish with a special Mr.Chang's ingredient."
	list_reagents = list("nutriment" = 2, "msg" = 4, "sugar" = 2)
	foodtype = MEAT|FRIED

