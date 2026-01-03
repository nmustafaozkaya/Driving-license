import json
import logging
import os
import sys
import tempfile

from PyQt6.QtCore import Qt, QTimer
from PyQt6.QtGui import QColor, QFont, QPalette, QPixmap, QIcon
from PyQt6.QtWidgets import (
    QApplication,
    QComboBox,
    QDialog,
    QFileDialog,
    QFrame,
    QGridLayout,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QMessageBox,
    QPushButton,
    QScrollArea,
    QSplitter,
    QStackedWidget,
    QTextEdit,
    QVBoxLayout,
    QWidget,
    QSizePolicy,
    QSpacerItem,
)
import firebase_admin
from firebase_admin import credentials, firestore, storage

# Firebase log seviyesini ayarla
logging.getLogger('firebase_admin').setLevel(logging.ERROR)
logging.getLogger('google.cloud').setLevel(logging.ERROR)

# Firebase servis anahtarı
SERVICE_ACCOUNT_KEY = {
    "type": "service_account",
    "project_id": "driver-lisances",
    "private_key_id": "98de2e2d51861689700d76b00df534b6ed0f50b1",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDJvh0eLrTefJTU\nx2DtMz3yZ/r7UZmQw9TdhCSSda9jvSdmIOS+wiW6QDvf08ndkFdvJtzthUZGk9Iu\nOoxHsG3jqnQXx5ULaLdOtS4HevL803+LwnLa9jRfi91XdoZboMYw48Hdjra1cLro\nKSaAXVxoXlTZ84R3rDuKWnhANQrTHQoBBdLD7DBEgSxGy3HZAXM9wYSB+WkPQ6uO\ncpQQ1p3s56f7VGUsa5krpl0oLlr/VafyXML0ixITTgFAtKtumGSAA2jJ6il+q5ZY\n4TMGNTukHa2ckftNdPKfYdvyJS7/ZbXmoPfCFuOEawAzJg85UjCHG805V8bH1XLk\nd39x7HpHAgMBAAECggEAUkAr//O78x+o0E2Pc3XaUjvZhGBi8zYcUcn/3SSVAt2K\nNCXCDRH7rsFkh9+BpE8mjp8yILafDcRTw1xEeC/yxYjntxA8cH/biH/uycbzTWfv\nTuxSxnntpWzRK8kbgzz7wNAC6NE4JaZV1bR9SYWG2Nho0MlrXx090y0KbOcTSDmL\nZK/Eqip7j4tbOf6POiyFT9DC0eqUhpRczmE1T86QuT7z6znd5EZ3fhIdSpholfTm\nmMey/fNEFWFda8AQvZavJMdDUzSNHm7u4N1GmOFdO5o2H1++EPvAnb5pUB7YKI2k\nUm484lUV5X6+pIorh5SS1yGpZegMSw30TMRUrol49QKBgQD0Bi/l8faoB7PUs0gG\nf2j+rtNvpOr6lCd7fBVmjXPh6NBtMDGTsiBQnpsLSWn3wVt0fAC92/k9JUG+1FgG\n3GfIwyCMsjm1d6GoLzVaSjz8A8N+0yYJtKiU1Fr1LsXmS5gxhWX6KWxhTaQGzuuI\nITv2KVIcIFAwqHvdSRR6j4u5zQKBgQDTpLhMFbgtjsX3hyforoxMENLusOc4yFWM\n6NNJM8TDJ9hsrOQK1UbaumoCpIqX3fw6FfxnTgUJ00T56INJuO05C0xRJ1nC1hf6\nV5noEmylsXqX2zDh0wiRWAGvG1MOUkePsb047Rbn9XURzR0jJHvSMd0ZDRjUkNWw\nT9u+xFIgYwKBgF4/hYBqU7nSP8KG++qGiybSnxcfuyHM1vL6mcliGL/IC7ggRQWm\nZpS8rWVOlX77TzdOLXsm2ryjByGNIfKEbhE8S/YLX/6Wlfk/Qnv88FDlozv4kVhu\nTi4tVnQb/JNV3xJBU4GrPhDWy+NVR+Lr8xzAGNaEJHSmnjB5aU9s4aqBAoGAN+nS\njrdGOzL29hgM4RoMEqR3NXwi+gtjHqD8AODeYLiMItniPUJvP6X0D9Ksksagti/M\nyPYBusDH/kYBOV7TvThQ5zfALQsmtoqiLH+BmJy0yJ2t4ltAbjWT7FEJtkTihwHr\n/bgVTx632QYZZoli9PsbcFzXbID/E19lrJZtJAUCgYAuItd0vaSvtJomKRIcWITc\nU65F9HPoFvcDNPUOGBAeHvfx1z72LRMitXsYoctviCLHFfDRdJK5sPU++ytBbuUs\n/L1KIeYGWpvEtBxqH/u33LPMiPKnolvaNVGeTcZaW/5CzDQRAhvc5nW4ngNGSmrw\nbIPTV5pL/Z4IwduA5eErww==\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-fbsvc@driver-lisances.iam.gserviceaccount.com",
    "client_id": "103173541271063886448",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40driver-lisances.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
}
# Firebase bağlantısı
def initialize_firebase():
    try:
        try:
            app = firebase_admin.get_app()
            return firestore.client()
        except ValueError:
            pass
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            json.dump(SERVICE_ACCOUNT_KEY, f)
            temp_file_path = f.name
        
        cred = credentials.Certificate(temp_file_path)
        firebase_admin.initialize_app(cred, {
            'storageBucket': 'driver-lisances.firebasestorage.app'
        })
        db = firestore.client()
        
        # Geçici dosyayı sil
        os.unlink(temp_file_path)
        
        return db
    except Exception as e:
        return None

db = initialize_firebase()

# Firebase Storage bucket referansı
bucket = None
# Pencere referanslarını tutmak için basit bir kayıt
OPEN_WINDOWS: list = []

def keep_window(win: QWidget):
    try:
        OPEN_WINDOWS.append(win)
        try:
            win.destroyed.connect(lambda _=None, w=win: OPEN_WINDOWS.remove(w) if w in OPEN_WINDOWS else None)
        except Exception:
            pass
    except Exception:
        pass

if db:
    try:
        # Projenin varsayılan bucket'ını kullan
        bucket = storage.bucket()
        # Bucket var mı kontrol et
        try:
            if hasattr(bucket, "exists") and not bucket.exists():
                bucket = None
        except Exception as _e:
            pass
    except Exception as e:
        pass

def get_window_size(base_width=1280, base_height=720):
    """Ekran çözünürlüğüne göre pencere boyutunu hesaplar
    Örnek: 1920x1080 ekranda 1280x720 boyutunu döndürür
    """
    try:
        # QApplication instance'ı al
        app = QApplication.instance()
        if app is None:
            # Eğer instance yoksa varsayılan değerleri döndür
            return base_width, base_height
        
        # Ana ekranı al
        screen = app.primaryScreen()
        if screen is None:
            return base_width, base_height
        
        # Ekran çözünürlüğünü al
        screen_size = screen.availableGeometry()
        screen_width = screen_size.width()
        screen_height = screen_size.height()
        
        # Oranı hesapla (1280/1920 = 0.6667, 720/1080 = 0.6667)
        # Ekran çözünürlüğünün %66.7'sini kullan
        ratio = 0.6667
        
        # Pencere boyutlarını hesapla
        window_width = int(screen_width * ratio)
        window_height = int(screen_height * ratio)
        
        # Minimum ve maksimum boyutları kontrol et
        # Küçük çözünürlükler için minimum boyutları ekran boyutuna göre ayarla
        # Ekran çözünürlüğünün %50'si kadar minimum, ama en az 640x480
        min_width = max(640, int(screen_width * 0.5))
        min_height = max(480, int(screen_height * 0.5))
        max_width, max_height = int(screen_width * 0.95), int(screen_height * 0.95)
        
        window_width = max(min_width, min(window_width, max_width))
        window_height = max(min_height, min(window_height, max_height))
        
        return window_width, window_height
    except Exception as e:
        # Hata durumunda varsayılan değerleri döndür
        return base_width, base_height

def get_window_position(window_width, window_height):
    """Pencereyi ekranın ortasına yerleştirmek için pozisyon hesaplar"""
    try:
        app = QApplication.instance()
        if app is None:
            return 100, 50
        
        screen = app.primaryScreen()
        if screen is None:
            return 100, 50
        
        screen_size = screen.availableGeometry()
        screen_width = screen_size.width()
        screen_height = screen_size.height()
        
        # Pencereyi ortala
        x = (screen_width - window_width) // 2
        y = (screen_height - window_height) // 2
        
        return x, y
    except Exception:
        return 100, 50

def dosya_yukle_firebase_storage(dosya_yolu, klasor_adi="sorular"):
    """Dosyayı Firebase Storage'a yükler ve URL döndürür"""
    if not bucket:
        return None
    
    try:
        # Dosya var mı kontrol et
        if not os.path.exists(dosya_yolu):
            return None
        
        # Dosya adını oluştur
        import uuid, mimetypes
        dosya_adi = f"{klasor_adi}/{uuid.uuid4()}_{os.path.basename(dosya_yolu)}"
        
        # Dosyayı yükle
        blob = bucket.blob(dosya_adi)
        content_type, _ = mimetypes.guess_type(dosya_yolu)
        if not content_type:
            content_type = "application/octet-stream"
        # Firebase Storage download token ayarla (herkese açık yapmadan erişim için)
        download_token = str(uuid.uuid4())
        blob.metadata = {"firebaseStorageDownloadTokens": download_token}
        blob.upload_from_filename(dosya_yolu, content_type=content_type)
        
        # Firebase'in standart indirme URL'si (token'lı)
        try:
            from urllib.parse import quote
            encoded_path = quote(dosya_adi, safe='')
            url = (
                f"https://firebasestorage.googleapis.com/v0/b/{bucket.name}/o/{encoded_path}?alt=media&token={download_token}"
            )
        except Exception as e:
            url = None
        
        return url
        
    except Exception as e:
        return None

def show_modern_message(parent, title, message, is_question=False):
    """Modern mesaj kutusu gösterir"""
    dialog = QDialog(parent)
    dialog.setWindowTitle(title)
    dialog.setModal(True)
    dialog.setFixedSize(450, 220)
    
    # Modern stil
    dialog.setStyleSheet("""
        QDialog {
            background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #ffffff, stop:1 #f8fafc);
            border-radius: 12px;
        }
        QLabel {
            color: #1e293b;
            font-size: 14px;
            font-weight: 500;
        }
        QPushButton {
            font-size: 13px;
            font-weight: 600;
            padding: 10px 24px;
            border-radius: 8px;
            min-height: 40px;
            border: none;
        }
    """)
    
    layout = QVBoxLayout()
    layout.setSpacing(20)
    layout.setContentsMargins(30, 30, 30, 30)
    
    # Mesaj
    msg_label = QLabel(message)
    msg_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
    msg_label.setWordWrap(True)
    layout.addWidget(msg_label)
    
    # Butonlar
    btn_layout = QHBoxLayout()
    btn_layout.setSpacing(12)
    
    if is_question:
        # Evet butonu
        yes_btn = QPushButton("Evet")
        yes_btn.setStyleSheet("""
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #10b981, stop:1 #059669);
                color: white;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #34d399, stop:1 #10b981);
            }
            QPushButton:pressed {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #059669, stop:1 #047857);
            }
        """)
        yes_btn.clicked.connect(lambda: dialog.accept())
        btn_layout.addWidget(yes_btn)
        
        # Hayır butonu
        no_btn = QPushButton("Hayır")
        no_btn.setStyleSheet("""
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #64748b, stop:1 #475569);
                color: white;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #94a3b8, stop:1 #64748b);
            }
            QPushButton:pressed {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #475569, stop:1 #334155);
            }
        """)
        no_btn.clicked.connect(lambda: dialog.reject())
        btn_layout.addWidget(no_btn)
    else:
        # Tamam butonu
        ok_btn = QPushButton("Tamam")
        ok_btn.setStyleSheet("""
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #6366f1, stop:1 #4f46e5);
                color: white;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #818cf8, stop:1 #6366f1);
            }
            QPushButton:pressed {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #4f46e5, stop:1 #4338ca);
            }
        """)
        ok_btn.clicked.connect(lambda: dialog.accept())
        btn_layout.addWidget(ok_btn)
    
    layout.addLayout(btn_layout)
    dialog.setLayout(layout)
    
    # Pencereyi ortala
    if parent:
        parent_geometry = parent.geometry()
        dialog_x = parent_geometry.x() + (parent_geometry.width() - dialog.width()) // 2
        dialog_y = parent_geometry.y() + (parent_geometry.height() - dialog.height()) // 2
        dialog.move(dialog_x, dialog_y)
    
    return dialog.exec() == QDialog.DialogCode.Accepted

class AnaMenu(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Soru Yönetim Sistemi - Ana Menü")
        # Ekran çözünürlüğüne göre dinamik boyutlandırma
        width, height = get_window_size(1200, 700)
        x, y = get_window_position(width, height)
        self.setGeometry(x, y, width, height)
        self.current_panel = None
        # Çocuk pencereleri güçlü referanslarla tut
        self.soru_panel = None
        self.duzenleme_panel = None
        # Uygulama ikonu ayarla
        self.setWindowIcon(QIcon("playstore.png"))
        self.init_ui()
    
    def init_ui(self):
        # Modern ana stil ayarları
        self.setStyleSheet("""
            QWidget {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1, 
                    stop:0 #f0f9ff, stop:0.5 #e0f2fe, stop:1 #dbeafe);
                font-family: 'Segoe UI', 'Arial', sans-serif;
            }
            QLabel#title {
                color: #1e40af;
                font-size: 32px;
                font-weight: 700;
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, 
                    stop:0 #ffffff, stop:1 #f8fafc);
                border-radius: 20px;
                padding: 25px 35px;
                border: none;
            }
            QPushButton#menuBtn {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #10b981, stop:1 #059669);
                color: white;
                border: none;
                border-radius: 16px;
                padding: 25px;
                font-size: 18px;
                font-weight: 600;
                min-height: 120px;
                min-width: 280px;
            }
            QPushButton#menuBtn:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #34d399, stop:1 #10b981);
            }
            QPushButton#menuBtn:pressed {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #059669, stop:1 #047857);
            }
        """)
        
        main_layout = QVBoxLayout()
        main_layout.setSpacing(35)
        main_layout.setContentsMargins(60, 60, 60, 60)
        
        # Modern başlık
        title = QLabel("Driving License\nQuestion Management System")
        title.setObjectName("title")
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        title.setWordWrap(False)
        main_layout.addWidget(title)
        
        main_layout.addStretch()
        
        # Menü butonları - Modern tasarım
        button_layout = QHBoxLayout()
        button_layout.setSpacing(50)
        
        # Sol buton - Soru Ekleme
        soru_ekle_btn = QPushButton("📝\nSORU EKLEME\n\nYeni sorular ekleyin\nve veritabanına kaydedin")
        soru_ekle_btn.setObjectName("menuBtn")
        soru_ekle_btn.clicked.connect(self.soru_ekleme_ac)
        button_layout.addWidget(soru_ekle_btn)
        
        # Sağ buton - Düzenleme
        duzenleme_btn = QPushButton("⚙️\nDÜZENLEME\n\nMevcut soruları\ndüzenleyin ve silin")
        duzenleme_btn.setObjectName("menuBtn")
        duzenleme_btn.setEnabled(True)
        duzenleme_btn.setStyleSheet("""
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #3b82f6, stop:1 #2563eb);
                color: #ffffff;
                border: none;
                border-radius: 16px;
                padding: 25px;
                font-size: 18px;
                font-weight: 600;
                min-height: 120px;
                min-width: 280px;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #60a5fa, stop:1 #3b82f6);
            }
            QPushButton:pressed {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #2563eb, stop:1 #1d4ed8);
            }
        """)
        duzenleme_btn.clicked.connect(self.duzenleme_ac)
        button_layout.addWidget(duzenleme_btn)
        
        main_layout.addLayout(button_layout)
        main_layout.addStretch()
        
        # Modern alt bilgi
        info_label = QLabel("💡 Veritabanı bağlantısı aktif" if db else "⚠️ Veritabanı bağlantısı yok")
        info_label.setStyleSheet("""
            color: #1e40af;
            font-size: 13px;
            font-weight: 500;
            text-align: center;
            background: qlineargradient(x1:0, y1:0, x2:1, y2:0, 
                stop:0 #ffffff, stop:1 #f1f5f9);
            padding: 12px 20px;
            border-radius: 12px;
            border: 1px solid #cbd5e1;
        """)
        info_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        main_layout.addWidget(info_label)
        
        self.setLayout(main_layout)
    
    def soru_ekleme_ac(self):
        panel = SoruEklemePaneli()
        keep_window(panel)
        panel.show()
        try:
            panel.raise_(); panel.activateWindow()
        except Exception:
            pass
        self.close()
    
    def duzenleme_ac(self):
        panel = DuzenlemePaneli()
        keep_window(panel)
        panel.show()
        try:
            panel.raise_(); panel.activateWindow()
        except Exception:
            pass
        self.close()
    
    def show_panel(self, panel):
        """Mevcut paneli kaldır ve yeni paneli göster"""
        if self.current_panel:
            self.current_panel.setParent(None)
        
        self.current_panel = panel
        self.current_panel.setParent(self)
        
        # Layout'u temizle ve yeni paneli ekle
        layout = self.layout()
        if layout:
            # Tüm widget'ları kaldır
            while layout.count():
                child = layout.takeAt(0)
                if child.widget():
                    child.widget().setParent(None)
            
            # Yeni paneli ekle
            layout.addWidget(panel)
            
        # Ana menü butonlarını ekle
        self.add_menu_buttons()
    
    def add_menu_buttons(self):
        """Ana menü butonlarını ekle"""
        if not self.current_panel:
            return
            
        # Alt kısma geri dön butonu ekle
        bottom_layout = QHBoxLayout()
        anasayfa_btn = QPushButton("🏠 Ana Menüye Dön")
        anasayfa_btn.setStyleSheet("""
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #6c757d, stop:1 #495057);
                color: white;
                border: 2px solid #495057;
                border-radius: 10px;
                padding: 10px 20px;
                font-size: 14px;
                font-weight: bold;
                margin: 10px;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #5a6268, stop:1 #343a40);
            }
        """)
        anasayfa_btn.clicked.connect(self.show_main_menu)
        bottom_layout.addWidget(anasayfa_btn)
        bottom_layout.addStretch()
        
        # Ana layout'a ekle
        main_layout = self.layout()
        if main_layout:
            main_layout.addLayout(bottom_layout)
    
    def show_main_menu(self):
        """Ana menüye dön"""
        if self.current_panel:
            self.current_panel.setParent(None)
            self.current_panel = None
        
        # Layout'u temizle
        layout = self.layout()
        if layout:
            while layout.count():
                child = layout.takeAt(0)
                if child.widget():
                    child.widget().setParent(None)
        
        # Ana menüyü yeniden oluştur
        self.init_ui()

class SoruEklemePaneli(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Soru Ekleme Paneli")
        # Ekran çözünürlüğüne göre dinamik boyutlandırma
        width, height = get_window_size(1400, 650)
        x, y = get_window_position(width, height)
        self.setGeometry(x, y, width, height)
        # Uygulama ikonu ayarla
        self.setWindowIcon(QIcon("playstore.png"))
        self.init_ui()
        
    def init_ui(self):
        # Modern stil ayarları
        self.setStyleSheet("""
            QWidget {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1, 
                    stop:0 #f0f9ff, stop:0.5 #e0f2fe, stop:1 #dbeafe);
                font-family: 'Segoe UI', 'Arial', sans-serif;
            }
            QLabel {
                color: #2d5a27;
                font-weight: bold;
                font-size: 10px;
                margin-bottom: 2px;
                padding: 1px;
            }
            QLineEdit, QTextEdit {
                border: 2px solid #e2e8f0;
                border-radius: 10px;
                padding: 10px;
                background-color: white;
                color: #1e293b;
                font-size: 13px;
                font-weight: normal;
                min-height: 15px;
                selection-background-color: #6366f1;
                selection-color: white;
            }
            QLineEdit:focus, QTextEdit:focus {
                border-color: #6366f1;
                background-color: #ffffff;
            }
            QTextEdit {
                color: #000000;
                background-color: white;
            }
            QLineEdit:focus, QTextEdit:focus {
                border-color: #2d5a27;
                background-color: #ffffff;
            }
            QLineEdit::placeholder, QTextEdit::placeholder {
                color: #999999;
                font-style: italic;
            }
            QComboBox {
                border: 2px solid #e2e8f0;
                border-radius: 10px;
                padding: 10px;
                background-color: white;
                color: #1e293b;
                font-size: 13px;
                font-weight: normal;
                min-height: 15px;
            }
            QComboBox:focus {
                border-color: #6366f1;
                background-color: #ffffff;
            }
            QComboBox::drop-down {
                border: none;
                width: 25px;
            }
            QComboBox::down-arrow {
                image: none;
                border-left: 4px solid transparent;
                border-right: 4px solid transparent;
                border-top: 4px solid #6366f1;
                margin-right: 8px;
            }
            QComboBox QAbstractItemView {
                border: 2px solid #e2e8f0;
                background-color: white;
                color: #1e293b;
                selection-background-color: #6366f1;
                selection-color: white;
                padding: 5px;
                border-radius: 8px;
            }
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #10b981, stop:1 #059669);
                color: white;
                border: none;
                border-radius: 10px;
                padding: 12px 24px;
                font-size: 13px;
                font-weight: 600;
                min-height: 36px;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #34d399, stop:1 #10b981);
            }
            QPushButton:pressed {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #059669, stop:1 #047857);
            }
            QPushButton#secondaryBtn {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #64748b, stop:1 #475569);
            }
            QPushButton#secondaryBtn:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #94a3b8, stop:1 #64748b);
            }
            QPushButton#dangerBtn {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #ef4444, stop:1 #dc2626);
            }
            QPushButton#dangerBtn:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #f87171, stop:1 #ef4444);
            }
            QFrame {
                background-color: white;
                border: none;
                border-radius: 8px;
                margin: 5px;
                padding: 15px;
            }
            QScrollArea {
                border: none;
                background-color: transparent;
            }
            /* Modern Scrollbar Stilleri */
            QScrollBar:vertical {
                background: #f1f5f9;
                width: 14px;
                border: none;
                border-radius: 7px;
                margin: 2px;
            }
            QScrollBar::handle:vertical {
                background: #cbd5e1;
                min-height: 30px;
                border-radius: 7px;
                margin: 2px;
            }
            QScrollBar::handle:vertical:hover {
                background: #94a3b8;
            }
            QScrollBar::handle:vertical:pressed {
                background: #64748b;
            }
            QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
                height: 0px;
            }
            QScrollBar::add-page:vertical, QScrollBar::sub-page:vertical {
                background: transparent;
            }
            QScrollBar:horizontal {
                background: #f1f5f9;
                height: 14px;
                border: none;
                border-radius: 7px;
                margin: 2px;
            }
            QScrollBar::handle:horizontal {
                background: #cbd5e1;
                min-width: 30px;
                border-radius: 7px;
                margin: 2px;
            }
            QScrollBar::handle:horizontal:hover {
                background: #94a3b8;
            }
            QScrollBar::handle:horizontal:pressed {
                background: #64748b;
            }
            QScrollBar::add-line:horizontal, QScrollBar::sub-line:horizontal {
                width: 0px;
            }
            QScrollBar::add-page:horizontal, QScrollBar::sub-page:horizontal {
                background: transparent;
            }
        """)
        
        # Ana layout
        main_layout = QVBoxLayout()
        main_layout.setSpacing(0)
        main_layout.setContentsMargins(0, 0, 0, 0)
        
        # LANDSCAPE LAYOUT: Scroll Area ile Yanlama Düzen
        scroll = QScrollArea()
        scroll_widget = QWidget()
        scroll_layout = QVBoxLayout()
        scroll_layout.setSpacing(5)  # Spacing azaltıldı
        scroll_layout.setContentsMargins(15, 0, 15, 10)  # Üst margin sıfırlandı
        
        # Modern başlık container
        header_container = QWidget()
        header_container.setStyleSheet("""
            QWidget {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #10b981, stop:1 #059669);
                border: none;
                border-radius: 12px;
                padding: 15px 20px;
            }
        """)
        header_layout = QHBoxLayout()
        header_layout.setSpacing(15)
        header_layout.setContentsMargins(0, 0, 0, 0)
        
        geri_btn = QPushButton("⬅️ Ana Menü")
        geri_btn.setStyleSheet("""
            QPushButton {
                background: rgba(255, 255, 255, 0.95);
                color: #059669;
                font-weight: 600;
                font-size: 13px;
                padding: 10px 20px;
                border: none;
                border-radius: 8px;
                min-height: 38px;
            }
            QPushButton:hover {
                background: rgba(255, 255, 255, 1);
                color: #047857;
            }
            QPushButton:pressed {
                background: rgba(255, 255, 255, 0.9);
            }
        """)
        geri_btn.clicked.connect(self.ana_menuye_don)
        header_layout.addWidget(geri_btn, alignment=Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignVCenter)
        
        header_layout.addStretch()
        
        baslik = QLabel("📝 SORU EKLEME PANELİ")
        baslik.setAlignment(Qt.AlignmentFlag.AlignCenter)
        baslik.setStyleSheet("""
            QLabel {
                font-size: 24px;
                font-weight: 700;
                color: #ffffff;
                background: transparent;
                border: none;
                padding: 0px;
            }
        """)
        header_layout.addWidget(baslik, stretch=1)
        header_layout.addStretch()
        
        header_container.setLayout(header_layout)
        scroll_layout.addWidget(header_container)
        
        # header_layout ve baslik'ı instance variable olarak sakla (SoruDuzenlemePaneli için)
        self.header_layout = header_layout
        self.baslik_label = baslik
        
        # Ana içerik çift sütunlu düzen
        content_splitter = QSplitter(Qt.Orientation.Horizontal)
        
        # Modern sol panel - Soru ve Cevaplar
        left_panel = QFrame()
        left_panel.setStyleSheet("""
            QFrame {
                border: 2px solid #e2e8f0;
                border-radius: 12px;
                padding: 0px;
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #f8fafc, stop:1 #f1f5f9);
            }
        """)
        left_layout = QVBoxLayout()
        left_layout.setSpacing(1)  # Çerçeveler arası boşluk azaltıldı
        left_layout.setContentsMargins(2, 0, 2, 2)  # Üst margin sıfırlandı
        
        # Soru girişi
        soru_label = QLabel("📝 Soru Metni:")
        soru_label.setStyleSheet("font-size: 20px; font-weight: bold; color: #2d5a27; margin: 0px; padding: 0px; border: none;")
        soru_label.setMaximumHeight(40)
        soru_label.setMaximumWidth(170)
        left_layout.addWidget(soru_label)
        self.soru_input = QTextEdit()
        self.soru_input.setMinimumHeight(150)
        self.soru_input.setMaximumHeight(250)
        self.soru_input.setFixedHeight(200)  # Sabit yükseklik azaltıldı
        self.soru_input.setPlaceholderText("Sorunuzu buraya detaylı ve net bir şekilde yazın. Soru açık, anlaşılır ve kapsamlı olmalıdır...")
        soru_font = QFont('Arial', 14)
        soru_font.setBold(True)
        self.soru_input.setFont(soru_font)
        # QTextEdit için özel stil
        self.soru_input.setStyleSheet("""
            QTextEdit {
                border: 2px solid #4a934a;
                border-radius: 6px;
                padding: 8px;
                background-color: white;
                color: #000000;
                font-family: 'Arial', sans-serif;
                font-size: 14px;
                font-weight: bold;
                min-height: 150px;
                max-height: 200px;
            }
            QTextEdit:focus {
                border-color: #2d5a27;
                background-color: #ffffff;
            }
        """)
        left_layout.addWidget(self.soru_input)
        
        # CEVAP SEÇENEKLERİ - Başlık ve doğru cevap seçimi yan yana
        cevap_header_layout = QHBoxLayout()
        cevap_header_layout.setSpacing(3)  # Spacing minimum
        cevap_header_layout.setContentsMargins(0, 0, 0, 0)  # Margin'ler 0
        
        cevap_header_layout.addStretch()
        cevaplar_baslik = QLabel("SORUNUN CEVAPLARINI GİRİNİZ")
        cevaplar_baslik.setStyleSheet("""
            QLabel {
                color: #28a745;
                font-weight: bold;
                font-size: 12px;
                padding: 1px 3px;
                margin: 0px;
                background-color: #e9f9ec;
                border: 1px solid #28a745;
                border-radius: 4px;
            }
        """)
        cevaplar_baslik.setAlignment(Qt.AlignmentFlag.AlignCenter)
        cevaplar_baslik.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed)
        cevaplar_baslik.setMaximumHeight(25)
        cevap_header_layout.addWidget(cevaplar_baslik)
        
        # Doğru cevap seçimi
        dogru_label = QLabel("✅ Doğru Cevap:")
        dogru_label.setStyleSheet("""
            QLabel {
                color: #28a745;
                font-weight: bold;
                font-size: 11px;
                padding: 1px 3px;
                margin: 0px;
                background-color: #e9f9ec;
                border: 1px solid #28a745;
                border-radius: 4px;
            }
        """)
        dogru_label.setMaximumHeight(25)
        cevap_header_layout.addWidget(dogru_label)
        
        cevap_secenekleri_layout = QVBoxLayout()
        cevap_secenekleri_layout.setSpacing(2)  # Spacing minimum
        cevap_secenekleri_layout.setContentsMargins(0, 0, 0, 0)  # Tüm margin'ler 0
        
        self.dogru_combo = QComboBox()
        self.dogru_combo.addItem("Lütfen seçiniz", None)  # Boş seçenek
        self.dogru_combo.addItems(["A", "B", "C", "D"])
        combo_font = QFont('Arial', 12)
        self.dogru_combo.setFont(combo_font)
        self.dogru_combo.setMinimumWidth(120)
        self.dogru_combo.setCurrentIndex(0)  # Boş seçeneğe sıfırla  # Varsayılan olarak boş seçenek
        cevap_header_layout.addWidget(self.dogru_combo)
        
        cevap_header_layout.addStretch()
        cevap_secenekleri_layout.addLayout(cevap_header_layout)

        # Cevap seçenekleri input'ları - 2x2 Grid: A-B yan yana, C-D yan yana
        cevap_inputs_layout = QGridLayout()
        cevap_inputs_layout.setSpacing(1)  # Spacing minimum - C ve D A ve B'ye yakın
        cevap_inputs_layout.setContentsMargins(0, 0, 0, 0)  # Tüm margin'ler 0
        self.cevap_inputs = []

        answer_font = QFont('Arial', 12)
        answer_font.setBold(False)
        
        for i in range(4):
            letter = "ABCD"[i]
            
            # Input - QTextEdit ile çok satırlı (label kaldırıldı)
            text_edit = QTextEdit()
            text_edit.setPlaceholderText(f"Seçenek {letter}")
            text_edit.setFont(answer_font)
            text_edit.setMinimumHeight(50)  # Minimum height azaltıldı - C ve D yukarı çıksın
            text_edit.setMaximumHeight(120)
            text_edit.setStyleSheet("""
                QTextEdit {
                    border: 1px solid #28a745;
                    background-color: white;
                    font-family: 'Arial', sans-serif;
                    font-size: 12px;
                    font-weight: normal;
                    padding: 6px 10px;
                    border-radius: 3px;
                    margin-top: 0px;
                }
                QTextEdit:focus {
                    border-color: #1e7e34;
                    background-color: #ffffff;
                }
            """)
            
            # Grid'e yerleştir: A ve B ilk satırda, C ve D ikinci satırda
            row = i // 2  # 0 veya 1 (A-B=0, C-D=1)
            col = i % 2   # 0 veya 1 (A,C=0, B,D=1)
            cevap_inputs_layout.addWidget(text_edit, row, col)
            self.cevap_inputs.append(text_edit)
        
        cevap_secenekleri_layout.addLayout(cevap_inputs_layout)
        
        left_layout.addLayout(cevap_secenekleri_layout)
        
        # CEVAP RESİMLERİ - Çerçeve kaldırıldı, direkt layout
        # Başlık - Cevap seçenekleri gibi düzenli
        cevap_resim_header_layout = QHBoxLayout()
        cevap_resim_header_layout.setSpacing(3)  # Spacing minimum
        cevap_resim_header_layout.setContentsMargins(0, 0, 0, 0)  # Margin'ler 0
        
        cevap_resim_header_layout.addStretch()
        cevap_resim_baslik = QLabel("SORUNUN CEVAP RESİMLERİNİ GİRİNİZ")
        cevap_resim_baslik.setStyleSheet("""
            QLabel {
                color: #28a745;
                font-weight: bold;
                font-size: 12px;
                padding: 1px 3px;
                margin: 0px;
                background-color: #e9f9ec;
                border: 1px solid #28a745;
                border-radius: 4px;
            }
        """)
        cevap_resim_baslik.setAlignment(Qt.AlignmentFlag.AlignCenter)
        cevap_resim_baslik.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed)
        cevap_resim_header_layout.addWidget(cevap_resim_baslik)
        cevap_resim_header_layout.addStretch()
        left_layout.addLayout(cevap_resim_header_layout)

        # Cevap resimleri: 2x2 Grid - A-B yan yana, C-D yan yana
        cevap_resim_inputs_layout = QGridLayout()
        cevap_resim_inputs_layout.setSpacing(4)
        cevap_resim_inputs_layout.setContentsMargins(0, 5, 0, 0)

        self.cevap_resim_inputs = []
        self.cevap_resim_previews = []
        for i in range(4):
            # Her cevap resmi için bir widget
            cevap_resim_widget = QWidget()
            cevap_resim_widget.setStyleSheet("background-color: transparent;")
            cevap_resim_widget_layout = QVBoxLayout()
            cevap_resim_widget_layout.setSpacing(2)
            cevap_resim_widget_layout.setContentsMargins(0, 0, 0, 0)

            letter = "ABCD"[i]
            
            # Üst satır: Label + Input + Buton
            ust_row = QHBoxLayout()
            ust_row.setSpacing(2)
            ust_row.setContentsMargins(0, 0, 0, 0)
            ust_row.setAlignment(Qt.AlignmentFlag.AlignTop)  # Üstte hizala
            
            harf_label = QLabel(f"{letter}:")
            harf_label.setMinimumHeight(26)  # Input ile aynı yükseklik
            harf_label.setMinimumWidth(30)
            harf_label.setStyleSheet("""
                QLabel {
                    color: #28a745;
                    font-weight: bold;
                    font-size: 12px;
                    background-color: #e8f5e9;
                    border: 1px solid #28a745;
                    border-radius: 4px;
                    padding: 2px 6px;
                    margin: 1px 0px;
                }
            """)
            harf_label.setAlignment(Qt.AlignmentFlag.AlignCenter | Qt.AlignmentFlag.AlignVCenter)
            ust_row.addWidget(harf_label)
            
            resim_input = QLineEdit()
            resim_input.setPlaceholderText(f"{letter} Resim URL...")
            resim_input.setFont(QFont('Arial', 11))
            resim_input.setMinimumHeight(26)  # Soru resim input'larıyla aynı yükseklik
            resim_input.setStyleSheet("""
                QLineEdit {
                    border: 2px solid #28a745;
                    border-radius: 4px;
                    padding: 5px 8px;
                    background-color: white;
                    font-size: 11px;
                }
                QLineEdit:focus {
                    border-color: #1e7e34;
                    background-color: #ffffff;
                }
            """)
            # URL değişince önizleme güncelle
            resim_input.textChanged.connect(lambda _t, idx=i: self._guncelle_cevap_resim_onizleme(idx))
            self.cevap_resim_inputs.append(resim_input)
            ust_row.addWidget(resim_input)
            
            resim_btn = QPushButton("Seç")
            resim_btn.setObjectName("secondaryBtn")
            resim_btn.setFixedSize(42, 20)  # Daha küçük
            resim_btn.setStyleSheet("""
                QPushButton {
                    font-size: 9px;
                    font-weight: bold;
                    padding: 1px 5px;
                    border: 2px solid #28a745;
                    border-radius: 3px;
                    background-color: #28a745;
                    color: white;
                }
                QPushButton:hover {
                    background-color: #1e7e34;
                    border-color: #1e7e34;
                }
                QPushButton:pressed {
                    background-color: #155724;
                    border-color: #155724;
                }
            """)
            resim_btn.clicked.connect(lambda checked, idx=i: self.cevap_resmi_sec(idx))
            ust_row.addWidget(resim_btn, alignment=Qt.AlignmentFlag.AlignTop)
            
            cevap_resim_widget_layout.addLayout(ust_row)
            
            # Önizleme (BAŞLANGIÇTA GİZLİ) - Belirgin border
            preview = QLabel()
            preview.setFixedSize(300, 200)
            preview.setStyleSheet("""
                QLabel {
                    border: 2px solid #28a745;
                    background: #ffffff;
                    border-radius: 4px;
                    margin-top: 2px;
                }
            """)
            preview.setScaledContents(True)
            preview.setVisible(False)  # Varsayılan olarak gizle
            self.cevap_resim_previews.append(preview)
            
            # Ortalamak için bir layout trick
            preview_container = QHBoxLayout()
            preview_container.addStretch()
            preview_container.addWidget(preview)
            preview_container.addStretch()
            
            cevap_resim_widget_layout.addLayout(preview_container)
            
            cevap_resim_widget.setLayout(cevap_resim_widget_layout)
            
            # Grid'e yerleştir: A ve B ilk satırda, C ve D ikinci satırda
            row = i // 2  # 0 veya 1 (A-B=0, C-D=1)
            col = i % 2   # 0 veya 1 (A,C=0, B,D=1)
            cevap_resim_inputs_layout.addWidget(cevap_resim_widget, row, col)
        
        left_layout.addLayout(cevap_resim_inputs_layout)
        
        # Sol layout'un en altına boşluk itici ekle (Her şeyi yukarı yaslar)
        left_layout.addStretch()
        
        left_panel.setLayout(left_layout)
        content_splitter.addWidget(left_panel)
        
        # Modern sağ panel - Ek Bilgiler ve Medya
        right_panel = QFrame()
        right_panel.setStyleSheet("""
            QFrame {
                border: 2px solid #e2e8f0;
                border-radius: 12px;
                padding: 15px;
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #f8fafc, stop:1 #f1f5f9);
            }
        """)
        right_layout = QVBoxLayout()
        right_layout.setSpacing(6)
        right_layout.setContentsMargins(10, 0, 10, 10)  # Üst margin sıfırlandı
        
        # Dil seçimi - En üstte
        dil_layout = QVBoxLayout()
        dil_layout.setSpacing(3)
        dil_label = QLabel("🌐 Dil Seçiniz:")
        dil_label.setStyleSheet("font-size: 14px; font-weight: bold; color: #2d5a27; margin-bottom: 2px;")
        dil_layout.addWidget(dil_label)
        
        self.dil_combo = QComboBox()
        self.dil_combo.addItem("🇹🇷 Türkçe (tr_sorular)", "tr_sorular")
        self.dil_combo.addItem("🇬🇧 English (en_sorular)", "en_sorular")
        combo_font_dil = QFont('Arial', 12)
        self.dil_combo.setFont(combo_font_dil)
        self.dil_combo.setMinimumWidth(200)
        self.dil_combo.setStyleSheet("""
            QComboBox {
                border: 2px solid #4a934a;
                border-radius: 6px;
                padding: 8px;
                background-color: white;
                color: #000000;
                font-size: 12px;
            }
            QComboBox:focus {
                border-color: #2d5a27;
                background-color: #ffffff;
            }
            QComboBox QAbstractItemView {
                border: 2px solid #4a934a;
                background-color: white;
                color: #000000;
                selection-background-color: #4a934a;
                selection-color: white;
                padding: 2px;
                outline: 0px;
            }
        """)
        # Dil değiştiğinde ay isimlerini güncelle
        self.dil_combo.currentIndexChanged.connect(self._dil_degisti)
        dil_layout.addWidget(self.dil_combo)
        right_layout.addLayout(dil_layout)
        
        # Tarih bilgileri - Kompakt ve tam görünsün
        tarih_layout = QVBoxLayout()
        tarih_layout.setSpacing(3)
        tarih_baslik_label = QLabel("📅 Tarih Bilgileri:")
        tarih_baslik_label.setStyleSheet("font-size: 14px; font-weight: bold; color: #2d5a27; margin-bottom: 2px;")
        tarih_layout.addWidget(tarih_baslik_label)
        
        tarih_row1 = QHBoxLayout()
        tarih_row1.addWidget(QLabel("Gün:"))
        self.gun_combo = QComboBox()
        self.gun_combo.addItems([str(i) for i in range(1, 32)])
        combo_font = QFont('Arial', 12)
        self.gun_combo.setFont(combo_font)
        self.gun_combo.setMinimumWidth(70)
        # Tüm günlerin görünür olması için maxVisibleItems'ı artır
        # Not: setMaxVisibleItems dropdown'da kaç öğe gösterileceğini belirler
        # 31 ayarlamak tüm öğeleri gösterir (1-31 arası günler)
        self.gun_combo.setMaxVisibleItems(31)  # Tüm günleri göster
        self.gun_combo.setStyleSheet("""
            QComboBox {
                border: 2px solid #4a934a;
                border-radius: 6px;
                padding: 8px;
                background-color: white;
                color: #000000;
                font-size: 12px;
            }
            QComboBox QAbstractItemView {
                border: 2px solid #4a934a;
                background-color: white;
                color: #000000;
                selection-background-color: #4a934a;
                selection-color: white;
                padding: 2px;
                outline: 0px;
                min-width: 70px;
            }
            QComboBox QAbstractItemView::item {
                padding: 4px;
                min-height: 22px;
            }
            QComboBox QAbstractItemView::item:hover {
                background-color: #e8f5e8;
            }
            QComboBox QScrollBar:vertical {
                background: #f5f5f5;
                width: 10px;
                border: none;
                border-radius: 5px;
                margin: 0px;
            }
            QComboBox QScrollBar::handle:vertical {
                background: #c0c0c0;
                min-height: 25px;
                border-radius: 5px;
                margin: 1px;
            }
            QComboBox QScrollBar::handle:vertical:hover {
                background: #a0a0a0;
            }
            QComboBox QScrollBar::handle:vertical:pressed {
                background: #808080;
            }
            QComboBox QScrollBar::add-line:vertical, QComboBox QScrollBar::sub-line:vertical {
                height: 0px;
            }
            QComboBox QScrollBar::add-page:vertical, QComboBox QScrollBar::sub-page:vertical {
                background: transparent;
            }
        """)
        tarih_row1.addWidget(self.gun_combo)
        
        tarih_row1.addWidget(QLabel("Ay:"))
        self.ay_combo = QComboBox()
        # Başlangıçta Türkçe aylar
        self.aylar_tr = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", 
                        "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
        self.aylar_en = ["January", "February", "March", "April", "May", "June",
                        "July", "August", "September", "October", "November", "December"]
        self.ay_combo.addItems(self.aylar_tr)
        self.ay_combo.setFont(combo_font)
        self.ay_combo.setMinimumWidth(120)
        tarih_row1.addWidget(self.ay_combo)
        
        tarih_row2 = QHBoxLayout()
        tarih_row2.addWidget(QLabel("Yıl:"))
        self.yil_combo = QComboBox()
        yillar = [str(i) for i in range(2020, 2051)]
        self.yil_combo.addItems(yillar)
        self.yil_combo.setCurrentText("2024")
        self.yil_combo.setFont(combo_font)
        self.yil_combo.setMinimumWidth(140)
        self.yil_combo.setStyleSheet(
            "QComboBox { min-width: 140px; }"
            " QComboBox QAbstractItemView { font-size: 13px; }"
            " QComboBox QAbstractItemView::item { min-height: 26px; }"
        )
        tarih_row2.addWidget(self.yil_combo)
        tarih_row2.addStretch()
        
        tarih_layout.addLayout(tarih_row1)
        tarih_layout.addLayout(tarih_row2)
        right_layout.addLayout(tarih_layout)
        
        # Kategori - Clickable Buttons
        kategori_layout = QVBoxLayout()
        kategori_layout.setSpacing(3)
        kategori_label = QLabel("🏷️ Kategori Seçiniz:")
        kategori_label.setStyleSheet("font-size: 14px; font-weight: bold; color: #2d5a27; margin-bottom: 2px;")
        kategori_layout.addWidget(kategori_label)

        # Kategori butonları için grid layout
        kategori_buttons_layout = QGridLayout()
        kategori_buttons_layout.setSpacing(5)
        
        # Kategori listesi - Türkçe ve İngilizce
        self.kategoriler_tr = [
            "Trafik ve Çevre Bilgisi",
            "İlk Yardım Bilgisi", 
            "Araç Tekniği (Motor ve Araç Bakımı)",
            "Trafik Adabı"
        ]
        self.kategoriler_en = [
            "Traffic and Environment",
            "First Aid",
            "Vehicle Technical",
            "Traffic Ethics"
        ]
        # Başlangıçta Türkçe kategoriler
        self.kategoriler = self.kategoriler_tr
        
        # Kategori butonları oluştur
        self.kategori_butonlari = []
        self.secili_kategori = None
        
        for i, kategori in enumerate(self.kategoriler):
            btn = QPushButton(kategori)
            btn.setCheckable(True)
            btn.setFont(QFont('Arial', 10))
            btn.setMinimumHeight(40)
            btn.setFocusPolicy(Qt.FocusPolicy.NoFocus)  # Odaklanmayı tamamen kaldır
            btn.setStyleSheet("""
                QPushButton {
                    background-color: #f8f9fa;
                    color: #2d5a27;
                    border: 2px solid #4a934a;
                    border-radius: 8px;
                    padding: 8px 12px;
                    font-weight: bold;
                    text-align: center;
                    outline: none;
                }
                QPushButton:hover {
                    background-color: #e8f5e8;
                    border-color: #2d5a27;
                    outline: none;
                }
                QPushButton:checked {
                    background-color: #4a934a;
                    color: white;
                    border-color: #2d5a27;
                    border-width: 3px;
                    outline: none;
                }
                QPushButton:focus {
                    outline: none;
                    border: 2px solid #4a934a;
                }
                QPushButton:focus:checked {
                    outline: none;
                    border: 3px solid #2d5a27;
                }
            """)
            
            # Buton tıklama olayını bağla
            btn.clicked.connect(lambda checked, idx=i: self.kategori_sec(idx))
            self.kategori_butonlari.append(btn)
            
            # 2x2 grid düzeninde yerleştir
            row = i // 2
            col = i % 2
            kategori_buttons_layout.addWidget(btn, row, col)
        
        kategori_layout.addLayout(kategori_buttons_layout)
        right_layout.addLayout(kategori_layout)
        
        # SORU MEDYALARI
        soru_medya_layout = QVBoxLayout()
        soru_medya_layout.setSpacing(3)
        
        soru_medya_baslik = QLabel("📝 SORU MEDYALARI")
        soru_medya_baslik.setStyleSheet("""
            QLabel {
                font-size: 14px;
                font-weight: bold;
                color: #17a2b8;
                margin-bottom: 2px;
            }
        """)
        soru_medya_layout.addWidget(soru_medya_baslik)
        
        # Soru videosu
        soru_video_layout = QHBoxLayout()
        soru_video_layout.setSpacing(10)
        soru_video_layout.setContentsMargins(0, 3, 0, 3)
        soru_video_layout.setAlignment(Qt.AlignmentFlag.AlignTop)  # Üstte hizala
        soru_video_label = QLabel("🎥 Soru Videosu:")
        soru_video_label.setStyleSheet("""
            color: #17a2b8; 
            font-weight: bold; 
            font-size: 12px;
            padding: 8px 0px;
            margin: 2px 0px;
        """)
        soru_video_layout.addWidget(soru_video_label)
        self.video_input = QLineEdit()
        self.video_input.setPlaceholderText("Video URL veya dosya yolu...")
        self.video_input.setFont(QFont('Arial', 11))
        self.video_input.setMinimumHeight(26)  # Resim input'larıyla aynı yükseklik
        self.video_input.setStyleSheet("""
            QLineEdit {
                border: 2px solid #17a2b8;
                background-color: white;
                font-size: 11px;
                padding: 5px 8px;
                border-radius: 4px;
            }
            QLineEdit:focus {
                border-color: #138496;
                background-color: #ffffff;
            }
        """)
        soru_video_layout.addWidget(self.video_input)
        video_btn = QPushButton("Seç")
        video_btn.setObjectName("secondaryBtn")
        video_btn.setFixedSize(42, 20)  # Resim butonlarıyla aynı boyut
        video_btn.setStyleSheet("""
            QPushButton {
                font-size: 9px;
                font-weight: bold;
                padding: 1px 5px;
                border: 2px solid #17a2b8;
                border-radius: 3px;
                background-color: #17a2b8;
                color: white;
            }
            QPushButton:hover {
                background-color: #138496;
                border-color: #138496;
            }
            QPushButton:pressed {
                background-color: #0d6674;
                border-color: #0d6674;
            }
        """)
        video_btn.clicked.connect(self.soru_videosu_sec)
        soru_video_layout.addWidget(video_btn, alignment=Qt.AlignmentFlag.AlignTop)
        soru_medya_layout.addLayout(soru_video_layout)
        
        # Soru resimleri: Birden fazla resim
        soru_resim_layout = QVBoxLayout()
        soru_resim_layout.setSpacing(3)
        soru_resim_layout.setContentsMargins(0, 0, 0, 0)
        soru_resim_baslik = QLabel("🖼️ Soru Resimleri (Maksimum 4 adet):")
        soru_resim_baslik.setStyleSheet("""
            color: #17a2b8; 
            font-weight: bold; 
            font-size: 13px;
            padding: 3px 0px;
            margin: 2px 0px;
        """)
        soru_resim_layout.addWidget(soru_resim_baslik)
        
        self.soru_resim_inputs = []
        self.soru_resim_previews = []
        for i in range(4):
            item_v = QVBoxLayout()
            item_v.setSpacing(2)
            item_v.setContentsMargins(0, 0, 0, 3)

            resim_row = QHBoxLayout()
            resim_row.setSpacing(2)  # Cevap resim row ile aynı spacing
            resim_row.setContentsMargins(0, 0, 0, 0)
            resim_row.setAlignment(Qt.AlignmentFlag.AlignTop)  # Üstte hizala

            resim_label = QLabel(f"Resim {i+1}:")
            resim_label.setMinimumHeight(26)  # Input ile aynı yükseklik
            resim_label.setMinimumWidth(90)
            resim_label.setStyleSheet("""
                QLabel {
                    color: #17a2b8;
                    font-weight: bold;
                    font-size: 12px;
                    background-color: #e0f7fa;
                    border: 1px solid #17a2b8;
                    border-radius: 4px;
                    padding: 2px 6px;
                    margin: 1px 0px;
                }
            """)
            resim_label.setAlignment(Qt.AlignmentFlag.AlignCenter | Qt.AlignmentFlag.AlignVCenter)
            resim_row.addWidget(resim_label)
            
            resim_input = QLineEdit()
            resim_input.setPlaceholderText(f"Resim {i+1} URL...")
            resim_input.setFont(QFont('Arial', 11))
            resim_input.setMinimumHeight(26)
            resim_input.setStyleSheet("""
                QLineEdit {
                    border: 2px solid #17a2b8;
                    background-color: white;
                    font-size: 11px;
                    padding: 5px 8px;
                    border-radius: 4px;
                }
                QLineEdit:focus {
                    border-color: #138496;
                    background-color: #ffffff;
                }
            """)
            resim_row.addWidget(resim_input)
            self.soru_resim_inputs.append(resim_input)
            
            resim_btn = QPushButton("Seç")
            resim_btn.setObjectName("secondaryBtn")
            resim_btn.setFixedSize(42, 20)  # Daha küçük
            resim_btn.setStyleSheet("""
                QPushButton {
                    font-size: 9px;
                    font-weight: bold;
                    padding: 1px 5px;
                    border: 2px solid #17a2b8;
                    border-radius: 3px;
                    background-color: #17a2b8;
                    color: white;
                }
                QPushButton:hover {
                    background-color: #138496;
                    border-color: #138496;
                }
                QPushButton:pressed {
                    background-color: #0d6674;
                    border-color: #0d6674;
                }
            """)
            resim_btn.clicked.connect(lambda checked, idx=i: self.soru_resmi_sec(idx))
            # URL değişince önizleme güncelle
            resim_input.textChanged.connect(lambda _t, idx=i: self._guncelle_soru_resim_onizleme(idx))
            resim_row.addWidget(resim_btn, alignment=Qt.AlignmentFlag.AlignTop)

            # Önizleme altta, daha büyük
            preview = QLabel()
            preview.setFixedSize(250, 180)
            preview.setStyleSheet("QLabel{border:1px solid #bfe8ef; background:#ffffff}")
            preview.setScaledContents(True)
            self.soru_resim_previews.append(preview)

            item_v.addLayout(resim_row)
            item_v.addWidget(preview)

            soru_resim_layout.addLayout(item_v)
        
        soru_medya_layout.addLayout(soru_resim_layout)
        right_layout.addLayout(soru_medya_layout)
        
        right_layout.addStretch()  # Alt kısımda boşluk bırak
        right_panel.setLayout(right_layout)
        content_splitter.addWidget(right_panel)
        
        # Splitter oranları ayarla (sol ve sağ eşit genişlikte)
        # Splitter oranları ayarla (sol %60, sağ %40)
        content_splitter.setStretchFactor(0, 3)
        content_splitter.setStretchFactor(1, 2)
        
        scroll_layout.addWidget(content_splitter)
        scroll_widget.setLayout(scroll_layout)
        scroll.setWidget(scroll_widget)
        scroll.setWidgetResizable(True)
        main_layout.addWidget(scroll)
        
        # Alt buton paneli - Kompakt
        buton_frame = QFrame()
        buton_frame.setStyleSheet("""
            QFrame {
                background-color: transparent;
                border: none;
                padding: 0px;
            }
        """)
        buton_layout = QHBoxLayout()
        buton_layout.setSpacing(6)
        buton_layout.setContentsMargins(15, 4, 15, 4)  # Minimal margin
        
        # Modern Temizle butonu - Kompakt
        temizle_btn = QPushButton("🧹 Formu Temizle")
        temizle_btn.setStyleSheet("""
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #ef4444, stop:1 #dc2626);
                color: white;
                font-size: 12px;
                font-weight: 600;
                padding: 10px 18px;
                min-height: 40px;
                border-radius: 8px;
                border: none;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #f87171, stop:1 #ef4444);
            }
            QPushButton:pressed {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #dc2626, stop:1 #b91c1c);
            }
        """)
        temizle_btn.clicked.connect(self.formu_temizle)
        buton_layout.addWidget(temizle_btn)
        
        buton_layout.addStretch()
        
        # Modern Kaydet butonu - Kompakt
        kaydet_btn = QPushButton("💾 SORU KAYDET")
        kaydet_btn.setStyleSheet("""
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #10b981, stop:1 #059669);
                color: white;
                font-size: 13px;
                font-weight: 600;
                padding: 10px 24px;
                min-height: 40px;
                border-radius: 8px;
                border: none;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #34d399, stop:1 #10b981);
            }
            QPushButton:pressed {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #059669, stop:1 #047857);
            }
        """)
        kaydet_btn.clicked.connect(self.soru_kaydet)
        buton_layout.addWidget(kaydet_btn)
        
        buton_frame.setLayout(buton_layout)
        main_layout.addWidget(buton_frame, alignment=Qt.AlignmentFlag.AlignBottom)
        
        # Ana layout margin'leri - butonların görünür olması için
        
        self.setLayout(main_layout)
    
    def ana_menuye_don(self):
        self.ana_menu = AnaMenu()
        self.ana_menu.show()
        try:
            self.ana_menu.raise_(); self.ana_menu.activateWindow()
        except Exception:
            pass
        self.close()
    
    # Soru listesi kaldırıldı
    # Medya seçim yardımcıları
    def _load_image_into_label(self, url: str, label: QLabel):
        try:
            if not url:
                label.clear()
                return
            import requests
            from io import BytesIO
            resp = requests.get(url, timeout=5)
            if resp.status_code == 200:
                data = resp.content
                pix = QPixmap()
                if pix.loadFromData(data):
                    label.setPixmap(pix)
                else:
                    label.clear()
            else:
                label.clear()
        except Exception:
            label.clear()

    def _guncelle_cevap_resim_onizleme(self, index: int):
        if 0 <= index < len(self.cevap_resim_inputs) and 0 <= index < len(self.cevap_resim_previews):
            url = self.cevap_resim_inputs[index].text().strip()
            preview_label = self.cevap_resim_previews[index]
            
            if url:
                # URL varsa yüklemeyi dene ve görünür yap
                self._load_image_into_label(url, preview_label)
                if not preview_label.pixmap() or preview_label.pixmap().isNull():
                    # Resim yüklenemezse gizli kalsın
                    preview_label.setVisible(False)
                else:
                    # Resim varsa göster
                    preview_label.setVisible(True)
            else:
                # URL yoksa temizle ve GİZLE
                preview_label.clear()
                preview_label.setVisible(False)

    def _guncelle_soru_resim_onizleme(self, index: int):
        if 0 <= index < len(self.soru_resim_inputs) and 0 <= index < len(self.soru_resim_previews):
            url = self.soru_resim_inputs[index].text().strip()
            self._load_image_into_label(url, self.soru_resim_previews[index])
    def soru_resmi_sec(self, index: int):
        dosya, _ = QFileDialog.getOpenFileName(self, f"Soru için resim {index+1} seç", "", "Görüntüler (*.png *.jpg *.jpeg *.bmp *.gif)")
        if dosya:
            # Firebase Storage'a yükle
            if bucket:
                url = dosya_yukle_firebase_storage(dosya, "soru_resimleri")
                if url:
                    self.soru_resim_inputs[index].setText(url)
                    self._guncelle_soru_resim_onizleme(index)
                    QMessageBox.information(self, "Başarılı", "Resim yüklendi.")
                else:
                    QMessageBox.warning(self, "Hata", "Resim yüklenemedi!")
            else:
                # Firebase Storage yoksa dosya yolunu direkt kullan
                self.soru_resim_inputs[index].setText(dosya)
                self._guncelle_soru_resim_onizleme(index)

    def soru_videosu_sec(self):
        dosya, _ = QFileDialog.getOpenFileName(self, "Soru için video seç", "", "Videolar (*.mp4 *.mov *.avi *.mkv)")
        if dosya:
            # Firebase Storage'a yükle
            if bucket:
                url = dosya_yukle_firebase_storage(dosya, "soru_videolari")
                if url:
                    self.video_input.setText(url)
                    QMessageBox.information(self, "Başarılı", "Video Firebase Storage'a yüklendi!")
                else:
                    QMessageBox.warning(self, "Hata", "Video yüklenemedi!")
            else:
                # Firebase Storage yoksa dosya yolunu direkt kullan
                self.video_input.setText(dosya)
    
    def cevap_resmi_sec(self, index: int):
        dosya, _ = QFileDialog.getOpenFileName(self, f"{index+1}. cevap için resim seç", "", "Görüntüler (*.png *.jpg *.jpeg *.bmp *.gif)")
        if dosya:
            # Firebase Storage'a yükle
            if bucket:
                url = dosya_yukle_firebase_storage(dosya, "cevap_resimleri")
                if url:
                    self.cevap_resim_inputs[index].setText(url)
                    self._guncelle_cevap_resim_onizleme(index)
                    QMessageBox.information(self, "Başarılı", "Resim yüklendi.")
                else:
                    QMessageBox.warning(self, "Hata", "Resim yüklenemedi!")
            else:
                # Firebase Storage yoksa dosya yolunu direkt kullan
                self.cevap_resim_inputs[index].setText(dosya)
                self._guncelle_cevap_resim_onizleme(index)
                QMessageBox.information(self, "Resim eklendi", f"{index+1}. cevap için resim eklendi.")
    
    def _dil_degisti(self):
        """Dil değiştiğinde ay isimlerini ve kategorileri güncelle"""
        secilen_dil = self.dil_combo.currentData()
        
        # Mevcut seçili ayın index'ini sakla
        current_ay_index = self.ay_combo.currentIndex()
        
        # Mevcut seçili kategorinin index'ini sakla
        current_kategori_index = self.secili_kategori
        
        # Ay combo'yu temizle ve yeni dile göre doldur
        self.ay_combo.clear()
        if secilen_dil == "en_sorular":
            self.ay_combo.addItems(self.aylar_en)
            self.kategoriler = self.kategoriler_en
        else:
            self.ay_combo.addItems(self.aylar_tr)
            self.kategoriler = self.kategoriler_tr
        
        # Aynı ay index'ini koru (Ocak -> January, Şubat -> February vs.)
        if 0 <= current_ay_index < self.ay_combo.count():
            self.ay_combo.setCurrentIndex(current_ay_index)
        
        # Kategori butonlarını güncelle
        for i, btn in enumerate(self.kategori_butonlari):
            if i < len(self.kategoriler):
                btn.setText(self.kategoriler[i])
        
        # Seçili kategoriyi koru
        if current_kategori_index is not None and 0 <= current_kategori_index < len(self.kategoriler):
            self.kategori_butonlari[current_kategori_index].setChecked(True)
    
    def kategori_sec(self, index: int):
        """Kategori seçim işlemi"""
        # Önceki seçimi kaldır
        if self.secili_kategori is not None:
            self.kategori_butonlari[self.secili_kategori].setChecked(False)
        
        # Yeni seçimi ayarla
        self.secili_kategori = index
        self.kategori_butonlari[index].setChecked(True)
    

    
    def onizleme_goster(self):
        # Form verilerini kontrol et
        soru_text = self.soru_input.toPlainText().strip()
        if not soru_text:
            QMessageBox.warning(self, "Uyarı", "Lütfen soruyu yazın!")
            return
            
        cevaplar = [c.text().strip() for c in self.cevap_inputs]
        if any(not c for c in cevaplar):
            QMessageBox.warning(self, "Uyarı", "Lütfen tüm cevapları doldurun!")
            return
        
        # Önizleme penceresi - Daha güzel formatlı
        onizleme_text = f"""📝 Soru: 
{soru_text}

✏️ Cevap Seçenekleri
1️⃣ {cevaplar[0]}
2️⃣ {cevaplar[1]}  
3️⃣ {cevaplar[2]}
4️⃣ {cevaplar[3]}

✅ Doğru Cevap: {self.dogru_combo.currentIndex() + 1}. seçenek
   → "{cevaplar[self.dogru_combo.currentIndex()]}"

📅 Tarih: {self.gun_combo.currentText()} {self.ay_combo.currentText()} {self.yil_combo.currentText()}

🏷️ Kategori: {self.kategori_input.text().strip() or 'Genel'}

🎨 Medya Dosyaları:
   🖼️ Soru Resmi: {'✅ Eklendi' if self.resim_input.text().strip() else '❌ Yok'}
   🎥 Video: {'✅ Eklendi' if self.video_input.text().strip() else '❌ Yok'}
        """
        
        # Önizleme yerine direkt kaydet
        self.soru_kaydet()
    
    def soru_kaydet(self):
        if not db:
            QMessageBox.critical(self, "Hata", "Firebase bağlantısı yok!")
            return
            
        try:
            # Form doğrulama
            if not self.soru_input.toPlainText().strip():
                QMessageBox.warning(self, "⚠️ Uyarı", "Lütfen soruyu detaylı bir şekilde yazın!")
                self.soru_input.setFocus()
                return
            # Kategori seçimi zorunlu
            if self.secili_kategori is None:
                QMessageBox.warning(self, "⚠️ Uyarı", "Lütfen bir kategori seçin!")
                return
            # Tarih zorunlu
            if not self.gun_combo.currentText().strip() or not self.ay_combo.currentText().strip() or not self.yil_combo.currentText().strip():
                QMessageBox.warning(self, "⚠️ Uyarı", "Lütfen gün, ay ve yıl seçin!")
                return
                
            # Cevap kontrolü - Esnek yapı (metin veya resim)
            cevaplar_raw = [c.toPlainText() for c in self.cevap_inputs]
            cevaplar = [str(c).strip() for c in cevaplar_raw]
            cevap_resimleri_raw = [c.text() for c in self.cevap_resim_inputs]
            cevap_resimleri = [str(c).strip() for c in cevap_resimleri_raw]
            
            # Dört cevabın her biri dolu olmalı (metin veya resim)
            letters = ["A", "B", "C", "D"]
            for i in range(4):
                if not (cevaplar[i] or cevap_resimleri[i]):
                    QMessageBox.warning(self, "⚠️ Uyarı", f"Lütfen {letters[i]} seçeneği için metin veya resim girin!")
                    return
            # Doğru cevap boş olamaz - önce seçim yapılıp yapılmadığını kontrol et
            correct_index = int(self.dogru_combo.currentIndex())
            if correct_index == 0:  # İlk seçenek "Lütfen seçiniz" ise
                QMessageBox.warning(self, "⚠️ Uyarı", "Lütfen doğru cevabı seçiniz!")
                return
            
            # Seçilen cevabın dolu olduğunu kontrol et (index 1'den başlıyor çünkü 0 boş seçenek)
            actual_index = correct_index - 1
            if not (cevaplar[actual_index] or cevap_resimleri[actual_index]):
                QMessageBox.warning(self, "⚠️ Uyarı", "Doğru cevap olarak seçtiğiniz seçenek boş. Lütfen doğru cevabı dolu bir seçenekten seçin!")
                return
            
            # Medya URL'lerini direkt al (Firebase Storage kullanmadan)
            soru_resimleri = []
            video_url = ""
            cevap_resimleri = []
            
            # Soru resimlerini al (maksimum 4 adet)
            for i, resim_input in enumerate(self.soru_resim_inputs):
                soru_resimleri.append(resim_input.text().strip())
            
            # Soru videosu al
            video_url = self.video_input.text().strip()
            
            # Cevap resimlerini al (yeni input alanlarından)
            for i, resim_input in enumerate(self.cevap_resim_inputs):
                cevap_resimleri.append(resim_input.text().strip())
            
            # Cevap verilerini hazırla (metin + resim) - Esnek yapı
            cevap_verileri = []
            for i, cevap_metni in enumerate(cevaplar):
                resim_url = cevap_resimleri[i] if i < len(cevap_resimleri) else ""
                
                # Eğer cevap metni boşsa ama resim varsa, sadece resim kullan
                if not cevap_metni.strip() and resim_url:
                    cevap_verileri.append({
                        "metin": "",  # Boş metin
                        "resim_url": resim_url
                    })
                # Eğer cevap metni varsa, metin + resim kullan
                elif cevap_metni.strip():
                    cevap_verileri.append({
                        "metin": cevap_metni,
                        "resim_url": resim_url
                    })
                # Her ikisi de boşsa, boş cevap
                else:
                    cevap_verileri.append({
                        "metin": "",
                        "resim_url": ""
                    })
            
            # Veriyi hazırla
            ay_str = str(self.ay_combo.currentText())
            gun_int = int(self.gun_combo.currentText())
            yil_int = int(self.yil_combo.currentText())
            
            # Seçilen kategoriyi al - Firebase için her zaman Türkçe kategori adını kullan
            # (UI'da İngilizce gösterilse bile, veritabanında tutarlılık için Türkçe saklanır)
            if self.secili_kategori is not None:
                kategori_str = str(self.kategoriler_tr[self.secili_kategori])
            else:
                kategori_str = "Genel"  # Varsayılan kategori
            
            # Doğru cevap index'ini hesapla (0. seçenek boş olduğu için 1 çıkar)
            cevap_index_int = int(self.dogru_combo.currentIndex()) - 1
            
            soru_veri = {
                "soru": str(self.soru_input.toPlainText().strip()),
                "cevaplar": cevap_verileri,  # Artık array of objects
                "cevap": cevap_index_int,
                "gün": gun_int,
                "ay": ay_str,
                "yıl": yil_int,
                "kategori": kategori_str,
                "soru_resimleri": soru_resimleri,  # Array of URLs
                "soru_videosu": video_url
            }
            
            # Seçilen dile göre koleksiyon seç
            secilen_dil_koleksiyon = self.dil_combo.currentData()
            if not secilen_dil_koleksiyon:
                secilen_dil_koleksiyon = "tr_sorular"  # Varsayılan Türkçe
            
            # Firebase'e kaydet
            doc_ref = db.collection(secilen_dil_koleksiyon).add(soru_veri)
            
            # Başarı mesajı - Basit, ortalanmış ve simgesiz
            msg = QMessageBox(self)
            msg.setIcon(QMessageBox.Icon.NoIcon)
            msg.setWindowTitle("Başarılı")
            msg.setText("<div style='text-align:center'>Soru başarıyla kaydedildi!</div>")
            msg.setStandardButtons(QMessageBox.StandardButton.Ok)
            # Varsayılan konumlandırma: merkez
            msg.exec()
            
            self.formu_temizle_onaysiz()  # Onay istemeden temizle
            
        except Exception as e:
            import traceback
            error_msg = f"Soru kaydedilirken hata oluştu:\n{str(e)}\n\nDetay: {traceback.format_exc()}"
            QMessageBox.critical(self, "❌ Hata", error_msg)
    
    def formu_temizle_onaysiz(self):
        """Onay istemeden formu temizler - kaydet sonrası için"""
        self.soru_input.clear()
        for cevap_input in self.cevap_inputs:
            cevap_input.clear()
        self.dogru_combo.setCurrentIndex(0)  # Boş seçeneğe sıfırla
        # Dil seçimi varsayılan olarak kalır (Türkçe)
        # Tarih alanları temizlenmez - son girilen değerler kalır
        
        # Kategori seçimini temizle
        if self.secili_kategori is not None:
            self.kategori_butonlari[self.secili_kategori].setChecked(False)
            self.secili_kategori = None
        
        for resim_input in self.soru_resim_inputs:
            resim_input.clear()
        self.video_input.clear()
        for resim_input in self.cevap_resim_inputs:
            resim_input.clear()
        
        # Odağı soru alanına getir
        self.soru_input.setFocus()
    
    def formu_temizle(self):
        if show_modern_message(self, "🧹 Formu Temizle", "Tüm alanlar temizlenecek. Emin misiniz?", is_question=True):
            # Tarih alanları ve dil seçimi hariç temizle
            self.soru_input.clear()
            for cevap_input in self.cevap_inputs:
                cevap_input.clear()
            self.dogru_combo.setCurrentIndex(0)  # Boş seçeneğe sıfırla
            # Dil seçimi varsayılan olarak kalır (Türkçe)
            # Tarih alanları temizlenmez - son girilen değerler kalır
            
            # Kategori seçimini temizle
            if self.secili_kategori is not None:
                self.kategori_butonlari[self.secili_kategori].setChecked(False)
                self.secili_kategori = None
            
            for resim_input in self.soru_resim_inputs:
                resim_input.clear()
            self.video_input.clear()
            for resim_input in self.cevap_resim_inputs:
                resim_input.clear()
            
            # Odağı soru alanına getir
            self.soru_input.setFocus()
            
            show_modern_message(self, "✅ Temizlendi", "Form başarıyla temizlendi!")

class SoruDuzenlemePaneli(SoruEklemePaneli):
    def __init__(self, doc_id: str, initial_data: dict | None = None, koleksiyon: str = "tr_sorular"):
        self.doc_id = doc_id
        self.koleksiyon = koleksiyon  # Hangi koleksiyondan geldiğini sakla
        # Önce tarih bilgisini sakla (geri dönüşte kullanacağız)
        self.prev_gun = None
        self.prev_ay = None
        self.prev_yil = None
        if isinstance(initial_data, dict):
            self.prev_gun = str(initial_data.get("gün") or initial_data.get("gun") or "").strip()
            self.prev_ay = str(initial_data.get("ay") or "").strip()
            self.prev_yil = str(initial_data.get("yıl") or initial_data.get("yil") or "").strip()
        super().__init__()
        # Dil seçimini koleksiyona göre ayarla
        if hasattr(self, 'dil_combo'):
            if self.koleksiyon == "en_sorular":
                self.dil_combo.setCurrentIndex(1)  # English
            else:
                self.dil_combo.setCurrentIndex(0)  # Türkçe
        self.setWindowTitle("Soru Düzenleme Paneli")
        # Uygulama ikonu ayarla
        self.setWindowIcon(QIcon("playstore.png"))
        # Üst bar: Geri butonu ekle, "Ana Menü" ve "Tarih Seç" butonlarını gösterme
        try:
            header_layout = getattr(self, 'header_layout', None)  # SoruEklemePaneli'ndeki header_layout
            if header_layout is not None:
                geri_btn2 = QPushButton("⬅️ Geri")
                geri_btn2.setStyleSheet("""
                    QPushButton {
                        background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                            stop:0 #6366f1, stop:1 #4f46e5);
                        color: white;
                        border: none;
                        border-radius: 10px;
                        padding: 10px 20px;
                        font-size: 13px;
                        font-weight: 600;
                        min-height: 32px;
                    }
                    QPushButton:hover {
                        background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                            stop:0 #818cf8, stop:1 #6366f1);
                    }
                    QPushButton:pressed {
                        background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                            stop:0 #4f46e5, stop:1 #4338ca);
                    }
                """)
                geri_btn2.clicked.connect(self.geri)
                header_layout.insertWidget(0, geri_btn2)
                # Var olan "Ana Menü" butonunu gizle
                try:
                    for i in range(header_layout.count()):
                        w = header_layout.itemAt(i).widget()
                        if hasattr(w, 'text') and isinstance(w.text(), str) and "Ana Menü" in w.text():
                            w.hide()
                except Exception:
                    pass
        except Exception:
            pass

        # Başlık metnini "Soru Düzenleme Paneli" yap
        try:
            baslik_label = getattr(self, 'baslik_label', None)
            if baslik_label is not None:
                baslik_label.setText("🛠️ SORU DÜZENLEME PANELİ")
        except Exception:
            pass

        # Ön doldurma (liste satırındaki mevcut verilerle)
        if isinstance(initial_data, dict) and initial_data:
            try:
                self._uygula_belge(initial_data)
            except Exception:
                pass
        self.yukle_ve_doldur()

    def yukle_ve_doldur(self):
        # Belgeyi senkron çek ve hemen doldur (ekran boş açılmasın)
        try:
            # Koleksiyon bilgisini kullan
            koleksiyon_adi = getattr(self, 'koleksiyon', 'tr_sorular')
            ref = db.collection(koleksiyon_adi).document(self.doc_id)
            snap = ref.get()
            if not snap.exists:
                QMessageBox.critical(self, "Hata", "Belge bulunamadı")
                return
            d = snap.to_dict() or {}
            self._uygula_belge(d)
        except Exception as e:
            QMessageBox.critical(self, "Hata", f"Belge yüklenemedi: {e}")

    def _uygula_belge(self, d: dict):
        # Yardımcı: çoklu anahtar oku
        def get_any(data: dict, keys: list[str], default=""):
            for k in keys:
                if k in data and data.get(k) not in (None, ""):
                    return data.get(k)
            return default

        # Soru
        soru_text = get_any(d, ["soru", "soru_text", "question"], "")
        self.soru_input.setPlainText(str(soru_text))
        # Cevaplar
        cevaplar = d.get("cevaplar", [])
        # Eğer dict ise A-D sırala
        if isinstance(cevaplar, dict):
            order_keys = ["A", "B", "C", "D", "a", "b", "c", "d", "1", "2", "3", "4"]
            tmp = []
            for k in ["A","B","C","D"]:
                if k in cevaplar:
                    tmp.append(cevaplar.get(k))
            if not tmp:
                for k in ["a","b","c","d"]:
                    if k in cevaplar:
                        tmp.append(cevaplar.get(k))
            if not tmp:
                for k in ["1","2","3","4"]:
                    if k in cevaplar:
                        tmp.append(cevaplar.get(k))
            cevaplar = tmp
        # Eski/diger şema: cevap1-4 veya a-d
        if not cevaplar:
            alt_keys = [
                ("cevap1","cevap2","cevap3","cevap4"),
                ("A","B","C","D"),
                ("a","b","c","d"),
            ]
            for keys in alt_keys:
                vals = [str(d.get(k, "")).strip() for k in keys]
                if any(vals):
                    cevaplar = vals
                    break
        for i in range(min(4, len(self.cevap_inputs))):
            metin = ""
            if isinstance(cevaplar, list) and len(cevaplar) > i:
                c = cevaplar[i]
                if isinstance(c, dict):
                    metin = c.get("metin", "")
                elif isinstance(c, str):
                    metin = c
            self.cevap_inputs[i].setPlainText(str(metin))
        # Cevap resimleri
        for i in range(min(4, len(self.cevap_resim_inputs))):
            url = ""
            if isinstance(cevaplar, list) and len(cevaplar) > i:
                c = cevaplar[i]
                if isinstance(c, dict):
                    url = c.get("resim_url", "")
            self.cevap_resim_inputs[i].setText(str(url))
        # Doğru cevap
        try:
            idx = get_any(d, ["cevap", "dogru", "correct", "answer", "right"], None)
            # Firebase'de 0-3 olarak kaydediliyor (0=A, 1=B, 2=C, 3=D)
            # ComboBox'ta: 0="Lütfen seçiniz", 1="A", 2="B", 3="C", 4="D"
            
            if isinstance(idx, str) and idx.isdigit():
                idx = int(idx)
            elif isinstance(idx, int):
                pass
            else:
                idx = None
            
            # Eğer idx None veya geçersizse boş seçenek
            if idx is None or not (0 <= idx <= 3):
                idx = 0  # Boş seçenek (index 0)
            else:
                # Firebase'den gelen 0-3 index'ine 1 ekle (çünkü ComboBox'ta 0 boş seçenek)
                idx = idx + 1
            
            self.dogru_combo.setCurrentIndex(idx)
        except Exception:
            self.dogru_combo.setCurrentIndex(0)  # Boş seçeneğe sıfırla
        # Tarihler
        try:
            gun_val = int(get_any(d, ["gün", "gun", "day"], 1))
        except Exception:
            gun_val = 1
        self.gun_combo.setCurrentText(str(gun_val))
        # Ay string veya int olabilir
        ay_val = get_any(d, ["ay", "month"], "Ocak")
        if isinstance(ay_val, int):
            ay_map = ["", "Ocak","Şubat","Mart","Nisan","Mayıs","Haziran","Temmuz","Ağustos","Eylül","Ekim","Kasım","Aralık"]
            if 1 <= ay_val <= 12:
                ay_val = ay_map[ay_val]
            else:
                ay_val = "Ocak"
        self.ay_combo.setCurrentText(str(ay_val))
        self.yil_combo.setCurrentText(str(get_any(d, ["yıl", "yil", "year"], "2024")))
        # Kategori (varsa) işaretle
        kategori_text = str(get_any(d, ["kategori", "category"], "Genel"))
        self.secili_kategori = None
        for i, kategori in enumerate(self.kategoriler):
            if kategori == kategori_text:
                self.kategori_butonlari[i].setChecked(True)
                self.secili_kategori = i
                break
        # Soru resimleri
        soru_resimleri = d.get("soru_resimleri", [])
        # Eski şema için geri dönüşüm: tekil resim alanları
        if not soru_resimleri:
            legacy_img = d.get("resim_url", "") or d.get("resim", "")
            if legacy_img:
                soru_resimleri = [legacy_img]
        if isinstance(soru_resimleri, list):
            for i in range(min(4, len(self.soru_resim_inputs))):
                self.soru_resim_inputs[i].setText(str(soru_resimleri[i] if i < len(soru_resimleri) else ""))
        # Video
        video_val = d.get("soru_videosu", "") or d.get("video_url", "") or d.get("video", "")
        self.video_input.setText(str(video_val))

    def soru_kaydet(self):
        if not db:
            QMessageBox.critical(self, "Hata", "Firebase bağlantısı yok!")
            return
        try:
            # Orijinal kaydet mantığından veri derle
            cevaplar_raw = [c.toPlainText() for c in self.cevap_inputs]
            cevaplar = [str(c).strip() for c in cevaplar_raw]
            cevap_resimleri_raw = [c.text() for c in self.cevap_resim_inputs]
            cevap_resimleri = [str(c).strip() for c in cevap_resimleri_raw]
            # Zorunlu: soru metni
            if not self.soru_input.toPlainText().strip():
                QMessageBox.warning(self, "⚠️ Uyarı", "Lütfen soruyu detaylı bir şekilde yazın!")
                return
            # Zorunlu: kategori
            if self.secili_kategori is None:
                QMessageBox.warning(self, "⚠️ Uyarı", "Lütfen bir kategori seçin!")
                return
            # Zorunlu: tarih
            if not self.gun_combo.currentText().strip() or not self.ay_combo.currentText().strip() or not self.yil_combo.currentText().strip():
                QMessageBox.warning(self, "⚠️ Uyarı", "Lütfen gün, ay ve yıl seçin!")
                return
            # Her seçenek için metin veya resim zorunlu
            letters = ["A", "B", "C", "D"]
            for i in range(4):
                if not (cevaplar[i] or cevap_resimleri[i]):
                    QMessageBox.warning(self, "⚠️ Uyarı", f"Lütfen {letters[i]} seçeneği için metin veya resim girin!")
                    return
            # Doğru cevap boş olamaz - önce seçim yapılıp yapılmadığını kontrol et
            correct_index = int(self.dogru_combo.currentIndex())
            if correct_index == 0:  # İlk seçenek "Lütfen seçiniz" ise
                QMessageBox.warning(self, "⚠️ Uyarı", "Lütfen doğru cevabı seçiniz!")
                return
            
            # Seçilen cevabın dolu olduğunu kontrol et (index 1'den başlıyor çünkü 0 boş seçenek)
            actual_index = correct_index - 1
            if not (cevaplar[actual_index] or cevap_resimleri[actual_index]):
                QMessageBox.warning(self, "⚠️ Uyarı", "Doğru cevap olarak seçtiğiniz seçenek boş. Lütfen doğru cevabı dolu bir seçenekten seçin!")
                return
            cevap_verileri = []
            for i, cevap_metni in enumerate(cevaplar):
                resim_url = cevap_resimleri[i] if i < len(cevap_resimleri) else ""
                if not cevap_metni.strip() and resim_url:
                    cevap_verileri.append({"metin": "", "resim_url": resim_url})
                elif cevap_metni.strip():
                    cevap_verileri.append({"metin": cevap_metni, "resim_url": resim_url})
                else:
                    cevap_verileri.append({"metin": "", "resim_url": ""})
            soru_resimleri = [i.text().strip() for i in self.soru_resim_inputs]
            video_url = self.video_input.text().strip()
            ay_str = str(self.ay_combo.currentText())
            gun_int = int(self.gun_combo.currentText())
            yil_int = int(self.yil_combo.currentText())
            
            # Seçilen kategoriyi al - Firebase için her zaman Türkçe kategori adını kullan
            # (UI'da İngilizce gösterilse bile, veritabanında tutarlılık için Türkçe saklanır)
            if self.secili_kategori is not None:
                kategori_str = str(self.kategoriler_tr[self.secili_kategori])
            else:
                kategori_str = "Genel"  # Varsayılan kategori
            
            # Doğru cevap index'ini hesapla (0. seçenek boş olduğu için 1 çıkar)
            cevap_index_int = int(self.dogru_combo.currentIndex()) - 1

            soru_veri = {
                "soru": str(self.soru_input.toPlainText().strip()),
                "cevaplar": cevap_verileri,
                "cevap": cevap_index_int,
                "gün": gun_int,
                "ay": ay_str,
                "yıl": yil_int,
                "kategori": kategori_str,
                "soru_resimleri": soru_resimleri,
                "soru_videosu": video_url
            }
            
            # Seçilen dile göre koleksiyon seç
            secilen_dil_koleksiyon = self.dil_combo.currentData()
            if not secilen_dil_koleksiyon:
                secilen_dil_koleksiyon = "tr_sorular"  # Varsayılan Türkçe
            
            # Eğer koleksiyon değiştiyse eski koleksiyondan sil, yeni koleksiyona ekle
            eski_koleksiyon = getattr(self, 'koleksiyon', 'tr_sorular')
            if eski_koleksiyon != secilen_dil_koleksiyon:
                # Eski koleksiyondan sil
                try:
                    db.collection(eski_koleksiyon).document(self.doc_id).delete()
                except Exception as e:
                    pass
                # Yeni koleksiyona ekle (yeni ID ile)
                db.collection(secilen_dil_koleksiyon).add(soru_veri)
            else:
                # Aynı koleksiyonda güncelle
                db.collection(secilen_dil_koleksiyon).document(self.doc_id).set(soru_veri, merge=False)
            
            # Koleksiyon bilgisini güncelle
            self.koleksiyon = secilen_dil_koleksiyon
            QMessageBox.information(self, "Başarılı", "Soru güncellendi.")
            # Düzenleme sonrası doğrudan seçili tarihin liste ekranına git
            try:
                gun_str = str(gun_int)
                ay_str_local = str(ay_str)
                yil_str = str(yil_int)
                p = SoruListePenceresi(gun_str, ay_str_local, yil_str, koleksiyon=secilen_dil_koleksiyon)
                keep_window(p)
                p.show()  # Dinamik boyutlandırma zaten __init__'de yapıldı
                try:
                    p.raise_(); p.activateWindow()
                except Exception:
                    pass
                self.close()
            except Exception:
                self.geri()
        except Exception as e:
            import traceback
            error_msg = f"Soru güncellenirken hata oluştu:\n{str(e)}\n\nDetay: {traceback.format_exc()}"
            QMessageBox.critical(self, "❌ Hata", error_msg)

    def geri(self):
        try:
            # Öncelik: düzenleme esnasında görünen tarih (previous varsa onu, yoksa combo'lardan al)
            gun = self.prev_gun or self.gun_combo.currentText()
            ay = self.prev_ay or self.ay_combo.currentText()
            yil = self.prev_yil or self.yil_combo.currentText()
            # Koleksiyon bilgisini kullan
            koleksiyon = getattr(self, 'koleksiyon', 'tr_sorular')
            p = SoruListePenceresi(str(gun), str(ay), str(yil), koleksiyon=koleksiyon)
            keep_window(p)
            p.show()  # Dinamik boyutlandırma zaten __init__'de yapıldı
            try:
                p.raise_(); p.activateWindow()
            except Exception:
                pass
            self.close()
        except Exception:
            try:
                d = DuzenlemePaneli()
                d.show()
                self.close()
            except Exception:
                self.close()

    def tarih_sec_ekrani(self):
        # Tercih: doğrudan soru listesine dön (seçili tarihle)
        try:
            if self.prev_gun and self.prev_ay and self.prev_yil:
                koleksiyon = getattr(self, 'koleksiyon', 'tr_sorular')
                p = SoruListePenceresi(self.prev_gun, self.prev_ay, self.prev_yil, koleksiyon=koleksiyon)
                keep_window(p)
                p.show()  # Dinamik boyutlandırma zaten __init__'de yapıldı
                try:
                    p.raise_(); p.activateWindow()
                except Exception:
                    pass
                self.close()
                return
        except Exception:
            pass
        # Yedek: tarih seçim ekranına dön
        try:
            d = DuzenlemePaneli()
            try:
                d.show()
            except Exception:
                pass
            try:
                d.raise_(); d.activateWindow()
            except Exception:
                pass
            self.close()
        except Exception:
            self.close()

    # Düzenleme ekranındaki "Ana Menü" butonunu tarih akışına yönlendir
    def ana_menuye_don(self):
        try:
            m = AnaMenu()
            m.show()
            try:
                m.raise_(); m.activateWindow()
            except Exception:
                pass
            self.close()
        except Exception:
            try:
                m = AnaMenu()
                m.show()
                self.close()
            except Exception:
                self.close()

class DuzenlemePaneli(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Düzenleme - Sorular")
        # Ekran çözünürlüğüne göre dinamik boyutlandırma
        width, height = get_window_size(1200, 700)
        x, y = get_window_position(width, height)
        self.setGeometry(x, y, width, height)
        # Açılan pencereleri referans olarak tut
        self.liste_penceresi = None
        self.edit_panel = None
        # Uygulama ikonu ayarla
        self.setWindowIcon(QIcon("playstore.png"))
        self.init_ui()
        
    def init_ui(self):
        layout = QVBoxLayout()
        layout.setSpacing(12)  # Modern spacing
        layout.setContentsMargins(15, 15, 15, 15)  # Modern margins

        # Modern başlık container - içinde buton ve başlık
        baslik_container = QWidget()
        baslik_container.setStyleSheet("""
            QWidget {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #6366f1, stop:1 #4f46e5);
                border: none;
                border-radius: 12px;
                padding: 15px 20px;
            }
        """)
        header_layout = QHBoxLayout()
        header_layout.setSpacing(15)
        header_layout.setContentsMargins(0, 0, 0, 0)

        # Modern ana menü butonu
        home_btn = QPushButton("🏠 Ana Menü")
        home_btn.setStyleSheet("""
            QPushButton {
                background: rgba(255, 255, 255, 0.95);
                color: #4f46e5;
                font-weight: 600;
                font-size: 13px;
                padding: 10px 20px;
                border: none;
                border-radius: 8px;
                min-height: 38px;
            }
            QPushButton:hover {
                background: rgba(255, 255, 255, 1);
                color: #4338ca;
            }
            QPushButton:pressed {
                background: rgba(255, 255, 255, 0.9);
            }
        """)
        home_btn.clicked.connect(self._go_home)
        header_layout.addWidget(home_btn, alignment=Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignVCenter)
        
        # Modern başlık metni - ortada
        baslik = QLabel("📅 Tarih Seçin")
        baslik.setAlignment(Qt.AlignmentFlag.AlignCenter)
        baslik.setStyleSheet("""
            QLabel {
                font-size: 24px;
                font-weight: 700;
                color: #ffffff;
                background: transparent;
                border: none;
                padding: 0px;
            }
        """)
        header_layout.addWidget(baslik, stretch=1)
        header_layout.addStretch()
        
        baslik_container.setLayout(header_layout)
        layout.addWidget(baslik_container)

        # Dil seçimi - Başlık altında
        dil_container = QWidget()
        dil_container.setStyleSheet("""
            QWidget {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #f8fafc, stop:1 #f1f5f9);
                border: 2px solid #e2e8f0;
                border-radius: 8px;
                padding: 10px 15px;
            }
        """)
        dil_layout = QHBoxLayout()
        dil_layout.setSpacing(10)
        dil_layout.setContentsMargins(0, 0, 0, 0)
        
        dil_label = QLabel("🌐 Dil:")
        dil_label.setStyleSheet("font-size: 14px; font-weight: bold; color: #1e293b;")
        dil_layout.addWidget(dil_label)
        
        self.dil_combo = QComboBox()
        self.dil_combo.addItem("🇹🇷 Türkçe (tr_sorular)", "tr_sorular")
        self.dil_combo.addItem("🇬🇧 English (en_sorular)", "en_sorular")
        self.dil_combo.setFont(QFont('Arial', 12))
        self.dil_combo.setMinimumWidth(250)
        self.dil_combo.setStyleSheet("""
            QComboBox {
                border: 2px solid #6366f1;
                border-radius: 6px;
                padding: 8px;
                background-color: white;
                color: #1e293b;
                font-size: 13px;
            }
            QComboBox:focus {
                border-color: #4f46e5;
            }
            QComboBox QAbstractItemView {
                border: 2px solid #6366f1;
                background-color: white;
                selection-background-color: #6366f1;
                selection-color: white;
            }
        """)
        self.dil_combo.currentIndexChanged.connect(self.on_dil_degisti)
        dil_layout.addWidget(self.dil_combo)
        dil_layout.addStretch()
        
        dil_container.setLayout(dil_layout)
        layout.addWidget(dil_container)

        # Modern günler listesi bölümü
        gunler_section = QFrame()
        gunler_section.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #f8fafc, stop:1 #f1f5f9);
                border: 2px solid #e2e8f0;
                border-radius: 12px;
                padding: 20px;
                margin: 10px;
            }
        """)
        gunler_layout = QVBoxLayout()
        gunler_layout.setContentsMargins(0, 0, 0, 0)
        
        # Modern tarih butonları scroll area
        self.tarih_scroll = QScrollArea()
        self.tarih_scroll.setWidgetResizable(True)
        try:
            # İçeriği sol-üstte hizala
            self.tarih_scroll.setAlignment(Qt.AlignmentFlag.AlignTop | Qt.AlignmentFlag.AlignLeft)
        except Exception:
            pass
        self.tarih_scroll.setStyleSheet("""
            QScrollArea {
                border: 2px solid #e2e8f0;
                border-radius: 10px;
                background-color: white;
            }
            QScrollBar:vertical {
                background: #f1f5f9;
                width: 14px;
                border: none;
                border-radius: 7px;
                margin: 2px;
            }
            QScrollBar::handle:vertical {
                background: #cbd5e1;
                min-height: 30px;
                border-radius: 7px;
                margin: 2px;
            }
            QScrollBar::handle:vertical:hover {
                background: #94a3b8;
            }
            QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
                height: 0px;
            }
        """)
        
        # Tarih butonları container
        self.tarih_widget = QWidget()
        from PyQt6.QtWidgets import QGridLayout as _QGridLayout
        self.tarih_buttons_layout = _QGridLayout()
        self.tarih_buttons_layout.setSpacing(12)  # Modern spacing
        try:
            # Layout'un içerik kenar boşluklarını ayarla
            self.tarih_buttons_layout.setContentsMargins(15, 15, 15, 15)
        except Exception:
            pass
        self.tarih_widget.setLayout(self.tarih_buttons_layout)
        self.tarih_scroll.setWidget(self.tarih_widget)
        
        gunler_layout.addWidget(self.tarih_scroll)
        gunler_section.setLayout(gunler_layout)
        layout.addWidget(gunler_section)

        # Modern seçilen tarih - üst bilgi
        self.secilen_tarih_label = QLabel("")
        self.secilen_tarih_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.secilen_tarih_label.setStyleSheet("""
            QLabel {
                color: #1e293b;
                font-size: 14px;
                padding: 10px;
                font-weight: 600;
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #f8fafc, stop:1 #f1f5f9);
                border-radius: 8px;
                border: 1px solid #e2e8f0;
            }
        """)
        layout.addWidget(self.secilen_tarih_label)

        # Modern durum etiketi
        self.status_label = QLabel("")
        self.status_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.status_label.setStyleSheet("""
            QLabel {
                color: #475569;
                font-size: 13px;
                padding: 8px;
                font-weight: 500;
                background: transparent;
            }
        """)
        layout.addWidget(self.status_label)


        # Tablo
        from PyQt6.QtWidgets import QTableWidget, QTableWidgetItem, QHeaderView
        self.table = QTableWidget()
        # Sade görünüm: Seç, Düzenle, Soru, Gün, Ay, Yıl (ID görünmeyecek)
        self.table.setColumnCount(5)
        self.table.setHorizontalHeaderLabels(["Düzenle", "Soru", "Gün", "Ay", "Yıl"])
        self.table.setStyleSheet("""
            QTableWidget {
                font-size: 13px;
                background: white;
                gridline-color: #e2e8f0;
                border: 2px solid #e2e8f0;
                border-radius: 10px;
            }
            QHeaderView::section {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #6366f1, stop:1 #4f46e5);
                color: white;
                padding: 10px;
                border: none;
                font-weight: 600;
                font-size: 13px;
            }
            QTableWidget::item {
                padding: 8px;
            }
            QTableWidget::item:selected {
                background: #6366f1;
                color: white;
            }
        """)
        self.table.verticalHeader().setVisible(False)
        self.table.setAlternatingRowColors(True)
        self.table.setWordWrap(True)
        self.table.horizontalHeader().setStretchLastSection(False)
        self.table.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeMode.Fixed)
        self.table.horizontalHeader().setSectionResizeMode(1, QHeaderView.ResizeMode.Stretch)
        self.table.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeMode.Fixed)
        self.table.horizontalHeader().setSectionResizeMode(3, QHeaderView.ResizeMode.Fixed)
        self.table.horizontalHeader().setSectionResizeMode(4, QHeaderView.ResizeMode.Fixed)
        self.table.setColumnWidth(0, 120)  # Düzenle
        self.table.setColumnWidth(2, 70)   # Gün
        self.table.setColumnWidth(3, 90)   # Ay
        self.table.setColumnWidth(4, 70)   # Yıl
        # Düzenlemeyi aç
        from PyQt6.QtWidgets import QAbstractItemView
        self.table.setEditTriggers(QAbstractItemView.EditTrigger.DoubleClicked | QAbstractItemView.EditTrigger.SelectedClicked)
        
        # Tabloyu başlangıçta gizle
        self.table.setVisible(False)
        layout.addWidget(self.table)

        self.setLayout(layout)
        
        # Tarihleri yükle
        self.load_tarihler()
    
    def _go_home(self):
        try:
            if hasattr(self, 'anasayfaya_don') and callable(self.anasayfaya_don):
                self.anasayfaya_don()
                return
        except Exception:
            pass
        try:
            m = AnaMenu()
            keep_window(m)
            m.show()
            try:
                m.raise_(); m.activateWindow()
            except Exception:
                pass
            self.close()
        except Exception:
            pass
    
    def on_dil_degisti(self):
        """Dil değiştiğinde tarihleri yeniden yükle"""
        self.load_tarihler()
    
    def load_tarihler(self):
        """Veritabanından mevcut tarihleri yükler ve butonlara ekler"""
        if not db:
            return
        
        try:
            # Seçilen dile göre koleksiyon seç
            secilen_dil_koleksiyon = self.dil_combo.currentData()
            if not secilen_dil_koleksiyon:
                secilen_dil_koleksiyon = "tr_sorular"  # Varsayılan Türkçe
            
            # Seçilen koleksiyondan soruları çek
            sorular = db.collection(secilen_dil_koleksiyon).stream()
            
            tarihler = set()
            
            for soru in sorular:
                data = soru.to_dict() or {}
                
                gun = data.get("gün")
                ay = data.get("ay")
                yil = data.get("yıl")
                
                if gun and ay and yil:
                    tarih_str = f"{gun} {ay} {yil}"
                    tarihler.add((tarih_str, int(yil), ay, int(gun)))
            
            # Tarihleri sırala (yıl, ay, gün)
            ay_sirasi = {"Ocak": 1, "Şubat": 2, "Mart": 3, "Nisan": 4, "Mayıs": 5, "Haziran": 6,
                        "Temmuz": 7, "Ağustos": 8, "Eylül": 9, "Ekim": 10, "Kasım": 11, "Aralık": 12,
                        "January": 1, "February": 2, "March": 3, "April": 4, "May": 5, "June": 6,
                        "July": 7, "August": 8, "September": 9, "October": 10, "November": 11, "December": 12}
            
            tarih_listesi = sorted(tarihler, key=lambda x: (x[1], ay_sirasi.get(x[2], 0), x[3]), reverse=True)
            
            # Eski butonları temizle
            for i in reversed(range(self.tarih_buttons_layout.count())):
                child = self.tarih_buttons_layout.itemAt(i).widget()
                if child:
                    child.setParent(None)
            
            # Modern tarih butonları oluştur (3 sütunlu grid)
            col_count = 3
            for idx, (tarih_str, yil, ay, gun) in enumerate(tarih_listesi):
                
                tarih_btn = QPushButton(tarih_str)
                tarih_btn.setFixedHeight(50)
                tarih_btn.setMinimumWidth(160)
                tarih_btn.setStyleSheet("""
                    QPushButton {
                        background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #ffffff, stop:1 #f8fafc);
                        color: #1e293b;
                        border: 2px solid #6366f1;
                        border-radius: 10px;
                        padding: 10px 15px;
                        font-size: 13px;
                        font-weight: 600;
                        text-align: center;
                    }
                    QPushButton:hover {
                        background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #6366f1, stop:1 #4f46e5);
                        color: white;
                        border-color: #4338ca;
                    }
                    QPushButton:pressed {
                        background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #4f46e5, stop:1 #4338ca);
                        color: white;
                        border-color: #3730a3;
                    }
                """)
                
                # Buton tıklama olayını bağla
                def _make_tarih_handler(tarih_text):
                    def handler():
                        self.tarih_sec(tarih_text)
                    return handler
                
                tarih_btn.clicked.connect(_make_tarih_handler(tarih_str))
                r = idx // col_count
                c = idx % col_count
                self.tarih_buttons_layout.addWidget(tarih_btn, r, c)
                    
        except Exception as e:
            pass
    
    def tarih_sec(self, tarih_str):
        """Seçilen tarihi ayır ve kayıtlar ekranını aç"""
        parts = tarih_str.split()
        if len(parts) >= 3:
            gun = parts[0]
            ay = parts[1]
            yil = parts[2]
            # Seçilen dile göre koleksiyon seç
            secilen_dil_koleksiyon = self.dil_combo.currentData()
            if not secilen_dil_koleksiyon:
                secilen_dil_koleksiyon = "tr_sorular"  # Varsayılan Türkçe
            
            try:
                p = SoruListePenceresi(gun, ay, yil, koleksiyon=secilen_dil_koleksiyon)
                keep_window(p)
                p.show()  # Dinamik boyutlandırma zaten __init__'de yapıldı
                try:
                    p.raise_(); p.activateWindow()
                except Exception:
                    pass
                self.close()
            except Exception as e:
                self.load_rows_by_date(gun, ay, yil, koleksiyon=secilen_dil_koleksiyon)
    
    def load_gunler(self):
        """Veritabanından mevcut günleri yükler ve butonlara ekler"""
        if not db:
            return
        
        try:
            # Tüm soruları çek
            sorular = db.collection("sorular").stream()
            
            gunler = set()
            
            for soru in sorular:
                data = soru.to_dict() or {}
                
                gun = data.get("gün")
                ay = data.get("ay")
                yil = data.get("yıl")
                
                if gun and ay and yil:
                    gun_str = f"{gun} {ay} {yil}"
                    gunler.add((gun_str, int(yil), ay, int(gun)))
            
            # Günleri sırala (yıl, ay, gün)
            ay_sirasi = {"Ocak": 1, "Şubat": 2, "Mart": 3, "Nisan": 4, "Mayıs": 5, "Haziran": 6,
                        "Temmuz": 7, "Ağustos": 8, "Eylül": 9, "Ekim": 10, "Kasım": 11, "Aralık": 12}
            
            gun_listesi = sorted(gunler, key=lambda x: (x[1], ay_sirasi.get(x[2], 0), x[3]), reverse=True)
            
            # Eski butonları temizle
            for i in reversed(range(self.gunler_buttons_layout.count())):
                child = self.gunler_buttons_layout.itemAt(i).widget()
                if child:
                    child.setParent(None)
            
            # Yeni gün butonları oluştur
            for gun_str, yil, ay, gun in gun_listesi:
                gun_btn = QPushButton(gun_str)
                gun_btn.setStyleSheet("""
                    QPushButton {
                        background-color: #f8f9fa;
                        color: #2d5a27;
                        border: 2px solid #28a745;
                        border-radius: 8px;
                        padding: 10px 15px;
                        font-size: 14px;
                        font-weight: bold;
                        text-align: left;
                        margin: 2px;
                    }
                    QPushButton:hover {
                        background-color: #e8f5e8;
                        border-color: #1e7e34;
                    }
                    QPushButton:pressed {
                        background-color: #28a745;
                        color: white;
                    }
                """)
                
                # Buton tıklama olayını bağla
                gun_btn.clicked.connect(lambda checked, t=gun_str: self.gun_sec(t))
                self.gunler_buttons_layout.addWidget(gun_btn)
                    
        except Exception as e:
            pass
    
    def gun_sec(self, gun_str):
        """Seçilen günü ayır ve soruları yükle"""
        # Gün string'ini parçala
        parts = gun_str.split()
        if len(parts) >= 3:
            gun = parts[0]
            ay = parts[1]
            yil = parts[2]
            
            # Bu gündeki soruları yükle
            self.load_rows_by_date(gun, ay, yil)
    
    def load_date_options(self):
        """Veritabanından mevcut tarihleri yükler ve butonlara ekler"""
        if not db:
            return
        
        try:
            # Tüm soruları çek
            sorular = db.collection("sorular").stream()
            
            tarihler = set()
            
            for soru in sorular:
                data = soru.to_dict() or {}
                
                gun = data.get("gün")
                ay = data.get("ay")
                yil = data.get("yıl")
                
                if gun and ay and yil:
                    tarih_str = f"{gun} {ay} {yil}"
                    tarihler.add((tarih_str, int(yil), ay, int(gun)))
            
            # Tarihleri sırala (yıl, ay, gün)
            ay_sirasi = {"Ocak": 1, "Şubat": 2, "Mart": 3, "Nisan": 4, "Mayıs": 5, "Haziran": 6,
                        "Temmuz": 7, "Ağustos": 8, "Eylül": 9, "Ekim": 10, "Kasım": 11, "Aralık": 12}
            
            tarih_listesi = sorted(tarihler, key=lambda x: (x[1], ay_sirasi.get(x[2], 0), x[3]), reverse=True)
            
            # Eski butonları temizle
            for i in reversed(range(self.tarih_buttons_layout.count())):
                child = self.tarih_buttons_layout.itemAt(i).widget()
                if child:
                    child.setParent(None)
            
            # Yeni tarih butonları oluştur
            for tarih_str, yil, ay, gun in tarih_listesi:
                tarih_btn = QPushButton(tarih_str)
                tarih_btn.setStyleSheet("""
                    QPushButton {
                        background-color: #f8f9fa;
                        color: #2d5a27;
                        border: 2px solid #28a745;
                        border-radius: 8px;
                        padding: 10px 15px;
                        font-size: 14px;
                        font-weight: bold;
                        text-align: left;
                        margin: 2px;
                    }
                    QPushButton:hover {
                        background-color: #e8f5e8;
                        border-color: #1e7e34;
                    }
                    QPushButton:pressed {
                        background-color: #28a745;
                        color: white;
                    }
                """)
                
                # Buton tıklama olayını bağla
                tarih_btn.clicked.connect(lambda checked, t=tarih_str: self.tarih_sec(t))
                self.tarih_buttons_layout.addWidget(tarih_btn)
                    
        except Exception as e:
            pass
    
    def load_rows_by_date(self, gun, ay, yil, koleksiyon: str = "tr_sorular"):
        """Belirli bir tarihteki soruları yükler"""
        from PyQt6.QtWidgets import QPushButton
        from functools import partial
        if not db:
            QMessageBox.warning(self, "Hata", "Veritabanı bağlantısı yok!")
            return
        
        try:
            # Üst bilgi: seçilen tarih
            try:
                self.secilen_tarih_label.setText(f"Seçilen Tarih: {gun} {ay} {yil}")
            except Exception:
                pass
            # Yerel açıcı: doğrudan düzenleme penceresini aç
            def _open_edit_local(doc_id: str, preload: dict | None = None):
                try:
                    self.edit_panel = SoruDuzenlemePaneli(doc_id, initial_data=preload, koleksiyon=koleksiyon)
                    try:
                        self.edit_panel.destroyed.connect(lambda _=None: self.show())
                    except Exception:
                        pass
                    keep_window(self.edit_panel)
                    self.edit_panel.show()  # Dinamik boyutlandırma zaten __init__'de yapıldı
                    try:
                        self.edit_panel.raise_(); self.edit_panel.activateWindow()
                    except Exception:
                        pass
                    self.hide()
                except Exception as e:
                    QMessageBox.critical(self, "Hata", f"Düzenleme ekranı açılamadı: {e}")

            # Eski satırları temizle
            self.table.setRowCount(0)
            # Satır -> belge ID eşlemesi
            self.row_ids: list[str] = []
            
            # Tüm belgeleri çek - seçilen koleksiyondan
            try:
                q = db.collection(koleksiyon)
                sorular = q.stream()
            except Exception as e:
                QMessageBox.critical(self, "Hata", f"Firebase bağlantı hatası: {e}")
                return

            def parse_int(val: object) -> int:
                if isinstance(val, int):
                    return val
                if isinstance(val, str) and val.isdigit():
                    return int(val)
                return 0

            # Sadece seçilen tarihteki kayıtları yükle
            rows = []
            for s in sorular:
                d = s.to_dict() or {}
                yil_val = parse_int(d.get("yıl"))
                ay_name = d.get("ay")
                gun_val = parse_int(d.get("gün"))

                # Tarih eşleşmesi kontrolü
                if (str(gun_val) == gun and ay_name == ay and str(yil_val) == yil):
                    rows.append({
                        "id": s.id,
                        "kategori": d.get("kategori", "Genel"),
                        "soru": d.get("soru", ""),
                        "cevaplar": d.get("cevaplar", []),
                        "dogru": (parse_int(d.get("cevap")) + 1),
                        "gun": gun_val,
                        "ay": ay_name,
                        "yil": yil_val,
                        "resim_url": d.get("resim_url", "") or d.get("resim", "") or "",
                        "video_url": d.get("video_url", "") or d.get("video", "") or ""
                    })

            # Tabloyu görünür yap
            self.table.setVisible(True)
            
            self.table.setRowCount(len(rows))
            from PyQt6.QtWidgets import QTableWidgetItem, QCheckBox, QWidget, QPushButton
            from PyQt6.QtWidgets import QHBoxLayout as _QHBox
            for r, item in enumerate(rows):
                # Eşlemeyi sakla (ID görünmeyecek)
                self.row_ids.append(item["id"]) 

                # Düzenle butonu
                edit_btn = QPushButton("DÜZENLE")
                edit_btn.setStyleSheet(
                    "QPushButton{background:#0d6efd; color:#ffffff; font-weight:bold; padding:0px; border:1px solid #0b5ed7; border-radius:0px;}"
                    " QPushButton:hover{background:#3b82f6; color:#ffffff;}"
                    " QPushButton:pressed{background:#0b5ed7; color:#ffffff;}"
                )
                try:
                    from PyQt6.QtWidgets import QSizePolicy as _QSizePolicy
                    edit_btn.setSizePolicy(_QSizePolicy.Policy.Expanding, _QSizePolicy.Policy.Expanding)
                    edit_btn.setMinimumHeight(1)
                except Exception:
                    pass
                edit_btn.setAutoDefault(False)
                edit_btn.setDefault(False)
                # satır verilerini önceden panele geçir (hızlı dolum için)
                preload = {
                    "soru": item.get("soru", ""),
                    "gün": item.get("gun", 0),
                    "ay": item.get("ay", "Ocak"),
                    "yıl": item.get("yil", 2024),
                    "kategori": item.get("kategori", "Genel"),
                    "cevaplar": item.get("cevaplar", []),
                    "cevap": (item.get("dogru", 1) - 1) if isinstance(item.get("dogru"), int) else item.get("dogru"),
                    "soru_resimleri": item.get("soru_resimleri", []),
                    "soru_videosu": item.get("video_url", ""),
                }
                edit_btn.clicked.connect(lambda _=False, did=item["id"], data=preload: _open_edit_local(did, data))
                edit_widget = QWidget()
                edit_layout = _QHBox()
                edit_layout.setContentsMargins(0,0,0,0)
                edit_layout.setSpacing(0)
                edit_layout.addWidget(edit_btn)
                edit_widget.setLayout(edit_layout)
                self.table.setCellWidget(r, 0, edit_widget)

                soru_item = QTableWidgetItem(item["soru"])      # 1
                gun_item = QTableWidgetItem(str(item["gun"]))   # 2
                ay_item = QTableWidgetItem(item["ay"])          # 3
                yil_item = QTableWidgetItem(str(item["yil"]))   # 4

                # Hizalar
                soru_item.setTextAlignment(int(Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignVCenter))
                gun_item.setTextAlignment(int(Qt.AlignmentFlag.AlignCenter))
                ay_item.setTextAlignment(int(Qt.AlignmentFlag.AlignCenter))
                yil_item.setTextAlignment(int(Qt.AlignmentFlag.AlignCenter))

                self.table.setItem(r, 1, soru_item)
                self.table.setItem(r, 2, gun_item)
                self.table.setItem(r, 3, ay_item)
                self.table.setItem(r, 4, yil_item)
            self.table.resizeRowsToContents()
            
            if len(rows) == 0:
                self.status_label.setText(f"{gun} {ay} {yil} tarihinde kayıt bulunamadı")
            else:
                self.status_label.setText(f"{gun} {ay} {yil} tarihinde {len(rows)} kayıt bulundu")
                
        except Exception as e:
            import traceback
            error_msg = f"Sorular yüklenemedi: {e}\n\nDetay: {traceback.format_exc()}"
            QMessageBox.critical(self, "Hata", error_msg)


class SoruListePenceresi(QWidget):
    def __init__(self, gun: str, ay: str, yil: str, koleksiyon: str = "tr_sorular"):
        super().__init__()
        
        self.setWindowTitle(f"{gun} {ay} {yil} - Sorular")
        # Ekran çözünürlüğüne göre dinamik boyutlandırma
        width, height = get_window_size(1200, 700)
        x, y = get_window_position(width, height)
        self.setGeometry(x, y, width, height)
        self.gun = gun
        self.ay = ay
        self.yil = yil
        self.koleksiyon = koleksiyon  # Hangi koleksiyondan geldiğini sakla
        
        # Açılan düzenleme panelini tut
        self.edit_panel = None
        # Satır önbelleği: doc_id -> veri (ön doldurma için)
        self.rows_cache = {}
        # Uygulama ikonu ayarla
        self.setWindowIcon(QIcon("playstore.png"))
        self.init_ui()

    def init_ui(self):
        from PyQt6.QtWidgets import QTableWidget, QTableWidgetItem, QHeaderView
        layout = QVBoxLayout()
        layout.setSpacing(12)
        layout.setContentsMargins(15, 15, 15, 15)

        # Modern üst bar container
        top_container = QWidget()
        top_container.setStyleSheet("""
            QWidget {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #6366f1, stop:1 #4f46e5);
                border: none;
                border-radius: 12px;
                padding: 15px 20px;
            }
        """)
        top_bar = QHBoxLayout()
        top_bar.setSpacing(15)
        top_bar.setContentsMargins(0, 0, 0, 0)
        
        geri_btn = QPushButton("⬅️ Geri")
        geri_btn.setStyleSheet("""
            QPushButton {
                background: rgba(255, 255, 255, 0.95);
                color: #4f46e5;
                font-weight: 600;
                font-size: 13px;
                padding: 10px 20px;
                border: none;
                border-radius: 8px;
                min-height: 38px;
            }
            QPushButton:hover {
                background: rgba(255, 255, 255, 1);
                color: #4338ca;
            }
            QPushButton:pressed {
                background: rgba(255, 255, 255, 0.9);
            }
        """)
        geri_btn.clicked.connect(self.geri)
        top_bar.addWidget(geri_btn)
        
        top_bar.addStretch()
        
        baslik = QLabel(f"📅 {self.gun} {self.ay} {self.yil} - Kayıtlar")
        baslik.setAlignment(Qt.AlignmentFlag.AlignCenter)
        baslik.setStyleSheet("""
            QLabel {
                font-size: 24px;
                font-weight: 700;
                color: #ffffff;
                background: transparent;
                border: none;
                padding: 0px;
            }
        """)
        top_bar.addWidget(baslik, stretch=1)
        top_bar.addStretch()
        
        top_container.setLayout(top_bar)
        layout.addWidget(top_container)

        # Modern tablo
        self.table = QTableWidget()
        self.table.setColumnCount(6)
        self.table.setHorizontalHeaderLabels(["Düzenle", "Sil", "Soru", "Gün", "Ay", "Yıl"])
        self.table.setStyleSheet("""
            QTableWidget {
                font-size: 13px;
                background: white;
                gridline-color: #e2e8f0;
                border: 2px solid #e2e8f0;
                border-radius: 10px;
            }
            QHeaderView::section {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #6366f1, stop:1 #4f46e5);
                color: white;
                padding: 10px;
                border: none;
                font-weight: 600;
                font-size: 13px;
            }
            QTableWidget::item {
                padding: 8px;
            }
            QTableWidget::item:selected {
                background: #6366f1;
                color: white;
            }
        """)
        self.table.verticalHeader().setVisible(False)
        self.table.horizontalHeader().setStretchLastSection(False)
        self.table.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeMode.Fixed)  # Düzenle
        self.table.horizontalHeader().setSectionResizeMode(1, QHeaderView.ResizeMode.Fixed)  # Sil
        self.table.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeMode.Stretch) # Soru
        self.table.horizontalHeader().setSectionResizeMode(3, QHeaderView.ResizeMode.Fixed)   # Gün
        self.table.horizontalHeader().setSectionResizeMode(4, QHeaderView.ResizeMode.Fixed)   # Ay
        self.table.horizontalHeader().setSectionResizeMode(5, QHeaderView.ResizeMode.Fixed)   # Yıl
        self.table.setColumnWidth(0, 110)
        self.table.setColumnWidth(1, 90)
        self.table.setColumnWidth(3, 70)
        self.table.setColumnWidth(4, 90)
        self.table.setColumnWidth(5, 70)
        layout.addWidget(self.table)

        # Modern durum etiketi (kayıt sayısı vb.)
        self.status_label = QLabel("")
        self.status_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.status_label.setStyleSheet("""
            QLabel {
                color: #475569;
                font-size: 13px;
                padding: 10px;
                font-weight: 500;
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #f8fafc, stop:1 #f1f5f9);
                border-radius: 8px;
                border: 1px solid #e2e8f0;
            }
        """)
        layout.addWidget(self.status_label)

        # Alt bar kaldırıldı (Ana Menü yok)

        self.setLayout(layout)

        self.load_rows()

    def load_rows(self):
        # DuzenlemePaneli.load_rows_by_date ile aynı mantık
        from PyQt6.QtWidgets import QPushButton
        if not db:
            QMessageBox.warning(self, "Hata", "Veritabanı bağlantısı yok!")
            return
        try:
            self.table.setRowCount(0)
            self.row_ids: list[str] = []
            self.rows_cache = {}

            def parse_int(val: object) -> int:
                if isinstance(val, int):
                    return val
                if isinstance(val, str) and val.isdigit():
                    return int(val)
                return 0

            q = db.collection(self.koleksiyon)
            sorular = q.stream()
            rows = []
            for s in sorular:
                d = s.to_dict() or {}
                yil_val = parse_int(d.get("yıl"))
                ay_name = d.get("ay")
                gun_val = parse_int(d.get("gün"))
                if (str(gun_val) == self.gun and ay_name == self.ay and str(yil_val) == self.yil):
                    row_obj = {
                        "id": s.id,
                        "soru": d.get("soru", ""),
                        "gun": gun_val,
                        "ay": ay_name,
                        "yil": yil_val,
                        "kategori": d.get("kategori", "Genel"),
                        "cevaplar": d.get("cevaplar", []),
                        "cevap": d.get("cevap"),
                        "dogru": d.get("cevap"),
                        "soru_resimleri": d.get("soru_resimleri", []),
                        "soru_videosu": d.get("soru_videosu", ""),
                        "video_url": d.get("video_url", "")
                    }
                    rows.append(row_obj)
                    self.rows_cache[s.id] = row_obj

            from PyQt6.QtWidgets import QTableWidgetItem
            self.table.setRowCount(len(rows))
            
            for r, item in enumerate(rows):
                self.row_ids.append(item["id"])
                
                edit_btn = QPushButton("DÜZENLE")
                edit_btn.setStyleSheet("""
                    QPushButton {
                        background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #6366f1, stop:1 #4f46e5);
                        color: white;
                        font-weight: 600;
                        font-size: 12px;
                        padding: 8px 12px;
                        border: none;
                        border-radius: 8px;
                    }
                    QPushButton:hover {
                        background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #818cf8, stop:1 #6366f1);
                    }
                    QPushButton:pressed {
                        background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #4f46e5, stop:1 #4338ca);
                    }
                """)
                def _make_edit(doc_id: str):
                    return lambda: self.open_edit_panel(doc_id)
                edit_btn.clicked.connect(_make_edit(item["id"]))
                from PyQt6.QtWidgets import QWidget as _QW, QHBoxLayout as _QHBox
                w = _QW()
                h = _QHBox()
                h.setContentsMargins(0,0,0,0)
                h.setSpacing(0)
                h.setSpacing(0)
                h.addWidget(edit_btn)
                w.setLayout(h)
                try:
                    w.setContentsMargins(0,0,0,0)
                except Exception:
                    pass
                self.table.setCellWidget(r, 0, w)

                # Modern Sil butonu
                del_btn = QPushButton("SİL")
                del_btn.setStyleSheet("""
                    QPushButton {
                        background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #ef4444, stop:1 #dc2626);
                        color: white;
                        font-weight: 600;
                        font-size: 12px;
                        padding: 8px 12px;
                        border: none;
                        border-radius: 8px;
                    }
                    QPushButton:hover {
                        background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #f87171, stop:1 #ef4444);
                    }
                    QPushButton:pressed {
                        background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #dc2626, stop:1 #b91c1c);
                    }
                """)
                try:
                    from PyQt6.QtWidgets import QSizePolicy as _QSizePolicy
                    del_btn.setSizePolicy(_QSizePolicy.Policy.Expanding, _QSizePolicy.Policy.Expanding)
                    del_btn.setMinimumHeight(1)
                except Exception:
                    pass
                # Silmeden önce onay iste
                del_btn.clicked.connect(lambda _=False, did=item["id"], row=r: self._confirm_and_delete(did, row))
                w2 = _QW(); h2 = _QHBox(); h2.setContentsMargins(0,0,0,0); h2.setSpacing(0); h2.addWidget(del_btn); w2.setLayout(h2)
                try:
                    w2.setContentsMargins(0,0,0,0)
                except Exception:
                    pass
                self.table.setCellWidget(r, 1, w2)

                self.table.setItem(r, 2, QTableWidgetItem(item["soru"]))
                self.table.setItem(r, 3, QTableWidgetItem(str(item["gun"])))
                self.table.setItem(r, 4, QTableWidgetItem(item["ay"]))
                self.table.setItem(r, 5, QTableWidgetItem(str(item["yil"])))
            
            self.table.resizeRowsToContents()
        except Exception as e:
            import traceback
            error_msg = f"Sorular yüklenemedi: {e}\n\nDetay: {traceback.format_exc()}"
            QMessageBox.critical(self, "Hata", error_msg)

    def open_edit_panel(self, doc_id: str):
        try:
            preload = self.rows_cache.get(doc_id, {})
            self.edit_panel = SoruDuzenlemePaneli(doc_id, initial_data=preload, koleksiyon=self.koleksiyon)
            # Çocuk kapanınca bu pencereyi geri göster
            try:
                self.edit_panel.destroyed.connect(lambda _=None: self.show())
            except Exception:
                pass
            keep_window(self.edit_panel)
            self.edit_panel.show()  # Dinamik boyutlandırma zaten __init__'de yapıldı
            try:
                self.edit_panel.raise_(); self.edit_panel.activateWindow()
            except Exception:
                pass
            self.hide()
        except Exception as e:
            QMessageBox.critical(self, "Hata", f"Düzenleme ekranı açılamadı: {e}")

    def _confirm_and_delete(self, doc_id: str, row_index: int):
        try:
            reply = QMessageBox.question(
                self,
                "Sil",
                "Bu kaydı silmek istediğinizden emin misiniz?",
                QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
                QMessageBox.StandardButton.No,
            )
            if reply != QMessageBox.StandardButton.Yes:
                return
            # Firestore'dan sil - seçilen koleksiyondan
            db.collection(self.koleksiyon).document(doc_id).delete()
            # Son kayıt mı? Evetse Düzenleme ana sayfasına dön
            try:
                remaining = self.table.rowCount() - 1
            except Exception:
                remaining = 0
            if remaining <= 0:
                try:
                    d = DuzenlemePaneli()
                    keep_window(d)
                    d.show()  # Dinamik boyutlandırma zaten __init__'de yapıldı
                    try:
                        d.raise_(); d.activateWindow()
                    except Exception:
                        pass
                    self.close()
                    return
                except Exception:
                    pass
            # Aksi halde seçili tarihin kayıtlarına yeniden git (pencere açık kalsın)
            try:
                p = SoruListePenceresi(self.gun, self.ay, self.yil, koleksiyon=self.koleksiyon)
                keep_window(p)
                p.show()  # Dinamik boyutlandırma zaten __init__'de yapıldı
                try:
                    p.raise_(); p.activateWindow()
                except Exception:
                    pass
                self.close()
            except Exception:
                # En azından satırı kaldırmayı dene
                if 0 <= row_index < self.table.rowCount():
                    self.table.removeRow(row_index)
        except Exception as e:
            QMessageBox.critical(self, "Hata", f"Silinemedi: {e}")

    def geri(self):
        try:
            p = DuzenlemePaneli()
            keep_window(p)
            p.show()  # Dinamik boyutlandırma zaten __init__'de yapıldı
            try:
                p.raise_(); p.activateWindow()
            except Exception:
                pass
            self.close()
        except Exception:
            self.close()

    def ana_menu(self):
        try:
            m = AnaMenu()
            m.show()
            self.close()
        except Exception:
            self.close()
    

if __name__ == "__main__":
    app = QApplication(sys.argv)
    # Son pencere kapanınca uygulama kapanmasın
    try:
        app.setQuitOnLastWindowClosed(True)
    except Exception:
        pass
    
    # Uygulama ayarları
    app.setApplicationName("Trafik Koçu Soru Yönetim Sistemi")
    app.setApplicationVersion("2.0")
    
    # Ana menüyü başlat
    window = AnaMenu()
    window.show()
    # Show image on top-right of the main window after it exists
    
    sys.exit(app.exec())