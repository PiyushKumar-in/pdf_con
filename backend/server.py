from flask import Flask, render_template, send_from_directory, request
from flask_cors import CORS
from uuid import uuid4
from os import system

app = Flask(__name__)

@app.route('/')
def home():
    return send_from_directory("../build/web/","index.html")

@app.route("/<file>")
def files(file):
    return send_from_directory("../build/web/",file)

@app.route('/compress',methods=['POST'])
def compressPost():
    id = uuid4().hex
    file = request.files['file']
    file.save(f"./data/{id}_{file.filename}")
    system(f"powershell -command mv './data/{id}_{file.filename}' '.\/data/{id}.pdf'")
    return send_from_directory("data",f"{id}.pdf")

@app.route('/merge',methods=['POST'])
def mergePost():
    id = uuid4().hex
    file = request.files['file0']
    file.save(f"./data/{id}_{file.filename}")
    system(f"powershell -command mv './data/{id}_{file.filename}' '.\/data/{id}.pdf'")
    return send_from_directory("data",f"{id}.pdf")

@app.route('/edit',methods=['POST'])
def editPost():
    print(request.args)
    id = uuid4().hex
    print(request.form["data"])
    file = request.files[list(request.files.keys())[0]]
    file.save(f"./data/{id}_{file.filename}")
    system(f"powershell -command mv './data/{id}_{file.filename}' '.\/data/{id}.pdf'")
    return send_from_directory("data",f"{id}.pdf")

if __name__=="__main__":
    CORS(app=app)
    app.run("localhost",80,debug=True)