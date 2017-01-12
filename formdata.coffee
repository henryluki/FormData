((self) ->

  if self.FormData
    return

  support =
    arrayBuffer: 'ArrayBuff' in self,
    blob: 'FileReader' in self && 'Blob' in self && (()->
      try
        new Blob()
        return true
      catch
        return false
    )()

  class StringPart
    constructor: (@name, @value)->

  class FilePart
    constructor: (@name, @filename, @souce)->

  class FormData
    constructor: ->
      @polyfill = true
      @_parts = []
      @boundary = "--------FormData" + Math.random()

    append: (key, value)->
      part
      if typeof value == "string"
        part = new StringPart(key, value)
      @_parts.push(part)

    toString: ()->
      boundary = @boundary
      @_parts.reduce((acc, part) ->
        acc.push("--" + boundary + "\r\n")
        if part instanceof StringPart
           acc.push("Content-Disposition: form-data; name=\""+ part.name +"\";\r\n\r\n")
           acc.push(part.value + "\r\n")
        acc.push("--" + boundary + "--")
        acc
      , []).join('')

  self.FormData = FormData

)(if typeof self != 'undefined' then self else this)