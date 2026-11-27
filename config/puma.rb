max_threads = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
threads max_threads, max_threads
bind "tcp://#{ENV.fetch("BIND_HOST", "127.0.0.1")}:#{ENV.fetch("PORT", 3000)}"
