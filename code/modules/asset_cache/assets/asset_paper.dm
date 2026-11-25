// Contains 256x128 versions of various in game company logos
/datum/asset/simple/logos
	assets = list(
		"ussplogo.png" = 'icons/misc/paper_icons/ussplogo.png',
		"solgovlogo.png" = 'icons/misc/paper_icons/solgovlogo.png',
		"thieflogo.png" = 'icons/misc/paper_icons/thieflogo.png',
		"syndielogo.png" = 'icons/misc/paper_icons/syndielogo.png',
		"ntlogo.png" = 'icons/misc/paper_icons/ntlogo.png',
		"talisman.png" = 'icons/misc/paper_icons/talisman.png',
	)

/datum/asset/spritesheet_batched/stamps
	name = "stamps"

/datum/asset/spritesheet_batched/stamps/create_spritesheets()
	var/icon/stamp_dmi = 'icons/misc/paper_icons/paper_stamps.dmi'
	for(var/state in icon_states(stamp_dmi))
		insert_icon(state, uni_icon(stamp_dmi, state))
