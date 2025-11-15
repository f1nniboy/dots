{
  inputs,
  pkgs,
  stdenv,
  ...
}:
pkgs.mkShell {
  shellHook = ''
    echo "🐍 dev shell - dots"
    export PS1='\n\[\033[1;34m\][\w]\$\[\033[0m\] '
  '';

  buildInputs = [
    inputs.colmena.defaultPackage.${stdenv.hostPlatform.system}
    pkgs.just
  ];
}
