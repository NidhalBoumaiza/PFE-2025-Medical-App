const nodemailer = require("nodemailer");

const sendEmail = async (options) => {
  try {
    // 1) Create a transporter
    const transport = nodemailer.createTransport({
      service: "gmail",
      host: "smtp.gmail.com",
      port: process.env.PORTMAILER || 587,
      auth: {
        user: process.env.USERMAILER || "",
        pass: process.env.PASSWORDMAILER || "",
      },
    });

    // 2) Define the email options
    const mailOptions = {
      from: "Medical App <noreply@medicalapp.com>",
      to: options.email,
      subject: options.subject,
      text: options.message,
      attachments: options.attachments,
    };

    // 3) Send the email
    const info = await transport.sendMail(mailOptions);
    console.log(`Email sent: ${info.messageId}`);
    return info;
  } catch (error) {
    console.error("Error sending email:", error);
    throw error; // Rethrow for proper handling in controller
  }
};

module.exports = sendEmail;
