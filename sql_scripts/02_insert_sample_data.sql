/* test için örnek veri */

/* bölümler*/
IF NOT EXISTS (SELECT 1 FROM dbo.Bolumler WHERE BolumAdi = N'Yazılım Mühendisliği')
BEGIN
    INSERT INTO dbo.Bolumler (BolumAdi, Fakulte)
    VALUES (N'Yazılım Mühendisliği', N'Mühendislik Fakültesi');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Bolumler WHERE BolumAdi = N'Bilgisayar Mühendisliği')
BEGIN
    INSERT INTO dbo.Bolumler (BolumAdi, Fakulte)
    VALUES (N'Bilgisayar Mühendisliği', N'Mühendislik Fakültesi');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Bolumler WHERE BolumAdi = N'Elektrik-Elektronik Mühendisliği')
BEGIN
    INSERT INTO dbo.Bolumler (BolumAdi, Fakulte)
    VALUES (N'Elektrik-Elektronik Mühendisliği', N'Mühendislik Fakültesi');
END
GO

/* oturumlar */
IF NOT EXISTS (SELECT 1 FROM dbo.Oturumlar WHERE Tanim = N'Oturum 1')
BEGIN
    INSERT INTO dbo.Oturumlar (Tanim, BaslangicSaat, BitisSaat)
    VALUES (N'Oturum 1', '09:00', '10:30');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Oturumlar WHERE Tanim = N'Oturum 2')
BEGIN
    INSERT INTO dbo.Oturumlar (Tanim, BaslangicSaat, BitisSaat)
    VALUES (N'Oturum 2', '11:00', '12:30');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Oturumlar WHERE Tanim = N'Oturum 3')
BEGIN
    INSERT INTO dbo.Oturumlar (Tanim, BaslangicSaat, BitisSaat)
    VALUES (N'Oturum 3', '13:30', '15:00');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Oturumlar WHERE Tanim = N'Oturum 4')
BEGIN
    INSERT INTO dbo.Oturumlar (Tanim, BaslangicSaat, BitisSaat)
    VALUES (N'Oturum 4', '15:30', '17:00');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Oturumlar WHERE Tanim = N'Oturum 5')
BEGIN
    INSERT INTO dbo.Oturumlar (Tanim, BaslangicSaat, BitisSaat)
    VALUES (N'Oturum 5', '17:30', '19:00');
END
GO

/* derslikler*/
IF NOT EXISTS (SELECT 1 FROM dbo.Derslikler WHERE Ad = N'Amfi-1')
BEGIN
    INSERT INTO dbo.Derslikler (Ad, Kapasite, Tip, Kat, Aktif)
    VALUES (N'Amfi-1', 70, N'Amfi', 1, 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.Derslikler WHERE Ad = N'Z-04')
BEGIN
    INSERT INTO dbo.Derslikler (Ad, Kapasite, Tip, Kat, Aktif)
    VALUES (N'Z-04', 70, N'Sınıf', 0, 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.Derslikler WHERE Ad = N'Lab-1')
BEGIN
    INSERT INTO dbo.Derslikler (Ad, Kapasite, Tip, Kat, Aktif)
    VALUES (N'Lab-1', 30, N'Lab', 2, 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.Derslikler WHERE Ad = N'B-201')
BEGIN
    INSERT INTO dbo.Derslikler (Ad, Kapasite, Tip, Kat, Aktif)
    VALUES (N'B-201', 60, N'Sınıf', 2, 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.Derslikler WHERE Ad = N'C-101')
BEGIN
    INSERT INTO dbo.Derslikler (Ad, Kapasite, Tip, Kat, Aktif)
    VALUES (N'C-101', 45, N'Sınıf', 1, 1);
END
GO

/* dersler */
DECLARE @YazilimBolumID INT;
DECLARE @BilgisayarBolumID INT;
DECLARE @ElektrikBolumID INT;

SELECT @YazilimBolumID = BolumID 
FROM dbo.Bolumler 
WHERE BolumAdi = N'Yazılım Mühendisliği';

SELECT @BilgisayarBolumID = BolumID 
FROM dbo.Bolumler 
WHERE BolumAdi = N'Bilgisayar Mühendisliği';

SELECT @ElektrikBolumID = BolumID 
FROM dbo.Bolumler 
WHERE BolumAdi = N'Elektrik-Elektronik Mühendisliği';

IF NOT EXISTS (SELECT 1 FROM dbo.Dersler WHERE DersKodu = N'YZM2126')
BEGIN
    INSERT INTO dbo.Dersler 
    (DersKodu, DersTuru, Ad, OgrenciSayisi, Yariyil, BolumID)
    VALUES 
    (N'YZM2126', N'Zorunlu', N'Veritabanı Sistemlerine Giriş', 132, 4, @YazilimBolumID);
END

IF NOT EXISTS (SELECT 1 FROM dbo.Dersler WHERE DersKodu = N'YZM2104')
BEGIN
    INSERT INTO dbo.Dersler 
    (DersKodu, DersTuru, Ad, OgrenciSayisi, Yariyil, BolumID)
    VALUES 
    (N'YZM2104', N'Zorunlu', N'Nesne Yönelimli Programlama', 90, 4, @YazilimBolumID);
END

IF NOT EXISTS (SELECT 1 FROM dbo.Dersler WHERE DersKodu = N'YZM2202')
BEGIN
    INSERT INTO dbo.Dersler 
    (DersKodu, DersTuru, Ad, OgrenciSayisi, Yariyil, BolumID)
    VALUES 
    (N'YZM2202', N'Zorunlu', N'Algoritma ve Programlama', 110, 2, @YazilimBolumID);
END

IF NOT EXISTS (SELECT 1 FROM dbo.Dersler WHERE DersKodu = N'BLM2001')
BEGIN
    INSERT INTO dbo.Dersler 
    (DersKodu, DersTuru, Ad, OgrenciSayisi, Yariyil, BolumID)
    VALUES 
    (N'BLM2001', N'Zorunlu', N'Bilgisayar Mimarisi', 75, 4, @BilgisayarBolumID);
END

IF NOT EXISTS (SELECT 1 FROM dbo.Dersler WHERE DersKodu = N'EEM1001')
BEGIN
    INSERT INTO dbo.Dersler 
    (DersKodu, DersTuru, Ad, OgrenciSayisi, Yariyil, BolumID)
    VALUES 
    (N'EEM1001', N'Zorunlu', N'Elektrik Devreleri', 65, 2, @ElektrikBolumID);
END
GO

/* personel */
DECLARE @YazilimID INT;
DECLARE @BilgisayarID INT;
DECLARE @ElektrikID INT;

SELECT @YazilimID = BolumID 
FROM dbo.Bolumler 
WHERE BolumAdi = N'Yazılım Mühendisliği';

SELECT @BilgisayarID = BolumID 
FROM dbo.Bolumler 
WHERE BolumAdi = N'Bilgisayar Mühendisliği';

SELECT @ElektrikID = BolumID 
FROM dbo.Bolumler 
WHERE BolumAdi = N'Elektrik-Elektronik Mühendisliği';

IF NOT EXISTS (
    SELECT 1 FROM dbo.Personel 
    WHERE Ad = N'Ayşe' AND Soyad = N'Demir'
)
BEGIN
    INSERT INTO dbo.Personel (Unvan, Ad, Soyad, BolumID, Aktif)
    VALUES (N'Dr. Öğr. Üyesi', N'Ayşe', N'Demir', @YazilimID, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.Personel 
    WHERE Ad = N'Mehmet' AND Soyad = N'Kaya'
)
BEGIN
    INSERT INTO dbo.Personel (Unvan, Ad, Soyad, BolumID, Aktif)
    VALUES (N'Doç. Dr.', N'Mehmet', N'Kaya', @BilgisayarID, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.Personel 
    WHERE Ad = N'Zeynep' AND Soyad = N'Yıldız'
)
BEGIN
    INSERT INTO dbo.Personel (Unvan, Ad, Soyad, BolumID, Aktif)
    VALUES (N'Arş. Gör.', N'Zeynep', N'Yıldız', @YazilimID, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.Personel 
    WHERE Ad = N'Can' AND Soyad = N'Öztürk'
)
BEGIN
    INSERT INTO dbo.Personel (Unvan, Ad, Soyad, BolumID, Aktif)
    VALUES (N'Prof. Dr.', N'Can', N'Öztürk', @ElektrikID, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.Personel 
    WHERE Ad = N'Elif' AND Soyad = N'Aksoy'
)
BEGIN
    INSERT INTO dbo.Personel (Unvan, Ad, Soyad, BolumID, Aktif)
    VALUES (N'Dr. Öğr. Üyesi', N'Elif', N'Aksoy', @YazilimID, 1);
END
GO

/* personel durum */
DECLARE @AyseID INT;
DECLARE @Oturum2ID INT;

SELECT @AyseID = PersonelID
FROM dbo.Personel
WHERE Ad = N'Ayşe' AND Soyad = N'Demir';

SELECT @Oturum2ID = OturumID
FROM dbo.Oturumlar
WHERE Tanim = N'Oturum 2';

IF NOT EXISTS (
    SELECT 1 
    FROM dbo.Personel_Durum
    WHERE PersonelID = @AyseID
      AND Tarih = '2026-05-20'
      AND OturumID = @Oturum2ID
)
BEGIN
    INSERT INTO dbo.Personel_Durum
    (PersonelID, Tarih, OturumID, MazeretTuru, Uygun)
    VALUES
    (@AyseID, '2026-05-20', @Oturum2ID, N'Danışmanlık Saati', 0);
END
GO

/* örnek sınav */
DECLARE @DersID INT;
DECLARE @OturumID INT;

SELECT @DersID = DersID 
FROM dbo.Dersler 
WHERE DersKodu = N'YZM2126';

SELECT @OturumID = OturumID 
FROM dbo.Oturumlar 
WHERE Tanim = N'Oturum 1';

IF NOT EXISTS (
    SELECT 1 
    FROM dbo.Sinavlar
    WHERE DersID = @DersID
      AND Tarih = '2026-05-20'
      AND OturumID = @OturumID
)
BEGIN
    INSERT INTO dbo.Sinavlar (DersID, Tarih, OturumID)
    VALUES (@DersID, '2026-05-20', @OturumID);
END
GO

/* örnek salon atama */
DECLARE @SinavID INT;
DECLARE @AmfiID INT;
DECLARE @Z04ID INT;

SELECT @SinavID = S.SinavID
FROM dbo.Sinavlar S
INNER JOIN dbo.Dersler D ON S.DersID = D.DersID
WHERE D.DersKodu = N'YZM2126'
  AND S.Tarih = '2026-05-20';

SELECT @AmfiID = DerslikID 
FROM dbo.Derslikler 
WHERE Ad = N'Amfi-1';

SELECT @Z04ID = DerslikID 
FROM dbo.Derslikler 
WHERE Ad = N'Z-04';

IF NOT EXISTS (
    SELECT 1 
    FROM dbo.Sinav_Salonlari
    WHERE SinavID = @SinavID
      AND DerslikID = @AmfiID
)
BEGIN
    INSERT INTO dbo.Sinav_Salonlari (SinavID, DerslikID)
    VALUES (@SinavID, @AmfiID);
END

IF NOT EXISTS (
    SELECT 1 
    FROM dbo.Sinav_Salonlari
    WHERE SinavID = @SinavID
      AND DerslikID = @Z04ID
)
BEGIN
    INSERT INTO dbo.Sinav_Salonlari (SinavID, DerslikID)
    VALUES (@SinavID, @Z04ID);
END
GO

/* örnek gözetmen atama*/
DECLARE @SalonAtama1 INT;
DECLARE @SalonAtama2 INT;
DECLARE @AysePersonelID INT;
DECLARE @MehmetPersonelID INT;

SELECT TOP 1 @SalonAtama1 = SinavSalonID
FROM dbo.Sinav_Salonlari SS
INNER JOIN dbo.Derslikler DL ON SS.DerslikID = DL.DerslikID
WHERE DL.Ad = N'Amfi-1';

SELECT TOP 1 @SalonAtama2 = SinavSalonID
FROM dbo.Sinav_Salonlari SS
INNER JOIN dbo.Derslikler DL ON SS.DerslikID = DL.DerslikID
WHERE DL.Ad = N'Z-04';

SELECT @AysePersonelID = PersonelID
FROM dbo.Personel
WHERE Ad = N'Ayşe' AND Soyad = N'Demir';

SELECT @MehmetPersonelID = PersonelID
FROM dbo.Personel
WHERE Ad = N'Mehmet' AND Soyad = N'Kaya';

IF NOT EXISTS (
    SELECT 1 
    FROM dbo.Gozetmen_Atamalari
    WHERE SinavSalonID = @SalonAtama1
      AND PersonelID = @AysePersonelID
)
BEGIN
    INSERT INTO dbo.Gozetmen_Atamalari
    (SinavSalonID, PersonelID, AtamaKaynak)
    VALUES
    (@SalonAtama1, @AysePersonelID, N'Kendi Bölümü');
END

IF NOT EXISTS (
    SELECT 1 
    FROM dbo.Gozetmen_Atamalari
    WHERE SinavSalonID = @SalonAtama2
      AND PersonelID = @MehmetPersonelID
)
BEGIN
    INSERT INTO dbo.Gozetmen_Atamalari
    (SinavSalonID, PersonelID, AtamaKaynak)
    VALUES
    (@SalonAtama2, @MehmetPersonelID, N'Ortak Havuz');
END
GO

/* kontrol */
SELECT * FROM dbo.Bolumler;
SELECT * FROM dbo.Dersler;
SELECT * FROM dbo.Oturumlar;
SELECT * FROM dbo.Derslikler;
SELECT * FROM dbo.Personel;
SELECT * FROM dbo.Personel_Durum;
SELECT * FROM dbo.Sinavlar;
SELECT * FROM dbo.Sinav_Salonlari;
SELECT * FROM dbo.Gozetmen_Atamalari;
GO