import json
from collections import Counter

tips = json.load(open('assets/data/tips.json', encoding='utf-8'))
ids = [t['id'] for t in tips]

duplicates = {id_val: count for id_val, count in Counter(ids).items() if count > 1}

print(f'Total tips: {len(tips)}')
print(f'Unique IDs: {len(set(ids))}')
print(f'Duplicates: {len(duplicates)}')

if duplicates:
    print('\nDuplicate IDs:')
    for id_val, count in sorted(duplicates.items())[:20]:  # Show first 20
        print(f'  {id_val}: {count} times')
