# sh-realpath

![shellcheck-ci](https://github.com/sambacha/sh-realpath/workflows/shellcheck-ci/badge.svg) 

- [sh-realpath](#sh-realpath)
  * [Overview](#overview)
  * [Other Solutions](#other-solutions)
    + [Install GNU Utils via Homebrew](#install-gnu-utils-via-homebrew)
      - [Pearl](#pearl)
  * [Usage](#usage)
  * [API](#api)
    + [readlink Emulation](#readlink-emulation)
  * [Quickstart](#quickstart)


## Overview 

> *A portable, pure shell implementation of realpath*

Copy the functions in [realpath.sh](realpath.sh) into your shell script to
avoid introducing a dependency on either `realpath` or `readlink -f`, since:

* `realpath` does not come installed by default
* `readlink -f` **is not portable** to OS-X 

## Other Solutions

### Install GNU Utils via Homebrew

`$ brew install coreutils` 

`$ greadlink -f $FILE`

`export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"`

#### Pearl 

```perl
perl -MCwd -e 'print Cwd::abs_path shift' ~/non-absolute/file
```

## Usage

    $ source ./realpath.sh
    $ realpath /proc/self
    /proc/2772

Or we can get tricky:

```bash
    $ cd /tmp
    $ mkdir -p somedir/targetdir somedir/anotherdir
    $ ln -s somedir somedirlink
    $ ln -s somedir/anotherdir/../anotherlink somelink
    $ ln -s targetdir/targetpath somedir/anotherlink
    $ realpath .///somedirlink/././anotherdir/../../somelink
    /tmp/somedir/targetdir/targetpath
```

## API

Note: unlike `realpath(1)`, these functions take no options; **do not** use `--` to escape any arguments

| Function                          | Description
| --------------------------------- | -------------
| <pre>realpath PATH</pre>          | Resolve all symlinks to `PATH`, then output the canonicalized result
| <pre>resolve_symlinks PATH</pre>  | If `PATH` is a symlink, follow it as many times as possible; output the path of the first non-symlink found
| <pre>canonicalize_path PATH</pre> | Output absolute path that `PATH` refers to, resolving any relative directories (`.`, `..`) in `PATH` and any symlinks in `PATH`'s ancestor directories

### readlink Emulation

`realpath.sh` includes optional readlink emulation.  It exposes a `readlink`
function that calls the system `readlink(1)` if it exists.  Otherwise it uses
`stat(1)` to emulate the same functionality.  In contrast to the functions in
the previous section, you may pass `--` as the first argument, since you may be
calling the system `readlink(1)`.

## Quickstart

`readlink -f` does two things

1) resolves symlinks recursively   
2) canonicalizes the result, hence:  

```bash
realpath() {
    canonicalize_path "$(resolve_symlinks "$1")"
}
First, the symlink resolver implementation:

resolve_symlinks() {
    local dir_context path
    path=$(readlink -- "$1")
    if [ $? -eq 0 ]; then
        dir_context=$(dirname -- "$1")
        resolve_symlinks "$(_prepend_path_if_relative "$dir_context" "$path")"
    else
        printf '%s\n' "$1"
    fi
}

_prepend_path_if_relative() {
    case "$2" in
        /* ) printf '%s\n' "$2" ;;
         * ) printf '%s\n' "$1/$2" ;;
    esac 
}
```

Finally, the function for canonicalizing a path:   

```bash 
canonicalize_path() {
    if [ -d "$1" ]; then
        _canonicalize_dir_path "$1"
    else
        _canonicalize_file_path "$1"
    fi
}   

_canonicalize_dir_path() {
    (cd "$1" 2>/dev/null && pwd -P) 
}           

_canonicalize_file_path() {
    local dir file
    dir=$(dirname -- "$1")
    file=$(basename -- "$1")
    (cd "$dir" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$file")
}
```

[quickstart source: stackoverflow](https://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac)

## License 

MIT

