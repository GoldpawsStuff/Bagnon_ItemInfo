# Bagnon_ItemInfo Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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
