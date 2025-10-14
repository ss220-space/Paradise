/priority_queue
	var/list/priority_node/heap = list()

/priority_node
	var/item
	var/priority

/priority_node/New(item, priority)
	. = ..()
	src.item = item
	src.priority = priority

/priority_queue/proc/enqueue(value, priority)
	heap += list(new /priority_node(value, priority))
	bubble_up(length(heap))

/priority_queue/proc/dequeue()
	if(length(heap) == 0)
		return null

	var/priority_node/top = heap[1]
	var/bottom = heap[length(heap)]
	var/item = top.item
	heap -= bottom
	if(!length(heap))
		return item
	heap[1] = bottom
	bubble_down(1)
	return item

/priority_queue/proc/peek()
	if(length(heap) == 0)
		return null
	return heap[1].item

/priority_queue/proc/is_empty()
	return length(heap) == 0

/priority_queue/proc/bubble_up(index)
	while(index > 1)
		var/parent = round(index / 2)

		if(heap[parent].priority < heap[index].priority)
			break

		swap(index, parent)
		index = parent


/priority_queue/proc/bubble_down(index)
	while(index * 2 <= length(heap))
		var/child = index * 2

		if(child + 1 <= length(heap) && heap[child + 1].priority < heap[child].priority)
			child++

		if(heap[index].priority < heap[child].priority)
			break

		swap(index, child)
		index = child


/priority_queue/proc/swap(a, b)
	var/list/temp = heap[a]
	heap[a] = heap[b]
	heap[b] = temp


/priority_queue/Destroy(force)
	..()
	return QDEL_HINT_IWILLGC
