### Installation

```shell
git clone https://github.com/yaitskov/upload-doc-to-hackage
cd upload-doc-to-hackage
nix-env -f default.nix --install
```

### Usage

Just run `upload-doc-to-hackage.sh -u <hackage-user> -p <passfile>` in root project.

#### Help

```
Usage: upload-doc-to-hackage.sh [ options ]

The script uploads cabal package docs to hackage.
Run the script in the root project folder with cabal file.
If doc archive is missing or older than current project version
then doc archive is generated.

User and Password can be set via HACKAGE_USER and HACKAGE_PASS
environment variables correspondently.
HACKAGE_PASS default is ~/.hackage-pass

Options:
  -u <user>
  -p <password-file>
  -v                   verbose
  -d                   dry run
```
