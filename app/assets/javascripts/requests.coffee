# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.App ||= {}

App.newPage =  ->
#  Lat = 38
#  Long = -78.5
#  applyLocation = (location) ->
#    coords = location.coords
#    Lat = coords.latitude
#    Long = coords.longitude
#    $("#LatInfo").val(Lat)
#    $("#LongInfo").val(Long)
#    $.ajax
#      url: "https://maps.googleapis.com/maps/api/geocode/json?latlng="+Lat+","+Long+"&sensor=true"
#      type: "POST"
#      success: (data, textStatus, jqXHR) ->
#        $("#AddInfo").val(data.results[0].formatted_address)
#      error: (jqXHR, textStatus, errorThrown) ->
#        console.log(errorThrown)
#
#  navigator.geolocation.getCurrentPosition applyLocation
#  false
  locFinder = new locationLoad();
  locFinder.getAddress();

  $("#AddInfo").blur ->
    address = $("#AddInfo").val()
    console.log("button clicked!")
    locFinder.getLatLng(address)


App.showPage = ->
  $( "#timerInfo" ).text (v, e)->
    upTime = new timer(e)
    upTime.updTimer() if e.indexOf("within") == -1

  return {
    example: (x) ->
      upTime = new timer(x)
      upTime.updTimer() if x.indexOf("within") == -1
  }

App.indexPage = ->
  $(".timerInfo").text (v, e) ->
    App.showPage().example(e)

$(document).on "page:change", ->
  App.newPage() if $(".requests.new").length > 0
  App.showPage() if $(".requests.show").length > 0
  App.indexPage() if $(".requests.index").length > 0








