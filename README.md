# pkm
**P**ac**K**age**M**anager - Simple apt-style [yay](https://github.com/Jguer/yay) wrapper

<!-- Uncomment when shelds going to add dub score -->
<!-- [![aur](https://img.shields.io/aur/version/pkm.svg?style=for-the-badge&logo=archlinux)](https://aur.archlinux.org/packages/pkm) 
[![dub](https://img.shields.io/dub/v/pkm.svg?style=for-the-badge&logo=d)](https://code.dlang.org/packages/pkm) 
[![git](https://img.shields.io/github/v/release/al1-ce/pkm?label=GIT&logo=github&style=for-the-badge)](https://github.com/al1-ce/pkm)
![license](https://img.shields.io/aur/license/pkm.svg?style=for-the-badge)
![aur votes](https://img.shields.io/aur/votes/pkm.svg?style=for-the-badge)  -->
<!-- Custom score badge, doesnt really work coz it shows 0.700090412 etc -->
<!-- ![](https://img.shields.io/badge/dynamic/json?color=blue&label=SCORE&query=%24.score&url=https%3A%2F%2Fcode.dlang.org%2Fapi%2Fpackages%2Fpkm%2Fstats&style=for-the-badge) -->

[![aur](https://img.shields.io/aur/version/pkm.svg?logo=archlinux&style=flat-square&logoColor=white)](https://aur.archlinux.org/packages/pkm) 
[![dub](https://img.shields.io/dub/v/pkm.svg?logo=d&style=flat-square)](https://code.dlang.org/packages/pkm) 
[![git](https://img.shields.io/github/v/release/al1-ce/pkm?label=git&logo=github&style=flat-square)](https://github.com/al1-ce/pkm)
![license](https://img.shields.io/aur/license/pkm.svg?style=flat-square)
![aur votes](https://img.shields.io/aur/votes/pkm.svg?style=flat-square) 
![dub rating](https://badgen.net/dub/rating/pkm?style=flat)
![dub rating](https://badgen.net/github/stars/al1-ce/pkm?style=flat)
![](https://img.shields.io/badge/status-⠀-success?style=flat-square)
<!-- ![](https://img.shields.io/badge/status-⠀-important?style=flat-square) -->
<!-- ![](https://img.shields.io/badge/status-⠀-critical?style=flat-square) -->
<!-- Cool status badge idk. Uncommentt current one -->

<!-- [![Packaging status](https://repology.org/badge/vertical-allrepos/pkm.svg)](https://repology.org/project/pkm/versions) -->

## Description

pkm is simple AUR helper intended to be used alongside with yay. It is not trying to be full replacement, but tries to improve and streamline installation/discovery sprocess.

All pkm commands are simply yay commands, wrapped in apt/pamac ux, which are displayed as is except search. Search in pkm is tweaked to have minimal interface and provide better results sorting.

![](readme/screenshot.png)

## Installation

### 1. Install [yay](https://github.com/Jguer/yay) and follow [yay first use](https://github.com/Jguer/yay#first-use)

### 2.1 Source
Compilation of this repository requires [dlang](https://dlang.org).

1. Clone [this repo](https://github.com/al1-ce/pkm) and build it with `dub build -b release`
2. Copy created binary `./bin/pkm` to somewhere in your path, for example `~/.local/bin/`
3. Or build project with `dub build pkm -b release -c install` to automatically move compiled binary into `/usr/bin`

### 2.2 Binary

1. Go to [releases](https://github.com/al1-ce/pkm/releases) and download binary.
2. Copy downloaded binary `pkm` to somewhere in your path, for example `~/.local/bin/`

### 2.3 AUR

1. Install with any package manager of your choice. Assuming you have `yay` install with `yay -Syu pkm`

### 2.4 dub

1. Fetch package with `dub fetch pkm`
2. Build and install into `/usr/bin` with `dub build pkm -b release -c install`

## Commands

pkm commands follow pamac/apt syntax. Installing `pkm install package`, removing `pkm remove package`, etc..

If you want to perform any of following command only on AUR then add `--aur` or `-a` flag to your command.

| Command | Description | yay command | 
| :------ | :---------- | :---------- |
| search | Search for package. | `yay -Ss [terms...]`
| list | List installed packages. | `yay -Q`
| info | Print info about package. | `yay -Qi [packages...]`
| install | Install package. | `yay -S [packages...]`
| remove | Remove package. | `yay -R [packages...]`
| checkupdates | Checks for available updates. | `yay -Qu`
| update | Update repositories. | `yay -Sy [packages...]`
| upgrade | Upgrade installed packages. | `yay -Su [packages...]`
| clean | Clean unneeded dependencies. | `yay -Yc`

## Config

pkm can be configured with config file located at `~/.config/pkm/conf.yaml`, `~/.config/pkm/pkm.yaml` or `~/.pkm.yaml`, one at `~` takes prority.

| Name | Type | Description | Default |
| :----| :--- | :---------- | :------ |
| yaypath | string | Custom path to yay binary. | Guessed with `which` |
| yaysearch | bool | Disable custom pkm search. | `false` |
| color | bool | Sets if search will be printed with colors. <br> Will not work if `yaysearch` is `true`. | `true` |
| separate | bool | Separates search results with separator. <br> Will not work if `yaysearch` is `true`. | `false` |
| separator | string | Sets separator for `separate` option. If it's unicode escape sequence then it must be wrapped in `"` | `"\u2500"` |
| separator-color | string | Sets formatting for `separate` option. Must be set with `\e` as escape symbol | `\e[90m` |
| auronly | bool | Should yay search only AUR. | `false` |
| managers | string[] | Defines custom managers. | `[ ]` |
| custom | string[] | Custom commands. | `[ ]` |

### Using custom package manager instead of yay:

You can set custom main package manager with yaypath.

If you're using pacman/yay-compatible package manager then you can use it as is while only setting yaysearch to true.
```yaml
yaypath: /usr/bin/pacman
yaysearch: yes
```

In case of package managers with flags/commands not compatible with pacman/yay you can override default commands with custom commands.
```yaml
yaypath: /usr/bin/pamac
yaysearch: yes
custom:
    # Overrides default search with pamac search and disables aur
    search: search --no-aur
```

### Managers:
Allows usage of custom managers such as pacman, pamac and other package managers and aur helpers.

Custom managers can be used only with custom commands.
```yaml
managers:
    # name: path
    pacman: /usr/bin/pacman
    pamac: /usr/bin/pamac
    aura: /usr/bin/aura
custom:
    # If you want to use custom package manager with custom command simply supply it 
    # as first argument
    sysupdate: pacman -Syu

```

### Custom commands:
Allows to create custom commands and overriding default commands.

If first argument will match any custom defined managers then this manager will be used.

If you want to override any command make sure that there's no duplicate keys in current KeyMap (i.e. `custom:`) since yaml does not allow for them.

Also args must be split by space, so avoid spaces inside one argument, `votecool: -Wv "my thing"` will be split as `['-Wv', '"my', 'thing"']`.
```yaml
managers:
    aura: /usr/bin/aura
    pamac: /usr/bin/pamac
custom:
    # command: [args...]
    # Args must exclude yay as pkm will auto-supply it
    updupg: -Syu
    vote: -Wv
    unvote: -Wu
    gendb: -Y --gendb
    # Uses custom package manager (in that case aura)
    updateaur: aura -Au
    # Overrides default serach
    search: pamac search
```

### Aliases:
Aliases can be either a command or custom command.
```yaml
alias:
    # alias: name
    i: install
    s: search
    find: search
    # Pointing to custom command shown in previous example
    u: unvote
```

Example config:

```yaml
# conf.yaml
yaypath: ~/.local/bin/yay
yaysearch: yes
auronly: yes
custom:
    updupg: -Syu
    vote: -Wv
    unvote: -Wu
alias:
    i: install
    s: search
    r: remove
```

## How to read search
All available `pkm` commands are calling `yay` with corresponding flags. This is true for search, but pkm also performs special operations to customise and improve yay's search.

Search always follows this schema:

```
package-name  [a] [o] [i] version/installed-version  package-size/votes install-size/popularity [repo]
    description
```

![](readme/screenshot_special.png)
![](readme/screenshot_special_bw.png)

Here's small table to assist you in reading it:

| Field | Meaning | Special notes |
| :- | :- | :- |
| package-name | Name of package. | | 
| [a] | Is package orphaned. | Highlighted in red when true. If color is disabled displayed as [ ]. "A" stands for abandoned. |
| [o] | Is package outdated. | Highlighted in red when true. If color is disabled displayed as [ ]. |
| [i] | Is package installed. | Highlighted in green when true. If color is disabled displayed as [ ]. |
| version | Version of package. | If installed version is different from current verison then field shows installed version hightlighed in light magenta. If color is disabled version diff shown with `@` at start. |
| package-size/votes | See notes. | If package from AUR: Package votes. <br> If package not from AUR: Package size. 
| package-size/votes | See notes. | If package from AUR: Package popularity. <br> If package not from AUR: Installation size. 
| [repo] | Repository of package. | Repository name is cropped to 3 symbols.
| description | Description. | |

If package is from AUR then it's displaying votes/popularity instead of size and votes/popularity are highlighted in this way:

![](readme/votes.png)

## FAQ

- ### No color anywhere except search
    See [yay faq](https://github.com/Jguer/yay#frequently-asked-questions)

- ### My config
```yaml
# ~/.config/pkm/conf.yaml
managers:
pacman: /usr/bin/pacman
custom:
    updupg: -Syu
    stats: -Ps
    pkgbuild: -Gp
    vote: -Wv
    unvote: -Wu
    sysupdate: pacman -Syu
    find: -Qs
alias:
    i: install
    s: search
    r: remove
    b: pkgbuild
    u: updupg
    I: info
    f: find
separate: yes
separator: "\u2500"
separator-color: "\e[38;5;237m"
```

### Other AUR helpers/tools
- [yay](https://github.com/Jguer/yay) 
- [paru](https://github.com/morganamilo/paru)
- [aurutils](https://github.com/AladW/aurutils)
- [pikaur](https://github.com/actionless/pikaur)
