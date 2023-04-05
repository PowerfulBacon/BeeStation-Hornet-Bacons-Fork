#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#define ANOMALY_TESTING //Uncomment this to enable anomaly testing

#ifdef ANOMALY_TESTING
#ifndef LOWMEMORYMODE
#define LOWMEMORYMODE
#endif
#endif

#include "map_files\generic\CentCom.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		#include "map_files\Mining\Lavaland.dmm"
		#include "map_files\debug\runtimestation.dmm"
		#include "map_files\debug\anomalystation.dmm"
		#include "map_files\CorgStation\CorgStation.dmm"
		#include "map_files\Deltastation\DeltaStation2.dmm"
		#include "map_files\MetaStation\MetaStation.dmm"
		#include "map_files\PubbyStation\PubbyStation.dmm"
		#include "map_files\BoxStation\BoxStation.dmm"
		#include "map_files\KiloStation\KiloStation.dmm"
		#include "map_files\flandstation\flandstation.dmm"

		#ifdef CIBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
