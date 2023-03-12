///Defines for anomaly types
#define ANOMALY_DELIMBER "delimber_anomaly"
#define ANOMALY_FLUX "flux_anomaly"
#define ANOMALY_GRAVITATIONAL "gravitational_anomaly"
#define ANOMALY_HALLUCINATION "hallucination_anomaly"
#define ANOMALY_PYRO "pyro_anomaly"
#define ANOMALY_VORTEX "vortex_anomaly"

///Defines for area allowances
#define ANOMALY_AREA_BLACKLIST list(/area/ai_monitored/turret_protected/ai,/area/ai_monitored/turret_protected/ai_upload,/area/engine,/area/solar,/area/holodeck,/area/shuttle)
#define ANOMALY_AREA_SUBTYPE_WHITELIST list(/area/engine/break_room)

///Defines for weighted anomaly chances
#define ANOMALY_WEIGHTS list(ANOMALY_GRAVITATIONAL = 55, ANOMALY_HALLUCINATION = 45, ANOMALY_DELIMBER = 35, ANOMALY_FLUX = 25, ANOMALY_PYRO = 5, ANOMALY_VORTEX = 1)

///Defines for the different types of explosion a flux anomaly can have
#define ANOMALY_FLUX_NO_EXPLOSION 0
#define ANOMALY_FLUX_EXPLOSIVE 1
#define ANOMALY_FLUX_LOW_EXPLOSIVE 2

#define DEFAULT_FLUX_VALUE 1000
/// Changes how flux decays. Lower values means flux decays slower
/// This means that after 10 minutes, the initial value will have halved
#define FLUX_HALF_LIFE 10

#define FLUX_TIER_1 50
#define FLUX_TIER_2 200
#define FLUX_TIER_3 800

// Anomaly states
#define ANOMALY_STATE_BREACHED 1
#define ANOMALY_STATE_STABLE 2

// Supression types
#define ANOMALY_SUPPRESSION_DISRUPTOR "disruptor"

#define ANOMALY_HEALTH_SAFE 200
#define ANOMALY_HEALTH_RISK 400
#define ANOMALY_HEALTH_THREAT 800
#define ANOMALY_HEALTH_HAZARD 1600
#define ANOMALY_HEALTH_DANGER 3200
