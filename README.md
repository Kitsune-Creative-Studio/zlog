# ZLOG - Zig Logger

Structured, async, multi-sink logger for Zig 0.15+

---

## Features

-   5/6 log levels: FATAL, ERROR, WARN, INFO, DEBUG (customizable)
-   File logging: single file per run, rotating by size/count/time
-   Structured JSON output (machine-parsable)
-   Timestamps (ISO-8601, monotonic)
-   Context/fields, tags, and custom key-value pairs
-   Formatters: pretty console, JSON
-   Async I/O: thread-safe queue, background worker, flush/shutdown
-   Sampling: fixed-rate, probabilistic, dynamic (by level/tags/pattern)
-   Log filtering and runtime config
-   Error handling: never panic, status return, last error query
-   Child loggers, inheritance, and trace/span propagation
-   Secrets redaction (configurable fields, masking)
-   Multiple sinks (console, file, remote-ready)
-   Traces and spans: auto-generation, propagation, API
-   Flush and shutdown API

---

## Example Log Output

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

---

## Usage

### Add as dependency (Zig 0.15+)

Add to your `build.zig.zon`:

```zig
.dependencies = .{
    .zlog = .{
        .url = "git+https://github.com/Kitsune-Creative-Studio/zlog/?ref=HEAD#commit",
        .hash = "zlog-0.0.1-...",
    },
}
```

In your `build.zig`:

```zig
const package = b.dependency("zlog", .{
    .target = target,
    .optimize = optimize,
});
const module = package.module("zlog");
exe.root_module.addImport("zlog", module);
```

In your code:

```zig
const zlog = @import("zlog");
```

---

## Build & Test

-   Zig version: **0.15.1** (or compatible)
-   Build: `zig build`
-   Run demo: `zig build run`
-   Build demo: `zig build -Dinstall-demo`
-   Run all tests: `zig build test`

---

## Project Structure

```
/ (root)
  build.zig
  build.zig.zon
  README.md
  LICENSE
  src/
    main.zig
    ...
  tests/
    integration.zig
    ...
```

---

## Security & Performance

-   Secrets redaction before output (configurable fields)
-   No panics on logging errors
-   Async logging for high throughput
-   Performance targets:
    -   10k logs to terminal: ≤3s
    -   10k logs to file: ≤500ms
    -   10k logs to multiple sinks: ≤3s

---

## Roadmap

-   [ ] Core logger with log levels and file/console sinks
-   [ ] Structured JSON and pretty output
-   [ ] Async I/O and flush/shutdown
-   [ ] Sampling (fixed, probabilistic, dynamic)
-   [ ] Error handling and status API
-   [ ] Child loggers and context
-   [ ] Traces and spans API
-   [ ] Secrets redaction
-   [ ] Remote sink support (HTTP, etc.)
-   [ ] Dynamic runtime config reload
-   [ ] More advanced sampling strategies
-   [ ] CLI tools for log analysis
-   [ ] Benchmarks and performance tuning
-   [ ] More integration tests and CI
-   [ ] Documentation site

---

## Documentation & Links

-   [Zig Documentation](https://ziglang.org/documentation/0.15.1)
-   [Zig std documentation](https://ziglang.org/documentation/0.15.1/std)
-   [Zig GitHub](https://github.com/ziglang/zig)

---

## License

GNU GENERAL PUBLIC LICENSE Version 3
