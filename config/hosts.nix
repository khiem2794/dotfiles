let
  users = import ./users.nix;
in
{
  t14 = {
    hostname = "t14";
    dir = "t14";
    arch = "x86_64-linux";
    user = users.default;
  };

  work = {
    hostname = "work";
    dir = "work";
    arch = "x86_64-linux";
    user = users.work;
  };
}
