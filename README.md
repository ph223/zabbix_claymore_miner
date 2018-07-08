# zabbix_claymore_miner

This is a template for Zabbix, designed to collect metrics from Claymore's Ethereum Dual miner.

# Requirements

* Claymore's Ethereum Dual miner 4.3+
* Zabbix 3.4

# Installation

First, install the Claymore's miner and zabbix-agent.

Installation steps:
```
git clone https://github.com/ph223/zabbix_claymore_miner
cp zabbix_claymore_miner/conf.d/claymore.conf /etc/zabbix/zabbix_agentd.d/
mkdir -p /etc/zabbix/scripts
cp zabbix_claymore_miner/scripts/claymore.pl /etc/zabbix/scripts/
chmod 755 /etc/zabbix/scripts/claymore.pl

systemctl restart zabbix-agent
```

Import claymore.xml template to you Zabbix frontend and apply it to required hosts.
