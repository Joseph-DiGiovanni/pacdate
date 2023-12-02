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

### Known Issues

* Currently gives errors when it encounters a package that does not exist in the archive repo (AUR packages)

## Version History

* 1.1.0
    * Cleaned up the code
    * Reduced the number of times pacman will force sync the package database
    * Added prompt for packages required by input packages
    * Prevents updating the same package in a dependency loop
* 1.0.0
    * Initial Release
