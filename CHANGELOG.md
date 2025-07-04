# Bagnon ItemLevel Plus Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [2.2.87-Release] 2025-06-18
- Updated for Retail client patch 11.1.7.
- Updated for Classic Era client patch 1.15.7.

## [2.2.86-Release] 2025-04-02
### Fixed
- I might have missed a line in the previous update, and nobody told me. 

## [2.2.85-Release] 2025-03-08
- Updated for WoW Classic Era Client Patch 1.15.6.
- Updated for WoW Retail Client Patch 11.1.0.

## [2.2.84-Release] 2024-09-02
### Fixed
- Fixed a bug related to using the deprecated library LibItemCache-2.0.

## [2.2.83-Release] 2024-08-18
- Updated for WoW Retail Client Patch 11.0.2.

## [2.2.82-Release] 2024-07-10
- Updated for WoW Classic Client Patch 1.15.3.

## [2.2.81-Release] 2024-06-28
- Updated for WoW Retail Client Patch 10.2.7.

## [2.2.80-Release] 2024-04-17
### Added
- Added the option to set the minimum displayed item level from 1 to 60, with 11 being the default.

## [2.2.79-Release] 2024-04-03
- Updated for WoW Client Patch 1.15.2.

## [2.2.78-Release] 2024-03-26
### Changed
- Uncommon rarity coloring should be a bit brighter and easier to spot now.

### Fixed
- The issue in retail where all items would get their itemlevel displayed has been fixed. We're bag to mostly showing equipable gear, battle pets and container slots again.

## [2.2.77-Release] 2024-03-22
- Updated for WoW Client Patch 10.2.6.
- Updated for WoW Client Patch 4.4.0.

## [2.2.76-Release] 2024-02-07
- Updated for WoW Client Patch 1.15.1.

## [2.2.75-Release] 2024-02-02
### Fixed
- Fixed an issue where `GetItemInfo` would cause a bug when called early in the loading process.
- Removed remnant debug output of BoE items in bags from last build. Too little coffee. Sowwy!

## [2.2.74-Release] 2024-02-01
### Fixed
- Fixed an issue where BoE labels would show even for already soulbound items when they were placed in the main bank container in Classic Era.

## [2.2.73-Release] 2024-01-17
- Updated for WoW Client Patch 10.2.5.

## [2.2.71-Release] 2024-01-13
### Fixed
- Fixed an issue that caused a bunch of bugs on logon, especially in Wrath and Classic.

## [2.2.70-Release] 2023-12-15
### Added
- Added our options menu to the blizzard interface options addons menu.
- Added the chat command `/bil` to directly open options menu. This does not conflict with the same chat command in the addon Bagnon ItemLevel, as that one simply does not load when this one is enabled.

### Changed
- Rebranded the addon and its option menu entries to **Bagnon ItemLevel Plus** as this better indicates what it does. The old name "ItemInfo" was simply too generic and undescriptive. The title alone should give a good indication of what an addon does.

### Removed
- Fully removed the old system to configure it through chat commands. The command remains, but now only and always opens the options menu window.

## [2.1.69-Release] 2023-11-17
- Updated for WoW Client Patch 1.15.0.

## [2.1.68-Release] 2023-11-07
- Updated for WoW Client Patch 10.2.0.

## [2.1.67-Release] 2023-11-01
### Changed
- Some minor performance tweaks. Everything matters!
- Made the BoE/BoU labels brighter for poor and common quality items.

## [2.1.66-Release] 2023-10-26
### Fixed
- All item qualities including poor and common will now display the BoE label when appropriate in Retail.

## [2.1.65-Release] 2023-10-25
### Added
- Added settings for garbage desaturation and darkening to the new `/bif` menu. This setting is currently not available through chat commands.

### Fixed
- Garbage desaturation should now properly function again.

## [2.1.64-Release] 2023-10-23
### Fixed
- AceLocale should now properly be embedded in the addon, which I forgot in the previous update thus breaking the whole thing. You guys don't feed me enough, my concentration is failing!

## [2.1.63-Release] 2023-10-22
### Added
- Added a a graphical options menu accessible by typing `/bif` with no arguments.

## [2.0.62-Release] 2023-10-11
- Updated for WoW Client Patch 3.4.3.

## [2.0.61-Release] 2023-09-19
- Added TaintLess.xml.

## [2.0.60-Release] 2023-09-06
- Updated for Retail client patch 10.1.7.

## [2.0.59-Release] 2023-08-30
### Fixed
- Garbage desaturation and darkening should be more consistent now and not "get stuck" anymore.

## [2.0.58-Release] 2023-08-24
- Updated for Classic client patch 1.14.4.

## [2.0.57-Release] 2023-07-25
### Fixed
- Fixed issues occurring with item caches resulting in missing item levels with Bagnon 10.1.3 and higher.

## [2.0.56-Release] 2023-07-22
### Changed
- Updated addon listing icon and text format.

## [2.0.55-Release] 2023-07-12
- Bumped to Retail Client Patch 10.1.5.

## [2.0.54-Release] 2023-06-21
- Bumped to Wrath Classic Client Patch 3.4.2.

## [2.0.53-Release] 2023-05-21
- Cosmetic stuff. Piggybacking.

## [2.0.52-Release] 2023-05-10
- Updated for Bagnon's API for WoW 10.1.0.

## [2.0.51-Release] 2023-05-03
- Updated for WoW 10.1.0.

## [2.0.50-Release] 2023-03-25
- Updated for WoW 10.0.7.

## [2.0.49-Release] 2023-02-28
### Changed
- The Wrath version should take better advantage of blizzard's 10.0.2 bag API which was ported to Wrath in 3.4.1 now.

## [2.0.48-Release] 2023-01-26
- Updated for WoW 10.0.5.

## [2.0.47-Release] 2023-01-18
- Updated for WoW 3.4.1.

## [2.0.46-Release] 2022-12-11
### Fixed
- Changed how bagID is queried to be more consistent across Bagnon updates and versions. A lot of C_Tooltip API errors and general Bagnon lag should be fixed by this.

## [2.0.45-Release] 2022-12-08
### Fixed
- Fixed an issue in retail with items that had less tooltipData than expected.

## [2.0.44-Release] 2022-11-25
### Changed
- Now only uses the old tooltip scanning in the classic versions of WoW.
- Now utilizes the C_TooltipInfo and TooltipUtil APIs in retail. Which will rock when Bagnon is updated for 10.0.2!

## [2.0.43-Release] 2022-11-16
- Bump to retail client patch 10.0.2.

## [2.0.42-Release] 2022-11-02
- Add support for retail 10.0.2 C_Container API.

## [2.0.41-Release] 2022-10-25
- Bumped retail version to the 10.0.0 patch.

## [2.0.40-Release] 2022-10-13
### Fixed
- Fixed an issue where the wrong bag slot would be queried, resulting in wrong information on the items.

## [2.0.39-Release] 2022-10-12
### Fixed
- The transmog collection module is no longer loaded in classics where it is not supported.
- The chat commands are once again in place and works.

## [2.0.37-Release] 2022-10-12
### Fixed
- Itemlevels are now once more only shown for actual gear.

## [2.0.36-RC] 2022-10-12
- Full performance rewrite to take much better advantage of Bagnon and Wildpant's APIs.

## [1.0.35-Release] 2022-08-17
- Bump to client patch 9.2.7.

## [1.0.34-Release] 2022-07-29
### Fixed
- Improved the client detection code.

## [1.0.33-Release] 2022-07-28
### Fixed
- Fixed an issue in WotLK Classic that sometimes could cause already bound items to still show the bind status.

## [1.0.32-Release] 2022-07-21
- Add support for WotLK Classic beta.

## [1.0.31-Release] 2022-07-09
- Bump for Classic Era client patch 1.14.3.

## [1.0.30-Release] 2022-06-14
### Changed
- Some untested performance updates.

## [1.0.29-Release] 2022-05-31
- Bump toc to WoW client patch 9.2.5.

## [1.0.28-Release] 2022-04-07
- Bump for BCC client patch 2.5.4.

## [1.0.27-Release] 2022-02-26
### Fixed
- Reintroduce tooltip scanning for soulbound status to fix itembind problems in the classics. [#6](https://github.com/GoldpawsStuff/Bagnon_BoE/issues/6)

## [1.0.26-Release] 2022-02-23
- ToC bump.

## [1.0.25-Release] 2022-02-16
- ToC bumps and license update.

## [1.0.24-Release] 2022-02-06
### Fixed
- Fixed an issue where bind status would not be properly updated when equipping items.

## [1.0.23-Release] 2021-12-13
### Fixed
- Fixed an issue where we attempted to check for rarity color before checking if we had a valid rarity to begin with.

## [1.0.22-Release] 2021-12-12
- Added BCC and Classic Era versions of the addon.

### Added
- Added commands to toggle between rarity colored text, and a much clearer white.

### Changed
- Added a message when the presence of the addon Bagnon ItemInfo causes this one to be auto-disabled.

## [1.0.21-Release] 2021-11-03
- Bump toc for 9.1.5.

## [1.0.20-Release] 2021-06-29
- Bump toc for 9.1.0.

## [1.0.19-Release] 2021-04-05
- Spring cleaning.

## [1.0.18-Release] 2021-03-10
- Bump to WoW client patch 9.0.5.

## [1.0.17-Release] 2020-11-18
- Bump to WoW Client patch 9.0.2.

## [1.0.16-Release] 2020-10-16
- Bump to WoW Client patch 9.0.1.

## [1.0.15-Release] 2020-09-25
- Cache fixes and Bagnon 9.x compatibility.

## [1.0.14-Release] 2020-08-07
### Changed
- ToC updates.

## [1.0.13-Release] 2020-01-13
### Fixed
- Fixed for Bagnon 8.2.29. Junk icons are working correctly now.

## [1.0.12-Release] 2020-01-09
### Fixed
- Fixed for Bagnon 8.2.27, December 26th 2019.

## [1.0.11-Release] 2019-10-08
- ToC updates.

## [1.0.10-Release] 2019-10-08
- Bump to WoW Client patch 8.2.5.
- Fix toc links.

## [1.0.9-Release] 2019-07-02
### Changed
- Updated for 8.2.0.

## [1.0.8-Release] 2019-04-29
### Fixed
- Changed how bag slot count is captured to be compatible with deDE.

## [1.0.7-Release] 2019-03-29
### Changed
- Updated toc display name to be in line with the main bagnon addon.
- Updated description links and team name.

## [1.0.6-Release] 2019-03-01
### Added
- Added chat commands to toggle the individual elements, since some don't want all four, but maybe just two or three.

## [1.0.5-Release] 2019-02-28
### Fixed
- Switched to tooltip scanning using global strings to avoid false positives on uncollected appearances.

## [1.0.4-Release] 2019-02-28
### Fixed
- Fixed an issue that sometimes could cause an "ambigous syntax" error.

## [1.0.3-Release] 2019-02-28
### Added
- Added a purple eye to indicate items with uncollected transmog appearances.

## [1.0.2-Release] 2019-02-27
### Fixed
- Item background scanning should once more update properly when you swap items in a bag slot, and not show the item level and bind status of the item that was previously there.

## [1.0.1-Release] 2019-02-27
### Fixed
- Fixed bug when showing BoE/BoU items.

## [1.0.0-Release] 2019-02-27
- Initial commit.
