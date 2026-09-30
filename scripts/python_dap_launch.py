"""Run a saved OJ solution with file-backed stdin under debugpy."""

import os
import runpy
import sys


def main():
    source, input_path, *arguments = sys.argv[1:]
    # Redirect fd 0 too, so input(), sys.stdin.buffer and os.read(0, ...) agree.
    with open(input_path, "rb") as sample:
        os.dup2(sample.fileno(), 0)
        sys.stdin = open(0, "r", encoding="utf-8", closefd=False)
        sys.__stdin__ = sys.stdin
        sys.argv = [source, *arguments]
        sys.path[0] = os.path.dirname(source)
        runpy.run_path(source, run_name="__main__")


if __name__ == "__main__":
    main()
