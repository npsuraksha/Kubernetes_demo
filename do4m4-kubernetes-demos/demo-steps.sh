# These are just ideas of things to try in Kubernetes
# - don't just run the whole script in one go!

# Start minikube, in a way suitable for accessing from internet
minikube start --vm-driver=none

# Build the hello-app and hello-consumer-app images
cd hello-app
npm install
npm run build-image
cd hello-consumer-app
npm install
npm run build-image
cd ..

# Start the hello application (version 1.0.0) as a deployment (single pod)
kubectl create deployment hello --image=hello:1.0.0

# Find out about the deployment
kubectl get deployments -o wide

# Find out about the pod(s)
kubectl get pods -o wide

# Find out extra detail about one specific thing
kubectl describe pod hello_xyzxyzxyz

# Find out about services
kubectl get services -o wide

# Access the pod via its IP address (within the cluster) -- MIGHT BE DIFFERENT!
curl http://172.17.0.3:8000

# Scale the application to run inside 3 x pods
kubectl scale deployment hello --replicas=3

# Review...
kubectl get deployments -o wide
kubectl get pods -o wide

# Access individual pods via cluster IP address
curl http://172.17.0.3:8000
curl http://172.17.0.4:8000
curl http://172.17.0.5:8000

# Expose the application pods as single service, with one IP address (cluster-IP)
kubectl expose deployment hello --name=hello-service --port=80 --target-port=8000

# Review...
kubectl get pods -o wide
kubectl get services

# Easy way to set up a provide an alias for the cluster IP address
export HELLO_SERVICE=$(kubectl get service hello-service -o jsonpath={.spec.clusterIP})

# Access hello service using its cluster IP
curl http://${HELLO_SERVICE}

# See what happens when one of the pods dies (process restarts)
curl http://${HELLO_SERVICE}/crash
kubectl get pods

# Look at the logs from the hello service (picks one pod)
kubectl logs deployment/hello

# Use STERN to combine logs from all pods in service
stern hello

# Rebuild an image for hello:1.0.1 (by editing the package.json
# file to change 'version' value, then doing npm run build-image)
# Redeploy the newer version of the hello image (1.0.1)
kubectl set image deployment/hello hello=hello:1.0.1

# Check versions of image used for deployment
kubectl get deployments -o wide

# Access hello service using its cluster IP
curl http://${HELLO_SERVICE}

# View the rollout history
kubectl rollout history deployment/hello

# View the rollout history, for specific revision
kubectl rollout history deployment/hello --revision=2

# Roll back to earlier deployment
kubectl rollout undo deployment/hello

# Access hello service using its cluster IP
curl http://${HELLO_SERVICE}

# Deploy the consumer web service (it calls the hello service using http://hello-service - see code)
kubectl create deployment hello-consumer --image=hello-consumer:1.0.0

# Create a cluster IP for the hello-consumer service
kubectl expose deployment hello-consumer --name=hello-consumer-service --port=80 --target-port=8000

# Access the consumer service (via cluster IP)
kubectl get services
export HELLO_CONSUMER_SERVICE=$(kubectl get service hello-consumer-service -o jsonpath={.spec.clusterIP})

curl http://${HELLO_CONSUMER_SERVICE}

# Simulate the consumer being unable to call the hello service
kubectl scale deployment hello --replicas=0
# Should see reply from consumer saying couldn't contact hello service
curl http://${HELLO_CONSUMER_SERVICE}

# Make it work again
kubectl scale deployment hello --replicas=3

# Expose hello-consumer app through a (simulated) load balancer
kubectl expose deployment hello-consumer --name=hello-consumer-lb --type=LoadBalancer --port=80 --target-port=8000

# Review...
kubectl get services

# Access the consumer service (via load balancer within cluster)
export HELLO_CONSUMER_LB=$(kubectl get service hello-consumer-lb -o jsonpath={.spec.clusterIP})
curl http://${HELLO_CONSUMER_LB}

# Access consumer service (via port exposed to internet)
# NB: Need to find out random port allocated, and open that port in AWS EC2 security group
# Then access via EC2 public IP + this random port number
curl http://localhost:PPPPP

# ---------------------------------
# Using YAML files
# ---------------------------------

# Create demo1.yaml file to spin up 1 x replica of hello service
kubectl apply -f demo1.yaml
kubectl get pods
kubectl get deployments

# Delete everything mentioned in config file
kubectl delete -f demo1.yaml

# Require 3 x replicas
kubectl apply -f demo1.yaml
kubectl get pods

# Require a service for the hello deployment
kubectl apply -f demo1.yaml
kubectl get services

# hello-consumer deployment + service + load balancer
kubectl apply -f demo1.yaml
kubectl get services -o wide

# Access environment variables (without being set first)
curl ${HELLO_SERVICE}/info

# Set the environment variables for hello service
curl ${HELLO_SERVICE}/info

# Create a store for our secrets
kubectl create secret generic doomsday --from-literal=launch-code=WXYZ-BOOM

# Change config to use secret (see notes)
# ...

# See the secret being used
curl ${HELLO_SERVICE}/info

# Change the secret (delete it and re-add)
kubectl delete secret doomsday
kubectl create secret generic doomsday --from-literal=launch-code=AAAA-BBBB

# Restart all pods in service, so see updated secret
kubectl rollout restart deployment hello

# See the updated secret being used
curl ${HELLO_SERVICE}/info

# Add config map files for development verses production
# for "message" setting, and feed it via environment variable MESSAGE
# Remember to also change the hello deployment definition to map setting to env
kubectl apply -f settings.dev.yaml
curl ${HELLO_SERVICE}/message
kubectl apply -f settings.dev.yaml
kubectl rollout restart deployment hello
curl ${HELLO_SERVICE}/message

# Add a file to the config map ("message-file") mapped to volume /app/data
# Incorporate the volume /app/data into the hello deployment
curl ${HELLO_SERVICE}/message2

# Have a look inside a hello pod, to see the volume, files and environment variables
kubectl exec deployment hello -it -- sh
ls /app/data
cat /app/data/message.txt
echo "Extra line" >> /app/data/message.txt
env | sort

# Configure a liveness probe for the hello service (/live)
# Make one of the pods returm 503 errors
# Look at pod status / restarts
# Look at the pod events
curl http://${HELLO_SERVICE}/stall
kubectl get pods
kubectl describe pod hello_xyzxyzxyz

# Configure a readiness probe for the hello service (/ready)
# Make one of the pods become not ready (but still live) for a period
# Look at pod status / restarts
# Look at the pod events
curl http://${HELLO_SERVICE}/busy/60
kubectl get pods
kubectl describe pod hello_xyzxyzxyz

# Demonstrate problem can have if rapid liveness checks
# But longer startup time (but which may be quick sometimes)
# Use environment variable START_TIME to simulate long startup
# Pod gets restarted before it finished loading
# Use startup probe to get round this (/ready)
# Look at pod status / restarts
# Look at the pod events
kubectl get pods
kubectl describe pod hello_xyzxyzxyz

# Get rid of entire minikube cluster
minikube delete