// see https://github.com/expressjs/serve-static
var connect = require('connect'),
    serveStatic = require('serve-static');

connect().use(serveStatic(__dirname)).listen(8080);
