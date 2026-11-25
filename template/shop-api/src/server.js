const http = require('http')

const port = process.env.PORT || 3000
http
  .createServer((req, res) => {
    res.writeHead(200, { 'content-type': 'application/json' })
    res.end(JSON.stringify({ service: 'shop-api', ok: true }))
  })
  .listen(port, () => console.log(`shop-api on :${port}`))
