module pkm.config;

import std.conv: to;
import std.file: exists;
import std.stdio: writeln;

import dyaml;

Config getConfig(string[] paths) {
    foreach (path; paths) {
        if (path.exists) {
            return __getConfig(path);
        }
    }
    return Config();
}

Config __getConfig(string configPath) {
    Node root;
    try {
        root = Loader.fromFile(configPath).load();
    } catch (YAMLException e) {
        return Config();
    }

    Config conf;

    if (root.type != NodeType.mapping) return conf;

    root.getKey!string(&conf.yaypath, "yaypath");
    root.getKey!bool(&conf.yaysearch, "yaysearch");
    root.getKey!bool(&conf.color, "color");
    root.getKey!bool(&conf.auronly, "auronly");

    return conf;
}

string configGetGlobal(string configPath, string field) {
    Node root = Loader.fromFile(configPath).load();

    if (root.type != NodeType.mapping) return "";
    if (!root.containsKeyAs!string(field)) return "";

    return root[field].as!string;
}

private bool containsKeyType(Node node, string key, NodeType type) {
    if (node.containsKey(key)) {
        if (node[key].type == type) {
            return true;
        }
    }
    return false;
}

private bool containsKeyAs(T)(Node node, string key) {
    if (node.containsKey(key)) {
        if (node[key].convertsTo!T) {
            return true;
        }
    }
    return false;
}

private void getKey(T)(Node node, T* variable, string field) {
    if (node.containsKeyAs!T(field)) {
        *variable = node[field].as!T;
    }
}


struct Config {
    string yaypath = "";
    bool yaysearch = false;
    bool color = true;
    bool auronly = false;
}