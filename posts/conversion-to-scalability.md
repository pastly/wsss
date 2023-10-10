---
Title: Conversion to Scalability 
date: 2023-10-09 01:00:00
draft: false
type: wsss
tags:
  - wsss
  - nix
---

Welcome. You're here either because you want to build a scalable static site,
you're lost, or your friend played a trick on you.

Locate a copy of your existing non-scalable static site. Its layout might look
something like this (mine did):

```console
[pastly@home:~/src/my-first-website]$ tree .
.
├── blog
│   ├── 1st-post.html
│   ├── first-post.html
│   ├── hello-world.html
│   ├── post-1.html
│   ├── test.html
├── css
│   ├── exploit-tor-browser-users.css
│   └── style.ccs
│   └── style.css
├── index.html
└── js
    └── deliver-ads.js

4 directories, 14 files

```
[first]: {{< ref intro-to-nix >}}

In this post I am moving the contents of my blog into my computer's nix store.
A Nix Store is kind of like an app store. You can
[search](https://www.apple.com/app-store/) for software in the global nix store
called "nixpkgs." For more information on Nix, see the first first post, [Introduction to Nix][first].

I created a directory and starting hacking away. Here's where I've landed,
which ~~false starts~~ pointless details elided.

```console
[pastly@home:~/src/wsss]$ tree
.
├── do-dir.nix
├── do-dir.sh
├── do-file.nix
├── do-file.sh
├── repo.nix
└── source-static-site -> [...]
```

`source-static-site` is a symlink to `~/src/my-first-website` for you.

`repo.nix` is this, and defines the root of a "nix package repository" built upon the main
nixpkgs repository that comes with NixOS.

```nix
let
  nixpkgs = import <nixpkgs> {};
  allPkgs = nixpkgs // pkgs;
  callPackage = path: overrides:
    let f = import path;
    in f ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);
  pkgs = with nixpkgs; {
    post01 = callPackage ./do-dir.nix { dir_name = ./source-static-site; };
  };
in pkgs
```

I build the "post01" package with `nix-build repo.nix -A post01`. This kicks off
a chain of recursion that stores each individual file and directory in my nix
store.

`do-file.nix` and `do-file.sh` are here, where the former is basically just
boiler plate to call the second, and the second is boiler plate for calling
`cp`.


```nix
{ pkgs, file_name }:
derivation {
  inherit file_name;
  inherit (pkgs) coreutils;
  name = builtins.concatStringsSep "-" [(builtins.baseNameOf file_name) "compiled"];
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./do-file.sh ];
  system = builtins.currentSystem;
}
```

```bash
$coreutils/bin/cp $file_name $out
```

Beautiful, and in need of no explanation.

`do-dir.nix` and `do-dir.sh` are here and slightly more complex than their file
counterparts.

```nix
{ pkgs, lib, callPackage, dir_name }:
let
  contents = builtins.readDir dir_name;
  files = map (x: callPackage ./do-file.nix { file_name = dir_name + "/${x}"; }) (builtins.attrNames (lib.attrsets.filterAttrs (n: v: v == "regular") contents));
  dirs =  map (x: callPackage ./do-dir.nix  { dir_name  = dir_name + "/${x}"; }) (builtins.attrNames (lib.attrsets.filterAttrs (n: v: v == "directory") contents));
in 
  derivation {
    inherit dir_name;
    inherit files dirs;
    inherit (pkgs) coreutils;
    name = builtins.concatStringsSep "-" [(builtins.baseNameOf dir_name) "compiled"];
    builder = "${pkgs.bash}/bin/bash";
    args = [ ./do-dir.sh ];
    system = builtins.currentSystem;
  }
```

```bash
echo "FILES -------------------------------------------------" >> $out
for f in $files; do
	echo $f >> $out
done

echo "DIRS -------------------------------------------------" >> $out
for f in $dirs; do
	echo $f >> $out
done
```

The output of a directory in the nix store is a text file that lists all its
file and directory children. The key to recursion is the `callPackage` calls
that are made once for every sub file and sub directory of the current one.

After a `nix-build repo.nix -A post01`, you can now `cat result` and get
something like this:

```
[pastly@home:~/src/wsss]$ cat result
FILES -------------------------------------------------
/nix/store/8qzmb9k8im2hli8xfzi8skxf1ps389dw-index.html-compiled
DIRS -------------------------------------------------
/nix/store/l3m9m96nck2wmm8nh1w5308g0pnb3p85-blog-compiled
/nix/store/9d3a196hx42c2gsf2qnv867sj4ymmh2k-css-compiled
/nix/store/dilifja1h3v6ppwxb4dlc0nm310hir4q-js-compiled
```

And you can further drill down. E.g.

```console
[pastly@home:~/src/wsss]$ cat /nix/store/dilifja1h3v6ppwxb4dlc0nm310hir4q-js-compiled
FILES -------------------------------------------------
/nix/store/zyvb8qcmlqn4vsf8q7bi4p2mbybv6phn-deliver-ads.js-compiled
DIRS -------------------------------------------------

[pastly@home:~/src/wsss]$ cat /nix/store/zyvb8qcmlqn4vsf8q7bi4p2mbybv6phn-deliver-ads.js-compiled
[... the contents of deliver-ads.js ...]
```

This is the stopping point for today. Next time we'll involve Rust in some way.
I know how, but you don't. So stay tuned. This will become the most WS of all SS.

The WSSS source code is on github: <https://github.com/pastly/wsss>.
The version as of this post is branch [post01](https://github.com/pastly/wsss/tree/post01).
