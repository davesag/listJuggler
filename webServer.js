// see https://github.com/expressjs/serve-static
var connect = require('connect'),
    serveStatic = require('serve-static'),
    port = 8080;

console.time("started");
console.log("Webserver running on port", port);
console.log("ctrl-c to exit");

connect().use(serveStatic(__dirname)).listen(8080);
