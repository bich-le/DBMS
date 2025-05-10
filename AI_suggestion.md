# 📋 GUI Development Plan for Banking Management System (KivyMD)

## Phase 0 – Setup (Done or Ongoing)
- [x] Connect to MySQL database.
- [x] Verify login credentials and determine role (Teller, Manager, Auditor, Director).
- [x] Basic `MainScreen` for login and role-based routing.

---

## Phase 1 – Core Screen Routing (Basic Functional Navigation)
🎯 **Goal:** Each role lands on a screen with layout and main action buttons.

- [x] `TellerScreen` (welcome + back)
- [x] `ManagerScreen` (welcome + back)
- [x] `AuditorScreen` (welcome + back)
- [x] `DirectorScreen` with buttons:
  - Customers
  - Employees
  - Transactions
  - Reports
  - Suspicion
  - System history

---

## Phase 2 – Customers Management
🎯 **Goal:** Allow Director to add/edit/delete/view customers

- [ ] Add `CustomerScreen`
- [ ] Display customer list (MDDataTable or ListView)
- [ ] Create form for adding/editing customer info
- [ ] Delete button with confirmation
- [ ] Connect to `Customers` table in DB

---

## Phase 3 – Account & Transaction Handling
🎯 **Goal:** Teller can open account, deposit, withdraw, and transfer

- [ ] Add buttons for account operations in `TellerScreen`
- [ ] Form to input `CustomerID`, initial balance, open date
- [ ] Create `TransactionScreen` with:
  - [ ] Account selection
  - [ ] Input for deposit/withdraw/transfer
- [ ] Execute `INSERT` into `Transactions` table
- [ ] Automatically update `Balance` in `Accounts` table
- [ ] (Optional) Use stored procedures in MySQL

---

## Phase 4 – Reporting
🎯 **Goal:** Managers/Directors can view transaction summaries and suspicious patterns

- [ ] Create `ReportScreen`
- [ ] Interface to filter by date or account
- [ ] Display:
  - Total transactions
  - Total inflow/outflow
- [ ] Highlight suspicious transactions (large amounts, unusual frequency)

---

## Phase 5 – Employee & Branch Management
🎯 **Goal:** Allow Managers/Directors to manage employees and branches

- [ ] `EmployeeScreen` with list and form to add/edit/delete employees
- [ ] `BranchScreen` for branch data management
- [ ] Connect to `EMPLOYEES` and `BRANCHES` tables
- [ ] Add confirmation dialogs

---

## Phase 6 – System & Access Control
🎯 **Goal:** Manage account status and track activity logs

- [ ] Add "System History" screen for Directors
- [ ] Lock/Unlock employee accounts
- [ ] Log activity such as login, transaction creation

---

## Phase 7 – UI Cleanup & Styling (Optional)
🎯 **Goal:** Polish UI/UX if time allows

- [ ] Harmonize colors, spacing, and fonts
- [ ] Add icons and more descriptive labels
- [ ] Responsive layout handling
- [ ] Loading spinners on network actions
- [ ] Snackbars or dialogs for success/error feedback

---
project_folder/
├── main.py
├── my.kv                      # chứa <MainScreen>
├── director_screen.py
├── director_screen.kv
├── manager_screen.py
├── manager_screen.kv
├── teller_screen.py
├── teller_screen.kv
├── auditor_screen.py
├── auditor_screen.kv

# làm code login chạy nhanh hơn nhưng đang không dùng cursor
import threading

def login(self):
    username = self.ids.username.text
    password = self.ids.password.text

    def do_login():
        app = MDApp.get_running_app()
        result = app.verify_login_and_get_position(username, password)
        if result:
            status = result['status']
            position = result['emp_position']
            if status == 'Active':
                self.goto_position(position.lower())
            else:
                self.show_login_error_dialog(f"Account status: {status}")
        else:
            self.show_login_error_dialog("Wrong login information.")
    
    threading.Thread(target=do_login).start()

def goto_position(self, screen_name):
    from kivy.clock import Clock
    Clock.schedule_once(lambda dt: self._goto(screen_name), 0)

def _goto(self, screen_name):
    app = MDApp.get_running_app()
    app.root.transition.direction = "left"
    app.root.current = screen_name
