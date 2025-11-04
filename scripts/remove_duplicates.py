import json

# Read current tips
tips = json.load(open('assets/data/tips.json', encoding='utf-8'))

print(f'Current total: {len(tips)} tips')

# Remove duplicates by keeping only first occurrence of each ID
seen_ids = set()
unique_tips = []

for tip in tips:
    if tip['id'] not in seen_ids:
        unique_tips.append(tip)
        seen_ids.add(tip['id'])
    else:
        print(f'Removing duplicate: {tip["id"]}')

print(f'\nAfter deduplication: {len(unique_tips)} tips')

# Verify we have exactly t001-t365
expected_ids = {f't{i:03d}' for i in range(1, 366)}
actual_ids = {t['id'] for t in unique_tips}

missing = expected_ids - actual_ids
extra = actual_ids - expected_ids

if missing:
    print(f'\nMissing IDs: {sorted(missing)}')
if extra:
    print(f'\nExtra IDs: {sorted(extra)}')

if not missing and not extra:
    print('\n✅ Perfect! All IDs from t001 to t365 present, no duplicates')

# Count by source
sources = {}
for tip in unique_tips:
    src = tip.get('source', 'Unknown')
    sources[src] = sources.get(src, 0) + 1

print('\nSource distribution:')
for src, count in sorted(sources.items()):
    percentage = (count / len(unique_tips)) * 100
    print(f'  {src}: {count} tips ({percentage:.1f}%)')

# Save cleaned tips
json.dump(unique_tips, open('assets/data/tips.json', 'w', encoding='utf-8'), indent=2, ensure_ascii=False)
print(f'\n✅ Saved {len(unique_tips)} unique tips to tips.json')
