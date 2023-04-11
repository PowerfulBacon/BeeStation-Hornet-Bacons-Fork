/datum/component/anomaly_base
	/// Current anomaly state
	var/anomaly_state = ANOMALY_STATE_BREACHED
	/// Anomaly supression health
	var/supression_max_health = ANOMALY_HEALTH_SAFE
	var/supression_health = ANOMALY_HEALTH_SAFE
	/// Anomaly stability
	/// Upon reaching 0 the anomaly will breach.
	/// This value will decrease when being tested on and will
	/// increase when in the containment chamber.
	var/stability_level = 100
	/// Is the anomaly currently supressed?
	var/is_supressed = FALSE
	/// Anomaly effect structure
	var/datum/anomaly_action/base_action
	// list of work types and their effect on stability
	// The sublist indicates progressive works on the anomaly
	var/list/work_type_stability_effect = list(
		ANOMALY_WORK_INTERACTION = list(-10, -15, -20, -30, -50),
		ANOMALY_WORK_FLUX = list(-10, -15, -20, -30, -50),
	)

/datum/component/anomaly_base/Initialize(anomaly_tag)
	. = ..()
	base_action = SSanomaly_science.create_anomaly_effect(src, anomaly_tag)
	if (!base_action)
		return COMPONENT_INCOMPATIBLE
	if (isobj(parent))
		var/obj/O = parent
		// Anomalies need to be able to be hittable.
		O.obj_flags |= CAN_BE_HIT
	// Register relevant signals
	RegisterSignal(parent, COMSIG_ANOMALY_SUPRESSED, .proc/supress)
	RegisterSignal(parent, COMSIG_ANOMALY_BREACH, .proc/begin_breach)
	RegisterSignal(parent, COMSIG_ANOMALY_CONTAINED, .proc/enter_containment)

/datum/component/anomaly_base/UnregisterFromParent()
	base_action.deactive_anomaly(src)

/datum/component/anomaly_base/process(delta_time)
	// Lose 1 point every second
	stability_level -= delta_time
	if (stability_level <= 0)
		begin_breach()

/datum/component/anomaly_base/proc/supress(datum/source, mob/user, suppression_type, power)
	supression_health -= power
	if (supression_health <= 0)
		// Enter a supressed state
		is_supressed = TRUE
		SEND_SIGNAL(parent, COMSIG_ANOMALY_ENTER_SUPRESSED_STATE)
		// After some time, become unsuppressed (unless we were contained)
		addtimer(CALLBACK(src, .proc/unsupress), 2 MINUTES)

/datum/component/anomaly_base/proc/unsupress()
	if (!is_supressed || anomaly_state != ANOMALY_STATE_BREACHED)
		return
	supression_health = supression_max_health
	is_supressed = FALSE
	SEND_SIGNAL(parent, COMSIG_ANOMALY_EXIT_SUPRESSED_STATE)

/datum/component/anomaly_base/proc/begin_breach()
	if (anomaly_state == ANOMALY_STATE_BREACHED)
		CRASH("Attempted to start anomaly breach while anomaly was already breaching")
	STOP_PROCESSING(SSanomaly_processing, src)
	anomaly_state = ANOMALY_STATE_BREACHED
	supression_health = supression_max_health
	// Reset stability to the max level
	stability_level = 100
	// Perform any breach actions
	SEND_SIGNAL(parent, COMSIG_ON_ANOMALY_BREACHED)

/datum/component/anomaly_base/proc/enter_containment()
	if (anomaly_state == ANOMALY_STATE_STABLE)
		return
	anomaly_state = ANOMALY_STATE_STABLE
	START_PROCESSING(SSanomaly_processing, src)
