function data = loadh5(filename)

F = hdf5info(filename);

for dname = F.GroupHierarchy.Datasets
    data.(dname.Name(2:end)) = hdf5read(filename, dname.Name);
end
