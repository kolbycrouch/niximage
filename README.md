# NixImage

Build fully contained AppImages with the Nix package manager!

## What is this?

NixImage is a set of nix expressions that generates a package, it's dependencies and an environment to turn that into an AppImage.

## How does this work?

We use nix to build a closure ( usually a package and it's graph of dependencies ) and copy that closure into an AppImage directory.
We then use a loader script and binary along with statically compiled binaries for dash and proot to start the generated package.

## Why?

Using nix and AppImage we can build a single file executable containing an application and everything it depends on except for the kernel.
This way we can run this application on any system running a ~recent version of the kernel the package was built for.

# FAQ's

## Do I need to know nix to use this?

Not for most packages. Some will require a little knowledge of nix to setup, especially if you want to customize the build.

## Does this compile a lot of code?

It depends on what is built.

## What systems does it support?

In theory it supports any system with both nix and fuse ( Linux,FreeBSD,NetBSD etc.. ).
In practice it has been tested only with Linux on x86_64 and aarch64.
