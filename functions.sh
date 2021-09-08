#!/bin/bash


mysql_stat(){
echo $(service --status-all | grep mysql)
echo $(mysqld --version)
}
hello(){
  echo "hello world!"
}

hello_arg(){
  echo "hello world! $1"
}

add_annotation(){
pmm-admin annotate "hello function world $1" --node --tags "$2"
}

add_start_annotation(){
pmm-admin annotate "Start $1" --node --tags "$2"
start_ts=$(date +%s)
}

add_finish_annotation(){
pmm-admin annotate "Finish $1" --node --tags "$2"
end_ts=$(date +%s)
}

get_cpu_info(){
echo "usage get_cpu_info() function is not recommended -- deprecated"
curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name,mode) (clamp_max(((avg by (mode,node_name) ( (clamp_max(rate(node_cpu_seconds_total{node_name="'$my_nodename'",mode!="idle"}[5m]),1)) or (clamp_max(irate(node_cpu_seconds_total{node_name="'$my_nodename'",mode!="idle"}[5m]),1)) ))*100 or (avg_over_time(node_cpu_average{node_name="'$my_nodename'", mode!="total", mode!="idle"}[5m]) or avg_over_time(node_cpu_average{node_name="'$my_nodename'", mode!="total", mode!="idle"}[5m]))),100))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

add_web_log(){
datetime=$(date)
sudo systemctl stop apache2
sudo chmod 777 /var/www/html/index.html
sudo echo "<br><br><font color='green'>$datetime -->> $1" >> /var/www/html/index.html
sudo systemctl start apache2
sleep 3
}



run_test(){
sudo mkdir -vp $log_folder/$1
sudo chmod 777 $log_folder/$1

add_start_annotation $1 $2
($3) > $log_folder/$1/$1_sysbenchmark.log
add_finish_annotation $1 $2

#get_cpu_info > $log_folder/$1/$1_cpu_01_log.json
get_cpu_usage > $log_folder/$1/$1_01_get_cpu_usage_log.json
get_cpu_max_util > $log_folder/$1/$1_02_get_cpu_max_util_log.json
get_cpu_norm_load > $log_folder/$1/$1_03_get_cpu_norm_load_log.json
get_cpu_max_core_util > $log_folder/$1/$1_04_get_cpu_max_core_util_log.json
get_cpu_credit_usage > $log_folder/$1/$1_05_get_cpu_credit_usage_log.json

get_context_switches > $log_folder/$1/$1_07_get_context_switches_log.json
get_context_switches_per_virtual_cpu > $log_folder/$1/$1_08_get_context_switches_per_virtual_cpu_log.json
get_interrupts > $log_folder/$1/$1_09_get_interrupts_log.json
get_runnable_processes > $log_folder/$1/$1_10_get_runnable_processes_log.json
get_blocked_processes > $log_folder/$1/$1_11_get_blocked_processes_log.json
get_created_processes_fork > $log_folder/$1/$1_12_get_created_processes_fork_log.json

get_memory_used > $log_folder/$1/$1_13_get_memory_used_log.json
get_memory_cache > $log_folder/$1/$1_14_get_memory_cache_log.json
get_memory_total > $log_folder/$1/$1_15_get_memory_total_log.json

get_virt_memory_used > $log_folder/$1/$1_16_get_virt_memory_used_log.json
get_virtual_memory_available > $log_folder/$1/$1_17_get_virtual_memory_available_log.json
get_virtual_momory_total > $log_folder/$1/$1_18_get_virtual_momory_total_log.json
get_cpu_exp > $log_folder/$1/$1_18_get_cpu_exp_log.json
}


### Resource collection functions


get_cpu_usage(){
curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name,mode) (clamp_max(((avg by (mode,node_name) ( (clamp_max(rate(node_cpu_seconds_total{node_name="'$my_nodename'",mode!="idle"}[5m]),1)) or (clamp_max(irate(node_cpu_seconds_total{node_name="'$my_nodename'",mode!="idle"}[5m]),1)) ))*100 or (avg_over_time(node_cpu_average{node_name="'$my_nodename'", mode!="total", mode!="idle"}[5m]) or avg_over_time(node_cpu_average{node_name="'$my_nodename'", mode!="total", mode!="idle"}[5m]))),100))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_cpu_max_util(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=clamp_max(max by (node_name) (sum  by (cpu,node_name) ( (clamp_max(rate(node_cpu_seconds_total{node_name="'$my_nodename'",mode!="idle",mode!="iowait"}[5s]),1)) or (clamp_max(irate(node_cpu_seconds_total{node_name="'$my_nodename'",mode!="idle",mode!="iowait"}[5m]),1)) )),1)' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_cpu_norm_load(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) ((avg_over_time(node_procs_running{node_name="'$my_nodename'"}[5s])-1) / scalar(count(node_cpu_seconds_total{mode="user", node_name="'$my_nodename'"})) or (avg_over_time(node_procs_running{node_name="'$my_nodename'"}[5m])-1) / scalar(count(node_cpu_seconds_total{mode="user", node_name="'$my_nodename'"})))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}



get_cpu_max_core_util(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=clamp_max(max by (node_name) (sum  by (cpu,node_name) ( (clamp_max(rate(node_cpu_seconds_total{node_name="'$my_nodename'",mode!="idle",mode!="iowait"}[5s]),1)) or (clamp_max(irate(node_cpu_seconds_total{node_name="'$my_nodename'",mode!="idle",mode!="iowait"}[5m]),1)) )),1)' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}


get_cpu_credit_usage(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (aws_rds_cpu_credit_usage_average{node_name="'$my_nodename'"})' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}



get_context_switches(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (rate(node_context_switches_total{node_name="'$my_nodename'"}[5s]) or irate(node_context_switches_total{node_name="'$my_nodename'"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_context_switches_per_virtual_cpu(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) ((rate(node_context_switches_total{node_name="'$my_nodename'"}[5s]) or irate(node_context_switches_total{node_name="'$my_nodename'"}[5m])) / scalar(count(node_cpu_seconds_total{mode="user", node_name="'$my_nodename'"})))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_interrupts(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (rate(node_intr_total{node_name="'$my_nodename'"}[5s]) or irate(node_intr_total{node_name="'$my_nodename'"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}



get_runnable_processes(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (clamp_min((avg_over_time(node_procs_running{node_name="'$my_nodename'"}[5s]) - 1) or (avg_over_time(node_procs_running{node_name="'$my_nodename'"}[5m]) -1),0))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_blocked_processes(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (avg_over_time(node_procs_blocked{node_name="'$my_nodename'"}[5s]) or avg_over_time(node_procs_blocked{node_name="'$my_nodename'"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_created_processes_fork(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (rate(node_forks_total{node_name="'$my_nodename'"}[5s]) or irate(node_forks_total{node_name="'$my_nodename'"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}


get_memory_used(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=clamp_min(avg by (node_name) (((avg_over_time(node_memory_MemTotal_bytes{node_name="'$my_nodename'"}[5s]) or avg_over_time(node_memory_MemTotal_bytes{node_name="'$my_nodename'"}[5m])) - ((avg_over_time(node_memory_MemFree_bytes{node_name="'$my_nodename'"}[5s]) or avg_over_time(node_memory_MemFree_bytes{node_name="'$my_nodename'"}[5m]))+ \n(avg_over_time(node_memory_Buffers_bytes{node_name="'$my_nodename'"}[5s]) or avg_over_time(node_memory_Buffers_bytes{node_name="'$my_nodename'"}[5m])) + \n(avg_over_time(node_memory_Cached_bytes{node_name="'$my_nodename'"}[5s]) or avg_over_time(node_memory_Cached_bytes{node_name="'$my_nodename'"}[5m]))))),0)' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_memory_cache(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (avg(avg_over_time(node_memory_Cached_bytes{node_name="'$my_nodename'",job=~\"rds.*|node.*\"}[5s]) or avg_over_time(node_memory_Cached_bytes{node_name="'$my_nodename'",job=~\"rds.*|node.*\"}[5m])) without (job))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_memory_total(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (avg_over_time(node_memory_MemTotal_bytes{node_name="'$my_nodename'"}[5s]) or avg_over_time(node_memory_MemTotal_bytes{node_name="'$my_nodename'"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}



get_resource(){
    curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query='$resourse_query'' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}


get_virt_memory_used(){

        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (\n((avg_over_time(node_memory_MemTotal_bytes{node_name=\"$node_name\"}[5s]) or avg_over_time(node_memory_MemTotal_bytes{node_name=\"$node_name\"}[5m])) +\n(avg_over_time(node_memory_SwapTotal_bytes{node_name=\"$node_name\"}[5s]) or avg_over_time(node_memory_SwapTotal_bytes{node_name=\"$node_name\"}[5m]))) -\n((avg_over_time(node_memory_SwapFree_bytes{node_name=\"$node_name\"}[5s]) or avg_over_time(node_memory_SwapFree_bytes{node_name=\"$node_name\"}[5m])) + ((avg_over_time(node_memory_MemAvailable_bytes{node_name=\"$node_name\"}[5s]) or avg_over_time(node_memory_MemAvailable_bytes{node_name=\"$node_name\"}[5m])) or\n((avg_over_time(node_memory_MemFree_bytes{node_name=\"$node_name\"}[5s]) or avg_over_time(node_memory_MemFree_bytes{node_name=\"$node_name\"}[5m]))+\n(avg_over_time(node_memory_Buffers_bytes{node_name=\"$node_name\"}[5s]) or avg_over_time(node_memory_Buffers_bytes{node_name=\"$node_name\"}[5m]))+\n(avg_over_time(node_memory_Cached_bytes{node_name=\"$node_name\"}[5s]) or avg_over_time(node_memory_Cached_bytes{node_name=\"$node_name\"}[5m])))))\n)' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}


get_virtual_memory_available(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (\n(avg_over_time(node_memory_SwapFree_bytes{node_name=\"$node_name\"}[5s]) or avg_over_time(node_memory_SwapFree_bytes{node_name=\"$node_name\"}[5m])) + ((avg_over_time(node_memory_MemAvailable_bytes{node_name=\"$node_name\"}[5s]) or avg_over_time(node_memory_MemAvailable_bytes{node_name=\"$node_name\"}[5m])) or\n((avg_over_time(node_memory_MemFree_bytes{node_name=\"$node_name\"}[5s]) or avg_over_time(node_memory_MemFree_bytes{node_name=\"$node_name\"}[5m]))+\n(avg_over_time(node_memory_Buffers_bytes{node_name=\"$node_name\"}[5s]) or avg_over_time(node_memory_Buffers_bytes{node_name=\"$node_name\"}[5m]))+\n(avg_over_time(node_memory_Cached_bytes{node_name=\"$node_name\"}[5s]) or avg_over_time(node_memory_Cached_bytes{node_name=\"$node_name\"}[5m]))))\n)' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_virtual_momory_total(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'avg by (node_name) ((avg_over_time(node_memory_MemTotal_bytes{node_name="'$my_nodename'"}[5s]) or avg_over_time(node_memory_MemTotal_bytes{node_name="'$my_nodename'"}[5m])) + \n(avg_over_time(node_memory_SwapTotal_bytes{node_name="'$my_nodename'"}[5s]) or avg_over_time(node_memory_SwapTotal_bytes{node_name="'$my_nodename'"}[5m])))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'

    
}
