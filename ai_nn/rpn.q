/ 02/10 - Preliminary implementation of anchor generating code - to convert into namespace. 
scales:2 xexp (3 4 5)
whctrs:{w:x[2]-x[0]+1;h:x[3]-x[1]+1;xctr:x[0]+0.5*(w-1);yctr:x[1]+0.5*(h-1);:(w;h;xctr;yctr)}
mkanchors:{[ws;hs;xctr;yctr] ws:((count ws),1)#ws;hs:((count hs),1)#hs;:(xctr-0.5*(ws-1)),'(yctr-0.5*(hs-1)),'(xctr+0.5*(ws-1)),'(yctr+0.5*(hs-1))}
ratioenum:{k:whctrs[x];w:k[0];h:k[1];xctr:k[2];yctr:k[3];size:w*h;sizeratios:size%y;ws:abs(sqrt(sizeratios));hs:abs(ws*y);:mkanchors[ws;hs;xctr;yctr]}
scaleenum:{k:whctrs[x];w:k[0];h:k[1];xctr:k[2];yctr:k[3];ws:w*scales;hs:h*scales;:mkanchors[ws;hs;xctr;yctr]}

x:(0;0;15;15);
kratios:(0.5; 1; 2);
re:ratioenum[x;kratios]

(scaleenum)each ratioenum[x;kratios]
