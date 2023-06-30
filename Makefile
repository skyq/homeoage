name = homepage_11ty
dist = /var/www/docker/skyq.ru/11ty/dist/
build:
	sudo docker build -t $(name) ./
run:
	sudo docker run -d -p 80:80 -v $(dist):/usr/share/nginx/html/:ro --name $(name) $(name) 
rm:
	sudo docker rm $(name)
rmi:
	sudo docker rmi $(name)
stop:
	sudo docker stop $(name)
start:
	sudo docker start $(name)
logs:
	sudo docker logs $(name)
ps:
	sudo docker ps -a
im:
	sudo docker images -a
bash:
	sudo docker exec -it $(name) /bin/bash
test:
	curl localhost:80
