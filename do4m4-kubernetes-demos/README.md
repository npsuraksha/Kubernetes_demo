# do4m4-kubernetes-demos

These files support a walkthrough of the main features of Kubernetes.

## Setup
* Starting minikube

## Main objects and controllers
* Create a deployment from an image
* View info about deployments and pods
* Access via pod IP and port
* Scale deployment to use multiple pods

## Services
* Create a service with cluster IP for deployment
* Get service information
* Access service via cluster IP and mapped port

## Logging
* View logs of individual pod
* View combined logs from multiple pods using stern

## Rollouts
* Rollout a new version of an image
* View rollout history
* Undo last rollout

## Linking services together
* Deploy a service that consumes another service
* Simulate failure in dependency

## Using YAML (workload) files
* Define desired state using YAML file
* Apply YAML file
* Change desired state by editing YAML and re-applying

## Environment variables and secrets
* Defining in deployment state
* Triggering redeployment to see updated variables
* Setting up secrets
* Linking secrets to environment variables

## Using config maps for environment-specific customisations
* Config map for environment variables
* Config map for files mapped to read-only volumes
* Exploring inside a pod (files and environment variables)

## Health monitoring
* Configuring liveness probes
* Configuring readiness probes
* Configuring startup probes