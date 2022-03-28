## List of some scripts i wrote in bash 
(intermedate to advanced bash users only)  
otherwise you should consider them unsafe  

Stand-alone scripts for full-disk encryption tested working from Ubuntu-live 20/21/22 .latest  
Credit/Follow along this guide: https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019  
The main script  
`scripts/enc.sh`  
The chroot script  
`scripts/enc2.sh`  
  
Most of the rest of the scripts require importing helpers.sh if the relative path changes
WIP/Needs re-testing as now separate from my local configs  

## jq scripts to deal with the gap rsync has 
...with moving archived files around on one side of a mirrored archive
They are meant mostly for large media files because their sizes are almost always unique  
It ended up far more complex than was expected and the jq bash syntax is painful  

`scripts/jq_arc_utils`  
utils for the other scripts  
  
`scripts/jq_clean`  
Prompts user for include/exclude of each dir within specified base_dir  
Creates digest files listing every file and it's size  
Prompts user on every self exact size collision for an action/inaction  
Then the digest files may be used to update a second base dir with the same sub-dirs  

`scripts/jq_rsync`  
Syncronize two archives after cleanup with jq_clean

There are lots of comments inline, expect using this to take some work,  
I'm just starting instructions for these

# ETC

`scripts/recode_webp_gif`  
Demuxes animated webp into frames (requires webp lib)  
Overlays / assembles frames into complete state (this shiz was hard)  
Upscale (optional)  
Recode to GIF 
Dir-refs are hard coded cause it's easier to use imo

`scripts/darc.js`  
Javascript to go dark mode in many sites (useful for particular places) ...WIP  copy/paste/dev-tools
  
Will clean up more and expand instructions sometime.  