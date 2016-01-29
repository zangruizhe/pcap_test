// for thread sleep time
#include <chrono>
#include <thread>

// >>>>>>>>>>>>>>>>g3log set begin>>>>>>>>>>>>>>>>>>>>>>

#include "reference/library/g3log/g3log.hpp"
#include "reference/library/g3log/logworker.hpp"
#include "reference/library/gflags/gflags.h"

DEFINE_int32(v, 10, "VLOG level");

int main(int argc, char** argv) {

    google::ParseCommandLineFlags(&argc, &argv, true);
    const std::string path_to_log_file = "./";
    g3::g_use_log_buffer = false;
    g3::g_print_log_to_screen = true;
    g3::g_log_v = FLAGS_v;

    auto worker = g3::LogWorker::createLogWorker();
    auto handle = worker->addDefaultLogger(argv[0], path_to_log_file);
    g3::initializeLogging(worker.get());

// >>>>>>>>>>>>>>>>g3log set end>>>>>>>>>>>>>>>>>>>>>>
//

    LOGF(INFO, "Hi log %d", 123);
    LOG(INFO) << "Test SLOG INFO";
    LOG(DEBUG) << "Test SLOG DEBUG";
    VLOG(5) << "VLOG(5)";


    while (true) {
      std::this_thread::sleep_for (std::chrono::seconds(10));
      LOG(INFO) << "main heart beat.";
    }

}

