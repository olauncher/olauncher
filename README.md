# olauncher
The old launcher we all know and love with the quality-of-life features of the new launcher.

## TODO
- Add Microsoft authentication (DONE)
- Add skin/cape management
- Add built-in JVMs (use java 8 for some versions and 17 for others)

### Lower priority stuff
- Switch from `version_manifest` to `version_manifest_v2`
- Try to maintain support for Java 8 to latest (Still working)
- Support demo users
- Paperclip-style redistributable
- Change launcher name and version
- Allow to switch out options.txt files (per-profile maybe?)

## How to build from source
The commands must be run in the following order to build from source:
- `decompile.sh`
  - Downloads original jar and decompiles it
- `init.sh`
  - Turns decompiled sources into a git repository
- `applyPatches.sh`
  - Applies OLauncher patches to the decompiled sources
- `mvn clean package`
  - Compiles the patched launcher
- `genredist.sh` (optional)
  - Generates the redistributable JAR - Do not distribute the JARs in `olauncher/target`!
