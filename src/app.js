// app.js
const { createApp } = require('./common');

const app = createApp();

const port = process.env.PORT || 3000;

app.listen(port, () => {
  console.log(`App listening on http://localhost:${port}`);
});
