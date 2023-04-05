/datum/component/anomaly_base
	/// Current anomaly state
	var/anomaly_state = ANOMALY_STATE_BREACHED
	/// Anomaly supression health
	var/supression_max_health = ANOMALY_HEALTH_SAFE
	var/supression_health = ANOMALY_HEALTH_SAFE
	/// Anomaly stability
	/// Upon reaching 0, the anomaly will enter its stable state
	/// where it will slowly rise if not contained.
	/// Stability will increase when not experimented on and will decrease when
	/// poorly experimented on
	var/stability_level = 100
	/// Is the anomaly currently supressed?
	var/is_supressed = FALSE
	/// Anomaly effect structure
	var/datum/anomaly_action/base_action

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
	anomaly_state = ANOMALY_STATE_BREACHED
	supression_health = supression_max_health
	stability_level = 100
	// Perform any breach actions
	SEND_SIGNAL(parent, COMSIG_ON_ANOMALY_BREACHED)

/datum/component/anomaly_base/proc/enter_containment()
	anomaly_state = ANOMALY_STATE_STABLE
