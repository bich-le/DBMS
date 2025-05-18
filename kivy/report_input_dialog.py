from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDRaisedButton
from kivymd.uix.textfield import MDTextField
from kivymd.uix.boxlayout import MDBoxLayout
from report_result_dialog import show_result_dialog
from kivy.metrics import dp
import mysql.connector
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

class ContentInputBase(MDBoxLayout):
    """Base class for all report input content"""
    def __init__(self, **kwargs):
        super().__init__(orientation="vertical", spacing=dp(10), padding=dp(20), 
                       adaptive_height=True, **kwargs)

class ContentAllTransaction(ContentInputBase):
    def __init__(self, date_from, date_to, **kwargs):
        super().__init__(**kwargs)
        self.add_widget(date_from)
        self.add_widget(date_to)

class ContentBranchTransaction(ContentInputBase):
    def __init__(self, branch_input, date_from, date_to, **kwargs):
        super().__init__(**kwargs)
        self.add_widget(branch_input)
        self.add_widget(date_from)
        self.add_widget(date_to)

class ContentSuspiciousTransaction(ContentInputBase):
    def __init__(self, suspicion_threshold, date_from, date_to, **kwargs):
        super().__init__(**kwargs)
        self.add_widget(suspicion_threshold)
        self.add_widget(date_from)
        self.add_widget(date_to)

class ContentAccountSummary(ContentInputBase):
    def __init__(self, account_type, as_of_date, **kwargs):
        super().__init__(**kwargs)
        self.add_widget(account_type)
        self.add_widget(as_of_date)

class ContentCustomerSummary(ContentInputBase):
    def __init__(self, branch_input, **kwargs):
        super().__init__(**kwargs)
        self.add_widget(branch_input)

class ReportInputDialog:
    def __init__(self, report_type):
        self.report_type = report_type
        self.dialog = None
        logger.info(f"Initialized dialog for report type: {report_type}")

    def open(self):
        try:
            build_method = getattr(self, f"build_{self.report_type}_dialog", None)
            if not build_method:
                raise ValueError(f"Unknown report type: {self.report_type}")
            
            self.dialog = build_method()
            self.dialog.open()
            logger.info(f"Opened {self.report_type} dialog successfully")
        except Exception as e:
            logger.error(f"Failed to open dialog: {str(e)}")
            self._show_error_dialog(f"Failed to open dialog: {str(e)}")

    def _create_input_field(self, hint_text, **kwargs):
        return MDTextField(
            hint_text=hint_text,
            size_hint_y=None,
            height=dp(60),
            multiline=False,
            **kwargs
        )

    def build_branch_transaction_dialog(self):
        self.branch_input = self._create_input_field("Branch ID (e.g., HN)")
        self.date_from = self._create_input_field("From Date (YYYY-MM-DD)")
        self.date_to = self._create_input_field("To Date (YYYY-MM-DD)")

        content = ContentBranchTransaction(
            branch_input=self.branch_input,
            date_from=self.date_from,
            date_to=self.date_to
        )

        return MDDialog(
            title="Branch Transaction Report",
            type="custom",
            content_cls=content,
            buttons=[self._create_generate_button()]
        )

    def build_all_transaction_dialog(self):
        self.date_from = self._create_input_field("From Date (YYYY-MM-DD)")
        self.date_to = self._create_input_field("To Date (YYYY-MM-DD)")

        content = ContentAllTransaction(
            date_from=self.date_from,
            date_to=self.date_to
        )

        return MDDialog(
            title="All Transaction History Report",
            type="custom",
            content_cls=content,
            buttons=[self._create_generate_button()]
        )

    def build_suspicious_transaction_dialog(self):
        self.suspicion_threshold = self._create_input_field("Threshold Amount (e.g., 1000000)")
        self.date_from = self._create_input_field("From Date (YYYY-MM-DD)")
        self.date_to = self._create_input_field("To Date (YYYY-MM-DD)")

        content = ContentSuspiciousTransaction(
            suspicion_threshold=self.suspicion_threshold,
            date_from=self.date_from,
            date_to=self.date_to
        )

        return MDDialog(
            title="Suspicious Transaction Report",
            type="custom",
            content_cls=content,
            buttons=[self._create_generate_button()]
        )

    def build_account_summary_dialog(self):
        self.account_type = self._create_input_field("Account Type (e.g., Savings)")
        self.as_of_date = self._create_input_field("As Of Date (YYYY-MM-DD)")

        content = ContentAccountSummary(
            account_type=self.account_type,
            as_of_date=self.as_of_date
        )

        return MDDialog(
            title="Account Summary Report",
            type="custom",
            content_cls=content,
            buttons=[self._create_generate_button()]
        )

    def build_customer_summary_dialog(self):
        self.branch_input = self._create_input_field("Branch ID (e.g., HN)")

        content = ContentCustomerSummary(
            branch_input=self.branch_input
        )

        return MDDialog(
            title="Customer Summary Report",
            type="custom",
            content_cls=content,
            buttons=[self._create_generate_button()]
        )

    def _create_generate_button(self):
        return MDRaisedButton(
            text="Generate Report",
            on_release=lambda x: self._handle_generate_report()
        )

    def _handle_generate_report(self):
        try:
            logger.info("Generate report button clicked")
            self.generate_report()
        except Exception as e:
            logger.error(f"Error generating report: {str(e)}")
            self._show_error_dialog(f"Error generating report: {str(e)}")

    def _test_db_connection(self):
        """Test database connection"""
        try:
            conn = mysql.connector.connect(
                host="localhost",
                user="dong",
                password="44444444",
                database="main",
                connect_timeout=3
            )
            conn.ping(reconnect=True, attempts=3)
            conn.close()
            logger.info("Database connection test: SUCCESS")
            return True
        except mysql.connector.Error as err:
            logger.error(f"Database connection FAILED: {err}")
            self._show_error_dialog(f"Database error: {err.msg}")
            return False

    def _get_report_parameters(self):
        """Get parameters for stored procedure based on report type"""
        try:
            if self.report_type == "branch_transaction":
                if not all([self.branch_input.text.strip(), self.date_from.text.strip(), self.date_to.text.strip()]):
                    raise ValueError("Please fill all fields: Branch ID, From Date, To Date")
                return (
                    "sp_branch_transaction_report",
                    [self.branch_input.text.strip(), self.date_from.text.strip(), self.date_to.text.strip()]
                )
            elif self.report_type == "all_transaction":
                if not all([self.date_from.text.strip(), self.date_to.text.strip()]):
                    raise ValueError("Please fill both date fields")
                return (
                    "sp_all_transaction_history",
                    [self.date_from.text.strip(), self.date_to.text.strip()]
                )
            elif self.report_type == "suspicious_transaction":
                if not all([self.suspicion_threshold.text.strip(), self.date_from.text.strip(), self.date_to.text.strip()]):
                    raise ValueError("Please fill all fields: Threshold, From Date, To Date")
                return (
                    "sp_suspicion_report",
                    [self.suspicion_threshold.text.strip(), self.date_from.text.strip(), self.date_to.text.strip()]
                )
            elif self.report_type == "account_summary":
                if not all([self.account_type.text.strip(), self.as_of_date.text.strip()]):
                    raise ValueError("Please fill both account type and date")
                return (
                    "sp_account_summary_report",
                    [self.account_type.text.strip(), self.as_of_date.text.strip()]
                )
            elif self.report_type == "customer_summary":
                if not self.branch_input.text.strip():
                    raise ValueError("Please enter branch ID")
                return (
                    "sp_customer_summary_by_branch",
                    [self.branch_input.text.strip()]
                )
            else:
                raise ValueError("Invalid report type")
        except ValueError as ve:
            self._show_error_dialog(str(ve))
            return None
        except Exception as e:
            logger.error(f"Error getting parameters: {e}")
            self._show_error_dialog("Error processing input parameters")
            return None

    def _process_result_rows(self, rows):
        """Convert datetime objects to strings"""
        processed_rows = []
        for row in rows:
            processed_row = []
            for value in row.values() if isinstance(row, dict) else row:
                if isinstance(value, datetime):
                    processed_row.append(value.strftime('%Y-%m-%d %H:%M:%S'))
                else:
                    processed_row.append(str(value))
            processed_rows.append(tuple(processed_row))
        return processed_rows

    def _execute_stored_procedure(self, proc_name, params):
        """Execute stored procedure and return results"""
        conn = None
        try:
            conn = mysql.connector.connect(
                host="localhost",
                user="dong",
                password="44444444",
                database="main",
                autocommit=True
            )
            cursor = conn.cursor(dictionary=True)
            
            logger.debug(f"Executing {proc_name} with params: {params}")
            cursor.callproc(proc_name, params)
            
            results = []
            for result in cursor.stored_results():
                columns = [desc[0] for desc in result.description]
                rows = result.fetchall()
                results.append((columns, rows))
                logger.debug(f"Retrieved {len(rows)} rows")
            
            if not results:
                raise Exception("No results returned from procedure")
                
            return results[0]
            
        except mysql.connector.Error as err:
            logger.error(f"Database error during execution: {err}")
            raise Exception(f"Database operation failed: {err.msg}")
        finally:
            if conn and conn.is_connected():
                cursor.close()
                conn.close()

    def generate_report(self):
        """Main report generation handler"""
        try:
            logger.info(f"Starting report generation for {self.report_type}")
            
            # 1. Verify database connection
            if not self._test_db_connection():
                return
                
            # 2. Get parameters
            proc_params = self._get_report_parameters()
            if not proc_params:
                return
                
            proc_name, params = proc_params
            logger.debug(f"Procedure: {proc_name}, Params: {params}")
            
            # 3. Execute procedure
            columns, rows = self._execute_stored_procedure(proc_name, params)
            logger.debug(f"Received {len(rows)} rows of data")
            
            # 4. Process data for display
            processed_rows = self._process_result_rows(rows)
            
            # 5. Show results
            show_result_dialog(
                f"{self.report_type.replace('_', ' ').title()} Results",
                columns,
                processed_rows
            )
            
        except Exception as e:
            logger.error(f"Report generation failed: {e}")
            self._show_error_dialog(f"Report generation error: {str(e)}")
        finally:
            if self.dialog:
                self.dialog.dismiss()

    def _show_error_dialog(self, message):
        """Show error dialog with custom styling"""
        error_dialog = MDDialog(
            title="[color=ff0000]ERROR[/color]",
            text=f"[size=16][b]Details:[/b][/size]\n{message}",
            buttons=[
                MDRaisedButton(
                    text="CLOSE",
                    theme_text_color="Custom",
                    text_color="white",
                    md_bg_color="#ff5252",
                    on_release=lambda x: error_dialog.dismiss()
                )
            ],
            type="custom",
            md_bg_color="#ffebee",
            radius=[20, 7, 20, 7]
        )
        error_dialog.open()