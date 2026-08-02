const sessions = {
  '力量 A': { summary:'下肢、推与核心。约 35-45 分钟，动作稳定优先。', exercises:[['自重深蹲','3 组 × 10-15 次','YaXPRqUwItQ'],['高位俯卧撑','3 组 × 8-12 次','0GsVJsS6474'],['臀桥','3 组 × 12-20 次','wPM8icPu6H8'],['扶椅后撤箭步蹲','2-3 组 × 每侧 8-10 次','xrPteyQLGAo'],['死虫式','3 组 × 每侧 6-10 次','I5xbsA71v1A'],['侧桥','2 组 × 每侧 15-30 秒','K2VljzCC16g']] },
  '力量 B': { summary:'臀腿、肩胛稳定与核心。约 30-40 分钟，动作稳定优先。', exercises:[['靠墙静蹲','3 组 × 35-60 秒','y-wV4Venusw'],['单腿臀桥','3 组 × 每侧 8-12 次','wPM8icPu6H8'],['高位俯卧撑','3 组 × 8-12 次','0GsVJsS6474'],['墙面滑手','3 组 × 8-12 次','CiM-s8I5dl8'],['俯卧 Y-T 抬臂','各 2 组 × 6-10 次','CiM-s8I5dl8'],['平板支撑','3 组 × 20-40 秒','pSHjTRCQxIw']] },
  '跑走耐力': { summary:'保持能说完整句子的强度；不适时改为快走。', exercises:[['热身快走','8 分钟','ml6cT4AZdqI'],['跑走交替','跑 2 分钟 + 走 2 分钟，7-8 轮','9L2b2khySLE'],['放松慢走','5 分钟','ml6cT4AZdqI'],['小腿拉伸','每侧 2 组 × 30 秒','YQmpO9VT2X4']] },
  '恢复日': { summary:'今天的份额是恢复。轻松完成即可，不追求训练感。', exercises:[['轻松快走','20-30 分钟','ml6cT4AZdqI'],['踝关节活动','每侧 1 分钟','IikP_teeLkI'],['墙面肩胛俯卧撑','2 组 × 10-15 次','g9d3B9J1Y9U'],['呼吸放松','3 分钟','aNXKjGFUlMs']] }
};
const repairs=[['单脚站立','每侧 2 组 × 30 秒','IikP_teeLkI'],['慢速提踵','3 组 × 12-20 次','YQmpO9VT2X4'],['墙面肩胛俯卧撑','2 组 × 10-15 次','g9d3B9J1Y9U'],['墙面滑手','2 组 × 8-12 次','CiM-s8I5dl8']];
const guides={
  '自重深蹲':{images:['/assets/guides/bodyweight-squat-ai.png'],steps:['双脚与髋同宽，脚尖自然微外，胸口保持打开。','臀部先向后坐，膝盖沿脚尖方向移动；下到可稳定控制的深度。','脚掌均匀发力站起，不要用膝盖内扣或借反弹起身。']},
  '高位俯卧撑':{images:['/assets/guides/incline-pushup-ai.png'],steps:['双手放在稳定的高支撑面，身体从头到脚跟成一条直线。','吸气下降，肘部向后约 30-45 度，不耸肩。','呼气推回；出现不稳、锐痛或麻木时立即停止。']},
  '臀桥':{images:['/assets/guides/bridge-start.svg','/assets/guides/bridge-up.svg'],steps:['仰卧屈膝，脚跟在膝盖正下方附近，腰背自然贴地。','用脚跟轻推地面，收紧臀部将髋抬到躯干与大腿接近直线。','顶部停一秒后慢慢下放；不要靠过度挺腰抬高。']},
  '扶椅后撤箭步蹲':{images:['/assets/guides/lunge-start.svg','/assets/guides/lunge-down.svg'],steps:['轻扶稳固椅背，先站稳，后脚向后迈一小步。','垂直下沉，前膝对准第二脚趾方向，重心保持在两脚之间。','以前脚推地回到站姿；脚踝不稳就缩短步幅或改靠墙静蹲。']},
  '死虫式':{images:['/assets/guides/dead-bug-ai.png'],steps:['仰卧，髋膝 90 度，双臂伸向天花板，轻轻收紧腹部。','缓慢伸远一侧腿和对侧手臂，始终让腰背稳定不拱起。','呼气回到起始位，再换边；范围小也没关系。']},
  '侧桥':{images:['/assets/guides/side-plank.png'],steps:['前臂放在肩正下方，双腿伸直或屈膝降低难度。','抬起髋部，让头、肩、髋、踝尽量连成直线。','保持呼吸，髋下沉或肩不适时结束该组。']},
  '靠墙静蹲':{images:['/assets/guides/wall-sit-ai.png'],steps:['背部贴墙，双脚向前迈出约半步到一步。','慢慢下滑到无膝痛且能稳定的角度，膝盖对准脚尖。','全脚掌着地、持续呼吸；膝痛或脚踝不适就提高角度。']},
  '单腿臀桥':{images:['/assets/guides/single-leg-bridge-ai.png'],steps:['先完成双腿臀桥姿势，再将一侧脚轻轻抬离地面。','支撑脚跟推地抬髋，骨盆尽量保持水平。','动作变形时改回双腿臀桥，不用追求抬得很高。']},
  '墙面滑手':{images:['/assets/guides/wall-slide-ai.png'],steps:['背靠墙或面向墙站立，肋骨轻轻收住，肩颈放松。','双手沿墙缓慢上滑，只到肩部稳定、无痛的范围。','下滑时保持肩胛平稳；卡住、不稳或疼痛就停止。']},
  '俯卧 Y-T 抬臂':{images:['/assets/guides/prone-yt-ai.png'],steps:['俯卧，额头轻贴毛巾，先把肩膀远离耳朵。','分别以 Y 和 T 形缓慢抬臂，幅度小、停一秒即可。','不要甩手或耸肩；出现不稳感时跳过。']},
  '平板支撑':{images:['/assets/guides/forearm-plank-ai.png'],steps:['前臂在肩正下方，双腿向后伸直，脚尖支地。','收紧臀腹，让身体保持长直线，不塌腰也不抬臀。','正常呼吸；姿势变形前结束，比硬撑更有效。']},
  '热身快走':{images:['/assets/guides/brisk-walk-ai.png'],steps:['前 2 分钟用舒适步速，脚掌轻柔落地。','逐步加快到身体微热但仍能完整说话的速度。','若脚踝疼痛或不稳，改为更慢速度并缩短时间。']},
  '跑走交替':{images:['/assets/guides/run-walk-ai.png'],steps:['先走 8 分钟热身，再用轻松跑开始每组。','跑段保持能控制的步频，不冲刺；走段让呼吸恢复。','脚踝出现疼痛、肿胀或不稳时当次改为全程快走。']},
  '放松慢走':{images:['/assets/guides/brisk-walk-ai.png'],steps:['训练后立刻切换为轻松步速。','让呼吸逐渐平稳，双肩放松。','至少走 5 分钟，再进行轻柔拉伸。']},
  '小腿拉伸':{images:['/assets/guides/calf-stretch-ai.png'],steps:['双手扶墙，一脚在后，后脚跟踩实地面。','后膝伸直时拉腓肠肌；微屈后膝时拉比目鱼肌。','保持轻微牵拉感，不弹震，也不要忍痛。']},
  '轻松快走':{images:['/assets/guides/brisk-walk-ai.png'],steps:['选择平坦路线，步速以能轻松交谈为准。','脚步落地保持平稳，避免急转和坡度冲刺。','脚踝不适就提前结束，不把恢复日练成高强度日。']},
  '踝关节活动':{images:['/assets/guides/ankle-circle.svg'],steps:['坐姿或扶墙站立，缓慢画圈活动脚踝。','分别做脚尖上勾、下压和内外转，幅度以舒适为准。','扭伤旧处若出现刺痛或肿胀，不要继续活动。']},
  '墙面肩胛俯卧撑':{images:['/assets/guides/wall-scapular-push-ai.png'],steps:['双手撑墙，手臂伸直，身体保持稳定。','不屈肘，只让肩胛轻轻靠近再推远。','动作小且慢，出现任何不稳感都应停止。']},
  '呼吸放松':{images:['/assets/guides/diaphragmatic-breathing-ai.png'],steps:['舒适躺下或坐直，一手放在腹部。','缓慢吸气让腹部轻轻鼓起，呼气比吸气稍长。','连续做 3 分钟，不憋气也不刻意用力。']},
  '单脚站立':{images:['/assets/guides/single-leg-stand-ai.png'],steps:['站在墙边或椅旁，先双脚稳定后抬起一只脚。','支撑脚三点均匀着地，视线看前方。','脚踝摇晃明显时可轻触墙面，不必强行闭眼。']},
  '慢速提踵':{images:['/assets/guides/slow-calf-raise-ai.png'],steps:['扶墙站稳，双脚平行，重心均匀落在前脚掌与脚跟。','缓慢抬起脚跟至最高点，停一秒。','用 2-3 秒慢慢放下；脚踝痛就减小幅度。']}
};
const $=selector=>document.querySelector(selector);
function localDateKey(date=new Date()){const y=date.getFullYear(),m=String(date.getMonth()+1).padStart(2,'0'),d=String(date.getDate()).padStart(2,'0');return `${y}-${m}-${d}`;}
const today=localDateKey();
let state=JSON.parse(localStorage.getItem('train-well-state')||'{}');
state.completedSessions=Array.isArray(state.completedSessions)?state.completedSessions:[];
state.setChecks=state.setChecks||{};
state.readiness=state.readiness||'normal';
let calendarCursor=new Date(new Date().getFullYear(),new Date().getMonth(),1);
function save(){localStorage.setItem('train-well-state',JSON.stringify(state));}
function latestStrength(){return [...state.completedSessions].reverse().find(item=>item.session==='力量 A'||item.session==='力量 B');}
function recommendedSession(){const last=latestStrength();return last?.session==='力量 A'?'力量 B':last?.session==='力量 B'?'力量 A':'力量 A';}
function prepareToday(){if(state.planDate===today)return;state.session=recommendedSession();state.planDate=today;save();}
function typeLabel(session){return session==='力量 A'?'A':session==='力量 B'?'B':session==='跑走耐力'?'跑':'修';}
function motionType(name){if(/深蹲|箭步|静蹲/.test(name))return 'squat';if(/俯卧撑|滑手|Y-T/.test(name))return 'push';if(/臀桥/.test(name))return 'bridge';if(/跑|走|踵|踝|站立/.test(name))return 'walk';return 'core';}
function setCount(dose){const match=dose.match(/(\d+)(?:-\d+)?\s*组/);return match?Number(match[1]):1;}
function setKey(name){return `${today}|${state.session}|${name}`;}
function checkedSets(name){return state.setChecks[setKey(name)]||[];}
function setButtons(name,dose){const checked=checkedSets(name),count=setCount(dose),single=count===1,allDone=checked.length===count,next=Array.from({length:count},(_,i)=>i).find(i=>!checked.includes(i)),status=allDone?'本动作已完成':single?'完成后记录本动作':'完成一组后自动进入下一组',summary=single?(allDone?'已完成':'待完成'):`${checked.length} / ${count} 组`;return `<div class="set-summary"><strong>${summary}</strong><span class="${allDone?'all-done':''}">${status}</span></div>${single?'':`<div class="set-bar" aria-label="已完成 ${checked.length} / ${count} 组"><i style="width:${checked.length/count*100}%"></i></div>`}<div class="set-checks">${allDone?'<button class="set-complete" disabled>✓ 本动作完成</button>':`<button class="set-next" data-set-name="${name}" data-set-index="${next}">${single?'完成本动作':`完成第 ${next+1} 组`}</button>`}${checked.map(index=>`<button class="set-undo" data-set-name="${name}" data-set-index="${index}">${single?'撤销完成':`第 ${index+1} 组 ✓`}</button>`).join('')}</div>`;}
function checkReminder(){if(!state.reminder||!('Notification'in window)||Notification.permission!=='granted')return;const [hour,minute]=state.reminder.split(':').map(Number),now=new Date(),due=new Date();due.setHours(hour,minute,0,0);const key=`train-well-reminded-${today}`;if(now>=due&&!localStorage.getItem(key)){new Notification('今天的训练份额',{body:`${state.session}：${sessions[state.session].summary}`,icon:'/icon.svg'});localStorage.setItem(key,'1');}}
function renderCalendar(){const year=calendarCursor.getFullYear(),month=calendarCursor.getMonth(),first=new Date(year,month,1),offset=(first.getDay()+6)%7,days=new Date(year,month+1,0).getDate();$('#calendar-title').textContent=new Intl.DateTimeFormat('zh-CN',{year:'numeric',month:'long'}).format(first);let cells=Array(offset).fill('<span class="calendar-day empty"></span>');for(let day=1;day<=days;day++){const key=localDateKey(new Date(year,month,day)),record=state.completedSessions.find(item=>item.date===key),isToday=key===today;cells.push(`<span class="calendar-day ${record?'has-record':''} ${isToday?'today':''}" title="${record?record.session:''}"><b>${day}</b>${record?`<i class="record ${record.session==='力量 A'?'strength-a':record.session==='力量 B'?'strength-b':record.session==='跑走耐力'?'run':'recovery'}">${typeLabel(record.session)}</i>`:''}</span>`);}$('#calendar-grid').innerHTML=cells.join('');const total=state.completedSessions.filter(item=>item.date.startsWith(`${year}-${String(month+1).padStart(2,'0')}`)).length;$('#calendar-summary').textContent=total?`本月已完成 ${total} 次训练`:'本月从第一份训练开始。';}
function render(){const current=sessions[state.session];$('#session-title').textContent=state.session;$('#session-summary').textContent=current.summary;$('#workout-list').innerHTML=current.exercises.map(([name,dose,videoId])=>`<article class="exercise"><span><strong>${name}</strong><small>${dose}</small>${setButtons(name,dose)}</span><button class="video-link" data-video-id="${videoId}" data-video-title="${name}" data-motion="${motionType(name)}" aria-label="查看 ${name} 图文指导" title="图文指导">▷</button></article>`).join('');$('#repair-list').innerHTML=repairs.map(([name,dose,videoId])=>`<article class="repair"><strong>${name}</strong><small>${dose}</small>${setButtons(name,dose)}<button class="repair-video" data-video-id="${videoId}" data-video-title="${name}" data-motion="${motionType(name)}">图文指导 ▷</button></article>`).join('');const done=state.completedSessions.some(item=>item.date===today);$('#complete-session').textContent=done?'今日已完成':'完成今日训练';$('#complete-session').classList.toggle('completed',done);document.querySelectorAll('[data-readiness]').forEach(button=>button.classList.toggle('selected',button.dataset.readiness===state.readiness));renderCalendar();}
function wikiTerm(name){return {'高位俯卧撑':'俯卧撑','扶椅后撤箭步蹲':'箭步蹲','单腿臀桥':'臀桥','俯卧 Y-T 抬臂':'肩胛骨','墙面肩胛俯卧撑':'肩胛骨','慢速提踵':'提踵','踝关节活动':'踝关节','热身快走':'快走','放松慢走':'快走','轻松快走':'快走','跑走交替':'跑步'}[name]||name;}
function openVideo(button){const name=button.dataset.videoTitle,guide=guides[name]||{steps:['先用舒适范围开始，动作保持缓慢可控。','训练中持续呼吸，避免借力或追求极限幅度。','出现疼痛、不稳或麻木时停止并改为恢复训练。']},images=guide.images||[];$('#video-title').textContent=`${name}指导`;$('#guide-images').innerHTML=images.map((src,index)=>`<img class="guide-image" src="${src}" alt="${name}动作示意 ${index+1}" loading="eager">`).join('');$('#guide-empty').textContent=images.length?'':'暂无已核验的公开授权图片，请按下方三步要点完成。';$('#guide-steps').innerHTML=guide.steps.map(step=>`<li>${step}</li>`).join('');$('#wiki-link').href=`https://baike.baidu.com/item/${encodeURIComponent(wikiTerm(name))}`;$('#video-credit').textContent=images.length?'图片：项目作者使用 AI 图像生成工具制作。':' ';$('#video-dialog').showModal();}
$('#readiness-options').addEventListener('click',event=>{if(!event.target.dataset.readiness)return;state.readiness=event.target.dataset.readiness;const messages={low:'今天降低训练量：改恢复日或每个动作少做一组。',normal:'按计划完成，所有动作保留 2 次余力。',high:'状态很好也不练到力竭。任选一个动作每组加 1 次。'};$('#status-copy').textContent=messages[state.readiness];save();render();});
$('#switch-session').onclick=()=>{const keys=Object.keys(sessions),index=keys.indexOf(state.session);state.session=keys[(index+1)%keys.length];save();render();};
let completionToastTimer;
function celebrateCompletion(){const button=$('#complete-session'),toast=$('#completion-toast');button.classList.add('celebrate');navigator.vibrate?.([20,45,35]);toast.classList.add('show');clearTimeout(completionToastTimer);completionToastTimer=setTimeout(()=>toast.classList.remove('show'),2200);}
$('#complete-session').onclick=()=>{if(state.completedSessions.some(item=>item.date===today))return;state.completedSessions.push({date:today,session:state.session});save();render();celebrateCompletion();};
document.addEventListener('click',event=>{const button=event.target.closest('[data-video-id]');if(!button)return;event.preventDefault();event.stopPropagation();openVideo(button);});
document.addEventListener('click',event=>{const button=event.target.closest('[data-set-name]');if(!button)return;const name=button.dataset.setName,index=Number(button.dataset.setIndex),key=setKey(name),current=checkedSets(name),willComplete=!current.includes(index);state.setChecks[key]=willComplete?[...current,index].sort((a,b)=>a-b):current.filter(item=>item!==index);save();render();if(willComplete){button.classList.add('pop');navigator.vibrate?.(25);}});
$('#close-video').onclick=()=>{$('#guide-images').innerHTML='';$('#video-dialog').close();};
$('#previous-month').onclick=()=>{calendarCursor=new Date(calendarCursor.getFullYear(),calendarCursor.getMonth()-1,1);renderCalendar();};
$('#next-month').onclick=()=>{calendarCursor=new Date(calendarCursor.getFullYear(),calendarCursor.getMonth()+1,1);renderCalendar();};
$('#settings-button').onclick=()=>$('#settings-dialog').showModal();$('#save-settings').onclick=()=>{state.reminder=$('#reminder-time').value;save();if('Notification'in window&&Notification.permission==='default')Notification.requestPermission();};
$('#today-date').textContent=new Intl.DateTimeFormat('zh-CN',{month:'long',day:'numeric',weekday:'short'}).format(new Date());prepareToday();render();checkReminder();if('serviceWorker'in navigator)navigator.serviceWorker.register('/sw.js');
