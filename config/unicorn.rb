# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/home/aff-backend"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/home/aff-backend/pids/unicorn.pid"

# Path to logs
# stderr_path "/path/to/log/unicorn.log"
# stdout_path "/path/to/log/unicorn.log"
stderr_path "/home/aff-backend/log/unicorn.log"
stdout_path "/home/aff-backend/log/unicorn.log"

# Unicorn socket
listen "/tmp/unicorn.aff-backend.sock"
listen "/tmp/unicorn.aff-backend.sock"

# Number of processes
# worker_processes 4
worker_processes 4

# Time-out
timeout 30
