
//==================
// Globals
//==================

//Assoc list job_name = list(spawns)
GLOBAL_LIST_EMPTY(syndicate_pvp_spawns)
GLOBAL_LIST_EMPTY(nanotrasen_pvp_spawns)

GLOBAL_LIST_EMPTY(syndicate_pvp_jobs)
GLOBAL_LIST_EMPTY(nanotrasen_pvp_jobs)

#define SYNDICATE_JOBS list(\
	"Syndicate Captain" = list(1, /datum/outfit/pvp/captain),\
	"Combat Medic" = list(INFINITY, /datum/outfit/pvp/medic),\
	"Combat Engineer" = list(INFINITY, /datum/outfit/pvp/engineer),\
	"Syndicate Operative" = list(INFINITY, /datum/outfit/pvp)\
)

#define NANOTRASEN_JOBS list(\
	"Captain" = list(1, ),\
	"Head of Security" = list(1, ),\
	"Security Officer" = list(INFINITY, ),\
	"Chief Medical Officer" = list(1, ),\
	"Medical Doctor" = list(INFINITY, ),\
	"Chief Engineer" = list(1, ),\
	"Engineer" = list(INFINITY, )\
)

/datum/game_mode/station_war
	name = "station war"
	config_tag = "war"
	false_report_weight = -1
	required_players = 0
	required_enemies = 0
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "The Syndicate have declared war on Nanotrasen in this sector for authorising construction in their territory!\n\
	Construct your station, build shuttles and set up teleporter links to access the enemy station before beginning your assault.\n\
	<span class='danger'>Syndicate</span>: Security the Nuclear Authentication disk from Nanotrasen and destroy their station.\n\
	<span class='notice'>Nanotrasen</span>: Trigger the self-destruct sequence in the core of the Syndicate station and destroy it."

	//Station Z levels
	var/nanotrasen_z
	var/syndicate_z

	//Station counts
	var/nanotrasen_people = 0
	var/syndicate_people = 0
	var/nanotrasen_to_syndicate = 1

/datum/game_mode/station_war/pre_setup()
	to_chat(world, "<span class='boldannounce'>Station wars setting up...</span>")
	to_chat(world, "<span class='boldannounce'>Deleting primary z-level (This may take a while).</span>")
	GLOB.admin_notice = "The gamemode is currently station war! Latejoining will automatically assign you to a team and give you a random job no matter what job you choose."
	//Goodbye station.
	nanotrasen_z = SSmapping.levels_by_trait(ZTRAIT_STATION)[1]
	for(var/x in 1 to world.maxx - 1)
		for(var/y in 1 to world.maxy - 1)
			var/turf/T = locate(x, y, nanotrasen_z)
			T.empty(null, null, list(), CHANGETURF_FORCEOP)
	//Spawn the stations
	to_chat(world, "<span class='boldannounce'>Generating new stations.</span>")
	return TRUE

/datum/game_mode/station_war/post_setup(report)
	//Spawn everyone (Shuffle a bit too)
	for(var/client/C in shuffle(GLOB.joined_player_list))
		mob_spawn(C.mob)
	return TRUE

//Chance that this can get skipped by shuttle call.
/datum/game_mode/station_war/make_antag_chance(mob/living/carbon/human/character)
	mob_spawn(character)

//Spawning!
/datum/game_mode/station_war/proc/mob_spawn(mob/living/carbon/human/character)
	if(nanotrasen_people > syndicate_people * nanotrasen_to_syndicate)
		syndicate_spawn(character)
	else
		nanotrasen_spawn(character)

/datum/game_mode/station_war/proc/nanotrasen_spawn(mob/living/carbon/human/character)
	//Welcome to your new life employee!
	nanotrasen_people ++
	character.forceMove(pick(GLOB.nanotrasen_pvp_spawns["latejoin"]))
	//Pick a job
	var/selected_job = pick(GLOB.nanotrasen_pvp_jobs)
	//Less job now
	GLOB.nanotrasen_pvp_jobs[selected_job] --
	if(GLOB.nanotrasen_pvp_jobs[selected_job] <= 0)
		GLOB.nanotrasen_pvp_jobs.Remove(selected_job)
	//Have your items
	var/datum/outfit/O = NANOTRASEN_JOBS[selected_job][2]
	character.equipOutfit(O)

/datum/game_mode/station_war/proc/syndicate_spawn(mob/living/carbon/human/character)
	//Welcome to the syndicate
	syndicate_people ++
	character.forceMove(pick(GLOB.syndicate_pvp_spawns["latejoin"]))
	//Pick a job
	var/selected_job = pick(GLOB.syndicate_pvp_jobs)
	//Less job now
	GLOB.syndicate_pvp_jobs[selected_job] --
	if(GLOB.syndicate_pvp_jobs[selected_job] <= 0)
		GLOB.syndicate_pvp_jobs.Remove(selected_job)
	//Have your items
	var/datum/outfit/O = SYNDICATE_JOBS[selected_job][2]
	character.equipOutfit(O)
	//Btw your an antag too for tracking
