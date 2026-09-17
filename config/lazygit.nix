{ lib, host, ... }: {
    programs.lazygit = {
        enable = true;
        settings = {
            promptToReturnFromSubprocess = false;
            git = {
                pagers = [
                    {
                        colorArg = "always";
                        pager = "delta --line-numbers --paging=never";
                    }
                ];
                log = {
                    showWholeGraph = true;
                };
                localBranchSortOrder = "alphabetical";
                remoteBranchSortOrder = "alphabetical";
            };
            customCommands = [
                {
                    key = "x";
                    command = "tig --all";
                    context = "global";
                    output = "terminal";
                }
            ];
        };
    };
}
