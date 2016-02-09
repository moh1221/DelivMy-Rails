# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  Lat = 38
  Long = -78.5
  applyLocation = (location) ->
    coords = location.coords
    Lat = coords.latitude
    Long = coords.longitude
    $("#LatInfo").val(Lat)
    $("#LongInfo").val(Long)
    $.ajax
      url: "http://maps.googleapis.com/maps/api/geocode/json?latlng="+Lat+","+Long+"&sensor=true"
      type: "POST"
      success: (data, textStatus, jqXHR) ->
        $("#AddInfo").val(data.results[0].formatted_address)
      error: (jqXHR, textStatus, errorThrown) ->
        console.log(errorThrown)

  navigator.geolocation.getCurrentPosition applyLocation
  false

  $("#AddInfo").blur ->
    address = $("#AddInfo").val()
    console.log("button clicked!")
    $.ajax
      url: "http://maps.googleapis.com/maps/api/geocode/json?address="+address+"&sensor=false"
      type: "POST"
      success: (data, textStatus, jqXHR) ->
        $("#LatInfo").val(data.results[0].geometry.location.lat)
        $("#LongInfo").val(data.results[0].geometry.location.lng)
      error: (jqXHR, textStatus, errorThrown) ->
        console.log(errorThrown)



