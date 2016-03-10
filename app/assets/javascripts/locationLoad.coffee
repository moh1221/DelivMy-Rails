class @locationLoad
  applyLocation: (location) ->
    coords = location.coords
    Lat = coords.latitude
    Long = coords.longitude
    $("#LatInfo").val(Lat)
    $("#LongInfo").val(Long)
    $.ajax
      url: "https://maps.googleapis.com/maps/api/geocode/json?latlng="+Lat+","+Long+"&sensor=true"
      type: "POST"
      success: (data, textStatus, jqXHR) ->
        $("#AddInfo").val(data.results[0].formatted_address)
      error: (jqXHR, textStatus, errorThrown) ->
        console.log(errorThrown)

  getAddress: -> navigator.geolocation.getCurrentPosition this.applyLocation

  getLatLng: (address) ->
    $.ajax
      url: "https://maps.googleapis.com/maps/api/geocode/json?address="+address+"&sensor=false"
      type: "POST"
      success: (data, textStatus, jqXHR) ->
        $("#LatInfo").val(data.results[0].geometry.location.lat)
        $("#LongInfo").val(data.results[0].geometry.location.lng)
      error: (jqXHR, textStatus, errorThrown) ->
        console.log(errorThrown)