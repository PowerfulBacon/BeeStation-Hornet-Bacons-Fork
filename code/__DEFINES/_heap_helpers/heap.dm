//////////////////////
//datum/heap object
//////////////////////

#define HEAP_TYPE(typepath, compare_value) ##typepath {\
	var/list/L;\
	New(...) {\
		L = list(args);\
	}\
	Destroy(force, ...) {\
		for(var/i in L) {\
			qdel(i);\
		}\
		L = null;\
		return ..();\
	}\
	proc/is_empty() {\
		return !length(L);\
	}\
	proc/insert(atom/A) {\
		L.Add(A);\
		swim(length(L));\
	}\
	proc/pop() {\
		if(!length(L)) {\
			return 0;\
		}\
		. = L[1];\
		L[1] = L[length(L)];\
		L.Cut(length(L));\
		if(length(L)) {\
			sink(1);\
		}\
	}\
	proc/swim(index) {\
		var/parent = round(index * 0.5);\
		while(parent > 0 && (L[index]:##compare_value - L[parent]:##compare_value > 0)) {\
			L.Swap(index,parent);\
			index = parent;\
			parent = round(index * 0.5);\
		}\
	}\
	proc/sink(index) {\
		var/g_child = get_greater_child(index);\
		while(g_child > 0 && (L[index]:##compare_value - L[g_child]:##compare_value < 0)) {\
			L.Swap(index,g_child);\
			index = g_child;\
			g_child = get_greater_child(index);\
		}\
	}\
	proc/get_greater_child(index) {\
		if(index * 2 > length(L)) {\
			return 0;\
		}\
		if(index * 2 + 1 > length(L)) {\
			return index * 2;\
		}\
		if(L[index * 2]:##compare_value - L[index * 2 + 1]:##compare_value < 0) {\
			return index * 2 + 1;\
		} else {\
			return index * 2;\
		}\
	}\
	proc/resort(atom/A) {\
		var/index = L.Find(A);\
		swim(index);\
		sink(index);\
	}\
	proc/List() {\
		. = L.Copy();\
	}\
	proc/operator+=(A) {\
		L.Add(A);\
		swim(length(L));\
	}\
	proc/operator|=(A) {\
		var/original_length = length(L);\
		L |= A;\
		if (original_length != length(L)) {\
			swim(length(L));\
		}\
	}\
	proc/operator-=(A) {\
		var/index = L.Find(A);\
		if(index == 0) {\
			return 0;\
		}\
		. = L[index];\
		L[index] = L[length(L)];\
		L.Cut(length(L));\
		if(length(L)) {\
			sink(index);\
		}\
	}\
}
