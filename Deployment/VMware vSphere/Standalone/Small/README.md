# Small deployment settings

This deployment is suitable for a small environment

Approximate usage recommendations:
- 100 concurrent users (SMB)
- 10 shares
- 1,000 concurrently open files
- Up to 20 million files
- Actual IO performance is going to be dependent on the type of storage used for the data disk(s) as well as the network connectivity to the DSX nodes

Settings for Anvil and DSX:

**Anvil**
```
- CPU: 8 cores
- Memory: 20 GB
- Metadata disk: 200 GB
```
**DSX**
```
- Count: 1 node
- CPU: 2 cores
- Memory: 8 GB
- Data disk: <Customer driven>
```
