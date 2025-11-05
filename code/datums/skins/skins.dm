/datum/item_skin_data
	/// Skin applyed item path
	var/item_path
	/// Name of skin (shown on radial menu)
	var/name
	/// Skin icon dmi (if null - use default item dmi)
	var/icon = null
	/// Skin icon_state
	var/icon_state
	/// Icon for radial menu (if null - use icon_state)
	var/menu_icon_state = null
	/// Minimal donater tier (0 for allow all players)
	var/donation_tier = 0


//MARK: Security baton
/datum/item_skin_data/security_baton
	item_path = /obj/item/melee/baton/security

/datum/item_skin_data/security_baton/standart
	name = "Стандартный"
	icon_state = "stunbaton"
	donation_tier = 1

/datum/item_skin_data/security_baton/classic
	name = "Классический"
	icon_state = "stunbaton_tg"
	donation_tier = 1

/datum/item_skin_data/security_baton/future
	name = "Футуристический"
	icon_state = "desolate_baton"
	donation_tier = 2

//MARK: Telescopic baton
/datum/item_skin_data/telescopic_baton
	item_path = /obj/item/melee/baton/telescopic

/datum/item_skin_data/telescopic_baton/classic
	name = "Классическая телескопическая дубинка"
	icon_state = "telebaton_tg"
	menu_icon_state = "telebaton_tg_on"
	donation_tier = 1

/datum/item_skin_data/telescopic_baton/bronze
	name = "Бронзовая телескопическая дубинка"
	icon_state = "telebaton_bronze"
	menu_icon_state = "telebaton_bronze_on"
	donation_tier = 1

/datum/item_skin_data/telescopic_baton/bronze_classic
	name = "Классическая бронзовая телескопическая дубинка"
	icon_state = "telebaton_tg_bronze"
	menu_icon_state = "telebaton_tg_bronze_on"
	donation_tier = 1

/datum/item_skin_data/telescopic_baton/silver
	name = "Серебрянная телескопическая дубинка"
	icon_state = "telebaton_silver"
	menu_icon_state = "telebaton_silver_on"
	donation_tier = 2

/datum/item_skin_data/telescopic_baton/silver_classic
	name = "Классическая серебрянная телескопическая дубинка"
	icon_state = "telebaton_tg_silver"
	menu_icon_state = "telebaton_tg_silver_on"
	donation_tier = 2

/datum/item_skin_data/telescopic_baton/gold
	name = "Золотая телескопическая дубинка"
	icon_state = "telebaton_gold"
	menu_icon_state = "telebaton_gold_on"
	donation_tier = 3

/datum/item_skin_data/telescopic_baton/gold_classic
	name = "Классическая золотая телескопическая дубинка"
	icon_state = "telebaton_tg_gold"
	menu_icon_state = "telebaton_tg_gold_on"
	donation_tier = 3

//MARK: Captain laser
/datum/item_skin_data/captain_laser
	item_path = /obj/item/gun/energy/laser/captain

/datum/item_skin_data/captain_laser/original
	name = "The Original"
	icon_state = "caplaser"

/datum/item_skin_data/captain_laser/restored
	name = "Restored"
	icon_state = "caplaser_new"

/datum/item_skin_data/captain_laser/alternative
	name = "Alternative"
	icon_state = "caplaser_newer"

//MARK: Specter
/datum/item_skin_data/specter
	item_path = /obj/item/gun/energy/specter

/datum/item_skin_data/specter/grey_slide
	name = "Grey slide"
	icon_state = "specter"

/datum/item_skin_data/specter/red_slide
	name = "Red slide"
	icon_state = "specter_red"

/datum/item_skin_data/specter/green_slide
	name = "Green slide"
	icon_state = "specter_green"

/datum/item_skin_data/specter/tan_slide
	name = "Tan slide"
	icon_state = "specter_tan"

/datum/item_skin_data/specter/green_handle
	name = "Green Handle"
	icon_state = "specter_greengrip"

/datum/item_skin_data/specter/tan_handle
	name = "Tan Handle"
	icon_state = "specter_tangrip"

/datum/item_skin_data/specter/red_handle
	name = "Red Handle"
	icon_state = "specter_redgrip"

//MARK: Enforcer
/datum/item_skin_data/enforcer
	item_path = /obj/item/gun/projectile/automatic/pistol/enforcer

/datum/item_skin_data/enforcer/grey_slide
	name = "Grey slide"
	icon_state = "enforcer_grey"

/datum/item_skin_data/enforcer/red_slide
	name = "Red slide"
	icon_state = "enforcer_red"

/datum/item_skin_data/enforcer/green_slide
	name = "Green slide"
	icon_state = "enforcer_green"

/datum/item_skin_data/enforcer/tan_slide
	name = "Tan slide"
	icon_state = "enforcer_tan"

/datum/item_skin_data/enforcer/black_slide
	name = "Black slide"
	icon_state = "enforcer_black"

/datum/item_skin_data/enforcer/green_handle
	name = "Green Handle"
	icon_state = "enforcer_greengrip"

/datum/item_skin_data/enforcer/tan_handle
	name = "Tan Handle"
	icon_state = "enforcer_tangrip"

/datum/item_skin_data/enforcer/red_handle
	name = "Red Handle"
	icon_state = "enforcer_redgrip"

//MARK: SP-8
/datum/item_skin_data/sp8
	item_path = /obj/item/gun/projectile/automatic/pistol/sp8

/datum/item_skin_data/sp8/black
	name = "Black"
	icon_state = "sp8_black"

/datum/item_skin_data/sp8/red
	name = "Red"
	icon_state = "sp8_red"

/datum/item_skin_data/sp8/green
	name = "Green"
	icon_state = "sp8_green"

/datum/item_skin_data/sp8/olive
	name = "Olive"
	icon_state = "sp8_olive"

/datum/item_skin_data/sp8/yellow
	name = "Yellow"
	icon_state = "sp8_yellow"

/datum/item_skin_data/sp8/white
	name = "White"
	icon_state = "sp8_white"

//MARK: SP-8T
/datum/item_skin_data/sp8t
	item_path = /obj/item/gun/projectile/automatic/pistol/sp8/sp8t

/datum/item_skin_data/sp8t/dust
	name = "Dust"
	icon_state = "sp8t_dust"

/datum/item_skin_data/sp8t/sea
	name = "Sea"
	icon_state = "sp8t_sea"

//MARK: Detective revolver
/datum/item_skin_data/detective_revolver
	item_path = /obj/item/gun/projectile/revolver/detective

/datum/item_skin_data/detective_revolver/original
	name = "The Original"
	icon_state = "detective"

/datum/item_skin_data/detective_revolver/leopard_sport
	name = "Leopard Spots"
	icon_state = "detective_leopard"

/datum/item_skin_data/detective_revolver/black_panther
	name = "Black Panther"
	icon_state = "detective_panther"

/datum/item_skin_data/detective_revolver/white_gold
	name = "White Gold"
	icon_state = "detective_gold"

/datum/item_skin_data/detective_revolver/gold_wood
	name = "Gold Wood"
	icon_state = "detective_gold_alt"

/datum/item_skin_data/detective_revolver/peacemaker
	name = "The Peacemaker"
	icon_state = "detective_peacemaker"

/datum/item_skin_data/detective_revolver/silver
	name = "Silver"
	icon_state = "detective_silver"

//MARK: Double barrel
/datum/item_skin_data/doublebarrel
	item_path = /obj/item/gun/projectile/revolver/doublebarrel

/datum/item_skin_data/doublebarrel/default
	name = "Default"
	icon_state = "dshotgun"

/datum/item_skin_data/doublebarrel/dark_red
	name = "Dark Red Finish"
	icon_state = "dshotgun-d"

/datum/item_skin_data/doublebarrel/ash
	name = "Ash"
	icon_state = "dshotgun-f"

/datum/item_skin_data/doublebarrel/fadded_grey
	name = "Faded Grey"
	icon_state = "dshotgun-g"

/datum/item_skin_data/doublebarrel/maple
	name = "Maple"
	icon_state = "dshotgun-l"

/datum/item_skin_data/doublebarrel/rosewood
	name = "Rosewood"
	icon_state = "dshotgun-p"
