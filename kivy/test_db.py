import mysql.connector

try:
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="Dance!11230592",
        database="main",
        connect_timeout=3
    )
    cursor = conn.cursor()
    cursor.execute("SELECT 1")
    print("Kết nối database thành công!")
    cursor.close()
    conn.close()
except Exception as e:
    print(f"Lỗi kết nối database: {e}")