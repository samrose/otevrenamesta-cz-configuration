{ pkgs, nodejs, stdenv, lib, ... }:

let

  packageName = with lib; concatStrings (map (entry: (concatStrings (mapAttrsToList (key: value: "${key}-${value}") entry))) (importJSON ./package.json));

  nodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
in
nodePackages."${packageName}".override {
  nativeBuildInputs = [ pkgs.makeWrapper ];

  postInstall = ''
    pushd $out/lib/node_modules/matrix-appservice-gitter
    patch -p1 < ${./schema-path.patch}
    popd

    makeWrapper '${nodejs}/bin/node' "$out/bin/matrix-appservice-gitter" \
    --add-flags "$out/lib/node_modules/matrix-appservice-gitter/index.js"
  '';

  meta = with lib; {
    description = "A Matrix <-> Gitter bridge";
    license = licenses.asl20;
  };
}
