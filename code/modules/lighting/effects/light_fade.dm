/*
 * Light fade by PowerfulBacon.
 * Uses animate to update the range of the light to 0 over a smooth period of time
 */
/atom/proc/fade_light(_time = 5)
	if(!light)
		return
	animate(light, time=_time, range=0)
