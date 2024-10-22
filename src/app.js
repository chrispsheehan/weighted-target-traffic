const app = require('./lambda');
const port = process.env.PORT;

console.log(`App starting with PORT: ${port}`);

app.listen(port, () => {
  console.log(`app listening on http://localhost:${port}`);
});
