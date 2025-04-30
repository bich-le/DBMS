import tkinter as tk
from tkinter import messagebox
class CustomerAccount:
    def __init__(self, customer_id, fname, lname, address, phone, gender, account_no, acc_type, balance):
        self.customer_id = customer_id
        self.fname = fname
        self.lname = lname
        self.address = address
        self.phone = phone
        self.gender = gender
        self.account_no = account_no
        self.acc_type = acc_type
        self.balance = float(balance)

        if acc_type.lower() == 'business':
            self.overdraft_limit = 25
        elif acc_type.lower() == 'savings':
            self.overdraft_limit = 50
        else:
            self.overdraft_limit = 0  # default fallback

    # Update methods
    def update_first_name(self, fname):
        self.fname = fname

    def update_last_name(self, lname):
        self.lname = lname

    def update_address(self, addr):
        self.address = addr

    def update_phone(self, phone):
        self.phone = phone

    # Getter methods
    def get_first_name(self):
        return self.fname

    def get_last_name(self):
        return self.lname

    def get_address(self):
        return self.address

    def get_phone(self):
        return self.phone

    def get_gender(self):
        return self.gender

    def get_acc_no(self):
        return self.account_no

    def get_account_type(self):
        return self.acc_type

    def get_balance(self):
        return self.balance

    # Banking operations
    def deposit(self, amount):
        self.balance += amount

    def withdraw(self, amount):
        self.balance -= amount

    def print_balance(self):
        print(f"\n The account balance is {self.balance:.2f}")
