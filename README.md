# batch_process_coordination
Maintains keys to help coordinate parallel processes.

## Routes

### Processes

#### Retrieve registered process names and their key space size

GET /api/v1/process

#### Register a new batch process

POST /api/v1/process

Body: {"name": <process_name>, "key_space": <size>}
  
size defaults to 10.

#### Unregister Process

DELETE /api/v1/process/<process_name>

### Batch Keys

#### Request a Batch Key for a process:

POST /api/v1/process/batch_keys

Body: {"process_name": <process name>, "machine": <machine name>}

#### Release a Batch Key for a process:

DELETE /api/v1/process/batch_keys/<process_name>/key

#### Retrieve current Batch Key state for a process:

GET /api/v1/process/batch_keys/<process_name>

