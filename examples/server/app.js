var express = require('express')
var multer  = require('multer')
var storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, './uploads')
    },
    filename: function (req, file, cb) {
        var mimetype = file.mimetype.split('/')[1]
        cb(null, file.fieldname + '-' + Date.now() + '.' + mimetype)
    }
})
var upload = multer({ storage: storage })

var app = express()
app.use(express.static('static'))

app.post('/upload', upload.any(), function (req, res, next) {
    console.log('body data', req.body)
    console.log('files data', req.files)
    res.sendStatus(200)
  // req.file is the `avatar` file
  // req.body will hold the text fields, if there were any
})
app.listen(3000, function () {
    console.log('Example app listening on port 3000!');
})