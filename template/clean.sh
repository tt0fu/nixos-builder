before=$(df -k . | awk 'NR==2 {print $4}')

sudo nh clean all
nh clean all

after=$(df -k . | awk 'NR==2 {print $4}')

freed_gb=$(echo $after $before | awk '{print ($1 - $2) / 1024.0 / 1024.0}')

echo ""

echo "Cleaning freed $freed_gb GB"
