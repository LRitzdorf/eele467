# Homework 4: Linux Tutorial

Heh, this *totally* feels necessary for me. Definitely.

Example commands from selected sections of Ryan's [Linux Tutorial for Beginners](https://ryanstutorials.net/linuxtutorial) are below.


## Manual Pages

```sh
$ man hier
```

Actually really useful; contains an overview of the Linux filesystem structure.


## File Manipulation

```sh
$ mkdir -v example
```

Does `mkdir` really need a verbose flag?.


## `vi` Text Editor

```sh
$ vim ~/.vimrc
```

Why does this tutorial still use `vi`?.


## Wildcards

```sh
$ vim **/*.vhd
```

The double-star matches any number of directory descent steps.


## Permissions

```sh
$ ls -lAh
```

See also: [`eza`](https://github.com/eza-community/eza), a modern replacement for `ls`.


## Filters

```sh
$ sed -E 's/we only (want) part of this/and we \1 to include it in the result/g'
```

Capture groups are neat!


## `grep` and Regular Expressions

```sh
$ grep -E '^\s+$' example.txt
```

I hate it when files have whitespace-only lines.


## Piping and Redirection

```sh
$ find . -iname '*.vhd' | xargs vsg --fix -f
```

Finds all VHDL files and runs `vsg` on each of them.


## Process Management

```sh
$ sudo kill -9 1
```

A great way to make your system ***very*** angry.


## Scripting

```sh
#!/bin/sh
# A simple script which runs whatever arguments you give it, then echoes the bell character.
# Great for letting you know when a long-running command finishes!
$@
echo -ne '\007'
```
