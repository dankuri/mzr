# mzr

Cross-platform & shell-independent `time` alternative with reported max memory usage & better formatted time. Written in [zig](https://ziglang.org/)

## Installation
For now, you'll first need to [install zig](https://ziglang.org/learn/getting-started/#installing-zig)

Then, to build from source:
```bash
git clone https://github.com/dankuri/mzr.git
cd mzr
zig build -Doptimize=ReleaseSafe
# put it somewhere in $PATH
sudo ln zig-out/bin/mzr /usr/local/bin/mzr # e.g on Unix system
```

## Motivation

`time` implementation is different in zsh, bash and some linux distro's even ship their own `time` (located at `/usr/bin/time`). Also, the output of it can be puzzling, when using for first time.
So, I decided to write my own version, with potential to expand it to show additional stats (avg/min/max cpu & mem usage, pid).
