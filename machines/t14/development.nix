{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    devenv
    php84
  ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

}