{ config, pkgs, lib, ...}:
let
  bigFileNginx = ''
    client_body_in_file_only clean;
    client_body_buffer_size 32K;

    # set max upload size
    client_max_body_size 2G;

    sendfile on;
    send_timeout 3600s;
  '';
  dnsTimeServers = [ "10.0.99.8" "10.0.99.24 " ];

in

{
  services.ckan = {
    listenPort = 9000;
    listenAddress = "127.0.0.1";
  };

  boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "floppy" "sd_mod" "sr_mod" ];

  users.extraUsers.root.hashedPassword = "$6$jcrgonWA$AREhvoz2Wq4kHidp32rESWVbJhHqVVBmiCCLUwnmA78N4Fwjy3LX9PZDw1WKtXhSrbA3BggQr1i7Df9FveYIz0";


  services.openssh.enable = true;
  services.openssh.challengeResponseAuthentication = true; #opet default
  services.openssh.passwordAuthentication = true; #default je true tj. melo by byt zbytecne
  #services.openssh.permitRootLogin = "without-password";
  services.openssh.permitRootLogin = "yes";
  services.openssh.ports = [ 22 ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.extraCommands = ''
    iptables -A INPUT -s 10.0.77.77 -j ACCEPT
    '';

  networking.nameservers = dnsTimeServers;
  networking.timeServers = dnsTimeServers;

  networking.enableIPv6 = false;

  services.nginx = {
    enable = true;

    recommendedProxySettings = true;

    virtualHosts = {
      "default" = {
        default = true;

        #onlySSL = true;
        addSSL = true;
        sslCertificate = "/root/certs/domain.crt";
        sslCertificateKey = "/root/certs/domain.key";

        locations = {
          "/" = {
            proxyPass = "http://localhost:9000";
            extraConfig = ''
              ${bigFileNginx}
            '';
          };
        };
      };
    };
  };

  systemd.services.gpcagent =
    { description = "GPCAgent monintoring";
      path = [ pkgs.jdk ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.jdk}/bin/java -jar /root/mon/GPCAgent.jar";
      };
    };
}
