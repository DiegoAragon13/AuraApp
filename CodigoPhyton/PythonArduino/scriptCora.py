import serial
import firebase_admin
from firebase_admin import credentials, firestore
import time
import re

# CONFIGURACIÓN
SERIAL_PORT = 'COM3'  
BAUD_RATE = 9600
CRED_JSON = 'auraapp-3e734-firebase-adminsdk-fbsvc-4bff67257c.json'

# Inicializa Firebase
try:
    cred = credentials.Certificate(CRED_JSON)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("Conectado a Firebase Firestore")
except Exception as e:
    print("Error al conectar con Firebase:", e)
    exit()

# Inicializa Serial
try:
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE)
    print(f"Puerto serial abierto: {SERIAL_PORT}")
    time.sleep(2)
except Exception as e:
    print("Error al abrir el puerto serial:", e)
    exit()

# Expresiones regulares más tolerantes (aceptan letras con errores o acentos)
hr_pattern = re.compile(r'Ritmo.*?:\s*([\d.]+)')
spo2_pattern = re.compile(r'Satur.*?:\s*([\d.]+)')

# Búfer para almacenar temporalmente valores
current_hr = None
current_spo2 = None

while True:
    try:
        line = ser.readline().decode(errors='replace').strip()
        print("Guardado:", line)

        hr_match = hr_pattern.search(line)
        spo2_match = spo2_pattern.search(line)

        if hr_match:
            current_hr = float(hr_match.group(1))
        if spo2_match:
            current_spo2 = float(spo2_match.group(1))

        # Cuando ambos valores han sido leídos, se suben
        if current_hr is not None and current_spo2 is not None:
            print(f"Detectado HR: {current_hr}, SpO2: {current_spo2}")

            if 30 < current_hr < 200 and 60 < current_spo2 <= 100:
                data = {
                    'timestamp': firestore.SERVER_TIMESTAMP,
                    'heart_rate_avg': current_hr,
                    'spo2_avg': current_spo2
                }
                try:
                    db.collection('mediciones').add(data)
                    print("Datos guardados en Firestore:", data)
                except Exception as e:
                    print("Error al guardar en Firestore:", e)
            else:
                print("Valores fuera de rango, no se guardaron.")

            current_hr = None
            current_spo2 = None

    except KeyboardInterrupt:
        print("\nFinalizado por el usuario.")
        break
    except Exception as e:
        print("Error:", e)
