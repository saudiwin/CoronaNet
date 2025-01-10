var mymap = L.map('mapid').setView([40, -10], 2);
L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiYWFwZXRyb3ZhIiwiYSI6ImNrYnJwbDR1ajI0cWczNnI1bnNjeDVmdGMifQ.npCTWwhT2NtfZma0UzcZOA', {
	attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
	maxZoom: 18,
	id: 'mapbox/streets-v11',
	tileSize: 512,
	zoomOffset: -1,
	accessToken: 'pk.eyJ1IjoiYWFwZXRyb3ZhIiwiYSI6ImNrYnJwbDR1ajI0cWczNnI1bnNjeDVmdGMifQ.npCTWwhT2NtfZma0UzcZOA'
}).addTo(mymap);
var markers = [];
$.getJSON("https://raw.githubusercontent.com/LuMesserschmidt/CoronaNet_V2/master/js/reports.json?token=AEV324OSXOFW4AIFQS3QHKDAUU75I", {}, function(data) {
	data = data["reports"];
	jQuery.each(data, function(index, entry) {
		var lat = entry["lat"];
		var lon = entry["lon"];
		var region = entry["region"];
		if (entry["reports"].length == 1) {
			markers.push(L.marker([lat, lon]).addTo(mymap)
			.bindPopup('<a href="' + entry["reports"][0]["link"] + '"><b>' + region + '</b></a><br>' + entry["reports"][0]["author"]));
		} else {
			var allAuthors = entry["reports"].map(x => x["author"]);
			var authors = [];
			allAuthors.forEach(function(x) {if (!authors.includes(x)) {authors.push(x);}});
			authors = authors.join(", ");
			var links = entry["reports"].map(x => '<a href="' + x["link"] + '">' + x["month"] + '</a>').join("<br>");
			markers.push(L.marker([lat, lon]).addTo(mymap)
			.bindPopup('<b>' + region + '</b><br>' + authors + '<br>' + links));
		}
	})
});