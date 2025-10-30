# main.py
import sys
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from backend import QBackend

QML_FILE = "qml/Main.qml"

if __name__ == "__main__":
    app = QApplication(sys.argv)

    backend = QBackend()
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("backend", backend)
    backend.open()

    engine.load(QML_FILE)
    if not engine.rootObjects():
        print("❌ Failed to load QML!")
        sys.exit(-1)
    sys.exit(app.exec())
