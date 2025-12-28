import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import axes3d
from math import pi
import os

data = np.loadtxt('u.dat')
misc = np.loadtxt('misc.dat')
nx = int(misc[0])
ny = int(misc[1])
d = misc[2]
dt = misc[3]

x = np.arange(0,pi+d,d)
y = np.arange(0,pi+d,d)
X, Y = np.meshgrid(x,y)

it = np.unique(data[:,0]).astype(int)

ax = plt.figure(figsize=(6,6)).add_subplot(projection='3d')
for i in it:
    mask = data[:,0]==i
    u = data[mask,1].reshape((nx+1,ny+1)).T
    ax.plot_surface(X,Y,u)
    filename=os.path.join('frames',f'frame_{i//it[1]:05d}.png')
    plt.savefig(filename)
    plt.clf()
plt.close()