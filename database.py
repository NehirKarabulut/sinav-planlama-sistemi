import pyodbc

import pyodbc

def get_sql_connection():
    """Yerel SQL Server (SSMS) veritabanına CANLI ve GERÇEK bağlantı açar."""
    server = r'LAPTOP-FMLI53KJ'
    database = 'SinavPlanlamaDB'
    
    conn_str = (
        f'DRIVER={{SQL Server}};'
        f'SERVER={server};'
        f'DATABASE={database};'
        f'Trusted_Connection=yes;'
    )
    try:
        return pyodbc.connect(conn_str)
    except Exception as e:
        print(f"\n❌ [CRITICAL DATABASE ERROR]: {e}\n")
        return None

def get_connection_info():
    return {"server": r"LAPTOP-FMLI53KJ", "database": "SinavPlanlamaDB"}

def is_mock_mode():
    return False
    
    conn_str = (
        f'DRIVER={{SQL Server}};'
        f'SERVER={server};'
        f'DATABASE={database};'
        f'Trusted_Connection=yes;'
    )
    try:
        return pyodbc.connect(conn_str)
    except Exception as e:
        print(f"Veritabanına bağlanırken hata oluştu: {e}")
        return None



def get_connection_info():
    """Eski koddaki import hatasını engellemek için bağlantı bilgisini döner."""
    return {"server": r"LAPTOP-FMLI53KJ\OMEN", "database": "SinavPlanlamaDB"}

def is_mock_mode():
    """Artık canlı modda olduğumuz için her zaman False döner."""
    return False