# Copilot Instruction File

This file is for providing instructions, documentation links, and notes for GitHub Copilot to reference during development of your SatisfactoryTools project.

## How to Use

-   Add URLs to documentation, release notes, or code repositories you want Copilot to fetch and use.
-   Add specific instructions, requirements, or clarifications for your project.
-   When you want Copilot to use a resource, mention the URL or instruction explicitly in your request.

## Project - ZLOG - Zig Logger

This project is custom logger for my future zig projects, its gonna be as zig package, i want the logger contain 5/6 log levels (FATAL, ERROR, WARN, INFO, DEBUG), have option to log to file with those options:

-   1 file per run
-   rotating file after x amount of logs or x amount of size or x amount of time
-   structured output (JSON key-value) so logs are machine-parsable Example:

```json
{
    "timestamp": "2023-10-01T12:00:00Z",
    "level": "INFO",
    "logger": "child.customName",
    "message": "User logged in",
    "tags": ["auth", "user"],
    "service": "auth-service",
    "version": "1.0.0",
    "env": "production",
    "pid": 12345,
    "host": "server01",
    "caller": {
        "file": "src/main.zig",
        "line": 42,
        "function": "main"
    },
    "trace": {
        "trace_id": "abcd1234efgh5678",
        "span_id": "ijkl9012mnop3456",
        "parent_span_id": "qrst7890uvwx1234"
    },
    "error": {
        "type": "AuthenticationError",
        "message": "Invalid credentials",
        "stack": "stack trace here"
    },
    "kwargs": { "userId": 67890, "ipAddress": "*.*.*.*" },
    "args": ["additional", "context", "info"],
    "duration_ms": 15
}
```

I also want the logger to contain:

-   Timestamps and maybe monotonic time (ISO-8601)
-   Context/fields
-   Formatters
-   Async I/O, Implementations:
    -   Thread-safe queue
    -   New thread where async enabled
    -   Thread for flushing queue to sinks
    -   Flush and shutdown handling
-   Sampling, Implementations:
    -   Implement at filter level
    -   Config set as filter
    -   Fixed-rate sampling
        -   Log every Nth message
        ```json
        {
            "type": "sampling",
            "method": "fixed",
            "rate": 10
        }
        ```
    -   Probabilistic sampling
        -   Log each message with probability p
        ```json
        {
            "type": "sampling",
            "method": "probabilistic",
            "probability": 0.1
        }
        ```
    -   Dynamic sampling based on log level or tags
        -   Sample based on:
            -   Log level
            -   Presence of specific tags
            -   Message content patterns (e.g., error codes)
            -   Time intervals (e.g., at least one log every N seconds)
            ```json
            {
                "type": "sampling",
                "method": "dynamic",
                "rules": [
                    { "level": "ERROR", "rate": 1 }, // Log all ERRORs
                    { "level": "WARN", "rate": 5 }, // Log 1 in 5 WARNs
                    { "tags": ["auth"], "rate": 2 }, // Log 1 in 2 messages with 'auth' tag
                    { "pattern": "timeout", "rate": 3 }, // Log 1 in 3 messages containing 'timeout'
                    { "min_interval_ms": 1000, "rate": 10 } // At least 1 log every second, sample others at rate of 10
                ]
            }
            ```
-   Log filtering
-   Error handling: Don't throw on logging:
    ```zig
    const LoggerError = error{
        QueueFull,
        IoError,
        FormatError,
        InvalidConfig,
        Unknown,
    };
    ```
    -   Handle errors internally and gracefully
    -   Return status bool on successful queueing on log call
    ```zig
    const status: bool = zlog.log(entry);
    if (!status) {
        // Optionally handle log failure (e.g., increment a metric, print to stderr)
    }
    ```
    -   Provide method to get last error
    ```zig
    const lastError: ?LoggerError = zlog.getLastError();
    ```
    -   If logging fails, optionally print to stderr and save error state
-   Runtime config
-   Pretty console output
-   Child loggers
-   Secrets redaction example:

```json
{
    "password": "********",
    "apiKey": "********"
}
```

-   Config load as JSON example:

```json
{
    "level": "DEBUG",
    "sinks": [
        {
            "type": "console",
            "level": "INFO",
            "format": "pretty",
            "error_report": false,
            "async": true
        },
        {
            "type": "file",
            "level": "DEBUG",
            "format": "json",
            "path": "/var/log/myapp.log",
            "rotation": {
                "size_mb": 100,
                "time": "1d",
                "line-count": 7,
                "max-files": 5,
                "FATAL": {
                    "size_mb": 50,
                    "time": "30d",
                    "line-count": 23,
                    "max-files": 10
                }
            },
            "error_report": true,
            "async": true
        }
    ],
    "error_report": {
        "type": "console",
        "level": "ERROR",
        "format": "pretty",
        "async": true
    },
    "format": {
        "type": "json",
        "timestamp_format": "ISO-8601",
        "include_caller": true,
        "include_trace": true,
        "include_error": true,
        "include_pid": true,
        "include_host": true,
        "include_duration": true,
        "include_tags": true,
        "include_args": true,
        "include_kwargs": true
    },
    "filters": [
        {
            "type": "tag",
            "include": ["auth", "payment"],
            "exclude": ["debug"]
        },
        {
            "type": "sampling",
            "method": "fixed",
            "rate": 10
        }
    ],
    "loggers": {
        "customName": {
            "level": "DEBUG",
            "tags": ["child"],
            "child_loggers": {
                "child": {
                    "level": "TRACE",
                    "tags": ["custom"],
                    "async_filter": true,
                    "filters": [
                        {
                            "type": "ars",
                            "include": ["special"],
                            "exclude": ["boring"]
                        }
                    ]
                }
            }
        }
    },
    "redaction": {
        "fields": ["password", "apiKey", "secret"],
        "mask": "********"
    },
    "context": {
        "service": "auth-service",
        "version": "1.0.0",
        "env": "production"
    }
}
```

-   Creating Custom log levels
-   Outputting only enabled log levels (e.g. FATAL and DEBUG only)
-   Multiple sinks
-   Possible future remote sinks
-   Stdout to terminal with toggle async logging
-   Traces and spans auto generating with user options to set:
    -   User can start trace/span with IDs or auto-generated
    ```zig
    const traceId = "abcd1234efgh5678";
    const spanId = "ijkl9012mnop3456";
    id: []const u8 = zlog.startTrace(traceId = traceId, spanId = spanId); // start trace with specific IDs
    id: []const u8 = zlog.startTrace(spanId = spanId); // auto-generate trace ID
    id: []const u8 = zlog.startTrace(traceId = traceId); // auto-generate span ID
    id: []const u8 = zlog.startTrace(); // auto-generate IDs
    id: []const u8 = zlog.startSpan(spanId = spanId);
    id: []const u8 = zlog.startSpan();  // auto-generate span ID
    id: []const u8 = childLogger.startSpan();  // new span in child logger
    ```
    -   User can end trace/span
    ```zig
    id: []const u8 = zlog.endTrace(traceId); // end specific trace
    id: []const u8 = zlog.endTrace(); // end current trace
    id: []const u8 = zlog.endSpan(spanId); // end specific span
    id: []const u8 = childLogger.endSpan(); // end current span in child logger
    ```
    -   Every log message have included current trace ID, span ID and parent span ID if any
    -   Auto-generate Trace when starting application or when child logger created and user specify that new trace needed
    ```zig
    const mainLogger = zlog.createLogger("main");
    const childLogger = mainLogger.createChildLogger("child", newTrace=true);
    ```
    -   Auto-generate Span when user start new span or when child logger created and user specify that new span needed
    ```zig
    const mainLogger = zlog.createLogger("main");
    const childLogger = mainLogger.createChildLogger("child", newSpan=true);
    ```
    -   User can enable option to generate new span for every new function call
    ```zig
    const mainLogger = zlog.createLogger("main", autoSpan=true);
    const childLogger = mainLogger.createChildLogger("child", autoSpan=true);
    ```
-   Flush and shutdown function example:

```zig
flushStatus: bool = zlog.flush();           // Flush all loggers and sinks and return status
flushStatus: bool = mainLogger.flush();     // Flush only main Logger
flushStatus: bool = childLogger.flush();    // Flush only child Logger
flushStatus: bool = zlog.shutdown();        // Flush and prepare for shutdown all loggers and sinks and return status
```

### Security considerations for secrets redaction

-   Automatically detecting and masking known secret fields in log messages.
-   Providing a way to configure which fields/keys are considered secrets.
-   Ensuring redaction happens before logs are written to disk or sent to remote sinks.
-   Avoiding accidental exposure in pretty console output or structured logs.

### Performance requirements

-   Logging 10k messages in max 3 seconds with to terminal
-   Logging 10k messages in max 100ms format only
-   Logging 10k to file in max 500ms
-   Logging 10k to http sink in max 2 seconds
-   Logging 10k to multiple sinks in max 3 seconds
-   Logging 10k to Rotating file 1K in max 600ms

### Pipeline example

```
Code -> Main Logger -> Async -> Filter -> Handler -> Formatter -> Sink
Code -> Main Logger -> Async -> Filter -> Handler -> Formatter -> Batch -> Remote Sink
Code -> Child Logger -> Main Logger -> Async -> Filter -> Handler -> Formatter -> Sink
Code -> Child Logger -> Async filter -> Main Logger -> Async -> Filter -> Handler -> Formatter -> Sink
Code -> Child Logger -> Child Logger -> Main Logger -> Async -> Filter -> Handler -> Formatter -> Sink
```

TODO: Build file Guidelines

### Project Structure

```
/.github/
    copilot_instructions.md     # Your instructions, links, notes for Copilot
/build.zig                      # File defining build options
/build.zig.zon                  # Zig package manager file
/README.md
/src/
    main.zig                    # Entry point, CLI dispatcher
/tests/
```

### Language

-   Zig - version 0.15.1
-   **OOP Design**: Use Object-Oriented Programming principles in Zig
-   No libraries, prefer std lib

### OOP Implementation Guidelines

#### Core Patterns

-   **Structs with Methods**: Domain objects (Item, Recipe, ProductionChain) should be structs with associated methods
-   **Interface Pattern**: Use vtables and function pointers for polymorphic behavior (especially optimizers)
-   **Composition**: Prefer composition over inheritance; ProductionChain should compose Items, Recipes, and Constraints
-   **Encapsulation**: Each object manages its own data and provides clean public APIs

#### Example Structure

```zig
// Domain object with methods
const Item = struct {
    id: []const u8,
    name: []const u8,

    pub fn init(id: []const u8, name: []const u8) Self { ... }
    pub fn isFluid(self: Self) bool { ... }
};

// Composition in main objects
const ProductionChain = struct {
    items: ArrayList(Item),
    recipes: ArrayList(Recipe),
    constraints: UserConstraints,

    pub fn optimize(self: *Self, optimizer: Optimizer) Result { ... }
};
```

## Development Approach

### Test-Driven Development (TDD)

-   **Write tests first**: Create unit tests before implementing any logic
-   **Example**: Write parser tests before implementing the parser
-   **Red-Green-Refactor**: Write failing test → Make it pass → Refactor
-   **Test structure**: Use Zig's built-in testing framework (`test` blocks)

TODO: Testing Guidelines

### Naming Conventions

Follow these strict naming rules:

1. **Don't abbreviate names**

    - ❌ `calc`, `str`, `num`, `min`, `max`
    - ✅ `calculate`, `string`, `number`, `minimum`, `maximum`

2. **Don't put types in variable names**

    - ❌ `itemList`, `nameString`, `countInt`
    - ✅ `items`, `name`, `count`

3. **Add units to variables unless the type tells you**

    - ❌ `duration` (unclear if seconds, minutes, etc.)
    - ✅ `duration_seconds`, `power_megawatts`, `rate_per_minute`
    - ✅ `delay: TimeSpan` (type encodes the unit, use `delay.seconds()` in function)

4. **Don't put types in your types**

    - ❌ `AbstractOptimizer`, `BaseParser`, `ItemInterface`
    - ✅ `Optimizer`, `Parser`, `Item`
    - **Exception for interfaces**: Use "I" prefix for interfaces
        - ✅ `IItem`, `IOptimizer`, `IParser`

5. **Refactor if you find yourself naming code "Utils"**

    - ❌ `JsonUtils`, `MathUtils`, `StringUtils`
    - ✅ `JsonReader`, `Calculator`, `TextFormatter`

6. **Use consistent naming patterns**

    - Use `getX`, `setX` for getters/setters
    - Use `isX`, `hasX` for boolean checks
    - Use `toX`, `fromX` for conversions

7. **Naming Patterns**
    - Use UPPERCASE for constants: `const MAX_RETRIES = 5;`
    - Use camelCase for variables and functions: `var itemCount = 10;`, `fn calculateTotal() { ... }`
    - Use PascalCase for types, classes, and structs: `const ProductionChain = struct { ... };`
    - Use snake_case for file names: `production_chain.zig`, `item.zig`
    - Use dash-case for keys, config options, and CLI arguments: `--log-level`, `file-path`

## Zig info

### Release Notes

-   15.1 -> https://ziglang.org/download/0.15.1/release-notes.html
-   14.0 -> https://ziglang.org/download/0.14.0/release-notes.html
-   13.0 -> https://ziglang.org/download/0.13.0/release-notes.html

### Other

-   Documentation -> https://ziglang.org/documentation/0.15.1
-   Zig std documentation -> https://ziglang.org/documentation/0.15.1/std
-   Zig github -> https://github.com/ziglang/zig
