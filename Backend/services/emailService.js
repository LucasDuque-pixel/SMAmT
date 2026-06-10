const nodemailer = require('nodemailer');

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
}

module.exports = {
    enviarEmailBoasVindas,
};