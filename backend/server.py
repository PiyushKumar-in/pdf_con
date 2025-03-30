from flask import Flask, render_template, send_from_directory

app = Flask(__name__)

@app.route('/')
def home():
    return send_from_directory("../build/web/","index.html")

@app.route("/<file>")
def files(file):
    return send_from_directory("../build/web/",file)

if __name__=="__main__":
    app.run("localhost",80,debug=True)