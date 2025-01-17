# Envvars
locals {
  armonik_conf = <<EOF
map $http_accept_language $accept_language {
    ~*^en en;
    ~*^fr fr;
}

map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

%{if var.ingress != null ? var.ingress.mtls : false~}
    map $ssl_client_s_dn $ssl_client_s_dn_cn {
        default "";
        ~CN=(?<CN>[^,/]+) $CN;
    }
%{endif~}
server {
%{if var.ingress != null ? var.ingress.tls : false~}
    listen 8443 ssl http2;
    listen [::]:8443 ssl http2;
    listen 9443 ssl http2;
    listen [::]:9443 ssl http2;
    ssl_certificate     /ingress/ingress.crt;
    ssl_certificate_key /ingress/ingress.key;
%{if var.ingress.mtls~}
    ssl_verify_client on;
    ssl_client_certificate /ingressclient/ca.pem;
%{else~}
    ssl_verify_client off;
    proxy_hide_header X-Certificate-Client-CN;
    proxy_hide_header X-Certificate-Client-Fingerprint;
%{endif~}
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers EECDH+AESGCM:EECDH+AES256;
    ssl_conf_command Ciphersuites TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256;
%{else~}
    listen 8080;
    listen [::]:8080;
    listen 9080 http2;
    listen [::]:9080 http2;
%{endif~}

    sendfile on;
    resolver kube-dns.kube-system ipv6=off;

    if ($accept_language ~ "^$") {
        set $accept_language "en";
    }

    location = / {
        rewrite ^ $scheme://$http_host/admin/$accept_language/;
    }
    location = /admin {
        rewrite ^ $scheme://$http_host/admin/$accept_language/;
    }
    location = /admin/ {
        rewrite ^ $scheme://$http_host/admin/$accept_language/;
    }
    location = /admin/en {
        rewrite ^ $scheme://$http_host/admin/en/;
    }
    location = /admin/fr {
        rewrite ^ $scheme://$http_host/admin/fr/;
    }
    # Deprecated, must be removed in a new version. Keeped for retrocompatibility
    location = /old-admin {
        rewrite ^ $scheme://$http_host/admin-0.8/ permanent;
    }
    # Deprecated, must be removed in a new version
    location = /admin-0.8 {
        rewrite ^ $scheme://$http_host/admin-0.8/ permanent;
    }
    # Deprecated, must be removed in a new version
    location = /admin-0.9 {
        rewrite ^ $scheme://$http_host/admin-0.9/$accept_language/;
    }
    # Deprecated, must be removed in a new version
    location = /admin-0.9/ {
        rewrite ^ $scheme://$http_host/admin-0.9/$accept_language/;
    }
    # Deprecated, must be removed in a new version
    location = /admin-0.9/en {
        rewrite ^ $scheme://$http_host/admin-0.9/en/;
    }
    # Deprecated, must be removed in a new version
    location = /admin-0.9/fr {
        rewrite ^ $scheme://$http_host/admin-0.9/fr/;
    }
%{if var.admin_gui != null~}
    set $admin_app_upstream ${local.admin_app_url};
    set $admin_0_8_upstream ${local.admin_0_8_url};
    set $admin_0_9_upstream ${local.admin_0_9_url};
    set $admin_api_upstream ${local.admin_api_url};
    location /admin/ {
        proxy_pass $admin_app_upstream$uri$is_args$args;
    }
    # Deprecated, must be removed in a new version
    location /admin-0.8/ {
        proxy_pass $admin_0_8_upstream$uri$is_args$args;
    }
    # Deprecated, must be removed in a new version
    location /admin-0.9/ {
        proxy_pass $admin_0_9_upstream$uri$is_args$args;
    }
    # Deprecated, must be removed in a new version
    location /api {
        proxy_pass $admin_api_upstream$uri$is_args$args;
    }
%{endif~}

    set $armonik_upstream grpc://${local.control_plane_endpoints.ip}:${local.control_plane_endpoints.port};
    location ~* ^/armonik\. {
%{if var.ingress != null ? var.ingress.mtls : false~}
        grpc_set_header X-Certificate-Client-CN $ssl_client_s_dn_cn;
        grpc_set_header X-Certificate-Client-Fingerprint $ssl_client_fingerprint;
%{endif~}
        grpc_pass $armonik_upstream;

        # Apparently, multiple chunks in a grpc stream is counted has a single body
        # So disable the limit
        client_max_body_size 0;

        # add a timeout of 1 month to avoid grpc exception for long task
        # TODO: find better configuration
        proxy_read_timeout 30d;
        proxy_send_timeout 1d;
        grpc_read_timeout 30d;
        grpc_send_timeout 1d;
    }

    location /static/ {
        alias /static/;
    }


  proxy_buffering off;
  proxy_request_buffering off;

%{if data.kubernetes_secret.shared_storage.data.file_storage_type == "s3"~}
 set $minio_upstream ${data.kubernetes_secret.shared_storage.data.service_url};
 location / {
    client_max_body_size 0;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    proxy_connect_timeout 300;
    # Default is HTTP/1, keepalive is only enabled in HTTP/1.1
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    chunked_transfer_encoding off;

    proxy_pass $minio_upstream$uri$is_args$args; # This uses the upstream directive definition to load balance
 }

 set $minioconsole_upstream ${data.kubernetes_secret.shared_storage.data.console_url};
 location /minioconsole {
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-NginX-Proxy true;

    rewrite ^/minioconsole/(.*) /$1 break;
    sub_filter '<head>' '<head><base href="$${scheme}://$${http_host}/minioconsole/">';
    sub_filter_once on;

    # This is necessary to pass the correct IP to be hashed
    real_ip_header X-Real-IP;

    proxy_connect_timeout 300;

    # To support websockets in MinIO versions released after January 2023
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    chunked_transfer_encoding off;

    proxy_pass $minioconsole_upstream$uri$is_args$args; # This uses the upstream directive definition to load balance and assumes a static Console port of 9001
 }
 %{endif~}


%{if data.kubernetes_secret.seq.data.enabled~}
    set $seq_upstream ${data.kubernetes_secret.seq.data.web_url};
    location = /seq {
        rewrite ^ $scheme://$http_host/seq/ permanent;
    }
    location /seq/ {
%{if var.ingress != null ? var.ingress.mtls : false~}
        proxy_set_header X-Certificate-Client-CN $ssl_client_s_dn_cn;
        proxy_set_header X-Certificate-Client-Fingerprint $ssl_client_fingerprint;
%{endif~}
        proxy_set_header Host $http_host;
        proxy_set_header Accept-Encoding "";
        rewrite  ^/seq/(.*)  /$1 break;
        proxy_pass $seq_upstream$uri$is_args$args;
        sub_filter '<head>' '<head><base href="$${scheme}://$${http_host}/seq/">';
        sub_filter_once on;
        proxy_hide_header content-security-policy;
    }
%{endif~}
%{if data.kubernetes_secret.grafana.data.enabled != ""~}
    set $grafana_upstream ${data.kubernetes_secret.grafana.data.url};
    location = /grafana {
        rewrite ^ $scheme://$http_host/grafana/ permanent;
    }
    location /grafana/ {
        rewrite  ^/grafana/(.*)  /$1 break;
%{if var.ingress != null ? var.ingress.mtls : false~}
        proxy_set_header X-Certificate-Client-CN $ssl_client_s_dn_cn;
        proxy_set_header X-Certificate-Client-Fingerprint $ssl_client_fingerprint;
%{endif~}
        proxy_set_header Host $http_host;
        proxy_pass $grafana_upstream$uri$is_args$args;
        sub_filter '<head>' '<head><base href="$${scheme}://$${http_host}/grafana/">';
        sub_filter_once on;
        proxy_intercept_errors on;
        error_page 301 302 307 =302 $${scheme}://$${http_host}$${upstream_http_location};
    }
    location /grafana/api/live {
        rewrite  ^/grafana/(.*)  /$1 break;
%{if var.ingress != null ? var.ingress.mtls : false~}
        proxy_set_header X-Certificate-Client-CN $ssl_client_s_dn_cn;
        proxy_set_header X-Certificate-Client-Fingerprint $ssl_client_fingerprint;
%{endif~}
%{if var.ingress != null ? var.ingress.tls : false~}
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
%{endif~}
        proxy_http_version 1.1;
        proxy_set_header Host $http_host;
        proxy_pass $grafana_upstream$uri$is_args$args;
    }
%{endif~}
}
EOF
}

resource "kubernetes_config_map" "ingress" {
  count = (var.ingress != null ? 1 : 0)
  metadata {
    name      = "ingress-nginx"
    namespace = var.namespace
  }
  data = {
    "armonik.conf" = local.armonik_conf
  }
}

resource "kubernetes_config_map" "static" {
  count = (var.ingress != null ? 1 : 0)
  metadata {
    name      = "ingress-nginx-static"
    namespace = var.namespace
  }
  data = {
    "environment.json" = jsonencode(var.environment_description)
  }
}

resource "local_file" "ingress_conf_file" {
  count           = (var.ingress != null ? 1 : 0)
  content         = local.armonik_conf
  filename        = "${path.root}/generated/configmaps/ingress/armonik.conf"
  file_permission = "0644"
}
