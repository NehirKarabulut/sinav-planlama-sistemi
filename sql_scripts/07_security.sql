/* =========================================================
   YZM 2126 - Sınav Planlama Sistemi
   07_security.sql
   Amaç:
   - App_Admin ve App_Viewer kullanıcılarını oluşturmak
   - GRANT / REVOKE / DENY işlemlerini yapmak
   - Role-Based Security isterini karşılamak
   ========================================================= */

------------------------------------------------------------
-- NOT:
-- Bu script SQL Server üzerinde çalıştırılacaktır.
-- Login oluşturma işlemi master seviyesinde yapılır.
-- User ve yetki işlemleri proje database'i içinde yapılır.
--
-- Eğer login zaten varsa hata almamak için önce kontrol edilir.
------------------------------------------------------------

------------------------------------------------------------
-- 1. LOGIN OLUŞTURMA
------------------------------------------------------------

IF NOT EXISTS (
    SELECT 1 
    FROM sys.server_principals 
    WHERE name = N'App_Admin'
)
BEGIN
    CREATE LOGIN App_Admin 
    WITH PASSWORD = 'Admin_12345!',
         CHECK_POLICY = OFF;
END
GO

IF NOT EXISTS (
    SELECT 1 
    FROM sys.server_principals 
    WHERE name = N'App_Viewer'
)
BEGIN
    CREATE LOGIN App_Viewer 
    WITH PASSWORD = 'Viewer_12345!',
         CHECK_POLICY = OFF;
END
GO

------------------------------------------------------------
-- 2. DATABASE USER OLUŞTURMA
------------------------------------------------------------

IF NOT EXISTS (
    SELECT 1 
    FROM sys.database_principals 
    WHERE name = N'App_Admin'
)
BEGIN
    CREATE USER App_Admin FOR LOGIN App_Admin;
END
GO

IF NOT EXISTS (
    SELECT 1 
    FROM sys.database_principals 
    WHERE name = N'App_Viewer'
)
BEGIN
    CREATE USER App_Viewer FOR LOGIN App_Viewer;
END
GO

------------------------------------------------------------
-- 3. APP_ADMIN YETKİLERİ
-- Yönetici tüm tablolarda okuma/yazma yapabilir.
------------------------------------------------------------

GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Bolumler TO App_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Dersler TO App_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Oturumlar TO App_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Derslikler TO App_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Personel TO App_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Personel_Durum TO App_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Sinavlar TO App_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Sinav_Salonlari TO App_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Gozetmen_Atamalari TO App_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Loglar TO App_Admin;
GO

------------------------------------------------------------
-- 4. APP_ADMIN PROCEDURE ÇALIŞTIRMA YETKİLERİ
------------------------------------------------------------

GRANT EXECUTE ON dbo.sp_SinavOlustur TO App_Admin;
GRANT EXECUTE ON dbo.sp_SalonAtamaYap TO App_Admin;
GRANT EXECUTE ON dbo.sp_GozetmenAta TO App_Admin;
GRANT EXECUTE ON dbo.sp_SinavSaatiGuncelle TO App_Admin;
GO

------------------------------------------------------------
-- 5. APP_VIEWER YETKİLERİ
-- Gözetmen / izleyici sadece rapor view'larını görebilir.
------------------------------------------------------------

GRANT SELECT ON dbo.vw_SinavProgrami TO App_Viewer;
GRANT SELECT ON dbo.vw_GozetmenGorevDagilimi TO App_Viewer;
GRANT SELECT ON dbo.vw_DerslikKullanimRaporu TO App_Viewer;
GRANT SELECT ON dbo.vw_BolumSinavYogunlugu TO App_Viewer;
GO

------------------------------------------------------------
-- 6. APP_VIEWER TABLO YAZMA YETKİLERİNİ ENGELLEME
-- DENY, GRANT'ten daha güçlüdür.
------------------------------------------------------------

DENY INSERT, UPDATE, DELETE ON dbo.Bolumler TO App_Viewer;
DENY INSERT, UPDATE, DELETE ON dbo.Dersler TO App_Viewer;
DENY INSERT, UPDATE, DELETE ON dbo.Oturumlar TO App_Viewer;
DENY INSERT, UPDATE, DELETE ON dbo.Derslikler TO App_Viewer;
DENY INSERT, UPDATE, DELETE ON dbo.Personel TO App_Viewer;
DENY INSERT, UPDATE, DELETE ON dbo.Personel_Durum TO App_Viewer;
DENY INSERT, UPDATE, DELETE ON dbo.Sinavlar TO App_Viewer;
DENY INSERT, UPDATE, DELETE ON dbo.Sinav_Salonlari TO App_Viewer;
DENY INSERT, UPDATE, DELETE ON dbo.Gozetmen_Atamalari TO App_Viewer;
DENY INSERT, UPDATE, DELETE ON dbo.Loglar TO App_Viewer;
GO

------------------------------------------------------------
-- 7. APP_VIEWER TABLOLARA DOĞRUDAN SELECT ATMASIN
-- Sadece view üzerinden rapor görsün.
------------------------------------------------------------

DENY SELECT ON dbo.Bolumler TO App_Viewer;
DENY SELECT ON dbo.Dersler TO App_Viewer;
DENY SELECT ON dbo.Oturumlar TO App_Viewer;
DENY SELECT ON dbo.Derslikler TO App_Viewer;
DENY SELECT ON dbo.Personel TO App_Viewer;
DENY SELECT ON dbo.Personel_Durum TO App_Viewer;
DENY SELECT ON dbo.Sinavlar TO App_Viewer;
DENY SELECT ON dbo.Sinav_Salonlari TO App_Viewer;
DENY SELECT ON dbo.Gozetmen_Atamalari TO App_Viewer;
DENY SELECT ON dbo.Loglar TO App_Viewer;
GO

------------------------------------------------------------
-- 8. REVOKE ÖRNEĞİ
-- Proje isterinde REVOKE de geçtiği için örnek olarak kullanıyoruz.
-- App_Viewer'a yanlışlıkla verilen genel EXECUTE yetkisi varsa geri alınır.
------------------------------------------------------------

REVOKE EXECUTE TO App_Viewer;
GO

------------------------------------------------------------
-- 9. SECURITY TEST SORGULARI
-- Bunlar SSMS'te test amaçlı kullanılabilir.
------------------------------------------------------------

-- App_Admin olarak test:
-- EXECUTE AS USER = 'App_Admin';
-- SELECT * FROM dbo.Dersler;
-- INSERT INTO dbo.Bolumler (BolumAdi, Fakulte) VALUES (N'Test Bölümü', N'Mühendislik Fakültesi');
-- REVERT;

-- App_Viewer olarak test:
-- EXECUTE AS USER = 'App_Viewer';
-- SELECT * FROM dbo.vw_SinavProgrami;
-- SELECT * FROM dbo.Dersler; -- DENY nedeniyle hata vermeli
-- INSERT INTO dbo.Dersler (DersKodu, DersTuru, Ad, OgrenciSayisi, Yariyil, BolumID)
-- VALUES (N'TEST101', N'Zorunlu', N'Test Dersi', 10, 1, 1); -- DENY nedeniyle hata vermeli
-- REVERT;
GO