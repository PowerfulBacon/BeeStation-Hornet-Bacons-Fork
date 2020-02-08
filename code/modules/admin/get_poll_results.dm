/client/proc/get_poll_results()
	set name = "Get Poll Results"
	set category = "Special Verbs"
	if(!check_rights(R_POLL))
		return
	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/datum/DBQuery/query_poll_get = SSdbcore.NewQuery("SELECT id, question FROM [format_table_name("poll_question")]")
	if(!query_poll_get.warn_execute())
		qdel(query_poll_get)
		return
	var/output = "<div align='center'><B>Player polls</B><hr><table>"
	var/i = 0
	while(query_poll_get.NextRow())
		var/pollid = query_poll_get.item[1]
		var/pollquestion = query_poll_get.item[2]
		output += "<tr bgcolor='#[ (i % 2 == 1) ? "e2e2e2" : "e2e2e2" ]'><td><a href='?_src_=holder;[HrefToken()];getpollresult=[pollid];page=0'><b>[pollquestion]</b></a></td></tr>"
		i++
	qdel(query_poll_get)
	output += "</table>"
	if(!QDELETED(src))
		src << browse(output,"window=playerpolllist;size=500x300")

/datum/admins/proc/GetMultichoiceOutput(pollid)
	//Get the results
	var/datum/DBQuery/query_get_poll_results = SSdbcore.NewQuery("SELECT optionid, count(*) FROM [format_table_name("poll_vote")] WHERE pollid = [pollid] GROUP BY optionid ORDER BY count(*) DESC")
	if(!query_get_poll_results.warn_execute())
		qdel(query_get_poll_results)
		return
	var/input = ""
	while(query_get_poll_results.NextRow())
		var/datum/DBQuery/query_get_option_name = SSdbcore.NewQuery("SELECT text FROM [format_table_name("poll_option")] WHERE id = [query_get_poll_results.item[1]]")
		if(!query_get_option_name.warn_execute())
			qdel(query_get_option_name)
			qdel(query_get_poll_results)
			return
		query_get_option_name.NextRow()
		input += "<tr><td>[query_get_option_name.item[1]]</td><td>[query_get_poll_results.item[2]]</td></tr>"
		qdel(query_get_option_name)
	qdel(query_get_poll_results)
	return input

/datum/admins/proc/GetRatingOutput(pollid)
	//The rating is a multichoice but with chioces between 2 numbers
	//Should be easy
	var/datum/DBQuery/query_get_poll_results = SSdbcore.NewQuery("SELECT optionid, rating, count(*) FROM [format_table_name("poll_vote")] WHERE pollid = [pollid] GROUP BY rating ORDER BY count(*) DESC")
	if(!query_get_poll_results.warn_execute())
		qdel(query_get_poll_results)
		return
	var/input = ""
	while(query_get_poll_results.NextRow())
		var/datum/DBQuery/query_get_option_name = SSdbcore.NewQuery("SELECT text FROM [format_table_name("poll_option")] WHERE id = [query_get_poll_results.item[1]]")
		if(!query_get_option_name.warn_execute())
			qdel(query_get_option_name)
			qdel(query_get_poll_results)
			return
		query_get_option_name.NextRow()
		input += "<tr><td>[query_get_option_name.item[2]]</td><td>[query_get_poll_results.item[3]]</td></tr>"
		qdel(query_get_option_name)
	qdel(query_get_poll_results)
	return input
