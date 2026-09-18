---
name: eroad-db-access
description: Connect to EROAD PostgreSQL databases in DEV, TEST, APACPP, NAPP, APAC, or NA, including shared DB Depot/DB ESP and service-owned RDS databases. Use whenever the user asks to connect to an EROAD database, retrieve or decrypt an environment database password, configure DataGrip/PostgreSQL, or run SQL against an EROAD environment. Supports AWS SSO authentication, approved DB Depot credentials, dynamic-configuration discovery for service RDS connection profiles, safe read-only psql execution, and clear production/read-replica safeguards.
---

# EROAD database access

Use this workflow for EROAD PostgreSQL databases. Keep credentials out of files, shell history, logs, and durable memory.

There are two credential models. Identify the database family before retrieving credentials or attempting a connection:

| Database family | Examples | Connection profile |
|---|---|---|
| **Shared DB Depot / DB ESP** | `central`, `postgres`, `espdb` | The environment-specific `developer` credential documented on the Engineer DB Credentials page. |
| **Service-owned RDS** | `ifta`, `journey`, `geofence`, `authorisation`, `ams`, `dls` | A service-specific endpoint and a paired username/password profile from deployed dynamic configuration. Do not assume `developer`, a service application user, or any other username will work. |

Use the DB Depot / DB ESP guidance below only for the first row. Use the **Service RDS databases** section for the second row.

For DB Depot and DB ESP, retrieve the current encrypted credential from the approved Confluence page at runtime:

https://eroad.atlassian.net/wiki/spaces/TS/pages/2256110882/Engineer+db+credentials+-+dbdepot+and+dbesp+-+all+environments

The page is authoritative for those databases' encrypted credentials and KMS key IDs. Use the `developer` credential for normal DB Depot / DB ESP work. The `debug` role is restricted to approved production-incident troubleshooting.

## Environment mapping

| Environment | AWS region | KMS key ID |
|---|---|---|
| DEV | `ap-southeast-2` | `cddeacf2-f43f-49ca-bec6-e2acc09364dd` |
| TEST | `ap-southeast-2` | `cddeacf2-f43f-49ca-bec6-e2acc09364dd` |
| APACPP | `ap-southeast-2` | `a896bf46-ec3b-4b35-b406-1d2c32fa9837` |
| NAPP | `us-west-2` | `cc9c2e83-4dbb-4573-aa47-4ef0ad3507f1` |
| APAC | `ap-southeast-2` | `96240ed8-7a88-4cc3-a072-175c563baf06` |
| NA | `us-west-2` | `1f38b8d8-9666-4eaa-aab4-458f8e6c36cc` |

## Network reachability

**IMPORTANT — read before attempting any connectivity check or TCP probe:**

The reachable host varies per environment — do not assume `reporting` always exists or `active` is always blocked:

| Environment | Use this host | Notes |
|---|---|---|
| DEV | `dbdepotreporting.dev.erdmg.com` | reporting = CNAME to active; both reachable |
| TEST | `dbdepotreporting.test.erdmg.com` | reporting = replica; both reachable |
| APACPP | `dbdepotactive.apacpp.erdmg.com` | **reporting does NOT exist (NXDOMAIN)**; active IS reachable over VPN |
| NAPP | `dbdepotactive.napp.erdmg.com` | reporting does NOT exist; active may time out if environment is stopped (preprod — not always running) |
| APAC | `dbdepotreporting.apac.erdmg.com` | reporting reachable; active is on private subnet — do NOT use |
| NA | `dbdepotreporting.na.erdmg.com` | reporting reachable; active is on private subnet — do NOT use |

**If connectivity fails:** check VPN is connected via FortiClient before any further diagnosis. Do not attempt TCP probes on `*active` hosts for APAC/NA — they will always time out.

## Host and database defaults

For DB Depot / DB ESP, use port `5432` and user `developer` unless the user specifies otherwise.  
**Use the host from the Network Reachability table above — not necessarily `reporting`.**

| Environment | dbdepot read host | dbesp read host | Database |
|---|---|---|---|
| DEV | `dbdepotreporting.dev.erdmg.com` | `dbespactive.dev.erdmg.com` | `postgres` / `espdb` |
| TEST | `dbdepotreporting.test.erdmg.com` | `dbespactive.test.erdmg.com` | `postgres` / `espdb` |
| APACPP | `dbdepotactive.apacpp.erdmg.com` | `dbespactive.apacpp.erdmg.com` | `postgres` / `espdb` |
| NAPP | `dbdepotactive.napp.erdmg.com` | `dbespactive.napp.erdmg.com` | `postgres` / `espdb` |
| APAC | `dbdepotreporting.apac.erdmg.com` | `dbespreporting.apac.erdmg.com` | `postgres` / `espdb` |
| NA | `dbdepotreporting.na.erdmg.com` | `dbespreporting.na.erdmg.com` | `postgres` / `espdb` |

## Authenticate to AWS

Check the AWS profile before attempting KMS decryption:

```bash
rtk aws sts get-caller-identity --profile default
```

If the profile is missing SSO values, configure the existing EROAD SSO session:

```bash
rtk aws configure set profile.default.sso_start_url 'https://d-97675aea20.awsapps.com/start/#'
rtk aws configure set profile.default.sso_region 'ap-southeast-2'
rtk aws sso login --profile default
```

Use the browser/device-code flow and never ask the user to paste credentials or MFA codes into chat.

## Decrypt the password

**Always use the helper script** — it handles SSO session checks, credential export, KMS decryption, and local caching automatically:

```bash
~/.pi/agent/skills/eroad-db-access/get-db-password.sh <env>            # stdout
~/.pi/agent/skills/eroad-db-access/get-db-password.sh <env> --copy     # clipboard
~/.pi/agent/skills/eroad-db-access/get-db-password.sh <env> --refresh  # force re-decrypt
```

Passwords are cached at `~/.config/copilot/db-passwords/<env>.env` (chmod 600). On subsequent calls the cache is used and no AWS call is made. Use `--refresh` when a password has been rotated.

For DB Depot / DB ESP, **do not** call `configuration-cmd decrypt` or `aws configure export-credentials` manually — the helper script handles both. `configuration-cmd` does not read SSO profile creds on its own; the helper exports `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN` first automatically. Service RDS uses the separate dynamic-configuration workflow below.

The decrypted password may be shown only when the user explicitly asks for it. Prefer the `--copy` flag to put it in clipboard without printing it.

Never write the plaintext password to a repository, session artifact, brain memory, or command log.

## DB Depot / DB ESP DataGrip/PostgreSQL configuration

Provide:

- Driver: PostgreSQL
- Host: environment/database host above
- Port: `5432`
- Authentication: User & Password
- User: `developer`
- Password: decrypted environment password
- Database: `postgres` for dbdepot, `espdb` for dbesp

Start with the default PostgreSQL connection settings. Only add SSL, SSH tunnelling, or a jump host when the user’s network or the database error indicates it is required. A password-authentication failure usually means the wrong environment secret or a stale password, not a missing database name.

## Service RDS databases

Service RDS instances are separate databases with their own application and administrative roles. Local `psql` access is supported when the environment endpoint is reachable and the selected credential profile is authorized. Rundeck's **Run RDS Support Script** remains an approved execution route, but it is not the only read-only query route.

### RDS preflight

Before connecting, establish all four items:

1. **Environment:** one of `dev`, `test`, `apacpp`, `napp`, `apac`, or `na`.
2. **Service/database:** for example, `ifta` / `ifta`. Do not infer this from a table name alone.
3. **Read-only scope:** the exact `SELECT`, `EXPLAIN`, or metadata query, including a reasonable `LIMIT` where needed.
4. **Endpoint type:** a non-production service endpoint, or an explicitly configured production **read replica**. Never use a production RDS writer endpoint for investigation from a developer laptop.

The environment must be running. NAPP and APACPP are on-demand preproduction environments and can be unavailable when not leased. Confirm FortiClient VPN connectivity before diagnosing a network failure.

### Find the exact RDS connection profile

The deployed connection values, including credentials, live in dynamic configuration. The checked-out `depot-configuration/configuration/<environment>.yml` file is the starting point for identifying:

- the service's JDBC URL or service DNS name;
- its configuration namespace;
- the matching username/password property names.

For production reads, find the service's explicitly configured replica URL in the same configuration. Do not manufacture a `-read-replica` hostname from a writer hostname. If the configuration does not provide a read replica, use the approved Rundeck route or obtain the database owner's direction.

**Credential pairing matters.** A service can publish both an administrative RDS profile and an application JDBC profile. They are different accounts with different passwords. Use the username and password from the same named profile; never pair an admin password with an application username, or vice versa.

For example, IFTA's `ifta.rds.username` / `ifta.rds.password` is an RDS administrative profile, while `jdbc.ifta.username` / `jdbc.ifta.password` is an application profile. This is an example only: discover the corresponding profile for the selected service rather than applying IFTA property names to another RDS database.

Do **not**:

- reuse a DB Depot / DB ESP `developer` password for a service RDS instance;
- try `developer`, `readonly`, `debug`, service users, or personal credentials in sequence;
- print, paste, write, cache, or place an RDS password in a command argument;
- retrieve Rundeck's internal credential-broker values from outside Rundeck.

An authentication failure means the selected endpoint/profile pair is not authorized or is stale. Stop and resolve that specific pairing; do not retry with other credentials.

### Export dynamic configuration safely

`configuration-cmd` does not automatically consume the AWS CLI's SSO profile. Export the current SSO credentials into one short-lived child process before invoking it. Use `us-west-2` for `napp` and `na`; all other environments use `ap-southeast-2`.

The following template lists **only configuration variable names**. It does not print values, including passwords. Replace `<environment>` and `<namespace>` only after identifying them from `depot-configuration`.

```bash
rtk python3 - <<'PY'
import json
import os
import re
import shlex
import subprocess
import sys

environment = "<environment>"
namespace = "<namespace>"
region = "us-west-2" if environment in {"napp", "na"} else "ap-southeast-2"

aws_credentials = json.loads(subprocess.check_output([
    "aws", "configure", "export-credentials",
    "--profile", "default", "--format", "process",
], text=True))

config_environment = os.environ.copy()
config_environment.update({
    "AWS_ACCESS_KEY_ID": aws_credentials["AccessKeyId"],
    "AWS_SECRET_ACCESS_KEY": aws_credentials["SecretAccessKey"],
    "AWS_SESSION_TOKEN": aws_credentials["SessionToken"],
    "AWS_REGION": region,
    "AWS_DEFAULT_REGION": region,
    "AWS_DYNAMODB_TABLE_PROPERTY": f"{environment}ConfigurationDynamoTableProperties",
})

result = subprocess.run(
    ["configuration-cmd", "export", "-n", namespace, "-f", "BASH"],
    env=config_environment,
    text=True,
    capture_output=True,
    check=True,
)

for line in result.stdout.splitlines():
    fields = shlex.split(line)
    assignment = next((field for field in fields if "=" in field), None)
    if assignment:
        key = assignment.split("=", 1)[0]
        if re.search(r"(?:USERNAME|PASSWORD|URL|HOST|DOMAIN)$", key):
            print(key)
PY
```

Review the names with the checked-out configuration to select one username/password pair and the intended endpoint. Do not redirect the full `configuration-cmd export` output to a file: it includes secrets.

### Run a local RDS read-only query

Use the selected dynamic-configuration variable names as inputs to this one-shot process. It keeps AWS credentials and the database password in process memory, requires TLS, limits execution to 30 seconds, and sets `default_transaction_read_only=on` on the connection.

```bash
rtk python3 - <<'PY'
import json
import os
import shlex
import subprocess
import sys

environment = "<environment>"
namespace = "<namespace>"
host = "<configured-rds-or-read-replica-host>"
database = "<database>"
username_key = "<CONFIG_*_USERNAME variable>"
password_key = "<CONFIG_*_PASSWORD variable>"
sql = "<single read-only SELECT, EXPLAIN, or metadata query>"

region = "us-west-2" if environment in {"napp", "na"} else "ap-southeast-2"
aws_credentials = json.loads(subprocess.check_output([
    "aws", "configure", "export-credentials",
    "--profile", "default", "--format", "process",
], text=True))

config_environment = os.environ.copy()
config_environment.update({
    "AWS_ACCESS_KEY_ID": aws_credentials["AccessKeyId"],
    "AWS_SECRET_ACCESS_KEY": aws_credentials["SecretAccessKey"],
    "AWS_SESSION_TOKEN": aws_credentials["SessionToken"],
    "AWS_REGION": region,
    "AWS_DEFAULT_REGION": region,
    "AWS_DYNAMODB_TABLE_PROPERTY": f"{environment}ConfigurationDynamoTableProperties",
})

config = subprocess.run(
    ["configuration-cmd", "export", "-n", namespace, "-f", "BASH"],
    env=config_environment,
    text=True,
    capture_output=True,
    check=True,
)
properties = {}
for line in config.stdout.splitlines():
    fields = shlex.split(line)
    assignment = next((field for field in fields if "=" in field), None)
    if assignment:
        key, value = assignment.split("=", 1)
        properties[key] = value

query_environment = os.environ.copy()
query_environment.update({
    "PGPASSWORD": properties[password_key],
    "PGOPTIONS": "-c default_transaction_read_only=on -c statement_timeout=30000",
})
result = subprocess.run(
    [
        "/opt/homebrew/opt/libpq/bin/psql",
        (
            f"host={host} port=5432 user={properties[username_key]} "
            f"dbname={database} connect_timeout=10 sslmode=require"
        ),
        "-v", "ON_ERROR_STOP=1",
        "-c", sql,
    ],
    env=query_environment,
    text=True,
)
raise SystemExit(result.returncode)
PY
```

If a service RDS endpoint does not support TLS, report that precise server error and use the documented service route; do not silently downgrade the connection to non-TLS. DB Depot and DB ESP have their own TLS behavior and remain covered by `sslmode=prefer` in their workflow.

## Running SQL from a session

Yes, SQL can be run from the current session when a PostgreSQL client or another approved database client is available and the user has network access to the private endpoint.

### Install the PostgreSQL client on macOS

Check first:

```bash
rtk command -v psql
```

If it is missing and Homebrew is available, install the client-only package:

```bash
rtk brew install libpq
rtk apply_patch <<'PATCH'
*** Begin Patch
*** Update File: /Users/josuebadenas/.zshrc
@@
 export PATH="$HOME/.local/bin:$PATH"
+export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
*** End Patch
PATCH
rtk zsh -ic 'psql --version'
```

Do not install the full PostgreSQL server when the user only needs a client.

### End-to-end session query workflow

1. Confirm the environment, database family, database name, and requested SQL.
2. Confirm the query is read-only. For an underspecified request, ask for the table/schema or offer a metadata query.
3. Get the password using the helper script (uses cache — no AWS call if already decrypted):

```bash
PGPASSWORD="$( ~/.pi/agent/skills/eroad-db-access/get-db-password.sh <env> )"
```

4. Execute:

```bash
PGPASSWORD="$( ~/.pi/agent/skills/eroad-db-access/get-db-password.sh <env> )" \
  /opt/homebrew/opt/libpq/bin/psql \
  "host=<reporting-host> port=5432 user=developer dbname=<database> connect_timeout=10 sslmode=prefer" \
  -v ON_ERROR_STOP=1 \
  -c "<read-only-query>"
```

5. Report the exact target, query shape, result summary, and any authentication/network/client error. Never claim success without command output.

For a basic connectivity check:

```sql
SELECT 1 AS connection_test;
```

For metadata discovery when the table is unknown:

```sql
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
ORDER BY table_schema, table_name
LIMIT 100;
```

If a requested table lookup returns zero rows, explain that the table or schema was not found rather than guessing a similarly named object.

For a read-only query:

```bash
rtk sh -c 'PGPASSWORD="$(pbpaste)" psql "host=<host> port=5432 user=developer dbname=<database> connect_timeout=10" -v ON_ERROR_STOP=1 -c "<query>"'
```

Prefer `psql` output with explicit column selection and a reasonable `LIMIT`. Do not put passwords directly in command arguments. If `psql` is unavailable, say so and provide the DataGrip steps or ask whether installing an existing approved client is acceptable.

Treat `SELECT`, `EXPLAIN`, and metadata inspection as read-only. Before running `INSERT`, `UPDATE`, `DELETE`, `ALTER`, `CREATE`, `DROP`, `TRUNCATE`, or administrative commands, show the exact SQL and obtain explicit confirmation. Never run destructive or production queries based only on an implied request.

Before executing a query, confirm:

1. Environment and database target.
2. Whether the query is read-only.
3. Scope limits for potentially large result sets.
4. Whether the endpoint requires VPN, bastion, or another private-network path.

Report connection failures plainly, distinguishing authentication, DNS/network, TLS, and missing-client errors. Do not retry repeatedly with different credentials.
