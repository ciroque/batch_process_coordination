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

### Batch Key Maintenance

#### Request a Batch Key for a process:

POST /api/v1/processor/batch_keys/<processor_name>

Body: {"hostname": <hostname>}

#### Release a Batch Key for a process:

DELETE /api/v1/processor/batch_keys/<processor_name>/key

#### Retrieve current Batch Key state for a process:

GET /api/v1/processor/batch_keys/<processor_name>

