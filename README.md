# Zad Al-Muslim - (زاد المسلم)

*By Ammar Ismail*


## App features
* Show prayer times with local notifications using location and astronimical calculations instead of API.
* Show Hiri date and other information like Ramadan or other Islamic events.
* Morning/Night azkar + other azkar/duas like after prayer azkar, quran duas, etc..
* Show duas based on mood like specific duas for feeling sad, injustice, depressed, etc..
* Different prayer guides like how to pray in janazah, Isitkhara, etc..

## TODO
* Convert page transitions to open containers and hero tags.
* Check why navigating back to main page redirects to home (might go if I switch page transitions like step above. Also, this behaviour happens only on newer android that have predictive pop).
* Add ratings, app share, and github redirect pages.
* Enhance developer page and add text animations.
* Maybe add buy me coffee page.

## Likely bugs

1. The Riyadh default can drive real notifications. If location is off, denied, or GPS fails on first launch, state still holds Riyadh and "السعودية" (Umm al-Qura). The listener treats any status other than initial or loading as settled. The toggles also pass whatever coordinates are in state. A user in Cairo can therefore get 7 days of Riyadh-time alarms with no hint. Wrong prayer times are worse than none. Add a LocationSource { cache, gps, fallbackDefault } to state and skip scheduling when it's fallbackDefault. Show a banner or a manual city picker instead.