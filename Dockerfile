# Lightweight static hosting using nginx
FROM nginx:alpine

# Install curl (for HEALTHCHECK) — wget is not reliable in alpine nginx image
RUN apk add --no-cache curl

# Remove default nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy the website into nginx's default serving directory
COPY website/ /usr/share/nginx/html/

# Custom nginx config: adds a /health endpoint for Nagios HTTP checks
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s CMD curl -fs http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]

