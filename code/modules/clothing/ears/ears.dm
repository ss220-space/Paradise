/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	slot_flags = ITEM_SLOT_EARS
	slot_flags_2 = ITEM_FLAG_TWOEARS
	item_flags = BANGPROTECT_TOTAL|HEALS_EARS
	strip_delay = 15
	put_on_delay = 25
	resistance_flags = FLAMMABLE

/obj/item/clothing/ears/earrings
	name = "Earrings"
	desc = "Простые золотые серёжки"
	icon_state = "earring_gold"
	item_state = "earring_gold"
	slot_flags = ITEM_SLOT_EARS
	species_restricted = list(SPECIES_HUMAN, SPECIES_VOX, SPECIES_VULPKANIN, SPECIES_TAJARAN, SPECIES_DIONA, SPECIES_DRASK, SPECIES_SLIMEPERSON, SPECIES_SKRELL, SPECIES_MACNINEPERSON, SPECIES_MOTH, SPECIES_NUCLEATION)

/obj/item/clothing/ears/earrings/Nt
	name = "Earrings NT"
	desc = "Золотые серьги с гравировкой НТ"
	icon_state = "earring_NT"
	item_state = "earring_NT"

/obj/item/clothing/ears/earrings/silver
	name = "Silver earings"
	desc = "Простые серебряные серьги"
	icon_state = "earring_silver"
	item_state = "earring_silver"
