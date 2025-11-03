{
  lib,
  cfg,
  config,
  ...
}:
with lib;
# TODO: fix horrible tab formatting
let
  mkYamlList =
    items:
    if items == [ ] then "[]" else builtins.concatStringsSep "\n" (map (i: "          - ${i}") items);

  mkYamlBoolean = item: if item then "true" else "false";

  mkSecret =
    id: key:
    ''{{ secret "${
      custom.mkSecretPath config "oidc/${id}/${key}" "authelia-main"
    }" | mindent 10 "|" | msquote }}'';

  mkClient = c: ''
          - client_name: ${c.name}
            client_id: ${mkSecret c.id "id"}
            client_secret: ${mkSecret c.id "secret-hash"}
            public: ${mkYamlBoolean c.public}
            authorization_policy: ${c.policy}
            require_pkce: ${mkYamlBoolean c.requirePkce}
            pkce_challenge_method: S256
            scopes:
    ${mkYamlList c.scopes}
            response_types:
    ${mkYamlList c.responseTypes}
            grant_types:
    ${mkYamlList c.grantTypes}
            access_token_signed_response_alg: ${c.accessTokenAlg}
            userinfo_signed_response_alg: ${c.userinfoAlg}
            token_endpoint_auth_method: ${c.tokenAuthMethod}
            redirect_uris:
    ${mkYamlList c.redirectUris}
  '';
in
''
  identity_providers:
    oidc:
      clients:
  ${(builtins.concatStringsSep "" (map mkClient cfg.clients))}
''
