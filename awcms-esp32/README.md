# AWCMS ESP32 IoT Firmware

ESP32-based IoT firmware with **gas sensor** and **camera** support.

## Features

- 💨 **Gas Sensor** - MQ-2/MQ-135 support with PPM calculation
- 📷 **Camera** - ESP32-CAM OV2640 streaming
- 🌐 **Web Dashboard** - Responsive dark-mode UI
- 📡 **WebSocket** - Real-time data updates
- ☁️ **Supabase Sync** - Cloud data storage

## Hardware

| Component | Model | Connection |
| :-------- | :---- | :--------- |
| Gas Sensor | MQ-2/MQ-135 | GPIO 34 (via voltage divider) |
| Camera | ESP32-CAM OV2640 | Built-in |

> ⚠️ **Important:** MQ sensors output 5V, use voltage divider to step down to 3.3V!

## Requirements

- ESP32 Dev Board (or ESP32-CAM for camera)
- PlatformIO IDE (VSCode extension)
- WiFi network
- 5V 2A power supply (for camera)

## Quick Start

1. **Install PlatformIO** in VSCode

2. **Configure credentials** in `include/config.h`:

   ```cpp
   #define WIFI_SSID "your_wifi"
   #define WIFI_PASSWORD "your_password"
   #define TENANT_ID "your_tenant_uuid"
   
   // For ESP32-CAM, uncomment:
   // #define ENABLE_CAMERA
   ```

3. **Upload filesystem:**

   ```bash
   pio run -t uploadfs
   ```

4. **Upload firmware:**

   ```bash
   pio run -t upload
   ```

5. **Access dashboard** at `http://<device-ip>/`

## Project Structure

```text
awcms-esp32/
├── platformio.ini
├── src/main.cpp
├── include/
│   ├── config.h           # Credentials
│   ├── gas_sensor.h       # MQ sensor
│   ├── camera.h           # ESP32-CAM
│   ├── webserver.h        # Web server
│   └── supabase_client.h  # Cloud sync
└── data/                  # Web UI
    ├── index.html
    ├── style.css
    └── app.js
```

## API Endpoints

| Endpoint | Method | Description |
| :------- | :----- | :---------- |
| `/api/status` | GET | Device status |
| `/api/gas` | GET | Gas sensor data |
| `/api/gas/calibrate` | POST | Calibrate sensor |
| `/api/camera` | GET | Camera status |
| `/capture` | GET | Take photo |
| `/api/restart` | POST | Restart device |

## Gas Sensor Levels

| Level | PPM | Action |
| :---- | :-- | :----- |
| Normal | <200 | Safe |
| Elevated | 200-500 | Monitor |
| Warning | 500-1000 | Ventilate |
| Danger | >1000 | Evacuate! |

## License

MIT
