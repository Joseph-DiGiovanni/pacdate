#!/bin/bash
# Pacdate v1.1.0 created by Joseph DiGiovanni (jdigiovanni78 at gmail dot com)

function show_usage() {
  echo ""
  echo "Usage: $0 <YYYY/MM/DD> <package package2 ...>"
  echo ""
}

function is_valid_date_format() {
  local regex="^[0-9]{4}/(0[1-9]|1[0-2])/(0[1-9]|[1-2][0-9]|3[0-1])$"

  if [[ $1 =~ $regex ]]; then
    return 0
  else
    return 1
  fi
}

function clean_whitespace() {
    awk '{$1=$1};1'
}

if ! is_valid_date_format "$1"; then
  echo "Date is invalid: $1"
  show_usage
  exit 1
else
  PACDATE=$1
  PACDATE_PKGLIST=${*:2 | clean_whitespace}
fi

echo "Packages will be updated to the archived version from $PACDATE."
echo " "

if [ -f /etc/pacman.d/mirrorlist.pacdate_backup ]; then
  echo "Mirrorlist already backed up."
else
  echo "Backing up mirrorlist..."
  # Make backup of mirror list
  sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.pacdate_backup
  # Create new mirror list
  sudo sh -c "echo 'Server=https://archive.archlinux.org/repos/$PACDATE/\$repo/os/\$arch' > /etc/pacman.d/mirrorlist"
  echo "Done."
fi

echo " "

if [ -z "$PACDATE_PKGLIST" ]; then
  # Update all
  sudo pacman -Syyu
else  
  # Update selected packages
  sudo pacman -Syy $PACDATE_PKGLIST
  
  # Get all dependencies for next run

  # Make an array of input packages
  IFS=' ' read -ra PACKAGE_ARRAY <<< "$PACDATE_PKGLIST"

  # Loop through array of packages
  for CURRENT_PKG in "${PACKAGE_ARRAY[@]}"; do
    CURRENT_DEPS=$(pacman -Qi $CURRENT_PKG|grep "Depends On"|cut -d: -f2|tr -d '\n')
    PACDATE_DEPS="$PACDATE_DEPS $CURRENT_DEPS"
  done

  # Clean up whitespace and deduplicate package names
  PACDATE_DEPS=$(echo "$PACDATE_DEPS" | xargs -n1 | sort -u | xargs | clean_whitespace)

  echo " "
  echo "Dependency info:"
  # Ask to rerun on dependencies
  if [ -n "$PACDATE_DEPS" ]; then
    echo " "
    echo "Depends On : " $PACDATE_DEPS
    echo " "
    read -p "Rerun on dependencies? (y/N) " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      PACDATE_NEXTRUN="$PACDATE_NEXTRUN $PACDATE_DEPS"
    fi
  fi

  echo " "
  if [ -n "$PACDATE_NEXTRUN" ]; then
    export PACDATE_DONE="$PACDATE_DONE"
    $0 "$PACDATE" $(echo "$PACDATE_NEXTRUN" | clean_whitespace)
  fi
fi

if [ -f /etc/pacman.d/mirrorlist.pacdate_backup ]; then
  echo " "
  echo "Restoring mirrorlist from backup..."
  sudo cp /etc/pacman.d/mirrorlist.pacdate_backup /etc/pacman.d/mirrorlist
  sudo rm /etc/pacman.d/mirrorlist.pacdate_backup
  echo "Done."
fi
exit 0
