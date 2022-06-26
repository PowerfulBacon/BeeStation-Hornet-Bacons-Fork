/datum/grant/research_bomb
	/// The name of the grant
	name = "Military explosive testing grant"
	/// A short description of the grant
	description = "The Nanotrasen military division is under-budget.\
		To avoid budget cuts we require your station to produce the exact \
		same explosive it has been doing for the last 10 years."
	/// Money that gets paid out on accepting
	initial_payout = 8000
	/// The payout for completing the grant
	completion_payout = 26000
	/// The time limit
	grant_time = 20 MINUTES
	/// Amount of money that gets taken for failing
	penalty = 12000

/datum/grant/proc/is_completed()
	return FALSE
