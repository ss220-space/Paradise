/**
 * Everything is sorted as recorded in chat-default.scss, so please observe the sorting when adding new define.
 * There are the same MARKS here as in chat-default.scss to simplify navigation.
 * All defines are renamed. Now they are named the same as their classes.
 */

/**
 * MARK: Without CSS
 * Are these chat selectors?
 */
#define span_adminnotice(str) ("<span class='adminnotice'>" + str + "</span>")
#define span_unconscious(str) ("<span class='unconscious'>" + str + "</span>")
#define span_emojienabled(str) ("<span class='emoji_enabled'>" + str + "</span>")
#define span_header(str) ("<span class='header'>" + str + "</span>")
#define span_linkoff(str) ("<span class='linkOff'>" + str + "</span>")
#define span_linkon(str) ("<span class='linkOn'>" + str + "</span>")
#define span_error(str) ("<span class='error'>" + str + "</span>")
#define span_gamesay(str) ("<span class='game say'>" + str + "</span>")
#define span_message(str) ("<span class='message'>" + str + "</span>")
#define span_boldmessage(str) ("<span class='boldmessage'>" + str + "</span>")
#define span_combatdanger(str) ("<span class='combat danger'>" + str + "</span>")
#define span_combatuserdanger(str) ("<span class='combat userdanger'>" + str + "</span>")
#define span_small(str) ("<span class='small'>" + str + "</span>")
#define span_game_emote(str) ("<span class='game emote'>" + str + "</span>")
#define span_vnimanie(str) ("<span class='ВНИМАНИЕ'>" + str + "</span>")
#define span_holoparasite(str) ("<span class='holoparasite'>" + str + "</span>")
#define span_hear(str) ("<span class='hear'>" + str + "</span>")
#define span_greenannounce(str) ("<span class='greenannounce'>" + str + "</span>")
#define span_caution(str) ("<span class='caution'>" + str + "</span>")
#define span_boldannounceic(str) ("<span class='boldannounceic'>" + str + "</span>")
#define span_boldannounceooc(str) ("<span class='boldannounceooc'>" + str + "</span>")
#define span_announce(str) ("<span class='announce'>" + str + "</span>")

/**
 * MARK: GENERAL STUFF
 */
#define span_italics(str) ("<span class='italic'>" + str + "</span>")
#define span_bold(str) ("<span class='bold'>" + str + "</span>")
#define span_bolditalics(str) ("<span class='bolditalics'>" + str + "</span>")
#define span_big(str) ("<span class='big'>" + str + "</span>")
#define span_bigbold(str) ("<span class='big bold'>" + str + "</span>")
#define span_reallybig(str) ("<span class='reallybig'>" + str + "</span>")
#define span_sans(str) ("<span class='sans'>" + str + "</span>")
#define span_wingdings(str) ("<span class='wingdings'>" + str + "</span>")
#define span_robot(str) ("<span class='robot'>" + str + "</span>")

/**
 * MARK: MOTD & MEMO
 */
#define span_motd(str) ("<span class='motd'>" + str + "</span>")
#define span_memo(str) ("<span class='memo'>" + str + "</span>")
#define span_memoedit(str) ("<span class='memoedit'>" + str + "</span>")

/**
 * MARK: General colors
 * TODO: Combine everything just bold fonts (prefix, yell, name, ooc etc.).
 */
#define span_ooc(str) ("<span class='ooc'>" + str + "</span>")
#define span_looc(str) ("<span class='looc'>" + str + "</span>")
#define span_discordpm(str) ("<span class='discordpm'>" + str + "</span>")
#define span_debug(str) ("<span class='debug'>" + str + "</span>")
#define span_deadsay(str) ("<span class='deadsay'>" + str + "</span>")
#define span_darkmblue(str) ("<span class='darkmblue'>" + str + "</span>")
#define span_prefix(str) ("<span class='prefix'>" + str + "</span>")
#define span_name(str) ("<span class='name'>" + str + "</span>")
#define span_yell(str) ("<span class='yell'>" + str + "</span>")

/**
 * MARK: Base colors
 * All new style colors must be converted to the corresponding span and written as class.
 */
#define span_red(str) ("<span class='red'>" + str + "</span>")
#define span_green(str) ("<span class='green'>" + str + "</span>")
#define span_purple(str) ("<span class='purple'>" + str + "</span>")
#define span_orange(str) ("<span class='orange'>" + str + "</span>")
#define span_blue(str) ("<span class='blue'>" + str + "</span>")
#define span_yellow(str) ("<span class='yellow'>" + str + "</span>")

/**
 * MARK: Other colors
 */
#define span_rose(str) ("<span class='rose'>" + str + "</span>")
#define span_interface(str) ("<span class='interface'>" + str + "</span>")
#define span_greentext(str) ("<span class='greentext'>" + str + "</span>")
#define span_redtext(str) ("<span class='redtext'>" + str + "</span>")
#define span_resonate(str) ("<span class='resonate'>" + str + "</span>")
#define span_specialnotice(str) ("<span class='specialnotice'>" + str + "</span>")
#define span_whisper(str) ("<span class='whisper'>" + str + "</span>")
#define span_clown(str) ("<span class='clown'>" + str + "</span>")
#define span_bad(str) ("<span class='bad'>" + str + "</span>")
#define span_average(str) ("<span class='average'>" + str + "</span>")
#define span_good(str) ("<span class='good'>" + str + "</span>")

/**
 * MARK: Admin/Mentor
 */
#define span_mentorhelp(str) ("<span class='mentorhelp'> " + str + "</span>")
#define span_mentorhelp3(str) ("<span class='mentorhelp' size='3'>" + str + "</span>")
#define span_admin(str) ("<span class='admin'>" + str + "</span>")
#define span_adminhelp(str) ("<span class='adminhelp'>" + str + "</span>")
#define span_adminhelp3(str) ("<span class='adminhelp' size='3'>" + str + "</span>")
#define span_adminticket(str) ("<span class='adminticket'>" + str + "</span>")
#define span_adminticketalt(str) ("<span class='adminticketalt'>" + str + "</span>")
#define span_admin_channel(str) ("<span class='admin_channel'>" + str + "</span>")
#define span_all_admin_ping(str) ("<span class='all_admin_ping'>" + str + "</span>")

// MARK: Radio
/**
 * MARK: Radio
 * TODO: Check and delete if it can be replaced.
 */
#define span_deptradio(str) ("<span class='deptradio'>" + str + "</span>")
#define span_syndradio(str) ("<span class='syndradio'>" + str + "</span>")
#define span_sciradio(str) ("<span class='sciradio'>" + str + "</span>")

/**
 * MARK: Alerts
 */
#define span_alert(str) ("<span class='alert'>" + str + "</span>")
#define span_ghostalert(str) ("<span class='ghostalert'>" + str + "</span>")
#define span_warning(str) ("<span class='warning'>" + str + "</span>")
#define span_boldwarning(str) ("<span class='boldwarning'>" + str + "</span>")
#define span_warningbig(str) ("<span class='warning big'>" + str + "</span>")
#define span_danger(str) ("<span class='danger'>" + str + "</span>")
#define span_bolddanger(str) ("<span class='bolddanger'>" + str + "</span>")
#define span_biggerdanger(str) ("<span class='biggerdanger'>" + str + "</span>")
#define span_userdanger(str) ("<span class='userdanger'>" + str + "</span>")
#define span_disarm(str) ("<span class='disarm'>" + str + "</span>")
#define span_notice(str) ("<span class='notice'>" + str + "</span>")
#define span_boldnotice(str) ("<span class='boldnotice'>" + str + "</span>")
#define span_suicide(str) ("<span class='suicide'>" + str + "</span>")

/**
 * MARK: Antagonists
 */
#define span_alien(str) ("<span class='alien'>" + str + "</span>")
#define span_noticealien(str) ("<span class='noticealien'>" + str + "</span>")
#define span_alertalien(str) ("<span class='alertalien'>" + str + "</span>")
#define span_terrorspider(str) ("<span class='terrorspider'>" + str + "</span>")
#define span_dantalion(str) ("<span class='dantalion'>" + str + "</span>")
#define span_sinister(str) ("<span class='sinister'>" + str + "</span>")
#define span_blob(str) ("<span class='blob'>" + str + "</span>")
#define span_revennotice(str) ("<span class='revennotice'>" + str + "</span>")
#define span_revenboldnotice(str) ("<span class='revenboldnotice'>" + str + "</span>")
#define span_revenbignotice(str) ("<span class='revenbignotice'>" + str + "</span>")
#define span_revenminor(str) ("<span class='revenminor'>" + str + "</span>")
#define span_revenwarning(str) ("<span class='revenwarning'>" + str + "</span>")
#define span_revendanger(str) ("<span class='revendanger'>" + str + "</span>")
#define span_changeling(str) ("<span class='changeling'>" + str + "</span>")
#define span_abductor(str) ("<span class='abductor'>" + str + "</span>")
#define span_mind_control(str) ("<span class='mind_control'>" + str + "</span>")
#define span_his_grace(str) ("<span class='his_grace'>" + str + "</span>")
#define span_shadowling(str) ("<span class='shadowling'>" + str + "</span>")

/**
 * MARK: Cults
 */
#define span_cult(str) ("<span class='cult'>" + str + "</span>")
#define span_cultspeech(str) ("<span class='cultspeech'>" + str + "</span>")
#define span_cultitalic(str) ("<span class='cultitalic'>" + str + "</span>")
#define span_cultlarge(str) ("<span class='cultlarge'>" + str + "</span>")
#define span_narsie(str) ("<span class='narsie'>" + str + "</span>")
#define span_narsiesmall(str) ("<span class='narsiesmall'>" + str + "</span>")
#define span_clock(str) ("<span class='clock'>" + str + "</span>")
#define span_clockspeech(str) ("<span class='clockspeech'>" + str + "</span>")
#define span_clockitalic(str) ("<span class='clockitalic'>" + str + "</span>")
#define span_clocklarge(str) ("<span class='clocklarge'>" + str + "</span>")
#define span_ratvar(str) ("<span class='ratvar'>" + str + "</span>")

/**
 * MARK: Syndicate codewords
 */
#define span_codephrases(str) ("<span class='codephrases'>" + str + "</span>")
#define span_coderesponses(str) ("<span class='coderesponses'>" + str + "</span>")

/**
 * MARK: Megafauna
 */
#define span_colossus(str) ("<span class='colossus'>" + str + "</span>")
#define span_hierophant(str) ("<span class='hierophant'>" + str + "</span>")
#define span_hierophant_warning(str) ("<span class='hierophant_warning'>" + str + "</span>")

/**
 * MARK: Anomaly
 */
#define span_bluespace_anomaly(str) ("<span class='bluespace_anomaly'>" + str + "</span>")
#define span_energetic_anomaly(str) ("<span class='energetic_anomaly'>" + str + "</span>")
#define span_atmospferic_anomaly(str) ("<span class='atmospferic_anomaly'>" + str + "</span>")
#define span_gravitational_anomaly(str) ("<span class='gravitational_anomaly'>" + str + "</span>")
#define span_vortex_anomaly(str) ("<span class='vortex_anomaly'>" + str + "</span>")

/**
 * MARK: Font sizes
 * Don't rename it. Each numbered span corresponds to the numbered font style.
 */
#define span_fontsize1(str) ("<span style='font-size: 10px;'>" + str + "</span>")
#define span_fontsize2(str) ("<span style='font-size: 13px;'>" + str + "</span>")
#define span_fontsize3(str) ("<span style='font-size: 16px;'>" + str + "</span>")
#define span_fontsize4(str) ("<span style='font-size: 18px;'>" + str + "</span>")
#define span_fontsize5(str) ("<span style='font-size: 24px;'>" + str + "</span>")
#define span_fontsize6(str) ("<span style='font-size: 32px;'>" + str + "</span>")
#define span_fontsize7(str) ("<span style='font-size: 48px;'>" + str + "</span>")

