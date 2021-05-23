#!/bin/bash


while getopts d:u:p: opts; do
   case ${opts} in
      ### add variables from console
      d) mysql_db=${OPTARG};;
      u) mysql_user=${OPTARG};;
      p) root_pass=${OPTARG};;
   esac
done
### define default variables in case itweren't setup with console parameteres
if [[ -z $mysql_db ]]; then mysql_db="sbtest";fi
if [[ -z $mysql_user ]]; then echo "MYSQL error: NO USER NAME PROVIDED" & exit 1;fi
if [[ -z $root_pass ]]; then echo "MYSQL error: NO PASSWORD PROVIDED" & exit 1;fi

echo "DB: " $mysql_db
echo "mysql user: " $mysql_user
echo "mysql pass: " $root_pass




start_time=`date +%s`

if [[ ! -e logs ]]; then
    mkdir logs
fi

cat /proc/cpuinfo >> logs/cpu_info.txt


start_time=`date +%s`
for threads in 1 2 8 16 32 64
do
    echo "CPU benchmark tests started"
    echo "CPU_test started: threads : " $threads

    sudo sysbench cpu --threads=$threads --cpu-max-prime=20000 run > logs/CPU_$threads.log

    echo "test teardown..."
    sleep 3


    echo "CPU_test_with_locks started: threads : " $threads

    sudo sysbench threads --num-threads=$threads --thread-yields=1000 --thread-locks=8 run > logs/CPU_locks_$threads.log

    echo "test teardown..."
    sleep 3
done

end_time=`date +%s`
cpu_runtime=$((end_time-start_time))

echo "CPU test took:" $cpu_runtime
echo ">>>> CPU test ENDED <<<<"
echo "=========================================================================================="
echo "=========================================================================================="
echo ""
echo ""
echo ""



echo ">>>> DB test STARTED <<<<"

start_time=`date +%s`

for iter_time in 5 10 30 60 300
do
    for iter_threads in 1 2 4 8 16 32 
    do
        for iter_size in 100000 2000000 5000000 10000000
        do
		echo preparation started
            sudo sysbench oltp_read_only --threads=10 --mysql-user=$mysql_user --mysql-password=$root_pass --table-size=$iter_size --tables=10 --db-driver=mysql --mysql-db=$mysql_db prepare

            for test_type in oltp_read_only oltp_write_only oltp_read_write
            do
                test_name="db_test_"$test_type"_time_"$iter_time"_threads_"$iter_threads"_iter_size_"$iter_size".log"
                echo "RUN DB test" $test_name
                
                sudo sysbench $test_type --time=$iter_time --threads=$iter_threads --table-size=$iter_size --mysql-user=$mysql_user --mysql-password=$root_pass --db-driver=mysql --mysql-db=$mysql_db run > logs/$test_name
                
                echo "test teardown..."
                sleep 3
            done
        done
    done
done




end_time=`date +%s`
DB_runtime=$((end_time-start_time))
echo "DB test took:" $DB_runtime
echo ">>>> DB test ENDED <<<<"


