const awsServerlessExpress = require('aws-serverless-express');
const app = require('./app');

const server = awsServerlessExpress.createServer(app);

exports.handler = async (event, context) => {
    console.log("Received event:", JSON.stringify(event));
    console.log("Lambda handler invoked");

    try {
        awsServerlessExpress.proxy(server, event, context);
        console.log("Proxy call finished");
    } catch (error) {
        console.error("Error during proxy execution:", error);
        throw error;
    }
};
