/* =========================================================
   YZM 2126 - Sınav Planlama Sistemi
   06_triggers.sql
   Amaç:
   - Trigger yapılarını oluşturmak
   - Sınav saati değişikliği, salon atama ve gözetmen atama işlemlerini loglamak
   ========================================================= */

------------------------------------------------------------
-- 1. SINAV SAAT DEĞİŞİKLİĞİ LOG TRIGGER'I
-- Ek ister:
-- Yönetici sınav saatini değiştirdiğinde Log tablosuna
-- Eski Saat, Yeni Saat, Değiştiren, Tarih bilgisi düşmelidir.
------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_SinavSaatDegisikligi_Log
ON dbo.Sinavlar
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Loglar
    (
        IslemTuru,
        TabloAdi,
        KayitID,
        EskiDeger,
        YeniDeger,
        DegistirenKullanici,
        IslemTarihi,
        Aciklama
    )
    SELECT
        N'UPDATE',
        N'Sinavlar',
        I.SinavID,

        N'Eski Tarih: ' + CONVERT(NVARCHAR(20), D.Tarih, 120) +
        N', Eski OturumID: ' + CAST(D.OturumID AS NVARCHAR(10)),

        N'Yeni Tarih: ' + CONVERT(NVARCHAR(20), I.Tarih, 120) +
        N', Yeni OturumID: ' + CAST(I.OturumID AS NVARCHAR(10)),

        SYSTEM_USER,
        GETDATE(),
        N'Sınav tarihi veya oturumu değiştirildi.'

    FROM inserted I
    INNER JOIN deleted D
        ON I.SinavID = D.SinavID
    WHERE 
        ISNULL(I.Tarih, '1900-01-01') <> ISNULL(D.Tarih, '1900-01-01')
        OR ISNULL(I.OturumID, -1) <> ISNULL(D.OturumID, -1);
END
GO

------------------------------------------------------------
-- 2. GÖZETMEN ATAMA LOG TRIGGER'I
-- Amaç:
-- Gözetmen ataması eklendiğinde log kaydı oluşturmak.
------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_GozetmenAtama_Log
ON dbo.Gozetmen_Atamalari
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Loglar
    (
        IslemTuru,
        TabloAdi,
        KayitID,
        EskiDeger,
        YeniDeger,
        DegistirenKullanici,
        IslemTarihi,
        Aciklama
    )
    SELECT
        N'INSERT',
        N'Gozetmen_Atamalari',
        I.GozetmenAtamaID,
        NULL,
        N'SinavSalonID: ' + CAST(I.SinavSalonID AS NVARCHAR(10)) +
        N', PersonelID: ' + CAST(I.PersonelID AS NVARCHAR(10)) +
        N', Kaynak: ' + I.AtamaKaynak,
        SYSTEM_USER,
        GETDATE(),
        N'Yeni gözetmen ataması yapıldı.'
    FROM inserted I;
END
GO

------------------------------------------------------------
-- 3. SALON ATAMA LOG TRIGGER'I
-- Amaç:
-- Sınava salon ataması yapıldığında log kaydı oluşturmak.
------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_SalonAtama_Log
ON dbo.Sinav_Salonlari
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Loglar
    (
        IslemTuru,
        TabloAdi,
        KayitID,
        EskiDeger,
        YeniDeger,
        DegistirenKullanici,
        IslemTarihi,
        Aciklama
    )
    SELECT
        N'INSERT',
        N'Sinav_Salonlari',
        I.SinavSalonID,
        NULL,
        N'SinavID: ' + CAST(I.SinavID AS NVARCHAR(10)) +
        N', DerslikID: ' + CAST(I.DerslikID AS NVARCHAR(10)),
        SYSTEM_USER,
        GETDATE(),
        N'Sınava yeni salon ataması yapıldı.'
    FROM inserted I;
END
GO

------------------------------------------------------------
-- 4. TRIGGER TEST SORGULARI
-- Not:
-- Bunlar SSMS üzerinde test amaçlı tek tek çalıştırılabilir.
------------------------------------------------------------

-- Sınav saat değişikliği trigger testi:
-- EXEC dbo.sp_SinavSaatiGuncelle
--      @SinavID = 1,
--      @YeniTarih = '2026-05-20',
--      @YeniOturumID = 2;

-- Logları gör:
-- SELECT * FROM dbo.Loglar ORDER BY LogID DESC;

GO