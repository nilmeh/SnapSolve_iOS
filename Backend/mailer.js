// mailer.js
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.GMAIL_USER,  
        pass: process.env.GMAIL_PASS,
    }
});

const sendReportEmail = async ({ userEmail, toEmail, subject, text }) => {
    const mailOptions = {
        from: process.env.GMAIL_USER,   // server's email
        to: toEmail,                    // Recipient (agency) email
        replyTo: userEmail,              // User's email (for reply-to)
        subject: subject,
        text: text,
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log('Email sent successfully!');
    } catch (error) {
        console.error('Error sending email:', error);
    }
};

module.exports = { sendReportEmail };
