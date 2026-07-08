# ABC Technologies — DevOps Assignment 2 (Use Case 1)

Corporate website deployed via Git → Jenkins → Docker → Kubernetes, with
Nagios, Graphite, and Grafana monitoring.

## What's in this folder

```
project/
├── website/                  # Static site: Home, About, Services, Careers, Gallery, Contact
├── Dockerfile                # nginx-based image, adds a /health endpoint
├── nginx.conf
├── Jenkinsfile                # Declarative pipeline: build → push → deploy
├── k8s/
│   ├── deployment.yaml       # 2-replica Deployment with liveness/readiness probes
│   └── service.yaml          # NodePort Service (port 30080)
└── monitoring/
    ├── nagios/abc-website.cfg          # Host + HTTP service checks
    └── graphite-grafana/
        ├── docker-compose.yml          # Graphite + Grafana stack
        └── push-metrics.sh             # Cron script pushing CPU/mem/HTTP metrics
```

---

## Step 1 — Push to GitHub (collaborative source control)

```bash
cd project
git init
git add .
git commit -m "Initial commit: ABC Technologies website + DevOps pipeline"
git branch -M main
git remote add origin https://github.com/<your-username>/<RegisterNumber>-DevOps-Project.git
git push -u origin main
```

If working with teammates, have each person clone the repo, create a feature
branch, and open a pull request — this satisfies the "multiple developers
collaborate" requirement. Screenshot the repo, commit history, and any PRs
for your report.

---

## Step 2 — Test the Docker build locally

```bash
docker build -t abc-website:local .
docker run -d -p 8081:80 --name abc-website-test abc-website:local
```

Visit `http://localhost:8081` in a browser — screenshot this for "Application
Output Screenshots." Confirm the health endpoint:

```bash
curl http://localhost:8081/health   # should return "healthy"
```

---

## Step 3 — Docker Hub

```bash
docker login
docker tag abc-website:local <dockerhub-username>/abc-technologies-website:latest
docker push <dockerhub-username>/abc-technologies-website:latest
```

Update `<dockerhub-username>` in `Jenkinsfile` and `k8s/deployment.yaml` to
match. Include the Docker Hub repo link in your report (optional item).

---

## Step 4 — Set up Jenkins

1. Install Jenkins (or run it in Docker: `docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts`).
2. Install plugins: **Docker Pipeline**, **Kubernetes CLI**, **Git**.
3. Add credentials (Manage Jenkins → Credentials):
   - `dockerhub-creds` — Username/Password (your Docker Hub login)
   - `kubeconfig` — Secret file, upload your cluster's kubeconfig (e.g. from `~/.kube/config` if using Minikube)
4. Create a new Pipeline job → "Pipeline script from SCM" → point it at your
   GitHub repo and set the script path to `Jenkinsfile`.
5. Configure a GitHub webhook (Settings → Webhooks → payload URL
   `http://<jenkins-host>:8080/github-webhook/`) so every push triggers a
   build automatically. If Jenkins isn't publicly reachable, poll SCM every
   few minutes instead (`Build Triggers → Poll SCM → H/5 * * * *`).
6. Run the job. Screenshot the Dashboard, Job Configuration, Console Output,
   and a successful build — required if Jenkins is local-only.

---

## Step 5 — Kubernetes deployment

If you don't have a cluster, use Minikube locally:

```bash
minikube start
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get pods -l app=abc-website
kubectl get svc abc-website-service
minikube service abc-website-service --url
```

Once Jenkins is wired up, the pipeline's "Deploy to Kubernetes" stage does
this automatically on every build. Screenshot `kubectl get pods` and
`kubectl get svc` showing Running/active state.

---

## Step 6 — Monitoring stack (Graphite + Grafana)

```bash
cd monitoring/graphite-grafana
docker-compose up -d
```

- Graphite UI: `http://localhost` (or the port you mapped, e.g. `:8080`)
- Grafana UI: `http://localhost:3000` (login `admin` / `admin`, then change password)

**Wire up metrics:**

1. Make `push-metrics.sh` executable and point `APP_URL` at your running site:
   ```bash
   chmod +x push-metrics.sh
   ```
2. Add it to cron to run every minute:
   ```bash
   crontab -e
   # add:
   * * * * * /full/path/to/push-metrics.sh
   ```
3. In Grafana: **Connections → Data sources → Add data source → Graphite**,
   URL `http://graphite:80` (or `http://localhost:80` if Grafana isn't in the
   same Docker network — simplest fix is adding both containers to the same
   `docker-compose.yml`, which is already done here).
4. Create a dashboard with panels for:
   - `abc_website.system.cpu_load`
   - `abc_website.system.memory_used_percent`
   - `abc_website.http.available` (HTTP Availability)
   - `abc_website.http.response_time_ms`
   - A stat panel showing uptime (Grafana's built-in "time since last data
     point at 0" or a simple uptime % calculated from `http.available`)

Screenshot the finished dashboard for "Grafana Dashboard Screenshot."

---

## Step 7 — Nagios

1. Install Nagios Core (on Ubuntu/Debian, follow the official install guide,
   or use a prebuilt Docker image like `jasonrivers/nagios`).
2. Copy `monitoring/nagios/abc-website.cfg` into
   `/usr/local/nagios/etc/objects/` and register it in `nagios.cfg`:
   ```
   cfg_file=/usr/local/nagios/etc/objects/abc-website.cfg
   ```
3. Update the `address` field to the IP/host where your container or
   Kubernetes NodePort is reachable, and adjust the port in `check_http` to
   match (`8081` for the local Docker test, `30080` for Kubernetes NodePort).
4. Restart Nagios and verify config:
   ```bash
   sudo nagios -v /usr/local/nagios/etc/nagios.cfg
   sudo systemctl restart nagios
   ```
5. Open the Nagios web UI, confirm the host shows **UP** and the HTTP service
   shows **OK**. Screenshot this.

---

## Step 8 — Documentation report

Structure your report using the assignment's mandatory sections:
1. Links table (GitHub, Jenkins, Docker Hub, App URL) on page 1.
2. Architecture diagram (Git → Jenkins → Docker → Kubernetes → Monitoring).
3. Step-by-step screenshots matching each step above, in order.
4. Final checklist from the assignment, all boxes checked.

I can generate this report as a Word document with your screenshots dropped
in, once you've captured them — just share the images and I'll assemble it.

---

## Naming reminder

- ZIP: `RegisterNumber_Name_DevOps_Project.zip`
- Report: `RegisterNumber_Name_DevOps_Report.pdf`
- GitHub repo: `RegisterNumber-DevOps-Project`
