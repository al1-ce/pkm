# pkm
**P**ac**K**age**M**anager - Simple apt-style [yay](https://github.com/Jguer/yay) wrapper

## Description

pkm is simple AUR helper intended to be used alongside with yay. It is not trying to be full replacement, but tries to improve and streamline installation/discovery sprocess.

All pkm commands are simply yay commands, wrapped in apt/pamac ux, which are displayed as is except search. Search in pkm is tweaked to have minimal interface and provide better results sorting.

![](readme/screenshot.png)

## Installation

### 1. Install [yay](https://github.com/Jguer/yay) and follow [yay first use](https://github.com/Jguer/yay#first-use)

### 2.1 Source
Compilation of this repository requires [dlang](https://dlang.org).

1. Clone [this repo](https://github.com/al1-ce/pkm) and build it with `dub build -b release`.
2. Copy created binary `./bin/pkm` to somewhere in your path, for example `~/.local/bin/`

### 2.2 Binary

1. Go to [releases](https://github.com/al1-ce/pkm/releases) and download binary.
2. Copy downloaded binary `./bin/pkm` to somewhere in your path, for example `~/.local/bin/`

<!-- ### 2.3 AUR -->

<!-- ### 2.4 dub -->

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
| stats | Print system statistics. | `yay -Ps`
| pkgbuild | Print PKGBUILD file | `yay -Gp [packages...]`

<!-- ## Config -->

## How to read search
All available `pkm` commands are calling `yay` with corresponding flags. This is true for search, but pkm also performs special operations to customise and improve yay's search.

Search always follows this schema:

```
package-name  [a] [o] [i] version/installed-version  package-size/votes install-size/popularity [repo]
    description
```

![](readme/screenshot_special.png)

Here's small table to assist you in reading it:

| Field | Meaning | Special notes |
| :- | :- | :- |
| package-name | Name of package. | | 
| [a] | Is package orphaned. | Highlighted in red when true. "A" stands for abandoned. |
| [a] | Is package outdated. | Highlighted in red when true. |
| [a] | Is package installed. | Highlighted in green when true. |
| version | Version of package. | If installed version is different from current verison then field shows installed version hightlighed in light magenta. |
| package-size/votes | See notes. | If package from AUR: Package votes. <br> If package not from AUR: Package size. 
| package-size/votes | See notes. | If package from AUR: Package popularity. <br> If package not from AUR: Installation size. 
| [repo] | Repository of package. | Repository name is cropped to 3 symbols.
| description | Description. | |

If package is from AUR then it's displaying votes/popularity instead of size and votes/popularity are highlighted in this way:

![](readme/votes.png)

### Other AUR helpers/tools
- [yay](https://github.com/Jguer/yay) 
- [paru](https://github.com/morganamilo/paru)
- [aurutils](https://github.com/AladW/aurutils)
- [pikaur](https://github.com/actionless/pikaur)