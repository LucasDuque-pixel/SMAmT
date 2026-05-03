from flask import Flask, request, jsonify
from pymongo import MongoClient
from datetime import datetime, timezone

app = Flask(__name__)
client = MongoClient("mongodb+srv://lucasduquema_db_user:aEdWSn0hYx5rc9zs@mongodb-duque.u0nd9yw.mongodb.net/")
db = client["monitoramento"]
colecao = db["dados_dht11"]

@app.route('/dados', methods=['POST'])
def receber_dados():
    try:
        dados = request.get_json()
        documento = {
            "temperatura": dados.get("temperatura"),
            "umidade": dados.get("umidade"),
            "data_hora": datetime.now(timezone.utc)
        }
        
        colecao.insert_one(documento)
        print(f"Dados salvos: {documento}")
        return jsonify({"status": "sucesso"}), 201

    except Exception as e:
        print(f"Erro: {e}")
        return jsonify({"status": "erro", "mensagem": str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)