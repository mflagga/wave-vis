#include <iostream>
#include <cmath>
#include <fstream>

using namespace std;

__device__
double s(int n){
    return n%2==0 ? 0.0 : 2.0/n;
}

__device__
double S(int n){
    return M_PI*M_PI*pow(-1,n+1)/n+2.0*(pow(-1,n)-1)/(n*n*n);
}

__device__
double A(int n, int m){
    return 4.0*(s(n)*s(m)-S(n)*s(m)-s(n)*S(m))/(M_PI*M_PI);
}

__device__
double B(int n, int m, double c){
    if (n==1){
        if (m!=1){
            return (2.0*m*(pow(-1,m)+1))/(M_PI*c*hypot(n,m)*(m*m-1));
        }
        else{
            return 0.0;
        }
    }
    else{
        return 0.0;
    }
}

__global__
void fillU(double *u, double t, int nx, int ny, int nmax, int mmax, double *x, double *y, double c){
    int idx = blockIdx.x*blockDim.x+threadIdx.x;
    int idy = blockIdx.y*blockDim.y+threadIdx.y;
    if (idx<=nx && idy<=ny){
        u[idx*(ny+1)+idy] = 0.0;
        for (int n=1;n<=nmax;n++){
            for (int m=1;m<=mmax;m++){
                u[idx*(ny+1)+idy] += (A(n,m)*cos(c*hypot(n,m)*t)+B(n,m,c)*sin(c*hypot(n,m)*t))*sin(n*x[idx])*sin(m*y[idy]);
            }
        }
    }
}

__global__
void fillVec(double *x, int nx, double d){
    int idx = blockIdx.x*blockDim.x+threadIdx.x;
    if (idx<=nx) x[idx] = idx*d;
}

void saveU(double *u, double *uC, int nx, int ny, int N, ofstream &ufile, int it){
    cudaMemcpy(uC,u,N*sizeof(double),cudaMemcpyDeviceToHost);
    for (int i=0;i<=nx;i++){
        for (int j=0;j<=ny;j++){
            ufile<<it<<'\t'<<uC[i*(ny+1)+j]<<'\n';
        }
    }
}