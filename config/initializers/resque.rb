require 'resque-scheduler'
require 'resque/scheduler/server'
Resque.redis = 'localhost:6379'
Resque::Scheduler.dynamic = true
Resque.schedule = YAML.load_file('config/resque_schedule.yml')
