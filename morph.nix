let
  # Pin the deployment package-set to a specific version of nixpkgs
  # update with nix-prefetch-url --unpack <URL>
  # tracks nixos-19.09 branch
  pkgs1909 = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/2f9bafaca90acd010cccd0e79e5f27aa7537957e.tar.gz";
    sha256 = "1mm7dqd2n775sazhjrdc2p9hjrgh5q4jqgj0f4m9h18pkp0i2wim";
  };

  pkgs2003 = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/70717a337f7ae4e486ba71a500367cad697e5f09.tar.gz";
    sha256 = "1sbmqn7yc5iilqnvy9nvhsa9bx6spfq1kndvvis9031723iyymd1";
  };

  # for VZ nodes
  legacyPkgs = builtins.fetchTarball {
    url    = "https://d3g5gsiof5omrk.cloudfront.net/nixos/17.09/nixos-17.09.3243.bca2ee28db4/nixexprs.tar.xz";
    sha256 = "1adi0m8x5wckginbrq0rm036wgd9n1j1ap0zi2ph4kll907j76i2";
  };

  buildVpsFreeTemplates = builtins.fetchTarball {
    url = "https://github.com/vpsfreecz/build-vpsfree-templates/archive/f5829847c8ee1666481eb8a64df61f3018635ec7.tar.gz";
    sha256 = "1r8b3wyn4ggw1skdalib6i4c4i0cwmbr828qm4msx7c0j76910z4";
  };

in
{
  network =  {
    pkgs = import pkgs1909 { };
    description = "om hosts";
  };

  mesta-libvirt = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/ct.nix
      ./machines/mesta-libvirt.nix
    ];
  };

  # qemu guest port 10222 (consul na services)
  consul = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/qemu.nix
      ./machines/consul.nix
    ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/292f707d-271c-4864-9e44-9d5c3d3b4243";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/c7affbc7-a187-4e3d-ad8d-7a603bd15a4d";
        fsType = "ext4";
      };
  };

  # qemu guest port 10422 (GLPI)
  glpi = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/qemu.nix
      ./machines/glpi.nix
    ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/11e70a61-7abc-478d-a436-4d601c8b1502";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/9c3b7793-d880-41d1-8438-f15323fe9400";
        fsType = "ext4";
      };
  };

  mesta-services = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/ct.nix
      ./machines/mesta-services.nix
    ];
  };

  # qemu guest port 10022 (mail)
  mail = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/qemu.nix
      ./machines/mail.nix
    ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/50884094-57df-49fe-984a-5e25c1f629ac";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/c4cb4b0c-2009-4c22-8ab4-9c9cfc061b59";
        fsType = "ext4";
      };
  };

  # qemu guest port 10322 (roundcube na services)
  roundcube = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/qemu.nix
      ./machines/roundcube.nix
    ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/26380b05-91d2-4521-816c-b6e3c226e127";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/0d79a0bc-a9bf-4c62-872e-fc68132263e1";
        fsType = "ext4";
      };
  };


  # qemu guest port 10122 (sympa)
  sympa = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/qemu.nix
      ./machines/sympa.nix
    ];

    deployment = {
      nixPath = [
        { prefix = "nixpkgs"; path = pkgs2003; }
      ];
    };

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/3558270a-9c25-492b-bf4b-dcd2db2c5cfa";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/d4eb070a-10ee-42f3-bd59-69d7d891965a";
        fsType = "ext4";
      };
  };

  # qemu guest port 10222 (midpoint)
  midpoint = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/qemu.nix
      ./machines/midpoint.nix
    ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/86171d08-b62d-4c99-b1d6-ea075e8183d0";
         fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/a821424a-1ffd-4c08-acf9-74078ee1eeff";
        fsType = "ext4";
      };
  };

  # qemu guest port 10322 (matomo)
  matomo = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/qemu.nix
      ./machines/matomo.nix
    ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/7274ccea-6b6f-4dde-96cf-822ab916a20a";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/b576410e-733d-46ed-b705-c07b801bac5a";
        fsType = "ext4";
      };
  };

  # qemu guest port 10722 (nia na services)
  nia = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/qemu.nix
      ./machines/nia.nix
    ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/0b49a00a-9583-40de-99d5-bb7b3d34a00c";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/67c449cc-3b5f-4d06-b7d4-1525fd3fcbc2";
        fsType = "ext4";
      };
  };

  # qemu guest port 10822 (ucto na services)
  ucto = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/qemu.nix
      ./machines/ucto.nix
    ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/586ee5e6-778f-4a0e-978d-639ac1a9f605";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/8bd49f91-0b35-4574-9f9d-cf2ce0d9efe4";
        fsType = "ext4";
      };
  };

  # qemu guest port 10922 (matrix na services)
  matrix = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/qemu.nix
      ./machines/matrix.nix
    ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/9bdeed3f-a0de-4438-be71-357742e9a08b";
        fsType = "ext4";
      };
  
    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/55759f28-3493-49be-be9a-4fe6847b2406";
        fsType = "ext4";
      };
  };


  # qemu guest port 10522 (wp)
  wp = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/qemu.nix
      ./machines/wp.nix
    ];

    deployment = {
      nixPath = [
        { prefix = "nixpkgs"; path = pkgs2003; }
      ];
    };

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/2e1eef19-5376-4c21-a6d2-a543b22cb079";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/1b2e41d9-9034-47a6-80eb-21f16215af54";
        fsType = "ext4";
      };
  };

  mediawiki = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/qemu.nix
      ./machines/mediawiki.nix
    ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/7364444d-c58e-4f5b-b1b7-d5300558bbe7";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/006a7bc5-5b45-470c-943f-77eee9a24c2e";
        fsType = "ext4";
      };
  };

  old-proxy = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./machines/proxy.nix
      "${buildVpsFreeTemplates}/files/configuration.nix"
    ];

    deployment = {
      nixPath = [
        { prefix = "nixpkgs"; path = legacyPkgs; }
      ];

      healthChecks = {
        http = [
          {
            scheme = "http";
            port = 80;
            host = "otevrenamesta.cz";
            path = "/";
            description = "Nginx is up";
          }
          {
            scheme = "https";
            port = 443;
            host = "otevrenamesta.cz";
            path = "/";
            description = "Web is up";
          }
          {
            scheme = "https";
            port = 443;
            host = "www.otevrenamesta.cz";
            path = "/";
            description = "WWW is up";
          }
          {
            scheme = "https";
            port = 443;
            host = "forum.otevrenamesta.cz";
            path = "/latest";
            description = "Forum is up";
          }
          {
            scheme = "https";
            port = 443;
            host = "iot.otevrenamesta.cz";
            path = "/about";
            description = "IoT is up";
          }
        ];
      };
    };
  };

  new-proxy = { config, pkgs, ... }: {
    imports = [
      ./env.nix
      ./profiles/qemu.nix
      ./machines/proxy.nix
    ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/3bc8b6e8-56e1-40c4-b0de-8eba32313610";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/00552ecd-9bf6-4111-9339-d9180e2023e1";
        fsType = "ext4";
      };

    deployment = {
      healthChecks = {
        http = [
          {
            scheme = "http";
            port = 80;
            host = "otevrenamesta.cz";
            path = "/";
            description = "Nginx is up";
          }
          {
            scheme = "https";
            port = 443;
            host = "otevrenamesta.cz";
            path = "/";
            description = "Web is up";
          }
          {
            scheme = "https";
            port = 443;
            host = "www.otevrenamesta.cz";
            path = "/";
            description = "WWW is up";
          }
          {
            scheme = "https";
            port = 443;
            host = "forum.otevrenamesta.cz";
            path = "/latest";
            description = "Forum is up";
          }
          {
            scheme = "https";
            port = 443;
            host = "iot.otevrenamesta.cz";
            path = "/about";
            description = "IoT is up";
          }
        ];
      };
    };
  };
}
