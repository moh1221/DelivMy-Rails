# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.App ||= {}

App.newPage =  ->
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

App.showPage = ->
  updateTimer = (input) ->
    a = input.split(/[^0-9]/)
    mytime = new Date(a[0],a[1]-1,a[2],a[3],a[4],a[5])
    if (mytime != undefined)
      end = new Date(mytime)
      _second = 1000
      _minute = _second * 60
      _hour = _minute * 60
      _day = _hour * 24
      now = new Date()
      distance = end - now
      if (distance < 0)
        return 'EXPIRED!'

      days = Math.floor(distance / _day)
      hours = Math.floor((distance % _day) / _hour)
      minutes = Math.floor((distance % _hour) / _minute)
      if (days > 0)
        dd = ""
        if (days == 1)
          dd = 'within ' + days + ' day'
        else
          dd = 'within ' + days + ' days'
        dd
      else if (days == 0 && hours > 0)
        hh = ""
        if (days == 1)
          hh = 'within ' + hours + ' hour'
        else
          hh = 'within ' + hours + ' hours'
        hh
      else if (days == 0 && hours == 0 && minutes > 0)
        mm = ""
        if (days == 1)
          mm = 'within ' + minutes + ' minute'
        else
          mm = 'within ' + minutes + ' minutes'
        mm
    else
      return 'Invalid!'

  $( "#timerInfo" ).text (v, e)->
    updateTimer(e)

  return {
    example: (x) ->
      updateTimer(x)
  }

App.indexPage = ->
  $(".timerInfo").text (v, e) ->
    App.showPage().example(e)



$(document).on "page:change", ->
  App.newPage() if $(".requests.new").length > 0
  App.showPage() if $(".requests.show").length > 0
  App.indexPage() if $(".requests.index").length > 0








