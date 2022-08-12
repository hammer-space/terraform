# Large size deployment settings

This deployment is suitable for a large environment

Approximate usage recommendations:
- 2,500 concurrent users per DSX node (SMB)
- 200 shares
- 10,000 concurrently open files
- Up to 1 billion files
- Actual IO performance is going to be dependent on the type of storage used for the data disk(s) as well as the network connectivity to the DSX nodes

Settings for Anvil and DSX:

**Anvil**
```
- CPU: 48 cores
- Memory: 128 GB
- Metadata disk: 4 TB
```
**DSX**
DSX node performance scales up and wide. A single large DSX node vs. several smaller may be beneficial in some workloads.
```
- Count: 4 nodes
- CPU: 16 cores
- Memory: 64 GB
- Data disk: <Customer driven>
```
