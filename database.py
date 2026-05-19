import os
from dotenv import load_dotenv

load_dotenv()

USE_MOCK = os.getenv("USE_MOCK", "true").lower() == "true"

DB_SERVER = os.getenv("DB_SERVER")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_PORT = os.getenv("DB_PORT", "1433")
DB_ROLE = os.getenv("DB_ROLE", "admin")


def is_mock_mode():
    """
    Uygulamanın mock veriyle mi yoksa gerçek DB ile mi çalışacağını döndürür.
    """
    return USE_MOCK


def get_connection_info():
    """
    DB bağlantı durumunu gösterir.
    """
    return {
        "use_mock": USE_MOCK,
        "server": DB_SERVER,
        "database": DB_NAME,
        "user": DB_USER,
        "port": DB_PORT,
        "role": DB_ROLE,
        "status": (
            "Mock mod aktif. Backend mock verilerle çalışıyor."
            if USE_MOCK
            else "DB modu aktif. Gerçek SQL Server bağlantısı kullanılacak."
        )
    }


def get_sql_connection():
    """
    DB hazır olunca aktif kullanılacak bağlantı fonksiyonu.

    DB moduna geçince:
    1. pip install pyodbc
    2. Mac'e ODBC Driver 18 kurulacak
    3. Bu fonksiyon aktif edilecek
    """

    if USE_MOCK:
        raise RuntimeError("Mock mod aktifken gerçek SQL bağlantısı açılamaz.")

    raise NotImplementedError("DB bağlantısı henüz aktif edilmedi.")