#!/usr/bin/env python3
import hashlib, json, pathlib, sys, zipfile
if len(sys.argv) != 2:
    raise SystemExit("Uso: python3 scripts/inventory.py reference/te-levo-28.9.zip")
source = pathlib.Path(sys.argv[1])
with zipfile.ZipFile(source) as z:
    entries = [{"name": i.filename, "size": i.file_size, "sha256": hashlib.sha256(z.read(i)).hexdigest()} for i in z.infolist() if not i.is_dir()]
out = pathlib.Path("analysis/apk_inventory.json")
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps({"archive": source.name, "files": entries}, indent=2, ensure_ascii=False), encoding="utf-8")
print(f"Inventário salvo em {out}")
