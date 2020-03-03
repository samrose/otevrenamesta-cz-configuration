{ config, pkgs, ... }:

let
  riotConfig = {
    default_server_config = {
      "m.homeserver" = {
        base_url = "https://matrix.vesp.cz";
        server_name = "vesp.cz";
      };
    };
    # don't allow choosing custom homeserver
    disable_custom_urls = true;
  };
  riotPkg = pkgs.callPackages ../packages/riot-web.nix { conf = riotConfig; };
in
{
  nixpkgs.overlays = [
    # https://github.com/matrix-org/synapse/issues/6211
    # https://twistedmatrix.com/trac/ticket/9740
    # https://github.com/twisted/twisted/pull/1225
    (self: super: {
      python3 = super.python3.override {
        packageOverrides = python-self: python-super: {
          twisted = python-super.twisted.overrideAttrs (attrs: {
            name = "patched-Twisted-18.9.0";
            # package overrides patchPhase, adding patch to `patches` does nothing
            patchPhase = attrs.patchPhase + ''
              patch -p1 < ${../packages/twisted-smtp-tlsv10.patch}
            '';
          });
        };
      };
    })
  ];

  environment.systemPackages = with pkgs; [
  ];

  networking = {
     hostName = "matrix";
     domain = "vesp.cz";
  };

  users.extraUsers.root.openssh.authorizedKeys.keys =
    with import ../ssh-keys.nix; [ rh ];

  services.postgresql.enable = true;

  services.matrix-synapse = {
    enable = true;
    no_tls = true;
    server_name = "vesp.cz";
    registration_shared_secret = with import ../secrets/matrix.nix; registration-secret;
    public_baseurl = "https://matrix.vesp.cz/";
    database_type = "psycopg2";
    database_args = {
      database = "matrix-synapse";
    };
    listeners = [
      { # federation
        bind_address = "";
        port = 8448;
        resources = [
          { compress = true; names = [ "client" "webclient" ]; }
          { compress = false; names = [ "federation" ]; }
        ];
        tls = false;
        type = "http";
        x_forwarded = true;
      }
    ];
    extraConfig = ''
      max_upload_size: "100M"

      email:
        smtp_host: mx.otevrenamesta.cz
        smtp_port: 25
        require_transport_security: true
        notif_from: "Matrix <info@otevrenamesta.cz>"
    '';

    enable_registration = true;
#    enable_registration_captcha = true;
#    recaptcha_public_key = ./matrix/recaptcha.pub;
#    recaptcha_private_key = ./matrix/recaptcha;
  };

  services.nginx = {
    enable = true;
    virtualHosts."riot.vesp.cz".root = riotPkg;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      8448  # Matrix federation and client connections
      80    # nginx+riot
    ];
  };
}
