# Ansible Playbook to deploy Secure server

This Ansible playbook automates the deployment and configuration of server. It ensures that the necessary dependencies, configuration files, and services are properly set for secure environment.

```bash
ansible-playbook -i inventory/inventory.yml main.yml
```

## Table of Contents

- [Requirements](#requirements)
- [Setup](#setup)
- [Variables](#variables)
- [Usage](#usage)
- [Services Installed](#services-installed)

## Requirements

Before using this playbook, ensure the following requirements are met:

1. **Ansible version**: Make sure you have Ansible 2.15+ installed.
2. **SSH Access**: Passwordless SSH access to all target servers.
3. **Python**: Python 3.x installed on the control node and all target hosts.
4. **Privileges**: The user running the playbook must have sudo privileges on the target machines.

## Setup

1. Install Ansible

    If Ansible is not installed, visit the official documentation for detailed instructions on how to install Ansible on various Linux distributions:

    [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html)


2. Clone the repository

    Clone this repository to your Ansible control node:

    ```bash
    git clone https://github.com/encapsulate-xyz/server-setup-playbook.git
    cd server-setup-playbook
    ```

3. Inventory

    Define your target servers' IP address or DNS in the inventory folder, and update the `inventory.yml`.

    Example for inventory.yml

    ```yaml
    ---
    all:
    children:
        hosts:
            validator.bera.testnet.encapsulate.xyz:
    ```

## Variables

This playbook allows customization through several variables. You can define these variables in the following locations:

- **`group_vars/all.yml`**: Contains all the port configurations.
- **`group_vars/default.yml`**: Contains version-specific variables.
- **`group_vars/vault.yml`**: Store secret variables, such as `passwords, api keys`, in this file.

## Usage

1. First, install the dependencies:

    ```bash
    ansible-galaxy install -r requirements.yml
    ```

2. Create a `ansible_vault_password` file containing ansible-vault password

3. Then run the playbook:

    ```bash
    ansible-playbook main.yml -l validator.bera.testnet.encapsulate.xyz
    ```

## Services Installed

| Services           | Description                                                                                     |
|--------------------|-------------------------------------------------------------------------------------------------|
| `node exporter`    | Node Exporter is used for exposing metrics about the operating system and hardware of a server. |
| `process exporter` | Process Exporter is used to expose information about running processes on a system.             |
| `promtail`         | Promtail is used to collect logs from various sources and send them to Loki.                    |
| `auditd`           | auditd provides logging of events                                                               |
| `fail2ban`         | fail2ban monitors the logs of applications to detect and prevent potential intrusions.          |
| `msmtp`            | msmtp is configured for mailing.                                                                |
| `rkhunter`         | rkhunter scans systems for rootkits, backdoors, and other potential vulnerabilities.            |

### auditd rules

Uses best practice rules from [Neo23x0](https://github.com/Neo23x0)

### fail2ban configuration

```toml
[sshd]
enabled = true
banaction = ufw         #fail2ban is configured to use ufw, to block ip address
port = {{ ssh_login_port | default('ssh') }}
filter = sshd
logpath = /var/log/auth.log
maxretry = 5            #max 5 fail attempts
findtime = 86400        #1 hour time window for multiple failed login attempts 
bantime  = -1           #-1 means implement permanent ban
```

### rkhunter configuration


| Setting                          | Note                                                                                                       |
|----------------------------------|------------------------------------------------------------------------------------------------------------|
| `UPDATE_MIRRORS=1`               | Enables automatic updating before running a scan                                                           |
| `MIRRORS_MODE=0`                 | Sticks to the primary mirror for updates                                                                   |
| `COPY_LOG_ON_ERROR=1`            | To save a copy of the log if there is an error                                                             |
| `PHALANX2_DIRTEST=1`             | Enables testing for the Phalanx2 rootkit                                                                   |
| `WEB_CMD=""`                     | This is to address an issue with the Debian package that disables the ability for rkhunter to self-update. |
| `USE_LOCKING=1`                  | To prevent issues with rkhunter running multiple times                                                     |
| `SHOW_SUMMARY_WARNINGS_NUMBER=1` | To see the actual number of warnings found                                                                 |
