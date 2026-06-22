/obj/item/clothing/glasses/meson/cyber/vox
	name = "meson vox eye"
	desc = "Мезонный кибернетический глаз с системой вставки в глазной разъем. Полностью заменяет функционирующий глаз или его полость. \
			ВНИМАНИЕ! Глаз возможно удалить только хирургическим путем. Из-за своего размера — не позволяет надевать прочие приблуды на глаза, заменяя очки."

/obj/item/clothing/glasses/meson/cyber/vox/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_EYES)
		ADD_TRAIT(src, TRAIT_NODROP, UNIQUE_TRAIT_SOURCE(src))
	else
		REMOVE_TRAIT(src, TRAIT_NODROP, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/glasses/thermal/cyber/vox
	name = "thermal vox eye"
	desc = "Термальный кибернетический глаз с системой вставки в глазной разъем. Полностью заменяет функционирующий глаз или его полость. \
			ВНИМАНИЕ! Глаз возможно удалить только хирургическим путем. Из-за своего размера — не позволяет надевать прочие приблуды на глаза, заменяя очки."

/obj/item/clothing/glasses/thermal/cyber/vox/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_EYES)
		ADD_TRAIT(src, TRAIT_NODROP, UNIQUE_TRAIT_SOURCE(src))
	else
		REMOVE_TRAIT(src, TRAIT_NODROP, UNIQUE_TRAIT_SOURCE(src))

