//How much pain affects conciousness
#define PAIN_CONCIOUSNESS_MULTIPLIER 1

//How much conciousness affect manipulation.
//If conciousness is reduced by 10, manipulation will be reduced by 8
#define CONCIOUSNESS_MANIPULATION_MULTIPLIER 0.8

//How much conciousness affects movement.
#define CONCIOUSNESS_MOVEMENT_MULTIPLIER 0.8

//Bodypart area defines

//Bodypart flags
#define PROTECTED (1 << 1)		//Won't have damage applied directly to it
#define ORGAN (1 << 2)			//Won't take damage from surface wounds (blunt impacts etc.)
#define CRITICAL (1 << 3)		//Mob will die if this organ is destroyed
#define FROZEN (1 << 4)			//Frozen
#define RECOLOURABLE (1 << 5)	//Recolourable in an augment manip

//Bodypart slots (Specific)

//Human parts
#define LEFT_ARM "leftarm"
#define RIGHT_ARM "righarm"
#define CHEST "chest"
#define HEAD "head"
#define LEFT_FOOT "leftfoot"
#define RIGHT_FOOT "rightfoot"
#define FINGER_LEFT_1 "fingerl1"
#define FINGER_LEFT_2 "fingerl2"
#define FINGER_LEFT_3 "fingerl3"
#define FINGER_LEFT_4 "fingerl4"
#define FINGER_LEFT_5 "fingerl5"
#define FINGER_RIGHT_1 "fingerr1"
#define FINGER_RIGHT_2 "fingerr2"
#define FINGER_RIGHT_3 "fingerr3"
#define FINGER_RIGHT_4 "fingerr4"
#define FINGER_RIGHT_5 "fingerr5"
#define LEFT_HAND "lefthand"
#define RIGHT_HAND "righthand"
#define JAW "jaw"
#define LEFT_LEG "leftleg"
#define RIGHT_LEG "rightleg"
#define PELVIS "pelvis"
#define RIBS "ribs"
#define LEFT_SHOULDER "leftshoulder"
#define RIGHT_SHOULDER "rightshoulder"
#define SKULL "skull"
#define TOE_LEFT_1 "toel1"
#define TOE_LEFT_2 "toel2"
#define TOE_LEFT_3 "toel3"
#define TOE_LEFT_4 "toel4"
#define TOE_LEFT_5 "toel5"
#define TOE_RIGHT_1 "toer1"
#define TOE_RIGHT_2 "toer2"
#define TOE_RIGHT_3 "toer3"
#define TOE_RIGHT_4 "toer4"
#define TOE_RIGHT_5 "toer5"
#define VOCAL_CHORDS "vocalchords"

//Human allowed parts
#define TAIL "tail"
#define WINGS "wings"

//Animals
#define BACK_RIGHT_LEG "backrightleg"
#define BACK_LEG_LEG "backleftleg"

//Organs
#define STOMACH "stomach"
#define TONGUE "tongue"
#define NOSE "nose"
#define LIVER "liver"
#define LEFT_KIDNEY "leftkidney"
#define RIGHT_KIDNEY "rightkidney"
#define HEART "heart"
#define LEFT_EYE "lefteye"
#define RIGHT_EYE "righteye"
#define LEFT_EAR "leftear"
#define RIGHT_EAR "rightear"
#define BRAIN "brain"
#define ZOMBIETUMOUR "zombietumour"
