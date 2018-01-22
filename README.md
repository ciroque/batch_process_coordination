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
      "process_name": "process-name",
      "key_set_size": 0
    },
    {
      "process_name": "process-name",
      "key_set_size": 0
    }
  ]
```

_***process_name**_ is the name of the batch process that is to be created.

_***key_set_size**_ is the size of the key space (i.e.: the number of keys available), defaults to *10*.

##### Register a new batch process

Request:

`POST /api/v1/process`

Body: 
  
```json
  {
    "process_name": "process-name",
    "key_set_size": 0
  }
```

Response:

```json
  {
    "process_name": "process-name",
    "key_space_size": 0
  }
```

##### Unregister Process

Request:

`DELETE /api/v1/process/<process_name>`

Response:

```json
  {
    "process_name": "process-name",
    "key_set_size": 0
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
      "external_id": "d4c55731-7c2e-48ac-b5db-6a5933ac8b9c",
      "key": 0,
      "last_completed_at": "2018-01-21 03:23:22.061203",
      "machine": "machine",
      "process_name": "process_name",
      "started_at": "2018-01-21 05:47:09.914996"
    },
    {
      "external_id": "6982c9b0-1fde-4839-ac4b-186f77345014",
      "key": 1,
      "last_completed_at": "2018-01-21 03:24:21.506564",
      "machine": "machine-2",
      "process_name": "process_name",
      "started_at": "2018-01-21 05:47:10.842902"
    }
  ]
````

_**external_id**_ (uuid string) A unique id to be used when releasing the batch key; *null* if the key is not currently locked.

_**key**_ (integer) The unique numeric value to be used by the handler to distinguish work load from other handlers.

_**last_completed_at**_ (datetime) The date and time this key was last used and handled successfully.

_**machine**_ (string) Arbitrary identifier for the host / instance / container / etc handling the key; *null* is the key is not currently locked.

_**process_name**_ (string) The process name.

_**started_at**_ (datetime) The date and time the key was locked; *null* if the key is not currently locked.

##### Request a Batch Key for a process:

Request:

`POST /api/v1/process/batch_keys`

Body:

```json
  {
    "process_name": "process_name", 
    "machine": "machine"
  }
```

_**process_name**_ is the name of the batch process for which a key is being requested.

_**machine**_ is the name of the host to which the key will be assigned. The actual value can be any arbitrary string. Using
duplicates has no effect on the service.

Response:

```json
  {
    "external_id": "b608a696-7197-42b1-bbbd-cabb962cbaad",
    "key": 0,
    "last_completed_at": "2018-01-20 03:20:16.020479",
    "machine": "machine",
    "process_name": "process_name",
    "started_at": "2018-01-21 05:47:07.046923"
  }
```

##### Release a Batch Key for a process:

Request:

`DELETE /api/v1/process/batch_keys/<external_id>`

Response:

````json
  {
    "external_id": "519afed1-54a3-428e-a03f-dc2907b24f42",
    "key": 0,
    "last_completed_at": "2018-01-21 03:28:35.860540",
    "machine": "machine",
    "process_name": "process_name",
    "started_at": "2018-01-21 05:47:13.957722"
  }
````

## Installation

### Docker

Batch Process Coordinator is available on [Docker](https://hub.docker.com/r/ciroque/batch_process_coordination/ "Batch Process Coordination on Docker Hub")

Pull the latest image using:

`docker pull ciroque/batch_process_coordination`

### Installer

WIP

