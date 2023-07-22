//Orbital vectors
//I hate that some of these modify src and the others just return a valid
// - bacon

/datum/orbital_vector
	var/x = 0
	var/y = 0

/datum/orbital_vector/New(_x = 0, _y = 0)
	. = ..()
	x = _x
	y = _y

//Returns a new vector equal to the current vector + other
/datum/orbital_vector/proc/Add(datum/orbital_vector/other)
	return new /datum/orbital_vector(
		other.x + x,
		other.y + y
	)

//Returns a new vector equal to the current vector * scalar_amount
/datum/orbital_vector/proc/Scale(scalar_amount)
	return new /datum/orbital_vector(
		x * scalar_amount,
		y * scalar_amount
	)

//Adds the other vector to our current vector.
/datum/orbital_vector/proc/AddSelf(datum/orbital_vector/other)
	src.x += other.x
	src.y += other.y
	return src

//Scales our current vector by a scalar amount
/datum/orbital_vector/proc/ScaleSelf(scalar_amount)
	x *= scalar_amount
	y *= scalar_amount
	return src

/datum/orbital_vector/proc/Copy()
	return new /datum/orbital_vector(x, y)

//Returns magnitude of the vector
/datum/orbital_vector/proc/Length()
	return sqrt(x * x + y * y)

//Returns distanace between 2 positional vectors
/datum/orbital_vector/proc/DistanceTo(datum/orbital_vector/other)
	var/delta_x = other.x - x
	var/delta_y = other.y - y
	return sqrt(delta_x * delta_x + delta_y * delta_y)

//Make the vector length 1
/datum/orbital_vector/proc/NormalizeSelf()
	var/total = Length()
	if(!total)
		x = 0
		y = 1
		return src
	x = x / total
	y = y / total
	return src

/datum/orbital_vector/proc/RotateSelf(angle)
	var/_x = x
	x = x * cos(angle) - y * sin(angle)
	y = _x * sin(angle) + y * cos(angle)
	return src

//Assuming we are a position vector
//Takes in position and direction of a line.
/datum/orbital_vector/proc/ShortestDistanceToLine(datum/orbital_vector/position, datum/orbital_vector/direction)
	if(!direction.x && !direction.y)
		return INFINITY
	//Uhhhhhhhhhh.
	if(!x && !y)
		x = 1
		y = 1
	var/lambda = (x * x + y * y - position.x * x - position.y * y) / (direction.x * x + direction.y * y)
	var/datum/orbital_vector/closestPoint = new(position.x + direction.x * lambda, position.y + direction.y * lambda)
	return closestPoint.DistanceTo(src)

/datum/orbital_vector/proc/operator+(datum/orbital_vector/other)
	return Add(other)

/datum/orbital_vector/proc/operator-(datum/orbital_vector/other)
	if (!other)
		return new /datum/orbital_vector(
			-x,
			-y
		)
	return new /datum/orbital_vector(
		x - other.x,
		y - other.y
	)

/datum/orbital_vector/proc/operator*(datum/orbital_vector/other)
	if (istype(other))
		return new /datum/orbital_vector(x * other.x, y * other.y)
	return Scale(other)

/datum/orbital_vector/proc/operator/(datum/orbital_vector/other)
	if (istype(other))
		return new /datum/orbital_vector(x / other.x, y / other.y)
	return  new /datum/orbital_vector(x / other, y / other)

/datum/orbital_vector/proc/operator+=(datum/orbital_vector/other)
	AddSelf(other)

/datum/orbital_vector/proc/operator-=(datum/orbital_vector/other)
	x -= other.x
	y -= other.y

/datum/orbital_vector/proc/operator*=(datum/orbital_vector/other)
	if (istype(other))
		x *= other.x
		y *= other.y
		return src
	x *= other
	y *= other
	return src

#ifndef SPACEMAN_DMM

/datum/orbital_vector/proc/operator/=(datum/orbital_vector/other)
	if (istype(other))
		x /= other.x
		y /= other.y
		return src
	x /= other
	y /= other
	return src

#endif

#if DM_VERSION >= 515

/datum/orbital_vector/proc/operator""()
	return "([x], [y])"

#endif
