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

  LF = "\r\n"
  BOUNDARY = "--------FormData" + Math.random()

  class StringPart
    constructor: (@name, @value)->

    convertToString: ()->
      lines = []
      new Promise((resolve)=>
        lines.push("--#{BOUNDARY}#{LF}")
        lines.push("Content-Disposition: form-data; name=#{@name};#{LF}#{LF}")
        lines.push("#{@value}#{LF}")
        resolve(lines)
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
      lines.push("--#{BOUNDARY}#{LF}")
      lines.push("Content-Disposition: form-data; name=#{@name}; filename=#{@filename}#{LF}")
      lines.push("Content-Type: #{@souce.type}#{LF}#{LF}")

      if support.blob && support.arrayBuffer
        @_readBlobAsArrayBuffer().then((strings)->
          lines.push(strings + LF)
          lines
        )
      else
        @_readBlobAsBinary().then((strings)->
          lines.push(strings + LF)
          lines
        )

  class FormData
    constructor: ->
      @polyfill = true
      @_parts = []
      @boundary = BOUNDARY

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
      parts = @_parts
      Promise.all(
        @_parts.map((part)-> part.convertToString())
      ).then((lines)->
        lines.push("--#{BOUNDARY}--")
        lines.reduce((acc, line)->
          acc = acc.concat(line)
          return acc
        []).join('')
      )

  self.FormData = FormData

)(if typeof self != 'undefined' then self else this)