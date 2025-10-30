# backend.py
import os, sys, json, time, threading
from typing import Optional
import serial
from serial.tools import list_ports
from PySide6.QtCore import QObject, Slot, Signal

DEFAULT_PORT = "COM4" if sys.platform.startswith("win") else "/dev/ttyACM0"
SERIAL_PORT = os.environ.get("PUMP_SERIAL_PORT", DEFAULT_PORT)
BAUD = 115200
OPEN_RETRY_SEC = 2.0


class PumpLink:
    """Pure-Python serial link (no QObject)"""
    def __init__(self, port: str = SERIAL_PORT, baud: int = BAUD):
        self.port = port
        self.baud = baud
        self.ser: Optional[serial.Serial] = None
        self._stop = False
        self._rx_thread: Optional[threading.Thread] = None
        self._tx_lock = threading.Lock()

    def open(self) -> bool:
        if self.ser and self.ser.is_open:
            return True
        while not self._stop:
            try:
                print(f"[PumpLink] Opening {self.port} @ {self.baud}…")
                self.ser = serial.Serial(self.port, self.baud, timeout=0.1)
                if not self._rx_thread or not self._rx_thread.is_alive():
                    self._rx_thread = threading.Thread(target=self._rx_loop, daemon=True)
                    self._rx_thread.start()
                print("[PumpLink] Port open ✓")
                return True
            except Exception as e:
                print(f"[PumpLink] open failed: {e}; retrying in {OPEN_RETRY_SEC}s")
                time.sleep(OPEN_RETRY_SEC)
        return False

    def close(self):
        self._stop = True
        try:
            if self.ser and self.ser.is_open:
                self.ser.close()
                print("[PumpLink] Port closed")
        except Exception as e:
            print(f"[PumpLink] close error: {e}")

    def _send(self, obj: dict):
        data = (json.dumps(obj) + "\n").encode("utf-8")
        with self._tx_lock:
            try:
                if not self.ser or not self.ser.is_open:
                    if not self.open():
                        print("[PumpLink] write skipped (port not open)")
                        return
                print(f"[PumpLink] TX: {data!r}")
                self.ser.write(data); self.ser.flush()
            except Exception as e:
                print(f"[PumpLink] write error: {e}")

    # API the wrapper will call:
    def set_flow(self, pump: int, ul_per_min: float): self._send({"pump": int(pump), "flow": float(ul_per_min)})
    def prime(self, pump: int):                       self._send({"prime": int(pump)})
    def stop(self, pump: int):                        self._send({"stop": int(pump)})
    def stop_all(self):                               self._send({"stop_all": True})
    def set_calibration(self, pump: int, ul_per_rev: float):
        self._send({"cal": {"pump": int(pump), "ul_per_rev": float(ul_per_rev)}})

    def _rx_loop(self):
        buf = b""
        while not self._stop:
            try:
                chunk = self.ser.read(256) if self.ser else b""
                if not chunk:
                    time.sleep(0.01); continue
                buf += chunk
                while b"\n" in buf:
                    line, buf = buf.split(b"\n", 1)
                    if line.strip():
                        try:
                            txt = line.decode("utf-8", "ignore")
                            print(f"[PumpLink] RX(raw): {txt}")
                        except Exception:
                            print(f"[PumpLink] RX(bytes): {line!r}")
            except Exception as e:
                print(f"[PumpLink] rx error: {e}")
                time.sleep(0.25)

# --- add below your PumpLink class in backend.py ---
from PySide6.QtCore import QObject, Slot, Signal

class QBackend(QObject):
    """Thin QObject wrapper that forwards QML calls to PumpLink."""
    connectionChanged = Signal(bool)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.link = PumpLink()  # uses your existing class

    # lifecycle
    @Slot(result=bool)
    def open(self) -> bool:
        ok = self.link.open()
        self.connectionChanged.emit(ok)
        return ok

    @Slot()
    def close(self):
        self.link.close()
        self.connectionChanged.emit(False)

    # pump controls (accept ints/doubles/variants from QML)
    @Slot('QVariant')
    @Slot(int)
    @Slot(float)
    def prime(self, pump):
        self.link.prime(int(pump))

    @Slot('QVariant', 'QVariant')
    @Slot(int, float)
    @Slot(int, int)
    def set_flow(self, pump, ul_per_min):
        self.link.set_flow(int(pump), float(ul_per_min))

    @Slot('QVariant')
    @Slot(int)
    @Slot(float)
    def stop(self, pump):
        self.link.stop(int(pump))

    @Slot()
    def stop_all(self):
        self.link.stop_all()

    @Slot('QVariant', 'QVariant')
    @Slot(int, float)
    @Slot(int, int)
    def set_calibration(self, pump, ul_per_rev):
        self.link.set_calibration(int(pump), float(ul_per_rev))

