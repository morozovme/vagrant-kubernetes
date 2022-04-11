helm repo add stable https://charts.helm.sh/stable
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install stable prometheus-community/kube-prometheus-stack

#kubectl edit svc stable-kube-prometheus-sta-prometheus
kubectl patch svc stable-kube-prometheus-sta-prometheus -p '{"spec": {"type": "LoadBalancer"}}'
#kubectl edit svc stable-grafana
kubectl patch svc stable-grafana -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc -A
