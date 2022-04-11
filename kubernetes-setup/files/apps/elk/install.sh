helm repo add elastic https://Helm.elastic.co
helm install --generate-name  elastic/elasticsearch -f ./values.yam
