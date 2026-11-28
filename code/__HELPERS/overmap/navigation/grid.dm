/proc/overmap_nav_heap_push(list/heap, list/item)
	heap += list(item)
	var/index = length(heap)
	while(index > 1)
		var/parent = FLOOR(index / 2, 1)
		var/list/above = heap[parent]
		if(above[4] <= item[4])
			break
		heap[index] = above
		index = parent
	heap[index] = item

/proc/overmap_nav_heap_pop(list/heap)
	. = heap[1]
	var/list/item = heap[length(heap)]
	heap.len--
	if(!length(heap))
		return
	var/index = 1
	while(index * 2 <= length(heap))
		var/child = index * 2
		var/list/next = heap[child]
		if(child < length(heap))
			var/list/right = heap[child + 1]
			if(right[4] < next[4])
				child++
				next = right
		if(next[4] >= item[4])
			break
		heap[index] = next
		index = child
	heap[index] = item
