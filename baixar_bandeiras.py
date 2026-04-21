"""
Baixa as bandeiras dos países da Copa do Mundo 2026 de flagcdn.com
Salva em assets/flags/ com o nome do código FIFA (ex: bra.png, arg.png)
Execute na raiz do projeto Flutter: python baixar_bandeiras.py
"""

import urllib.request
import os
import time

# Pasta de destino
OUTPUT_DIR = os.path.join("assets", "flags")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Base da URL - bandeiras 80px de largura (suficiente para miniatura no app)
BASE_URL = "https://flagcdn.com/w80/{iso}.png"

# Mapeamento: código FIFA (nome do arquivo) -> código ISO para download
# 46 países confirmados + 4 placeholders UEFA playoff (a definir em março/2026)
TEAMS = {
    # ANFITRIÕES
    "usa": "us",
    "can": "ca",
    "mex": "mx",

    # CONMEBOL (6)
    "arg": "ar",
    "bra": "br",
    "uru": "uy",
    "col": "co",
    "ecu": "ec",
    "par": "py",

    # UEFA confirmados (12)
    "eng": "gb-eng",
    "fra": "fr",
    "cro": "hr",
    "nor": "no",
    "por": "pt",
    "ger": "de",
    "ned": "nl",
    "sui": "ch",
    "sco": "gb-sct",
    "esp": "es",
    "aut": "at",
    "bel": "be",

    # CAF (10)
    "tun": "tn",
    "mar": "ma",
    "rsa": "za",
    "egy": "eg",
    "alg": "dz",
    "gha": "gh",
    "civ": "ci",
    "sen": "sn",
    "cpv": "cv",
    "cmr": "cm",

    # AFC (8)
    "jpn": "jp",
    "kor": "kr",
    "ksa": "sa",
    "qat": "qa",
    "aus": "au",
    "uzb": "uz",
    "jor": "jo",
    "irq": "iq",

    # CONCACAF (sem anfitriões)
    "pan": "pa",
    "cur": "cw",
    "hai": "ht",

    # OFC (1)
    "nzl": "nz",
}

# Placeholders para os 6 spots de playoff (UEFA + intercontinental)
# Serão substituídos após março/2026
# Por enquanto baixamos os candidatos mais prováveis como backup
PLAYOFF_CANDIDATES = {
    # UEFA playoff (Path A)
    "ita": "it",
    "wal": "gb-wls",
    "nir": "gb-nir",
    "bih": "ba",
    # UEFA playoff (Path B)
    "gre": "gr",
    "ukr": "ua",
    "geo": "ge",
    "arm": "am",
    # UEFA playoff (Path C)
    "srb": "rs",
    "fin": "fi",
    "irl": "ie",
    "hun": "hu",
    # UEFA playoff (Path D)
    "den": "dk",
    "mne": "me",
    "cze": "cz",
    "rou": "ro",
    # Intercontinental playoff
    "ven": "ve",
    "uae": "ae",
    "bol": "bo",
    "sur": "sr",
    "ncl": "nc",
    "jam": "jm",
    "cod": "cd",  # DR Congo
}

def baixar(fifa_code, iso_code, label=""):
    url = BASE_URL.format(iso=iso_code)
    destino = os.path.join(OUTPUT_DIR, f"{fifa_code}.png")

    if os.path.exists(destino):
        print(f"  ✓ {fifa_code}.png já existe, pulando.")
        return True

    try:
        urllib.request.urlretrieve(url, destino)
        tamanho = os.path.getsize(destino)
        if tamanho < 100:
            os.remove(destino)
            print(f"  ✗ {fifa_code}.png — arquivo inválido (muito pequeno)")
            return False
        print(f"  ✓ {fifa_code}.png baixado ({tamanho} bytes) {label}")
        return True
    except Exception as e:
        print(f"  ✗ {fifa_code}.png — erro: {e}")
        return False

print("=" * 55)
print("  Baixando bandeiras Copa 2026 — países confirmados")
print("=" * 55)
ok = 0
fail = 0
for fifa, iso in TEAMS.items():
    if baixar(fifa, iso):
        ok += 1
    else:
        fail += 1
    time.sleep(0.1)  # respeita o servidor

print()
print("=" * 55)
print("  Baixando candidatos aos playoffs (backup)")
print("=" * 55)
for fifa, iso in PLAYOFF_CANDIDATES.items():
    if baixar(fifa, iso, "[playoff]"):
        ok += 1
    else:
        fail += 1
    time.sleep(0.1)

print()
print("=" * 55)
print(f"  Concluído: {ok} baixados, {fail} com erro")
print(f"  Pasta: {os.path.abspath(OUTPUT_DIR)}")
print("=" * 55)