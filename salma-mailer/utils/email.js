const nodemailer = require("nodemailer");

const sendEmail = async (options) => {
  // 1) Create a transporter :
  var transport = nodemailer.createTransport({
    service: "gmail",
    host: "smtp.gmail.com",
    port: process.env.PORTMAILER,
    auth: {
      user: process.env.USERMAILER,
      pass: process.env.PASSWORDMAILER,
    },
  });
  // 2) Define the email options :
  const mailOptions = {
    from: "Medical App",
    to: options.email,
    subject: options.subject,
    text: options.message,
    attachments: options.attachments,
  };
  await transport.sendMail(mailOptions);
};

module.exports = sendEmail;
