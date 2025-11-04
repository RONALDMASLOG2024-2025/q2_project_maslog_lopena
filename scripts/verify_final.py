import json

tips = json.load(open('assets/data/tips.json', encoding='utf-8'))

print(f'Total tips: {len(tips)}')

print(f'\nBreakdown:')
t001_120 = len([t for t in tips if t['id'] <= 't120'])
t121_172 = len([t for t in tips if 't121' <= t['id'] <= 't172'])
t173_365 = len([t for t in tips if 't173' <= t['id'] <= 't365'])

print(f'  t001-t120: {t001_120} (original AI tips)')
print(f'  t121-t172: {t121_172} (verified tips with sources)')
print(f'  t173-t365: {t173_365} (new AI tips)')

print(f'\nVerified tip sources (t121-t172):')
verified = [t for t in tips if 't121' <= t['id'] <= 't172']
for v in verified[:5]:
    print(f"  {v['id']}: {v['text'][:55]}... [{v['source']}]")

print('\nLast 3 tips:')
for t in tips[-3:]:
    print(f"  {t['id']}: {t['text'][:55]}... [{t.get('source', 'N/A')}]")

# Category distribution
categories = {}
for tip in tips:
    cat = tip['category']
    categories[cat] = categories.get(cat, 0) + 1

print('\nCategory distribution:')
for cat, count in sorted(categories.items()):
    percentage = (count / len(tips)) * 100
    print(f'  {cat}: {count} tips ({percentage:.1f}%)')
