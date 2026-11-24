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
	var/list/stamp_files = list(
		"stamp-clown" = 'icons/misc/paper_icons/large_stamp-clown.png',
		"stamp-deny" = 'icons/misc/paper_icons/large_stamp-deny.png',
		"stamp-ok" = 'icons/misc/paper_icons/large_stamp-ok.png',
		"stamp-hop" = 'icons/misc/paper_icons/large_stamp-hop.png',
		"stamp-cmo" = 'icons/misc/paper_icons/large_stamp-cmo.png',
		"stamp-ce" = 'icons/misc/paper_icons/large_stamp-ce.png',
		"stamp-hos" = 'icons/misc/paper_icons/large_stamp-hos.png',
		"stamp-rd" = 'icons/misc/paper_icons/large_stamp-rd.png',
		"stamp-cap" = 'icons/misc/paper_icons/large_stamp-cap.png',
		"stamp-qm" = 'icons/misc/paper_icons/large_stamp-qm.png',
		"stamp-law" = 'icons/misc/paper_icons/large_stamp-law.png',
		"stamp-cent" = 'icons/misc/paper_icons/large_stamp-cent.png',
		"stamp-syndicate" = 'icons/misc/paper_icons/large_stamp-syndicate.png',
		"stamp-taipan" = 'icons/misc/paper_icons/large_stamp-taipan.png',
		"stamp-rep" = 'icons/misc/paper_icons/large_stamp-rep.png',
		"stamp-magistrate" = 'icons/misc/paper_icons/large_stamp-magistrate.png',
		"stamp-ward" = 'icons/misc/paper_icons/large_stamp-ward.png',
		"stamp-mime" = 'icons/misc/paper_icons/large_stamp-mime.png',
		"stamp-ploho" = 'icons/misc/paper_icons/large_stamp-ploho.png',
		"stamp-BIGdeny" = 'icons/misc/paper_icons/large_stamp-BIGdeny.png',
		"stamp-navcom" = 'icons/misc/paper_icons/large_stamp-navcom.png',
		"stamp-ussp" = 'icons/misc/paper_icons/large_stamp-ussp.png',
		"stamp-solgov" = 'icons/misc/paper_icons/large_stamp-solgov.png',
	)
	for(var/stamp_key in stamp_files)
		insert_icon(stamp_key, uni_icon(stamp_files[stamp_key], ""))
