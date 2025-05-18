import mysql.connector

try:
    conn = mysql.connector.connect(
        host="localhost",
        user="dong",
        password="44444444",
        database="main",
        port=3306  # Sử dụng port bạn vừa kiểm tra
    )
    print("✅ Kết nối thành công!")
    conn.close()
except Exception as e:
    print(f"❌ Lỗi: {e}")