module pkm.config;

import std.conv: to;
import std.file: exists;
import std.stdio: writeln;
import std.array: split;

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
        writeln("Error: Invalid config. Using default configuration.");
        return Config();
    }

    Config conf;

    const NodeType mapping = NodeType.mapping;

    if (root.type != mapping) return conf;

    root.getKey!string(&conf.yaypath, "yaypath");
    root.getKey!bool(&conf.yaysearch, "yaysearch");
    root.getKey!bool(&conf.color, "color");
    root.getKey!bool(&conf.auronly, "auronly");

    if (root.hasKeyType!mapping("custom")) {
        auto custom = root["custom"].mappingKeys;
        foreach (key; custom) {
            if (key.type == NodeType.string) {
                string keyname = key.as!string;
                conf.custom ~= keyname;
                conf.args ~= root["custom"][keyname].as!string.split(' ');
            }
        }
        // writeln(conf.custom);
        // writeln(conf.args);
    }

    return conf;
}

string configGetGlobal(string configPath, string field) {
    Node root = Loader.fromFile(configPath).load();

    if (root.type != NodeType.mapping) return "";
    if (!root.hasKeyAs!string(field)) return "";

    return root[field].as!string;
}

private bool hasKeyType(NodeType T)(Node node, string key) {
    if (node.containsKey(key)) {
        if (node[key].type == T) {
            return true;
        }
    }
    return false;
}

private bool hasKeyAs(T)(Node node, string key) {
    if (node.containsKey(key)) {
        if (node[key].convertsTo!T) {
            return true;
        }
    }
    return false;
}

private void getKey(T)(Node node, T* variable, string field) {
    if (node.hasKeyAs!T(field)) {
        *variable = node[field].as!T;
    }
}


struct Config {
    string yaypath = "";
    bool yaysearch = false;
    bool color = true;
    bool auronly = false;
    string[] custom = [];
    string[][] args = [];
}