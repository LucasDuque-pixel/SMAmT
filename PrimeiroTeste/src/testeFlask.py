from flask import Flask, request, jsonify
from pymongo import MongoClient
from datetime import datetime, timezone
from zoneinfo import ZoneInfo
import requests

app = Flask(__name__)
client = MongoClient("mongodb://lucasduquema_db_user:-AVsm3jw4DSTMb.@ac-zlfepsl-shard-00-00.u0nd9yw.mongodb.net:27017,ac-zlfepsl-shard-00-01.u0nd9yw.mongodb.net:27017,ac-zlfepsl-shard-00-02.u0nd9yw.mongodb.net:27017/?ssl=true&replicaSet=atlas-h92ahp-shard-0&authSource=admin&appName=MongoDB-Duque")
db = client["monitoramento"]
colecao = db["dados_dht11"]
fuso_brasilia = ZoneInfo("America/Sao_Paulo")
BOT_TOKEN = "8942217857:AAGvyJDlirHP-GVgK2-9E1I5iF9yWI7oqnc"
CHAT_ID = "-5240852491"

@app.route('/dados', methods=['POST'])
def receber_dados():
    try:

        dados = request.get_json()

        if dados.get("ruido") < 5:
            som = "Apropriado"
        else:
            som = "Ruidoso"

        documento = {
            "temperatura": dados.get("temperatura"),
            "umidade": dados.get("umidade"),
            "ruido": som,
            "data_hora": datetime.now(fuso_brasilia)
        }

        colecao.insert_one(documento)

        alerta = False
        motivos = []

        if documento["temperatura"] > 35:
            alerta = True
            motivos.append(
                f"Temperatura alta ({documento['temperatura']}°C)"
            )

        if documento["ruido"] == "Ruidoso":
            alerta = True
            motivos.append("Ruído elevado")

        if alerta:

            mensagem = (
                "⚠ ALERTA NO AMBIENTE ⚠\n\n"
                f"Temperatura: {documento['temperatura']}°C\n"
                f"Umidade: {documento['umidade']}%\n"
                f"Ruído: {documento['ruido']}\n\n"
                f"Motivos:\n- "
                + "\n- ".join(motivos)
            )

            enviar_telegram(mensagem)

        print(f"Dados salvos: {documento}")

        return jsonify({"status": "sucesso"}), 201

    except Exception as e:

        print(f"Erro: {e}")

        return jsonify({
            "status": "erro",
            "mensagem": str(e)
        }), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
    
def enviar_telegram(mensagem):

    url = (
        f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
    )

    requests.post(
        url,
        json={
            "chat_id": CHAT_ID,
            "text": mensagem
        }
    )