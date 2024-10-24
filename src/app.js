const express = require('express');
const os = require('os');

const app = express();
app.use(express.json());

const basePath = process.env.BASE_PATH || "";
const port = process.env.PORT

console.log(`App starting with BASE_PATH: ${basePath}`);
console.log(`App starting with PORT: ${port}`);

app.use((req, res, next) => {
  console.log(`Request received: ${req.method} ${req.url}`);
  next();
});

app.get(`/${basePath}/health`, (req, res) => {
  res.status(200).json({ msg: "Hello, this is your API" });
});

app.get(`/${basePath}/host`, (req, res) => {
  const hostname = os.hostname();
  const currentTime = new Date().toISOString();

  res.status(200).json({
    message: `Request handled by backend at ${currentTime}`,
    hostname: hostname,
    backend: "ecs"
  });
});

app.listen(port, () => {
  console.log(`app listening on http://localhost:${port}`);
});
