const express = require('express');
const os = require('os');

const createApp = () => {
  const app = express();
  app.use(express.json());

  const creatures = [
    'Squirrel',
    'Rabbit',
    'Ferret',
    'Badger'
  ];

  const iceCreamFlavors = [
    'Vanilla',
    'Chocolate',
    'Strawberry',
    'Mint Chocolate Chip'
  ];

  const stage = process.env.STAGE || "unknown";
  const backend = process.env.BACKEND || "unknown"; 

  console.log(`App starting with STAGE: ${stage}`);
  console.log(`App starting with BACKEND: ${backend}`);

  app.use((req, res, next) => {
    console.log(`Request received: ${req.method} ${req.url}`);
    next();
  });

  app.get(`/health`, (req, res) => {
    res.status(200).json({ msg: "Hello, this is your API" });
  });

  app.get(`/${stage}/host`, (req, res) => {
    const hostname = os.hostname();
    const currentTime = new Date().toISOString();

    res.status(200).json({
      message: `Request handled by backend at ${currentTime}`,
      hostname: hostname,
      backend: backend
    });
  });

  app.get(`/${stage}/small-woodland-creature`, (req, res) => {
    const randomIndex = Math.floor(Math.random() * creatures.length);
    const selectedCreature = creatures[randomIndex];

    res.status(200).json({
      creature: selectedCreature,
      backend: backend
    });
  });

  app.get(`/${stage}/ice-cream-flavour`, (req, res) => {
    const randomIndex = Math.floor(Math.random() * iceCreamFlavors.length);
    const selectedFlavor = iceCreamFlavors[randomIndex];
  
    res.status(200).json({
      flavor: selectedFlavor,
      backend: backend
    });
  });

  return app;
};

module.exports = { createApp };
