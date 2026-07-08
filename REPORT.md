# ABC Technologies DevOps Project Report

## Mandatory Submission Links

| Sl. No. | Submission Item | Description | Value |
| --- | --- | --- | --- |
| 1 | GitHub Repository Link | Link to the complete source code repository. | https://github.com/Prasannaa-V/23BIT0041-DevOps-Project |
| 2 | Jenkins Build URL | URL of the successful Jenkins job or pipeline. If Jenkins is local, include screenshots instead of the URL. | Local Jenkins screenshots required |
| 3 | Docker Hub Repository Link | Optional Docker image repository link. | Not published yet |
| 4 | Application URL | Deployed application URL. If local, provide the local URL and a browser screenshot. | http://localhost:8081 |
| 5 | Grafana Dashboard Screenshot | Screenshot showing monitored metrics. | Add screenshot here |
| 6 | Nagios Monitoring Screenshot | Screenshot showing host and services in UP/OK state. | Add screenshot here |
| 7 | Graphite Metrics Screenshot | Screenshot showing application or system metrics received in Graphite. | Add screenshot here |

## Project Overview

ABC Technologies is a corporate website built with HTML, CSS, JavaScript, and image assets. The project demonstrates a DevOps workflow with GitHub, Jenkins, Docker, Kubernetes, Nagios, Graphite, and Grafana.

## Implementation Steps

### 1. Source Control

- Repository created and pushed to GitHub.
- Branch used: `main`.

### 2. Docker Build and Runtime

- Docker image builds successfully from the provided Dockerfile.
- The container serves the website through Nginx.
- Health endpoint: `http://localhost:8081/health`

### 3. Jenkins Automation

- Jenkins pipeline configured in `Jenkinsfile`.
- Required screenshots to include:
  - Jenkins Dashboard
  - Job Configuration
  - Console Output
  - Successful Build

### 4. Kubernetes Deployment

- Kubernetes manifests are in `k8s/`.
- Required screenshots to include:
  - `kubectl get pods`
  - `kubectl get svc`

### 5. Monitoring

- Nagios configuration is in `monitoring/nagios/abc-website.cfg`.
- Graphite and Grafana stack is in `monitoring/graphite-grafana/`.
- Required screenshots to include:
  - Graphite metrics screen
  - Grafana dashboard
  - Nagios host and service status

## Final Submission Checklist

- [x] GitHub repository is accessible.
- [x] All source code has been pushed to GitHub.
- [ ] Jenkins build completed successfully.
- [ ] Maven build completed successfully.
- [x] Docker image was created successfully.
- [ ] Docker container is running.
- [ ] Kubernetes Pods and Services are in the Running state.
- [ ] Application is accessible in the browser.
- [ ] Nagios displays the Host as UP and Services as OK.
- [ ] Graphite is receiving metrics.
- [ ] Grafana dashboard displays the required metrics.
- [ ] Documentation contains screenshots of every implementation step.
- [ ] All required links have been included.

## Screenshot Placeholders

Add the following screenshots to the final report before exporting to PDF or Word:

- GitHub repository page
- Jenkins dashboard and build logs
- Docker build output
- Running container and browser output
- Kubernetes deployment and service output
- Nagios monitoring screen
- Graphite metrics screen
- Grafana dashboard

## Naming Convention

- Project ZIP: `23BIT0041_Name_DevOps_Project.zip`
- Documentation: `23BIT0041_Name_DevOps_Report.pdf`
- GitHub Repository: `23BIT0041-DevOps-Project`
