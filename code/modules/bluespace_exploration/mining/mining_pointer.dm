/obj/item/pinpointer/mining
	name = "mass locator"
	desc = "An invaluable mining tool that points towards the nearest body of mass."
	minimum_range = 20

/obj/item/pinpointer/mining/scan_for_target()
	var/closest_distance = INFINITY
	var/closest_target
	var/turf/T = get_turf(src)
	for(var/obj/effect/abstract/mining_landmark/landmark in GLOB.mining_landmarks)
		var/turf/landmark_turf = get_turf(landmark)
		if(landmark_turf.z != T.z)
			continue
		var/distance = get_dist(T, landmark)
		if(distance < closest_distance)
			closest_distance = distance
			closest_target = landmark
	target = closest_target
