//! Four QR-style square finders plus colored orientation dots. No neural model.
#[derive(Clone, Copy, Debug)]
struct Point { x:f32,y:f32 }
#[derive(Clone,Copy)]
struct Finder {p:Point,scale:f32,hits:u32}
static mut ROBUST_CANDIDATES:[[f32;8];8]=[[0.;8];8];
static mut ROBUST_COUNT:usize=0;
#[no_mangle]
pub unsafe extern "C" fn robust_alignment_candidates(out:*mut f32)->i32{if out.is_null(){return 0;}let n=ROBUST_COUNT;std::ptr::copy_nonoverlapping(std::ptr::addr_of!(ROBUST_CANDIDATES) as *const f32,out,n*8);n as i32}

const CENTERS:[Point;4]=[Point{x:16.,y:16.},Point{x:368.,y:16.},Point{x:368.,y:112.},Point{x:16.,y:112.}];
const DOTS:[Point;4]=[Point{x:16.,y:36.},Point{x:368.,y:36.},Point{x:368.,y:92.},Point{x:16.,y:92.}];
const GRID:[Point;4]=[Point{x:32.,y:32.},Point{x:352.,y:32.},Point{x:352.,y:96.},Point{x:32.,y:96.}];
fn ratio(r:&[usize;5],edge_tolerant:bool)->Option<f32>{
    // LCD glow erodes the thin outer black rings; at the display edge they
    // may instead join the dark bezel. Estimate scale from the inner runs,
    // retaining both outer edges without demanding a QR-perfect thickness.
    if edge_tolerant {
        let unit=(r[1]+r[2]+r[3]) as f32/5.;
        if unit<1.5||(r[0] as f32)<unit*0.2||(r[4] as f32)<unit*0.2{return None;}
        for i in 1..4 {let k=if i==2{3.}else{1.};if (r[i] as f32-k*unit).abs()>k*unit*0.6{return None;}}
        return Some(unit);
    }
    let unit=r.iter().sum::<usize>() as f32/7.;
    if unit<1.5 || r.iter().any(|&n|n==0){return None;}
    for i in 0..5 {let k=if i==2 {3.}else{1.};if (r[i] as f32-k*unit).abs()>k*unit*0.55{return None;}}
    Some(unit)
}
fn cross(gray:&[u8],w:usize,h:usize,x:usize,y:usize,vertical:bool,t:u8,edge_tolerant:bool)->Option<(f32,f32)>{
    let length=if vertical{h}else{w};let center=if vertical{y}else{x};
    let dark=|pos:usize|{gray[if vertical{pos*w+x}else{y*w+pos}]<t};
    if !dark(center){return None;}
    let mut lo=center;while lo>0 && dark(lo-1){lo-=1;}
    let mut hi=center+1;while hi<length && dark(hi){hi+=1;}
    let mut r=[0usize;5];r[2]=hi-lo;
    let mut l=lo;while l>0 && !dark(l-1){r[1]+=1;l-=1;}
    while l>0 && dark(l-1){r[0]+=1;l-=1;}
    let mut q=hi;while q<length && !dark(q){r[3]+=1;q+=1;}
    while q<length && dark(q){r[4]+=1;q+=1;}
    let scale=ratio(&r,edge_tolerant)?;Some(((lo+hi) as f32/2.,scale))
}
fn homography(src:&[Point;4],dst:&[Point;4])->Option<[f32;8]>{
    let mut a=[[0f32;9];8];
    for i in 0..4 {
        let (x,y,u,v)=(src[i].x,src[i].y,dst[i].x,dst[i].y);
        a[2*i]=[x,y,1.,0.,0.,0.,-u*x,-u*y,u];
        a[2*i+1]=[0.,0.,0.,x,y,1.,-v*x,-v*y,v];
    }
    for c in 0..8 {
        let pivot=(c..8).max_by(|&i,&j|a[i][c].abs().total_cmp(&a[j][c].abs()))?;
        if a[pivot][c].abs()<1e-6{return None;}a.swap(c,pivot);
        let scale=a[c][c];for j in c..9 {a[c][j]/=scale;}
        for r in 0..8 {if r!=c {let f=a[r][c];for j in c..9 {a[r][j]-=f*a[c][j];}}}
    }
    Some(std::array::from_fn(|i|a[i][8]))
}
fn map(m:&[f32;8],p:Point)->Point {let d=m[6]*p.x+m[7]*p.y+1.;Point{x:(m[0]*p.x+m[1]*p.y+m[2])/d,y:(m[3]*p.x+m[4]*p.y+m[5])/d}}
fn rgb(rgba:&[u8],w:usize,h:usize,p:Point)->Option<[f32;3]>{
    if !p.x.is_finite()||!p.y.is_finite()||p.x<0.||p.y<0.||p.x>=w as f32-1.||p.y>=h as f32-1.{return None;}
    let x=p.x.floor() as usize;let y=p.y.floor() as usize;let fx=p.x-x as f32;let fy=p.y-y as f32;
    Some(std::array::from_fn(|c|{
        let v=|dx,dy|rgba[((y+dy)*w+x+dx)*4+c] as f32;
        v(0,0)*(1.-fx)*(1.-fy)+v(1,0)*fx*(1.-fy)+v(0,1)*(1.-fx)*fy+v(1,1)*fx*fy
    }))
}
#[no_mangle]
pub unsafe extern "C" fn locate_live_grid(rgba:*const u8,width:u32,height:u32,out:*mut f32)->i32{
    locate(rgba,width,height,out,&CENTERS,&DOTS,&GRID,false,4.)
}
unsafe fn locate(rgba:*const u8,width:u32,height:u32,out:*mut f32,centers:&[Point;4],dots:&[Point;4],grid:&[Point;4],fallback:bool,module:f32)->i32{
    if fallback{ROBUST_COUNT=0;}
    if rgba.is_null()||out.is_null()||width<160||height<64{return -1;}
    let (w,h)=(width as usize,height as usize);let pixels=std::slice::from_raw_parts(rgba,w*h*4);
    let gray:Vec<u8>=pixels.chunks_exact(4).map(|p|((p[0] as u32*77+p[1] as u32*150+p[2] as u32*29)>>8) as u8).collect();
    let lo=*gray.iter().min().unwrap();let hi=*gray.iter().max().unwrap();if hi-lo<50{return 0;}let t=lo+(hi-lo)/2;
    let mut finders:Vec<Finder>=Vec::new();
    for y in (0..h).step_by(2) {
        let mut runs:Vec<(usize,usize,bool)>=Vec::new();let mut start=0;let mut dark=gray[y*w]<t;
        for x in 1..=w {let next=x<w && gray[y*w+x]<t;if x==w||next!=dark {runs.push((start,x-start,dark));start=x;dark=next;}}
        for win in runs.windows(5) {
            if !win[0].2{continue;}
            let lengths=std::array::from_fn(|i|win[i].1);let Some(unit)=ratio(&lengths,module!=4.)else{continue;};
            let cx=win[2].0+win[2].1/2;
            let Some((cy,vs))=cross(&gray,w,h,cx,y,true,t,module!=4.)else{continue;};if (unit-vs).abs()>unit*0.65{continue;}
            let Some((rx,hs))=cross(&gray,w,h,cx,cy as usize,false,t,module!=4.)else{continue;};
            let Some((ry,_))=cross(&gray,w,h,rx as usize,cy as usize,true,t,module!=4.)else{continue;};
            let p=Point{x:rx,y:ry};let scale=(hs+vs)*0.5;
            if let Some(f)=finders.iter_mut().find(|f|(f.p.x-p.x).hypot(f.p.y-p.y)<scale*2.) {
                let n=f.hits as f32;f.p.x=(f.p.x*n+p.x)/(n+1.);f.p.y=(f.p.y*n+p.y)/(n+1.);f.hits+=1;
            }else{finders.push(Finder{p,scale,hits:1});}
        }
    }
    finders.retain(|f|f.hits>=3);finders.sort_by_key(|f|std::cmp::Reverse(f.hits));finders.truncate(8);
    if finders.len()<4{return finders.len() as i32;}
    let mut best_score=0.85f32;let mut best=None;
    let mut geometric_score=f32::MAX;let mut geometric_points=None;
    let targets=[[1.,0.,0.],[0.,1.,0.],[0.,0.,1.],[0.5,0.5,0.]];
    for a in 0..finders.len(){for b in a+1..finders.len(){for c in b+1..finders.len(){for d in c+1..finders.len(){
        let chosen=[finders[a],finders[b],finders[c],finders[d]];
        let min=chosen.iter().map(|f|f.scale).fold(f32::MAX,f32::min);let max=chosen.iter().map(|f|f.scale).fold(0.,f32::max);if max>min*2.5{continue;}
        let mut p=chosen.map(|f|f.p);let cx=p.iter().map(|v|v.x).sum::<f32>()/4.;let cy=p.iter().map(|v|v.y).sum::<f32>()/4.;
        p.sort_by(|a,b|(a.y-cy).atan2(a.x-cx).total_cmp(&(b.y-cy).atan2(b.x-cx)));
        let area=(0..4).map(|i|p[i].x*p[(i+1)%4].y-p[(i+1)%4].x*p[i].y).sum::<f32>().abs()/2.;if area<2000.{continue;}
        if fallback {
            // Finder module size and separation select a plausible panel without
            // requiring any color dot. Verified packet identity resolves orientation.
            let unit=chosen.iter().map(|f|f.scale).sum::<f32>()/4.;
            let lengths:Vec<f32>=(0..4).map(|i|(p[i].x-p[(i+1)%4].x).hypot(p[i].y-p[(i+1)%4].y)/unit).collect();
            let long=(centers[1].x-centers[0].x).abs()/module;
            let short=(centers[3].y-centers[0].y).abs()/module;
            for shift in 0..2 {
                let score=(0..4).map(|i|(lengths[i]/if (i+shift)%2==0{long}else{short}).ln().abs()).sum::<f32>();
                let support=chosen.iter().map(|f|f.hits as f32).sum::<f32>();
                let ranked=score+4./support;
                if score<2.5 && ranked<geometric_score {geometric_score=ranked;geometric_points=Some(p);}
            }
        }
        for direction in [1usize,3] {for rotation in 0..4 {
            let dst=std::array::from_fn(|i|p[(rotation+i*direction)%4]);
            let Some(m)=homography(centers,&dst)else{continue;};
            let mut score=0.;let mut ok=true;
            for i in 0..4 {
                let Some(color)=rgb(pixels,w,h,map(&m,dots[i]))else{ok=false;break;};
                let sum=color.iter().sum::<f32>().max(1.);
                let e=(0..3).map(|c|(color[c]/sum-targets[i][c]).powi(2)).sum::<f32>();
                if e>0.42{ok=false;break;}score+=e;
            }
            if ok && score<best_score {
                let q=grid.map(|g|map(&m,g));
                if q.iter().any(|p|p.x<0.||p.y<0.||p.x>=w as f32||p.y>=h as f32){continue;}
                if (q[1].x-q[0].x).hypot(q[1].y-q[0].y)<160.{continue;}
                best_score=score;best=Some(q);
            }
        }}
    }}}}
    if fallback {
        if let Some(p)=geometric_points {
            let mut n=0;
            // Put the dot-ranked orientation first when available, but never use
            // dots to reject an otherwise plausible panel.

            for direction in [1usize,3] {for rotation in 0..4 {
                let dst=std::array::from_fn(|i|p[(rotation+i*direction)%4]);
                let Some(m)=homography(centers,&dst)else{continue;};let q=grid.map(|g|map(&m,g));
                if q.iter().any(|v|!v.x.is_finite()||!v.y.is_finite()||v.x<0.||v.y<0.||v.x>=w as f32||v.y>=h as f32){continue;}
                let values:[f32;8]=std::array::from_fn(|i|if i%2==0{q[i/2].x}else{q[i/2].y});
                if (0..n).any(|j|(0..8).map(|i|(ROBUST_CANDIDATES[j][i]-values[i]).abs()).sum::<f32>()<1.){continue;}
                if n<8{ROBUST_CANDIDATES[n]=values;n+=1;}
            }}
            if let Some(q)=best {
                let values:[f32;8]=std::array::from_fn(|i|if i%2==0{q[i/2].x}else{q[i/2].y});
                if let Some(index)=(0..n).find(|&j|(0..8).map(|i|(ROBUST_CANDIDATES[j][i]-values[i]).abs()).sum::<f32>()<1.){let first=ROBUST_CANDIDATES[0];ROBUST_CANDIDATES[0]=ROBUST_CANDIDATES[index];ROBUST_CANDIDATES[index]=first;}else{if n<8{ROBUST_CANDIDATES[n]=ROBUST_CANDIDATES[0];n+=1;}ROBUST_CANDIDATES[0]=values;}
            }
            ROBUST_COUNT=n;
            if n>0{std::ptr::copy_nonoverlapping(std::ptr::addr_of!(ROBUST_CANDIDATES) as *const f32,out,8);return 4;}
        }
    }
    if let Some(q)=best {for i in 0..4 {*out.add(2*i)=q[i].x;*out.add(2*i+1)=q[i].y;}4}else{-2}
}
#[no_mangle]
pub unsafe extern "C" fn rectify_live_grid(rgba:*const u8,width:u32,height:u32,quad:*const f32,out:*mut u8)->i32{
    rectify(rgba,width,height,quad,out,640,128)
}
unsafe fn rectify(rgba:*const u8,width:u32,height:u32,quad:*const f32,out:*mut u8,ow:usize,oh:usize)->i32{
    if rgba.is_null()||quad.is_null()||out.is_null()||width<2||height<2{return -1;}
    let values=std::slice::from_raw_parts(quad,8);let dst=std::array::from_fn(|i|Point{x:values[2*i],y:values[2*i+1]});
    let src=[Point{x:0.,y:0.},Point{x:ow as f32,y:0.},Point{x:ow as f32,y:oh as f32},Point{x:0.,y:oh as f32}];
    let Some(m)=homography(&src,&dst)else{return 0;};
    let pixels=std::slice::from_raw_parts(rgba,width as usize*height as usize*4);let output=std::slice::from_raw_parts_mut(out,ow*oh*4);
    for y in 0..oh {for x in 0..ow {
        let Some(c)=rgb(pixels,width as usize,height as usize,map(&m,Point{x:x as f32+0.5,y:y as f32+0.5}))else{return 0;};
        let i=(y*ow+x)*4;for k in 0..3 {output[i+k]=c[k].round() as u8;}output[i+3]=255;
    }}1
}

#[no_mangle]pub unsafe extern "C" fn locate_robust_grid(rgba:*const u8,width:u32,height:u32,out:*mut f32)->i32{
 let centers=[Point{x:16.,y:16.},Point{x:368.,y:16.},Point{x:368.,y:144.},Point{x:16.,y:144.}];
 let dots=[Point{x:16.,y:36.},Point{x:368.,y:36.},Point{x:368.,y:124.},Point{x:16.,y:124.}];
 let grid=[Point{x:32.,y:32.},Point{x:352.,y:32.},Point{x:352.,y:128.},Point{x:32.,y:128.}];
 locate(rgba,width,height,out,&centers,&dots,&grid,true,4.)
}
#[no_mangle]pub unsafe extern "C" fn rectify_robust_grid(rgba:*const u8,width:u32,height:u32,quad:*const f32,out:*mut u8)->i32{rectify(rgba,width,height,quad,out,640,192)}

#[no_mangle]pub unsafe extern "C" fn rectify_flex_grid(rgba:*const u8,width:u32,height:u32,quad:*const f32,out:*mut u8,ow:u32,oh:u32)->i32{
 if ow<64||ow>2048||oh<32||oh>1024{return -1;}rectify(rgba,width,height,quad,out,ow as usize,oh as usize)
}

/// TI-84 CE LCD geometry: square finders, vertically expanded data grid.
/// These are actual 320x240 renderer pixel boundaries, not browser coordinates.
#[no_mangle]
pub unsafe extern "C" fn locate_ti84_grid(rgba:*const u8,width:u32,height:u32,out:*mut f32)->i32 {
 let centers=[Point{x:13.,y:14.},Point{x:307.,y:14.},Point{x:307.,y:224.},Point{x:13.,y:224.}];
 let dots=[Point{x:13.,y:47.},Point{x:307.,y:47.},Point{x:307.,y:191.},Point{x:13.,y:191.}];
 let grid=[Point{x:27.,y:40.},Point{x:293.,y:40.},Point{x:293.,y:198.},Point{x:27.,y:198.}];
 locate(rgba,width,height,out,&centers,&dots,&grid,true,24./7.)
}

/// Sample CE cells at their actual rounded LCD centers. Expanding a 96-column
/// grid by a uniform scale otherwise blends adjacent 2/3-pixel cells.
#[no_mangle]
pub unsafe extern "C" fn rectify_ti84_grid(rgba:*const u8,width:u32,height:u32,quad:*const f32,out:*mut u8,ow:u32,oh:u32)->i32 {
 if rgba.is_null()||quad.is_null()||out.is_null()||width<2||height<2||ow<96||oh<29||ow>2048||oh>1024{return 0;}
 let q=std::slice::from_raw_parts(quad,8);let dst=std::array::from_fn(|i|Point{x:q[2*i],y:q[2*i+1]});
 let src=[Point{x:27.,y:40.},Point{x:293.,y:40.},Point{x:293.,y:198.},Point{x:27.,y:198.}];
 let Some(m)=homography(&src,&dst)else{return 0;};let pixels=std::slice::from_raw_parts(rgba,width as usize*height as usize*4);let output=std::slice::from_raw_parts_mut(out,ow as usize*oh as usize*4);
 let mut cells=[[0u8;3];96*29];
 for row in 0..29{for col in 0..96 {
 let x0=27+(col*266+48)/96;let x1=27+((col+1)*266+48)/96;
 let y0=40+(row*158+14)/29;let y1=40+((row+1)*158+14)/29;
 let mut p=map(&m,Point{x:(x0+x1) as f32/2.,y:(y0+y1) as f32/2.});p.x-=0.5;p.y-=0.5;
 let Some(c)=rgb(pixels,width as usize,height as usize,p)else{return 0;};cells[row*96+col]=c.map(|v|v.round().clamp(0.,255.) as u8);
 }}
 for y in 0..oh as usize{for x in 0..ow as usize{let c=cells[(y*29/oh as usize)*96+x*96/ow as usize];let i=(y*ow as usize+x)*4;output[i..i+3].copy_from_slice(&c);output[i+3]=255;}}1
}
