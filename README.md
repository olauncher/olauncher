# olauncher
The old launcher we all know and love with the quality-of-life features of the new launcher. This aims to support java 8 through modern java.

## How to use
1. Go to the [latest release](https://github.com/olauncher/olauncher/releases/latest)
2. Download the `olauncher-xxx-redist.jar` file
3. Run it

### But the launcher is broken :(
Have you used the new launcher in this .minecraft directory? If so, switch .minecraft directories or delete/rename the `launcher_profiles.json` folder. You will have to recreate your minecraft profiles, as the new `launcher_profiles.json` format is incompatible with this version.

## Features
- Microsoft authentication
- Bundled JVMs
  - Automatically downloads the appropriate JVM for all minecraft versions
  - You just need a runtime to open the actual launcher
  - You can still provide your own JVMs
- Update checking

## Planned Features
- Add skin/cape management

### Minor TODOs
- Replace Mojang's Hopper service with our own
- Support demo users (if they have a Microsoft account but no Minecraft profile)
- Use `version_manifest_v2`

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
  - Make sure you've run `git submodule update --init` as this script uses the `AutoOL` submodule.
  - Generates the redistributable JAR - Do not distribute the JARs in `olauncher/target`!
