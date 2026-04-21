"""
Baixa a bandeira da Tunísia que estava faltando em assets/flags/
Execute na raiz do projeto Flutter: python baixar_tun.py
"""

import urllib.request
import os

OUTPUT_DIR = os.path.join("assets", "flags")
os.makedirs(OUTPUT_DIR, exist_ok=True)

destino = os.path.join(OUTPUT_DIR, "tun.png")
url = "https://flagcdn.com/w80/tn.png"

try:
    urllib.request.urlretrieve(url, destino)
    tamanho = os.path.getsize(destino)
    if tamanho < 100:
        os.remove(destino)
        print("✗ tun.png — arquivo inválido (muito pequeno)")
    else:
        print(f"✓ tun.png baixado ({tamanho} bytes) em {os.path.abspath(destino)}")
except Exception as e:
    print(f"✗ tun.png — erro: {e}")
