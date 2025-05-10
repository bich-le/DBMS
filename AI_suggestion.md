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