/datum/quest_system/quest
	var/name = "Generic Quest"
	var/desc = "%faction wants you to do some things."
	var/list/factions = list()
	var/completion_reputation_change = 0
	var/failure_reputation_change = 0

	//Stuff after the quest has been sent
	var/sending_faction

/datum/quest_system/quest/proc/on_trigger()
	return 1

/datum/quest_system/quest/proc/on_accept()
	return 1

/datum/quest_system/quest/proc/on_reject()
	return 1

/datum/quest_system/quest/proc/on_finished()
	return 1

/datum/quest_system/quest/proc/on_sucessful()
	return 1

/datum/quest_system/quest/proc/on_failure()
	return 1

/datum/quest_system/quest/proc/check_completion()
	return QUEST_NOT_ENDED
