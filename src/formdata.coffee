((self) ->

  if self.FormData
    return

  support =
    arrayBuffer: !!self.ArrayBuffer,
    blob: !!self.FileReader && !!self.Blob && (()->
      try
        new Blob()
        return true
      catch
        return false
    )()

  CRLF = "\r\n"
  BOUNDARY = "--------FormData" + Math.random()

  class StringPart
    constructor: (@name, @value)->

    convertToString: ()->
      lines = []
      new Promise((resolve)=>
        lines.push("--#{BOUNDARY}#{CRLF}")
        lines.push("Content-Disposition: form-data; name=\"#{@name}\";#{CRLF}#{CRLF}")
        lines.push("#{@value}#{CRLF}")
        resolve(lines.join(''))
      )

  class BlobPart
    constructor: (@name, @filename, @souce)->

    _readArrayBufferAsString: (buff)->
      view = new Uint8Array(buff)
      view.reduce((acc, b)->
        acc.push(String.fromCharCode(b))
        acc
      , new Array(view.length)).join('')

    _readBlobAsArrayBuffer: ()->
      new Promise((resolve)=>
        reader = new FileReader()
        reader.readAsArrayBuffer(@souce)
        reader.onload = ()=>
          resolve(@_readArrayBufferAsString(reader.result))
      )

    _readBlobAsBinary: ()->
      new Promise((resolve)=>
        resolve(@souce.getAsBinary())
      )

    convertToString: ()->
      lines = []
      lines.push("--#{BOUNDARY}#{CRLF}")
      lines.push("Content-Disposition: form-data; name=\"#{@name}\"; filename=\"#{@filename}\"#{CRLF}")
      lines.push("Content-Type: #{@souce.type}#{CRLF}#{CRLF}")

      if support.blob && support.arrayBuffer
        @_readBlobAsArrayBuffer().then((strings)->
          lines.push(strings + CRLF)
          lines.join('')
        )
      else
        @_readBlobAsBinary().then((strings)->
          lines.push(strings + CRLF)
          lines.join('')
        )

  class FormData
    constructor: ->
      @polyfill = true
      @_parts = []
      @boundary = BOUNDARY

    _stringToTypedArray: (string)->
      bytes = Array.prototype.map.call(string, (s)->
        s.charCodeAt(0)
      )
      new Uint8Array(bytes)

    append: (key, value)->
      part = null
      if typeof value == "string"
        part = new StringPart(key, value)
      else if value instanceof Blob
        part = new BlobPart(key, value.name || "blob", value)
      else
        part = new StringPart(key, value)
      if part
        @_parts.push(part)
      @

    toString: ()->
      parts = @_parts
      Promise.all(
        @_parts.map((part)-> part.convertToString())
      ).then((lines)->
        lines.push("--#{BOUNDARY}--")
        lines.join('')
      ).then(@_stringToTypedArray)

  self.FormData = FormData

)(if typeof self != 'undefined' then self else this)