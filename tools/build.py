#!/usr/bin/env python3
"""Render src/track_scripts/*.tpl into track_scripts/.

Instruqt lifecycle scripts can't read files from this repo, so the files they need are
inlined at build time. Markers, each on a line of its own:

  #@file   <repo path> <dest path> <mode>   (bash)  write one file
  #@bundle <repo dir>  <dest dir>           (bash)  unpack a whole directory
  #@psfile <repo path> <dest path>          (PowerShell) write one file
  #@include <repo path>                     paste a file's text in place (shared snippets)

src/track_scripts/*.tpl  -> track_scripts/<name>
src/challenges/<dir>/*   -> <dir>/*   (challenge folders; assignment.md is copied as is)

Run from the repo root:  python3 tools/build.py
"""
import base64, io, os, sys, tarfile, textwrap

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "src", "track_scripts")
OUT = os.path.join(ROOT, "track_scripts")


def b64(data: bytes) -> str:
    return "\n".join(textwrap.wrap(base64.b64encode(data).decode(), 76))


def bash_file(src, dest, mode):
    data = open(os.path.join(ROOT, src), "rb").read()
    return (f'mkdir -p "$(dirname {dest})"\n'
            f"base64 -d > {dest} <<'__B64__'\n{b64(data)}\n__B64__\n"
            f"chmod {mode} {dest}\n")


def bash_bundle(src, dest):
    buf = io.BytesIO()
    with tarfile.open(fileobj=buf, mode="w:gz") as tar:
        tar.add(os.path.join(ROOT, src), arcname=".")
    return (f"mkdir -p {dest}\n"
            f"base64 -d <<'__B64__' | tar -xz -C {dest}\n{b64(buf.getvalue())}\n__B64__\n")


def ps_file(src, dest):
    data = base64.b64encode(open(os.path.join(ROOT, src), "rb").read()).decode()
    return (f"New-Item -ItemType Directory -Force -Path (Split-Path '{dest}') | Out-Null\n"
            f"[IO.File]::WriteAllBytes('{dest}', [Convert]::FromBase64String('{data}'))\n")


def render(text):
    out = []
    for line in text.splitlines(keepends=True):
        parts = line.split()
        if parts[:1] == ["#@file"]:
            out.append(bash_file(*parts[1:4]))
        elif parts[:1] == ["#@bundle"]:
            out.append(bash_bundle(*parts[1:3]))
        elif parts[:1] == ["#@psfile"]:
            out.append(ps_file(*parts[1:3]))
        elif parts[:1] == ["#@include"]:
            out.append(open(os.path.join(ROOT, parts[1])).read())
        else:
            out.append(line)
    return "".join(out)


SYNC = [  # files Terraform user-data needs, copied next to it before bundling
    ("assets/app/portal_api.py", "assets/terraform/files/portal_api.py"),
    ("assets/bin/preflight.sh", "assets/terraform/files/preflight.sh"),
]


def main():
    for src, dst in SYNC:
        with open(os.path.join(ROOT, src), "rb") as a, open(os.path.join(ROOT, dst), "wb") as b:
            b.write(a.read())
    os.makedirs(OUT, exist_ok=True)
    for name in sorted(os.listdir(SRC)):
        if not name.endswith(".tpl"):
            continue
        target = os.path.join(OUT, name[:-4])
        with open(os.path.join(SRC, name)) as f:
            rendered = render(f.read())
        with open(target, "w") as f:
            f.write(rendered)
        os.chmod(target, 0o755)
        print(f"built track_scripts/{name[:-4]}")
    csrc = os.path.join(ROOT, "src", "challenges")
    for chal in sorted(os.listdir(csrc)):
        os.makedirs(os.path.join(ROOT, chal), exist_ok=True)
        for name in sorted(os.listdir(os.path.join(csrc, chal))):
            with open(os.path.join(csrc, chal, name)) as f:
                text = f.read()
            target = os.path.join(ROOT, chal, name)
            with open(target, "w") as f:
                f.write(text if name.endswith(".md") else render(text))
            if not name.endswith(".md"):
                os.chmod(target, 0o755)
        print(f"built {chal}/")


if __name__ == "__main__":
    sys.exit(main())
