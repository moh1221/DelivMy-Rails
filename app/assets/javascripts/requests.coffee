# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.App ||= {}

App.newPage =  ->
  locFinder = new locationLoad()
  locFinder.getAddress()

  $("#AddInfo").blur ->
    address = $("#AddInfo").val()
    console.log("button clicked!")
    locFinder.getLatLng(address)

  remove_fields = (link) ->
    $(link).previous("input[type=hidden]").value = "1"
    $(link).up(".fields").hide()


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
  remove_fields = (link) ->
    $(link).previous("input[type=hidden]").value = "1"
    $(link).up(".fields").hide()








