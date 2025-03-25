function ticker() {
	setInterval(function () {
		window.location = 'byond://?src=[UID()]&update_content=1';
	}, 1000);
}

window.onload = function () {
	dropdowns();
	ticker();
};
