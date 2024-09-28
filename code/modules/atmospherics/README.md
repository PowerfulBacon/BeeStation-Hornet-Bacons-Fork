
# Regmos Atmospherics

A simple runthrough of the concepts of this system because nobody likes reading overly long documents.

# Gasflow

## Regions

- Regions are **rectangular** collections of turfs where atmos can freely move from any turf within the region to any other turf.
- Every turf within a region shares the exact same gas mixture. Equalisation is instant.

## Groups

- Groups are collections of regions that are directly accessible to each other.

# Design Explanations

If you like reading overly long documents then this part is for you.

## Why are regions rectangular

By imposing the restrictino that regions must be rectangular, calculating their cost when turfs are modified is significantly cheaper. If you build a wall through the middle of an atmos zone, it is quite difficult to work out if the region was split in 2 without recreating and scanning the entire zone. By forcing regions to be rectangular, calculating when regions are divided is much cheaper.
