{
  inputs,
  pkgs,
  stdenv,
  ...
}:
pkgs.mkShell {
  shellHook = ''
    echo "🐚 dev shell for dots"
    export PS1='\n\[\033[1;34m\][\w]\$\[\033[0m\] '
  '';

  buildInputs = with pkgs; [
    inputs.colmena.defaultPackage.${stdenv.hostPlatform.system}
    just
    sops
  ];
}
