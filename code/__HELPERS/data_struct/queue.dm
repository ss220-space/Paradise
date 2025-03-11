/*
* Double linked list node
*/
/node
	var/value
	var/prev
	var/next

/*
* Defining a queue based on a double linked list
*/
/queue
	/// Link to the beginning of the list
	var/node/head
	/// Link to end of list
	var/node/tail
	/// Number of elements in queue
	var/count = 0

/*
* Adding an element to the end of the queue
*/
/queue/proc/enqueue(value)
	var/node/new_node = new
	new_node.value = value

	if (!tail)
		head = new_node
		tail = new_node
	else
		tail.next = new_node
		new_node.prev = tail
		tail = new_node
	count++
/*
 * Retrieving an element from the head of the queue
 */
/queue/proc/dequeue()
	if (!head)
		return null

	var/value = head.value
	var/node/old_head = head

	head = head.next
	if (head)
		head.prev = null
	else
		tail = null
	old_head.value = null
	old_head.next = null
	qdel(old_head)
	count--
	return value
/*
* Returns an element from the beginning of the queue without removing it
*/
/queue/proc/peek()
	if (!head)
		return null
	return head.value

/*
* Checking if the queue is empty
*/
/queue/proc/is_empty()
	return count == 0

/*
* Returns the number of elements in the queue
*/
/queue/proc/size()
	return count
