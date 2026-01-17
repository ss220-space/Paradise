/// Default value for the max_complexity var on MODsuits
#define DEFAULT_MAX_COMPLEXITY 15

/// Default cell drain per process on MODsuits
#define DEFAULT_CHARGE_DRAIN 5

/// Default time for a part to seal
#define MOD_ACTIVATION_STEP_TIME (2 SECONDS)

/// Passive module, just acts when put in naturally.
#define MODULE_PASSIVE 0
/// Usable module, does something when you press a button.
#define MODULE_USABLE 1
/// Toggle module, you turn it on/off and it does stuff.
#define MODULE_TOGGLE 2
/// Actively usable module, you may only have one selected at a time.
#define MODULE_ACTIVE 3

/// This module can be used during phaseout
#define MODULE_ALLOW_PHASEOUT (1<<0)
/// This module can be used while incapacitated
#define MODULE_ALLOW_INCAPACITATED (1<<1)
/// This module can be used while the suit is off
#define MODULE_ALLOW_INACTIVE (1<<2)
/// This module can be used (by button) while the suit is unworn
#define MODULE_ALLOW_UNWORN (1<<3)

//Defines used by the theme for clothing flags and similar
#define CONTROL_LAYER "control_layer"
#define HELMET_FLAGS "helmet_flags"
#define CHESTPLATE_FLAGS "chestplate_flags"
#define GAUNTLETS_FLAGS "gauntlets_flags"
#define BOOTS_FLAGS "boots_flags"

#define UNSEALED_LAYER "unsealed_layer"
#define UNSEALED_CLOTHING "unsealed_clothing"
#define SEALED_CLOTHING "sealed_clothing"
#define UNSEALED_INVISIBILITY "unsealed_invisibility"
#define SEALED_INVISIBILITY "sealed_invisibility"
#define UNSEALED_COVER "unsealed_cover"
#define SEALED_COVER "sealed_cover"
#define CAN_OVERSLOT "can_overslot"
#define UNSEALED_MESSAGE "unsealed_message"
#define SEALED_MESSAGE "sealed_message"

//Default text for different messages for the user.
#define HELMET_UNSEAL_MESSAGE "открывается с характерным скрипом"
#define HELMET_SEAL_MESSAGE "закрывается с характерным скрипом"
#define CHESTPLATE_UNSEAL_MESSAGE "освобождает ваше тело"
#define CHESTPLATE_SEAL_MESSAGE "плотно облегает ваше тело"
#define GAUNTLET_UNSEAL_MESSAGE "ослабляют свою хватку на ваших руках"
#define GAUNTLET_SEAL_MESSAGE "сжимаются на ваших руках"
#define BOOT_UNSEAL_MESSAGE "ослабляют свою хватку на ваших ногах"
#define BOOT_SEAL_MESSAGE "плотно обхватывают ваши ноги"

//Defines used to override MOD clothing's icon and worn icon files in the skin.
#define MOD_ICON_OVERRIDE "mod_icon_override"
#define MOD_WORN_ICON_OVERRIDE "mod_worn_icon_override"

/// How likely the UI is to fail when malfunctioning
#define MOD_MALFUNCTION_PROB 75

/// all theme defines
#define MOD_VARIANT_STANDART "standard"
#define MOD_VARIANT_CIVILIAN "civilian"
#define MOD_VARIANT_ENGINEERING "engineering"
#define MOD_VARIANT_ATMOSPHERIC "atmospheric"
#define MOD_VARIANT_ADVANCED "advanced"
#define MOD_VARIANT_MINING "mining"
#define MOD_VARIANT_ASTEROID "asteroid"
#define MOD_VARIANT_LOADER "loader"
#define MOD_VARIANT_MEDICAL "medical"
#define MOD_VARIANT_CORPSMAN "corpsman"
#define MOD_VARIANT_RESCUE "rescue"
#define MOD_VARIANT_RESEARCH "research"
#define MOD_VARIANT_SECURITY "security"
#define MOD_VARIANT_BRIGPILOT "brigpilot"
#define MOD_VARIANT_SAFEGUARD_WARDEN "safeguard-ward"
#define MOD_VARIANT_SAFEGUARD "safeguard"
#define MOD_VARIANT_BRIGMED "security-med"
#define MOD_VARIANT_MAGNATE "magnate"
#define MOD_VARIANT_PRAETORIAN "praetorian"
#define MOD_VARIANT_COSMOHONK "cosmohonk"
#define MOD_VARIANT_SYNDICATE "syndicate"
#define MOD_VARIANT_HONKERATIVE "honkerative"
#define MOD_VARIANT_ELITE "elite"
#define MOD_VARIANT_CONTRACTOR "contractor"
#define MOD_VARIANT_PROTOTYPE "prototype"
#define MOD_VARIANT_RESPONSORY "responsory"
#define MOD_VARIANT_INQUISITORY "inquisitory"
#define MOD_VARIANT_APOCRYPHAL "apocryphal"
#define MOD_VARIANT_CORPORATE "corporate"
#define MOD_VARIANT_DEBUG "debug"
