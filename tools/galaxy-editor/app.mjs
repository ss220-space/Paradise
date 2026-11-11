import { fitCamera, project, unproject, zoomCamera, niceStep, territoryStyle, lineDash, linkPoints, pointsPath, validateGalaxy, CORE_IDS, MARKER_SHAPES, markerPath, validMarkerImage } from './geometry.mjs';
const $ = (s) => document.querySelector(s);
const map = $('#map'), view = $('#view');
const clone = (v) => structuredClone(v);
const esc = (v) => String(v ?? '').replace(/[&<>"']/g, (c) => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
let chart, revision, token, camera, collection = 'systems', selected, undo = [], redo = [], drag, drawing = false;
let drawBackup, drawSnapshot;
const draftKey = 'paradise-galaxy-editor-v2';
const status = (text) => { $('#status').textContent = text; $('#status').title = text; };
const dims = () => [view.clientWidth, view.clientHeight];
const point = (e) => { const b=map.getBoundingClientRect();return [e.clientX-b.left,e.clientY-b.top]; };
const worldPoint = (e) => unproject(point(e),camera,...dims());
const at = (p) => project(p,camera,...dims());
const item = () => chart[collection].find((x)=>x.id===selected);
function remember() { undo.push(JSON.stringify(chart)); if(undo.length>60)undo.shift(); redo=[]; }
function changed() { try { localStorage.setItem(draftKey,JSON.stringify({chart,revision})); status('Есть несохранённые изменения'); } catch { status('Черновик не помещается в браузере. Сохрани в игру или экспортируй JSON.'); } render(); }
function refresh() { list(); inspect(); render(); }
function list() {
  $('#objects').innerHTML=chart[collection].map((o)=>`<option value="${esc(o.id)}" ${o.id===selected?'selected':''}>${esc(o.name||o.id)}</option>`).join('');
  $('#delete').disabled = collection==='systems' && CORE_IDS.includes(selected);
}
function input(label, value, apply, type='text', options) {
  const row=document.createElement('label'); row.append(document.createTextNode(label));
  const el=document.createElement(options?'select':type==='textarea'?'textarea':'input');
  if(options) for(const [v,text] of options) { const opt=document.createElement('option');opt.value=v;opt.textContent=text;el.append(opt); }
  else if(type!=='textarea')el.type=type;
  if(type==='textarea')row.className='wide';
  if(type==='number')el.step='any';
  if(type==='checkbox')el.checked=!!value;else el.value=value??'';
  el.addEventListener('change',()=>{ const v=type==='checkbox'?el.checked:type==='number'?Number(el.value):el.value; if(type==='number'&&!Number.isFinite(v))return; remember();if(apply(v)===false)return;changed();list(); });
  row.append(el);$('#inspector').append(row);return el;
}
function heading(text){const h=document.createElement('h3');h.textContent=text;$('#inspector').append(h);}
function inspect(){
  const panel=$('#inspector');panel.replaceChildren();const obj=item();if(!obj)return;
  heading(collection==='systems'?'Система':collection==='pois'?'Точка интереса':'Свойства');
  input('ID',obj.id,()=>{}).disabled=true;
  if(collection!=='links')input('Название',obj.name,(v)=>obj.name=v);
  if(['systems','pois'].includes(collection)){
    input('X',obj.x,(v)=>obj.x=v,'number');input('Y',obj.y,(v)=>obj.y=v,'number');
    if(collection==='systems') {
      const kinds=[['station','Станционный'],['service','Служебный'],['wilderness','Обычный'],['transit','Транзитный (без карты)']];
      if(!kinds.some(([id])=>id===obj.kind))kinds.push([obj.kind,obj.kind]);
      input('Тип сектора',obj.kind,v=>{obj.kind=v;inspect();},'text',kinds.filter(([id])=>id!=='transit'||!CORE_IDS.includes(obj.id)));
      if(obj.kind==='transit'){const hint=document.createElement('p');hint.textContent='Только точка маршрута: карта не создаётся, остановка и вход невозможны. Соедини с двумя соседними секторами. Перелёт продолжится до конечного обычного сектора.';panel.append(hint);}
    } else input('Тип',obj.kind,v=>obj.kind=v);
    input('Описание',obj.description,(v)=>obj.description=v,'textarea');
    if(collection==='systems')input('Государство',obj.faction||'',(v)=>obj.faction=v,'text',[['','Вне юрисдикции'],...chart.factions.map(f=>[f.id,f.name])]);
    else input('Цвет',obj.color,(v)=>obj.color=v,'color');
    const m=obj.marker||{};const set=(key,v)=>{obj.marker||={};obj.marker[key]=v;};
    heading('Маркер и подпись');
    input('Форма',m.shape|| (collection==='pois'||obj.kind==='transit'?'diamond':'circle'),v=>set('shape',v),'text',MARKER_SHAPES.map((x,i)=>[x,['Круг','Ромб','Квадрат','Треугольник','Звезда','Крест','Кольцо'][i]]));
    const numeric=(label,key,fallback,min,max)=>{const el=input(label,m[key]??fallback,v=>set(key,v),'number');el.min=min;el.max=max;};
    input('Цвет маркера',m.color||obj.color||chart.factions.find(f=>f.id===obj.faction)?.color||'#c3d2e3',v=>set('color',v),'color');
    input('Заливка',m.fill||m.color||'#c3d2e3',v=>set('fill',v),'color');
    numeric('Размер','size',collection==='pois'||obj.kind==='transit'?5:3.5,1,40);numeric('Толщина','width',1,.5,8);numeric('Прозрачность','opacity',1,0,1);numeric('Поворот °','rotation',0,-360,360);
    input('Показывать подпись',!!(m.showLabel??true),v=>set('showLabel',v),'checkbox');
    numeric('Размер подписи','labelSize',12,6,32);input('Цвет подписи',m.labelColor||m.color||'#c3d2e3',v=>set('labelColor',v),'color');numeric('Сдвиг подписи X','labelX',15,-200,200);numeric('Сдвиг подписи Y','labelY',4,-200,200);
    heading('Изображение вместо маркера');
    const upload=document.createElement('input');upload.type='file';upload.accept='image/png,image/jpeg,image/webp';upload.id='marker-image';
    upload.onchange=async()=>{const file=upload.files[0];if(!file)return;if(file.size>512*1024){status('Изображение больше 512 КиБ');return;}const data=await new Promise((resolve,reject)=>{const reader=new FileReader();reader.onload=()=>resolve(reader.result);reader.onerror=reject;reader.readAsDataURL(file);});if(!validMarkerImage(data)){status('Поддерживаются PNG, JPEG и WebP');return;}remember();set('image',data);changed();inspect();};panel.append(upload);
    numeric('Размер картинки','imageSize',32,8,160);
    if(validMarkerImage(m.image)){const preview=document.createElement('img');preview.src=m.image;preview.alt='Маркер';panel.append(preview);const remove=document.createElement('button');remove.textContent='Удалить изображение';remove.onclick=()=>{remember();delete obj.marker.image;changed();inspect();};panel.append(remove);}
    if(collection==='systems'&&obj.kind!=='transit'){
      heading('Веса генерации сектора');
      const defaults=obj.id==='station'?{hazards:.3,ruins:.7}:obj.id==='wilderness_a'?{hazards:1,ruins:2}:{hazards:0,ruins:0};
      for(const [key,label] of [['hazards','Общая плотность угроз'],['asteroids','Астероиды ×'],['emp','ЭМ-поля ×'],['carp','Карпы ×'],['ruins','Руины']]){
        const el=input(label,obj.generation?.[key]??defaults[key]??1,v=>{obj.generation||={};obj.generation[key]=v;},'number');el.min=0;el.max=5;el.step=.1;
      }
      const hint=document.createElement('p');hint.textContent='0 — отключено. Астероиды, ЭМ-поля и карпы умножаются на общую плотность. Руины независимы. Пустые сектора по умолчанию пусты. Служебный сектор не создаёт угрозы. Изменения применяются после перезапуска мира.';panel.append(hint);
    }
  }
  if(collection==='factions'){input('Цвет',obj.color,v=>obj.color=v,'color');}
  if(collection==='territories'){input('Государство',obj.faction,v=>obj.faction=v,'text',chart.factions.map(f=>[f.id,f.name]));pointsInput(obj,'points');}
  if(collection==='links'){
    for(const key of ['from','to'])input(key==='from'?'Откуда':'Куда',obj[key],v=>obj[key]=v,'text',chart.systems.map(s=>[s.id,s.name]));
    input('Состояние',obj.state,v=>obj.state=v,'text',[['active','Активная'],['closed','Закрытая'],['unstable','Нестабильная']]);input('Доступ',obj.access,v=>obj.access=v,'text',[['public','Общий'],['restricted','IFF']]);
    input('Длина перехода',obj.distance??1000,v=>obj.distance=v,'number');input('Цвет',obj.color,v=>obj.color=v,'color');pointsInput(obj,'waypoints');
  }
  if(['factions','territories','links'].includes(collection)){
    heading('Линии и заливка');const style=collection==='links'?obj:(obj.style||{});const set=(k,v)=>{if(collection==='links')obj[k]=v;else{obj.style||={};obj.style[k]=v;}};
    input('Линия',style.line||'solid',v=>set('line',v),'text',['solid','dashed','dotted','dash-dot'].map(x=>[x,x]));
    for(const [key,label,def] of [['width','Толщина',2],['opacity','Прозрачность',.85],['fillOpacity','Непрозрачность заливки',.18],['hatchOpacity','Непрозрачность штриховки',.25],['hatchSpacing','Шаг штриховки',12]])input(label,style[key]??def,v=>set(key,v),'number');
    input('Заливка',style.fill||'#193a51',v=>set('fill',v),'color');input('Штриховка',style.hatch||'none',v=>set('hatch',v),'text',['none','diagonal','cross','dots','horizontal'].map(x=>[x,x]));
  }
}
function pointsInput(obj,key){const el=input('Координаты [X, Y]',JSON.stringify(obj[key]||[]),v=>{try{const pts=JSON.parse(v);if(!Array.isArray(pts)||!pts.every(p=>Array.isArray(p)&&p.length===2&&p.every(Number.isFinite)))throw Error();obj[key]=pts;}catch{status('Нужен JSON-массив пар [X,Y]');return false;}},'textarea');el.className='points';}
function marker(obj,color,poi=false){const m=obj.marker||{},r=m.size??(poi||obj.kind==='transit'?5:3.5),shape=m.shape||(poi||obj.kind==='transit'?'diamond':'circle'),tint=m.color||color,d=markerPath(shape,r),size=m.imageSize??32;
  return `<g opacity="${esc(m.opacity??1)}" transform="rotate(${esc(m.rotation||0)})">${validMarkerImage(m.image)?`<image href="${esc(m.image)}" x="${-size/2}" y="${-size/2}" width="${size}" height="${size}"/>`:d?`<path d="${d}" fill="${shape==='cross'?'none':esc(m.fill||tint)}" stroke="${esc(tint)}" stroke-width="${esc(m.width??1)}"/>`:`<circle r="${r}" fill="${shape==='ring'?'none':esc(m.fill||tint)}" stroke="${esc(tint)}" stroke-width="${esc(m.width??1)}"/>`}</g>`;}
function render(){if(!chart||!camera)return;const [w,h]=dims();map.setAttribute('viewBox',`0 0 ${w} ${h}`);let svg='',defs='';const step=niceStep(85/camera.scale),lo=unproject([0,h],camera,w,h),hi=unproject([w,0],camera,w,h);
  for(let x=Math.floor(lo[0]/step)*step;x<=hi[0]+step;x+=step){const [px]=at([x,0]);svg+=`<path d="M${px} 0V${h}" stroke="#203346" stroke-width=".7"/><text x="${px+4}" y="${h-8}" fill="#58718c">${+x.toFixed(2)}</text>`;}
  for(let y=Math.floor(lo[1]/step)*step;y<=hi[1]+step;y+=step){const [,py]=at([0,y]);svg+=`<path d="M0 ${py}H${w}" stroke="#203346" stroke-width=".7"/>`;}
  for(const [i,t] of chart.territories.entries()){const f=chart.factions.find(f=>f.id===t.faction),s=territoryStyle(t,chart.factions),color=f?.color||'#8ea9bf',pitch=s.hatchSpacing;
    defs+=`<pattern id="hatch-${i}" width="${pitch}" height="${pitch}" patternUnits="userSpaceOnUse">${s.hatch==='dots'?`<circle cx="2" cy="2" r="1" fill="${esc(color)}"/>`:`<path d="${s.hatch==='horizontal'?`M0 2H${pitch}`:`M0 ${pitch}L${pitch} 0${s.hatch==='cross'?`M0 0L${pitch} ${pitch}`:''}`}" fill="none" stroke="${esc(color)}"/>`}</pattern>`;
    const d=pointsPath(t.points.map(at))+'Z';svg+=`<g data-kind="territories" data-id="${esc(t.id)}"><path d="${d}" fill="${esc(s.fill)}" fill-opacity="${s.fillOpacity}" stroke="${esc(color)}" stroke-width="${s.width}" stroke-opacity="${s.opacity}" stroke-dasharray="${lineDash(s.line)||''}"/>${s.hatch!=='none'?`<path d="${d}" fill="url(#hatch-${i})" opacity="${s.hatchOpacity}"/>`:''}</g>`;
  }
  for(const l of chart.links){const d=pointsPath(linkPoints(l,chart.systems).map(at));svg+=`<path data-kind="links" data-id="${esc(l.id)}" d="${d}" fill="none" stroke="${esc(l.color)}" stroke-width="${l.id===selected?4:l.width||1.5}" opacity="${l.opacity??.8}" stroke-dasharray="${lineDash(l.line)||''}"/>`;}
  for(const kind of ['pois','systems'])for(const obj of chart[kind]){const [x,y]=at([obj.x,obj.y]),m=obj.marker||{},color=obj.color||chart.factions.find(f=>f.id===obj.faction)?.color||'#c3d2e3';svg+=`<g data-kind="${kind}" data-id="${esc(obj.id)}" transform="translate(${x} ${y})"><circle r="${Math.max(15,(m.imageSize||0)/2,m.size||0)}" fill="transparent"/>${obj.id===selected?'<circle r="12" fill="none" stroke="#ffdb88" stroke-dasharray="3 3"/>':''}${marker(obj,color,kind==='pois')}${!!(m.showLabel??true)?`<text x="${m.labelX??15}" y="${m.labelY??4}" fill="${esc(m.labelColor||m.color||color)}" style="font-size:${m.labelSize||12}px">${esc(obj.name)}${obj.kind==='transit'?' [транзит]':''}</text>`:''}</g>`;}
  const obj=item();if(obj&&['territories','links'].includes(collection)){for(const [i,p] of (obj[collection==='links'?'waypoints':'points']||[]).entries()){const [x,y]=at(p);svg+=`<circle data-vertex="${i}" cx="${x}" cy="${y}" r="5" fill="#ffe4a2" stroke="#152538"/>`;}}
  map.innerHTML=`<defs>${defs}</defs>${svg}`;$('#undo').disabled=!undo.length;$('#redo').disabled=!redo.length;
}
$('#collection').onchange=()=>{cancelDrawing();collection=$('#collection').value;selected=chart[collection][0]?.id;refresh();};
$('#objects').onchange=()=>{cancelDrawing();selected=$('#objects').value;inspect();render();};
$('#add').onclick=()=>{cancelDrawing();remember();let i=1,id;do{id=`${collection}_${i++}`;}while(chart[collection].some(x=>x.id===id));const common={id,name:'Новый объект'};let obj;
  if(collection==='systems'||collection==='pois')obj={...common,x:+camera.x.toFixed(2),y:+camera.y.toFixed(2),kind:collection==='systems'?'wilderness':'landmark',...(collection==='pois'?{color:'#d4b779'}:{})};
  if(collection==='factions')obj={...common,color:'#7fcde0'};
  if(collection==='territories')obj={...common,faction:chart.factions[0]?.id,points:[[camera.x-20,camera.y-20],[camera.x+20,camera.y-20],[camera.x,camera.y+20]]};
  if(collection==='links'){if(chart.systems.length<2)return;obj={id,from:chart.systems[0].id,to:chart.systems[1].id,state:'active',access:'public',color:'#89c9ec',waypoints:[]};}
  chart[collection].push(obj);selected=id;changed();refresh();};
$('#delete').onclick=()=>{const obj=item();if(!obj||collection==='systems'&&CORE_IDS.includes(obj.id))return;cancelDrawing();remember();chart[collection]=chart[collection].filter(x=>x!==obj);if(collection==='systems')chart.links=chart.links.filter(l=>l.from!==obj.id&&l.to!==obj.id);if(collection==='factions'){chart.territories=chart.territories.filter(t=>t.faction!==obj.id);chart.systems.forEach(s=>{if(s.faction===obj.id)delete s.faction;});}selected=chart[collection][0]?.id;changed();refresh();};
const zoom=(factor,anchor=dims().map(n=>n/2))=>{camera=zoomCamera(camera,factor,anchor,...dims());render();};
$('#plus').onclick=()=>zoom(1.25);$('#minus').onclick=()=>zoom(.8);$('#fit').onclick=()=>{camera=fitCamera(chart,...dims());render();};
map.addEventListener('wheel',e=>{e.preventDefault();zoom(Math.exp(-Math.max(-500,Math.min(500,e.deltaY*(e.deltaMode===1?16:1)))*.0015),point(e));},{passive:false});
function cancelDrawing(){if(!drawing)return;const obj=item();obj[collection==='links'?'waypoints':'points']=drawBackup;drawing=false;$('#draw').classList.remove('active');render();}
function finishDrawing(){if(!drawing)return;const obj=item(),pts=obj[collection==='links'?'waypoints':'points'];if(collection==='territories'&&pts.length<3){status('Границе нужны минимум три точки');return;}drawing=false;undo.push(drawSnapshot);redo=[];$('#draw').classList.remove('active');changed();inspect();}
$('#draw').onclick=()=>{if(drawing){finishDrawing();return;}const obj=item();if(!obj||!['territories','links'].includes(collection)){status('Выбери границу или гиперсвязь');return;}drawSnapshot=JSON.stringify(chart);const key=collection==='links'?'waypoints':'points';drawBackup=clone(obj[key]);obj[key]=[];drawing=true;$('#draw').classList.add('active');render();};
function appendPoint(e){const obj=item(),key=collection==='links'?'waypoints':'points',pts=obj[key],p=worldPoint(e),limit=key==='points'?512:64;if(pts.length>=limit)return;if(pts.length&&Math.hypot(...at(pts.at(-1)).map((v,i)=>v-point(e)[i]))<4)return;pts.push(p.map(v=>+v.toFixed(2)));render();}
map.onpointerdown=e=>{if(e.button!==0)return;map.setPointerCapture(e.pointerId);if(drawing){appendPoint(e);drag={draw:true};return;}const target=e.target.closest('[data-id]'),vertex=e.target.closest('[data-vertex]');if(vertex){remember();drag={vertex:+vertex.dataset.vertex};return;}if(target){collection=target.dataset.kind;selected=target.dataset.id;$('#collection').value=collection;inspect();list();if(['systems','pois'].includes(collection)){remember();drag={object:item(),start:worldPoint(e),x:item().x,y:item().y};render();return;}}drag={pan:true,start:point(e),camera:{...camera}};render();};
map.onpointermove=e=>{const wp=worldPoint(e);$('#coords').textContent=`X ${wp[0].toFixed(1)} · Y ${wp[1].toFixed(1)}${drawing?' · Enter — завершить':''}`;if(!drag)return;if(drag.draw){if(e.shiftKey)appendPoint(e);return;}if(drag.object){drag.object.x=+(drag.x+wp[0]-drag.start[0]).toFixed(2);drag.object.y=+(drag.y+wp[1]-drag.start[1]).toFixed(2);}else if(drag.vertex!==undefined){item()[collection==='links'?'waypoints':'points'][drag.vertex]=wp.map(v=>+v.toFixed(2));}else if(drag.pan){const p=point(e);camera={...drag.camera,x:drag.camera.x-(p[0]-drag.start[0])/camera.scale,y:drag.camera.y+(p[1]-drag.start[1])/camera.scale};}render();};
map.onpointerup=e=>{if(drag?.object||drag?.vertex!==undefined){changed();inspect();}drag=null;if(map.hasPointerCapture(e.pointerId))map.releasePointerCapture(e.pointerId);};map.onpointercancel=()=>drag=null;
function history(back){cancelDrawing();const source=back?undo:redo,target=back?redo:undo;if(!source.length)return;target.push(JSON.stringify(chart));chart=JSON.parse(source.pop());changed();refresh();}
$('#undo').onclick=()=>history(true);$('#redo').onclick=()=>history(false);
document.addEventListener('keydown',e=>{if(e.key==='Escape')cancelDrawing();if(e.key==='Enter'&&drawing){e.preventDefault();finishDrawing();}if(!e.target.closest('input,textarea,select')&&e.ctrlKey&&e.key.toLowerCase()==='z'){e.preventDefault();history(!e.shiftKey);}});
$('#export').onclick=()=>{if(drawing)finishDrawing();const url=URL.createObjectURL(new Blob([JSON.stringify(chart,null,2)],{type:'application/json'})),a=document.createElement('a');a.href=url;a.download='overmap_galaxy.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);};
$('#import').onchange=async()=>{try{const doc=JSON.parse(await $('#import').files[0].text()),errors=validateGalaxy(doc);if(errors.length)throw Error(errors.join('\n'));cancelDrawing();remember();chart=doc;selected=chart[collection][0]?.id;camera=fitCamera(chart,...dims());changed();refresh();}catch(e){status(e.message);}$('#import').value='';};
$('#save').onclick=async()=>{try{if(drawing){finishDrawing();if(drawing)return;}const errors=validateGalaxy(chart);if(errors.length)throw Error(errors.join('\n'));const res=await fetch('/api/chart',{method:'POST',headers:{'Content-Type':'application/json','X-Editor-Token':token},body:JSON.stringify({chart,revision})});const data=await res.json();if(!res.ok)throw Error(data.error);revision=data.revision;localStorage.removeItem(draftKey);status('Сохранено. Перезапусти мир для применения.');}catch(e){status(e.message);}};
new ResizeObserver(()=>render()).observe(view);
try{const data=await(await fetch('/api/chart')).json();({chart,revision,token}=data);const saved=JSON.parse(localStorage.getItem(draftKey)||'null');if(saved&&saved.revision===revision&&validateGalaxy(saved.chart).length===0){chart=saved.chart;status('Восстановлен локальный черновик');}else status('Загружено. Сохранение — только по кнопке.');selected=chart.systems[0]?.id;camera=fitCamera(chart,...dims());refresh();}catch(e){status(e.message);}
