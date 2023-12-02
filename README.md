# Pacdate

Automate downgrading Archlinux packages to a specific date with pacman.

## Getting Started

### Dependencies

* Pacman

### Installing

You can run this script from anywhere, but it can be easily installed to a system via the [AUR](https://aur.archlinux.org/packages/pacdate).

### Executing program

To downgrade the entire system to a specific date in the past use:

```
pacdate 2023/11/26
```

Make sure you use YYYY/MM/DD format.

Add package names to the end of the command separated by spaces to only act on specific packages:

```
pacdate 2023/11/13 blender
```

## Version History

* 1.0.0
    * Initial Release
