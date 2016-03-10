# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.App ||= {}

App.showPage = ->

  $( "#timerInfo" ).text (v, e)->
    upTimer = new timer(x)
    upTimer.updTimer(e) if e.indexOf("within") == -1

  return {
    example: (x) ->
      upTimer = new timer(x)
      upTimer.updTimer(x) if x.indexOf("within") == -1
  }

App.indexPage = ->
  $(".timerInfo").text (v, e) ->
    App.showPage().example(e)

  map
  markers = new Array();
  updateMap = () ->
    bounds = map.getBounds()
    southWest = bounds.getSouthWest()
    northEast = bounds.getNorthEast()
    $.ajax 'search' ,
      type: "GET",
      dataType: "JSON",
      data:
        sw: southWest.toUrlValue()
        ne: northEast.toUrlValue()
        center: [map.getCenter().lat(), map.getCenter().lng()]
      asnyc: false,
      success: (data, x, v) ->
        console.log(data)
        removeMarkersOutsideOfMapBounds() if markers.length > 0
        json = data
        json.map (i) ->
          id = i.id
          if(!markers[id] || markers[id] == null)
            markers[id] = createMarker(i)
            map.addOverlay(markers[id])

  createMarkerClickHandler = (marker, location) ->
    return () ->
      marker.openInfoWindowHtml(
        '<div><strong>' + location.PlaceName + '</strong><br/> ' +
          location.address + '<br/>'+
          'Cost: $' + location.cost + ' - Fees: $' + location.fees + '</div>')

    return false

  createMarker = (location) ->
    latlng = new GLatLng location.Lat, location.Long
    marker = new GMarker latlng
    handler = createMarkerClickHandler(marker, location)
    google.maps.event.addListener marker, "click", handler
    return marker

  removeMarkersOutsideOfMapBounds = () ->
  for i in markers
    if i > 0 && markers[i] && !map.getBounds().containsLatLng(markers[i].getLatLng())
      map.removeOverlay(markers[i])
      markers[i] = null




  map = new GMap2 document.getElementById("map")
  map.setCenter new GLatLng(37.731145,-97.326092),4

  google.maps.event.addListener map, "moveend", () -> updateMap()






$(document).on "page:change", ->
  App.showPage() if $(".search.show").length > 0
  App.indexPage() if $(".search.index").length > 0