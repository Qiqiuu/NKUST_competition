from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import numpy as np
import io
from medrecognizer import MedicineRecognizer

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

recognizer = MedicineRecognizer(load_model_path="models/medicine_recognizer.pkl")

@app.post("/recognize")
async def recognize(file: UploadFile = File(...)):
    contents = await file.read()
    image = Image.open(io.BytesIO(contents)).convert("RGB")
    image = np.array(image)

    pred = recognizer.predict_image(image)

    return {
        "medicine": pred
    }