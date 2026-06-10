#!/usr/bin/env bash
GH="/c/Program Files/GitHub CLI/gh.exe"
REPO="marcusvsfigueredo-cpu/marcos-rego-linktree"
for i in $(seq 1 40); do
  cert=$("$GH" api "repos/$REPO/pages" --jq '.https_certificate.state // "n/a"' 2>/dev/null)
  echo "[$i] cert_state = $cert"
  if [ "$cert" = "approved" ] || [ "$cert" = "issued" ]; then
    echo "Certificado pronto! Ativando Enforce HTTPS..."
    "$GH" api -X PUT "repos/$REPO/pages" -F https_enforced=true >/dev/null 2>&1
    sleep 6
    code=$(curl -s -o /dev/null -w "%{http_code}" https://marcosrego.com.br/ 2>/dev/null)
    echo "RESULTADO: HTTPS ATIVO. https://marcosrego.com.br/ -> HTTP $code"
    exit 0
  fi
  sleep 60
done
echo "RESULTADO: ainda emitindo apos ~40min. Rodar checagem manual."
