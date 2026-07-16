#! /usr/bin/bash

arch=$(uname -a)

pcpu=$(lscpu | grep "Core(s) per socket" | awk 'NR==1 {print $NF}')

vcpu=$(lscpu | grep "CPU(s)" | awk 'NR==1 {print $NF}')


total_mem=$(free -m | grep Mem | awk '{print $2}')
used_mem=$(free -m | grep Mem | awk '{print $3}')
pct_mem=$(awk -v total="$total_mem" -v used="$used_mem" 'BEGIN{printf("%.2f", (used*100/total))}')
mem_usage="${used_mem}/${total_mem}MB ($pct_mem%)"

total_disk=$(df -m | grep mapper | awk '{disk_t += $2} END{printf("%.1fGb", disk_t/1024)}')
used_disk=$(df -m | grep mapper | awk '{disk_u+=$3} END {printf("%i",disk_u)}')
pct_disk=$(df -m | grep mapper | awk '{disk_t+=$2} {disk_u+=$3} END{printf("%i%%", (disk_u*100/disk_t))}')
disk_usage="$used/$total ($pct_disk)"


cpu_idle=$(top -bn1 | grep Cpu | awk '{for(i=1;i<=NF;i++) if($i=="id,") {val=$(i-1); split(val, arr, ","); j=1; if(arr[j]=="ni"){j+=1}; printf("%f", arr[j])}}')
cpu_load=$(awk -v t="100" -v i="$cpu_idle" 'BEGIN{printf("%.1f%%", (t - i))}')

last_boot=$(who --boot |  awk '{for(i=1;i<=NF;i++) if($i ~ /boot/) printf("%s %s", $(i+1), $NF)}')

active_lvm=$(lsblk | grep lvm | wc -l | awk '{if($1=="0") print "no"; else print "yes"}')

connections=$(ss -s | grep TCP |grep estab | awk '{for(i=1;i<=NF;i++){if($i ~ /estab/) estab+=$(i+1)} printf("%s ESTABLISHED", estab)}')

logged_in=$(w -h | awk '{print $1}' | sort -u | wc -l)

ip=$(hostname -I | awk '{print $1}')
mac=$(ip a | grep ether | awk 'NR==1 {print $2}')
ip_mac="$ip ($mac)"

sudo_counts=$(journalctl -q | grep sudo | grep COMMAND | wc -l)


message=\
"    #Architecture: $arch
    #Physical CPU: $pcpu
    #vCPU: $vcpu
    #Memory Usage: $mem_usage
    #Disk Usage: $disk_usage
    #CPU load: $cpu_load
    #Last boot: $last_boot
    #LVM use: $active_lvm
    #TCP Connections: $connections
    #User log: $logged_in
    #Network: $ip_mac
    #Sudo: $sudo_counts cmd
"

while (true);
do
	wall "$message"

	for dest in $(w -h | grep -v "tty" | awk '{print $2}');
	do
		printf "\n%s\n" "$message" > "/dev/$dest";
	done
	sleep 600
done
