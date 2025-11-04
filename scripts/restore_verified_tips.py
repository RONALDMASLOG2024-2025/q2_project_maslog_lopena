#!/usr/bin/env python3
"""
Restore 52 verified tips from documentation into proper positions (t121-t172)
"""

import json
from datetime import datetime, timedelta

# Read current tips
with open('assets/data/tips.json', 'r', encoding='utf-8') as f:
    tips = json.load(f)

print(f"Current tips: {len(tips)}")

# Filter to keep only t001-t120 and t173-t365
original_tips = [t for t in tips if t['id'] <= 't120']
new_ai_tips = [t for t in tips if t['id'] >= 't173']

print(f"Keeping t001-t120: {len(original_tips)} tips")
print(f"Keeping t173-t365: {len(new_ai_tips)} tips")

# Verified tips from documentation
verified_tips_data = [
    # PHASE 1 - PCMag (9 tips) - t121-t129
    {"text": "Hard restart your phone regularly to clear app caching running amok, network connectivity difficulties, and memory glitches.", "category": "deviceCare", "explanation": "Clears accumulated issues that slow down performance without requiring any deletions or changes.", "source": "PCMag"},
    {"text": "Uninstall apps you're not using to free up storage and stop background processing.", "category": "deviceCare", "explanation": "Unused apps consume storage and quietly hog processing power in the background, slowing your device.", "source": "PCMag"},
    {"text": "Turn on Auto Archive in Google Play to automatically remove unused app data while keeping icons.", "category": "deviceCare", "explanation": "Frees up space automatically without losing apps completely—you can restore them anytime.", "source": "PCMag"},
    {"text": "Keep apps updated to their most optimized, efficient versions.", "category": "deviceCare", "explanation": "App updates include performance improvements and bug fixes that make devices run faster.", "source": "PCMag"},
    {"text": "Upload photos and videos to Google Photos or iCloud to free up device storage.", "category": "energySaving", "explanation": "Photos and videos consume the most storage space—freeing it up improves performance and extends device life.", "source": "PCMag"},
    {"text": "Clear browsing history and website data to remove trace bits that slow your phone down.", "category": "deviceCare", "explanation": "Web pages and apps leave behind cached data that accumulates over time and consumes resources.", "source": "PCMag"},
    {"text": "Install the latest operating system version for more efficient performance.", "category": "deviceCare", "explanation": "OS updates are optimized for better speed and battery efficiency compared to older versions.", "source": "PCMag"},
    {"text": "Delete widgets you don't actively use to reduce system resource consumption.", "category": "energySaving", "explanation": "Widgets constantly refresh and consume system resources even when you're not looking at them.", "source": "PCMag"},
    {"text": "Monitor battery health and consider replacement if it drops below 80%.", "category": "deviceCare", "explanation": "Poor battery health directly impacts device performance and reliability.", "source": "PCMag"},
    
    # PHASE 1 - LG Electronics (4 tips) - t130-t133
    {"text": "Keep your laptop battery level between 20% and 80% to maximize its lifespan.", "category": "energySaving", "explanation": "Avoiding extreme charge levels (0% or 100%) reduces stress on lithium-ion cells and extends battery life.", "source": "LG Electronics"},
    {"text": "Lower screen brightness to significantly extend battery life.", "category": "energySaving", "explanation": "The display is one of the biggest power consumers—reducing brightness can add hours of battery life.", "source": "LG Electronics"},
    {"text": "When taking extended breaks, use hibernation mode instead of sleep to save maximum power.", "category": "energySaving", "explanation": "Hibernation saves your work and uses almost no power, unlike sleep mode which still drains the battery.", "source": "LG Electronics"},
    {"text": "If storing your laptop for weeks or months, charge it to around 50% first.", "category": "deviceCare", "explanation": "Storing at extreme charge levels (0% or 100%) can permanently damage battery capacity.", "source": "LG Electronics"},
    
    # PHASE 1 - NHM UK (6 tips) - t134-t139
    {"text": "Think twice before upgrading—do you really need a new device?", "category": "ecoBuying", "explanation": "Extending device life by even one year prevents mining of rare earth minerals and reduces e-waste significantly.", "source": "Natural History Museum UK"},
    {"text": "Take broken electronics to a repair cafe instead of buying new.", "category": "deviceCare", "explanation": "Many devices only need minor repairs—fixing them avoids mining new materials and keeps e-waste out of landfill.", "source": "Natural History Museum UK"},
    {"text": "If your device still works, give it to someone who can use it.", "category": "disposal", "explanation": "Reuse is better than recycling—extending a device's useful life has the lowest environmental impact.", "source": "Natural History Museum UK"},
    {"text": "Check if the manufacturer has a take-back program for credit or recycling.", "category": "disposal", "explanation": "Manufacturers can recover valuable materials more efficiently than generic recycling facilities.", "source": "Natural History Museum UK"},
    {"text": "Never throw electronics in regular trash—find a certified e-waste recycler in your area.", "category": "disposal", "explanation": "E-waste contains toxic substances (lead, mercury) that leach into soil and water from landfills.", "source": "Natural History Museum UK"},
    {"text": "Choose brands that offer clear end-of-life recycling or take-back services.", "category": "ecoBuying", "explanation": "Supporting responsible companies drives industry change toward sustainable practices.", "source": "Natural History Museum UK"},
    
    # PHASE 2 - Honor (8 tips) - t140-t147
    {"text": "Restart your phone weekly to clear memory, remove temporary files, and trigger system updates.", "category": "deviceCare", "explanation": "Regular restarts prevent memory leaks and performance degradation from accumulated temporary data.", "source": "Honor"},
    {"text": "Update Android operating system regularly for performance optimizations and bug fixes.", "category": "deviceCare", "explanation": "OS updates include security improvements and better app compatibility that enhance device longevity.", "source": "Honor"},
    {"text": "Remove old files and downloads you no longer need to free up space.", "category": "deviceCare", "explanation": "Deleting outdated documents prevents storage clutter that slows down your device.", "source": "Honor"},
    {"text": "Clear app cache regularly by going to Settings > Apps > Storage > Clear Cache.", "category": "deviceCare", "explanation": "Cached data accumulates over time and can cause apps to slow down or malfunction.", "source": "Honor"},
    {"text": "If supported, transfer apps from internal storage to SD card.", "category": "deviceCare", "explanation": "Moving apps to SD card frees up valuable internal storage for better performance.", "source": "Honor"},
    {"text": "Disable or uninstall pre-installed apps (bloatware) that you don't use.", "category": "deviceCare", "explanation": "Bloatware takes up space and resources even when you're not actively using it.", "source": "Honor"},
    {"text": "Restrict apps from running in background via Developer options to limit background processes.", "category": "energySaving", "explanation": "Background processes drain battery and CPU even when apps aren't actively in use.", "source": "Honor"},
    {"text": "Reduce animation effects in Developer options to make phone feel faster.", "category": "energySaving", "explanation": "Disabling animations reduces visual delays and makes UI interactions more responsive.", "source": "Honor"},
    
    # PHASE 2 - Norton (10 tips) - t148-t157
    {"text": "Use compressed air to remove dust from fans and vents quarterly, preventing overheating.", "category": "deviceCare", "explanation": "Dust buildup restricts airflow, causing components to overheat and fail prematurely.", "source": "Norton"},
    {"text": "Use compressed air monthly to remove dust from USB, HDMI, and audio ports.", "category": "deviceCare", "explanation": "Dust in ports can prevent proper connections and cause intermittent failures.", "source": "Norton"},
    {"text": "Defragment HDD monthly to reorganize fragmented data for faster access (HDDs only, not SSDs).", "category": "energySaving", "explanation": "Defragmentation reduces disk seek time, improving performance on traditional hard drives.", "source": "Norton"},
    {"text": "Disable unnecessary startup apps via Task Manager to speed boot time.", "category": "energySaving", "explanation": "Fewer startup programs mean faster boots and more available resources after startup.", "source": "Norton"},
    {"text": "Avoid quickly turning computer on/off to reduce stress on components.", "category": "deviceCare", "explanation": "Power cycling stresses capacitors and hard drives, potentially shortening their lifespan.", "source": "Norton"},
    {"text": "Disconnect laptop charger when fully charged to preserve battery capacity.", "category": "energySaving", "explanation": "Overcharging generates heat that degrades battery chemistry over time.", "source": "Norton"},
    {"text": "Keep food and drinks away from your PC to prevent spill-related damage.", "category": "deviceCare", "explanation": "Liquid damage is one of the most common and devastating causes of electronics failure.", "source": "Norton"},
    {"text": "Store your PC in a cool location to reduce overheating risk and accidental damage.", "category": "deviceCare", "explanation": "Heat accelerates component degradation, while cool storage extends hardware life.", "source": "Norton"},
    {"text": "Sort desktop files into labeled folders monthly to improve performance.", "category": "energySaving", "explanation": "Organized files reduce system indexing overhead and make finding files faster.", "source": "Norton"},
    {"text": "Empty Recycle Bin weekly to clear deleted files and free up hard drive space.", "category": "energySaving", "explanation": "Recycle Bin files still occupy disk space until permanently deleted.", "source": "Norton"},
    
    # PHASE 2 - EPA (7 tips) - t158-t164
    {"text": "Consider upgrading existing computer hardware or software instead of buying new.", "category": "ecoBuying", "explanation": "Upgrading RAM or storage is often cheaper and more sustainable than full replacement.", "source": "EPA"},
    {"text": "Remove all personal information from electronics before donation or recycling.", "category": "disposal", "explanation": "Data breaches can occur if you don't properly wipe devices before disposal.", "source": "EPA"},
    {"text": "Remove lithium-ion batteries for separate recycling—never trash them.", "category": "disposal", "explanation": "Lithium-ion batteries can explode or catch fire in landfills and require special handling.", "source": "EPA"},
    {"text": "Research e-waste drop-off locations in your local area.", "category": "disposal", "explanation": "Many communities have free e-waste collection events or permanent drop-off centers.", "source": "EPA"},
    {"text": "Find battery recycling locations through Call2Recycle website.", "category": "disposal", "explanation": "Call2Recycle operates thousands of battery recycling drop-off locations across North America.", "source": "EPA"},
    {"text": "Search for electronics recycling options by zip code using Earth911.", "category": "disposal", "explanation": "Earth911's recycling locator helps you find certified recyclers near you.", "source": "EPA"},
    {"text": "Donate functional devices to charities or refurbishment programs.", "category": "disposal", "explanation": "Working electronics have value—donation helps others while keeping devices in use longer.", "source": "EPA"},
    
    # PHASE 3 - Android Authority (8 tips) - t165-t172
    {"text": "Keep phone charged between 30-80% to maximize battery lifespan.", "category": "energySaving", "explanation": "Partial charging reduces stress on lithium-ion cells compared to full 0-100% cycles.", "source": "Android Authority"},
    {"text": "Don't leave phone charging overnight or in cradle all day.", "category": "deviceCare", "explanation": "Idle charging causes mini-cycles and heat buildup that degrade battery health.", "source": "Android Authority"},
    {"text": "Heat is battery's biggest enemy—keep phone under 40°C (104°F).", "category": "deviceCare", "explanation": "High temperatures accelerate chemical degradation inside lithium-ion batteries.", "source": "Android Authority"},
    {"text": "Limit fast charging use—it creates heat stress on battery.", "category": "energySaving", "explanation": "Fast charging is convenient but generates more heat than slower charging methods.", "source": "Android Authority"},
    {"text": "Don't game or stream while charging—it distorts charging cycles and generates extra heat.", "category": "energySaving", "explanation": "Using phone while charging creates parasitic load that degrades battery faster.", "source": "Android Authority"},
    {"text": "If device supports it, enable bypass charging feature.", "category": "deviceCare", "explanation": "Bypass charging powers device directly from charger, reducing battery wear.", "source": "Android Authority"},
    {"text": "Store devices at 40-50% charge for long periods to prevent battery degradation.", "category": "deviceCare", "explanation": "Mid-range charge prevents capacity loss during extended storage.", "source": "Android Authority"},
    {"text": "Regular small top-ups are better for Li-ion batteries than long full charge cycles.", "category": "energySaving", "explanation": "Frequent partial charges reduce stress compared to deep discharge cycles.", "source": "Android Authority"},
]

# Create verified tips t121-t172
verified_tips = []
base_date = datetime(2025, 11, 5)  # Start after original tips

for i, tip_data in enumerate(verified_tips_data):
    tip_id = f"t{121 + i:03d}"
    created_at = (base_date + timedelta(days=i)).isoformat() + "Z"
    
    verified_tip = {
        "id": tip_id,
        "text": tip_data["text"],
        "category": tip_data["category"],
        "explanation": tip_data["explanation"],
        "createdAt": created_at,
        "source": tip_data["source"]
    }
    
    verified_tips.append(verified_tip)

print(f"Created {len(verified_tips)} verified tips (t121-t172)")

# Combine all tips in order: t001-t120, t121-t172, t173-t365
all_tips = original_tips + verified_tips + new_ai_tips

print(f"Total tips after restoration: {len(all_tips)}")

# Verify distribution
categories = {}
sources = {}
for tip in all_tips:
    cat = tip['category']
    src = tip.get('source', 'Unknown')
    categories[cat] = categories.get(cat, 0) + 1
    sources[src] = sources.get(src, 0) + 1

print("\nCategory distribution:")
for cat, count in sorted(categories.items()):
    percentage = (count / len(all_tips)) * 100
    print(f"  {cat}: {count} tips ({percentage:.1f}%)")

print("\nSource distribution:")
for src, count in sorted(sources.items()):
    percentage = (count / len(all_tips)) * 100
    print(f"  {src}: {count} tips ({percentage:.1f}%)")

# Verify tip IDs are sequential
print("\nVerifying tip ID sequence...")
for i, tip in enumerate(all_tips):
    expected_id = f"t{i+1:03d}"
    if tip['id'] != expected_id:
        print(f"ERROR: Tip at index {i} has id '{tip['id']}', expected '{expected_id}'")

# Write restored tips
with open('assets/data/tips.json', 'w', encoding='utf-8') as f:
    json.dump(all_tips, f, indent=2, ensure_ascii=False)

print(f"\n✅ Successfully restored 365 tips!")
print(f"   - t001-t120: AI-Generated (original curated)")
print(f"   - t121-t172: Verified from authoritative sources (52 tips)")
print(f"   - t173-t365: AI-Generated (newly created)")
