# EECS-205-game
Final Game for EECS 205, Winter 2018, Northwestern University

## Controls

 - Right/Left arrow keys control rotational velocity
 - Up arrow key accelerates the player
 - Left Click/Space fire the blaster
   - It is recommended to use leftclick, as space interrupts motion commands
 - P pauses/unpauses the game
 - R restarts the game, only when the player has died
 - Escape exits the game

## Scores

Score is granted on both a time basis and on a per-kill basis.

1 point is awarded each time the game advances a frame.

Each type of asteroid (there are currently eight, although some share sprites) has its own score bounty, ranging from 50 points for the first spawned asteroid to 1000 points for the respawned last asteroid:

1. ![bitmap](sprites/asteroid_003.png) is worth 50 points
2. ![bitmap](sprites/asteroid_000.png) is worth 100 points
3. ![bitmap](sprites/asteroid_005.png) is worth 75 points
4. ![bitmap](sprites/asteroid_001.png) is worth 150 points
5. ![bitmap](sprites/asteroid_000_003.png) (first spawn) is worth 200 points
6. ![bitmap](sprites/asteroid_000_003.png) (respawns) is worth 500 points
7. ![bitmap](sprites/asteroid_002.png) (first spawn) is worth 750 points
8. ![bitmap](sprites/asteroid_002.png) (respawns) is worth 1000 points

Score will be granted to the player for the frame they die on, and for killing an asteroid if they do so with their fighter - They will not, however, gain any points for blaster shots which impact on the last frame of the game.

## Sound effects

Sound effects are stored in the `sound` folder. They can be freely deleted (they will be replaced with silence) or replaced.

## Credits

All sprites are either mine, edited versions of public domain images, or given by the EECS 205 course. The binary library `libgame.obj` was also given to me by the EECS 205 course, as was starter versions of the assembly files and includes, and the build script `make.bat`.

### Sounds

There are three "fundamental" sounds:

1. For the Damaged Coda
2. `engineloop`
3. `blast`

The two RCS sound effects are modifications of `engineloop` to stereo.

For the Damaged Coda is a song by Blonde Redhead, from their album "Melody of Certain Damaged Lemons", which can be purchased [on Amazon](https://www.amazon.com/Melody-Certain-Damaged-Lemons-REDHEAD/dp/B00004SW9X). It is used here under US Fair Use law as I understand it, for non-commercial, educational purposes only. That is, neither I nor anyone else may profit from this game so long as this file is present, and this game is produced as an educational project. It has been trimmed to fit its purpose in the game.

`engineloop` is sourced under the CC0 license from [freesound user qubodup](https://freesound.org/people/qubodup/sounds/146770/). This user has no outside affiliation with me, or with this project, and has not in any way endorsed this project. The file has been edited to reduce its volume.

`blast` was created by me. It is a short sine wave, chirping from 800Hz to 200Hz over 0.3 seconds.

## Details

### Bitmaps

Here is a list of all bitmaps and their sources:

 - ![bitmap](sprites/asteroid_000.png) is used for the general `asteroid0`, and was given by EECS 205
 - ![bitmap](sprites/asteroid_001.png) is used for the general `asteroid1`, and was given by EECS 205
 - ![bitmap](sprites/asteroid_002.png) is used for both types of `asteroid3`, and was given by EECS 205
 - ![bitmap](sprites/asteroid_003.png) is used for the initial `asteroid0`, and was given by EECS 205
 - ![bitmap](sprites/asteroid_005.png) is used for the initial `asteroid1`, and was given by EECS 205
 - ![bitmap](sprites/asteroid_000_003.png) is used for both types of `asteroid2`, and was made by me, editing togther the general `asteroid0` and initial `asteroid0` sprites
 - ![bitmap](sprites/background.png) is used as the background for the game.
   - It is a cropped and downscaled version of the public domain [Hubble Ultra Deep Field](http://hubblesite.org/image/3380/news_release/2014-27), with colors brought down to those available to the game.
   - It is the only bitmap to bypass the `blit.asm` drawing routines - Instead, for performance (as it doesn't require transforms or transparency, and covers the whole screen, and is drawn every frame), it is copied over the screen buffer at the beginning of every frame using `rep movsb`.
 - ![bitmap](sprites/blast.png) is used as the projectile fired by the fighter, and was made by me from scratch.
 - ![bitmap](sprites/fighter_000.png) is the 'resting' fighter sprite, and was given by EECS 205
 - ![bitmap](sprites/fighter_002.png) is the first frame of the fighter's engines animation, and was given by EECS 205
 - ![bitmap](sprites/fighter_001.png) is the second frame of the fighter's engines animation, and was given by EECS 205
 - ![bitmap](sprites/rcs_ccw.png) is the fighter overlay for firing thrusters for counter-clockwise rotation, and was made by me from scratch.
 - ![bitmap](sprites/rcs_cw.png) is the fighter overlay for firing thrusters for clockwise rotation, and was made by me from scratch.
 - ![bitmap](sprites/shield_power.png) is overlaid on the fighter to show that it is shielded, and was made by me from scratch.
 - ![bitmap](sprites/shield_pickup.png) is the sprite for the collectible shield powerup, and was made by me from scratch.
 - ![bitmap](sprites/paused.png) is overlaid on the game when the game is paused, and was made by me from scratch - The used font is [IBM CGAThin](https://int10h.org/oldschool-pc-fonts/fontlist/)
 - ![bitmap](sprites/gameover.png) is overlaid on the game after the player dies, and was made by me from scratch - The used font is [Butcherman](https://fonts.google.com/specimen/Butcherman)
 
### Game Mechanics

This is a short list of certain game mechanics which are worth pointing out.

1. Everything wraps around the screen. But while it does so, it spends a brief period entirely offscreen - Do not assume that things just disappeared!
2. Blaster shots kill you if they hit you. Use them sparingly, and don't take too many risky shots - You might get swarmed.
3. Asteroids always respawn on set timers (relative to framerate), at set locations. Be careful staying near spawn locations if an asteroid might spawn soon - There is no grace period.
4. Your blaster has a cooldown of about 2 seconds. Don't use it if you're going to need it soon.
5. Your rotation doesn't stop by itself. Don't spin the ship too fast - There's a limit to how fast it will spin, but you'll lose control before you hit it.
6. Your shield can and will be hit by your blaster if you fire while shielded. Don't fire unless you need to - But if you need to, plan ahead!
7. The shield pickup respawns on a set timer, starting from when you last collected it. Using it effectively will mean using your shield offensively just before you can collect a new shield - They don't stack.
8. Asteroids do not destroy each other. Instead, they bounce off each other. Don't expect to be safe in the vicinity of two asteroids that might hit each other.
