# Sınav Planlama Sistemi - Backend Kontrol Dokümanı

Bu doküman, **YZM 2126 Veritabanı Sistemlerine Giriş** dersi kapsamında geliştirilen Sınav Planlama Sistemi projesinin backend tarafında hangi isterlerin hangi dosya, endpoint veya SQL scripti ile karşılandığını açıklamak için hazırlanmıştır.

Proje backend tarafında şu an **mock data** ile çalışmaktadır. Veritabanı hazır olduğunda aynı endpoint yapısı korunarak SQL Server bağlantısı aktif edilecektir.

---

## 1. Backend Teknolojileri

Projede backend tarafında kullanılan teknolojiler:

- Python
- FastAPI
- Uvicorn
- Mock data ile geliştirme
- SQL Server bağlantısı için hazırlık
- SQL Server Management Studio ile uyumlu SQL scriptleri
- Stored Procedure, UDF, View, Trigger, Transaction, Log ve Security yapıları

---

## 2. Proje Klasör Yapısı

```text
sinav-planlama-api
├── main.py
├── planlama.py
├── database.py
├── sql_service.py
├── requirements.txt
├── .env.example
├── BACKEND_README.md
├── sql_scripts
│   ├── 01_create_tables.sql
│   ├── 02_insert_sample_data.sql
│   ├── 03_views.sql
│   ├── 04_functions.sql
│   ├── 05_stored_procedures.sql
│   ├── 06_triggers.sql
│   ├── 07_security.sql
│   ├── 08_backup_procedure.sql
│   └── 09_test_queries.sql
└── venv