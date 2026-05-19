/* sp */
/*sınav atama*/
CREATE OR ALTER PROCEDURE dbo.sp_SinavOlustur
    @DersID INT,
    @Tarih DATE,
    @OturumID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Yariyil INT;
    DECLARE @DersTuru NVARCHAR(30);
    DECLARE @GunlukSinavSayisi INT;

    SELECT 
        @Yariyil = Yariyil,
        @DersTuru = DersTuru
    FROM dbo.Dersler
    WHERE DersID = @DersID;

    IF @Yariyil IS NULL
    BEGIN
        RAISERROR(N'Ders bulunamadı.', 16, 1);
        RETURN;
    END

    /*zorunlu derslerin aynı oturuma konulmasını engelle*/
    IF EXISTS (
        SELECT 1
        FROM dbo.Sinavlar S
        INNER JOIN dbo.Dersler D ON S.DersID = D.DersID
        WHERE D.Yariyil = @Yariyil
          AND D.DersTuru = N'Zorunlu'
          AND S.Tarih = @Tarih
          AND S.OturumID = @OturumID
          AND D.DersID <> @DersID
    )
    BEGIN
        RAISERROR(N'Aynı yarıyıldaki zorunlu dersler aynı tarih ve oturuma atanamaz.', 16, 1);
        RETURN;
    END

    /*günlük sınav sayısı kontrolü*/
    SET @GunlukSinavSayisi = dbo.fn_GunlukSinavSayisi(@Tarih, @Yariyil);

    IF @GunlukSinavSayisi >= 2
    BEGIN
        PRINT N'Uyarı: Bu yarıyıl için aynı güne 2 sınav zaten atanmış. Yeni sınav 2 sınav limitini aşabilir.';
    END

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Sinavlar
        WHERE DersID = @DersID
          AND Tarih = @Tarih
          AND OturumID = @OturumID
    )
    BEGIN
        INSERT INTO dbo.Sinavlar (DersID, Tarih, OturumID)
        VALUES (@DersID, @Tarih, @OturumID);
    END

    SELECT 
        S.SinavID,
        S.DersID,
        D.DersKodu,
        D.Ad AS DersAdi,
        S.Tarih,
        S.OturumID,
        O.Tanim AS Oturum,
        @GunlukSinavSayisi + 1 AS GunlukSinavSayisi
    FROM dbo.Sinavlar S
    INNER JOIN dbo.Dersler D ON S.DersID = D.DersID
    INNER JOIN dbo.Oturumlar O ON S.OturumID = O.OturumID
    WHERE S.DersID = @DersID
      AND S.Tarih = @Tarih
      AND S.OturumID = @OturumID;
END
GO

/*salon atama*/
CREATE OR ALTER PROCEDURE dbo.sp_SalonAtamaYap
    @SinavID INT,
    @DerslikIDList NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;    /*transaction*/

        DECLARE @Tarih DATE;
        DECLARE @OturumID INT;
        DECLARE @OgrenciSayisi INT;
        DECLARE @ToplamKapasite INT;

        SELECT
            @Tarih = S.Tarih,
            @OturumID = S.OturumID,
            @OgrenciSayisi = D.OgrenciSayisi
        FROM dbo.Sinavlar S
        INNER JOIN dbo.Dersler D ON S.DersID = D.DersID
        WHERE S.SinavID = @SinavID;

        IF @Tarih IS NULL
        BEGIN
            RAISERROR(N'Sınav bulunamadı.', 16, 1);
        END

        /*seçilen salon toplam kapasite*/
        SELECT @ToplamKapasite = SUM(DL.Kapasite)
        FROM dbo.Derslikler DL
        WHERE DL.DerslikID IN (
            SELECT TRY_CAST(value AS INT)
            FROM STRING_SPLIT(@DerslikIDList, ',')
        );

        IF ISNULL(@ToplamKapasite, 0) < @OgrenciSayisi
        BEGIN
            RAISERROR(N'Seçilen salonların toplam kapasitesi öğrenci sayısından az olamaz.', 16, 1);
        END

        /*salon çakışma kontrolü*/
        IF EXISTS (
            SELECT 1
            FROM STRING_SPLIT(@DerslikIDList, ',') X
            WHERE dbo.fn_SalonMusaitMi(TRY_CAST(X.value AS INT), @Tarih, @OturumID) = 0
              AND NOT EXISTS (
                    SELECT 1
                    FROM dbo.Sinav_Salonlari SS
                    WHERE SS.SinavID = @SinavID
                      AND SS.DerslikID = TRY_CAST(X.value AS INT)
              )
        )
        BEGIN
            RAISERROR(N'Seçilen salonlardan biri aynı tarih ve oturumda dolu.', 16, 1);
        END

        /*atama ekle*/
        INSERT INTO dbo.Sinav_Salonlari (SinavID, DerslikID)
        SELECT 
            @SinavID,
            TRY_CAST(value AS INT)
        FROM STRING_SPLIT(@DerslikIDList, ',') X
        WHERE TRY_CAST(value AS INT) IS NOT NULL
          AND NOT EXISTS (
                SELECT 1
                FROM dbo.Sinav_Salonlari SS
                WHERE SS.SinavID = @SinavID
                  AND SS.DerslikID = TRY_CAST(X.value AS INT)
          );

        COMMIT TRANSACTION;       /*commit*/

        SELECT 
            N'Salon atama işlemi başarıyla tamamlandı.' AS Mesaj,
            @SinavID AS SinavID,
            @ToplamKapasite AS ToplamKapasite,
            @OgrenciSayisi AS OgrenciSayisi;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;       /*rollback*/

        DECLARE @HataMesaji NVARCHAR(4000);
        SET @HataMesaji = ERROR_MESSAGE();

        RAISERROR(@HataMesaji, 16, 1);
    END CATCH
END
GO

/*gözetmen atama*/
CREATE OR ALTER PROCEDURE dbo.sp_GozetmenAta
    @SinavID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Tarih DATE;
        DECLARE @OturumID INT;
        DECLARE @DersBolumID INT;

        SELECT
            @Tarih = S.Tarih,
            @OturumID = S.OturumID,
            @DersBolumID = D.BolumID
        FROM dbo.Sinavlar S
        INNER JOIN dbo.Dersler D ON S.DersID = D.DersID
        WHERE S.SinavID = @SinavID;

        IF @Tarih IS NULL
        BEGIN
            RAISERROR(N'Sınav bulunamadı.', 16, 1);
        END

        DECLARE @SinavSalonID INT;
        DECLARE @SecilenPersonelID INT;
        DECLARE @AtamaKaynak NVARCHAR(50);

        DECLARE salon_cursor CURSOR FOR
        SELECT SS.SinavSalonID
        FROM dbo.Sinav_Salonlari SS
        WHERE SS.SinavID = @SinavID
          AND NOT EXISTS (
                SELECT 1
                FROM dbo.Gozetmen_Atamalari GA
                WHERE GA.SinavSalonID = SS.SinavSalonID
          );

        OPEN salon_cursor;

        FETCH NEXT FROM salon_cursor INTO @SinavSalonID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SecilenPersonelID = NULL;
            SET @AtamaKaynak = NULL;

            /*bölüme uygun gözetmen*/
            SELECT TOP 1
                @SecilenPersonelID = P.PersonelID,
                @AtamaKaynak = N'Kendi Bölümü'
            FROM dbo.Personel P
            WHERE P.Aktif = 1
              AND P.BolumID = @DersBolumID
              AND dbo.fn_GozetmenMusaitMi(P.PersonelID, @Tarih, @OturumID) = 1
              AND dbo.fn_ArdisikOturumUygunMu(P.PersonelID, @Tarih, @OturumID) = 1
            ORDER BY dbo.fn_GozetmenGorevSayisi(P.PersonelID) ASC;

            /*bölüme uygun yoksa ortak havuzdan*/
            IF @SecilenPersonelID IS NULL
            BEGIN
                SELECT TOP 1
                    @SecilenPersonelID = P.PersonelID,
                    @AtamaKaynak = N'Ortak Havuz'
                FROM dbo.Personel P
                WHERE P.Aktif = 1
                  AND P.BolumID <> @DersBolumID
                  AND dbo.fn_GozetmenMusaitMi(P.PersonelID, @Tarih, @OturumID) = 1
                  AND dbo.fn_ArdisikOturumUygunMu(P.PersonelID, @Tarih, @OturumID) = 1
                ORDER BY dbo.fn_GozetmenGorevSayisi(P.PersonelID) ASC;
            END

            IF @SecilenPersonelID IS NULL
            BEGIN
                CLOSE salon_cursor;
                DEALLOCATE salon_cursor;
                RAISERROR(N'Uygun gözetmen bulunamadı. Atama işlemi geri alındı.', 16, 1);
            END

            INSERT INTO dbo.Gozetmen_Atamalari
            (SinavSalonID, PersonelID, AtamaKaynak)
            VALUES
            (@SinavSalonID, @SecilenPersonelID, @AtamaKaynak);

            FETCH NEXT FROM salon_cursor INTO @SinavSalonID;
        END

        CLOSE salon_cursor;
        DEALLOCATE salon_cursor;

        COMMIT TRANSACTION;

        SELECT 
            N'Gözetmen atama işlemi başarıyla tamamlandı.' AS Mesaj,
            @SinavID AS SinavID;
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'salon_cursor') >= -1
        BEGIN
            CLOSE salon_cursor;
            DEALLOCATE salon_cursor;
        END

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @HataMesaji NVARCHAR(4000);
        SET @HataMesaji = ERROR_MESSAGE();

        RAISERROR(@HataMesaji, 16, 1);
    END CATCH
END
GO

/*sınav saati güncelleme*/
CREATE OR ALTER PROCEDURE dbo.sp_SinavSaatiGuncelle
    @SinavID INT,
    @YeniTarih DATE,
    @YeniOturumID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Sinavlar
        WHERE SinavID = @SinavID
    )
    BEGIN
        RAISERROR(N'Sınav bulunamadı.', 16, 1);
        RETURN;
    END

    UPDATE dbo.Sinavlar
    SET 
        Tarih = @YeniTarih,
        OturumID = @YeniOturumID
    WHERE SinavID = @SinavID;

    SELECT 
        N'Sınav tarihi / oturumu güncellendi. Log triggerı çalışacaktır.' AS Mesaj,
        @SinavID AS SinavID,
        @YeniTarih AS YeniTarih,
        @YeniOturumID AS YeniOturumID;
END
GO

------------------------------------------------------------
-- 5. TEST ÇAĞRILARI
-- Not:
-- Bunlar test amaçlıdır. Gerekirse SSMS'te tek tek çalıştırılır.
------------------------------------------------------------

-- Yeni sınav oluşturma örneği:
-- EXEC dbo.sp_SinavOlustur 
--      @DersID = 2, 
--      @Tarih = '2026-05-21', 
--      @OturumID = 2;

-- Salon atama örneği:
-- EXEC dbo.sp_SalonAtamaYap 
--      @SinavID = 1, 
--      @DerslikIDList = '1,2';

-- Gözetmen atama örneği:
-- EXEC dbo.sp_GozetmenAta 
--      @SinavID = 1;

-- Sınav saati güncelleme örneği:
-- EXEC dbo.sp_SinavSaatiGuncelle 
--      @SinavID = 1,
--      @YeniTarih = '2026-05-20',
--      @YeniOturumID = 2;
GO