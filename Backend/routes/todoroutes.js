const express = require('express');
const {todo , gettodo , updatetodo , deletetodo} = require("../controller/todocontroller")

const authmiddlewere = require('../config/auth');

const router = express.Router();

router.post("/todo", authmiddlewere,todo);
router.get("/todo",authmiddlewere, gettodo);
router.put("/todo/:todoid" ,authmiddlewere , updatetodo )
router.delete("/todo/:todoid", authmiddlewere ,deletetodo)

module.exports = router;