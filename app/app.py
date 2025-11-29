from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return "<h1>Hello from the Azure Landing Zone!</h1><p>This app is running securely inside a VNet.</p>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)