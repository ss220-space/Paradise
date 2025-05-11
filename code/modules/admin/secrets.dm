/datum/admins
	var/current_tab =0

/datum/admins/proc/Secrets()


	if(!check_rights(0))	return
	var/dat = {"<center>"}

	dat += "<a href='byond://?src=[UID()];secretsmenu=tab;tab=0' [current_tab == 0 ? "class='linkOn'" : ""]>Debug</a>"
	dat += "<a href='byond://?src=[UID()];secretsmenu=tab;tab=1' [current_tab == 1 ? "class='linkOn'" : ""]>IC Events</a>"
	dat += "<a href='byond://?src=[UID()];secretsmenu=tab;tab=2' [current_tab == 2 ? "class='linkOn'" : ""]>OOC Events</a>"

	dat += "</center>"
	dat += "<hr>"
	switch(current_tab)
		if(0) // Debug
			if(check_rights(R_ADMIN,0))
				dat += {"
						<center><b><h2>Admin Secrets</h2></b>
						<b>Game</b><br>
						<a href='byond://?src=[UID()];secretsadmin=showailaws'>Show AI Laws</a>&nbsp;&nbsp;
						<a href='byond://?src=[UID()];secretsadmin=manifest'>Show Crew Manifest</a><br>
						<a href='byond://?src=[UID()];secretsadmin=view_codewords'>Show code phrases and responses</a><br>
						<a href='byond://?src=[UID()];secretsadmin=night_shift_set'>Set Night Shift Mode</a><br>
						<b>Bombs</b><br>
						[check_rights(R_SERVER, 0) ? "&nbsp;&nbsp;<a href='byond://?src=[UID()];secretsfun=togglebombcap'>Toggle bomb cap</a><br>" : "<br>"]
						<b>Lists</b><br>
						<a href='byond://?src=[UID()];secretsadmin=list_signalers'>Show last [length(GLOB.lastsignalers)] signalers</a>&nbsp;&nbsp;
						<a href='byond://?src=[UID()];secretsadmin=list_lawchanges'>Show last [length(GLOB.lawchanges)] law changes</a><br>
						<a href='byond://?src=[UID()];secretsadmin=DNA'>List DNA (Blood)</a>&nbsp;&nbsp;
						<a href='byond://?src=[UID()];secretsadmin=fingerprints'>List Fingerprints</a><br>
						<b>Power</b><br>
						<a href='byond://?src=[UID()];secretsfun=blackout'>Break all lights</a>&nbsp;&nbsp;
						<a href='byond://?src=[UID()];secretsfun=whiteout'>Fix all lights</a><br>
						<a href='byond://?src=[UID()];secretsfun=power'>Make all areas powered</a>&nbsp;&nbsp;
						<a href='byond://?src=[UID()];secretsfun=unpower'>Make all areas unpowered</a>&nbsp;&nbsp;
						<a href='byond://?src=[UID()];secretsfun=quickpower'>Power all SMES</a><br>
						<b>Global Gravity State</b><br>
						<a href='byond://?src=[UID()];secretsfun=gravity'>Currently: [isnull(GLOB.gravity_is_on) ? "Default Handling" : GLOB.gravity_is_on ? "ON" : "OFF"]</a><br>
						</center>
					"}

			else if(check_rights(R_SERVER,0)) //only add this if admin secrets are unavailiable; otherwise, it's added inline
				dat += "<center><b>Bomb cap: </b><a href='byond://?src=[UID()];secretsfun=togglebombcap'>Toggle bomb cap</a><br></center>"
				dat += "<br>"
			if(check_rights(R_DEBUG,0))
				dat += {"
					<center>
					<b>Security Level Elevated</b><br>
					<br>
					<a href='byond://?src=[UID()];secretscoder=maint_access_engiebrig'>Change all maintenance doors to engie/brig access only</a><br>
					<a href='byond://?src=[UID()];secretscoder=maint_ACCESS_BRIG'>Change all maintenance doors to brig access only</a><br>
					<a href='byond://?src=[UID()];secretscoder=infinite_sec'>Remove cap on security officers</a>&nbsp;&nbsp;
					<br>
					<b>Coder Secrets</b><br>
					<br>
					<a href='byond://?src=[UID()];secretsadmin=list_job_debug'>Show Job Debug</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretscoder=spawn_objects'>Admin Log</a><br>
					<br>
					</center>
					"}

		if(1)
			if(check_rights((R_EVENT|R_SERVER),0))
				dat += {"
					<center>
					<h2><b>IC Events</b></h2>
					<b>Teams</b><br>
					<a href='byond://?src=[UID()];secretsfun=infiltrators_syndicate'>Send SIT - Syndicate Infiltration Team</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=striketeam_syndicate'>Send in a Syndie Strike Team</a>&nbsp;&nbsp;
					<br><a href='byond://?src=[UID()];secretsfun=striketeam'>Send in the Deathsquad</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=honksquad'>Send in a HONKsquad</a><br>
					<a href='byond://?src=[UID()];secretsfun=gimmickteam'>Send in a Gimmick Team</a><br>
					<b>Change Security Level</b><br>
					<a href='byond://?src=[UID()];secretsfun=securitylevel0'>Security Level - Green</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=securitylevel1'>Security Level - Blue</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=securitylevel2'>Security Level - Red</a><br>
					<a href='byond://?src=[UID()];secretsfun=securitylevel3'>Security Level - Gamma</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=securitylevel4'>Security Level - Epsilon</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=securitylevel5'>Security Level - Delta</a><br>
					<b>Create Weather</b><br>
					<a href='byond://?src=[UID()];secretsfun=weatherashstorm'>Weather - Ash Storm</a>&nbsp;&nbsp;
					<br>
					<b>Reinforce Station</b><br>
					<a href='byond://?src=[UID()];secretsfun=gammashuttle'>Move the Gamma Armory</a>&nbsp;&nbsp;
					<br>
					<b>Renames</b><br>
					<a href='byond://?src=[UID()];secretsfun=set_station_name'>Rename Station Name</a><br>
					<a href='byond://?src=[UID()];secretsfun=reset_station_name'>Reset Station Name</a><br>
					<a href='byond://?src=[UID()];secretsfun=set_centcomm_name'>Rename Central Comand</a><br>
					<br>
					<b>Spawns</b><br>
					<a href='byond://?src=[UID()];secretsfun=spawn_cargo_crate'>Spawn Cargo Crate</a><br>
					</center>"}
		if(2)
			if(check_rights((R_SERVER|R_EVENT),0))
				dat += {"
					<center>
					<h2><b>OOC Events</b></h2>
					<b>Thunderdome</b><br>
					<a href='byond://?src=[UID()];secretsfun=tdomestart'>Start a Thunderdome match</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=tdomereset'>Reset Thunderdome to default state</a><br><br>"}
					/*	У нас не используется
				dat+= {"<b>ERT Armory</b><br>
					<a href='byond://?src=[UID()];secretsfun=armotyreset'>Reset Armory to default state</a><br><br>
					<a href='byond://?src=[UID()];secretsfun=armotyreset1'>Set Armory to 1 option</a><br><br>
					<a href='byond://?src=[UID()];secretsfun=armotyreset2'>Set Armory to 2 option</a><br><br>
					<a href='byond://?src=[UID()];secretsfun=armotyreset3'>Set Armory to 3 option</a><br><br>
					<b>Clothing</b><br>"}
					*/
				dat+={"<b>Clothes</b><br>
					<a href='byond://?src=[UID()];secretsfun=sec_clothes'>Remove 'internal' clothing</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=sec_all_clothes'>Remove ALL clothing</a><br>
					<b>TDM</b><br>
					<a href='byond://?src=[UID()];secretsfun=traitor_all'>Everyone is the traitor</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=onlyone'>There can only be one!</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=onlyme'>There can only be me!</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=onlyoneteam'>Dodgeball (TDM)!</a><br>
					<b>Round-enders</b><br>
					<a href='byond://?src=[UID()];secretsfun=floorlava'>The floor is lava! (DANGEROUS: extremely lame)</a><br>
					<a href='byond://?src=[UID()];secretsfun=fakelava'>The floor is fake-lava! (non-harmful)</a><br>
					<a href='byond://?src=[UID()];secretsfun=monkey'>Turn all humans into monkeys</a><br>
					<a href='byond://?src=[UID()];secretsfun=polymorph'>Polymorph All</a>
					<a href='byond://?src=[UID()];secretsfun=fakeguns'>Make all items look like guns</a><br>
					<a href='byond://?src=[UID()];secretsfun=prisonwarp'>Warp all Players to Prison</a><br>
					<a href='byond://?src=[UID()];secretsfun=stupify'>Make all players stupid</a><br>
					<a href='byond://?src=[UID()];secretsfun=customportal'>Spawn a custom portal storm</a><br>
					<a href='byond://?src=[UID()];secretsfun=mass_mindswap'>Mass mindswap</a><br>
					<b>Misc</b><br>
					<a href='byond://?src=[UID()];secretsfun=sec_classic1'>Remove firesuits, grilles, and pods</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=tripleAI'>Triple AI mode (needs to be used in the lobby)</a><br>
					<a href='byond://?src=[UID()];secretsfun=flicklights'>Ghost Mode</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=schoolgirl'>Japanese Animes Mode</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=eagles'>Egalitarian Station Mode</a><br>
					<a href='byond://?src=[UID()];secretsfun=guns'>Summon Guns</a>&nbsp;&nbsp;
					<a href='byond://?src=[UID()];secretsfun=magic'>Summon Magic</a>
					<br>
					<a href='byond://?src=[UID()];secretsfun=rolldice'>Roll the Dice</a><br>
					<br>
					<br>
					<a href='byond://?src=[UID()];secretsfun=moveferry'>Move Ferry</a><br>
					<a href='byond://?src=[UID()];secretsfun=moveminingshuttle'>Move Mining Shuttle</a><br>
					<a href='byond://?src=[UID()];secretsfun=movelaborshuttle'>Move Labor Shuttle</a><br>
					<br>
					</center>"}
	dat += "</center>"
	var/datum/browser/popup = new(usr, "secrets", "<div align='center'>Admin Secrets</div>", 630, 670)
	popup.set_content(dat)
	popup.open(0)
