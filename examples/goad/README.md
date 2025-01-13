# GOAD Lab Setup Scripts

Two automation scripts to help deploy the Game Of Active Directory (GOAD) lab environment.

## Scripts

### 1-start-vms.sh
- Initializes and starts required Incus VMs
- Configures base Kali Linux instance with essential pentesting tools
- Sets up networking for lab environment
- Prerequisites: Incus installed and configured

### 2-deploy-goad.sh
- Deploys GOAD (Game Of Active Directory) lab environment 【1】
- Sets up vulnerable Active Directory testing environment
- Creates multi-forest, multi-domain Windows infrastructure
- https://github.com/Orange-Cyberdefense/GOAD

## Note
This lab environment is intentionally vulnerable and should only be used in isolated testing environments
