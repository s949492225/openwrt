docker run -d \
  --name portainer \
  --network bridge \
  -p 9000:9000 \
  -v /other/Configs/portainer:/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart unless-stopped \
  6053537/portainer-ce:latest
