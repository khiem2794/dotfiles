{ lib, host, ... }: {
    programs.lazygit = {
        enable = true;
        settings = {
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
        };
    };
}