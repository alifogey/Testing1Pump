import sys
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from backend import QBackend

QML_FILE = "../src/qml/Main.qml"

app = QApplication(sys.argv)
backend = QBackend()                                # QObject
engine = QQmlApplicationEngine()
engine.rootContext().setContextProperty("backend", backend)  # lowercase name used in QML
backend.open()
engine.load(QML_FILE)
if not engine.rootObjects():
    sys.exit(-1)
sys.exit(app.exec())


