const express = require('express');
const os = require('os');

const app = express();

const port = process.env.PORT;
const basePath = process.env.BASE_PATH || "";

app.use((req, res, next) => {
  console.log(`Request received: ${req.method} ${req.url}`);
  next();
});

app.get('/health', (req, res) => {
  res.status(200).json({msg: "Hello, this is your API"});
});

app.get(`/${basePath}/host`, (req, res) => {
  const hostname = os.hostname();
  const currentTime = new Date().toISOString();

  res.status(200).json({
    message: `Request handled by backend at ${currentTime}`,
    hostname: hostname
  });
});

if (require.main === module) {
    app.listen(port, () => {
        console.log(`Server running on port ${port}`);
        console.log(`Listening on http://localhost:${port}`)
    });
}
