require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

// Conexão Mongo
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB conectado'))
  .catch(err => console.log(err));

// Rotas
app.use('/auth', require('./routes/auth'));

app.listen(process.env.PORT, () => {
  console.log('Servidor rodando na porta', process.env.PORT);
});