# server-setup-playbook

### To run the playbook

```
ansible-playbook main.yml -e "target=" --ask-vault-pass
```

### Services Enabled

| Services| Description|
| -- | -- |
| `node exporter`|Node Exporter is used for exposing metrics about the operating system and hardware of a server.|
| `process exporter`|Process Exporter is used to expose information about running processes on a system.|
| `promtail`|Promtail is used to collect logs from various sources and send them to Loki.|
| `auditd`|auditd provides logging of events|
| `fail2ban`|fail2ban monitors the logs of applications to detect and prevent potential intrusions.|
| `msmtp`|msmtp is configured for mailing.|
| `rkhunter`|rkhunter scans systems for rootkits, backdoors, and other potential vulnerabilities.|

### auditd

Uses best practice rules from [Neo23x0](https://github.com/Neo23x0) 

### fail2ban configuration

```
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

|Setting|Note|
|--|--|
|`UPDATE_MIRRORS=1`|Enables automatic updating before running a scan|
|`MIRRORS_MODE=0`|Sticks to the primary mirror for updates|
|`COPY_LOG_ON_ERROR=1`|To save a copy of the log if there is an error|
|`PHALANX2_DIRTEST=1`|Enables testing for the Phalanx2 rootkit|
|`WEB_CMD=""`|This is to address an issue with the Debian package that disables the ability for rkhunter to self-update.|
|`USE_LOCKING=1`|To prevent issues with rkhunter running multiple times|
|`SHOW_SUMMARY_WARNINGS_NUMBER=1`|To see the actual number of warnings found|

### About variables

|Variable|Note|
|--|--|
|`ssh_login_port`|Define the ssh port|
|`swap_size_gb`|Define the desired swap size in GB|
|`swap_file_path`|Define the swap file path you want to create swap|
|`swappiness_value`|Define the desired swappiness value|
|`mail_to`|Setup the email who will recieve alerts|
|`mail_from`|Setup the email who will send alerts|
|`mail_smtp_server`|Define smtp server for mailing|
|`mail_port`|Define the smtp port|
|`monitor_server_dns`|Define your monitoring server dns|
|`node_exporter_version`|Define the node exporter version|
|`promtail_version`|Define the promtail version|
