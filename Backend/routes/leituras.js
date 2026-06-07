const express = require('express');
const router = express.Router();
const Leitura = require('../models/Leitura');

router.get('/historico', async (req, res) => {
    try {
        // Busca os últimos 50 registros ordenados pelo mais recente
        const dados = await Leitura.find().sort({ data_hora: -1 }).limit(50);
        
        console.log(`[API] Sucesso: ${dados.length} registros enviados.`);
        res.json(dados);
        
    } catch (err) {
        console.error("[API] Erro ao buscar leituras:", err);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;