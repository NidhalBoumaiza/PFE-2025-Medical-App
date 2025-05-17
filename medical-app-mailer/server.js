const app = require("./app");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const socketIo = require("socket.io");
const conversationController = require("./controllers/conversationController");

process.on("uncaughtException", (err) => {
  console.log("UNCAUGHT EXCEPTION! 💥 Shutting down...");
  console.log(err.name, err.message);
  process.exit(1);
});

// Load environment variables
dotenv.config({ path: "./.env" });

// Set NODE_ENV to development if not already set
if (!process.env.NODE_ENV) {
  process.env.NODE_ENV = "development";
  console.log(
    "Environment not specified, defaulting to development mode"
  );
}

console.log(`Running in ${process.env.NODE_ENV} mode`);

const DB = process.env.DATABASE;
mongoose.set("strictQuery", true);

mongoose
  .connect(DB, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("DB connection successful!"));

// Add a test route to app.js exports
app.get("/api/v1/test", (req, res) => {
  res.status(200).json({
    status: "success",
    message: "Server is running correctly",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  });
});

const port = process.env.PORT || 3000;
const server = app.listen(port, () => {
  console.log("\n===========================================");
  console.log("🚀 Medical App Server running on port " + port);
  console.log("===========================================");
  console.log("\n📌 Available endpoints:");
  console.log("- GET  /api/v1/test - Test server connection");
  console.log("- GET  /api/v1/users - User routes");
  console.log("- GET  /api/v1/appointments - Appointment routes");
  console.log("- GET  /api/v1/conversations - Conversation routes");
  console.log("- GET  /api/v1/notifications - Notification routes");
  console.log("- GET  /api/v1/prescriptions - Prescription routes");
  console.log("===========================================\n");
});

process.on("unhandledRejection", (err) => {
  console.log("UNHANDLED REJECTION! 💥 Shutting down...");
  console.log(err.name, err.message);
  server.close(() => {
    process.exit(1);
  });
});

// Initialize Socket.IO
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

// Store connected users
let connectedUsers = {};

// Socket.IO connection handling
io.on("connection", (socket) => {
  console.log("A user connected");

  // When a user connects, store their user ID and socket ID
  socket.on("userConnected", (userId) => {
    connectedUsers[userId] = socket.id;
    console.log(`User ${userId} connected with socket ${socket.id}`);
  });

  // Handle sending messages
  socket.on("sendMessage", async (data) => {
    try {
      const { recipientId, message } = data;
      const senderId = socket.handshake.query.userId;

      if (!senderId || !recipientId || !message) {
        console.error("Missing data for sending message");
        return;
      }

      // Save message to database
      await conversationController.storeMessage(
        senderId,
        recipientId,
        message
      );

      // Send message to recipient if they are online
      const recipientSocketId = connectedUsers[recipientId];
      if (recipientSocketId) {
        io.to(recipientSocketId).emit("receiveMessage", {
          senderId,
          message,
          timestamp: new Date(),
        });
      }
    } catch (error) {
      console.error("Error sending message:", error);
    }
  });

  // Handle user disconnect
  socket.on("disconnect", () => {
    console.log("A user disconnected");

    // Remove user from connected users
    for (const userId in connectedUsers) {
      if (connectedUsers[userId] === socket.id) {
        delete connectedUsers[userId];
        console.log(`User ${userId} disconnected`);
        break;
      }
    }
  });
});
