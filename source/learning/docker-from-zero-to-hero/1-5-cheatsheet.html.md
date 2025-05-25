---
layout: learning
course_title: "Docker: From Zero to Hero"
module_title: "Module 1: Introduction to Docker and Installation"
section_title: "Checklist"
---

Here’s a handy reference of the most important Docker commands you’ll use daily to build, run, and manage containers efficiently.

### **Image Management**

| Command | Description | Example |
| --- | --- | --- |
| `docker pull <image>` | Download an image from a registry (e.g., Docker Hub) | `docker pull nginx` |
| `docker images` | List all downloaded images | `docker images` |
| `docker rmi <image>` | Remove one or more images | `docker rmi nginx:latest` |

### **Container Lifecycle**

| Command | Description | Example |
| --- | --- | --- |
| `docker run <image>` | Create and start a container from an image | `docker run nginx` |
| `docker run -d -p 8080:80 nginx` | Run container detached, map port 8080 to 80 | `docker run -d -p 8080:80 nginx` |
| `docker ps` | List running containers | `docker ps` |
| `docker ps -a` | List all containers, including stopped | `docker ps -a` |
| `docker stop <container_id>` | Stop a running container | `docker stop 4c01db0b339c` |
| `docker start <container_id>` | Start a stopped container | `docker start 4c01db0b339c` |
| `docker restart <container_id>` | Restart a running container | `docker restart 4c01db0b339c` |
| `docker rm <container_id>` | Remove a stopped container | `docker rm 4c01db0b339c` |

### **Container Interaction**

| Command | Description | Example |
| --- | --- | --- |
| `docker logs <container_id>` | View logs from a container | `docker logs 4c01db0b339c` |
| `docker exec -it <container_id> sh` | Open an interactive shell inside a running container | `docker exec -it 4c01db0b339c sh` |
| `docker inspect <container_id>` | Get detailed JSON info about a container | `docker inspect 4c01db0b339c` |

### **Other Useful Commands**

| Command | Description | Example |
| --- | --- | --- |
| `docker version` | Show Docker client and server version | `docker version` |
| `docker info` | Show system-wide information about Docker | `docker info` |
| `docker network ls` | List Docker networks | `docker network ls` |
| `docker volume ls` | List Docker volumes | `docker volume ls` |

### Tips:

- To avoid typing full container IDs, you can use the first few unique characters.
- Use `docker ps -a` often to check for containers that you might want to clean up.
- When mapping ports (`p` flag), the format is `host_port:container_port`.
- Detached mode (`d`) runs containers in the background.
- Use `docker exec` to troubleshoot running containers without stopping them.
