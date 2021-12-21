#!/bin/bash


#    https://www.linuxtechi.com/setup-private-docker-registry-kubernetes/
#   
#
#
#
#
#

 sudo mkdir /opt/certs /opt/registry
 cd /opt
 sudo openssl req -newkey rsa:4096 -nodes -sha256 -keyout \
 ./certs/registry.key -x509 -days 365 -out ./certs/registry.crt

 echo "EOT
apiVersion: apps/v1
kind: Deployment
metadata:
  name: private-repository-k8s
  labels:
    app: private-repository-k8s
spec:
  replicas: 1
  selector:
    matchLabels:
      app: private-repository-k8s
  template:
    metadata:
      labels:
        app: private-repository-k8s
    spec:
      volumes:
      - name: certs-vol
        hostPath:
          path: /opt/certs
          type: Directory
      - name: registry-vol
        hostPath:
          path: /opt/registry
          type: Directory

      containers:
        - image: registry:2
          name: private-repository-k8s
          imagePullPolicy: IfNotPresent
          env:
          - name: REGISTRY_HTTP_TLS_CERTIFICATE
            value: "/certs/registry.crt"
          - name: REGISTRY_HTTP_TLS_KEY
            value: "/certs/registry.key"
          ports:
            - containerPort: 5000
          volumeMounts:
          - name: certs-vol
            mountPath: /certs
          - name: registry-vol
            mountPath: /var/lib/registry
EOT" >> private-registry.yaml
sudo kubectl create -f private-registry.yaml


 
apiVersion: v1
kind: Service
metadata:
  labels:
    app: private-repository-k8s
  name: private-repository-k8s
spec:
  ports:
  - port: 5000
    nodePort: 31320
    protocol: TCP
    targetPort: 5000
  selector:
    app: private-repository-k8s
  type: NodePort