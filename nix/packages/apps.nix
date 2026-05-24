# Applications: terminal, launcher, control panels
{ pkgs }:

with pkgs; [
  # Terminal
  ghostty
  tmux

  # Launcher
  fuzzel

  # Control panels
  networkmanagerapplet
  blueman
  pavucontrol
  easyeffects
  gradia

  # Icons
  kdePackages.breeze-icons
  hicolor-icon-theme
]
