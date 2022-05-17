docker run -d -p 5000:5000 --restart=always --name registry registry:2

docker pull ubuntu:16.04

docker tag ubuntu:16.04 k8smaster.home:5000/myubuntu

docker push k8smaster.home:5000/myubuntu

docker image remove ubuntu:16.04

docker image remove k8smaster.home:5000/myubuntu

curl -X GET http://k8smaster.home:5000/v2/_catalog

docker pull k8smaster.home:5000/myubuntu
