# -*- coding: utf-8 -*-
"""بعد از اضافه کردن فایل JSON:
1) نام فایل فقط انگلیسی باشد (مثال: job_burnout.json)
2) فیلد id داخل JSON هم همان نام انگلیسی باشد
3) python content/rebuild_indexes.py
4) flutter pub get && flutter run -d chrome

ویندوز + Flutter با نام فارسی فایل asset خطا می‌دهد.
"""
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parent

def ascii_ok(name: str) -> bool:
    return bool(re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_\-]*', name))

def rebuild_methods():
    units = root / 'units' / 'methods'
    units.mkdir(parents=True, exist_ok=True)
    index = []
    for f in sorted(units.glob('*.json'), key=lambda p: int(p.stem) if p.stem.isdigit() else 0):
        if not ascii_ok(f.stem):
            print(f'WARN method file not ascii: {f.name}')
        d = json.loads(f.read_text(encoding='utf-8'))
        m = d.get('meta', d)
        index.append({
            'id': int(str(m.get('id', f.stem))),
            't': m.get('t') or '',
            'c': m.get('c') or 'self',
            'time': m.get('time') or '—',
            'desc': m.get('desc') or '',
            'updatedAt': m.get('updatedAt') or '',
        })
    (root / 'methods_index.json').write_text(json.dumps(index, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f'methods: {len(index)}')

def rebuild_problems():
    units = root / 'units' / 'problems'
    units.mkdir(parents=True, exist_ok=True)
    index = []
    for f in sorted(units.glob('*.json')):
        if not ascii_ok(f.stem):
            print(f'ERROR: نام فایل باید فقط انگلیسی باشد: {f.name}')
            print('  مثال درست: parental_burnout.json')
            continue
        d = json.loads(f.read_text(encoding='utf-8'))
        pid = str(d.get('id') or f.stem)
        if not ascii_ok(pid):
            print(f'WARN: id داخل JSON انگلیسی نیست ({pid}) — از نام فایل استفاده می‌شود')
            pid = f.stem
            d['id'] = pid
            f.write_text(json.dumps(d, ensure_ascii=False, indent=2), encoding='utf-8')
        if pid != f.stem:
            print(f'WARN: id ({pid}) با نام فایل ({f.stem}) یکی نیست — فایل را به {pid}.json تغییر نام بده')
        index.append({
            'id': pid,
            'n': d.get('n') or d.get('name') or pid,
            'cat': d.get('cat') or 'burnout',
            'updatedAt': d.get('updatedAt') or '',
        })
    (root / 'problems_index.json').write_text(json.dumps(index, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f'problems: {len(index)}')

if __name__ == '__main__':
    rebuild_methods()
    rebuild_problems()
