#!/usr/bin/env bash
# Monitora o DNS (helios) e o certificado do GitHub Pages.
# Quando o IP antigo sumir e o certificado for emitido, ativa o Enforce HTTPS.

GH="/c/Program Files/GitHub CLI/gh.exe"
REPO="marcusvsfigueredo-cpu/marcos-rego-linktree"
BADIP="2.57.91.91"
NS="helios.dns-parking.com"

for i in $(seq 1 150); do
  dns=$(nslookup marcosrego.com.br "$NS" 2>/dev/null)
  if echo "$dns" | grep -q "$BADIP"; then
    echo "[$i] DNS ainda com $BADIP no $NS — aguardando propagacao..."
    sleep 120
    continue
  fi
  echo "[$i] DNS limpo no $NS. Checando certificado..."
  cert=$("$GH" api "repos/$REPO/pages" --jq '.https_certificate.state // "n/a"' 2>/dev/null)
  echo "[$i] cert_state = $cert"
  if [ "$cert" = "approved" ] || [ "$cert" = "issued" ]; then
    echo "[$i] Certificado pronto! Ativando Enforce HTTPS..."
    "$GH" api -X PUT "repos/$REPO/pages" -F https_enforced=true >/dev/null 2>&1
    sleep 5
    code=$(curl -s -o /dev/null -w "%{http_code}" https://marcosrego.com.br/ 2>/dev/null)
    echo "RESULTADO: HTTPS ativado. Teste https://marcosrego.com.br/ -> HTTP $code"
    exit 0
  fi
  echo "[$i] DNS ok, mas GitHub ainda emitindo o certificado. Aguardando..."
  sleep 120
done
echo "RESULTADO: tempo limite atingido. Rodar a verificacao manual de novo."
