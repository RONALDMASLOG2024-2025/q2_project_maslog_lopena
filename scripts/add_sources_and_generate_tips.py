#!/usr/bin/env python3
"""
Script to:
1. Add 'source': 'AI-Generated' to tips without sources (t001-t120)
2. Generate 193 new AI tips (t173-t365) to complete 365-day goal
"""

import json
from datetime import datetime, timedelta

# Read existing tips
with open('assets/data/tips.json', 'r', encoding='utf-8') as f:
    tips = json.load(f)

print(f"Loaded {len(tips)} existing tips")

# Step 1: Add source to existing unsourced tips
ai_generated_count = 0
for tip in tips:
    if 'source' not in tip:
        tip['source'] = 'AI-Generated'
        ai_generated_count += 1

print(f"Added 'AI-Generated' source to {ai_generated_count} existing tips")

# Step 2: Generate 193 new AI tips (t173-t365)
# Category distribution to maintain balance:
# energySaving: 77 tips (40%)
# deviceCare: 71 tips (37%)
# disposal: 31 tips (16%)
# ecoBuying: 14 tips (7%)

new_tips_data = [
    # ENERGY SAVING TIPS (77 tips)
    {"text": "Reduce email attachment sizes by compressing files before sending.", "category": "energySaving", "explanation": "Smaller files require less data transfer and storage, reducing energy consumption across servers and networks."},
    {"text": "Unsubscribe from unnecessary email newsletters to reduce server load.", "category": "energySaving", "explanation": "Each stored email consumes server energy. Fewer emails mean less data center power usage."},
    {"text": "Use text-based emails instead of HTML when possible.", "category": "energySaving", "explanation": "Plain text emails are smaller and require less processing power to send and store."},
    {"text": "Download maps for offline use instead of streaming navigation constantly.", "category": "energySaving", "explanation": "Offline maps eliminate continuous data transfer, saving battery and network energy."},
    {"text": "Disable automatic video playback in social media apps.", "category": "energySaving", "explanation": "Auto-play videos consume significant data and battery. Manual playback gives you control."},
    {"text": "Use airplane mode when you don't need connectivity.", "category": "energySaving", "explanation": "Airplane mode disables all radios, dramatically reducing power consumption."},
    {"text": "Close background apps that use location services when not needed.", "category": "energySaving", "explanation": "GPS tracking is power-intensive. Limiting it to essential apps saves battery."},
    {"text": "Disable push notifications for non-essential apps.", "category": "energySaving", "explanation": "Constant notifications wake the device and use network power for syncing."},
    {"text": "Use static wallpapers instead of live or animated ones.", "category": "energySaving", "explanation": "Animated wallpapers require continuous GPU processing, draining battery faster."},
    {"text": "Turn off haptic feedback if you don't need it.", "category": "energySaving", "explanation": "Vibration motors consume more power than you'd expect over daily use."},
    
    {"text": "Reduce screen timeout to 30 seconds or less.", "category": "energySaving", "explanation": "Shorter timeout means less wasted display time when you've walked away."},
    {"text": "Disable automatic brightness and set it manually to a comfortable level.", "category": "energySaving", "explanation": "Auto-brightness sensors use power and may set brightness higher than needed."},
    {"text": "Use Wi-Fi calling instead of cellular when available.", "category": "energySaving", "explanation": "Wi-Fi uses less power than cellular radios for voice calls."},
    {"text": "Limit cloud photo backup to Wi-Fi only, not cellular.", "category": "energySaving", "explanation": "Cellular uploads drain battery faster. Wi-Fi-only backup conserves mobile power."},
    {"text": "Disable automatic app updates and update manually when charging.", "category": "energySaving", "explanation": "Large updates consume significant battery. Scheduling them during charging is more efficient."},
    {"text": "Use reader mode in browsers to strip unnecessary content.", "category": "energySaving", "explanation": "Reader mode removes ads and scripts, reducing CPU load and data transfer."},
    {"text": "Clear browser cache monthly to improve performance.", "category": "energySaving", "explanation": "Bloated caches slow down browsing, causing CPU to work harder."},
    {"text": "Disable browser extensions you don't actively use.", "category": "energySaving", "explanation": "Extensions run continuously in the background, consuming CPU and memory."},
    {"text": "Use a lightweight browser for basic web browsing.", "category": "energySaving", "explanation": "Minimalist browsers use less resources than feature-heavy alternatives."},
    {"text": "Limit the number of open browser windows to reduce memory use.", "category": "energySaving", "explanation": "Each window consumes RAM and CPU. Consolidating tabs saves energy."},
    
    {"text": "Disable desktop widgets and live tiles you don't check regularly.", "category": "energySaving", "explanation": "Live updates require constant CPU and network activity."},
    {"text": "Use task manager to close energy-intensive background processes.", "category": "energySaving", "explanation": "Hidden processes can consume significant power without providing value."},
    {"text": "Disable Windows visual effects for better battery life.", "category": "energySaving", "explanation": "Animations and transparency effects require GPU power continuously."},
    {"text": "Use power-saving mode in your router during nighttime hours.", "category": "energySaving", "explanation": "Reducing router power or Wi-Fi range when not needed saves energy."},
    {"text": "Turn off your router when on vacation or extended absences.", "category": "energySaving", "explanation": "Home network equipment uses 24/7 power. Shutting it down eliminates waste."},
    {"text": "Use a smart plug to schedule device charging during off-peak hours.", "category": "energySaving", "explanation": "Off-peak charging is often greener and may cost less depending on your utility."},
    {"text": "Unplug laptop chargers when not in use to avoid phantom drain.", "category": "energySaving", "explanation": "Chargers draw power even when not charging. Unplugging eliminates this waste."},
    {"text": "Use a charging timer to prevent overcharging overnight.", "category": "energySaving", "explanation": "Timers stop power flow after devices are fully charged, preventing waste."},
    {"text": "Charge multiple devices simultaneously with multi-port chargers.", "category": "energySaving", "explanation": "Single multi-port chargers are more efficient than multiple individual chargers."},
    {"text": "Use solar chargers for portable devices when outdoors.", "category": "energySaving", "explanation": "Solar power is renewable and eliminates grid electricity use for charging."},
    
    {"text": "Disable 5G and use LTE when you don't need maximum speed.", "category": "energySaving", "explanation": "5G radios consume more power than LTE. Switching saves battery."},
    {"text": "Use grayscale mode to reduce OLED screen power consumption.", "category": "energySaving", "explanation": "Grayscale uses less power on OLED displays than full color."},
    {"text": "Disable always-listening voice assistants when privacy allows.", "category": "energySaving", "explanation": "Voice assistants continuously monitor audio, using CPU and microphone power."},
    {"text": "Use wired headphones instead of Bluetooth when possible.", "category": "energySaving", "explanation": "Bluetooth audio requires radio power. Wired connections don't."},
    {"text": "Reduce video call quality when high-definition isn't necessary.", "category": "energySaving", "explanation": "Lower resolution uses less bandwidth and CPU, reducing energy consumption."},
    {"text": "Disable video in calls when you only need audio.", "category": "energySaving", "explanation": "Video streaming uses significantly more power than audio alone."},
    {"text": "Use screen sharing sparingly in video calls.", "category": "energySaving", "explanation": "Screen sharing requires extra processing power for encoding and transmission."},
    {"text": "Close unnecessary apps before starting resource-intensive tasks.", "category": "energySaving", "explanation": "Freeing resources prevents system from working harder than needed."},
    {"text": "Use hibernate instead of sleep for longer breaks.", "category": "energySaving", "explanation": "Hibernate uses zero power by saving state to disk, unlike sleep's standby mode."},
    {"text": "Enable printer sleep mode for home office equipment.", "category": "energySaving", "explanation": "Printers can enter deep sleep when idle, significantly reducing power draw."},
    
    {"text": "Print double-sided to reduce paper and ink consumption.", "category": "energySaving", "explanation": "Less printing means less manufacturing and transportation energy for supplies."},
    {"text": "Use draft mode for everyday printing to save ink and energy.", "category": "energySaving", "explanation": "Draft mode uses less ink and prints faster, requiring less printer-on time."},
    {"text": "Preview documents before printing to avoid wasting paper and ink.", "category": "energySaving", "explanation": "Mistakes waste both supplies and the energy used to produce them."},
    {"text": "Consolidate printing jobs instead of printing individual pages.", "category": "energySaving", "explanation": "Batch printing reduces warmup cycles and overall printer-on time."},
    {"text": "Use digital signatures instead of printing documents to sign.", "category": "energySaving", "explanation": "Digital signatures eliminate printing, scanning, and transportation energy."},
    {"text": "Share documents digitally instead of making multiple printed copies.", "category": "energySaving", "explanation": "Cloud sharing eliminates printing energy and paper waste."},
    {"text": "Use e-books instead of downloading and printing PDF documents.", "category": "energySaving", "explanation": "E-readers and screens use less total energy than printing physical copies."},
    {"text": "Disable telemetry and analytics in apps when privacy settings allow.", "category": "energySaving", "explanation": "Constant data reporting uses network and CPU power continuously."},
    {"text": "Use local file storage instead of constant cloud syncing.", "category": "energySaving", "explanation": "Local-first work reduces network activity and server load."},
    {"text": "Disable animated GIFs in messaging apps.", "category": "energySaving", "explanation": "Animated images require continuous CPU decoding, draining battery."},
    
    {"text": "Use keyboard shortcuts instead of mouse for common tasks.", "category": "energySaving", "explanation": "Keyboards use less power than optical mice that track movement continuously."},
    {"text": "Reduce mouse polling rate if you're not gaming.", "category": "energySaving", "explanation": "High polling rates use more USB power. Standard rates work fine for office use."},
    {"text": "Disable RGB lighting on gaming peripherals when not gaming.", "category": "energySaving", "explanation": "RGB LEDs can draw several watts continuously. Turning them off saves power."},
    {"text": "Use a smaller external monitor when you don't need a large display.", "category": "energySaving", "explanation": "Smaller screens use proportionally less power than larger ones."},
    {"text": "Turn off second monitors when using only your primary display.", "category": "energySaving", "explanation": "Extra monitors consume power even when showing static content."},
    {"text": "Use picture-in-picture mode instead of running multiple video streams.", "category": "energySaving", "explanation": "Single stream with PIP uses less CPU than multiple simultaneous videos."},
    {"text": "Download videos for offline viewing instead of re-streaming.", "category": "energySaving", "explanation": "One download uses less total energy than multiple streams over time."},
    {"text": "Use lower video quality (480p/720p) when 4K isn't necessary.", "category": "energySaving", "explanation": "Lower resolutions require less bandwidth and CPU decoding power."},
    {"text": "Disable autoplay on YouTube and streaming platforms.", "category": "energySaving", "explanation": "Autoplay causes unnecessary video loading and playback, wasting energy."},
    {"text": "Use audio-only mode for podcasts instead of video podcasts.", "category": "energySaving", "explanation": "Audio files are smaller and require less CPU to decode than video."},
    
    {"text": "Limit refresh rate to 60Hz when high refresh isn't needed.", "category": "energySaving", "explanation": "Higher refresh rates (120Hz+) use significantly more GPU and display power."},
    {"text": "Use e-ink displays for reading when available.", "category": "energySaving", "explanation": "E-ink uses power only when changing pages, not for static display."},
    {"text": "Disable location history tracking when not needed for navigation.", "category": "energySaving", "explanation": "Continuous location logging uses GPS power all day long."},
    {"text": "Use Wi-Fi hotspot from your phone instead of buying separate mobile router.", "category": "energySaving", "explanation": "One device uses less total energy than two separate devices."},
    {"text": "Disable Bluetooth discovery mode when not pairing new devices.", "category": "energySaving", "explanation": "Discovery mode continuously broadcasts, using radio power."},
    {"text": "Use NFC for quick tasks instead of Bluetooth pairing.", "category": "energySaving", "explanation": "NFC uses less power than Bluetooth for simple data transfers."},
    {"text": "Disable shake-to-undo and motion gestures if you don't use them.", "category": "energySaving", "explanation": "Motion sensors continuously monitor movement, using accelerometer power."},
    {"text": "Use manual email fetch instead of push for non-urgent accounts.", "category": "energySaving", "explanation": "Push email maintains constant connections. Manual fetch checks only when you open the app."},
    {"text": "Reduce the number of email accounts synced to your device.", "category": "energySaving", "explanation": "Each account requires separate sync processes and network connections."},
    {"text": "Use aggregator apps instead of running multiple individual apps.", "category": "energySaving", "explanation": "One app uses fewer resources than many apps doing similar tasks."},
    
    {"text": "Disable weather widgets that update frequently.", "category": "energySaving", "explanation": "Constant weather updates require network and CPU activity."},
    {"text": "Use static icons instead of live app badges.", "category": "energySaving", "explanation": "Live badges require apps to run in background to update counts."},
    {"text": "Limit the number of smart home devices connected to your network.", "category": "energySaving", "explanation": "Each IoT device adds to continuous network traffic and router load."},
    {"text": "Use local control for smart home devices instead of cloud control.", "category": "energySaving", "explanation": "Local control eliminates internet round-trips and server processing."},
    {"text": "Turn off smart home devices when on vacation.", "category": "energySaving", "explanation": "Unused smart devices still consume standby power and network resources."},
    {"text": "Use energy monitoring apps to identify power-hungry apps.", "category": "energySaving", "explanation": "Knowing which apps drain battery helps you make informed usage decisions."},
    {"text": "Disable app refresh in background for non-essential apps.", "category": "energySaving", "explanation": "Background refresh keeps apps active even when you're not using them."},
    
    # DEVICE CARE TIPS (71 tips)
    {"text": "Restart your devices weekly to clear memory and improve performance.", "category": "deviceCare", "explanation": "Regular restarts close memory leaks and refresh system processes for better efficiency."},
    {"text": "Keep your device's operating system up to date.", "category": "deviceCare", "explanation": "OS updates include performance improvements and battery optimizations."},
    {"text": "Avoid exposing devices to direct sunlight for extended periods.", "category": "deviceCare", "explanation": "UV exposure and heat can damage screens and degrade internal components."},
    {"text": "Don't use devices in extreme cold temperatures.", "category": "deviceCare", "explanation": "Cold can slow battery chemistry and make screens brittle."},
    {"text": "Allow cold devices to warm up before charging.", "category": "deviceCare", "explanation": "Charging cold batteries can cause internal damage. Let them reach room temperature first."},
    {"text": "Use official or certified chargers to protect battery health.", "category": "deviceCare", "explanation": "Uncertified chargers may deliver incorrect voltage, damaging batteries."},
    {"text": "Avoid using damaged charging cables.", "category": "deviceCare", "explanation": "Frayed cables can short circuit or deliver unstable power, risking device damage."},
    {"text": "Keep connectors clean and free of lint or debris.", "category": "deviceCare", "explanation": "Dirty connectors cause poor charging connections and potential damage."},
    {"text": "Use a soft, lint-free cloth to clean screens.", "category": "deviceCare", "explanation": "Abrasive materials can scratch screens. Microfiber cloths are safest."},
    {"text": "Avoid using harsh chemicals on screens.", "category": "deviceCare", "explanation": "Chemicals can damage oleophobic coatings and screen materials."},
    
    {"text": "Apply screen protectors to prevent scratches.", "category": "deviceCare", "explanation": "Screen protectors are cheaper to replace than entire screens."},
    {"text": "Use tempered glass screen protectors for better protection.", "category": "deviceCare", "explanation": "Glass protectors absorb impact better than plastic films."},
    {"text": "Remove screen protectors when they become scratched or bubbled.", "category": "deviceCare", "explanation": "Damaged protectors reduce visibility and don't protect as effectively."},
    {"text": "Keep devices away from moisture and humidity.", "category": "deviceCare", "explanation": "Moisture can corrode internal components and damage electronics."},
    {"text": "Don't charge devices in humid environments like bathrooms.", "category": "deviceCare", "explanation": "Humidity plus electricity increases corrosion and short-circuit risks."},
    {"text": "If a device gets wet, power it off immediately and let it dry.", "category": "deviceCare", "explanation": "Operating wet electronics can cause short circuits and permanent damage."},
    {"text": "Don't use heat sources to dry wet devices.", "category": "deviceCare", "explanation": "Heat can warp components and damage batteries. Air dry only."},
    {"text": "Use silica gel packets to absorb moisture if device gets wet.", "category": "deviceCare", "explanation": "Silica gel actively draws moisture out more effectively than rice."},
    {"text": "Store devices in a dry, cool place when not in use.", "category": "deviceCare", "explanation": "Proper storage prevents humidity damage and temperature stress."},
    {"text": "Avoid stacking heavy objects on laptops or tablets.", "category": "deviceCare", "explanation": "Pressure can crack screens or damage internal components."},
    
    {"text": "Close laptop lids gently to prevent hinge damage.", "category": "deviceCare", "explanation": "Aggressive closing stresses hinges and can crack screens."},
    {"text": "Lift laptops from the base, not the screen.", "category": "deviceCare", "explanation": "Lifting by the screen stresses hinges and can crack the display."},
    {"text": "Don't carry laptops by their screens when open.", "category": "deviceCare", "explanation": "Screen weight can damage hinges and the screen itself."},
    {"text": "Use both hands when carrying tablets to prevent drops.", "category": "deviceCare", "explanation": "Secure grip prevents expensive accidental drops."},
    {"text": "Keep food and drinks away from devices.", "category": "deviceCare", "explanation": "Spills can destroy electronics instantly. Prevention is key."},
    {"text": "Don't use devices with greasy or wet hands.", "category": "deviceCare", "explanation": "Moisture and oils can damage screens and enter ports."},
    {"text": "Clean keyboard keys gently with compressed air.", "category": "deviceCare", "explanation": "Debris under keys affects typing and can damage mechanisms."},
    {"text": "Avoid eating over keyboards to prevent debris buildup.", "category": "deviceCare", "explanation": "Food particles attract pests and gunk up mechanisms."},
    {"text": "Use keyboard covers for laptops in dusty environments.", "category": "deviceCare", "explanation": "Covers prevent dust and debris from entering sensitive mechanisms."},
    {"text": "Don't force connectors or ports when plugging in cables.", "category": "deviceCare", "explanation": "Forcing can bend pins or crack solder joints inside ports."},
    
    {"text": "Check cable orientation before plugging in to avoid port damage.", "category": "deviceCare", "explanation": "Wrong orientation can bend or break connector pins."},
    {"text": "Support cables near connectors to reduce port stress.", "category": "deviceCare", "explanation": "Dangling cables put mechanical stress on ports over time."},
    {"text": "Unplug cables by gripping the connector, not the wire.", "category": "deviceCare", "explanation": "Pulling on wires can break internal connections in the cable."},
    {"text": "Coil cables loosely to prevent wire damage.", "category": "deviceCare", "explanation": "Tight coiling can break internal wires and damage insulation."},
    {"text": "Avoid running over cables with chair wheels.", "category": "deviceCare", "explanation": "Crushing damages wires and creates short-circuit risks."},
    {"text": "Replace frayed or damaged cables immediately.", "category": "deviceCare", "explanation": "Damaged cables pose fire and shock risks."},
    {"text": "Use cable management to organize and protect wires.", "category": "deviceCare", "explanation": "Organized cables last longer and prevent tripping hazards."},
    {"text": "Don't wrap charging cables tightly around power adapters.", "category": "deviceCare", "explanation": "Tight wrapping stresses cable connections at the adapter joint."},
    {"text": "Store unused cables properly to prevent tangling and damage.", "category": "deviceCare", "explanation": "Tangled cables develop kinks and broken wires."},
    {"text": "Label cables to identify them easily and prevent mix-ups.", "category": "deviceCare", "explanation": "Proper labeling prevents using wrong chargers or cables."},
    
    {"text": "Keep backup of important files on external drives or cloud.", "category": "deviceCare", "explanation": "Backups protect against data loss from device failure."},
    {"text": "Test backups periodically to ensure they work.", "category": "deviceCare", "explanation": "Untested backups may be corrupted or incomplete when you need them."},
    {"text": "Use antivirus software to protect against malware.", "category": "deviceCare", "explanation": "Malware can slow devices and steal data. Protection is essential."},
    {"text": "Avoid clicking suspicious links or downloading unknown files.", "category": "deviceCare", "explanation": "Malicious files can damage systems or steal information."},
    {"text": "Keep your browser updated to patch security vulnerabilities.", "category": "deviceCare", "explanation": "Browser updates close security holes that attackers exploit."},
    {"text": "Use strong, unique passwords for device accounts.", "category": "deviceCare", "explanation": "Strong passwords protect against unauthorized access and data theft."},
    {"text": "Enable two-factor authentication for important accounts.", "category": "deviceCare", "explanation": "2FA adds extra security layer beyond just passwords."},
    {"text": "Lock your devices when stepping away from them.", "category": "deviceCare", "explanation": "Locking prevents unauthorized access to your data."},
    {"text": "Enable find my device features for theft recovery.", "category": "deviceCare", "explanation": "Tracking features help locate lost devices and protect data."},
    {"text": "Encrypt sensitive data stored on devices.", "category": "deviceCare", "explanation": "Encryption protects data if device is lost or stolen."},
    
    {"text": "Disable unused features to reduce attack surface.", "category": "deviceCare", "explanation": "Fewer active services mean fewer potential security vulnerabilities."},
    {"text": "Review app permissions and revoke unnecessary access.", "category": "deviceCare", "explanation": "Apps often request more permissions than needed. Limiting access improves security."},
    {"text": "Uninstall apps you no longer use.", "category": "deviceCare", "explanation": "Unused apps consume storage and may have security vulnerabilities."},
    {"text": "Keep minimum number of apps installed for better performance.", "category": "deviceCare", "explanation": "Fewer apps mean less storage use and faster system performance."},
    {"text": "Monitor storage space and keep at least 10% free.", "category": "deviceCare", "explanation": "Low storage slows devices. Free space allows efficient operation."},
    {"text": "Clear app caches regularly to free up storage.", "category": "deviceCare", "explanation": "Cached data accumulates over time, consuming valuable storage."},
    {"text": "Organize files into folders for easier management.", "category": "deviceCare", "explanation": "Organization makes finding files easier and helps identify what to delete."},
    {"text": "Delete duplicate photos and videos to save storage.", "category": "deviceCare", "explanation": "Duplicates waste storage space without adding value."},
    {"text": "Compress large files before storing or sharing.", "category": "deviceCare", "explanation": "Compression reduces storage use and transfer times."},
    {"text": "Use cloud storage for files you don't need locally.", "category": "deviceCare", "explanation": "Offloading to cloud frees device storage while keeping files accessible."},
    
    {"text": "Defragment traditional hard drives annually.", "category": "deviceCare", "explanation": "Fragmentation slows HDDs. Defragging organizes data for faster access."},
    {"text": "Don't defragment SSDs - it reduces their lifespan.", "category": "deviceCare", "explanation": "SSDs don't need defragging and it wastes write cycles unnecessarily."},
    {"text": "Enable TRIM for SSDs to maintain performance.", "category": "deviceCare", "explanation": "TRIM helps SSDs manage deleted data efficiently for sustained speed."},
    {"text": "Check drive health regularly with diagnostic tools.", "category": "deviceCare", "explanation": "Early warning of drive failure allows backup before data loss."},
    {"text": "Safely eject external drives before unplugging.", "category": "deviceCare", "explanation": "Proper ejection prevents data corruption and drive damage."},
    {"text": "Don't move laptops while hard drives are spinning.", "category": "deviceCare", "explanation": "Movement can cause HDD head crashes and permanent damage."},
    {"text": "Use a laptop cooling pad if device runs hot.", "category": "deviceCare", "explanation": "Extra cooling extends component life and prevents thermal throttling."},
    {"text": "Keep firmware updated on peripherals and accessories.", "category": "deviceCare", "explanation": "Firmware updates fix bugs and improve compatibility."},
    {"text": "Calibrate touch screens if they become unresponsive.", "category": "deviceCare", "explanation": "Calibration fixes drift and improves touch accuracy."},
    {"text": "Reset devices to factory settings if they become very slow.", "category": "deviceCare", "explanation": "Fresh start eliminates software bloat and corruption."},
    {"text": "Backup data before performing factory resets.", "category": "deviceCare", "explanation": "Factory reset erases everything. Backups prevent data loss."},
    
    # DISPOSAL TIPS (31 tips)
    {"text": "Donate old devices to schools or nonprofits instead of discarding.", "category": "disposal", "explanation": "Working devices help underserved communities and avoid e-waste."},
    {"text": "Check manufacturer take-back programs before recycling.", "category": "disposal", "explanation": "Manufacturers often offer free recycling and may provide credit."},
    {"text": "Remove personal data multiple times before disposal.", "category": "disposal", "explanation": "Single wipes can be recovered. Multiple passes ensure data security."},
    {"text": "Destroy storage media physically if it contained sensitive data.", "category": "disposal", "explanation": "Physical destruction prevents any possibility of data recovery."},
    {"text": "Don't throw broken devices in regular trash.", "category": "disposal", "explanation": "Electronics contain toxic materials requiring special handling."},
    {"text": "Find local e-waste collection events in your community.", "category": "disposal", "explanation": "Collection events make proper disposal convenient and free."},
    {"text": "Contact your city's waste management for e-waste disposal options.", "category": "disposal", "explanation": "Many cities offer dedicated e-waste pickup or drop-off."},
    {"text": "Return old devices to retailers that offer trade-in programs.", "category": "disposal", "explanation": "Trade-ins give devices second life and may earn you credit."},
    {"text": "Separate batteries from devices before recycling.", "category": "disposal", "explanation": "Batteries require different recycling processes than electronics."},
    {"text": "Don't incinerate electronic waste.", "category": "disposal", "explanation": "Burning electronics releases toxic fumes and heavy metals."},
    
    {"text": "Keep original packaging for easier returns and resale.", "category": "disposal", "explanation": "Original boxes increase resale value and protect during shipping."},
    {"text": "Research resale value before assuming device is worthless.", "category": "disposal", "explanation": "Even old devices have value for parts or collectors."},
    {"text": "Sell working devices on reputable secondhand marketplaces.", "category": "disposal", "explanation": "Resale extends device life and reduces manufacturing demand."},
    {"text": "Include original accessories when selling devices.", "category": "disposal", "explanation": "Complete sets fetch higher prices and are more useful to buyers."},
    {"text": "Clean devices thoroughly before selling or donating.", "category": "disposal", "explanation": "Clean devices are more appealing and show you cared for them."},
    {"text": "Be honest about device condition when selling.", "category": "disposal", "explanation": "Honesty prevents disputes and builds trust with buyers."},
    {"text": "Take clear photos for online listings of devices for sale.", "category": "disposal", "explanation": "Good photos increase buyer confidence and sale prices."},
    {"text": "Test devices before selling to ensure they work.", "category": "disposal", "explanation": "Verifying functionality prevents issues for buyers."},
    {"text": "Disable activation locks before selling smartphones.", "category": "disposal", "explanation": "Locked devices are unusable to buyers and may be disputed."},
    {"text": "Remove SIM cards and memory cards before disposal.", "category": "disposal", "explanation": "Cards contain personal data and are reusable in new devices."},
    
    {"text": "Recycle printer cartridges at office supply stores.", "category": "disposal", "explanation": "Cartridge recycling programs often provide rewards or discounts."},
    {"text": "Don't dispose of CDs or DVDs in regular recycling.", "category": "disposal", "explanation": "Optical media require specialized recycling due to composition."},
    {"text": "Properly recycle old chargers and cables separately.", "category": "disposal", "explanation": "Cables contain copper that can be recovered through recycling."},
    {"text": "Return broken devices to manufacturer for responsible recycling.", "category": "disposal", "explanation": "Manufacturers can recycle proprietary components more effectively."},
    {"text": "Check if your workplace has e-waste recycling programs.", "category": "disposal", "explanation": "Corporate programs often handle large volumes efficiently."},
    {"text": "Educate family members about proper e-waste disposal.", "category": "disposal", "explanation": "Household awareness prevents improper disposal of electronics."},
    {"text": "Keep a dedicated box for e-waste until you can recycle it.", "category": "disposal", "explanation": "Collecting items prevents them from being thrown in trash."},
    {"text": "Don't hoard broken devices - recycle them promptly.", "category": "disposal", "explanation": "Timely recycling recovers materials before they degrade."},
    {"text": "Support right-to-repair legislation in your area.", "category": "disposal", "explanation": "Right-to-repair extends device life and reduces e-waste."},
    {"text": "Participate in community electronics swap events.", "category": "disposal", "explanation": "Swapping extends device life and builds community connections."},
    {"text": "Document device disposal for tax deductions if donating.", "category": "disposal", "explanation": "Charitable donations of electronics may be tax-deductible."},
    
    # ECO-BUYING TIPS (14 tips)
    {"text": "Buy devices with long manufacturer support commitments.", "category": "ecoBuying", "explanation": "Longer support means more years of updates before obsolescence."},
    {"text": "Choose products with eco-certifications like EPEAT or Energy Star.", "category": "ecoBuying", "explanation": "Certifications verify environmental claims and efficiency standards."},
    {"text": "Research company sustainability practices before purchasing.", "category": "ecoBuying", "explanation": "Supporting eco-conscious companies drives industry-wide change."},
    {"text": "Buy local when possible to reduce shipping emissions.", "category": "ecoBuying", "explanation": "Local purchases minimize transportation environmental impact."},
    {"text": "Choose products made from recycled materials.", "category": "ecoBuying", "explanation": "Recycled materials reduce mining and raw resource extraction."},
    {"text": "Avoid products with excessive packaging.", "category": "ecoBuying", "explanation": "Minimal packaging reduces waste and material consumption."},
    {"text": "Buy multi-functional devices instead of specialized single-use ones.", "category": "ecoBuying", "explanation": "One versatile device replaces several, reducing total manufacturing."},
    {"text": "Choose devices with standard replaceable parts.", "category": "ecoBuying", "explanation": "Replaceable parts extend life and reduce full device replacement."},
    {"text": "Buy quality over quantity - invest in durable devices.", "category": "ecoBuying", "explanation": "Well-made devices last longer, reducing replacement frequency."},
    {"text": "Consider renting or leasing for short-term needs.", "category": "ecoBuying", "explanation": "Temporary use doesn't require permanent ownership."},
    
    {"text": "Wait for genuine needs before buying new technology.", "category": "ecoBuying", "explanation": "Avoiding impulse purchases reduces unnecessary consumption."},
    {"text": "Research longevity and reliability before purchasing.", "category": "ecoBuying", "explanation": "Reliable devices avoid premature failure and replacement."},
    {"text": "Check warranty length and coverage before buying.", "category": "ecoBuying", "explanation": "Good warranties indicate manufacturer confidence and support."},
    {"text": "Support companies with take-back and recycling programs.", "category": "ecoBuying", "explanation": "Producer responsibility ensures end-of-life device handling."},
]

# Generate tips t173-t365
tip_id_counter = 173
base_date = datetime(2025, 6, 20)

for i, tip_data in enumerate(new_tips_data):
    tip_id = f"t{tip_id_counter:03d}"
    created_at = (base_date + timedelta(days=i)).isoformat() + "Z"
    
    new_tip = {
        "id": tip_id,
        "text": tip_data["text"],
        "category": tip_data["category"],
        "explanation": tip_data["explanation"],
        "createdAt": created_at,
        "source": "AI-Generated"
    }
    
    tips.append(new_tip)
    tip_id_counter += 1

print(f"Generated {len(new_tips_data)} new AI tips")
print(f"Total tips now: {len(tips)}")

# Verify category distribution
categories = {}
for tip in tips:
    cat = tip['category']
    categories[cat] = categories.get(cat, 0) + 1

print("\nCategory distribution:")
for cat, count in sorted(categories.items()):
    percentage = (count / len(tips)) * 100
    print(f"  {cat}: {count} tips ({percentage:.1f}%)")

# Write updated tips
with open('assets/data/tips.json', 'w', encoding='utf-8') as f:
    json.dump(tips, f, indent=2, ensure_ascii=False)

print(f"\n✅ Successfully created {len(tips)} total tips!")
print(f"   - t001-t120: AI-Generated (original)")
print(f"   - t121-t172: Verified sources")
print(f"   - t173-t{len(tips):03d}: AI-Generated (new)")
