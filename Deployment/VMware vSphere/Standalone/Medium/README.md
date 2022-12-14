# Medium size deployment settings

This deployment is suitable for a medium-sized environment

Approximate usage recommendations:
- 1,000 concurrent users (SMB)
- 100 shares
- 3,000 concurrently open files
- Up to 100 million files
- Actual IO performance is going to be dependent on the type of storage used for the data disk(s) as well as the network connectivity to the DSX nodes

Settings for Anvil and DSX:

**Anvil**
```
- CPU: 24 cores
- Memory: 64 GB
- Metadata disk: 1024 GB
```
**DSX**
DSX node performance scales up and wide. A single large DSX node vs. several smaller may be beneficial in some workloads.
```
- Count: 2 nodes
- CPU: 8 cores
- Memory: 32 GB
- Data disk: <Customer driven>
```
