import json
import logging
import os
import sys
import tempfile

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QColor, QFont, QPalette, QPixmap
from PyQt6.QtWidgets import (
    QApplication,
    QComboBox,
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
    "project_id": "oval-cyclist-472813-c6",
    "private_key_id": "9c82abc564231054c61bfb94f1c18ebe3be992af",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDUGVPBzIOVkl7D\npLB7f3//LKpHpLI1OZnxMqX8OwHZmuPKNQX3oHn0B4dO3BMOWZWfYw/7IcDHTBeM\nAiSD5+283V1AOoBJcyxxRy35Xu1xggKv+DHUs7SZsdQzGEF/qQTY2/Fuv+4r8KCW\nXEnIKEoutSxZFFHOjvNzB0gwAOP6gH9TPxMQNrnYynxjQJqtlj+KS+VZ5BPFKcFU\n6Ga3JrJc+BAtI3CSiVLkmlskPbjETg+bc1alRAd8T0T8chmvr4hrN9LNfOpZGqPf\nxKM9Ex/rScSmA6dmY6ix/3qdHwX53/3iCDrbjPx6VtYDBb5o9A22pjPrNafFwuKp\nub4zg6prAgMBAAECggEARapD/oXEOp6nDa/MX+QTEKeFDp8kAaN30ueF6YEgLG9Z\nnpMn8Jv/Mo4+fUJ/59i48m9BUoVVoqB1o4EYqVLGnaA//ta4SGfSEysECMKLTxsa\n8t2c0HZuPYVRY6715I6Jjwk/FddozXnt5TVO7rV9GDZd6Kxp6mS9xeyAY3QHbcGp\n/Pzszq1cRxVQHZlFzoi6eQPb60E7OGrl+WeynRicO1vDuk9yWNNOMMLIp7oTS08A\n+ru0Jv+6GLigO+5TJr41R6OnlS2eplrew7EJtgp27WaiLtlrnZwOd/LNQI3DK9xL\n18sTJInW0aTZFx3qHcBn64DZpo8frkUJjWNuXzHXwQKBgQDqQmtHkBhRcHVfgxmO\nQVrMdBcRpdw0IJXECKmbWOrVNXqFLvZQAVTPQPPJrJWe21tCItaKfbz1pyCRQKxH\n+xozLGNrC6G/ri+XbxetJG6gWclV+QH6B2Wp6aVTuiqxHsdaxoAjBtEjdgM0Plw1\n15tD1Cv+Z6oCE1423xrXJBvwuwKBgQDnyGoSeu5+PLEHPnfUgY+pM3ti8r0WWl3r\nyc+rdnTWYDfW4/mNmGRz/OGP/JVYqaD0UMOgzzbyt2UQTH+8MN5abrK8FvH6jO5F\nIyl74AgfelD8Xs45bgc/K0iPdDLRhL0RU7mgYujzu9tvxaxNOkltYplamhvCRSOr\nEqeEAt4qEQKBgQClgTOGJdnof8mNJ3SAus/JryM1Rrdi5Lqq+2vI43NWGyhqvBkt\nwSMIIl2a2KIEz/mTqkVlJxy/ecpalRSi7lc+XFgJIviuEgRxuv1BSIIYLBdA9GJf\nIabD+tzhYKAU7yftjFyvYnuT0CbHXF+NcryxmU9TuC22tbRUlB/EbDCJTQKBgQCG\ngbeMoeplN7NEEOxZVhaYilfARD2XCzoV6zeouUV0YsIE4qeflCA3bzk25c2FdmsB\nXR0p5RZuJB9yJfK6s2FV+Yefv3ENhVuAo7cfPBN6sPDug9YJXeC2t9eT6ErVa8KM\nm5nNiZjGWO4vHveumXSjFeUIvwX850KbtGeiJEfpAQKBgH74tZDvGeYbmjo5c+qW\nydRden/GVcekxhYehaHAV3L8P3G3Tg1sbK4IZEfkozDojfm0Mid6KzHRlqgxPjRM\n2eo/PtQft+/rXvQ695x7CRJLY4FyyrUjLz3eZZweFTiHF61Dab52RhfbMzQpezmK\nvyio6k/VRGd5bIg9qc3oxs33\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-fbsvc@oval-cyclist-472813-c6.iam.gserviceaccount.com",
    "client_id": "110946591714011408690",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40oval-cyclist-472813-c6.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
}
# Firebase bağlantısı
def initialize_firebase():
    try:
        # Geçici dosya oluştur
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            json.dump(SERVICE_ACCOUNT_KEY, f)
            temp_file_path = f.name
        
        cred = credentials.Certificate(temp_file_path)
        firebase_admin.initialize_app(cred, {
            'storageBucket': 'oval-cyclist-472813-c6.firebasestorage.app'
        })
        db = firestore.client()
        
        # Geçici dosyayı sil
        os.unlink(temp_file_path)
        
        return db
    except Exception as e:
        print(f"Firebase bağlantısı kurulamadı: {e}")
        return None

db = initialize_firebase()

# Firebase Storage bucket referansı
bucket = None
if db:
    try:
        # Projenin varsayılan bucket'ını kullan
        bucket = storage.bucket()
        # Bucket var mı kontrol et
        try:
            if hasattr(bucket, "exists") and not bucket.exists():
                print(f"Uyarı: Bucket bulunamadı: {bucket.name}. Firebase Console > Storage'da Storage'ı etkinleştirin veya doğru bucket adını girin.")
                bucket = None
        except Exception as _e:
            # exists() bazı ortamlarda yetki/bucket yoksa hata atabilir
            print(f"Bucket doğrulama yapılamadı: {_e}")
    except Exception as e:
        print(f"Firebase Storage bağlantısı kurulamadı: {e}")
        print("Firebase Storage'ın aktif olduğundan emin olun!")

def dosya_yukle_firebase_storage(dosya_yolu, klasor_adi="sorular"):
    """Dosyayı Firebase Storage'a yükler ve URL döndürür"""
    if not bucket:
        print("Bucket bulunamadı!")
        return None
    
    try:
        # Dosya var mı kontrol et
        if not os.path.exists(dosya_yolu):
            print(f"Dosya bulunamadı: {dosya_yolu}")
            return None
            
        print(f"Dosya yükleniyor: {dosya_yolu}")
        
        # Dosya adını oluştur
        import uuid, mimetypes
        dosya_adi = f"{klasor_adi}/{uuid.uuid4()}_{os.path.basename(dosya_yolu)}"
        print(f"Storage yolu: {dosya_adi}")
        
        # Dosyayı yükle
        blob = bucket.blob(dosya_adi)
        content_type, _ = mimetypes.guess_type(dosya_yolu)
        if not content_type:
            content_type = "application/octet-stream"
        # Firebase Storage download token ayarla (herkese açık yapmadan erişim için)
        download_token = str(uuid.uuid4())
        blob.metadata = {"firebaseStorageDownloadTokens": download_token}
        blob.upload_from_filename(dosya_yolu, content_type=content_type)
        print("Dosya yüklendi!")
        
        # Firebase'in standart indirme URL'si (token'lı)
        try:
            from urllib.parse import quote
            encoded_path = quote(dosya_adi, safe='')
            url = (
                f"https://firebasestorage.googleapis.com/v0/b/{bucket.name}/o/{encoded_path}?alt=media&token={download_token}"
            )
            print(f"Download URL: {url}")
        except Exception as e:
            print(f"Download URL oluşturulamadı: {e}")
            url = None
        
        return url
        
    except Exception as e:
        print(f"Dosya yükleme hatası: {e}")
        import traceback
        print(f"Detay: {traceback.format_exc()}")
        return None

class AnaMenu(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Soru Yönetim Sistemi - Ana Menü")
        self.setGeometry(200, 100, 1200, 700)
        self.current_panel = None
        self.init_ui()
    
    def init_ui(self):
        # Ana stil ayarları
        self.setStyleSheet("""
            QWidget {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1, 
                    stop:0 #e8f5e8, stop:1 #c8e6c8);
                font-family: 'Arial', sans-serif;
            }
            QLabel#title {
                color: #2d5a27;
                font-size: 28px;
                font-weight: bold;
                background-color: rgba(255, 255, 255, 0.9);
                border-radius: 15px;
                padding: 20px;
                border: 3px solid #4a934a;
            }
            QPushButton#menuBtn {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #5cb85c, stop:1 #4a934a);
                color: white;
                border: 3px solid #2d5a27;
                border-radius: 20px;
                padding: 20px;
                font-size: 18px;
                font-weight: bold;
                min-height: 80px;
                min-width: 200px;
            }
            QPushButton#menuBtn:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #6fc86f, stop:1 #5cb85c);
                border-color: #1a3d1a;
                border-width: 4px;
            }
            QPushButton#menuBtn:pressed {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #4a934a, stop:1 #2d5a27);
            }
        """)
        
        main_layout = QVBoxLayout()
        main_layout.setSpacing(30)
        main_layout.setContentsMargins(50, 50, 50, 50)
        
        # Başlık
        title = QLabel("Trafik Koçu Soru Yönetim Sistemi")
        title.setObjectName("title")
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        main_layout.addWidget(title)
        
        # Alt başlık kaldırıldı
        
        main_layout.addStretch()
        
        # Menü butonları
        button_layout = QHBoxLayout()
        button_layout.setSpacing(40)
        
        # Sol buton - Soru Ekleme
        soru_ekle_btn = QPushButton("📝\nSORU EKLEME\n\nYeni sorular ekleyin\nve veritabanına kaydedin")
        soru_ekle_btn.setObjectName("menuBtn")
        soru_ekle_btn.clicked.connect(self.soru_ekleme_ac)
        button_layout.addWidget(soru_ekle_btn)
        
        # Sağ buton - Düzenleme (Şimdilik pasif)
        duzenleme_btn = QPushButton("⚙️\nDÜZENLEME\n\nMevcut soruları\ndüzenleyin ve silin")
        duzenleme_btn.setObjectName("menuBtn")
        duzenleme_btn.setEnabled(True)
        duzenleme_btn.setStyleSheet("""
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #26f0e3, stop:1 #1dd1a1);
                color: #ffffff;
                border: 3px solid #2d5a27;
            }
        """)
        duzenleme_btn.clicked.connect(self.duzenleme_ac)
        button_layout.addWidget(duzenleme_btn)
        
        main_layout.addLayout(button_layout)
        main_layout.addStretch()
        
        # Alt bilgi
        info_label = QLabel("💡 Veritabanı bağlantısı aktif" if db else "⚠️ Veritabanı bağlantısı yok")
        info_label.setStyleSheet("""
            color: #2d5a27;
            font-size: 12px;
            text-align: center;
            background-color: rgba(255, 255, 255, 0.7);
            padding: 10px;
            border-radius: 8px;
        """)
        info_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        main_layout.addWidget(info_label)
        
        self.setLayout(main_layout)
    
    def soru_ekleme_ac(self):
        panel = SoruEklemePaneli()
        panel.showFullScreen()
        self.hide()
    
    def duzenleme_ac(self):
        duzenleme_panel = DuzenlemePaneli()
        duzenleme_panel.showFullScreen()
        self.hide()
    
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
        # Landscape (yanlama) düzen için genişlik artırıldı, yükseklik azaltıldı
        self.setGeometry(50, 50, 1400, 800)
        self.init_ui()
        
    def init_ui(self):
        # İyileştirilmiş stil ayarları
        self.setStyleSheet("""
            QWidget {
                background-color: #f8f9fa;
                font-family: 'Arial', sans-serif;
            }
            QLabel {
                color: #2d5a27;
                font-weight: bold;
                font-size: 10px;
                margin-bottom: 2px;
                padding: 1px;
            }
            QLineEdit, QTextEdit {
                border: 2px solid #4a934a;
                border-radius: 6px;
                padding: 8px;
                background-color: white;
                color: #000000;
                font-size: 12px;
                font-weight: normal;
                min-height: 15px;
                selection-background-color: #4a934a;
                selection-color: white;
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
                border: 2px solid #4a934a;
                border-radius: 6px;
                padding: 8px;
                background-color: white;
                color: #000000;
                font-size: 12px;
                font-weight: normal;
                min-height: 15px;
            }
            QComboBox:focus {
                border-color: #2d5a27;
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
                border-top: 4px solid #4a934a;
                margin-right: 8px;
            }
            QComboBox QAbstractItemView {
                border: 2px solid #4a934a;
                background-color: white;
                color: #000000;
                selection-background-color: #4a934a;
                selection-color: white;
                padding: 5px;
            }
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #5cb85c, stop:1 #4a934a);
                color: white;
                border: none;
                border-radius: 8px;
                padding: 10px 20px;
                font-size: 12px;
                font-weight: bold;
                min-height: 15px;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #6fc86f, stop:1 #5cb85c);
            }
            QPushButton:pressed {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #4a934a, stop:1 #2d5a27);
            }
            QPushButton#secondaryBtn {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #868e96, stop:1 #6c757d);
            }
            QPushButton#secondaryBtn:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #9ca3ab, stop:1 #868e96);
            }
            QPushButton#dangerBtn {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #f56565, stop:1 #e53e3e);
            }
            QPushButton#dangerBtn:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #fc8181, stop:1 #f56565);
            }
            QFrame {
                background-color: white;
                border: 2px solid #e0e0e0;
                border-radius: 8px;
                margin: 5px;
                padding: 15px;
            }
            QScrollArea {
                border: none;
                background-color: transparent;
            }
        """)
        
        # Ana layout
        main_layout = QVBoxLayout()
        main_layout.setSpacing(15)
        main_layout.setContentsMargins(20, 20, 20, 20)
        
        # Başlık
        header_layout = QHBoxLayout()
        
        # Geri butonu
        geri_btn = QPushButton("⬅️ Ana Menü")
        geri_btn.setObjectName("secondaryBtn")
        geri_btn.clicked.connect(self.ana_menuye_don)
        header_layout.addWidget(geri_btn)
        
        # Soru listesi butonu kaldırıldı
        
        header_layout.addStretch()
        
        baslik = QLabel("📝 SORU EKLEME PANELİ")
        baslik.setStyleSheet("""
            QLabel {
                font-size: 22px;
                font-weight: bold;
                color: #2d5a27;
                padding: 12px;
                text-align: center;
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, 
                    stop:0 #e8f5e8, stop:1 #d4edda);
                border-radius: 10px;
                border: 2px solid #4a934a;
            }
        """)
        baslik.setAlignment(Qt.AlignmentFlag.AlignCenter)
        
        header_layout.addStretch()
        main_layout.addLayout(header_layout)
        main_layout.addWidget(baslik)
        
        # LANDSCAPE LAYOUT: Scroll Area ile Yanlama Düzen
        scroll = QScrollArea()
        scroll_widget = QWidget()
        scroll_layout = QVBoxLayout()
        
        # Ana içerik çift sütunlu düzen
        content_splitter = QSplitter(Qt.Orientation.Horizontal)
        
        # SOL PANEL - Soru ve Cevaplar
        left_panel = QFrame()
        left_layout = QVBoxLayout()
        left_layout.setSpacing(0)  # Çerçeveler arası boşluk yok
        
        # Soru girişi
        soru_label = QLabel("📝 Soru Metni:")
        soru_label.setStyleSheet("font-size: 20px; font-weight: bold; color: #2d5a27; margin: 1px; padding: 1px;")
        soru_label.setMaximumHeight(50)
        soru_label.setMaximumWidth(170)
        left_layout.addWidget(soru_label)
        self.soru_input = QTextEdit()
        self.soru_input.setMinimumHeight(50)
        self.soru_input.setMaximumHeight(70)
        self.soru_input.setPlaceholderText("Sorunuzu buraya detaylı ve net bir şekilde yazın. Soru açık, anlaşılır ve kapsamlı olmalıdır...")
        font = QFont('Arial', 11)
        self.soru_input.setFont(font)
        left_layout.addWidget(self.soru_input)
        
        # CEVAP SEÇENEKLERİ - Ayrı çerçeve
        cevap_secenekleri_frame = QFrame()
        cevap_secenekleri_frame.setStyleSheet("""
            QFrame {
                border: 2px solid #28a745;
                border-radius: 8px;
                padding: 10px;
                background-color: #f8fff9;
            }
        """)
        cevap_secenekleri_layout = QVBoxLayout()
        cevap_secenekleri_layout.setSpacing(2)
        cevap_secenekleri_layout.setContentsMargins(3, 2, 3, 2)
        # Başlık: Cevaplar giriniz - Büyütüldü
        cevaplar_baslik = QLabel("📝 CEVAPLARI GİRİNİZ")
        cevaplar_baslik.setStyleSheet("""
            QLabel {
                color: #28a745;
                font-weight: bold;
                font-size: 14px;
                padding: 4px 6px;
                margin: 0px;
                background-color: #e9f9ec;
                border: 1px solid #28a745;
                border-radius: 4px;
            }
        """)
        cevaplar_baslik.setAlignment(Qt.AlignmentFlag.AlignLeft)
        # Genişliği düşür (içerik boyutuna göre) ve solda dursun
        cevaplar_baslik.setSizePolicy(QSizePolicy.Policy.Maximum, QSizePolicy.Policy.Fixed)
        cevap_secenekleri_layout.addWidget(cevaplar_baslik, alignment=Qt.AlignmentFlag.AlignLeft)

        
        # Cevap seçenekleri input'ları
        cevap_inputs_layout = QVBoxLayout()
        cevap_inputs_layout.setSpacing(2)
        cevap_inputs_layout.setContentsMargins(0, 2, 0, 2)
        self.cevap_inputs = []

        answer_font = QFont('Arial', 11)
        
        for i in range(4):
            row_layout = QHBoxLayout()
            row_layout.setSpacing(4)
            row_layout.setContentsMargins(0, 1, 0, 1)
            row_layout.setAlignment(Qt.AlignmentFlag.AlignVCenter)

            label = QLabel(f"Cevap {i+1}:")
            label.setMinimumHeight(24)
            label.setMinimumWidth(80)
            label.setStyleSheet("""
                QLabel {
                    color: #28a745;
                    font-weight: bold;
                    font-size: 12px;
                    background-color: #ffffff;
                    border: 1px solid #28a745;
                    border-radius: 4px;
                    padding: 2px 6px;
                    margin: 1px 0px;
                }
            """)
            label.setAlignment(Qt.AlignmentFlag.AlignCenter | Qt.AlignmentFlag.AlignVCenter)
            row_layout.addWidget(label)
            
            line_edit = QLineEdit()
            line_edit.setPlaceholderText(f"Seçenek {i+1}")
            line_edit.setFont(answer_font)
            line_edit.setMinimumHeight(24)
            line_edit.setStyleSheet("""
                QLineEdit {
                    border: 1px solid #28a745;
                    background-color: white;
                    font-size: 11px;
                    padding: 3px 6px;
                    border-radius: 3px;
                }
                QLineEdit:focus {
                    border-color: #1e7e34;
                    background-color: #ffffff;
                }
            """)
            row_layout.addWidget(line_edit)
            self.cevap_inputs.append(line_edit)
            cevap_inputs_layout.addLayout(row_layout)
        
        cevap_secenekleri_layout.addLayout(cevap_inputs_layout)
        
        cevap_secenekleri_frame.setLayout(cevap_secenekleri_layout)
        left_layout.addWidget(cevap_secenekleri_frame)
        # Bölümler arası küçük boşluk
        left_layout.addSpacing(8)
        
        # CEVAP RESİMLERİ - Cevapların altında, boşluk kaldırıldı
        cevap_resimleri_frame = QFrame()
        cevap_resimleri_frame.setStyleSheet("""
            QFrame {
                border: 2px solid #28a745;
                border-radius: 8px;
                padding: 10px;
                background-color: #f8fff9;
            }
        """)
        cevap_resimleri_layout = QVBoxLayout()
        cevap_resimleri_layout.setSpacing(0)
        cevap_resimleri_layout.setContentsMargins(0, 0, 0, 0)  # Üst ve alt boşluk kaldırıldı

        # CEVAP RESİMLERİ başlığı - EN ÜSTTE
        cevap_resim_baslik = QLabel("🖼️ CEVAP RESİMLERİ:")
        cevap_resim_baslik.setStyleSheet("""
            QLabel {
                color: #28a745;
                font-weight: bold;
                font-size: 14px;
                padding: 4px 6px;
                margin: 0px;
                background-color: #e9f9ec;
                border: 1px solid #28a745;
                border-radius: 4px;
            }
        """)
        cevap_resim_baslik.setSizePolicy(QSizePolicy.Policy.Maximum, QSizePolicy.Policy.Fixed)
        # Başlığı frame'in en üstüne ekle
        cevap_resimleri_layout.addWidget(cevap_resim_baslik, alignment=Qt.AlignmentFlag.AlignLeft)

        # Cevap resimleri: Her cevap için ayrı input
        cevap_resim_inputs_layout = QVBoxLayout()
        cevap_resim_inputs_layout.setSpacing(0)
        cevap_resim_inputs_layout.setContentsMargins(0, 6, 0, 0)

        self.cevap_resim_inputs = []
        self.cevap_resim_previews = []
        for i in range(4):
            item_v = QVBoxLayout()
            item_v.setSpacing(0)
            item_v.setContentsMargins(0, 0, 0, 0)

            resim_row = QHBoxLayout()
            resim_row.setSpacing(1)
            resim_row.setContentsMargins(0, 0, 0, 0)

            resim_label = QLabel(f"Cevap {i+1}:")
            resim_label.setMinimumHeight(24)
            resim_label.setMinimumWidth(80)
            resim_label.setStyleSheet("""
                QLabel {
                    color: #28a745;
                    font-weight: bold;
                    font-size: 12px;
                    background-color: #ffffff;
                    border: 1px solid #28a745;
                    border-radius: 4px;
                    padding: 2px 6px;
                    margin: 1px 0px;
                }
            """)
            resim_label.setAlignment(Qt.AlignmentFlag.AlignCenter | Qt.AlignmentFlag.AlignVCenter)
            resim_row.addWidget(resim_label)
            
            resim_input = QLineEdit()
            resim_input.setPlaceholderText(f"Resim URL...")
            resim_input.setFont(QFont('Arial', 10))
            resim_input.setMinimumHeight(24)
            resim_input.setStyleSheet("""
                QLineEdit {
                    border: 1px solid #28a745;
                    background-color: white;
                    font-size: 10px;
                    padding: 3px 6px;
                    border-radius: 3px;
                }
                QLineEdit:focus {
                    border-color: #1e7e34;
                    background-color: #ffffff;
                }
            """)
            resim_row.addWidget(resim_input)
            self.cevap_resim_inputs.append(resim_input)
            
            resim_btn = QPushButton("Seç")
            resim_btn.setObjectName("secondaryBtn")
            resim_btn.setFixedSize(45, 25)
            resim_btn.setStyleSheet("""
                QPushButton {
                    font-size: 9px; 
                    padding: 2px 6px;
                    font-weight: bold;
                }
            """)
            resim_btn.clicked.connect(lambda checked, idx=i: self.cevap_resmi_sec(idx))
            # URL değişince önizleme güncelle
            resim_input.textChanged.connect(lambda _t, idx=i: self._guncelle_cevap_resim_onizleme(idx))
            resim_row.addWidget(resim_btn)

            # Önizleme altta, daha büyük
            preview = QLabel()
            preview.setFixedSize(160, 110)
            preview.setStyleSheet("QLabel{border:1px solid #cfe3cf; background:#ffffff}")
            preview.setScaledContents(True)
            self.cevap_resim_previews.append(preview)

            item_v.addLayout(resim_row)
            item_v.addWidget(preview)

            cevap_resim_inputs_layout.addLayout(item_v)
        
        cevap_resimleri_layout.addLayout(cevap_resim_inputs_layout)
        cevap_resimleri_frame.setLayout(cevap_resimleri_layout)
        left_layout.addWidget(cevap_resimleri_frame)
        
        # Doğru cevap - Kompakt
        dogru_layout = QHBoxLayout()
        dogru_layout.addWidget(QLabel("✅ Doğru Cevap:"))
        self.dogru_combo = QComboBox()
        self.dogru_combo.addItems(["1. Seçenek", "2. Seçenek", "3. Seçenek", "4. Seçenek"])
        self.dogru_combo.setFont(font)
        dogru_layout.addWidget(self.dogru_combo)
        dogru_layout.addStretch()
        left_layout.addLayout(dogru_layout)
        
        left_panel.setLayout(left_layout)
        content_splitter.addWidget(left_panel)
        
        # SAĞ PANEL - Ek Bilgiler ve Medya
        right_panel = QFrame()
        right_layout = QVBoxLayout()
        
        # Tarih bilgileri - Kompakt ve tam görünsün
        tarih_frame = QFrame()
        tarih_frame.setStyleSheet("border: 1px solid #dee2e6; border-radius: 6px; padding: 10px;")
        tarih_layout = QVBoxLayout()
        tarih_baslik_label = QLabel("📅 Tarih Bilgileri:")
        tarih_baslik_label.setStyleSheet("font-size: 16px; font-weight: bold; color: #2d5a27;")
        tarih_layout.addWidget(tarih_baslik_label)
        
        tarih_row1 = QHBoxLayout()
        tarih_row1.addWidget(QLabel("Gün:"))
        self.gun_combo = QComboBox()
        self.gun_combo.addItems([str(i) for i in range(1, 32)])
        self.gun_combo.setFont(font)
        self.gun_combo.setMinimumWidth(70)
        tarih_row1.addWidget(self.gun_combo)
        
        tarih_row1.addWidget(QLabel("Ay:"))
        self.ay_combo = QComboBox()
        aylar = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", 
                "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
        self.ay_combo.addItems(aylar)
        self.ay_combo.setFont(font)
        self.ay_combo.setMinimumWidth(120)
        tarih_row1.addWidget(self.ay_combo)
        
        tarih_row2 = QHBoxLayout()
        tarih_row2.addWidget(QLabel("Yıl:"))
        self.yil_combo = QComboBox()
        yillar = [str(i) for i in range(2020, 2031)]
        self.yil_combo.addItems(yillar)
        self.yil_combo.setCurrentText("2024")
        self.yil_combo.setFont(font)
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
        tarih_frame.setLayout(tarih_layout)
        right_layout.addWidget(tarih_frame)
        
        # Kategori - Clickable Buttons
        kategori_layout = QVBoxLayout()
        kategori_label = QLabel("🏷️ Kategori Seçiniz:")
        kategori_label.setStyleSheet("font-size: 20px; font-weight: bold; color: #2d5a27; margin: 2px; padding: 1px;")
        kategori_label.setMaximumHeight(50)
        kategori_layout.addWidget(kategori_label)

        # Kategori butonları için grid layout
        kategori_buttons_layout = QGridLayout()
        kategori_buttons_layout.setSpacing(8)
        
        # Kategori listesi
        self.kategoriler = [
            "Trafik ve Çevre Bilgisi",
            "İlk Yardım Bilgisi", 
            "Araç Tekniği (Motor ve Araç Bakımı)",
            "Trafik Adabı"
        ]
        
        # Kategori butonları oluştur
        self.kategori_butonlari = []
        self.secili_kategori = None
        
        for i, kategori in enumerate(self.kategoriler):
            btn = QPushButton(kategori)
            btn.setCheckable(True)
            btn.setFont(QFont('Arial', 11))
            btn.setMinimumHeight(45)
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
        soru_medya_frame = QFrame()
        soru_medya_frame.setStyleSheet("""
            QFrame {
                border: 2px solid #17a2b8;
                border-radius: 8px;
                padding: 15px;
                background-color: #f8fdff;
            }
        """)
        soru_medya_layout = QVBoxLayout()
        
        soru_medya_baslik = QLabel("📝 SORU MEDYALARI")
        soru_medya_baslik.setStyleSheet("""
            QLabel {
                font-size: 14px;
                font-weight: bold;
                color: #17a2b8;
                padding: 5px;
                text-align: center;
                background-color: rgba(23, 162, 184, 0.1);
                border-radius: 4px;
            }
        """)
        soru_medya_baslik.setAlignment(Qt.AlignmentFlag.AlignCenter)
        soru_medya_layout.addWidget(soru_medya_baslik)
        
        # Soru resimleri: Birden fazla resim
        soru_resim_layout = QVBoxLayout()
        soru_resim_layout.setSpacing(8)
        soru_resim_layout.setContentsMargins(0, 0, 0, 0)
        soru_resim_baslik = QLabel("🖼️ Soru Resimleri (Maksimum 4 adet):")
        soru_resim_baslik.setStyleSheet("""
            color: #17a2b8; 
            font-weight: bold; 
            font-size: 13px;
            padding: 8px 0px;
            margin: 5px 0px;
        """)
        soru_resim_layout.addWidget(soru_resim_baslik)
        
        self.soru_resim_inputs = []
        self.soru_resim_previews = []
        for i in range(4):
            item_v = QVBoxLayout()
            item_v.setSpacing(4)
            item_v.setContentsMargins(0, 0, 0, 8)

            resim_row = QHBoxLayout()
            resim_row.setSpacing(0)
            resim_row.setContentsMargins(0, 0, 0, 0)

            resim_label = QLabel(f"Resim {i+1}:")
            resim_label.setMinimumHeight(24)
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
            resim_btn.setFixedSize(56, 28)
            resim_btn.setStyleSheet("""
                QPushButton {
                    font-size: 11px; 
                    padding: 4px 8px;
                    font-weight: bold;
                }
            """)
            resim_btn.clicked.connect(lambda checked, idx=i: self.soru_resmi_sec(idx))
            # URL değişince önizleme güncelle
            resim_input.textChanged.connect(lambda _t, idx=i: self._guncelle_soru_resim_onizleme(idx))
            resim_row.addWidget(resim_btn)

            # Önizleme altta, daha büyük
            preview = QLabel()
            preview.setFixedSize(180, 130)
            preview.setStyleSheet("QLabel{border:1px solid #bfe8ef; background:#ffffff}")
            preview.setScaledContents(True)
            self.soru_resim_previews.append(preview)

            item_v.addLayout(resim_row)
            item_v.addWidget(preview)

            soru_resim_layout.addLayout(item_v)
        
        soru_medya_layout.addLayout(soru_resim_layout)
        
        # Soru videosu
        soru_video_layout = QHBoxLayout()
        soru_video_layout.setSpacing(10)
        soru_video_layout.setContentsMargins(0, 15, 0, 5)
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
        self.video_input.setFont(QFont('Arial', 10))
        self.video_input.setStyleSheet("""
            QLineEdit {
                border: 1px solid #17a2b8;
                background-color: white;
                font-size: 10px;
            }
        """)
        soru_video_layout.addWidget(self.video_input)
        video_btn = QPushButton("Seç")
        video_btn.setObjectName("secondaryBtn")
        video_btn.setFixedSize(50, 25)
        video_btn.setStyleSheet("QPushButton { font-size: 10px; padding: 2px; }")
        video_btn.clicked.connect(self.soru_videosu_sec)
        soru_video_layout.addWidget(video_btn)
        soru_medya_layout.addLayout(soru_video_layout)
        
        soru_medya_frame.setLayout(soru_medya_layout)
        right_layout.addWidget(soru_medya_frame)
        
        
        right_layout.addStretch()  # Alt kısımda boşluk bırak
        right_panel.setLayout(right_layout)
        content_splitter.addWidget(right_panel)
        
        # Splitter oranları ayarla (sol %60, sağ %40)
        content_splitter.setStretchFactor(0, 3)
        content_splitter.setStretchFactor(1, 2)
        
        scroll_layout.addWidget(content_splitter)
        scroll_widget.setLayout(scroll_layout)
        scroll.setWidget(scroll_widget)
        scroll.setWidgetResizable(True)
        main_layout.addWidget(scroll)
        
        # Alt buton paneli - Sabit
        buton_frame = QFrame()
        buton_frame.setStyleSheet("""
            QFrame {
                background-color: #f8f9fa;
                border: 2px solid #dee2e6;
                border-radius: 8px;
                padding: 10px;
            }
        """)
        buton_layout = QHBoxLayout()
        buton_layout.setSpacing(15)
        
        # Temizle butonu
        temizle_btn = QPushButton("🧹 Formu Temizle")
        temizle_btn.setObjectName("dangerBtn")
        temizle_btn.clicked.connect(self.formu_temizle)
        buton_layout.addWidget(temizle_btn)
        
        # Önizleme kaldırıldı
        
        buton_layout.addStretch()
        
        # Kaydet butonu - Ana buton
        kaydet_btn = QPushButton("💾 SORU KAYDET")
        kaydet_btn.setStyleSheet("""
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #28a745, stop:1 #20c997);
                font-size: 16px;
                font-weight: bold;
                padding: 15px 25px;
                min-height: 20px;
                border-radius: 10px;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1, 
                    stop:0 #34ce57, stop:1 #2dd4aa);
            }
        """)
        kaydet_btn.clicked.connect(self.soru_kaydet)
        buton_layout.addWidget(kaydet_btn)
        
        buton_frame.setLayout(buton_layout)
        main_layout.addWidget(buton_frame)
        
        self.setLayout(main_layout)
    
    def ana_menuye_don(self):
        self.ana_menu = AnaMenu()
        self.ana_menu.show()
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
            self._load_image_into_label(url, self.cevap_resim_previews[index])

    def _guncelle_soru_resim_onizleme(self, index: int):
        if 0 <= index < len(self.soru_resim_inputs) and 0 <= index < len(self.soru_resim_previews):
            url = self.soru_resim_inputs[index].text().strip()
            self._load_image_into_label(url, self.soru_resim_previews[index])
    def soru_resmi_sec(self, index: int):
        dosya, _ = QFileDialog.getOpenFileName(self, f"Soru için resim {index+1} seç", "", "Görüntüler (*.png *.jpg *.jpeg *.bmp *.gif)")
        if dosya:
            print(f"Seçilen dosya: {dosya}")
            # Firebase Storage'a yükle
            if bucket:
                print("Firebase Storage bucket mevcut, yükleme başlıyor...")
                url = dosya_yukle_firebase_storage(dosya, "soru_resimleri")
                if url:
                    self.soru_resim_inputs[index].setText(url)
                    self._guncelle_soru_resim_onizleme(index)
                    QMessageBox.information(self, "Başarılı", f"Resim {index+1} Firebase Storage'a yüklendi!\nURL: {url[:50]}...")
                else:
                    QMessageBox.warning(self, "Hata", "Resim yüklenemedi! Konsol çıktısını kontrol edin.")
            else:
                print("Firebase Storage bucket bulunamadı, dosya yolu kullanılıyor...")
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
                    QMessageBox.information(self, "Başarılı", f"Cevap {index+1} resmi Firebase Storage'a yüklendi!")
                else:
                    QMessageBox.warning(self, "Hata", "Resim yüklenemedi!")
            else:
                # Firebase Storage yoksa dosya yolunu direkt kullan
                self.cevap_resim_inputs[index].setText(dosya)
                self._guncelle_cevap_resim_onizleme(index)
                QMessageBox.information(self, "Resim eklendi", f"{index+1}. cevap için resim eklendi.")
    
    def kategori_sec(self, index: int):
        """Kategori seçim işlemi"""
        # Önceki seçimi kaldır
        if self.secili_kategori is not None:
            self.kategori_butonlari[self.secili_kategori].setChecked(False)
        
        # Yeni seçimi ayarla
        self.secili_kategori = index
        self.kategori_butonlari[index].setChecked(True)
        
        # Seçilen kategoriyi konsola yazdır (opsiyonel)
        print(f"Seçilen kategori: {self.kategoriler[index]}")
    

    
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
        onizleme_text = f"""


📝 Soru: 
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
                
            # Cevap kontrolü - Esnek yapı (metin veya resim)
            cevaplar_raw = [c.text() for c in self.cevap_inputs]
            cevaplar = [str(c).strip() for c in cevaplar_raw]
            cevap_resimleri_raw = [c.text() for c in self.cevap_resim_inputs]
            cevap_resimleri = [str(c).strip() for c in cevap_resimleri_raw]
            
            # En az bir cevap (metin veya resim) olmalı
            gecerli_cevaplar = 0
            for i in range(4):
                if cevaplar[i] or cevap_resimleri[i]:
                    gecerli_cevaplar += 1
            
            if gecerli_cevaplar == 0:
                QMessageBox.warning(self, "⚠️ Uyarı", "Lütfen en az bir cevap seçeneği doldurun (metin veya resim)!")
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
            
            # Seçilen kategoriyi al
            if self.secili_kategori is not None:
                kategori_str = str(self.kategoriler[self.secili_kategori])
            else:
                kategori_str = "Genel"  # Varsayılan kategori
            
            cevap_index_int = int(self.dogru_combo.currentIndex())
            
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
            
            # Firebase'e kaydet
            doc_ref = db.collection("sorular").add(soru_veri)
            
            # Başarı mesajı - Özelleştirilmiş
            msg = QMessageBox()
            msg.setIcon(QMessageBox.Icon.Information)
            msg.setWindowTitle("✅ Başarılı!")
            msg.setText("🎉 Soru başarıyla kaydedildi!")
            # Medya bilgilerini hazırla
            resim_sayisi = len([url for url in soru_veri['soru_resimleri'] if url])
            video_var = bool(soru_veri['soru_videosu'])
            
            medya_bilgi = []
            if resim_sayisi > 0:
                medya_bilgi.append(f"{resim_sayisi} Resim")
            if video_var:
                medya_bilgi.append("Video")
            if not medya_bilgi:
                medya_bilgi.append("Yok")
            
            msg.setInformativeText(f"""
📊 Soru Detayları:
• ID: {doc_ref[1].id[:12]}...
• Kategori: {soru_veri['kategori']}
• Cevap Sayısı: {len(cevaplar)}
• Medya: {' / '.join(medya_bilgi)}
            """)
            msg.setStandardButtons(QMessageBox.StandardButton.Ok)
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
        self.dogru_combo.setCurrentIndex(0)
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
        reply = QMessageBox.question(self, "🧹 Formu Temizle", 
                                   "Tüm alanlar temizlenecek. Emin misiniz?",
                                   QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
                                   QMessageBox.StandardButton.No)
        
        if reply == QMessageBox.StandardButton.Yes:
            # Tarih alanları hariç temizle
            self.soru_input.clear()
            for cevap_input in self.cevap_inputs:
                cevap_input.clear()
            self.dogru_combo.setCurrentIndex(0)
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
            
            QMessageBox.information(self, "🧹 Temizlendi", "Form başarıyla temizlendi!")

class SoruDuzenlemePaneli(SoruEklemePaneli):
    def __init__(self, doc_id: str):
        self.doc_id = doc_id
        super().__init__()
        self.setWindowTitle("Soru Düzenleme Paneli")
        self.yukle_ve_doldur()

    def yukle_ve_doldur(self):
        try:
            ref = db.collection("sorular").document(self.doc_id)
            snap = ref.get()
            if not snap.exists:
                QMessageBox.critical(self, "Hata", "Belge bulunamadı")
                return
            d = snap.to_dict() or {}
            # Soru
            self.soru_input.setPlainText(str(d.get("soru", "")))
            # Cevaplar
            cevaplar = d.get("cevaplar", [])
            for i in range(min(4, len(self.cevap_inputs))):
                metin = ""
                if isinstance(cevaplar, list) and len(cevaplar) > i:
                    c = cevaplar[i]
                    if isinstance(c, dict):
                        metin = c.get("metin", "")
                self.cevap_inputs[i].setText(str(metin))
            # Cevap resimleri
            for i in range(min(4, len(self.cevap_resim_inputs))):
                url = ""
                if isinstance(cevaplar, list) and len(cevaplar) > i:
                    c = cevaplar[i]
                    if isinstance(c, dict):
                        url = c.get("resim_url", "")
                self.cevap_resim_inputs[i].setText(str(url))
            # Doğru cevap
            self.dogru_combo.setCurrentIndex(int(d.get("cevap", 0)))
            # Tarihler
            try:
                gun_val = int(d.get("gün", 1))
            except Exception:
                gun_val = 1
            self.gun_combo.setCurrentText(str(gun_val))
            self.ay_combo.setCurrentText(str(d.get("ay", "Ocak")))
            self.yil_combo.setCurrentText(str(d.get("yıl", "2024")))
            # Kategori - Seçilen kategoriyi butonlarda işaretle
            kategori_text = str(d.get("kategori", "Genel"))
            self.secili_kategori = None
            for i, kategori in enumerate(self.kategoriler):
                if kategori == kategori_text:
                    self.kategori_butonlari[i].setChecked(True)
                    self.secili_kategori = i
                    break
            # Soru resimleri
            soru_resimleri = d.get("soru_resimleri", [])
            if isinstance(soru_resimleri, list):
                for i in range(min(4, len(self.soru_resim_inputs))):
                    self.soru_resim_inputs[i].setText(str(soru_resimleri[i] if i < len(soru_resimleri) else ""))
            # Video
            self.video_input.setText(str(d.get("soru_videosu", "")))
        except Exception as e:
            QMessageBox.critical(self, "Hata", f"Belge yüklenemedi: {e}")

    def soru_kaydet(self):
        if not db:
            QMessageBox.critical(self, "Hata", "Firebase bağlantısı yok!")
            return
        try:
            # Orijinal kaydet mantığından veri derle
            cevaplar_raw = [c.text() for c in self.cevap_inputs]
            cevaplar = [str(c).strip() for c in cevaplar_raw]
            cevap_resimleri_raw = [c.text() for c in self.cevap_resim_inputs]
            cevap_resimleri = [str(c).strip() for c in cevap_resimleri_raw]
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
            
            # Seçilen kategoriyi al
            if self.secili_kategori is not None:
                kategori_str = str(self.kategoriler[self.secili_kategori])
            else:
                kategori_str = "Genel"  # Varsayılan kategori
            
            cevap_index_int = int(self.dogru_combo.currentIndex())

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
            # Güncelle
            db.collection("sorular").document(self.doc_id).set(soru_veri, merge=False)
            QMessageBox.information(self, "Başarılı", "Soru güncellendi.")
            # Düzenleme sonrası listeye dön
            self.ana_menuye_don()
        except Exception as e:
            import traceback
            error_msg = f"Soru güncellenirken hata oluştu:\n{str(e)}\n\nDetay: {traceback.format_exc()}"
            QMessageBox.critical(self, "❌ Hata", error_msg)

class DuzenlemePaneli(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Düzenleme - Sorular")
        self.setGeometry(150, 80, 1200, 700)
        self.init_ui()
        
    def init_ui(self):
        layout = QVBoxLayout()

        baslik = QLabel("📋 Mevcut Soruları Düzenleyin ve Silin")
        baslik.setAlignment(Qt.AlignmentFlag.AlignCenter)
        baslik.setStyleSheet("font-size: 22px; font-weight: bold; color:#ffffff; background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #dc3545, stop:1 #c82333); padding: 10px; border: 2px solid #bd2130; border-radius: 8px;")
        layout.addWidget(baslik)

        # GÜNLER LİSTESİ BÖLÜMÜ
        gunler_section = QFrame()
        gunler_section.setStyleSheet("""
            QFrame {
                background-color: #f8f9fa;
                border: 2px solid #dee2e6;
                border-radius: 8px;
                padding: 15px;
                margin: 10px;
            }
        """)
        gunler_layout = QVBoxLayout()
        
        # Tarih butonları için scroll area (tam ekranı kapsayacak şekilde)
        self.tarih_scroll = QScrollArea()
        self.tarih_scroll.setWidgetResizable(True)
        try:
            # İçeriği sol-üstte hizala
            self.tarih_scroll.setAlignment(Qt.AlignmentFlag.AlignTop | Qt.AlignmentFlag.AlignLeft)
        except Exception:
            pass
        self.tarih_scroll.setStyleSheet("""
            QScrollArea {
                border: 1px solid #dee2e6;
                border-radius: 6px;
                background-color: white;
            }
        """)
        
        # Tarih butonları container
        self.tarih_widget = QWidget()
        from PyQt6.QtWidgets import QGridLayout as _QGridLayout
        self.tarih_buttons_layout = _QGridLayout()
        self.tarih_buttons_layout.setSpacing(1)
        try:
            # Layout'un içerik kenar boşluklarını kaldır
            self.tarih_buttons_layout.setContentsMargins(0, 0, 0, 0)
        except Exception:
            pass
        self.tarih_widget.setLayout(self.tarih_buttons_layout)
        self.tarih_scroll.setWidget(self.tarih_widget)
        
        gunler_layout.addWidget(self.tarih_scroll)
        gunler_section.setLayout(gunler_layout)
        layout.addWidget(gunler_section)
        
        # Üst kontrol çubuğu
        top_bar = QHBoxLayout()
        
        # Ana menüye dön butonu
        anasayfa_btn = QPushButton("🏠 Ana Menüye Dön")
        anasayfa_btn.setStyleSheet("QPushButton{background:#6c757d; color:white; font-weight:bold; padding:8px 14px; border:1px solid #495057; border-radius:6px;} QPushButton:hover{background:#5a6268}")
        anasayfa_btn.clicked.connect(self._go_home)
        top_bar.addWidget(anasayfa_btn)
        
        top_bar.addStretch()

        layout.addLayout(top_bar)

        # Durum etiketi
        self.status_label = QLabel("")
        self.status_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.status_label.setStyleSheet("color:#2d5a27; font-size:12px; padding:6px;")
        layout.addWidget(self.status_label)


        # Tablo
        from PyQt6.QtWidgets import QTableWidget, QTableWidgetItem, QHeaderView
        self.table = QTableWidget()
        # Sade görünüm: Seç, Düzenle, Soru, Gün, Ay, Yıl (ID görünmeyecek)
        self.table.setColumnCount(5)
        self.table.setHorizontalHeaderLabels(["Düzenle", "Soru", "Gün", "Ay", "Yıl"])
        self.table.setStyleSheet(
            "QTableWidget { font-size: 13px; background:white; gridline-color:#cfe3cf; }"
            "QHeaderView::section { background:#4a934a; color:white; padding:6px; border:0px; }"
            "QTableWidget::item { padding:6px; }"
            "QTableWidget::item:selected { background:#d4edda; color:#2d5a27; }"
        )
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
            m.show()
            self.close()
        except Exception:
            pass
    
    def load_tarihler(self):
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
            
            # Yeni tarih butonları oluştur (3 sütunlu grid)
            col_count = 3
            for idx, (tarih_str, yil, ay, gun) in enumerate(tarih_listesi):
                tarih_btn = QPushButton(tarih_str)
                tarih_btn.setFixedWidth(140)
                tarih_btn.setStyleSheet("""
                    QPushButton {
                        background-color: #f8f9fa;
                        color: #2d5a27;
                        border: 2px solid #28a745;
                        border-radius: 8px;
                        padding: 4px 8px;
                        font-size: 11px;
                        font-weight: bold;
                        text-align: center;
                        margin: 0px;
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
                r = idx // col_count
                c = idx % col_count
                self.tarih_buttons_layout.addWidget(tarih_btn, r, c)
                    
        except Exception as e:
            print(f"Tarihler yüklenirken hata: {e}")
    
    def tarih_sec(self, tarih_str):
        """Seçilen tarihi ayır ve soruları yükle"""
        # Tarih string'ini parçala
        parts = tarih_str.split()
        if len(parts) >= 3:
            gun = parts[0]
            ay = parts[1]
            yil = parts[2]
            
            # Bu tarihteki soruları yeni pencerede aç
            try:
                pencere = SoruListePenceresi(gun, ay, yil)
                pencere.showFullScreen()
                self.close()
            except Exception:
                # Hata halinde eski davranışa düş
                self.load_rows_by_date(gun, ay, yil)
    
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
            print(f"Günler yüklenirken hata: {e}")
    
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
            print(f"Tarih seçenekleri yüklenirken hata: {e}")
    
    def tarih_sec(self, tarih_str):
        """Seçilen tarihi ayır ve soruları yükle"""
        # Tarih string'ini parçala
        parts = tarih_str.split()
        if len(parts) >= 3:
            gun = parts[0]
            ay = parts[1]
            yil = parts[2]
            
            # Bu tarihteki soruları yükle
            self.load_rows_by_date(gun, ay, yil)
    
    def load_rows_by_date(self, gun, ay, yil):
        """Belirli bir tarihteki soruları yükler"""
        from PyQt6.QtWidgets import QPushButton
        from functools import partial
        if not db:
            QMessageBox.warning(self, "Hata", "Veritabanı bağlantısı yok!")
            return
        
        try:
            # Eski satırları temizle
            self.table.setRowCount(0)
            # Satır -> belge ID eşlemesi
            self.row_ids: list[str] = []
            
            # Tüm belgeleri çek
            try:
                q = db.collection("sorular")
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
                    "QPushButton{background:#0d6efd; color:#ffffff; font-weight:bold; padding:4px 12px 10px 12px; border:1px solid #0b5ed7; border-radius:0px;}"
                    " QPushButton:hover{background:#3b82f6; color:#ffffff;}"
                    " QPushButton:pressed{background:#0b5ed7; color:#ffffff;}"
                )
                edit_btn.setAutoDefault(False)
                edit_btn.setDefault(False)
                edit_btn.setMinimumHeight(30)
                from PyQt6.QtWidgets import QSizePolicy as _QSizePolicy
                edit_btn.setSizePolicy(_QSizePolicy.Policy.Expanding, _QSizePolicy.Policy.Expanding)
                def _make_edit(doc_id: str):
                    return lambda: self.open_edit_panel(doc_id)
                edit_btn.clicked.connect(_make_edit(item["id"]))
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
    def __init__(self, gun: str, ay: str, yil: str):
        super().__init__()
        self.setWindowTitle(f"{gun} {ay} {yil} - Sorular")
        self.setGeometry(120, 80, 1200, 700)
        self.gun = gun
        self.ay = ay
        self.yil = yil
        self.init_ui()

    def init_ui(self):
        from PyQt6.QtWidgets import QTableWidget, QTableWidgetItem, QHeaderView
        layout = QVBoxLayout()

        # Üst bar
        top_bar = QHBoxLayout()
        geri_btn = QPushButton("⬅️ Geri")
        geri_btn.setStyleSheet("QPushButton{background:#6c757d; color:white; font-weight:bold; padding:8px 14px; border:1px solid #495057; border-radius:6px;} QPushButton:hover{background:#5a6268}")
        geri_btn.clicked.connect(self.geri)
        top_bar.addWidget(geri_btn)
        top_bar.addStretch()
        baslik = QLabel(f"📅 {self.gun} {self.ay} {self.yil} - Kayıtlar")
        baslik.setAlignment(Qt.AlignmentFlag.AlignCenter)
        baslik.setStyleSheet("font-size: 18px; font-weight: bold; color:#2d5a27; padding: 8px;")
        top_bar.addStretch()
        layout.addLayout(top_bar)
        layout.addWidget(baslik)

        # Tablo
        self.table = QTableWidget()
        self.table.setColumnCount(5)
        self.table.setHorizontalHeaderLabels(["Düzenle", "Soru", "Gün", "Ay", "Yıl"])
        self.table.setStyleSheet(
            "QTableWidget { font-size: 13px; background:white; gridline-color:#cfe3cf; }"
            "QHeaderView::section { background:#4a934a; color:white; padding:6px; border:0px; }"
            "QTableWidget::item { padding:6px; }"
            "QTableWidget::item:selected { background:#d4edda; color:#2d5a27; }"
        )
        self.table.verticalHeader().setVisible(False)
        self.table.horizontalHeader().setStretchLastSection(False)
        self.table.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeMode.Fixed)
        self.table.horizontalHeader().setSectionResizeMode(1, QHeaderView.ResizeMode.Stretch)
        self.table.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeMode.Fixed)
        self.table.horizontalHeader().setSectionResizeMode(3, QHeaderView.ResizeMode.Fixed)
        self.table.horizontalHeader().setSectionResizeMode(4, QHeaderView.ResizeMode.Fixed)
        self.table.setColumnWidth(0, 120)
        self.table.setColumnWidth(2, 70)
        self.table.setColumnWidth(3, 90)
        self.table.setColumnWidth(4, 70)
        layout.addWidget(self.table)

        # Alt bar
        bottom = QHBoxLayout()
        ana_menu_btn = QPushButton("🏠 Ana Menü")
        ana_menu_btn.setStyleSheet("QPushButton{background:#6c757d; color:white; font-weight:bold; padding:8px 14px; border:1px solid #495057; border-radius:6px;} QPushButton:hover{background:#5a6268}")
        ana_menu_btn.clicked.connect(self.ana_menu)
        bottom.addWidget(ana_menu_btn)
        bottom.addStretch()
        layout.addLayout(bottom)

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

            def parse_int(val: object) -> int:
                if isinstance(val, int):
                    return val
                if isinstance(val, str) and val.isdigit():
                    return int(val)
                return 0

            q = db.collection("sorular")
            sorular = q.stream()
            rows = []
            for s in sorular:
                d = s.to_dict() or {}
                yil_val = parse_int(d.get("yıl"))
                ay_name = d.get("ay")
                gun_val = parse_int(d.get("gün"))
                if (str(gun_val) == self.gun and ay_name == self.ay and str(yil_val) == self.yil):
                    rows.append({
                        "id": s.id,
                        "soru": d.get("soru", ""),
                        "gun": gun_val,
                        "ay": ay_name,
                        "yil": yil_val,
                    })

            from PyQt6.QtWidgets import QTableWidgetItem
            self.table.setRowCount(len(rows))
            for r, item in enumerate(rows):
                self.row_ids.append(item["id"]) 
                edit_btn = QPushButton("DÜZENLE")
                edit_btn.setStyleSheet(
                    "QPushButton{background:#0d6efd; color:#ffffff; font-weight:bold; padding:4px 12px 10px 12px; border:1px solid #0b5ed7; border-radius:0px;}"
                    " QPushButton:hover{background:#3b82f6; color:#ffffff;}"
                    " QPushButton:pressed{background:#0b5ed7; color:#ffffff;}"
                )
                def _make_edit(doc_id: str):
                    return lambda: self.open_edit_panel(doc_id)
                edit_btn.clicked.connect(_make_edit(item["id"]))
                from PyQt6.QtWidgets import QWidget as _QW, QHBoxLayout as _QHBox
                w = _QW()
                h = _QHBox()
                h.setContentsMargins(0,0,0,0)
                h.addWidget(edit_btn)
                w.setLayout(h)
                self.table.setCellWidget(r, 0, w)

                self.table.setItem(r, 1, QTableWidgetItem(item["soru"]))
                self.table.setItem(r, 2, QTableWidgetItem(str(item["gun"])))
                self.table.setItem(r, 3, QTableWidgetItem(item["ay"]))
                self.table.setItem(r, 4, QTableWidgetItem(str(item["yil"])))
            self.table.resizeRowsToContents()
        except Exception as e:
            import traceback
            error_msg = f"Sorular yüklenemedi: {e}\n\nDetay: {traceback.format_exc()}"
            QMessageBox.critical(self, "Hata", error_msg)

    def open_edit_panel(self, doc_id: str):
        try:
            panel = SoruDuzenlemePaneli(doc_id)
            panel.showFullScreen()
            self.close()
        except Exception as e:
            QMessageBox.critical(self, "Hata", f"Düzenleme ekranı açılamadı: {e}")

    def geri(self):
        try:
            p = DuzenlemePaneli()
            p.showFullScreen()
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
    
    def load_rows(self):
        from PyQt6.QtWidgets import QPushButton
        from functools import partial
        if not db:
            QMessageBox.warning(self, "Hata", "Veritabanı bağlantısı yok!")
            return
        try:
            # Eski satırları temizle
            self.table.setRowCount(0)
            # Satır -> belge ID eşlemesi
            self.row_ids: list[str] = []
            # Tüm belgeleri çek
            try:
                q = db.collection("sorular")
                sorular = q.stream()
            except Exception as e:
                QMessageBox.critical(self, "Hata", f"Firebase bağlantı hatası: {e}")
                return

            def month_to_name(val: object) -> str:
                months = ["", "Ocak","Şubat","Mart","Nisan","Mayıs","Haziran","Temmuz","Ağustos","Eylül","Ekim","Kasım","Aralık"]
                if isinstance(val, int):
                    if 1 <= val <= 12:
                        return months[val]
                    return ""
                if isinstance(val, str):
                    return val
                return ""

            def parse_int(val: object) -> int:
                if isinstance(val, int):
                    return val
                if isinstance(val, str) and val.isdigit():
                    return int(val)
                return 0

            # Önce tüm kayıtları yükle
            all_rows = []
            for s in sorular:
                d = s.to_dict() or {}
                yil_val = parse_int(d.get("yıl"))
                ay_name = month_to_name(d.get("ay"))
                gun_val = parse_int(d.get("gün"))
                kategori = d.get("kategori", "Genel")

                all_rows.append({
                    "id": s.id,
                    "kategori": kategori,
                    "soru": d.get("soru", ""),
                    "cevaplar": d.get("cevaplar", []),
                    "dogru": (parse_int(d.get("cevap")) + 1),
                    "gun": gun_val,
                    "ay": ay_name,
                    "yil": yil_val,
                    "resim_url": d.get("resim_url", "") or d.get("resim", "") or "",
                    "video_url": d.get("video_url", "") or d.get("video", "") or ""
                })

            # Tüm soruları göster (filtreleme yok)
            rows = all_rows
            total_docs = len(all_rows)

            self.table.setRowCount(len(rows))
            from PyQt6.QtWidgets import QTableWidgetItem, QCheckBox, QWidget, QPushButton
            from PyQt6.QtWidgets import QHBoxLayout as _QHBox
            for r, item in enumerate(rows):
                # Eşlemeyi sakla (ID görünmeyecek)
                self.row_ids.append(item["id"]) 

                # Düzenle butonu
                edit_btn = QPushButton("DÜZENLE")
                edit_btn.setStyleSheet(
                    "QPushButton{background:#0d6efd; color:#ffffff; font-weight:bold; padding:4px 12px 10px 12px; border:1px solid #0b5ed7; border-radius:0px;}"
                    " QPushButton:hover{background:#3b82f6; color:#ffffff;}"
                    " QPushButton:pressed{background:#0b5ed7; color:#ffffff;}"
                )
                edit_btn.setAutoDefault(False)
                edit_btn.setDefault(False)
                edit_btn.setMinimumHeight(30)
                from PyQt6.QtWidgets import QSizePolicy as _QSizePolicy
                edit_btn.setSizePolicy(_QSizePolicy.Policy.Expanding, _QSizePolicy.Policy.Expanding)
                def _make_edit(doc_id: str):
                    return lambda: self.open_edit_panel(doc_id)
                edit_btn.clicked.connect(_make_edit(item["id"]))
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
                self.status_label.setText("Seçilen filtrelerle eşleşen kayıt bulunamadı")
            else:
                self.status_label.setText(f"Gösterilen: {len(rows)} / Toplam: {total_docs} kayıt")
        except Exception as e:
            import traceback
            error_msg = f"Sorular yüklenemedi: {e}\n\nDetay: {traceback.format_exc()}"
            QMessageBox.critical(self, "Hata", error_msg)

    def delete_selected(self):
        try:
            from PyQt6.QtWidgets import QCheckBox
            rows_to_delete = []
            for r in range(self.table.rowCount()):
                cell = self.table.cellWidget(r, 0)
                if not cell:
                    continue
                cb = cell.findChild(QCheckBox)
                if cb and cb.isChecked():
                    rows_to_delete.append(r)
            if not rows_to_delete:
                QMessageBox.information(self, "Bilgi", "Silmek için en soldan seçim yapın.")
                return
            reply = QMessageBox.question(self, "Sil", f"{len(rows_to_delete)} kayıt silinsin mi?", QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No, QMessageBox.StandardButton.No)
            if reply != QMessageBox.StandardButton.Yes:
                return
            # Büyükten küçüğe sil ki sıra bozulmasın
            for r in sorted(rows_to_delete, reverse=True):
                if r < len(self.row_ids):
                    db.collection("sorular").document(self.row_ids[r]).delete()
                    self.table.removeRow(r)
                    del self.row_ids[r]
            QMessageBox.information(self, "Silindi", "Seçili kayıtlar silindi.")
        except Exception as e:
            QMessageBox.critical(self, "Hata", f"Silinemedi: {e}")

    def open_add_panel(self):
        try:
            panel = SoruEklemePaneli()
            panel.showFullScreen()
            self.close()
        except Exception:
            pass
    
    def open_edit_panel(self, doc_id: str):
        try:
            panel = SoruDuzenlemePaneli(doc_id)
            panel.showFullScreen()
            self.close()
        except Exception as e:
            QMessageBox.critical(self, "Hata", f"Düzenleme ekranı açılamadı: {e}")
    
    def anasayfaya_don(self):
        """Ana menüye dön"""
        try:
            from PyQt6.QtWidgets import QApplication
            # Ana menüyü yeniden oluştur ve göster
            self.ana_menu = AnaMenu()
            self.ana_menu.show()
            self.close()
        except Exception as e:
            QMessageBox.critical(self, "Hata", f"Anasayfaya dönülemedi: {e}")
    

if __name__ == "__main__":
    app = QApplication(sys.argv)
    
    # Uygulama ayarları
    app.setApplicationName("Trafik Koçu Soru Yönetim Sistemi")
    app.setApplicationVersion("2.0")
    
    # Ana menüyü başlat
    window = AnaMenu()
    window.show()
    # Show image on top-right of the main window after it exists
    try:
        label = QLabel(window)
        pixmap = QPixmap("resim.png")
        if not pixmap.isNull():
            label.setPixmap(pixmap)
            label.setGeometry(window.width() - pixmap.width() - 10, 10, pixmap.width(), pixmap.height())
            label.raise_()
            label.show()
    except Exception:
        pass
    
    sys.exit(app.exec())