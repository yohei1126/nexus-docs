# RM&D OSS Architecture — Part 5C: Infrastructure Abstraction Patterns

> Part 5C of 6 · Section 8.9: Ports & Adapters architecture, interface definitions, adapter implementations, testing strategies, migration playbooks

> **Navigation:** [ARCH1 Overview](ARCH1_OVERVIEW.md) · [ARCH2 Security & Licensing](ARCH2_VENDOR_SECURITY.md) · [ARCH3 Plugin API](ARCH3_PLUGIN_API.md) · [ARCH4 Deployment](ARCH4_DEPLOYMENT.md) · **[ARCH5 Index](ARCH5_INDEX.md)** · [ARCH6 Strategy](ARCH6_STRATEGY.md)

> **Part 5 Sections:** [5A: OSS Selection](ARCH5A_OSS_SELECTION.md) · [5B: Analytics & KPI](ARCH5B_ANALYTICS_KPI.md) · **5C: Abstraction Patterns** · [5D: Tech Stack](ARCH5D_TECH_STACK.md)

---

### 8.9 Infrastructure Abstraction Patterns {#8.9-infrastructure-abstraction}

**Key Principle:** **"Minimize infrastructure lock-in through well-defined abstraction layers."**

To achieve the flexibility recommended in [Section 8.3 (Deployment Scale)](#83-recommended-oss-stack-by-deployment-scale), each component in the stack (Gateway, Database, Message Broker, API Gateway) must be **decoupled from tool-specific implementations**. This allows seamless migration from lightweight tools (e.g., Mosquitto) to enterprise-grade solutions (e.g., Kafka) without rewriting business logic.

#### 8.9.1 Architecture Pattern: Ports & Adapters (Hexagonal Architecture)

The Nexus platform follows the **Ports & Adapters** pattern to separate business logic from infrastructure concerns:

```text
┌─────────────────────────────────────────────────────────────┐
│         Application Core (Business Logic)                  │
│   - Device management                                       │
│   - Telemetry processing & validation                      │
│   - Rule evaluation & fault detection                      │
│   - BCA KPI calculations                                    │
└───────────────────────┬─────────────────────────────────────┘
                        │ depends on (interfaces only)
                        ▼
┌─────────────────────────────────────────────────────────────┐
│         Ports (Interfaces / Contracts)                      │
│   - IDeviceRepository       (CRUD operations)               │
│   - ITimeSeriesStore        (metrics storage)               │
│   - IMessageBroker          (pub/sub)                       │
│   - IGatewayAdapter         (device integration)            │
│   - IAPIGateway             (routing, auth, rate limiting)  │
└───────────────────────┬─────────────────────────────────────┘
                        │ implemented by
                        ▼
┌─────────────────────────────────────────────────────────────┐
│         Adapters (Tool-Specific Implementations)            │
│   - PostgreSQLDeviceRepo    / MongoDBDeviceRepo             │
│   - TimescaleDBAdapter      / InfluxDBAdapter / QuestDBAdapter│
│   - KafkaMessageBroker      / NATSMessageBroker / MQTTBroker│
│   - EdgeXGatewayAdapter     / ThingsBoardGatewayAdapter     │
│   - KongAPIGateway          / TraefikAPIGateway             │
└─────────────────────────────────────────────────────────────┘
```

**Benefits:**

1. **Tool Replacement:** Change infrastructure by swapping adapter implementations without touching business logic
2. **Multi-Cloud:** Run different adapters in different regions (e.g., NATS in edge, Kafka in cloud)
3. **Testing:** Mock adapters for unit tests without requiring real infrastructure
4. **Scale-Based Selection:** Use lightweight MQTT for PoC, transition to Kafka for production
5. **Vendor Independence:** Zero vendor lock-in, no proprietary APIs in core logic

---

#### 8.9.2 Port Definitions (Interfaces)

**Normative Requirement:** All infrastructure integrations MUST implement these standardized interfaces.

##### 8.9.2.1 Time-Series Database (ITimeSeriesStore)

```typescript
/**
 * Time-series data storage abstraction
 * Implementations: TimescaleDB, InfluxDB, QuestDB, Prometheus
 */
interface ITimeSeriesStore {
  /**
   * Write a single metric to the time-series database
   * @throws StorageError if write fails
   */
  write(metric: Metric): Promise<void>;

  /**
   * Write multiple metrics in a batch (optimized for bulk ingestion)
   * @throws StorageError if batch write fails
   */
  writeBatch(metrics: Metric[]): Promise<void>;

  /**
   * Query time-series data with filters
   * @param params - Query parameters (time range, filters, aggregations)
   * @returns Array of matching metrics
   */
  query(params: TimeSeriesQuery): Promise<Metric[]>;

  /**
   * Perform aggregations (SUM, AVG, MAX, MIN, PERCENTILE)
   * @param params - Aggregation parameters
   * @returns Aggregated metric values
   */
  aggregate(params: AggregationQuery): Promise<AggregatedMetric>;

  /**
   * Delete metrics matching criteria (for GDPR/data retention compliance)
   * @param params - Deletion criteria
   */
  delete(params: DeletionCriteria): Promise<void>;
}

/**
 * Metric data structure (tool-agnostic)
 */
interface Metric {
  deviceId: string;
  metricName: string;        // e.g., "temperature", "door_open_count"
  value: number | boolean | string;
  timestamp: Date;
  tags?: Record<string, string>;  // e.g., { "location": "floor_3", "building_id": "SG001" }
  metadata?: Record<string, any>;
}

/**
 * Query parameters
 */
interface TimeSeriesQuery {
  deviceIds?: string[];
  metricNames?: string[];
  startTime: Date;
  endTime: Date;
  filters?: Record<string, any>;  // Tag-based filtering
  limit?: number;
  offset?: number;
}

/**
 * Aggregation parameters
 */
interface AggregationQuery extends TimeSeriesQuery {
  aggregationType: 'SUM' | 'AVG' | 'MAX' | 'MIN' | 'COUNT' | 'PERCENTILE';
  groupBy?: string[];          // e.g., ["deviceId", "hour"]
  interval?: string;           // e.g., "5m", "1h", "1d"
  percentile?: number;         // For PERCENTILE aggregations (e.g., 95, 99)
}
```

**Example Adapter Implementations:**

```typescript
// TimescaleDB Adapter (PostgreSQL extension)
class TimescaleDBAdapter implements ITimeSeriesStore {
  constructor(private pool: pg.Pool) {}

  async write(metric: Metric): Promise<void> {
    const query = `
      INSERT INTO metrics (device_id, metric_name, value, timestamp, tags)
      VALUES ($1, $2, $3, $4, $5)
    `;
    await this.pool.query(query, [
      metric.deviceId,
      metric.metricName,
      metric.value,
      metric.timestamp,
      JSON.stringify(metric.tags || {})
    ]);
  }

  async query(params: TimeSeriesQuery): Promise<Metric[]> {
    const query = `
      SELECT device_id, metric_name, value, timestamp, tags
      FROM metrics
      WHERE timestamp BETWEEN $1 AND $2
        ${params.deviceIds ? 'AND device_id = ANY($3)' : ''}
      ORDER BY timestamp DESC
      LIMIT $4
    `;
    const result = await this.pool.query(query, [
      params.startTime,
      params.endTime,
      params.deviceIds,
      params.limit || 1000
    ]);
    return result.rows.map(this.mapRowToMetric);
  }
}

// InfluxDB Adapter (Time-series optimized)
class InfluxDBAdapter implements ITimeSeriesStore {
  constructor(private writeApi: WriteApi, private queryApi: QueryApi) {}

  async write(metric: Metric): Promise<void> {
    const point = new Point(metric.metricName)
      .tag('device_id', metric.deviceId)
      .floatField('value', metric.value)
      .timestamp(metric.timestamp);

    if (metric.tags) {
      Object.entries(metric.tags).forEach(([key, val]) => {
        point.tag(key, val);
      });
    }

    this.writeApi.writePoint(point);
    await this.writeApi.flush();  // Ensure data is written
  }

  async query(params: TimeSeriesQuery): Promise<Metric[]> {
    const flux = `
      from(bucket: "${this.bucket}")
        |> range(start: ${params.startTime.toISOString()}, stop: ${params.endTime.toISOString()})
        |> filter(fn: (r) => r["_measurement"] == "${params.metricNames?.[0]}")
        |> limit(n: ${params.limit || 1000})
    `;
    const result = await this.queryApi.collectRows(flux);
    return result.map(this.mapFluxToMetric);
  }
}

// QuestDB Adapter (Ultra-fast ingestion)
class QuestDBAdapter implements ITimeSeriesStore {
  constructor(private sender: Sender) {}

  async write(metric: Metric): Promise<void> {
    this.sender
      .table(metric.metricName)
      .symbol('device_id', metric.deviceId)
      .floatColumn('value', metric.value)
      .at(metric.timestamp.getTime() * 1_000_000, 'ns');  // QuestDB uses nanoseconds

    await this.sender.flush();
  }

  async query(params: TimeSeriesQuery): Promise<Metric[]> {
    // QuestDB uses PostgreSQL wire protocol
    const query = `
      SELECT device_id, metric_name, value, timestamp
      FROM ${params.metricNames?.[0]}
      WHERE timestamp BETWEEN '${params.startTime.toISOString()}' AND '${params.endTime.toISOString()}'
      LIMIT ${params.limit || 1000}
    `;
    const result = await this.client.query(query);
    return result.rows.map(this.mapRowToMetric);
  }
}
```

---

##### 8.9.2.2 Message Broker (IMessageBroker)

```typescript
/**
 * Message broker abstraction for pub/sub messaging
 * Implementations: Kafka, NATS, MQTT (Mosquitto/VerneMQ), RabbitMQ
 */
interface IMessageBroker {
  /**
   * Publish a message to a topic
   * @param topic - Topic name (e.g., "telemetry.device.123")
   * @param message - Message payload
   * @param options - Optional publishing options (QoS, retention, etc.)
   */
  publish(topic: string, message: Message, options?: PublishOptions): Promise<void>;

  /**
   * Subscribe to a topic and register a message handler
   * @param topic - Topic name or pattern (e.g., "telemetry.*")
   * @param handler - Callback function to process messages
   * @returns Subscription ID for unsubscribing
   */
  subscribe(topic: string, handler: MessageHandler): Promise<string>;

  /**
   * Unsubscribe from a topic
   * @param subscriptionId - Subscription ID returned by subscribe()
   */
  unsubscribe(subscriptionId: string): Promise<void>;

  /**
   * Connect to the message broker
   */
  connect(): Promise<void>;

  /**
   * Disconnect from the message broker
   */
  disconnect(): Promise<void>;
}

interface Message {
  payload: any;              // Message body (JSON, binary, etc.)
  headers?: Record<string, string>;  // Optional headers
  timestamp?: Date;
}

interface PublishOptions {
  qos?: 0 | 1 | 2;          // Quality of Service (MQTT-style)
  retain?: boolean;          // Retain last message for new subscribers
  partition?: string;        // For Kafka-like brokers
}

type MessageHandler = (message: Message) => void | Promise<void>;
```

**Example Adapter Implementations:**

```typescript
// Kafka Adapter (Enterprise-grade, high throughput)
class KafkaMessageBroker implements IMessageBroker {
  private producer: Producer;
  private consumer: Consumer;
  private subscriptions = new Map<string, string>();

  constructor(private config: KafkaConfig) {}

  async connect(): Promise<void> {
    this.producer = new Kafka(this.config).producer();
    this.consumer = new Kafka(this.config).consumer({ groupId: this.config.groupId });
    await this.producer.connect();
    await this.consumer.connect();
  }

  async publish(topic: string, message: Message, options?: PublishOptions): Promise<void> {
    await this.producer.send({
      topic,
      messages: [{
        value: JSON.stringify(message.payload),
        headers: message.headers,
        partition: options?.partition
      }]
    });
  }

  async subscribe(topic: string, handler: MessageHandler): Promise<string> {
    await this.consumer.subscribe({ topic, fromBeginning: false });
    const subscriptionId = crypto.randomUUID();

    this.consumer.run({
      eachMessage: async ({ topic, partition, message }) => {
        await handler({
          payload: JSON.parse(message.value.toString()),
          headers: message.headers as Record<string, string>,
          timestamp: new Date(Number(message.timestamp))
        });
      }
    });

    this.subscriptions.set(subscriptionId, topic);
    return subscriptionId;
  }

  async disconnect(): Promise<void> {
    await this.producer.disconnect();
    await this.consumer.disconnect();
  }
}

// NATS Adapter (Lightweight, edge-optimized)
class NATSMessageBroker implements IMessageBroker {
  private nc: NatsConnection;
  private subscriptions = new Map<string, Subscription>();

  constructor(private servers: string[]) {}

  async connect(): Promise<void> {
    this.nc = await connect({ servers: this.servers });
  }

  async publish(topic: string, message: Message): Promise<void> {
    const codec = JSONCodec();
    this.nc.publish(topic, codec.encode(message.payload), {
      headers: headers(message.headers || {})
    });
  }

  async subscribe(topic: string, handler: MessageHandler): Promise<string> {
    const codec = JSONCodec();
    const sub = this.nc.subscribe(topic);
    const subscriptionId = crypto.randomUUID();

    (async () => {
      for await (const msg of sub) {
        await handler({
          payload: codec.decode(msg.data),
          headers: msg.headers ? headersToObject(msg.headers) : {},
          timestamp: new Date()
        });
      }
    })();

    this.subscriptions.set(subscriptionId, sub);
    return subscriptionId;
  }

  async unsubscribe(subscriptionId: string): Promise<void> {
    const sub = this.subscriptions.get(subscriptionId);
    if (sub) {
      sub.unsubscribe();
      this.subscriptions.delete(subscriptionId);
    }
  }

  async disconnect(): Promise<void> {
    await this.nc.drain();
    await this.nc.close();
  }
}

// MQTT Adapter (IoT-optimized, device-friendly)
class MQTTMessageBroker implements IMessageBroker {
  private client: mqtt.MqttClient;
  private handlers = new Map<string, MessageHandler>();

  constructor(private brokerUrl: string) {}

  async connect(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.client = mqtt.connect(this.brokerUrl);
      this.client.on('connect', () => resolve());
      this.client.on('error', (err) => reject(err));
      this.client.on('message', (topic, payload) => {
        const handler = this.handlers.get(topic);
        if (handler) {
          handler({
            payload: JSON.parse(payload.toString()),
            timestamp: new Date()
          });
        }
      });
    });
  }

  async publish(topic: string, message: Message, options?: PublishOptions): Promise<void> {
    return new Promise((resolve, reject) => {
      this.client.publish(
        topic,
        JSON.stringify(message.payload),
        { qos: options?.qos || 0, retain: options?.retain || false },
        (err) => (err ? reject(err) : resolve())
      );
    });
  }

  async subscribe(topic: string, handler: MessageHandler): Promise<string> {
    return new Promise((resolve, reject) => {
      this.client.subscribe(topic, (err) => {
        if (err) reject(err);
        else {
          this.handlers.set(topic, handler);
          resolve(topic);  // Use topic as subscription ID for MQTT
        }
      });
    });
  }

  async unsubscribe(subscriptionId: string): Promise<void> {
    return new Promise((resolve, reject) => {
      this.client.unsubscribe(subscriptionId, (err) => {
        if (err) reject(err);
        else {
          this.handlers.delete(subscriptionId);
          resolve();
        }
      });
    });
  }

  async disconnect(): Promise<void> {
    return new Promise((resolve) => {
      this.client.end(false, {}, () => resolve());
    });
  }
}
```

---

##### 8.9.2.3 Gateway Adapter (IGatewayAdapter)

```typescript
/**
 * Gateway abstraction for device management and command execution
 * Implementations: EdgeX Foundry, ThingsBoard, Node-RED
 */
interface IGatewayAdapter {
  /**
   * Register a new device with the gateway
   * @param device - Device configuration (ID, type, protocols, metadata)
   */
  registerDevice(device: DeviceConfig): Promise<void>;

  /**
   * Send a command to a device (e.g., restart, set parameter, trigger action)
   * @param deviceId - Target device ID
   * @param command - Command to execute
   * @returns Command result
   */
  sendCommand(deviceId: string, command: Command): Promise<CommandResult>;

  /**
   * Register a callback for telemetry data from devices
   * @param handler - Callback function to process incoming telemetry
   */
  onTelemetry(handler: (data: TelemetryData) => void): void;

  /**
   * Get the current status of a device
   * @param deviceId - Device ID
   * @returns Device status (online, offline, faulted)
   */
  getDeviceStatus(deviceId: string): Promise<DeviceStatus>;

  /**
   * Remove a device from the gateway
   * @param deviceId - Device ID
   */
  removeDevice(deviceId: string): Promise<void>;
}

interface DeviceConfig {
  deviceId: string;
  deviceType: string;         // e.g., "lift", "hvac", "sensor"
  protocol: string;           // e.g., "mqtt", "opcua", "modbus"
  connectionParams: Record<string, any>;
  metadata?: Record<string, any>;
}

interface Command {
  name: string;               // e.g., "restart", "set_temperature"
  parameters?: Record<string, any>;
  timeout?: number;           // Command timeout in milliseconds
}

interface CommandResult {
  success: boolean;
  response?: any;
  error?: string;
  executedAt: Date;
}

interface TelemetryData {
  deviceId: string;
  timestamp: Date;
  metrics: Record<string, any>;  // e.g., { "temperature": 23.5, "door_state": "open" }
}

enum DeviceStatus {
  ONLINE = 'online',
  OFFLINE = 'offline',
  FAULTED = 'faulted',
  MAINTENANCE = 'maintenance'
}
```

**Example Adapter Implementations:**

```typescript
// EdgeX Foundry Adapter
class EdgeXGatewayAdapter implements IGatewayAdapter {
  constructor(
    private coreMetadataClient: CoreMetadataClient,
    private coreCommandClient: CoreCommandClient
  ) {}

  async registerDevice(device: DeviceConfig): Promise<void> {
    const edgexDevice = {
      name: device.deviceId,
      profileName: device.deviceType,
      protocols: {
        [device.protocol]: device.connectionParams
      },
      adminState: 'UNLOCKED',
      operatingState: 'ENABLED'
    };

    await this.coreMetadataClient.addDevice(edgexDevice);
  }

  async sendCommand(deviceId: string, command: Command): Promise<CommandResult> {
    try {
      const response = await this.coreCommandClient.issueSetCommand(
        deviceId,
        command.name,
        command.parameters || {}
      );

      return {
        success: true,
        response: response.data,
        executedAt: new Date()
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
        executedAt: new Date()
      };
    }
  }

  onTelemetry(handler: (data: TelemetryData) => void): void {
    // Subscribe to EdgeX event stream via Redis Pub/Sub or MQTT
    this.eventSubscriber.on('event', (event) => {
      handler({
        deviceId: event.deviceName,
        timestamp: new Date(event.origin),
        metrics: this.parseEdgeXReadings(event.readings)
      });
    });
  }

  async getDeviceStatus(deviceId: string): Promise<DeviceStatus> {
    const device = await this.coreMetadataClient.getDeviceByName(deviceId);
    return device.operatingState === 'ENABLED' ? DeviceStatus.ONLINE : DeviceStatus.OFFLINE;
  }
}

// ThingsBoard Adapter
class ThingsBoardGatewayAdapter implements IGatewayAdapter {
  constructor(private tbClient: ThingsBoardClient) {}

  async registerDevice(device: DeviceConfig): Promise<void> {
    const tbDevice = {
      name: device.deviceId,
      type: device.deviceType,
      label: device.deviceId,
      additionalInfo: device.metadata
    };

    await this.tbClient.createDevice(tbDevice);
  }

  async sendCommand(deviceId: string, command: Command): Promise<CommandResult> {
    try {
      const response = await this.tbClient.sendRPC({
        deviceId,
        method: command.name,
        params: command.parameters || {},
        timeout: command.timeout || 5000
      });

      return {
        success: true,
        response,
        executedAt: new Date()
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
        executedAt: new Date()
      };
    }
  }

  onTelemetry(handler: (data: TelemetryData) => void): void {
    this.tbClient.subscribeTelemetry((deviceId, metrics) => {
      handler({
        deviceId,
        timestamp: new Date(),
        metrics
      });
    });
  }

  async getDeviceStatus(deviceId: string): Promise<DeviceStatus> {
    const device = await this.tbClient.getDevice(deviceId);
    return device.active ? DeviceStatus.ONLINE : DeviceStatus.OFFLINE;
  }
}
```

---

##### 8.9.2.4 API Gateway (IAPIGateway)

```typescript
/**
 * API Gateway abstraction for routing, authentication, and rate limiting
 * Implementations: Kong, Traefik, Envoy
 */
interface IAPIGateway {
  /**
   * Configure rate limiting for a route
   * @param route - Route identifier (path or service name)
   * @param limits - Rate limit configuration
   */
  configureRateLimit(route: string, limits: RateLimitConfig): Promise<void>;

  /**
   * Configure authentication for a route
   * @param route - Route identifier
   * @param authConfig - Authentication configuration (JWT, API key, OAuth2)
   */
  configureAuth(route: string, authConfig: AuthConfig): Promise<void>;

  /**
   * Add a new route to the gateway
   * @param route - Route configuration (path, upstream, methods)
   */
  addRoute(route: RouteConfig): Promise<void>;

  /**
   * Remove a route from the gateway
   * @param routeId - Route identifier
   */
  removeRoute(routeId: string): Promise<void>;

  /**
   * Get metrics for a specific route
   * @param routeId - Route identifier
   * @returns Route metrics (requests, latency, errors)
   */
  getRouteMetrics(routeId: string): Promise<RouteMetrics>;
}

interface RateLimitConfig {
  perSecond?: number;
  perMinute?: number;
  perHour?: number;
  burst?: number;            // Max burst capacity
  keyBy?: 'ip' | 'user' | 'api_key';  // Rate limit key
}

interface AuthConfig {
  type: 'jwt' | 'api_key' | 'oauth2' | 'basic';
  config: Record<string, any>;  // Auth-specific configuration
}

interface RouteConfig {
  path: string;              // e.g., "/api/v1/devices"
  methods: ('GET' | 'POST' | 'PUT' | 'DELETE')[];
  upstream: string;          // Backend service URL
  stripPath?: boolean;       // Strip matched path before forwarding
  preserveHost?: boolean;    // Preserve original host header
}

interface RouteMetrics {
  requestCount: number;
  errorCount: number;
  avgLatencyMs: number;
  p95LatencyMs: number;
  p99LatencyMs: number;
}
```

**Example Adapter Implementations:**

```typescript
// Kong API Gateway Adapter
class KongAPIGatewayAdapter implements IAPIGateway {
  constructor(private kongAdminClient: KongAdminClient) {}

  async configureRateLimit(route: string, limits: RateLimitConfig): Promise<void> {
    await this.kongAdminClient.plugins.create({
      name: 'rate-limiting',
      route: { id: route },
      config: {
        second: limits.perSecond,
        minute: limits.perMinute,
        hour: limits.perHour,
        policy: 'local',
        limit_by: limits.keyBy || 'ip'
      }
    });
  }

  async configureAuth(route: string, authConfig: AuthConfig): Promise<void> {
    const pluginName = authConfig.type === 'jwt' ? 'jwt' :
                       authConfig.type === 'api_key' ? 'key-auth' :
                       authConfig.type === 'oauth2' ? 'oauth2' : 'basic-auth';

    await this.kongAdminClient.plugins.create({
      name: pluginName,
      route: { id: route },
      config: authConfig.config
    });
  }

  async addRoute(route: RouteConfig): Promise<void> {
    // First, create or get the service (upstream)
    const service = await this.kongAdminClient.services.createOrUpdate({
      name: `service-${route.path.replace(/\//g, '-')}`,
      url: route.upstream
    });

    // Then, create the route
    await this.kongAdminClient.routes.create({
      service: { id: service.id },
      paths: [route.path],
      methods: route.methods,
      strip_path: route.stripPath !== false,
      preserve_host: route.preserveHost || false
    });
  }

  async getRouteMetrics(routeId: string): Promise<RouteMetrics> {
    const stats = await this.kongAdminClient.routes.getStatistics(routeId);
    return {
      requestCount: stats.request_count,
      errorCount: stats.error_count,
      avgLatencyMs: stats.avg_latency,
      p95LatencyMs: stats.p95_latency,
      p99LatencyMs: stats.p99_latency
    };
  }
}

// Traefik API Gateway Adapter
class TraefikAPIGatewayAdapter implements IAPIGateway {
  constructor(private traefikClient: TraefikClient) {}

  async configureRateLimit(route: string, limits: RateLimitConfig): Promise<void> {
    await this.traefikClient.createMiddleware({
      name: `ratelimit-${route}`,
      rateLimit: {
        average: limits.perMinute || 100,
        burst: limits.burst || 50,
        period: '1m'
      }
    });

    // Attach middleware to route
    await this.traefikClient.updateRoute(route, {
      middlewares: [`ratelimit-${route}`]
    });
  }

  async configureAuth(route: string, authConfig: AuthConfig): Promise<void> {
    const middlewareName = `auth-${route}`;

    if (authConfig.type === 'basic') {
      await this.traefikClient.createMiddleware({
        name: middlewareName,
        basicAuth: authConfig.config
      });
    } else if (authConfig.type === 'jwt') {
      await this.traefikClient.createMiddleware({
        name: middlewareName,
        plugin: {
          jwtAuth: authConfig.config
        }
      });
    }

    await this.traefikClient.updateRoute(route, {
      middlewares: [middlewareName]
    });
  }

  async addRoute(route: RouteConfig): Promise<void> {
    await this.traefikClient.createRoute({
      rule: `Path(\`${route.path}\`)`,
      service: route.upstream,
      middlewares: []
    });
  }

  async getRouteMetrics(routeId: string): Promise<RouteMetrics> {
    const metrics = await this.traefikClient.getMetrics(routeId);
    return {
      requestCount: metrics.total_requests,
      errorCount: metrics.total_errors,
      avgLatencyMs: metrics.avg_duration_ms,
      p95LatencyMs: metrics.p95_duration_ms,
      p99LatencyMs: metrics.p99_duration_ms
    };
  }
}
```

---

#### 8.9.3 Configuration-Driven Adapter Selection

**Key Principle:** Infrastructure tool selection is determined by **configuration**, not hardcoded logic.

##### 8.9.3.1 Configuration Schema

```yaml
# config/production.yaml
infrastructure:
  # Time-series database configuration
  database:
    adapter: "timescaledb"  # Options: "timescaledb", "influxdb", "questdb", "prometheus"
    connection:
      host: "${DB_HOST}"
      port: 5432
      database: "nexus_metrics"
      username: "${DB_USER}"
      password: "${DB_PASSWORD}"
      ssl: true

  # Message broker configuration
  messageBroker:
    adapter: "kafka"  # Options: "kafka", "nats", "mqtt", "rabbitmq"
    brokers:
      - "${KAFKA_BROKER_1}"
      - "${KAFKA_BROKER_2}"
      - "${KAFKA_BROKER_3}"
    config:
      groupId: "nexus-telemetry-processor"
      clientId: "nexus-cloud-1"
      ssl: true

  # Gateway configuration
  gateway:
    adapter: "edgex"  # Options: "edgex", "thingsboard", "node-red"
    apiUrl: "${GATEWAY_API_URL}"
    credentials:
      username: "${GATEWAY_USER}"
      password: "${GATEWAY_PASSWORD}"

  # API Gateway configuration
  apiGateway:
    adapter: "kong"  # Options: "kong", "traefik", "envoy"
    adminUrl: "${KONG_ADMIN_URL}"
    proxyUrl: "${KONG_PROXY_URL}"
    credentials:
      apiKey: "${KONG_API_KEY}"

# For small deployments (PoC, pilot)
# config/development.yaml
infrastructure:
  database:
    adapter: "questdb"  # Lightweight, single-node
    connection:
      host: "localhost"
      port: 9000

  messageBroker:
    adapter: "mqtt"  # Simple, minimal resources
    brokers:
      - "mqtt://localhost:1883"

  gateway:
    adapter: "node-red"  # Visual programming, rapid prototyping
    apiUrl: "http://localhost:1880"

  apiGateway:
    adapter: "traefik"  # Automatic service discovery
    adminUrl: "http://localhost:8080"
```

##### 8.9.3.2 Dependency Injection Container

```typescript
/**
 * Infrastructure factory for creating adapters based on configuration
 */
class InfrastructureFactory {
  constructor(private config: InfrastructureConfig) {}

  /**
   * Create time-series database adapter
   */
  createTimeSeriesStore(): ITimeSeriesStore {
    switch (this.config.database.adapter) {
      case 'timescaledb':
        return new TimescaleDBAdapter(this.config.database.connection);

      case 'influxdb':
        return new InfluxDBAdapter(this.config.database.connection);

      case 'questdb':
        return new QuestDBAdapter(this.config.database.connection);

      case 'prometheus':
        return new PrometheusAdapter(this.config.database.connection);

      default:
        throw new Error(`Unknown database adapter: ${this.config.database.adapter}`);
    }
  }

  /**
   * Create message broker adapter
   */
  createMessageBroker(): IMessageBroker {
    switch (this.config.messageBroker.adapter) {
      case 'kafka':
        return new KafkaMessageBroker(this.config.messageBroker.brokers, this.config.messageBroker.config);

      case 'nats':
        return new NATSMessageBroker(this.config.messageBroker.brokers);

      case 'mqtt':
        return new MQTTMessageBroker(this.config.messageBroker.brokers[0]);

      case 'rabbitmq':
        return new RabbitMQMessageBroker(this.config.messageBroker.brokers[0]);

      default:
        throw new Error(`Unknown message broker: ${this.config.messageBroker.adapter}`);
    }
  }

  /**
   * Create gateway adapter
   */
  createGatewayAdapter(): IGatewayAdapter {
    switch (this.config.gateway.adapter) {
      case 'edgex':
        return new EdgeXGatewayAdapter(
          this.config.gateway.apiUrl,
          this.config.gateway.credentials
        );

      case 'thingsboard':
        return new ThingsBoardGatewayAdapter(
          this.config.gateway.apiUrl,
          this.config.gateway.credentials
        );

      case 'node-red':
        return new NodeREDGatewayAdapter(this.config.gateway.apiUrl);

      default:
        throw new Error(`Unknown gateway adapter: ${this.config.gateway.adapter}`);
    }
  }

  /**
   * Create API gateway adapter
   */
  createAPIGateway(): IAPIGateway {
    switch (this.config.apiGateway.adapter) {
      case 'kong':
        return new KongAPIGatewayAdapter(this.config.apiGateway.adminUrl);

      case 'traefik':
        return new TraefikAPIGatewayAdapter(this.config.apiGateway.adminUrl);

      case 'envoy':
        return new EnvoyAPIGatewayAdapter(this.config.apiGateway.adminUrl);

      default:
        throw new Error(`Unknown API gateway: ${this.config.apiGateway.adapter}`);
    }
  }
}

/**
 * Application bootstrap
 */
class Application {
  private timeSeriesStore: ITimeSeriesStore;
  private messageBroker: IMessageBroker;
  private gatewayAdapter: IGatewayAdapter;
  private apiGateway: IAPIGateway;

  async initialize() {
    // Load configuration from environment
    const config = await loadConfig(process.env.NODE_ENV || 'production');

    // Create infrastructure components
    const factory = new InfrastructureFactory(config.infrastructure);

    this.timeSeriesStore = factory.createTimeSeriesStore();
    this.messageBroker = factory.createMessageBroker();
    this.gatewayAdapter = factory.createGatewayAdapter();
    this.apiGateway = factory.createAPIGateway();

    // Initialize services with dependencies
    const telemetryService = new TelemetryService(
      this.timeSeriesStore,
      this.messageBroker
    );

    const deviceService = new DeviceService(
      this.gatewayAdapter,
      this.messageBroker
    );

    const kpiService = new KPIService(this.timeSeriesStore);

    // Start application
    await this.messageBroker.connect();
    await this.startServices();
  }
}
```

---

#### 8.9.4 Testing Strategies

##### 8.9.4.1 Mock Adapters for Unit Tests

```typescript
/**
 * In-memory mock for time-series database (no external dependencies)
 */
class MockTimeSeriesStore implements ITimeSeriesStore {
  private metrics: Metric[] = [];

  async write(metric: Metric): Promise<void> {
    this.metrics.push({ ...metric });
  }

  async writeBatch(metrics: Metric[]): Promise<void> {
    this.metrics.push(...metrics);
  }

  async query(params: TimeSeriesQuery): Promise<Metric[]> {
    return this.metrics.filter(m =>
      m.timestamp >= params.startTime &&
      m.timestamp <= params.endTime &&
      (!params.deviceIds || params.deviceIds.includes(m.deviceId))
    ).slice(0, params.limit || 1000);
  }

  async aggregate(params: AggregationQuery): Promise<AggregatedMetric> {
    const metrics = await this.query(params);
    const values = metrics.map(m => Number(m.value));

    switch (params.aggregationType) {
      case 'AVG':
        return { value: values.reduce((a, b) => a + b, 0) / values.length };
      case 'MAX':
        return { value: Math.max(...values) };
      case 'MIN':
        return { value: Math.min(...values) };
      default:
        return { value: 0 };
    }
  }

  async delete(params: DeletionCriteria): Promise<void> {
    this.metrics = this.metrics.filter(m => m.deviceId !== params.deviceId);
  }

  // Test helper methods
  reset(): void {
    this.metrics = [];
  }

  getMetricCount(): number {
    return this.metrics.length;
  }
}

/**
 * Mock message broker (synchronous, in-memory)
 */
class MockMessageBroker implements IMessageBroker {
  private handlers = new Map<string, MessageHandler[]>();
  private connected = false;

  async connect(): Promise<void> {
    this.connected = true;
  }

  async publish(topic: string, message: Message): Promise<void> {
    if (!this.connected) throw new Error('Not connected');

    const handlers = this.handlers.get(topic) || [];
    for (const handler of handlers) {
      await handler(message);
    }
  }

  async subscribe(topic: string, handler: MessageHandler): Promise<string> {
    if (!this.handlers.has(topic)) {
      this.handlers.set(topic, []);
    }
    this.handlers.get(topic)!.push(handler);
    return `sub-${topic}-${Date.now()}`;
  }

  async unsubscribe(subscriptionId: string): Promise<void> {
    // Simplified: clear all handlers
    this.handlers.clear();
  }

  async disconnect(): Promise<void> {
    this.connected = false;
    this.handlers.clear();
  }

  // Test helper
  isConnected(): boolean {
    return this.connected;
  }
}

/**
 * Example unit test using mock adapters
 */
describe('TelemetryService', () => {
  let service: TelemetryService;
  let mockStore: MockTimeSeriesStore;
  let mockBroker: MockMessageBroker;

  beforeEach(() => {
    mockStore = new MockTimeSeriesStore();
    mockBroker = new MockMessageBroker();
    service = new TelemetryService(mockStore, mockBroker);
  });

  it('should store incoming telemetry', async () => {
    const metric: Metric = {
      deviceId: 'device-123',
      metricName: 'temperature',
      value: 23.5,
      timestamp: new Date()
    };

    await service.recordMetric(metric);

    const stored = await mockStore.query({
      deviceIds: ['device-123'],
      startTime: new Date(Date.now() - 60000),
      endTime: new Date()
    });

    expect(stored).toHaveLength(1);
    expect(stored[0].value).toBe(23.5);
  });

  it('should publish alerts when threshold exceeded', async () => {
    let publishedAlert: any = null;

    await mockBroker.subscribe('alerts', (msg) => {
      publishedAlert = msg.payload;
    });

    const metric: Metric = {
      deviceId: 'device-123',
      metricName: 'temperature',
      value: 50,  // Exceeds threshold
      timestamp: new Date()
    };

    await service.recordMetric(metric);

    expect(publishedAlert).not.toBeNull();
    expect(publishedAlert.deviceId).toBe('device-123');
    expect(publishedAlert.alertType).toBe('temperature_high');
  });
});
```

##### 8.9.4.2 Integration Tests (Testcontainers)

```typescript
/**
 * Integration tests using real databases via Testcontainers
 */
describe('TimescaleDBAdapter Integration', () => {
  let container: StartedTestContainer;
  let adapter: TimescaleDBAdapter;

  beforeAll(async () => {
    // Start TimescaleDB in Docker container
    container = await new GenericContainer('timescale/timescaledb:latest-pg15')
      .withExposedPorts(5432)
      .withEnvironment({
        POSTGRES_PASSWORD: 'test',
        POSTGRES_DB: 'test'
      })
      .start();

    const pool = new pg.Pool({
      host: container.getHost(),
      port: container.getMappedPort(5432),
      database: 'test',
      user: 'postgres',
      password: 'test'
    });

    // Initialize schema
    await pool.query(`
      CREATE TABLE IF NOT EXISTS metrics (
        device_id TEXT,
        metric_name TEXT,
        value DOUBLE PRECISION,
        timestamp TIMESTAMPTZ,
        tags JSONB
      );
      SELECT create_hypertable('metrics', 'timestamp', if_not_exists => TRUE);
    `);

    adapter = new TimescaleDBAdapter(pool);
  });

  afterAll(async () => {
    await container.stop();
  });

  it('should write and query metrics', async () => {
    const metric: Metric = {
      deviceId: 'device-123',
      metricName: 'temperature',
      value: 23.5,
      timestamp: new Date(),
      tags: { location: 'floor_3' }
    };

    await adapter.write(metric);

    const results = await adapter.query({
      deviceIds: ['device-123'],
      startTime: new Date(Date.now() - 60000),
      endTime: new Date()
    });

    expect(results).toHaveLength(1);
    expect(results[0].value).toBe(23.5);
    expect(results[0].tags?.location).toBe('floor_3');
  });

  it('should perform aggregations correctly', async () => {
    // Insert test data
    const metrics: Metric[] = Array.from({ length: 10 }, (_, i) => ({
      deviceId: 'device-123',
      metricName: 'temperature',
      value: 20 + i,
      timestamp: new Date(Date.now() - i * 60000)
    }));

    await adapter.writeBatch(metrics);

    const result = await adapter.aggregate({
      deviceIds: ['device-123'],
      metricNames: ['temperature'],
      startTime: new Date(Date.now() - 600000),
      endTime: new Date(),
      aggregationType: 'AVG'
    });

    expect(result.value).toBeCloseTo(24.5, 1);
  });
});
```

---

#### 8.9.5 Migration Playbooks

**Scenario:** Migrate from lightweight MQTT (PoC) to enterprise Kafka (production) without downtime.

##### 8.9.5.1 Pre-Migration Checklist

| Step | Action | Verification |
|------|--------|--------------|
| 1 | Deploy Kafka cluster (3+ brokers) | `kafka-topics.sh --list` |
| 2 | Create topics with appropriate partitions | `kafka-topics.sh --describe` |
| 3 | Deploy new KafkaMessageBroker adapter | Unit tests pass |
| 4 | Configure dual-write (MQTT + Kafka) | Monitor both brokers |
| 5 | Verify data consistency | Compare message counts |
| 6 | Switch consumers to Kafka | Monitor lag |
| 7 | Disable MQTT writes | Final data reconciliation |
| 8 | Decommission MQTT broker | Archive logs |

##### 8.9.5.2 Dual-Write Pattern (Zero Downtime)

```typescript
/**
 * Dual-write adapter for safe migration
 */
class DualWriteMessageBroker implements IMessageBroker {
  constructor(
    private primary: IMessageBroker,    // New broker (Kafka)
    private secondary: IMessageBroker,  // Old broker (MQTT)
    private mode: 'dual-write' | 'primary-only' = 'dual-write'
  ) {}

  async publish(topic: string, message: Message, options?: PublishOptions): Promise<void> {
    // Always write to primary
    await this.primary.publish(topic, message, options);

    // Write to secondary during migration phase
    if (this.mode === 'dual-write') {
      try {
        await this.secondary.publish(topic, message, options);
      } catch (error) {
        // Log error but don't fail (secondary is being phased out)
        console.warn('Secondary broker write failed:', error);
      }
    }
  }

  async subscribe(topic: string, handler: MessageHandler): Promise<string> {
    // Subscribe only to primary
    return this.primary.subscribe(topic, handler);
  }

  // Delegate other methods to primary
  async connect(): Promise<void> {
    await this.primary.connect();
    if (this.mode === 'dual-write') {
      await this.secondary.connect();
    }
  }

  async disconnect(): Promise<void> {
    await this.primary.disconnect();
    if (this.mode === 'dual-write') {
      await this.secondary.disconnect();
    }
  }
}

/**
 * Configuration for migration
 */
const migrationConfig = {
  infrastructure: {
    messageBroker: {
      adapter: 'dual-write',
      primary: {
        adapter: 'kafka',
        brokers: ['kafka-1:9092', 'kafka-2:9092', 'kafka-3:9092']
      },
      secondary: {
        adapter: 'mqtt',
        brokers: ['mqtt://mosquitto:1883']
      },
      mode: 'dual-write'  // Change to 'primary-only' after verification
    }
  }
};
```

##### 8.9.5.3 Database Migration (TimescaleDB → QuestDB)

```bash
#!/bin/bash
# Migration script: TimescaleDB to QuestDB

set -e

echo "Step 1: Export data from TimescaleDB"
psql -h timescale-host -U postgres -d nexus -c "
  COPY (
    SELECT device_id, metric_name, value, timestamp, tags
    FROM metrics
    WHERE timestamp >= NOW() - INTERVAL '30 days'
  ) TO STDOUT WITH CSV HEADER
" > metrics_export.csv

echo "Step 2: Transform CSV for QuestDB (if needed)"
# QuestDB accepts CSV with specific timestamp format
python3 transform_timestamps.py metrics_export.csv > metrics_questdb.csv

echo "Step 3: Import into QuestDB via HTTP"
curl -F data=@metrics_questdb.csv 'http://questdb-host:9000/imp?name=metrics'

echo "Step 4: Verify row count"
TIMESCALE_COUNT=$(psql -h timescale-host -U postgres -d nexus -t -c "SELECT COUNT(*) FROM metrics")
QUESTDB_COUNT=$(curl -G 'http://questdb-host:9000/exec' --data-urlencode "query=SELECT COUNT(*) FROM metrics" | jq '.dataset[0][0]')

if [ "$TIMESCALE_COUNT" -eq "$QUESTDB_COUNT" ]; then
  echo "✅ Migration successful: $TIMESCALE_COUNT rows migrated"
else
  echo "❌ Migration failed: TimescaleDB=$TIMESCALE_COUNT, QuestDB=$QUESTDB_COUNT"
  exit 1
fi

echo "Step 5: Update application config to use QuestDB"
kubectl set env deployment/nexus-telemetry DB_ADAPTER=questdb DB_HOST=questdb-host

echo "Step 6: Monitor application logs for errors"
kubectl logs -f deployment/nexus-telemetry --since=5m
```

---

#### 8.9.6 Real-World Example: BCA KPI Service (Infrastructure-Agnostic)

```typescript
/**
 * BCA KPI Service - demonstrates infrastructure independence
 * Works with ANY database/broker adapter
 */
class BCAKPIService {
  constructor(
    private timeSeriesStore: ITimeSeriesStore,  // Interface, not concrete implementation
    private messageBroker: IMessageBroker       // Interface, not concrete implementation
  ) {}

  /**
   * Calculate TFPE (Technical Faults Per Equipment)
   * BCA Annex A requirement
   */
  async calculateTFPE(
    deviceIds: string[],
    startDate: Date,
    endDate: Date
  ): Promise<number> {
    // Query faults from time-series database (adapter-agnostic)
    const faults = await this.timeSeriesStore.query({
      deviceIds,
      metricNames: ['fault_event'],
      startTime: startDate,
      endTime: endDate
    });

    // Filter technical faults (exclude vandalism, water ingress, etc.)
    const technicalFaults = faults.filter(fault =>
      fault.tags?.fault_category === 'technical'
    );

    const months = (endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24 * 30);
    return technicalFaults.length / deviceIds.length / months;
  }

  /**
   * Calculate MTTR (Mean Time To Repair)
   * BCA Annex A requirement
   */
  async calculateMTTR(
    deviceIds: string[],
    startDate: Date,
    endDate: Date
  ): Promise<number> {
    const repairDurations = await this.timeSeriesStore.aggregate({
      deviceIds,
      metricNames: ['repair_duration_hours'],
      startTime: startDate,
      endTime: endDate,
      aggregationType: 'AVG'
    });

    return repairDurations.value;
  }

  /**
   * Publish KPI alert when threshold exceeded
   */
  async publishKPIAlert(kpiType: string, value: number, threshold: number): Promise<void> {
    if (value > threshold) {
      await this.messageBroker.publish('kpi.alerts', {
        payload: {
          kpiType,
          value,
          threshold,
          timestamp: new Date(),
          severity: 'warning'
        }
      });
    }
  }

  /**
   * Generate BCA compliance report
   * Works with ANY database adapter (TimescaleDB, InfluxDB, QuestDB)
   */
  async generateComplianceReport(
    buildingId: string,
    month: Date
  ): Promise<BCAComplianceReport> {
    const deviceIds = await this.getDevicesByBuilding(buildingId);
    const startDate = new Date(month.getFullYear(), month.getMonth(), 1);
    const endDate = new Date(month.getFullYear(), month.getMonth() + 1, 0);

    const [tfpe, mttr, fttr, availability] = await Promise.all([
      this.calculateTFPE(deviceIds, startDate, endDate),
      this.calculateMTTR(deviceIds, startDate, endDate),
      this.calculateFTTR(deviceIds, startDate, endDate),
      this.calculateAvailability(deviceIds, startDate, endDate)
    ]);

    return {
      buildingId,
      month: month.toISOString(),
      kpis: {
        tfpe: { value: tfpe, target: 0.5, status: tfpe < 0.5 ? 'pass' : 'fail' },
        mttr: { value: mttr, target: 2, status: mttr < 2 ? 'pass' : 'fail' },
        fttr: { value: fttr, target: 85, status: fttr > 85 ? 'pass' : 'fail' },
        availability: { value: availability, target: 99, status: availability > 99 ? 'pass' : 'fail' }
      },
      generatedAt: new Date()
    };
  }
}

/**
 * Application bootstrap - infrastructure tools selected via config
 */
async function bootstrap() {
  const config = await loadConfig();
  const factory = new InfrastructureFactory(config.infrastructure);

  // Create adapters (concrete implementations determined at runtime)
  const timeSeriesStore = factory.createTimeSeriesStore();
  const messageBroker = factory.createMessageBroker();

  // Inject dependencies (business logic is infrastructure-agnostic)
  const bcaKPIService = new BCAKPIService(timeSeriesStore, messageBroker);

  // Service works identically whether using TimescaleDB or QuestDB,
  // Kafka or NATS, EdgeX or ThingsBoard
  const report = await bcaKPIService.generateComplianceReport('SG001', new Date());
  console.log(report);
}
```

---

#### 8.9.7 Benefits Summary

| Benefit | Without Abstraction | With Abstraction (Ports & Adapters) |
|---------|---------------------|-------------------------------------|
| **Tool Replacement** | Rewrite all business logic | Change 1 config line + deploy new adapter |
| **Testing** | Requires real infrastructure | Mock adapters, no external dependencies |
| **Multi-Cloud** | Vendor lock-in | Deploy different adapters per region |
| **Scaling** | Forced to scale vertically | Switch from Mosquitto → Kafka seamlessly |
| **Migration** | High risk, long downtime | Gradual, zero-downtime (dual-write pattern) |
| **Team Onboarding** | Learn tool-specific APIs | Learn standard interfaces once |
| **Vendor Negotiation** | No leverage | "We can switch to competitor in 1 week" |

---

#### 8.9.8 License Compliance for Adapter Implementations

All adapter implementations use **commercially permissive** clients:

| Component | Client Library | License | Commercial Use |
|-----------|---------------|---------|----------------|
| **TimescaleDB** | `pg` (node-postgres) | MIT | ✅ Unrestricted |
| **InfluxDB** | `@influxdata/influxdb-client` | MIT | ✅ Unrestricted |
| **QuestDB** | `@questdb/nodejs-client` | Apache 2.0 | ✅ Unrestricted |
| **Kafka** | `kafkajs` | MIT | ✅ Unrestricted |
| **NATS** | `nats.ws` | Apache 2.0 | ✅ Unrestricted |
| **MQTT** | `mqtt` | MIT | ✅ Unrestricted |
| **Kong** | `@kong/admin-client` | Apache 2.0 | ✅ Unrestricted |
| **Traefik** | HTTP API (no client) | N/A | ✅ Unrestricted |

---

#### 8.9.9 Implementation Roadmap

**Phase 1: Define Interfaces (Week 1-2)**
- Define `ITimeSeriesStore`, `IMessageBroker`, `IGatewayAdapter`, `IAPIGateway`
- Document interface contracts (input/output schemas)
- Create TypeScript/Go/Python interface definitions

**Phase 2: Implement Initial Adapters (Week 3-6)**
- Implement 2 adapters per interface (e.g., TimescaleDB + InfluxDB)
- Write unit tests using mock adapters
- Write integration tests using Testcontainers

**Phase 3: Refactor Business Logic (Week 7-10)**
- Refactor services to depend on interfaces, not implementations
- Inject dependencies via configuration
- Validate with existing integration tests

**Phase 4: Add Configuration Layer (Week 11-12)**
- Implement `InfrastructureFactory`
- Create environment-specific configs (dev, staging, prod)
- Document adapter selection decision tree

**Phase 5: Migration Validation (Week 13-14)**
- Test migration from lightweight → enterprise tools
- Document migration playbooks
- Conduct load testing with different adapters

---


---

**Next:** [Part 5D: Technology Stack & Resource Sizing](ARCH5D_TECH_STACK.md) - Specific technology recommendations, resource sizing, glossary
