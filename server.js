const express = require("express");
//const fileUpload = require("express-fileupload");
const fs = require("fs");
const crypto = require("crypto");
const formidable = require('formidable');

const app = express();

//app.use(fileUpload({
//    debug : true
//}))

app.get("/", function (req, res) {
	res.send("Hello World");
});

const hash = crypto.createHash("md5");

app.post("/upload",function (req, res, next) {
	const form = formidable({ multiples: false, uploadDir: "./uploads/tmp", keepExtensions: true, hash: 'md5' });
	console.log("upload received");

	let fields = null
	let files = null
	let tmp = null
	let name = null
	let ver = null
	let plat = null
	let hash = null

	form.parse(req, (err, fields, files) => {
		if (err) {
		  next(err);
		  return;
		}
		console.log(fields);
		console.log(files);
		console.log(files.data.hash);
		fields = fields;
		files = files;
		tmp = files.data.path;
		name = fields.projName;
		ver = fields.projVer;
		plat = fields.projPlat;
		hash = files.data.hash;
	});

	form.on('end', () => {
		res.status(200).json({ fields, files });

		console.log(tmp, name, ver, plat);
		handleFile(tmp, name, ver, plat, hash);
	});

	/*
	// Use the mv() method to place the file somewhere on your server
	file.mv("./uploads/" + req.files.data.name, function (err) {
		if (err) return res.status(500).send(err);

		res.send("File uploaded!");
	});
	console.log(req.files.data.name);
	*/
});

app.listen(3000, () => {
	console.log('Server listening on http://localhost:3000 ...');
});

function handleFile(tmp, name, ver, platform, hash) {
	const FILE_EXT = ".zip";
	const STATIC_DIR = `./uploads/${name}/${platform}`
	const STATIC_PATH = `${STATIC_DIR}/${name}-${ver}`;
	let path = STATIC_PATH + FILE_EXT;
	
	let dirStats = fs.stat(STATIC_DIR, (err, stats) => {
		if (err) console.error(err);
		// If directory DOES NOT exist create and move file
		if (err != null && err.code === 'ENOENT') {
			createDir("./uploads", name, platform, (newPath) => {
				fs.rename(tmp, newPath, () => console.log(`Successfully moved tmp -> ${newPath}.`));
				return;
			});
		}
		// If directory exists check if file exists
		fs.stat(path, (err, stats) => {
			// If file DOES exist check to see what sub version number we need
			if (err != null && err.code !== 'ENOENT') {
				// TODO check checksum hash to see if copy then no need to do anything
				getSubFileVersion(0, path, (i, newPath) => {
					fs.rename(tmp, newPath, () => console.log(`Successfully moved tmp -> ${newPath}.`));
				});
				return;
			}
			// If file DOES NOT exist move file
			fs.rename(tmp, path, () => console.log(`Successfully moved tmp -> ${path}.`));
		});
	});
}

function getSubFileVersion(index, path, cb) {
	if (index == 9) cb(index, path);
	path = `${STATIC_PATH}-${index}${FILE_EXT}`;
	fs.stats(path, (err, stats) => {
		if (err != null && err.code === 'ENOENT') cb(index, path);
		else {
			getSubFileVersion(index, path, cb);
		}
	});
}

function createDir(path, name, platform, cb) {
	fs.mkdir(path, (err, p1) => {
		console.log(path);
		path += `/${name}`;
		fs.mkdir(path, (err, p2) => {
			console.log(path);
			path += `/${platform}`;
			fs.mkdir(path, (err, p3) => {
				console.log("created dir", path);
				cb(path + `/${STATIC_PATH}${FILE_EXT}`);
			});
		});
	});
}

function removeFile(path) {
	fs.unlink(path, (err) => {
		if (err) throw err;
	});
}