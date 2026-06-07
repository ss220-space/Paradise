/**
 * Datums for coffee cartridges
 */

/datum/coffee_cartridge_type
	/// Unique identifier for the cartridge type
	var/id
	/// Name in English
	var/name_en
	/// Embeddable Russian name (used at the end of each case)
	var/ru_name_base
	/// Icon state for the cartridge
	var/icon_state

/datum/coffee_cartridge_type/New()
	. = ..()
	if(!id || !name_en || !ru_name_base || !icon_state)
		CRASH("Coffee cartridge type [type] created without required vars.")

// MARK: Premium cartridge types

/datum/coffee_cartridge_type/blend
	id = "blend"
	name_en = "Miscela di Piccione"
	ru_name_base = "Миццела Де Пиччионе"
	icon_state = "cartridge_blend"

/datum/coffee_cartridge_type/blue_mountain
	id = "blue_mountain"
	name_en = "Montagna Blu"
	ru_name_base = "Монтанна Блю"
	icon_state = "cartridge_blue_mtn"

/datum/coffee_cartridge_type/kilimanjaro
	id = "kilimanjaro"
	name_en = "Kilimangiaro"
	ru_name_base = "Килиманджаро"
	icon_state = "cartridge_kilimanjaro"

/datum/coffee_cartridge_type/mocha
	id = "mocha"
	name_en = "Moka Arabica"
	ru_name_base = "Моккачино Арабика"
	icon_state = "cartridge_mocha"
