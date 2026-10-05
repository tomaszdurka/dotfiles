{ user, lib, ... }:

let
  # brews.txt / casks.txt are plain text files (one package per line) so that
  # sync.sh can edit them without having to parse Nix. Blank lines and
  # "#" comments are allowed.
  readPackageList = file:
    lib.filter (line: line != "" && !lib.hasPrefix "#" line)
      (map (lib.removeSuffix "\r") (lib.splitString "\n" (builtins.readFile file)));
in

{
  # Determinate Nix manages the Nix daemon, so nix-darwin must not.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;

  # macOS system settings. Applied on every rebuild; typo'd option names fail
  # the build instead of being silently ignored, which is why these live in
  # Nix instead of a `defaults write` script.
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat starts
      AppleShowAllExtensions = true;
      # Menu bar always visible - I want the clock on screen. Explicitly false
      # (not just omitted) because the old setup set it to true on this machine.
      _HIHideMenuBar = false;
    };
    # macOS 26 (Tahoe) renders the menu bar fully transparent by default, so
    # whatever is behind it bleeds through. This makes it solid again.
    universalaccess.reduceTransparency = true;
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # no icons on the desktop
    trackpad.Clicking = true;              # tap to click
    # Hide the input/emoji ("keyboard") icon from the menu bar.
    CustomUserPreferences."com.apple.TextInputMenu".visible = false;
    # BetterSnapTool: snap halves/quarters itself instead of handing them to
    # macOS native tiling, which animates and sizes windows to the full screen
    # height (ignoring the menu bar). Thirds always used this classic path.
    CustomUserPreferences."com.hegenberg.BetterSnapTool".BSTSequoiaUseClassicSnapping = true;
  };

  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    # ADDITIVE on purpose: a rebuild installs what is listed and never
    # uninstalls anything that isn't. Manually installed packages survive.
    # Run ./sync.sh to pull manual installs back into brew/brews.txt.
    onActivation.cleanup = "none";
    onActivation.autoUpdate = true;
    brews = readPackageList ./brew/brews.txt;
    casks = readPackageList ./brew/casks.txt;
    taps = [
      {
        name = "humanlayer/humanlayer";
        trusted = true;
      }
    ];
  };

  # If home-manager needs to replace an existing real file, keep a copy.
  home-manager.backupFileExtension = "backup";
}
