{ pkgs, ... }:
{
  programs.mise = {
    enable = true;
    enableBashIntegration = true;

    globalConfig = {
      tools = {
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
}
