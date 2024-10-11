docker run -d \
  --name portainer \
  --restart unless-stopped \
  -p 9000:9000 \
  -v /other/Configs/portainer:/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  portainer/portainer-ce:latest