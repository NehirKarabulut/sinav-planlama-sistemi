-- ========================================================
-- ONCE TEMIZLIK 
-- ========================================================
DELETE FROM dbo.Loglar;
DELETE FROM dbo.Gozetmen_Atamalari;
DELETE FROM dbo.Sinav_Salonlari;
DELETE FROM dbo.Sinavlar;
DELETE FROM dbo.Personel_Durum;
DELETE FROM dbo.Personel;
DELETE FROM dbo.Dersler;
DELETE FROM dbo.Derslikler;
DELETE FROM dbo.Bolumler;
DELETE FROM dbo.Oturumlar;


-- ========================================================
-- 1. RESMI OTURUMLAR
-- ========================================================
SET IDENTITY_INSERT dbo.Oturumlar ON;

INSERT INTO dbo.Oturumlar (OturumID, Tanim, BaslangicSaat, BitisSaat) VALUES 
(1, N'Sabah-1', '09:00', '10:00'),
(2, N'Sabah-2', '10:30', '11:30'),
(3, N'Öğle', '12:00', '13:00'),
(4, N'Öğleden Sonra-1', '13:45', '14:45'),
(5, N'Öğleden Sonra-2', '15:15', '16:30');

SET IDENTITY_INSERT dbo.Oturumlar OFF;


-- ========================================================
-- 2. RESMI DERSLIKLER VE KONTENJANLARI
-- ========================================================
SET IDENTITY_INSERT dbo.Derslikler ON;

INSERT INTO dbo.Derslikler (DerslikID, Ad, Kapasite, Tip, Aktif) VALUES 
-- Kucuk Siniflar (Sinav Kontenjani: 36)
(1, '205', 36, N'Sınıf', 1), (2, '206', 36, N'Sınıf', 1), (3, '207', 36, N'Sınıf', 1), (4, '208', 36, N'Sınıf', 1),
(5, '305', 36, N'Sınıf', 1), (6, '306', 36, N'Sınıf', 1), (7, '307', 36, N'Sınıf', 1), (8, '308', 36, N'Sınıf', 1),
-- Orta Siniflar
(9, '309', 40, N'Sınıf', 1),
(10, '311', 50, N'Sınıf', 1),
-- Buyuk Siniflar (Sinav Kontenjani: 60) 
(11, '209', 60, N'Amfi', 1), (12, '210', 60, N'Amfi', 1), (13, '310', 60, N'Amfi', 1), (14, '409', 60, N'Amfi', 1), (15, '410', 60, N'Amfi', 1);

SET IDENTITY_INSERT dbo.Derslikler OFF;


-- ========================================================
-- 3. RESMI BES MUHENDISLIK BOLUMU
-- ========================================================
SET IDENTITY_INSERT dbo.Bolumler ON;

INSERT INTO dbo.Bolumler (BolumID, BolumAdi, Fakulte) VALUES 
(1, N'Yazılım Mühendisliği', N'Mühendislik Fakültesi'),
(2, N'Elektrik Mühendisliği', N'Mühendislik Fakültesi'),
(3, N'Makine Mühendisliği', N'Mühendislik Fakültesi'),
(4, N'Mekatronik Mühendisliği', N'Mühendislik Fakültesi'),
(5, N'Enerji Sistemleri Mühendisliği', N'Mühendislik Fakültesi');

SET IDENTITY_INSERT dbo.Bolumler OFF;


-- ========================================================
-- 4. AKILLI ALGORITMA TESTLERI ICIN DERSLER (KONTENJAN SENARYOLARI)
-- ========================================================
SET IDENTITY_INSERT dbo.Dersler ON;

INSERT INTO dbo.Dersler (DersID, DersKodu, Ad, OgrenciSayisi, Yariyil, BolumID, DersTuru) VALUES 
-- Yazilim Muhendisligi Dersleri
(1, 'YZM2126', N'Veritabanı Sistemleri', 150, 4, 1, N'Zorunlu'), -- 150 kisi (Salon birlestirme ve Havuz testi icin)
(2, 'YZM1002', N'Programlama II', 60, 2, 1, N'Zorunlu'),       -- Kucuk sinif senaryosu (Kontenjan: 60)
(3, 'YZM3001', N'Yazılım Mimarisi', 80, 6, 1, N'Zorunlu'),     -- 309 nolu sinif senaryosu (Kontenjan: 80)
-- Diger bolumlerden havuz testi icin ornek dersler
(4, 'EEM2001', N'Devre Analizi', 50, 4, 2, N'Zorunlu'),        -- 311 nolu sinif senaryosu (Kontenjan: 50)
(5, 'MAK3002', N'Akışkanlar Mekaniği', 60, 6, 3, N'Zorunlu');

SET IDENTITY_INSERT dbo.Dersler OFF;


-- ========================================================
-- 5. ORTAK HAVUZU TETIKLEYECEK AKADEMIK PERSONEL (GOZETMENLER)
-- ========================================================
SET IDENTITY_INSERT dbo.Personel ON;

INSERT INTO dbo.Personel (PersonelID, Unvan, Ad, Soyad, BolumID) VALUES 
-- Yazilim Muhendisligi
(1, N'Dr. Öğr. Üyesi', N'Ayşe', N'Demir', 1),
(2, N'Arş. Gör.', N'Can', N'Yılmaz', 1),
-- Elektrik Muhendisligi Hocalari
(3, N'Doc. Dr.', N'Mehmet', N'Kaya', 2),
(4, N'Arş. Gör.', N'Elif', N'Yıldız', 2),
-- Makine Muhendisligi Hocalari
(5, N'Prof. Dr.', N'Ahmet', N'Şahin', 3),
(6, N'Arş. Gör.', N'Mustafa', N'Aydın', 3);

SET IDENTITY_INSERT dbo.Personel OFF;


-- ========================================================
-- 6. "IZINLI" KURALI TEST ETMEK ICIN MAZERET KAYDI
-- ========================================================
-- Can Yilmaz, 2026-06-01 tarihindeki 2. Oturumda (Sabah-2) izinli.
SET IDENTITY_INSERT dbo.Personel_Durum ON;

INSERT INTO dbo.Personel_Durum (DurumID, PersonelID, Tarih, OturumID, Uygun, MazeretTuru) VALUES
(1, 2, '2026-06-01', 2, 0, N'İzinli / Mazeretli');

SET IDENTITY_INSERT dbo.Personel_Durum OFF;


-- ========================================================
-- 7. PLANLANMAYI BEKLEYEN RESMI SINAV KAYITLARI
-- ========================================================
-- Backend'den (Swagger) tetikleyecegimiz sinav havuzunu buraya ekledik.
SET IDENTITY_INSERT dbo.Sinavlar ON;

INSERT INTO dbo.Sinavlar (SinavID, DersID, Tarih, OturumID) VALUES 
(1, 1, '2026-06-01', 2); -- 1 nolu Veritabani sinav, 2026-06-01 tarihinde, Sabah-2 oturumunda

SET IDENTITY_INSERT dbo.Sinavlar OFF;

-- ===================================================================
-- 8. CANLI SINAV VE HOCA ATAMALARI 
-- ===================================================================

-- Önce eksik olan Hakan Yurt ve Merve Aslan hocaları Personel tablosuna ekliyoruz
SET IDENTITY_INSERT dbo.Personel ON;

INSERT INTO dbo.Personel (PersonelID, Unvan, Ad, Soyad, BolumID) VALUES 
(7, N'Arş. Gör.', N'Hakan', N'Yurt', 1),  -- Yazılım Mühendisliği (ID:1)
(8, N'Arş. Gör.', N'Merve', N'Aslan', 1); -- Yazılım Mühendisliği (ID:1)

SET IDENTITY_INSERT dbo.Personel OFF;


-- Şimdi 1 nolu sınava (Veritabanı) 209 ve 210 nolu Amfileri bağlıyoruz
SET IDENTITY_INSERT dbo.Sinav_Salonlari ON;

INSERT INTO dbo.Sinav_Salonlari (SinavSalonID, SinavID, DerslikID) VALUES
(1, 1, 11), -- 1 nolu sınava 209 nolu Amfi (DerslikID:11) atandı
(2, 1, 12); -- 1 nolu sınava 210 nolu Amfi (DerslikID:12) atandı

SET IDENTITY_INSERT dbo.Sinav_Salonlari OFF;


-- Son olarak Hakan ve Merve Hocaları bu amfilere görevli olarak yazıyoruz
SET IDENTITY_INSERT dbo.Gozetmen_Atamalari ON;

INSERT INTO dbo.Gozetmen_Atamalari (GozetmenAtamaID, SinavSalonID, PersonelID, AtamaKaynak) VALUES
(1, 1, 7, N'Kendi Bölümü'), -- Hakan Yurt (ID:7) -> 1 nolu salona (Amfi 209)
(2, 2, 8, N'Kendi Bölümü'); -- Merve Aslan (ID:8) -> 2 nolu salona (Amfi 210)

SET IDENTITY_INSERT dbo.Gozetmen_Atamalari OFF;