/**
 * Hostile Conciousness
 * Represents a mob with a hostile conciousness. This will seek nearby
 * targets and then attempt to move towards or attack them.
 *
 * This requires sub nodes which will register signals to the anomamly
 * parent in order to implement the targetting and hostile behavioural
 * logic. The tree structure can function similarly to a behavioural
 * tree.
 * Doesn't have to be quite as robust in terms of AI levels when compared
 * to simple animals, since there will be very few anomalies in the world
 * and hopefully very few present at one time (otherwise you are screwed).
 * In extreme cases the number will be like 10, and if its breaching it is
 * guaranteed to be hostile and active (unlike simple animals which go idle
 * after some time).
 */

/datum/anomaly_action/hostile_conciousness
	/// The probability of overriding target when something attacks us
	var/override_target_with_attacker_probability = 0
	/// The time in which we reconsider targets and attack something else
	var/reconsider_target_timer = 15 SECONDS
	/// The range at which we lose our target
	var/lose_target_range = 8

	/// Our current target
	var/atom/movable/current_target = null
	/// World time to reconsider targets
	var/reconsider_target_at = 0

///Register signals to the anomaly base datum
/datum/anomaly_action/hostile_conciousness/initialise_anomaly(datum/component/anomaly_base/anomaly)
	. = ..()
	// We only need to process while in our breaching state
	if (anomaly.anomaly_state == ANOMALY_STATE_BREACHED)
		// Start processing the logic center of this anomaly
		START_PROCESSING(SSanomaly_science, src)
	// Register signals that we might want to react to


/datum/anomaly_action/hostile_conciousness/deactive_anomaly(datum/component/anomaly_base/anomaly)
	// If we were processing, then stop
	if (anomaly.anomaly_state == ANOMALY_STATE_BREACHED)
		STOP_PROCESSING(SSanomaly_science, src)
	. = ..()

/datum/anomaly_action/hostile_conciousness/process(delta_time)
	// If the anomaly is supressed, then perform no actions
	if (parent_anomaly.is_supressed)
		return
	// Check if we need to lose the target
	check_target_range()
	// Target Consideration
	if (!current_target || world.time > reconsider_target_at)
		select_target()
	if (!current_target)
		idle_behaviour()
	else
		combat_behaviour()

///========================
/// Event-driven reactions
///========================

///========================
/// Target Checking
///========================

/datum/anomaly_action/hostile_conciousness/proc/check_target_range()
	if (!current_target)
		return
	var/current_distance = get_dist(parent_anomaly.parent, current_target)
	if (current_distance < lose_target_range)
		return
	if (SEND_SIGNAL(parent_anomaly.parent, COMSIG_ANOMALY_TARGET_LEAVE_RANGE, current_target))
		return
	unobserve_target()

///========================
/// Target Identification
///========================

/datum/anomaly_action/hostile_conciousness/proc/select_target()
	var/list/valid_targets = identify_targets()
	if (!length(valid_targets))
		return
	observe_target(valid_targets[1])
	reconsider_target_at = world.time + reconsider_target_timer

/datum/anomaly_action/hostile_conciousness/proc/identify_targets()
	var/list/target_list = list()
	SEND_SIGNAL(parent_anomaly.parent, COMSIG_ANOMALY_IDENTIFY_TARGETS, target_list)
	return target_list

/// Needed for hard delete handling
/datum/anomaly_action/hostile_conciousness/proc/observe_target(atom/target)
	current_target = target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/unobserve_target)

/datum/anomaly_action/hostile_conciousness/proc/unobserve_target()
	SIGNAL_HANDLER
	if (!current_target)
		return
	UnregisterSignal(current_target, COMSIG_PARENT_QDELETING)
	current_target = null

///========================
/// Action Handling
///========================

/datum/anomaly_action/hostile_conciousness/proc/idle_behaviour()
	SEND_SIGNAL(parent_anomaly.parent, COMSIG_ANOMALY_IDLE_BEHAVIOUR)

/datum/anomaly_action/hostile_conciousness/proc/combat_behaviour()
	SEND_SIGNAL(parent_anomaly.parent, COMSIG_ANOMALY_COMBAT_BEHAVIOUR, current_target)
