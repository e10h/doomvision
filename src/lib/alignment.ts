export const FRAME_WIDTH=384, FRAME_HEIGHT=128, GRID_X=32, GRID_Y=32;
export const FINDERS=[[16,16],[368,16],[368,112],[16,112]] as const;
export const DOTS=[[16,36],[368,36],[368,92],[16,92]] as const;
export function drawAlignment(ctx:CanvasRenderingContext2D,scale=3) {
  ctx.fillStyle='#ffffff';ctx.fillRect(0,0,FRAME_WIDTH*scale,FRAME_HEIGHT*scale);
  for(const [x,y] of FINDERS) {
    ctx.fillStyle='#000000';ctx.fillRect((x-14)*scale,(y-14)*scale,28*scale,28*scale);
    ctx.fillStyle='#ffffff';ctx.fillRect((x-10)*scale,(y-10)*scale,20*scale,20*scale);
    ctx.fillStyle='#000000';ctx.fillRect((x-6)*scale,(y-6)*scale,12*scale,12*scale);
  }
  const colors=['#ff0000','#00ff00','#0000ff','#ffff00'];
  DOTS.forEach(([x,y],i)=>{ctx.fillStyle=colors[i];ctx.fillRect((x-3)*scale,(y-3)*scale,6*scale,6*scale);});
}
