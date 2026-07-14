
// All terror spider code that relates to queen ruling over a hive

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoHiveSense()
	var/hsline = ""
	to_chat(src, "Ваш род: ")
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/poison/terror_spider/terror_spider = thing
		if(terror_spider.spider_awaymission != spider_awaymission)
			continue
		hsline = "* [DECLENT_RU_CAP(terror_spider, NOMINATIVE)] в [get_area(terror_spider)], "
		if(terror_spider.stat == DEAD)
			hsline += "МЁРТВ"
		else
			hsline += "здоровье [terror_spider.health] / [terror_spider.maxHealth], "
		if(terror_spider.ckey)
			hsline += " *Управляется Игроком* "
		else
			hsline += " ИИ "
		to_chat(src,hsline)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CountSpiders()
	var/numspiders = 0
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/poison/terror_spider/terror_spider = thing
		if(terror_spider.stat != DEAD && !terror_spider.spider_placed && spider_awaymission == terror_spider.spider_awaymission)
			numspiders += 1
	return numspiders

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CountSpidersDetailed(check_mine = FALSE, list/mytypes = list())
	var/list/spider_totals = list("all" = 0)
	var/check_list = length(mytypes) > 0
	for(var/thistype in mytypes)
		spider_totals[thistype] = 0
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/poison/terror_spider/terror_spider = thing
		if(terror_spider.stat == DEAD || terror_spider.spider_placed || spider_awaymission != terror_spider.spider_awaymission)
			continue
		if(check_mine && terror_spider.spider_myqueen != src)
			continue
		if(check_list && !(terror_spider.type in mytypes))
			continue
		if(terror_spider == src)
			continue
		if(spider_totals[terror_spider.type])
			spider_totals[terror_spider.type]++
		else
			spider_totals[terror_spider.type] = 1
		spider_totals["all"]++
	for(var/thing in GLOB.ts_egg_list)
		var/obj/structure/spider/eggcluster/terror_eggcluster/terror_eggcluster = thing
		if(check_mine && terror_eggcluster.spider_myqueen != src)
			continue
		if(check_list && terror_eggcluster.spiderling_type && !(terror_eggcluster.spiderling_type in mytypes))
			continue
		if(spider_totals[terror_eggcluster.spiderling_type])
			spider_totals[terror_eggcluster.spiderling_type] += terror_eggcluster.spiderling_number
		else
			spider_totals[terror_eggcluster.spiderling_type] = terror_eggcluster.spiderling_number
		spider_totals["all"] += terror_eggcluster.spiderling_number
	for(var/thing in GLOB.ts_spiderling_list)
		var/obj/structure/spider/spiderling/terror_spiderling/terror_spiderling = thing
		if(terror_spiderling.stillborn)
			continue
		if(check_mine && terror_spiderling.spider_myqueen != src)
			continue
		if(check_list && terror_spiderling.grow_as && !(terror_spiderling.grow_as in mytypes))
			continue
		if(spider_totals[terror_spiderling.grow_as])
			spider_totals[terror_spiderling.grow_as]++
		else
			spider_totals[terror_spiderling.grow_as] = 1
		spider_totals["all"]++
	return spider_totals

