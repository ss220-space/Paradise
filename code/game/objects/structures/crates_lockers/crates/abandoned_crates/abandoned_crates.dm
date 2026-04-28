/**
 * # Abandoned Crate
 *
 * A secure crate that requires a unique code to unlock. Contains randomized loot.
 *
 * This crate uses a bulls-and-cows guessing game. Incorrect attempts may cause an explosion.
 */
/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "Какой-то странный ржавый ящик... Интересно, что может быть внутри?"
	icon_state = "dangercrate"
	base_icon_state = "dangercrate"
	integrity_failure = 0 // Cannot be broken open physically
	tamperproof = 90 // High chance of explosion when tampered with
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	/// Secret code required to unlock the crate
	var/code = null
	/// List of previous attempts in format: list("attempt" = "1234", "bulls" = 1, "cows" = 2)
	var/list/previous_attempts = list()
	/// Remaining attempts to input the correct code
	var/attempts = 10
	/// Length of the generated code (number of digits)
	var/code_length = 4
	/// Whether to delete the crate after opening
	var/qdel_on_open = FALSE
	/// Whether loot has already been spawned inside the crate
	var/spawned_loot = FALSE

	/**
	 * Weighted list of possible loot items.
	 * Format: list(list(typepath = probability) = group_weight).
	 * Total probability = ((probability in sublist * group weight) / 100)
	 */
	var/static/list/possible_loot = list(
		// Alcohol and entertainment
		list(
			/obj/effect/spawner/abandoned_crate/booze = 15,
			/obj/effect/spawner/abandoned_crate/drugs = 5,
			/obj/effect/spawner/abandoned_crate/snappops = 5,
			/obj/effect/spawner/abandoned_crate/toy_balloon = 5,
			/obj/effect/spawner/abandoned_crate/toy_weapons = 8,
			/obj/effect/spawner/abandoned_crate/toy_pistols = 8,
			) = 46,

		// Tools and equipment
		list(
			/obj/effect/spawner/abandoned_crate/tools = 15,
			/obj/effect/spawner/abandoned_crate/science_equipment = 10,
			/obj/effect/spawner/abandoned_crate/electronics = 8,
			/obj/effect/spawner/abandoned_crate/mining_tools = 7,
			/obj/effect/spawner/abandoned_crate/random_components = 5,
			) = 45,

		// Valuable materials
		list(
			/obj/effect/spawner/abandoned_crate/diamonds = 8,
			/obj/effect/spawner/abandoned_crate/bluespace_crystal = 8,
			/obj/effect/spawner/abandoned_crate/cash = 5,
			/obj/effect/spawner/abandoned_crate/random_coins = 5,
			) = 26,

		// Clothes and suits
		list(
			/obj/effect/spawner/abandoned_crate/casual_clothes = 10,
			/obj/effect/spawner/abandoned_crate/funny_clothes = 8,
			/obj/effect/spawner/abandoned_crate/bedsheets = 5,
			/obj/effect/spawner/abandoned_crate/roman_armor = 5,
			/obj/effect/spawner/abandoned_crate/pet_costumes = 5,
			/obj/effect/spawner/abandoned_crate/chicken_costume = 5,
			/obj/effect/spawner/abandoned_crate/clown_kit = 4,
			/obj/effect/spawner/abandoned_crate/mime_kit = 4,
			/obj/effect/spawner/abandoned_crate/tacticool_gear = 4,
			/obj/effect/spawner/abandoned_crate/wrestling_gear = 4,
			/obj/effect/spawner/abandoned_crate/justice_kit = 3,
			/obj/effect/spawner/abandoned_crate/gentleman_kit = 3,
			/obj/effect/spawner/abandoned_crate/fursuit = 3,
			/obj/effect/spawner/abandoned_crate/space_suit = 3,
			) = 66,

		// Weapons and Security
		list(
			/obj/effect/spawner/abandoned_crate/security_gear = 12,
			/obj/effect/spawner/abandoned_crate/shotgun_kit = 8,
			/obj/effect/spawner/abandoned_crate/syndicate_gear = 8,
			/obj/effect/spawner/abandoned_crate/energy_weapons = 8,
			/obj/effect/spawner/abandoned_crate/katana = 5,
			/obj/effect/spawner/abandoned_crate/wizard_gear = 5,
			/obj/effect/spawner/abandoned_crate/bombarda = 4,
			) = 50,

		// Medicine and science
		list(
			/obj/effect/spawner/abandoned_crate/medical = 10,
			/obj/effect/spawner/abandoned_crate/organs = 8,
			/obj/effect/spawner/abandoned_crate/cybernetics = 5,
			/obj/effect/spawner/abandoned_crate/dna_injectors = 5,
			/obj/effect/spawner/abandoned_crate/weed = 5,
			) = 33,

		// Miscellaneous
		list(
			/obj/effect/spawner/abandoned_crate/posters = 8,
			/obj/effect/spawner/abandoned_crate/random_seeds = 8,
			/obj/effect/spawner/abandoned_crate/soulstone = 5,
			) = 21,
		)

/obj/structure/closet/crate/secure/loot/get_ru_names()
	return list(
		NOMINATIVE = "заброшенный ящик",
		GENITIVE = "заброшенного ящика",
		DATIVE = "заброшенному ящику",
		ACCUSATIVE = "заброшенный ящик",
		INSTRUMENTAL = "заброшенным ящиком",
		PREPOSITIONAL = "заброшенном ящике",
	)

/obj/structure/closet/crate/secure/loot/Initialize(mapload)
	. = ..()
	code = generate_code(code_length)

/// Generates a random code of specified length with no repeating digits
/obj/structure/closet/crate/secure/loot/proc/generate_code(length)
	var/list/digits = list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	var/list/code_digits = list()

	for(var/i in 1 to length)
		if(!length(digits))
			break
		var/digit = pick(digits)
		code_digits += digit
		digits -= digit //there are never matching digits in the answer

	return code_digits.Join("")

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user, list/modifiers)
	if(!locked)
		return ..()

	if(!user.can_perform_action(src))
		return

	var/input = tgui_input_text(user, title = "Дека-кодовый замок", message = "Введите [code_length] цифр[DECL_SEC_MIN(code_length)]. Все цифры должны быть уникальными.", max_length = code_length)

	if(input == code)
		if(!spawned_loot)
			spawn_loot()
		tamperproof = 0 // Set explosion chance to zero, so we dont accidently hit it with a multitool and instantly die
		togglelock(user)
		SStgui.close_user_uis(user, src)
		return

	if(!validate_input(input))
		to_chat(user, span_notice("Вы оставляете ящик в покое."))
		return

	to_chat(user, span_warning("Вспыхивает красная лампочка."))
	previous_attempts += list(bulls_and_cows(input))
	attempts--

	if(attempts <= 0)
		boom(user)

/**
 * Validates user input for code attempts
 *
 * Checks if input is the correct length, contains only digits,
 * and has no repeating digits.
 *
 * Arguments:
 * * input - The user's guess attempt
 *
 * Returns:
 * * boolean - TRUE if input is valid, FALSE otherwise
 */
/obj/structure/closet/crate/secure/loot/proc/validate_input(input)
	if(!input || code_length != length(input))
		return FALSE

	var/list/used_digits = list()
	for(var/i in 1 to length(input))
		var/char = input[i]
		if(!(char >= "0" && char <= "9")) // If a non-digit is found, reject the input
			return FALSE
		if(char in used_digits) // If a digit is repeated, reject the input
			return FALSE
		used_digits += char

	return TRUE

/obj/structure/closet/crate/secure/loot/click_alt(mob/living/user)
	attack_hand(user) //this helps you not blow up so easily by overriding unlocking which results in an immediate boom.
	return CLICK_ACTION_SUCCESS

/obj/structure/closet/crate/secure/loot/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	// Attempt to update tgui ui, open and update if needed.
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AbandonedCrate", DECLENT_RU_CAP(src, NOMINATIVE))
		ui.open()

/obj/structure/closet/crate/secure/loot/ui_data(mob/user)
	var/list/data = list()

	data["previous_attempts"] = previous_attempts
	data["attempts_left"] = attempts

	return data

/obj/structure/closet/crate/secure/loot/multitool_act(mob/living/user, obj/item/tool)
	if(!locked)
		return

	if(Adjacent(user))
		ui_interact(user)

	return TRUE

/**
 * Implements bulls and cows algorithm
 *
 * Compares the guess against the actual code.
 * Bulls = correct digit in correct position.
 * Cows = correct digit in wrong position.
 *
 * Arguments:
 * * guess - The user's guess string
 *
 * Returns:
 * * list - Contains attempt, bulls count, and cows count
 */
/obj/structure/closet/crate/secure/loot/proc/bulls_and_cows(guess)
	var/bulls = 0
	var/cows = 0

	for(var/i in 1 to code_length)
		var/guess_char = guess[i]
		var/code_char = code[i]

		if(guess_char == code_char)
			bulls++
		else if(findtext(code, guess_char))
			cows++

	return list("attempt" = guess, "bulls" = bulls, "cows" = cows)

/obj/structure/closet/crate/secure/loot/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/card/emag))
		if(locked)
			emag_act(user)
			return ATTACK_CHAIN_BLOCKED_ALL
		add_fingerprint(user)
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
	return ..()

/obj/structure/closet/crate/secure/loot/emag_act(mob/user)
	. = ..()

	if(!locked)
		return

	add_attack_logs(user, src, "emag-bombed")
	boom(user) // No feedback since it just explodes, thats its own feedback
	return TRUE

/obj/structure/closet/crate/secure/loot/togglelock(mob/user, silent = FALSE)
	if(!locked)
		. = ..() // Run the normal code.
		if(locked) // Double check if the crate actually locked itself when the normal code ran.
			// Reset the anti-tampering, number of attempts and last attempt when the lock is re-enabled.
			tamperproof = initial(tamperproof)
			attempts = initial(attempts)
			previous_attempts = list()
		return
	if(tamperproof)
		return
	return ..()

/obj/structure/closet/crate/secure/loot/deconstruct(disassembled = TRUE)
	if(locked)
		boom()
		return
	return ..()

/obj/structure/closet/crate/secure/loot/after_open(mob/living/user, force)
	. = ..()
	if(qdel_on_open)
		qdel(src)

/**
 * Spawns loot inside the crate
 *
 * Selects a random loot item from the weighted possible_loot list.
 * Marks the crate as having spawned loot.
 */
/obj/structure/closet/crate/secure/loot/proc/spawn_loot()
	var/loot = pick_weight_recursive(possible_loot)
	new loot(src)
	spawned_loot = TRUE

/obj/structure/closet/crate/secure/loot/shove_impact(mob/living/target, mob/living/attacker)
	if(locked)
		return FALSE
	return ..()

/obj/structure/closet/crate/secure/loot/can_vv_get(var_name)
	if(var_name == NAMEOF(src, code) && !check_rights(R_PERMISSIONS, FALSE))
		return FALSE
	return ..()
