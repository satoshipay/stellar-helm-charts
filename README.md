# Stellar Helm Charts

Helm charts for Stellar applications (Core, Horizon, Friendbot, ...)

## Stellar Core

```
helm repo update
helm dependency update stellar-core
helm install \
  --namespace stellar-testnet \
  --name stellar-core \
  --values stellar-core.testnet.values.yaml \
  stellar-core
```

## Stellar Horizon

```
helm repo update
helm dependency update stellar-horizon
helm install \
  --namespace stellar-testnet \
  --name stellar-horizon \
  --values stellar-horizon.testnet.values.yaml \
  stellar-horizon
```
