const express = require("express");
const authController = require("../controllers/authController");
const router = express.Router();
router.route("/sendMailService").post(authController.sendMailService);

module.exports = router;
