//Orbital vectors
//I hate that some of these modify src and the others just return a valid
// - bacon

/datum/orbital_vector
	var/x = 0
	var/y = 0
	var/z = 0

/datum/orbital_vector/New(_x = 0, _y = 0, _z = 0)
	. = ..()
	x = _x
	y = _y
	z = _z

//Returns a new vector equal to the current vector + other
/datum/orbital_vector/proc/Add(datum/orbital_vector/other)
	return new /datum/orbital_vector(
		other.x + x,
		other.y + y,
		other.z + z
	)

//Returns a new vector equal to the current vector * scalar_amount
/datum/orbital_vector/proc/Scale(scalar_amount)
	return new /datum/orbital_vector(
		x * scalar_amount,
		y * scalar_amount,
		z * scalar_amount
	)

//Adds the other vector to our current vector.
/datum/orbital_vector/proc/AddSelf(datum/orbital_vector/other)
	src.x += other.x
	src.y += other.y
	src.z += other.z
	return src

//Scales our current vector by a scalar amount
/datum/orbital_vector/proc/ScaleSelf(scalar_amount)
	x *= scalar_amount
	y *= scalar_amount
	z *= scalar_amount
	return src

//Returns magnitude of the vector
/datum/orbital_vector/proc/Length2D()
	return sqrt(x * x + y * y)

//Returns magnitude of the vector
/datum/orbital_vector/proc/Length()
	return sqrt(x * x + y * y + z * z)

//Returns planar distanace between 2 positional vectors
/datum/orbital_vector/proc/DistanceTo2D(datum/orbital_vector/other)
	var/delta_x = other.x - x
	var/delta_y = other.y - y
	return sqrt(delta_x * delta_x + delta_y * delta_y)

//Returns distanace between 2 positional vectors
/datum/orbital_vector/proc/DistanceTo(datum/orbital_vector/other)
	var/delta_x = other.x - x
	var/delta_y = other.y - y
	var/delta_z = other.z - z
	return sqrt(delta_x * delta_x + delta_y * delta_y + delta_z * delta_z)

//Make the vector length 1
/datum/orbital_vector/proc/NormalizeSelf2D()
	var/total = Length2D()
	if(!total)
		x = 0
		y = 1
		return src
	x = x / total
	y = y / total
	return src

//Make the vector length 1
/datum/orbital_vector/proc/NormalizeSelf()
	var/total = Length()
	if(!total)
		x = 0
		y = 1
		z = 0
		return src
	x = x / total
	y = y / total
	z = z / total
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
