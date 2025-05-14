const express = require("express");
const notificationController = require("../controllers/notificationController");
const router = express.Router();

router.route("/send").post(notificationController.sendNotification);
router
  .route("/save")
  .post(notificationController.saveNotificationToFirestore);

module.exports = router;
