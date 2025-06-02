const express = require('express')
const {loginuser , registeruser} = require('../controller/authcontroller')

const router = express.Router();
router.post("/register" , registeruser);
router.post("/login", loginuser)

module.exports = router;