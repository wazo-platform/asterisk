# wazo-gdb

`wazo-gdb` makes it easier to analyse core dumps for older versions of Wazo.

## Usage

```
./wazo-gdb <wazo_version> <core_file>
```

Example:

```
./wazo-gdb 17.16 /tmp/core.0123456789
```

## Source files

`wazo-gdb` also creates a directory `sources` containing the Asterisk sources for the given version of Wazo.
