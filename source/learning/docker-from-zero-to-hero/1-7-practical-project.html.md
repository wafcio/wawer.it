---
layout: learning
course_title: "Docker: From Zero to Hero"
module_title: "Module 1: Introduction to Docker and Installation"
section_title: "Practical Project"
---

## “Simple Web Server with Docker” — Portfolio-Ready Project

### **Project Overview**

This project is designed to showcase your foundational Docker skills by creating, running, and managing a containerized web server application. It’s a hands-on demonstration of how you can use Docker to:

- Build and run containers
- Map host ports to container ports
- Manage container lifecycle (start, stop, remove)
- Inspect container logs and interact with running containers
- Write clear, organized documentation for your project

You will create a public GitHub repository containing all the necessary files, instructions, and a README that explains your Docker knowledge and project details — perfect to share with potential employers or collaborators.

### **Project Requirements**

1. **Dockerfile**

    Create a Dockerfile that sets up a lightweight web server based on the official Nginx image (or Alpine with a simple HTTP server). You can add a custom HTML page to serve.

2. **Custom HTML Page**

    Add a basic custom `index.html` page that displays:

    - Your name or username
    - A short message like “Hello from Docker Container!”
    - Optionally, system info from inside the container (use simple shell commands inside the container to generate this content)
3. **Docker Compose (Optional but Recommended)**

    Include a `docker-compose.yml` to demonstrate multi-container orchestration, e.g., the web server plus a simple service like Redis or a placeholder container.

4. **Run and Test Instructions**

    Provide step-by-step instructions in your README to:

    - Build the Docker image (`docker build`)
    - Run the container mapping a local port (e.g., `8080`) to the container’s port (`80`)
    - Verify the web server is accessible through `http://localhost:8080`
    - Show commands to check running containers, stop, remove, and inspect logs
5. **Interaction with Container**

    Show how to exec into the running container, explore files, and demonstrate a basic command like viewing your `index.html` file or system info inside the container.

6. **Project Documentation (README.md)**

    Your README should include:

    - **Project description** — what the project does and what Docker concepts it demonstrates
    - **Prerequisites** — Docker installed on your machine
    - **Setup and running instructions** — all commands with explanations
    - **Key Docker concepts used** — images, containers, volumes (if any), ports, CLI commands
    - **What you learned** — short reflection on your learning process
    - **Screenshots or terminal output** — optional, to visually show results
7. **Optional Enhancements (Extra Credit)**
    - Add a `Dockerfile` that builds the image from a simple Node.js or Python HTTP server instead of Nginx.
    - Use environment variables or volumes to inject configuration or content dynamically.
    - Include a CI workflow (GitHub Actions) that automatically builds and tests your Docker image on push.

### **Why This Project?**

- Demonstrates hands-on knowledge of Docker basics essential for any containerized development role.
- Shows your ability to write clear documentation and share your work publicly.
- Provides a real-world example of running a web service inside a container.
- Prepares you for more complex Docker use cases and Docker Compose orchestration.
- Makes your GitHub portfolio stand out with a simple, practical, and well-documented Docker project.

### **How to Present It**

- Host the project on GitHub with a meaningful repo name (e.g., `docker-simple-webserver`).
- Include a descriptive README with badges (build status if you add CI) and clear instructions.
- Add a screenshot or GIF of the web page served from Docker and terminal commands showing container lifecycle management.
- Share the repository link on your CV, LinkedIn, or job applications.
