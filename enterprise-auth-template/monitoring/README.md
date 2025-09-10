# 📊 Enterprise Auth Template - Monitoring & Observability

## Overview

This monitoring stack provides comprehensive observability for the Enterprise Auth Template application, including:

- **Metrics Collection**: Prometheus for time-series metrics
- **Visualization**: Grafana dashboards for real-time monitoring
- **Log Aggregation**: Loki for centralized logging
- **Distributed Tracing**: Jaeger for request tracing
- **Alerting**: AlertManager for intelligent alert routing
- **System Monitoring**: Node Exporter for host metrics

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Enterprise Auth Template running
- At least 4GB RAM available for monitoring stack

### Start Monitoring Stack

```bash
# From the monitoring directory
cd monitoring

# Start all monitoring services
docker-compose -f docker-compose.monitoring.yml up -d

# Verify services are running
docker-compose -f docker-compose.monitoring.yml ps
```

### Access Monitoring Tools

- **Grafana**: http://localhost:3001 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Jaeger UI**: http://localhost:16686
- **AlertManager**: http://localhost:9093

## 📈 Available Metrics

### Application Metrics

#### HTTP Metrics
- `http_requests_total` - Total HTTP requests by method, endpoint, status
- `http_request_duration_seconds` - Request duration histogram
- `http_requests_active` - Currently active requests
- `http_errors_total` - Total errors by type
- `http_response_size_bytes` - Response size distribution

#### Database Metrics
- `database_query_duration_seconds` - Query execution time
- `database_connection_pool_size` - Connection pool statistics
- `database_transactions_total` - Transaction counts

#### Cache Metrics
- `cache_hits_total` - Cache hit count
- `cache_misses_total` - Cache miss count
- `cache_operations_duration_seconds` - Cache operation latency

#### Business Metrics
- `user_login_attempts_total` - Login attempts by status
- `user_registrations_total` - User registration count
- `user_sessions_active` - Active user sessions

### System Metrics

- CPU usage and load average
- Memory utilization
- Disk I/O and space
- Network traffic
- Container resource usage

## 🎯 Grafana Dashboards

### Main Dashboard

The main dashboard includes:

1. **Request Overview**
   - Request rate by method
   - Response time percentiles
   - Error rate trends

2. **Performance Metrics**
   - API latency distribution
   - Database query performance
   - Cache hit rates

3. **System Health**
   - CPU and memory usage
   - Disk utilization
   - Network throughput

4. **Business Metrics**
   - User activity patterns
   - Authentication success rates
   - Registration trends

### Custom Dashboards

To import additional dashboards:

1. Open Grafana (http://localhost:3001)
2. Navigate to Dashboards → Import
3. Upload JSON file or paste dashboard ID
4. Select Prometheus datasource

## 🚨 Alerting

### Configured Alerts

#### Critical Alerts (Immediate notification)
- API Down (no response for 1 minute)
- Database Down (connection failed)
- Very High Latency (>3s for 2 minutes)
- Security: Brute Force Attack Detection

#### Warning Alerts (5-minute delay)
- High Request Latency (>1s)
- High Error Rate (>5%)
- Database Slow Queries (>500ms)
- Low Cache Hit Rate (<70%)
- Resource Usage (CPU >80%, Memory >90%, Disk >85%)

#### Info Alerts (Business metrics)
- No New Registrations (2 hours)
- Unusual Activity Patterns
- Registration Spikes

### Alert Routing

Alerts are routed based on severity and component:

- **Critical**: Email + Slack + PagerDuty
- **Warning**: Email + Slack
- **Info**: Email only

### Configuring Alert Recipients

Edit `alertmanager.yml` to configure recipients:

```yaml
receivers:
  - name: 'critical-alerts'
    email_configs:
      - to: 'your-email@company.com'
    slack_configs:
      - api_url: 'YOUR_SLACK_WEBHOOK_URL'
        channel: '#alerts'
```

## 📋 Log Aggregation

### Viewing Logs

1. Open Grafana
2. Navigate to Explore
3. Select Loki datasource
4. Use LogQL queries:

```logql
# All backend errors
{service="enterprise-auth-backend"} |= "error"

# Slow requests
{service="enterprise-auth-backend"} |> "duration" |> "1.0"

# Failed logins
{service="enterprise-auth-backend"} |= "login" |= "failure"

# By request ID
{service="enterprise-auth-backend"} |= "request_id=\"abc-123\""
```

### Log Fields

Structured logs include:
- `@timestamp` - Event timestamp
- `level` - Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- `message` - Log message
- `request_id` - Request tracking ID
- `user_id` - User identifier
- `duration` - Operation duration
- `exception` - Error details and traceback

## 🔍 Distributed Tracing

### Viewing Traces

1. Open Jaeger UI (http://localhost:16686)
2. Select service: `enterprise-auth-backend`
3. Find traces by:
   - Operation name
   - Duration
   - Tags (user_id, request_id, etc.)

### Trace Context

Traces include:
- Request flow through services
- Database query timing
- Cache operations
- External API calls
- Error locations

## 🛠️ Maintenance

### Backup Monitoring Data

```bash
# Backup Prometheus data
docker run --rm -v monitoring_prometheus_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/prometheus-backup.tar.gz -C /data .

# Backup Grafana dashboards
docker run --rm -v monitoring_grafana_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/grafana-backup.tar.gz -C /data .
```

### Update Monitoring Stack

```bash
# Pull latest images
docker-compose -f docker-compose.monitoring.yml pull

# Restart with new images
docker-compose -f docker-compose.monitoring.yml up -d
```

### Clean Up Old Data

```bash
# Prometheus retention is set to 30 days by default
# Loki retention is set to 30 days by default

# Manual cleanup if needed
docker exec -it prometheus sh -c "rm -rf /prometheus/data/wal"
docker exec -it loki sh -c "rm -rf /loki/chunks/*"
```

## 🔧 Troubleshooting

### Prometheus Not Scraping Metrics

1. Check target status: http://localhost:9090/targets
2. Verify backend is exposing metrics: `curl http://localhost:8000/metrics`
3. Check network connectivity between containers

### Grafana Dashboard Not Loading

1. Verify datasources are configured
2. Check Prometheus is running and accessible
3. Reload dashboard or re-import

### High Memory Usage

1. Reduce retention periods in configuration
2. Increase compaction intervals
3. Add memory limits to containers

### Alerts Not Firing

1. Check AlertManager status: http://localhost:9093
2. Verify alert rules in Prometheus
3. Check SMTP/Slack configuration

## 📚 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [AlertManager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/)

## 🤝 Contributing

To add new metrics or dashboards:

1. Add metric collection in application code
2. Update Prometheus scrape configuration if needed
3. Create/update Grafana dashboard
4. Add alert rules for critical metrics
5. Document new metrics in this README

## 📄 License

This monitoring configuration is part of the Enterprise Auth Template and follows the same license.