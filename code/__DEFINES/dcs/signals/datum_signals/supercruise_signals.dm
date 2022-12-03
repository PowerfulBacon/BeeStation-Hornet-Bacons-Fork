// Exploration related signals
/// Called when a message is sent to an orbital body: (message)
#define COMSIG_ORBITAL_BODY_MESSAGE "orbital_body_message"
/// Called on SSorbits when an orbital body is created on an orbital map: (datum/orbital_object/body, datum/orbital_map/map)
#define COMSIG_ORBITAL_BODY_CREATED "orbital_body_created"
/// Called on a space level when generation is complete
#define COMSIG_SPACE_LEVEL_GENERATED "space_level_generated"

// Shuttle Machinery Signals
/// Called when a shuttle engine updates its status: (is_active)
#define COMSIG_SHUTTLE_ENGINE_STATUS_CHANGE "shuttle_engine_status"
/// Called when a shield generator changes its health amount: (old_amount, new_amount)
#define COMSIG_SHUTTLE_SHIELD_HEALTH_CHANGE "shuttle_shield_health_change"
/// Called when a shuttle has its NPC controller killed
#define COMSIG_SHUTTLE_NPC_INCAPACITATED "shuttle_npc_incapacitated"
/// Called when a collision alert for shuttles is toggled (new_status)
#define COMSIG_SHUTTLE_TOGGLE_COLLISION_ALERT "shuttle_collision_alert_toggle"

// Orbital Communication Signals
/// Called when a communication manager receieves a message: (string/sender, string/message, bool/emergency)
#define COMSIG_COMMUNICATION_RECEIEVED "communication_recieved"
