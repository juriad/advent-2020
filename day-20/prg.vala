errordomain PrgError {
    MISSING_ARGUMENT,
    CORNER_NOT_FOUND;
}

enum Dir {
    T, B, L, R;
}

class Tile {
    public int id;
    public int size;
    Gee.List<string> grid;
    public string orientation;

    public Tile(int id, Gee.List<string> grid, string orientation = "") {
        this.id = id;
        this.size = grid.size;
        this.grid = grid;
        this.orientation = orientation;
        // stdout.printf ("%d %d\n", id, size);
    }

    public Tile.from_lines(Gee.List<string> lines) {
        string header = lines[0];
        int offset = "Tile ".length;
        string strId = header.substring(offset, header.length - offset - 1);

        var grid = lines.slice(1, lines.size);
        this(int.parse(strId), grid);
    }

    public string top() {
        return grid[0];
    }

    public string bottom() {
        return grid[size - 1].reverse();
    }

    public string left() {
        string l = "";
        for (int i = 0; i < size; i++) {
            l += grid[i].substring(0, 1);
        }
        return l.reverse();
    }

    public string right() {
        string r = "";
        for (int i = 0; i < size; i++) {
            r += grid[i].substring(grid[i].length - 1, 1);
        }
        return r;
    }

    public Gee.List<string> borders() {
        var borders = new Gee.ArrayList<string>();
        borders.add(top());
        borders.add(bottom());
        borders.add(left());
        borders.add(right());
        return borders;
    }

    public Tile flip() {
        var g = new Gee.ArrayList<string>();
        foreach (string l in grid) {
            g.add(l.reverse());
        }
        return new Tile(id, g, orientation + "F");
    }

    public Tile rotate() {
        var g = new Gee.ArrayList<string>();
        foreach (string l in grid) {
            g.add("");
        }
        for (int i = 0; i < size; i++) {
            foreach (string l in grid) {
                g[i] = g[i] + l.substring(size - i - 1, 1);
            }
        }

        return new Tile(id, g, orientation + "R");
    }

    public static Tile stitch(Gee.List<Gee.List<Tile>> grid) {
        var lines = new Gee.ArrayList<string>();
        foreach (var row in grid) {
            for (int r = 1; r < row[0].size - 1; r++) {
                string line = "";
                foreach (Tile t in row) {
                    line += t.grid[r].substring(1, t.grid[r].length - 2);
                }
                lines.add(line);
            }
        }

        return new Tile(0, lines);
    }

    public void print() {
        foreach (string line in grid) {
            stdout.printf("%s\n", line);
        }
    }

    public int countPatterns(string[] pattern) {
        Gee.List<Regex> regexes = new Gee.ArrayList<Regex>();
        for (int i = 0; i < pattern.length; i++) {
            regexes.add(new Regex(pattern[i].replace(" ", "."), RegexCompileFlags.OPTIMIZE, 0));
        }

        int matches = 0;

        for (int i = 0; i < size - regexes.size; i++) {
            int start = 0;
            MatchInfo matchInfo;

            while (regexes[0].match(grid[i].substring(start), 0, out matchInfo)) {
                int pos;
                matchInfo.fetch_pos(0, out pos, null);
                start += pos;

                bool found = true;
                for (int n = 1; n < regexes.size; n++) {
                    if (!regexes[n].match(grid[i + n].substring(start, pattern[n].length))) {
                        found = false;
                        break;
                    }
                }

                if (found) {
                    // string match = matchInfo.fetch(0);
                    // stdout.printf("Line %d position %d, sub %s\n", i, start, grid[i].substring(start));
                    matches++;
                }

                start++;
            }
        }

        return matches;
    }

    public int count(char x) {
        int cnt = 0;
        foreach (string m in grid) {
            foreach (char c in m.to_utf8()) {
                if (c == x) {
                    cnt++;
                }
            }
        }
        return cnt;
    }
}

Gee.List<Tile> readTiles(File file) {
    var stream = new DataInputStream (file.read());

    var tiles = new Gee.ArrayList<Tile>();

    var lines = new Gee.ArrayList<string>();
    string line;
    // Read lines until end of file (null) is reached
    while ((line = stream.read_line (null)) != null) {
        if (line.length == 0) {
            tiles.add(new Tile.from_lines(lines));
            lines = new Gee.ArrayList<string>();
        } else {
            lines.add(line);
        }
    }
    if (!lines.is_empty) {
        tiles.add(new Tile.from_lines(lines));
    }

    return tiles;
}

Gee.Map<string, Tile> uniqueBorders(Gee.List<Tile> tiles) {
    var borderTiles = new Gee.HashMap<string, Tile>();
    foreach (Tile t in tiles) {
        foreach (string b in t.borders()) {
            if (borderTiles.has_key(b)) {
                borderTiles.unset(b);
            } else {
                borderTiles[b] = t;
            }
        }
        foreach (string b in t.flip().borders()) {
            if (borderTiles.has_key(b)) {
                borderTiles.unset(b);
            } else {
                borderTiles[b] = t;
            }
        }
    }
    return borderTiles;
}

Gee.List<Tile> findCorners(Gee.Map<string, Tile> uniqueBorders) {
    var tileCounts = new Gee.HashMap<Tile, int?>();
    foreach (var t in uniqueBorders.values) {
        tileCounts[t] = (tileCounts[t] ?? 0) + 1;
    }

    var corners = new Gee.ArrayList<Tile>();
    foreach (var e in tileCounts.entries) {
        if (e.value == 4) {
            corners.add(e.key);
        }
    }

    return corners;
}

Tile findTopLeftOrientation(Tile corner, Gee.Map<string, Tile> uniqueBorders) {
    Tile t = corner;
    for (int i = 0; i < 4; i++) {
        if (uniqueBorders.has_key(t.left()) && uniqueBorders.has_key(t.top())) {
            return t;
        }
        t = t.rotate();
    }
    throw new PrgError.CORNER_NOT_FOUND("Top left corner orientation could not be found");
}

delegate string BorderExtractor(Tile t);

Tile? findMatchingTile(Tile tile, BorderExtractor extractor, Gee.List<Tile> tiles) {
    string border = extractor(tile.rotate().rotate()).reverse();

    foreach (Tile t in tiles) {
        for (int i = 0; i < 4; i++) {
            if (extractor(t) == border && t.id != tile.id) {
                return t;
            }
            t = t.rotate();
        }
    }
    foreach (Tile t in tiles) {
        t = t.flip();
        for (int i = 0; i < 4; i++) {
            if (extractor(t) == border && t.id != tile.id) {
                return t;
            }
            t = t.rotate();
        }
    }
    return null;
}

Gee.List<Gee.List<Tile>> positionTiles(Tile corner, Gee.List<Tile> tiles) {
    var grid = new Gee.ArrayList<Gee.List<Tile>>();
    var row = new Gee.ArrayList<Tile>();
    row.add(corner);
    grid.add(row);

    int r = 0;
    int c = 1;
    while (true) {
        if (c > 0) {
            Tile right = findMatchingTile(grid[r][c-1], (t) => t.left(), tiles);
            if (right == null) {
                r++;
                c = 0;
            } else {
                grid[r].add(right);
                c++;
            }
        } else {
            Tile bottom = findMatchingTile(grid[r-1][c], (t) => t.top(), tiles);
            if (bottom == null) {
                return grid;
            } else {
                row = new Gee.ArrayList<Tile>();
                row.add(bottom);
                grid.add(row);
                c++;
            }
        }
    }
}

int countMonsters(Tile tile, string[] monster) {
    Tile t = tile;
    for (int i = 0; i < 4; i++) {
        int cnt = t.countPatterns(monster);
        if (cnt > 0) {
            return cnt;
        }
        t = t.rotate();
    }
    return countMonsters(tile.flip(), monster);
}

void main(string[] args) {
    if (args.length <= 1) {
        throw new PrgError.MISSING_ARGUMENT("Provide a file name");
    }

    var file = File.new_for_path (args[1]);
    Gee.List<Tile> tiles = readTiles(file);

    Gee.Map<string, Tile> borders = uniqueBorders(tiles);
    Gee.List<Tile> corners = findCorners(borders);

    long p = 1;
    foreach (Tile t in corners) {
        p *= t.id;
    }
    stdout.printf ("Corners: %ld\n", p);

    Tile tl = findTopLeftOrientation(corners[0], borders);
    // stdout.printf ("TL: %d %s\n", tl.id, tl.orientation);

    var grid = positionTiles(tl, tiles);
    // foreach (var row in grid) {
    //     foreach (Tile t in row) {
    //         stdout.printf ("%d %-4s ", t.id, t.orientation);
    //     }
    //     stdout.printf ("\n");
    // }

    Tile image = Tile.stitch(grid);
    // image.print();

    string[] monster = {
        "                  # ",
        "#    ##    ##    ###",
        " #  #  #  #  #  #   "
    };


    int mSize = new Tile(-1, new Gee.ArrayList<string>.wrap(monster)).count('#');
    int mCount = countMonsters(image, monster);
    // stdout.printf("Monster %d: %d times\n", mSize, mCount);

    int darkCount = image.count('#');
    stdout.printf("Density: %d\n", darkCount - mCount * mSize);
}
