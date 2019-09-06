mdtable
=======

Convert TSV to Markdown table.

```
$ cat src.txt
Name	Power	Toughness
Ghitu Lavarunner	1	2
Viashino Pyromancer	2	1
Goblin Chainwhirler	3	3
$ cat src.txt | mdtable
| Name                | Power | Toughness |
|---------------------|-------|-----------|
| Ghitu Lavarunner    | 1     | 2         |
| Viashino Pyromancer | 2     | 1         |
| Goblin Chainwhirler | 3     | 3         |
```

Usage
-----

```
$ mdtable [<option(s)>] [<file(s)>]
convert TSV to Markdown table.

options:
  -d, --deconvert  convert Markdown table to TSV
      --help       print usage
```

Requirements
------------

- `column`

Installation
------------

1. Copy `mdtable` into your `$PATH`.
2. Make `mdtable` executable.

### Example

```
$ curl -L https://raw.githubusercontent.com/kusabashira/mdtable/master/mdtable > ~/bin/mdtable
$ chmod +x ~/bin/mdtable
```

Note: In this example, `$HOME/bin` must be included in `$PATH`.

Options
-------

### -d, --deconvert

Convert Markdown table to TSV.

```
$ cat src.txt
| Name                | Power | Toughness |
|---------------------|-------|-----------|
| Ghitu Lavarunner    | 1     | 2         |
| Viashino Pyromancer | 2     | 1         |
| Goblin Chainwhirler | 3     | 3         |
$ cat src.txt | mdtable -d
Name	Power	Toughness
Ghitu Lavarunner	1	2
Viashino Pyromancer	2	1
Goblin Chainwhirler	3	3
```

### --help

Print usage.

```
$ mdtable --help
(Print usage)
```

License
-------

MIT License

Author
------

nil2 <nil2@nil2.org>
