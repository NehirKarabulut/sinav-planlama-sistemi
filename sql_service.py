"""
sql_service.py

Bu dosya DB hazır olduğunda SQL Server işlemlerini yönetecek.
Şu an mock moddayız, bu yüzden fonksiyonlar gerçek DB bağlantısı açmıyor.

DB hazır olunca:
- SELECT sorguları
- Stored Procedure çağrıları
- View çağrıları
- UDF çağrıları
- Log sorguları
buradan yönetilecek.
"""

from database import get_sql_connection


def fetch_all(query: str, params: tuple = ()):
    """
    SELECT sorguları için kullanılacak.

    Örnek:
    fetch_all("SELECT * FROM dbo.Dersler")
    """
    raise NotImplementedError("DB hazır olunca SELECT sorguları burada çalışacak.")


def execute_command(query: str, params: tuple = ()):
    """
    INSERT / UPDATE / DELETE sorguları için kullanılacak.
    """
    raise NotImplementedError("DB hazır olunca komut sorguları burada çalışacak.")


def execute_stored_procedure(procedure_name: str, params: tuple = ()):
    """
    Stored Procedure çağırmak için kullanılacak.

    Örnek:
    execute_stored_procedure(
        "dbo.sp_SinavOlustur",
        (ders_id, tarih, oturum_id)
    )
    """
    raise NotImplementedError("DB hazır olunca Stored Procedure çağrıları burada çalışacak.")


def execute_scalar_function(function_query: str, params: tuple = ()):
    """
    UDF / Function çağırmak için kullanılacak.

    Örnek:
    SELECT dbo.fn_GozetmenMusaitMi(?, ?, ?)
    """
    raise NotImplementedError("DB hazır olunca UDF çağrıları burada çalışacak.")


def fetch_view(view_name: str):
    """
    View çağırmak için kullanılacak.

    Örnek:
    fetch_view("dbo.vw_SinavProgrami")
    """
    query = f"SELECT * FROM {view_name}"
    raise NotImplementedError(f"DB hazır olunca şu view çağrılacak: {query}")


def call_backup_procedure():
    """
    Bonus ister içindir.
    Şu an 08_backup_procedure.sql pasif olduğu için çalıştırılmayacak.
    """
    raise NotImplementedError("Backup procedure şu an pasif. Sonra aktif edilecek.")