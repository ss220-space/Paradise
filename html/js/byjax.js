function replaceContent() {
	var args = Array.prototype.slice.call(arguments);
	var id = args[0];
	var content = args[1];
	var callback = null;
	if (args[2]) {
		callback = args[2];
		if (args[3]) {
			args = args.slice(3);
		}
	}
	var parent = document.getElementById(id);
	if (typeof parent !== 'undefined' && parent != null) {
		parent.innerHTML = content ? content : '';
	}
	if (callback && window[callback]) {
		window[callback].apply(null, args);
	}
}
