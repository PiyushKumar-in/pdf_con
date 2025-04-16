from flask import Flask, render_template, send_from_directory, request, abort
from flask_cors import CORS
from uuid import uuid4
from os import system,listdir, path
from json import loads


def mergedNames(data):
    dataMerged = []
    for i in data:
        if (len(dataMerged)==0) or (dataMerged[-1]["name"]!=i["name"]) or ("0" in ["page"]):
            dataMerged.append(i)
        else:
            dataMerged[-1]["page"] += " " + i["page"]
    return dataMerged

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
    system(f"cd ./data && mkdir {id}")
    while (f"{id}" not in listdir("./data")):
        pass
    compression = request.form["compression"]
    file = request.files['file']
    file.save(f"./data/{id}/{id}_{file.filename}")
    
    if compression in ("low", "medium","high"):
        comp = "screen" if compression=="high" else ("ebook" if compression=="medium" else "printer")
        system(f"cd data/{id} && gs -sDEVICE=pdfwrite -dPDFSETTINGS=/{comp} -dNOPAUSE -dQUIET -dBATCH -sOutputFile=\"compressed_{id}.pdf\" \"./{id}_{file.filename}\" && cd ../..")
    else:
        system(f"cd data/{id} && gs -sDEVICE=pdfwrite -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=\"compressed_screen_{id}.pdf\" \"./{id}_{file.filename}\" && cd ../..")
        system(f"cd data/{id} && gs -sDEVICE=pdfwrite -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile=\"compressed_printer_{id}.pdf\" \"./{id}_{file.filename}\" && cd ../..")
        system(f"cd data/{id} && gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=\"compressed_ebook_{id}.pdf\" \"./{id}_{file.filename}\" && cd ../..")
        orignal_size = path.getsize(f"./data/{id}/{id}_{file.filename}")
        size1 = path.getsize(f"./data/{id}/compressed_screen_{id}.pdf")/orignal_size
        size3 = path.getsize(f"./data/{id}/compressed_printer_{id}.pdf")/orignal_size
        size2 = path.getsize(f"./data/{id}/compressed_ebook_{id}.pdf")/orignal_size

        if (compression=="80"):
            if (size3<0.8):
                system(f"mv ./data/{id}/compressed_printer_{id}.pdf ./data/compressed_{id}.pdf")
            elif (size2<0.8):
                system(f"mv ./data/{id}/compressed_ebook_{id}.pdf ./data/compressed_{id}.pdf")
            elif (size2<0.8):
                system(f"mv ./data/{id}/compressed_screen_{id}.pdf ./data/compressed_{id}.pdf")
            else:
                system(f"rm ./data/{id}/")
                return abort(501)
                
        elif (compression=="50"):
            if (size3<0.5):
                system(f"mv ./data/{id}/compressed_printer_{id}.pdf ./data/compressed_{id}.pdf")
            elif (size2<0.5):
                system(f"mv ./data/{id}/compressed_ebook_{id}.pdf ./data/compressed_{id}.pdf")
            elif (size2<0.5):
                system(f"mv ./data/{id}/compressed_screen_{id}.pdf ./data/compressed_{id}.pdf")
            else:
                system(f"rm ./data/{id}/")
                return abort(501)
        elif (compression=="30"):
            if (size3<0.3):
                system(f"mv ./data/{id}/compressed_printer_{id}.pdf ./data/compressed_{id}.pdf")
            elif (size2<0.3):
                system(f"mv ./data/{id}/compressed_ebook_{id}.pdf ./data/compressed_{id}.pdf")
            elif (size2<0.3):
                system(f"mv ./data/{id}/compressed_screen_{id}.pdf ./data/compressed_{id}.pdf")
            else:
                system(f"rm ./data/{id}/")
                return abort(501)


    while (f"compressed_{id}.pdf" not in listdir(f"./data/")):
        pass
    system(f"rm ./data/{id}/")
    return send_from_directory("data",f"compressed_{id}.pdf")

@app.route('/merge',methods=['POST'])
def mergePost():
    id = uuid4().hex
    system(f"cd ./data && mkdir {id}")
    while (f"{id}" not in listdir("./data")):
        pass
    filesLables = []
    for fileName in request.files:
        file = request.files[fileName]
        file.save(f"./data/{id}/{id}_{file.filename}")
        filesLables.append(f"\"./data/{id}/{id}_{file.filename}\"")
    names = (" ".join(filesLables));
    command = f"pdftk {names} cat output ./data/{id}.pdf"
    system(command)
    while (f"{id}.pdf" not in listdir("./data")):
        pass
    system(f"rm -rf ./data/{id}")
    return send_from_directory("data",f"{id}.pdf")

@app.route('/edit',methods=['POST'])
def editPost():
    id = uuid4().hex

    mergedNamesOuput = mergedNames(loads(request.form["data"]))
    system(f"cd ./data && mkdir {id} && cd ..")
    while (f"{id}" not in listdir("./data")):
        pass

    for fileName in request.files:
        file = request.files[fileName]
        file.save(f"./data/{id}/{id}_{file.filename}")
        if (not file.filename.lower().endswith(".pdf")):
            print(f"convert \"./data/{id}/{id}_{file.filename}\" \"./data/{id}/{id}_{file.filename}.pdf\"")
            system(f"cd ./data/{id}/ &&convert \"{id}_{file.filename}\" \"{id}_{file.filename}.pdf\"")
            while (f"{id}_{file.filename}.pdf" not in listdir(f"./data/{id}")):
                pass
    for i in range(len(mergedNamesOuput)):
        fileVar = mergedNamesOuput[i]
        if ("0" in fileVar["page"]):
            system(f"pdftk \"./data/{id}/{id}_{fileVar['name']}.pdf\" cat output ./data/{id}/{i}.pdf")
            while (f"{i}.pdf" not in listdir(f"./data/{id}/")):
                pass
        else:
            system(f"pdftk \"./data/{id}/{id}_{fileVar['name']}\" cat {fileVar['page']} output ./data/{id}/{i}.pdf")
            while (f"{i}.pdf" not in listdir(f"./data/{id}/")):
                pass
    filesNames = " ".join([f"./data/{id}/{i}.pdf" for i in range(len(mergedNamesOuput))])
    system(f"pdftk {filesNames} cat output ./data/{id}.pdf")
    while (f"{id}.pdf" not in listdir("./data")):
        pass
    system(f"rm -rf ./data/{id}/")
    while (f"{id}" in listdir("./data")):
        pass
    return send_from_directory("data",f"{id}.pdf")

if __name__=="__main__":
    CORS(app=app)
    app.run("localhost",8080,debug=True)