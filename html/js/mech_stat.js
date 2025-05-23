function ticker() {
	setInterval(function () {
		const uidElement = document.getElementById('uid_container');
		const UID = uidElement ? uidElement.getAttribute('data-uid') : null;
		if (UID) {
			window.location = 'byond://?src=' + UID + '&update_content=1';
		}
	}, 1000);
}

window.onload = function () {
	dropdowns();
	ticker();
};
