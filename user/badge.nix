rec {
  handle = "spitfire";
  realname = "Cody Hannafon";
  email = handle + "@stargem.xyz";
  keyid = "9DF8448A4ACC64949E67F100A11DD3537BBB8CD9";
  pubkey = builtins.fetchurl {
    url = "https://keys.openpgp.org/vks/v1/by-fingerprint/${keyid}";
    sha256 = "bjsiCzZiLWlOD1JCdLsQTYL9vFQ1no1BOKfdeDzO+CU=";
  };
}