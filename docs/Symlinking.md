# Symlinking

As the git folder was getting a bit large, we had to move all the lua code into a sub directory so the ComputerCraft computers wouldn't run out of hdd space.

I used this command to symlink the computer root folder into my minecraft install.

## Windows

```batch
mklink /D C:\<path to minecraft world folder>\computer\0 C:\<path to dr-roboto>\computerRoot
```

## Mac

```bash
ln -s /<path to minecraft world folder>/computer/index /<path to dr-roboto>/computerRoot
```
