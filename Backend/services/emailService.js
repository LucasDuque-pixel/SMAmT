const nodemailer = require('nodemailer');

console.log("EMAIL_USER:", process.env.EMAIL_USER);
console.log(
    "EMAIL_PASS existe:",
    !!process.env.EMAIL_PASS
);

const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 587,
    secure: false,
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});

async function enviarEmailBoasVindas(nome, email) {

    const linkTelegram =
        'https://t.me/SEU_LINK_DO_GRUPO';
    
    console.log("Iniciando envio para:", email);

    await transporter.sendMail({
        from: `"SMAmT" <${process.env.EMAIL_USER}>`,
        to: email,
        subject: 'Bem-vindo ao SMAmT',

        html: `
            <h2>Olá, ${nome}!</h2>

            <p>
                Seu cadastro no Sistema de Monitoramento
                Ambiental foi realizado com sucesso.
            </p>

            <p>
                Entre no grupo oficial para receber
                notificações do sistema:
            </p>

            <p>
                <a href="${linkTelegram}">
                    Entrar no Grupo Telegram
                </a>
            </p>

            <br>

            <p>
                Equipe SMAmT
            </p>
        `,
    });
    console.log("Email enviado:")
}
transporter.verify(function(error, success) {

    if (error) {
        console.log("SMTP erro:");
        console.log(error);
    } else {
        console.log(
            "Servidor SMTP conectado com sucesso"
        );
    }

});


module.exports = {
    enviarEmailBoasVindas,
};