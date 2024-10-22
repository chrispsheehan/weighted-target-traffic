const app = require('./lambda');
const port = process.env.PORT;

app.listen(port, () => {
  console.log(`app listening on http://localhost:${port}`);
});
