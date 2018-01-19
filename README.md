# batch_process_coordination
Maintains keys to help coordinate parallel processes.

## Routes

### Process Maintenance

#### Register a new batch process

POST to /api/v1/processor

Body: {"name": <your_name>, "key_space": <size>}
  
size defaults to 10.

#### Unregister Process

DELETE /api/v1/processor/<processor_name>

### Lock Key Maintenance

#### Request a lock key for a process:

POST /api/v1/processor/moduli/<processor_name>

Body: {"hostname": <hostname>}

#### Release a lock key for a process:

DELETE /api/v1/processor/moduli/<processor_name>/key

#### Retrieve current lock key state for a process:

GET /api/v1/processor/moduli/<processor_name>

