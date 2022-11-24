module pkm.search;

import std.process: execute, environment, executeShell, Config, spawnProcess, wait;
import std.file: tempDir, remove, readText;
// import std.file;
import std.stdio;
import std.regex;
import std.path: buildNormalizedPath, absolutePath;
import std.array: split;
import std.conv: to;
import std.range: repeat;
import std.algorithm: canFind, sort;
import std.numeric: gapWeightedSimilarityNormalized;

import core.sys.posix.sys.ioctl;

import pkm.pkg;
import sily.bashfmt;

// yay regex:
// (.*?)\/(.*?)\s(.*?)\s\((.*?)\)(?:\s\[(.*)\])?(?:\s\((Orphaned)\))?(?:\s\(Out-of-date:\s(.*?)\))?(?:\s\((Installed)(?:\:\s(.*?))?\))?(?:\s{6}|\s{5})(.*)(?:\r|\n|\z)
// 1    2    3        4                5        6          7           8           9             10   
// repo/name version (size|aur-votes) [group]? (orphaned) (outofdate) (installed: (version)) \n (description)
private auto reg = regex(
        r"(.*?)\/(.*?)\s(.*?)\s\((.*?)\)(?:\s\[(.*)\])?" ~ 
        r"(?:\s\((Orphaned)\))?(?:\s\(Out-of-date:\s(.*?)\))?" ~ 
        r"(?:\s\((Installed)(?:\:\s(.*?))?\))?(?:\s{6}|\s{5})(.*)(?:\r|\n|\z)", "gm");

int search(string[] terms, bool color) {
    string yay = "/usr/bin/yay";
    string tmpFile = tempDir ~ "/" ~ "pkm-yay-search-output.txt";
    tmpFile = tmpFile.buildNormalizedPath.absolutePath;

    auto processOut = File(tmpFile, "w+");

    auto pidErr = wait(spawnProcess([yay, "-Ss"] ~ terms, std.stdio.stdin, processOut));

    processOut.close();

    if (pidErr) {
        remove(tmpFile);
        writefln("yay exited with code \"%d\"", pidErr);
        return pidErr;
    }

    printPackages(tmpFile, terms, color);

    remove(tmpFile);
    
    return 0;
}


// 1    2    3        4                5        6          
// repo/name version (size|aur-votes) [group]? (orphaned) 
//  7           8           9             10   
// (outofdate) (installed: (version)) \n (description)
void printPackages(string tmpFile, string[] searchTerms, bool color) {
    string contents = readText(tmpFile);

    Pkg[] pkgs = [];

    auto packages = matchAll(contents, reg);

    foreach (pkg; packages) {
        string pkgsize;
        string inssize;

        if (pkg[1] == "aur") {
            string[] _size = pkg[4].split(' ');
            pkgsize = _size[0];
            inssize = _size[1];
        } else {
            string[] _size = pkg[4].split(' ');
            pkgsize = _size[0] ~ " " ~ _size[1];
            inssize = _size[2] ~ " " ~ _size[3];
        }

        pkgs ~= Pkg(
            pkg[1],  // repo
            pkg[2], // name
            pkg[3], // version
            pkgsize, // package size / aur votes
            inssize, // installation size / aur popularity
            pkg[5], // group
            pkg[6] != "" ? true : false, // is orphaned
            pkg[7] != "" ? true : false, // is out of date
            pkg[7], // out of date date
            pkg[8] != "" ? true : false, // is installed
            pkg[9], // installed version
            pkg[10] // description
        );
    }

    sort!((a,b) {
        return gapWeightedSimilarityNormalized(a.name.split("-"), searchTerms, 0) < 
               gapWeightedSimilarityNormalized(b.name.split("-"), searchTerms, 0);
    })(pkgs);

    foreach (pkg; pkgs) {
        printPackage(pkg, color);
    }
}

void printPackage(Pkg pkg, bool color) {
    // if (!(pkg.isOrphaned || pkg.isInstalled || pkg.isOutdated)) return;
    winsize w;
    ioctl(0, TIOCGWINSZ, &w);
    int terminalWidth = w.ws_col;

    string installstr = color || pkg.isInstalled ? "[i]" : "[ ]";
    string orphanedstr = color || pkg.isOrphaned ? "[a]" : "[ ]";
    string outdatedstr = color || pkg.isOutdated ? "[o]" : "[ ]";
    ulong flagsLength = installstr.length + orphanedstr.length + outdatedstr.length + 2;
    
    ulong installPos = 1;
    if (pkg.name.length + flagsLength < terminalWidth / 2) {
        installPos = (terminalWidth / 2) - pkg.name.length - flagsLength;
    }
    write(pkg.name);

    write(' '.repeat(installPos));

    if (pkg.isOrphaned) {
        writecol(FG.ltred, color,orphanedstr);
    } else {
        // write(' '.repeat(orphanedstr.length));
        writecol(FG.dkgray, color, orphanedstr);
    }

    write(' ');

    if (pkg.isOutdated) {
        writecol(FG.ltred, color, outdatedstr);
    } else {
        // write(' '.repeat(outdatedstr.length));
        writecol(FG.dkgray, color, outdatedstr);
    }

    write(' ');

    if (pkg.isInstalled) {
        writecol(FG.ltgreen, color, installstr);
    } else {
        // write(' '.repeat(installstr.length));
        writecol(FG.dkgray, color, installstr);
    }

    write(' ');

    ulong verlen = pkg.installedVersion != "" ? pkg.installedVersion.length + (color ? 0 : 1) : pkg.ver.length;
    if (pkg.installedVersion != "") {
        writecol(FG.ltmagenta, color, (color ? "" : "@") ~ pkg.installedVersion);
    } else {
        writecol(FG.cyan, color, pkg.ver);
    }

    ulong reposize = "[aur]".length + 1;
    ulong sizelen = pkg.pkgsize.length + pkg.inssize.length + 1;

    ulong wantedlen = verlen + sizelen + 1 + reposize;
    ulong rside = 1;
    if (wantedlen < terminalWidth / 2) {
        rside = (terminalWidth / 2) - wantedlen;
    }

    write(' '.repeat(rside));

    if (pkg.repo == "aur") {
        float votes = pkg.aurvotes.to!float;
        FG colvot = FG.dkgray;
        if (votes >= 100.0) colvot = FG.ltred;
        if (votes >= 250.0) colvot = FG.ltyellow;
        if (votes >= 500.0) colvot = FG.ltcyan;
        if (votes >= 750.0) colvot = FG.ltgreen;
        if (votes >= 1000.0) colvot = FG.ltblue;

        float popul = pkg.aurpopul.to!float;
        FG colpop = FG.dkgray;
        if (popul >= 1.0) colpop = FG.ltred;
        if (popul >= 10.0) colpop = FG.ltyellow;
        if (popul >= 20.0) colpop = FG.ltcyan;
        if (popul >= 30.0) colpop = FG.ltgreen;
        if (popul >= 40.0) colpop = FG.ltblue;
        writecol(colvot, color, pkg.aurvotes);
        write(' ');
        writecol(colpop, color, pkg.aurpopul);
    } else {
        writecol(FG.reset, color, pkg.pkgsize);
        write(' ');
        writecol(FG.reset, color, pkg.inssize);
    }
    write(' ');

    FG repocol = FG.reset;
    switch (pkg.repo) {
        case "aur": repocol = FG.ltblue; break;
        case "core": repocol = FG.ltyellow; break;
        case "extra": repocol = FG.ltgreen; break;
        case "community": repocol = FG.ltmagenta; break;
        default: 
            if (pkg.repo.canFind("testing")) {
                repocol = FG.ltred;
            } else {
                repocol = FG.ltcyan;
            }
        break;
    }

    writecol(repocol, color, "[" ~ pkg.repo[0..3] ~ "]");
    writeln();
    writeln("    " ~ pkg.description);

    // writeln();
}

void writecol(FG col, bool enabled, string args) {
    if (enabled) {
        write(col ~ args ~ FG.reset);
    } else {
        write(args);
    }
}

void writelncol(FG col, bool enabled, string args) {
    writecol(col, enabled, args ~ "\n");
}