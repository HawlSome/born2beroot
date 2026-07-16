#! /usr/bin/bash

su -
apt install ufw openssh-server sudo libpam-pwquality -y

#configure ssh
ufw enable
ufw allow 4242
echo "Port 4242" > /etc/ssh/sshd_config
echo "PermitRootLogin no" > /etc/ssh/sshd_config
systemctl restart sshd
systemctl enable ufw
systemct restart ufw

#configure user
groupadd user42
usermod -a -G sudo $USERNAME
usermod -a -G user42 $USERNAME

#configure password quality
rules=\
"
difok = 7
minlen = 10
dcredit = -1
ucredit = -1
lcredit = -1
maxrepeat = 3
gecoscheck = 1
retry = 3
enforce_root
"
echo "$rules" > /etc/security/pwquality

#configure sudo
secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
sudo_rules=\
"
Defaults	requiretty
Defaults	secure_path=$secure_path
Defaults	passwd_tries=3
Defaults	badpass_message="Nice try, you can do better !!!"
Defaults	log_input, log_output
Defaults	iolog_dir="/var/log/sudo"
Defaults	logfile="/var/log/sudo/sudo.log"
"

echo "type visudo and pastes those rules inside it."
echo "$sudo_rules"

#create script for monitoring
cp ./monitoring.sh /root/monitoring.sh
chmod 722 /root/monitoring.sh
echo "open crontab(the file for scheduling cron) with:\n  crontab -e (run as root)."
echo "paste the command bellow inside it:"
echo "@reboot /root/monitoring.sh"
systemctl enable cron
systemct restart cron