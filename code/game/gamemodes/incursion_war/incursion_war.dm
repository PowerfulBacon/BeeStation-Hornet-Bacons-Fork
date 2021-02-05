/datum/game_mode
	var/datum/team/incursion/war_team_one

/datum/game_mode/incursion_war
	name = "incursion_war"
	config_tag = "incursion_war"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Brig Physician")
	antag_flag = ROLE_INCURSION
	false_report_weight = 10
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "A large force of syndicate operatives have infiltrated the ranks of the station and wish to take it by force!\n\
	<span class='danger'>Incursionists</span>: Defeat the other incursion team.\n\
	<span class='notice'>Crew</span>: Survive the events on space station 13!"

	required_enemies = 20

	title_icon = "traitor"

	var/datum/team/incursion/pre_war_team_a
	var/datum/team/incursion/pre_war_team_b

/datum/game_mode/incursion_war/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/list/datum/mind/possible_traitors = get_players_for_role(ROLE_INCURSION)

	var/cost_base = CONFIG_GET(number/incursion_cost_base)
	var/cost_increment = CONFIG_GET(number/incursion_cost_increment)
	var/pop = GLOB.player_details.len
	var/team_size = (2 * pop) / ((2 * cost_base) + ((pop - 1) * cost_increment))
	team_size = CLAMP(team_size, CONFIG_GET(number/incursion_count_min), CONFIG_GET(number/incursion_count_max))

	//2 teams
	for(var/team_number in 1 to 2)
		//What team are they a part of
		var/datum/team/incursion/team = new
		//Assign members
		for(var/k in 1 to team_size)
			var/datum/mind/incursion = antag_pick(possible_traitors, ROLE_INCURSION)
			if(!incursion)
				message_admins("Ran out of people to put in an incursion team, wanted [team_size] but only got [k-1]")
				break
			possible_traitors -= incursion
			antag_candidates -= incursion
			team.add_member(incursion)
			incursion.special_role = "incursionist"
			incursion.restricted_roles = restricted_jobs
			log_game("[key_name(incursion)] has been selected as a member of the incursion")
		//Assign team to the variable
		if(team_number == 1)
			pre_war_team_a = team
		else
			pre_war_team_b = team

	gamemode_ready = TRUE
	return TRUE

/datum/game_mode/incursion_war/post_setup(report)
	
	return ..()
