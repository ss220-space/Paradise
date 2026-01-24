// Generic listoflist safe add and removal macros:
///If value is a list, wrap it in a list so it can be used with list add/remove operations
#define LIST_VALUE_WRAP_LISTS(value) (islist(value) ? list(value) : value)
///Add an untyped item to a list, taking care to handle list items by wrapping them in a list to remove the footgun
#define UNTYPED_LIST_ADD(list, item) (list += LIST_VALUE_WRAP_LISTS(item))
///Remove an untyped item to a list, taking care to handle list items by wrapping them in a list to remove the footgun
#define UNTYPED_LIST_REMOVE(list, item) (list -= LIST_VALUE_WRAP_LISTS(item))

/*
 * ## Lazylists
 *
 * * What is a lazylist?
 *
 * True to its name a lazylist is a lazy instantiated list.
 * It is a list that is only created when necessary (when it has elements) and is null when empty.
 *
 * * Why use a lazylist?
 *
 * Lazylists save memory - an empty list that is never used takes up more memory than just `null`.
 *
 * * When to use a lazylist?
 *
 * Lazylists are best used on hot types when making lists that are not always used.
 *
 * For example, if you were adding a list to all atoms that tracks the names of people who touched it,
 * you would want to use a lazylist because most atoms will never be touched by anyone.
 *
 * * How do I use a lazylist?
 *
 * A lazylist is just a list you defined as `null` rather than `list()`.
 * Then, you use the LAZY* macros to interact with it, which are essentially null-safe ways to interact with a list.
 *
 * Note that you probably should not be using these macros if your list is not a lazylist.
 * This will obfuscate the code and make it a bit harder to read and debug.
 *
 * Generally speaking you shouldn't be checking if your lazylist is `null` yourself, the macros will do that for you.
 * Remember that LAZYLEN (and by extension, length) will return 0 if the list is null.
 */

///Initialize the lazylist
#define LAZYINITLIST(L) if(!L) { L = list(); }
///If the provided list is empty, set it to null
#define UNSETEMPTY(L) if(L && !length(L)) L = null
///If the provided key -> list is empty, remove it from the list
#define ASSOC_UNSETEMPTY(L, K) if(!length(L[K])) L -= K;
///Like LAZYCOPY - copies an input list if the list has entries, If it doesn't the assigned list is nulled
#define LAZYLISTDUPLICATE(L) (L ? L.Copy() : null )
///Remove an item from the list, set the list to null if empty
#define LAZYREMOVE(L, I) if(L) { L -= I; if(!length(L)) { L = null; } }
///Add an item to the list, if the list is null it will initialize it
#define LAZYADD(L, I) if(!L) { L = list(); } L += I;
///Add an item to the list if not already present, if the list is null it will initialize it
#define LAZYOR(L, I) if(!L) { L = list(); } L |= I;
///Returns the key of the submitted item in the list
#define LAZYFIND(L, V) (L ? L.Find(V) : 0)
///returns L[I] if L exists and I is a valid index of L, runtimes if L is not a list
#define LAZYACCESS(L, I) (L ? (isnum(I) ? (I > 0 && I <= length(L) ? L[I] : null) : L[I]) : null)
///Sets the item K to the value V, if the list is null it will initialize it
#define LAZYSET(L, K, V) if(!L) { L = list(); } L[K] = V;
///Sets the length of a lazylist
#define LAZYSETLEN(L, V) if(!L) { L = list(); } L.len = V;
///Returns the length of the list
#define LAZYLEN(L) length(L)
///Sets a list to null
#define LAZYNULL(L) L = null
///Adds to the item K the value V, if the list is null it will initialize it
#define LAZYADDASSOC(L, K, V) if(!L) { L = list(); } L[K] += V;
///This is used to add onto lazy assoc list when the value you're adding is a /list/. This one has extra safety over lazyaddassoc because the value could be null (and thus cant be used to += objects)
#define LAZYADDASSOCLIST(L, K, V) if(!L) { L = list(); } L[K] += list(V);
///Removes the value V from the item K, if the item K is empty will remove it from the list, if the list is empty will set the list to null
#define LAZYREMOVEASSOC(L, K, V) if(L) { if(L[K]) { L[K] -= V; if(!length(L[K])) L -= K; } if(!length(L)) L = null; }
///Accesses an associative list, returns null if nothing is found
#define LAZYACCESSASSOC(L, I, K) L ? L[I] ? L[I][K] ? L[I][K] : null : null : null
///Qdel every item in the list before setting the list to null
#define QDEL_LAZYLIST(L) for(var/I in L) qdel(I); L = null;
//These methods don't null the list
///Use LAZYLISTDUPLICATE instead if you want it to null with no entries
#define LAZYCOPY(L) (L ? L.Copy() : list() )
/// Consider LAZYNULL instead
#define LAZYCLEARLIST(L) if(L) L.Cut()
///Returns the list if it's actually a valid list, otherwise will initialize it
#define SANITIZE_LIST(L) ( islist(L) ? L : list() )
/// Performs an insertion on the given lazy list with the given key and value. If the value already exists, a new one will not be made.
#define LAZYORASSOCLIST(lazy_list, key, value) \
	LAZYINITLIST(lazy_list); \
	LAZYINITLIST(lazy_list[key]); \
	lazy_list[key] |= value;
/// Calls Insert on the lazy list if it exists, otherwise initializes it with the value
#define LAZYINSERT(lazylist, index, value) \
	if(!lazylist) { \
		lazylist = list(value); \
	} else if(index == 0 && index > length(lazylist)) { \
		lazylist += value; \
	} else { \
		lazylist.Insert(index, value); \
	}
///Ensures the length of a list is at least I, prefilling it with V if needed. if V is a proc call, it is repeated for each new index so that list() can just make a new list for each item.
#define LISTASSERTLEN(L, I, V...) \
	if(length(L) < I) { \
		var/_OLD_LENGTH = length(L); \
		L.len = I; \
		/* Convert the optional argument to a if check */ \
		for(var/_USELESS_VAR in list(V)) { \
			for(var/_INDEX_TO_ASSIGN_TO in _OLD_LENGTH+1 to I) { \
				L[_INDEX_TO_ASSIGN_TO] = V; \
			} \
		} \
	}
///If the lazy list is currently initialized find item I in list L
#define LAZYIN(L, I) (L && (I in L))
///Clears a list and then re-initializes it
#define LAZYREINITLIST(L) LAZYCLEARLIST(L); LAZYINITLIST(L);
/// Returns whether a numerical index is within a given list's bounds. Faster than isnull(LAZYACCESS(L, I)).
#define ISINDEXSAFE(L, I) (I >= 1 && I <= length(L))

#define reverseList(L) reverse_range(L.Copy())

/// Passed into BINARY_INSERT to compare keys
#define COMPARE_KEY __BIN_LIST[__BIN_MID]
/// Passed into BINARY_INSERT to compare values
#define COMPARE_VALUE __BIN_LIST[__BIN_LIST[__BIN_MID]]

/**
 * Binary search sorted insert from TG
 * INPUT: Object to be inserted
 * LIST: List to insert object into
 * TYPECONT: The typepath of the contents of the list
 * COMPARE: The object to compare against, usualy the same as INPUT
 * COMPARISON: The variable on the objects to compare
 * COMPTYPE: How should the values be compared? Either COMPARE_KEY or COMPARE_VALUE.
 */
#define BINARY_INSERT(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			var ##TYPECONT/__BIN_ITEM;\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(__BIN_ITEM.##COMPARISON <= COMPARE.##COMPARISON) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = __BIN_ITEM.##COMPARISON > COMPARE.##COMPARISON ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)

/**
 * Custom binary search sorted insert utilising comparison procs instead of vars.
 * INPUT: Object to be inserted
 * LIST: List to insert object into
 * TYPECONT: The typepath of the contents of the list
 * COMPARE: The object to compare against, usualy the same as INPUT
 * COMPARISON: The plaintext name of a proc on INPUT that takes a single argument to accept a single element from LIST and returns a positive, negative or zero number to perform a comparison.
 * COMPTYPE: How should the values be compared? Either COMPARE_KEY or COMPARE_VALUE.
 */
#define BINARY_INSERT_PROC_COMPARE(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			var ##TYPECONT/__BIN_ITEM;\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(__BIN_ITEM.##COMPARISON(COMPARE) <= 0) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = __BIN_ITEM.##COMPARISON(COMPARE) > 0 ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)

#define SORT_FIRST_INDEX(list) (list[1])
#define SORT_PRIORITY_INDEX(list) (list["priority"])
#define SORT_COMPARE_DIRECTLY(thing) (thing)
#define SORT_VAR_NO_TYPE(varname) var/varname
/**
 * Even more custom binary search sorted insert, using defines instead of vars
 * INPUT: Item to be inserted
 * LIST: List to insert INPUT into
 * TYPECONT: A define setting the var to the typepath of the contents of the list
 * COMPARE: The item to compare against, usualy the same as INPUT
 * COMPARISON: A define that takes an item to compare as input, and returns their comparable value
 * COMPTYPE: How should the list be compared? Either COMPARE_KEY or COMPARE_VALUE.
 */
#define BINARY_INSERT_DEFINE(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			##TYPECONT(__BIN_ITEM);\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(##COMPARISON(__BIN_ITEM) <= ##COMPARISON(COMPARE)) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = ##COMPARISON(__BIN_ITEM) > ##COMPARISON(COMPARE) ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)

/**
 * Returns a list in plain english as a string
 *
 * Arguments:
 * * input_list - The list to convert to a string
 * * nothing_text - Text to return if the list is empty
 * * and_text - Text to use before the last item
 * * comma_text - Text to use between items
 * * final_comma_text - Text to use before the last item (replaces comma_text for the last comma)
 */
/proc/english_list(list/input_list, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "" )
	var/list_length = length(input_list)
	if(!list_length)
		return "[nothing_text]"
	else if(list_length == 1)
		return "[input_list[1]]"
	else if(list_length == 2)
		return "[input_list[1]][and_text][input_list[2]]"
	else
		var/output = ""
		var/current_index = 1
		while(current_index < list_length)
			if(current_index == list_length - 1)
				comma_text = final_comma_text

			output += "[input_list[current_index]][comma_text]"
			current_index++

		return "[output][and_text][input_list[current_index]]"

/**
 * Returns a list in plain russian as a string
 *
 * Arguments:
 * * input_list - The list to convert to a string
 * * nothing_text - Text to return if the list is empty
 * * and_text - Text to use before the last item
 * * comma_text - Text to use between items
 * * final_comma_text - Text to use before the last item (replaces comma_text for the last comma)
 */
/proc/russian_list(list/input_list, nothing_text = "ничего", and_text = " и ", comma_text = ", ", final_comma_text = "" )
	var/list_length = length(input_list)
	if(!list_length)
		return "[nothing_text]"
	else if(list_length == 1)
		return "[input_list[1]]"
	else if(list_length == 2)
		return "[input_list[1]][and_text][input_list[2]]"
	else
		var/output = ""
		var/current_index = 1
		while(current_index < list_length)
			if(current_index == list_length - 1)
				comma_text = final_comma_text

			output += "[input_list[current_index]][comma_text]"
			current_index++

		return "[output][and_text][input_list[current_index]]"

/**
 * Returns list element or null. Should prevent "index out of bounds" error.
 *
 * Arguments:
 * * source_list - The list to get the element from
 * * element_index - The index or key of the element to retrieve
 */
/proc/listgetindex(list/source_list, element_index)
	if(!istype(source_list))
		return

	if(isnum(element_index) && ISINTEGER(element_index) && ISINRANGE(element_index, 1, length(source_list)))
		return source_list[element_index]

	else if(element_index in source_list)
		return source_list[element_index]

/**
 * Return either pick(list) or null if list is not of type /list or is empty
 *
 * Arguments:
 * * source_list - The list to pick a random element from
 */
/proc/safepick(list/source_list)
	if(!islist(source_list) || !length(source_list))
		return
	return pick(source_list)

/**
 * Returns the top (last) element from the list, does not remove it from the list. Stack functionality.
 *
 * Arguments:
 * * target_list - The list to peek at
 */
/proc/peek(list/target_list)
	var/list_length = length(target_list)
	if(list_length != 0)
		return target_list[list_length]

/**
 * Checks if the list is empty
 *
 * Arguments:
 * * target_list - The list to check for emptiness
 */
/proc/isemptylist(list/target_list)
	return !length(target_list)

/**
 * Checks if an atom is of a type present in the given list
 *
 * Arguments:
 * * checked_atom - The atom to check the type of
 * * target_list - The list of types to check against
 * * check_subtypes - If TRUE, includes subtypes in the check
 */
/proc/is_type_in_list(atom/checked_atom, list/target_list, check_subtypes = TRUE)
	if(!checked_atom || !length(target_list) || !checked_atom)
		return FALSE
	for(var/target_type in target_list)
		if(check_subtypes)
			if(istype(checked_atom, target_type))
				return TRUE
		else
			if(checked_atom.type == target_type)
				return TRUE
	return FALSE

/**
 * Checks if an atom's type is present in a typecache list
 *
 * Arguments:
 * * checked_atom - The atom to check the type of
 * * type_cache - The typecache list to check against
 */
/proc/is_type_in_typecache(atom/checked_atom, list/type_cache)
	if(!type_cache || !length(type_cache) || !checked_atom)
		return FALSE
	return type_cache[checked_atom.type]

/**
 * Returns a new list with only atoms that are in the provided typecache
 *
 * Arguments:
 * * source_atoms - The list of atoms to filter
 * * filter_typecache - The typecache used for filtering
 */
/proc/typecache_filter_list(list/source_atoms, list/filter_typecache)
	RETURN_TYPE(/list)
	. = list()
	for(var/atom/current_atom as anything in source_atoms)
		if(filter_typecache[current_atom.type])
			. += current_atom

/**
 * Returns a new list with atoms that are not in the provided typecache
 *
 * Arguments:
 * * source_atoms - The list of atoms to filter
 * * filter_typecache - The typecache used for filtering
 */
/proc/typecache_filter_list_reverse(list/source_atoms, list/filter_typecache)
	RETURN_TYPE(/list)
	. = list()
	for(var/atom/current_atom as anything in source_atoms)
		if(!filter_typecache[current_atom.type])
			. += current_atom

/**
 * Filters atoms using both inclusion and exclusion typecaches
 *
 * Arguments:
 * * source_atoms - The list of atoms to filter
 * * inclusion_typecache - The typecache of types to include
 * * exclusion_typecache - The typecache of types to exclude
 */
/proc/typecache_filter_multi_list_exclusion(list/source_atoms, list/inclusion_typecache, list/exclusion_typecache)
	. = list()
	for(var/atom/current_atom as anything in source_atoms)
		if(inclusion_typecache[current_atom.type] && !exclusion_typecache[current_atom.type])
			. += current_atom

/**
 * Like typesof() or subtypesof(), but returns a typecache instead of a list.
 * This time it also uses the associated values given by the input list for the values of the subtypes.
 *
 * Latter values from the input list override earlier values.
 * Thus subtypes should come _after_ parent types in the input list.
 * Notice that this is the opposite priority of [/proc/is_type_in_list] and [/proc/is_path_in_list].
 *
 * Arguments:
 * - path: A typepath or list of typepaths with associated values.
 * - single_value: The assoc value used if only a single path is passed as the first variable.
 * - only_root_path: Whether the typecache should be specifically of the passed types.
 * - ignore_root_path: Whether to ignore the root path when caching subtypes.
 * - clear_nulls: Whether to remove keys with null assoc values from the typecache after generating it.
 */
/proc/zebra_typecacheof(path, single_value = TRUE, only_root_path = FALSE, ignore_root_path = FALSE, clear_nulls = FALSE)
	if(isnull(path))
		return

	if(ispath(path))
		if(isnull(single_value))
			return

		. = list()
		if(only_root_path)
			.[path] = single_value
			return

		for(var/subtype in (ignore_root_path ? subtypesof(path) : typesof(path)))
			.[subtype] = single_value
		return

	if(!islist(path))
		CRASH("Tried to create a typecache of [path] which is neither a typepath nor a list.")

	. = list()
	var/list/pathlist = path
	if(only_root_path)
		for(var/current_path in pathlist)
			.[current_path] = pathlist[current_path]
	else if(ignore_root_path)
		for(var/current_path in pathlist)
			for(var/subtype in subtypesof(current_path))
				.[subtype] = pathlist[current_path]
	else
		for(var/current_path in pathlist)
			for(var/subpath in typesof(current_path))
				.[subpath] = pathlist[current_path]

	if(!clear_nulls)
		return

	for(var/cached_path in .)
		if(isnull(.[cached_path]))
			. -= cached_path

// MARK: TODO: REF
/// Like typesof() or subtypesof(), but returns a typecache instead of a list
/proc/typecacheof(path, ignore_root_path, only_root_path = FALSE)
	if(ispath(path))
		var/list/types = list()
		if(only_root_path)
			types = list(path)
		else
			types = ignore_root_path ? subtypesof(path) : typesof(path)
		var/list/L = list()
		for(var/T in types)
			L[T] = TRUE
		return L
	else if(islist(path))
		var/list/pathlist = path
		var/list/L = list()
		if(ignore_root_path)
			for(var/P in pathlist)
				for(var/T in subtypesof(P))
					L[T] = TRUE
		else
			for(var/P in pathlist)
				if(only_root_path)
					L[P] = TRUE
				else
					for(var/T in typesof(P))
						L[T] = TRUE
		return L

// MARK: TODO: REF
/// Returns a list containing all subtypes of the given path, but not the given path itself.
/proc/subtypesof(path)
	if(!path || !ispath(path))
		CRASH("Invalid path, failed to fetch subtypes of \"[path]\".")
	return (typesof(path) - path)

/**
 * Removes any null entries from the list
 * Returns TRUE if the list had nulls, FALSE otherwise
 *
 * Arguments:
 * * target_list - The list to remove null entries from
 */
/proc/list_clear_nulls(list/target_list)
	return (target_list.RemoveAll(null) > 0)

/**
 * Removes any empty weakrefs from the list
 * Returns TRUE if the list had empty refs, FALSE otherwise
 *
 * Arguments:
 * * target_list - The list to remove empty weakrefs from
 */
/proc/list_clear_empty_weakrefs(list/target_list)
	var/initial_length = length(target_list)
	for(var/datum/weakref/weakref_entry in target_list)
		if(!weakref_entry.resolve())
			target_list -= weakref_entry
	return length(target_list) < initial_length

/**
 * Returns list containing all the entries from first list that are not present in second.
 * If skiprep = TRUE, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 *
 * Arguments:
 * * first_list - The first list to compare
 * * second_list - The second list to compare against
 * * skip_duplicates - If TRUE, repeated elements are treated as one
 */
/proc/difflist(list/first_list, list/second_list, skip_duplicates = FALSE)
	if(!islist(first_list) || !islist(second_list))
		return
	var/list/result_list = new
	if(skip_duplicates)
		for(var/list_entry in first_list)
			if(!(list_entry in result_list) && !(list_entry in second_list))
				UNTYPED_LIST_ADD(result_list, list_entry)
	else
		result_list = first_list - second_list
	return result_list

/**
 * Picks a random element from a list based on a weighting system.
 * All keys with zero or non integer weight will be considered as one
 * For example, given the following list:
 * A = 5, B = 3, C = 1, D = 0
 * A would have a 50% chance of being picked,
 * B would have a 30% chance of being picked,
 * C would have a 10% chance of being picked,
 * and D would have a 10% chance of being picked.
 * This proc not modify input list
 *
 * Arguments:
 * * weighted_list - The list with weights to pick from
 */
/proc/pickweight(list/weighted_list)
	var/total_weight = 0
	for(var/current_item in weighted_list)
		var/current_weight = weighted_list[current_item]
		if(!current_weight)
			current_weight = 1
		total_weight += current_weight

	total_weight = rand(1, total_weight)
	for(var/current_item in weighted_list)
		var/current_weight = weighted_list[current_item]
		if(!current_weight)
			current_weight = 1
		total_weight -= current_weight
		if(total_weight <= 0)
			return current_item

	return null

/**
 * Picks a random element from a list based on a weighting system.
 * All keys with zero or non integer weight will be considered as zero
 * For example, given the following list:
 * A = 6, B = 3, C = 1, D = 0
 * A would have a 60% chance of being picked,
 * B would have a 30% chance of being picked,
 * C would have a 10% chance of being picked,
 * and D would have a 0% chance of being picked.
 * This proc not modify input list
 *
 * Arguments:
 * * weighted_list - The list with weights to pick from
 */
/proc/pick_weight_classic(list/weighted_list)
	if(length(weighted_list) == 0)
		return null

	var/total_weight = 0
	for(var/current_item in weighted_list)
		var/current_weight = weighted_list[current_item]
		if(!current_weight)
			continue
		total_weight += current_weight

	total_weight = rand(1, total_weight)
	for(var/current_item in weighted_list)
		var/current_weight = weighted_list[current_item]
		if(!current_weight)
			continue
		total_weight -= current_weight
		if(total_weight <= 0)
			return current_item

	return null

/**
 * Pick a random element from the list and remove it from the list.
 *
 * Arguments:
 * * source_list - The list to pick and remove from
 */
/proc/pick_n_take(list/source_list)
	RETURN_TYPE(source_list[_].type)
	if(length(source_list))
		var/chosen_index = rand(1, length(source_list))
		. = source_list[chosen_index]
		source_list.Cut(chosen_index, chosen_index + 1) // Cut is far more efficient that Remove()

/**
 * Like pick_weight, but allowing for nested lists.
 *
 * For example, given the following list:
 * list(A = 1, list(B = 1, C = 1))
 * A would have a 50% chance of being picked,
 * and list(B, C) would have a 50% chance of being picked.
 * If list(B, C) was picked, B and C would then each have a 50% chance of being picked.
 * So the final probabilities would be 50% for A, 25% for B, and 25% for C.
 *
 * Weights should be integers. Entries without weights are assigned weight 1 (so unweighted lists can be used as well)
 */
/proc/pick_weight_recursive(list/list_to_pick)
	var/result = pick_weight_classic(fill_with_ones(list_to_pick))
	while(islist(result))
		result = pick_weight_classic(fill_with_ones(result))
	return result

/**
 * Picks a random element by weight from the list and removes it from the list
 *
 * Arguments:
 * * source_list - The weighted list to pick and remove from
 */
/proc/pick_weight_n_take(list/source_list)
	RETURN_TYPE(source_list[_].type)
	if(length(source_list) > 0)
		var/selected_item = pick_weight_classic(source_list)
		source_list -= selected_item
		return selected_item
	return null

/**
 * Picks multiple unique elements from the suplied list.
 * If the given list has a length less than the amount given then it will return a list with an equal amount
 *
 * Arguments:
 * * listfrom - The list where to pick from
 * * amount - The amount of elements it tries to pick.
 */
/proc/pick_multiple_unique(list/listfrom, amount)
	var/list/result = list()
	var/list/copy = listfrom.Copy() // Ensure the original ain't modified
	while(length(copy) && length(result) < amount)
		var/picked = pick(copy)
		result += picked
		copy -= picked
	return result

/**
 * Given a list, return a copy where values without defined weights are given weight 1.
 * For example, fill_with_ones(list(A, B=2, C)) = list(A=1, B=2, C=1)
 * Useful for weighted random choices (loot tables, syllables in languages, etc.)
 */
/proc/fill_with_ones(list/list_to_pad)
	if(!islist(list_to_pad))
		return list_to_pad

	var/list/final_list = list()

	for(var/key in list_to_pad)
		if(list_to_pad[key])
			final_list[key] = list_to_pad[key]
		else
			final_list[key] = 1

	return final_list

/**
 * Returns the top (last) element from the list, does not remove it from the list. Stack functionality.
 *
 * Arguments:
 * * target_list - The list to pop from
 */
/proc/pop(list/target_list)
	if(length(target_list))
		. = target_list[length(target_list)]
		target_list.len--

/**
 * Returns the first element from the list and removes it. Queue functionality.
 *
 * Arguments:
 * * target_list - The list to pop from
 */
/proc/popleft(list/target_list)
	if(length(target_list))
		. = target_list[1]
		target_list.Cut(1, 2)

/**
 * Returns a new list with the elements in random order
 *
 * Arguments:
 * * source_list - The list to shuffle
 */
/proc/shuffle(list/source_list)
	if(!source_list)
		return
	source_list = source_list.Copy()

	for(var/current_index in 1 to length(source_list) - 1)
		source_list.Swap(current_index, rand(current_index, length(source_list)))

	return source_list

// MARK: TODO: REF
//Mergesort: divides up the list into halves to begin the sort
/proc/sort_key(list/client/L, order = 1)
	if(isnull(L) || length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1
	return mergeKey(sort_key(L.Copy(0,middle)), sort_key(L.Copy(middle)), order)

// MARK: TODO: REF
//Mergsort: does the actual sorting and returns the results back to sortAtom
/proc/mergeKey(list/client/L, list/client/R, order = 1)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= length(L) && Ri <= length(R))
		var/client/rL = L[Li]
		var/client/rR = R[Ri]
		if(sorttext(rL.ckey, rR.ckey) == order)
			result += L[Li++]
		else
			result += R[Ri++]

	if(Li <= length(L))
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

// MARK: TODO: REF
//Mergesort: divides up the list into halves to begin the sort
/proc/sortAtom(list/atom/L, order = 1)
	list_clear_nulls(L)
	if(isnull(L) || length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1
	return mergeAtoms(sortAtom(L.Copy(0,middle)), sortAtom(L.Copy(middle)), order)

// MARK: TODO: REF
//Mergsort: does the actual sorting and returns the results back to sortAtom
/proc/mergeAtoms(list/atom/L, list/atom/R, order = 1)
	if(!L || !R) return 0
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= length(L) && Ri <= length(R))
		var/atom/rL = L[Li]
		var/atom/rR = R[Ri]
		if(sorttext(rL.name, rR.name) == order)
			result += L[Li++]
		else
			result += R[Ri++]

	if(Li <= length(L))
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

// MARK: TODO: REF
//Mergesort: Specifically for record datums in a list.
/proc/sortRecord(list/datum/data/record/L, field = "name", order = 1)
	if(isnull(L))
		return list()
	if(length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1
	return mergeRecordLists(sortRecord(L.Copy(0, middle), field, order), sortRecord(L.Copy(middle), field, order), field, order)

// MARK: TODO: REF
//Mergsort: does the actual sorting and returns the results back to sortRecord
/proc/mergeRecordLists(list/datum/data/record/L, list/datum/data/record/R, field = "name", order = 1)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	if(!isnull(L) && !isnull(R))
		while(Li <= length(L) && Ri <= length(R))
			var/datum/data/record/rL = L[Li]
			if(isnull(rL))
				L -= rL
				continue
			var/datum/data/record/rR = R[Ri]
			if(isnull(rR))
				R -= rR
				continue
			if(sorttext(rL.fields[field], rR.fields[field]) == order)
				result += L[Li++]
			else
				result += R[Ri++]

		if(Li <= length(L))
			return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

// MARK: TODO: REF
//Mergesort: any value in a list
/proc/sortList(list/L)
	if(length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1 // Copy is first,second-1
	return mergeLists(sortList(L.Copy(0,middle)), sortList(L.Copy(middle))) //second parameter null = to end of list

// MARK: TODO: REF
//Mergsorge: uses sortAssoc() but uses the var's name specifically. This should probably be using mergeAtom() instead
/proc/sortNames(list/L)
	var/list/Q = new()
	for(var/atom/x in L)
		Q[x.name] = x
	return sortAssoc(Q)

// MARK: TODO: REF
/proc/mergeLists(list/L, list/R)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= length(L) && Ri <= length(R))
		if(sorttext(L[Li], R[Ri]) < 1)
			result += R[Ri++]
		else
			result += L[Li++]

	if(Li <= length(L))
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

// MARK: TODO: REF
// List of lists, sorts by element[key] - for things like crew monitoring computer sorting records by name.
/proc/sortByKey(list/L, key)
	if(length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1
	return mergeKeyedLists(sortByKey(L.Copy(0, middle), key), sortByKey(L.Copy(middle), key), key)

// MARK: TODO: REF
/proc/mergeKeyedLists(list/L, list/R, key)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= length(L) && Ri <= length(R))
		if(sorttext(L[Li][key], R[Ri][key]) < 1)
			// Works around list += list2 merging lists; it's not pretty but it works
			result += "temp item"
			result[length(result)] = R[Ri++]
		else
			result += "temp item"
			result[length(result)] = L[Li++]

	if(Li <= length(L))
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

// MARK: TODO: REF
//Mergesort: any value in a list, preserves key=value structure
/proc/sortAssoc(list/L)
	if(length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1 // Copy is first,second-1
	return mergeAssoc(sortAssoc(L.Copy(0,middle)), sortAssoc(L.Copy(middle))) //second parameter null = to end of list

// MARK: TODO: REF
/proc/mergeAssoc(list/L, list/R)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= length(L) && Ri <= length(R))
		if(sorttext(L[Li], R[Ri]) < 1)
			result += R&R[Ri++]
		else
			result += L&L[Li++]

	if(Li <= length(L))
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

#define MAX_BITFIELD_BITS 24

/**
 * Converts a bitfield to a list of numbers (or words if a wordlist is provided)
 *
 * Arguments:
 * * input_bitfield - The bitfield to convert to a list
 * * word_list - Optional list of words to use instead of numeric bit values
 */
/proc/bitfield_to_list(input_bitfield = 0, list/word_list)
	var/list/result_list = list()
	if(islist(word_list))
		var/max_index = min(length(word_list), MAX_BITFIELD_BITS)
		var/current_bit = 1
		for(var/current_index in 1 to max_index)
			if(input_bitfield & current_bit)
				result_list += word_list[current_index]
			current_bit = current_bit << 1
	else
		for(var/bit_position = 0 to (MAX_BITFIELD_BITS - 1))
			var/bit_value = 1 << bit_position
			if(input_bitfield & bit_value)
				result_list += bit_value

	return result_list

#undef MAX_BITFIELD_BITS

/// Returns the key based on the index
#define KEYBYINDEX(L, index) (((index <= length(L)) && (index > 0)) ? L[index] : null)

/**
 * Counts the number of items of a specified type in a list
 *
 * Arguments:
 * * source_list - The list to search through
 * * target_type - The type to count instances of
 */
/proc/count_by_type(list/source_list, target_type)
	var/count = 0
	for(var/current_item in source_list)
		if(istype(current_item, target_type))
			count++
	return count

/**
 * Recursively copies a list and all lists contained within it
 * Does not copy any other reference types
 *
 * Arguments:
 * * source_list - The list to deep copy
 */
/proc/deep_copy_list(list/source_list)
	if(!islist(source_list))
		return source_list
	. = source_list.Copy()
	for(var/index in 1 to length(source_list))
		var/current_key = .[index]
		if(isnum(current_key))
			// Numbers cannot ever be associative keys
			continue
		var/current_value = .[current_key]
		if(islist(current_value))
			current_value = deep_copy_list(current_value)
			.[current_key] = current_value
		if(islist(current_key))
			current_key = deep_copy_list(current_key)
			.[index] = current_key
			.[current_key] = current_value

// MARK: TODO: REF
/proc/dd_sortedObjectList(list/L, cache=list())
	if(length(L) < 2)
		return L
	var/middle = length(L) / 2 + 1 // Copy is first,second-1
	return dd_mergeObjectList(dd_sortedObjectList(L.Copy(0,middle), cache), dd_sortedObjectList(L.Copy(middle), cache), cache) //second parameter null = to end of list

// MARK: TODO: REF
/proc/dd_mergeObjectList(list/L, list/R, list/cache)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= length(L) && Ri <= length(R))
		var/LLi = L[Li]
		var/RRi = R[Ri]
		var/LLiV = cache[LLi]
		var/RRiV = cache[RRi]
		if(!LLiV)
			LLiV = LLi:dd_SortValue()
			cache[LLi] = LLiV
		if(!RRiV)
			RRiV = RRi:dd_SortValue()
			cache[RRi] = RRiV
		if(LLiV < RRiV)
			result += L[Li++]
		else
			result += R[Ri++]

	if(Li <= length(L))
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

// MARK: TODO: REF
/datum/proc/dd_SortValue()
	return "[src]"

// MARK: TODO: REF
/obj/machinery/dd_SortValue()
	return "[sanitize(name)]"

// MARK: TODO: REF
/obj/machinery/camera/dd_SortValue()
	return "[c_tag]"

/// Picks from the list, with some safeties, and returns the "default" arg if it fails
#define DEFAULTPICK(L, default) ((islist(L) && length(L)) ? pick(L) : default)

/**
 * Shuffles a list in place and returns the same list
 *
 * Arguments:
 * * target_list - The list to shuffle
 */
/proc/shuffle_inplace(list/target_list)
	if(!target_list)
		return

	for(var/current_index in 1 to length(target_list) - 1)
		target_list.Swap(current_index, rand(current_index, length(target_list)))

	return target_list

/**
 * Returns a new list with no duplicate entries
 *
 * Arguments:
 * * source_list - The list to remove duplicates from
 */
/proc/unique_list(list/source_list)
	. = list()
	for(var/list_element in source_list)
		. |= LIST_VALUE_WRAP_LISTS(list_element)

/**
 * Removes duplicate entries from a list in place, preserving associated values
 *
 * Arguments:
 * * target_list - The list to remove duplicates from (modified in place)
 */
/proc/unique_list_in_place(list/target_list)
	var/list/temporary_copy = target_list.Copy()
	target_list.len = 0
	for(var/current_key in temporary_copy)
		if(isnum(current_key))
			target_list |= current_key
		else
			target_list[current_key] = temporary_copy[current_key]

/**
 * Moves a single element from one position to another within a list, preserving associations
 *
 * Arguments:
 * * target_list - The list to modify
 * * source_index - The current index of the element to move (1 to list length)
 * * destination_index - The target index for the element (1 to list length + 1)
 */
/proc/move_element(list/target_list, source_index, destination_index)
	if(source_index == destination_index || source_index + 1 == destination_index) // No need to move
		return
	if(source_index > destination_index)
		++source_index // Since a null will be inserted before source_index, the index needs to be nudged right by one

	target_list.Insert(destination_index, null)
	target_list.Swap(source_index, destination_index)
	target_list.Cut(source_index, source_index + 1)

/**
 * Moves a range of elements from one position to another within a list, preserving associations
 *
 * Arguments:
 * * target_list - The list to modify
 * * source_index - The starting index of the range to move
 * * destination_index - The target starting index for the range
 * * range_length - The number of elements to move (default: 1)
 */
/proc/move_range(list/target_list, source_index, destination_index, range_length = 1)
	var/distance = abs(destination_index - source_index)
	if(range_length >= distance) // More elements to move than distance - shift left/right by distance
		if(source_index <= destination_index)
			return // No need to move
		source_index += range_length // We want to shift left instead of right

		for(var/iteration in 1 to distance)
			target_list.Insert(source_index, null)
			target_list.Swap(source_index, destination_index)
			target_list.Cut(destination_index, destination_index + 1)
	else
		if(source_index > destination_index)
			source_index += range_length

		for(var/iteration in 1 to range_length)
			target_list.Insert(destination_index, null)
			target_list.Swap(source_index, destination_index)
			target_list.Cut(source_index, source_index + 1)

/**
 * Swaps two ranges of elements within a list, preserving order of overwritten elements
 * Note: If ranges overlap, only the destination order will be fully preserved
 *
 * Arguments:
 * * target_list - The list to modify
 * * first_range_start - The starting index of the first range
 * * second_range_start - The starting index of the second range
 * * range_length - The length of the ranges to swap (default: 1)
 */
/proc/swap_range(list/target_list, first_range_start, second_range_start, range_length = 1)
	var/distance = abs(second_range_start - first_range_start)
	if(range_length > distance) // Overlap detected - use insertion method
		if(first_range_start < second_range_start)
			second_range_start += range_length
		else
			first_range_start += range_length

		for(var/iteration in 1 to distance)
			target_list.Insert(first_range_start, null)
			target_list.Swap(first_range_start, second_range_start)
			target_list.Cut(second_range_start, second_range_start + 1)
	else
		if(second_range_start > first_range_start)
			var/temp = second_range_start
			second_range_start = first_range_start
			first_range_start = temp

		for(var/iteration in 1 to range_length)
			target_list.Swap(first_range_start++, second_range_start++)

/**
 * Scales all values in a counter list by a given scalar factor
 *
 * Arguments:
 * * source_list - The list of key-value pairs to scale
 * * scale_factor - The scalar value to multiply each value by
 */
/proc/counterlist_scale(list/source_list, scale_factor)
	var/list/scaled_list = list()
	for(var/list_key in source_list)
		scaled_list[list_key] = source_list[list_key] * scale_factor
	. = scaled_list

/**
 * Calculates the sum of all values in a counter list
 *
 * Arguments:
 * * source_list - The list of key-value pairs to sum
 */
/proc/counterlist_sum(list/source_list)
	. = 0
	for(var/list_key in source_list)
		. += source_list[list_key]

/**
 * Normalizes a counter list by dividing each value by the total sum
 *
 * Arguments:
 * * source_list - The list of key-value pairs to normalize
 */
/proc/counterlist_normalise(list/source_list)
	var/total_sum = counterlist_sum(source_list)
	if(total_sum != 0)
		. = counterlist_scale(source_list, 1 / total_sum)
	else
		. = source_list

/**
 * Combines two counter lists by adding values for matching keys
 *
 * Arguments:
 * * base_list - The base list to which values will be added
 * * additional_list - The list containing additional values to combine
 */
/proc/counterlist_combine(list/base_list, list/additional_list)
	for(var/list_key in additional_list)
		var/additional_value = additional_list[list_key]
		if(list_key in base_list)
			base_list[list_key] += additional_value
		else
			base_list[list_key] = additional_value

/**
 * A proc for turning a list into an associative list.
 *
 * A simple proc for turning all things in a list into an associative list, instead
 * Each item in the list will have an associative value of TRUE

 * Arguments:
 * * flat_list - the list that it passes to make associative
 */
/proc/make_associative(list/flat_list)
	. = list()
	for(var/thing in flat_list)
		.[thing] = TRUE

/**
 * Removes all occurrences of a specified element from a list
 *
 * Arguments:
 * * element_to_remove - The element to remove from the list
 * * target_list - The list from which to remove the element
 */
/proc/list_clear_duplicates(element_to_remove, list/target_list)
	if(!istype(target_list))
		stack_trace("Wrong type of list passed.")
		return
	while(element_to_remove in target_list)
		target_list -= element_to_remove

// MARK: TODO: REF
///sort any value in a list
/proc/sort_list(list/list_to_sort, cmp = /proc/cmp_text_asc)
	return sortTim(list_to_sort.Copy(), cmp)

// MARK: TODO: REF
///uses sort_list() but uses the var's name specifically
/proc/sort_names(list/list_to_sort)
	return sort_list(list_to_sort, cmp = /proc/cmp_name_asc)

/**
 * Takes a weighted list and expands it into raw entries
 * This eats more memory, but saves time when actually picking from it
 *
 * Arguments:
 * * weighted_list - The weighted list to expand
 */
/proc/expand_weights(list/weighted_list)
	var/list/weight_values = list()
	for(var/current_item in weighted_list)
		var/current_weight = weighted_list[current_item]
		if(!current_weight)
			continue
		weight_values += current_weight

	var/common_factor = greatest_common_factor(weight_values)

	var/list/expanded_list = list()
	for(var/current_item in weighted_list)
		var/current_weight = weighted_list[current_item]
		if(!current_weight)
			continue
		for(var/iteration_index in 1 to current_weight / common_factor)
			UNTYPED_LIST_ADD(expanded_list, current_item)
	return expanded_list

/**
 * Takes a list of numbers and returns the highest value that cleanly divides them all
 * Note: this implementation is expensive for large numbers, intended for small lists
 *
 * Arguments:
 * * number_list - The list of numbers to find the greatest common factor for
 */
/proc/greatest_common_factor(list/number_list)
	var/smallest_value = min(number_list)
	for(var/current_divisor in smallest_value to 1 step -1)
		var/is_common_factor = TRUE
		for(var/current_number in number_list)
			if(current_number % current_divisor != 0)
				is_common_factor = FALSE
				break
		if(is_common_factor)
			return current_divisor

/**
 * Compare two lists, returns TRUE if they are the same
 *
 * Arguments:
 * * first_list - The first list to compare
 * * second_list - The second list to compare
 */
/proc/compare_list(list/first_list, list/second_list)
	if(!islist(first_list) || !islist(second_list))
		return FALSE

	if(first_list.len != second_list.len)
		return FALSE

	for(var/current_index in 1 to first_list.len)
		if(first_list[current_index] != second_list[current_index])
			return FALSE

	return TRUE

/**
 * Verifies that a list is sorted according to the given comparator function
 * Throws a runtime error if the list is not sorted
 *
 * Arguments:
 * * target_list - The list to check for sorted order
 * * list_name - The name of the list for error reporting
 * * cmp - The comparison function to use (default: numeric ascending)
 */
/proc/assert_sorted(list/target_list, list_name, cmp = GLOBAL_PROC_REF(cmp_numeric_asc))
	var/previous_value = target_list[1]

	for(var/current_index in 2 to length(target_list))
		var/current_value = target_list[current_index]

		if(call(cmp)(current_value, previous_value) < 0)
			stack_trace("[list_name] is not sorted. value at [current_index] ([current_value]) is in the wrong place compared to the previous value of [previous_value] (when compared to by [cmp])")

		previous_value = current_value

/**
 * Converts an associative list into a flat list of keys
 *
 * Arguments:
 * * associative_list - The associative list to extract keys from
 */
/proc/assoc_to_keys(list/associative_list)
	var/list/key_list = list()
	for(var/key in associative_list)
		UNTYPED_LIST_ADD(key_list, key)
	return key_list

/**
 * Reverses the order of elements in a list within the specified range
 * Replaces reverseList ~Carnie
 *
 * Arguments:
 * * target_list - The list to reverse
 * * start_index - The starting index of the range to reverse (default: 1)
 * * end_index - The ending index of the range to reverse (default: 0, meaning end of list)
 */
/proc/reverse_range(list/target_list, start_index = 1, end_index = 0)
	if(length(target_list))
		start_index = start_index % length(target_list)
		end_index = end_index % (length(target_list) + 1)
		if(start_index <= 0)
			start_index += length(target_list)
		if(end_index <= 0)
			end_index += length(target_list) + 1

		--end_index
		while(start_index < end_index)
			target_list.Swap(start_index++, end_index--)

	return target_list

/**
 * Takes an input_key, as text, and the list of keys already used, outputting a replacement key in the format of "[input_key] ([number_of_duplicates])" if it finds a duplicate
 * Use this for lists of things that might have the same name, like mobs or objects, that you plan on giving to a player as input
 *
 * Arguments:
 * * input_key - The key to check for duplicates
 * * used_keys - List of keys already in use
 */
/proc/avoid_assoc_duplicate_keys(input_key, list/used_keys)
	if(!input_key || !istype(used_keys))
		return
	if(used_keys[input_key])
		used_keys[input_key]++
		input_key = "[input_key] ([used_keys[input_key]])"
	else
		used_keys[input_key] = 1
	return input_key

/**
 * Checks if two lists contain the same elements, ignoring order
 *
 * Arguments:
 * * first_list - First list to compare
 * * second_list - Second list to compare
 */
/proc/lists_equal_unordered(list/first_list, list/second_list)
	// This ensures that both lists contain the same elements by checking if the difference between them is empty in both directions.
	return !length(first_list ^ second_list)

/**
 * Converts a list to a string representation in "list(key => value, ...)" format
 *
 * Arguments:
 * * source_list - The list to convert to string
 */
/proc/print_single_line(list/source_list)
	. = "list("
	for(var/current_index in 1 to length(source_list))
		var/current_key = source_list[current_index]
		. += "[current_key]"
		var/current_value = source_list[current_key]
		if(!isnull(current_value))
			. += " => [current_value]"
		if(current_index < length(source_list))
			. += ", "
	. += ")"

/**
 * Counts the number of nested lists within a list, up to a maximum count
 *
 * Arguments:
 * * target_list - The list to count nested lists in
 * * max_count - Maximum number of lists to count before returning
 */
/proc/get_list_count(list/target_list, max_list_count)
	var/list/lists_to_process = list()
	lists_to_process += list(target_list)
	var/list_count = 1
	while(length(lists_to_process))
		var/list/current_list = lists_to_process[length(lists_to_process)]
		lists_to_process.len--
		for(var/list/nested_list in current_list)
			lists_to_process += list(nested_list)
			list_count += 1
		if(list_count > max_list_count)
			return list_count

	return list_count

/// A version of deep_copy_list that actually supports associative list nesting: list(list(list("a" = "b"))) will actually copy correctly.
/proc/deep_copy_list_alt(list/inserted_list)
	if(!islist(inserted_list))
		return inserted_list
	var/copied_list = inserted_list.Copy()
	. = copied_list
	for(var/key_or_value in inserted_list)
		if(isnum(key_or_value) || !inserted_list[key_or_value])
			continue
		var/value = inserted_list[key_or_value]
		var/new_value = value
		if(islist(value))
			new_value = deep_copy_list_alt(value)
		copied_list[key_or_value] = new_value
