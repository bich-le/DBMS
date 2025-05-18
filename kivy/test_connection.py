import mysql.connector

try:
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="Dance!11230592",
        database="main",
        port=3306  # Sử dụng port bạn vừa kiểm tra
    )
    print("✅ Kết nối thành công!")
    conn.close()
except Exception as e:
    print(f"❌ Lỗi: {e}")