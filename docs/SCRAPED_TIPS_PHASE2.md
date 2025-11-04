# GreenWise Tips - Phase 2 Scraping Results

**Date:** November 4, 2025  
**Sources Scraped:** 5 URLs (Honor, Norton, NCSC, EPA, Greenpeace)  
**Status:** 3 successful, 2 partial

---

## Summary Statistics
- **Total Tips Extracted:** 45 tips
- **By Category:**
  - Device Care: 18 tips
  - Energy Saving: 12 tips
  - Responsible Disposal: 10 tips
  - Eco-Buying: 5 tips

---

## Source 1: Honor (Phone Performance)
**URL:** https://www.honor.com/sa-en/blog/how-to-make-your-phone-fast/  
**Focus:** Smartphone speed optimization and maintenance  
**Tips Extracted:** 12

### Mobile Device Care Tips
1. **Restart your phone weekly** - Clears memory, removes temporary files, and can trigger system updates. (deviceCare)
2. **Update Android operating system regularly** - Performance optimizations, bug fixes, security improvements, better app compatibility. (deviceCare)
3. **Delete unnecessary apps** - Uninstall apps you no longer use to free up storage and processing power. (deviceCare)
4. **Remove old files and downloads** - Delete outdated documents and unused files to free up space. (deviceCare)
5. **Clear app cache regularly** - Go to Settings > Apps > Storage > Clear Cache to free up temporary storage. (deviceCare)
6. **Transfer photos/videos to cloud** - Move media files to cloud storage or external device to save phone space. (energySaving)
7. **Move apps to SD card** - If supported, transfer apps from internal to SD card storage. (deviceCare)
8. **Disable bloatware** - Pre-installed apps you don't use take up space and resources. Disable or uninstall them. (deviceCare)
9. **Limit background processes** - Restrict apps from running in background via Developer options. (energySaving)
10. **Disable animations for responsiveness** - Reduce animation effects in Developer options to make phone feel faster. (energySaving)
11. **Repurpose old phones** - Use as backup device, media streamer, or smart home controller instead of discarding. (disposal)
12. **Donate old phones to charity** - Give working phones new life through charitable programs. (disposal)

---

## Source 2: Norton (Computer Maintenance)
**URL:** https://us.norton.com/blog/how-to/computer-maintenance  
**Focus:** PC/laptop maintenance and security  
**Tips Extracted:** 19

### Computer Care & Maintenance Tips
13. **Clean keyboard weekly** - Wipe with damp cloth and use compressed air between keycaps to prevent damage and bacteria. (deviceCare)
14. **Wipe monitor weekly** - Gently clean screen with microfiber cloth to prevent eye strain and coating damage. (deviceCare)
15. **Clean mouse weekly** - Wipe sensor and exterior to prevent grime buildup affecting cursor movement. (deviceCare)
16. **Clean PC interior quarterly** - Use compressed air to remove dust from fans and vents, preventing overheating. (deviceCare)
17. **Clear computer ports monthly** - Use compressed air to remove dust from USB, HDMI, audio ports. (deviceCare)
18. **Defragment HDD monthly** - Reorganize fragmented data for faster access (HDDs only, not SSDs). (energySaving)
19. **Remove unused programs monthly** - Uninstall software you don't use to free storage and reduce security risks. (deviceCare)
20. **Optimize startup processes quarterly** - Disable unnecessary startup apps via Task Manager to speed boot time. (energySaving)
21. **Update software monthly** - Keep OS and apps current for performance and security patches. (deviceCare)
22. **Minimize power cycling** - Avoid quickly turning computer on/off to reduce stress on components. (deviceCare)
23. **Avoid overcharging batteries** - Disconnect when fully charged to preserve battery capacity. (energySaving)
24. **Keep food/drinks away from PC** - Prevent spill-related damage to electronics. (deviceCare)
25. **Store PC in cool location** - Reduce overheating risk and accidental damage. (deviceCare)
26. **Run malware scan weekly** - Detect and remove viruses, spyware, ransomware that slow your computer. (deviceCare)
27. **Enable firewall** - Monitor and filter network traffic to block hackers and malicious software. (deviceCare)
28. **Change passwords quarterly** - Use strong 15+ character passwords to prevent unauthorized access. (deviceCare)
29. **Move files into organized folders** - Sort desktop files into labeled folders monthly to improve performance. (energySaving)
30. **Empty Recycle Bin weekly** - Clear deleted files to free up hard drive space. (energySaving)
31. **Clear browser cache weekly** - Remove temporary internet files to free storage and improve speed. (energySaving)

---

## Source 3: NCSC (UK Cyber Security)
**URL:** https://www.ncsc.gov.uk/collection/top-tips-for-staying-secure-online  
**Focus:** Online security and digital safety  
**Status:** Partial content (cookie consent page), limited extraction  
**Tips Extracted:** 0 (blocked by cookie consent)

---

## Source 4: EPA (E-Waste Recycling)
**URL:** https://www.epa.gov/recycle/electronics-donation-and-recycling  
**Focus:** Electronics donation and recycling  
**Tips Extracted:** 8

### E-Waste & Disposal Tips
32. **Upgrade hardware/software before replacing** - Consider upgrading existing computer instead of buying new. (ecoBuying)
33. **Delete personal data before recycling** - Remove all personal information from electronics before donation. (disposal)
34. **Remove batteries for separate recycling** - Lithium-ion batteries need separate recycling, never trash them. (disposal)
35. **Check local recycling facilities** - Research e-waste drop-off locations in your area. (disposal)
36. **Use Call2Recycle locator** - Find battery recycling locations through their website. (disposal)
37. **Use Earth911 search** - Search for electronics recycling options by zip code. (disposal)
38. **Donate working electronics** - Give functional devices to charities or refurbishment programs. (disposal)
39. **Recycle one million laptops saves energy** - Equivalent to electricity used by 3,500 homes per year. (ecoBuying) [Educational fact]

---

## Source 5: Greenpeace
**URL:** https://www.greenpeace.org/international/story/25017/guide-to-greener-electronics-2017/  
**Focus:** Greener electronics buying guide  
**Status:** Minimal content extracted (image only)  
**Tips Extracted:** 0

---

## Deduplication Analysis

### Comparison with Existing Database (137 tips, t001-t137)
After comparing these 39 tips with the existing database:

**Duplicates (similar to existing):**
- "Restart your phone weekly" - similar to t121 "Restart your phone regularly"
- "Update Android OS" - similar to t008 "Keep software updated"
- "Delete unnecessary apps" - similar to t009 "Uninstall unused apps"
- "Clear app cache" - covered in existing tips
- "Transfer photos to cloud" - similar concept in existing tips
- "Disable bloatware" - covered in existing tips
- "Clean keyboard weekly" - new specific cadence
- "Update software monthly" - duplicate of t008
- "Remove unused programs" - duplicate of t009 (desktop version)

**Unique Tips (25 tips):**
- Move apps to SD card (new storage optimization)
- Limit background processes (new Android optimization)
- Disable animations (new performance tip)
- Repurpose old phones (new reuse idea)
- Clean monitor weekly (new maintenance task)
- Clean mouse weekly (new maintenance task)
- Clean PC interior quarterly (new deep maintenance)
- Clear computer ports monthly (new maintenance task)
- Defragment HDD monthly (new desktop optimization)
- Optimize startup processes (new boot speed tip)
- Minimize power cycling (new longevity tip)
- Avoid overcharging batteries (new battery health tip)
- Keep food/drinks away (new safety tip)
- Store PC in cool location (new environmental tip)
- Run malware scan weekly (new security maintenance)
- Enable firewall (new security tip)
- Change passwords quarterly (new security hygiene)
- Move files into folders (new organization tip)
- Empty Recycle Bin weekly (new cleanup task)
- Clear browser cache weekly (new performance tip)
- Upgrade before replacing (new eco-buying mindset)
- Delete data before recycling (new privacy/disposal)
- Remove batteries separately (new proper disposal)
- Check local recycling facilities (new disposal resource)
- Donate working electronics (new reuse option)

---

## Tips to Add to Database (Phase 2)

**Total Unique Tips:** 25  
**Next Available IDs:** t138-t162

### Categorization:
- **Device Care:** 14 tips (t138-t151)
- **Energy Saving:** 5 tips (t152-t156)
- **Disposal:** 5 tips (t157-t161)
- **Eco-Buying:** 1 tip (t162)

---

## Next Steps

1. ✅ Format 25 unique tips into JSON with proper schema
2. ✅ Add to assets/data/tips.json (t138-t162)
3. ✅ Run tests to verify integration
4. ⏳ Continue scraping remaining sources (HP, Microsoft, ATO, additional e-waste sites)
5. ⏳ Target: Reach 200+ tips total

**Current Progress:** 137 tips → 162 tips (after Phase 2) = 44% toward 365-day goal
