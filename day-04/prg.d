import std.string;
import std.stdio;
import std.conv;

alias Predicate = bool function(string);

string[string][] loadPeople() {
    string[string][] people;
    string[string] person;
    foreach (line; stdin.byLine) {
        if (line.empty) {
            people ~= person.dup;
            person.clear;
        }

        foreach (item; line.split( " ")) {
            auto kv = item.split( ":");
            string k = kv[0].idup;
            person[k] = kv[1].idup;
        }
    }

    if (!person.empty) {
        people ~= person.dup;
    }
    return people;
}

bool hasAll(string[string] person, Predicate[string] keys) {
    foreach (key; keys.keys) {
        if (! (key in person)) {
            return false;
        }
    }
    return true;
}

bool hasAllValid(string[string] person, Predicate[string] keys) {
    foreach (key, val; keys) {
        if (! (key in person)) {
            return false;
        } else {
            auto valid = val( person[key]);
            if (!valid) {
                return false;
            }
        }
    }
    return true;
}

void main()
{
    auto people = loadPeople();

    Predicate[string] keys = [
    "byr": function (string byr) {
        try
        {
            int yr = to!int( byr);
            return yr >= 1920 && yr <= 2002 && byr.length == 4;
        }
        catch(Exception e)
        {
            return false;
        }
    }, "iyr":function (string iyr) {
        try
        {
            int yr = to!int( iyr);
            return yr >= 2010 && yr <= 2020 && iyr.length == 4;
        }
        catch(Exception e)
        {
            return false;
        }
    }, "eyr":function (string eyr) {
        try
        {
            int yr = to!int( eyr);
            return yr >= 2020 && yr <= 2030 && eyr.length == 4;
        }
        catch(Exception e)
        {
            return false;
        }
    }, "hgt":function (string hgt) {
        try
        {
            if (hgt.endsWith( "cm")) {
                int cm = to!int( hgt[0..$-2]);
                return cm >= 150 && cm <= 193;
            } else if (hgt.endsWith( "in")) {
                int inc = to!int( hgt[0..$-2]);
                return inc >= 59 && inc <= 76;
            } else {
                return false;
            }
        }
        catch(Exception e)
        {
            return false;
        }
    }, "hcl":function (string hcl) {
        if (hcl.length != 7 || hcl[0] != '#') {
            return false;
        }
        try
        {
            to!int( hcl[1..4], 16);
            return true;
        }
        catch(Exception e)
        {
            return false;
        }
    }, "ecl":function (string ecl) {
        return "amb blu brn gry grn hzl oth".indexOf( ecl) >= 0;
    }, "pid":function (string pid) {
        try
        {
            to!long( pid);
            return pid.length == 9;
        }
        catch(Exception e)
        {
            return false;
        }
    }];

    int valid1 = 0;
    int valid2 = 0;
    foreach (person; people) {
        if (hasAll( person, keys)) {
            valid1++;
        }
        if (hasAllValid( person, keys)) {
            valid2++;
        }
    }

    writeln( valid1);
    writeln( valid2);
}
