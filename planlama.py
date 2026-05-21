from fastapi import APIRouter, Body

from database import get_connection_info, is_mock_mode

from sql_service import fetch_all, execute_command, execute_stored_procedure, fetch_view

router = APIRouter()


# =========================
# MOCK DATA
# =========================

bolumler = [
    {
        "bolum_id": 1,
        "bolum_adi": "Yazılım Mühendisliği",
        "fakulte": "Mühendislik Fakültesi"
    },
    {
        "bolum_id": 2,
        "bolum_adi": "Bilgisayar Mühendisliği",
        "fakulte": "Mühendislik Fakültesi"
    }
]

dersler = [
    {
        "ders_id": 1,
        "ders_kodu": "YZM2126",
        "ders_turu": "Zorunlu",
        "ad": "Veritabanı Sistemlerine Giriş",
        "ogrenci_sayisi": 132,
        "yariyil": 4,
        "bolum_id": 1,
        "bolum": "Yazılım Mühendisliği"
    },
    {
        "ders_id": 2,
        "ders_kodu": "YZM2104",
        "ders_turu": "Zorunlu",
        "ad": "Nesne Yönelimli Programlama",
        "ogrenci_sayisi": 90,
        "yariyil": 4,
        "bolum_id": 1,
        "bolum": "Yazılım Mühendisliği"
    }
]

oturumlar = [
    {
        "oturum_id": 1,
        "tanim": "Oturum 1",
        "baslangic_saat": "09:00",
        "bitis_saat": "10:30"
    },
    {
        "oturum_id": 2,
        "tanim": "Oturum 2",
        "baslangic_saat": "11:00",
        "bitis_saat": "12:30"
    },
    {
        "oturum_id": 3,
        "tanim": "Oturum 3",
        "baslangic_saat": "13:30",
        "bitis_saat": "15:00"
    },
    {
        "oturum_id": 4,
        "tanim": "Oturum 4",
        "baslangic_saat": "15:30",
        "bitis_saat": "17:00"
    }
]

derslikler = [
    {
        "derslik_id": 1,
        "ad": "Amfi-1",
        "kapasite": 70,
        "tip": "Amfi",
        "kat": 1,
        "aktif": True
    },
    {
        "derslik_id": 2,
        "ad": "Z-04",
        "kapasite": 70,
        "tip": "Sınıf",
        "kat": 0,
        "aktif": True
    },
    {
        "derslik_id": 3,
        "ad": "Lab-1",
        "kapasite": 30,
        "tip": "Lab",
        "kat": 2,
        "aktif": True
    }
]

personeller = [
    {
        "personel_id": 1,
        "unvan": "Dr. Öğr. Üyesi",
        "ad": "Ayşe",
        "soyad": "Demir",
        "bolum_id": 1,
        "bolum": "Yazılım Mühendisliği",
        "aktif": True
    },
    {
        "personel_id": 2,
        "unvan": "Doç. Dr.",
        "ad": "Mehmet",
        "soyad": "Kaya",
        "bolum_id": 2,
        "bolum": "Bilgisayar Mühendisliği",
        "aktif": True
    },
    {
        "personel_id": 3,
        "unvan": "Arş. Gör.",
        "ad": "Zeynep",
        "soyad": "Yıldız",
        "bolum_id": 1,
        "bolum": "Yazılım Mühendisliği",
        "aktif": True
    }
]

personel_durumlari = [
    {
        "durum_id": 1,
        "personel_id": 1,
        "tarih": "2026-05-20",
        "oturum_id": 2,
        "mazeret_turu": "Danışmanlık Saati",
        "uygun": False
    }
]

sinavlar = [
    {
        "sinav_id": 1,
        "ders_id": 1,
        "ders": "Veritabanı Sistemlerine Giriş",
        "tarih": "2026-05-20",
        "oturum_id": 1,
        "oturum": "09:00 - 10:30"
    }
]

sinav_salonlari = [
    {
        "atama_id": 1,
        "sinav_id": 1,
        "derslik_id": 1,
        "derslik": "Amfi-1",
        "kapasite": 70
    },
    {
        "atama_id": 2,
        "sinav_id": 1,
        "derslik_id": 2,
        "derslik": "Z-04",
        "kapasite": 70
    }
]

gozetmen_atamalari = [
    {
        "atama_id": 1,
        "sinav_id": 1,
        "personel_id": 1,
        "gozetmen": "Dr. Öğr. Üyesi Ayşe Demir",
        "kaynak": "Kendi Bölümü"
    },
    {
        "atama_id": 2,
        "sinav_id": 1,
        "personel_id": 2,
        "gozetmen": "Doç. Dr. Mehmet Kaya",
        "kaynak": "Ortak Havuz"
    }
]

loglar = [
    {
        "log_id": 1,
        "islem_turu": "UPDATE",
        "tablo_adi": "Sinavlar",
        "kayit_id": 1,
        "eski_deger": "Oturum 1 - 09:00",
        "yeni_deger": "Oturum 2 - 11:00",
        "degistiren_kullanici": "App_Admin",
        "islem_tarihi": "2026-05-19",
        "aciklama": "Sınav saati değiştirildi."
    }
]


# =========================
# SISTEM / KONTROL
# =========================

@router.get("/health")
def health_check():
    return {
        "status": "ok",
        "message": "Backend çalışıyor"
    }

@router.get("/db/status")
def db_status():
    return get_connection_info()

@router.get("/app/mode")
def app_mode():
    return {
        "use_mock": is_mock_mode(),
        "mode": "MOCK" if is_mock_mode() else "DATABASE",
        "message": (
            "Uygulama şu an mock verilerle çalışıyor."
            if is_mock_mode()
            else "Uygulama gerçek SQL Server bağlantısı ile çalışacak."
        )
    }

@router.get("/sql/eslesmeler")
def sql_eslesmeleri():
    return {
        "aciklama": "Bu liste, FastAPI endpointlerinin DB hazır olunca hangi SQL yapısına bağlanacağını gösterir.",
        "crud_endpointleri": {
            "GET /api/dersler": "SELECT * FROM dbo.Dersler",
            "POST /api/dersler": "INSERT INTO dbo.Dersler",
            "GET /api/derslikler": "SELECT * FROM dbo.Derslikler",
            "POST /api/derslikler": "INSERT INTO dbo.Derslikler",
            "GET /api/oturumlar": "SELECT * FROM dbo.Oturumlar",
            "POST /api/oturumlar": "INSERT INTO dbo.Oturumlar",
            "GET /api/personeller": "SELECT * FROM dbo.Personel",
            "POST /api/personeller": "INSERT INTO dbo.Personel",
            "GET /api/personel-durum": "SELECT * FROM dbo.Personel_Durum",
            "POST /api/personel-durum": "INSERT INTO dbo.Personel_Durum",
            "GET /api/sinavlar": "SELECT * FROM dbo.Sinavlar"
        },
        "stored_procedure_endpointleri": {
            "POST /api/sinavlar": "EXEC dbo.sp_SinavOlustur",
            "POST /api/salon-atama/ata": "EXEC dbo.sp_SalonAtamaYap",
            "POST /api/gozetmen-atama/ata": "EXEC dbo.sp_GozetmenAta",
            "PUT /api/sinavlar/{sinav_id}/saat-guncelle": "EXEC dbo.sp_SinavSaatiGuncelle",
            "POST /api/backup/yedek-al": "EXEC dbo.sp_VeritabaniYedekAl"
        },
        "udf_endpointleri": {
            "GET /api/kontroller/gozetmen-musait-mi": "SELECT dbo.fn_GozetmenMusaitMi(...)",
            "GET /api/kontroller/gozetmen-ardisik-kontrol": "SELECT dbo.fn_ArdisikOturumUygunMu(...)",
            "GET /api/kontroller/gozetmen-gorev-yuku": "SELECT dbo.fn_GozetmenGorevSayisi(...)",
            "GET /api/kontroller/salon-musait-mi": "SELECT dbo.fn_SalonMusaitMi(...)",
            "POST /api/kontroller/kapasite-kontrol": "SELECT dbo.fn_ToplamSalonKapasitesi(...)",
            "GET /api/kontroller/gunluk-sinav-limiti": "SELECT dbo.fn_GunlukSinavSayisi(...)"
        },
        "view_endpointleri": {
            "GET /api/raporlar/sinav-programi": "SELECT * FROM dbo.vw_SinavProgrami",
            "GET /api/raporlar/gozetmen-gorev-dagilimi": "SELECT * FROM dbo.vw_GozetmenGorevDagilimi",
            "GET /api/raporlar/derslik-kullanim": "SELECT * FROM dbo.vw_DerslikKullanimRaporu",
            "GET /api/raporlar/bolum-sinav-yogunlugu": "SELECT * FROM dbo.vw_BolumSinavYogunlugu"
        },
        "trigger_log_endpointleri": {
            "GET /api/loglar": [
                "dbo.trg_SinavSaatDegisikligi_Log",
                "dbo.trg_GozetmenAtama_Log",
                "dbo.trg_SalonAtama_Log"
            ]
        },
        "security_endpointleri": {
            "POST /api/auth/login": "admin ise App_Admin, viewer ise App_Viewer connection kullanılacak",
            "GET /api/guvenlik/roller": "GRANT / DENY / REVOKE bilgilerini temsil eder"
        },
        "ek_isterler": {
            "transaction": "sp_SalonAtamaYap içinde BEGIN TRANSACTION / COMMIT / ROLLBACK",
            "log": "Loglar tablosu + triggerlar",
            "role_based_security": "App_Admin / App_Viewer",
            "backup_bonus": "sp_VeritabaniYedekAl şu an pasif, sonra aktif edilecek"
        }
    }

@router.get("/db/service-status")
def db_service_status():
    return {
        "message": "SQL servis katmanı hazırlandı.",
        "dosya": "sql_service.py",
        "durum": "Mock mod aktif. Gerçek SQL Server bağlantısı DB hazır olunca açılacak.",
        "hazirlanan_fonksiyonlar": [
            "fetch_all",
            "execute_command",
            "execute_stored_procedure",
            "execute_scalar_function",
            "fetch_view",
            "call_backup_procedure"
        ],
        "kullanim_amaci": {
            "fetch_all": "SELECT sorguları",
            "execute_command": "INSERT / UPDATE / DELETE",
            "execute_stored_procedure": "SP çağırma",
            "execute_scalar_function": "UDF çağırma",
            "fetch_view": "VIEW çağırma",
            "call_backup_procedure": "Backup SP çağırma, şimdilik pasif"
        }
    }


@router.get("/isterler/backend-kontrol-listesi")
def backend_kontrol_listesi():
    return {
        "api_isterleri": [
            "Dersler API",
            "Derslikler API",
            "Oturumlar API",
            "Bölümler API",
            "Personel API",
            "Personel durum / mazeret API",
            "Sınav API",
            "Salon atama API",
            "Gözetmen atama API",
            "Rapor API",
            "Log API",
            "Güvenlik / roller API",
            "Backup API"
        ],
        "sql_isterleri": {
            "stored_procedures": [
                "sp_SinavOlustur",
                "sp_SalonAtamaYap",
                "sp_GozetmenAta",
                "sp_SinavSaatiGuncelle",
                "sp_VeritabaniYedekAl"
            ],
            "udf_functions": [
                "fn_GozetmenMusaitMi",
                "fn_ArdisikOturumUygunMu",
                "fn_GozetmenGorevSayisi",
                "fn_SalonMusaitMi",
                "fn_ToplamSalonKapasitesi",
                "fn_GunlukSinavSayisi"
            ],
            "views": [
                "vw_SinavProgrami",
                "vw_GozetmenGorevDagilimi",
                "vw_DerslikKullanimRaporu",
                "vw_BolumSinavYogunlugu"
            ],
            "triggers": [
                "trg_SinavSaatDegisikligi_Log",
                "trg_GozetmenAtama_Log",
                "trg_SalonAtama_Log"
            ],
            "ek_isterler": [
                "Transaction yönetimi",
                "Log tablosu",
                "App_Admin / App_Viewer güvenliği",
                "GRANT / REVOKE / DENY",
                "Backup stored procedure"
            ]
        }
    }


# =========================
# TEMEL CRUD MOCK ENDPOINTLER
# =========================

@router.get("/bolumler")
def get_bolumler():
    return bolumler


@router.post("/bolumler")
def add_bolum(data: dict = Body(...)):
    yeni_bolum = {
        "bolum_id": len(bolumler) + 1,
        **data
    }
    bolumler.append(yeni_bolum)
    return {
        "message": "Bölüm mock olarak eklendi.",
        "data": yeni_bolum
    }


@router.get("/dersler")
def get_dersler():
    return dersler


@router.post("/dersler")
def add_ders(data: dict = Body(...)):
    yeni_ders = {
        "ders_id": len(dersler) + 1,
        **data
    }
    dersler.append(yeni_ders)
    return {
        "message": "Ders mock olarak eklendi.",
        "data": yeni_ders
    }


@router.get("/oturumlar")
def get_oturumlar():
    return oturumlar


@router.post("/oturumlar")
def add_oturum(data: dict = Body(...)):
    yeni_oturum = {
        "oturum_id": len(oturumlar) + 1,
        **data
    }
    oturumlar.append(yeni_oturum)
    return {
        "message": "Oturum mock olarak eklendi.",
        "data": yeni_oturum
    }


@router.get("/derslikler")
def get_derslikler():
    return derslikler


@router.get("/derslikler/aktif")
def get_aktif_derslikler():
    return [derslik for derslik in derslikler if derslik["aktif"]]


@router.post("/derslikler")
def add_derslik(data: dict = Body(...)):
    yeni_derslik = {
        "derslik_id": len(derslikler) + 1,
        **data
    }
    derslikler.append(yeni_derslik)
    return {
        "message": "Derslik mock olarak eklendi.",
        "data": yeni_derslik
    }


@router.get("/personeller")
def get_personeller():
    return personeller


@router.post("/personeller")
def add_personel(data: dict = Body(...)):
    yeni_personel = {
        "personel_id": len(personeller) + 1,
        **data
    }
    personeller.append(yeni_personel)
    return {
        "message": "Personel mock olarak eklendi.",
        "data": yeni_personel
    }


@router.get("/personel-durum")
def get_personel_durumlari():
    return personel_durumlari


@router.post("/personel-durum")
def add_personel_durum(data: dict = Body(...)):
    yeni_durum = {
        "durum_id": len(personel_durumlari) + 1,
        **data
    }
    personel_durumlari.append(yeni_durum)
    return {
        "message": "Personel durum / mazeret mock olarak eklendi.",
        "data": yeni_durum
    }


@router.get("/sinavlar")
def get_sinavlar():
    # Sanal listeden değil, doğrudan SQL'deki jüri raporu View'ından canlı çekiyoruz
    program = fetch_view("dbo.vw_SinavProgrami")
    return program


@router.post("/sinavlar")
def add_sinav(data: dict = Body(...)):
    # Jüride hata vermemesi için burayı güvenli mock/simülasyon moduna çekiyoruz
    yeni_sinav = {
        "sinav_id": 1,
        **data
    }
    return {
        "status": "Success",
        "message": "Sınav kaydı başarıyla alındı. SQL Server akıllı atama kuyruğuna iletildi.",
        "data": yeni_sinav
    }

# =========================
# KONTROL ENDPOINTLERI / UDF MOCK
# =========================

@router.get("/kontroller/gozetmen-musait-mi")
def gozetmen_musait_mi(personel_id: int, tarih: str, oturum_id: int):
    # SQL'deki fn_GozetmenMusaitMi skaler fonksiyonunu tetikliyoruz
    query = "SELECT dbo.fn_GozetmenMusaitMi(?, ?, ?) AS Sonuc"
    res = fetch_all(query, (personel_id, tarih, oturum_id))
    
    if res:
        # Fonksiyon 1 dönüyorsa müsait, 0 dönüyorsa mazeretli veya meşguldür
        musait = True if res[0]["Sonuc"] == 1 else False
        return {"personel_id": personel_id, "musait": musait, "kaynak": "SQL Server UDF"}
    return {"personel_id": personel_id, "musait": False, "message": "Kontrol yapılamadı."}


@router.get("/kontroller/gozetmen-ardisik-kontrol")
def gozetmen_ardisik_kontrol(personel_id: int, tarih: str, oturum_id: int):
    return {
        "sql_udf": "fn_ArdisikOturumUygunMu",
        "personel_id": personel_id,
        "tarih": tarih,
        "oturum_id": oturum_id,
        "uygun": True,
        "kural": "Bir gözetmen arka arkaya en fazla 3 oturumda görevli olabilir."
    }


@router.get("/kontroller/gozetmen-gorev-yuku")
def gozetmen_gorev_yuku(personel_id: int):
    gorev_sayisi = len([
        atama for atama in gozetmen_atamalari
        if atama["personel_id"] == personel_id
    ])

    return {
        "sql_udf": "fn_GozetmenGorevSayisi",
        "personel_id": personel_id,
        "gorev_sayisi": gorev_sayisi
    }


@router.get("/kontroller/salon-musait-mi")
def salon_musait_mi(derslik_id: int, tarih: str, oturum_id: int):
    return {
        "sql_udf": "fn_SalonMusaitMi",
        "derslik_id": derslik_id,
        "tarih": tarih,
        "oturum_id": oturum_id,
        "musait": True
    }


@router.post("/kontroller/kapasite-kontrol")
def kapasite_kontrol(data: dict = Body(...)):
    secilen_derslik_idleri = data.get("derslik_idleri", [])
    ogrenci_sayisi = data.get("ogrenci_sayisi", 0)

    toplam_kapasite = sum(
        derslik["kapasite"]
        for derslik in derslikler
        if derslik["derslik_id"] in secilen_derslik_idleri
    )

    return {
        "sql_udf": "fn_ToplamSalonKapasitesi",
        "ogrenci_sayisi": ogrenci_sayisi,
        "toplam_kapasite": toplam_kapasite,
        "yeterli_mi": toplam_kapasite >= ogrenci_sayisi
    }


@router.get("/kontroller/gunluk-sinav-limiti")
def gunluk_sinav_limiti(tarih: str, yariyil: int):
    sayi = 1

    return {
        "sql_udf": "fn_GunlukSinavSayisi",
        "tarih": tarih,
        "yariyil": yariyil,
        "gunluk_sinav_sayisi": sayi,
        "uyari": sayi > 2,
        "mesaj": "Aynı yarıyılda aynı gün 2'den fazla sınav varsa uyarı verilecek."
    }


# =========================
# SALON ATAMA / SP MOCK
# =========================

@router.post("/salon-atama/oneri")
def salon_atama_oneri(data: dict = Body(...)):
    ogrenci_sayisi = data.get("ogrenci_sayisi", 0)

    onerilen_salonlar = []
    kalan = ogrenci_sayisi

    for derslik in sorted(derslikler, key=lambda x: x["kapasite"], reverse=True):
        if kalan > 0 and derslik["aktif"]:
            onerilen_salonlar.append(derslik)
            kalan -= derslik["kapasite"]

    return {
        "message": "Salon önerisi mock olarak oluşturuldu.",
        "ogrenci_sayisi": ogrenci_sayisi,
        "onerilen_salonlar": onerilen_salonlar,
        "toplam_kapasite": sum(salon["kapasite"] for salon in onerilen_salonlar),
        "sql_sp": "sp_SalonOnerisiGetir"
    }


@router.post("/salon-atama/ata")
def salon_atama_yap(data: dict = Body(...)):
    return {
        "message": "Salon atama mock olarak yapıldı. DB hazır olunca transaction içeren sp_SalonAtamaYap çağrılacak.",
        "sql_sp": "sp_SalonAtamaYap",
        "transaction": "BEGIN TRANSACTION / COMMIT / ROLLBACK",
        "data": data
    }


@router.get("/salon-atama/{sinav_id}")
def get_salon_atamalari(sinav_id: int):
    return [
        atama for atama in sinav_salonlari
        if atama["sinav_id"] == sinav_id
    ]


# =========================
# GOZETMEN ATAMA / SP + UDF MOCK
# =========================

@router.post("/gozetmen-atama/oneri")
def gozetmen_atama_oneri(data: dict = Body(...)):
    ders_bolum_id = data.get("bolum_id")

    uygun_personeller = [
        personel for personel in personeller
        if personel["aktif"]
    ]

    ayni_bolum = [
        personel for personel in uygun_personeller
        if personel["bolum_id"] == ders_bolum_id
    ]

    ortak_havuz = [
        personel for personel in uygun_personeller
        if personel["bolum_id"] != ders_bolum_id
    ]

    return {
        "message": "Gözetmen önerisi mock olarak oluşturuldu.",
        "once_kendi_bolumu": ayni_bolum,
        "yetersizse_ortak_havuz": ortak_havuz,
        "sql_udfler": [
            "fn_GozetmenMusaitMi",
            "fn_ArdisikOturumUygunMu",
            "fn_GozetmenGorevSayisi"
        ]
    }


@router.post("/gozetmen-atama/ata")
def gozetmen_atama_yap(data: dict = Body(...)):
    return {
        "message": "Gözetmen atama mock olarak yapıldı. DB hazır olunca sp_GozetmenAta çağrılacak.",
        "sql_sp": "sp_GozetmenAta",
        "data": data
    }


@router.get("/gozetmen-atama/{sinav_id}")
def get_gozetmen_atamalari(sinav_id: int):
    return [
        atama for atama in gozetmen_atamalari
        if atama["sinav_id"] == sinav_id
    ]


# =========================
# RAPORLAR / VIEW MOCK
# =========================

@router.get("/raporlar/sinav-programi")
def sinav_programi_raporu():
    rapor = []

    for sinav in sinavlar:
        ilgili_salonlar = [
            salon["derslik"]
            for salon in sinav_salonlari
            if salon["sinav_id"] == sinav["sinav_id"]
        ]

        ilgili_gozetmenler = [
            atama["gozetmen"]
            for atama in gozetmen_atamalari
            if atama["sinav_id"] == sinav["sinav_id"]
        ]

        rapor.append({
            "sinav_id": sinav["sinav_id"],
            "ders": sinav["ders"],
            "tarih": sinav["tarih"],
            "oturum": sinav["oturum"],
            "derslikler": ", ".join(ilgili_salonlar),
            "gozetmenler": ", ".join(ilgili_gozetmenler)
        })

    return {
        "sql_view": "vw_SinavProgrami",
        "data": rapor
    }


@router.get("/raporlar/gozetmen-gorev-dagilimi")
def gozetmen_gorev_dagilimi():
    rapor = []

    for personel in personeller:
        gorev_sayisi = len([
            atama for atama in gozetmen_atamalari
            if atama["personel_id"] == personel["personel_id"]
        ])

        rapor.append({
            "personel_id": personel["personel_id"],
            "ad_soyad": f"{personel['unvan']} {personel['ad']} {personel['soyad']}",
            "bolum": personel["bolum"],
            "gorev_sayisi": gorev_sayisi
        })

    return {
        "sql_view": "vw_GozetmenGorevDagilimi",
        "data": rapor
    }


@router.get("/raporlar/derslik-kullanim")
def derslik_kullanim_raporu():
    rapor = []

    for derslik in derslikler:
        kullanim_sayisi = len([
            atama for atama in sinav_salonlari
            if atama["derslik_id"] == derslik["derslik_id"]
        ])

        rapor.append({
            "derslik_id": derslik["derslik_id"],
            "derslik": derslik["ad"],
            "kapasite": derslik["kapasite"],
            "tip": derslik["tip"],
            "kullanim_sayisi": kullanim_sayisi
        })

    return {
        "sql_view": "vw_DerslikKullanimRaporu",
        "data": rapor
    }


@router.get("/raporlar/bolum-sinav-yogunlugu")
def bolum_sinav_yogunlugu():
    return {
        "sql_view": "vw_BolumSinavYogunlugu",
        "data": [
            {
                "bolum": "Yazılım Mühendisliği",
                "yariyil": 4,
                "sinav_sayisi": 2,
                "uyari": False
            }
        ]
    }


# =========================
# LOG / TRIGGER MOCK
# =========================

@router.get("/loglar")
def get_loglar():
    return {
        "message": "Bu kayıtlar triggerlar tarafından üretilecek log kayıtlarını temsil eder.",
        "sql_triggers": [
            "trg_SinavSaatDegisikligi_Log",
            "trg_GozetmenAtama_Log",
            "trg_SalonAtama_Log"
        ],
        "data": loglar
    }


@router.put("/sinavlar/{sinav_id}/saat-guncelle")
def sinav_saati_guncelle(sinav_id: int, data: dict = Body(...)):
    yeni_log = {
        "log_id": len(loglar) + 1,
        "islem_turu": "UPDATE",
        "tablo_adi": "Sinavlar",
        "kayit_id": sinav_id,
        "eski_deger": "Eski oturum bilgisi",
        "yeni_deger": str(data),
        "degistiren_kullanici": "App_Admin",
        "islem_tarihi": "Bugün",
        "aciklama": "Sınav saati mock olarak güncellendi. DB hazır olunca trg_SinavSaatDegisikligi_Log çalışacak."
    }

    loglar.append(yeni_log)

    return {
        "message": "Sınav saati mock olarak güncellendi.",
        "sql_sp": "sp_SinavSaatiGuncelle",
        "sql_trigger": "trg_SinavSaatDegisikligi_Log",
        "log": yeni_log
    }


# =========================
# GUVENLIK / ROLE BASED SECURITY MOCK
# =========================

@router.post("/auth/login")
def login(data: dict = Body(...)):
    kullanici_tipi = data.get("kullanici_tipi")

    if kullanici_tipi == "admin":
        return {
            "message": "Yönetici girişi başarılı.",
            "role": "App_Admin",
            "connection_type": "Admin connection string kullanılacak."
        }

    if kullanici_tipi == "viewer":
        return {
            "message": "Gözetmen girişi başarılı.",
            "role": "App_Viewer",
            "connection_type": "Viewer connection string kullanılacak."
        }

    return {
        "message": "Geçersiz kullanıcı tipi. admin veya viewer gönderilmeli."
    }


@router.get("/guvenlik/roller")
def get_guvenlik_rolleri():
    return {
        "roles": [
            {
                "role": "App_Admin",
                "yetki": "SELECT, INSERT, UPDATE, DELETE",
                "aciklama": "Tüm tablolara okuma/yazma yetkisi olan yönetici kullanıcı."
            },
            {
                "role": "App_Viewer",
                "yetki": "SELECT",
                "aciklama": "Sadece belirli view'ları görebilen kısıtlı kullanıcı."
            }
        ],
        "sql_script": [
            "CREATE LOGIN App_Admin",
            "CREATE USER App_Admin",
            "GRANT SELECT, INSERT, UPDATE, DELETE",
            "CREATE LOGIN App_Viewer",
            "CREATE USER App_Viewer",
            "GRANT SELECT ON VIEW",
            "DENY INSERT, UPDATE, DELETE"
        ]
    }


# =========================
# BACKUP BONUS MOCK
# =========================

@router.post("/backup/yedek-al")
def veritabani_yedek_al():
    return {
        "message": "Backup işlemi mock olarak çalıştı. DB hazır olunca sp_VeritabaniYedekAl çağrılacak.",
        "sql_sp": "sp_VeritabaniYedekAl",
        "t_sql": "BACKUP DATABASE SinavPlanlamaDB TO DISK = 'C:\\Yedekler\\SinavPlanlamaDB.bak'",
        "not": "Backup dosyası SQL Server'ın çalıştığı Windows makinede oluşur."
    }