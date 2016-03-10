class @timer
  constructor: (@timerUpdate) ->
  updTimer: () ->
    a = @timerUpdate.split(/[^0-9]/)
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