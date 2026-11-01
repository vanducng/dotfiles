# Changelog

## [0.38.0](https://github.com/vanducng/dotfiles/compare/v0.37.0...v0.38.0) (2026-11-01)


### Features

* **rexboard:** model aliases, so one model reads one way on the board ([5083b86](https://github.com/vanducng/dotfiles/commit/5083b86b07c4958c96bfbffd936175c87870bb85))
* **rex:** cut the layout to the cockpit with pi as tab 3 ([8e554ed](https://github.com/vanducng/dotfiles/commit/8e554ede1ce26e65e508ce8fea8a6ee72172429c))
* **tmux:** forward OSC 8 hyperlinks for xterm-rex clients ([5c23749](https://github.com/vanducng/dotfiles/commit/5c2374945671d131cdb08a1444d93261e1f14bfe))


### Bug Fixes

* **zsh:** keep mise shims ahead of Homebrew in login and interactive shells ([#274](https://github.com/vanducng/dotfiles/issues/274)) ([08e42ec](https://github.com/vanducng/dotfiles/commit/08e42ec9aaabc45b01d38f1ccd3097aff39a68b5))

## [0.37.0](https://github.com/vanducng/dotfiles/compare/v0.36.0...v0.37.0) (2026-10-31)


### Features

* align CLI Proxy setup across hosts and converge on sync ([#272](https://github.com/vanducng/dotfiles/issues/272)) ([60dd3c0](https://github.com/vanducng/dotfiles/commit/60dd3c080fa765e7032c0c70e9b019dd43e7f035))
* **gopass:** sync stores every 6 hours ([81c3a67](https://github.com/vanducng/dotfiles/commit/81c3a67a407536ef681a0719f390e362959ed099))
* **mise:** put mise shims ahead of system tools and trust the workspace checkout ([#273](https://github.com/vanducng/dotfiles/issues/273)) ([cad09b1](https://github.com/vanducng/dotfiles/commit/cad09b1d4921051088f22b0bcb54d97bc586fd14))
* **pi:** lead the footer and title with the OpenRig seat name ([d68a9fa](https://github.com/vanducng/dotfiles/commit/d68a9fa7b8428c998c75de5b192142c598ed780c))
* **pi:** name the cli-proxy provider cpa, add Sonnet 5.5, Haiku 5.5 and Terra ([5f406ca](https://github.com/vanducng/dotfiles/commit/5f406caed6fc83103b35f99625de1a90d7a89be7))
* **rexboard:** drop the openrig extension's role column, which repeats the block label ([6ab6f6b](https://github.com/vanducng/dotfiles/commit/6ab6f6bb0e673c1594b0df12597f5fba284f77cb))
* **rexboard:** send a message to the OpenRig seat in a row ([#270](https://github.com/vanducng/dotfiles/issues/270)) ([f567e6e](https://github.com/vanducng/dotfiles/commit/f567e6ed45793793da239cc4fe19ffd65162b70d))
* **rexboard:** show the openrig extension's PROJECT before RIG ([a214973](https://github.com/vanducng/dotfiles/commit/a214973fe8275f056a97916270db3bc18af4f0f2))
* **rexboard:** sign the board's sends as captain@global, seats keep their own name ([#271](https://github.com/vanducng/dotfiles/issues/271)) ([8e22557](https://github.com/vanducng/dotfiles/commit/8e22557f4dccf73adc118b0ca3af9502b5d5d0ce))


### Bug Fixes

* **mise:** install node and python as glibc builds on Linux ([e352e61](https://github.com/vanducng/dotfiles/commit/e352e6146f9edcbe2b46847613f681cb779685ea))
* **mise:** match only the node daemon process in the restart check ([2cf50a7](https://github.com/vanducng/dotfiles/commit/2cf50a7146bd9c8b75d4f6881d7a0388b9428ffe))
* **mise:** pin exact tool versions across hosts ([19ab212](https://github.com/vanducng/dotfiles/commit/19ab2123ff61cba376a0a568872fd3ae55cd2c49))
* **mise:** repoint every OpenRig node path to the pinned node ([0d33908](https://github.com/vanducng/dotfiles/commit/0d3390808ee8ae2b39599026741950323516cdcd))
* **rexboard:** run rexboard from ~/.local/bin or Homebrew in the Codex and Claude hooks, so they work on Linux ([bab0be2](https://github.com/vanducng/dotfiles/commit/bab0be27aa01f6a4bc6dd7e3f39a6dc5aa6b36c3))
* **tmux:** fit OpenRig tiles to the view in use, even with several views on one seat ([ccbb189](https://github.com/vanducng/dotfiles/commit/ccbb18943087b0cf51fa432d4960da4cd206f9b3))
* **tmux:** send extended keys as CSI-u; drop Pi exclusions for removed ClaudeKit skills ([afd396b](https://github.com/vanducng/dotfiles/commit/afd396b8a3a821e516b82064b6c85f8b11f2a8c0))

## [0.36.0](https://github.com/vanducng/dotfiles/compare/v0.35.1...v0.36.0) (2026-10-30)


### Features

* **bin:** track vd-skills-sync and prune links to removed skills ([dbfea78](https://github.com/vanducng/dotfiles/commit/dbfea783078e30c32e2eb8791f6660dc33f51219))
* **cnb-openvpn:** route a machine-local split list over the tunnel ([e1bce39](https://github.com/vanducng/dotfiles/commit/e1bce3966c44b95f7e6b314ce90440e8e1dfda88))
* **homelab:** run BrowserOS neo instead of BrowserOS ([247a298](https://github.com/vanducng/dotfiles/commit/247a298a0c24aa274cfbdd41e9b1bf308f13484d))
* **pi:** use the hardware cursor and drop the codex-fast extensions ([7b818f9](https://github.com/vanducng/dotfiles/commit/7b818f903587edaa22cda721db2e0738c0e67014))


### Bug Fixes

* **gopass:** restore the config.local include so each host keeps its own store mount ([2eae563](https://github.com/vanducng/dotfiles/commit/2eae563bdb9b9cceca96b036abf51347d848a7d1))
* **homelab:** reach the CNB bastion over the OpenVPN tunnel ([8e54316](https://github.com/vanducng/dotfiles/commit/8e543160655544968ffc33a6017a836384594252))

## [0.35.1](https://github.com/vanducng/dotfiles/compare/v0.35.0...v0.35.1) (2026-10-30)


### Bug Fixes

* **docs:** focus the search input even when Pagefind mounts late ([#266](https://github.com/vanducng/dotfiles/issues/266)) ([a299f86](https://github.com/vanducng/dotfiles/commit/a299f86f6fc354f6d790c66a22a8825366925d69))
* **docs:** focus the search input when the dialog itself holds focus ([#267](https://github.com/vanducng/dotfiles/issues/267)) ([c067ea0](https://github.com/vanducng/dotfiles/commit/c067ea08258e5c703eea5a945b899358cec2f966))
* **macos-deps:** make runnable from make setup ([5bb08c3](https://github.com/vanducng/dotfiles/commit/5bb08c32f75890c785db50913612d155c8c058e5))
* **pi:** dropped legacy auth key from Structured MCP entry ([234ef08](https://github.com/vanducng/dotfiles/commit/234ef08dafa8214c8f776421084dc63bdf5be592))
* **stow:** back up conflicting files and restow atomically ([f51af9e](https://github.com/vanducng/dotfiles/commit/f51af9ed4b837393dfd29fd594b1066b75d18801))
* **tmux:** size a lone ignore-size tile's window to the tile ([c4fa612](https://github.com/vanducng/dotfiles/commit/c4fa6125516f354dda5bcb4ece554fafcbd745f5))
* **zsh:** put Homebrew first on PATH for pi ([5fad051](https://github.com/vanducng/dotfiles/commit/5fad051be0bee2fc4b060f2b6830db1301223fc3))

## [0.35.0](https://github.com/vanducng/dotfiles/compare/v0.34.0...v0.35.0) (2026-10-28)


### Features

* **cpq:** fall back to 1Password for the management key ([b597add](https://github.com/vanducng/dotfiles/commit/b597adde5d5e3e9c2d518e0c6a6763baa99908a4))
* **rex:** add linux-01 host, Linux personal server setup, ctrl-alt-3 host jump ([efc5a3e](https://github.com/vanducng/dotfiles/commit/efc5a3eb60a6177b5bbd46f0a4f0f88d7e797baa))
* **rexboard:** an OpenRig extension and a Caps+B board key ([#259](https://github.com/vanducng/dotfiles/issues/259)) ([ac11b52](https://github.com/vanducng/dotfiles/commit/ac11b52550c472190487d27e51a809c3f4e60d95))
* **rex:** floating project picker and centered popups ([ad7f7bc](https://github.com/vanducng/dotfiles/commit/ad7f7bc63a877da98e6485e06045547d114434a6))
* **rex:** hooks through rexboard hook and hooks install, with a fail-open shim ([5539fc4](https://github.com/vanducng/dotfiles/commit/5539fc48e39afa6210efe39c0d719b8268fc0b1a))
* **rex:** name agent panes and simplify shell titles ([1bec4ed](https://github.com/vanducng/dotfiles/commit/1bec4eda38e7d21a5ac4e54880c7341cdd50fea0))
* **rex:** send the agent's own words to Rex, and report Codex and pi ([#256](https://github.com/vanducng/dotfiles/issues/256)) ([5b96cb5](https://github.com/vanducng/dotfiles/commit/5b96cb520c971fb6526fdc084ca66315a0147353))
* **shell-linux:** load atuin aliases without a key, prefer musl mise binaries ([34a32a4](https://github.com/vanducng/dotfiles/commit/34a32a48b755e8433cb0e9cda6d45522b89de9bb))
* **shell-linux:** replace gws with gog 0.39.1 in mise ([b7848a1](https://github.com/vanducng/dotfiles/commit/b7848a193bf9e4e986bf7e062c0ffb62f18aed9a))
* **skhd:** meh+3 opens linux-01 over Jump Desktop ([734d6da](https://github.com/vanducng/dotfiles/commit/734d6dacf3473c95693856554a4c03e55419408d))
* **zsh:** put Homebrew and ~/.local/bin on PATH in .zshenv for Moshi SSH probes ([c3cac43](https://github.com/vanducng/dotfiles/commit/c3cac430ef0e2e46920935279392827b3ec888fa))


### Bug Fixes

* **cpq:** handle Claude windows without a reset time ([9d61183](https://github.com/vanducng/dotfiles/commit/9d61183f4b9bf1bbd6bac21a6ace7c913665578c))
* **rex:** find rexboard wherever it is installed ([#252](https://github.com/vanducng/dotfiles/issues/252)) ([08e75a4](https://github.com/vanducng/dotfiles/commit/08e75a4ef9454bc0195651c486f78abe61a3c6d4))
* **rex:** keep pi's final report in print mode ([#258](https://github.com/vanducng/dotfiles/issues/258)) ([5066dd5](https://github.com/vanducng/dotfiles/commit/5066dd5e4d5167a3b2223aaa69474fb5728ef1b1))
* **rex:** merge the rex hooks into the live Claude settings ([#255](https://github.com/vanducng/dotfiles/issues/255)) ([2107adf](https://github.com/vanducng/dotfiles/commit/2107adfe043732cb7351838537e15e7e542f65d3))
* **rex:** open copy mode read-only so a stray key cannot edit the capture ([#260](https://github.com/vanducng/dotfiles/issues/260)) ([57b8688](https://github.com/vanducng/dotfiles/commit/57b868836c5fa21ef64d2fcb4ec0d053d4337d5b))
* **rex:** report status from tmux seats started without TMUX ([#254](https://github.com/vanducng/dotfiles/issues/254)) ([1993c6c](https://github.com/vanducng/dotfiles/commit/1993c6c3c8547a0f6788da9f2f32d377eda9f97a))
* **rex:** stopped competing pane title updates ([#263](https://github.com/vanducng/dotfiles/issues/263)) ([bd95cc4](https://github.com/vanducng/dotfiles/commit/bd95cc46b343bbd504930e9951080c9347a145fa))
* **tmux:** only force arm64 default-command on macOS ([ee54692](https://github.com/vanducng/dotfiles/commit/ee54692c2476704a1f1a9e17f18f536c6a3b7e9d))

## [0.34.0](https://github.com/vanducng/dotfiles/compare/v0.33.0...v0.34.0) (2026-10-26)


### Features

* **rex:** cockpit session with foreman tab, and clipboard image paste to remote panes ([#250](https://github.com/vanducng/dotfiles/issues/250)) ([b4d1d77](https://github.com/vanducng/dotfiles/commit/b4d1d7726bc2876b29d7999648187a9b0af9a129))
* **rex:** lay out the fixed Rex sessions and number the rest after them ([#249](https://github.com/vanducng/dotfiles/issues/249)) ([0cbb788](https://github.com/vanducng/dotfiles/commit/0cbb788b9d48847bad60db37cb2927e562eb2fd4))
* **rex:** move the focused pane with alt+shift+arrows ([#251](https://github.com/vanducng/dotfiles/issues/251)) ([bc24cac](https://github.com/vanducng/dotfiles/commit/bc24cacd36960de8600aa7ffd132cde494ce4ea2))
* **rex:** rexboard keys, board window tiling and jump.pre_cmd ([#246](https://github.com/vanducng/dotfiles/issues/246)) ([745394e](https://github.com/vanducng/dotfiles/commit/745394e8b0e7bf50a88a7d98b48b5456ce8d916d))
* **rex:** show the rexboard board in the current Rex window ([#248](https://github.com/vanducng/dotfiles/issues/248)) ([b97f1e4](https://github.com/vanducng/dotfiles/commit/b97f1e4f3bc0e71997e047198fdd0d42b6978985))
* **sync:** git-sync-repos every 15 minutes, including the projects workspace ([29e3340](https://github.com/vanducng/dotfiles/commit/29e3340539ee7e25e606f1cc9238b9db78d06179))


### Bug Fixes

* **sync:** run git-sync-repos and git-fetch-repos with /bin/bash ([3fe4105](https://github.com/vanducng/dotfiles/commit/3fe41059381ad67b898342a2afae93a9bfe8a56c))

## [0.33.0](https://github.com/vanducng/dotfiles/compare/v0.32.0...v0.33.0) (2026-10-25)


### Features

* **hammerspoon:** opened GitHub repo PRs from a Hyper+I chooser ([751e352](https://github.com/vanducng/dotfiles/commit/751e352d5996b1647685be1b17d7293ba622c51f))

## [0.32.0](https://github.com/vanducng/dotfiles/compare/v0.31.0...v0.32.0) (2026-10-25)


### Features

* **release:** merged the release PR and synced every Mac with make release ([88e89ad](https://github.com/vanducng/dotfiles/commit/88e89ad5a50e7d23020c8ce165a147161962dcac))

## [0.31.0](https://github.com/vanducng/dotfiles/compare/v0.30.0...v0.31.0) (2026-10-25)


### Features

* **rex:** spun the agent status glyph in plain Rex pane headers ([34deb84](https://github.com/vanducng/dotfiles/commit/34deb840e6e4f4750c8b4b3a63efdb4f8247fb76))

## [0.30.0](https://github.com/vanducng/dotfiles/compare/v0.29.0...v0.30.0) (2026-10-24)


### Features

* **rex:** replayed seat agent status to tiles that attach later ([f87d338](https://github.com/vanducng/dotfiles/commit/f87d338b1901cc6c31296c4828136b240b176ecb))
* **rex:** showed agents in OpenRig tmux seats as agents in Rex ([3265394](https://github.com/vanducng/dotfiles/commit/32653942255a08d534a084b9711c386cb9ee8433))
* **rex:** switched hosts with Ctrl-Alt-1..9 from one hosts.json ([980ef91](https://github.com/vanducng/dotfiles/commit/980ef9177945194d7a989a2b9ca9fb743339d271))
* **rex:** toggled back to the last session with C-x a ([3858fa6](https://github.com/vanducng/dotfiles/commit/3858fa6d1a0827789ed572654c492dddc9688171))
* **rex:** turned on Program Activity sounds ([f6b1b3a](https://github.com/vanducng/dotfiles/commit/f6b1b3abefc316efe642053ec5c71c8171ebdcf7))
* **rex:** walked every tab in sidebar order with Ctrl-Alt-&lt; and &gt; ([3b7faa2](https://github.com/vanducng/dotfiles/commit/3b7faa27a1d4beb03498cf791003272f0fae935f))


### Bug Fixes

* **rex:** dismissed notices with Alt-Cmd-. ([610ec99](https://github.com/vanducng/dotfiles/commit/610ec99c11664f1e8410fd249e5ea01fd48800f3))
* **rex:** moved tabs with Shift-Cmd-arrows ([#240](https://github.com/vanducng/dotfiles/issues/240)) ([e7b7f9c](https://github.com/vanducng/dotfiles/commit/e7b7f9ced8dbdae1fb6354e6ff9a319d91f0fff5))
* **rex:** trimmed session keys to one per action and opened sessions on the web ([3b3a89c](https://github.com/vanducng/dotfiles/commit/3b3a89c1c8d00ada926af58e3c0da4e756fd4e0a))
* **yabai:** moved Jump Desktop to the main display ([1b2659d](https://github.com/vanducng/dotfiles/commit/1b2659d558e83e770b18400516c8e19aab2b3834))

## [0.29.0](https://github.com/vanducng/dotfiles/compare/v0.28.0...v0.29.0) (2026-10-24)


### Features

* **agents:** gave Claude Code, Grok, pi and Codex one minimal status line ([#238](https://github.com/vanducng/dotfiles/issues/238)) ([ecd20bf](https://github.com/vanducng/dotfiles/commit/ecd20bf416060b7aa5184bf1a6c140a77a894b57))


### Bug Fixes

* **atuin:** applied the marine theme that was parsed under [daemon] ([#234](https://github.com/vanducng/dotfiles/issues/234)) ([2f499df](https://github.com/vanducng/dotfiles/commit/2f499dfe61c0127a536f534517a50f6717443e9c))
* **ci:** made validate pass by skipping zsh files and pinning Claude hooks to /usr/bin/python3 ([#233](https://github.com/vanducng/dotfiles/issues/233)) ([ef23a7d](https://github.com/vanducng/dotfiles/commit/ef23a7d8c0b553c0cfe0bdc4e14d59d8c4ec7068))
* **rex:** freed Ctrl-Shift-Up/Down for moving tabs ([#237](https://github.com/vanducng/dotfiles/issues/237)) ([abee15c](https://github.com/vanducng/dotfiles/commit/abee15caf240a883fb5b60ece3d2c8a50ba7bfab))
* **rex:** made copy mode and the picker show up on any pane ([#236](https://github.com/vanducng/dotfiles/issues/236)) ([98993de](https://github.com/vanducng/dotfiles/commit/98993de9b97430405862a3846667345c75acef97))
* **zsh:** stopped ssh from printing command not found in Claude Code shells ([#239](https://github.com/vanducng/dotfiles/issues/239)) ([f749825](https://github.com/vanducng/dotfiles/commit/f7498251c68c9a320ee852fe67206d3713ba93ca))

## [0.28.0](https://github.com/vanducng/dotfiles/compare/v0.27.0...v0.28.0) (2026-10-24)


### Features

* **atuin:** switched search to the daemon's fuzzy mode and enabled AI ([#232](https://github.com/vanducng/dotfiles/issues/232)) ([794b398](https://github.com/vanducng/dotfiles/commit/794b3985ecef9e5ae87ca167d56634f12390a771))
* **herdr:** dropped the C-x n/p tab keys for the direct Ctrl-1..9 jump ([#228](https://github.com/vanducng/dotfiles/issues/228)) ([8c4217b](https://github.com/vanducng/dotfiles/commit/8c4217b1efc0b9ae76a47e192ad4bfd90d7c4350))
* **nix:** set Structured to its side layout through home-manager ([#229](https://github.com/vanducng/dotfiles/issues/229)) ([f62ecb6](https://github.com/vanducng/dotfiles/commit/f62ecb64e324ff608178251f81cd872a45939d86))
* **rex:** numbered tab labels for cmd+N on C-x i ([#226](https://github.com/vanducng/dotfiles/issues/226)) ([93fcf59](https://github.com/vanducng/dotfiles/commit/93fcf59973143379d5d6f28c30d8916d8dea7643))


### Bug Fixes

* **rex:** cut copy mode and picker startup lag ([#231](https://github.com/vanducng/dotfiles/issues/231)) ([4316937](https://github.com/vanducng/dotfiles/commit/4316937d269b2841ddbe859e9a265e4e4a70699b))
* **zsh:** cut new shell startup from 10-20s to under a second ([#230](https://github.com/vanducng/dotfiles/issues/230)) ([04b7abc](https://github.com/vanducng/dotfiles/commit/04b7abc4e9094253a9a20b6a06910f3a9369f39c))

## [0.27.0](https://github.com/vanducng/dotfiles/compare/v0.26.0...v0.27.0) (2026-10-24)


### Features

* **homelab:** added GNOME Pop Shell tiling with Mac-style keys on linux-01 ([#213](https://github.com/vanducng/dotfiles/issues/213)) ([41eebb3](https://github.com/vanducng/dotfiles/commit/41eebb3842a3d62002492b5df1aa78956947439e))
* **homelab:** always showed workspace numbers 1-9 and dropped the Firefox key on linux-01 ([#221](https://github.com/vanducng/dotfiles/issues/221)) ([2140f5a](https://github.com/vanducng/dotfiles/commit/2140f5a1dea7eb4455a68e3b0428aa868964f926))
* **homelab:** made cmd+c/v copy and paste in Ghostty on linux-01 ([#222](https://github.com/vanducng/dotfiles/issues/222)) ([203aa6e](https://github.com/vanducng/dotfiles/commit/203aa6e91ae55c2a99169f47e31a848722d6efca))
* **homelab:** pinned apps to workspaces and reloaded a blank wall dashboard ([#218](https://github.com/vanducng/dotfiles/issues/218)) ([c31fd6e](https://github.com/vanducng/dotfiles/commit/c31fd6e5640ebdea092fe40a3c8f54f40fb524ad))
* **homelab:** put BrowserOS neo on meh+s, Chrome on meh+d, and slimmed the GNOME panel ([#214](https://github.com/vanducng/dotfiles/issues/214)) ([e4f6116](https://github.com/vanducng/dotfiles/commit/e4f6116e0f6792b6e16360125124bddc8cf8ec68))
* **homelab:** put Grok Bot on meh+v on linux-01 ([#217](https://github.com/vanducng/dotfiles/issues/217)) ([74839a7](https://github.com/vanducng/dotfiles/commit/74839a783a50ed94f144a90123c967df94be4c42))
* **homelab:** put the sysmon hub on meh+f and added an app taskbar to the GNOME panel ([#215](https://github.com/vanducng/dotfiles/issues/215)) ([00c3c0c](https://github.com/vanducng/dotfiles/commit/00c3c0c111ee9b75c7a4103334a60884c5fcffe8))
* Jump host names, OpenVPN split repair, shell and agent config updates ([90401a2](https://github.com/vanducng/dotfiles/commit/90401a2c499de47cafb7c2053c09e05c4d2a9dfc))
* **jump-desktop:** name hosts mini-01, linux-01, macpro and pin the Apple account ([3122f05](https://github.com/vanducng/dotfiles/commit/3122f05cdd796ea66188e2dbce9f6892c4bec112))
* **jump-desktop:** version Jump Desktop viewer entries and helper shim ([6fa5e9b](https://github.com/vanducng/dotfiles/commit/6fa5e9b7ceb55a5e1c798743b361df47ea4963d1))
* **jump-desktop:** version Jump Desktop viewer entries and helper shim ([8383674](https://github.com/vanducng/dotfiles/commit/8383674d2b7b12a4e31773033c19df02b1415fb4))
* **linux:** exported the 1Password service account token for agents on linux-01 ([#219](https://github.com/vanducng/dotfiles/issues/219)) ([5d1eb4a](https://github.com/vanducng/dotfiles/commit/5d1eb4acba589fc2a37b834964ba0823e15ae3fb))
* **openvpn:** pin CNB host routes to the tun and repair them after reconnects ([c384e3c](https://github.com/vanducng/dotfiles/commit/c384e3c1992779cddbeabe1dfda67cc38c987b1e))
* **rex:** added Rex config with herdr-style keys and multi-Mac hosts ([#224](https://github.com/vanducng/dotfiles/issues/224)) ([f3def9a](https://github.com/vanducng/dotfiles/commit/f3def9ab9a48445de555f3fdd517d7c573674a25))
* **rex:** fixed cross-Mac session jumps and added tab, numbering, and picker keys ([#225](https://github.com/vanducng/dotfiles/issues/225)) ([e585251](https://github.com/vanducng/dotfiles/commit/e5852514618b3a7c1f4e9a88895b296b8edce678))
* **skhd:** opened the Mac mini over Jump Desktop on meh+2 ([#212](https://github.com/vanducng/dotfiles/issues/212)) ([6d42da1](https://github.com/vanducng/dotfiles/commit/6d42da11309dc703f424898ffe556505a3b0fb6c))
* **ssh:** shared home host aliases mini-01, linux-01, macpro ([2f314d1](https://github.com/vanducng/dotfiles/commit/2f314d11ac62a372ddfb5f0e9f085a1c77c9979f))
* **ssh:** shared home host aliases mini-01, linux-01, macpro ([415954a](https://github.com/vanducng/dotfiles/commit/415954a6566cf174b02973d32176972606efb3c1))


### Bug Fixes

* **homelab:** addressed review feedback on the linux-01 desktop scripts ([#216](https://github.com/vanducng/dotfiles/issues/216)) ([014e1dc](https://github.com/vanducng/dotfiles/commit/014e1dcc0d26cad9183ee5448cdbc1e7f8f75da4))
* **homelab:** waited for the network before opening the wall and put app search on cmd+space ([#220](https://github.com/vanducng/dotfiles/issues/220)) ([08a2b21](https://github.com/vanducng/dotfiles/commit/08a2b218057aa09550894fe6bf56467b11aa6db8))
* **shell:** portable aliases and paths, quieter startup on unreadable cwd ([f1e30c3](https://github.com/vanducng/dotfiles/commit/f1e30c39b918d70c326280eff36ec05dff9ce347))
* **zsh:** prefer the installer atuin over Homebrew ([#223](https://github.com/vanducng/dotfiles/issues/223)) ([5d6512e](https://github.com/vanducng/dotfiles/commit/5d6512e63922085b28e14596826607d9d84d9c07))

## [0.26.0](https://github.com/vanducng/dotfiles/compare/v0.25.1...v0.26.0) (2026-10-18)


### Features

* **bin:** add cpq for CLI Proxy account quota ([4d2d9aa](https://github.com/vanducng/dotfiles/commit/4d2d9aa2d8b24cccad9042055e372bc2d64b6240))
* **desktop:** pinned Screen Sharing, path matching, and cpq ([202a517](https://github.com/vanducng/dotfiles/commit/202a5170ad2cc11ec4bb584c0d5fc97a050c79c8))
* **yabai:** pin Screen Sharing on space 2 and Aside on space 3 ([#206](https://github.com/vanducng/dotfiles/issues/206)) ([bbd5a71](https://github.com/vanducng/dotfiles/commit/bbd5a719c6ee53a590040ebb66ef7abbbfcf2777))
* **yabai:** pin Screen Sharing on space 9 ([7a97e2a](https://github.com/vanducng/dotfiles/commit/7a97e2a5003d973b628cef4d5edfd77c21e026c8))


### Bug Fixes

* **herdr-fingers:** match paths that contain spaces ([3659f84](https://github.com/vanducng/dotfiles/commit/3659f843921bbedc683a4864f15676e0f3d4d8ea))
* **homelab:** name the Ubuntu dev box linux01 ([7a9c493](https://github.com/vanducng/dotfiles/commit/7a9c4935e51a5b7abc3447c586da16602b112931))
* **mise:** stow the Linux toolset only on Linux ([6be331e](https://github.com/vanducng/dotfiles/commit/6be331e30fa8e9cf0b2f6362b85bc1146c29a0a9))
* **mise:** stow the Linux toolset only on Linux ([ac77085](https://github.com/vanducng/dotfiles/commit/ac7708572786898aee795c90fe14482a59808b85))
* **skhd:** pass hotkeys through remote viewers ([4d3b2b4](https://github.com/vanducng/dotfiles/commit/4d3b2b4fb5c749c3a163f90670bad6f70997d698))
* **skhd:** passed hotkeys through remote viewers ([0923638](https://github.com/vanducng/dotfiles/commit/0923638d533aeeffa9fdf429a01ade5a90ae6344))

## [0.25.1](https://github.com/vanducng/dotfiles/compare/v0.25.0...v0.25.1) (2026-10-09)


### Bug Fixes

* **hooks:** disabled agent sound and telegram notify ([#199](https://github.com/vanducng/dotfiles/issues/199)) ([f9aa924](https://github.com/vanducng/dotfiles/commit/f9aa924ef44c6c3e0ba54beeb00740a57cec28ad))

## [0.25.0](https://github.com/vanducng/dotfiles/compare/v0.24.0...v0.25.0) (2026-10-05)


### Features

* **ai:** added ccx for Claude Code via CLI Proxy ([#197](https://github.com/vanducng/dotfiles/issues/197)) ([d0c7d15](https://github.com/vanducng/dotfiles/commit/d0c7d153e5a3f31b0436547e3356249f42a81d26))
* **ai:** tracked which CLI Proxy models answer ([#198](https://github.com/vanducng/dotfiles/issues/198)) ([8ba992e](https://github.com/vanducng/dotfiles/commit/8ba992ee8f0f9477cc14d79da675d9cb7594ccfb))
* **codex:** add cliproxy-muse profile with apps disabled ([a05ed2b](https://github.com/vanducng/dotfiles/commit/a05ed2bc848b6b8f573da1ee39ff39f7dcca7547))
* **codex:** add named CLI proxy model profiles ([5b0bb95](https://github.com/vanducng/dotfiles/commit/5b0bb9585083186572f61de0ab760c6b3215c887))

## [0.24.0](https://github.com/vanducng/dotfiles/compare/v0.23.1...v0.24.0) (2026-09-27)


### Features

* **ai:** add Claude Opus 5.5 to the cliproxy catalog ([#194](https://github.com/vanducng/dotfiles/issues/194)) ([61483a1](https://github.com/vanducng/dotfiles/commit/61483a16ad694115ce6e75915e98b1c26d42185f))
* moved the desktop browser to Aside ([#195](https://github.com/vanducng/dotfiles/issues/195)) ([6bb115a](https://github.com/vanducng/dotfiles/commit/6bb115ac027be74c72f1962f7e0e78d213753c23))
* **yabai:** kept one Dia window and dropped Superwhisper ([#191](https://github.com/vanducng/dotfiles/issues/191)) ([7367f2a](https://github.com/vanducng/dotfiles/commit/7367f2a0e93c032b754aa74293ff290258f824b1))


### Bug Fixes

* **borders:** drop the border on unfocused windows ([#192](https://github.com/vanducng/dotfiles/issues/192)) ([48db4a1](https://github.com/vanducng/dotfiles/commit/48db4a15b770ea62c553dd3c4d83045b1e41b94c))
* **yabai:** kept herdr-bar a sidebar beside Dia and ego lite ([#189](https://github.com/vanducng/dotfiles/issues/189)) ([86269e3](https://github.com/vanducng/dotfiles/commit/86269e348e1fa77f7d6d1fe1a114ea4dcdb97dc8))
* **yabai:** kept messaging apps on the built-in display ([#193](https://github.com/vanducng/dotfiles/issues/193)) ([d2f2444](https://github.com/vanducng/dotfiles/commit/d2f2444caf39e6a00b26fa071b0536a110d32b0e))

## [0.23.1](https://github.com/vanducng/dotfiles/compare/v0.23.0...v0.23.1) (2026-09-22)


### Bug Fixes

* **yabai:** floated Vivaldi fullscreen ([#182](https://github.com/vanducng/dotfiles/issues/182)) ([7231f0e](https://github.com/vanducng/dotfiles/commit/7231f0e4f4f9cc42e3a475f86bbaa7e0946dced5))

## [0.23.0](https://github.com/vanducng/dotfiles/compare/v0.22.0...v0.23.0) (2026-09-22)


### Features

* **pi:** replaced subagents with local extension ([#166](https://github.com/vanducng/dotfiles/issues/166)) ([2403120](https://github.com/vanducng/dotfiles/commit/2403120b4ff55b19b34ca1cdcc5094d345c0f9f1))
* **tinycast:** open btop and dua from keyboard shortcuts ([#174](https://github.com/vanducng/dotfiles/issues/174)) ([275bcc6](https://github.com/vanducng/dotfiles/commit/275bcc68b768f1e6ec8a3b2fd429ba8d33c1fa13))
* **tinycast:** shared one overlay for processes, disk, and vault ([#180](https://github.com/vanducng/dotfiles/issues/180)) ([4feb562](https://github.com/vanducng/dotfiles/commit/4feb562c210d1a0ee5fe59b626eba9c74faf7300))
* **tmux:** focus panes with Ctrl-Alt-hjkl like Herdr ([fa6a039](https://github.com/vanducng/dotfiles/commit/fa6a039091aa407052f0effcf5f4c70bcc93f6c2))


### Bug Fixes

* **homelab:** keep kernel Tailscale so Moshi Mosh has a TUN ([f3996e2](https://github.com/vanducng/dotfiles/commit/f3996e205a9f6e732e83d16eb6d0252d4701fbf8))
* **kitty:** kept overlay color and skhd hotkeys ([#183](https://github.com/vanducng/dotfiles/issues/183)) ([8e07c40](https://github.com/vanducng/dotfiles/commit/8e07c40ef42872a69eab5d1eef209c21b3bdfcae))
* **nvim:** prefer Homebrew so yazi.nvim does not run Intel ya ([#177](https://github.com/vanducng/dotfiles/issues/177)) ([f809482](https://github.com/vanducng/dotfiles/commit/f8094824572ba46452ca97fa44e28e35f5846e36))
* **tinycast:** close sysmon overlays without a kitty confirm ([#178](https://github.com/vanducng/dotfiles/issues/178)) ([f05119a](https://github.com/vanducng/dotfiles/commit/f05119aa1b1d5911caac431627fcdf4bd9368044))
* **tinycast:** focus the audio picker for keyboard use ([#169](https://github.com/vanducng/dotfiles/issues/169)) ([e8702ed](https://github.com/vanducng/dotfiles/commit/e8702ed8196e882cdbc4b42928ca4c3204504eba))
* **tinycast:** hide Teams, Jump, and Kuycon from the audio picker ([#172](https://github.com/vanducng/dotfiles/issues/172)) ([0dae203](https://github.com/vanducng/dotfiles/commit/0dae203d55bb61e0d02e2249198aae2c9caaad68))
* **tinycast:** keep sysmon overlays alive and focus them instantly ([#176](https://github.com/vanducng/dotfiles/issues/176)) ([a0e1a18](https://github.com/vanducng/dotfiles/commit/a0e1a18e97e1110ed25f545c4e3644f52d7476e8))
* **tinycast:** persist sysmon in tmux and move disk off the Dock chord ([#175](https://github.com/vanducng/dotfiles/issues/175)) ([9158c02](https://github.com/vanducng/dotfiles/commit/9158c02740d40ffb42b56c17a94b2e8e5e701691))
* **tinycast:** reuse the open audio picker instead of stacking another ([#173](https://github.com/vanducng/dotfiles/issues/173)) ([756467e](https://github.com/vanducng/dotfiles/commit/756467ee681d55906a5a75511fa053ca0fb11d67))
* **tinycast:** show paired AirPods in the audio picker ([#170](https://github.com/vanducng/dotfiles/issues/170)) ([e558a9a](https://github.com/vanducng/dotfiles/commit/e558a9a87e1994a87cf5956faa68feed72cd0c9b))
* **tinycast:** skip login zsh so the audio picker opens faster ([#171](https://github.com/vanducng/dotfiles/issues/171)) ([2525bab](https://github.com/vanducng/dotfiles/commit/2525bab4b9fe03b180cfc1e3559cd2bf5cb929fe))
* **tinycast:** use kitty.conf syntax so overlay close is not confirmed ([#179](https://github.com/vanducng/dotfiles/issues/179)) ([cdbc1e7](https://github.com/vanducng/dotfiles/commit/cdbc1e7ec82376f40c08606a50adea0bc60c4479))
* **tmux:** stopped TUI frames from filling scrollback ([#181](https://github.com/vanducng/dotfiles/issues/181)) ([13ec479](https://github.com/vanducng/dotfiles/commit/13ec479fb23e906d87b921189a3bac1ed6ce00a5))

## [0.22.0](https://github.com/vanducng/dotfiles/compare/v0.21.0...v0.22.0) (2026-09-20)


### Features

* **mac:** add OpenVPN Connect CLI controls ([#165](https://github.com/vanducng/dotfiles/issues/165)) ([607d28e](https://github.com/vanducng/dotfiles/commit/607d28e765bc17435b42597a4aab1adbec441321))
* **skhd:** add 1Password launcher hotkey ([#163](https://github.com/vanducng/dotfiles/issues/163)) ([1be933d](https://github.com/vanducng/dotfiles/commit/1be933d2e926f3bd0ce4c0ac4ec252fc7b6f12c9))


### Bug Fixes

* **config:** swapped app hotkeys and added Pi extension ([7e32ec5](https://github.com/vanducng/dotfiles/commit/7e32ec59789c15502730a6946e0fb24cc8c0e37d))
* **herdr:** restored detached shell shortcuts ([#164](https://github.com/vanducng/dotfiles/issues/164)) ([268804c](https://github.com/vanducng/dotfiles/commit/268804ca056b0b30da94074af1e0796b24f8ceb0))
* **skhd:** swap Alter and WhatsApp hotkeys ([0624443](https://github.com/vanducng/dotfiles/commit/062444353969646861e39a2abc692702a55bfdfb))

## [0.21.0](https://github.com/vanducng/dotfiles/compare/v0.20.0...v0.21.0) (2026-09-19)


### Features

* **cursor:** align agent CLI config and docs ([#151](https://github.com/vanducng/dotfiles/issues/151)) ([6de22ec](https://github.com/vanducng/dotfiles/commit/6de22ecf8964a67fef279ddb576bb18e6c55b468))
* **dotfiles:** ensure firstmate on Mac and Linux from one path ([#156](https://github.com/vanducng/dotfiles/issues/156)) ([55ac2c5](https://github.com/vanducng/dotfiles/commit/55ac2c53b12cfd491723d4afb72344ba79dcef62))
* **homelab:** add fetch-only repo refresh and on-enter debounce ([a1eb7c4](https://github.com/vanducng/dotfiles/commit/a1eb7c430b1105f0dd0d5593c79855f94dbcbee1))
* **homelab:** added fetch-only repo refresh and on-enter debounce ([87fd69d](https://github.com/vanducng/dotfiles/commit/87fd69d8c3302caebdf6c56a15268fb164159d83))
* **homelab:** sync firstmate into personal/ like skills ([#155](https://github.com/vanducng/dotfiles/issues/155)) ([f99930a](https://github.com/vanducng/dotfiles/commit/f99930a47e17abe6b65afdedc7a48995e5f5c7f8))
* **mac:** add cnb-openvpn-mac split-tunnel helper ([#157](https://github.com/vanducng/dotfiles/issues/157)) ([479e37a](https://github.com/vanducng/dotfiles/commit/479e37adebdf2178feee221f3ee80e331ca94b79))
* **op:** version 1Password CLI setup for biometric unlock ([e6ec332](https://github.com/vanducng/dotfiles/commit/e6ec33250e2f7ab3b8d09ae9c77a8b1e61f8a1c7))
* **op:** version 1Password CLI setup for biometric unlock ([305127a](https://github.com/vanducng/dotfiles/commit/305127ab74578f9bd49fd9220f81d662700059f9))
* **pi:** add CLIProxy model configs and environment setup ([#152](https://github.com/vanducng/dotfiles/issues/152)) ([bb70b6e](https://github.com/vanducng/dotfiles/commit/bb70b6e608bdeefadc38c236b78cb36adfc551b3))
* **tinycast:** add Tinycast launcher cask and float rules ([e66786c](https://github.com/vanducng/dotfiles/commit/e66786c49cbcdfd8e00744cc7de18eafaaea168c))
* **tinycast:** added launcher setup and hotkey config ([#148](https://github.com/vanducng/dotfiles/issues/148)) ([bd6b985](https://github.com/vanducng/dotfiles/commit/bd6b9851b990cd4dcb27ef0841d7bf1baf3d487d))
* **tinycast:** script hotkeys and quick action prompts ([6a9c805](https://github.com/vanducng/dotfiles/commit/6a9c8054ac226262eea7bc25b55af7e6a36bd773))


### Bug Fixes

* **homelab:** address remaining git-fetch review nits ([ee52f54](https://github.com/vanducng/dotfiles/commit/ee52f54f3f1aec7d3ffbd2880cd68b17cfdc01de))
* **homelab:** chmod 700 ~/.ssh in CLIProxy env setup ([#154](https://github.com/vanducng/dotfiles/issues/154)) ([45c1640](https://github.com/vanducng/dotfiles/commit/45c1640c38f51bb9ba350db383d2d57e0e8d637a))
* **homelab:** harden git-fetch for public-repo and review nits ([89a1af0](https://github.com/vanducng/dotfiles/commit/89a1af017a0c5a91af992ff1e2ea2a90f96961b7))
* **homelab:** keep firstmate at ~/firstmate like skills ([ec4e25d](https://github.com/vanducng/dotfiles/commit/ec4e25ddb4fff11f3c67b69b04b66be2be43123d))
* **homelab:** make CLIProxy env setup idempotent ([#153](https://github.com/vanducng/dotfiles/issues/153)) ([9e86b43](https://github.com/vanducng/dotfiles/commit/9e86b4327487923d4661a2e9c573eda569594689))
* **homelab:** tighten git-fetch review findings ([7daa9f0](https://github.com/vanducng/dotfiles/commit/7daa9f08cedc5a9d96b14e4839a4e378676e0838))
* **op:** drop OP_ACCOUNT shorthand, document manual-account shadowing ([df16182](https://github.com/vanducng/dotfiles/commit/df161827486ce5089de7953d8f13edc078a22452))
* **op:** drop OP_ACCOUNT shorthand, document manual-account shadowing ([8f6f678](https://github.com/vanducng/dotfiles/commit/8f6f67832121d252eb5e0d1cac1dd5165258e9c7))
* **zsh:** use $HOME instead of hardcoded /Users/vanducng ([4e6241b](https://github.com/vanducng/dotfiles/commit/4e6241b8fa90a9a1af474448eff173173758fb2c))

## [0.20.0](https://github.com/vanducng/dotfiles/compare/v0.19.0...v0.20.0) (2026-09-17)


### Features

* added pi standby badge and herdr session picker ([#144](https://github.com/vanducng/dotfiles/issues/144)) ([c9121c7](https://github.com/vanducng/dotfiles/commit/c9121c73c17fb19acf995f50c6f8c5ecb17d2451))
* **pi:** wake captain when sibling crews settle ([#146](https://github.com/vanducng/dotfiles/issues/146)) ([0734729](https://github.com/vanducng/dotfiles/commit/07347298c20f359c0e8db855e394ffab19088a98))


### Bug Fixes

* **agents:** write coworker email like a person ([#147](https://github.com/vanducng/dotfiles/issues/147)) ([3c250bc](https://github.com/vanducng/dotfiles/commit/3c250bcee62d7910f2d3be8dec50b0ad15a3a002))

## [0.19.0](https://github.com/vanducng/dotfiles/compare/v0.18.0...v0.19.0) (2026-09-15)


### Features

* **herdr:** added C-x 0 home jump and remapped prefix chords ([#142](https://github.com/vanducng/dotfiles/issues/142)) ([be0c7fb](https://github.com/vanducng/dotfiles/commit/be0c7fb088c28abecf790eccaf1d1b45f4d16b96))

## [0.18.0](https://github.com/vanducng/dotfiles/compare/v0.17.0...v0.18.0) (2026-09-15)


### Features

* **pi:** stretch auto-retry to about 15 minutes ([#139](https://github.com/vanducng/dotfiles/issues/139)) ([7ad4792](https://github.com/vanducng/dotfiles/commit/7ad4792f86410f23e84244b940df1e8ee6c59f61))
* **yabai:** pinned Obsidian, LibreOffice, and ego to dedicated spaces ([#141](https://github.com/vanducng/dotfiles/issues/141)) ([0db090f](https://github.com/vanducng/dotfiles/commit/0db090fd51cc76ec6e08ce8b83d50332e0f0fa0d))

## [0.17.0](https://github.com/vanducng/dotfiles/compare/v0.16.0...v0.17.0) (2026-09-11)


### Features

* **git:** add includeIf identities for crashchat, ab-spectrum, bhcoe ([7ed79b0](https://github.com/vanducng/dotfiles/commit/7ed79b0f2949d7a6ad310d7a57b6f09103289036))
* **homelab:** auto-connect Tailscale on boot ([dd59884](https://github.com/vanducng/dotfiles/commit/dd5988480ddb402a64f836ef48b29860556802a9))
* **linux:** add CNB OpenVPN user daemon from Mac Tunnelblick profile ([d4973d7](https://github.com/vanducng/dotfiles/commit/d4973d7744bfcf104b5d5585f0ed7815f9c8f768))
* **linux:** add homelab layout, never-sleep, and user sshd ([23cd2c3](https://github.com/vanducng/dotfiles/commit/23cd2c350efe91c2cf191aab65ba3899a8d8d766))
* **linux:** add remote CDP, RDP tunnels, and userspace Tailscale ([b5be98a](https://github.com/vanducng/dotfiles/commit/b5be98af8ffdaebff33acac23af5670c3da5d778))
* **linux:** add sudo helper to enable ssh/mosh remote access ([1eb1ea7](https://github.com/vanducng/dotfiles/commit/1eb1ea7897192bcaf8101f416ba9f6c704a90203))
* **linux:** add Sway/Ghostty desktop with skhd-equivalent keys ([6bc3ca1](https://github.com/vanducng/dotfiles/commit/6bc3ca1d69cb48ade9cfea3858b4207a2ef16835))
* **linux:** add user-space bootstrap and portable stow set ([18df72d](https://github.com/vanducng/dotfiles/commit/18df72d2cd77b292e6bf658ee3af48451497c32d))
* **linux:** added dpl homelab remote, CNB OpenVPN, and Tailscale ([651ad18](https://github.com/vanducng/dotfiles/commit/651ad1892c6bdc05a8fd71dabd17ef3046fc1ed7))
* **linux:** CNB OpenVPN MAIN profile plus Mac bastion jump ([673de26](https://github.com/vanducng/dotfiles/commit/673de26e99b0d06cad6a60a089774b1894956dc2))
* **linux:** format 970 as dpl-work for git worktrees and docker data ([838ef6b](https://github.com/vanducng/dotfiles/commit/838ef6b7e5909f4800bb01a1b69705bce89fa5ee))
* **linux:** keep bulky tool stores on the 970 work disk ([15510d1](https://github.com/vanducng/dotfiles/commit/15510d1f8589ef3f19f6e0a050f7ad898242580d))
* **linux:** persist tun cnb0 for user-space CNB OpenVPN ([7368c1d](https://github.com/vanducng/dotfiles/commit/7368c1d8de0433f127a2aa519893c7871a9a878c))
* **linux:** point gopass at ~/work/git/personal/pass ([71c6f4c](https://github.com/vanducng/dotfiles/commit/71c6f4cedcda272b31f2f55b61a73dd94e432a48))
* **linux:** store CNB VPN in gopass and start/stop on demand ([46b6bd5](https://github.com/vanducng/dotfiles/commit/46b6bd58ba4717994a4c00e7ef68439baae2cc62))
* **pi:** add ponytail package pinned at v4.9.0 ([7f21890](https://github.com/vanducng/dotfiles/commit/7f2189036d89fabe0d209d3658280dabeead3a79))
* **pi:** add Structured MCP via pi-mcp-adapter ([#131](https://github.com/vanducng/dotfiles/issues/131)) ([cd48994](https://github.com/vanducng/dotfiles/commit/cd48994567ad1eee71185cf4936f493a11e03aff))


### Bug Fixes

* **agents:** dropped Claude proxy billing and disabled Langfuse ([#129](https://github.com/vanducng/dotfiles/issues/129)) ([ecbd379](https://github.com/vanducng/dotfiles/commit/ecbd379a61cdaf0114f714aa4436182c0f916a56))
* **config:** restore cross-platform dotfiles validation ([#126](https://github.com/vanducng/dotfiles/issues/126)) ([96e71af](https://github.com/vanducng/dotfiles/commit/96e71afad8c5a56f177c845d1234f9a3b3ceeaff))
* **git:** keep work mailboxes out of the tracked repo ([40409cb](https://github.com/vanducng/dotfiles/commit/40409cb6862719cdef29dd1416f4eede20dabba6))
* **herdr:** restored workspace switching on linux and mosh ([#128](https://github.com/vanducng/dotfiles/issues/128)) ([346e4aa](https://github.com/vanducng/dotfiles/commit/346e4aa0120ea11160538c8a949de0ab31370beb))
* **kitty:** forwarded ctrl+alt+1..9 to herdr workspaces ([#133](https://github.com/vanducng/dotfiles/issues/133)) ([f5ac961](https://github.com/vanducng/dotfiles/commit/f5ac9612188d206c2852d4dbde9307ec7060bcb2))
* **linux:** finish homelab docker, mosh, SSH PATH, and OpenVPN caps ([531337d](https://github.com/vanducng/dotfiles/commit/531337d58a3fa6a1dabc536bd3a4779f5f82b276))
* **linux:** keep stowed pi wrapper ahead of mise node bins ([21ce2ed](https://github.com/vanducng/dotfiles/commit/21ce2ed537498f5fa4a35c6ca32e3dff3689a231))
* **linux:** restored yazi, miu-db.nvim, and release-please 0.16.0 ([#136](https://github.com/vanducng/dotfiles/issues/136)) ([603acbc](https://github.com/vanducng/dotfiles/commit/603acbc6a7948b33739f6f5bf9a26af2ebbe0695))
* **linux:** stop hardcoding work emails in VPN helpers and docs ([e719415](https://github.com/vanducng/dotfiles/commit/e7194150a9eea9109899931d7d7a164f433e16ac))
* **linux:** use merge.conflictstyle diff3 on Ubuntu 22.04 git ([9b45b6c](https://github.com/vanducng/dotfiles/commit/9b45b6c3d66d9e26b18fa647ed4d53281b658777))
* **nvim:** compiled tree-sitter-cli for older glibc ([#134](https://github.com/vanducng/dotfiles/issues/134)) ([1834564](https://github.com/vanducng/dotfiles/commit/18345645f114ea869f5289b970f940b421ce8318))
* **nvim:** restored kulala HTTP syntax highlighting ([#130](https://github.com/vanducng/dotfiles/issues/130)) ([58e3dea](https://github.com/vanducng/dotfiles/commit/58e3deaeb2885f9cbd030a98a997d99cf264b613))
* **pi:** kept ~/.pi a real directory on linux and macos stow ([#127](https://github.com/vanducng/dotfiles/issues/127)) ([6906fb4](https://github.com/vanducng/dotfiles/commit/6906fb41a771c78d15e0b24aced872854af4f77e))
* **shell:** restore kitty keyboard protocol after ssh drop ([#135](https://github.com/vanducng/dotfiles/issues/135)) ([4b71fae](https://github.com/vanducng/dotfiles/commit/4b71fae0145c04fc226dca13bc5126bdf307e5ea))

## [0.16.0](https://github.com/vanducng/dotfiles/compare/v0.15.0...v0.16.0) (2026-08-18)


### Features

* **ai:** add Claude Fable 5 and align cliproxy windows ([#118](https://github.com/vanducng/dotfiles/issues/118)) ([8e1fca6](https://github.com/vanducng/dotfiles/commit/8e1fca6c7e1a058dec14a8a4f42873d2ecbd2185))
* **ai:** cliproxy reasoning levels and stow-managed dsh settings ([#115](https://github.com/vanducng/dotfiles/issues/115)) ([0960f43](https://github.com/vanducng/dotfiles/commit/0960f43486f284afbf03f1a38ffb73ee0709a57a))
* **dsh:** symlink global AGENTS.md into ~/.dsh ([#117](https://github.com/vanducng/dotfiles/issues/117)) ([a165f68](https://github.com/vanducng/dotfiles/commit/a165f68a7f78e2b71c4637391e492da809cb0ffd))
* **pi:** add subagents and guardrails packages ([#116](https://github.com/vanducng/dotfiles/issues/116)) ([e1afda3](https://github.com/vanducng/dotfiles/commit/e1afda351513072e88196d35b2d4fc1e0f3b4c68))
* **pi:** exposed grok-4.6 xhigh thinking level ([#113](https://github.com/vanducng/dotfiles/issues/113)) ([a0f072b](https://github.com/vanducng/dotfiles/commit/a0f072b91514bc5e64fca23f8feea6c1b139e25a))

## [0.15.0](https://github.com/vanducng/dotfiles/compare/v0.14.2...v0.15.0) (2026-08-16)


### Features

* **codex:** route Codex and Pi through CLI proxy and update models ([#98](https://github.com/vanducng/dotfiles/issues/98)) ([cc98577](https://github.com/vanducng/dotfiles/commit/cc985779342813b87c53c2276ce6b1edfc9f715d))
* **grok:** added stow-managed Grok config and lifecycle hooks ([#102](https://github.com/vanducng/dotfiles/issues/102)) ([7272d2b](https://github.com/vanducng/dotfiles/commit/7272d2b182f6c037aedfd5fe1dc06ff59c8eca7c))
* **launchd:** set CLI_PROXY_API_KEY for macOS GUI apps ([#107](https://github.com/vanducng/dotfiles/issues/107)) ([2978eaf](https://github.com/vanducng/dotfiles/commit/2978eaff971b2db7167b64d49abfa810df0e7edb))
* **nvim:** added JSONL pretty-print maps ([#109](https://github.com/vanducng/dotfiles/issues/109)) ([759e1ff](https://github.com/vanducng/dotfiles/commit/759e1ffc94d6a668a1074e1a065c2f521c413d73))
* **pi:** add Grok 4.6 to CLI proxy model list ([#108](https://github.com/vanducng/dotfiles/issues/108)) ([ed548ba](https://github.com/vanducng/dotfiles/commit/ed548ba1f9e2664c56900b21f95beb66167599ab))
* **skhd:** bind meh-v to Grok Bot ([#110](https://github.com/vanducng/dotfiles/issues/110)) ([58d6d05](https://github.com/vanducng/dotfiles/commit/58d6d056797fde35def446d62709848afd5c96dd))


### Bug Fixes

* **codex:** avoid unexpanded $HOME in direct-spawn MCP env ([#105](https://github.com/vanducng/dotfiles/issues/105)) ([13f1d78](https://github.com/vanducng/dotfiles/commit/13f1d7852250cde7c180faad763448f9aa031ebf))
* **codex:** expand Computer Use home paths via bash and $HOME ([#104](https://github.com/vanducng/dotfiles/issues/104)) ([288f808](https://github.com/vanducng/dotfiles/commit/288f808ad3bedb512a679a514a26a2df0cf3058c))
* **codex:** launch node_repl via portable home-expanding wrapper ([#106](https://github.com/vanducng/dotfiles/issues/106)) ([2a76081](https://github.com/vanducng/dotfiles/commit/2a76081798525929b65f57cce05843ac413ec3b9))
* **direnv:** cache poetry venv and avoid here-doc ENOSPC on new pane ([#100](https://github.com/vanducng/dotfiles/issues/100)) ([a597d9f](https://github.com/vanducng/dotfiles/commit/a597d9f174dd6ceefdda4824fa6d8c5763f4b387))
* **herdr:** use contextual pane names ([3212204](https://github.com/vanducng/dotfiles/commit/32122047c1426dc37e11ab1a0eab30c0d37bf1a7))

## [0.14.2](https://github.com/vanducng/dotfiles/compare/v0.14.1...v0.14.2) (2026-08-09)


### Bug Fixes

* **codex:** clean up MCP startup config ([#97](https://github.com/vanducng/dotfiles/issues/97)) ([3f18f23](https://github.com/vanducng/dotfiles/commit/3f18f23abc5720981e84c97f64d514cbf81d2246))


### Performance Improvements

* **gopass:** keep secret reads local ([c2c4a5e](https://github.com/vanducng/dotfiles/commit/c2c4a5e5eaf639517ba871742908bd54fecd48e9))
* **herdr-fingers:** bounded the pane read so idle agent panes stop freezing ([#95](https://github.com/vanducng/dotfiles/issues/95)) ([76ae800](https://github.com/vanducng/dotfiles/commit/76ae80094589479d5981a890d61d4a1f7042ec00))

## [0.14.1](https://github.com/vanducng/dotfiles/compare/v0.14.0...v0.14.1) (2026-08-06)


### Bug Fixes

* **pi:** ran pi on the Node it was installed under ([#91](https://github.com/vanducng/dotfiles/issues/91)) ([27415f3](https://github.com/vanducng/dotfiles/commit/27415f3a3bd111f675581bd40e82c94078e3121f))


### Performance Improvements

* **herdr-fingers:** dropped two subshell forks per candidate ([#94](https://github.com/vanducng/dotfiles/issues/94)) ([5c94f24](https://github.com/vanducng/dotfiles/commit/5c94f241405e0d005cdcafd77294dc3c2d1d0612))

## [0.14.0](https://github.com/vanducng/dotfiles/compare/v0.13.1...v0.14.0) (2026-08-04)


### Features

* **agents:** improve Codex and Herdr defaults ([a22f067](https://github.com/vanducng/dotfiles/commit/a22f067ac7d2e78a6cd40876cf93e17e6622d9e1))
* **agents:** versioned Claude rules in dotfiles and removed stale guidance ([#87](https://github.com/vanducng/dotfiles/issues/87)) ([c664500](https://github.com/vanducng/dotfiles/commit/c664500353589de86ea720c69141ae202fdf4fec))
* **environment:** added portable coding-agent profiles ([#82](https://github.com/vanducng/dotfiles/issues/82)) ([2fce55e](https://github.com/vanducng/dotfiles/commit/2fce55eb925f166fb69b718094e4bd88eec2dd02))
* **herdr:** move the tab bar below terminal panes ([#90](https://github.com/vanducng/dotfiles/issues/90)) ([829717a](https://github.com/vanducng/dotfiles/commit/829717a4cbe3b65c695734e3636b7334ea930965))
* **pi:** add CLIProxyAPI model catalog ([#86](https://github.com/vanducng/dotfiles/issues/86)) ([0af851c](https://github.com/vanducng/dotfiles/commit/0af851c35a2f604749cd6940e5bd215677ad61d3))


### Bug Fixes

* **codex:** suppress unstable feature warning ([#89](https://github.com/vanducng/dotfiles/issues/89)) ([1e60443](https://github.com/vanducng/dotfiles/commit/1e604436ff93345578d30e805b406533eabbe6b9))
* **zsh:** dedupe PATH and drop dead entries ([#85](https://github.com/vanducng/dotfiles/issues/85)) ([1a8eff7](https://github.com/vanducng/dotfiles/commit/1a8eff76480d4b1a570f256c2ba17c493ac32b58))

## [0.13.1](https://github.com/vanducng/dotfiles/compare/v0.13.0...v0.13.1) (2026-07-31)


### Bug Fixes

* **ghostty:** drop global secure-input toggle, show SKE indicator ([#80](https://github.com/vanducng/dotfiles/issues/80)) ([73e5608](https://github.com/vanducng/dotfiles/commit/73e5608014ac79624c4ad2c996be7233c133bdb7))

## [0.13.0](https://github.com/vanducng/dotfiles/compare/v0.12.2...v0.13.0) (2026-07-30)


### Features

* **herdr:** expanded contextual pane names ([#78](https://github.com/vanducng/dotfiles/issues/78)) ([ad17188](https://github.com/vanducng/dotfiles/commit/ad171887d853ffd3c855db9bf408ab5cb3d38800))

## [0.12.2](https://github.com/vanducng/dotfiles/compare/v0.12.1...v0.12.2) (2026-07-29)


### Bug Fixes

* **docs:** keep header search clickable ([#76](https://github.com/vanducng/dotfiles/issues/76)) ([8d9dd46](https://github.com/vanducng/dotfiles/commit/8d9dd4642627ad51f1b3bbbe86364c24fa0a3086))

## [0.12.1](https://github.com/vanducng/dotfiles/compare/v0.12.0...v0.12.1) (2026-07-29)


### Bug Fixes

* **docs:** scope search trigger sizing ([#74](https://github.com/vanducng/dotfiles/issues/74)) ([b2f82a0](https://github.com/vanducng/dotfiles/commit/b2f82a01b26d89e6d06fd2ba9b49d4506bf2927d))

## [0.12.0](https://github.com/vanducng/dotfiles/compare/v0.11.2...v0.12.0) (2026-07-29)


### Features

* **herdr:** added session-context pane rename on prefix+shift+p ([#72](https://github.com/vanducng/dotfiles/issues/72)) ([01742dc](https://github.com/vanducng/dotfiles/commit/01742dc11e213e749e37e6c3b3902293b5f7fc96))

## [0.11.2](https://github.com/vanducng/dotfiles/compare/v0.11.1...v0.11.2) (2026-07-29)


### Bug Fixes

* **docs:** restore shell spacing ([#70](https://github.com/vanducng/dotfiles/issues/70)) ([27ec309](https://github.com/vanducng/dotfiles/commit/27ec309cbc92b01fda1a910cfd16f1ed920ec50e))

## [0.11.1](https://github.com/vanducng/dotfiles/compare/v0.11.0...v0.11.1) (2026-07-29)


### Bug Fixes

* **docs:** center navigation shell ([#69](https://github.com/vanducng/dotfiles/issues/69)) ([935fb8b](https://github.com/vanducng/dotfiles/commit/935fb8b8927f508b4fbfe29cbba158d8423fce22))
* **docs:** restore layout and feature Herdr ([#67](https://github.com/vanducng/dotfiles/issues/67)) ([a43cfb1](https://github.com/vanducng/dotfiles/commit/a43cfb14b3eae1836a44890b4e647ac3bd1a7a7a))

## [0.11.0](https://github.com/vanducng/dotfiles/compare/v0.10.0...v0.11.0) (2026-07-27)


### Features

* improve local agent workflows ([942c3a6](https://github.com/vanducng/dotfiles/commit/942c3a63b5d1b7979b35c99e7c970ea0b5e9ed6e))
* **skhd:** launch Ego on space one ([035da36](https://github.com/vanducng/dotfiles/commit/035da36b158748d3792573b7a5a9f440ca16f137))

## [0.10.0](https://github.com/vanducng/dotfiles/compare/v0.9.0...v0.10.0) (2026-07-24)


### Features

* **herdr:** integrate Droid and Moshi remote workflows ([0629cbc](https://github.com/vanducng/dotfiles/commit/0629cbca25cb291b8ab7be13947496e7f75edc0d))


### Bug Fixes

* **herdr:** improve navigation and path opening ([#62](https://github.com/vanducng/dotfiles/issues/62)) ([f3dc194](https://github.com/vanducng/dotfiles/commit/f3dc1946a5604687d0cb82d385eebe21b372584c))
* **yabai:** repair broken signals and Alter focus-steal on app launch ([8d3fa91](https://github.com/vanducng/dotfiles/commit/8d3fa915641824fb27d1dd317e7b540a5d092cc2))

## [0.9.0](https://github.com/vanducng/dotfiles/compare/v0.8.0...v0.9.0) (2026-07-21)


### Features

* improve Herdr navigation and route agents to Droid ([#58](https://github.com/vanducng/dotfiles/issues/58)) ([19b5172](https://github.com/vanducng/dotfiles/commit/19b5172c2a0975b460321cb99973587140c94009))


### Bug Fixes

* **ghostty:** drop shift+enter=text:\x1b\r so newline works in herdr panes ([725cb46](https://github.com/vanducng/dotfiles/commit/725cb46c51979276f7f7ef16d015ec2fc8b1cf10))

## [0.8.0](https://github.com/vanducng/dotfiles/compare/v0.7.0...v0.8.0) (2026-07-20)


### Features

* **herdr:** added portable tmux-style setup ([#56](https://github.com/vanducng/dotfiles/issues/56)) ([dbfebca](https://github.com/vanducng/dotfiles/commit/dbfebca4d49ae083b628c57ece425c157681a891))

## [0.7.0](https://github.com/vanducng/dotfiles/compare/v0.6.0...v0.7.0) (2026-07-20)


### Features

* **agents:** add shared global instructions ([#55](https://github.com/vanducng/dotfiles/issues/55)) ([4deac9f](https://github.com/vanducng/dotfiles/commit/4deac9f62cefe10b60c157c9c75d0c3cad6ed059))
* **nvim:** enable PHP LSP ([#49](https://github.com/vanducng/dotfiles/issues/49)) ([4bf0583](https://github.com/vanducng/dotfiles/commit/4bf0583932f074629ad14d9d08feaef40bece257))
* **skhd:** add tldraw offline shortcut ([#54](https://github.com/vanducng/dotfiles/issues/54)) ([ef25212](https://github.com/vanducng/dotfiles/commit/ef252128560d4459f6b8736f6965d572eb7c8c22))


### Bug Fixes

* restored desktop and editor workflows ([#53](https://github.com/vanducng/dotfiles/issues/53)) ([dd32a15](https://github.com/vanducng/dotfiles/commit/dd32a15f5c013c75c3ec1a7caf9c6bc2de641ca3))
* **zsh:** front mise go bin in PATH to fix go tool/GOROOT mismatch ([c2cfb12](https://github.com/vanducng/dotfiles/commit/c2cfb12fe1a2c8453ee000a131cae070b7e3189c))

## [0.6.0](https://github.com/vanducng/dotfiles/compare/v0.5.0...v0.6.0) (2026-07-03)


### Bug Fixes

* **tmux:** resolved hinted worktree paths ([#43](https://github.com/vanducng/dotfiles/issues/43)) ([ef285e8](https://github.com/vanducng/dotfiles/commit/ef285e81710a1509b543432610f136c35c67f920))

## [0.5.0](https://github.com/vanducng/dotfiles/compare/v0.4.0...v0.5.0) (2026-07-03)


### Features

* **codex:** add [agents] block to tune native subagents ([3c3a5a2](https://github.com/vanducng/dotfiles/commit/3c3a5a24458ce702ed5952be0d19314e02d3b259))
* **codex:** track ~/.codex/hooks.json in dotfiles ([2c4cd7b](https://github.com/vanducng/dotfiles/commit/2c4cd7bc397b1b311ebf7d7176f931d63c6e5ee4))
* **miu:** tracked miu-cr config ([#33](https://github.com/vanducng/dotfiles/issues/33)) ([2758751](https://github.com/vanducng/dotfiles/commit/2758751afa3decbe5de3218469a9de484c0b8a8f))


### Bug Fixes

* harden agent hooks and desktop placement ([b4ee388](https://github.com/vanducng/dotfiles/commit/b4ee388f27c201329e53f03d0b18de52e995e540))
* **skhd:** reassign meh app launchers ([#39](https://github.com/vanducng/dotfiles/issues/39)) ([3381452](https://github.com/vanducng/dotfiles/commit/3381452fc99bafbb4e667551393087b90e94d91e))
* **skhd:** swap Zalo and Telegram launchers ([#41](https://github.com/vanducng/dotfiles/issues/41)) ([fed328a](https://github.com/vanducng/dotfiles/commit/fed328a68b1a71b4c7117528d88a7a3a64a8cd70))

## [0.4.0](https://github.com/vanducng/dotfiles/compare/v0.3.0...v0.4.0) (2026-07-03)


### Features

* **codex:** add [agents] block to tune native subagents ([3c3a5a2](https://github.com/vanducng/dotfiles/commit/3c3a5a24458ce702ed5952be0d19314e02d3b259))
* **codex:** track ~/.codex/hooks.json in dotfiles ([2c4cd7b](https://github.com/vanducng/dotfiles/commit/2c4cd7bc397b1b311ebf7d7176f931d63c6e5ee4))
* **miu:** tracked miu-cr config ([#33](https://github.com/vanducng/dotfiles/issues/33)) ([2758751](https://github.com/vanducng/dotfiles/commit/2758751afa3decbe5de3218469a9de484c0b8a8f))
* **skhd:** rebind Cursor to meh-f, add cmd+ctrl arrow display moves ([315378a](https://github.com/vanducng/dotfiles/commit/315378a49610d150a6e3e113557137b10813998a))


### Bug Fixes

* harden agent hooks and desktop placement ([b4ee388](https://github.com/vanducng/dotfiles/commit/b4ee388f27c201329e53f03d0b18de52e995e540))
* **skhd:** reassign meh app launchers ([#39](https://github.com/vanducng/dotfiles/issues/39)) ([3381452](https://github.com/vanducng/dotfiles/commit/3381452fc99bafbb4e667551393087b90e94d91e))

## [0.3.0](https://github.com/vanducng/dotfiles/compare/v0.2.0...v0.3.0) (2026-06-30)


### Features

* **codex:** add [agents] block to tune native subagents ([3c3a5a2](https://github.com/vanducng/dotfiles/commit/3c3a5a24458ce702ed5952be0d19314e02d3b259))
* **codex:** track ~/.codex/hooks.json in dotfiles ([2c4cd7b](https://github.com/vanducng/dotfiles/commit/2c4cd7bc397b1b311ebf7d7176f931d63c6e5ee4))
* **miu:** tracked miu-cr config ([#33](https://github.com/vanducng/dotfiles/issues/33)) ([2758751](https://github.com/vanducng/dotfiles/commit/2758751afa3decbe5de3218469a9de484c0b8a8f))
* **skhd:** rebind Cursor to meh-f, add cmd+ctrl arrow display moves ([315378a](https://github.com/vanducng/dotfiles/commit/315378a49610d150a6e3e113557137b10813998a))
* **tmux:** make space toggle last window ([#27](https://github.com/vanducng/dotfiles/issues/27)) ([84a42d2](https://github.com/vanducng/dotfiles/commit/84a42d29960ec55ee3ccee2e8ab782ce6c3fc7e3))


### Bug Fixes

* harden agent hooks and desktop placement ([b4ee388](https://github.com/vanducng/dotfiles/commit/b4ee388f27c201329e53f03d0b18de52e995e540))
* **zsh:** stop hard-setting GOROOT — let mise own go ([#25](https://github.com/vanducng/dotfiles/issues/25)) ([6145e1f](https://github.com/vanducng/dotfiles/commit/6145e1f014dcadee2792340edd5be94f8f8bee6d))

## [0.2.0](https://github.com/vanducng/dotfiles/compare/v0.1.0...v0.2.0) (2026-06-27)


### Features

* **ci:** register browser automation CLIs as optional deps ([#21](https://github.com/vanducng/dotfiles/issues/21)) ([61d3eb5](https://github.com/vanducng/dotfiles/commit/61d3eb5af488f8a0600ad3a1829615d0402cbbe8))
* **codex:** add [agents] block to tune native subagents ([3c3a5a2](https://github.com/vanducng/dotfiles/commit/3c3a5a24458ce702ed5952be0d19314e02d3b259))
* **codex:** track ~/.codex/hooks.json in dotfiles ([2c4cd7b](https://github.com/vanducng/dotfiles/commit/2c4cd7bc397b1b311ebf7d7176f931d63c6e5ee4))
* **miu:** tracked miu-cr config ([#33](https://github.com/vanducng/dotfiles/issues/33)) ([2758751](https://github.com/vanducng/dotfiles/commit/2758751afa3decbe5de3218469a9de484c0b8a8f))
* **skhd:** rebind Cursor to meh-f, add cmd+ctrl arrow display moves ([315378a](https://github.com/vanducng/dotfiles/commit/315378a49610d150a6e3e113557137b10813998a))
* **tmux:** make space toggle last window ([#27](https://github.com/vanducng/dotfiles/issues/27)) ([84a42d2](https://github.com/vanducng/dotfiles/commit/84a42d29960ec55ee3ccee2e8ab782ce6c3fc7e3))


### Bug Fixes

* **zsh:** stop hard-setting GOROOT — let mise own go ([#25](https://github.com/vanducng/dotfiles/issues/25)) ([6145e1f](https://github.com/vanducng/dotfiles/commit/6145e1f014dcadee2792340edd5be94f8f8bee6d))

## [0.1.0](https://github.com/vanducng/dotfiles/compare/v0.5.0...v0.1.0) (2026-06-25)


### Features

* add .claude file to project root for easier access ([fbe6828](https://github.com/vanducng/dotfiles/commit/fbe682888e08d97193cb002f1490aa59f84ab291))
* add atuin alias backup and restore system ([b316731](https://github.com/vanducng/dotfiles/commit/b316731b9de5bc43ea1b13b940a74a93aed400a0))
* add Claude Code configuration to dotfiles ([3374ec1](https://github.com/vanducng/dotfiles/commit/3374ec1c85bf5d93bf69591824ba2d1fa4e850c6))
* add codex usage-limit reset notifier ([73370aa](https://github.com/vanducng/dotfiles/commit/73370aad958a241d06d62b7dba11c55c1f9f9080))
* add comprehensive CLAUDE.md with data engineering guidelines ([b686a31](https://github.com/vanducng/dotfiles/commit/b686a31edbdb969e23cb93157a0f85d26a76a03e))
* add lazygit configuration and update Makefile ([9548258](https://github.com/vanducng/dotfiles/commit/9548258c6a97ca931a05f346e472dc60f2ccd2d6))
* add light/dark mode toggle button ([f396ab8](https://github.com/vanducng/dotfiles/commit/f396ab86106a810d8e87df27409b92a849dd8895))
* add MiuMun release-please automation ([#17](https://github.com/vanducng/dotfiles/issues/17)) ([8b3f880](https://github.com/vanducng/dotfiles/commit/8b3f880d959dfa7d43a0a5be6602875107656b8d))
* add pre-commit hook for secret detection ([4b80dc5](https://github.com/vanducng/dotfiles/commit/4b80dc5a3b9275653c5504dde7a4c2c37743ea1d))
* add taskwarrior config ([4f19afd](https://github.com/vanducng/dotfiles/commit/4f19afd774d40de092ed5d0e24edb018a25de162))
* Add yazi and zathura ([be6bb1c](https://github.com/vanducng/dotfiles/commit/be6bb1cb74ad55f00981b3d3e62e81c45ff6b956))
* add zen mode keybindings for full screen and session-wide exit ([773ba78](https://github.com/vanducng/dotfiles/commit/773ba78f91a2ce9445914df19e1e67e9c3d9e8b0))
* add zen mode preservation for telescope file selection ([943cb3c](https://github.com/vanducng/dotfiles/commit/943cb3c53138bac07dd023f838c08d6a0e744d00))
* added atuin config ([5347976](https://github.com/vanducng/dotfiles/commit/53479760b2abdb6ff9c443cb923ef6cfcd03e8a2))
* added dbee config ([6113f21](https://github.com/vanducng/dotfiles/commit/6113f2141d76682c1d6c85ca3904f99caee9a293))
* added dbt plugin ([a44a10f](https://github.com/vanducng/dotfiles/commit/a44a10fdf6482183872a18fdae9ef995dd6d1272))
* added ghostty config ([ebea746](https://github.com/vanducng/dotfiles/commit/ebea74610a23ff27206338ec1800fd719e6a3350))
* added hammerspoon ([445c7c5](https://github.com/vanducng/dotfiles/commit/445c7c56075154fde79fe835c6c5ba3152b5aa95))
* added mise config ([29b18e1](https://github.com/vanducng/dotfiles/commit/29b18e19ffc06bf64c36f615b7ad1c07018bfdf8))
* added new command ([30fb785](https://github.com/vanducng/dotfiles/commit/30fb7853c254b9c69fd290d0a9962bf08c04b166))
* added nushell ([58c78a6](https://github.com/vanducng/dotfiles/commit/58c78a69673cc532736c776c6f9e987b59e8405c))
* added nvim config ([872d70f](https://github.com/vanducng/dotfiles/commit/872d70fae00cf869502b7fe2ac3f91e9d114f3a7))
* added nvim vscode configs ([c81f7e7](https://github.com/vanducng/dotfiles/commit/c81f7e7dd25a7e76b543f60209e035ac6419bf76))
* added nvm config ([b9c80b4](https://github.com/vanducng/dotfiles/commit/b9c80b45f5f7e5baf89a2effbe2bd0f0db0cf83c))
* added yazi ([90c789d](https://github.com/vanducng/dotfiles/commit/90c789df00a475f511dd3eb06b00147e54c759b1))
* added zen mode ([f271be3](https://github.com/vanducng/dotfiles/commit/f271be36958fa0f9d49180cdd99914e47aadd5e8))
* **auth:** add JWT authentication to API ([468c918](https://github.com/vanducng/dotfiles/commit/468c918f56c7017350d5f1749ac8cf44f465076c))
* **ci:** register browser automation CLIs as optional deps ([#21](https://github.com/vanducng/dotfiles/issues/21)) ([61d3eb5](https://github.com/vanducng/dotfiles/commit/61d3eb5af488f8a0600ad3a1829615d0402cbbe8))
* **codex:** add [agents] block to tune native subagents ([3c3a5a2](https://github.com/vanducng/dotfiles/commit/3c3a5a24458ce702ed5952be0d19314e02d3b259))
* **codex:** expand config, add miudb/node_repl MCP servers and plugins ([03944f5](https://github.com/vanducng/dotfiles/commit/03944f567458f424b30e02aeb2f4e6658920a361))
* **codex:** manage config with dotfiles ([b359542](https://github.com/vanducng/dotfiles/commit/b359542e0d0406c496da32dfbd82441a13710fd7))
* **codex:** track ~/.codex/hooks.json in dotfiles ([2c4cd7b](https://github.com/vanducng/dotfiles/commit/2c4cd7bc397b1b311ebf7d7176f931d63c6e5ee4))
* **config:** update starship prompt ([b50dc49](https://github.com/vanducng/dotfiles/commit/b50dc49f26979659aad70a9ddb95d5578678984f))
* **delta:** add git diff configuration ([0b6fa0a](https://github.com/vanducng/dotfiles/commit/0b6fa0a3c2551a2a34d5a0bf05d0be79e13fb1f0))
* disable neovim features, auto suggestion for dbee cmp, refresh nvim script ([fc4db36](https://github.com/vanducng/dotfiles/commit/fc4db3628661509a34f05c44b1ef5ba0d0a8cabf))
* disable verbose notifications during SQL execution ([4a91ba9](https://github.com/vanducng/dotfiles/commit/4a91ba995fa5b76357bc8d7357612157c817f514))
* **dotfiles:** configure codex and yabai workflow ([2f5655c](https://github.com/vanducng/dotfiles/commit/2f5655ce809e4ead9a4cbd4a7466579b122b79f1))
* **dotfiles:** Update application shortcuts and workspace configurations ([9dece5f](https://github.com/vanducng/dotfiles/commit/9dece5fe1a686d59c0d0849ef9b04ebc23cc3127))
* enhance atuin configuration and zsh integration ([de9cd0d](https://github.com/vanducng/dotfiles/commit/de9cd0dfe1d0a14919130964863838ef92e081e0))
* enhance SQL error handling with user-friendly messages ([cc75a4f](https://github.com/vanducng/dotfiles/commit/cc75a4fb308e050d90d8b204019806d0eb871b16))
* enhanced tmux binding and switch to supermaven for auto completion ([fa04d26](https://github.com/vanducng/dotfiles/commit/fa04d26c751730fe78a95be039f08434f1d82b62))
* enhanced tmux layout ([7823859](https://github.com/vanducng/dotfiles/commit/78238592bc2ea227ff94b716deee9c8d2f263977))
* **ghostty:** add tmux-style leader-chord keybindings for pane control ([52a1613](https://github.com/vanducng/dotfiles/commit/52a161341ad4143269b7db7dad05b7ad0f743c68))
* **gui:** add new theme configurations ([8e773dc](https://github.com/vanducng/dotfiles/commit/8e773dcc89efbc87349895fe1760b131085bad4d))
* **hammerspoon,nvim:** route markdown + media through file-browser skill ([f6d90a5](https://github.com/vanducng/dotfiles/commit/f6d90a5005de6b7c2f8605a345a8904cf3daedf9))
* **hammerspoon,nvim:** route markdown + media through file-browser skill ([8df7400](https://github.com/vanducng/dotfiles/commit/8df74004c8d22a65d7f6c15ff4cdafb6f622a747))
* **hammerspoon,nvim:** route markdown rendering through Dia + ~/skills ([af3ecb6](https://github.com/vanducng/dotfiles/commit/af3ecb65700222089d5a33d94fec8205bf1ea67b))
* **hammerspoon:** add canvas clock with date line, rebind Hyper+C ([99f9bb1](https://github.com/vanducng/dotfiles/commit/99f9bb18aa685dd017d3b78310aeba6c67ceb544))
* **hammerspoon:** enhance window cycling logic ([dc0d389](https://github.com/vanducng/dotfiles/commit/dc0d389314087e60943f994aad393169e347ef88))
* **hammerspoon:** improve window cycling with space-scoped logic ([967d777](https://github.com/vanducng/dotfiles/commit/967d7777378ed7ba852161a1a40081d680aac624))
* **hooks:** parameterize attention-sound for Claude Code and Codex reuse ([3e2290a](https://github.com/vanducng/dotfiles/commit/3e2290ae2239c856ccf283c9f292b4464b7c1f2d))
* implement comprehensive CI/CD pipeline for dotfiles ([fbca682](https://github.com/vanducng/dotfiles/commit/fbca68279f920b9f62a957ae1faf7693f797ed73))
* Initial commit ([1720e07](https://github.com/vanducng/dotfiles/commit/1720e0718d588d5074feb7e20069932252d88890))
* **lazygit:** add custom Neovim commands for editing files ([807ef1f](https://github.com/vanducng/dotfiles/commit/807ef1ff12f565430d4e97bb86a36e50ae8cc2ee))
* make neo-tree background transparent ([9dd03e5](https://github.com/vanducng/dotfiles/commit/9dd03e50e1e23e346f2294715112977e7083591f))
* make neo-tree background transparent ([3780673](https://github.com/vanducng/dotfiles/commit/3780673f1f9fb39486b7119b1918a583fba0dbd1))
* migrate all shell aliases to atuin dotfiles management ([efbe08b](https://github.com/vanducng/dotfiles/commit/efbe08bc3690fc9716390c8bb0875d7762c9bd59))
* **nvim,hammerspoon:** use .git root as file-browser sidebar root ([cb2fcc2](https://github.com/vanducng/dotfiles/commit/cb2fcc20703d4a16d7edc47fb8f4c3829778b8c7))
* **nvim,hammerspoon:** use .git root as file-browser sidebar root ([6132c5f](https://github.com/vanducng/dotfiles/commit/6132c5f81777fe01d790d777bb0ab6ce23c7a3ef))
* **nvim:** add comprehensive AI coding assistance ([a5af3be](https://github.com/vanducng/dotfiles/commit/a5af3bef232549af0a72535ae07cdd86acaa1c5d))
* **nvim:** add kulala.nvim for HTTP request testing ([d722caf](https://github.com/vanducng/dotfiles/commit/d722cafa26cde308f25db3e4a8badb88c1763026))
* **nvim:** add mermaid export to clipboard ([d9962ee](https://github.com/vanducng/dotfiles/commit/d9962eedf87bde60cbf969c00a85738b39da71c7))
* **nvim:** add sqlit plugin, disable dbee ([5eb4da5](https://github.com/vanducng/dotfiles/commit/5eb4da55cfdcad73ae306c7593d65e1627fb7613))
* **nvim:** enhance database tools with Snowflake MFA support ([731670b](https://github.com/vanducng/dotfiles/commit/731670ba1e0187e46cb62a4dc7b6911ea7701fb1))
* **nvim:** improve development tooling and formatting ([f261339](https://github.com/vanducng/dotfiles/commit/f2613390d1e5187397d9935db7369bf13b8c6dfd))
* **nvim:** increase mermaid export resolution to 3x scale ([997140a](https://github.com/vanducng/dotfiles/commit/997140a75c5391d4d19d8da7d41751e9f92dbceb))
* **nvim:** migrate nvim-treesitter master -&gt; main branch ([945c82a](https://github.com/vanducng/dotfiles/commit/945c82ab71d88bf047edbfe527bffbd3398add3b))
* **nvim:** replace dbee with miu-db ([3279f81](https://github.com/vanducng/dotfiles/commit/3279f812720e1c22cac0adea475e13c404796428))
* **nvim:** upgrade AstroNvim ^5 -&gt; ^6 ([25f3da4](https://github.com/vanducng/dotfiles/commit/25f3da4eab9c50048c34401b6df29306a367ff2e))
* optimize zen mode and tmux improvements ([bedf8cb](https://github.com/vanducng/dotfiles/commit/bedf8cb671f74f1b027d62a7b2235f2a54eca242))
* prepare dotfiles for public release ([871b06e](https://github.com/vanducng/dotfiles/commit/871b06eb8d70a125cef8642e8f9c1f132c19f9d0))
* reactor ([24f573b](https://github.com/vanducng/dotfiles/commit/24f573b688bd130b4bf27f10aaa468e9a481c834))
* remove sketchybar ([5ddb18c](https://github.com/vanducng/dotfiles/commit/5ddb18c392d1852e296065480c3df7409cbe02a5))
* Reorganize dotfiles ([cc008fd](https://github.com/vanducng/dotfiles/commit/cc008fd29487188aa010943084765cd9b7544001))
* restructure the folder ([4700508](https://github.com/vanducng/dotfiles/commit/47005085515e828be3bfbe30cc2a11d5780f0090))
* simplify dbee configuration and disable verbose notifications ([756c86c](https://github.com/vanducng/dotfiles/commit/756c86c4b7014e7ff87d7b269b20fc4e07356466))
* **skhd,yabai:** add Cliq launcher on space 14 ([472a434](https://github.com/vanducng/dotfiles/commit/472a4343373a186a53e759fc9134f32b2243b9a3))
* **skhd,yabai:** add Herd launcher on space 8, move Arc to space 13 ([b740b21](https://github.com/vanducng/dotfiles/commit/b740b211fd7803e174d19d860fa8d3e4be2dacae))
* **skhd,yabai:** add WhatsApp launcher on space 13 ([#11](https://github.com/vanducng/dotfiles/issues/11)) ([c947db0](https://github.com/vanducng/dotfiles/commit/c947db03142b8dc77d900ea564ad2483af49c43a))
* **skhd:** add Codex desktop shortcut ([dbe791d](https://github.com/vanducng/dotfiles/commit/dbe791d310a1afd31071856da25a2dea5c03e6ac))
* **skhd:** rebind Cursor to meh-f, add cmd+ctrl arrow display moves ([315378a](https://github.com/vanducng/dotfiles/commit/315378a49610d150a6e3e113557137b10813998a))
* **starship:** enable direnv integration ([45cf562](https://github.com/vanducng/dotfiles/commit/45cf562f21732579b25a807cd928908aefb0eba7))
* **stow:** add borders and rift window management configs ([1c5042f](https://github.com/vanducng/dotfiles/commit/1c5042f285408b5094ee73e661d761706ff4aff4))
* **system:** update shortcuts and shell environment ([938858f](https://github.com/vanducng/dotfiles/commit/938858f138b0d0aad05e7cdb91ab00477432a5ce))
* **tmux-agent:** add skip-permissions flag, slash cmd and file ref support ([f589505](https://github.com/vanducng/dotfiles/commit/f5895055b008323c80a42340994e8f11558dca76))
* **tmux-sessionizer:** enhance directory search and quoting ([a4fe652](https://github.com/vanducng/dotfiles/commit/a4fe652814bf1521d5dd58a970e4778e6bcfa052))
* **tmux:** add key bindings for pane selection and vim-tmux-navigator integration ([8819132](https://github.com/vanducng/dotfiles/commit/88191325f315b7d0f9645b873f46d49c3a5fc671))
* **tmux:** add layout prefix mode with multiple pane layouts ([7d5427f](https://github.com/vanducng/dotfiles/commit/7d5427fb5504e2f8a49040cdc58806b601fb3ec4))
* **tmux:** add new key bindings and plugins ([3336e63](https://github.com/vanducng/dotfiles/commit/3336e631317f7709bf53693b9ec498aa8067ee2a))
* **tmux:** add tmux-agent for worktree-based Claude Code workflows ([31ab1ca](https://github.com/vanducng/dotfiles/commit/31ab1ca066d9286e69410ad51f1818cb81d7ca7d))
* **tmux:** improve fingers patterns, enable alt-action, ship open-path ([#10](https://github.com/vanducng/dotfiles/issues/10)) ([50f0a41](https://github.com/vanducng/dotfiles/commit/50f0a410d828428b35137b8a6c5e2b2bbdd8ada4))
* **tmux:** make space toggle last window ([#27](https://github.com/vanducng/dotfiles/issues/27)) ([84a42d2](https://github.com/vanducng/dotfiles/commit/84a42d29960ec55ee3ccee2e8ab782ce6c3fc7e3))
* **tmux:** optimize layout for agentic coding workflow ([4a28ac5](https://github.com/vanducng/dotfiles/commit/4a28ac5e46a2fbaff52609adf4ae47159b1914aa))
* **tmux:** optimize layout for agentic coding workflow ([79c3bc7](https://github.com/vanducng/dotfiles/commit/79c3bc7c654ce1aa1f14aa4710273d01c2ebe3cd))
* **tmux:** update tmux configuration for improved usability ([20ab3de](https://github.com/vanducng/dotfiles/commit/20ab3de7f5efbed60d24ece95ce5395645e1933a))
* unified AI completion system with conflict prevention ([5aaaaca](https://github.com/vanducng/dotfiles/commit/5aaaaca580777665bba44f2ad611b127143600e5))
* update Claude configuration with SuperClaude v2 ([8437e46](https://github.com/vanducng/dotfiles/commit/8437e46158e4ca124f24f49462045878b7a40248))
* update Claude configuration with SuperClaude v2 ([ca1a641](https://github.com/vanducng/dotfiles/commit/ca1a6417db508617ff31e6ed1016534d443fc44c))
* update dbee config to use 'x' for disconnect toggle ([d25a7ab](https://github.com/vanducng/dotfiles/commit/d25a7ab289eb384b96425ce10e30c899c9ea3f2b))
* update nvim vscode ([3048db4](https://github.com/vanducng/dotfiles/commit/3048db42076c28128d5e7debebcdcf4d7c4a25da))
* **yabai:** auto-unzoom on new window creation ([29e3198](https://github.com/vanducng/dotfiles/commit/29e3198671198f379db84b5f7d495733de889f25))
* **yabai:** disable window opacity and update rules ([1a14d2c](https://github.com/vanducng/dotfiles/commit/1a14d2ce223d2ed49af813703c10fe97b40ae86d))
* **yabai:** pin chat/browser apps to spaces 8-12 ([7f9cd8a](https://github.com/vanducng/dotfiles/commit/7f9cd8a4a8be460c44f62d759af30a9c780e6f35))
* **yazi:** improve navigation keybindings and add initial-dir plugin ([928f9b0](https://github.com/vanducng/dotfiles/commit/928f9b08db2d2d6239efb5b357ecfdd4b35fe9a5))
* **zsh:** source bruin env ([7be28ff](https://github.com/vanducng/dotfiles/commit/7be28ffc760aec2ed50085224821f7d6b388889f))


### Bug Fixes

* add CNAME file to preserve custom domain on deploy ([45f0171](https://github.com/vanducng/dotfiles/commit/45f0171f8eccf8f059e85559ade0bfa7d8d3aef9))
* add jsonc parser for JSON with comments support ([3159eb0](https://github.com/vanducng/dotfiles/commit/3159eb0d65b3c8909e2cd3d087dba73d21e883ee))
* add missing dockerfile and hcl parsers to nvim refresh script ([f44d853](https://github.com/vanducng/dotfiles/commit/f44d8532c59ceaa033ce69de58cbf11ed96a86cf))
* add safety checks for pyenv and gh initialization in zshrc ([1b88095](https://github.com/vanducng/dotfiles/commit/1b880958ca76c499c237cb7ba89d02c897a8b84f))
* add tsx and jsx parsers for React support ([9d92f91](https://github.com/vanducng/dotfiles/commit/9d92f9122e8780090d83ca5b3545f7974a7befe9))
* anchor first managed release to v0.1.0 ([#19](https://github.com/vanducng/dotfiles/issues/19)) ([5b16e5b](https://github.com/vanducng/dotfiles/commit/5b16e5b6a1b28a5d1afaeac51989ef055521b0ce))
* change Copilot next suggestion from Ctrl+i to Ctrl+n ([8214d8b](https://github.com/vanducng/dotfiles/commit/8214d8b45dc23ec0fc4c4be92c3f9add30cb2c93))
* comprehensive E5101 error prevention with type safety ([1f5e14f](https://github.com/vanducng/dotfiles/commit/1f5e14f18ce93d36165a4f249bf6e100e1064931))
* **docs:** restore default markdown extensions (fenced code, toc, tables) ([4633efc](https://github.com/vanducng/dotfiles/commit/4633efcb068e671fae1a55ca9f4d6d5a24f5d830))
* duplicate claude alias ([cd47453](https://github.com/vanducng/dotfiles/commit/cd47453080890f0c8a704aa6e4dea6ac414cb3ba))
* ensure blink.cmp configuration is properly applied for cmp-dbee ([0419272](https://github.com/vanducng/dotfiles/commit/0419272da7d0b0245970ddb6db2186fee995153d))
* ensure utils functions respect disabled connections ([497b0cd](https://github.com/vanducng/dotfiles/commit/497b0cd338f512ce8123ab18ad678681db35b033))
* **ghostty,ci:** keep skhd alive under SKE + ship wtfutil dashboard ([#12](https://github.com/vanducng/dotfiles/issues/12)) ([40b1566](https://github.com/vanducng/dotfiles/commit/40b15660b3f7c5f2a43fa75243a220dacbb9a234))
* **hammerspoon:** open file-browser URLs in Dia, not Arc ([209ad55](https://github.com/vanducng/dotfiles/commit/209ad55934bd4b5a6f5e4acc78276e6ee6b69383))
* **hammerspoon:** open file-browser URLs in Dia, not Arc ([00a19f2](https://github.com/vanducng/dotfiles/commit/00a19f2be5ca1846b2e483b6bcc6c09b3fecbf40))
* implement code review improvements ([09d6dd1](https://github.com/vanducng/dotfiles/commit/09d6dd1bf0f277addc2e6d08ddaf323ed8aeaa90))
* number display on tmux ([a836682](https://github.com/vanducng/dotfiles/commit/a836682deaf0c6dcf5b44282ded4ac01c555410c))
* **nvim:** correct miu-db plugin directory path ([2c4cbc0](https://github.com/vanducng/dotfiles/commit/2c4cbc01baf4a09c3ecb061f5940312ad6165f27))
* **nvim:** move pyright disable from config to handlers (v6 compat) ([7f4a777](https://github.com/vanducng/dotfiles/commit/7f4a77737af75824e5ec11fa391fe482115badcd))
* **nvim:** use colon syntax for client:supports_method ([1b38b19](https://github.com/vanducng/dotfiles/commit/1b38b199a510821884cde18cd5d48e758898eb8e))
* **nvim:** use vim.diagnostic.enable(bool, filter) API for nvim 0.12 ([ffc7d99](https://github.com/vanducng/dotfiles/commit/ffc7d993eded7af501730a41af0dbdf98bdc89f1))
* prevent VSCode from globally activating Python virtual environments ([ee4b2b0](https://github.com/vanducng/dotfiles/commit/ee4b2b0595bfbeb242cd1cec05b880e2dbe7a8f5))
* relative path symlink ([1f5d642](https://github.com/vanducng/dotfiles/commit/1f5d642191d07f5d418e49a742574313bd7824c9))
* remove duplicate cmp-dbee setup and add debug output ([d17276f](https://github.com/vanducng/dotfiles/commit/d17276f95a21e2446df23b0ffe882fa34d1e3948))
* remove neocodeium from lazy-lock.json ([fa3f630](https://github.com/vanducng/dotfiles/commit/fa3f6303ff8f4d533cdb85d32121e53408e6f8c8))
* replace neo-tree with yazi+oil for better performance and stability ([a987f8a](https://github.com/vanducng/dotfiles/commit/a987f8a068c811520ec015ce101e286924e3eef4))
* resolve atuin keybinding conflict with zsh-vi-mode ([1f4fdca](https://github.com/vanducng/dotfiles/commit/1f4fdca63289aa5d227fcac596c114094a4e9d39))
* resolve CI/CD pipeline failures ([915e5fe](https://github.com/vanducng/dotfiles/commit/915e5fef9a65b6b6143240cae1d115fc004bb1b6))
* resolve neocodeium load error and revise copilot keymaps ([57b829d](https://github.com/vanducng/dotfiles/commit/57b829dfeef1238cfcc217a09801011377a076ba))
* resolve nvim treesitter ARM64 architecture mismatch and neo-tree refresh errors ([9f87ffe](https://github.com/vanducng/dotfiles/commit/9f87ffe3665d6679607d5c59ada26963f98871f3))
* resolve Tab key issue in Neovim insert mode ([d55c468](https://github.com/vanducng/dotfiles/commit/d55c4683dfc324123c035ab8c5d01e9d8a973dfb))
* simplify nvim-dbee setup to prevent window_layout nil error ([5452f02](https://github.com/vanducng/dotfiles/commit/5452f02aebf662a02b000a786ff183ad955fcabf))
* **skhd:** open Slack on display 2 ([bc62100](https://github.com/vanducng/dotfiles/commit/bc62100e94feff496c40bcf84dfbb2bef8b37a30))
* **tmux-sessionizer:** attach instead of switch when outside tmux ([452d33f](https://github.com/vanducng/dotfiles/commit/452d33f57a2f7133ee261f656b8d8258d7d58292))
* **tmux:** ensure tmux-fingers binding registers on fresh server start ([3ae9b69](https://github.com/vanducng/dotfiles/commit/3ae9b691981642396548117d125e36e39c2c7228))
* **tmux:** stay in copy mode after yanking text ([17dcd2c](https://github.com/vanducng/dotfiles/commit/17dcd2c3a7f819ade74f154f03b15f4b4c7ea62c))
* use correct zensical dark mode config (slate scheme) ([7e6e4d3](https://github.com/vanducng/dotfiles/commit/7e6e4d3bbdb87317cd91833f7e868db5c6cd17b6))
* use full path for arc command in hammerspoon init.lua ([892af3e](https://github.com/vanducng/dotfiles/commit/892af3e8702ff8f8dcbad5ce42676d8d5e165fb5))
* **yabai:** force-float Alter so it never re-tiles after moves ([#13](https://github.com/vanducng/dotfiles/issues/13)) ([1fbaef0](https://github.com/vanducng/dotfiles/commit/1fbaef05d05918c1f3b18d8eceaba2db8c45d27d))
* yazi navigation and keymap configuration ([bed47fd](https://github.com/vanducng/dotfiles/commit/bed47fdbdaedef332ab4a6faa3d73ed4e44fb5ad))
* zen config ([a240063](https://github.com/vanducng/dotfiles/commit/a240063dd2789a9068d6cf697601b48685152544))
* **zsh:** allow homebrew metadata refresh ([61167cd](https://github.com/vanducng/dotfiles/commit/61167cd2da1173f399f1edd69bbea82a53393d25))
* **zsh:** stop hard-setting GOROOT — let mise own go ([#25](https://github.com/vanducng/dotfiles/issues/25)) ([6145e1f](https://github.com/vanducng/dotfiles/commit/6145e1f014dcadee2792340edd5be94f8f8bee6d))


### Performance Improvements

* major zsh startup optimization - 72% faster startup ([9db10d9](https://github.com/vanducng/dotfiles/commit/9db10d966ca0dd6ad473739c00c11c1f85894ba4))
* optimize zsh startup time and add direnv config ([2381737](https://github.com/vanducng/dotfiles/commit/23817371ec66b4ca612d0ebdeb066f14b7f0469a))
* use blink-wrapper to eliminate completion lag ([fdc67d3](https://github.com/vanducng/dotfiles/commit/fdc67d3736f1e492b722a8d54f268a0d40970765))

## [0.5.0](https://github.com/vanducng/dotfiles/compare/v0.4.0...v0.5.0) (2026-06-25)


### Features

* **codex:** track ~/.codex/hooks.json in dotfiles ([2c4cd7b](https://github.com/vanducng/dotfiles/commit/2c4cd7bc397b1b311ebf7d7176f931d63c6e5ee4))

## [0.4.0](https://github.com/vanducng/dotfiles/compare/v0.3.0...v0.4.0) (2026-06-19)


### Features

* **skhd:** rebind Cursor to meh-f, add cmd+ctrl arrow display moves ([315378a](https://github.com/vanducng/dotfiles/commit/315378a49610d150a6e3e113557137b10813998a))

## [0.3.0](https://github.com/vanducng/dotfiles/compare/v0.2.1...v0.3.0) (2026-06-17)


### Features

* **tmux:** make space toggle last window ([#27](https://github.com/vanducng/dotfiles/issues/27)) ([84a42d2](https://github.com/vanducng/dotfiles/commit/84a42d29960ec55ee3ccee2e8ab782ce6c3fc7e3))

## [0.2.1](https://github.com/vanducng/dotfiles/compare/v0.2.0...v0.2.1) (2026-06-17)


### Bug Fixes

* **zsh:** stop hard-setting GOROOT — let mise own go ([#25](https://github.com/vanducng/dotfiles/issues/25)) ([6145e1f](https://github.com/vanducng/dotfiles/commit/6145e1f014dcadee2792340edd5be94f8f8bee6d))

## [0.2.0](https://github.com/vanducng/dotfiles/compare/v0.1.0...v0.2.0) (2026-06-12)


### Features

* **ci:** register browser automation CLIs as optional deps ([#21](https://github.com/vanducng/dotfiles/issues/21)) ([61d3eb5](https://github.com/vanducng/dotfiles/commit/61d3eb5af488f8a0600ad3a1829615d0402cbbe8))

## 0.1.0 (2026-06-07)


### Features

* add .claude file to project root for easier access ([fbe6828](https://github.com/vanducng/dotfiles/commit/fbe682888e08d97193cb002f1490aa59f84ab291))
* add atuin alias backup and restore system ([b316731](https://github.com/vanducng/dotfiles/commit/b316731b9de5bc43ea1b13b940a74a93aed400a0))
* add Claude Code configuration to dotfiles ([3374ec1](https://github.com/vanducng/dotfiles/commit/3374ec1c85bf5d93bf69591824ba2d1fa4e850c6))
* add codex usage-limit reset notifier ([73370aa](https://github.com/vanducng/dotfiles/commit/73370aad958a241d06d62b7dba11c55c1f9f9080))
* add comprehensive CLAUDE.md with data engineering guidelines ([b686a31](https://github.com/vanducng/dotfiles/commit/b686a31edbdb969e23cb93157a0f85d26a76a03e))
* add lazygit configuration and update Makefile ([9548258](https://github.com/vanducng/dotfiles/commit/9548258c6a97ca931a05f346e472dc60f2ccd2d6))
* add light/dark mode toggle button ([f396ab8](https://github.com/vanducng/dotfiles/commit/f396ab86106a810d8e87df27409b92a849dd8895))
* add MiuMun release-please automation ([#17](https://github.com/vanducng/dotfiles/issues/17)) ([8b3f880](https://github.com/vanducng/dotfiles/commit/8b3f880d959dfa7d43a0a5be6602875107656b8d))
* add pre-commit hook for secret detection ([4b80dc5](https://github.com/vanducng/dotfiles/commit/4b80dc5a3b9275653c5504dde7a4c2c37743ea1d))
* add taskwarrior config ([4f19afd](https://github.com/vanducng/dotfiles/commit/4f19afd774d40de092ed5d0e24edb018a25de162))
* Add yazi and zathura ([be6bb1c](https://github.com/vanducng/dotfiles/commit/be6bb1cb74ad55f00981b3d3e62e81c45ff6b956))
* add zen mode keybindings for full screen and session-wide exit ([773ba78](https://github.com/vanducng/dotfiles/commit/773ba78f91a2ce9445914df19e1e67e9c3d9e8b0))
* add zen mode preservation for telescope file selection ([943cb3c](https://github.com/vanducng/dotfiles/commit/943cb3c53138bac07dd023f838c08d6a0e744d00))
* added atuin config ([5347976](https://github.com/vanducng/dotfiles/commit/53479760b2abdb6ff9c443cb923ef6cfcd03e8a2))
* added dbee config ([6113f21](https://github.com/vanducng/dotfiles/commit/6113f2141d76682c1d6c85ca3904f99caee9a293))
* added dbt plugin ([a44a10f](https://github.com/vanducng/dotfiles/commit/a44a10fdf6482183872a18fdae9ef995dd6d1272))
* added ghostty config ([ebea746](https://github.com/vanducng/dotfiles/commit/ebea74610a23ff27206338ec1800fd719e6a3350))
* added hammerspoon ([445c7c5](https://github.com/vanducng/dotfiles/commit/445c7c56075154fde79fe835c6c5ba3152b5aa95))
* added mise config ([29b18e1](https://github.com/vanducng/dotfiles/commit/29b18e19ffc06bf64c36f615b7ad1c07018bfdf8))
* added new command ([30fb785](https://github.com/vanducng/dotfiles/commit/30fb7853c254b9c69fd290d0a9962bf08c04b166))
* added nushell ([58c78a6](https://github.com/vanducng/dotfiles/commit/58c78a69673cc532736c776c6f9e987b59e8405c))
* added nvim config ([872d70f](https://github.com/vanducng/dotfiles/commit/872d70fae00cf869502b7fe2ac3f91e9d114f3a7))
* added nvim vscode configs ([c81f7e7](https://github.com/vanducng/dotfiles/commit/c81f7e7dd25a7e76b543f60209e035ac6419bf76))
* added nvm config ([b9c80b4](https://github.com/vanducng/dotfiles/commit/b9c80b45f5f7e5baf89a2effbe2bd0f0db0cf83c))
* added yazi ([90c789d](https://github.com/vanducng/dotfiles/commit/90c789df00a475f511dd3eb06b00147e54c759b1))
* added zen mode ([f271be3](https://github.com/vanducng/dotfiles/commit/f271be36958fa0f9d49180cdd99914e47aadd5e8))
* **auth:** add JWT authentication to API ([468c918](https://github.com/vanducng/dotfiles/commit/468c918f56c7017350d5f1749ac8cf44f465076c))
* **codex:** expand config, add miudb/node_repl MCP servers and plugins ([03944f5](https://github.com/vanducng/dotfiles/commit/03944f567458f424b30e02aeb2f4e6658920a361))
* **codex:** manage config with dotfiles ([b359542](https://github.com/vanducng/dotfiles/commit/b359542e0d0406c496da32dfbd82441a13710fd7))
* **config:** update starship prompt ([b50dc49](https://github.com/vanducng/dotfiles/commit/b50dc49f26979659aad70a9ddb95d5578678984f))
* **delta:** add git diff configuration ([0b6fa0a](https://github.com/vanducng/dotfiles/commit/0b6fa0a3c2551a2a34d5a0bf05d0be79e13fb1f0))
* disable neovim features, auto suggestion for dbee cmp, refresh nvim script ([fc4db36](https://github.com/vanducng/dotfiles/commit/fc4db3628661509a34f05c44b1ef5ba0d0a8cabf))
* disable verbose notifications during SQL execution ([4a91ba9](https://github.com/vanducng/dotfiles/commit/4a91ba995fa5b76357bc8d7357612157c817f514))
* **dotfiles:** configure codex and yabai workflow ([2f5655c](https://github.com/vanducng/dotfiles/commit/2f5655ce809e4ead9a4cbd4a7466579b122b79f1))
* **dotfiles:** Update application shortcuts and workspace configurations ([9dece5f](https://github.com/vanducng/dotfiles/commit/9dece5fe1a686d59c0d0849ef9b04ebc23cc3127))
* enhance atuin configuration and zsh integration ([de9cd0d](https://github.com/vanducng/dotfiles/commit/de9cd0dfe1d0a14919130964863838ef92e081e0))
* enhance SQL error handling with user-friendly messages ([cc75a4f](https://github.com/vanducng/dotfiles/commit/cc75a4fb308e050d90d8b204019806d0eb871b16))
* enhanced tmux binding and switch to supermaven for auto completion ([fa04d26](https://github.com/vanducng/dotfiles/commit/fa04d26c751730fe78a95be039f08434f1d82b62))
* enhanced tmux layout ([7823859](https://github.com/vanducng/dotfiles/commit/78238592bc2ea227ff94b716deee9c8d2f263977))
* **ghostty:** add tmux-style leader-chord keybindings for pane control ([52a1613](https://github.com/vanducng/dotfiles/commit/52a161341ad4143269b7db7dad05b7ad0f743c68))
* **gui:** add new theme configurations ([8e773dc](https://github.com/vanducng/dotfiles/commit/8e773dcc89efbc87349895fe1760b131085bad4d))
* **hammerspoon,nvim:** route markdown + media through file-browser skill ([f6d90a5](https://github.com/vanducng/dotfiles/commit/f6d90a5005de6b7c2f8605a345a8904cf3daedf9))
* **hammerspoon,nvim:** route markdown + media through file-browser skill ([8df7400](https://github.com/vanducng/dotfiles/commit/8df74004c8d22a65d7f6c15ff4cdafb6f622a747))
* **hammerspoon,nvim:** route markdown rendering through Dia + ~/skills ([af3ecb6](https://github.com/vanducng/dotfiles/commit/af3ecb65700222089d5a33d94fec8205bf1ea67b))
* **hammerspoon:** add canvas clock with date line, rebind Hyper+C ([99f9bb1](https://github.com/vanducng/dotfiles/commit/99f9bb18aa685dd017d3b78310aeba6c67ceb544))
* **hammerspoon:** enhance window cycling logic ([dc0d389](https://github.com/vanducng/dotfiles/commit/dc0d389314087e60943f994aad393169e347ef88))
* **hammerspoon:** improve window cycling with space-scoped logic ([967d777](https://github.com/vanducng/dotfiles/commit/967d7777378ed7ba852161a1a40081d680aac624))
* **hooks:** parameterize attention-sound for Claude Code and Codex reuse ([3e2290a](https://github.com/vanducng/dotfiles/commit/3e2290ae2239c856ccf283c9f292b4464b7c1f2d))
* implement comprehensive CI/CD pipeline for dotfiles ([fbca682](https://github.com/vanducng/dotfiles/commit/fbca68279f920b9f62a957ae1faf7693f797ed73))
* Initial commit ([1720e07](https://github.com/vanducng/dotfiles/commit/1720e0718d588d5074feb7e20069932252d88890))
* **lazygit:** add custom Neovim commands for editing files ([807ef1f](https://github.com/vanducng/dotfiles/commit/807ef1ff12f565430d4e97bb86a36e50ae8cc2ee))
* make neo-tree background transparent ([9dd03e5](https://github.com/vanducng/dotfiles/commit/9dd03e50e1e23e346f2294715112977e7083591f))
* make neo-tree background transparent ([3780673](https://github.com/vanducng/dotfiles/commit/3780673f1f9fb39486b7119b1918a583fba0dbd1))
* migrate all shell aliases to atuin dotfiles management ([efbe08b](https://github.com/vanducng/dotfiles/commit/efbe08bc3690fc9716390c8bb0875d7762c9bd59))
* **nvim,hammerspoon:** use .git root as file-browser sidebar root ([cb2fcc2](https://github.com/vanducng/dotfiles/commit/cb2fcc20703d4a16d7edc47fb8f4c3829778b8c7))
* **nvim,hammerspoon:** use .git root as file-browser sidebar root ([6132c5f](https://github.com/vanducng/dotfiles/commit/6132c5f81777fe01d790d777bb0ab6ce23c7a3ef))
* **nvim:** add comprehensive AI coding assistance ([a5af3be](https://github.com/vanducng/dotfiles/commit/a5af3bef232549af0a72535ae07cdd86acaa1c5d))
* **nvim:** add kulala.nvim for HTTP request testing ([d722caf](https://github.com/vanducng/dotfiles/commit/d722cafa26cde308f25db3e4a8badb88c1763026))
* **nvim:** add mermaid export to clipboard ([d9962ee](https://github.com/vanducng/dotfiles/commit/d9962eedf87bde60cbf969c00a85738b39da71c7))
* **nvim:** add sqlit plugin, disable dbee ([5eb4da5](https://github.com/vanducng/dotfiles/commit/5eb4da55cfdcad73ae306c7593d65e1627fb7613))
* **nvim:** enhance database tools with Snowflake MFA support ([731670b](https://github.com/vanducng/dotfiles/commit/731670ba1e0187e46cb62a4dc7b6911ea7701fb1))
* **nvim:** improve development tooling and formatting ([f261339](https://github.com/vanducng/dotfiles/commit/f2613390d1e5187397d9935db7369bf13b8c6dfd))
* **nvim:** increase mermaid export resolution to 3x scale ([997140a](https://github.com/vanducng/dotfiles/commit/997140a75c5391d4d19d8da7d41751e9f92dbceb))
* **nvim:** migrate nvim-treesitter master -&gt; main branch ([945c82a](https://github.com/vanducng/dotfiles/commit/945c82ab71d88bf047edbfe527bffbd3398add3b))
* **nvim:** replace dbee with miu-db ([3279f81](https://github.com/vanducng/dotfiles/commit/3279f812720e1c22cac0adea475e13c404796428))
* **nvim:** upgrade AstroNvim ^5 -&gt; ^6 ([25f3da4](https://github.com/vanducng/dotfiles/commit/25f3da4eab9c50048c34401b6df29306a367ff2e))
* optimize zen mode and tmux improvements ([bedf8cb](https://github.com/vanducng/dotfiles/commit/bedf8cb671f74f1b027d62a7b2235f2a54eca242))
* prepare dotfiles for public release ([871b06e](https://github.com/vanducng/dotfiles/commit/871b06eb8d70a125cef8642e8f9c1f132c19f9d0))
* reactor ([24f573b](https://github.com/vanducng/dotfiles/commit/24f573b688bd130b4bf27f10aaa468e9a481c834))
* remove sketchybar ([5ddb18c](https://github.com/vanducng/dotfiles/commit/5ddb18c392d1852e296065480c3df7409cbe02a5))
* Reorganize dotfiles ([cc008fd](https://github.com/vanducng/dotfiles/commit/cc008fd29487188aa010943084765cd9b7544001))
* restructure the folder ([4700508](https://github.com/vanducng/dotfiles/commit/47005085515e828be3bfbe30cc2a11d5780f0090))
* simplify dbee configuration and disable verbose notifications ([756c86c](https://github.com/vanducng/dotfiles/commit/756c86c4b7014e7ff87d7b269b20fc4e07356466))
* **skhd,yabai:** add Cliq launcher on space 14 ([472a434](https://github.com/vanducng/dotfiles/commit/472a4343373a186a53e759fc9134f32b2243b9a3))
* **skhd,yabai:** add Herd launcher on space 8, move Arc to space 13 ([b740b21](https://github.com/vanducng/dotfiles/commit/b740b211fd7803e174d19d860fa8d3e4be2dacae))
* **skhd,yabai:** add WhatsApp launcher on space 13 ([#11](https://github.com/vanducng/dotfiles/issues/11)) ([c947db0](https://github.com/vanducng/dotfiles/commit/c947db03142b8dc77d900ea564ad2483af49c43a))
* **skhd:** add Codex desktop shortcut ([dbe791d](https://github.com/vanducng/dotfiles/commit/dbe791d310a1afd31071856da25a2dea5c03e6ac))
* **starship:** enable direnv integration ([45cf562](https://github.com/vanducng/dotfiles/commit/45cf562f21732579b25a807cd928908aefb0eba7))
* **stow:** add borders and rift window management configs ([1c5042f](https://github.com/vanducng/dotfiles/commit/1c5042f285408b5094ee73e661d761706ff4aff4))
* **system:** update shortcuts and shell environment ([938858f](https://github.com/vanducng/dotfiles/commit/938858f138b0d0aad05e7cdb91ab00477432a5ce))
* **tmux-agent:** add skip-permissions flag, slash cmd and file ref support ([f589505](https://github.com/vanducng/dotfiles/commit/f5895055b008323c80a42340994e8f11558dca76))
* **tmux-sessionizer:** enhance directory search and quoting ([a4fe652](https://github.com/vanducng/dotfiles/commit/a4fe652814bf1521d5dd58a970e4778e6bcfa052))
* **tmux:** add key bindings for pane selection and vim-tmux-navigator integration ([8819132](https://github.com/vanducng/dotfiles/commit/88191325f315b7d0f9645b873f46d49c3a5fc671))
* **tmux:** add layout prefix mode with multiple pane layouts ([7d5427f](https://github.com/vanducng/dotfiles/commit/7d5427fb5504e2f8a49040cdc58806b601fb3ec4))
* **tmux:** add new key bindings and plugins ([3336e63](https://github.com/vanducng/dotfiles/commit/3336e631317f7709bf53693b9ec498aa8067ee2a))
* **tmux:** add tmux-agent for worktree-based Claude Code workflows ([31ab1ca](https://github.com/vanducng/dotfiles/commit/31ab1ca066d9286e69410ad51f1818cb81d7ca7d))
* **tmux:** improve fingers patterns, enable alt-action, ship open-path ([#10](https://github.com/vanducng/dotfiles/issues/10)) ([50f0a41](https://github.com/vanducng/dotfiles/commit/50f0a410d828428b35137b8a6c5e2b2bbdd8ada4))
* **tmux:** optimize layout for agentic coding workflow ([4a28ac5](https://github.com/vanducng/dotfiles/commit/4a28ac5e46a2fbaff52609adf4ae47159b1914aa))
* **tmux:** optimize layout for agentic coding workflow ([79c3bc7](https://github.com/vanducng/dotfiles/commit/79c3bc7c654ce1aa1f14aa4710273d01c2ebe3cd))
* **tmux:** update tmux configuration for improved usability ([20ab3de](https://github.com/vanducng/dotfiles/commit/20ab3de7f5efbed60d24ece95ce5395645e1933a))
* unified AI completion system with conflict prevention ([5aaaaca](https://github.com/vanducng/dotfiles/commit/5aaaaca580777665bba44f2ad611b127143600e5))
* update Claude configuration with SuperClaude v2 ([8437e46](https://github.com/vanducng/dotfiles/commit/8437e46158e4ca124f24f49462045878b7a40248))
* update Claude configuration with SuperClaude v2 ([ca1a641](https://github.com/vanducng/dotfiles/commit/ca1a6417db508617ff31e6ed1016534d443fc44c))
* update dbee config to use 'x' for disconnect toggle ([d25a7ab](https://github.com/vanducng/dotfiles/commit/d25a7ab289eb384b96425ce10e30c899c9ea3f2b))
* update nvim vscode ([3048db4](https://github.com/vanducng/dotfiles/commit/3048db42076c28128d5e7debebcdcf4d7c4a25da))
* **yabai:** auto-unzoom on new window creation ([29e3198](https://github.com/vanducng/dotfiles/commit/29e3198671198f379db84b5f7d495733de889f25))
* **yabai:** disable window opacity and update rules ([1a14d2c](https://github.com/vanducng/dotfiles/commit/1a14d2ce223d2ed49af813703c10fe97b40ae86d))
* **yabai:** pin chat/browser apps to spaces 8-12 ([7f9cd8a](https://github.com/vanducng/dotfiles/commit/7f9cd8a4a8be460c44f62d759af30a9c780e6f35))
* **yazi:** improve navigation keybindings and add initial-dir plugin ([928f9b0](https://github.com/vanducng/dotfiles/commit/928f9b08db2d2d6239efb5b357ecfdd4b35fe9a5))
* **zsh:** source bruin env ([7be28ff](https://github.com/vanducng/dotfiles/commit/7be28ffc760aec2ed50085224821f7d6b388889f))


### Bug Fixes

* add CNAME file to preserve custom domain on deploy ([45f0171](https://github.com/vanducng/dotfiles/commit/45f0171f8eccf8f059e85559ade0bfa7d8d3aef9))
* add jsonc parser for JSON with comments support ([3159eb0](https://github.com/vanducng/dotfiles/commit/3159eb0d65b3c8909e2cd3d087dba73d21e883ee))
* add missing dockerfile and hcl parsers to nvim refresh script ([f44d853](https://github.com/vanducng/dotfiles/commit/f44d8532c59ceaa033ce69de58cbf11ed96a86cf))
* add safety checks for pyenv and gh initialization in zshrc ([1b88095](https://github.com/vanducng/dotfiles/commit/1b880958ca76c499c237cb7ba89d02c897a8b84f))
* add tsx and jsx parsers for React support ([9d92f91](https://github.com/vanducng/dotfiles/commit/9d92f9122e8780090d83ca5b3545f7974a7befe9))
* anchor first managed release to v0.1.0 ([#19](https://github.com/vanducng/dotfiles/issues/19)) ([5b16e5b](https://github.com/vanducng/dotfiles/commit/5b16e5b6a1b28a5d1afaeac51989ef055521b0ce))
* change Copilot next suggestion from Ctrl+i to Ctrl+n ([8214d8b](https://github.com/vanducng/dotfiles/commit/8214d8b45dc23ec0fc4c4be92c3f9add30cb2c93))
* comprehensive E5101 error prevention with type safety ([1f5e14f](https://github.com/vanducng/dotfiles/commit/1f5e14f18ce93d36165a4f249bf6e100e1064931))
* **docs:** restore default markdown extensions (fenced code, toc, tables) ([4633efc](https://github.com/vanducng/dotfiles/commit/4633efcb068e671fae1a55ca9f4d6d5a24f5d830))
* duplicate claude alias ([cd47453](https://github.com/vanducng/dotfiles/commit/cd47453080890f0c8a704aa6e4dea6ac414cb3ba))
* ensure blink.cmp configuration is properly applied for cmp-dbee ([0419272](https://github.com/vanducng/dotfiles/commit/0419272da7d0b0245970ddb6db2186fee995153d))
* ensure utils functions respect disabled connections ([497b0cd](https://github.com/vanducng/dotfiles/commit/497b0cd338f512ce8123ab18ad678681db35b033))
* **ghostty,ci:** keep skhd alive under SKE + ship wtfutil dashboard ([#12](https://github.com/vanducng/dotfiles/issues/12)) ([40b1566](https://github.com/vanducng/dotfiles/commit/40b15660b3f7c5f2a43fa75243a220dacbb9a234))
* **hammerspoon:** open file-browser URLs in Dia, not Arc ([209ad55](https://github.com/vanducng/dotfiles/commit/209ad55934bd4b5a6f5e4acc78276e6ee6b69383))
* **hammerspoon:** open file-browser URLs in Dia, not Arc ([00a19f2](https://github.com/vanducng/dotfiles/commit/00a19f2be5ca1846b2e483b6bcc6c09b3fecbf40))
* implement code review improvements ([09d6dd1](https://github.com/vanducng/dotfiles/commit/09d6dd1bf0f277addc2e6d08ddaf323ed8aeaa90))
* number display on tmux ([a836682](https://github.com/vanducng/dotfiles/commit/a836682deaf0c6dcf5b44282ded4ac01c555410c))
* **nvim:** correct miu-db plugin directory path ([2c4cbc0](https://github.com/vanducng/dotfiles/commit/2c4cbc01baf4a09c3ecb061f5940312ad6165f27))
* **nvim:** move pyright disable from config to handlers (v6 compat) ([7f4a777](https://github.com/vanducng/dotfiles/commit/7f4a77737af75824e5ec11fa391fe482115badcd))
* **nvim:** use colon syntax for client:supports_method ([1b38b19](https://github.com/vanducng/dotfiles/commit/1b38b199a510821884cde18cd5d48e758898eb8e))
* **nvim:** use vim.diagnostic.enable(bool, filter) API for nvim 0.12 ([ffc7d99](https://github.com/vanducng/dotfiles/commit/ffc7d993eded7af501730a41af0dbdf98bdc89f1))
* prevent VSCode from globally activating Python virtual environments ([ee4b2b0](https://github.com/vanducng/dotfiles/commit/ee4b2b0595bfbeb242cd1cec05b880e2dbe7a8f5))
* relative path symlink ([1f5d642](https://github.com/vanducng/dotfiles/commit/1f5d642191d07f5d418e49a742574313bd7824c9))
* remove duplicate cmp-dbee setup and add debug output ([d17276f](https://github.com/vanducng/dotfiles/commit/d17276f95a21e2446df23b0ffe882fa34d1e3948))
* remove neocodeium from lazy-lock.json ([fa3f630](https://github.com/vanducng/dotfiles/commit/fa3f6303ff8f4d533cdb85d32121e53408e6f8c8))
* replace neo-tree with yazi+oil for better performance and stability ([a987f8a](https://github.com/vanducng/dotfiles/commit/a987f8a068c811520ec015ce101e286924e3eef4))
* resolve atuin keybinding conflict with zsh-vi-mode ([1f4fdca](https://github.com/vanducng/dotfiles/commit/1f4fdca63289aa5d227fcac596c114094a4e9d39))
* resolve CI/CD pipeline failures ([915e5fe](https://github.com/vanducng/dotfiles/commit/915e5fef9a65b6b6143240cae1d115fc004bb1b6))
* resolve neocodeium load error and revise copilot keymaps ([57b829d](https://github.com/vanducng/dotfiles/commit/57b829dfeef1238cfcc217a09801011377a076ba))
* resolve nvim treesitter ARM64 architecture mismatch and neo-tree refresh errors ([9f87ffe](https://github.com/vanducng/dotfiles/commit/9f87ffe3665d6679607d5c59ada26963f98871f3))
* resolve Tab key issue in Neovim insert mode ([d55c468](https://github.com/vanducng/dotfiles/commit/d55c4683dfc324123c035ab8c5d01e9d8a973dfb))
* simplify nvim-dbee setup to prevent window_layout nil error ([5452f02](https://github.com/vanducng/dotfiles/commit/5452f02aebf662a02b000a786ff183ad955fcabf))
* **skhd:** open Slack on display 2 ([bc62100](https://github.com/vanducng/dotfiles/commit/bc62100e94feff496c40bcf84dfbb2bef8b37a30))
* **tmux-sessionizer:** attach instead of switch when outside tmux ([452d33f](https://github.com/vanducng/dotfiles/commit/452d33f57a2f7133ee261f656b8d8258d7d58292))
* **tmux:** ensure tmux-fingers binding registers on fresh server start ([3ae9b69](https://github.com/vanducng/dotfiles/commit/3ae9b691981642396548117d125e36e39c2c7228))
* **tmux:** stay in copy mode after yanking text ([17dcd2c](https://github.com/vanducng/dotfiles/commit/17dcd2c3a7f819ade74f154f03b15f4b4c7ea62c))
* use correct zensical dark mode config (slate scheme) ([7e6e4d3](https://github.com/vanducng/dotfiles/commit/7e6e4d3bbdb87317cd91833f7e868db5c6cd17b6))
* use full path for arc command in hammerspoon init.lua ([892af3e](https://github.com/vanducng/dotfiles/commit/892af3e8702ff8f8dcbad5ce42676d8d5e165fb5))
* **yabai:** force-float Alter so it never re-tiles after moves ([#13](https://github.com/vanducng/dotfiles/issues/13)) ([1fbaef0](https://github.com/vanducng/dotfiles/commit/1fbaef05d05918c1f3b18d8eceaba2db8c45d27d))
* yazi navigation and keymap configuration ([bed47fd](https://github.com/vanducng/dotfiles/commit/bed47fdbdaedef332ab4a6faa3d73ed4e44fb5ad))
* zen config ([a240063](https://github.com/vanducng/dotfiles/commit/a240063dd2789a9068d6cf697601b48685152544))
* **zsh:** allow homebrew metadata refresh ([61167cd](https://github.com/vanducng/dotfiles/commit/61167cd2da1173f399f1edd69bbea82a53393d25))


### Performance Improvements

* major zsh startup optimization - 72% faster startup ([9db10d9](https://github.com/vanducng/dotfiles/commit/9db10d966ca0dd6ad473739c00c11c1f85894ba4))
* optimize zsh startup time and add direnv config ([2381737](https://github.com/vanducng/dotfiles/commit/23817371ec66b4ca612d0ebdeb066f14b7f0469a))
* use blink-wrapper to eliminate completion lag ([fdc67d3](https://github.com/vanducng/dotfiles/commit/fdc67d3736f1e492b722a8d54f268a0d40970765))

## Changelog
