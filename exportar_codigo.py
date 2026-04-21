import os
from datetime import datetime

root = os.getcwd()
timestamp = datetime.now().strftime('%d/%m/%Y %H:%M:%S')

# ── Configurações ─────────────────────────────────────────────────────────────

EXTENSOES_CODIGO = {'.dart', '.js', '.ts', '.json', '.yaml', '.yml', '.rules', '.md'}

EXTENSOES_AUDITORIA = {
    ".dart", ".yaml", ".yml", ".kts", ".gradle", ".js",
    ".xml", ".json", ".plist", ".swift", ".rules"
}

IGNORAR_PASTAS = {
    '.git', 'build', '.dart_tool', '.idea',
    '.vscode', 'Pods', '.gradle', 'test',
    'node_modules', '.flutter-plugins', 'seed'
}

IGNORAR_ARQUIVOS = {
    "firebase_options.dart",
    "google-services.json",
    "GoogleService-Info.plist",
    "exportar_codigo.py",
    "auditoria_codigo_py.txt",
    "normalizar_dart.py",
    "serviceAccountKeyBolao.json",
}

# ── Grupos de arquivos por parte ──────────────────────────────────────────────
# Cada tupla: (nome_do_arquivo_saida, lista_de_subpastas_ou_prefixos)
# "" = raiz do projeto + android/ + ios/

PARTES = [
    ("auditoria_parte1_config.txt",  [""]),
    ("auditoria_parte2_models.txt",  ["lib\\data"]),
    ("auditoria_parte3_services.txt",["lib\\services",
                                      "lib\\core",
                                      "lib\\main.dart"]),
    ("auditoria_parte4_features.txt",["lib\\features"]),
]

# ── Arquivos críticos sempre incluídos ────────────────────────────────────────

def is_critical(full_path):
    n = full_path.replace("\\", "/")
    if n.endswith("MainActivity.kt"):       return True
    if n.endswith(".entitlements"):         return True
    if n.endswith("Info.plist"):            return True
    if n.endswith("AppDelegate.swift"):     return True
    if "network_security_config.xml" in n:  return True
    return False

def pertence_a_parte(full_path, prefixos):
    rel = os.path.relpath(full_path, root)
    for p in prefixos:
        if p == "":
            partes_rel = rel.split(os.sep)
            if partes_rel[0] in ("android", "ios") or len(partes_rel) == 1:
                return True
        else:
            if rel.startswith(p):
                return True
    return False

# ── Passo 1: Normalizar quebras de linha ──────────────────────────────────────

print("Normalizando arquivos...")
normalizados = 0

for dirpath, dirnames, filenames in os.walk(root):
    dirnames[:] = [d for d in dirnames if d not in IGNORAR_PASTAS]

    for file in filenames:
        if file in IGNORAR_ARQUIVOS:
            continue
        ext = os.path.splitext(file)[1].lower()
        if ext not in EXTENSOES_CODIGO:
            continue
        caminho = os.path.join(dirpath, file)
        try:
            with open(caminho, 'rb') as f:
                conteudo = f.read()
            texto = conteudo.decode('utf-8', errors='replace')
            normalizado = texto.replace('\r\r\n', '\n').replace('\r\n', '\n').replace('\r', '\n')
            if not normalizado.endswith('\n'):
                normalizado += '\n'
            if normalizado != texto:
                with open(caminho, 'w', encoding='utf-8', newline='\n') as f:
                    f.write(normalizado)
                normalizados += 1
        except Exception as e:
            print(f'  ERRO ao normalizar {caminho}: {e}')

print(f"  {normalizados} arquivo(s) normalizado(s).")

# ── Passo 2: Coletar todos os arquivos elegíveis ──────────────────────────────

todos_arquivos = []

for dirpath, dirnames, filenames in os.walk(root):
    dirnames[:] = [d for d in dirnames if d not in IGNORAR_PASTAS]

    for file in sorted(filenames):
        if file in IGNORAR_ARQUIVOS:
            continue
        ext = os.path.splitext(file)[1]
        full_path = os.path.join(dirpath, file)

        if not is_critical(full_path):
            if ext not in EXTENSOES_AUDITORIA:
                continue

        todos_arquivos.append(full_path)

# ── Passo 3: Escrever cada parte ──────────────────────────────────────────────

print("Gerando partes da auditoria...")
total_geral = 0

for nome_saida, prefixos in PARTES:
    output = os.path.join(root, nome_saida)
    file_count = 0

    with open(output, "w", encoding="utf-8") as out:
        out.write("==================================================\n")
        out.write(f"AUDITORIA DE CÓDIGO — {nome_saida}\n")
        out.write(f"Gerado em: {timestamp}\n")
        out.write(f"Pasta raiz: {root}\n")
        out.write("==================================================\n\n")

        for full_path in todos_arquivos:
            if not pertence_a_parte(full_path, prefixos):
                continue

            out.write("==================================================\n")
            out.write(f"ARQUIVO: {full_path}\n")
            out.write("==================================================\n")

            try:
                with open(full_path, "r", encoding="utf-8") as f:
                    for i, line in enumerate(f, start=1):
                        out.write(f"{i:4}: {line}")
                file_count += 1
            except Exception as e:
                out.write(f"[ERRO ao ler arquivo: {e}]\n")

            out.write("\n\n")

        out.write("==================================================\n")
        out.write(f"Total de arquivos nesta parte: {file_count}\n")
        out.write("==================================================\n")

    total_geral += file_count
    print(f"  {nome_saida}: {file_count} arquivo(s)")

# ── Verificar arquivos não cobertos por nenhuma parte ─────────────────────────

nao_cobertos = [
    f for f in todos_arquivos
    if not any(pertence_a_parte(f, prefixos) for _, prefixos in PARTES)
]

if nao_cobertos:
    output = os.path.join(root, "auditoria_parte5_outros.txt")
    with open(output, "w", encoding="utf-8") as out:
        out.write("==================================================\n")
        out.write(f"AUDITORIA DE CÓDIGO — auditoria_parte5_outros.txt\n")
        out.write(f"Gerado em: {timestamp}\n")
        out.write(f"Pasta raiz: {root}\n")
        out.write("==================================================\n\n")
        for full_path in nao_cobertos:
            out.write("==================================================\n")
            out.write(f"ARQUIVO: {full_path}\n")
            out.write("==================================================\n")
            try:
                with open(full_path, "r", encoding="utf-8") as f:
                    for i, line in enumerate(f, start=1):
                        out.write(f"{i:4}: {line}")
                total_geral += 1
            except Exception as e:
                out.write(f"[ERRO ao ler arquivo: {e}]\n")
            out.write("\n\n")
        out.write("==================================================\n")
        out.write(f"Total de arquivos nesta parte: {len(nao_cobertos)}\n")
        out.write("==================================================\n")
    print(f"  auditoria_parte5_outros.txt: {len(nao_cobertos)} arquivo(s) não coberto(s)")

print(f"\nTotal geral: {total_geral} arquivo(s) exportado(s).")
print("Arquivos gerados na pasta raiz do projeto:")
for nome_saida, _ in PARTES:
    print(f"  - {nome_saida}")
if nao_cobertos:
    print(f"  - auditoria_parte5_outros.txt")
