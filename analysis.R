


library(data.table)
library(rlist)
library(tictoc)
library(tidyverse)
library(future)
library(furrr)
library(parallel)
library(foreach)
library(doParallel)
library(tictoc)

options(digits.secs = 3)  
options(scipen = 999)


main_path <- paste(getwd(),"/logs", sep="")

path_to_cpu_info <- paste(dir_name,"/cpu_info.txt",sep="")


save_plot <- function(file_path_name,plot_to_save){
  if(!is.null(file_path_name)){
    fileName_to_save <- paste(file_path_name,".png",sep="")
    ggsave(fileName_to_save,plot_to_save,width = 16, height = 9, dpi = 350, units = "in", device='png')
    print(paste("plot successfully saved:",fileName_to_save))
  }
}

add_logo <- function(input_gg_plot,path_to_file){
  require(magick)
  require(cowplot)
  logo_img <- image_read(path_to_file)) 
  input_gg_plot <- ggdraw() + 
    draw_plot(input_gg_plot,x = 0, y = 0.025, width = 1, height = .97)+
    draw_image(logo_img,x = 0.8, y = 0.88, width = 0.15, height = 0.15)
  input_gg_plot
}

convert_ts_to_dt_par <- function(input_dt){
  ncores <-  detectCores(logical = FALSE)
  mac_cluster <- makeCluster(ncores)
  doParallel::registerDoParallel(mac_cluster)
  tic("do some parralel stuff")
  pack <- c("elasticsearchr","tidyverse","data.table","lubridate","tictoc")
  par_result <- foreach(i=seq_along(1:NROW(input_dt)), .packages=pack) %dopar% {
    temp_val <-  input_dt[i]$values %>% as.data.table() %>% 
      setnames(c("V1","V2"), c("timestamp", "value"))
    temp_val$id_core <- i
    temp_val$value <- as.numeric(temp_val$value)
    cbind(input_dt[i,!"values"],temp_val)
  }
  toc()
  stopCluster(mac_cluster)
  
  
  # tic("join data took:")
  result_dt <- rbindlist(par_result, use.names = TRUE, fill = TRUE)
  result_dt[,":="(timestamp=round(as.numeric(sub("\\.(.*)","", timestamp))/10)*10)]
  result_dt
}

cpu_info <- function(path_to_cpu_info){
  cpu_lines <- read_lines(path_to_cpu_info)
  cpu_lines <- cpu_lines[1:9]  %>% as.data.table()
  cpu_lines[, .:=sub("\t|\t\t", "", .)]
  cpu_lines[, c("title","value") := tstrsplit(., ":", fixed=TRUE)]
  cpu_lines[, title:=sub(" ", "_", title)]
  cpu_lines[, value:=sub(" ", "", value)]
  cpu_lines[,.(title,value)]
  cpu_dt <- data.table::transpose(cpu_lines,make.names = "title")[2]
  cpu_dt
}

path_to_cpu_tests <- paste(dir_name,"/CPU_1.log",sep="")

parse_cpu_test_info <- function(path_to_cpu_tests){
  cpu_log_lines <- read_lines(path_to_cpu_tests) %>% trimws(.)  %>% as.data.table()
  condition_list <- c("Number of threads","Prime numbers limit",
                      "events per second","total time",
                      "total time","total number of events","min","avg","max","percentile","sum",
                      "events (avg/stddev)","execution time (avg/stddev)")
  
  
  cpu_log_lines <- cpu_log_lines[Reduce(`|`, Map(`%like%`, list(.), condition_list))]
  cpu_log_lines[, c("title","value") := tstrsplit(., ":", fixed=TRUE)]
  cpu_log_lines[, title:=gsub(" ", "_", title, fixed=FALSE)]
  cpu_log_lines[, value:=sub(" ", "", value)]
  cpu_log_lines[,.(title,value)]
  cpu_log_lines[title %like% "events_per_second", ":="(title=paste("cpu_speed",title,sep="_"))]
  cpu_log_lines[title %like% "total_time", ":="(title=paste("general_statistic",title,sep="_"))]
  cpu_log_lines[title %like% "total_number_of_events", ":="(title=paste("general_statistic",title,sep="_"))]
  
  cpu_log_lines[title %like% "min", ":="(title=paste("latency_ms",title,sep="_"))]
  cpu_log_lines[title %like% "avg", ":="(title=paste("latency_ms",title,sep="_"))]
  cpu_log_lines[title %like% "max", ":="(title=paste("latency_ms",title,sep="_"))]
  cpu_log_lines[title %like% "percentile", ":="(title=paste("latency_ms",title,sep="_"))]
  cpu_log_lines[title %like% "sum", ":="(title=paste("latency_ms",title,sep="_"))]
  cpu_log_lines[title %like% "events_(avg/stddev)", ":="(title=paste("thread_fairness",title,sep="_"))]
  cpu_log_lines[title %like% "execution_time_(avg/stddev)", ":="(title=paste("thread_fairness",title,sep="_"))]
  
  cpu_dt <- data.table::transpose(cpu_log_lines,make.names = "title")[2]
  cpu_dt[, c("latency_ms_events_avg","latency_ms_events_stddev") := tstrsplit(`latency_ms_events_(avg/stddev)`, ":", fixed=TRUE)]
  cpu_dt[,":="(`latency_ms_events_(avg/stddev)`= NULL)]
  cpu_dt[,":="(latency_ms_events_avg=sub("\\/.*", "", latency_ms_events_avg), latency_ms_events_stddev=sub(".*\\/", "", latency_ms_events_stddev))]
  
  cpu_dt[, c("latency_ms_execution_time_avg","latency_ms_execution_time_stddev") := tstrsplit(`latency_ms_execution_time_(avg/stddev)`, ":", fixed=TRUE)]
  cpu_dt[,":="(`latency_ms_execution_time_(avg/stddev)`= NULL)]
  cpu_dt[,":="(latency_ms_execution_time_avg=sub("\\/.*", "", latency_ms_execution_time_avg), latency_ms_execution_time_stddev=sub(".*\\/", "", latency_ms_execution_time_stddev))]
  cpu_dt
}

get_cpu_dt_result <- function(path_list, input_test_type){
  temp_list <- list()
  for(item in seq_along(path_list)){
    path_to_log_file <- path_to_cpu_tests <- paste(dir_name,path_list[item],sep="/")
    temp_cpu_test_dt <- parse_cpu_test_info(path_to_log_file) %>% 
      cbind(cpu_info_dt)
    temp_cpu_test_dt$full_path <- path_to_log_file
    temp_cpu_test_dt$file_name <- path_list[item]
    temp_list[[item]] <- temp_cpu_test_dt
  }
  cpu_dt_result <- rbindlist(temp_list)
  cpu_dt_result$test_type <- input_test_type
  cpu_dt_result
}


parse_db_log_file <- function(path_db_test_log){
  db_log_lines <- read_lines(path_db_test_log) %>% trimws(.)  %>% as.data.table()
  condition_list <- c("Number of threads","Prime numbers limit",
                      "events per second","total time",
                      "total time","total number of events","min","avg","max","percentile","sum",
                      "events (avg/stddev)","execution time (avg/stddev)", "read:","write","other", "total", "transactions","queries:","ignored errors","reconnects" )
  
  
  db_log_lines <- db_log_lines[Reduce(`|`, Map(`%like%`, list(.), condition_list))]
  db_log_lines[, c("title","value") := tstrsplit(., ":", fixed=TRUE)]
  db_log_lines[, title:=gsub(" ", "_", title, fixed=FALSE)]
  db_log_lines[, value:=sub(" ", "", value)]
  db_log_lines[,.(title,value)]
  db_log_lines[title %like% "events_per_second", ":="(title=paste("cpu_speed",title,sep="_"))]
  db_log_lines[title %like% "total_time", ":="(title=paste("general_statistic",title,sep="_"))]
  db_log_lines[title %like% "total_number_of_events", ":="(title=paste("general_statistic",title,sep="_"))]
  
  db_log_lines[title %like% "min", ":="(title=paste("latency_ms",title,sep="_"))]
  db_log_lines[title %like% "avg", ":="(title=paste("latency_ms",title,sep="_"))]
  db_log_lines[title %like% "max", ":="(title=paste("latency_ms",title,sep="_"))]
  db_log_lines[title %like% "percentile", ":="(title=paste("latency_ms",title,sep="_"))]
  db_log_lines[title %like% "sum", ":="(title=paste("latency_ms",title,sep="_"))]
  
  
  db_log_lines[title %like% "read:", ":="(title=paste("query_exec",title,sep="_"))]
  db_log_lines[title %like% "write", ":="(title=paste("query_exec",title,sep="_"))]
  db_log_lines[title %like% "other", ":="(title=paste("query_exec",title,sep="_"))]
  db_log_lines[title %like% "total", ":="(title=paste("query_exec",title,sep="_"))]
  db_log_lines[title %like% "transactions", ":="(title=paste("sql_stat",title,sep="_"))]
  
  

  
  
  db_log_lines[title %like% "queries:", ":="(title=paste("sql_stat",title,sep="_"))]
  db_log_lines[title %like% "ignored errors", ":="(title=paste("sql_stat",title,sep="_"))]
  db_log_lines[title %like% "reconnects", ":="(title=paste("sql_stat",title,sep="_"))]
  

  
  db_log_lines[title %like% "events_(avg/stddev)", ":="(title=paste("thread_fairness",title,sep="_"))]
  db_log_lines[title %like% "execution_time_(avg/stddev)", ":="(title=paste("thread_fairness",title,sep="_"))]
  
  db_dt <- data.table::transpose(db_log_lines,make.names = "title")[2]
  db_dt[, c("latency_ms_events_avg","latency_ms_events_stddev") := tstrsplit(`latency_ms_events_(avg/stddev)`, ":", fixed=TRUE)]
  db_dt[,":="(`latency_ms_events_(avg/stddev)`= NULL)]
  db_dt[,":="(latency_ms_events_avg=sub("\\/.*", "", latency_ms_events_avg), latency_ms_events_stddev=sub(".*\\/", "", latency_ms_events_stddev))]
  
  db_dt[, c("latency_ms_execution_time_avg","latency_ms_execution_time_stddev") := tstrsplit(`latency_ms_execution_time_(avg/stddev)`, ":", fixed=TRUE)]
  db_dt[,":="(`latency_ms_execution_time_(avg/stddev)`= NULL)]
  db_dt[,":="(latency_ms_execution_time_avg=sub("\\/.*", "", latency_ms_execution_time_avg), latency_ms_execution_time_stddev=sub(".*\\/", "", latency_ms_execution_time_stddev))]
  db_dt[, c("sql_stat_transactions_total","sql_stat_transactions_per_sec") := tstrsplit(sql_stat_transactions, "(", fixed=TRUE)]
  db_dt[, c("queries_total","queries_per_sec") := tstrsplit(queries, "(", fixed=TRUE)]
  db_dt[, sql_stat_transactions_per_sec:=sub(" per sec.)", "", sql_stat_transactions_per_sec)]
  db_dt[, queries_per_sec:=sub(" per sec.)", "", queries_per_sec)]
  
  db_dt
}

get_db_dt_result <- function(path_list, input_test_type){
  temp_list <- list()
  for(item in seq_along(path_list)){
    path_to_log_file <- paste(dir_name,path_list[item],sep="/")
    temp_db_test_dt <- parse_db_log_file(path_to_log_file) %>% 
      cbind(cpu_info_dt)
    temp_db_test_dt$full_path <- path_to_log_file
    temp_db_test_dt$file_name <- path_list[item]
    temp_list[[item]] <- temp_db_test_dt
  }
  db_dt_result <- rbindlist(temp_list)
  db_dt_result$test_type <- input_test_type
  db_dt_result
}


dir_list <- list.dirs(path = main_path, full.names = TRUE, recursive = TRUE)
dir_list <- dir_list[dir_list != main_path]


temp_big_list <- list()
for (dir_name in dir_list) {

  tic(paste("parsing data for ",dir_name))
  print(dir_name)

  files <- dir(dir_name)

  CPU_log_files <- files[files %like% "CPU"]
  CPU_locks_test_files <- CPU_log_files[CPU_log_files %like% "CPU_lock"]
  CPU_simple_test_files <- CPU_log_files[!(CPU_log_files %like% "CPU_lock")]
  DB_test_log_files <- files[!(files %like% "CPU|cpu")]
  DB_test_read_files <- DB_test_log_files[(DB_test_log_files %like% "read_only")]
  DB_test_write_files <- DB_test_log_files[(DB_test_log_files %like% "write_only")]
  DB_test_combined_files <- DB_test_log_files[(DB_test_log_files %like% "read_write")]
  
  
  cpu_info_path <- paste(dir_name,"/cpu_info.txt",sep="")
  cpu_info_dt <- cpu_info(cpu_info_path)
  
  
  simple_CPU_test_dt<- get_cpu_dt_result(CPU_simple_test_files,"CPU_SIMPLE_TEST")
  lock_CPU_test <- get_cpu_dt_result(CPU_locks_test_files,"CPU_LOCK_TEST")
  cpu_test_dt <- rbindlist(list(lock_CPU_test,simple_CPU_test_dt), fill = TRUE)
  
  db_read_result <- get_db_dt_result(DB_test_read_files, "read")
  db_write_result <- get_db_dt_result(DB_test_read_files, "write")
  db_combined_result <- get_db_dt_result(DB_test_read_files, "read_write")
  db_test_dt <- rbindlist(list(db_read_result,db_write_result,db_combined_result), fill = TRUE)
  print(">>> parsing end <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
  toc()
  
  big_path_resullt_dt <- rbindlist(list(db_test_dt,cpu_test_dt), fill = TRUE)
  
  temp_big_list <- list.append(temp_big_list,big_path_resullt_dt)
}


result_table <- rbindlist(temp_big_list, fill = TRUE)
result_table

result_table[,":="(cpu_type=ifelse(is.na(vendor_id),"Graviton2","Intel"))]


saveRDS(result_table, "result_dt.RDS")


### Analysis ##########
library(ggplot2)
library(DataExplorer)
library(data.table)

cpu_dt <- readRDS("result_dt.RDS")


### CPU review ################
cpu_test_dt <- cpu_dt[test_type %like% "CPU"]

cpu_test_dt[is.na(cpu_speed_events_per_second)]$cpu_speed_events_per_second <- "0"

cpu_test_dt <- cpu_test_dt[,.(test_type,Number_of_threads,cpu_type,latency_ms_min,latency_ms_avg,latency_ms_max, latency_ms_95th_percentile, latency_ms_sum,latency_ms_events_avg,latency_ms_events_stddev, latency_ms_execution_time_avg,latency_ms_execution_time_stddev, general_statistic_total_number_of_events,cpu_speed_events_per_second)]


cpu_melted_dt <- melt(cpu_test_dt,id.vars=c("test_type","Number_of_threads","cpu_type"),
     measure.vars = names(cpu_test_dt)[4:14],
     value.name = "value") 

cpu_melted_dt$value <- as.numeric(trimws(cpu_melted_dt$value))

sorted_labels <- paste(sort((cpu_melted_dt$Number_of_threads)))
sorted_labels <- c("1","2","4","8","16","32","64")
cpu_melted_dt$Number_of_threads <- factor(cpu_melted_dt$Number_of_threads, levels = sorted_labels)



CPU_latency <- cpu_melted_dt[variable %in% c("latency_ms_min", "latency_ms_avg","latency_ms_max", "latency_ms_95th_percentile")]

CPU_latency_big <- cpu_melted_dt[variable %in% c( "latency_ms_events_avg","general_statistic_total_number_of_events", "cpu_speed_events_per_second")]


CPU_latencies_plot <- ggplot(CPU_latency,aes(x=as.factor(variable),
                         y=value,
                         fill=cpu_type)) + 
  geom_bar(stat = "identity", position ="dodge" ) + 
  facet_grid(test_type ~ Number_of_threads) + 
  scale_fill_manual(values=c( "#E69F00", "#56B4E9")) + 
  labs(title = "CPU comparison latencies",
       subtitle = "less is better",
       fill = "CPU type")+
  xlab("sysbench chahacteristic")+
  ylab("ms")+
  theme(axis.text.x = element_text(angle = 30, 
                                   vjust = 0.9, 
                                   hjust=1)) + 
  scale_y_sqrt()


CPU_other_plot <- ggplot(CPU_latency_big,aes(x=as.factor(variable),
                       y=value,
                       fill=cpu_type)) + 
  geom_bar(stat = "identity", position ="dodge" ) + 
  facet_grid(test_type ~ Number_of_threads, scales = "free_y") + 
  scale_fill_manual(values=c( "#E69F00", "#56B4E9")) + 
  labs(title = "CPU comparison",
       subtitle = "more is better",
       fill = "CPU type")+
  xlab("sysbench chahacteristic")+
  ylab("")+
  theme(axis.text.x = element_text(angle = 30, 
                                   vjust = 0.9, 
                                   hjust=1)) + 
  scale_y_sqrt()   


### DB review #################

DB_CPU_test_dt <- cpu_dt[!(test_type %like% "CPU")]



DB_test_dt <- DB_CPU_test_dt[,.(test_type,Number_of_threads,cpu_type,latency_ms_execution_time_avg,read, query_exec_write, query_exec_other, query_exec_total, sql_stat_transactions_total, sql_stat_transactions_per_sec, queries_total, queries_per_sec,  latency_ms_min,latency_ms_avg,latency_ms_max, latency_ms_95th_percentile, latency_ms_sum,latency_ms_events_avg,latency_ms_events_stddev,latency_ms_execution_time_stddev,query_exec_general_statistic_total_time)]


DB_test_dt <- DB_test_dt[, lapply(.SD, trimws), by=.(test_type,cpu_type)]
DB_test_dt <- DB_test_dt[, lapply(.SD, as.numeric), by=.(test_type,cpu_type)]
DB_test_dt[,":="(latency_ms_execution_time_avg =round(latency_ms_execution_time_avg))]




DB_test_dt_melted <- melt(DB_test_dt,id.vars=c("test_type","Number_of_threads","cpu_type"),
                          measure.vars = names(DB_test_dt)[4:18],
                          value.name = "value") 



sorted_labels <- paste(sort((DB_test_dt_melted$Number_of_threads)))
sorted_labels <- c("1","2","4","8","16","32","64")
DB_test_dt_melted$Number_of_threads <- factor(DB_test_dt_melted$Number_of_threads, levels = sorted_labels)



DB_operation<- DB_test_dt_melted[variable %in% c("read", "query_exec_other", "query_exec_total")]

DB_transactions <- DB_test_dt_melted[variable %in% c("sql_stat_transactions_total", "sql_stat_transactions_per_sec", "queries_total", "queries_per_sec")]

DB_latency <- DB_test_dt_melted[variable %in% c("latency_ms_min", "latency_ms_avg","latency_ms_max", "latency_ms_95th_percentile")]

DB_latency_big <- DB_test_dt_melted[variable %in% c( "latency_ms_events_avg","general_statistic_total_number_of_events", "cpu_speed_events_per_second")]




DB_operations <- ggplot(DB_operation,aes(x=as.factor(variable),
                    y=value,
                    fill=cpu_type)) + 
  geom_boxplot() +
  facet_grid(test_type ~ Number_of_threads, scales="free_y") + 
  scale_fill_manual(values=c( "#E69F00", "#56B4E9")) + 
  labs(title = "CPU comparison for sql operation\namount of sql operation",
       subtitle = "more is better",
       fill = "CPU type")+
  xlab("sysbench chahacteristic")+
  ylab("amount")+
  theme(axis.text.x = element_text(angle = 30, 
                                   vjust = 0.9, 
                                   hjust=1)) + 
  scale_y_log10()


DB_transaction_plot <- ggplot(DB_transactions,aes(x=as.factor(variable),
                        y=value,
                        fill=cpu_type)) + 
  geom_boxplot() +
  facet_grid(test_type ~ Number_of_threads, scales="free_y") + 
  scale_fill_manual(values=c( "#E69F00", "#56B4E9")) + 
  labs(title = "CPU comparison for sql operation\ntransactions",
       subtitle = "more is better",
       fill = "CPU type")+
  xlab("sysbench chahacteristic")+
  ylab("amount")+
  theme(axis.text.x = element_text(angle = 30, 
                                   vjust = 0.9, 
                                   hjust=1)) + 
  scale_y_log10()



DB_latencies_plot <- ggplot(DB_latency,aes(x=as.factor(variable),
                                             y=value,
                                             fill=cpu_type)) + 
  geom_boxplot() +
  facet_grid(test_type ~ Number_of_threads) + 
  scale_fill_manual(values=c( "#E69F00", "#56B4E9")) + 
  labs(title = "CPU comparison latencies\nduring DB tests",
       subtitle = "less is better",
       fill = "CPU type")+
  xlab("sysbench chahacteristic")+
  ylab("ms")+
  theme(axis.text.x = element_text(angle = 30, 
                                   vjust = 0.9, 
                                   hjust=1)) + 
  scale_y_sqrt()


DB_other_plot <- ggplot(DB_latency_big,aes(x=as.factor(variable),
                                             y=value,
                                             fill=cpu_type)) + 
  geom_boxplot() +
  facet_grid(test_type ~ Number_of_threads, scales = "free_y") + 
  scale_fill_manual(values=c( "#E69F00", "#56B4E9")) + 
  labs(title = "CPU comparison\nduring DB tests",
       subtitle = "more is better",
       fill = "CPU type")+
  xlab("sysbench chahacteristic")+
  ylab("")+
  theme(axis.text.x = element_text(angle = 30, 
                                   vjust = 0.9, 
                                   hjust=1)) + 
  scale_y_sqrt()   





### results ##############
CPU_latencies_plot
CPU_other_plot


DB_operations
DB_transaction_plot
DB_latencies_plot
DB_other_plot





###############

ggplot(CPU_latency_big,aes(x=as.factor(variable),
                           y=value,
                           fill=cpu_type)) + 
  geom_boxplot() +
  facet_grid(test_type ~ Number_of_threads, scales="free_y") + 
  scale_fill_manual(values=c( "#E69F00", "#56B4E9")) + 
  labs(title = "CPU comparison for sql operation\ntransactions",
       subtitle = "more is better",
       fill = "CPU type")+
  xlab("sysbench chahacteristic")+
  ylab("amount")+
  theme(axis.text.x = element_text(angle = 30, 
                                   vjust = 0.9, 
                                   hjust=1)) + 
  scale_y_log10()

template_gplot<- function(dt){
  
  min_datetime <- min(dt$hms)
  max_datetime <- max(dt$hms)
  time_breaks <- seq(min_datetime,max_datetime,10) %>% unique() %>% .[matches("(:00:0|:30:0)", vars=.)] %>% sort()
  
  
  min_y_break <- min(pods_ps$N)-20
  if(min_y_break < 0) {min_y_break <- 0}
  max_y_break <- max(pods_ps$N)+50
  generated_y_breaks <- seq(min_y_break,max_y_break,10)
  
  
  title_generated <- ""
  subtitle_generated <- paste("for period: ",min_datetime, " - ", max_datetime,"\n", sep="" )
  caption_generated <- "Information collected from grafana web api "
  
  
  result_plot <- ggplot(dt, aes(x=hms, y=N,color=can_use_spot)) + 
    geom_line() + 
    geom_point(size=.8) +
    scale_x_datetime(breaks=time_breaks) + 
    scale_y_continuous(breaks = generated_y_breaks,limits = c(0, max_y_break)) +
    labs(x="",
         y="",
         title=title_generated,
         subtitle = subtitle_generated,
         caption = caption_generated,
         color = "") + 
    theme(axis.text.x = element_text(angle = 45, vjust = 0.9, hjust=1),
          axis.text.y = element_text(angle = -45, vjust = 0.9, hjust=1, size=6))
  result_plot
}
