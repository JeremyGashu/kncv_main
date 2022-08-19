let functions = require("firebase-functions");
let express = require("express");
let { Server } = require('socket.io');
let http = require('http');


/* Express */
let app = express();

let server = http.createServer(app);



let io = new Server(server, {
    cors: {
        origin: '*',
        methods: 'GET,HEAD,PUT,PATCH,POST,DELETE'
    }
});


io.on('connection', (socket) => {
    console.log(`A user is connected `);
    io.emit('HELLO', 'HELLO There...');
});

app.get("/", (request, response) => {
    response.send("Hello from Express on Firebase!");
});

app.get("/test", (request, response) => {
    response.send({test : 'Test...'});
});

let api1 = functions.https.onRequest(app);

module.exports = {
    api1
}