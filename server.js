const express = require('express')
const multer = require('multer')
const fileUpload = require('express-fileupload')
const upload = multer({dest: 'uploads/'})

const app = express()
app.use(fileUpload())

app.get('/', function (req, res) {
  res.send('Hello World')
})

app.post('/upload', function (req, res) {
    console.log("upload received");
    console.log(req.files);
    let file = req.files.data;
    
    // Use the mv() method to place the file somewhere on your server
    file.mv('./uploads/' + req.files.data.name, function(err) {
        if (err)
        return res.status(500).send(err);

        res.send('File uploaded!');
    });
    console.log(req.files.data.name)
})

app.listen(3000)