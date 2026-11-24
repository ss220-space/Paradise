/datum/asset/simple/paper
	assets = list(
		"large_stamp-clown.png" = 'icons/misc/paper_icons/large_stamp-clown.png',
		"large_stamp-deny.png" = 'icons/misc/paper_icons/large_stamp-deny.png',
		"large_stamp-ok.png" = 'icons/misc/paper_icons/large_stamp-ok.png',
		"large_stamp-hop.png" = 'icons/misc/paper_icons/large_stamp-hop.png',
		"large_stamp-cmo.png" = 'icons/misc/paper_icons/large_stamp-cmo.png',
		"large_stamp-ce.png" = 'icons/misc/paper_icons/large_stamp-ce.png',
		"large_stamp-hos.png" = 'icons/misc/paper_icons/large_stamp-hos.png',
		"large_stamp-rd.png" = 'icons/misc/paper_icons/large_stamp-rd.png',
		"large_stamp-cap.png" = 'icons/misc/paper_icons/large_stamp-cap.png',
		"large_stamp-qm.png" = 'icons/misc/paper_icons/large_stamp-qm.png',
		"large_stamp-law.png" = 'icons/misc/paper_icons/large_stamp-law.png',
		"large_stamp-cent.png" = 'icons/misc/paper_icons/large_stamp-cent.png',
		"large_stamp-syndicate.png" = 'icons/misc/paper_icons/large_stamp-syndicate.png',
		"large_stamp-taipan.png" = 'icons/misc/paper_icons/large_stamp-taipan.png',
		"large_stamp-rep.png" = 'icons/misc/paper_icons/large_stamp-rep.png',
		"large_stamp-magistrate.png" = 'icons/misc/paper_icons/large_stamp-magistrate.png',
		"large_stamp-ward.png" = 'icons/misc/paper_icons/large_stamp-ward.png',
		"large_stamp-mime.png" = 'icons/misc/paper_icons/large_stamp-mime.png',
		"large_stamp-ploho.png" = 'icons/misc/paper_icons/large_stamp-ploho.png',
		"large_stamp-BIGdeny.png" = 'icons/misc/paper_icons/large_stamp-BIGdeny.png',
		"large_stamp-navcom.png" = 'icons/misc/paper_icons/large_stamp-navcom.png',
		"large_stamp-ussp.png" = 'icons/misc/paper_icons/large_stamp-ussp.png',
		"large_stamp-solgov.png" = 'icons/misc/paper_icons/large_stamp-solgov.png',
	)

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
