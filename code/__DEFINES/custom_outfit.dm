#define CUSTOM_OUTFIT_DEFAULT_NAME "Custom Outfit"
#define CUSTOM_OUTFIT_LIMB_STATUS_AMPUTATED "amputated"
#define CUSTOM_OUTFIT_LIMB_STATUS_PROSTHETIC "prosthetic"
#define CUSTOM_OUTFIT_LIMB_STATUS_AUGMENTED "augmented"
#define CUSTOM_OUTFIT_MAX_REAGENT_AMOUNT 100
#define CUSTOM_OUTFIT_MAX_ITEM_COUNT 100

#define CUSTOM_OUTFIT_CONTAINER_BACKPACK "backpack"
#define CUSTOM_OUTFIT_CONTAINER_BELT "belt"

// ispath-based type check helpers
#define CUSTOM_OUTFIT_IS_ITEM_PATH(path) ispath(path, /obj/item)
#define CUSTOM_OUTFIT_IS_STORAGE_PATH(path) ispath(path, /obj/item/storage)
#define CUSTOM_OUTFIT_IS_INTERNAL_ORGAN_PATH(path) ispath(path, /obj/item/organ/internal)
#define CUSTOM_OUTFIT_IS_MOD_CONTROL_PATH(path) ispath(path, /obj/item/mod/control)
#define CUSTOM_OUTFIT_IS_SKILL_PATH(path) ispath(path, /datum/skill)
#define CUSTOM_OUTFIT_IS_REAGENT_PATH(path) ispath(path, /datum/reagent)
#define CUSTOM_OUTFIT_IS_ID_CARD_PATH(path) ispath(path, /obj/item/card/id)
#define CUSTOM_OUTFIT_IS_CLOTHING_PATH(path) ispath(path, /obj/item/clothing)
#define CUSTOM_OUTFIT_IS_HARDSUIT_HELMET_PATH(path) ispath(path, /obj/item/clothing/head/helmet/space/hardsuit)
#define CUSTOM_OUTFIT_IS_VALID_ITEM_ENTRY(path, count) (CUSTOM_OUTFIT_IS_ITEM_PATH(path) && isnum(count) && (count) > 0)
#define CUSTOM_OUTFIT_IS_VALID_SKILL_LEVEL(path, level) (CUSTOM_OUTFIT_IS_SKILL_PATH(path) && isnum(level))
#define CUSTOM_OUTFIT_IS_VALID_REAGENT_VOLUME(path, amount) (CUSTOM_OUTFIT_IS_REAGENT_PATH(path) && isnum(amount) && (amount) > 0)
