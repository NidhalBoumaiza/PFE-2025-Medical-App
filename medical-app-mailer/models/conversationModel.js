const mongoose = require("mongoose");

// Schema for individual messages
const messageSchema = new mongoose.Schema(
  {
    sender: {
      type: mongoose.Schema.ObjectId,
      ref: "User",
      required: [true, "Un message doit avoir un expéditeur"],
    },
    content: {
      type: String,
      trim: true,
    },
    timestamp: {
      type: Date,
      default: Date.now,
    },
    readBy: [
      {
        type: mongoose.Schema.ObjectId,
        ref: "User",
      },
    ],
    type: {
      type: String,
      enum: ["text", "image", "file"],
      default: "text",
    },
    fileUrl: {
      type: String,
    },
    fileName: {
      type: String,
    },
    fileSize: {
      type: Number,
    },
    fileMimeType: {
      type: String,
    },
    status: {
      type: String,
      enum: ["sent", "delivered", "read"],
      default: "sent",
    },
  },
  {
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Schema for conversations
const conversationSchema = new mongoose.Schema(
  {
    patientId: {
      type: mongoose.Schema.ObjectId,
      ref: "User",
      required: [true, "Une conversation doit avoir un patient"],
    },
    doctorId: {
      type: mongoose.Schema.ObjectId,
      ref: "User",
      required: [true, "Une conversation doit avoir un médecin"],
    },
    patientName: {
      type: String,
      required: [true, "Le nom du patient est requis"],
    },
    doctorName: {
      type: String,
      required: [true, "Le nom du médecin est requis"],
    },
    lastMessage: {
      type: String,
      default: "",
    },
    lastMessageType: {
      type: String,
      enum: ["text", "image", "file"],
      default: "text",
    },
    lastMessageTime: {
      type: Date,
      default: Date.now,
    },
    lastMessageSenderId: {
      type: mongoose.Schema.ObjectId,
      ref: "User",
    },
    lastMessageReadBy: [
      {
        type: mongoose.Schema.ObjectId,
        ref: "User",
      },
    ],
    lastMessageUrl: {
      type: String,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Add index for faster queries
conversationSchema.index(
  { patientId: 1, doctorId: 1 },
  { unique: true }
);

// Static method to parse date strings
conversationSchema.statics.parseDateTime = function (dateTimeString) {
  if (!dateTimeString) return new Date();

  try {
    return new Date(dateTimeString);
  } catch (error) {
    console.error("Error parsing date:", error);
    return new Date();
  }
};

// Virtual populate messages
conversationSchema.virtual("messages", {
  ref: "Message",
  foreignField: "conversation",
  localField: "_id",
});

const Conversation = mongoose.model(
  "Conversation",
  conversationSchema
);
const Message = mongoose.model("Message", messageSchema);

module.exports = { Conversation, Message };
