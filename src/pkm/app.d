import std.stdio;
import std.getopt;
import std.array: popFront, join;
import std.process: execute, environment, executeShell, Config, spawnProcess, wait;

import pkm.search;

import sily.getopt;

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

private const string _version = "pkm v1.0.0";

int main(string[] args) {
    version(Windows) {
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
        Commands("stats", "[option]"),
        Commands("pkgbuild", "[option] <package(s)>"),
    ];

    if (optVersion) {
        writeln(_version);
        return 0;
    }

    if (help.helpWanted || args.length == 1) {
        printGetopt("", "pkm <operation> [...]", coms, help.options);
        return 0;
    }

    string yay = "/usr/bin/yay";

    string[] ops = args.dup;
    ops.popFront(); // removes [0] command
    ops.popFront(); // removes 'command'
    
    if (optAur) {
        ops ~= ["--aur"];
    }

    switch (args[1]) {
        case "search":
            return search(ops);
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
        case "stats":
            return wait(spawnProcess([yay, "-Ps"]));
        case "pkgbuild":
            return wait(spawnProcess([yay, "-Gp"] ~ ops));
        default:
            writefln("Unknown command \"%s\".", args[1]);
            return 1;
    }
}
