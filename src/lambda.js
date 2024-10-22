const express = require('express');
const awsServerlessExpress = require('aws-serverless-express');
const os = require('os');

const app = express();
app.use(express.json());

const basePath = process.env.BASE_PATH || "";

console.log(`App starting with BASE_PATH: ${basePath}`);

app.use((req, res, next) => {
  console.log(`Request received: ${req.method} ${req.url}`);
  next();
});

app.get(`/${basePath}/health`, (req, res) => {
  console.log("Health check endpoint hit");
  res.status(200).json({ msg: "Hello, this is your API" });
});

app.get(`/${basePath}/host`, (req, res) => {
  console.log("Host info endpoint hit");
  const hostname = os.hostname();
  const currentTime = new Date().toISOString();

  res.status(200).json({
    message: `Request handled by backend at ${currentTime}`,
    hostname: hostname
  });
});

const server = awsServerlessExpress.createServer(app);

const handler = (event, context) => {
  try {
    console.log("Received event:", JSON.stringify(event, null, 2))
    awsServerlessExpress.proxy(server, event, context);
  } catch (error) {
    console.error(`Error in handler: ${error.message}`);
    context.fail(`Internal Server Error: ${error.message}`);
  }
};

exports.handler = handler;