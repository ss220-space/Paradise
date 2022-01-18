#!/bin/bash

[[ -d ./station/config/names ]] || cp -r ../../config/names ./station/config
[[ -d ./station/config/news ]] || cp -r ../../config/news ./station/config
[[ -d ./station/config/title_screens ]] || cp -r ../../config/title_screens ./station/config
[[ -f ./station/config/admin_ranks.txt ]] || cp ../../config/example/admin_ranks.txt ./station/config
[[ -f ./station/config/admins.txt ]] || cp ../../config/example/admins.txt ./station/config
[[ -f ./station/config/alienwhitelist.txt ]] || cp ../../config/example/alienwhitelist.txt ./station/config
[[ -f ./station/config/away_mission_config.txt ]] || cp ../../config/example/away_mission_config.txt ./station/config
[[ -f ./station/config/config.txt ]] || cp ../../config/example/config.txt ./station/config
[[ -f ./station/config/dbconfig.txt ]] || cp ../../config/example/dbconfig.docker.txt ./station/config/dbconfig.txt
[[ -f ./station/config/game_options.txt ]] || cp ../../config/example/game_options.txt ./station/config
[[ -f ./station/config/hublist.txt ]] || cp ../../config/example/hublist.txt ./station/config
[[ -f ./station/config/jobs.txt ]] || cp ../../config/example/jobs.txt ./station/config
[[ -f ./station/config/jobs_highpop.txt ]] || cp ../../config/example/jobs_highpop.txt ./station/config
[[ -f ./station/config/lavaRuinBlacklist.txt ]] || cp ../../config/example/lavaRuinBlacklist.txt ./station/config
[[ -f ./station/config/motd.txt ]] || cp ../../config/example/motd.txt ./station/config
[[ -f ./station/config/ofwhitelist.txt ]] || cp ../../config/example/ofwhitelist.txt ./station/config
[[ -f ./station/config/rules.html ]] || cp ../../config/example/rules.html ./station/config
[[ -f ./station/config/spaceRuinBlacklist.txt ]] || cp ../../config/example/spaceRuinBlacklist.txt ./station/config
[[ -f ./station/config/tos.txt ]] || cp ../../config/example/tos.txt ./station/config
[[ -f ./station/config/twitch_censor.txt ]] || cp ../../config/example/twitch_censor.txt ./station/config
