
//Progression rate
//ax^2 + bx + initial
//50 exp at level 1, 5000 exp at level 10

//EXP REQUIRED PER LEVEL:
/*
1 - 135.5 (Total: 135.5)
2 - 312 (Total: 447.5)
3 - 579.5 (Total: 1027)
4 - 938 (Total: 1965)
5 - 1387.5 (Total: 3352.5)
6 - 1928 (Total: 5280.5)
7 - 2559.5 (Total: 7840)
8 - 3282 (Total: 11122)
9 - 4095.5 (Total: 15217)
10 -5000 (Total: 20217.5)
 */

#define SKILLTREE_SQUARE_COEFF 45.5
#define SKILLTREE_X_COEFF 40
#define SKILLTREE_FIRST_LEVEL 50

//Max level per tree
#define SKILLTREE_MAX_LEVEL 10

//Name of the skilltree levels.
#define SKILLTREE_LEVEL_NAMES list(
	0 = "inept",
	1 = "beginner",
	2 = "amatuer",
	3 = "novice",
	4 = "familiar",
	5 = "skilled",
	6 = "highly skilled",
	7 = "professional",
	8 = "expert",
	9 = "master",
	10 = "galactic master"
)

//Medical skill gain
#define SKILLTREE_EXP_NEWCHEM 80		//Made a brand new chemical
#define SKILLTREE_EXP_OLDCHEM 0.5		//Made a chemical they made before (* amount made)
