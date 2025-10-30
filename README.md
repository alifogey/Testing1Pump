# Testing1Pump
Folder with UI, Arduino, and python code to successfully control 1 pump using the UI

## To view UI
Open the UI (Try5 project) **or** run the Python app to look at the user interface

## Layout

UNO_loopback_test/
 ├─ UNO_loopback_test.ino              # arduino code
src/
 ├─ main.py              # Python app launcher
 ├─ backend.py           # Serial communication
 └─ qml/                 # User Interface .qml files
         Main.qml
         PumpCardForm.ui.qml
         SetupPageForm.ui.qml
         RunPageForm.ui.qml
         Try5.qmlproject  #to view just the UI
## Run
Arduino
1. Plug in arduino, make sure motor drivers and pumps are connect
2. Open Arduino IDE and select the correct board (Arduino Mega 2560) and port
3. Click File Open and find UNO_loopback_test.ino in UNO_loopback_test folder. 
4. Click upload (light on arduino should flash)
5. Plug in external power source
6. To confirm that everythings working, open the Serial Monitor in arduino and test this command, -- If pump is wired correctly, it should move briefly 
```
{"prime": 1}
```
7. Close Serial Monitor (if not closed, won't run)
8. Then open powershell
9. Copy this whole block of code
```
cd "C:Users\...." ** change with your folder path
pip install PySide6 pyserial
$env:PUMP_SERIAL_PORT="COM4"   # use your real COM port
python main.py
```
10.  In UI: set Pump 1 flow, **Prime**, **Ready to Run → Start**.

## Firmware
- Board: **Mega 2560**
- Upload `arduino/RAMPS_PumpControl.ino`
- Default mapping: **UI Pump 1 → E1 driver**. Change `PUMP_MAP[]` if needed.
