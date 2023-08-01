"If you would like to use your own neuronal population data, the data must be a .mat file with a .data attribute which contains spiking data in the format ```neurons x trial-length x number of trials```. Furthermore, we suggest using data with a sequence length less than 100 timesteps; while there is not a clear data size limit, larger datasets are more prone to failure when running the python script. Once you have your data in a .mat file, you can use the ```convert_h5.m in the tutorial package to convert it to the necessary .h5``` "
 quoted from this link [AutoLFAD](https://snel-repo.github.io/autolfads/data/)