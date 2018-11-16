web: bundle exec rails s
worker: PIDFILE=./resque.pid BACKGROUND=yes QUEUE="*" RAILS_ENV=production  rake resque:work >>  resque.log &

