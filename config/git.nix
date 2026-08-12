{ lib, host, ... }: {
    programs.git = {
        enable = true;

        settings = {
            user = {
                name = host.git.name;
                email = host.git.email;
            };

            core = {
                pager = "delta";
            };

            interactive = {
                diffFilter = "delta --color-only";
            };

            delta = {
                navigate = true;
                line-numbers = true;
            };
        };
    };
}