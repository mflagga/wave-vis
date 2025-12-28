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

x = np.arange(0,pi,d)
y = np.arange(0,pi,d)
X, Y = np.meshgrid(x,y)
umax = data[:,1].max()
umin = data[:,1].min()

it = np.unique(data[:,0]).astype(int)

cmap1 = 'jet'

ax = plt.figure(figsize=(6,6)).add_subplot(projection='3d')
for i in it:
    mask = data[:,0]==i
    u = data[mask,1].reshape((nx+1,ny+1)).T
    ax.plot_surface(X,Y,u,edgecolor='royalblue',lw=0.5,rstride=8,cstride=8,alpha=0.3)
    ax.contour(X, Y, u, zdir='z', offset=umin - 0.1*(umax - umin), cmap=cmap1)
    ax.contour(X, Y, u, zdir='x', offset=x.min(), cmap=cmap1)
    ax.contour(X, Y, u, zdir='y', offset=y.max(), cmap=cmap1)
    ax.set(xlim=(x.min(), x.max()), ylim=(y.min(), y.max()), 
           zlim=(umin, umax),
           xlabel='X', ylabel='Y', zlabel='Z')
    filename=os.path.join('frames',f'frame_{i//it[1]:05d}.png')
    plt.savefig(filename)
    ax.cla()
plt.close()