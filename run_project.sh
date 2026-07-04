#!/bin/bash

# Exit on error
set -e

echo "=== Starting Guestbook Deployment and Validation ==="

# 1. Export Namespace
if [ -z "$MY_NAMESPACE" ]; then
  USERNAME=$(ibmcloud cr namespaces | grep -v "Listing namespaces" | grep -v "OK" | xargs)
  export MY_NAMESPACE=$USERNAME
fi
echo "Using namespace: $MY_NAMESPACE"

# 2. Build and push initial image
echo "Building and pushing docker image..."
docker build . -t us.icr.io/$MY_NAMESPACE/guestbook:v1
docker push us.icr.io/$MY_NAMESPACE/guestbook:v1

# 3. Apply deployment
echo "Applying initial deployment..."
# Temporarily set CPU to 50m and 20m for revision 1
sed -i 's/cpu: 5m/cpu: 50m/g' v1/guestbook/deployment.yml
sed -i 's/cpu: 2m/cpu: 20m/g' v1/guestbook/deployment.yml
sed -i "s|image: us.icr.io/.*|image: us.icr.io/$MY_NAMESPACE/guestbook:v1|g" v1/guestbook/deployment.yml
kubectl apply -f v1/guestbook/deployment.yml

# Save index.html as app
cp v1/guestbook/public/index.html app

# 4. Configure HPA
echo "Configuring HPA..."
kubectl autoscale deployment guestbook --cpu-percent=5 --min=1 --max=10 || true

# Wait for HPA to initialize
echo "Waiting for HPA initialization..."
sleep 15
kubectl get hpa guestbook > hpa

# 5. Generate Load
echo "Generating load in background..."
kubectl run -i --tty load-generator --rm --image=busybox:1.36.0 --restart=Never --timeout=60s -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://guestbook:3000; done" || true

# Capture HPA scaling
echo "Capturing HPA scaling status..."
kubectl get hpa guestbook > hpa2

# 6. Update CPU limits for Revision 2
echo "Updating CPU limits to 5m/2m for Revision 2..."
sed -i 's/cpu: 50m/cpu: 5m/g' v1/guestbook/deployment.yml
sed -i 's/cpu: 20m/cpu: 2m/g' v1/guestbook/deployment.yml
kubectl apply -f v1/guestbook/deployment.yml > deployment

# Capture rollout details
echo "Waiting for rollout to register..."
sleep 10
kubectl rollout history deployments guestbook --revision=2 > rev

# 7. Perform Rollback
echo "Undoing deployment to revision 1..."
kubectl delete hpa guestbook || true
kubectl scale deployment guestbook --replicas=1
kubectl rollout undo deployment/guestbook --to-revision=1

echo "Getting replica sets..."
sleep 10
kubectl get rs > rs

echo "=== Script Completed Successfully ==="
