moment = require('moment/moment')

if Meteor.isServer
  Meteor.callSync = Meteor.wrapAsync(Meteor.call, Meteor) # only available on server side.
  @CollectionError = new Mongo.Collection 'error' #Collection for error logging

  Meteor.methods
    'console.log': (msg) ->
#      msg = "### #{if __file? then __file}/#{if __function? then __function}/#{if __line? then __line} $$$ #{msg}"
      console.log msg
    'throwError': (err) -> # err: thrown err object
      if typeof err is 'string'
        err = strMessage: err
      err.createdAt = new Date()
      err.__filename = __filename
      err.__function = __function
      err.__line = __line
      CollectionError.insert err

### Debug Info Usage
  err.createdAt = new Date()
  err.strMessage = err.toString()
  err.__filename = __filename
  err.__function = __function
  err.__line = __line
###
Object.defineProperty global, '__stack', get: ->
  orig = Error.prepareStackTrace

  Error.prepareStackTrace = (_, stack) ->
    stack

  err = new Error
  Error.captureStackTrace err, arguments.callee
  stack = err.stack
  Error.prepareStackTrace = orig
  stack

Object.defineProperty global, '__line', get: ->
  __stack[1].getLineNumber()
Object.defineProperty global, '__function', get: ->
  __stack[1].getFunctionName()

@isTestMode = do -> if process?.env?.IS_TEST_MODE is 'true' then true else false


@cl = (msg) ->
  if Meteor.isClient
#    return msg
    console.log.apply(null, arguments)
    try Meteor.call 'console.log', msg catch err #send server if possible
  else
    console.log.apply(null, arguments)
#    Codeasy.utils.serverLog msg

# Date prototyping
@Date.prototype.addSeconds = (s) ->
  @setSeconds @getSeconds() + s
  return @
@Date.prototype.addMinutes = (m) ->
  @setMinutes @getMinutes() + m
  return @
@Date.prototype.addHours = (h) ->
  @setHours @getHours() + h
  return @
@Date.prototype.addDates = (d) ->
  @setDate @getDate() + d
  return @
@Date.prototype.addMonths = (value) ->
  n = @getDate()
  @setDate 1
  @setMonth @getMonth() + value
  @setDate Math.min(n, @getDaysInMonth())
  return @
@Date.prototype.addYears = (years) ->
  n = @getDate()
  @setDate 1
  @setMonth @getMonth() + (years*12)
  @setDate Math.min(n, @getDaysInMonth())
  return @
@Date.prototype.toStringYM = ->
  return moment(this).format('YYYY-MM')
@Date.prototype.toStringYM = ->
  return moment(this).format('YYYY-MM')
@Date.prototype.toStringYMD = ->
  return moment(this).format('YYYY-MM-DD')
@Date.prototype.toStringYMDdot = ->
  return moment(this).format('YYYY.MM.DD')
@Date.prototype.toStringMDHM = ->
  return moment(this).format('MM-DD HH:mm')
@Date.prototype.toStringMD = ->
  return moment(this).format('MM-DD')
@Date.prototype.toStringHMS = ->
  return moment(this).format('HH:mm:ss')
@Date.prototype.toStringH = ->
  return moment(this).format('HH')
@Date.prototype.toStringM = ->
  return moment(this).format('mm')
@Date.prototype.toStringHM = ->
  return moment(this).format('HH:mm')
@Date.prototype.toStringYMDHMS = ->
  return moment(this).format('YYYY-MM-DD HH:mm:ss')
@Date.prototype.toDateFromString = (_str) ->
  return moment(_str, 'YYYY-MM-DD HH:mm:ss').toDate()

Date.isLeapYear = (year) ->
  year % 4 == 0 and year % 100 != 0 or year % 400 == 0
Date.getDaysInMonth = (year, month) ->
  [
    31
    if Date.isLeapYear(year) then 29 else 28
    31
    30
    31
    30
    31
    31
    30
    31
    30
    31
  ][month]
@Date.prototype.isLeapYear = ->
  Date.isLeapYear @getFullYear()
@Date.prototype.getDaysInMonth = ->
  Date.getDaysInMonth @getFullYear(), @getMonth()
Date.prototype.clone = -> return new Date @getTime()

@CheckTimer = class
  ### jwjin/1508210653
  checkTime = new CheckTimer()
  ...logic...
  checkTime.log 'check place 1'
  ...logic...
  checkTime.log 'check place 2'
  ...
  This will display a time taken by logic as it's name
  ###

  constructor: -> @lastTime = new Date()
  log: (name) ->
    now = new Date()
    cl "#{name}: #{now.getTime() - @lastTime.getTime()}"
    @lastTime = now
    return
#throw Error with log on DB
@throwError = (err) ->
  Meteor.call 'throwError', err #err object or string for message

unless @Codeasy then @Codeasy = {}

@Codeasy.utils =
  getFileLink: (_id) ->
###
  param
    _id: _id of file collection
  return
    link of file
###
    if _id? then return "#{Meteor.absoluteUrl()}cdn/storage/db_files/#{_id}/original/#{_id}"
    else return "/images/samples/logo.png"

  getGroup_ids: (userInfo) ->
#admin / company / center ??? userInfo??? ????????? ????????? gruop_ids??? ????????? [] return
    unless userInfo then userInfo = Meteor.user() #?????? ????????? ?????? ????????? ????????? ??????
    switch userInfo?.profile?.authority
      when 'admin' or 'sc'
        return userInfo.profile.group_ids
      when 'company'
        group_ids = []
        userInfo.profile.company_ids.forEach (company_id) ->
          CollectionGroups.find(p_id: company_id).forEach (group) ->
            group_ids.push group._id
        return group_ids
      when 'center'
        group_ids = []
        userInfo.profile.center_ids.forEach (center_id) ->
          CollectionCompanies.find(p_id: center_id).forEach (company) ->
            CollectionGroups.find(p_id: company._id).forEach (group) ->
              group_ids.push group._id
        return group_ids
      else []
#      else throw new Meteor.Error userInfo, 'getGroup_ids authority error'

  nullCheckDefault: (param, defaultType) ->
    if param?
      if (typeof param) is 'number' then return param.toString()
      else return param
    else
      switch defaultType
        when 'string' then return ''
        when 'array' then return []
        when 'object' then return {}
  getPadNumber: (n, length, char) ->
# 0 padding / n: nunber, length: target length, char: pad character
    char = char or '0'
    n = n + ''
    if n.length >= length then n else new Array(length - (n.length) + 1).join(char) + n
  getRandomPaddedNumber: (n) ->
# n: length (first padding with 0. ex> 001)
# return typeof number
    add = 1
    max = 12 - add
    # 12 is the min safe number Math.random() can generate without it starting to pad the end with zeros.
    if n > max
      return generate(max) + generate(n - max)
    max = 10 ** (n + add)
    min = max / 10
    # Math.pow(10, n) basically
    number = Math.floor(Math.random() * (max - min + 1)) + min
    ('' + number).substring add
  getRandomNumber: (min, max) ->
# min to max(exclude) / return typeof number
    min = Math.ceil(min)
    max = Math.floor(max)
    return Math.floor(Math.random() * (max - min)) + min
  exist: (_obj) ->
#return true when exist or return false
    if typeof _obj is 'number' then return true
    else return _obj? and !!_obj and !!Object.keys(_obj).length
  checkArgs: (condition, args) ->
    if !condition or (do -> return true for str in args when condition.hasOwnProperty(str) is false) then throw new Meteor.Error condition, 'method arguments error'

#  replaceAll: (_string, _selector, _any) ->
#    revTest = _string.replace(/_selector/gi, _any); #selector -> regex??? ?????? ??????
#    return revTest

  formatBytes: (bytes, decimals) ->
#    usage: formatBytes(139328839)
    if(bytes == 0) then return '0 Byte'
    k = 1000
    dm = decimals + 1 || 3
    sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
    i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i]

  getDateDiff: (date1, date2, interval) ->
#usage: mydiff('date1', 'date2', 'days')
    second = 1000
    minute = second * 60
    hour = minute * 60
    day = hour * 24
    week = day * 7
    date1 = new Date(date1)
    date2 = new Date(date2)
    timediff = date2 - date1
    if isNaN(timediff)
      return NaN
    switch interval
      when 'years'
        return date2.getFullYear() - date1.getFullYear()
      when 'months'
        return date2.getFullYear() * 12 + date2.getMonth() - (date1.getFullYear() * 12 + date1.getMonth())
      when 'weeks'
        return Math.floor(timediff / week)
      when 'days'
        return Math.floor(timediff / day)
      when 'hours'
        return Math.floor(timediff / hour)
      when 'minutes'
        return Math.floor(timediff / minute)
      when 'seconds'
        return Math.floor(timediff / second)
      else
        return undefined

  getWellFormedDateString: (_digitString) ->
    tmp = _digitString.replace /-/g, ''
    rslt = tmp.substring 0,4
    rslt += '-'
    rslt += tmp.substring 4, 6
    rslt += '-'
    rslt += tmp.substring 6,8
    return rslt

  setConnectionPool: (status)->
    Meteor.setTimeout ->
      Meteor.call 'connectionPool', status, Router?.current()?.route?.name
    , 0

  isInt: (n) ->
#return boolean
    n % 1 is 0

  log: ->
#usage : Log().write('arg1', 'arg2')
    Log = Error
    Log.prototype.write = ->
      args = Array.prototype.slice.call arguments, 0
      suffix = if @lineNumber then 'line: ' + @lineNumber else 'stack: ' + @stack
      args.concat [suffix]

  isNumeric: (n) ->
    return !isNaN(parseFloat(n)) && isFinite(n)

  getClone: (_obj) ->
# cannot clone function
    JSON.parse(JSON.stringify(_obj));

  getClass: (obj) ->
    if typeof obj is "undefined" then return "undefined"
    if obj is null then return "null"
    return Object.prototype.toString.call(obj).match(/^\[object\s(.*)\]$/)[1]

  getStartEndOfDate: (_date) ->
    strYMD = _date.toStringYMD
    return {
      startAt: Date.toDateFromString(strYMD + ' 00:00:00')
      endAt: Date.toDateFromString(strYMD + ' 00:00:00').addDates(1)
    }

  getObjectCounts: (_object) ->
    Object.keys(_object).length

  formatNumber: (str) ->
    unless str? then return ''
    str = str.toString()
    num = str.replace(/\,/gi, '')
    num.toString().replace /(\d)(?=(\d{3})+(?!\d))/g, '$1,'

  hasOnlyDigits: (_val) ->
    if /^-?\d+\.?\d*$/.test _val then return true
    else return false

  formatStringToNumber: (str) ->
    unless str? then return ''
    num = str.replace(/\,/gi, '')
    parseInt(num)

  datePlusZeroWord: (_val) ->
    if _val.length < 2 then return '0' + _val
    else return _val

  stringToDateArray: (_str, _selector) ->
    arr = []
    temps = _str.split(_selector)
    temps.forEach (_string) ->
      arr.push new Date(_string.trim())
    return arr

# get several times ago
# Usage: timeSince new Date()
# return: x minutes ago
  timeSince: (date) ->
    seconds = Math.floor((new Date - date) / 1000)
    interval = Math.floor(seconds / 31536000)
    if interval > 1
      return interval + ' years'
    interval = Math.floor(seconds / 2592000)
    if interval > 1
      return interval + ' months'
    interval = Math.floor(seconds / 86400)
    if interval > 1
      return interval + ' days'
    interval = Math.floor(seconds / 3600)
    if interval > 1
      return interval + ' hours'
    interval = Math.floor(seconds / 60)
    if interval > 1
      return interval + ' mins'
    return Math.floor(seconds) + ' seconds'

# ????????? ???????????? ????????? ???????????? ???.
# ???????????? ?????????????????? ????????? ????????? 'hh:mm:ss' ???????????? ??????
  consumedTime: (startTime, endTime) ->
# ?????? ???????????? ????????? ????????? ?????? ??????
    if startTime > endTime
      temp = startTime
      startTime = endTime
      endTime = temp

    # ?????? ????????? ??????????????? ??????
    startTime = startTime.getTime()
    endTime = endTime.getTime()
    conTime = endTime - startTime

    # ???:???:??? ??????
    ms = conTime % 1000
    conTime = (conTime - ms) / 1000
    s = conTime % 60
    conTime = (conTime - s) / 60
    m = conTime % 60
    conTime = (conTime - m) / 60
    h = conTime % 60

    # ???????????? ??? ????????? ???????????? ??????
    s = if s < 10 then '0' + s else '' + s
    m = if m < 10 then '0' + m else '' + m
    h = if h < 10 then '0' + h else '' + h

    # ?????? ????????? ??????
    return h + ':' + m + ':' + s

###
  desc: ??????????????????
  usage: Codeasy.excelDownload(table_id, event)
###
  excelDownload: (table_id, event) ->
#getting values of current time for generating the file name
    dt = new Date
    day = dt.getDate()
    month = dt.getMonth() + 1
    year = dt.getFullYear()
    hour = dt.getHours()
    mins = dt.getMinutes()
    postfix = day + '.' + month + '.' + year + '_' + hour + '.' + mins
    #creating a temporary HTML link element (they support setting file names)
    a = document.createElement('a')
    #getting data from our div that contains the HTML table
    data_type = 'data:application/vnd.ms-excel;charset=utf-8'
    table_div = document.getElementById(table_id)  ##??????????????? ?????? table id
    table_html = table_div.outerHTML.replace(RegExp(' ', 'g'), '%20')
    a.href = data_type + ', ' + table_html
    #        a.charset="euc-kr"
    #setting the file name
    a.download = 'exported_table_' + postfix + '.xls'
    #triggering the function
    a.click()
    #just in case, prevent default behaviour
    return event.preventDefault()

if Meteor.isClient
  _.extend @Codeasy.utils,
    getCurrrentPath: ->
      c = window.location.pathname
      b = c.slice 0, -1
      a = c.slice -1
      if b is '' then return '/'
      else
        if a is '/' then return b
        else return c
    cordovaDeviceType: ->
      if navigator.userAgent.match(/iPad/i) or navigator.userAgent.match(/iPhone/i)
        return 'i'
      if navigator.userAgent.match(/Android/i)
        return 'a'
else
  _.extend @Codeasy.utils,
    serverLog: ->
      console.log('run')
      nFs = Npm.require('fs')
      logFileNm = (new moment(new Date())).format('YYYYMMDD') + '.log'
      for logKey of Object.keys(arguments)
        logDt = (new moment(new Date())).format('YYYY-MM-DD HH:mm:ss') + " "
        if typeof(arguments[logKey]) is 'object'
          nFs.writeFile "#{process.env.PWD}/.meteor/#{logFileNm}", logDt + JSON.stringify(arguments[logKey], Object.getOwnPropertyNames(arguments[logKey])) + '\n', flag:'a', (err) ->
        else
          nFs.writeFile "#{process.env.PWD}/.meteor/#{logFileNm}", logDt + arguments[logKey] + '\n', flag:'a', (err) -> return