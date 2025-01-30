{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "legacylauncher";

  # URL to the `.deb` file
  src = pkgs.fetchurl {
    url = "https://llaun.ch/ubuntu";
    sha256 = "f0f3e6506ff6a4e940bbb6e0decbf86fe5ce290d9e53b2fb7e87b4b2a51bfdbc";
  };

  nativeBuildInputs = with pkgs; [ dpkg bash wget jre8 ];
  buildInputs = with pkgs; [ jre8 ];

  unpackPhase = ''
    mkdir -p extracted
    dpkg-deb -x ${src} extracted
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/128x128/apps
    mkdir -p $out/share/icons/hicolor/256x256/apps
    mkdir -p $out/lib/legacylauncher
    mkdir -p $out/jar
    cp -r extracted/usr/share/applications/* $out/share/applications/
    cp -r extracted/usr/share/icons/hicolor/128x128/apps/* $out/share/icons/hicolor/128x128/apps/
    cp -r extracted/usr/share/icons/hicolor/256x256/apps/* $out/share/icons/hicolor/256x256/apps/
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
    APP_DIR=$out/bin 
    BOOTSTRAP="$out/lib/legacylauncher/bootstrap.jar"
    [ ! -d "\$APP_DIR" ] && echo "Creating app directory" && mkdir -p "\$APP_DIR"
    cat <<EOF > $out/bin/legacylauncher
#!/usr/bin/env bash
set -euo pipefail
APP_DIR=$out/bin
BOOTSTRAP="$out/lib/legacylauncher/bootstrap.jar"
echo "Starting the launcher"
exec java -jar "\$BOOTSTRAP" "\$@"
EOF
    chmod +r+x $APP_DIR/legacylauncher
  '';

  meta = with pkgs.lib; {
    description = "Legacy Launcher is a simple and lightweight Minecraft launcher made by turikhay.";
    homepage = "https://llaun.ch";
    license = licenses.free;
    maintainers = with maintainers; [ turikhay rminstrel chatgpt ];
  };
}
