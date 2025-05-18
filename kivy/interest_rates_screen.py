from kivy.properties import NumericProperty, StringProperty, ListProperty
from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.uix.card import MDCard
from connection import create_connection

class InterestRateCard(MDCard):
    rate_id = NumericProperty()
    rate_value = NumericProperty()
    account_type = StringProperty()
    status = StringProperty()
    min_balance = NumericProperty(allownone=True)
    max_balance = NumericProperty(allownone=True)
    term = NumericProperty(allownone=True)
    card_color = ListProperty([0.3, 0.15, 0.5, 1])

class InterestRateScreen(MDBoxLayout):
    nav_drawer = None  # sẽ được gán từ ngoài nếu cần

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # Nếu dùng nav_drawer, gán sau khi khởi tạo
        self.load_interest_rates()

    def load_interest_rates(self):
        # Kết nối MySQL và lấy dữ liệu bảng INTEREST_RATES
        conn = create_connection()
        if not conn:
            print("Không thể kết nối database!")
            return

        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("""
                SELECT ir.interest_rate_id, ir.interest_rate_val, ir.cus_account_type_id, 
                       ir.min_balance, ir.max_balance, ir.status, ir.term, cat.cus_account_type_name
                FROM INTEREST_RATES ir
                JOIN CUSTOMER_ACCOUNT_TYPES cat ON ir.cus_account_type_id = cat.cus_account_type_id
            """)
            rows = cursor.fetchall()
        except Exception as e:
            print("Lỗi truy vấn:", e)
            rows = []
        finally:
            conn.close()

        # Gán màu theo loại tài khoản
        type_colors = {
            'Checking': [0.3, 0.15, 0.5, 1],
            'Saving': [0.4, 0.2, 0.6, 1],
            'Fixed Deposit': [0.5, 0.25, 0.7, 1]
        }

        container = self.ids.rates_container
        container.clear_widgets()

        for row in rows:
            card = InterestRateCard()
            card.rate_id = row['interest_rate_id']
            card.rate_value = float(row['interest_rate_val'])
            card.account_type = row.get('cus_account_type_name', row['cus_account_type_id'])
            card.status = row['status']
            card.min_balance = row['min_balance'] if row['min_balance'] is not None else 0
            card.max_balance = row['max_balance'] if row['max_balance'] is not None else 0
            card.term = row['term'] if row['term'] is not None else 0
            card.card_color = type_colors.get(card.account_type, [0.3, 0.15, 0.5, 1])
            container.add_widget(card)

    def show_add_rate_form(self):
        print("Show add rate form")

    def show_filters(self):
        print("Show filters")