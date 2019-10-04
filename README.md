# MEG GENERAL FUNCTIONS
The scripts and functions here are meant to stream line the use of fieldtrip and other functions for the preprocessing of MEG data.
It was designed and tested for the KIT Yokagawa System at NYU.

## Dependencies
- MATLAB
- [Fieldtrip Toolbox](http://www.fieldtriptoolbox.org/)
- [sqdDenoise Toolbox](https://isr.umd.edu/Labs/CSSL/simonlab/Denoising.html)
- Hopefully that's it.

## Example Script
The script `MGF_examplescript.m` shows an example of how the functions can be used to clean some data.
You'll have to provide the data.
To use it you will need to change the file information and parameters at the top of the script and ensure that all the functions called
are in your MATLAB path.

Ignore `MGF_runanalysis.m`. 

## Notes:
### `MGF_cleanbadchans`
This function allows for the cleaning of specified bad channels by replacing them with an interpolation of neighboring channels.
You can either give it directly the channels you want clean or make choices based on visual inspection.
If you choose, 'visual', the program calls ft_rejectvisual using the 'summary' option and it shows you a summary of the channels based on a feature of your selection.
I generally use 1/var to identify dead channels, and var to identify supper noisy channels.

It's worth noting that reject visual splits the data into segments of a specific length that you can choose.
Make sure that the total session length is a multiple of the segment length you choose.
Otherwise the remainder will be cut off.

### `MGF_overclean`
I tend to prefer keeping as much data as possible rather than removing trials with issues.
To do that, I created overclean which takes anything above an excessive threshold and does a series of operations to get it under the threshold.
If the number of channels above threshold are below a certain number (set by you), it will perform channel cleaning using MGF_cleanbadchans.
If it is over, it will remove the first Principal Component in that segment.
It's probably not every one's cup of tea which is why I called it overclean.
