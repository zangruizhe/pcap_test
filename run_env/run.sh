#!/bin/sh
ulimit -c unlimited
#ulimit -u unlimited

base_dir="$(cd "$(dirname "$0")";pwd)"
bin_name="pcap_test"
bin_path="${base_dir}/${bin_name}"

$(cd "${base_dir}")

export LD_LIBRARY_PATH=${base_dir}:~/shared_lib:$LD_LIBRARY_PATH


femas_market_data_mac_address="00:00:00:00:00:00"

run_cmd="nohup ${bin_path} \
1>>stdout.log 2>&1 &"

# --femas_market_data_mac_address=${femas_market_data_mac_address} \

pid=0

clean()
{
  $(rm -rf .*core .*log)
}

gflag()
{
  ${bin_path} --help
}
start()
{
  getbinpid;
  if [ $pid -gt 0 ]; then
    echo "\"${bin_path}\" has been running. pid: $pid"
    return
  fi
  eval $run_cmd
  getbinpid;
  if [ $pid -gt 0 ]; then
    echo "succeeded to start \"${bin_path}\". pid: $pid"
    # createLogLink;
    return 0
  else
    echo "failed to start \"${bin_path}\""
    return 1
  fi
}
stop()
{
  getbinpid;
  if [ $pid -eq 0 ]; then
    echo "\"${bin_path}\" has not been running"
    return
  fi
  # kill -9 $pid
  kill  $pid
  getbinpid;
  if [ $pid -eq 0 ]; then
    echo "succeeded to stop \"${bin_path}\""
    return 0
  else
    echo "failed to stop \"${bin_path}\""
    return 1
  fi
}
restart()
{
  stop;
  start;
}
check()
{
  getbinpid;
  if [ $pid -gt 0 ]; then
    echo "\"${bin_path}\" is running, pid: $pid"
    return 1
  else
    echo "\"${bin_path}\" is not running"
    return 0
  fi
}

getbinpid()
{
  pid=0
  for local_pid in `/sbin/pidof ${bin_name}`
  do
    cmdline=`cat /proc/$local_pid/cmdline`
    echo $cmdline | grep -q "${bin_path}"
    result=$?
    if [ $result -eq 0 ]; then
      pid=$local_pid
      return 0
    fi
  done
  return 1
}
createLogLink()
{
  log_name=$(ls -rth | grep .*g3log.*.log | tail -n1)
  # $(ln -sf ${log_name} ${bin_name}.log)
  $(ln -sf ${log_name} log)
}
monitor()
{
  getbinpid;
  if [ $pid -gt 0 ]; then
    return 0
  else
    start;
    ret=$?
    return $ret
  fi
}

if [ $# -ne 1 ]; then
  echo "Usage: $(basename "$0") start/stop/restart/monitor/check"
  exit -1
fi
case "$1" in
  "start")
    start;
    ;;
  "stop")
    stop;
    ;;
  "restart")
    restart;
    ;;
  "check")
    check;
    ;;
  "gflag")
    gflag
    ;;
  "monitor")
    monitor;
    ;;
  "clean")
    clean;
    ;;
  *)
    echo "Usage: $(basename "$0") start/stop/restart/monitor/check/gflag/clean"
    exit -1
esac

