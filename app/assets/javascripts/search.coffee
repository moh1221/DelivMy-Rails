# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.App ||= {}

App.showPage = ->
  updateTimer = (input) ->
    mytime = input
    mytime = new Date(mytime)
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
  App.showPage() if $(".search.show").length > 0
  App.indexPage() if $(".search.index").length > 0