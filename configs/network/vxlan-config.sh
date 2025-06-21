# VXLAN Configuration

# Physical interface (adjust based on your system)
PHYSICAL_INTERFACE="enp0s1"

# DC1 - North America
VXLAN_DC1_ID=20
VXLAN_DC1_SUBNET="10.20.0.0/16"
VXLAN_DC1_GATEWAY="10.20.1.1"

# DC2 - Europe
VXLAN_DC2_ID=30
VXLAN_DC2_SUBNET="10.30.0.0/16"
VXLAN_DC2_GATEWAY="10.30.1.1"

# DC3 - Asia Pacific
VXLAN_DC3_ID=40
VXLAN_DC3_SUBNET="10.40.0.0/16"
VXLAN_DC3_GATEWAY="10.40.1.1"

# VXLAN UDP Port
VXLAN_PORT=4789

# Multicast Group (optional, for simulation)
VXLAN_GROUP="239.1.1.1"