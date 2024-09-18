///conversion ratio from joules to watts
#define WATTS / 0.002
///conversion ratio from watts to joules
#define JOULES * 0.002

GLOBAL_VAR_INIT(CELLRATE, 0.002)  //! conversion ratio between a watt-tick and kilojoule
GLOBAL_VAR_INIT(CHARGELEVEL, 0.001) // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

GLOBAL_LIST_EMPTY(powernets)

#define WANTS_POWER_NODE(typepath) ##typepath/Initialize(mapload, ...) {\
	. = ..();\
	if (mapload) {\
		for (var/obj/structure/cable/cable in loc) {\
			cable.add_power_node();\
		}\
	}\
}
