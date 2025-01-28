{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "legacylauncher";
  version = "latest";

  # URL to the `.deb` file (replace with the correct URL and sha256 hash)
  src = pkgs.fetchurl {
    url = "https://llaun.ch/ubuntu";
    sha256 = "f0f3e6506ff6a4e940bbb6e0decbf86fe5ce290d9e53b2fb7e87b4b2a51bfdbc"; # Replace with actual sha256 hash
  };

  nativeBuildInputs = [ pkgs.dpkg pkgs.bash pkgs.wget ];
  buildInputs = [ pkgs.jre8 ];

  unpackPhase = ''
    # Extract the .deb file using dpkg
    mkdir -p extracted
    dpkg-deb -x ${src} extracted
  '';

  installPhase = ''
    # Prepare installation directories
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/128x128/apps
    mkdir -p $out/share/icons/hicolor/256x256/apps

    mkdir -p $out/lib/legacylauncher

    # Copy the extracted files to the proper locations
    cp -r extracted/usr/share/applications/* $out/share/applications/
    cp -r extracted/usr/share/icons/hicolor/128x128/apps/* $out/share/icons/hicolor/128x128/apps/
    cp -r extracted/usr/share/icons/hicolor/256x256/apps/* $out/share/icons/hicolor/256x256/apps/

    # Download the bootstrap JAR
    echo "Downloading shared bootstrap"
    for host in llaun.ch eu1.llaun.ch lln4.ru ru1.lln4.ru
    do
        echo "Trying $host..."
        wget https://$host/jar -O $out/lib/legacylauncher/bootstrap.jar && break
    done

    if [ ! -f "$out/lib/legacylauncher/bootstrap.jar" ]; then
        echo "Failed to download bootstrap" >&2
        exit 1
    fi

    # Rewrite and install the main shell script
    cat <<EOF > $out/bin/legacylauncher
#!/usr/bin/env bash

set -euo pipefail

APP_DIR=$out/bin/
BOOTSTRAP="\$APP_DIR/bootstrap.jar"
SHARED_BOOTSTRAP="$out/lib/legacylauncher/bootstrap.jar"

[ ! -d "\$APP_DIR" ] && echo "Creating app directory" && mkdir -p "\$APP_DIR"
[ ! -f "\$BOOTSTRAP" ] && echo "Copying shared bootstrap" && cp "\$SHARED_BOOTSTRAP" "\$BOOTSTRAP"

echo "Starting the launcher"
exec java -jar "\$BOOTSTRAP" "\$@"
EOF

    chmod +x $out/bin/legacylauncher
  '';

  meta = with pkgs.lib; {
    description = "Legacy Launcher is a simple and lightweight Minecraft launcher";
    homepage = "https://llaun.ch";
    license = licenses.free;
    maintainers = with maintainers; [ turikhay rminstrel chatgpt ];
  };
}
