let
  daniel = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCVm0eesBi2kL7W13AYcTTpG2TzokaayjTnXV+FRjBrI3gNkTU4dfz6rZOmjvgZ3BOKK6fqbqMRLa7T59TU1jrtO6HzayjF9AyX+c4aW+NQzTO+7amUe3lqsDppVxRM9v87UnUMmAr9Lnoghv/hxrRDqIrv/fRjaza8bZx2JFvaT+1IzZwvyYHtn6y0o3Icn9PMaNqOD85cAmKdKFg3TjkHcqylMoD4jrJA//EjhJPKdJky/1XyniWt6nY6ZE4ZIBnMJHPSPTuqTc0VnhEh3rsfC1peghm9O5/mt1J4vHv1n6rfYi8HrtxDLDB9hxzmkFmM9/iWDnjISowt34oxB7b8LU15vcyABNhc4nFHYqMasPVRh0cInxM43J9qmRB28wZdHyy6kN7PA0O4RvatKilBI/SlFgLRexxjfqt18VUgsltzwg/zxhjv0PVgU8R3AcaiLtXyWJovqiiSwwATn6ID0ypmvpLnIHRoNd+xyLNWDm3M0Ic0SHNHadxnywt7SlE=";
  root = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLyb0vZmGGswlyFaVibIbwqZXSF1xtod3/q+9yOmsFnIC0brehyh7dczTzp7P72Rpy2rZEMEmC721VdUkh28mYSVOReRArBxxhHOFlGCw0lfWNpFJAIf9koceMoxFvxvjLPTqxWIjLn0Xtp6tzuR4Qnp2P/uiclBNfpJ6NpNVjHaZkBNxO6RQE/m8y/2Nzq7u6sbV/AKPpme1FfbAnsgzmiXISI+j60vQMaR1XcOePlTIcs0kkDSfPKYKVNQtsajmSImbKokwt9BvFrLx2bJr1eTtlmulSx+Zg4KJZY+ab/q/Zu3bygsyDQCTtTseAvtkefx0HgVf31HvaYQ8NGijclsNhNXPCenetcT04eJynxnTaXIeV9lowyzHDuGnUWYsdjC2SrtOYgYdg/IdsXfh883P7O2Gl8iuZUFHsqHGPgrMhXXQXoDPN620vToOnpazj55s5YvvGO9ertWPE5x4+CjXAEv0FfTynRYxAvaf6b6PjQBXWk+iO0rityuWum4M=";
  users = [ daniel root ];

  xps13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGVm1pvxL0lXyvGrGFR+OoSYtEuFbkmg1rrTfU9eyWpc";
  systems = [ xps13 ];
in
{
  "daniel-fullname.age".publicKeys = [ root xps13 ];
  "daniel-password.age".publicKeys = [ root xps13 ];
  "root-password.age".publicKeys = [ root xps13 ];
}
