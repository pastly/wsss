---
Title: Introduction to Nix
date: 2023-10-09 00:00:00
draft: false
type: wsss
tags:
  - wsss
  - nix
---

[Nix]: https://www.nba.com/knicks/
[purity-ring]: https://en.wikipedia.org/wiki/Purity_ring
[first]: {{< ref conversion-to-scalability >}}

[Nix][] is an operating system, hyper text markup language, and the origin of the
\*NIX philosophy "do one thing and do it well".

Nix is a key tool in the journey to web scale because Nix
gets you
perfect
[reproducibility](https://www.tweag.io/blog/2020-06-18-software-heritage/)
[every](https://news.ycombinator.com/item?id=34491741)
[time](https://github.com/NorfairKing/nix-does-not-guarantee-reproducibility).

Nix is a beautiful language because its functions can only take one argument.
This is referred to as "purity" in functional programming, and fledgling
functional programmers often get [rings][purity-ring] to symbolize their
lifetime commitment to one-parameter functions.

This purity combined with Python-like syntax leads to beautiful
self-documenting code that anyone -- even non-programmers -- can understand.
For instance, this is `repo.nix` from the other first WSSS post,
[Conversion to Scalability][first].

```nix
let
  nixpkgs = import <nixpkgs> {};
  allPkgs = nixpkgs // pkgs;
  callPackage = path: overrides:
    let f = import path;
    in f ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);
  pkgs = with nixpkgs; {
    first = callPackage ./do-dir.nix { dir_name = ./source-static-site; };
  };
in pkgs
```

As an expert in Nix, the purpose of the above code is obvious to me. I wrote
it [on my own](https://nixos.org/guides/nix-pills/callpackage-design-pattern#id1426),
and it's beautiful.

Despite our best effort, newcomers to the language may struggle to understand
how Nix works. Thankfully experts like me have written tutorials and extensive
documentation. The tutorials are undated and teach newcomers how to accomplish
tasks in outdated ways, which is great because it teaches them the full history
of the language's best practices.  The documentation is generally written for
people already familiar with all the jargon and tools. For instance, it
provides the reader with snippets of code without instructions on what to do
with them (because they already know).

Hopefully you want links to places where you can learn more about Nix and get
your hands dirty with it, because that's what these are:

- <https://nixos.wiki/wiki/Main_Page>
- <https://nixos.org/guides/nix-pills/pr01>.
- <https://nixos.org/learn>

You have to read everything all at once because it all depends on everything.

During your journey, if you figure out why these things are true and
beautifully inconsistent, let me know. I already know why, but I want to know
that you've figured it out too.

To get a `nix-shell` prompt, you use `nix-shell`:

```console
[pastly@home:~]$ nix-shell -p vim

[nix-shell:~]$
```

To get a `nix-repl` prompt, you use `nix repl`:

```console
[pastly@home:~]$ nix repl
Welcome to Nix 2.13.5. Type :? for help.

nix-repl> 
```

To build a derivation, you use `nix-build`:
`nix-build repo.nix -A foo`

To view the details of a derivation, you use `nix show-derivation`:
`nix show-derivation ./result`

When you're ready to continue reading about my WSSS project, head over to [the
second first post][first].
