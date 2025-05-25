---
layout: learning
course_title: "Docker: From Zero to Hero"
module_title: "Module 1: Introduction to Docker and Installation"
section_title: "Practical Exercises"
---

These exercises will help you apply the core Docker concepts and commands covered in the theory section. They focus on installing Docker, running basic containers, and mastering essential CLI commands.

### Exercise 1: Install Docker

- Follow the official installation guide for your operating system (Linux/macOS/Windows).
- Verify your installation by running:

    ```bash
    docker --version
    docker info
    ```

- **Linux users:** Ensure you can run Docker commands without `sudo` by adding your user to the `docker` group if needed.

### Exercise 2: Run the hello-world Container

- Run the simplest Docker container to verify your Docker setup:

    ```bash
    docker run hello-world
    ```

- Observe the output and describe the steps Docker performs (image pull, container creation, execution).

### Exercise 3: Explore Running Containers

- Start an Nginx web server container in detached mode, mapping port 8080 on your host to port 80 in the container:

    ```bash
    docker run -d -p 8080:80 nginx
    ```

- Check that the container is running with:

    ```bash
    docker ps
    ```

- Open your web browser and navigate to [http://localhost:8080](http://localhost:8080/) to see the Nginx welcome page.
- Inspect the container logs using:

    ```bash
    docker logs <container_id>
    ```

### Exercise 4: Interact with a Running Container

- Access the running Nginx container’s shell:

    ```bash
    docker exec -it <container_id> sh
    ```

- Explore the container’s filesystem, for example:

    ```bash
    ls /usr/share/nginx/html
    ```

- Exit the container shell by typing `exit`.

### Exercise 5: Manage Container Lifecycle

- Stop the running Nginx container:

    ```bash
    docker stop <container_id>
    ```

- Remove the stopped container:

    ```bash
    docker rm <container_id>
    ```

- List all containers, including stopped ones:

    ```bash
    docker ps -a
    ```


---

### Optional Challenge: Run an Alpine Container

- Start an interactive Alpine Linux container:

    ```bash
    docker run -it alpine sh
    ```

- Explore basic Linux commands inside the container.
- Exit and remove the container after you finish.

**Summary:**

These exercises provide hands-on experience with Docker installation, container creation and management, and interaction with running containers — building a solid foundation for the rest of the course.
