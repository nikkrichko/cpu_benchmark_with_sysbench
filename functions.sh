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
get_virtual_memory_total > $log_folder/$1/$1_18_get_virtual_memory_total_log.json

get_swap_total > $log_folder/$1/$1_19_get_swap_total_log.json
get_swap_free > $log_folder/$1/$1_20_get_swap_free_log.json
get_swap_used > $log_folder/$1/$1_21_get_swap_used_log.json
get_swap_activity_total > $log_folder/$1/$1_22_get_swap_activity_total_log.json
get_swap_activity_out_write > $log_folder/$1/$1_23_get_swap_activity_out_write_log.json
get_swap_activity_in_read > $log_folder/$1/$1_24_get_swap_activity_in_read_log.json

get_io_total > $log_folder/$1/$1_25_get_io_total_log.json
get_io_disk_write > $log_folder/$1/$1_26_get_io_disk_write_log.json
get_io_disk_read > $log_folder/$1/$1_27_get_io_disk_read_log.json
get_glob_file_descriptor_usage_alloc > $log_folder/$1/$1_28_get_glob_file_descriptor_usage_alloc_log.json
get_glob_file_descriptor_usage_limit > $log_folder/$1/$1_29_get_get_glob_file_descriptor_usage_limit_log.json

get_disk_io_latency_read > $log_folder/$1/$1_30_get_disk_io_latency_read_log.json
get_disk_io_latency_write > $log_folder/$1/$1_31_get_disk_io_latency_write_log.json
get_disk_io_latency_avg_read_1h > $log_folder/$1/$1_32_get_disk_io_latency_avg_read_1h_log.json
get_disk_io_latency_avg_write_1h > $log_folder/$1/$1_33_get_disk_io_latency_avg_write_1h_log.json

get_disk_io_load_read > $log_folder/$1/$1_34_get_disk_io_load_read_log.json
get_disk_io_load_write > $log_folder/$1/$1_35_get_disk_io_load_write_log.json
get_disk_io_load_total > $log_folder/$1/$1_36_get_disk_io_load_total_log.json

get_network_outbound > $log_folder/$1/$1_37_get_virtual_momory_total_log.json
get_network_inbound > $log_folder/$1/$1_38_get_virtual_momory_total_log.json

get_network_err_recieve > $log_folder/$1/$1_39_get_network_err_recieve_log.json
get_network_err_transmit > $log_folder/$1/$1_40_get_network_err_transmit_log.json
get_network_err_recieve_drop > $log_folder/$1/$1_41_get_network_err_recieve_drop_log.json
get_network_err_transmit_drop > $log_folder/$1/$1_42_get_network_err_transmit_drop_log.json

get_tcp_retransmition_ratio > $log_folder/$1/$1_43_get_tcp_retransmition_ratio_log.json
get_tcp_retransmition_segment > $log_folder/$1/$1_44_get_tcp_retransmition_segment_log.json

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

get_virtual_memory_total(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) ((avg_over_time(node_memory_MemTotal_bytes{node_name="'$my_nodename'"}[5s]) or avg_over_time(node_memory_MemTotal_bytes{node_name="'$my_nodename'"}[5m])) + \n(avg_over_time(node_memory_SwapTotal_bytes{node_name="'$my_nodename'"}[5s]) or avg_over_time(node_memory_SwapTotal_bytes{node_name="'$my_nodename'"}[5m])))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

  get_swap_total(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (max_over_time(node_memory_SwapTotal_bytes{node_name="'$my_nodename'"}[5s]) or max_over_time(node_memory_SwapTotal_bytes{node_name="'$my_nodename'"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
    
}

get_swap_free(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (max_over_time(node_memory_SwapFree_bytes{node_name="'$my_nodename'"}[5s]) or max_over_time(node_memory_SwapFree_bytes{node_name="'$my_nodename'"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
    
}

get_swap_used(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) ((avg_over_time(node_memory_SwapTotal_bytes{node_name="'$my_nodename'"}[5s]) or avg_over_time(node_memory_SwapTotal_bytes{node_name="'$my_nodename'"}[5m])) -\n(avg_over_time(node_memory_SwapFree_bytes{node_name="'$my_nodename'"}[5s]) or avg_over_time(node_memory_SwapFree_bytes{node_name="'$my_nodename'"}[5m])))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}


get_swap_activity_total(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) ((rate(node_vmstat_pswpin{node_name="'$my_nodename'"}[5s]) * 4096 or irate(node_vmstat_pswpin{node_name="'$my_nodename'"}[5m]) * 4096) + (rate(node_vmstat_pswpout{node_name="'$my_nodename'"}[5s]) * 4096 or irate(node_vmstat_pswpout{node_name="'$my_nodename'"}[5m]) * 4096))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_swap_activity_out_write(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (rate(node_vmstat_pswpout{node_name="'$my_nodename'"}[5s]) * 4096 or irate(node_vmstat_pswpout{node_name="'$my_nodename'"}[5m]) * 4096)' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_swap_activity_in_read(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (rate(node_vmstat_pswpin{node_name="'$my_nodename'"}[5s]) * 4096 or irate(node_vmstat_pswpin{node_name="'$my_nodename'"}[5m]) * 4096)' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}


get_io_total(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) ((rate(node_vmstat_pgpgin{node_name="'$my_nodename'"}[5s]) * 1024 or irate(node_vmstat_pgpgin{node_name="'$my_nodename'"}[5m]) * 1024 ) + (rate(node_vmstat_pgpgout{node_name="'$my_nodename'"}[5s]) * 1024 or irate(node_vmstat_pgpgout{node_name="'$my_nodename'"}[5m]) * 1024) or\n((max_over_time(rdsosmetrics_diskIO_writeKbPS{node_name="'$my_nodename'"}[5s]) or max_over_time(rdsosmetrics_diskIO_writeKbPS{node_name="'$my_nodename'"}[5m])) +\n(max_over_time(rdsosmetrics_diskIO_readKbPS{node_name="'$my_nodename'"}[5s]) or max_over_time(rdsosmetrics_diskIO_readKbPS{node_name="'$my_nodename'"}[5m])))* 1024)' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_io_disk_write(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) ((rate(node_vmstat_pgpgout{node_name="'$my_nodename'"}[5s]) * 1024 or irate(node_vmstat_pgpgout{node_name="'$my_nodename'"}[5m]) * 1024) or\n(max_over_time(rdsosmetrics_diskIO_writeKbPS{node_name="'$my_nodename'"}[5s]) or max_over_time(rdsosmetrics_diskIO_writeKbPS{node_name="'$my_nodename'"}[5m])) * 1024)' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_io_disk_read(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (rate(node_vmstat_pgpgin{node_name="'$my_nodename'"}[5s]) * 1024 or irate(node_vmstat_pgpgin{node_name="'$my_nodename'"}[5m]) * 1024 or\n(max_over_time(rdsosmetrics_diskIO_readKbPS{node_name="'$my_nodename'"}[5s]) or max_over_time(rdsosmetrics_diskIO_readKbPS{node_name="'$my_nodename'"}[5m])) * 1024)' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_glob_file_descriptor_usage_alloc(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (max_over_time(node_filefd_allocated{node_name="'$my_nodename'"}[5s]) or max_over_time(node_filefd_allocated{node_name="'$my_nodename'"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_glob_file_descriptor_usage_limit(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (max_over_time(node_filefd_maximum{node_name="'$my_nodename'"}[5s]) or max_over_time(node_filefd_maximum{node_name="'$my_nodename'"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}


get_disk_io_latency_read(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) ((sum by (node_name) (rate(node_disk_read_time_seconds_total{node_name="'$my_nodename'"}[5s])) / sum by (node_name) (rate(node_disk_reads_completed_total{node_name="'$my_nodename'"}[5s]) > 0 )) or (sum by (node_name) (irate(node_disk_read_time_seconds_total{node_name="'$my_nodename'"}[5m])) / \nsum by (node_name) (irate(node_disk_reads_completed_total{node_name="'$my_nodename'"}[5m]) > 0 ))\nor avg_over_time(aws_rds_read_latency_average{node_name="'$my_nodename'"}[5s])/1000 or avg_over_time(aws_rds_read_latency_average{node_name="'$my_nodename'"}[5m])/1000 or\navg_over_time(rdsosmetrics_diskIO_readLatency{node_name="'$my_nodename'"}[5s])/1000 or avg_over_time(rdsosmetrics_diskIO_readLatency{node_name="'$my_nodename'"}[5m])/1000)' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_disk_io_latency_write(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) ((sum by (node_name) (rate(node_disk_write_time_seconds_total{node_name="'$my_nodename'"}[5s])) / sum by (node_name) (rate(node_disk_writes_completed_total{node_name="'$my_nodename'"}[5s]) > 0 )) or (sum by (node_name) (irate(node_disk_write_time_seconds_total{node_name="'$my_nodename'"}[5m])) / \nsum by (node_name) (irate(node_disk_writes_completed_total{node_name="'$my_nodename'"}[5m]) > 0 ))\nor (avg_over_time(aws_rds_write_latency_average{node_name="'$my_nodename'"}[5s])/1000 or avg_over_time(aws_rds_write_latency_average{node_name="'$my_nodename'"}[5m])/1000) or\n(avg_over_time(rdsosmetrics_diskIO_writeLatency{node_name="'$my_nodename'"}[5s]) or avg_over_time(rdsosmetrics_diskIO_writeLatency{node_name="'$my_nodename'"}[5m]))/1000)' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_disk_io_latency_avg_read_1h(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) ((sum by (node_name) (rate(node_disk_read_time_seconds_total{node_name="'$my_nodename'"}[1h])) / sum by (node_name) (rate(node_disk_reads_completed_total{node_name="'$my_nodename'"}[1h]) > 0 ))\nor avg_over_time(aws_rds_read_latency_average{node_name="'$my_nodename'"}[1h])/1000 or avg_over_time(aws_rds_read_latency_average{node_name="'$my_nodename'"}[1h])/1000 or\navg_over_time(rdsosmetrics_diskIO_readLatency{node_name="'$my_nodename'"}[1h])/1000 or avg_over_time(rdsosmetrics_diskIO_readLatency{node_name="'$my_nodename'"}[1h])/1000)' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_disk_io_latency_avg_write_1h(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) ((sum by (node_name) (rate(node_disk_write_time_seconds_total{node_name="'$my_nodename'"}[1h])) / sum by (node_name) (rate(node_disk_writes_completed_total{node_name="'$my_nodename'"}[1h]) > 0 )) \nor (avg_over_time(aws_rds_write_latency_average{node_name="'$my_nodename'"}[5s])/1000 or avg_over_time(aws_rds_write_latency_average{node_name="'$my_nodename'"}[1h])/1000) or\n(avg_over_time(rdsosmetrics_diskIO_writeLatency{node_name="'$my_nodename'"}[5s])/1000 or avg_over_time(rdsosmetrics_diskIO_writeLatency{node_name="'$my_nodename'"}[1h])/1000))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}



get_disk_io_load_read(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (sum by (node_name) (rate(node_disk_read_time_seconds_total{node_name="'$my_nodename'"}[5s])) or sum by (node_name) (irate(node_disk_read_time_seconds_total{node_name="'$my_nodename'"}[5m])) or\n(sum by (node_name) (rdsosmetrics_diskIO_readIOsPS{node_name="'$my_nodename'"})))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_disk_io_load_write(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (sum by (node_name) (rate(node_disk_write_time_seconds_total{node_name="'$my_nodename'"}[5s])) or sum by (node_name) (irate(node_disk_write_time_seconds_total{node_name="'$my_nodename'"}[5m])) or (sum by (node_name) (rdsosmetrics_diskIO_writeIOsPS{node_name="'$my_nodename'"})))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_disk_io_load_total(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) ((sum by (node_name) (rate(node_disk_read_time_seconds_total{node_name="'$my_nodename'"}[5s])) or sum by (node_name) (irate(node_disk_read_time_seconds_total{node_name="'$my_nodename'"}[5m]))) + (sum by (node_name) (rate(node_disk_write_time_seconds_total{node_name="'$my_nodename'"}[5s])) or sum by (node_name) (irate(node_disk_write_time_seconds_total{node_name="'$my_nodename'"}[5m]))) or\n(sum by (node_name) (rdsosmetrics_diskIO_writeIOsPS{node_name="'$my_nodename'"})) +  (sum by (node_name) (rdsosmetrics_diskIO_readIOsPS{node_name="'$my_nodename'"})))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_network_outbound(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=sum by (node_name) (rate(node_network_transmit_bytes_total{node_name="'$my_nodename'", device!=\"lo\"}[5s])) or sum by (node_name) (irate(node_network_transmit_bytes_total{node_name="'$my_nodename'", device!=\"lo\"}[5m])) or\nsum by (node_name) (max_over_time(rdsosmetrics_network_tx{node_name="'$my_nodename'"}[5s])) or sum by (node_name) (max_over_time(rdsosmetrics_network_tx{node_name="'$my_nodename'"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_network_inbound(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=sum by (node_name) (rate(node_network_receive_bytes_total{node_name="'$my_nodename'", device!=\"lo\"}[5s])) or sum by (node_name) (irate(node_network_receive_bytes_total{node_name="'$my_nodename'", device!=\"lo\"}[5m])) or sum by (node_name) (max_over_time(rdsosmetrics_network_rx{node_name="'$my_nodename'"}[5s])) or sum by (node_name) (max_over_time(rdsosmetrics_network_rx{node_name="'$my_nodename'"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}


get_network_err_recieve(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=sum by (node_name) (rate(node_network_receive_errs_total{node_name="'$my_nodename'", device!=\"lo\"}[5s])) or \nsum by (node_name) (irate(node_network_receive_errs_total{node_name="'$my_nodename'", device!=\"lo\"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_network_err_transmit(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=sum by (node_name) (rate(node_network_transmit_errs_total{node_name="'$my_nodename'", device!=\"lo\"}[5s])) or\nsum by (node_name) (irate(node_network_transmit_errs_total{node_name="'$my_nodename'", device!=\"lo\"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_network_err_recieve_drop(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=sum by (node_name) (rate(node_network_receive_drop_total{node_name="'$my_nodename'", device!=\"lo\"}[5s])) or\nsum by (node_name) (irate(node_network_receive_drop_total{node_name="'$my_nodename'", device!=\"lo\"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_network_err_transmit_drop(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=sum by (node_name) (rate(node_network_transmit_drop_total{node_name="'$my_nodename'", device!=\"lo\"}[5s])) or \nsum by (node_name) (irate(node_network_transmit_drop_total{node_name="'$my_nodename'", device!=\"lo\"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_tcp_retransmition_ratio(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (rate(node_netstat_Tcp_RetransSegs{node_name="'$my_nodename'"}[5s])/(rate(node_netstat_Tcp_OutSegs{node_name="'$my_nodename'"}[5s]) > 0) or irate(node_netstat_Tcp_RetransSegs{node_name="'$my_nodename'"}[5m])/(irate(node_netstat_Tcp_OutSegsSegs{node_name="'$my_nodename'"}[5m]) > 0))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}

get_tcp_retransmition_segment(){
        curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name) (rate(node_netstat_Tcp_RetransSegs{node_name="'$my_nodename'"}[5s]) or irate(node_netstat_Tcp_RetransSegs{node_name="'$my_nodename'"}[5m]))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}
