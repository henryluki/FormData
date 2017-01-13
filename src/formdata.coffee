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
      new Promise((resolve)=>
        s = []
        s.push("Content-Disposition: form-data; name=#{@name};#{LF}#{LF}")
        s.push("#{@value}#{LF}")
        resolve(s.join(''))
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
      s = []
      s.push("Content-Disposition: form-data; name=#{@name}; filename=#{@filename}#{LF}")
      s.push("Content-Type: #{@souce.type}#{LF}#{LF}")

      if support.blob && support.arrayBuffer
        @_readBlobAsArrayBuffer().then((strings)->
          s.push(strings + LF)
          s.join('')
        )
      else
        @_readBlobAsBinary().then((strings)->
          s.push(strings + LF)
          s.join('')
        )

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
      lines = []
      parts = @_parts
      new Promise((resolve)->
        parts.reduce((promise, part) ->
          promise.then((line)->
            part.convertToString().then((strings)->
              lines.push("--#{boundary}#{LF}")
              lines.push(strings)
              lines
            )
          )
        , new Promise()).join('')
      ).then((lines)->
        lines.push("--#{boundary}--")
        lines.join('')
      )

  self.FormData = FormData

)(if typeof self != 'undefined' then self else this)