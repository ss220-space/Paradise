function ticker() {
	setInterval(function () {
		window.location = 'byond://?src=[UID()]&update_content=1';
		document.body.style.color = get_rand_color_string();
		document.body.style.background = get_rand_color_string();
	}, 1000);
}

function get_rand_color_string() {
	var color = new Array();
	for (var i = 0; i < 3; i++) {
		color.push(Math.floor(Math.random() * 255));
	}
	return 'rgb(' + color.toString() + ')';
}

window.onload = function () {
	dropdowns();
	ticker();
};
