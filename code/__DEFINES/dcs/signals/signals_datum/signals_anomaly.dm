
////////////////////////////////
// Anomaly Information Passing Signals
////////////////////////////////

/// Identify targets (list/out_target_list)
#define COMSIG_ANOMALY_IDENTIFY_TARGETS "identify_targets"
/// Trigger idle behaviour
#define COMSIG_ANOMALY_IDLE_BEHAVIOUR "idle_behaviour"
/// Combat behaviour (atom/movable/target)
#define COMSIG_ANOMALY_COMBAT_BEHAVIOUR "combat_behaviour"
/// The behaviour to run when the target moves out of range (atom/movable/target)
#define COMSIG_ANOMALY_TARGET_LEAVE_RANGE "target_left_range"
	/// Block the default action of losing the target
	#define COMSIG_ANOMALY_DONT_LOSE_TARGET (1 << 0)

////////////////////////////////
// Anomaly Event Signals
////////////////////////////////

/// Anomaly breach triggered
#define COMSIG_ANOMALY_BREACH "anomaly_breach"
/// Order an anomaly to enter its contained state
#define COMSIG_ANOMALY_CONTAINED "anomaly_contained"
/// Anomaly breach triggered
#define COMSIG_ON_ANOMALY_BREACHED "on_anomaly_breached"
/// Anomaly was successfully supressed
#define COMSIG_ANOMALY_ENTER_SUPRESSED_STATE "anomaly_supressed_state"
/// Anomaly finished its supression phase
#define COMSIG_ANOMALY_EXIT_SUPRESSED_STATE "anomaly_unsupressed"

////////////////////////////////
// Anomaly Attack Signals
////////////////////////////////

/// When an anomaly is hit with a supressing weapon (mob/user, suppression_type, power)
#define COMSIG_ANOMALY_SUPRESSED "anomaly_suppressed"

////////////////////////////////
// Anomaly Interaction Signals
////////////////////////////////

/// Direct Interaction, triggered by directly interacting with the anomaly (mob/user)
#define COMSIG_ANOMALY_DIRECT_INTERACTION "anomaly_interaction"
/// Temporal Interaction, triggered by use in the temporal analysis chamber (mob/user)
#define COMSIG_ANOMALY_TEMPORAL_INTERACTION "temporal_interaction"
/// Flux Vacuum Interaction, triggered by low flux levels (mob/user)
#define COMSIG_ANOMALY_FLUX_VACUUM_INTERACTION "flux_vacuum_interaction"
