docker run -p 8083:8083 --rm -u root \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $(which docker):/usr/bin/docker \
-v $(which com.docker.cli):/usr/bin/com.docker.cli \
--add-host=host.docker.internal:$(hostname -I) \
ppm-builder:latest