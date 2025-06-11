helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.9.0 -f values.yaml
kubectl apply -f ./storage_classes/3_replicas.yaml
kubectl apply -f ./storage_classes/strict_local.yaml
