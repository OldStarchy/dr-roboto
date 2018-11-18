# Project Outline

## Functional Requirements

When referenced in other parts of the document, they are prefixed with a hash (eg. `# Crafting`)

### Basic Replication

The robot can autonomously build an advanced crafty mining turtle

-   Resource Gathering
-   Smelting
-   Crafting

### Resource Gathering

The robot can autonomously mine / collect basic resources when a particular item is required. These routines should be able to be run until a requirement is met, stopped, then potentially resumed later.

### Hive Mind

Multiple robots can work together performing multiple tasks at once. Although this is a low priority milestone, it should be kept in mind when developing other parts so as not to make it too hard to implement later.

### Smelting

The robot can build and manage smelting many items in multiple furnaces.

### Basic Smelting

The robot can smelt items in a furnace when a particular item is required.

### Crafting

The robot can craft items when a particular item is required. This involves managing items in the inventory, and temporarily moving excess items to a chest when they would be in the way of the crafting grid.

### Item Management

The robot can create storage chests and leave items in them when they are not required (eg. excess dirt)

### POI / Blocks Management

The robot keeps a catalogue of all points of interest, such as chest and furnace locations, and locations of constructed farms.

### Global Navigation

The robot can navigate to any recorded POI This includes moving to and facing a particular direction to, for example, access different sides of a furnace.

### Basic navigation

The robot can move without running out of fuel or getting stuck by un/known blocks, mobs, or falling objects. The robot can also automatically pick up and consume lava source blocks when flying through them.

### Movement Tracking

The robot keeps track of its location whenever it moves, and records its location to disk in case of crashes / reboots.

### Fluid Handling

The robot can pick up and place water and lava, as well as tell the difference between flowing fluid and source blocks.
