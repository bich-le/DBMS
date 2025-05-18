# report_config.py

from kivy.metrics import dp

REPORT_CONFIGS = {
    'transaction_report': {
        'title': 'All Transactions',
        'columns': [
            ("[b]Transaction ID[/b]", dp(50)),
            ("[b]Date & Time[/b]", dp(50)),
            ("[b]Amount[/b]", dp(50)),
            ("[b]Type[/b]", dp(40)),
            ("[b]Branch[/b]", dp(40)),
        ]
    },
    'branch_transaction_report': {
        'title': 'Branch Transactions',
        'columns': [
            ("[b]Transaction ID[/b]", dp(50)),
            ("[b]Date & Time[/b]", dp(50)),
            ("[b]Amount[/b]", dp(50)),
            ("[b]Type[/b]", dp(40)),
            ("[b]Branch[/b]", dp(40)),
        ]
    },
    'account_summary': {
        'title': 'Account Summary',
        'columns': [
            ("[b]Account ID[/b]", dp(50)),
            ("[b]Holder[/b]", dp(50)),
            ("[b]Total Balance[/b]", dp(50)),
            ("[b]Open Date[/b]", dp(40)),
        ]
    },
    'customer_summary': {
        'title': 'Customer Summary',
        'columns': [
            ("[b]Customer ID[/b]", dp(50)),
            ("[b]Name[/b]", dp(50)),
            ("[b]Total Accounts[/b]", dp(50)),
            ("[b]Total Balance[/b]", dp(50)),
        ]
    },
    'suspicious_transactions': {
        'title': 'Suspicious Transactions',
        'columns': [
            ("[b]Transaction ID[/b]", dp(50)),
            ("[b]Date[/b]", dp(50)),
            ("[b]Amount[/b]", dp(50)),
            ("[b]Reason[/b]", dp(70)),
        ]
    }
}
