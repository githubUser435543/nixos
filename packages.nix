{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    _7zz
    audit
    autoconf
    automake
    awscli2
    binutils
    binwalk
    bison
    btop
    burpsuite
    caido-desktop
    codex
    crosspipe
    debugedit
    discord
    dmidecode
    docker-compose
    efivar
    esptool
    exiftool
    fakeroot
    fastfetch
    feh
    feroxbuster
    ffuf
    file
    flameshot
    flatpak
    flex
    fzf
    gcc
    gdb
    gettext
    gh
    (symlinkJoin {
      name = "ghidra-dark";
      paths = [ ghidra ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/ghidra" \
          --prefix JAVA_TOOL_OPTIONS ' ' '-DTheme=Class:generic.theme.builtin.FlatDarkTheme'
      '';
    })
    gnumake
    gvisor
    hashcat
    hollywood
    httptoolkit
    httpx
    i3status
    inetutils
    jdk17
    jq
    libreoffice-fresh
    librewolf
    libtool
    libxml2_13
    lshw
    ltrace
    m4
    man-db
    man-pages
    metasploit
    minisign
    mpop
    neovim
    netbird
    netcat-openbsd
    netexec
    nfs-utils
    nikto
    nmap
    nodejs
    nuclei
    obsidian
    kdePackages.okular
    opencode
    openconnect
    openobserve
    openssh
    openvpn
    osquery
    patch
    pavucontrol
    perlPackages.XMLWriter
    pkg-config
    putty
    pypy27
    pypy311
    qbe
    ranger
    rclone
    remmina
    ripgrep
    rlwrap
    rnote
    sl
    slurp
    sqlmap
    sshpass
    strace
    tcpdump
    texliveBasic
    thc-hydra
    tmux
    glibc.static
    (ungoogled-chromium.override {
      commandLineArgs = "--force-dark-mode --extension-mime-request-handling=always-prompt-for-install";
    })
    unzip
    upx
    valgrind
    vim
    wget
    which
    whois
    wiremix
    wl-clipboard
    wpscan
    zathura
    (python3.withPackages (ps: with ps; [ pwntools pyx scapy ]))
  ];
}
