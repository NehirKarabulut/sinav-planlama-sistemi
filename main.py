from fastapi import FastAPI
from planlama import router as planlama_router

app = FastAPI(
    title="Sınav Planlama API",
    description="YZM 2126 Veritabanı Sistemlerine Giriş Projesi Backend API",
    version="1.0.0"
)

app.include_router(planlama_router, prefix="/api")


@app.get("/")
def home():
    return {
        "message": "Sınav Planlama API çalışıyor",
        "docs": "http://127.0.0.1:8000/docs"
    }