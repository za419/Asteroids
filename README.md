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

Each type of asteroid (there are currently eight, although some share sprites) has its own score bounty, ranging from 50 points for the first spawned asteroid to 1000 points for the respawned last asteroid.

Score will be granted to the player for the frame they die on, and for killing an asteroid if they do so with their fighter - They will not, however, gain any points for blaster shots which impact on the last frame of the game.

## Sound effects

Sound effects are stored in the `sound` folder. They can be freely deleted (they will be replaced with silence) or replaced.

## Credits

All sprites are either mine or given by the EECS 205 course. The binary library `libgame.obj` was also given to me by the EECS 205 course, as was starter versions of the assembly files and includes, and the build script `make.bat`.

### Sounds

There are three "fundamental" sounds:

1. For the Damaged Coda
2. `engineloop`
3. `blast`

The two RCS sound effects are modifications of `engineloop` to stereo.

For the Damaged Coda is a song by Blonde Redhead, from their album "Melody of Certain Damaged Lemons". It is used here under US Fair Use law as I understand it, for non-commercial, educational purposes only. That is, neither I nor anyone else may profit from this game so long as this file is present, and this game is produced as an educational project. It has been trimmed to fit its purpose in the game.

`engineloop` is sourced under the CC0 license from [freesound user qubodup](https://freesound.org/people/qubodup/sounds/146770/). This user has no outside affiliation with me, or with this project, and has not in any way endorsed this project. The file has been edited to reduce its volume.

`blast` was created by me. It is a short sine wave, chirping from 800Hz to 200Hz over 0.3 seconds.
