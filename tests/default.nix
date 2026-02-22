{
  lib,
  drowse,
  pkgs,
}:

let
  inherit (pkgs)
    fetchFromGitHub
    git
    testers
    ;
in

lib.fix (self: {
  callPackage = drowse.callPackage {
    pname = "hello";
    version = "2.12.2";
    src = ./hello.nix;
  };
  callPackageVersion = testers.testVersion {
    package = self.callPackage;
  };

  callPackageArgs = drowse.callPackage {
    pname = "hello";
    version = "2.12.2";
    src = ./hello.nix;
    args.withGit = true;
  };
  callPackageArgsVersion = testers.testVersion {
    package = self.callPackageArgs;
    inherit (git) version;
  };

  callPackageArgsString = drowse.callPackage {
    pname = "hello";
    version = "2.12.2";
    src = ./hello.nix;
    args = /* nix */ ''
      { withGit = true; }
    '';
  };
  callPackageArgsStringVersion = testers.testVersion {
    package = self.callPackageArgsString;
    inherit (git) version;
  };

  crate2nix = drowse.crate2nix {
    pname = "hello-rs";
    version = "0.1.0";
    src = ./hello-rs;
    dynamicCargoDeps = false;
  };
  crate2nixVersion = testers.testVersion {
    package = self.crate2nix;
  };

  crate2nixArgs = drowse.crate2nix {
    pname = "hello-rs";
    version = "0.1.0";
    src = ./hello-rs;
    args.rootFeatures = [ "fancy" ];
  };
  crate2nixArgsVersion = testers.testVersion {
    package = self.crate2nixArgs;
    version = "9.9.9+fancy";
  };

  crate2nixArgsString = drowse.crate2nix {
    pname = "hello-rs";
    version = "0.1.0";
    src = ./hello-rs;
    args = /* nix */ ''
      { rootFeatures = [ "fancy" ]; }
    '';
  };
  crate2nixArgsStringVersion = testers.testVersion {
    package = self.crate2nixArgsString;
    version = "9.9.9+fancy";
  };

  crate2nixDynamic = drowse.crate2nix {
    pname = "hello-rs";
    version = "0.1.0";
    src = ./hello-rs;
    dynamicCargoDeps = true;
  };
  crate2nixDynamicVersion = testers.testVersion {
    package = self.crate2nixDynamic;
  };
  crate2nixDynamicEquivalent = testers.testEqualContents {
    assertion = "crate2nix and crate2nixDynamic are equivalent";
    expected = self.crate2nix;
    actual = self.crate2nixDynamic;
  };

  crate2nixSelect = drowse.crate2nix {
    pname = "hello-rs";
    version = "0.1.0";
    src = ./hello-rs;
    select = /* nix */ ''
      project:
      project.rootCrate.build.override {
        features = [ "fancy" ];
      }
    '';
  };
  crate2nixSelectVersion = testers.testVersion {
    package = self.crate2nixSelect;
    version = "9.9.9+fancy";
  };

  crate2nixRemote = drowse.crate2nix (finalAttrs: {
    pname = "nurl";
    version = "0.4.0";
    dynamicCargoDeps = true;
    src = fetchFromGitHub {
      owner = "nix-community";
      repo = "nurl";
      rev = "v${finalAttrs.version}";
      hash = "sha256-BxtvT2k4mErYPU9lNpZlat9ULI2wKXQToic7+PgkCSk=";
    };
  });
  crate2nixRemoteVersion = testers.testVersion {
    package = self.crate2nixRemote;
  };
})
