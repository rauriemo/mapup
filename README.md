Mapup is a mashup between instagram and google maps for a better visualization of the pictures you and your friends have taken.

It is currently hosted on http://mapup.herokuapp.com

It is a one page app built with ruby and sinatra for the routes and interaction with the instagram gem, and javascript with Ajax calls to those routes using the google maps API in the front end.

It will keep sending requests untill it loads all of your pictures on startup (you can also reach this functionality again by clicking on your profile picture).

Clicking you pic feed will load the 100 most recent images in your feed that are geotagged.

Clicking on go to me will take you to your current location so you can see the pictures your friends are taking near you or that you have taken near that location.

I also implemented Overlapping Marker Spiderfier to better handle the issue of overlapping markers, allowing you to open the infowindow for a specific picture from any zoom distance.

It was built over 4 days for my phase 2 project while attending Dev Bootcamp.




