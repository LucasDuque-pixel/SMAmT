require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

// 1. Conexão GENÉRICA ao Cluster
// Removido o 'dbName' global para permitir que os modelos 
// acessem bancos diferentes conforme necessário.
mongoose.connect(process.env.MONGO_URI)
.then(async () => {
  console.log('MongoDB conectado ao Cluster com sucesso.');
  
  // Diagnóstico seguro
  console.log("=== DIAGNÓSTICO DE BANCO DE DADOS ===");
  if (mongoose.connection.db) {
    // Lista os bancos disponíveis no cluster, não apenas coleções
    console.log("Conectado ao cluster central.");
  }
  console.log("======================================");

  // 2. Inicia o servidor
  app.listen(process.env.PORT || 3000, () => {
    console.log('Servidor rodando na porta', process.env.PORT || 3000);
  });
})
.catch(err => {
  console.error('Erro crítico ao conectar no MongoDB:', err);
  process.exit(1); 
});



// Rotas
app.use('/auth', require('./routes/auth'));
app.use('/api/v1/leituras', require('./routes/leituras'));