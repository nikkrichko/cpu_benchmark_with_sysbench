#!/bin/bash

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
curl -u admin:admin --location --request POST 'http://'$grafana_dns'/graph/api/datasources/proxy/1/api/v1/query_range' \
--header 'accept: application/json, text/plain, */*' \
--header 'x-grafana-org-id: 1' \
--header 'content-type: application/x-www-form-urlencoded' \
--data-urlencode 'query=avg by (node_name,mode) (clamp_max(((avg by (mode,node_name) ( (clamp_max(rate(node_cpu_seconds_total{node_name="'$my_nodename'",mode!="idle"}[5m]),1)) or (clamp_max(irate(node_cpu_seconds_total{node_name="'$my_nodename'",mode!="idle"}[5m]),1)) ))*100 or (avg_over_time(node_cpu_average{node_name="'$my_nodename'", mode!="total", mode!="idle"}[5m]) or avg_over_time(node_cpu_average{node_name="'$my_nodename'", mode!="total", mode!="idle"}[5m]))),100))' \
--data-urlencode 'end='$start_ts'' \
--data-urlencode 'start='$end_ts'' \
--data-urlencode 'step=10'
}


run_some_test(){
add_start_annotation $1 $2
($3)
add_finish_annotation $1 $2
get_cpu_info > $log_folder/$1_benchmark.json
}
