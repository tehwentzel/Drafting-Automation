## Overview
This is a repository of newer functions for use with Northwestern's Cad systems with the new Tririga system. The files can be installed by going to 
   1. Manage -> Load Application -> Contents (Under "Starting Suite")
   2. Navigate to the folder with the files and add them
   
*The parent folder should also be added to the "trusted files" search path in autocad's options if you don't want a warning every time  Autocad opens:*
   1. Options -> Trusted Locations -> Add
   2. Add the folder containing the lisp files to this search path.

#### Notes
Certain functions (doorify, insertTitleBlock, tripdf) rely on using files in their current location.
 * doorify: 
   [The doorPath](https://github.com/tehwentzel/Drafting-Automation/blob/480b5b6649eaa915924bef722b9d34c5cb20b6b6/Tririga%20Scrips%20and%20Lisps/Doorify.lsp#L39) variable should be changed to the location of the [dynamic door.dwg](https://github.com/tehwentzel/Drafting-Automation/blob/tririga-updates/Tririga%20Scrips%20and%20Lisps/Dynamic_Door.dwg) file should it move.
   
 * insertTitleBlock: 
   [the parentFolder](https://github.com/tehwentzel/Drafting-Automation/blob/480b5b6649eaa915924bef722b9d34c5cb20b6b6/Tririga%20Scrips%20and%20Lisps/insertTitleblock.lsp#L9) variable should be changed to the folder containing the titleblocks, should it move
   
 * triPDF: 
   the main part of the changes are in the "PublishTriPDF.lsp" file.  To change the location of the folder that contains the plotstyles, edit [this line](https://github.com/tehwentzel/Drafting-Automation/blob/480b5b6649eaa915924bef722b9d34c5cb20b6b6/Tririga%20Scrips%20and%20Lisps/PublishTriPDF.lsp#L17) and replace "Y:\\Plotstyles" with the folder.  To change the plotstyle, change [this line](https://github.com/tehwentzel/Drafting-Automation/blob/480b5b6649eaa915924bef722b9d34c5cb20b6b6/Tririga%20Scrips%20and%20Lisps/PublishTriPDF.lsp#L36) by replacing the "." with the name of the plotstyle (in quotes, eg "custom.ctb")

#### A brief overview of the important functions:
 * triPublish: explodes dimensions in the drawing temporarily before publishing to tririga, so that they can show up in the drawing
 * triPDF: creates and appropriately oriented pdf of the drawing.  The current lisp is set up to allow for a custom plotstyle to be used, but currently defaults to none.
 * FMLayers: imports all of FM's standard layers and changes them to the proper colors
 * reColor: changes the colors of FM's standard layers to their correct settings.  Turns on layers meant for plotting, freezes other layers.
 * stddims: changes all dimensions to a standard style and layer
 * fixText: changes most text to a standard style
 * UpdateCustomFields: Attempts to update the fields for building and floor in the drawing.  First attempts to get the info from the old FM database.  Defaults to using the parent folder and file name otherwise.
 * insertTitleBlock: Inserts and auto-scales one of the dynamic titleblocks in this folder based on if the drawing is landscape or portrait.
 * doorify: inserts a dynamic 3' door block at a selected point.
 * pclose: closes all polylines on an A-Polyline* layer
 * splineToPline: flattens all splines to polylines (they don't show up in tririga).  Does not work on splines in blocks.
 * FMclean: Purges and overkills the drawing, runs recolor, stddims, fixtext, splineToPline, and pclose, deletes polylines with areas smaller than a doorway.
