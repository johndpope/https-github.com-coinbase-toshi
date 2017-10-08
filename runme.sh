echo "start redis server locally"
redis-server --port 6379 --protected-mode no &
#docker-compose build
#docker-compose start db 
#docker-compose run web bundle exec rake db:create
#docker-compose run -e TOSHI_ENV=production web bundle exec bundle install  
#docker-compose run -e TOSHI_ENV=production web bundle exec rake db:create db:migrate 
#docker-compose build  # run this before `up` to run the latest code
docker-compose up 
#open http://0.0.0.0:5000 
