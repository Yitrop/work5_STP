from flask import Flask, jsonify
import time
import threading

app = Flask(__name__)

# Счетчик для /metrics
request_count = 0
lock = threading.Lock()

@app.route('/time')
def get_time():
    return jsonify({"time": int(time.time())})

@app.route('/metrics')
def get_metrics():
    global request_count
    with lock:
        request_count += 1
    return jsonify({"count": request_count})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3030)
