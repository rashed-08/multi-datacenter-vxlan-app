source configs/network/vxlan-config.sh

echo "Creating VXLAN-Docker bridge connections..."

# Create bridge interfaces for each DC
sudo ip link add br-dc1 type bridge
sudo ip link add br-dc2 type bridge  
sudo ip link add br-dc3 type bridge

# Add transport-layer IPs to each bridge
sudo ip addr add $HOST_DC1_IP/24 dev br-dc1
sudo ip addr add $HOST_DC2_IP/24 dev br-dc2
sudo ip addr add $HOST_DC3_IP/24 dev br-dc3

# Add container gateway IPs (overlay IPs)
sudo ip addr add $VXLAN_DC1_GATEWAY/16 dev br-dc1
sudo ip addr add $VXLAN_DC2_GATEWAY/16 dev br-dc2
sudo ip addr add $VXLAN_DC3_GATEWAY/16 dev br-dc3

# Attach VXLAN interfaces to bridges
sudo ip link set vxlan${VXLAN_DC1_ID} master br-dc1
sudo ip link set vxlan${VXLAN_DC2_ID} master br-dc2
sudo ip link set vxlan${VXLAN_DC3_ID} master br-dc3

# Bring bridges up
sudo ip link set br-dc1 up
sudo ip link set br-dc2 up
sudo ip link set br-dc3 up

echo "VXLAN bridges created!"