#!/bin/bash

# Clear screen
clear

echo "=========================================================="
echo "          MICROSERVICES PROJECT - TASK EVIDENCE           "
echo "=========================================================="
echo ""

echo "----------------------------------------------------------"
echo ">>> TASK 1 & 2: Backend Deployments Status"
echo "----------------------------------------------------------"
echo "Run this command to check/screenshot your backend app status:"
echo "  ibmcloud ce app list"
echo ""

echo "----------------------------------------------------------"
echo ">>> TASK 3: Git Clone Verification"
echo "----------------------------------------------------------"
echo "Run this command to show your cloned frontend repo directory:"
echo "  ls -la /home/project/dealer_evaluation_frontend"
echo ""

echo "----------------------------------------------------------"
echo ">>> TASK 4: Code Changes in index.html (URLs Updated)"
echo "----------------------------------------------------------"
echo "Run this command to view/screenshot the updated URLs in index.html:"
echo "  grep -n -E \"codeengine|appdomain|localhost\" /home/project/dealer_evaluation_frontend/index.html"
echo ""

echo "----------------------------------------------------------"
echo ">>> TASK 5: Frontend Deployment Status"
echo "----------------------------------------------------------"
echo "Run this command to check/screenshot your frontend app status:"
echo "  ibmcloud ce app get -n frontend"
echo ""

echo "----------------------------------------------------------"
echo ">>> TASK 6, 7, 8, 9: Web UI Screenshots"
echo "----------------------------------------------------------"
echo "Access the Frontend URL in your browser to take the screenshots:"
FRONTEND_URL=$(ibmcloud ce application get --name frontend --output url 2>/dev/null || ibmcloud ce app get -n frontend 2>/dev/null | grep -i "URL:" | awk '{print $2}')
if [ -z "$FRONTEND_URL" ]; then
  echo "  (Frontend is not deployed yet. Run ./deploy_microservices.sh first)"
else
  echo "  URL: $FRONTEND_URL"
fi
echo ""
echo "Take screenshots of:"
echo "  1. homepage.png: Dropdown showing products preloaded"
echo "  2. product_dealer.png: Selecting a product showing the dealers list"
echo "  3. product_dealer_price.png: Selecting a dealer showing their price"
echo "  4. product_all_dealers_prices.png: Selecting 'All Dealers' showing all prices"
echo "=========================================================="
