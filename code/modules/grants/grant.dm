/datum/grant
	/// The name of the grant
	var/name
	/// A short description of the grant
	var/description
	/// Money that gets paid out on accepting
	var/initial_payout
	/// The payout for completing the grant
	var/completion_payout
	/// The timelimit
	var/grant_time
	/// Amount of money that gets taken for failing
	var/penalty

/datum/grant/proc/is_completed()
	return FALSE
