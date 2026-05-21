const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET || 'segredo_super';

// Cadastro
router.post('/register', async (req, res) => {
  try {
    const { nome, email, senha } = req.body;

    if (!nome || !email || !senha) {
      return res.status(400).json({ message: 'Preencha nome, email e senha.' });
    }

    const emailExiste = await User.findOne({ email: email.toLowerCase() });
    if (emailExiste) {
      return res.status(409).json({ message: 'Este email já está cadastrado.' });
    }

    const senhaHash = await bcrypt.hash(senha, 10);

    const novoUsuario = new User({
      nome,
      email: email.toLowerCase(),
      senha: senhaHash
    });

    await novoUsuario.save();

    return res.status(201).json({
      message: 'Usuário cadastrado com sucesso.'
    });
  } catch (error) {
    return res.status(500).json({ message: 'Erro ao cadastrar usuário.', error: error.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, senha } = req.body;

    if (!email || !senha) {
      return res.status(400).json({ message: 'Preencha email e senha.' });
    }

    const usuario = await User.findOne({ email: email.toLowerCase() });
    if (!usuario) {
      return res.status(401).json({ message: 'Credenciais inválidas.' });
    }

    const senhaCorreta = await bcrypt.compare(senha, usuario.senha);
    if (!senhaCorreta) {
      return res.status(401).json({ message: 'Credenciais inválidas.' });
    }

    const token = jwt.sign(
      {
        id: usuario._id,
        email: usuario.email,
        nome: usuario.nome
      },
      JWT_SECRET,
      { expiresIn: '1d' }
    );

    return res.status(200).json({
      token,
      user: {
        id: usuario._id,
        nome: usuario.nome,
        email: usuario.email
      }
    });
  } catch (error) {
    return res.status(500).json({ message: 'Erro ao fazer login.', error: error.message });
  }
});

// Middleware de autenticação
function auth(req, res, next) {
  const header = req.headers.authorization;

  if (!header) {
    return res.status(401).json({ message: 'Token não informado.' });
  }

  const token = header.startsWith('Bearer ') ? header.split(' ')[1] : header;

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Token inválido ou expirado.' });
  }
}

// Dados do usuário logado
router.get('/me', auth, async (req, res) => {
  try {
    const usuario = await User.findById(req.user.id).select('-senha');

    if (!usuario) {
      return res.status(404).json({ message: 'Usuário não encontrado.' });
    }

    return res.json(usuario);
  } catch (error) {
    return res.status(500).json({ message: 'Erro ao buscar usuário.', error: error.message });
  }
});

module.exports = router;