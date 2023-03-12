# What is anomaly science

Anomaly science is a full replacement for science.
The idea is for these mechanics to fully replace the current science dynamic and research tree.

The goals of anomaly science are:
- A more consistent mechanic for science to work on, disallowing splitting up and doing their own thing.
- Have research feel like new things are being researched rather than purchased.
- A research system where gaining research is more active.
- Encourage scientists to leave their department more often.
- Players are encouraged to create dangerous situations, which creates conflict and interesting scenarios.

### What are anomalies?

Anomalies are the heart and soul of anomaly science and core to what makes them interesting.
Each anomaly will have a general structure and outline, however will have individual elements and effects randomly selected. This will provide interesting handmade effects while still keeping the mystery and risk factor of not fully knowing what something could be.

One example of an anomaly which could exist on this system is a book.
This book will have an effect when read by a user. This effect will be randomly selected from a list of possible effects. It could do nothing the first time, but get worse and more severe over time. It could summon monsters when read, etc.
Another example of a more active anomaly could be a monster.
When not being viewed by anyone this monster can teleport anywhere on the map that is dark.
It will then proceed to run at and use its anomalous power on anyone who is unfortunate enough to come across it. (Note: Not sure if I really like the idea of mob anomalies tbh)

For the style of anomalies to create, imaging lob corp / SCP for inspiration.

### Types of anomalies and how to deal with them

Physical Threat - The anomaly poses a threat to personnel that come into physical contact with it. Active anomalies of this kind can often be dealt with via a lockdown along with either physical force or luring back to containment.

Spatial Distortion - The anomaly can manipulate space and may have powers ranging from self teleportation, teleportation of others, bringing items from alternate locations. Dealing with them is very difficulty, and the use of specialist equipment such as bluespace anchors will be useful. The main difficulty with locating them is with subdueing them, so the radio is your best friend here.

### Flux Entropy

Flux entropy is a global measure of how many anomalies are active and causing chaos.
An active anomaly contributes a large amount to flux entropy, while one that is contained and not being used will contribute a very small amount.
Flux entropy can be harvested, meaning that it is benificial for scientists to keep dangerous anomalies in a state close to being dangerous in order to get flux faster.

This value will be time dependant, decreasing on its own over time and each anomaly contributes some amount per second. This needs to be non-linear so that flux cannot increase to infinite when gain is 10 and loss is 5.

### Harvesting flux

Flux harvesters will convert the global flux entropy into flux power cores, which acquiring is the main goal of science.
Setting the flux harvesters too high will result in the flux entropy falling extremely low, causing a larger number of anomalies to begin to appear and torment the station. Setting them low will mean less flux power cores can be harvested.
This, in turn, encourages scientists to interact with anomalies in order to increase the flux entropy value so that it can be harvested at greater rates safely; but also allows them to increase the flux harvest rate in order to encourage new anomalies to appear.

## What will harvested flux be used for

Harvested flux will be used by advanced fabricators to create things on the research bench that cannot be created by regular fabricators.
It can also be used to power the research generators which unlock new recipes for the advanced fabricators.

The only advanced fabricator is in science, any advanced technology items need to be acquired from science.
Certain things like flux powered weapons require charging with more flux in order to use.

These flux items should have antagonistic uses, but should generally be weak enough against antagonists that they dont ruin gameplay for them.

#### Generating Research Points

Building research generators which are powered by flux cores will progress the currently selected technology.
You can build more research generators to speed up research, but will still require flux cores.

### How will anomalies spawn?

As the game progresses, the flux entropy value at which new anomalies can spawn will slowly increase, meaning more and more anomalies will appear over time and get increasingly more dangerous.
Anomalies will only spawn when the global flux entropy is **below** this threshold. This means that while the value is high, new ones will not spawn.

### What will scientists do with anomalies once contained?

Once contained, scientists can work with anomalies in order to increase the flux entropy value.
The riskier the anomaly is to work with, the more the flux entropy value will increase, providing some risk vs reward.

### What will happen to the current research tree?

The current research tree will be looked at and heavilly reconsidered. Anything available roundstart should either be a roundstart item in the lathes or a purchasable item from cargo.

All of the more advanced technologies will be covered by the new research tree.

### Job Roles

Research Director - Same as current
Containment Specialist - Involves running around and locating potential hazard zones for anomalies. Their job is to identify areas that could potentially have anomalies spawning in it, identify any hidden anomalies in the wild and bring any uncontained anomalies back into science for study.
Junior/Senior Researcher - The people that conduct research on the anomalies in order to extract flux. After some amount of play time, the senior research role is unlocked which does the same thing but provides an RP flavour role to the people who know more about the possible anomaly effects.

### Existing Mechanics

Xenobiology crossbreeds will be fully removed (mainly due to ongoing balance issues), however slimes may stay in the game accessible to cargo.
This system is working as an expansion to xeno-artifacts and so xeno-artifacts will be updated and integrated into this new system.
Toxins lab will be removed however the underlying mechanics will remain, as they are core to the atmospherics system.
The experimentor and maint artifacts will be fully removed from the game.
Research servers and the current research system will be replaced.
Robotics will remain as members of the science department.

### Dynamics

Main focus is on teamworking mechanics, we want players to work together.

# Development

In order to test and prototype the mechanics, we will use non-randomly generated anomalies.

# Anomaly Containment

Anomaly containment follows 3 phases:

- Immobilise: Render the anomaly into a state where it is unable to move.
- Stabilise: Stabilise the anomaly so that it may be moved to a containment location.
- Utilise: Trigger the anomalies effects in a controlled environment in order to harvest flux and learn more about it.

## Immobilise

The immobilise phase of anomaly containment involves making the anomaly unable to move so that it can be stabilised.
Different anomalies may have different methods of immobilisation, it may involve damaging the anomaly until it stops moving or capturing it in a containment grid.

Once an anomaly is in a breaching state, then it needs to be stabilised. In order to stabilise an anomaly, it needs to be kept in a single place for long enough,

### Immobilisation Grid

Works like a field generator. Deploy the 4 corners of a grid and activate. Any anomalies caught inside will be immobilised, allowing for them to be stabilised.
Note that due to the time it takes to setup the grid, this is only effective for relatively slow anomalies.

### Disruptor Baton

Deals stamina damage. Has a long cooldown, but deals a huge amount of disruption damage to anomalies. Disruption damage functions as a temporary health bar for anomalies. Once it is depleted, the anomaly may stop certain actions (This is mostly effective for physical mob-like entities that are actively fighting you as it blocks their direct powers). Disruption will not deactivate 'passive' abilities only 'active' ones (Things that are innate to the object such as touching it causes shock will still happen, but abilities that require looking for and then attacking targets will be).

## Stabilise

Remote anomaly stabilisation tool: A ranged beam which slowly stabilises any anomalies in front of it. Once the anomaly has been stabilised, it will remain stable for 60 seconds. It can be placed into an anomaly transport basket.

Anomaly transport basket: A small temporary containment basket for anomalies to be transported in. Anomalies in the basket will break free if they don't move for 3 minutes. These are temporary storage units which allow for transfering the anomalies to the actual containment chambers. The actual containment chambers contain permanent stabilisers which an anomaly will never destabilise from (However these need to be deactivated in order to perform research and increase the latent flux levels and gather insights at the research database)

## Utillise

### Researching Anomalies

There are 4 main types of actions you can perform on anomalies.
Performing these actions will trigger its anomalous effects, which increases the flux entropy value of the world.
Performing too many actions on an anomaly in a short period of time may cause it to become active and leave containment, or performing a bad work type on anomalies. (Maybe we should make it a percentage chance to happen depending on the work type)
These 4 interaction types are intended to provide consistent ways to trigger the inconsistent effects of anomalies and get around the current issue of anomalies where half the work is trying to figure out how to activate them.

Each anomaly has a certain percentage value for how likely these interaction types are to succeed when working with it.
If an anomaly has too many failure incidents while being worked with, then it will become active and attempt to either breach containment or perform its anomalous effect.

#### Interaction

Interaction is the most basic type of action you can perform on an anomaly. It involves going to the anomaly and simply using it.
Depending on the anomaly base, using it may be different. A book anomaly will consider reading an interaction, a vending machine will be using it and a monster could be touching/attacking it (Although monsters may seek to interact with you).
Whatever makes the most sense is an interaction.

> The effectiveness of interaction will vary, anomaly types like books will probably respond pretty well to interaction, dangerous anomalies will probably respond pretty badly because you have to get right next to the anomaly in order to interact with it, which poses a lot of danger.

#### Flux Reduction Chamber

Some anomalies are inherently stable and will be difficult to trigger its anomalous effects.
The flux reduction chamber will reduce the levels of flux in that room, which makes anomalies more reactive.
This could be disastrous on already reactive anomalies, which will now become even more active and dangerous but may be the only way to activate the effects of some more inert anomalies.

The scientists working on this must carefully monitor the reaction levels of the anomalies as they slowly increase the power of the machine, increasing the power too much may cause the anomaly to become unstable.

> Flux reduction is effective against inert anomalies, but reactive anomalies will respond extremely poorly to it and will almost certainly have a containment breach triggered.

#### Quantum Field Chamber

> The quantum field chamber is effective against anomalies with spatial distortion abilities. Anomalies with higher intelligence that do not have spatial distortion abilities will respond extremely poorly.

#### Unnamed Chamber

> The unnamed chamber is effective against anomalies with a higher intelligence function. Actively  dangerous anomalies will respond well


### Rewards

# Anomaly Examples

**Spreading Style**

This anomaly can spread to other atoms in the world.
Every minute after it is out, it spreads to that atom.
Any atom it infects is infected with an extremely basic AI which will attack nearby mobs.

![[Pasted image 20230312145256.png]]

**Interactable Style**

This is a book anomaly that performs an action when read, otherwise it is completely inert and performs no actions.

**AI/Mob Style**

This is a hostile anomaly that will engage mobs in melee range.
After there are no hostile mobs around, it will assimilate corpses creating more instances of itself.

**AI/Mob Style 2**

This is a hostile anomaly that uses pysonic energy to attack targets at range.
It can move through walls and will attempt to flee from nearby mobs.
