from kivy.metrics import dp
from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.uix.label import MDLabel
from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDRaisedButton
from kivymd.uix.datatables import MDDataTable
from kivymd.uix.card import MDCard
from datetime import datetime
from kivy.core.window import Window

def show_result_dialog(title, columns, rows, on_close_callback=None):
    # Thiết lập kích thước dialog phù hợp
    Window.size = (1000, 700)
    
    # Xử lý dữ liệu đầu vào
    processed_rows = []
    for row in rows:
        if isinstance(row, tuple):
            processed_rows.append(list(row))
        else:
            processed_rows.append(row.copy() if hasattr(row, 'copy') else row[:])
    
    # Tính toán thống kê
    stats = {
        'total': len(processed_rows),
        'debit': 0,
        'credit': 0,
        'pending': 0,
        'largest': 0,
        'smallest': float('inf'),
        'types': {},
        'branches': {}
    }
    
    for row in processed_rows:
        try:
            row.extend([None] * (7 - len(row)))
            
            amount = row[2]
            direction = str(row[3]).strip().title() if row[3] else ""
            trans_type = str(row[5]).strip() if row[5] else "Unknown"
            branch = str(row[6]).strip() if row[6] else "Unknown"
            
            if amount is None or str(amount).strip() == '':
                stats['pending'] += 1
                continue
                
            if isinstance(amount, str):
                amount = float(amount.replace('₽', '').replace(',', '').strip())
            
            if direction == 'Debit':
                stats['debit'] += amount
            elif direction == 'Credit':
                stats['credit'] += amount
                
            stats['largest'] = max(stats['largest'], amount)
            stats['smallest'] = min(stats['smallest'], amount)
            
            stats['types'][trans_type] = stats['types'].get(trans_type, 0) + 1
            stats['branches'][branch] = stats['branches'].get(branch, 0) + 1
            
        except Exception as e:
            print(f"Error processing row: {e}")
            continue
    
    net_flow = stats['credit'] - stats['debit']
    avg_trans = (stats['debit'] + stats['credit']) / max(1, stats['total'] - stats['pending'])
    
    layout = MDBoxLayout(
        orientation="vertical",
        spacing=dp(5),
        padding=[dp(10), dp(10), dp(10), dp(5)], 
        size_hint=(1, None),  # Thay đổi ở đây
        height=Window.height * 0.8  # Chiếm 90% chiều cao màn hình
        
    )
    
    header = MDBoxLayout(
        orientation="vertical",
        spacing=dp(2),
        size_hint_y=None,
        height=dp(60),
        padding=dp(5),
        md_bg_color=(0.5, 0.2, 0.6, 1)
    )
    
    bank_label = MDLabel(
        text="[size=22][color=ffffff][b]DTNB BANK[/b][/color][/size]",
        halign="center",
        markup=True,
        size_hint_y=None,
        height=dp(30),
        padding=[0, dp(11), 0, 0])
    
    report_label = MDLabel(
        text=f"[size=20][color=ffffff][b]{title}[/b][/color][/size]",
        halign="center",
        markup=True,
        size_hint_y=None,
        height=dp(30),
        padding=[0, dp(4), 0, 0])
    
    header.add_widget(MDBoxLayout(size_hint_y=None, height=dp(10)))
    header.add_widget(bank_label)
    header.add_widget(report_label)
    layout.add_widget(header)
    
    stats_card = MDCard(
        orientation="vertical",
        size_hint=(1, None),
        height=dp(90),
        padding=dp(15),
        elevation=4,
        radius=[15,],
        md_bg_color=(0.95, 0.95, 0.95, 1))
    
    stats_row1 = MDBoxLayout(orientation="horizontal", spacing=dp(10))
    stats_items1 = [
        f"[b]Total:[/b] {stats['total']}",
        f"[b]Debit:[/b] {stats['debit']:,.0f} ₽",
        f"[b]Credit:[/b] {stats['credit']:,.0f} ₽",
        f"[b]Net Flow:[/b] {net_flow:+,.0f} ₽"
    ]
    for item in stats_items1:
        stats_row1.add_widget(MDLabel(
            text=f"[size=16]{item}[/size]",
            markup=True,
            halign="center",
            size_hint_x=1/len(stats_items1)))
    
    stats_row2 = MDBoxLayout(orientation="horizontal", spacing=dp(10))
    stats_items2 = [
        f"[b]Avg. Amount:[/b] {avg_trans:,.0f} ₽",
        f"[b]Largest:[/b] {stats['largest']:,.0f} ₽",
        f"[b]Smallest:[/b] {stats['smallest']:,.0f} ₽",
        f"[b]Pending:[/b] {stats['pending']}"
    ]
    for item in stats_items2:
        stats_row2.add_widget(MDLabel(
            text=f"[size=16]{item}[/size]",
            markup=True,
            halign="center",
            size_hint_x=1/len(stats_items2)))
    
    stats_card.add_widget(stats_row1)
    stats_card.add_widget(stats_row2)
    layout.add_widget(stats_card)
    
    formatted_rows = []
    for row in processed_rows:
        try:
            trans_id = str(row[0]) if row[0] else "N/A"
            trans_time = str(row[1]) if row[1] else "N/A"
            
            amount = row[2]
            if amount is None or str(amount).strip() == '':
                amount_str = "[color=ff0000]Pending[/color]"
            else:
                if isinstance(amount, str):
                    amount = float(amount.replace('₽', '').replace(',', '').strip())
                amount_str = f"{amount:,.0f} ₽"
            
            direction = str(row[3]).title() if row[3] else ""
            if direction == 'Debit':
                amount_str = f"[color=ff0000]{amount_str} ▼[/color]"
            elif direction == 'Credit':
                amount_str = f"[color=00aa00]{amount_str} ▲[/color]"
            
            trans_type = str(row[5]) if row[5] else "N/A"
            branch = str(row[6]) if row[6] else "N/A"
            
            formatted_rows.append([
                f"[font=RobotoMono-Regular]{trans_id}[/font]",
                trans_time,
                amount_str,
                trans_type,
                branch
            ])
        except Exception as e:
            print(f"Error formatting row: {e}")
            continue
    
    table = MDDataTable(
        size_hint=(1, None),
        height=Window.height * 0.5, 
        
        column_data=[
            ("[b]Transaction ID[/b]", dp(50)),
            ("[b]Date & Time[/b]", dp(50)),
            ("[b]Amount[/b]", dp(50)),
            ("[b]Type[/b]", dp(40)),
            ("[b]Branch[/b]", dp(40))
        ],
        row_data=formatted_rows,
        rows_num=10,
        elevation=2,
        background_color_header= "#8e24aa",
        background_color_cell="#ffffff",
        background_color_selected_cell="#f3e5f5",
        use_pagination=True,
        padding=dp(10),
        check=True,
        sorted_on="Date & Time",
        sorted_order="DSC"
    )
    layout.add_widget(table)
    
    footer = MDBoxLayout(
        orientation="horizontal",
        size_hint_y=None,
        height=dp(40),
        spacing=dp(10))
    
    page_info = MDLabel(
        text=f"Page 1 of {max(1, len(formatted_rows)//10 + 1)}",
        size_hint_x=None,
        width=dp(150))
    
    timestamp = MDLabel(
        text=f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
        halign="right",
        size_hint_x=0.6)
    
    system_info = MDLabel(
        text="DTNB Core Banking System",
        halign="right",
        size_hint_x=0.4)
    
    footer.add_widget(page_info)
    footer.add_widget(timestamp)
    footer.add_widget(system_info)
    layout.add_widget(footer)
    
    dialog = MDDialog(
        type="custom",
        content_cls=layout,
        size_hint=(0.95, None),
        height=Window.height * 0.9,  # Hoặc giá trị phù hợp
        auto_dismiss=False,
        buttons=[
            MDRaisedButton(
                text="EXPORT",
                on_release=lambda x: export_report(formatted_rows, stats)),
            MDRaisedButton(
                text="CLOSE",
                on_release=lambda x: close_and_go_back(dialog, on_close_callback))
        ])
    dialog.open()
    return dialog

def close_and_go_back(dialog, callback):
    dialog.dismiss()
    if callback:
        callback()

def export_report(data, stats):
    # Hàm xuất báo cáo (placeholder)
    print("Export function will be implemented here")
