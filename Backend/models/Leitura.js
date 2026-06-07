const mongoose = require('mongoose');

// Se você está usando uma conexão dedicada, certifique-se que ela está instanciada aqui:
const monitoramentoConn = mongoose.createConnection(process.env.MONGO_URI, {
  dbName: 'monitoramento'
});

const LeituraSchema = new mongoose.Schema({
  temperatura: Number,
  umidade: Number,
  ruido: mongoose.Schema.Types.Mixed,
  data_hora: Date
}, { 
  collection: 'dados_dht11' // Garanta que o nome é exatamente esse!
});

// Use a conexão monitoramentoConn, não o mongoose global
module.exports = monitoramentoConn.model('Leitura', LeituraSchema);