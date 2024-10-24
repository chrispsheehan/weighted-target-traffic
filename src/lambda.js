// lambda.js
const { createApp } = require('./common');
const awsServerlessExpress = require('aws-serverless-express');

const app = createApp();

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
