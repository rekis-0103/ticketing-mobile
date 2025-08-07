import xml.etree.ElementTree as ET
import json

# Contoh isi file FlutterSharedPreferences.xml
xml_data = ''''''

# Parsing XML
root = ET.fromstring(xml_data)
result = {}

# Ekstrak key dan value dari setiap string
for item in root.findall('string'):
    key = item.get('name').replace('flutter.', '')
    try:
        value = json.loads(item.text)
    except json.JSONDecodeError:
        value = item.text  # fallback kalau bukan JSON
    result[key] = value

# Tampilkan hasil JSON di terminal
print(json.dumps(result, indent=4))
