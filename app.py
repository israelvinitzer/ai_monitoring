from flask import Flask


app = Flask(__name__)


@app.route('/')
@app.route('/health')
def health():
    return "status: healthy 200"