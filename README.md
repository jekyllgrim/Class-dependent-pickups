# Class-depended pickups for GZDoom

© 2021-2025 Agent_Ash aka Jekyll Grim Payne

## Description

ZScript-based class-dependent pickups for GZDoom. The `JGP_ClassDependentPickup` class allows defining pickups that will look like different items and will give different items depending on the player's playerclass. **It's compatible with multiplayer**: the item will still look like and give different items to different players, but once one player picks it up, it'll disappear for everyone.

Includes two example player classes for demo purposes. They can be replaced with any other player classes.

### How to use

You only need the base class defined in `CDP_ZScript/cdp_base.zs`. The `cdp_examples.zs` file contains example player classes and an example pickup that you don't need to copy into your own project.

Once you copied the `JGP_ClassDependentPickup` class defined in `cdp_base.zs` into your project (you may also want to find & replace "JGP" with a custom prefix), you can do one of the following:

1. Create your own pickup based on the base class and use its `ClassPairs` argument to define the pairs of classes. 

2. Use the `JGP_ClassDependentPickup.Create(pos, pairs)` static function to spawn a custom pickup from anywhere. The `pos` argument determines the position to spawn, and the `pairs` argument functions the same way as the `ClassPairs` property.

Class pairs, whether defined through a property or a static function argument, uses the following syntax: 

`"FirstPlayerClass:FirstItemClass|SecondPlayerClass:SecondItemClass"` and so on. So, place `:` between a playerclass name and an item name, and place `|` between each pair. There's no limit on the number of pairs.

Note that the player classes must be defined via the *class* name, not their displayname (for example, `DoomPlayer` is valid, `Doom Marine` is not).

### License and permissions

This resource is licensed under MIT license. See [LICENSE.txt](CDP_ZScript/LICENSE.txt) for details. Short version: anyone can use it for any purpose, just copy my LICENSE.txt somewhere into your project.
