# Batch Process Coordination Service

## Overview

A service to help coordinate concurrent batch processing. The service maintains a set of keys that can be acquired by a
processor. The exact semantics are left to the application making use of the service.

The inspiration came from an implementation that used the batch key as a modulo test against the integer id field from a
database table.

## Service Details

### Routes

The service provides two routes, one to manage the registered processes, the second to manage the batch keys.

#### Processes

##### Retrieve registered processes and their key space size

Request:

`GET /api/v1/process`

Response:

```json
  [
    {
      "process_name": string,
      "key_set_size": integer
    },
    ...,
    {
      "process_name": string,
      "key_set_size": integer
    }
  ]
```

##### Register a new batch process

Request:

`POST /api/v1/process`

Body: 
  
```json
  {
    "process_name": string,
    "key_set_size": integer
  }
```

_process_name_ is the name of the batch process that is to be created.

_key_set_size_ is the size of the key space (i.e.: the number of keys available), defaults to *10*.

Response:

```json
  {
    "process_name": string,
    "key_space_size": integer
  }
```

##### Unregister Process

Request:

`DELETE /api/v1/process/<process_name>`

Response:

```json
  {
    "process_name": string,
    "key_set_size": integer
  }
```

#### Batch Keys

##### Retrieve current Batch Key state for a process:

Request:

`GET /api/v1/process/batch_keys/<process_name>`

Response:

````json
  [
    {
      "external_id": UUID,
      "key": integer,
      "last_completed_at": datetime,
      "machine": string,
      "process_name": string,
      "started_at": datetime
    },
    ...,
    {
      "external_id": UUID,
      "key": integer,
      "last_completed_at": datetime,
      "machine": string,
      "process_name": string,
      "started_at": datetime
    }
  ]
````

##### Request a Batch Key for a process:

Request:

`POST /api/v1/process/batch_keys`

Body:

```json
  {
    "process_name": string, 
    "machine": string
  }
```

_process_name_ is the name of the batch process for which a key is being requested.

_machine_ is the name of the host to which the key will be assigned. The actual value can be any arbitrary string. Using
duplicates has no effect on the service.

Response:

```json
  {
    "external_id": UUID,
    "key": integer,
    "last_completed_at": datetime,
    "machine": string,
    "process_name": string,
    "started_at": datetime
  }
```

##### Release a Batch Key for a process:

Request:

`DELETE /api/v1/process/batch_keys/<external_id>`

Response:

````json
  {
    "external_id": UUID,
    "key": integer,
    "last_completed_at": datetime,
    "machine": string,
    "process_name": string,
    "started_at": datetime
  }
````



## Installation

### Docker

### Installer



