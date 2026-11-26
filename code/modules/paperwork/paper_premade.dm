/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"

/obj/item/paper/crumpled/update_icon_state()
	if(!is_empty())
		icon_state = "scrap_words"

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/paper/fortune
	name = "fortune"
	icon_state = "slip"

/obj/item/paper/fortune/Initialize(mapload)
	. = ..()
	var/fortunemessage = pick(GLOB.fortune_cookie_messages)
	add_raw_text("<center>**[fortunemessage]**</center>\n<center>**Lucky numbers**: [rand(1,49)], [rand(1,49)], [rand(1,49)], [rand(1,49)], [rand(1,49)]</center>")
	add_raw_text("<center>**Lucky numbers**: [rand(1,49)], [rand(1,49)], [rand(1,49)], [rand(1,49)], [rand(1,49)]</center>")

/obj/item/paper/fortune/update_icon_state()
	icon_state = initial(icon_state)

/obj/item/paper/Court
	name = "Judgement"
	default_raw_text = "For crimes against the station, the offender is sentenced to:\n\n\n\n"

/obj/item/paper/Toxin
	name = "Chemical Information"
	default_raw_text = "Known Onboard Toxins:\n\n\tGrade A Semi-Liquid Plasma:\n\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.\n\n\t\tA gas mask fails to filter plasma after 50 units.\n\n\t\tWill attempt to diffuse like a gas.\n\n\t\tFiltered by scrubbers.\n\n\t\tThere is a bottled version which is very different\n\n\t\t\tfrom the version found in canisters!\n\n\n\n\t\tWARNING: Highly Flammable. Keep away from heat sources\n\n\t\texcept in a enclosed fire area!\n\n\t\tWARNING: It is a crime to use this without authorization.\n\nKnown Onboard Anti-Toxin:\n\n\tAnti-Toxin Type 01P: Works against Grade A Plasma.\n\n\t\tBest if injected directly into bloodstream.\n\n\t\tA full injection is in every regular Med-Kit.\n\n\t\tSpecial toxin Kits hold around 7.\n\n\n\nKnown Onboard Chemicals (other):\n\n\tRejuvenation T#001:\n\n\t\tEven 1 unit injected directly into the bloodstream\n\n\t\t\twill cure paralysis and sleep plasma.\n\n\t\tIf administered to a dying patient it will prevent\n\n\t\t\tfurther damage for about units*3 seconds.\n\n\t\t\tit will not cure them or allow them to be cured.\n\n\t\tIt can be administeredd to a non-dying patient\n\n\t\t\tbut the chemicals disappear just as fast.\n\n\tSoporific T#054:\n\n\t\t5 units wilkl induce precisely 1 minute of sleep.\n\n\t\t\tThe effect are cumulative.\n\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/paper/courtroom
	name = "A Crash Course in Legal SOP on SS13"
	default_raw_text = "**Roles:**\n\nThe Detective is basically the investigator and prosecutor.\n\nThe Staff Assistant can perform these functions with written authority from the Detective.\n\nThe Captain/HoP/Warden is ct as the judicial authority.\n\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.\n\n\n\n**Investigative Phase:**\n\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.\n\n\n\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.\n\n\n\n**Pre-Pre-Trial Phase:**\n\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.\n\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.\n\n**Possible Motions:**\n\n1. <u>Invalidate Evidence-</u> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.\n\n2. <u>Free Movement-</u> Basically the defendant is to be kept uncuffed before and during the trial.\n\n3. <u>Subpoena Witness-</u> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.\n\n4. <u>Drop the Charges-</u> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.\n\n5. <u>Declare Incompetent-</u> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.\n\n\n\nALL SIDES MOVE TO A COURTROOM\n\n**Pre-Trial Hearings:**\n\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.\n\n\n\n**The Trial:**\n\nThe trial has three phases.\n\n1. **Opening Arguments**- Each side can give a short speech. They may not present ANY evidence.\n\n2. **Witness Calling/Evidence Presentation**- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.\n\nFINALLY once both sides are done calling witnesses we move onto the next phase.\n\n3. **Closing Arguments**- Same as opening.\n\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.\n\n\n\n**Sentencing Phase:**\n\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part.\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.\n\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.\n\n\n\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.\n\n"

/obj/item/paper/hydroponics
	name = "Greetings from Billy Bob"
	default_raw_text = "**Hey fellow botanist!**\n\n\n\nI didn't trust the station folk so I left\n\na couple of weeks ago. But here's some\n\ninstructions on how to operate things here.\n\nYou can grow plants and each iteration they become\n\nstronger, more potent and have better yield, if you\n\nknow which ones to pick. Use your botanist's analyzer\n\nfor that. You can turn harvested plants into seeds\n\nat the seed extractor, and replant them for better stuff!\n\nSometimes if the weed level gets high in the tray\n\nmutations into different mushroom or weed species have\n\nbeen witnessed. On the rare occassion even weeds mutate!\n\n\n\nEither way, have fun!\n\n\n\nBest regards,\n\nBilly Bob Johnson.\n\n\n\nPS.\n\nHere's a few tips:\n\nIn nettles, potency = damage\n\nIn amanitas, potency = deadliness + side effect\n\nIn Liberty caps, potency = drug power + effect\n\nIn chilis, potency = heat\n\n**Nutrients keep mushrooms alive!**\n\n**Water keeps weeds such as nettles alive!**\n\n**All other plants need both.**"

/obj/item/paper/chef
	name = "Cooking advice from Morgan Ramslay"
	default_raw_text = "Right, so you're wanting to learn how to feed the teeming masses of the station yeah?\n\n\n\nWell I was asked to write these tips to help you not burn all of your meals and prevent food poisonings.\n\n\n\nOkay first things first, making a humble ball of dough.\n\n\n\nCheck the lockers for a bag or two of flour and then find a glass cup or a beaker, something that can hold liquids. Next pour 15 units of flour into the container and then pour 10 units of water in as well. Hey presto! You've made a ball of dough, which can lead to many possibilities.\n\n\n\nAlso, before I forget, KEEP YOUR FOOD OFF THE DAMN FLOOR! Space ants love getting onto any food not on a table or kept away in a closed locker. You wouldn't believe how many injuries have resulted from space ants...\n\n\n\nOkay back on topic, let's make some cheese, just follow along with me here.\n\n\n\nLook in the lockers again for some milk cartons and grab another glass to mix with. Next look around for a bottle named 'Universal Enzyme' unless they changed the look of it, it should be a green bottle with a red label. Now pour 5 units of enzyme into a glass and 40 units of milk into the glass as well. In a matter of moments you'll have a whole wheel of cheese at your disposal.\n\n\n\nOkay now that you've got the ingredients, let's make a classic crewman food, cheese bread.\n\n\n\nMake another ball of dough, and cut up your cheese wheel with a knife or something else sharp such as a pair of wire cutters. Okay now look around for an oven in the kitchen and put 2 balls of dough and 2 cheese wedges into the oven and turn it on. After a few seconds a fresh and hot loaf of cheese bread will pop out. Lastly cut it into slices with a knife and serve.\n\n\n\nCongratulations on making it this far. If you haven't created a burnt mess of slop after following these directions you might just be on your way to becoming a master chef someday.\n\n\n\nBe sure to look up other recipes and bug the Head of Personnel if Botany isn't providing you with crops, wheat is your friend and lifeblood.\n\n\n\nGood luck in the kitchen, and try not to burn down the place.\n\n\n\n-Morgan Ramslay"

/obj/item/paper/djstation
	name = "DJ Listening Outpost"
	default_raw_text = "**Welcome new owner!**\n\nYou have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio fequencies. Here is a step by step guide to start listening in on those saucy radio channels:\n<ol><li>Equip yourself with a multi-tool</li><li>Use the multitool on each machine, that is the broadcaster, receiver and the relay.</li><li>Turn all the machines on, it has already been configured for you to listen on.</li></ol> Simple as that. Now to listen to the private channels, you'll have to configure the intercoms, located on the front desk. Here is a list of frequencies for you to listen on.\n<ul><li>145.7 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Mining Channel</li><li>134.7 - Cargo Channel</li>"

/obj/item/paper/monolithren
	name = "For stalkers"
	default_raw_text = "Sorry Mario, your wishgranter in another castle. Your Friendly God"

/obj/item/paper/jobs
	name = "Job Information"
	default_raw_text = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.\n\nThe data will be in the following form.\n\nGenerally lower ranking positions come first in this list.\n\n\n\n**Job Name**   general access>lab access-engine access-systems access (atmosphere control)\n\n\tJob Description\n\nJob Duties (in no particular order)\n\nTips (where applicable)\n\n\n\n**Research Assistant** 1>1-0-0\n\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.\n\n1. Assist the researchers.\n\n2. Clean up the labs.\n\n3. Prepare materials.\n\n\n\n**Staff Assistant** 2>0-0-0\n\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)\n\n1. Patrol ship/Guard key areas\n\n2. Assist security officer\n\n3. Perform other security duties.\n\n\n\n**Technical Assistant** 1>0-0-1\n\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.\n\n1. Assist Station technician and Engineers.\n\n2. Perform general maintenance of station.\n\n3. Prepare materials.\n\n\n\n**Medical Assistant** 1>1-0-0\n\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)\n\n1. Assist the medical personnel.\n\n2. Update medical files.\n\n3. Prepare materials for medical operations.\n\n\n\n**Research Technician** 2>3-0-0\n\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.\n\n1. Inform superiors of research.\n\n2. Perform research alongside of official researchers.\n\n\n\n**Detective** 3>2-0-0\n\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.\n\n1. Perform crime-scene investigations/draw conclusions.\n\n2. Store and catalogue evidence properly.\n\n3. Testify to superiors/inquieries on findings.\n\n\n\n**Station Technician** 2>0-2-3\n\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.\n\n1. Maintain SS13 systems.\n\n2. Repair equipment.\n\n\n\n**Atmospheric Technician** 3>0-0-4\n\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.\n\n1. Maintain atmosphere on SS13\n\n2. Research atmospheres on the space station. (safely please!)\n\n\n\n**Engineer** 2>1-3-0\n\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.\n\n1. Upkeep the engine.\n\n2. Prevent fires in the engine.\n\n3. Maintain a safe orbit.\n\n\n\n**Medical Researcher** 2>5-0-0\n\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.\n\n1. Make sure the station is kept safe.\n\n2. Research medical properties of materials studied of Space Station 13.\n\n\n\n**Scientist** 2>5-0-0\n\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Plasma Technicians as plasma is the material they routinly handle.\n\n1. Research plasma\n\n2. Make sure all plasma is properly handled.\n\n\n\n**Medical Doctor (Officer)** 2>0-0-0\n\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.\n\n1. Heal wounded people.\n\n2. Perform examinations of all personnel.\n\n3. Moniter usage of medical equipment.\n\n\n\n**Security Officer** 3>0-0-0\n\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.\n\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)\n\n1. Maintain order.\n\n2. Assist others.\n\n3. Repair structural problems.\n\n\n\n**Head of Security** 4>5-2-2\n\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.\n\n1. Oversee security.\n\n2. Assign patrol duties.\n\n3. Protect the station and staff.\n\n\n\n**Head of Personnel** 4>4-2-2\n\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.\n\n1. Assign duties.\n\n2. Moderate personnel.\n\n3. Moderate research.\n\n\n**Captain** 5>5-5-5 (unrestricted station wide access)\n\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.\n\n1. Assign all positions on SS13\n\n2. Inspect the station for any problems.\n\n3. Perform administrative duties.\n\n"

/obj/item/paper/photograph
	name = "photo"
	icon_state = "photo"

/obj/item/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	default_raw_text = "Alert Levels:\n\nBlue- Emergency\n\n\t1. Caused by fire\n\n\t2. Caused by manual interaction\n\n\tAction:\n\n\t\tClose all fire doors. These can only be opened by reseting the alarm\n\nRed- Ejection/Self Destruct\n\n\t1. Caused by module operating computer.\n\n\tAction:\n\n\t\tAfter the specified time the module will eject completely.\n\n\n\nEngine Maintenance Instructions:\n\n\tShut off ignition systems:\n\n\tActivate internal power\n\n\tActivate orbital balance matrix\n\n\tRemove volatile liquids from area\n\n\tWear a fire suit\n\n\n\n\tAfter\n\n\t\tDecontaminate\n\n\t\tVisit medical examiner\n\n\n\nToxin Laboratory Procedure:\n\n\tWear a gas mask regardless\n\n\tGet an oxygen tank.\n\n\tActivate internal atmosphere\n\n\n\n\tAfter\n\n\t\tDecontaminate\n\n\t\tVisit medical examiner\n\n\n\nDisaster Procedure:\n\n\tFire:\n\n\t\tActivate sector fire alarm.\n\n\t\tMove to a safe area.\n\n\t\tGet a fire suit\n\n\t\tAfter:\n\n\t\t\tAssess Damage\n\n\t\t\tRepair damages\n\n\t\t\tIf needed, Evacuate\n\n\tMeteor Shower:\n\n\t\tActivate fire alarm\n\n\t\tMove to the back of ship\n\n\t\tAfter\n\n\t\t\tRepair damage\n\n\t\t\tIf needed, Evacuate\n\n\tAccidental Reentry:\n\n\t\tActivate fire alarms in front of ship.\n\n\t\tMove volatile matter to a fire proof area!\n\n\t\tGet a fire suit.\n\n\t\tStay secure until an emergency ship arrives.\n\n\n\n\t\tIf ship does not arrive-\n\n\t\t\tEvacuate to a nearby safe area!"

/obj/item/paper/blueshield
	name = "paper- 'Blueshield Mission Briefing'"
	default_raw_text = "**Blueshield Mission Briefing**\nYou are charged with the defence of any persons of importance within the station. This includes, but is not limited to, The Captain, The Heads of Staff and Central Command staff. You answer directly to the Nanotrasen Representative who will assist you in achieving your mission.\nWhen required to achieve your primary responsibility, you should liaise with security and share resources; however, the day to day security operations of the station are outside of your jurisdiction.\nMonitor the health and safety of your principals, identify any potential risks and threats, then alert the proper departments to resolve the situation. You are authorized to act as bodyguard to any of the station heads that you determine are most in need of protection; however, additional access to their departments shall be granted solely at their discretion.\nObserve the station alert system and carry your armaments only as required by the situation, or when authorized by the Head of Security or Captain in exceptional cases.\nRemember, as an agent of Nanotrasen it is your responsibility to conduct yourself appropriately and you will be held to the highest standard. You will be held accountable for your actions. Security is authorized to search, interrogate or detain you as required by their own procedures. Lawyers will also monitor and observe your conduct, and their mandate applies equally to security and Blueshield operations."

/obj/item/paper/ntrep
	name = "paper- 'Nanotrasen Representative Mission Briefing'"
	default_raw_text = "**Nanotrasen Representative Mission Briefing**\n\nNanotrasen Central Command has dispatched you to this station in order to liaise with command staff on their behalf. As experienced field officers, the staff on the station are experts in handling their own fields. It is your job, however, to consider the bigger picture and to direct the staff towards Nanotrasen's corporate interests.\nAs a civilian, you should consider yourself an advisor, diplomat and intermediary. The command staff do not answer to you directly and are not required to follow your orders, nor do you have disciplinary authority over personnel. In all station internal matters you answer to the Head of Personnel who will direct you in your conduct within the station. However, you also answer to Central Command who may, as required, direct you in acting on company interests.\nCentral Command may dispatch orders to the staff through you which you are responsible to communicate; however, enforcement of these orders is not your mandate and will be handled directly by Central Command or authorized Nanotrasen personnel. When not specifically directed by Central Command, assist the Head of Personnel in evaluation of the station and receiving departmental reports.\nYour office has been provided with a direct link to Central Command, through which you can issue any urgent reports or requests for Nanotrasen intervention. Remember that any direct intervention is a costly exercise and should be used only when the situation justifies the request. You will be held accountable for any unnecessary usage of Nanotrasen resources.\n"

/obj/item/paper/armory
	name = "paper- 'Armory Inventory'"
	default_raw_text = "4 Deployable Barriers\n4 Portable Flashers\n1 Mechanical Toolbox\n2 Boxes of Spare Handcuffs\n1 Box of Flashbangs\n1 Box of Spare R.O.B.U.S.T. Cartridges\n1 Tracking Implant Kit\n1 Chemical Implant Kit\n1 Box of Tear Gas Grenades\n1 Explosive Ordnance Disposal Suit\n1 Biohazard Suit\n6 Gas Masks\n1 Lockbox of Mindshield Implants\n1 Ion Rifle\n3 Sets of Riot Equipment\n2 Sets of Security Hardsuits\n1 Ablative Armor Vest\n3 Bulletproof Vests\n3 Helmets\n\n2 Riot Shotguns\n2 Boxes of Beanbag Shells\n3 Laser Guns\n3 Energy Guns\n3 Advanced Tasers"

/obj/item/paper/firingrange
	name = "paper- 'Firing Range Instructions'"
	default_raw_text = "Directions:\n*First you'll want to make sure there is a target stake in the center of the magnetic platform. Next, take an aluminum target from the crates back there and slip it into the stake. Make sure it clicks! Next, there should be a control console mounted on the wall somewhere in the room.\n\n This control console dictates the behaviors of the magnetic platform, which can move your firing target around to simulate real-world combat situations. From here, you can turn off the magnets or adjust their electromagnetic levels and magnetic fields. The electricity level dictates the strength of the pull - you will usually want this to be the same value as the speed. The magnetic field level dictates how far the magnetic pull reaches.\n\nSpeed and path are the next two settings. Speed is associated with how fast the machine loops through the designated path. Paths dictate where the magnetic field will be centered at what times. There should be a pre-fabricated path input already. You can enable moving to observe how the path affects the way the stake moves. To script your own path, look at the following key:*\n\nN: North\nS: South\nE: East\nW: West\nC: Center\nR: Random (results may vary)\n; or &: separators. They are not necessary but can make the path string better visible."

/obj/item/paper/holodeck
	name = "paper- 'Holodeck Disclaimer'"
	default_raw_text = "Bruises sustained in the holodeck can be healed simply by sleeping."

/obj/item/paper/syndimemo
	name = "paper- 'Memo'"
	default_raw_text = "GET DAT FUKKEN DISK"

/obj/item/paper/synditele
	name = "Teleporter Instructions"
	default_raw_text = "<h3>Teleporter Instruction</h3><hr><ol><li>Install circuit board, glass and wiring to complete Teleporter Control Console</li><li>Use a screwdriver, wirecutter and screwdriver again on the Teleporter Station to connect it</li><li>Set destination with Teleporter Control Computer</li><li>Activate Teleporter Hub with Teleporter Station</li></ol>"

/obj/item/paper/russiantraitorobj
	name = "paper- 'Mission Objectives'"
	default_raw_text = "The Syndicate have cunningly disguised a Syndicate Uplink as your PDA. Simply enter the code \"678 Bravo\" into the ringtone select to unlock its hidden features.\n**Objective #1**. Kill the God damn AI in a fire blast that it rocks the station. **Success!**  \n**Objective #2**. Escape alive. **Failed.**"

/obj/item/paper/russiannuclearoperativeobj
	name = "paper- 'Objectives of a Nuclear Operative'"
	default_raw_text = "**Objective #1**: Destroy the station with a nuclear device."

/obj/item/paper/clownship
	name = "paper- 'Note'"
	default_raw_text = "The call has gone out! Our ancestral home has been rediscovered! Not a small patch of land, but a true clown nation, a true Clown Planet! We're on our way home at last!"

/obj/item/paper/syndicate
	default_raw_text = "<center>\[logo:syndielogo.png\]</center><hr>\n"

/obj/item/paper/nanotrasen
	default_raw_text = "<center>\[logo:ntlogo.png\]</center><hr>\n"

/obj/item/paper/ussp
	default_raw_text = "<center>\[logo:ussplogo.png\]</center><hr>\n"

/obj/item/paper/solgov
	default_raw_text = "<center>\[logo:solgovlogo.png\]</center><hr>\n"

/obj/item/paper/human
	default_raw_text =  ""

/obj/item/paper/central_command
	name = "Директива Центрального командования"

/obj/item/paper/central_command/Initialize(mapload)
	. = ..()
	var/time_str = "Время: [station_time_timestamp()]"
	if(!GLOB.genname)
		GLOB.genname = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names_male)]"

	var/header_html = "<table><tr><td>\[logo:ntlogo.png\]</td><td><table><tr><td><small>Форма NT-CC-DRV</small></td></tr><tr><td><small>[command_name()]</small></td></tr><tr><td><small>[time_str]</small></td></tr><tr><td><b>Директива Центрального командования</b></td></tr></table></td></tr></table><hr>\n"
	var/footer_html = "\n\n<small><i>Подпись: <font face=\"[SIGNATURE_FONT]\">[GLOB.genname]</font></i>, в должности <i>Nanotrasen Navy Officer</i></small><hr><small><i>Содержимое данного документа следует считать конфиденциальным. Если не указано иное, распространение содержащейся в данном документе информации среди третьих лиц и сторонних организаций строго запрещено.<br>Невыполнение директив, содержащихся в данном документе, считается нарушением политики корпорации и может привести к наложению различных дисциплинарных взысканий.<br>Данный документ считается действительным только при наличии подписи и печати офицера Центрального командования.</i></small>"

	var/body_text = default_raw_text ? default_raw_text : "\[___________________________________________________\]"
	clear_paper()
	add_raw_text("[header_html][body_text][footer_html]", PEN_FONT, COLOR_BLACK, FALSE, FALSE)
	update_appearance()

/obj/item/paper/central_command/archive/station_reports
	default_raw_text = "<center>**Приветствую Центральное командование**</center>\nСообщает вам ██████████ █████████, в должности капитан </span>.\n\nВ данный момент на станции код: Зеленый </span>\nАктивные угрозы для станции: **Отсуствуют </span>**\nПотери среди экипажа: Отсуствуют </span>\nПовреждения на станции: Отсуствуют</span>\nОбщее состояние станции: Удовлетворительное </span>\nДополнительная информация: Отсутствует\n<hr>\n<center><h3>Подписи и штампы</h3></center>\nПодпись:  ██████████ █████████ <hr><small>*В данном документе описывается полное состояние станции, необходимо перечислить всю доступную информацию. \n*Информацию, которую вы считаете нужной, необходимо сообщить в разделе — дополнительная информация. \n***Данный документ считается официальным только после подписи уполномоченного лица и наличии на документе его печати.** </small></small>"

/obj/item/paper/central_command/archive/memes

/obj/item/paper/thief
	name = "Инструкции"
	default_raw_text = "<center>\[logo:thieflogo.png\]</center><hr>\n \
	<center><h2>Инструкции</h2></center>\n \
	<center><h3>Здравия, товарищ по ремеслу!</h3></center>\n\n \
	Данная инструкция поможет тебе разобраться и сразу не попасться.\n\n \
	Ну... Тут как повезет. Но помни, если тебя поймали — ты никого не знаешь.\n\n \
	Мы постараемся вытащить тебя как только так сразу. А до этого момента сиди держи язык за зубами. Гильдия всегда всё знает.\n \
	<hr>\n \
	**Начнем с основ.**\n\n \
	В твоих руках находится коробка с твоими личным инструментарием, который ты взял с собой. Надеюсь ты тщательно подумал что берешь. В любом случае, думать уже поздно, теперь работай с тем что есть и что под рукой.\n\n \
	Надеюсь ты не взял с собой термальные очки. Ты же уважающий себя член нашей гильдии. Ведь так?\n\n \
	А даже если взял, наверняка мы заменили тебе их на не-хамелеонные и приложили коробку сладостей. Наслаждайся.\n\n \
	Если же не взял — мое личное уважение за знание своего ремесла и уверенность.\n\n \
	Также в твой набор вложен портфель и перчатки. Портфель позволяет тебе спрятать вещи в него, а после запрятать их где-нибудь под-полом. Конечно ты можешь и без этого спрятать их в бачок унитаза, судить твои методы не буду. Они все хороши.\n\n \
	Наши фирменные перчатки не оставляют следов и позволяют стащить вещь у твоей цели прямо на её глазах в твои руки. И она даже ничего не заметит. Конечно если ты не снимаешь с неё трусы. Лёгкий ветерок щекочащий булочки вызывает подозрения.\n \
	<hr>\n \
	**А теперь по пунктам:**\n \
	1. Получи информацию по цели.\n \
	2. Найди цель.\n \
	3. Продумай план с использованием своего снаряжения и снаряжения станции.\n \
	\t3.1 Заполучи дополнительное снаряжение при необходимости.\n \
	\t3.2 Воспользуйся украденными денежными средствами для получения снаряжения.\n \
	4. Действуй. Не сиди и не жди. Чем дольше ты ждешь, тем больше шансов что цель пострадает до её заполучения.\n \
	\t4.1 Если цель — предмет, просто не потеряй его после кражи.\n \
	\t4.2 Если цель — структура, убедись что её не разобрали никакие клоуны.\n \
	\t4.3 Если цель — питомец, убедись в её безопасности, помести её в переноску, рюкзак или шкаф, свяжи по возможности.\n \
	5. Контролируй сохранность цели во избежания её повреждения или... смерти. Иначе задача будет провалена.\n \
	6. Для успешного выполнения цели необходимо:\n \
	\t6.1 Предметы: Храни их на себе, в себе, в карманах или рюкзаке.\n \
	\t6.2 Структура: Держи её возле себя по прибытию.\n \
	\t6.3 Питомец: Держи его в рюкзаке, в карманах, переноске, шкафу или на голове по прибытию.\n \
	7. ...\n \
	8. Profit!\n\n \
	<small>**Уничтожь улики, коробку и инструкцию во избежании раскрытия работы гильдии.**</small>\n\n \
	<small>~~~ <b>Твой Куратор:</b> Персональный Управляемый Помощник Согласования ~~~</small>"

/obj/item/paper/dog_detective_explain
	name = "Форма NT-PET- — Уведомление агента внутренних дел \"Нанотрейзен\" о питомце \"Гав Гавыч\""
	default_raw_text = "<center>\[logo:ntlogo.png\]</center><hr>\n\
	<center><h3>Отдел внутренних дел \"Нанотрейзен\" по надзору за животными.</h3>\n\
	<b>Официальное Уведомление</b></center><hr>\n\
	ᅠᅠАгенство внутренних дел по надзору за домашними животными находящимися на станции сообщает, приставленный к вам питомец \"Гав Гавыч\" почил. Он верно служил ремеслу дознавателей, сыщиков и детективов. Мы будем помнить о его вкладе и сохраним о нём память в анналах истории о домашних питомцах \"Нанотрейзен\".\n\
	<hr>\n\
	<center><h3>Штампы и данные:</h3></center>\n\
	Время принятия отчета: \[_____________\]\n\
	<hr><small>Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче агенту.<br>Данный документ может содержать личную информацию.</small>"

/obj/item/paper/evilfax
	name = "Centcomm Reply"
	default_raw_text = ""
	var/mytarget = null
	var/myeffect = null
	var/used = FALSE
	var/countdown = 60
	var/activate_on_timeout = FALSE
	var/faxmachineid = null

/obj/item/paper/evilfax/ui_interact(mob/user, datum/tgui/ui)
	if(user == mytarget)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			evilpaper_specialaction(C)
			..()
		else
			// This should never happen, but just in case someone is adminbussing
			evilpaper_selfdestruct()
	else
		if(mytarget)
			to_chat(user,span_notice("This page appears to be covered in some sort of bizzare code. The only bit you recognize is the name of [mytarget]. Perhaps [mytarget] can make sense of it?"))
		else
			evilpaper_selfdestruct()

/obj/item/paper/evilfax/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/paper/evilfax/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(mytarget && !used)
		var/mob/living/carbon/target = mytarget
		var/datum/disease/virus/transformation/corgi/D = new
		D.Contract(target)
	return ..()

/obj/item/paper/evilfax/process()
	if(!countdown)
		if(mytarget)
			if(activate_on_timeout)
				addtimer(CALLBACK(src, PROC_REF(evilpaper_specialaction), mytarget), 3 SECONDS, TIMER_DELETE_ME)
			else
				message_admins("[mytarget] ignored an evil fax until it timed out.")
		else
			message_admins("Evil paper '[src]' timed out, after not being assigned a target.")
		used = TRUE
		evilpaper_selfdestruct()
	else
		countdown--

/obj/item/paper/evilfax/proc/evilpaper_specialaction(mob/living/carbon/target)
	if(!iscarbon(target))
		return

	var/obj/machinery/photocopier/faxmachine/fax = locateUID(faxmachineid)
	if(myeffect == "Borgification")
		to_chat(target,span_userdanger("You seem to comprehend the AI a little better. Why are your muscles so stiff?"))
		var/datum/disease/virus/transformation/robot/D = new
		D.Contract(target)
	else if(myeffect == "Corgification")
		to_chat(target,span_userdanger("You hear distant howling as the world seems to grow bigger around you. Boy, that itch sure is getting worse!"))
		var/datum/disease/virus/transformation/corgi/D = new
		D.Contract(target)
	else if(myeffect == "Death By Fire")
		to_chat(target,span_userdanger("You feel hotter than usual. Maybe you should lowe-wait, is that your hand melting?"))
		var/turf/simulated/target_location = get_turf(target)
		var/obj/effect/hotspot/hotspot = new /obj/effect/hotspot/fake(target_location)
		hotspot.temperature = 1000
		hotspot.recolor()
		target.adjustFireLoss(150) // hard crit, the burning takes care of the rest.
	else if(myeffect == "Total Brain Death")
		to_chat(target,span_userdanger("You see a message appear in front of you in bright red letters: <b>YHWH-3 ACTIVATED. TERMINATION IN 3 SECONDS</b>"))
		ADD_TRAIT(target, TRAIT_NO_CLONE, EVIL_FAX_TRAIT)
		target.adjustBrainLoss(125)
	else if(myeffect == "Honk Tumor")
		if(!target.get_int_organ(/obj/item/organ/internal/honktumor))
			new /obj/item/organ/internal/honktumor(target)
			to_chat(target,span_userdanger("Life seems funnier, somehow."))
	else if(myeffect == "Cluwne")
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			to_chat(H, span_userdanger("You feel surrounded by sadness. Sadness... and HONKS!"))
			H.makeCluwne()
	else if(myeffect == "Demote")
		GLOB.major_announcement.announce(
			message = "[target.real_name] настоящим приказом был понижен до Гражданского. Немедленно обработайте этот запрос. Невыполнение этих распоряжений является основанием для расторжения контракта.",
			new_title = ANNOUNCE_CCDEMOTE_RU,
			new_sound = SSstation.announcer.get_rand_report_sound(),
		)
		for(var/datum/data/record/R in sortRecord(GLOB.data_core.security))
			if(R.fields["name"] == target.real_name)
				R.fields["criminal"] = SEC_RECORD_STATUS_DEMOTE
				R.fields["last_modifier_level"] = LAW_LEVEL_CENTCOMM
				R.fields["comments"] += "Central Command Demotion Order, given on [GLOB.current_date_string] [station_time_timestamp()]<br> Process this demotion immediately. Failure to comply with these orders is grounds for termination."
		update_all_mob_security_hud()
	else if(myeffect == "Demote with Bot")
		GLOB.major_announcement.announce(
			message = "[target.real_name] настоящим приказом был понижен до Гражданского. Немедленно обработайте этот запрос. Невыполнение этих распоряжений является основанием для расторжения контракта.",
			new_title = ANNOUNCE_CCDEMOTE_RU,
			new_sound = SSstation.announcer.get_rand_report_sound(),
		)
		for(var/datum/data/record/R in sortRecord(GLOB.data_core.security))
			if(R.fields["name"] == target.real_name)
				R.fields["criminal"] = SEC_RECORD_STATUS_ARREST
				R.fields["last_modifier_level"] = LAW_LEVEL_CENTCOMM
				R.fields["comments"] += "Central Command Demotion Order, given on [GLOB.current_date_string] [station_time_timestamp()]<br> Process this demotion immediately. Failure to comply with these orders is grounds for termination."
		update_all_mob_security_hud()
		if(fax)
			var/turf/T = get_turf(fax)
			new /obj/effect/portal(T)
			new /mob/living/simple_animal/bot/secbot(T)
	else if(myeffect == "Revoke Fax Access")
		GLOB.fax_blacklist += target.real_name
		if(fax)
			fax.authenticated = FALSE
	else if(myeffect == "Angry Fax Machine")
		if(fax)
			fax.become_mimic()
	else
		message_admins("Evil paper [src] was activated without a proper effect set! This is a bug.")

	used = TRUE
	evilpaper_selfdestruct()

/obj/item/paper/evilfax/proc/evilpaper_selfdestruct()
	visible_message(span_danger("[src] spontaneously catches fire, and burns up!"))
	qdel(src)

/obj/item/paper/researchnotes
	name = "paper - 'Research Notes'"
	default_raw_text = "**The notes appear gibberish to you. Perhaps a destructive analyzer in R&D could make sense of them.**"
	origin_tech = "combat=4;materials=4;engineering=4;biotech=4"

/obj/item/paper/researchnotes/Initialize(mapload)
	. = ..()
	var/list/possible_techs = list(RESEARCH_TREE_MATERIALS, RESEARCH_TREE_ENGINEERING, RESEARCH_TREE_PLASMA, RESEARCH_TREE_POWERSTORAGE, RESEARCH_TREE_BLUESPACE, RESEARCH_TREE_BIOTECH, RESEARCH_TREE_COMBAT, RESEARCH_TREE_MAGNETS, RESEARCH_TREE_PROGRAMMING, RESEARCH_TREE_ILLEGAL)
	var/mytech = pick(possible_techs)
	var/mylevel = rand(7, 9)
	origin_tech = "[mytech]=[mylevel]"
	name = "research notes - [mytech] [mylevel]"

/obj/item/paper/form
	var/id // official form ID
	var/altername // alternative form name
	var/category // category name
	var/confidential = FALSE
	var/from
	var/notice = "Перед заполнением прочтите от начала до конца | Во всех PDA имеется ручка"
	var/access = null // form visible only with appropriate access
	var/syndicate = FALSE
	var/is_header_needed = TRUE
	var/logo_icon = "ntlogo.png"
	var/footer_text = footer_signstampfax

	var/const/footer_signstampfax = "<hr><center><small>Подписи глав являются доказательством их согласия.<br>Данный документ является недействительным при отсутствии релевантной печати.<br>Пожалуйста, отправьте обратно подписанную/проштампованную копию факсом.</small></center>"
	var/const/footer_signstamp = "<hr><center><small>Подписи глав являются доказательством их согласия.<br>Данный документ является недействительным при отсутствии релевантной печати.</small></center>"
	var/const/footer_confidential = "<hr><center><small>Данный документ является недействительным при отсутствии печати.<br>Отказ от ответственности: Данный факс является конфиденциальным и не может быть прочтен сотрудниками не имеющего доступа. Если вы получили данный факс по ошибке, просим вас сообщить отправителю и удалить его из вашего почтового ящика или любого другого носителя. И \"Нанотрейзен\", и любой её агент не несёт ответственность за любые сделанные заявления, они являются исключительно заявлениями отправителя, за исключением если отправителем является \"Нанотрейзен\" или один из её агентов. Отмечаем, что ни \"Нанотрейзен\", ни один из агентов корпорации не несёт ответственности за наличие вирусов, который могут содержаться в данном факсе или его приложения, и это только ваша прерогатива просканировать факс и приложения на них. Никакие контракты не могут быть заключены посредством факсимильной связи.</small></center>"

/obj/item/paper/form/proc/get_header_text()
	if(!is_header_needed)
		return ""
	return "<table><tr><td valign='top'>\[logo:[logo_icon]\]</td><td valign='top'><small>[name][confidential ? " \[КОНФИДЕНЦИАЛЬНО\]" : ""]</small><br><h3>[altername]</h3><br><table><tr><td>[from]</td><td style='padding-left:15px;'>[category]</td></tr></table></td></tr></table><center><small>[notice]</small></center><hr>"

/obj/item/paper/form/Initialize(mapload)
	if(!from)
		from = "Научная станция \"Нанотрейзен\" \"[SSmapping.map_datum.station_name]\""
	default_raw_text = "[get_header_text()][default_raw_text][footer_text]"
	. = ..()

// MARK: Главы станции

/obj/item/paper/form/NT_COM_ORDER
	name = "Форма NT-COM-ORDER"
	id = "NT-COM-ORDER"
	altername = "Приказ"
	category = "Главы станции"
	default_raw_text = "Я, \[_____________\], в должности \[_____________\], приказываю:\n\n\[___________________________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись инициатора: \[_____________\]\nВремя подписания приказа:\n\[_____________\]\nДата подписания приказа:\n\[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве должностного лица.</small>"

/obj/item/paper/form/NT_COM_ST
	name = "Форма NT-COM-ST"
	id = "NT-COM-ST"
	altername = "Отчет о ситуации на станции"
	category = "Главы станции"
	default_raw_text = "<center>**Приветствую Центральное командование**</center>\n\nСообщает вам \[_____________\], в должности \n\[_____________\].\n\nВ данный момент на станции код:\n\[_____________\]\nАктивные угрозы для станции:\n**\[_____________\]**\nПотери среди экипажа: \n\[_____________\]\nПовреждения на станции:\n\[_____________\]\nОбщее состояние станции:\n\[_____________\]\nДополнительная информация:\n\[_____________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись: \[_____________\]\n<hr><small>В данном документе описывается полное состояние станции, необходимо перечислить всю доступную информацию.\nИнформацию, которую вы считаете нужной, необходимо сообщить в разделе — дополнительная информация.\n**Данный документ считается официальным только после подписи уполномоченного лица и наличии на документе его печати.**</small>"

/obj/item/paper/form/NT_COM_ACAP
	name = "Форма NT-COM-ACAP"
	id = "NT-COM-ACAP"
	altername = "Заявление о повышении главы отдела до и.о. капитана"
	category = "Главы станции"
	default_raw_text = "Я, \[_____________\], в должности главы отделения\n\n\[_____________\], прошу согласовать нынешнее командование станции Керберос в повышении меня до и.о. капитана.\n\n⠀⠀⠀При назначении меня на данную должность, я обязуюсь выполнять все рекомендации и правила, согласно стандартным рабочим процедурам капитана. До появления капитана, я обеспечиваю порядок и управление станцией, сохранность и безопасность *диска с кодами авторизации ядерной боеголовки, а также самой боеголовки, коды от сейфов и личные вещи капитана*.\n\n⠀⠀⠀При появлении капитана мне необходимо будет сообщить: состояние и статус станции, о своем продвижении до и.о. капитана, и обнулить капитанский доступ по первому требованию капитана.\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись заявителя:\n\[_____________\]\nПодпись инициатора повышения:\n\[_____________\]\nВремя вступления в должность и.о. капитана:\n\[_____________\]\nПодпись главы отделения \[_____________\]:\n\[_____________\]\nПодпись главы отделения \[_____________\]:\n\[_____________\]\nПодпись главы отделения \[_____________\]:\n\[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченного лица, производившего инициацию повышения, и выдаче заявителю.\nЕсли один (или более) глав отсутствуют, необходимо собрать подписи действующих глав.\nТакже в данном документе главам, которые согласились с кандидатом, необходимо поставить свою печать и подпись.</small>"

/obj/item/paper/form/NT_COM_ACOM
	name = "Форма NT-COM-ACOM"
	id = "NT-COM-ACOM"
	altername = "Заявление о повышении сотрудника до и.о. главы отделения"
	category = "Главы станции"
	default_raw_text = "ᅠᅠЯ, \[_____________\], в должности сотрудника отделения **\[_____________\]**, прошу согласовать нынешнее командование станции Керберос в повышении меня до звания и.о. главы \[_____________\].\n\n⠀⠀⠀При назначении меня на данную должность, я обязуюсь выполнять все рекомендации и правила, которые присутствуют на главе отделения \[_____________\]. До появления основного главы отделения, я обеспечиваю порядок и управление своим отделом, сохранность и безопасность *личных вещей главы отделения*.\n\n⠀⠀⠀При появлении главы отделения, мне необходимо сообщить: состояние и статус своего отдела, о своем продвижении до и.о. главы отделения, и сдать доступ и.о. главы и взятые вещи при первом требовании прибывшего главы.\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись заявителя:\n\[_____________\]\nПодпись инициатора повышения:\n\[_____________\]\nВремя вступления в и.о. \[_____________\]:\n\[_____________\]\nПодпись главы отделения \[_____________\]:\n\[_____________\]\nПодпись главы отделения \[_____________\]:\n\[_____________\]\nПодпись главы отделения \[_____________\]:\n\[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченного лица, производившего инициацию повышения, и выдаче заявителю.\nПри указании главы рекомендуется использовать сокращения:\nГВ (глав. врач), ГИ (глав. инженер), НР (науч. рук.), КМ (квартирмейстер), ГСБ (глава СБ), ГП (глава персонала).\nЕсли один (или более) глав отсутствуют, необходимо собрать подписи действующих глав.\nТакже в данном документе главам, которые согласились с кандидатом, необходимо поставить свою печать и подпись.</small>"

/obj/item/paper/form/NT_COM_LCOM
	name = "Форма NT-COM-LCOM"
	id = "NT-COM-LCOM"
	altername = "Заявление об увольнении главы отделения"
	category = "Главы станции"
	default_raw_text = "ᅠᅠЯ, \[_____________\], в должности —\n\[_____________\], заявляю об официальном увольнении действующего главы \[_____________\], отделения \[_____________\].\nПричина увольнения:\n\[_____________\]\n\n⠀⠀⠀При наличии иных причин от других глав, они также могут написать их в данном документе:\n\[_____________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись инициатора увольнения:\n\[_____________\]\nПодпись увольняемого об ознакомлении:\n\[_____________\]\nДата и время увольнения:\n\[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченного лица, производившего инициацию увольнения, и выдаче увольняемому.\nДля полной эффективности данного документа необходимо собрать как можно больше причин для увольнения и перечислить их. Инициировать увольнение может только *капитан или глава персонала.*</small>"

/obj/item/paper/form/NT_COM_REQ
	name = "Форма NT-COM-REQ"
	id = "NT-COM-REQ"
	altername = "Запрос на поставку с Центрального командования"
	category = "Главы станции"
	default_raw_text = "<center>**Приветствую Центральное командование**</center>\n\nСообщает вам \[_____________\], в должности \n\[_____________\].\n\n**Текст запроса:**\n\[___________________________________________________\]\n\n**Причина запроса:**\n\[___________________________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись: \[_____________\]\n<hr><small>В данном документе описываются запросы на поставку оборудования/ресурсов, необходимо перечислить по пунктам необходимое для поставки.\n**Данный документ считается официальным только после подписи уполномоченного лица и наличии на документе его печати.**</small>"

/obj/item/paper/form/NT_COM_OS
	name = "Форма NT-COM-OS"
	id = "NT-COM-OS"
	altername = "Отчёт о выполнении цели"
	category = "Главы станции"
	default_raw_text = "Цель станции: \[_____________\]\n\nСтатус цели: \n\[_____________\]\nОбщее состояние станции:\n\[_____________\]\nАктивные угрозы: \n\[_____________\]\nОценка работы экипажа:\n\[_____________\]\nДополнительные замечания:\n\[_____________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nДолжность уполномоченного лица:\n\[_____________\]\nПодпись уполномоченного лица:\n\[_____________\]\n<hr><small>**Данное сообщение должно сообщить вам о состоянии цели, установленной Центральным командованием \"Нанотрейзен\" для ИСН \"Керберос\". Убедительная просьба внимательно прочитать данное сообщение для вынесения наиболее эффективных указаний для последующей деятельности станции.**\nДанный документ считается официальным только при наличии подписи уполномоченного лица и соответствующего его должности штампа. В случае отсутствия любого из указанных элементов данный документ не является официальным и рекомендуется его удалить с любого информационного носителя.\nОТКАЗ ОТ ОТВЕТСТВЕННОСТИ: Корпорация \"Нанотрейзен\" не несёт ответственности, если данный документ не попал в руки первоначального предполагаемого получателя. Однако корпорация Nanotrasen запрещает использование любой имеющейся в данном документе информации третьими лицами и сообщает, что это преследуется по закону, даже если информация в данном документе не является достоверной.</small>"

// MARK: Медицинский отдел

/obj/item/paper/form/NT_MD_01
	name = "Форма NT-MD-01"
	id = "NT-MD-01"
	altername = "Постановление на поставку медикаментов"
	category = "Медицинский отдел"
	default_raw_text = "⠀⠀⠀ Я, \[_____________\], в должности \[_____________\], запрашиваю следующие медикаменты на поставку в медбей:\n**\[___________________________________________________\]**\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись заказчика: \[_____________\]\nПодпись грузчика: \[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и выдаче грузчику или производившему поставку.</small>"
	footer_text = footer_signstamp

/obj/item/paper/form/NT_MD_02
	name = "Форма NT-MD-02"
	id = "NT-MD-02"
	altername = "Отчёт о вскрытии"
	category = "Медицинский отдел"
	default_raw_text = "<center><h3>Основная информация</h3></center>\n<table><tr><td>Скончавшийся:</td><td>\[_____________\]</td></tr><tr><td>Раса:</td><td>\[_____________\]</td></tr><tr><td>Пол:</td><td>\[_____________\]</td></tr><tr><td>Возраст:</td><td>\[_____________\]</td></tr><tr><td>Группа крови:</td><td>\[_____________\]</td></tr><tr><td>Должность:</td><td>\[_____________\]</td></tr></table>\n<hr>\n<center><h3>Отчёт о вскрытии</h3></center>\n<table><tr><td>Тип смерти:</td><td>\[_____________\]</td></tr><tr><td>Описание тела:</td><td>\[_____________\]</td></tr><tr><td>Метки и раны:</td><td>\[_____________\]</td></tr><tr><td>Вероятная причина смерти:</td><td>\[_____________\]</td></tr></table>\n\nДетали:\n\[___________________________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Вскрытие провёл:</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_signstamp

/obj/item/paper/form/NT_MD_03
	name = "Форма NT-MD-03"
	id = "NT-MD-03"
	altername = "Постановление на изготовление химических препаратов"
	category = "Медицинский отдел"
	default_raw_text = "⠀⠀⠀ Я, \[_____________\], в должности \[_____________\], запрашиваю следующие химические медикаменты для служебного использования в медбее:\n**\[___________________________________________________\]**\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись заказчика: \[_____________\]\nПодпись исполняющего:\n\[_____________\]\nВремя заказа: \[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и выдаче лицу, исполнившему заказ.</small>"
	footer_text = footer_signstamp

/obj/item/paper/form/NT_MD_04
	name = "Форма NT-MD-04"
	id = "NT-MD-04"
	altername = "Сводка о вирусе"
	category = "Медицинский отдел"
	default_raw_text = "<center>**Вирус: \[_____________\]**</center>\n\nПолное название вируса:\n\[____________________________________\]\nСвойства вируса: \n\[___________________________________________________\]\nПередача вируса: \n\[____________________________________\]\nПобочные эффекты: \n\[____________\]\n\nДополнительная информация:\n\[___________________________________________________\]\n\nЛечение вируса: \n\[____________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись вирусолога: \[_____________\]\n<hr><small>В дополнительной информации указывается вся остальная информация по поводу данного вируса.</small>"
	footer_text = footer_signstamp

/obj/item/paper/form/NT_MD_05
	name = "Форма NT-MD-05"
	id = "NT-MD-05"
	altername = "Отчет о психологическом состоянии"
	category = "Медицинский отдел"
	default_raw_text = "Пациент: \[____________________________________\]\nРаздражители:\n\[____________________________________\]\nСимптомы и побочные действия:\n\[___________________________________________________\]\nДополнительная информация:\n\[___________________________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись психолога: \[_____________\]\nВремя обследования: \[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и выдаче пациенту.</small>"
	footer_text = footer_signstamp

/obj/item/paper/form/NT_MD_VRR
	name = "Форма NT-MD-VRR"
	id = "NT-MD-VRR"
	altername = "Запрос на распространение вируса"
	category = "Медицинский отдел"
	default_raw_text = "<center><h3>Основная информация</h3></center>\n\nЯ, \[_____________\], в должности — \[_____________\], запрашиваю право на распространение вируса среди экипажа станции.\n<table><tr><td>Название вируса:</td><td>\[_____________\]</td></tr><tr><td>Задачи вируса:</td><td>\[_____________\]</td></tr><tr><td>Лечение:</td><td>\[_____________\]</td></tr><tr><td>Вакцина была произведена и в данный момент находится:</td><td>\[_____________\]</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Подпись вирусолога:</td><td>\[_____________\]</td></tr><tr><td>Подпись глав. врача:</td><td>\[_____________\]</td></tr><tr><td>Подпись капитана:</td><td>\[_____________\]</td></tr></table>\n<hr><small>Производитель вируса несет полную ответственность за его распространение, изолирование и лечение.\nПри возникновении опасных или смертельных побочных эффектов у членов экипажа производитель должен незамедлительно предоставить вакцину от данного вируса.</small>"
	footer_text = footer_signstamp

// MARK: Исследовательский отдел

/obj/item/paper/form/NT_RND_01
	name = "Форма NT-RND-01"
	id = "NT-RND-01"
	altername = "Отчет о странном предмете"
	category = "Исследовательский отдел"
	default_raw_text = "Название предмета: \[_____________\]\nТип предмета:\n\[_____________\]\nСтроение: \[_____________\]\nОсобенности и функционал:\n\[_____________\]\nДополнительная информация:\n\[___________________________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись производившего осмотр:\n\[_____________\]\n<hr><small>В дополнительной информации рекомендуется указать остальную информацию о предмете, любое взаимодействие с ним, модификации, итоговый вариант после модификации.</small>"

/obj/item/paper/form/NT_RND_02
	name = "Форма NT-RND-02"
	id = "NT-RND-02"
	altername = "Заявление на киберизацию"
	category = "Исследовательский отдел"
	default_raw_text = "⠀⠀⠀ Я, \[_____________\], в должности \[_____________\], самовольно подтверждаю согласие на проведение киберизации.\n\n⠀⠀⠀ Я полностью доверяю работнику \[_____________\] в должности — \[_____________\]. Я хорошо осведомлен о рисках, связанных как с операцией, так и с киберизацией, и понимаю, что Nanotrasen не несет ответственности, если эти процедуры вызовут боль, заражение или иные случаи летального характера.\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись заявителя:\n\[_____________\]\nПодпись уполномоченного:\n\[_____________\]\n<hr><small>Если член экипажа мертв, данный документ нет необходимости создавать.\nЕсли член экипажа жив, данный документ сохраняется только у уполномоченного лица.\nДанный документ может использоваться как для создания киборгов, так и для ИИ.</small>"

/obj/item/paper/form/NT_RND_03
	name = "Форма NT-RND-03"
	id = "NT-RND-03"
	altername = "Заявление на получение и установку импланта"
	category = "Исследовательский отдел"
	default_raw_text = "<center><h3>Заявление</h3></center>\n<table><tr><td>Имя заявителя:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта заявителя:<br><small>Эта информация есть в ваших заметках</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr><tr><td>Требуемый имплантат:<br><small>Может требовать дополнительного согласования</small><br>\[____________________________________\]</td></tr><tr><td>Причина:<br><small>Объясните свои намерения</small><br>\[___________________________________________________\]</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Дата и время:</td><td>\[_____________\]</td></tr><tr><td>Подпись заявителя:</td><td>\[_____________\]</td></tr><tr><td>Подпись Руководителя Исследований:</td><td>\[_____________\]</td></tr><tr><td>Подпись выполняющего установку имплантата:</td><td>\[_____________\]</td></tr></table>"

// MARK: Общие формы

/obj/item/paper/form/NT_BLANK
	name = "Форма NT"
	id = "NT-BLANK"
	altername = "Пустой бланк для любых целей"
	category = "Общие формы"
	default_raw_text = "<center><h3>Основная информация</h3></center>\n<table><tr><td>Имя заявителя:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта заявителя:<br><small>Эта информация есть в ваших заметках</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr></table>\n<hr>\n<center><h3>Заявление</h3></center>\n\[___________________________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись заявителя:</td><td>\[_____________\]</td></tr><tr><td>Подпись главы персонала:</td><td>\[_____________\]</td></tr><tr><td>Подпись (дополнительная):</td><td>\[_____________\]</td></tr></table>"

/obj/item/paper/form/NT_E_112
	name = "Форма NT-E-112"
	id = "NT-E-112"
	altername = "Экстренное письмо"
	category = "Общие формы"
	notice = "Форма предназначена только для экстренного использования."
	default_raw_text = "<center><h3>Основная информация</h3></center>\n<table><tr><td>Имя заявителя:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта заявителя:<br><small>Эта информация есть в ваших заметках</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr></table>\n<hr>\n<center><h3>Отчёт о ситуации</h3></center>\n\[___________________________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись уполномоченного лица:</td><td>\[_____________\]</td></tr><tr><td>Должность уполномоченного лица:</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_signstamp

// MARK: Отдел кадров

/obj/item/paper/form/NT_HR_00
	name = "Форма NT-HR-00"
	id = "NT-HR-00"
	altername = "Бланк заявления"
	category = "Отдел кадров"
	default_raw_text = "<center><h3>Основная информация</h3></center>\n<table><tr><td>Имя заявителя:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта заявителя:<br><small>Эта информация есть в ваших заметках</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr></table>\n<hr>\n<center><h3>Заявление</h3></center>\n\[___________________________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись заявителя:</td><td>\[_____________\]</td></tr><tr><td>Подпись главы персонала:</td><td>\[_____________\]</td></tr><tr><td>Подпись (дополнительная):</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_signstamp

/obj/item/paper/form/NT_HR_01
	name = "Форма NT-HR-01"
	id = "NT-HR-01"
	altername = "Заявление о приеме на работу"
	category = "Отдел кадров"
	default_raw_text = "<center><h3>Заявление</h3></center>\n<table><tr><td>Имя заявителя:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта заявителя:<br><small>Эта информация есть в ваших заметках</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr><tr><td>Запрашиваемая должность:<br><small>Требует наличия квалификации</small><br>\[____________________________________\]</td></tr><tr><td>Список компетенций:<br>\[____________________________________\]</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись заявителя:</td><td>\[_____________\]</td></tr><tr><td>Подпись главы персонала:</td><td>\[_____________\]</td></tr><tr><td>Подпись будущего главы:</td><td>\[_____________\]</td></tr></table>"

/obj/item/paper/form/NT_HR_02
	name = "Форма NT-HR-02"
	id = "NT-HR-02"
	altername = "Заявление на смену должности"
	category = "Отдел кадров"
	default_raw_text = "<center><h3>Заявление</h3></center>\n<table><tr><td>Имя заявителя:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта заявителя:<br><small>Эта информация есть в ваших заметках</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr><tr><td>Запрашиваемая должность:<br><small>Требует наличия квалификации</small><br>\[____________________________________\]</td></tr><tr><td>Причина:<br><small>Объясните свои намерения</small><br>\[___________________________________________________\]</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись заявителя:</td><td>\[_____________\]</td></tr><tr><td>Подпись главы персонала:</td><td>\[_____________\]</td></tr><tr><td>Подпись текущего главы:</td><td>\[_____________\]</td></tr><tr><td>Подпись будущего главы:</td><td>\[_____________\]</td></tr></table>"

/obj/item/paper/form/NT_HR_12
	name = "Форма NT-HR-12"
	id = "NT-HR-12"
	altername = "Приказ на смену должности"
	category = "Отдел кадров"
	default_raw_text = "<center><h3>Приказ</h3></center>\n<table><tr><td>Имя сотрудника:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта сотрудника:<br><small>Эта информация есть у главы персонала</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr><tr><td>Запрашиваемая должность:<br><small>Требует наличия квалификации</small><br>\[____________________________________\]</td></tr><tr><td>Причина:<br><small>Объясните свои намерения</small><br>\[___________________________________________________\]</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись инициатора:</td><td>\[_____________\]</td></tr><tr><td>Подпись главы персонала:</td><td>\[_____________\]</td></tr></table>"

/obj/item/paper/form/NT_HR_03
	name = "Форма NT-HR-03"
	id = "NT-HR-03"
	altername = "Заявление об увольнении"
	category = "Отдел кадров"
	default_raw_text = "<center><h3>Заявление</h3></center>\n<table><tr><td>Имя заявителя:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта заявителя:<br><small>Эта информация есть в ваших заметках</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr><tr><td>Причина:<br><small>Объясните свои намерения</small><br>\[___________________________________________________\]</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись заявителя:</td><td>\[_____________\]</td></tr><tr><td>Подпись главы персонала:</td><td>\[_____________\]</td></tr><tr><td>Подпись текущего главы:</td><td>\[_____________\]</td></tr></table>"

/obj/item/paper/form/NT_HR_13
	name = "Форма NT-HR-13"
	id = "NT-HR-13"
	altername = "Приказ об увольнении"
	category = "Отдел кадров"
	default_raw_text = "<center><h3>Приказ</h3></center>\n<table><tr><td>Имя увольняемого:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта увольняемого:<br><small>Эта информация есть у главы персонала</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr><tr><td>Причина:<br><small>Объясните свои намерения</small><br>\[___________________________________________________\]</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись инициатора:</td><td>\[_____________\]</td></tr><tr><td>Подпись главы персонала:</td><td>\[_____________\]</td></tr></table>"

/obj/item/paper/form/NT_HR_04
	name = "Форма NT-HR-04"
	id = "NT-HR-04"
	altername = "Заявление на выдачу новой ID карты"
	category = "Отдел кадров"
	default_raw_text = "<center><h3>Заявление</h3></center>\n<table><tr><td>Имя заявителя:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта заявителя:<br><small>Эта информация есть в ваших заметках</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr><tr><td>Причина:<br><small>Объясните свои намерения</small><br>\[___________________________________________________\]</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись заявителя:</td><td>\[_____________\]</td></tr><tr><td>Подпись главы персонала:</td><td>\[_____________\]</td></tr></table>"

/obj/item/paper/form/NT_HR_05
	name = "Форма NT-HR-05"
	id = "NT-HR-05"
	altername = "Заявление на дополнительный доступ"
	category = "Отдел кадров"
	default_raw_text = "<center><h3>Заявление</h3></center>\n<table><tr><td>Имя заявителя:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта заявителя:<br><small>Эта информация есть в ваших заметках</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr><tr><td>Требуемый доступ:<br><small>Может требовать дополнительного согласования</small><br>\[____________________________________\]</td></tr><tr><td>Причина:<br><small>Объясните свои намерения</small><br>\[___________________________________________________\]</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись заявителя:</td><td>\[_____________\]</td></tr><tr><td>Подпись главы персонала:</td><td>\[_____________\]</td></tr><tr><td>Подпись текущего главы:</td><td>\[_____________\]</td></tr></table>"

/obj/item/paper/form/NT_HR_06
	name = "Форма NT-HR-06"
	id = "NT-HR-06"
	altername = "Лицензия на создание организации/отдела"
	category = "Отдел кадров"
	default_raw_text = "<center><h3>Заявление</h3></center>\n\nЯ, **\[_____________\]**, прошу Вашего разрешения на создание **\[_____________\]** для работы с экипажем.\n\nНаше Агентство/Отдел займет **\[_____________\]**.\n\nНаша Организация обязуется соблюдать Космический Закон. Также я, **\[_____________\]**, как глава отдела, буду нести ответственность за своих сотрудников и обязуюсь наказывать их за несоблюдение Космического Закона или же передавать сотрудникам Службы Безопасности.\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\n*Время: \[_____________\]*\n*Подпись заявителя: \[_____________\]*\n*Подпись главы персонала: \[_____________\]*\n<hr><small>Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан обладателю лицензии.\nДанная форма документа обязательно должна подтверждаться печатью ответственного лица. В случае наличия опечаток и отсутствия подписей или печатей лицензия будет являться недействительной.</small>"

/obj/item/paper/form/NT_HR_07
	name = "Форма NT-HR-07"
	id = "NT-HR-07"
	altername = "Разрешение на перестройку/перестановку"
	category = "Отдел кадров"
	default_raw_text = "<center><h3>Разрешение</h3></center>\n\nЯ, **\[_____________\]**, прошу Вашего разрешения на перестройку/перестановку помещения **\[_____________\]** под свои нужды или нужды организации.\n\nДолжность заявителя: \[_____________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\n*Время: \[_____________\]*\n*Подпись заявителя: \[_____________\]*\n*Подпись главы персонала: \[_____________\]*\n<hr><small>Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан заявителю.</small>"

/obj/item/paper/form/NT_HR_08
	name = "Форма NT-HR-08"
	id = "NT-HR-08"
	altername = "Запрос о постройке меха"
	category = "Отдел кадров"
	default_raw_text = "⠀⠀⠀Я, \[_____________\], прошу произвести постройку меха — **\[_____________\]**, с данными модификациями — \n*\[_____________\]*, для выполнения задач:\n*\[_____________\]*.\n⠀⠀⠀\n\nТакже я, \[_____________\], обязуюсь соблюдать все правила, законы и предупреждения, а также соглашаюсь выполнять все устные или письменные инструкции или приказы со стороны командования, представителей или агентов Nanotrasen и Центрального командования.\n⠀⠀⠀При получении меха я становлюсь ответственным за его повреждение, уничтожение, похищение или попадание в руки людей, относящихся к врагам Nanotrasen.\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись заявителя: \n\[_____________\]\nВремя постройки меха: \n\[_____________\]\nВремя передачи меха заявителю:\n\[_____________\]\nПодпись изготовителя меха:\n\[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и выдаче заявителю.</small>"

/obj/item/paper/form/NT_HR_09
	name = "Форма NT-HR-09"
	id = "NT-HR-09"
	altername = "Квитанция о продаже пода"
	category = "Отдел кадров"
	default_raw_text = "⠀⠀⠀Я, \[_____________\], в должности —\n\[_____________\] произвожу передачу транспортного средства на платной основе члену экипажа \[_____________\], в должности —\n\[_____________\]. Продаваемый под имеет модификации: \n\[_____________\]. Стоимость пода: \n**\[_____________\]**.\n⠀⠀⠀\nЯ, \[_____________\], как покупатель, становлюсь ответственным за его повреждение, уничтожение, похищение или попадание в руки людей, относящихся к врагам Nanotrasen.\n⠀⠀⠀Также я обязуюсь соблюдать все правила, законы и предупреждения, а также соглашаюсь выполнять все устные или письменные инструкции или приказы со стороны командования, представителей или агентов Nanotrasen и Центрального командования.\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись продавца: \[_____________\]\nПодпись покупателя: \[_____________\]\nВремя сделки: \[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и выдаче покупателю.</small>"

// MARK: Отдел сервиса

/obj/item/paper/form/NT_MR
	name = "Форма NT-MR"
	id = "NT-MR"
	altername = "Свидетельство о заключении брака"
	category = "Отдел сервиса"
	default_raw_text = "⠀⠀⠀Объявляется, что \[_____________\], и\n\[_____________\], официально прошли процедуру заключения гражданского брака.\n<hr>\n<center><h3>Подписи и штампы</h3></center>\nПодпись уполномоченного:\n\[_____________\]\nПодпись свидетеля:\n\[_____________\]\nПодпись свидетеля:\n\[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и выдаче одному из представителей брака.\nПри заявлении о расторжении брака необходимо наличие двух супругов и данного документа.</small>"

/obj/item/paper/form/NT_MRL
	name = "Форма NT-MRL"
	id = "NT-MRL"
	altername = "Заявление о расторжении брака"
	category = "Отдел сервиса"
	default_raw_text = "⠀⠀⠀Просим произвести регистрацию расторжения брака, подтверждаем взаимное согласие на расторжение брака.\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись супруга: \[_____________\]\nПодпись супруги: \[_____________\]\n\nПодпись уполномоченного:\n\[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и выдаче каждому из супругов.</small>"

// MARK: Отдел снабжения

/obj/item/paper/form/NT_REQ_01
	name = "Форма NT-REQ-01"
	id = "NT-REQ-01"
	altername = "Запрос на поставку"
	category = "Отдел снабжения"
	default_raw_text = "<center><h3>Сторона запроса</h3></center>\n<table><tr><td>Имя запросившего:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта:<br><small>Эта информация есть в ваших заметках</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr><tr><td>Способ получения:<br><small>Предпочитаемый способ</small><br>\[____________________________________\]</td></tr><tr><td>Причина запроса:<br>\[___________________________________________________\]</td></tr><tr><td>Список запроса:<br>\[___________________________________________________\]</td></tr></table>\n<hr>\n<center><h3>Сторона поставки</h3></center>\n<table><tr><td>Имя поставщика:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта:<br><small>Эта информация есть в ваших заметках</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr><tr><td>Способ доставки:<br><small>Утверждённый способ</small><br>\[____________________________________\]</td></tr><tr><td>Комментарии:<br>\[_____________\]</td></tr><tr><td>Список поставки и цены:<br>\[_____________\]</td></tr><tr><td>Итоговая стоимость:<br><small>Пропустите, если бесплатно</small><br>\[____________________________________\]</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись стороны запроса:</td><td>\[_____________\]</td></tr><tr><td>Подпись стороны поставки:</td><td>\[_____________\]</td></tr><tr><td>Подпись главы (если требуется):</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_signstamp

/obj/item/paper/form/NT_SUP_01
	name = "Форма NT-SUP-01"
	id = "NT-SUP-01"
	altername = "Регистрационная форма для подтверждения заказа"
	category = "Отдел снабжения"
	default_raw_text = "<center><h3>Отдел снабжения</h3></center>\n<center>**Регистрационная форма для подтверждения заказа**</center>\n\nИмя заявителя: \[_____________\]\nДолжность заявителя: \[_____________\]\nПодробное объяснение о необходимости заказа:\n\[___________________________________________________\]\n\nВремя: \[_____________\]\nПодпись заявителя: \[_____________\]\nПодпись руководителя: \[_____________\]\nПодпись сотрудника снабжения:\n\[_____________\]\n<hr><small>Данная форма является приложением для оригинального автоматического документа, полученного с рук заявителя. Для подтверждения заказа заявителя необходимы указанные подписи и соответствующие печати отдела по заказу.</small>"

// MARK: Служба безопасности

/obj/item/paper/form/NT_SEC_01
	name = "Форма NT-SEC-01"
	id = "NT-SEC-01"
	altername = "Свидетельские показания"
	category = "Служба безопасности"
	default_raw_text = "<center><h3>Информация о свидетеле</h3></center>\n<table><tr><td>Имя свидетеля:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта свидетеля:<br><small>Эта информация есть у главы персонала</small><br>\[____________________________________\]</td></tr><tr><td>Должность свидетеля:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr></table>\n<hr>\n<center><h3>Свидетельство</h3></center>\n\[___________________________________________________\]\n\n<small>Я, (подпись свидетеля) \[_____________\], подтверждаю, что приведенная выше информация является правдивой и точной, насколько мне известно, и передана в меру моих возможностей. Подписываясь ниже, я тем самым подтверждаю, что Верховный Суд может признать меня неуважительным или виновным в лжесвидетельстве согласно Закону SolGov 552 (a) (c) и Постановлению корпорации Nanotrasen 7716 (c).</small>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись сотрудника, получающего показания:</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_SEC_11
	name = "Форма NT-SEC-11"
	id = "NT-SEC-11"
	altername = "Ордер на обыск"
	category = "Служба безопасности"
	default_raw_text = "<center><h3>Информация о свидетеле</h3></center>\n<table><tr><td>Имя свидетеля:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта свидетеля:<br><small>Эта информация есть у главы персонала</small><br>\[____________________________________\]</td></tr><tr><td>Должность свидетеля:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr></table>\n<hr>\n<center><h3>Ордер</h3></center>\n<table><tr><td>В целях обыска:<br><small>(помещения, имущества, лица)</small><br>\[____________________________________\]</td></tr></table>\n\nОзнакомившись с письменными показаниями свидетеля(-ей), у меня появились основания полагать, что на лицах или помещениях, указанных выше, имеются соответствующие доказательства в этой связи или в пределах, в частности:\n\n\[___________________________________________________\]\n\nи другое имущество, являющееся доказательством уголовного преступления, контрабанды, плодов преступления или предметов, иным образом принадлежащих преступнику, или имущество, спроектированное или предназначенное для использования, или которое используется или использовалось в качестве средства совершения уголовного преступления, в частности заговор с целью совершения преступления, или совершения злонамеренного предъявления ложных и фиктивных претензий к или против корпорации \"Нанотрейзен\" или его дочерних компаний.\n\nЯ удовлетворен тем, что показания под присягой и любые записанные показания устанавливают вероятную причину полагать, что описанное имущество в данный момент скрыто в описанных выше помещениях, лицах или имуществе, и устанавливают законные основания для выдачи этого ордера.\n\nВЫ НАСТОЯЩИМ КОМАНДИРОВАНЫ для обыска вышеуказанного помещения, имущества или лица в течение \[_____________\] минут с даты выдачи настоящего ордера на указанное скрытое имущество, и если будет установлено, что имущество изъято, оставить копию этого ордера в качестве доказательства на реквизированную собственность, в соответствии с требованиями указа корпорации Nanotrasen.\n\nСлава Корпорации Nanotrasen!\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись уполномоченного лица:</td><td>\[_____________\]</td></tr><tr><td>Должность уполномоченного лица:</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_SEC_21
	name = "Форма NT-SEC-21"
	id = "NT-SEC-21"
	altername = "Ордер на арест"
	category = "Служба безопасности"
	default_raw_text = "<center><h3>Ордер</h3></center>\n<table><tr><td>В целях ареста:<br><small>Имя полностью и без ошибок</small><br>\[__________________________\]</td></tr><tr><td>Должность:</td><td>\[_____________\]</td></tr></table>\n\nСотрудники Службы Безопасности настоящим уполномочены и направлены на задержание и арест указанного лица. Они будут игнорировать любые заявления о неприкосновенности или привилегии со стороны подозреваемого или агентов, действующих от его имени. Сотрудники немедленно доставят указанное лицо в Бриг для отбывания наказания за следующие преступления:\n\n\[___________________________________________________\]\n\nПредполагается, что подозреваемый будет отбывать наказание в \[_____________\] за вышеуказанные преступления.\n\nСлава Корпорации Nanotrasen!\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись уполномоченного лица:</td><td>\[_____________\]</td></tr><tr><td>Должность уполномоченного лица:</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_SEC_02
	name = "Форма NT-SEC-02"
	id = "NT-SEC-02"
	altername = "Отчёт по результатам расследования"
	category = "Служба безопасности"
	default_raw_text = "<center><h3>Дело \[_____________\]</h3></center>\n<table><tr><td>Тип происшествия/преступления:</td><td>\[_____________\]</td></tr><tr><td>Время происшествия/преступления:</td><td>\[_____________\]</td></tr><tr><td>Местоположение:</td><td>\[_____________\]</td></tr><tr><td>Краткое описание:</td><td>\[_____________\]</td></tr></table>\n<hr>\n<center><h3>Участвующие лица</h3></center>\n<table><tr><td>Арестованные:</td><td>\[_____________\]</td></tr><tr><td>Подозреваемые:</td><td>\[_____________\]</td></tr><tr><td>Свидетели:</td><td>\[_____________\]</td></tr><tr><td>Раненые:</td><td>\[_____________\]</td></tr><tr><td>Пропавшие:</td><td>\[_____________\]</td></tr><tr><td>Скончавшиеся:</td><td>\[_____________\]</td></tr></table>\n<hr>\n<center><h3>Ход расследования</h3></center>\n\[___________________________________________________\]\n\n<table><tr><td>Прикреплённые доказательства:</td><td>\[_______________________\]</td></tr><tr><td>Дополнительные замечания:</td><td>\[_____________\]</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись уполномоченного лица:</td><td>\[_____________\]</td></tr><tr><td>Должность уполномоченного лица:</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_SEC_03
	name = "Форма NT-SEC-03"
	id = "NT-SEC-03"
	altername = "Заявление о краже"
	category = "Служба безопасности"
	default_raw_text = "⠀⠀⠀Я, \[_____________\], в должности \[_____________\], заявляю:\n\[___________________________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись потерпевшего:\n\[_____________\]\nПодпись принимавшего заявление:\n\[_____________\]\nВремя принятия заявления:\n\[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и выдаче потерпевшему.\nПри обнаружении предмета кражи (предмет, жидкость или существо), данный предмет необходимо передать детективу для дальнейшего осмотра и обследования.\nПосле заключения детектива предмет можно выдать владельцу.</small>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_SEC_04
	name = "Форма NT-SEC-04"
	id = "NT-SEC-04"
	altername = "Заявление о причинении вреда здоровью или имуществу"
	category = "Служба безопасности"
	default_raw_text = "⠀⠀⠀Я, \[_____________\], в должности \[_____________\], заявляю:\n\[___________________________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись пострадавшего:\n\[_____________\]\nВремя происшествия:\n\[_____________\]\nПодпись уполномоченного:\n\[_____________\]\nВремя принятия заявления:\n\[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и выдаче пострадавшему.</small>"
	footer_text = footer_confidential
/obj/item/paper/form/NT_SEC_05
	name = "Форма NT-SEC-05"
	id = "NT-SEC-05"
	altername = "Разрешение на оружие"
	category = "Служба безопасности"
	default_raw_text = "⠀⠀⠀Члену экипажа, \[_____________\], в должности\n\[_____________\], было выдано разрешение на оружие. Я соглашаюсь с условиями его использования, хранения и применения. Данное оружие я обязуюсь применять только в целях самообороны, защиты своих личных вещей и рабочего места, а также для защиты своих коллег.\n⠀⠀⠀При попытке применения оружия против остальных членов экипажа, не представляющих угрозу, или при запугивании данным оружием, я лишаюсь лицензии на оружие, а также понесу наказание при нарушении закона.\n\n**Название и тип оружия:**\n\[_____________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись уполномоченного:\n\[_____________\]\nПодпись получателя: \n\[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и выдаче получателю.\nДокумент не является действительным без печати Вардена/ГСБ и его подписи.</small>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_SEC_06
	name = "Форма NT-SEC-06"
	id = "NT-SEC-06"
	altername = "Разрешение на присваивание канала связи"
	category = "Служба безопасности"
	default_raw_text = "<center><h3>Разрешение</h3></center>\n\nЯ, **\[_____________\]**, прошу Вашего разрешения на присваивание канала связи **\[_____________\]** для грамотной работы организации.\n\nДолжность заявителя: \[_____________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\n*Время: \[_____________\]*\n*Подпись заявителя: \[_____________\]*\n*Подпись главы персонала: \[_____________\]*\n*Подпись главы службы безопасности:*\n*\[_____________\]*\n<hr><small>Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан заявителю.\nОбязательно провести копирование документа для службы безопасности.</small>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_SEC_07
	name = "Форма NT-SEC-07"
	id = "NT-SEC-07"
	altername = "Лицензия на использование канала связи и владение дополнительным оборудованием"
	category = "Служба безопасности"
	default_raw_text = "<center><h3>Лицензия</h3></center>\n\nИмя обладателя лицензии:\n\[_____________\]\nДолжность обладателя лицензии:\n\[_____________\]\nЗарегистрированный канал связи:\n\[_____________\]\nПеречень зарегистрированной экипировки:\n\[_____________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\n*Время: \[_____________\]*\n*Подпись заявителя: \[_____________\]*\n*Подпись главы персонала: \[_____________\]*\n*Подпись главы службы безопасности:*\n*\[_____________\]*\n<hr><small>Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан обладателю лицензии.\nОбязательно провести копирование документа для службы безопасности.\nДанная форма документа обязательно должна подтверждаться печатью ответственного лица. В случае наличия опечаток и отсутствия подписей или печатей лицензия будет являться недействительной.</small>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_SEC_08
	name = "Форма NT-SEC-08"
	id = "NT-SEC-08"
	altername = "Лицензирование вооружения и экипировки для исполнения деятельности"
	category = "Служба безопасности"
	default_raw_text = "<center><h3>Лицензия</h3></center>\n\nИмя обладателя лицензии:\n\[_____________\]\nДолжность обладателя лицензии:\n\[_____________\]\nПеречень зарегистрированного вооружения:\n\[_____________\]\nПеречень зарегистрированной экипировки:\n\[_____________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nВремя: \n\[_____________\]\nПодпись обладателя лицензии:\n\[_____________\]\nПодпись главы службы безопасности:\n\[_____________\]\n<hr><small>Данная форма документа обязательно должна подтверждаться печатью ответственного лица. В случае наличия опечаток и отсутствия подписей или печатей лицензия будет являться недействительной. Обязательно провести копирование документа для службы безопасности, оригинал документа должен быть выдан обладателю лицензии. В случае несоответствия должности обладателя лицензии можно приступить к процедуре аннулирования лицензии и изъятию вооружения, экипировки.</small>"
	footer_text = footer_confidential

// MARK: Юридический отдел

/obj/item/paper/form/NT_LD_00
	name = "Форма NT-LD-00"
	id = "NT-LD-00"
	altername = "Бланк заявления"
	category = "Юридический отдел"
	default_raw_text = "<center><h3>Основная информация</h3></center>\n<table><tr><td>Имя заявителя:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Номер аккаунта заявителя:<br><small>Эта информация есть в ваших заметках</small><br>\[____________________________________\]</td></tr><tr><td>Текущая должность:<br><small>Указано на ID карте</small><br>\[____________________________________\]</td></tr></table>\n<hr>\n<center><h3>Заявление</h3></center>\n\[___________________________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись заявителя:</td><td>\[_____________\]</td></tr><tr><td>Подпись уполномоченного сотрудника:</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_signstamp

/obj/item/paper/form/NT_LD_01
	name = "Форма NT-LD-01"
	id = "NT-LD-01"
	altername = "Судебный приговор"
	category = "Юридический отдел"
	notice = "Данный документ является законным решением суда.<br>Пожалуйста внимательно прочитайте его и следуйте предписаниям, указанные в нем."
	default_raw_text = "<center><h3>Дело \[_____________\]</h3></center>\n<table><tr><td>Имя обвинителя:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr><tr><td>Имя обвиняемого:<br><small>Полностью и без ошибок</small><br>\[____________________________________\]</td></tr></table>\n<hr>\n<center><h3>Приговор</h3></center>\n\[___________________________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись уполномоченного лица:</td><td>\[_____________\]</td></tr><tr><td>Должность уполномоченного лица:</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_LD_02
	name = "Форма NT-LD-02"
	id = "NT-LD-02"
	altername = "Смертный приговор"
	category = "Юридический отдел"
	notice = "Любой смертный приговор, выданный человеком, званием младше, чем капитан, является не действительным, и все казни, действующие от этого приговора являются незаконными. Любой, кто незаконно привел в исполнение смертный приговор действую согласно ложному ордену виновен в убийстве первой степени, и должен быть приговорен минимум к пожизненному заключению и максимум к кибернизации. Этот документ или его факс-копия являются Приговором, который может оспорить только Магистрат или Дивизией защиты активов Nanotrasen (далее именуемой «Компанией»)"
	default_raw_text = "<center><h3>Дело \[_____________\]</h3></center>\n\nПринимая во внимание, что \[_____________\] <small>(далее именуемый \"подсудимый\")</small>, сознательно совершил преступления статей Космического закона <small>(далее указаны как \"преступления\")</small>, а именно:\n\[_____________\],\nсуд приговаривает подсудимого к смертной казни через \[____________________________________\].\n\nПриговор должен быть приведен в исполнение в течение 15 минут после получения данного приказа. Вещи подсудимого, включая ID-карту, ПДА, униформу и рюкзак, должны быть сохранены и переданы соответствующим органам (ID-карту передать главе персонала или капитану для уничтожения), возвращены в соответствующий отдел или сложены в хранилище улик. Любая контрабанда должна быть немедленно помещена в хранилище улик. Любую контрабанду запрещено использовать защитой активов или другими персонами, представляющими компанию или её активы и цели, кроме сотрудников отдела исследований и развития.\n\nТело подсудимого должно быть помещено в морг и забальзамировано, только если данное действие не будет нести опасность станции, активам компании или её имуществу. Останки подсудимого должны быть собраны и подготовлены к доставке к близлежащему административному центру компании, всё имущество и активы должны быть переданы семье подсудимого после окончания смены.\n\nСлава Nanotrasen!\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись уполномоченного лица:</td><td>\[_____________\]</td></tr><tr><td>Должность уполномоченного лица:</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_LD_03
	name = "Форма NT-LD-03"
	id = "NT-LD-03"
	altername = "Заявление о нарушении СРП членом экипажа"
	category = "Юридический отдел"
	default_raw_text = "⠀⠀⠀Я, \[_____________\], в должности —\n\[_____________\], заявляю, что член экипажа — \[_____________\], в должности \[_____________\], нарушил один (или несколько) пунктов из *Стандартных Рабочих Процедур*, а именно:\n\[_____________\]\n\nПримерное время нарушения:\n\[_____________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись заявителя: \n\[_____________\]\nПодпись принимающего: \n\[_____________\]\nВремя принятия заявления:\n\[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и выдаче заявителю.\nПосле вынесения решения в отношении правонарушителя желательно сообщить о решении заявителю.</small>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_LD_04
	name = "Форма NT-LD-04"
	id = "NT-LD-04"
	altername = "Заявление о нарушении СРП одним из отделов"
	category = "Юридический отдел"
	default_raw_text = "⠀⠀⠀Я, \[_____________\], в должности —\n\[_____________\], заявляю, что сотрудники в отделении \[_____________\], нарушили один (или несколько) пунктов из *Стандартных Рабочих Процедур*, а именно:\n\[_____________\]\n\nПримерное время нарушения:\n\[_____________\]\nПодпись заявителя: \n\[_____________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись принимающего: \n\[_____________\]\nВремя принятия заявления:\n\[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и выдаче заявителю.\nПосле вынесения решения в отношении правонарушителей желательно сообщить о решении заявителю.</small>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_LD_05
	name = "Форма NT-LD-05"
	id = "NT-LD-05"
	altername = "Отчет агента внутренних дел"
	category = "Юридический отдел"
	default_raw_text = "ᅠᅠЯ, \[_____________\], как агент внутренних дел, сообщаю:\n\[___________________________________________________\]\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\nПодпись АВД:\n\[_____________\]\nПодпись уполномоченного:\n\[_____________\]\nВремя принятия отчета:\n\[_____________\]\n<hr><small>Данный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и выдаче агенту.\nДанный документ может содержать нарушения, неправильность выполнения работы, невыполнение правил/сводов/законов/СРП.</small>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_LD_06
	name = "Форма NT-LD-06"
	id = "NT-LD-06"
	altername = "Бланк жалоб АВД"
	category = "Юридический отдел"
	default_raw_text = "<center><h3>Заявление</h3></center>\n\n**Заявитель:** \[_____________\]\n<small>Укажите своё полное имя, должность и номер аккаунта.</small>\n\n**Предмет жалобы:** \[_____________\]\n<small>Укажите, на что/кого вы жалуетесь.</small>\n\n**Обстоятельства:** \[_____________\]\n<small>Укажите подробные обстоятельства произошедшего.</small>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n\n**Подпись:** \[_____________\]\n<small>Ваша подпись.</small>\n\n**Жалоба рассмотрена:**\n\[____________________________________\]\n<small>Имя и фамилия рассмотревшего.</small>\n<hr><small>Обязательно провести копирование документа для агента внутренних дел, оригинал документа должен быть приложен к отчету о расследовании. Копия документа должна быть сохранена в картотеке офиса агента внутренних дел.\nОбязательно донести жалобу до главы отдела, который отвечает за данного сотрудника, если таковой имеется. Если главы отдела нет на смене или он отсутствует по какой-то причине, жалобу следует донести до вышестоящего сотрудника станции.\nЕсли жалоба была написана на главу отдела, следует донести жалобу до вышестоящего сотрудника станции.\nГлава отдела, которому была донесена жалоба, обязан провести беседу с указанным в жалобе сотрудником станции. В зависимости от тяжести проступка, глава отдела имеет право подать приказ об увольнении.</small>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_LD_DENY
	name = "Форма NT-LD-DENY"
	id = "NT-LD-DENY"
	altername = "Запрет на реанимацию"
	category = "Юридический отдел"
	default_raw_text = "Я, \[_____________\], в должности \[_____________\], сообщаю о постановлении запрета на реанимацию в отношении:\n\[_____________\]\n<small>Указать имя члена экипажа.</small>\n\nИсходя из того, что вышеупомянутый член экипажа попал под действие особых случаев применения летальной силы, а именно:\n\[___________________________________________________\]\n<small>Описать особый случай применения летальной силы, указанный в СРП СБ.</small>\n\nТело члена экипажа должно быть помещено в морг, ксерокопия данного документа должна находиться в картотеке патологоанатома либо приложена к мешку с трупом подсудимого. Служебное оборудование данного члена экипажа должно быть передано вышестоящему главе отдела. Личные вещи, не нарушающие Космический Закон, должны оставаться вместе с членом экипажа либо в ячейке морга.\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Дата и время:</td><td>\[_____________\]</td></tr><tr><td>Должность уполномоченного лица:</td><td>\[_____________\]</td></tr><tr><td>Подпись уполномоченного лица:</td><td>\[_____________\]</td></tr></table>\n<hr><small>Данный документ является недействительным при отсутствии подписи и печати уполномоченного лица.\nДанный документ подлежит ксерокопированию для сохранения в архиве уполномоченных лиц и хранения одного экземпляра в картотеке патологоанатома либо в мешке для трупов с вышеуказанным членом экипажа.</small>"

// MARK: Центральное командование

/obj/item/paper/form/NT_COM_01
	name = "Форма NT-COM-01"
	id = "NT-COM-01"
	altername = "Запрос отчёта общего состояния станции"
	category = "Центральное командование"
	from = "Административный корабль \"Нанотрейзен\" АКН Трурль"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	default_raw_text = "<center><h3>Запрос</h3></center>\n\nУполномоченный офицер, \[_____________\], в должности \n\[_____________\], запрашивает сведения об общем состоянии станции.\n<hr>\n<center><h3>Ответ</h3></center>\n<table><tr><td>Общее состояние станции:</td><td>\[_____________\]</td></tr><tr><td>Криминальный статус:</td><td>\[_____________\]</td></tr></table>\n<table><tr><td>Повышений:</td><td>\[_____________\]</td></tr><tr><td>Понижений:</td><td>\[_____________\]</td></tr><tr><td>Увольнений:</td><td>\[_____________\]</td></tr></table>\n<table><tr><td>Раненые:</td><td>\[_____________\]</td></tr><tr><td>Пропавшие:</td><td>\[_____________\]</td></tr><tr><td>Скончавшиеся:</td><td>\[_____________\]</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись уполномоченного лица:</td><td>\[_____________\]</td></tr><tr><td>Должность уполномоченного лица:</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_COM_02
	name = "Форма NT-COM-02"
	id = "NT-COM-02"
	altername = "Запрос отчёта состояния трудовых активов станции"
	category = "Центральное командование"
	from = "Административный корабль \"Нанотрейзен\" АКН Трурль"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	default_raw_text = "<center><h3>Запрос</h3></center>\n\nУполномоченный офицер, \[_____________\], в должности \n\[_____________\], запрашивает сведения о состоянии трудовых активов станции.\n<hr>\n<center><h3>Ответ</h3></center>\n<table><tr><td>Количество сотрудников:</td><td>\n\[_____________\]</td></tr><tr><td>Количество гражданских:</td><td>\n\[_____________\]</td></tr><tr><td>Количество киборгов:</td><td>\n\[_____________\]</td></tr><tr><td>Количество ИИ:</td><td>\n\[_____________\]</td></tr></table>\n<table><tr><td>Заявлений о приёме на работу:</td><td>\n\[_____________\]</td></tr><tr><td>Заявлений на смену должности:</td><td>\n\[_____________\]</td></tr><tr><td>Приказов на смену должности:</td><td>\n\[_____________\]</td></tr><tr><td>Заявлений об увольнении:</td><td>\n\[_____________\]</td></tr><tr><td>Приказов об увольнении:</td><td>\n\[_____________\]</td></tr><tr><td>Заявлений на выдачу новой ID карты:</td><td>\n\[_____________\]</td></tr><tr><td>Заявлений на дополнительный доступ:</td><td>\n\[_____________\]</td></tr></table>\n<table><tr><td>Медианный уровень квалификации смены:</td><td>\n\[_____________\]</td></tr><tr><td>Уровень взаимодействия отделов:</td><td>\n\[_____________\]</td></tr><tr><td>Самый продуктивный отдел смены:</td><td>\n\[_____________\]</td></tr></table>\n<table><tr><td>Приложите все имеющиеся документы:</td><td>NT-HR-00</td></tr><tr><td></td><td>NT-HR-01</td></tr><tr><td></td><td>NT-HR-02</td></tr><tr><td></td><td>NT-HR-12</td></tr><tr><td></td><td>NT-HR-03</td></tr><tr><td></td><td>NT-HR-13</td></tr><tr><td></td><td>NT-HR-04</td></tr><tr><td></td><td>NT-HR-05</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись уполномоченного лица:</td><td>\[_____________\]</td></tr><tr><td>Должность уполномоченного лица:</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_COM_03
	name = "Форма NT-COM-03"
	id = "NT-COM-03"
	altername = "Запрос отчёта криминального статуса станции"
	category = "Центральное командование"
	from = "Административный корабль \"Нанотрейзен\" АКН Трурль"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	default_raw_text = "<center><h3>Запрос</h3></center>\n\nУполномоченный офицер, \[_____________\], в должности \n\[_____________\], запрашивает сведения о криминальном статусе станции.\n<hr>\n<center><h3>Ответ</h3></center>\n<table><tr><td>Текущий статус угрозы:</td><td>\[_____________\]</td></tr><tr><td>Количество офицеров в отделе:</td><td>\[_____________\]</td></tr><tr><td>Количество раненых офицеров:</td><td>\[_____________\]</td></tr><tr><td>Количество скончавшихся офицеров:</td><td>\[_____________\]</td></tr><tr><td>Количество серьёзных инцидентов:</td><td>\[_____________\]</td></tr><tr><td>Количество незначительных инцидентов:</td><td>\[_____________\]</td></tr><tr><td>Количество раскрытых дел:</td><td>\[_____________\]</td></tr><tr><td>Количество арестованных:</td><td>\[_____________\]</td></tr><tr><td>Количество сбежавших:</td><td>\[_____________\]</td></tr></table>\n<table><tr><td>Приложите все имеющиеся документы:</td><td>NT-SEC-01</td></tr><tr><td></td><td>NT-SEC-11</td></tr><tr><td></td><td>NT-SEC-21</td></tr><tr><td></td><td>NT-SEC-02</td></tr><tr><td></td><td>Лог камер заключения</td></tr></table>\n<hr>\n<center><h3>Подписи и штампы</h3></center>\n<table><tr><td>Время:</td><td>\[_____________\]</td></tr><tr><td>Подпись уполномоченного лица:</td><td>\[_____________\]</td></tr><tr><td>Должность уполномоченного лица:</td><td>\[_____________\]</td></tr></table>"
	footer_text = footer_confidential

/obj/item/paper/form/NT_COM_04
	name = "Форма NT-COM-04"
	id = "NT-COM-04"
	altername = "Запрос отчёта здравоохранения станции"
	category = "Центральное командование"
	from = "Административный корабль \"Нанотрейзен\" АКН Трурль"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	default_raw_text = "\[___________________________________________________\]"
	footer_text = footer_confidential

/obj/item/paper/form/NT_COM_05
	name = "Форма NT-COM-05"
	id = "NT-COM-05"
	altername = "Запрос отчёта научно-технического прогресса станции"
	category = "Центральное командование"
	from = "Административный корабль \"Нанотрейзен\" АКН Трурль"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	default_raw_text = "\[___________________________________________________\]"
	footer_text = footer_confidential

/obj/item/paper/form/NT_COM_06
	name = "Форма NT-COM-06"
	id = "NT-COM-06"
	altername = "Запрос отчёта инженерного обеспечения станции"
	category = "Центральное командование"
	from = "Административный корабль \"Нанотрейзен\" АКН Трурль"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	default_raw_text = "\[___________________________________________________\]"
	footer_text = footer_confidential

/obj/item/paper/form/NT_COM_07
	name = "Форма NT-COM-07"
	id = "NT-COM-07"
	altername = "Запрос отчёта статуса снабжения станции "
	category = "Центральное командование"
	from = "Административный корабль \"Нанотрейзен\" АКН Трурль"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	default_raw_text = "\[___________________________________________________\]"
	footer_text = footer_confidential

// MARK: Синдикатские формы

/obj/item/paper/form/syndieform
	name = "ALERT A CODER SYND FORM"
	altername = "ALERT A CODER FORM"
	access = ACCESS_SYNDICATE_COMMAND
	confidential = TRUE
	category = null
	syndicate = TRUE
	var/const/footer_to_taipan = "<hr><center><small><i>Несоблюдение и/или нарушение указаний, содержащихся в данном письме, карается смертью.<br>Копирование, распространение и использование содержащейся информации карается смертью, за исключением случаев, описанных в письме.<br>Письмо подлежит уничтожению после ознакомления.</i></small></center>"
	var/const/footer_from_taipan = "<hr><center><small><i>Целевым получателем запроса является Синдикат<br>Копирование, распространение и использование документа и представленной информации за пределами целевого получателя запроса и экипажа станции запрещено.<br>Оригинал документа после отправки целевому получателю подлежит хранению в защищённом месте, либо уничтожению с соответствующим указанием.<br>В случае проникновения на объект посторонних лиц или угрозы проникновения документ подлежит уничтожению до или после отправки.</i></small></center>"
	footer_text = footer_to_taipan

/obj/item/paper/form/syndieform/get_header_text()
	if(!is_header_needed)
		return ""
	return "<table><tr><td>\[logo:syndielogo.png\]</td><td><center><b>[confidential ? "СОВЕРШЕННО СЕКРЕТНО<br>" : ""]</b><b>[id]</b></center></td></tr></table><hr>"

/obj/item/paper/form/syndieform/SYND_COM_TC
	name = "Форма SYND-COM-TC"
	id = "SYND-COM-TC"
	altername = "Официальное письмо"
	category = "Синдикат"
	default_raw_text = "\
		<center><h2><u>Официальное письмо объекту</u><br>\"ННКСС Тайпан\"</h2></center><hr>\
		\[______________________\]\n\n\
		<small>\
		Подпись: \[_____________\], в должности \[_____________\]\n\
		Дата: \[_____________\]\n\
		Время: \[_____________\]\
		</small>"

/obj/item/paper/form/syndieform/SYND_COM_SUP
	name = "Форма SYND-COM-SUP"
	id = "SYND-COM-SUP"
	altername = "Запрос особой доставки"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer_text = footer_from_taipan
	default_raw_text = "\
		<center><h2>Запрос особой доставки на станцию<br>\"Синдиката\"</h2></center><hr>\
		<center>\
		<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>\
		<tr>\
		<td><center><b>Данные<br>для<br>доставки</b></center></td>\
		<td>\
		<center><b><u>Получатель</u></b></center>\
		<u>Наименование станции</u>: \"ННКСС <b>Тайпан</b>\"<br>\
		<u>Наименование сектора</u>: Эпсилон Лукусты\
		</td>\
		</tr>\
		</table>\
		</center>\n\n\
		В связи с отсутствием в стандартном перечне заказов прошу доставить следующее:\n\
		<ul><li><u>\[_____________\]</u></li></ul>\n\
		Причина запроса:\n\
		**\[_____________\]**\n\n\
		<small>\
		Подпись: \[_____________\], в должности \[_____________\]\n\
		Дата: \[_____________\]\n\
		Время: \[_____________\]\
		</small>"

/obj/item/paper/form/syndieform/SYND_TAI_NO00
	name = "Форма SYND-TAI-№00"
	id = "SYND-TAI-№00"
	altername = "Экстренное письмо"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer_text = footer_from_taipan
	default_raw_text = "\
		<center><h2><u>Экстренное письмо</u><br>ННКСС \"Тайпан\"</h2></center><hr>\
		\[______________________\]\n\n\
		<small>\
		Подпись: \[_____________\], в должности \[_____________\]\n\
		Дата: \[_____________\]\n\
		Время: \[_____________\]\
		</small>"

/obj/item/paper/form/syndieform/SYND_TAI_NO01
	name = "Форма SYND-TAI-№01"
	id = "SYND-TAI-№01"
	altername = "Отчёт о ситуации на станции"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer_text = footer_from_taipan
	default_raw_text = "\
		<h3>Отчёт о ситуации на станции</h3><hr>\
		<u>Наименование станции</u>: ННКСС \"Тайпан\"\n\n\
		Общее состояние станции:\n\
		\[_____________\]\n\
		Численность персонала станции:\n\
		\[_____________\]\n\
		Общее состояние персонала станции:\n\
		\[_____________\]\n\
		Непосредственные внешние угрозы:\n\
		**\[_____________\]**\n\
		Подробности: \n\[_______________________\]\n\
		Дополнительная информация:\n\
		\[_____________\]\n\n\
		<small>\
		Подпись: \[_____________\], в должности \[_____________\]\n\
		Дата: \[_____________\]\n\
		Время: \[_____________\]\
		</small>"

/obj/item/paper/form/syndieform/SYND_TAI_NO02
	name = "Форма SYND-TAI-№02"
	id = "SYND-TAI-№02"
	altername = "Отчёт о разработке вируса"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer_text = footer_from_taipan
	default_raw_text = "\
		<h3>Отчёт о разработке вируса</h3><hr>\
		<u>Наименование вируса</u>: **\[_____________\]**\n\n\
		Тип вируса: \[_____________\]\n\
		Способ распространения: \[_____________\]\n\
		Перечень симптомов: \[_____________\]\n\
		Описание: \[_____________\]\n\n\
		<u>Наличие вакцины</u>: **\[_____________\]**\n\
		<u>Наименование вакцины</u>: \[_____________\]\n\n\
		Дополнительная информация: \[_____________\]\n\
		Указания к хранению вируса:\n\
		\[_____________\]\n\n\
		<small>\
		Подпись разработчика: \[_____________\], в должности **\[_____________\]**\n\
		Подпись Директора Исследований:\n\
		\[_____________\]\n\
		Дата: \[_____________\]\n\
		Время: \[_____________\]\
		</small>\n\
		<hr><small>\
		Отчёт недействителен без подписи Директора Исследований. В случае его отсутствия требуется подпись Офицера Телекоммуникаций или заменяющего его лица с указанием должности.\n\
		Заполняется Директором Исследований. В случае его отсутствия заполняется Офицером Телекоммуникаций или заменяющим его лицом.\
		</small>"

/obj/item/paper/pamphletdeathsquad
	icon_state = "pamphlet-ds"

/obj/item/paper/pamphletdeathsquad/update_icon_state()
	return

/obj/item/paper/mortar
	name = "Инструкция по сборке снаряда для мортиры"
	default_raw_text = "**Инструкция по сборке снаряда для мортиры**</br>\
	1) Для начала соберите боевую часть. Для этого нужно вставить минимум один(максимум 2) бикер, с нужными вам реагентами.</br>\
	Помните: у снаряда есть ограничения по вместимости бикеров(50 с камерой и 100 без)</br>\
	2) После того, как вставите нужные бикеры, закрутите крышку отверткой.</br> \
	Внимание: Не рекомендуется пытаться раскрутить крышку после сборки. Это приведет к преждевременному смешению содержимого.</br> \
	3) Затем необходимо вставить собраную боевую часть в корпус снаряда.</br> \
	4) Затем вставьте в корпус бикер с топливом(минимум 60 юнитов). Наши снаряды используют водород в качестве оного</br> \
	5) После этого можно завершить сборку снаряда, закрутив крышку отверткой \
	"
