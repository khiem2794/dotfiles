{ pkgs, ... }:
{
  # mise: polyglot version manager for python, node, and 100+ tools
  # Docs: https://mise.jdx.dev/ | HM options: programs.mise.*
  #
  # HM renders globalConfig to $XDG_CONFIG_HOME/mise/config.toml as a READ-ONLY
  # nix store symlink. Consequence: `mise use --global ...` cannot write to it and
  # will fail. Change global tools by editing this file and rebuilding.
  # Per-project `mise.toml` / `.mise.toml` in a repo stays fully mutable.
  programs.mise = {
    enable = true;
    enableBashIntegration = true;

    globalConfig = {
      tools = {
        # "lts" floats to whatever is current LTS at install time; pin ("22")
        # if you want the version reproducible across machines.
        node = "lts";
        python = "3.12";
      };

      settings = {
        # Idiomatic version files are opt-in per tool, and off by default.
        # node   -> .nvmrc, .node-version
        # python -> .python-version
        # (.tool-versions and mise.toml are always honoured, regardless.)
        idiomatic_version_file_enable_tools = [ "node" "python" ];
      };
    };
  };

  # Fast python package/venv manager; complements mise's python *version*
  # management. Per project: `uv venv && uv pip install ...`
  home.packages = with pkgs; [
    uv
  ];
}
