# Stellar Helm Charts

Helm charts for Stellar applications (Core, Horizon, Friendbot, ...)

## Stellar Core

```
helm repo update
helm dependency update stellar-core
helm install \
  --namespace stellar-core-testnet \
  --name stellar-core \
  --values stellar-core.testnet.values.yaml \
  stellar-core
```
