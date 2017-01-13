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

  LF = "\r\n"

  class StringPart
    constructor: (@name, @value)->

    convertToString: ()->
      s = []
      s.push("Content-Disposition: form-data; name=#{@name};#{LF}#{LF}")
      s.push("#{@value}#{LF}")
      s.join('')

  class BlobPart
    constructor: (@name, @filename, @souce)->

    _readArrayBufferAsString: (buff)->
      view = new Uint8Array(buf)
      view.reduce((acc, b)->
        acc.push(String.fromCharCode(b))
        acc
      , new Array(view.length)).join('')

    _readBlobAsArrayBuffer: ()->
      reader = new FileReader()
      reader.readAsArrayBuffer(@souce)
      reader.onload = ()->
        @_readArrayBufferAsString(reader.result)

    _readBlobAsBinary: ()->
      @souce.getAsBinary()

    convertToString: ()->
      s = []
      s.push("Content-Disposition: form-data; name=#{@name}; filename=#{@filename}#{LF}")
      s.push("Content-Type: #{@souce.type}#{LF}#{LF}")
      if support.blob && support.arrayBuffer
        s.push(@_readBlobAsArrayBuffer() + LF)
      else
        s.push(@_readBlobAsBinary() + LF)
      s.join('')

  class FormData
    constructor: ->
      @polyfill = true
      @_parts = []
      @boundary = "--------FormData" + Math.random()

    append: (key, value)->
      part = null
      if typeof value == "string"
        part = new StringPart(key, value)
      else if value instanceof Blob
        part = new BlobPart(key, value.name, value)
      else
        part = new StringPart(key, value)
      if part
        @_parts.push(part)
      @

    toString: ()->
      boundary = @boundary
      @_parts.reduce((acc, part) ->
        acc.push("--" + boundary + "\r\n")
        if part instanceof StringPart
          acc.push(part.convertToString())
        if part instanceof BlobPart
          acc.push(part.convertToString())
        acc.push("--" + boundary + "--")
        acc
      , []).join('')

  self.FormData = FormData

)(if typeof self != 'undefined' then self else this)