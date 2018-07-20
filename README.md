# Generalissimo

An addon for World of Warcraft
------------------------------

**Take command** of your legions of alts with Generalissimo!

Generalissimo is inspired by a well-known alt management addon.  Since
its author took a bunch of time away from WoW, and because I like to
program in my spare time, I decided to take a crack at such a tool
myself.

When I briefly played WildStar, I wrote a similar addon for it called
Generalist.  The name "Generalissimo" is derived from that.

Obviously it is *very* lean on features right now, but I'll be working
on it.

How to Install
--------------

Currently the addon requires you to install the Ace3 (standalone)
addon.  It's not really using much Ace functionality yet, but as I
develop it, I might do so.  If I find I'm not really likely to, I'll
remove that dependency.

So:

1. Install the Ace3 standalone addon
1. Download this repository
1. Move the `Generalissimo` folder to your WoW `Interface/Addons` folder.

Usage
-----

* Log into each alt that you care about gathering data about. The
  addon has no mystical or borderline-divine methods of knowing about
  them otherwise.

* Then type the `/gen` command in your chat frame to show or hide the
  Generalissimo window.  (You can also click the X button in the upper
  right to hide it.)

I'll add a minimap button at some point, and when I get around to
adding inventory, you'll need to visit the bank as well, etc.  This is
pretty barebones.

No, the tabs (Currency, Professions) don't do anything yet.  They
should sooner or later.

Release Notes
-------------

### 0.01

The first version I'm putting in the repository.  Stores characters'
classes (represented only by the color of their names), levels,
average item levels, and gold.  Only shows alts on the same realm and
same account as the one you're currently on.  Does not distinguish
faction.  Seems to do what little it does bug-free.

Note on Licensing
-----------------

I'm licensing this currently with GPLv3, but I have not yet accepted
any pull requests under those terms, so I (the original author) retain
the right to release it under other licenses.
