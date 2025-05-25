---
layout: learning
course_title: "Docker: From Zero to Hero"
module_title: "Module 1: Introduction to Docker and Installation"
section_title: "Theory"
---

## Goal of the Module

By the end of this module, students will:

- Understand what Docker is and how it works.
- Be able to install Docker on their system.
- Grasp key concepts such as containers, images, and registries.
- Be ready to build and run their first containerized application.

This foundational knowledge will support the first **practical project**: *Containerizing and running a simple web application using Docker*, suitable for publishing to GitHub or Docker Hub.

## What is Docker?

**Docker** is an open-source platform that simplifies how developers build, ship, and run applications. It uses a technology called **containerization**, which packages applications and all their dependencies into a single, portable unit called a **container**.

This means that your application can run **anywhere** — on your laptop, in the cloud, on a production server — without worrying about environment mismatches or missing libraries.

### What is a Container?

A container is a **lightweight, standalone, executable** software package that includes:

- The application code
- All required dependencies (e.g., Python, Node.js, Ruby)
- System tools and libraries (e.g., OpenSSL, libc)
- Configuration files and runtime

Unlike virtual machines, containers **share the host system’s kernel** and do **not** require a full operating system per instance — making them **much faster and more efficient**.

### Example Analogy

Think of containers like **shipping containers** in logistics. Regardless of what's inside (cars, clothes, electronics), every container has the same standard size and can be loaded on ships, trucks, or trains. Similarly, Docker containers ensure your software runs the same no matter the environment.

### Why Docker? – Key Benefits

- **Environment Consistency**
    Your app runs the same in development, staging, and production – no more “it works on my machine!”
<br>
- **Fast Deployment**
    Containers start in seconds, unlike full virtual machines that can take minutes.
<br>
- **Lightweight and Efficient**
    No need for full guest operating systems → containers are small and use fewer resources.
<br>
- **Portability Across Platforms**
    Run the same container image on Linux, macOS, Windows, or in the cloud.
<br>
- **Isolation and Security**
    Applications are isolated from each other and from the host, reducing conflicts and attack surface.
<br>
- **Microservices Ready**
    Ideal for breaking applications into smaller, composable services that can scale independently.

### Containers vs Virtual Machines (VMs)

| Feature | Containers | Virtual Machines |
| --- | --- | --- |
| Startup Time | Seconds | Minutes |
| Resource Usage | Low | High (entire OS) |
| Isolation Level | Process-level isolation | Full OS isolation |
| Portability | High | Moderate (OS-specific) |
| Use Case | Microservices, CI/CD | Full OS environments |

### What Can You Do with Docker?

- Develop and test applications locally in isolated environments
- Run legacy software without polluting your host system
- Automate CI/CD pipelines
- Deploy microservices at scale
- Create reproducible development environments for teams

## Virtual Machines vs Containers

Before Docker and containerization became widespread, the most common way to isolate applications was through **virtual machines (VMs)**. Both VMs and containers are used to create isolated environments for applications, but they differ significantly in how they achieve that isolation.

### Virtual Machines: How They Work

A **virtual machine** emulates an entire physical computer, including:

- Hardware (CPU, memory, disk)
- A guest operating system (Windows, Linux, etc.)
- System libraries and your application

VMs run on top of a **hypervisor** like VMware, VirtualBox, or KVM, which manages multiple guest OSes on a single physical machine.

### Containers: A More Efficient Approach

Docker containers take a different approach. Instead of emulating full machines, containers:

- Share the **host OS kernel**
- Use Linux features like **namespaces** (for isolation) and **cgroups** (for resource control)
- Package only the **application and its dependencies**

This makes them **much faster, lighter, and easier to manage** than VMs.

### Key Differences – Detailed Comparison

| Feature | **Virtual Machines (VMs)** | **Docker Containers** |
| --- | --- | --- |
| **Startup Time** | Minutes (boot full OS) | Seconds (start process) |
| **Guest OS** | Required per VM | Not needed (shared kernel) |
| **Image Size** | Large (GBs) | Small (MBs) |
| **Performance** | Overhead from hypervisor and guest OS | Near-native speed |
| **Isolation** | Strong – full system isolation | Process-level (less overhead) |
| **Security Surface** | Larger (full OS, attack surface) | Smaller but depends on host kernel security |
| **Portability** | Limited by hypervisor or OS | High – run anywhere Docker is supported |
| **Management** | Complex – multiple OSes to update | Simple – containers run on same OS |

### Technical Insights

- **Namespaces** isolate containers' process trees, file systems, users, and networks.
- **Control groups (cgroups)** limit resource usage (CPU, memory, etc.) for containers.
- Containers run as regular processes on the host OS and don’t need a separate kernel.

### Historical Context

- In the early 2000s, virtualization solved the problem of poor hardware utilization.
- By the 2010s, applications needed **faster deployment, more scalability**, and **lighter** environments → Docker emerged (2013) based on **LXC** and improved UX.

### When to Use What?

| Use Case | Better Fit |
| --- | --- |
| Running multiple OS types (e.g., Windows + Linux) | Virtual Machines |
| Strong multi-tenant security (full isolation) | Virtual Machines |
| Lightweight, fast deployment | Docker |
| CI/CD pipelines or dev environments | Docker |
| Legacy apps with OS dependencies | VMs (initially) or Docker with care |

### Conclusion

Both VMs and containers serve different purposes. Containers don’t replace VMs — they complement them. In modern infrastructures, you often see **containers running inside virtual machines** for the best of both worlds: **security** from VMs and **agility** from containers.

## Key Concepts

Understanding these core concepts is essential before working with Docker in real-world scenarios. These elements form the foundation of Docker’s architecture.

### **Image** – The Application Blueprint

A **Docker image** is a **read-only, immutable** file that serves as a **blueprint** for a container. It contains:

- Your application code
- System libraries and dependencies
- Configuration files
- A base OS layer (e.g., Alpine, Debian)

Images are **built in layers**. Each command in a `Dockerfile` (like `RUN`, `COPY`, `ADD`) creates a new image layer, which makes them efficient to reuse and share.

> Analogy: Think of an image like a cake recipe. It doesn’t do anything by itself, but it tells Docker how to build a working app (container).

**Example**:

```bash
docker pull nginx
```

This downloads the official `nginx` image from Docker Hub.

### **Container** – The Running Application

A **container** is a **runtime instance** of an image. When you start a container from an image:

- Docker unpacks the image layers
- It creates a new **writable layer on top**
- It starts the specified application process inside an isolated environment

> Analogy: If an image is a recipe, a container is a cake made using that recipe. You can make multiple cakes (containers) from the same recipe (image).

**Example**:

```bash
docker run -d -p 80:80 nginx
```

This runs a container from the `nginx` image in the background (`-d`), exposing port 80.

Containers are **ephemeral by default** – when stopped, changes are lost unless you use **volumes** (see below).

### **Dockerfile** – Image Build Instructions

A **Dockerfile** is a **plain text file** that contains step-by-step instructions for building a Docker image. It allows you to automate the setup of:

- Base operating system
- Required packages and dependencies
- Application files and configs
- Startup commands

Typical instructions include: `FROM`, `COPY`, `RUN`, `CMD`, `EXPOSE`.

**Example Dockerfile**:

```
FROM python:3.11
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "main.py"]
```

> Once you have a Dockerfile, you can build the image with:

```bash
docker build -t my-python-app .
```

### **Docker Engine** – The Core Component

The **Docker Engine** is the software that makes Docker work. It consists of three main components:

- **Docker Daemon (`dockerd`)**
    - Runs in the background
    - Manages containers, images, volumes, networks
    - Requires root/admin permissions
- **Docker CLI (`docker`)**
    - Command-line interface
    - You interact with it by running commands like `docker run`, `docker build`, etc.
- **Docker REST API**
    - Provides programmatic access to Docker features
    - Used by tools like Docker Compose or Portainer

**Example interaction**:

```bash
docker ps
```

This sends a request from the CLI to the daemon to list running containers.

### **Docker Hub** – Image Registry

Docker Hub is a **cloud-based registry service** where users can:

- Download prebuilt public images (e.g., `ubuntu`, `nginx`, `postgres`)
- Share their own custom images
- Host private repositories (with a free tier and paid plans)

> Official images are maintained by Docker and trusted by the community.

**Example**:

```bash
docker pull node:20
```

This pulls the official Node.js image (version 20).

You can also **push your own image** to Docker Hub:

```bash
docker tag my-app your-username/my-app
docker push your-username/my-app
```

### **Volume** – Persistent Data (Brief Intro)

A **volume** is a **Docker-managed directory on the host machine** used to persist data outside the container’s writable layer.

Why it matters:

- Containers are **ephemeral** – deleting one removes its data unless volumes are used.
- Volumes survive restarts and container replacements.

> You’ll learn more in Module 4, but it’s important to know containers without volumes = temporary data only.
>

Example:

```bash
docker run -v myvolume:/data busybox
```

---

### Summary Table

| Concept | Description |
| --- | --- |
| **Image** | Blueprint with app code and dependencies |
| **Container** | Running instance of an image |
| **Dockerfile** | Script to build custom images |
| **Docker Engine** | Software to run/build/manage containers |
| **Docker Hub** | Cloud registry for public/private images |
| **Volume** | Persistent storage across container restarts |

## Docker Architecture

Docker uses a **client-server architecture** that enables developers to build, run, and manage containers efficiently. Understanding the core components and how they interact is essential before diving deeper into practical usage.

---

### **Docker Client**

The **Docker Client** is what you interact with — typically through the command line interface (CLI). When you run commands like `docker build`, `docker run`, or `docker ps`, the client sends those commands to the **Docker Daemon** via REST API.

> Analogy: Think of the client as a remote control — it tells Docker what to do, but doesn’t do the work itself.

### Example:

```bash
docker pull nginx
```

This command tells the daemon to pull the `nginx` image from a registry.

### **Docker Daemon** (`dockerd`)

The **Docker Daemon** is the background service that does all the heavy lifting. It listens for requests from the client and manages Docker objects such as images, containers, networks, and volumes.

### Responsibilities:

- Building Docker images
- Creating and managing containers
- Handling storage (volumes) and networking
- Communicating with container registries (e.g., Docker Hub)

The daemon typically runs as a root-level system service.

> Analogy: The daemon is like a chef who receives orders (commands) and prepares the dishes (containers) using the recipes (images).

### **Docker Registry**

A **Docker Registry** is a storage and distribution system for Docker images. Registries can be:

- **Public** – like Docker Hub, the default registry used by Docker.
- **Private** – hosted internally (e.g., AWS ECR, GitLab Container Registry, Harbor).

### Common Operations:

- `docker pull <image>` – downloads an image from the registry
- `docker push <image>` – uploads a custom image to the registry

> Registries allow teams to share and version application environments easily.

### **Docker Objects**

Docker uses several core objects to manage containerized environments:

### **Images**

- Read-only templates for containers
- Contain everything needed to run an app (code, libraries, configuration)
- Built using Dockerfiles

### **Containers**

- Running instances of images
- Lightweight and isolated processes
- Include a writable layer for runtime changes

### **Volumes**

- Persistent storage for containers
- Data remains intact even if the container is removed
- Useful for databases and shared data

### **Networks**

- Enable communication between containers
- Can be bridged, host-based, or overlay (for swarm mode)
- Crucial for multi-container applications and service discovery

### How It All Works Together

Here’s the typical flow:

1. You issue a command via the **Docker Client**
2. The **Client** sends it to the **Docker Daemon**
3. The **Daemon** pulls the image from the **Registry** (if needed)
4. The **Daemon** creates a **Container** from the **Image**
5. Optional: it sets up **Volumes** and **Networks** as defined

This architecture allows Docker to be powerful, yet simple — separating the user interface (client) from the low-level operations (daemon), and supporting centralized storage (registry) and deployment across multiple systems.

## Installing Docker

Docker can be installed on **Linux**, **macOS**, and **Windows**. This section will guide you step by step to get Docker up and running on your system.

---

### Linux (Ubuntu/Debian-based)

Follow instructions under [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)

---

### macOS

#### Step 1: Install Docker Desktop

1. Visit https://www.docker.com/products/docker-desktop/
2. Download the macOS version
3. Install it by dragging Docker to the `Applications` folder

#### Step 2: Run Docker Desktop

- Open Docker Desktop from Launchpad or Spotlight
- Wait until Docker finishes starting (look for “Docker is running” in the menu bar icon)

#### Step 3: Enable Docker in Terminal (usually automatic)

Docker CLI should be available by default. If not, make sure `/usr/local/bin/docker` is in your PATH.

### Windows

#### Step 1: Enable Virtualization in BIOS (if needed)

Docker Desktop for Windows uses WSL2 or Hyper-V under the hood. You may need to:

- Reboot into BIOS/UEFI and enable virtualization (Intel VT-x or AMD-V)
- Enable Hyper-V via Control Panel or PowerShell (for older setups)

#### Step 2: Install WSL2 (Windows Subsystem for Linux)

On Windows 10/11:

```powershell
wsl --install
```

> Make sure you have installed a Linux distribution (Ubuntu is fine).

#### Step 3: Install Docker Desktop

1. Download from https://www.docker.com/products/docker-desktop/
2. Run the installer
3. Choose WSL2 as the backend when prompted

#### Step 4: Run Docker Desktop

- Open Docker Desktop
- Confirm it's running (check tray icon)

### Verifying Your Installation

Once Docker is installed, verify that everything is working:

### Check Docker Version:

```bash
docker --version
```

Example output:

```
Docker version 24.0.2, build cb74dfc
```

### Check Docker System Info:

```bash
docker info
```

This displays detailed information about your Docker installation: version, storage driver, number of containers, etc.

### Run a Test Container:

```bash
docker run hello-world
```

Expected output:

```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

> If this works, Docker is correctly installed and functional.

### Troubleshooting

- **"Permission denied" on Linux?** → You probably need to add your user to the `docker` group (see above).
- **Command not found?** → Ensure Docker binary is in your system's PATH.
- **WSL2 or virtualization issues?** → Check BIOS settings and WSL2 installation status.

## Common Docker CLI Commands

The Docker CLI (Command Line Interface) is the main way developers interact with Docker. This section introduces the most commonly used commands that every Docker user should know. Each command includes a description, syntax, and real-life example.

### **Inspecting Docker Installation**

| Command | Description | Example |
| --- | --- | --- |
| `docker version` | Shows the installed Docker client and daemon versions. | `docker version` |
| `docker info` | Displays system-wide Docker info, including running containers, images, storage driver, etc. | `docker info` |

### **Working with Images**

| Command | Description | Example |
| --- | --- | --- |
| `docker pull <image>` | Downloads an image from Docker Hub or a custom registry. | `docker pull nginx` |
| `docker images` | Lists all images currently stored on your machine. | `docker images` |
| `docker rmi <image>` | Removes an image from your system. Useful for cleaning up. | `docker rmi nginx` |

### **Running and Managing Containers**

| Command | Description | Example |
| --- | --- | --- |
| `docker run <image>` | Creates and starts a new container from an image. | `docker run nginx` |
| `docker run -d <image>` | Runs the container in detached mode (in the background). | `docker run -d nginx` |
| `docker run -p 8080:80 <image>` | Maps a container port to a host port. | `docker run -p 8080:80 nginx` |
| `docker run --name mycontainer <image>` | Assigns a name to the container. | `docker run --name webapp nginx` |
| `docker run -v /host:/container <image>` | Mounts a volume from host to container. | `docker run -v $(pwd):/app myimage` |

### **Inspecting Containers**

| Command | Description | Example |
| --- | --- | --- |
| `docker ps` | Lists running containers. | `docker ps` |
| `docker ps -a` | Lists all containers (running + stopped). | `docker ps -a` |
| `docker logs <container>` | Shows logs (stdout/stderr) from a container. | `docker logs webapp` |
| `docker inspect <container>` | Returns low-level info in JSON format. | `docker inspect webapp` |

### **Stopping and Removing Containers**

| Command | Description | Example |
| --- | --- | --- |
| `docker stop <container>` | Gracefully stops a running container. | `docker stop webapp` |
| `docker kill <container>` | Force-stops a container immediately. | `docker kill webapp` |
| `docker rm <container>` | Removes a stopped container. | `docker rm webapp` |
| `docker rm -f <container>` | Force removes a running container. | `docker rm -f webapp` |

### **Cleaning Up**

| Command | Description | Example |
| --- | --- | --- |
| `docker system prune` | Cleans up unused data: stopped containers, unused images, networks, etc. | `docker system prune` |
| `docker volume ls` | Lists Docker volumes. | `docker volume ls` |
| `docker volume rm <name>` | Deletes a specific volume. | `docker volume rm myvolume` |

### **Quick Practice Suggestions**

- Pull and run the official `nginx` image, map port `80` to `8080`, and visit it in your browser.
- Run a container with a custom name and check it with `docker ps`.
- Stop, remove, and relaunch containers to understand lifecycle.
- Explore `docker logs` and `docker inspect` for deeper insights.

## First Steps with Containers

Now that Docker is installed and you understand its core concepts, it's time to **run your first containers**. These exercises will help you verify your setup and introduce you to container basics in action.

### **Step 1: Run the `hello-world` Container**

This is the simplest Docker container used to check that Docker is working correctly.

```bash
docker run hello-world
```

### What this does:

- Docker checks if the `hello-world` image is available locally.
- If not, it pulls it from Docker Hub.
- It creates a new container and executes a program that prints a confirmation message.

You should see output like:

```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

If you see this, **Docker is successfully installed and working.**

### **Step 2: Run a Web Server (nginx)**

Let’s launch a lightweight web server using the official `nginx` image.

```bash
docker run -d -p 8080:80 nginx
```

### Explanation:

- `d`: Run in detached mode (in the background).
- `p 8080:80`: Map **host port 8080** to **container port 80** (nginx serves on port 80).

Now open your browser and navigate to:

```
http://localhost:8080
```

You should see the **default Nginx welcome page**.

### **Check What’s Running**

```bash
docker ps
```

You’ll see the running container with its ID, image, status, and port mapping.

### **Interact with the Container**

### View logs:

```bash
docker logs <container_id>
```

### Example:

```bash
docker logs nginx_container
```

This shows you the access logs and startup output.

### Execute a shell command inside the container:

```bash
docker exec -it <container_id> bash
```

> Note: nginx doesn’t include bash by default. Use sh instead:

```bash
docker exec -it <container_id> sh
```

This gives you **interactive shell access** to the container, just like being logged into a tiny Linux machine.

### **Stop and Clean Up**

To stop the container:

```bash
docker stop <container_id>
```

To remove it:

```bash
docker rm <container_id>
```

### Summary

By now, you've:

- Verified Docker is installed with `hello-world`
- Pulled and ran your first web container (`nginx`)
- Accessed it in a browser via port mapping
- Explored container logs and shell access
