/**
 * This code contains abstract stacked item. Main goal of this is to make items dropping from storages, smartfridges, etc. not lag the clients out.
 * It is, as simple is possible, tries to implement stacked items behavior like in storages.
 * Main features:
 * - Items appear stacked when dropped from smartfridge on destruction or when amount taken at one time is too high
 * - Same rule applies to bags or storages with display_contents_with_number and allow_quick_empty properties enabled
 * - Can't be taken by hand. Instead, player takes one sample from entire stack.
 * - Same rule applies to pulling. Player pulls only one sample from entire stack.
 * - Player can walk over stack.
 * - Integrity of stack is determenied by summary of stacked items.
 * - One by one items are deleted from stack if stack is damaged by integrity of one stack item.
 */
