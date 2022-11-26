import std.stdio;
import std.getopt;
import std.array : popFront, join, popBack;
import std.process : execute, environment, executeShell, spawnProcess, wait;
import std.algorithm : canFind, countUntil;
import std.file : readText, tempDir, remove, exists;
import std.path : buildNormalizedPath, absolutePath, expandTilde, baseName;

import pkm.search;
import pkm.config;
import pkm.getopt;


// --aur -a
// --no-aur
// --version -v
// --help -h
// search | yay -Ss term
// list | yay -Q
// info | yay -Qi
// install | yay -S term
// reinstall | yay -R & yay -S
// remove | yay -R term
// checkupdates | yay -Qu
// update | yay -Sy
// upgrade | yay -Su
// clone
// build
// clean | yay -Yc
// -- custom --
// stats | yay -Ps
// pkgbuild | yay -G term | yay -Gp term

private const string _version = "pkm v1.1.3";

string fixPath(string path) {
    return path.buildNormalizedPath.expandTilde.absolutePath;
}

int main(string[] args) {
    version (Windows) {
        writefln("Unable to run on windows.");
        return 1;
    }

    bool optVersion = false;
    bool optAur = false;

    auto help = getopt(
        args,
        config.bundling, config.passThrough,
        "version", "print version", &optVersion,
        "aur|a", "search only aur", &optAur
    );

    string[] configPath = [
        "~/.pkm.yaml".fixPath,
        "~/.config/pkm/conf.yaml".fixPath,
    ];
    Config conf = getConfig(configPath);

    Commands[] coms = [
        Commands("search", "[option] <package(s)>"),
        Commands("list", "[option]"),
        Commands("info", "[option] <package(s)>"),
        Commands("install", "[option] <package(s)>"),
        // Commands("reinstall", "[option] <package(s)>"),
        Commands("remove", "[option] <package(s)>"),
        Commands("checkupdates", "[option]"),
        Commands("update", "[option] <package(s)>"),
        Commands("upgrade", "[option] <package(s)>"),
        Commands("clean", "[option]"),
    ];

    if (optVersion) {
        writeln(_version);
        return 0;
    }

    if (help.helpWanted || args.length == 1) {
        printGetopt("", "pkm <operation> [...]", coms, help.options, conf.custom, conf.args);
        return 0;
    }

    string yay = "";
    bool yayDefined = false;
    string cyay = conf.yaypath.fixPath;
    if (cyay != "" && (
            (cyay.exists && cyay.baseName == "yay") ||
            (exists(cyay ~ "/yay")))) {
        yayDefined = true;
        yay = cyay;
    } else if (cyay != "") {
        writefln("Cannot find yay in \"%s\". \nAttempting to guess yay location.", conf.yaypath);
        yay = "/usr/bin/yay";
    }

    if (!yayDefined) {
        string tmpFile = tempDir ~ "/" ~ "pkm-yay-path.txt";
        tmpFile = tmpFile.buildNormalizedPath.absolutePath;

        auto processOut = File(tmpFile, "w+");
        wait(spawnProcess(["which", "yay"], std.stdio.stdin, processOut));
        processOut.close();
        string _out = tmpFile.readText();
        remove(tmpFile);
        _out.popBack();

        if (_out.canFind("which: no yay in")) {
            writeln("Error: cannot find yay.");
            return 1;
        } else {
            yay = _out.fixPath;
        }
    }

    // writeln(yay);

    string[] ops = args.dup;
    ops.popFront(); // removes [0] command
    ops.popFront(); // removes 'command'

    if (optAur || conf.auronly) {
        ops ~= ["--aur"];
    }

    switch (args[1]) {
        case "search":
            if (conf.yaysearch) {
                return wait(spawnProcess([yay, "-Ss"] ~ ops));
            } else {
                return search(yay, ops, conf.color);
            }
        case "list":
            return wait(spawnProcess([yay, "-Q"]));
        case "info":
            return wait(spawnProcess([yay, "-Qi"] ~ ops));
        case "install":
            return wait(spawnProcess([yay, "-S"] ~ ops));
        // case "reinstall":
        //     return wait(spawnProcess([yay, "-R"] ~ ops));
        //     return wait(spawnProcess([yay, "-S"] ~ ops));
        case "remove":
            return wait(spawnProcess([yay, "-R"] ~ ops));
        case "checkupdates":
            return wait(spawnProcess([yay, "-Qu"] ~ ops));
        case "update":
            return wait(spawnProcess([yay, "-Sy"] ~ ops));
        case "upgrade":
            return wait(spawnProcess([yay, "-Su"] ~ ops));
        case "clean":
            return wait(spawnProcess([yay, "-Yc"]));
        default:
            if (conf.custom.canFind(args[1])) {
                ulong argspos = conf.custom.countUntil(args[1]);
                return wait(spawnProcess([yay] ~ conf.args[argspos] ~ ops));
            } else {
                writefln("Unknown command \"%s\". Executing as is.", args[1]);
                return wait(spawnProcess([yay] ~ ops));
            }
    }
}
