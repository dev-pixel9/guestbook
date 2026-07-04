#!/bin/bash

# Exit on error
set -e

echo "=========================================================="
echo "      Deploying Microservices to IBM Cloud Code Engine     "
echo "=========================================================="
echo ""

# 1. Verify Namespace
if [ -z "$SN_ICR_NAMESPACE" ]; then
  echo "SN_ICR_NAMESPACE is not set. Extracting from ibmcloud..."
  NAMESPACE=$(ibmcloud cr namespaces | grep "sn-labs-" | xargs)
  export SN_ICR_NAMESPACE=$NAMESPACE
fi
echo "Using registry namespace: $SN_ICR_NAMESPACE"

# 2. Deploy Product Details Backend (prodlist)
echo ""
echo ">>> Step 1: Deploying Product Details microservice (Python)..."
echo "Command:"
echo "  ibmcloud ce application create --name prodlist --image us.icr.io/\${SN_ICR_NAMESPACE}/prodlist --registry-secret icr-secret --port 5000 --build-context-dir products_list --build-source https://github.com/ibm-developer-skills-network/dealer_evaluation_backend.git"
echo ""
ibmcloud ce application create --name prodlist \
  --image us.icr.io/${SN_ICR_NAMESPACE}/prodlist \
  --registry-secret icr-secret \
  --port 5000 \
  --build-context-dir products_list \
  --build-source https://github.com/ibm-developer-skills-network/dealer_evaluation_backend.git

# Get product details deployment URL
echo "Getting URL for prodlist..."
PROD_URL=$(ibmcloud ce application get --name prodlist --output url || ibmcloud ce app get -n prodlist | grep -i "URL:" | awk '{print $2}')
echo "Product Details URL: $PROD_URL"

# 3. Deploy Dealer Pricing Backend (dealerdetails)
echo ""
echo ">>> Step 2: Deploying Dealer Pricing microservice (Node.js)..."
echo "Command:"
echo "  ibmcloud ce application create --name dealerdetails --image us.icr.io/\${SN_ICR_NAMESPACE}/dealerdetails --registry-secret icr-secret --port 8080 --build-context-dir dealer_details --build-source https://github.com/ibm-developer-skills-network/dealer_evaluation_backend.git"
echo ""
ibmcloud ce application create --name dealerdetails \
  --image us.icr.io/${SN_ICR_NAMESPACE}/dealerdetails \
  --registry-secret icr-secret \
  --port 8080 \
  --build-context-dir dealer_details \
  --build-source https://github.com/ibm-developer-skills-network/dealer_evaluation_backend.git

# Get dealer pricing deployment URL
echo "Getting URL for dealerdetails..."
DEALER_URL=$(ibmcloud ce application get --name dealerdetails --output url || ibmcloud ce app get -n dealerdetails | grep -i "URL:" | awk '{print $2}')
echo "Dealer Pricing URL: $DEALER_URL"

# 4. Clone Frontend Microservice
echo ""
echo ">>> Step 3: Cloning Frontend Microservice..."
echo "Commands:"
echo "  cd /home/project"
echo "  git clone https://github.com/ibm-developer-skills-network/dealer_evaluation_frontend.git"
echo ""
cd /home/project
rm -rf dealer_evaluation_frontend
git clone https://github.com/ibm-developer-skills-network/dealer_evaluation_frontend.git
cd dealer_evaluation_frontend

# 5. Update index.html placeholders with deployed URLs
echo ""
echo ">>> Step 4: Updating index.html with deployment URLs..."
# Ensure no double slashes on replace
PROD_URL="${PROD_URL%/}"
DEALER_URL="${DEALER_URL%/}"

echo "Replacing http://localhost:5000/ with $PROD_URL/"
sed -i "s|http://localhost:5000/|$PROD_URL/|g" index.html

echo "Replacing http://localhost:8080/ with $DEALER_URL/"
sed -i "s|http://localhost:8080/|$DEALER_URL/|g" index.html

# 6. Deploy Frontend Microservice
echo ""
echo ">>> Step 5: Deploying Frontend microservice..."
echo "Command:"
echo "  ibmcloud ce application create --name frontend --image us.icr.io/\${SN_ICR_NAMESPACE}/frontend --registry-secret icr-secret --port 5001 --build-source ."
echo "  (Note: If this or previous commands fail with 'Wait failed', you can rename the app to 'prodlist1', 'dealerdetails1', or 'frontend1' and rerun)."
echo ""
ibmcloud ce application create --name frontend \
  --image us.icr.io/${SN_ICR_NAMESPACE}/frontend \
  --registry-secret icr-secret \
  --port 5001 \
  --build-source .

# Get frontend deployment URL
FRONTEND_URL=$(ibmcloud ce application get --name frontend --output url || ibmcloud ce app get -n frontend | grep -i "URL:" | awk '{print $2}')

echo ""
echo "=========================================================="
echo "               DEPLOYMENT SUMMARY                         "
echo "=========================================================="
echo "Product Details microservice URL:  $PROD_URL/"
echo "Dealer Pricing microservice URL:   $DEALER_URL/"
echo "Frontend microservice URL:         $FRONTEND_URL/"
echo "=========================================================="
echo "You can now open the Frontend URL to access your app!"
