/* =========================================================
   YZM 2126 - Sınav Planlama Sistemi
   04_functions.sql
   Amaç:
   - UDF / User Defined Function yapılarını oluşturmak
   - Gözetmen, salon, kapasite ve sınav limiti kontrollerini yapmak
   ========================================================= */

------------------------------------------------------------
-- 1. GÖZETMEN MÜSAİT Mİ?
-- Kontrol:
-- - Gözetmenin ilgili tarih/oturumda mazereti var mı?
-- - Aynı tarih/oturumda başka salonda görevli mi?
------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_GozetmenMusaitMi
(
    @PersonelID INT,
    @Tarih DATE,
    @OturumID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @Sonuc BIT = 1;

    -- Mazeret / izin / danışmanlık kontrolü
    IF EXISTS (
        SELECT 1
        FROM dbo.Personel_Durum PD
        WHERE PD.PersonelID = @PersonelID
          AND PD.Tarih = @Tarih
          AND PD.OturumID = @OturumID
          AND PD.Uygun = 0
    )
    BEGIN
        SET @Sonuc = 0;
    END

    -- Aynı oturumda başka sınavda görevli mi?
    IF EXISTS (
        SELECT 1
        FROM dbo.Gozetmen_Atamalari GA
        INNER JOIN dbo.Sinav_Salonlari SS
            ON GA.SinavSalonID = SS.SinavSalonID
        INNER JOIN dbo.Sinavlar S
            ON SS.SinavID = S.SinavID
        WHERE GA.PersonelID = @PersonelID
          AND S.Tarih = @Tarih
          AND S.OturumID = @OturumID
    )
    BEGIN
        SET @Sonuc = 0;
    END

    RETURN @Sonuc;
END
GO

------------------------------------------------------------
-- 2. GÖZETMEN ARDIŞIK OTURUM UYGUN MU?
-- Kural:
-- Bir gözetmen arka arkaya en fazla 3 oturumda görev alabilir.
------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_ArdisikOturumUygunMu
(
    @PersonelID INT,
    @Tarih DATE,
    @OturumID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @Sonuc BIT = 1;
    DECLARE @ArdisikSayi INT;

    SELECT @ArdisikSayi = COUNT(DISTINCT S.OturumID)
    FROM dbo.Gozetmen_Atamalari GA
    INNER JOIN dbo.Sinav_Salonlari SS
        ON GA.SinavSalonID = SS.SinavSalonID
    INNER JOIN dbo.Sinavlar S
        ON SS.SinavID = S.SinavID
    WHERE GA.PersonelID = @PersonelID
      AND S.Tarih = @Tarih
      AND S.OturumID BETWEEN @OturumID - 3 AND @OturumID - 1;

    IF @ArdisikSayi >= 3
    BEGIN
        SET @Sonuc = 0;
    END

    RETURN @Sonuc;
END
GO

------------------------------------------------------------
-- 3. GÖZETMEN GÖREV SAYISI
-- Amaç:
-- Adil dağıtım için personelin toplam görev sayısını döndürür.
------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_GozetmenGorevSayisi
(
    @PersonelID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @GorevSayisi INT;

    SELECT @GorevSayisi = COUNT(*)
    FROM dbo.Gozetmen_Atamalari
    WHERE PersonelID = @PersonelID;

    RETURN ISNULL(@GorevSayisi, 0);
END
GO

------------------------------------------------------------
-- 4. SALON MÜSAİT Mİ?
-- Kontrol:
-- Aynı derslikte aynı tarih ve oturumda başka sınav var mı?
------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_SalonMusaitMi
(
    @DerslikID INT,
    @Tarih DATE,
    @OturumID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @Sonuc BIT = 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.Sinav_Salonlari SS
        INNER JOIN dbo.Sinavlar S
            ON SS.SinavID = S.SinavID
        WHERE SS.DerslikID = @DerslikID
          AND S.Tarih = @Tarih
          AND S.OturumID = @OturumID
    )
    BEGIN
        SET @Sonuc = 0;
    END

    RETURN @Sonuc;
END
GO

------------------------------------------------------------
-- 5. TOPLAM SALON KAPASİTESİ
-- Amaç:
-- Bir sınava atanmış salonların toplam kapasitesini verir.
------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_ToplamSalonKapasitesi
(
    @SinavID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @ToplamKapasite INT;

    SELECT @ToplamKapasite = SUM(D.Kapasite)
    FROM dbo.Sinav_Salonlari SS
    INNER JOIN dbo.Derslikler D
        ON SS.DerslikID = D.DerslikID
    WHERE SS.SinavID = @SinavID;

    RETURN ISNULL(@ToplamKapasite, 0);
END
GO

------------------------------------------------------------
-- 6. GÜNLÜK SINAV SAYISI
-- Kural:
-- Aynı yarıyıl için aynı güne 2'den fazla sınav varsa uyarı verilir.
------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_GunlukSinavSayisi
(
    @Tarih DATE,
    @Yariyil INT
)
RETURNS INT
AS
BEGIN
    DECLARE @SinavSayisi INT;

    SELECT @SinavSayisi = COUNT(*)
    FROM dbo.Sinavlar S
    INNER JOIN dbo.Dersler D
        ON S.DersID = D.DersID
    WHERE S.Tarih = @Tarih
      AND D.Yariyil = @Yariyil;

    RETURN ISNULL(@SinavSayisi, 0);
END
GO

------------------------------------------------------------
-- 7. FUNCTION TEST SORGULARI
------------------------------------------------------------

-- Gözetmen müsaitlik testi
SELECT dbo.fn_GozetmenMusaitMi(1, '2026-05-20', 1) AS GozetmenMusaitMi;

-- Ardışık oturum testi
SELECT dbo.fn_ArdisikOturumUygunMu(1, '2026-05-20', 4) AS ArdisikOturumUygunMu;

-- Görev sayısı testi
SELECT dbo.fn_GozetmenGorevSayisi(1) AS GozetmenGorevSayisi;

-- Salon müsaitlik testi
SELECT dbo.fn_SalonMusaitMi(1, '2026-05-20', 1) AS SalonMusaitMi;

-- Toplam kapasite testi
SELECT dbo.fn_ToplamSalonKapasitesi(1) AS ToplamSalonKapasitesi;

-- Günlük sınav sayısı testi
SELECT dbo.fn_GunlukSinavSayisi('2026-05-20', 4) AS GunlukSinavSayisi;
GO