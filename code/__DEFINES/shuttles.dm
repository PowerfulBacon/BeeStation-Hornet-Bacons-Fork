//shuttle mode defines
#define SHUTTLE_IDLE		"idle"
#define SHUTTLE_IGNITING	"igniting"
#define SHUTTLE_RECALL		"recalled"
#define SHUTTLE_CALL		"called"
#define SHUTTLE_DOCKED		"docked"
#define SHUTTLE_STRANDED	"stranded"
#define SHUTTLE_ESCAPE		"escape"
#define SHUTTLE_ENDGAME		"endgame: game over"
#define SHUTTLE_RECHARGING		"recharging"
#define SHUTTLE_PREARRIVAL		"landing"

#define EMERGENCY_IDLE_OR_RECALLED (SSshuttle.emergency && ((SSshuttle.emergency.mode == SHUTTLE_IDLE) || (SSshuttle.emergency.mode == SHUTTLE_RECALL)))
#define EMERGENCY_ESCAPED_OR_ENDGAMED (SSshuttle.emergency && ((SSshuttle.emergency.mode == SHUTTLE_ESCAPE) || (SSshuttle.emergency.mode == SHUTTLE_ENDGAME)))
#define EMERGENCY_AT_LEAST_DOCKED (SSshuttle.emergency && SSshuttle.emergency.mode != SHUTTLE_IDLE && SSshuttle.emergency.mode != SHUTTLE_RECALL && SSshuttle.emergency.mode != SHUTTLE_CALL)

// Shuttle return values
#define SHUTTLE_CAN_DOCK "can_dock"
#define SHUTTLE_NOT_A_DOCKING_PORT "not a docking port"
#define SHUTTLE_DWIDTH_TOO_LARGE "docking width too large"
#define SHUTTLE_WIDTH_TOO_LARGE "width too large"
#define SHUTTLE_DHEIGHT_TOO_LARGE "docking height too large"
#define SHUTTLE_HEIGHT_TOO_LARGE "height too large"
#define SHUTTLE_ALREADY_DOCKED "we are already docked"
#define SHUTTLE_SOMEONE_ELSE_DOCKED "someone else docked"

//Launching Shuttles to CentCom
#define NOLAUNCH -1
#define UNLAUNCHED 0
#define ENDGAME_LAUNCHED 1
#define EARLY_LAUNCHED 2
#define ENDGAME_TRANSIT 3

// Ripples, effects that signal a shuttle's arrival
#define SHUTTLE_RIPPLE_TIME 100

#define TRANSIT_REQUEST 1
#define TRANSIT_READY 2

#define SHUTTLE_TRANSIT_BORDER 16

#define PARALLAX_LOOP_TIME 25
#define HYPERSPACE_END_TIME 5

#define HYPERSPACE_WARMUP 1
#define HYPERSPACE_LAUNCH 2
#define HYPERSPACE_END 3

#define CALL_SHUTTLE_REASON_LENGTH 12

//Engine related
#define ENGINE_COEFF_MIN 0.5
#define ENGINE_COEFF_MAX 2
#define ENGINE_DEFAULT_MAXSPEED_ENGINES 5

// Alert level related
#define ALERT_COEFF_AUTOEVAC_NORMAL 2.5
#define ALERT_COEFF_GREEN 2
#define ALERT_COEFF_BLUE 1
#define ALERT_COEFF_RED 0.5
#define ALERT_COEFF_AUTOEVAC_CRITICAL 0.4
#define ALERT_COEFF_DELTA 0.25

//Docking error flags
#define DOCKING_SUCCESS				0
#define DOCKING_BLOCKED				(1<<0)
#define DOCKING_IMMOBILIZED			(1<<1)
#define DOCKING_AREA_EMPTY			(1<<2)
#define DOCKING_NULL_DESTINATION	(1<<3)
#define DOCKING_NULL_SOURCE			(1<<4)

//Docking turf movements
#define MOVE_TURF 1
#define MOVE_AREA 2
#define MOVE_CONTENTS 4

//Rotation params
#define ROTATE_DIR 		1
#define ROTATE_SMOOTH 	2
#define ROTATE_OFFSET	4

#define SHUTTLE_DOCKER_LANDING_CLEAR 1
#define SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT 2
#define SHUTTLE_DOCKER_BLOCKED 3

//Shuttle defaults
#define SHUTTLE_DEFAULT_SHUTTLE_AREA_TYPE /area/shuttle
#define SHUTTLE_DEFAULT_UNDERLYING_AREA /area/space

//Shuttle unlocks
#define SHUTTLE_UNLOCK_BUBBLEGUM "bubblegum"
#define SHUTTLE_UNLOCK_ALIENTECH "abductor"
#define SHUTTLE_UNLOCK_MEDISIM "holodeck"
#define SHUTTLE_UNLOCK_NARNAR "bcult"

//Shuttle preset danger levels

/// Generally safe for station consumption, has everything a typical shuttle needs
#define SHUTTLE_DANGER_SAFE 0
/// Missing key components or has mild elements of danger, but generally won't kill you
#define SHUTTLE_DANGER_SUBPAR 1
/// Possibility for most people on this shuttle to die with little effort
#define SHUTTLE_DANGER_HIGH 2

#define CUSTOM_SHUTTLE_ACCELERATION_SCALE 10
#define CUSTOM_SHUTTLE_MIN_THRUST_TO_WEIGHT 1

#define SHUTTLE_CREATOR_MAX_SIZE CONFIG_GET(number/max_shuttle_size)
#define CUSTOM_SHUTTLE_LIMIT CONFIG_GET(number/max_shuttle_count)

/// Orbital object is not in orbit and cannot enter it
#define ORBITAL_STATUS_NONE 0
/// Orbital object has the height to enter orbit
#define ORBITAL_STATUS_READY 1
/// Orbital object is currently in orbit
#define ORBITAL_STATUS_ORBIT 2

/// Landing gear is not deployed
#define GEAR_STATUS_UP 0
/// Landing gear is currently deploying/retracting
#define GEAR_STATUS_MOVING 1
/// Landing gear is fully deployed and ready to dock
#define GEAR_STATUS_DEPLOYED 2

#define GEAR_DEPLOY_SPEED 8 SECONDS

/// The maximum speed at which you can safely land a shuttle via
/// the landing gear.
#define MAX_SAFE_LANDING_SPEED 60

/// Angle before we start to stall
#define STALL_ANGLE 25
/// Minimum angle of attack before we stall
#define STALL_LOW_ANGLE -10
/// Constant wing area of the ship
/// Don't change this
#define WING_AREA 50
/// Reference weight in kilograms of a shuttle object, used for
/// calculating the lift generated.
/// This mainly affects how much lift we generate at low
/// speeds and altitudes.
#define SHUTTLE_WEIGHT 18000
/// Flight level you have to be at in order to enter orbit
#define ORBIT_HEIGHT 18000
/// height that shuttle spawns at
#define SHUTTLE_SPAWN_HEIGHT 20000
/// Radius of the planet (relative to orbit height)
/// This mainly affects the amount of lift generated at high
/// altitudes.
#define PLANET_RADIUS 90000
/// The maximum speed that a shuttle should be able to achieve without
/// orbital thrusters in m/s.
/// This should be calculated such that we cannot reach orbit
/// on lift alone
#define MAX_REASONABLE_SHUTTLE_SPEED 100
/// How much the air density falls off at higher altitudes. Results
/// in less lift generated at high altitudes, but has less effect
/// on lift at low altitudes.
#define AIR_DENSITY_FALLOFF 800
/// Any additional speed over this won't generate extra lift
#define WING_MAX_SPEED 150

/*

Copy this into desmos to get a graph if you ever want to
modify these settings.
r_{planet} is the radius of the planet
g is the gravity
w is the weight of the ship
v is the velocity of the ship instance
p is the pitch of the ship instance
v_{z} is the vertical speed of the ship instance
the 500 in the a(x) equation is the air density falloff

r_{planet}=196000
g=10
w=9500
v=165
p=0
v_{z}=0

f\left(x\right)=-gw\cdot\left(\frac{r_{planet}^{2}}{\left(r_{planet}+x\right)^{2}}\right)
y=\frac{\left(f\left(x\right)+l\left(x\right)\right)}{w}
a\left(x\right)=1.6\cdot\min\left(\frac{1}{\max\left(\frac{x}{500},1\right)},1\right)
l\left(x\right)=\left\{\left|a_{attack}\right|<25:0.5\ \cdot\ a\left(x\right)\cdot v^{2}\cdot50\cdot\left(5+a_{attack}\right)\left(40-a_{attack}\right)0.003,0\right\}
a_{attack}=p-\left(\arctan\left(\frac{v_{z}}{v}\right)\cdot\frac{360}{2\pi}\right)
y=-g\left(\frac{r_{planet}^{2}}{\left(r_{planet}+x\right)^{2}}\right)
 */
