function assocToJSON(assoc) {
    assoc.replace("{", "[");
    assoc.replace("}", "]");
    assoc.replace("<|", "{");
    assoc.replace("|>", "}");
    assoc.replace("->", ":");
    return assoc;
}
