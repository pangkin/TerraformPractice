#!/bin/bash
sudo apt update && sudo apt upgrage -y
sudo apt install -y apache2
echo "MyWEB Page" | sudo tee /var/www/html/index.html
