const express = require('express')
const connectdb = require('./config/db');
const cors = require("cors");

const dotenv= require("dotenv");
const bodyParser = require('body-parser');
dotenv.config();

const app = express()
app.use(cors())
app.use(bodyParser.json())
connectdb();

app.use("/auth", require('./routes/authroutes'))
app.use("/api", require('./routes/todoroutes'))
const port = 5000
app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
