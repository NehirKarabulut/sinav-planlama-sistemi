/* =========================================================
   YZM 2126 - Sınav Planlama Sistemi
   09_test_queries.sql
   Amaç:
   - Tüm SQL isterlerini test etmek
   - Table, View, Function, Stored Procedure, Trigger, Log,
     Transaction, Security ve Backup kontrollerini yapmak
   ========================================================= */

------------------------------------------------------------
-- 1. TEMEL TABLO KONTROLLERİ
------------------------------------------------------------
SELECT * FROM dbo.Bolumler;
SELECT * FROM dbo.Dersler;
SELECT * FROM dbo.Oturumlar;
SELECT * FROM dbo.Derslikler;
SELECT * FROM dbo.Personel;
SELECT * FROM dbo.Personel_Durum;
SELECT * FROM dbo.Sinavlar;
SELECT * FROM dbo.Sinav_Salonlari;
SELECT * FROM dbo.Gozetmen_Atamalari;
SELECT * FROM dbo.Loglar;
GO

------------------------------------------------------------
-- 2. VIEW TESTLERİ
-- En az 3 view isteri için kontrol
------------------------------------------------------------
SELECT * FROM dbo.vw_SinavProgrami;
SELECT * FROM dbo.vw_GozetmenGorevDagilimi;
SELECT * FROM dbo.vw_DerslikKullanimRaporu;
SELECT * FROM dbo.vw_BolumSinavYogunlugu;
GO

------------------------------------------------------------
-- 3. FUNCTION / UDF TESTLERİ
-- En az 3 UDF isteri için kontrol
------------------------------------------------------------

-- Gözetmen müsait mi?
SELECT dbo.fn_GozetmenMusaitMi(1, '2026-05-20', 1) AS GozetmenMusaitMi;
GO

-- Gözetmen ardışık oturum kuralına uygun mu?
SELECT dbo.fn_ArdisikOturumUygunMu(1, '2026-05-20', 4) AS ArdisikOturumUygunMu;
GO

-- Gözetmenin görev sayısı kaç?
SELECT dbo.fn_GozetmenGorevSayisi(1) AS GozetmenGorevSayisi;
GO

-- Salon müsait mi?
SELECT dbo.fn_SalonMusaitMi(1, '2026-05-20', 1) AS SalonMusaitMi;
GO

-- Sınava atanmış salonların toplam kapasitesi
SELECT dbo.fn_ToplamSalonKapasitesi(1) AS ToplamSalonKapasitesi;
GO

-- Aynı yarıyıl için günlük sınav sayısı
SELECT dbo.fn_GunlukSinavSayisi('2026-05-20', 4) AS GunlukSinavSayisi;
GO

------------------------------------------------------------
-- 4. STORED PROCEDURE TESTLERİ
-- En az 3 SP isteri için kontrol
------------------------------------------------------------

-- 4.1 Yeni sınav oluşturma testi
-- Not: Eğer aynı kayıt varsa unique constraint nedeniyle ekleme yapmayabilir.
EXEC dbo.sp_SinavOlustur
    @DersID = 2,
    @Tarih = '2026-05-21',
    @OturumID = 2;
GO

-- 4.2 Salon atama testi
-- Bu işlem transaction içerir.
EXEC dbo.sp_SalonAtamaYap
    @SinavID = 1,
    @DerslikIDList = '1,2';
GO

-- 4.3 Gözetmen atama testi
EXEC dbo.sp_GozetmenAta
    @SinavID = 1;
GO

-- 4.4 Sınav saati güncelleme testi
-- Bu işlem trigger ile Loglar tablosuna kayıt düşürmelidir.
EXEC dbo.sp_SinavSaatiGuncelle
    @SinavID = 1,
    @YeniTarih = '2026-05-20',
    @YeniOturumID = 2;
GO

------------------------------------------------------------
-- 5. TRIGGER / LOG TESTLERİ
------------------------------------------------------------

-- Sınav saati değişikliği log kaydı oluştu mu?
SELECT * 
FROM dbo.Loglar
ORDER BY LogID DESC;
GO

-- Gözetmen atama logları oluştu mu?
SELECT *
FROM dbo.Loglar
WHERE TabloAdi = N'Gozetmen_Atamalari'
ORDER BY LogID DESC;
GO

-- Salon atama logları oluştu mu?
SELECT *
FROM dbo.Loglar
WHERE TabloAdi = N'Sinav_Salonlari'
ORDER BY LogID DESC;
GO

------------------------------------------------------------
-- 6. TRANSACTION / ROLLBACK TESTİ
-- Bilerek kapasitesi yetersiz salon seçilerek hata alınması beklenir.
-- Hata olursa sp_SalonAtamaYap içinde ROLLBACK çalışmalıdır.
------------------------------------------------------------

-- Bu test hata verebilir, bu normaldir.
-- Çünkü Lab-1 kapasitesi 30, YZM2126 öğrenci sayısı 132.
-- İşlem geri alınmalı.
BEGIN TRY
    EXEC dbo.sp_SalonAtamaYap
        @SinavID = 1,
        @DerslikIDList = '3';
END TRY
BEGIN CATCH
    SELECT 
        N'Rollback testi başarılı: Hata yakalandı ve işlem geri alındı.' AS Mesaj,
        ERROR_MESSAGE() AS HataMesaji;
END CATCH;
GO

------------------------------------------------------------
-- 7. GÜVENLİK TESTLERİ
-- App_Admin ve App_Viewer yetkileri kontrol edilir.
------------------------------------------------------------

-- App_Admin tüm tablolarda SELECT yapabilmeli.
EXECUTE AS USER = 'App_Admin';
SELECT TOP 5 * FROM dbo.Dersler;
SELECT TOP 5 * FROM dbo.Sinavlar;
REVERT;
GO

-- App_Viewer sadece view görebilmeli.
EXECUTE AS USER = 'App_Viewer';
SELECT TOP 5 * FROM dbo.vw_SinavProgrami;
REVERT;
GO

-- App_Viewer doğrudan tablo okuyamamalı.
-- Bu test hata verebilir, bu normaldir.
BEGIN TRY
    EXECUTE AS USER = 'App_Viewer';
    SELECT TOP 5 * FROM dbo.Dersler;
    REVERT;
END TRY
BEGIN CATCH
    IF ORIGINAL_LOGIN() IS NOT NULL
    BEGIN
        REVERT;
    END

    SELECT 
        N'App_Viewer tablo SELECT engeli başarılı.' AS Mesaj,
        ERROR_MESSAGE() AS HataMesaji;
END CATCH;
GO

-- App_Viewer INSERT yapamamalı.
-- Bu test hata verebilir, bu normaldir.
BEGIN TRY
    EXECUTE AS USER = 'App_Viewer';

    INSERT INTO dbo.Bolumler (BolumAdi, Fakulte)
    VALUES (N'Yetkisiz Test Bölümü', N'Mühendislik Fakültesi');

    REVERT;
END TRY
BEGIN CATCH
    IF ORIGINAL_LOGIN() IS NOT NULL
    BEGIN
        REVERT;
    END

    SELECT 
        N'App_Viewer INSERT engeli başarılı.' AS Mesaj,
        ERROR_MESSAGE() AS HataMesaji;
END CATCH;
GO

------------------------------------------------------------
-- 8. BACKUP BONUS TESTİ
-- 08_backup_procedure.sql şu an pasif hale getirildi.
-- Aktif edilirse aşağıdaki komut çalıştırılabilir.
------------------------------------------------------------

-- EXEC dbo.sp_VeritabaniYedekAl;
-- SELECT * FROM dbo.Loglar ORDER BY LogID DESC;
GO

------------------------------------------------------------
-- 9. FINAL KONTROL RAPORU
------------------------------------------------------------

SELECT 
    (SELECT COUNT(*) FROM dbo.Bolumler) AS BolumSayisi,
    (SELECT COUNT(*) FROM dbo.Dersler) AS DersSayisi,
    (SELECT COUNT(*) FROM dbo.Oturumlar) AS OturumSayisi,
    (SELECT COUNT(*) FROM dbo.Derslikler) AS DerslikSayisi,
    (SELECT COUNT(*) FROM dbo.Personel) AS PersonelSayisi,
    (SELECT COUNT(*) FROM dbo.Sinavlar) AS SinavSayisi,
    (SELECT COUNT(*) FROM dbo.Sinav_Salonlari) AS SalonAtamaSayisi,
    (SELECT COUNT(*) FROM dbo.Gozetmen_Atamalari) AS GozetmenAtamaSayisi,
    (SELECT COUNT(*) FROM dbo.Loglar) AS LogSayisi;
GO