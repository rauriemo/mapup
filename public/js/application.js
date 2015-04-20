function initialize() {

// set styles for map
var styles = [
    {
      stylers: [
        { hue: "#4169E1" },
        { saturation: -20 }
      ]
    },{
      featureType: "road",
      elementType: "geometry",
      stylers: [
        { lightness: 100 },
        { visibility: "simplified" }
      ]
    },{
      featureType: "road",
      elementType: "labels",
      stylers: [
        { visibility: "off" }
      ]
    }
  ];

//create styled map object
var styledMap = new google.maps.StyledMapType(styles, {name: "Styled Map"});

//set options for default map
//center lat+long
//control options hybrid/terrain/styled
var mapOptions = {
  center: { lat: 21.340207, lng: -28.394057},
  zoom: 3,
  mapTypeControlOptions: {
      mapTypeIds: [google.maps.MapTypeId.TERRAIN, google.maps.MapTypeId.HYBRID, 'map_style']
    }
};

//create map object and assign to
//map-canvas div
var map = new google.maps.Map(document.getElementById('map-canvas'),
    mapOptions);

//set the map type it starts at
map.mapTypes.set('map_style', styledMap);
map.setMapTypeId('map_style');

//limits zoomout to zoom 3
var opt = { minZoom: 3};
map.setOptions(opt);

//ajax request that returns array of user pictures on page refresh
 $.ajax({
      type: 'get',
      url: '/users/self/feed',
      dataType: "json",
  }).done(populateMap)

//populate map with markers for each user picture and create infowindows on click
function populateMap(response) {

  var infoWindow = new google.maps.InfoWindow({content: ""});

  for (var i=0; i<response.length;i++){

    var icon = {
        url: response[i].thumbnail, // url
        scaledSize: new google.maps.Size(50, 50), // scaled size
        origin: new google.maps.Point(0,0), // origin
        anchor: new google.maps.Point(0, 0) // anchor
    };

    marker = new google.maps.Marker({
          position: {
            lat: response[i].location.latitude,
            lng: response[i].location.longitude},
          map: map,
          icon: icon,
    })

    var contentString ="<img src=\""+response[i].url+"\" height=\"370\" width=\"370\">";

      bindInfoWindow(marker, map,
       infoWindow, contentString);
  }

}

function bindInfoWindow(marker, map, infowindow, description) {
    google.maps.event.addListener(marker, 'click', function() {
        infowindow.setContent(description);
        infowindow.open(map, marker);
    });
}

//set div to be used when you click on marker
var contentString ='<div id="picture"></div>'

//set above div as what is rendered in content of indoWindow
var infowindow = new google.maps.InfoWindow({
    content: contentString
});

//general format for creating markers
// var marker = new google.maps.Marker({
//     position: myLatlng,
//     map: map,
// });

//event listener for marker click
// google.maps.event.addListener(marker, 'click', function() {
//   infowindow.open(map,marker);
// });

}

//event listener to run initialize method on window complete load
google.maps.event.addDomListener(window, 'load', initialize);

// on initialize function add method that sends ajax call to route, that route should return array of my pictures