    1  kubectl get nodes
    2  kubectl get pods --all-namespaces
    3  helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
    4  kubectl create namespace cattle-system
    5  touch cert-manager.sh
    6  vi cert-manager.sh
    7  chmod +x cert-manager.sh
    8  ./cert-manager.sh
    9  kubectl get pods --namespace cert-manager
   10  helm install rancher rancher-latest/rancher   --namespace cattle-system   --set hostname=rancher.my.org
   11  kubectl get pods --all-namespaces
   12  kubectl get svc
   13  kubectl get svc --all-namespaces
   14  kubectl edit svc rancher -n cattle-system
   15  cat vagrant-kubernetes/kubernetes-setup/files/apps/jenkins/jenkins-service.yaml
   16  kubectl get svc --all-namespaces
   17  kubectl edit svc rancher -n cattle-system
   18  kubectl get svc --all-namespaces
   19  kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}'
   20  history
