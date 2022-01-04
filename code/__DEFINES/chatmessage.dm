/// How long the chat message's spawn-in animation will occur for
#define CHAT_MESSAGE_SPAWN_TIME		0.2 SECONDS
/// How long the chat message will exist prior to any exponential decay
#define CHAT_MESSAGE_LIFESPAN		5.4 SECONDS
/// How long the chat message's end of life fading animation will occur for
#define CHAT_MESSAGE_EOL_FADE		0.3 SECONDS
/// Factor of how much the message index (number of messages) will account to exponential decay
#define CHAT_MESSAGE_EXP_DECAY		0.7
/// Factor of how much height will account to exponential decay
#define CHAT_MESSAGE_HEIGHT_DECAY	0.9
/// Approximate height in pixels of an 'average' line, used for height decay
#define CHAT_MESSAGE_APPROX_LHEIGHT	10
/// Max width of chat message in pixels
#define CHAT_MESSAGE_WIDTH			128
/// Max length of chat message in characters
#define CHAT_MESSAGE_MAX_LENGTH		110
/// Maximum precision of float before rounding errors occur (in this context)
#define CHAT_LAYER_Z_STEP			0.0001
/// The number of z-layer 'slices' usable by the chat message layering
#define CHAT_LAYER_MAX_Z			(CHAT_LAYER_MAX - CHAT_LAYER) / CHAT_LAYER_Z_STEP
/// The dimensions of the chat message icons
#define CHAT_MESSAGE_ICON_SIZE		7
/// How much the message moves up before fading out.
#define MESSAGE_FADE_PIXEL_Y 10

// Message types
#define CHATMESSAGE_CANNOT_HEAR 0
#define CHATMESSAGE_HEAR 1
#define CHATMESSAGE_SHOW_LANGUAGE_ICON 2

#define BUCKET_LIMIT (world.time + TICKS2DS(min(BUCKET_LEN - (SSrunechat.practical_offset - DS2TICKS(world.time - SSrunechat.head_offset)) - 1, BUCKET_LEN - 1)))
#define BALLOON_TEXT_WIDTH 200
#define BALLOON_TEXT_SPAWN_TIME (0.2 SECONDS)
#define BALLOON_TEXT_FADE_TIME (0.1 SECONDS)
#define BALLOON_TEXT_FULLY_VISIBLE_TIME (0.7 SECONDS)
#define BALLOON_TEXT_TOTAL_LIFETIME(mult) (BALLOON_TEXT_SPAWN_TIME + BALLOON_TEXT_FULLY_VISIBLE_TIME*mult + BALLOON_TEXT_FADE_TIME)
/// The increase in duration per character in seconds
#define BALLOON_TEXT_CHAR_LIFETIME_INCREASE_MULT (0.05)
/// The amount of characters needed before this increase takes into effect
#define BALLOON_TEXT_CHAR_LIFETIME_INCREASE_MIN 10

#define COLOR_JOB_UNKNOWN "#dda583"
#define COLOR_PERSON_UNKNOWN "#999999"
#define COLOR_CHAT_EMOTE "#727272"

//For jobs that aren't roundstart but still need colours
GLOBAL_LIST_INIT(job_colors_pastel, list(
	"Prisoner" = 		"#d38a5c",
	"CentCom" = 		"#90FD6D",
	"Unknown"=			COLOR_JOB_UNKNOWN,
))

//Chat message imaging flags
//Defines the different ways in which the same message can look
#define CHAT_MESSAGE_FLAG_MAXIMUM (1 << 3) - 1

#define CHAT_MESSAGE_SCRAMBLED (1 << 0)			//Scramble the message (not understood language)
#define CHAT_MESSAGE_VIRTUAL_SPEAKER (1 << 1)	//Show a virtual speaker (from radio messages)
#define CHAT_MESSAGE_LANGUAGE_ICON (1 << 2)		//Show a language icon
