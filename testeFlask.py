from flask import Flask, request, jsonify
from pymongo import MongoClient
from datetime import datetime, timezone
from zoneinfo import ZoneInfo
from datetime import timedelta
import requests

app = Flask(__name__)
client = MongoClient("mongodb://lucasduquema_db_user:-AVsm3jw4DSTMb.@ac-zlfepsl-shard-00-00.u0nd9yw.mongodb.net:27017,ac-zlfepsl-shard-00-01.u0nd9yw.mongodb.net:27017,ac-zlfepsl-shard-00-02.u0nd9yw.mongodb.net:27017/?ssl=true&replicaSet=atlas-h92ahp-shard-0&authSource=admin&appName=MongoDB-Duque")
db = client["monitoramento"]
colecao = db["dados_dht11"]
fuso_brasilia = ZoneInfo("America/Sao_Paulo")
BOT_TOKEN = "8942217857:AAGvyJDlirHP-GVgK2-9E1I5iF9yWI7oqnc"
CHAT_ID = "-5240852491"
ultimo_alerta_temperatura = None
ultimo_alerta_umidade = None
ultimo_alerta_ruido = None
INTERVALO_ALERTA = timedelta(minutes=5)

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

        global ultimo_alerta_temperatura
        global ultimo_alerta_umidade
        global ultimo_alerta_ruido

        agora = datetime.now(fuso_brasilia)

        # ==========================
        # ALERTAS DE TEMPERATURA
        # ==========================

        alerta_temperatura = False
        motivos_temperatura = []

        if documento["temperatura"] > 30:
            alerta_temperatura = True
            motivos_temperatura.append(
                f"Temperatura alta ({documento['temperatura']}°C)"
            )

        if documento["temperatura"] < 16:
            alerta_temperatura = True
            motivos_temperatura.append(
                f"Temperatura baixa ({documento['temperatura']}°C)"
            )

        if alerta_temperatura:

            pode_enviar = (
                ultimo_alerta_temperatura is None
                or agora - ultimo_alerta_temperatura >= INTERVALO_ALERTA
            )

            if pode_enviar:

                mensagem = (
                    "🌡 ALERTA DE TEMPERATURA 🌡\n\n"
                    f"Temperatura: {documento['temperatura']}°C\n"
                    f"Umidade: {documento['umidade']}%\n"
                    f"Ruído: {documento['ruido']}\n\n"
                    "Motivos:\n• "
                    + "\n• ".join(motivos_temperatura)
                    + f"\n\n🕒 {agora.strftime('%d/%m/%Y %H:%M:%S')}"
                )

                enviar_telegram(mensagem)
                ultimo_alerta_temperatura = agora

        # ==========================
        # ALERTAS DE UMIDADE
        # ==========================

        alerta_umidade = False
        motivos_umidade = []

        if documento["umidade"] > 70:
            alerta_umidade = True
            motivos_umidade.append(
                f"Umidade alta ({documento['umidade']}%)"
            )

        if documento["umidade"] < 30:
            alerta_umidade = True
            motivos_umidade.append(
                f"Umidade baixa ({documento['umidade']}%)"
            )

        if alerta_umidade:

            pode_enviar = (
                ultimo_alerta_umidade is None
                or agora - ultimo_alerta_umidade >= INTERVALO_ALERTA
            )

            if pode_enviar:

                mensagem = (
                    "💧 ALERTA DE UMIDADE 💧\n\n"
                    f"Temperatura: {documento['temperatura']}°C\n"
                    f"Umidade: {documento['umidade']}%\n"
                    f"Ruído: {documento['ruido']}\n\n"
                    "Motivos:\n• "
                    + "\n• ".join(motivos_umidade)
                    + f"\n\n🕒 {agora.strftime('%d/%m/%Y %H:%M:%S')}"
                )

                enviar_telegram(mensagem)
                ultimo_alerta_umidade = agora

        # ==========================
        # ALERTAS DE RUÍDO
        # ==========================

        alerta_ruido = False
        motivos_ruido = []

        if documento["ruido"] == "Ruidoso":
            alerta_ruido = True
            motivos_ruido.append("Ruído elevado")

        if alerta_ruido:

            pode_enviar = (
                ultimo_alerta_ruido is None
                or agora - ultimo_alerta_ruido >= INTERVALO_ALERTA
            )

            if pode_enviar:

                mensagem = (
                    "🔊 ALERTA DE RUÍDO 🔊\n\n"
                    f"Temperatura: {documento['temperatura']}°C\n"
                    f"Umidade: {documento['umidade']}%\n"
                    f"Ruído: {documento['ruido']}\n\n"
                    "Motivos:\n• "
                    + "\n• ".join(motivos_ruido)
                    + f"\n\n🕒 {agora.strftime('%d/%m/%Y %H:%M:%S')}"
                )

                enviar_telegram(mensagem)
                ultimo_alerta_ruido = agora

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