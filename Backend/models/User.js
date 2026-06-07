const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  nome: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  senha: {
    type: String,
    required: true
  }
}, {
  timestamps: true,
  collection: 'users', // Força o nome da coleção
  dbName: 'monitoramento' // O "GPS": força a busca neste banco de dados
});

module.exports = mongoose.model('User', UserSchema);