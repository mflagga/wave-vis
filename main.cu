#include "header.cuh"

int main(){

    // parametry
    // fali
    const double c = 1.0;
    // techniczne
    const int nmax = 5;
    const int mmax = 5;
    const double d = 0.01;
    const double dt = 0.05;
    // animacji
    const double tmax = 10.0;
    const int fps = 10;
    const double seconds = 10.0;

    // parametry wtórne
    const int nx = int(M_PI/d);
    const int ny = int(M_PI/d);
    const int N = (nx+1)*(ny+1);
    double t;
    const int itmax = int(tmax/dt);
    const int co_ktora=int(itmax/(fps*seconds));
    const int ip = itmax/100;

    // architektura
    int tp1 = 256;
    int tp2 = 8;
    dim3 threads1 = dim3(tp1);
    dim3 blocks1 = dim3((nx+threads1.x+1)/threads1.x);
    dim3 threads2 = dim3(tp2,tp2);
    dim3 blocks2 = dim3((nx+threads2.x+1)/threads2.x,(ny+threads2.y+1)/threads2.y);

    // alokacja i inicjalizacja
    double *x; cudaMalloc(&x,(nx+1)*sizeof(double));
    double *y; cudaMalloc(&y,(ny+1)*sizeof(double));
    double *u; cudaMalloc(&u,N*sizeof(double));
    fillVec<<<blocks1,threads1>>>(x,nx,d);
    fillVec<<<blocks1,threads1>>>(y,ny,d);
    cudaDeviceSynchronize();
    double *uC = new double[N];

    // zmienne do petli
    ofstream ufile("u.dat");

    // mierzenie czasu
    auto start = chrono::high_resolution_clock::now();

    // pętla po czasie // trzeba ją zmienić. założenie jest błędne, chcemy zapisywać każdą klatkę bo rozwiązanie nie zależy od dt
    for (int it=0; it<=itmax; it++){
        if (it%ip==0) cout<<"\r"<<it/ip<<"%"<<flush;
        t = it*dt;
        fillU<<<blocks2,threads2>>>(u,t,nx,ny,nmax,mmax,x,y,c);
        cudaDeviceSynchronize();
        if (it%co_ktora==0) saveU(u,uC,nx,ny,N,ufile,it);
    }
    cout<<'\n';

    // mierzenie czasu
    auto stop = chrono::high_resolution_clock::now();
    auto duration = chrono::duration_cast<chrono::milliseconds>(stop-start);
    cout<<"Czas pętli: "<<duration.count()<<" ms\n";

    // przekaz c++ -> python
    ofstream misc("misc.dat");
    misc
    <<nx<<'\n'
    <<ny<<'\n'
    <<d<<'\n'
    <<dt<<'\n'
    ;
    // przekaz c++ -> ffmpeg
    ofstream fpsfile("fps.dat");
    fpsfile<<fps;
    fpsfile.close();

    // czystki
    cudaFree(x);
    cudaFree(y);
    ufile.close();
    cudaFree(u);
    delete [] uC;
    misc.close();

    // return zero
    return 0;
}