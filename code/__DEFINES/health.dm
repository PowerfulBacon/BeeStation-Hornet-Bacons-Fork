
//Bodypart position flags

//====Head====

#define BP_HEAD "head"

//Head Bones / contents
#define BP_SKULL "skull"
#define BP_JAW "jaw"
#define BP_NECK "neck"

//Head Internal Organs
#define BP_BRAIN "brain"
#define BP_VOICEBOX "voicebox"
#define BP_TONGUE "tongue"
#define BP_NOSE "nose"
#define BP_LEFT_EYE "left_eye"
#define BP_RIGHT_EYE "right_eye"
#define BP_LEFT_EAR "left_ear"
#define BP_RIGHT_EAR "right_ear"

//====Body====

#define BP_BODY "body"

//Body Bones / contents
#define BP_RIBS "ribs"
#define BP_SPINE "spine"
#define BP_PELVIS "pelvis"

//Body internal Organs
#define BP_HEART "heart"
#define BP_LUNGS "lungs"
#define BP_STOMACH "stomach"

//Bodypart flags
#define BP_FLAG_REMOVABLE (1 << 1)	//If set the bodypart can be removed via surgery / dismemberment.
#define BP_FLAG_CRITICAL (1 << 2)	//If set the bodypart will cause the owner to instantly die if destroyed / removed.
