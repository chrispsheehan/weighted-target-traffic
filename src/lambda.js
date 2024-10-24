const express = require('express');
const awsServerlessExpress = require('aws-serverless-express');
const os = require('os');

const app = express();
app.use(express.json());

const stage = process.env.STAGE || "";
const backend = process.env.BACKEND || "";
const basePath = `${stage}/${backend}`

console.log(`App starting with BASE_PATH: ${basePath}`);

app.use((req, res, next) => {
  console.log(`Request received: ${req.method} ${req.url}`);
  next();
});

app.get(`/${basePath}/health`, (req, res) => {
  res.status(200).json({ msg: "Hello, this is your API" });
});

app.get(`/${stage}/host`, (req, res) => {
  const hostname = os.hostname();
  const currentTime = new Date().toISOString();

  res.status(200).json({
    message: `Request handled by backend at ${currentTime}`,
    hostname: hostname,
    backend: "lambda"
  });
});

const server = awsServerlessExpress.createServer(app);

const handler = (event, context) => {
  try {
    awsServerlessExpress.proxy(server, event, context);
  } catch (error) {
    console.error(`Error in handler: ${error.message}`);
    context.fail(`Internal Server Error: ${error.message}`);
  }
};

exports.handler = handler;