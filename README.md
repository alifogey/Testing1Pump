# Test_1_Pump — QML UI + Python backend + RAMPS firmware (1‑pump demo)

Open the UI (Try5 project) **or** run the Python app to control one pump.

## Layout
- `src/` — Python app (`main.py`, `backend.py`, and QML in `src/qml/`)
- `Try5/Try5Content/` — the same QML files for Qt Design Studio
- `arduino/` — firmware `RAMPS_PumpControl.ino`

## Run
```powershell
cd src
pip install PySide6 pyserial
$env:PUMP_SERIAL_PORT="COM4"   # use your real COM port
python main.py
```
- In UI: set Pump 1 flow, **Prime**, **Ready to Run → Start**.

## Firmware
- Board: **Mega 2560**
- Upload `arduino/RAMPS_PumpControl.ino`
- Default mapping: **UI Pump 1 → E1 driver**. Change `PUMP_MAP[]` if needed.
