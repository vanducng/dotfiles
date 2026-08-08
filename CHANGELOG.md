# Changelog

## [0.14.2](https://github.com/vanducng/dotfiles/compare/v0.14.1...v0.14.2) (2026-08-08)


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
