// mailer.js
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.GMAIL_USER,  
        pass: process.env.GMAIL_PASS,
    }
});

const sendReportEmail = async ({ fromEmail, toEmail, subject, text, replyToEmail }) => {
    const mailOptions = {
        from: fromEmail,  // Sender's email (user's email)
        to: toEmail,      // Recipient's email (agency's email or whoever you are sending the report to)
        subject: subject,
        text: text,
        replyTo: replyToEmail  // Setting the reply-to address
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log('Email sent successfully!');
    } catch (error) {
        console.error('Error sending email:', error);
    }
};


module.exports = { sendReportEmail };
