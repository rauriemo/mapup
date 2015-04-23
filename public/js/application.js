
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
  map = new google.maps.Map(document.getElementById('map-canvas'),
      mapOptions);

  //set the map type it starts at
  map.mapTypes.set('map_style', styledMap);
  map.setMapTypeId('map_style');

  //limits zoomout to zoom 3
  var opt = { minZoom: 3};
  map.setOptions(opt);

  var marker_container = [];


function initialize() {

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

      //reset image and marker size
      var icon = {
          url: response[i].thumbnail, // url
          scaledSize: new google.maps.Size(50, 50), // scaled size
          origin: new google.maps.Point(0,0), // origin
          anchor: new google.maps.Point(0, 0) // anchor
      };

      //place marker
      var marker = new google.maps.Marker({
            position: {
              lat: response[i].location.latitude,
              lng: response[i].location.longitude},
            map: map,
            icon: icon,
      })

      marker_container.push(marker)

      //create content for infowindow
      var contentString ="<img src=\""+response[i].url+"\" height=\"370\" width=\"370\"><div>"+response[i].username+" "+response[i].tags+"</div>";

      //bind content of infowindow listener
      bindInfoWindow(marker, map, infoWindow, contentString);
    }

  }

  function bindInfoWindow(marker, map, infowindow, description) {
      google.maps.event.addListener(marker, 'click', function() {
          infowindow.setContent(description);
          infowindow.open(map, marker);
      });
  }

}

//event listener to run initialize method on window complete load
google.maps.event.addDomListener(window, 'load', initialize);

$(document).ready(function() {

  // var map;

  function getUserPics(event){
    event.preventDefault();
    $.ajax({
      type: 'get',
      url: '/users/self/feed',
      dataType: "json",
    }).done(populateMap)
  }

  function getNewsFeed(event){
    event.preventDefault();
    $.ajax({
      type: 'get',
      url: '/user_media_feed',
      dataType: "json",
    }).done(populateMap)
  }

  function populateMap(response) {
    // response is array of objects in format:
    //location: Object
      // latitude: 37.781923821
      // longitude: -122.
    // thumbnail:
    // url:

    while(marker_container[0]){
     marker_container.pop().setMap(null);
    }

    var infoWindow = new google.maps.InfoWindow({content: ""});

    for (var i=0; i<response.length;i++){

      //reset image and marker size
      var icon = {
          url: response[i].thumbnail, // url
          scaledSize: new google.maps.Size(50, 50), // scaled size
          origin: new google.maps.Point(0,0), // origin
          anchor: new google.maps.Point(0, 0) // anchor
      };

      //place marker
      marker = new google.maps.Marker({
            position: {
              lat: response[i].location.latitude,
              lng: response[i].location.longitude},
            map: map,
            icon: icon,
      })

      marker_container.push(marker)


      //create content for infowindow
      var contentString ="<img src=\""+response[i].url+"\" height=\"370\" width=\"370\"><div>"+response[i].username+" "+response[i].tags+"</div>";

      //bind content of infowindow listener
      bindInfoWindow(marker, map, infoWindow, contentString);
    }

  }

  function bindInfoWindow(marker, map, infowindow, description) {
      google.maps.event.addListener(marker, 'click', function() {
          infowindow.setContent(description);
          infowindow.open(map, marker);
      });
  }

  function currentLocation(){
    if (navigator.geolocation){
         navigator.geolocation.getCurrentPosition(getPosition);
     }
     else{
          alert("Geolocation is not supported by this browser.");
     }
  }

  function getPosition(position) {
        UserLatitude = position.coords.latitude;
        UserLongitude = position.coords.longitude;
        showPosition(UserLatitude, UserLongitude);
  }

  function showPosition(userLatitude, userLongitude){
    lat= userLatitude;
    lon= userLongitude;
    latlon=new google.maps.LatLng(lat, lon);
    map.panTo(latlon);
    map.setZoom(15);
    var circle = new google.maps.Circle({
      map: map,
      center: latlon,
      radius: 100,
      fillColor: '#5CB8E6',
    });
  }

  // function logoutUser(event){
  //   event.preventDefault();
  //   $.ajax({
  //     url: "https://instagram.com/accounts/logout/",
  //       }).done(redirectToHome)
  // }

  // function redirectToHome(){
  //   location.reload();
  // }

  // $("#logout").on("click", logoutUser)
  $("#profile_pic").on("click", getUserPics);
  $("#news_feed").on("click", getNewsFeed);
  $("#center").on("click", currentLocation);
});
