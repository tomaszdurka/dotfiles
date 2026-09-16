{ config, pkgs, lib, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  # Edit-in-place symlinks: the real file stays in this repo, the path in
  # ~/ just points at it. Editing a linked file needs no rebuild.
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";

  # CLI tools come from Homebrew (see brew/brews.txt). Nix only provides
  # what brew does poorly: fonts.
  home.packages = with pkgs; [
    nerd-fonts.hack   # the font every terminal renders in
  ];
  fonts.fontconfig.enable = true;

  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    # Note: no autosuggestion.enable here. The history-based gray ghost text
    # guessed wrong too often; Ctrl+R (fzf) replaces it on demand.
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      # nvm (installed via brew) needs to be sourced to work
      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"

      # t: fuzzy-pick a project folder and jump to a tmux session for it,
      # creating the session if needed. Works inside and outside tmux.
      t() {
        local dir name
        dir=$(find ~/projects -mindepth 1 -maxdepth 2 -type d -not -name ".*" | fzf --reverse) || return
        name=$(basename "$dir" | tr "." "_")
        tmux new-session -ds "$name" -c "$dir" 2>/dev/null
        if [ -n "$TMUX" ]; then
          tmux switch-client -t "$name"
        else
          tmux attach -t "$name"
        fi
      }
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
    };
  };

  # Ctrl+R: fuzzy history search. Ctrl+T: fuzzy file picker. Alt+C: fuzzy cd.
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Terminal + editor configs, linked straight into this repo.
  home.file.".config/ghostty".source = link "home/.config/ghostty";
  home.file.".config/tmux/tmux.conf".source = link "home/.config/tmux/tmux.conf";
  home.file.".config/wezterm".source = link "home/.config/wezterm";
  home.file.".config/nvim".source = link "home/.config/nvim";
  home.file.".config/herdr/config.toml".source = link "home/.config/herdr/config.toml";

  # Agent configs: Claude, Codex, and opencode all share one AGENTS.md.
  home.file.".claude/CLAUDE.md".source = link "home/AGENTS.md";
  home.file.".codex/AGENTS.md".source = link "home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source = link "home/AGENTS.md";
  home.file.".claude/settings.json".source = link "home/.claude/settings.json";

  # Pi: link only authored files; credentials and runtime state stay local.
  home.file.".pi/agent/themes".source = link "home/.pi/agent/themes";
  home.file.".pi/agent/extensions".source = link "home/.pi/agent/extensions";
  home.file.".pi/agent/models.json".source = link "home/.pi/agent/models.json";
  home.file.".pi/agent/settings.json".source = link "home/.pi/agent/settings.json";

  # tmux plugins are managed by TPM. Clone it if missing, then install any
  # plugins declared in tmux.conf (idempotent, skips what's already there),
  # so no manual prefix+I is ever needed.
  # Must run after linkGeneration: install_plugins reads ~/.config/tmux/tmux.conf,
  # which only exists once home-manager has created the symlinks. TERM is set
  # because the activation environment has none and tmux refuses to start without it.
  home.activation.installTmuxPlugins = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    TPM_DIR="$HOME/.config/tmux/plugins/tpm"
    if [ ! -d "$TPM_DIR" ]; then
      ${pkgs.git}/bin/git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR" || \
        echo "warning: could not clone tpm (offline?); run 'git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm' later"
    fi
    if [ -d "$TPM_DIR" ]; then
      TERM=xterm-256color PATH="${pkgs.git}/bin:/opt/homebrew/bin:$PATH" \
        "$TPM_DIR/bin/install_plugins" >/dev/null || \
        echo "warning: tmux plugin install failed; run prefix+I inside tmux later"
    fi
  '';
}
