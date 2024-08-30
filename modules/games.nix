{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    xonotic
    superTux
    superTuxKart
    mars
  ];
}